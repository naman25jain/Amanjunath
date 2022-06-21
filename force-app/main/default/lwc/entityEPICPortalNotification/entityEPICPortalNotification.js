import {LightningElement, track, api} from 'lwc';
import getNotifications from '@salesforce/apex/EpicPortalNotificationsController.getNotifications';
import updateArchivedStatus from '@salesforce/apex/EpicPortalNotificationsController.updateArchivedStatus';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getBase64Pdf from '@salesforce/apex/CloudStorageUtils.getBase64Pdf';
import getFileUrlWithSAS from '@salesforce/apex/CloudStorageUtils.getFileUrlWithSAS';
import  { loadStyle } from 'lightning/platformResourceLoader';
import cssResource from '@salesforce/resourceUrl/CssFile';
export default class entityEPICPortalNotification extends LightningElement{
    
    updatedEpicArchivedCases;
    isActiveNotfnFound = false;
    isExptDataAvailable = false;
    spinner = false;
    initialized = false;
    @track recordsToDisplay= [];
    @track assetReportURL;
    @track asstExistTrans;
    @track dataCom = []; 
    @track epicNotfns = [];       
    @track recordsfromPaginator = [];
    @track _parentEntity;
    @track sortDirection = 'asc';
    @track sortedBy;       
    @track hrefdata;        
    @track defaultSortDirectionCom = 'asc';        
    @track rowNumberOffset;
    @track epicReportArchivedStatus = false;
    @track notificationTitle = 'New EPIC Notification';
    @track reportStatus = 'New';
    @track archivedStatus = false;
    @track isListOfUnArchivedRecords = true;
    //Datatable coloumns for New EPIC Cases
    @track newCol = [{        
        label: 'Credential Type',
        fieldName: 'credentialType',
        initialWidth: 150,
        sortable: true,
        typeAttributes: {            
            wrapText: true
        }
    },
    {        
        label: 'Attendance Start Date',
        fieldName: 'attendanceStartDate',
        initialWidth: 180,
        sortable: true,
        typeAttributes: {            
            wrapText: true
        }
    },
    {        
        label: 'Attendance End Date',
        fieldName: 'attendanceEndDate',
        initialWidth: 180,
        sortable: true,
        typeAttributes: {            
            wrapText: true
        }
    },
    {        
        label: 'Date Degree Issued',
        fieldName: 'dateDegreeIssued',
        initialWidth: 180,
        sortable: true,
        typeAttributes: {            
            wrapText: true
        }
    },
    {        
        label: 'Title of Medical Degree',
        fieldName: 'medicalDegreeTitle',
        initialWidth: 190,
        sortable: true,
        typeAttributes: {            
            wrapText: true
        }
    },
    {        
        label: 'Name on Document',
        fieldName: 'nameOnDocument',
        initialWidth: 160,
        sortable: true,
        wrapText: true
    },
    {        
        label: 'Applicant Name',
        fieldName: 'applicantName',
        initialWidth: 150,
        sortable: true,
        wrapText: true
    },    
    {        
        label: 'ECFMG ID',
        fieldName: 'myIntealthId',
        initialWidth: 160,
        sortable: true,
        typeAttributes: {            
            wrapText: true
        }       
    },
    {        
        label: 'Credential Status',
        fieldName: 'credentialStatus',
        initialWidth: 160,
        sortable: true,
        typeAttributes: {            
            wrapText: true
        }
    },
    {        
        label: 'Issuing Institution',
        fieldName: 'issuingInstitution',
        initialWidth: 160,
        sortable: true,
        typeAttributes: {            
            wrapText: true
        }
    },
    {        
        label: 'Issuing Institution Country',
        fieldName: 'issuingInstitutionCountry',
        initialWidth: 160,
        sortable: true,
        typeAttributes: {            
            wrapText: true
        }
    },
    {        
        label: 'First Verification Request Sent Date',
        fieldName: 'firstVerificationRequestSentDate',
        initialWidth: 200,
        sortable: true,
        typeAttributes: {            
            wrapText: true
        }
    },
    {        
        label: 'Available Until',
        fieldName: 'availableUntil',
        initialWidth: 150,
        sortable: true,
        typeAttributes: {            
            wrapText: true
        }
    },
    {        
        label: 'Archive',
        initialWidth: 100,
        type: "button",
        typeAttributes: {  
            label: 'Archive',  
            name: 'Archive',  
            title: 'Archive',  
            disabled: false,  
            value: 'Archive', 
            variant: 'base', 
            iconPosition: 'left'  
        }
    },
    {   
        label: 'View Credential',
        initialWidth: 150,
        type: "button", 
        typeAttributes: {  
            label: 'View Credential',  
            name: 'View Credential',  
            title: 'View Credential',  
            disabled: false,  
            value: 'View Credential',
            variant: 'base',  
            iconPosition: 'left'  
        }
    },
    {   
        label: 'Download Credential',
        initialWidth: 150,
        type: "button", 
        typeAttributes: {  
            label: 'Download Credential',  
            name: 'Download Credential',  
            title: 'Download Credential',  
            disabled: false,  
            value: 'Download Credential',
            variant: 'base',  
            iconPosition: 'left'  
        }
    },
    {   
        label: 'View Translation',
        initialWidth: 150,
        type: "button", 
        typeAttributes: {  
            label: 'View Translation',  
            name: 'View Translation',  
            title: 'View Translation',  
            disabled: false,  
            value: 'View Translation',
            variant: 'base',  
            iconPosition: 'left',
            class: { fieldName: 'cssClass' }  
        }
    },
    {   
        label: 'Download Translation',
        initialWidth: 150,
        type: "button", 
        typeAttributes: {  
            label: 'Download Translation',  
            name: 'Download Translation',  
            title: 'Download Translation',  
            disabled: false,  
            value: 'Download Translation',
            variant: 'base',  
            iconPosition: 'left',
            class: { fieldName: 'cssClass' }    
        },
    }
    ];
    @track archiveCol = [{        
        label: 'Credential Type',
        fieldName: 'credentialType',
        initialWidth: 150,
        sortable: true,
        typeAttributes: {            
            wrapText: true
        }
    },
    {        
        label: 'Attendance Start Date',
        fieldName: 'attendanceStartDate',
        initialWidth: 180,
        sortable: true,
        typeAttributes: {            
            wrapText: true
        }
    },
    {        
        label: 'Attendance End Date',
        fieldName: 'attendanceEndDate',
        initialWidth: 180,
        sortable: true,
        typeAttributes: {            
            wrapText: true
        }
    },
    {        
        label: 'Date Degree Issued',
        fieldName: 'dateDegreeIssued',
        initialWidth: 180,
        sortable: true,
        typeAttributes: {            
            wrapText: true
        }
    },
    {        
        label: 'Title of Medical Degree',
        fieldName: 'medicalDegreeTitle',
        initialWidth: 190,
        sortable: true,
        typeAttributes: {            
            wrapText: true
        }
    },
    {        
        label: 'Name on Document',
        fieldName: 'nameOnDocument',
        initialWidth: 160,
        sortable: true,
        wrapText: true
    },
    {        
        label: 'Applicant Name',
        fieldName: 'applicantName',
        initialWidth: 150,
        sortable: true,
        wrapText: true
    },    
    {        
        label: 'ECFMG ID',
        fieldName: 'myIntealthId',
        initialWidth: 160,
        sortable: true,
        typeAttributes: {            
            wrapText: true
        }       
    },
    {        
        label: 'Credential Status',
        fieldName: 'credentialStatus',
        initialWidth: 160,
        sortable: true,
        typeAttributes: {            
            wrapText: true
        }
    },
    {        
        label: 'Issuing Institution',
        fieldName: 'issuingInstitution',
        initialWidth: 160,
        sortable: true,
        typeAttributes: {            
            wrapText: true
        }
    },
    {        
        label: 'Issuing Institution Country',
        fieldName: 'issuingInstitutionCountry',
        initialWidth: 160,
        sortable: true,
        typeAttributes: {            
            wrapText: true
        }
    },
    {        
        label: 'First Verification Request Sent Date',
        fieldName: 'firstVerificationRequestSentDate',
        initialWidth: 200,
        sortable: true,
        typeAttributes: {            
            wrapText: true
        }
    },
    {        
        label: 'Available Until',
        fieldName: 'availableUntil',
        initialWidth: 150,
        sortable: true,
        typeAttributes: {            
            wrapText: true
        }
    },
    {        
        label: 'Download Credential',
        initialWidth: 150,
        type: "button", 
        typeAttributes: {  
            label: 'Download Credential',  
            name: 'DownloadCredential',  
            title: 'Download Credential',  
            disabled: false,  
            value: 'Download',
            variant: 'base',  
            iconPosition: 'left'  
        }
    },
    {        
        label: 'Download Translation',
        initialWidth: 150,
        type: "button", 
        typeAttributes: {  
            label: 'Download Translation',  
            name: 'DownloadTranslation',  
            title: 'Download Translation',  
            disabled: false,  
            value: 'Download',
            variant: 'base',  
            iconPosition: 'left'  
        }
    },
    {        
        label: 'Unarchive',
        initialWidth: 100,
        type: "button",
        typeAttributes: {  
            label: 'Unarchive',  
            name: 'Unarchive',  
            title: 'Unarchive',  
            disabled: false,  
            value: 'Unarchive', 
            variant: 'base', 
            iconPosition: 'left'  
        }
    }
    ];
    //To retrieve options in the dropdown to choose new or archived reports
    get options(){
        return[
            { label: 'New', value: 'New' },
            { label: 'Archived', value: 'Archived' },
        ];
    }
    
    @api
    get parentEntity(){
        return this._parentEntity;
    }
    set parentEntity(value){
        this.setAttribute('parentEntity', value);
        this._parentEntity = value;
        this.setup();
    }

    @api setup(){
        this.sortDirection = '';
        this.sortedBy = '';
        this.sortDirectionCom = '';
        this.sortedByCom = '';
        // Active Requests
        this.data = [];
        this.activeRequests = [];
        this.isActiveNotfnFound = false;
        this.spinner = true;            
        this.dataCom = [];
        this.recordsToDisplay = [];
        this.epicNotfns = [];
        //Gets the valid list of epic cases under the enitity
        getNotifications({entityId : this._parentEntity, archivedStatus : this.epicReportArchivedStatus})
        .then(prData => {
            this.spinner = false; 
            if(prData){
                let rowNumCom = 0;
                prData.forEach(caseRec => {
                        this.isActiveNotfnFound = true;
                        this.isExptDataAvailable = true;
                        let hideTranslation='showActionButton';
                        if(caseRec.asstExistTrans==='false')
                        {
                             hideTranslation= 'hideActionButton';
                        }
                        
                        let tempRecord ={
                            Id: caseRec.caseId,
                            credentialType: caseRec.credentialType,
                            attendanceStartDate: caseRec.attendanceStartDate,
                            attendanceEndDate: caseRec.attendanceEndDate,
                            dateDegreeIssued: caseRec.dateDegreeIssued,
                            medicalDegreeTitle: caseRec.medicalDegreeTitle,
                            nameOnDocument: caseRec.nameOnDocument,
                            applicantName: caseRec.applicantName,
                            myIntealthId: caseRec.myIntealthId,
                            credentialStatus: caseRec.credentialStatus,
                            issuingInstitution: caseRec.issuingInstitution,
                            issuingInstitutionCountry: caseRec.issuingInstitutionCountry,
                            firstVerificationRequestSentDate: caseRec.firstVerificationRequestSentDate,
                            availableUntil: caseRec.notificationAvailableDate,
                            asstCred: caseRec.asstCred,
                            typeCred: caseRec.typeCred,
                            urlCred: caseRec.urlCred,
                            urlTrans: caseRec.urlTrans,
                            asstTrans: caseRec.asstTrans,
                            typeTrans: caseRec.typeTrans,
                            asstExistTrans: caseRec.asstExistTrans,
                            cssClass: hideTranslation
                        };
                        tempRecord.rowNumber = '' + (rowNumCom + 1);
                        if(this.dataCom.length > 0){
                            this.dataCom = [...this.dataCom, tempRecord];
                        }else{
                            this.dataCom = [tempRecord];
                        }
                        this.attributesList = ['Id']; 
                    rowNumCom = rowNumCom + 1;
                });
                this.epicNotfns = this.dataCom; 
                if(this.template.querySelector('.paginatorAR') !== null){
                    this.template.querySelector('.paginatorAR').records = this.epicNotfns;
                    this.template.querySelector('.paginatorAR').totalRecords = this.epicNotfns.length;
                    this.template.querySelector('.paginatorAR').setRecordsPerPage();
                }
            }
        })
    }
    //To handle row/button actions of the datatable
    handleRowActions(event){
        this.spinner = true; 
        const recId =  event.detail.row.Id;
        const actionName = event.detail.action.name;
        const uCred=event.detail.row.urlCred;
        const uTrans=event.detail.row.urlTrans;
        if(actionName === 'Archive'){ 
            updateArchivedStatus({caseId : recId, archivedStatus : true})                        
            .then(data => {
                const toastEvent = new ShowToastEvent({
                    title:'Record Archived',
                    message:'Record Archived successfully',
                    variant:'success',
                })
                this.dispatchEvent(toastEvent);
                this.spinner = false;
                this.setup();                            
            })
        } else if(actionName === 'Unarchive'){
            updateArchivedStatus({caseId : recId, archivedStatus : false})                        
            .then(data => {
                const toastEvent = new ShowToastEvent({
                    title:'Record Unarchived',
                    message:'Record Unarchived successfully',
                    variant:'success',
                })
                this.dispatchEvent(toastEvent);
                this.spinner = false;
                this.setup();                            
            })
        } else if(actionName === 'View Credential'){ 
            this.spinner= false;
            this.assetIdToShow = '';
            this.docType = '';
            let idx = event.detail.row.asstCred;
            let doc = event.detail.row.typeCred;           
            this.assetIdToShow = idx;
            this.docType = doc;
            let tempPayload = {
                contactId: null,
                caseId: null,
                catsId: null,
                documentType: null,
                assetRecordType: null,
                createOrReplace: null,
                assetStatus: null,
                assetCreationRequired: null,
                assetId: null
            };
            tempPayload.assetId = idx;
            tempPayload.documentType = doc;
            this.assetIdToShow = JSON.stringify(tempPayload);
            this.template.querySelector('.addAuthScreenModalAsset').show();       
       }  else if(actionName === 'View Translation' ){ 
        this.spinner= false;
        this.assetIdToShow = '';
        this.docType = '';
        let idx = event.detail.row.asstTrans;
        let doc = event.detail.row.typeTrans;             
        this.assetIdToShow = idx;
        this.docType = doc;
        let tempPayload = {
         contactId: null,
         caseId: null,
         catsId: null,
         documentType: null,
         assetRecordType: null,
         createOrReplace: null,
         assetStatus: null,
         assetCreationRequired: null,
         assetId: null
     };
        tempPayload.assetId = idx;
        tempPayload.documentType = doc;
        this.assetIdToShow = JSON.stringify(tempPayload);
        this.template.querySelector('.addAuthScreenModalAsset').show();    
    } else if(actionName === 'Download Credential'){
         this.spinner= false;
         this.refactorViewReport(uCred,actionName);
       } else if(actionName === 'Download Translation'){
        this.spinner= false;
        this.refactorViewReport(uTrans,actionName);
        }
    }
    refactorViewReport(recId,actionName){
        this.assetReportURL = recId;
        let azureUrl = this.assetReportURL;
        let splitParams = azureUrl.split("/");
        if(splitParams.length > 0){
            let tempFileName = splitParams[splitParams.length - 1];
            if(this.assetReportURL){
                getFileUrlWithSAS({
                    fileName: tempFileName
                })
                .then(result=>{
                    if(actionName == 'Download Credential' || actionName == 'Download Translation'){
                       // this.showDocument = false;
                        if(result){
                            this.documentUrl = result;
                            let temp = result;
                            //call apex method to get base64
                            getBase64Pdf({surl: temp})
                            .then(data=>{
                                var bbody = data; 
                                var byteCharacters = atob(bbody);
                                var byteCharacters = atob(bbody.replace(/^data:image\/(png|jpeg|jpg);base64,/, ''));                
                                const buf = new Array(byteCharacters.length);
                                for (var i = 0; i != byteCharacters.length; ++i) buf[i] = byteCharacters.charCodeAt(i);      
                                const view = new Uint8Array(buf);      
                                const blob = new Blob([view], {
                                    type: 'application/octet-stream'
                                });
                                const a = window.document.createElement('a');
                                a.href = window.URL.createObjectURL(blob);
                                a.download = tempFileName;
                                document.body.appendChild(a);
                                a.click();
                                document.body.removeChild(a);
                            }).catch(error => {
                                dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Error downloading Asset!',
                                        message: error.message,
                                        variant: 'error',
                                    })
                                );
                              })
                            this.spinner = false;
                        }
                    }
                })
            }
        }
    
}
    // Used to sort the columns
    sortBy(field, reverse, primer){
        const key = primer ?
            function (x){
                return primer(x[field]);
            } :
            function (x){
                return x[field];
            };
        return function (a, b){
            var x = key(a) ? key(a).toLowerCase() : '';
            var y = key(b) ? key(b).toLowerCase() : '';
            return reverse * ((x > y) - (y > x));
        };
    }
    //Handling table sort
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
    //Handling pagintorEvent
    handleARPaginatorChange(event){
        this.recordsToDisplay = event.detail;
        if(this.recordsToDisplay.length > 0){
            this.rowNumberOffset = this.recordsToDisplay[0].rowNumber - 1;
        }
    }
    //To handle toggling of New & Archived Reports
    handleReportStatusChange(event){
        this.reportStatus = event.detail.value;
        if(this.reportStatus == 'New'){
            this.epicReportArchivedStatus = false;
            this.isListOfUnArchivedRecords = true;
        } else if(this.reportStatus == 'Archived'){
            this.epicReportArchivedStatus = true;
            this.isListOfUnArchivedRecords = false;
        }
        this.setup();
    }
    //Show or hide export button
    renderedCallback(){
        if(this.initialized){
            if(this.isActiveNotfnFound){
                this.isExptDataAvailable = true;
            }else{
                this.isExptDataAvailable = false;
            }
            return;
        }
        this.initialized = true;
        loadStyle(this, cssResource);
    } 
    //To download the epic reports data by using this method
    exportToCSV(){
        let columnHeader = ["Credential Type", "Attendance Start Date", "Attendance End Date", "Date Degree Issued", "Title of Medical Degree", "Name on Document", "Applicant Name", "ECFMG ID", "Credential Status", "Issuing Institution", "Issuing Institution Country", "First Verification Request Sent Date", "Available Until"];
        let jsonKeys = ["credentialType", "attendanceStartDate", "attendanceEndDate", "dateDegreeIssued", "medicalDegreeTitle", "nameOnDocument", "applicantName", "myIntealthId", "credentialStatus","issuingInstitution", "issuingInstitutionCountry", "firstVerificationRequestSentDate", "availableUntil"];
        var jsonRecordsData = this.recordsToDisplay;
        let csvIterativeData;
        let csvSeperator
        let newLineCharacter;
        csvSeperator = ",";
        newLineCharacter = "\n";
        csvIterativeData = "";
        csvIterativeData += columnHeader.join(csvSeperator);
        csvIterativeData += newLineCharacter;
        if(jsonRecordsData.length > 0){
            for(let i = 0; i < jsonRecordsData.length; i++){
                let counter = 0;
                for(let iteratorObj in jsonKeys){
                    let dataKey = jsonKeys[iteratorObj];
                    if(counter > 0){
                        csvIterativeData += csvSeperator;
                    }
                    if(jsonRecordsData[i][dataKey] !== null && jsonRecordsData[i][dataKey] !== undefined){
                        csvIterativeData += '"' + jsonRecordsData[i][dataKey] + '"';
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
    //To refresh the records/page after changing status to archived or unarchived
    @api refreshSetup(){
        this.setup();
    }
}