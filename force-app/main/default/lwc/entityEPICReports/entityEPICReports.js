import {LightningElement, track, api} from 'lwc';
import getEpicCases from '@salesforce/apex/EpicReportsController.getEpicCases';
import updateArchivedStatus from '@salesforce/apex/EpicReportsController.updateArchivedStatus';
import getParentEnityName from '@salesforce/apex/EpicReportsController.getParentEnityName';
import getBase64Pdf from '@salesforce/apex/CloudStorageUtils.getBase64Pdf';
import getEPICReport from "@salesforce/apex/EpicReptHistoryListController.getEPICReport";
import updateEntityExternalStatus from '@salesforce/apex/EpicReportsController.updateEntityExternalStatus';
import getFileUrlWithSAS from '@salesforce/apex/CloudStorageUtils.getFileUrlWithSAS';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
export default class EntityEPICReports extends LightningElement{
    
    updatedEpicArchivedCases;
    isActiveReqFound = false;
    isExptDataAvailable = false;
    spinner = false;
    initialized = false;
    header;
    documentUrl;
    @track epicReportURL;
    @track recordsToDisplay= [];
    @track dataCom = []; 
    @track epicReports = [];       
    @track recordsfromPaginator = [];
    @track _parentEntity;
    @track sortDirection = 'asc';
    @track sortedBy;       
    @track hrefdata;        
    @track defaultSortDirectionCom = 'asc';        
    @track rowNumberOffset;
    @track epicReportArchivedStatus = false;
    @track reportStatus = 'New';
    @track isListOfUnArchivedRecords = true;
    //Datatable coloumns for New EPIC Cases
    @track col = [
        {
            label: 'Entity Name',
            fieldName: 'entityName',
            initialWidth: 150,
            sortable: true,
            typeAttributes: {            
                wrapText: true
            }
        },
        {        
            label: 'Credential',
            fieldName: 'documentType',
            initialWidth: 150,
            sortable: true,
            typeAttributes: {            
                wrapText: true
            }
        },
        {        
            label: 'Applicant Name',
            fieldName: 'ContactName',
            initialWidth: 150,
            sortable: true,
            typeAttributes: {            
                wrapText: true
            }
        },
        {        
            label: 'ECFMG ID',
            fieldName: 'myIntealthId',
            initialWidth: 150,
            sortable: true,
            typeAttributes: {            
                wrapText: true
            }
        },
        {        
            label: 'Reference Number',
            fieldName: 'referenceNumber',
            sortable: true,
            initialWidth: 150,
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
            label: 'Date Report Received',
            fieldName: 'dateReportReceived',
            initialWidth: 100,
            sortable: true,
            wrapText: true
        },
        {        
            label: 'Available Until',
            fieldName: 'availableUntil',
            initialWidth: 200,
            sortable: true,
            typeAttributes: {            
                wrapText: true
            }       
        },
        {
            label: 'View',
            type: "button",
            initialWidth: 20, 
            typeAttributes: {  
                label: 'View',  
                name: 'View',  
                title: 'View',  
                disabled: false,  
                value: 'view',  
                variant: 'base',
                iconPosition: 'left'  
            },
            cellAttributes: { 
                class: 'test-css'
            }
        },  
        {   
            label: 'Download',
            initialWidth: 80,
            type: "button", 
            typeAttributes: {  
                label: 'Download',  
                name: 'Download',  
                title: 'Download',  
                disabled: false,  
                value: 'Download',
                variant: 'base',  
                iconPosition: 'left'  
            }
        },
        {
            label: 'Archive',
            initialWidth: 90,
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
    ];
		//Datatable coloumns for Archived EPIC Cases
    @track archivedReportCols = [
        {
            label: 'Entity Name',
            fieldName: 'entityName',
            initialWidth: 150,
            sortable: true,
            typeAttributes: {            
                wrapText: true
            }
        },
        {        
            label: 'Credential',
            fieldName: 'documentType',
            initialWidth: 150,
            sortable: true,
            typeAttributes: {            
                wrapText: true
            }
        },
        {        
            label: 'Applicant Name',
            fieldName: 'ContactName',
            initialWidth: 150,
            sortable: true,
            typeAttributes: {            
                wrapText: true
            }
        },
        {        
            label: 'ECFMG ID',
            fieldName: 'myIntealthId',
            initialWidth: 150,
            sortable: true,
            typeAttributes: {            
                wrapText: true
            }
        },
        {        
            label: 'Reference Number',
            fieldName: 'referenceNumber',
            sortable: true,
            initialWidth: 150,
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
            label: 'Date Report Received',
            fieldName: 'dateReportReceived',
            initialWidth: 100,
            sortable: true,
            wrapText: true
        },
        {        
            label: 'Available Until',
            fieldName: 'availableUntil',
            initialWidth: 200,
            sortable: true,
            typeAttributes: {            
                wrapText: true
            }       
        },
        {
            label: 'View',
            type: "button",
            initialWidth: 20, 
            typeAttributes: {  
                label: 'View',  
                name: 'View',  
                title: 'View',  
                disabled: false,  
                value: 'view',  
                variant: 'base',
                iconPosition: 'left'  
            },
            cellAttributes: { 
                class: 'test-css'
            }
        },  
        {   
            label: 'Download',
            initialWidth: 80,
            type: "button", 
            typeAttributes: {  
                label: 'Download',  
                name: 'Download',  
                title: 'Download',  
                disabled: false,  
                value: 'Download',
                variant: 'base',  
                iconPosition: 'left'  
            }
        },
        {
            label: 'Unarchive',
            initialWidth: 90,
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
        },
    ];
    //To retrieve options in the dropdown to choose new or archived reports
    get options(){
        return[
            { label: 'New', value: 'New' },
            { label: 'Archived', value: 'Archived' },
        ];
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
        this.isActiveReqFound = false;
        this.spinner = true;             
        this.dataCom = [];
        this.recordsToDisplay = [];
        this.epicReports = [];
        //Gets the valid list of epic cases under the enitity
        getEpicCases({parentEntityId : this._parentEntity, archivedStatus : this.epicReportArchivedStatus})
        .then(prData => {
            this.isActiveReqFound = true;
            this.spinner = false; 
            if(prData){
                let rowNumCom = 0;
                prData.forEach(caseRec => {
                        this.isExptDataAvailable = true;
                        let tempRecord = {
                            Id:caseRec.Id,
                            entityName:caseRec.Entity__r.Name,
                            documentType:caseRec.Document_Type__c,
                            ContactName:caseRec.Contact.Name,
                            myIntealthId: caseRec.MyIntealth_ID__c,
                            referenceNumber:caseRec.Reference_Number__c,
                            status:caseRec.Entity_External_Status__c,
                            dateReportReceived:caseRec.EPIC_Report_Received_Date__c,
                            availableUntil:caseRec.EPIC_Report_Available_Date__c
                        };
                        tempRecord.rowNumber = '' + (rowNumCom + 1);
                        if(this.dataCom.length > 0){
                            this.dataCom = [...this.dataCom, tempRecord];
                        }else{
                            this.dataCom = [tempRecord];
                        }
                        this.attributesList = ['id']; 
                    rowNumCom = rowNumCom + 1;
                });
                this.epicReports = this.dataCom; 
                if(this.template.querySelector('.paginatorCR') !== null){
                    this.template.querySelector('.paginatorCR').records = this.epicReports;
                    this.template.querySelector('.paginatorCR').totalRecords = this.epicReports.length;
                    this.template.querySelector('.paginatorCR').setRecordsPerPage();
                }
            }
        }) 
        getParentEnityName({parentEntityId : this._parentEntity})        
        .then(data => {
            if(data === 'Ministry of Health, Kuwait' && this.isListOfUnArchivedRecords){
                this.col = this.col.filter(columns=> columns.label !== 'CoverLetter');
                this.col.push({   
                    label: 'CoverLetter',initialWidth: 150,
                    type: "button", typeAttributes: {  
                    label: 'Cover Letter',
                    name: 'Cover Letter',
                    title: 'Cover Letter',
                    disabled: false,
                    value: 'Cover Letter',
                    variant: 'base',
                    iconPosition: 'left'
                }});
            }
            else if(data === 'Ministry of Health, Kuwait' && !this.isListOfUnArchivedRecords){
            this.archivedReportCols = this.archivedReportCols.filter(columns=> columns.label !== 'CoverLetter');
                this.archivedReportCols.push({   
                    label: 'CoverLetter',initialWidth: 150,
                    type: "button", typeAttributes: {  
                    label: 'Cover Letter',
                    name: 'Cover Letter',
                    title: 'Cover Letter',
                    disabled: false,
                    value: 'Cover Letter',
                    variant: 'base',
                    iconPosition: 'left'
                }});  
            }
        })
    }
    //To handle row/button actions of the datatable
    handleRowActions(event){
        this.spinner = true; 
        const recId =  event.detail.row.Id;
        const actionName = event.detail.action.name;
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
            .catch(error => {console.log('get Error: ' + error.body.message)});
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
            .catch(error => {console.log('get Error: ' + error.body.message)});
        } else if(actionName === 'View'){
            this.refactorViewReport(recId,actionName);
            //add logic to update the entity external status after report is viewed
            updateEntityExternalStatus({caseId : recId})
            .then(data =>{
                if(data){
                    console.log('status updated');
                }
            }).catch(error => {console.log('get Error: ' + error.body.message)}); 
            this.spinner = false;
            this.setup();
             
        } else if(actionName === 'Download'){
            this.refactorViewReport(recId,actionName);
            //add logic to update the entity external status after report is viewed
            updateEntityExternalStatus({caseId : recId})
            .then(data =>{
                if(data){
                    console.log('status updated');
                }
            }).catch(error => {console.log('get Error: ' + error.body.message)}); 
            this.spinner = false;
            this.setup();
        }
    }

    refactorViewReport(recId,actionName){
        getEPICReport({caseId: recId})
            .then(res=>{
                if(res){
                    this.epicReportURL = res;
                }
                if(!this.spinner){
                    this.spinner = true;
                }
                let azureUrl = this.epicReportURL;
                let splitParams = azureUrl.split("/");
                if(splitParams.length > 0){
                    let tempFileName = splitParams[splitParams.length - 1];
                    if(this.epicReportURL){
                        getFileUrlWithSAS({
                            fileName: tempFileName
                        })
                        .then(result=>{
                            if(actionName == 'View'){
                                this.showDocument = true;
                                if(result && this.template.querySelector("c-modal")){
                                    this.header = 'EPIC Verification Report';
                                    this.documentUrl = result;
                                    this.template.querySelector("c-modal").show();
                                    this.spinner = false;  
                                }
                            }else if(actionName == 'Download'){
                                this.showDocument = false;
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
                                                title: 'Error downloading EPIC Verifictaion Report!',
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
            }).catch(error=>{
            window.console.error('Error: '+JSON.stringify(error));
            this.spinner = false;
        }); 
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
    //Show or hide export button
    renderedCallback(){
        if(this.initialized){
            if(this.isActiveReqFound || this.isCompletedReqFound){
                this.isExptDataAvailable = true;
            }else{
                this.isExptDataAvailable = false;
            }
            return;
        }
        this.initialized = true;
    } 
    //To download the epic reports data by using this method
    exportToCSV(){
        let columnHeader = ["Entity Name", "Credential", "Applicant Name", "ECFMG ID", "Reference Number", "Status", "Date Report Received", "Available Until"];
        let jsonKeys = ["entityName", "documentType", "ContactName", "myIntealthId", "referenceNumber", "status", "dateReportReceived", "availableUntil"];
        var jsonRecordsData = this.dataCom;
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
    handleCloseModal() {
        this.header = null;
        this.documentUrl = null;
        this.showDocument = false;
    }
    handleShowDocument(){
        this.template.querySelector("c-document-viewer").viewUrl(this.documentUrl);
    }
}