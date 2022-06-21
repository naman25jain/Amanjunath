import { LightningElement,track,api } from 'lwc';
import getEVActiveCase from '@salesforce/apex/EnrollmentVerificationEntityController.getEVActiveCase';
import getEVCompletedCase from '@salesforce/apex/EnrollmentVerificationEntityController.getEVCompletedCase';
import getMessage from '@salesforce/apex/RestrictedMessage.getMessage';
import performanceErrormsg from '@salesforce/label/c.Restriction_Service_Error_Message';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; 
import Id from '@salesforce/user/Id';
import enrollmentCredentialMessage from '@salesforce/label/c.Enrollment_Credential_Toast_Message';
import getContact from '@salesforce/apex/EnrollmentVerificationEntityController.getContact';
export default class EvEntityListViews extends LightningElement {
    userId=Id;
    @track col = [{    
        label: 'Case Number',
        fieldName: 'caseNumber',
        type: 'button',
        initialWidth: 100,
        sortable: true,
        typeAttributes: {
            title: 'Case Number',
            variant: 'border-filled',
            disabled: false,
            class:'caseNumberTd',
            wrapText: true,  
            label: {fieldName: 'caseNumber'}          
        }      
    },
    {        
        label: 'Rest of Name',
        fieldName: 'restOfName',
        initialWidth: 150,
        sortable: true,
        typeAttributes: {            
            wrapText: true
        }
    },
    {        
        label: 'Last Name',
        fieldName: 'lastName',
        initialWidth: 150,
        sortable: true,
        typeAttributes: {            
            wrapText: true
        }
    },
    {        
        label: 'USMLE ID',
        fieldName: 'usmleId',
        initialWidth: 100,
        sortable: true,
        typeAttributes: {            
            wrapText: true
        }
    },
    {        
        label: 'Unique Medical School ID',
        fieldName: 'uniqueMedicalSchoolID',
        initialWidth: 200,
        sortable: true,
        typeAttributes: {            
            wrapText: true
        }
    },
    {        
        label: 'Date of Birth',
        fieldName: 'dateOfBirth',
        initialWidth: 150,
        sortable: true,
        typeAttributes: {            
            wrapText: true
        }
    },
    {        
        label: 'Exam Type',
        fieldName: 'examType',
        initialWidth: 150,
        sortable: true,
        wrapText: true
    },
    {        
        label: 'Eligibility Period',
        fieldName: 'eligibilityPeriod',
        initialWidth: 200,
        sortable: true,
        wrapText: true
    },    
    {        
        label: 'Record Available Date',
        fieldName: 'recordAvailableDate',
        initialWidth: 200,
        sortable: true,
        typeAttributes: {            
            wrapText: true
        }       
    },
    {        
        label: 'Status',
        fieldName: 'status',
        initialWidth: 100,
        sortable: true,
        typeAttributes: {            
            wrapText: true
        }
    },
];  
    @track columns = [{    
        label: 'Case Number',
        fieldName: 'caseNumber',
        type: 'button',
        initialWidth: 100,
        sortable: true,
        typeAttributes: {
            title: 'Case Number',
            variant: 'border-filled',
            disabled: false,
            class:'caseNumberTd',
            wrapText: true,  
            label: {fieldName: 'caseNumber'}          
        }      
    },
    {        
        label: 'Rest of Name',
        fieldName: 'restOfName',
        initialWidth: 150,
        sortable: true,
        typeAttributes: {            
            wrapText: true
        }
    },
    {        
        label: 'Last Name',
        fieldName: 'lastName',
        initialWidth: 150,
        sortable: true,
        typeAttributes: {            
            wrapText: true
        }
    },
    {        
        label: 'USMLE ID',
        fieldName: 'usmleId',
        initialWidth: 100,
        sortable: true,
        typeAttributes: {            
            wrapText: true
        }
    },
    {        
        label: 'Unique Medical School ID',
        fieldName: 'uniqueMedicalSchoolID',
        initialWidth: 200,
        sortable: true,
        typeAttributes: {            
            wrapText: true
        }
    },
    {        
        label: 'Date of Birth',
        fieldName: 'dateOfBirth',
        initialWidth: 150,
        sortable: true,
        typeAttributes: {            
            wrapText: true
        }
    },
    {        
        label: 'Exam Type',
        fieldName: 'examType',
        initialWidth: 150,
        sortable: true,
        wrapText: true
    },
    {        
        label: 'Eligibility Period',
        fieldName: 'eligibilityPeriod',
        initialWidth: 200,
        sortable: true,
        wrapText: true
    },    
    {        
        label: 'Record Available Date',
        fieldName: 'recordAvailableDate',
        initialWidth: 200,
        sortable: true,
        typeAttributes: {            
            wrapText: true
        }       
    },
    {        
        label: 'Status',
        fieldName: 'status',
        initialWidth: 100,
        sortable: true,
        typeAttributes: {            
            wrapText: true
        }
    },
    {        
        label: 'Deadline',
        fieldName: 'deadline',
        type: 'deadlineIcon',
        initialWidth: 100,
        cellAttributes: {
            iconName: { fieldName: 'deadlineWarning' },
            iconLabel: '',
            iconPosition: 'left',
            iconAlternativeText: 'Important',
        },
    }
];    
    @track data = [];
    @track dataCom = [];
    @track defaultSortDirection = 'asc';
    @track sortDirection = 'asc';
    @track sortedBy;
    @track defaultSortDirectionCom = 'asc';
    @track sortDirectionCom = 'asc';
    @track sortedByCom;
    @track isActiveReqFound = false;
    @track isCompletedReqFound = false;
    @track activeRequests = [];
    @track recordsToDisplay = [];
    @track rowNumberOffset;
    @track completedRequests = [];
    @track recordsToDisplayCom = [];
    @track rowNumberOffsetCom;  
    @track activeCount;
    @track completedCount;
    @track isExptDataAvailable = false;
    @api refreshListOnload = false;
    @track hrefdata;
    @api restrictedAccess;
    @track attributesList = [];
    // Used to sort the columns
    sortBy(field, reverse, primer) {
        const key = primer ?
            function (x) {
                return primer(x[field]);
            } :
            function (x) {
                return x[field];
            };

        return function (a, b) {
            var x = key(a) ? key(a).toLowerCase() : '';
            var y = key(b) ? key(b).toLowerCase() : '';
            return reverse * ((x > y) - (y > x));
        };
    }
    onHandleSort(event){
        const {
            fieldName: sortedBy,
            sortDirection
        } = event.detail;
        const cloneData = [...this.recordsToDisplay];
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.recordsToDisplay = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }
    onHandleSortCompleted(event){
        const {
            fieldName: sortedByCom,
            sortDirection
        } = event.detail;
        const cloneDataCom = [...this.recordsToDisplayCom];
        cloneDataCom.sort(this.sortBy(sortedByCom, sortDirection === 'asc' ? 1 : -1));
        this.recordsToDisplayCom = cloneDataCom;
        this.sortDirectionCom = sortDirection;
        this.sortedByCom = sortedByCom;
    }
    @api
    get currentEntity(){
        return this._currentEnt;
    }
    set currentEntity(value){
        this.setAttribute('currentEntity', value);
        this._currentEnt = value;
        this.getRestriction();
        this.setup();
    }
    initialized = false;
    @track _currentEnt;
    @api setup(){
        this.sortDirection = '';
        this.sortedBy = '';
        this.sortDirectionCom = '';
        this.sortedByCom = '';
        // Active Requests
        this.data = [];
        this.recordsToDisplay = [];
        this.activeRequests = [];
        this.isActiveReqFound = false;
        getEVActiveCase({ currentEntityId: this._currentEnt }).then(prData => {
            this.getRestriction();
            if (prData){
                let rowNum = 0;
                for (let key in prData){
                    if (prData.hasOwnProperty(key)){
                        this.isActiveReqFound = true;
						this.isExptDataAvailable = true;
                        let tempRecord = {
                            id: prData[key]['caseId'],
                            conId: prData[key]['conId'],
                            caseNumber: prData[key]['caseNumber'],
                            caseService: prData[key]['caseService'],
                            entityConId: prData[key]['entityConId'],
                            restOfName: prData[key]['restOfName'],
                            lastName: prData[key]['lastName'],
                            usmleId: prData[key]['usmleID'],
                            uniqueMedicalSchoolID: prData[key]['uniqueMedicalSchoolID'],
                            dateOfBirth: prData[key]['dateOfBirth'],
                            examType: prData[key]['examType'],
                            eligibilityPeriod: prData[key]['eligibilityPeriod'],
                            recordAvailableDate: prData[key]['recordAvailableDate'],
                            status: prData[key]['status'],
                            deadlineWarning: prData[key]['deadline']
                        };
                        tempRecord.rowNumber = '' + (rowNum + 1);
                        if (this.data.length > 0){
                            this.data = [...this.data, tempRecord];
                        }else{
                            this.data = [tempRecord];
                        }
                        this.attributesList = ['id','conId'];
                    }
                    rowNum = rowNum + 1;
                }
                this.activeRequests = this.data;
                if(this.template.querySelector('.paginatorAR') !== null){
                    this.template.querySelector('.paginatorAR').records = this.activeRequests;
                    this.template.querySelector('.paginatorAR').totalRecords = this.activeRequests.length;
                    this.template.querySelector('.paginatorAR').setRecordsPerPage();
                }
            }
        })
        .catch(error => {
            window.console.error('get Error: ' + JSON.stringify(error));
        });
        // Completed Requests
        this.dataCom = [];
        this.completedRequests = [];
        this.recordsToDisplayCom = [];
        this.isCompletedReqFound = false;
        getEVCompletedCase({currentEntityId : this._currentEnt}).then(prData => {
            this.getRestriction();
            if (prData){
                let rowNumCom = 0;
                for (let key in prData){
                    if (prData.hasOwnProperty(key)){
                        this.isCompletedReqFound = true;
						this.isExptDataAvailable = true;
                        let tempRecord = {
                            id: prData[key]['caseId'],
                            conId: prData[key]['conId'],
                            caseNumber: prData[key]['caseNumber'],
                            caseService: prData[key]['caseService'],
                            entityConId: prData[key]['entityConId'],
                            restOfName: prData[key]['restOfName'],
                            lastName: prData[key]['lastName'],
                            usmleId: prData[key]['usmleID'],
                            uniqueMedicalSchoolID: prData[key]['uniqueMedicalSchoolID'],
                            dateOfBirth: prData[key]['dateOfBirth'],
                            examType: prData[key]['examType'],
                            eligibilityPeriod: prData[key]['eligibilityPeriod'],
                            recordAvailableDate: prData[key]['recordAvailableDate'],
                            status: prData[key]['status']
                        };
                        tempRecord.rowNumber = '' + (rowNumCom + 1);
                        if (this.dataCom.length > 0){
                            this.dataCom = [...this.dataCom, tempRecord];
                        }else{
                            this.dataCom = [tempRecord];
                        }
                        this.attributesList = ['id','conId'];                  
                    }
                    rowNumCom = rowNumCom + 1;
                }
                this.completedRequests = this.dataCom;
                if (this.template.querySelector('.paginatorCR') !== null){
                    this.template.querySelector('.paginatorCR').records = this.completedRequests;
                    this.template.querySelector('.paginatorCR').totalRecords = this.completedRequests.length;
                    this.template.querySelector('.paginatorCR').setRecordsPerPage();
                }
            }
        })
        .catch(error => {
            window.console.error('get Error: ' + JSON.stringify(error));
        });   
    }
    @api getRestriction(){
        getContact({
            userId: this.userId
        }).then(conResult => {
            let tempJson ={
                accountId: this._currentEnt,
                contactId: conResult,
                service: 'Enrollment Verification - Internal and External'
            };
            getMessage({jsonInput: JSON.stringify(tempJson)}).then(result => {
                if(result){
                    this.restrictedAccess=true;
                    this.errorMessages=performanceErrormsg;
                }else{
                    this.restrictedAccess=false;
                }
            })
        })
    }
    @api refreshSetup(){
        this.setup();
        this.getRestriction();
    }
    renderedCallback(){
        if (this.initialized){
            if(!this.restrictedAccess){
                if(this.isActiveReqFound ||this.isCompletedReqFound){
                    this.isExptDataAvailable = true;
                }else{
                    this.isExptDataAvailable = false;
                }
            }
            return;
        }
        this.initialized = true;
    }   
	handleRowActions(event){    
        let row = event.detail.row;
        let caseId = row.id;
        let conId = row.conId;
        let entityConId = row.entityConId;
        let caseService = row.caseService;
        let messageWrapper = {"accountId" : this._currentEnt,
        "contactId" : entityConId,
        "service": caseService +' - Internal and External'};
        getMessage({jsonInput: JSON.stringify(messageWrapper)})
        .then(result => {
            if(result){
                this.restrictedAccess=true;
                const evt = new ShowToastEvent({
                    title: 'Restriction Applied',
                    message: enrollmentCredentialMessage,
                    variant: 'error',
                });
                this.dispatchEvent(evt);
            }else{
                this.restrictedAccess=false;
                this.showDetail(caseId,conId);
            }
        })
        .catch(error => {
            window.console.error(error);
        });
    }
    showDetail(caseId,conId){
        let ca = {
            cas: caseId,
            con: conId
        };
        const selectEvent = new CustomEvent("nextevent", {
            detail: ca
        });
        this.dispatchEvent(selectEvent);
    }
    handleARPaginatorChange(event){
        this.recordsToDisplay = event.detail;
        if (this.recordsToDisplay.length > 0){
            this.rowNumberOffset = this.recordsToDisplay[0].rowNumber - 1;
        }
    }
    handleCRPaginatorChange(event){
        this.recordsToDisplayCom = event.detail;
        if (this.recordsToDisplayCom.length > 0){
            this.rowNumberOffsetCom = this.recordsToDisplayCom[0].rowNumber - 1;
        }
    }
    exportToCSV(){
        let columnHeader = [ "Case Number", "Rest Of Name", "Last Name", "USMLE ID", "Unique Medical School ID", "Date Of Birth", "Exam Type", "Eligibility Period", "Record Available Date","Status"];
        let jsonKeys = [ "caseNumber", "restOfName", "lastName", "usmleId", "uniqueMedicalSchoolID", "dateOfBirth", "examType", "eligibilityPeriod", "recordAvailableDate","status"];
        var jsonRecordsData = this.data;
        var jsonRecordsDataCom = this.dataCom;
        let csvIterativeData;
        let csvSeperator
        let newLineCharacter;
        csvSeperator = ",";
        newLineCharacter = "\n";
        csvIterativeData = "";
        csvIterativeData += columnHeader.join(csvSeperator);
        csvIterativeData += newLineCharacter;
        if(jsonRecordsData.length > 0){
            for (let i = 0; i < jsonRecordsData.length; i++){
                let counter = 0;
                for (let iteratorObj in jsonKeys){
                    let dataKey = jsonKeys[iteratorObj];
                    if (counter > 0){
                        csvIterativeData += csvSeperator;
                    }
                    if (jsonRecordsData[i][dataKey] !== null && jsonRecordsData[i][dataKey] !== undefined){
                        csvIterativeData += '"' + jsonRecordsData[i][dataKey] + '"';
                    }else{
                        csvIterativeData += '""';
                    }
                    counter++;
                }
                csvIterativeData += newLineCharacter;
            }
        }
        if(jsonRecordsDataCom.length > 0){
            for (let i = 0; i < jsonRecordsDataCom.length; i++){
                let counter = 0;
                for (let iteratorObj in jsonKeys){
                    let dataKey = jsonKeys[iteratorObj];
                    if (counter > 0){
                        csvIterativeData += csvSeperator;
                    }
                    if (jsonRecordsDataCom[i][dataKey] !== null &&
                        jsonRecordsDataCom[i][dataKey] !== undefined
                    ){
                        csvIterativeData += '"' + jsonRecordsDataCom[i][dataKey] + '"';
                    }else{
                        csvIterativeData += '""';
                    }
                    counter++;
                }
                csvIterativeData += newLineCharacter;
            }
        }
        let newVal = csvIterativeData.replaceAll('<br>',';');
        this.hrefdata = "data:text/csv;charset=utf-8," + encodeURI(newVal);
    }    
}