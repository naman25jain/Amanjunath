import {LightningElement,track,api} from 'lwc';
import getCaseData from '@salesforce/apex/CredVerificationListViewController.getCaseRecords';
import checkExistingReviewer from '@salesforce/apex/EntityCredVerController.checkExistingReviewer';
import updateCaseStatus from '@salesforce/apex/EntityCredVerController.updateCaseStatus';
import updateEntityReviewer from '@salesforce/apex/EntityCredVerController.updateEntityReviewer';
import getConstants from "@salesforce/apex/OnlineNotaryConfirmationController.getConstants";
import getMessage from '@salesforce/apex/RestrictedMessage.getMessage';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; 
import enrollmentCredentialMessage from '@salesforce/label/c.Enrollment_Credential_Toast_Message';
const appSpecColumns = [{
    label:'Case Number',
    fieldName:'CaseID',
    type:'button',
    sortable:'true',
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
}];
const columns = [
    {
        label:'Case Number', fieldName:'CaseID', type:'button',sortable: "true",
        typeAttributes:{
            label:{
                fieldName:'CaseNumberUrl'

            }
        }
    },{
        label:'Rest Of Name',
        fieldName:'restOfName',
        type:'Text',
        sortable: "true"
    },{
        label:'Last Name',
        fieldName:'ContactLastName',
        type:'Text',
        sortable: "true"
    },{
        label:'ECFMG ID',
        fieldName:'MyIntealth_ID__c',
        type:'Formula',
        sortable: "true"
    },{
        label:'Unique Medical School ID',
        fieldName:'AccountUniqueMedicalSchoolID',
        type:'Text',
        sortable: "true"
    },{
        label:'Date of Birth',
        fieldName:'Date_of_Birth__c',
        sortable: "true"
    },{
        label:'Status',
        fieldName:'Entity_External_Status__c',
        type:'Picklist',
        sortable: "true"
    },{
        label:'Record Available Date',
        fieldName:'Record_Available_Date__c',
        sortable: "true"
    }
];
export default class CredentialVerificationData extends LightningElement{
    _constants;
    @track _currentEnt;
    @track  returncs;
    @track nodata;
    @track data = [];
    @track columns = columns;
    @track sortBy;
    @track sortDirection;
    @track confirmLang = null;
    @track currentCaseId = null;
    @track isActiveReqFound = false;
    @track rowNumberOffset;
    @track recordsToDisplay = [];
    extStatus;
    caseNumber;
    _currCaseId;
    _applicantSpecific = false;
    @api applicantId = '';
    @api
    get applicantSpecific(){
        return this._applicantSpecific;
    }
    set applicantSpecific(value){
        this._applicantSpecific = value;
        if(this._applicantSpecific){
            this.columns = appSpecColumns;
        }
    }
    @api
    get currentEntity(){
        return this._currentEnt;
    }
    set currentEntity(value){
        this.setAttribute('currentEntity', value);
        this._currentEnt = value;
        if(!this._applicantSpecific){
            this.setup();
        }        
    }
    @api
    get currCaseId(){
        return this._currCaseId;
    }
    set currCaseId(value){
        this._currCaseId = value;
        if(value && value!=''){            
            this.setup();
        }
    }
    @api setup(){
        this.isActiveReqFound = false;
        this.currentData =[];
        getCaseData({currentEntityId:this._currentEnt,applicantId: this.applicantId,currCaseId: this._currCaseId})
        .then(prData=>{
            if(prData){
                let rowNum = 0;
                let recList = [];
                for(let key in prData){
                    if(prData.hasOwnProperty(key)){
                        this.isActiveReqFound = true;
                        this.performanceDataRecords = [];
                        let tempRecord = {
                            CaseID: prData[key]['caseId'],
                            CaseNumberUrl: prData[key]['caseNumber'],                            
                            caseService: prData[key]['caseService'],
                            entityConId: prData[key]['entityConId'],
                            restOfName: prData[key]['restOfName'],
                            ContactLastName: prData[key]['lastName'],
                            MyIntealth_ID__c: prData[key]['myIntealthId'],
                            AccountUniqueMedicalSchoolID: prData[key]['uniqueMedicalSchoolID'],
                            Date_of_Birth__c: prData[key]['dateOfBirth'],
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
                if(!this._applicantSpecific && this.template.querySelector('.paginatorAR') !== null){
                    this.template.querySelector('.paginatorAR').records = this.currentData;
                    this.template.querySelector('.paginatorAR').totalRecords = this.currentData.length;
                    this.template.querySelector('.paginatorAR').setRecordsPerPage();
                }else if(this._applicantSpecific){
                    this.recordsToDisplay = this.currentData;
                }
            }else{
                this.currentData = [];
                this.isActiveReqFound = false;
            }
            if(this._applicantSpecific){
                const selectEvent = new CustomEvent("activecount",{detail:this.currentData.length});
                this.dispatchEvent(selectEvent);
            }
        })
        .catch(error=>{
            window.console.error('Error: '+error);
        })
    }
    handleSortdata(event){
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
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
        this.recordsToDisplay = this.data;
    }
    handleRowActions(event){
        let row = event.detail.row;
        let caseId = row.CaseID;
        this.currentCaseId = caseId;
        this.caseNumber = row.CaseNumberUrl;
        this.extStatus = row.Entity_External_Status__c;
        this.stepNumber = row.Entity_Review_Step__c;
        this.confirmLang = 'Case ' + this.caseNumber + ' is already under review. Do you want to reassign it to you and proceed';
        let entityConId = row.entityConId;
        let caseService = row.caseService;
        let messageWrapper = {"accountId" : this._currentEnt,
        "contactId" : entityConId,
        "service": caseService +' - Internal and External'};
        getMessage({jsonInput: JSON.stringify(messageWrapper)})
        .then(result => {
            if(result){
                const evt = new ShowToastEvent({
                    title: 'Restriction Applied',
                    message: enrollmentCredentialMessage,
                    variant: 'error',
                });
                this.dispatchEvent(evt);
            }else{
                if(this.applicantSpecific){
                    this.template.querySelector('[data-id="leaveExistingWindow"]').show();
                }else{
                    this.alreadyInProcess();
                }
            }
        })
        .catch(error => {
            window.console.error(error);
        });
        
    }
    showDetail(caseId){
        let caseInfo = {caseId:caseId,stepNumber:this.stepNumber,caseNumber:this.caseNumber};
        const selectEvent = new CustomEvent("nextevent",{
            detail:caseInfo
        });
        this.dispatchEvent(selectEvent);
    }
    connectedCallback(){
        getConstants().then(result2=>{
            this._constants = result2;
        })
    }
    proceedSubmit(){
        this.updateEntityReviewerJs(this.currentCaseId);
        this.showDetail(this.currentCaseId);
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
    // checks if the record is already being processed by some one else.
    alreadyInProcess(){
        if(this.extStatus === 'In Process'){
            checkExistingReviewer({
                caseId: this.currentCaseId
            }).then(result1=>{
                if(result1){
                    this.showDetail(this.currentCaseId);
                }else{
                    this.template.querySelector('[data-id="confirmationWindow"]').show();
                }
            }).catch(err=>window.console.error('Error: ',err));
        }else{
            this.updateReviewerAndStatusJs(this.currentCaseId);
            this.showDetail(this.currentCaseId);
        }
    }
    proceedNext(){
        const selectEvent = new CustomEvent("removecomp",{});
        this.dispatchEvent(selectEvent);
        this.alreadyInProcess();
    }
}