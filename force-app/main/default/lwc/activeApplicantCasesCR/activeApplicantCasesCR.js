import {LightningElement,api,track} from 'lwc';
import getCaseRecords from '@salesforce/apex/CredVerificationListViewController.getCaseRecords';
import checkExistingReviewer from '@salesforce/apex/EntityCredVerController.checkExistingReviewer';
import updateCaseStatus from '@salesforce/apex/EntityCredVerController.updateCaseStatus';
import updateEntityReviewer from '@salesforce/apex/EntityCredVerController.updateEntityReviewer';
import getConstants from "@salesforce/apex/OnlineNotaryConfirmationController.getConstants";
const columns = [
    {
        label:'Case Number', fieldName:'CaseID', type:'button',sortable: "true",
        typeAttributes:{
            label:{
                fieldName:'CaseNumberUrl'
            }
        }
    },{
        label:'Record Available Date',
        fieldName:'Record_Available_Date__c',
        sortable: "true"
    },{
        label:'Status',
        fieldName:'Entity_External_Status__c',
        type:'Picklist',
        sortable: "true"
    }
];
export default class ActiveApplicantCasesCR extends LightningElement{
    _caseId;
    _appId;
    _constants;
    caseNum;
    @track _currentEnt;
    @track data = [];
    @track columns = columns;
    @track sortBy;
    @track sortDirection;
    @track currentCaseId = null;
    @track confirmLang = null;
    @track rowNumberOffset;
    @track recordsToDisplay = [];
    @api
    get caseId(){
        return this._casedId;
    }
    set caseId(value){
        if(value){
            this._caseId = value;
        }
    } 
    @api
    get currentEntity(){
        return this._currentEnt;
    }
    set currentEntity(value){
        this.setAttribute('currentEntity',value);
        this._currentEnt = value;
    }  
    @api
    get appId(){
        return this._appId;
    }
    set appId(value){
        this.setAttribute('appId',value);
        this._appId = value;
    }  
    handleSortdata(event){
        const {fieldName: sortedBy,sortDirection} = event.detail;
        const cloneData = [...this.recordsToDisplay];
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.recordsToDisplay = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
        this.sortData(event.detail.fieldName, event.detail.sortDirection);
    }
    sortData(fieldname, direction){
        let parseData = JSON.parse(JSON.stringify(this.data));
        let keyValue = (a) => {
            return a[fieldname];
        };
        let isReverse = direction === 'asc' ? 1: -1;
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x).toLowerCase() : ''; // handling null values
            y = keyValue(y) ? keyValue(y).toLowerCase(): '';
            return isReverse * ((x > y) - (y > x));
        });
        this.data = parseData;
    } 
    handleRowActions(event){
        let row = event.detail.row;
        let caseId = row.CaseID;
        this.currentCaseId = caseId;
        let caseNumber = row.CaseNumberUrl;    
        this.caseNum = caseNumber;
        let extStatus = row.Entity_External_Status__c;        
        this.stepNumber = row.Entity_Review_Step__c;
        this.confirmLang = 'Case ' + caseNumber + ' is already under review. Do you want to reassign it to you and proceed';
        if(extStatus === 'In Process'){
            checkExistingReviewer({
                caseId: caseId
            }).then(result1=>{
                if(result1){
                    this.showDetail(caseId,caseNumber);
                }else{
                    this.template.querySelector('[data-id="confirmationWindow"]').show();
                }
            }).catch(err=>window.console.error('Error: ',err));
        }else{
            this.updateReviewerAndStatusJs(caseId);
            this.showDetail(caseId,caseNumber);
        }
    }
    showDetail(caseId,caseNumber){
        let caseInfo = {caseId: caseId, stepNumber: this.stepNumber, caseNumber: caseNumber};
        const selectEvent = new CustomEvent("nextevent",{
            detail:caseInfo
        });
        this.dispatchEvent(selectEvent);
    }
    connectedCallback(){
        getConstants().then(result2=>{
            this._constants = result2;
        })
        this.currentData =[];
        getCaseRecords({currentEntityId: this._currentEnt, applicantId: this._appId, currCaseId: this._caseId})
        .then(prData=>{
            if(prData){
                let rowNum = 0; 
                let recList = [];
                for(let key in prData){
                    if(prData.hasOwnProperty(key)){
                        let tempRecord = {
                            CaseID: prData[key]['caseId'],
                            CaseNumberUrl: prData[key]['caseNumber'],                            
                            caseService: prData[key]['caseService'],
                            entityConId: prData[key]['entityConId'],
                            Record_Available_Date__c: prData[key]['recordAvailableDate'],
                            Entity_External_Status__c: prData[key]['status'],
                            Entity_Review_Step__c: prData[key]['reviewStep']
                        };
                        tempRecord.rowNumber = '' + (rowNum + 1);
                        recList.push(tempRecord);
                    }
                    rowNum = rowNum + 1;
                }
                this.data = [...recList];
                this.currentData = this.data;
                if(this.template.querySelector('.paginatorAR') !== null){
                    this.template.querySelector('.paginatorAR').records = this.currentData;
                    this.template.querySelector('.paginatorAR').totalRecords = this.currentData.length;
                    this.template.querySelector('.paginatorAR').setRecordsPerPage();
                }
            }else{
                this.currentData = [];
            }
        }).catch(error=>{
            window.console.error('get Error: ' + JSON.stringify(error));
        });
    }
    proceedSubmit(){
        this.updateEntityReviewerJs(this.currentCaseId);
        this.showDetail(this.currentCaseId, this.caseNum);
    }
    updateEntityReviewerJs(caseId){
        updateEntityReviewer({caseId: caseId}).catch(err=>window.console.error('Error: ',err));
    }
    updateReviewerAndStatusJs(caseId){
        updateEntityReviewer({caseId: caseId}).then(result3=>{
            updateCaseStatus({
                caseId: caseId,
                status: this._constants.LWC_CASE_STATUS_IN_REVIEW_AT_ENTITY
            });
        }).catch(err=>window.console.error('Error: ',err));
    }
    handleARPaginatorChange(event){
        this.recordsToDisplay = event.detail;
        if(this.recordsToDisplay.length > 0){
            this.rowNumberOffset = this.recordsToDisplay[0].rowNumber - 1;
        }
    }
    showCredRevLandPage(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('credreviewlist',{});
        this.dispatchEvent(selectEvent);
    }
}