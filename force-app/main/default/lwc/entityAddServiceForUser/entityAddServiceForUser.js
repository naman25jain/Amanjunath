import { LightningElement, track, wire, api } from 'lwc';
import getListOfContactsInEntity from "@salesforce/apex/EntityServiceRequestController.getListOfContactsInEntity";
import getContactDetail from "@salesforce/apex/EntityServiceRequestController.getContactDetail";
import getServicesAndRole from "@salesforce/apex/EntityServiceRequestController.getServicesAndRole";
import createCaseandCase2Services from "@salesforce/apex/EntityServiceRequestController.createCaseandCase2Services";
import checkAssetSignatureInContact from "@salesforce/apex/EntityServiceRequestController.checkAssetSignatureInContact";
import delAssetOnCancel from "@salesforce/apex/EntityServiceRequestController.delAssetOnCancel";
export default class EntityAddServiceForUser extends LightningElement {
    @track contactList;
    @track contactId;
    @track lastName;
    @track restOfName;
    @track checkBoxValue;
    @track emailAddress;
    @track generationalSuffix;
    @track phoneNumber;
    @track department;
    @track jobTitle;
    @track legalNameConsists;
    @track serviceName;
    @track coordinatorDean;
    @track coordinator = true;
    @track serviceId;
    @track roleList;
    @track servicesList = [];
    @track showRestofDom = false;
    @track showServiceRoleTable;
    @api assetSignatureForm = false;
    @api contentDocumentId;
    @api fileName;
    @api fileType;
    @track spinner = false;
    @track modalTitle = 'Alert';
    @track modalContent = 'Are you sure you want to cancel? All changes will be lost.';
    @track showUploadSignature = false;
    @track fileUploaded = false;
    @track signatureAlreadyExist;
    @track contactSignAssetId;
    @track contactSignAssetAzureDocUrl;
    @track payloadSignedSignatureForm;
    @track showSignUploadButton = true;
    _currentEnt;
    @api
    get curEntity(){
        return this._currentEnt;
    }
    set curEntity(value){
        this.setAttribute('curEntity', value);
        this._currentEnt = value;   
    }
    @wire(getListOfContactsInEntity,{currentEntityId : '$_currentEnt'})
    getListOfContacts(result){     
        if(result.data !== undefined){
            let dataList = [];
            if(result !== '' ){
                let tempVal = [];
                dataList = result.data;
                for(var key in dataList){
                    let tempTcRecord = {value: key, label: result.data[key] }
                    tempVal.push(tempTcRecord);
                }
                this.contactList = tempVal;
                if(this.contactSignAssetAzureDocUrl){
                    delAssetOnCancel({assetUrl : this.contactSignAssetAzureDocUrl});
                    this.contactSignAssetAzureDocUrl = '';
                }
                this.payloadSignedSignatureForm = JSON.stringify({
                    contactId: this.contactId,
                    caseId: 'Add a New Service for User',
                    documentType: 'Signed Signature Form',
                    assetRecordType: 'Entity_Document',
                    createOrReplace: 'Create',
                    assetStatus: 'In Progress',
                    assetCreationRequired: 'true',
                    assetId: null,
                    azureUrl: null,
                    createFromPB: 'true'
                });
            }        
        } 
    }
    changeListOfContacts(event){
        const contactName = event.detail.value;
        this.contactId = contactName;
        this.lastName = '';
        this.restOfName ='';
        this.checkBoxValue = false;
        this.generationalSuffix ='';
        this.phoneNumber = '';
        this.department ='';
        this.jobTitle ='';
        this.emailAddress = '';
        this.legalNameConsists = '';
        this.showRestofDom = true;
        this.showUploadSignature = false;
        this.payloadSignedSignatureForm = JSON.stringify({
            contactId: this.contactId,
            caseId: 'Add a New Service for User',
            documentType: 'Signed Signature Form',
            assetRecordType: 'Entity_Document',
            createOrReplace: 'Create',
            assetStatus: 'In Progress',
            assetCreationRequired: 'true',
            assetId: null,
            azureUrl: null,
            createFromPB: 'true'
        });
        this.template.querySelectorAll(".servicecheckbox")
        .forEach(elem => {
          elem.checked = false;
        });
        getContactDetail({contactId : this.contactId})
        .then(result => {
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
            }
        })
        getServicesAndRole({contactId: this.contactId, currentEntityId: this._currentEnt})
            .then(value=>{
                if(value){
                    if(value.length > 0){
                        this.showServiceRoleTable = true;
                        this.servicesList = [];                      
                        for(let key in value){
                            if(value.hasOwnProperty(key)){
                                this.roleList = 'User';
                                let tempRecordValues = {
                                    serviceName: value[key].serviceName,
                                    serviceId: value[key].serviceId,
                                    signReq: value[key].signatureReq
                                };
                                this.servicesList.push(tempRecordValues);
                            }
                        }
                    }
                    else{
                        this.servicesList = [];
                        this.showServiceRoleTable = false;
                    }
                }
            })   
        checkAssetSignatureInContact({contactId: this.contactId})
            .then(value=>{
                if(value === 'False'){
                    this.signatureAlreadyExist = false;
                }
                else{
                    this.signatureAlreadyExist = true;
                }
            })
            this.sbmtButtonEnabled = false;
            delAssetOnCancel({assetUrl : this.contactSignAssetAzureDocUrl});
    }
    renderedCallback(){
        if(this.coordinator === false){
            this.template
            .querySelectorAll(".serviceComboBox")
            .forEach(elem => {
                elem.checked = false;
            });
            this.template
            .querySelectorAll(".servicecheckbox")
            .forEach(elem => {
                elem.checked = false;
            });
        }
        if(this.servicesList == ''){
            this.showServiceRoleTable = false;
        }
    }   
    handleOnAssetInserted(event){
        this.fileUpload = false;
        this.signatureFlag = false;
        this.contactSignAssetAzureDocUrl = event.detail.url;
        this.payloadSignedSignatureForm = JSON.stringify({
            contactId: this.contactId,
            caseId: 'Add a New Service for User',
            documentType: 'Signed Signature Form',
            assetRecordType: 'Entity_Document',
            createOrReplace: 'Create',
            assetStatus: 'In Progress',
            assetCreationRequired: 'true',
            assetId: null,
            azureUrl: event.detail.url,
            createFromPB: 'true'
        });
        this.fileUploaded = true;        
    }  
    openModal(){
        this.template.querySelector('c-modal-component').show();
    }
    handleYesClick(){
        delAssetOnCancel({assetUrl : this.contactSignAssetAzureDocUrl});
        const selectEvent = new CustomEvent("previousevent", {});
        this.dispatchEvent(selectEvent);
    }
    @track sbmtButtonEnabled = false;
    @track selectdSer = [];
    @track errorMessage = false;
    handleCheckboxChange(event){
        let tempShowButton = 0;
        let selectedServices = [];
        this.template.querySelectorAll(".servicecheckbox")
            .forEach(elem=>{
                if(elem.checked === true){
                    tempShowButton = tempShowButton + 1;
                    this.sbmtButtonEnabled = true;
                    selectedServices.push(elem.name);
                }
                else{
                    if(tempShowButton === 0){
                        this.sbmtButtonEnabled = false;
                    }
                }                   
            });
        this.selectdSer = JSON.stringify(selectedServices);
        if(this.signatureAlreadyExist === false){
            for(let count = 0; count < this.servicesList.length; count++){
                if( this.selectdSer.includes(this.servicesList[count].serviceId) && this.servicesList[count].signReq === true){
                    this.showUploadSignature = true;
                    this.errorMessage = false;
                    break;
                }
                else{
                    this.showUploadSignature = false;
                }
            }
            if(this.showUploadSignature === false && this.contactSignAssetAzureDocUrl){
                delAssetOnCancel({assetUrl : this.contactSignAssetAzureDocUrl});
                this.payloadSignedSignatureForm = '';
                this.payloadSignedSignatureForm = JSON.stringify({
                    contactId: this.contactId,
                    caseId: 'Add a New Service for User',
                    documentType: 'Signed Signature Form',
                    assetRecordType: 'Entity_Document',
                    createOrReplace: 'Create',
                    assetStatus: 'In Progress',
                    assetCreationRequired: 'true',
                    assetId: null,
                    createFromPB: 'true'
                });
            }
        }
    }
    nextButton(){
        if(this.showUploadSignature === true && this.fileUploaded === false){
            this.errorMessage = true;
        }
        else{
            this.spinner = true;
            if(this.showUploadSignature === true){
                this.caseStatus = 'Pending Review';
            }
            else{
                this.caseStatus = 'Pending User Access';
            }
            if(this.showUploadSignature == false && this.contactSignAssetAzureDocUrl){
                delAssetOnCancel({assetUrl : this.contactSignAssetAzureDocUrl});
                this.contactSignAssetAzureDocUrl = '';
            }
            createCaseandCase2Services({
                servicesSelected : this.selectdSer,
                contactId: this.contactId,
                caseStatus: this.caseStatus,
                assetUrl : this.contactSignAssetAzureDocUrl,
                currentEntityId : this._currentEnt
            })
            .then(result => {
                this.spinner = false;
                const selectEvent = new CustomEvent("previousevent", {});
                this.dispatchEvent(selectEvent);
            })
            .catch(error => {
                this.spinner = false;      
            });
        }       
    }
}