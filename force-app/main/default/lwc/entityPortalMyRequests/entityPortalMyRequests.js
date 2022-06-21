import {LightningElement, track, api} from 'lwc';
import getActiveRequests from '@salesforce/apex/EntityPortalMyRequestsController.getActiveRequests';
import getContactDetail from "@salesforce/apex/EntityServiceRequestController.getContactDetail";
import getRequestedServices from "@salesforce/apex/EntityPortalMyRequestsController.getRequestedServices";
import checkAssetSignatureInContact from "@salesforce/apex/EntityServiceRequestController.checkAssetSignatureInContact";
import deleteOrpahnedAssetInContact from "@salesforce/apex/EntityServiceRequestController.deleteOrpahnedAssetInContact";
import getSignedSignatureAsset from '@salesforce/apex/EntityPortalMyRequestsController.getSignedSignatureAsset';
import getIncompleteSignedSignatureAsset from '@salesforce/apex/EntityPortalMyRequestsController.getIncompleteSignedSignatureAsset';
import updateCaseandAsset from '@salesforce/apex/EntityPortalMyRequestsController.updateCaseandAsset';
import delAssetOnCancel from '@salesforce/apex/EntityPortalMyRequestsController.delAssetOnCancel';
import checkServiceAndAcceptedSignForm from '@salesforce/apex/EntityPortalMyRequestsController.checkServiceAndAcceptedSignForm';
const columns = [
    {
        label: 'Case Number',
        type: 'button',
        sortable: true,
        fieldName: 'caseNumber',
        typeAttributes: {
            title: 'Case Number',
            variant: 'border-filled',
            disabled: false,
            class:'caseNumberTd',
            label: { fieldName: 'caseNumber' },
            name: { fieldName: 'caseId' },
        }
    },
    {
        label: 'Case Type',
        fieldName: 'caseType',
        sortable: true
    },
    {
        label: 'Rest of Name',
        fieldName: 'firstName',
        sortable: true
    },
    {
        label: 'Last Name',
        fieldName: 'lastName',
        sortable: true
    },
    {
        label: 'Service(s) Requested',
        fieldName: 'serviceNamesList',
        sortable: true
    },
    {
        label: 'Case Status',
        fieldName: 'caseStatus',
        sortable: true
    },
    {
        label: 'Action Needed',
        fieldName: 'actionNeeded',
        sortable: true
    },
    {
        label: 'Date Opened',
        fieldName: 'dateOpened',
        sortable: true
    },
    {
        label: 'Last Modified Date',
        fieldName: 'lastModifiedDate',
        sortable: true
    }
];
export default class EntityPortalMyRequests extends LightningElement{
    @track recordsList = []; //All Records available
    @track activeCount;
    @track isActiveReqFound = false;
    @track spinner = false;
    @track showCaseDetail = false;
    @track showFileUploadAndSubmit = false;
    @track recordsToDisplay = []; //Records to be displayed on the page
    @track attributesList = [];
    @track rowNumberOffset; //Row number
    @track columns = columns;
    @track contactId;
    @track currentCaseId;
    @track entityContactId;
    @track lastName;
    @track restOfName;
    @track checkBoxValue;
    @track emailAddress;
    @track generationalSuffix;
    @track phoneNumber;
    @track department;
    @track jobTitle;
    @track legalNameConsists;
    @track servicesList = [];
    @track assetSignatureForm = false;
    @track contentDocumentId;
    @track modalTitle = 'Alert';
    @track modalContent = 'Are you sure you want to cancel? All changes will be lost.';
    @track showUploadSignature = false;
    @track fileUploaded = false;
    @track signatureAlreadyExist;
    @track contactSignAsseAzureUrl;
    @track showErrorMessage = false;
    @track entityAssetFileName;
    @track entityAssetFileType;
    @track entityAssetFileURL;
    @track sortedDirection = 'asc';
    @track sortedColumn; 
    @track assetIdToDisplay;  
    @track assetIdToInsert;  
    @track showErrorMessages; 
    @track showIncompleteSignForm;  
    @track tempPayload = {
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
            var a = key(a) ? key(a).toLowerCase() : '';
            var b = key(b) ? key(b).toLowerCase() : '';
            return reverse * ((a > b) - (b > a));
        };
    }
    onHandleSort(event) {
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
    @api
    get currentEntity() {
        return this._currentEnt;
    }
    set currentEntity(value) {
        this.setAttribute('currentEntity', value);
        this._currentEnt = value;
        this.setup();
    }
    @track _currentEnt;
    @api setup() {
        this.sortDirection = '';
        this.sortedBy = '';
        this.recordsList = [];
        this.activeRequests = [];
        this.recordsToDisplay = [];
        this.isActiveReqFound = false;
        this.showErrorMessages = false;
        this.showIncompleteSignForm = false;
        getActiveRequests({
            currentEntityId: this._currentEnt
        })
        .then(result => {
            if (result !== undefined && result !== null) {
                this.isActiveReqFound = true;
                let rowNum = 0;
                for (let key in result) {
                    if (result.hasOwnProperty(key)) {  
                        let tempRecord = {
                            caseId: result[key].caseId,
                            contactId: result[key].contactId,
                            nameUrl: "/entity360/s/case/" + result[key].caseId,
                            caseNumber: result[key].caseNumber,
                            caseType: result[key].caseType,
                            firstName: result[key].restOfName,
                            lastName: result[key].lastName,
                            caseStatus: result[key].externalStatus,
                            actionNeeded: result[key].actionRequired ? 'Yes' : 'No',
                            dateOpened: result[key].createdDate,
                            lastModifiedDate: result[key].lastModifiedDate
                        }
                        tempRecord.serviceNamesList = '';
                        tempRecord.rowNumber = '' + (rowNum + 1);
                        if (result[key].hasOwnProperty('serviceNamesList')) {
                            for (let i = 0; i < result[key].serviceNamesList.length; i++) {
                                tempRecord.serviceNamesList = tempRecord.serviceNamesList + result[key].serviceNamesList[i] + ', ';
                            }
                        }
                        tempRecord.serviceNamesList = tempRecord.serviceNamesList.replace(/,\s*$/, "");
                        if (this.recordsList.length > 0) {
                            this.recordsList = [...this.recordsList, tempRecord];
                        } else {
                            this.recordsList = [tempRecord];
                        }
                        this.attributesList = ['serviceNamesList','caseId','nameUrl'];
                    }
                    rowNum = rowNum + 1;
                }
                this.activeRequests = this.recordsList;
                if (this.template.querySelector('.paginatorAR') !== null) {
                    this.template.querySelector('.paginatorAR').records = this.activeRequests;
                    this.template.querySelector('.paginatorAR').totalRecords = this.activeRequests.length;
                    this.template.querySelector('.paginatorAR').setRecordsPerPage();
                }
            }
            else{
                if(result === null){
                    this.recordsList = [];
                    this.isActiveReqFound = false;
                }
            }
        })
        .catch(error => {
            window.console.log("Error: ", JSON.stringify(error));
        });
    }
    //Capture the event fired from the paginator component
    handlePaginatorChange(event) {
        this.recordsToDisplay = event.detail;
        if (this.recordsToDisplay.length > 0) {
            this.rowNumberOffset = this.recordsToDisplay[0].rowNumber - 1;
        }
    }
    getKeys = function (obj) {
        var keys = [];
        for (var key in obj) {
            keys.push(key);
        }
        return keys;
    }
    displayCaseDetails(event){
        this.spinner = true;
        let row = event.detail.row;
        this.currentCaseId = row.caseId;
        this.contactId = row.contactId;
        let actionRequired = row.actionNeeded  ? 'Yes' : 'No';
        let caseStatusIncomplete = row.caseStatus  === 'Incomplete';
        this.assetIdToInsert =  JSON.stringify({
            contactId: this._currentEnt,
            caseId: 'Add a New User Request',
            documentType: 'Signed Signature Form',
            assetRecordType: 'Entity_Document',
            createOrReplace: 'Replace',
            assetStatus: 'In Progress',
            accountId: this._currentEnt,
            assetCreationRequired: 'true',
            assetId: null,
            createFromPB: 'true'
        });
        if(caseStatusIncomplete){
            getIncompleteSignedSignatureAsset({
                contactId: this.contactId
            })
            .then(asstDetails =>{
                if(asstDetails !== ''){
                    this.assetIdToDisplay = JSON.stringify(asstDetails);
                    this.showIncompleteSignForm = caseStatusIncomplete;
                    checkServiceAndAcceptedSignForm({
                        contactId: this.contactId,
                        caseId: this.currentCaseId
                    })
                    .then(showUpld =>{
                        if(showUpld === 'true'){
                            this.showFileUploadAndSubmit = actionRequired && caseStatusIncomplete;
                        }
                    })
                }
            })
            .catch(error =>{
                window.console.error("Error: " + JSON.stringify(error));
            });
        }else{
            this.showIncompleteSignForm = caseStatusIncomplete;
            this.showFileUploadAndSubmit = actionRequired && caseStatusIncomplete;
        }
        getContactDetail({
            contactId: this.contactId
        })
        .then(result =>{
            if(result){
                if(result.lastName !== "" && result.lastName !== undefined){
                    this.lastName = result.lastName;
                }
                if(result.restOfName !== "" && result.restOfName !== undefined){
                    this.restOfName = result.restOfName;
                }
                if(result.legalNameConsists !== "" && result.legalNameConsists !== undefined){
                    this.checkBoxValue = result.legalNameConsists;
                }
                if(result.generationalSuffix !== "" && result.generationalSuffix !== undefined){
                    this.generationalSuffix = result.generationalSuffix;
                }
                if(result.phoneNumber !== "" && result.phoneNumber !== undefined){
                    this.phoneNumber = result.phoneNumber;
                }
                if(result.department !== "" && result.department !== undefined){
                    this.department = result.department;
                }
                if(result.jobTitle !== "" && result.jobTitle !== undefined){
                    this.jobTitle = result.jobTitle;
                }
                if(result.emailAddress !== "" && result.emailAddress !== undefined){
                    this.emailAddress = result.emailAddress;
                }
                // Get Signed Signature Asset  
                getSignedSignatureAsset({
                    contactId: this.contactId
                })
                .then(assetInfo =>{
                    if(assetInfo !== ''){                
                        this.tempPayload.assetId = assetInfo;
                        this.tempPayload.documentType='Signed Signature Form';
                        this.entityAssetFileURL = JSON.stringify(this.tempPayload);                        
                    }
                    this.spinner = false;
                    this.showCaseDetail = true; 
                })
                .catch(error =>{
                    window.console.error(JSON.stringify(error));
                    this.spinner = false;
                }); 
            }     
        })
        .catch(error =>{
            window.console.error("Error: " + JSON.stringify(error));
        });
        // Get Services
        getRequestedServices({
            caseId: this.currentCaseId
        })
        .then(value =>{
            if(value){
                if(value.length > 0){
                    this.servicesList = [];
                    for(let key in value){
                        if(value.hasOwnProperty(key)){
                            this.roleList = 'User';
                            let tempRecordValues ={
                                serviceName: value[key].serviceName,
                                serviceId: value[key].serviceId,
                                signReq: value[key].signatureReq
                            };
                            this.servicesList.push(tempRecordValues);
                        }
                    }
                }else{
                    this.servicesList = [];
                }
            }
        })
        .catch(error =>{
            window.console.error("Error: " + JSON.stringify(error));
        });
        // Check Asset Signature is available in Contact or not
        checkAssetSignatureInContact({
            contactId: this.contactId
        })
        .then(value =>{
            if(value === 'False'){
                this.signatureAlreadyExist = false;
            }else{
                this.signatureAlreadyExist = true;
            }
        })
        .catch(error =>{
            window.console.error("Error: " + JSON.stringify(error));
        });
        // Delete unlinked Asset
        deleteOrpahnedAssetInContact({
            contactId: this.contactId
        })
        .catch(error =>{
            window.console.error("Error: " + JSON.stringify(error));
        });
    }
    handleOnAssetInserted(event){
        this.contactSignAsseAzureUrl = event.detail.url;
    }
    handleOnAssetUrlGenerated(event){
        this.fileUploaded = true;
        this.signatureFlag = false;  
        this.signUrl = event.detail.url;        
        this.contactSignAssetUrl = this.signUrl;
        this.assetIdToInsert =  JSON.stringify({
            contactId: null,
            caseId: 'Add a New User Request',
            documentType: 'Signed Signature Form',
            assetRecordType: 'Entity_Document',
            createOrReplace: 'Replace',
            assetStatus: 'In Progress',
            accountId: this._currentEnt,
            assetCreationRequired: 'true',
            assetId: null,
            createFromPB: 'true'
        }); 
    }
    submitButton(){
        if(this.showFileUploadAndSubmit === true && this.fileUploaded === false){
            this.showErrorMessages = true;
        }else{
            this.spinner = true;
            updateCaseandAsset({
                caseId: this.currentCaseId,
                assetAzureUrl: this.contactSignAsseAzureUrl,
                contactId: this.contactId
            }).then(result =>{
                if(result === 'true'){
                    this.spinner = false;
                    this.showCaseDetail = false;
                    this.setup();
                }
            });
        }
    }
    openModal(){
        this.template.querySelector('c-modal-component').show();
    }
    handleYesClick(){
        if(this.contactSignAssetUrl){
            this.spinner = true;
            delAssetOnCancel({assetUrl : this.contactSignAssetUrl})
            .then(result =>{
                if(result === 'true'){
                    this.signUrl = null;
                    this.spinner = false;
                    this.showCaseDetail = false; 
                }
            });
        }else{ 
            this.showCaseDetail = false;    
        }
    }
    @api refreshSetup(){
        this.setup();
    }
    handleARPaginatorChange(event) {
        this.recordsToDisplay = event.detail;
        if (this.recordsToDisplay.length > 0) {
            this.rowNumberOffset = this.recordsToDisplay[0].rowNumber - 1;
        }
    }
}