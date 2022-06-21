import { LightningElement,track,wire,api } from 'lwc';
import getCredentialAttributes from '@salesforce/apex/EpicCredVerController.getCredentialAttributes';
import markAssetsForDeletion from '@salesforce/apex/EpicCredVerController.deleteAssetsWithoutCase';
import assetsDeletionOnPageLoad from '@salesforce/apex/EpicCredVerController.assetsDeletionOnPageLoad';
import updateCatsRecord from '@salesforce/apex/EpicCredVerController.updateCatsRecord';
import getAssetUrls from '@salesforce/apex/EpicCredVerController.getAssetUrls';
import updateCredential from '@salesforce/apex/EpicCredVerController.updateCredential';
import createCredential from '@salesforce/apex/EpicCredVerController.createCredential';
import deleteEpicVerfRepRequestCase from '@salesforce/apex/EpicCredVerController.deleteEpicVerfRepRequestCase';
import dtChecker from '@salesforce/apex/EpicCredVerController.dtChecker';
import getCatCheckboxValues from '@salesforce/apex/EpicCredVerController.getCatCheckboxValues';
import checkEpicFMDExist from '@salesforce/apex/EpicCredVerController.checkEpicFMDExist';
import getContactId from '@salesforce/apex/AppForCertController.getContactId';
import getContact from '@salesforce/apex/AppForCertController.getContactName';
import epicFMD from '@salesforce/label/c.EPIC_Final_Medical_Diploma';
import epicAGD from '@salesforce/label/c.EPIC_Alternate_Graduation_Documents';
import epicFMST from '@salesforce/label/c.EPIC_Final_Medical_School_Transcript';
import epicSMST from '@salesforce/label/c.EPIC_Student_Medical_School_Transcript';
import epicPreIC from '@salesforce/label/c.EPIC_Pregraduate_Internship_Credential';
import epicPostIC from '@salesforce/label/c.EPIC_Postgraduate_Medical_Education_Credential';
import epicSQ from '@salesforce/label/c.EPIC_Specialist_Qualification';
import epicMRC from '@salesforce/label/c.EPIC_Medical_Registration_Certificate';
import epicLPM from '@salesforce/label/c.EPIC_License_to_Practice_Medicine';
import epicADMS from '@salesforce/label/c.EPIC_Advanced_Degree_in_the_Medical_Sciences';
import epicDL from '@salesforce/label/c.EPIC_Dean_s_Letter';
import epicCGS from '@salesforce/label/c.EPIC_Certificate_of_Good_Standing';
import epicTCT from '@salesforce/label/c.EPIC_Transfer_Credit_Transcript';
import getProgDocTypeMap from '@salesforce/apex/EpicCredVerController.getProgDocTypeMap';
import searchEntities from "@salesforce/apex/EpicCredVerController.searchEntities";
import checkVerifictn from "@salesforce/apex/EpicCredVerController.checkVerifictn";
import searchRegOrg from "@salesforce/apex/EpicCredVerController.searchRegOrgEpicReport";
import getEvrFieldValues from '@salesforce/apex/EpicCredVerController.getEvrFieldValues';
import {ShowToastEvent} from "lightning/platformShowToastEvent";
const EPIC_PROGRAM = "EPIC";
export default class CredIntakeManage extends LightningElement{  
    label = {epicFMD,epicAGD,epicFMST,epicSMST,epicPreIC,epicPostIC,epicSQ,epicMRC,epicLPM,epicADMS,epicDL,epicCGS,epicTCT};     
    _stylePresent = false;
    @track epic = false;
    @api program;    
    @track spinner = false;
    @track contactName = '' ;
    @track isNameDiffernt = false;
    @api recordId;    
    @track wrapRecValues = '';
    @track catRecValues = '';
    @track selectedEntErr = false;
    @track listOfFields = [];
    @track listOfFieldsError = [];
    @track listOfFieldsDateCheck = [];
    @track credAttError = false;
    @track showDocMsg = false;
    @track docTypeMsg = '';
    @track docTypeLPM = '';
    @track credItems = [];
    @track chosenAttrValue = '';
    @track checkBoxValue = false;
    @track showCredUploadButton = false;
    @track showUploadSection = false;
    @track showTranslationSection = false;
    @track showTransUploadButton = false;
    @track checkFMD = false;
    @track payloadCredential;
    @track payloadCredTrans;
    @track credUrl = null;
    @track transUrl = null;
    @track showCheckboxes = false;
    @track contactId = null;
    @track requestedToSend = false;
    @track haveCertificate = false;
    @track isErrTransUpload = false;
    @track isPortal = false;
    @track isNonPortalWeb = false;
    @track isNonPortalPaper = false;
    @track sendViaCourier = false;
    @track checkBoxError = false;
    @track checkBoxErrorMsg = 'Please select the appropriate option (Only one of the option should be checked)';
    @track tempPayloadCredential = {
        documentType: 'Final Medical Diploma',
        assetRecordType: 'Credential',
        createOrReplace: 'Create',
        assetStatus: 'In Progress',
        assetCreationRequired: 'true',
        assetName: 'Credential Request',
        assetId: null,
        caseId: null,
        createFromPB: 'true'
    };
    @track tempPayloadCredTrans = {
        documentType: 'Translation',
        assetRecordType: 'Credential',
        createOrReplace: 'Create',
        assetStatus: 'In Progress',
        assetCreationRequired: 'true',
        assetName: 'Credential type - Translation',
        assetId: null,
        caseId: null,
        createFromPB: 'true'
    };
    @track tempPayloadCredName = {
        documentType: 'Name Document',
        assetRecordType: 'Identity',
        createOrReplace: 'Create',
        assetStatus: 'In Progress',
        assetCreationRequired: 'true',
        assetName: 'Name Document',
        assetId: null,
        caseId: null,
        createFromPB: 'true'
    };
    @track breakSave;
    @track referenceNumber = '';
    @track isErrCredUpload = false;
    @track nameOnDoc;
    @track showNameUploadButton = false;
    @track showNameSection = false;
    @track nameUrl = null;
    @track payloadCredName;    
    @track nameOnDocErr = false;
    @track showEntitySearch = false;
    @track recordsList = [];
    @track recordIdEdit = null;
    @track records = [];
    @api searchfield = 'Name';
    @api iconname = "standard:account";
    @track modalTitle = 'Add New Entity';
    @track backTitle = 'Attention!'
    @track modalContent = '';
    @track confirmContent = 'You have selected the '+this.selectedAuthorityName+' to receive an EPIC Verification Report.The report will be sent automatically when your credential has been verified. Do you want to continue?';
    @track selectedRec = [];
    @track showAddedOrgs = false;
    @track selectedEntityId = '';
    @track selectedAccountName = '';
    @track selectedRecord = false;
    @api recordsExistSubmitButton = false;
    @track nameIsDifferent = false;
    @track translationRequired = false;
    @api editMode = false;
    @track uploadSection = true;
    @track authRecordsList = [];
    @track authRecords = [];
    @track selectedAuthRec = [];
    @track selectedAuthEntityId = '';
    @track selectedAuthRecord;
    @track showAuthEntitySearch = true;
    @track selectedAuthorityName= '';
    @track specialIntruction = '';
    @track regOrgDoNotKnow = false;
    @track evrRecord = {};
    @track stagingRecord = {};
    connectedCallback(){
        this.spinner = false;
        if(this.program === EPIC_PROGRAM){
            this.epic = true;
        }
        else{
            this.epic = false;
        }
        getContactId().then(result =>{
            this.contactName = ''
            this.contactId = result;
            this.tempPayloadCredential.contactId = this.contactId;
            this.tempPayloadCredTrans.contactId = this.contactId;
            this.tempPayloadCredName.contactId = this.contactId;
            this.payloadCredName = JSON.stringify(this.tempPayloadCredName);
            this.payloadCredential = JSON.stringify(this.tempPayloadCredential);
            this.payloadCredTrans = JSON.stringify(this.tempPayloadCredTrans);
            getContact({
                contactId: this.contactId
            }).then(result1 =>{
                 if(result1){
                    this.contactName = JSON.stringify(result1).replace('"', '').replace('"', '');
                }
            })
            assetsDeletionOnPageLoad({contactId: this.contactId});
            if(this.recordId){
                this.spinner = true;
                getCatCheckboxValues({catsId: this.recordId}).then(catsRecord=>{
                    if(catsRecord){
                        this.stagingRecord = catsRecord;
                        this.haveCertificate = catsRecord.Issued_in_the_last_90_days__c;
                        this.requestedToSend = catsRecord.Requested_to_be_sent_to_ECFMG__c;
                        this.selectedEntityId = catsRecord.Account__c;
                        this.sendViaCourier = catsRecord.Courier_service_for_an_additional_fee__c;
                        this.caseId = catsRecord.Case__c;
                        this.selectedRec = {
                            Name: catsRecord.Account__r.Name,
                            BillingStreet: catsRecord.Account__r.BillingStreet,
                            BillingCity: catsRecord.Account__r.BillingCity,
                            BillingState: catsRecord.Account__r.BillingState,
                            BillingCountry: catsRecord.Account__r.BillingCountry,
                            BillingPostalCode: catsRecord.Account__r.BillingPostalCode
                        }
                        this.selectedRecord = true;
                        getAssetUrls({caseId: this.caseId}).then(urlMap=>{
                            if(urlMap){
                                this.chosenAttrValue = catsRecord.Credential_Type__c;
                                this.tempPayloadCredential.documentType = catsRecord.Credential_Type__c;
                                this.payloadCredential = JSON.stringify(this.tempPayloadCredential);
                                this.tempPayloadCredTrans.assetName = this.chosenAttrValue+ ' - Translation';
                                this.payloadCredTrans = JSON.stringify(this.tempPayloadCredTrans);
                                this.validatePortalUser();
                                this.loadMappedFields();
                                if(this.chosenAttrValue === 'Final Medical Diploma'){            
                                    this.showDocMsg = true;        
                                    this.docTypeMsg = this.label.epicFMD;
                                }else if(this.chosenAttrValue === 'Certificate of Good Standing'){
                                    this.showCheckboxes = true;
                                    this.credUrl = null;
                                    this.showDocMsg = true;        
                                    this.docTypeMsg = this.label.epicCGS;
                                }else if(this.chosenAttrValue === 'Alternate Graduation Document'){
                                    this.showDocMsg = true;        
                                    this.docTypeMsg = this.label.epicAGD;
                                }else if(this.chosenAttrValue === 'Letter from Dean'){
                                    this.showDocMsg = true;        
                                    this.docTypeMsg = this.label.epicDL;
                                }else if(this.chosenAttrValue === 'Final Medical School Transcript'){
                                    this.showDocMsg = true;        
                                    this.docTypeMsg = this.label.epicFMST;
                                }else if(this.chosenAttrValue === 'Student Medical School Transcript'){
                                    this.showDocMsg = true;        
                                    this.docTypeMsg = this.label.epicSMST;
                                }else if(this.chosenAttrValue === 'Transcript to Document Transfer Credits'){
                                    this.showDocMsg = true;        
                                    this.docTypeMsg = this.label.epicTCT;
                                }else if(this.chosenAttrValue === 'Pregraduate Internship Certificate'){
                                    this.showDocMsg = true;        
                                    this.docTypeMsg = this.label.epicPreIC;
                                }else if(this.chosenAttrValue === 'Postgraduate Training Credential'){
                                    this.showDocMsg = true;        
                                    this.docTypeMsg = this.label.epicPostIC;
                                }else if(this.chosenAttrValue === 'Specialist Qualification'){
                                    this.showDocMsg =true;        
                                    this.docTypeMsg = this.label.epicSQ;
                                }else if(this.chosenAttrValue === 'Advanced Degree in the Medical Sciences'){
                                    this.showDocMsg = true;        
                                    this.docTypeMsg = this.label.epicADMS;
                                }else if(this.chosenAttrValue === 'Medical Registration Certificate/License to Practice Medicine'){
                                    this.showDocMsg = true;        
                                    this.docTypeMsg = this.label.epicMRC;
                                    this.docTypeLPM = this.label.epicLPM;
                                }
                                this.credUrl = urlMap['Credential Request'];
                                this.nameOnDoc = urlMap['Name on document'];
                                this.tempPayloadCredTrans.parentUrl = urlMap['Credential Request'];
                                this.payloadCredTrans = JSON.stringify(this.tempPayloadCredTrans);
                                this.tempPayloadCredName.parentUrl = urlMap['Credential Request'];
                                this.payloadCredName = JSON.stringify(this.tempPayloadCredName);
                                if(urlMap['Name is different'] === 'true'){
                                    this.nameIsDifferent = true;
                                    this.nameUrl = urlMap['Name Document'];
                                    this.showNameUploadButton = true;
                                }
                                if(urlMap['Translation required'] === 'true'){
                                    this.translationRequired = true;
                                    this.transUrl = urlMap['Translation'];
                                    this.showTransUploadButton = true;
                                }
                                this.showDocMsg = true;
                                if(this.chosenAttrValue !== 'Certificate of Good Standing' || (this.chosenAttrValue === 'Certificate of Good Standing' && this.haveCertificate === true)){
                                    this.showNameSection = true;
                                    this.showUploadSection = true;
                                    this.showCredUploadButton = true;
                                    this.showTranslationSection = true;
                                }
                                if(this.chosenAttrValue == 'Certificate of Good Standing'){
                                    this.showCheckboxes = true;
                                }
                                getEvrFieldValues({catsId:this.recordId}).then(evrRcrd=>{
                                    if(evrRcrd){
                                        this.evrRecord = evrRcrd;
                                        this.selectedAuthEntityId = evrRcrd.Entity__c;
                                        this.regOrgDoNotKnow = evrRcrd.Do_Not_Know_Orgs_to_send_EPIC_Reports__c;
                                        this.referenceNumber = evrRcrd.Reference_Number__c;
                                        if(this.selectedAuthEntityId){
                                            this.selectedAuthorityName = evrRcrd.Entity__r.Name;
                                            this.selectedAuthRec = {
                                                Name: evrRcrd.Entity__r.Name,
                                                BillingStreet: evrRcrd.Entity__r.BillingStreet,
                                                BillingCity: evrRcrd.Entity__r.BillingCity,
                                                BillingState: evrRcrd.Entity__r.BillingState,
                                                BillingCountry: evrRcrd.Entity__r.BillingCountry,
                                                BillingPostalCode: evrRcrd.Entity__r.BillingPostalCode
                                            }
                                            if(evrRcrd.Entity__r.Parent_Authority__c != null && evrRcrd.Entity__r.Parent_Authority__r.Use_same_instruction_for_child_entities__c == true){
                                                this.specialIntruction = evrRcrd.Entity__r.Parent_Authority__r.EPIC_Client_Special_Instructions_Languag__c;
                                            }else{
                                                this.specialIntruction = evrRcrd.Entity__r.EPIC_Client_Special_Instructions_Languag__c;
                                            }
                                            this.showAuthEntitySearch = false;
                                            this.selectedAuthRecord = true;
                                        }
                                        if(this.regOrgDoNotKnow){
                                            this.selectedAuthRecord = false;
                                            this.showAuthEntitySearch = false;
                                            this.selectedAuthEntityId = '';
                                            this.selectedEntErr = false;
                                            this.selectedAuthorityName = '';
                                            this.referenceNumber = '';
                                        }
                                    }else{                                        
                                        this.regOrgDoNotKnow = true;
                                        this.selectedAuthRecord = false;
                                        this.showAuthEntitySearch = false;
                                        this.selectedAuthEntityId = '';
                                        this.selectedEntErr = false;
                                        this.selectedAuthorityName = '';
                                        this.referenceNumber = '';
                                    }
                                })
                                this.spinner = false;
                            }
                        })
                    }
                })
            }else{
                this.spinner = false;
            }
        })
    }
    @wire(getCredentialAttributes,{
        programName: '$program'
    })
    wiredCredAttr({error, data}){
        if(data){
            for(var i=0; i<data.length; i++){
                this.credItems = [...this.credItems ,{value: data[i], label: data[i]}];  
            }                                 
        }
        else if(error){
            this.credItems = [];
        }
    } 
    loadMappedFields(){
        if(this.chosenAttrValue){
            this._stylePresent = false;
            getProgDocTypeMap({docName:this.chosenAttrValue,programName: this.program})
            .then(
            result=>{                   
                this.listOfFields = [];                 
                if(result){
                    for(let key in result){                    
                        if(result.hasOwnProperty(key)){ // Filtering the data in the loop 
                            if(this.chosenAttrValue === 'Certificate of Good Standing'){
                                this.listOfFields.push({value:result[key], key:key, isReq:false, errMSg:'', required:false});
                            }else{
                                this.listOfFields.push({value:result[key], key:key, isReq:false, errMSg:'', required:true});
                            }                           
                        }
                    }
                    if(this.recordId){
                        let tempList = [];
                        for(let i=0; i < this.listOfFields.length; i++){
                            let tempRecord = this.listOfFields[i];
                            if(tempRecord){
                                if((tempRecord.key === 'Expiration_Date__c' || (this.haveCertificate && key === 'Issue_Date__c'))&& this.chosenAttrValue === 'Certificate of Good Standing'){
                                    tempList.push({value:tempRecord.value, key:tempRecord.key, isReq:tempRecord.isisReq, fieldValue:this.stagingRecord[tempRecord.key], required:false});
                                }else{
                                    tempList.push({value:tempRecord.value, key:tempRecord.key, isReq:tempRecord.isisReq, fieldValue:this.stagingRecord[tempRecord.key], required:true});
                                }
                            }
                        }
                        this.listOfFields = tempList;
                    }else{
                        this.spinner = false;           
                    }
                }
           })
        }         
    }
    handleChangeCredential(event){
        this.recordId = null;
        this.selectedEntErr = false;
        this.selectedAuthEntityId = '';
        this.selectedAuthRec = [];
        this.selectedAuthRecord = false;
        this.selectedAuthorityName = '';
        this.regOrgDoNotKnow = false;
        this.referenceNumber = '';
        this.showAuthEntitySearch = true;
        this.isPortal = false;
        this.isNonPortalWeb = false;
        this.isNonPortalPaper = false;
        this.sendViaCourier = false;
        this.recordIdEdit = null;
        this.selectedRec = [];
        this.selectedEntityId = null;
        this.nameIsDifferent = false;
        this.translationRequired = false;
        this.spinner = true;
        this.nameOnDoc = null;
        this.credAttError = false;
        this.listOfFields = []; 
        this.nameOnDocErr = false;
        this.showNameUploadButton = false;
        this.showNameSection = false;
        this.isErrCredUpload = false;
        this.isErrTransUpload = false;
        this.tempPayloadCredTrans.assetName = event.detail.value+ ' - Translation';
        this.showTranslationSection = false;
        this.showTransUploadButton = false;
        this.requestedToSend = false;
        this.haveCertificate = false;
        this.showCheckboxes = false;
        this.showUploadSection = false; 
        this.showCredUploadButton = false;
        this.checkFMD = false; 
        this.showDocMsg =false;    
        this.recordsExistSubmitButton = true;
        this.selectedRecord = true; 
        this.recordsList = [];
        this.showEntitySearch = false;
        this.selectedAccountName = '';
        this.recordsExistSubmitButton = false;
        this.specialIntruction = '';
        if(this.template.querySelector('.accountName') !== null){
            this.template.querySelector('.accountName').value = '';
        }
        const selectedOption = event.detail.value;
        if(selectedOption !== this.chosenAttrValue && this.credUrl !== null){
            markAssetsForDeletion({azureUrl : this.credUrl});
            this.credUrl = null;
            if(this.transUrl){
                markAssetsForDeletion({azureUrl : this.transUrl});
                this.transUrl = null;
                this.showTranslationSection = false;
                this.showTransUploadButton = false;
            }
            if(this.nameUrl){
                markAssetsForDeletion({azureUrl : this.nameUrl});
                this.nameUrl = null;
                this.showNameSection = false;
                this.showNameUploadButton = false;
            }
        }
        this.chosenAttrValue = selectedOption;
        if(this.chosenAttrValue !== 'Final Medical Diploma'){ 
            this.loadMappedFields();
        }
        this.tempPayloadCredential.documentType = this.chosenAttrValue;
        this.payloadCredential = JSON.stringify(this.tempPayloadCredential);
        this.docTypeMsg = '';
        this.docTypeLPM = '';
        if(this.chosenAttrValue){
            this.showEntitySearch = true;
            this.selectedRecord = false;
        }
        if(this.chosenAttrValue === 'Final Medical Diploma'){            
            this.showDocMsg = true;        
            this.docTypeMsg = this.label.epicFMD;
            checkEpicFMDExist({}).then(result =>{
                if(result){
                    this.showUploadSection = false;
                    this.checkFMD = true;
                    this.spinner = false;
                }
                else{
                    this.credUrl = null;
                    this.checkFMD = false;
                    this.showUploadSection = true;
                    this.showCredUploadButton = true;
                    this.loadMappedFields();
                }
            })
        }else if(this.chosenAttrValue === 'Certificate of Good Standing'){
            this.showCheckboxes = true;
            this.credUrl = null;
            this.showDocMsg = true;        
            this.docTypeMsg = this.label.epicCGS;
        }else if(this.chosenAttrValue === 'Alternate Graduation Document'){
            this.showDocMsg = true;        
            this.docTypeMsg = this.label.epicAGD;
        }else if(this.chosenAttrValue === 'Letter from Dean'){
            this.showDocMsg = true;        
            this.docTypeMsg = this.label.epicDL;
        }else if(this.chosenAttrValue === 'Final Medical School Transcript'){
            this.showDocMsg = true;        
            this.docTypeMsg = this.label.epicFMST;
        }else if(this.chosenAttrValue === 'Student Medical School Transcript'){
            this.showDocMsg = true;        
            this.docTypeMsg = this.label.epicSMST;
        }else if(this.chosenAttrValue === 'Transcript to Document Transfer Credits'){
            this.showDocMsg = true;        
            this.docTypeMsg = this.label.epicTCT;
        }else if(this.chosenAttrValue === 'Pregraduate Internship Certificate'){
            this.showDocMsg = true;        
            this.docTypeMsg = this.label.epicPreIC;
        }else if(this.chosenAttrValue === 'Postgraduate Training Credential'){
            this.showDocMsg = true;        
            this.docTypeMsg = this.label.epicPostIC;
        }else if(this.chosenAttrValue === 'Specialist Qualification'){
            this.showDocMsg =true;        
            this.docTypeMsg = this.label.epicSQ;
        }else if(this.chosenAttrValue === 'Advanced Degree in the Medical Sciences'){
            this.showDocMsg = true;        
            this.docTypeMsg = this.label.epicADMS;
        }else if(this.chosenAttrValue === 'Medical Registration Certificate/License to Practice Medicine'){
            this.showDocMsg = true;        
            this.docTypeMsg = this.label.epicMRC;
            this.docTypeLPM = this.label.epicLPM;
        }        
        if(this.chosenAttrValue !== 'Certificate of Good Standing' && this.chosenAttrValue !== 'Final Medical Diploma'){
            this.credUrl = null;
            this.showUploadSection = true;
            this.showCredUploadButton = true;
            this.template.querySelector("c-cloud-document-upload-wrapper").auraThumbnailLoader();
        }        
    }
    handleOnCredentialUpload(event){
        this.showCredUploadButton = false;
        this.credUrl = event.detail.url;
        this.tempPayloadCredTrans.parentUrl = event.detail.url;
        this.tempPayloadCredName.parentUrl = event.detail.url;
        this.showNameSection = true;
        this.showCredUploadButton = true;
        this.isErrCredUpload = false;
        this.showTranslationSection = true;
    }
    handleUploadTransOrNot(event){
        this.checkBoxValue = event.target.checked;
        this.translationRequired = event.target.checked;
        this.isErrTransUpload = false;
        this.payloadCredTrans = JSON.stringify(this.tempPayloadCredTrans);
        if(this.checkBoxValue){
            this.showTransUploadButton = true;
        }
        else{
            this.showTransUploadButton = false;
            if(this.transUrl){
                markAssetsForDeletion({azureUrl : this.transUrl});
                this.transUrl = null;
            }
        }
    }
    handleVerReqCourier(event){
        this.sendViaCourier = event.target.checked;
    }
    handleOnCredTransUpload(event){
        this.isErrTransUpload = false;
        this.showTransUploadButton = false;
        this.transUrl = event.detail.url;
        this.showTransUploadButton = true;
    }
    preventBackslash(event){
        if(event.which === 8 || event.which === 46){
            event.preventDefault();
        }
    }
    validateInputForDate(event){
        if(event.target.fieldName.includes("Date__c")){
            if(event.which > 7 &&  event.which < 222){
                event.preventDefault();
            }
        }
        if(event.target.fieldName.includes("Year")){
            if(!((event.keyCode >= 48 && event.keyCode <= 57)||event.keyCode == 8 || event.keyCode == 46)){
                event.preventDefault();
            }
        } 
    }
    preventDefaultMethod(event){
        event.preventDefault();
    }
    handleChangeRequestedToSend(event){
        this.requestedToSend = event.target.checked;
    }
    handleChangeHaveCertificate(event){
        this.haveCertificate = event.target.checked;
        this.loadMappedFields();
        this.showUploadSection = false;
        this.showCredUploadButton = false;
        this.isErrCredUpload = false;
        this.isErrTransUpload = false;
        this.nameOnDocErr = false;
        if(this.haveCertificate){
            this.showUploadSection = true;
            this.showCredUploadButton = true;
        }else{
            this.nameOnDoc = null;
            this.showNameSection = false;
            this.showNameUploadButton = false;
            this.showTranslationSection = false;
            this.showTransUploadButton = false;
            if(this.credUrl){
                markAssetsForDeletion({azureUrl : this.credUrl});
                this.credUrl = null;
            }
            if(this.transUrl){
                markAssetsForDeletion({azureUrl : this.transUrl});
                this.transUrl = null;
            }
            if(this.nameUrl){
                markAssetsForDeletion({azureUrl : this.nameUrl});
                this.nameUrl = null;
            }
        }
    }
    saveButton(){
        if(this.uploadSection){
            this.validateAllValues();
        }
        if(this.uploadSection === false && this.showAuthEntitySearch === true && this.selectedAuthEntityId === ''){
            this.breakSave = true;
            this.selectedEntErr = true;
        }
        if(!this.breakSave){  
            this.spinner = true;
            if(this.caseId){//For Editing the form
                this.spinner = true;
                this.recordIdEdit = null;
                let tempEvr = {
                    program : this.program,
                    authId : this.selectedAuthEntityId,
                    ref : this.referenceNumber,
                    regOrgDNK : this.regOrgDoNotKnow
                } 
                let tempCatsRecord = JSON.parse(this.catRecValues);
                tempCatsRecord.Id = this.stagingRecord.Id;
                updateCatsRecord({fieldvals:JSON.stringify(tempCatsRecord), catsId:this.stagingRecord.Id}).then(result=>{
                    let credUploadWrapper ={
                        credUrl: this.credUrl,
                        transUrl: this.transUrl,
                        nameUrl: this.nameUrl,
                        nameOnDoc: this.nameOnDoc,
                        nameDifferent: this.showNameUploadButton,
                        translationRequired: this.showTransUploadButton,
                        requestedToSend: this.requestedToSend,
                        haveCertificate: this.haveCertificate,
                        caseId: this.caseId,
                        catsId: this.stagingRecord.Id,
                        entityId: this.selectedEntityId,
                        evrId:this.evrRecord.Id,
                        evrWrap:JSON.stringify(tempEvr)
                    }
                    updateCredential({inputJSON: JSON.stringify(credUploadWrapper)}).then(saveResult=>{
                        if(saveResult){
                            const selectEvent = new CustomEvent('showscredintland', {});
                            this.dispatchEvent(selectEvent);
                            this.spinner = false;
                        }
                    })
                    if(this.regOrgDoNotKnow == true){
                        deleteEpicVerfRepRequestCase({
                            evrcsId:this.evrRecord.Id,
                            secParentCaseId:this.caseId,
                            regOrgDNK:this.regOrgDoNotKnow,
                        })
                    }
                })
            }
            else{
                let evr = {
                    program : this.program,
                    authId : this.selectedAuthEntityId,
                    ref : this.referenceNumber,
                    regOrgDNK : this.regOrgDoNotKnow
                }                
                createCredential({inputJSON: this.wrapRecValues,fieldvals:this.catRecValues,evrValues:JSON.stringify(evr)}).then(saveResult=>{
                    if(saveResult){
                        this.spinner = false;                        
                        const selectEvent = new CustomEvent('showscredintland', {});
                        this.dispatchEvent(selectEvent);
                    }
                })
            }            
        }
    }
    handleChangeForInputFields(event){
        this.nameOnDoc = event.target.value;
        this.nameOnDocErr = false;
    }
    handleUploadNameCheckbox(event){
        this.payloadCredName = JSON.stringify(this.tempPayloadCredName);
        this.showNameUploadButton = event.target.checked;
        this.nameIsDifferent = event.target.checked; 
        if(!event.target.checked){
            if(this.nameUrl){
                markAssetsForDeletion({azureUrl : this.nameUrl});
                this.nameUrl = null;
            }
        }
    }
    handleOnCredNameUpload(event){
        this.showNameUploadButton = false;
        this.nameUrl = event.detail.url;
        this.showNameUploadButton = true;
    }
    cancelButton(event){
        if(this.credUrl){
            markAssetsForDeletion({azureUrl : this.credUrl});
            this.credUrl = null;
        }
        if(this.transUrl){
            markAssetsForDeletion({azureUrl : this.transUrl});
            this.transUrl = null;
        }
        if(this.nameUrl){
            markAssetsForDeletion({azureUrl : this.nameUrl});
            this.nameUrl = null;
        }
        event.preventDefault();
        const selectEvent = new CustomEvent('showscredintland', {});
        this.dispatchEvent(selectEvent);    
    }
    deleteNameAsset(){
        this.nameUrl = null;
    }  
    renderedCallback(){      
        if(this.template.querySelector('lightning-input-field') !== null && this._stylePresent === false){
            const style = document.createElement('style');
            style.innerText = `c-cred-intake-manage .slds-form-element__icon{
                display: none;
            }.accountName .slds-input{
                padding-left: 6%;
            }.slds-has-error .slds-form-element__help{
                display: none;
            }`;
            this.template.querySelector('lightning-input-field').appendChild(style);            
            this._stylePresent = true;
        }
    }
    handleChangeForSearch(event){
        const searchKey = event.detail.value;
        this.recordsList = [];
        this.records = [];
        this.recordsExistSubmitButton = false;
        searchEntities({
            searchKey: searchKey, credType: this.chosenAttrValue, programName: this.program
        }).then(result =>{
            this.records = result;
            this.recordsList = [];
            for(let i=0; i < this.records.length; i++){
                let rec = this.records[i];
                this.recordsList.push(rec);
                this.recordsList[i].Name = rec[this.searchfield];
                this.recordsList[i].Id = this.records[i].Id;
            }
        }).catch(error =>{
            this.records = undefined;
        });
        if(searchKey && this.chosenAttrValue !== 'Final Medical Diploma' && this.chosenAttrValue !== 'Final Medical School Transcript' && this.chosenAttrValue !== 'Transcript to Document Transfer Credits' && this.chosenAttrValue !== 'Student Medical School Transcript' && this.chosenAttrValue !== 'Alternate Graduation Document' && this.chosenAttrValue !== 'Letter from Dean'){
            this.recordsExistSubmitButton = true;
        }
        if(!searchKey){
            this.recordsList = [];
        }
    }
    handleSelect(event){
        this.selectedEntErr = false;
        this.selectedRec = event.detail;
        this.selectedEntityId = this.selectedRec.Id; 
        this._stylePresent = false;               
        this.template.querySelector('.addScreenModal').show();
    }
    handleYesClick(){
        this.showEntitySearch = true;
        this.selectedRecord = false;
        this.showEntitySearch = false;
        this.selectedRecord = true;
        this.validatePortalUser();
        const successevt = new ShowToastEvent({
                                title: "Success",
                                message: 'Entity has been added',
                                variant: "Success"
                                });
        this.dispatchEvent(successevt);
    }
    handleDeleteOnClick(event){
        this.template.querySelector('.removeScreenModal').title = 'Remove this entity?';
        this.template.querySelector('.removeScreenModal').show();
    }
    handleYesDeleteClick(){
        this.selectedRecord = true;
        this.showEntitySearch = false;
        this.recordsExistSubmitButton = true;
        this.recordsList = [];
        this.selectedRecord = false;
        this.showEntitySearch = true;
        this.recordsExistSubmitButton = false;
        this.selectedEntityId = '';
        this.isPortal = false;
        this.isNonPortalWeb = false;
        this.isNonPortalPaper = false;
        this.sendViaCourier = false;
        const successevt = new ShowToastEvent({
                                title: "Success",
                                message: 'Entity has been removed',
                                variant: "Success"
                                });
        this.dispatchEvent(successevt);
    }
    validatePortalUser(){
        this.isPortal = false;
        this.isNonPortalWeb = false;
        this.isNonPortalPaper = false;
        if(this.selectedEntityId){  
            checkVerifictn({
                accId: this.selectedEntityId, credType: this.chosenAttrValue})
                .then(result =>{
                if(result){
                    if(result === 'PORTAL'){
                        this.sendViaCourier = false;
                        this.isPortal = true;
                        this.isNonPortalWeb = false;
                        this.isNonPortalPaper = false;
                    }else if(result === 'NONPORTAL_EM_Web'){
                        this.isPortal = false;
                        this.isNonPortalWeb = true;
                        this.isNonPortalPaper = false;
                        this.sendViaCourier = false;
                    }else if(result === 'NONPORTAL_PAPER'){
                        this.isPortal = false;
                        this.isNonPortalWeb = false;
                        this.isNonPortalPaper = true;
                    } 
                }
            }).catch(error =>{
                window.console.log('error'+JSON.stringify(error));
            });
        }   
    }
    nextButton(){
        this.validateAllValues();
    }
    validateAllValues(){        
        this.nameOnDocErr = false;
        this.credAttError = false;
        this.breakSave = false;
        this.isErrCredUpload = false;
        this.isErrTransUpload = false;
        this.checkBoxError = false;
        const inputFields = this.template.querySelectorAll('lightning-input-field');
        if(!this.chosenAttrValue && this.template.querySelector('.credAtt') !== null){
            this.credAttError = true;
            this.breakSave = true;
            this.template.querySelector('.credAtt').classList.add('slds-has-error');            
        }
        else{
            if(this.template.querySelector('.credAtt') !== null){
                this.credAttError = false;
                this.template.querySelector('.credAtt').classList.remove('slds-has-error');
            }            
        }
        if(((this.chosenAttrValue === 'Certificate of Good Standing' && this.haveCertificate === true) || (this.chosenAttrValue !== 'Certificate of Good Standing')) && (this.credUrl === null || this.credUrl === undefined)){            
            this.isErrCredUpload = true;
            this.breakSave = true;
        }
        if(this.chosenAttrValue === 'Certificate of Good Standing' && this.haveCertificate === false && this.requestedToSend === false){            
            this.checkBoxError = true;
            this.breakSave = true;
        }
        if(this.chosenAttrValue === 'Certificate of Good Standing' && this.haveCertificate === true && this.requestedToSend === true){            
            this.checkBoxError = true;
            this.breakSave = true;
        }
        if(this.showTransUploadButton === true && this.transUrl === null){
            this.isErrTransUpload = true;
            this.breakSave = true;
        }
        if(!this.selectedEntityId && this.showEntitySearch && !this.selectedRecord){
            this.selectedEntErr = true;
            this.breakSave = true;
        }
        if(!this.nameOnDoc && this.template.querySelector('.nameOnDoc') !== null){
            this.nameOnDocErr = true;
            this.breakSave = true;
            this.template.querySelector('.nameOnDoc').classList.add('slds-has-error');  
        }
        else{
            this.nameOnDocErr = false;
            if(this.template.querySelector('.nameOnDoc') !== null){
                this.template.querySelector('.nameOnDoc').classList.remove('slds-has-error');
            }            
        }        
        if(inputFields && inputFields.length !== 0){
            let tempVal = [];
            let tempValFields = [];        
            let valDateCheck = {} 
            inputFields.forEach(field => {
                if(field.value){   
                    field.classList.remove('slds-has-error');
                    field.isReq = false; 
                    field.errMSg = '';
                    if(field.fieldName === 'Degree_Issue_Date__c'){
                        valDateCheck.degIssueDt = field.value;
                    }
                    if(field.fieldName === 'Graduation_Year__c'){
                        valDateCheck.gradYrDt = field.value;
                    }
                    if(field.fieldName === 'Degree_expected_to_be_issued_Year__c'){
                        valDateCheck.degExpYrDt = field.value;
                    }
                    if(field.fieldName === 'Attendance_Start_Date__c'){
                        valDateCheck.attStDt = field.value;
                    }
                    if(field.fieldName === 'Attendance_End_Date__c'){
                        valDateCheck.attEndDt = field.value;
                    }
                    if(field.fieldName === 'Program_Start_Date__c'){
                        valDateCheck.prStDt = field.value;
                    }
                    if(field.fieldName === 'Program_End_Date__c'){
                        valDateCheck.prEndDt = field.value;
                    }                
                    if(field.fieldName === 'Issue_Date__c'){
                        valDateCheck.issDt = field.value;
                    }
                    if(field.fieldName === 'Expiration_Date__c'){
                        valDateCheck.expDt = field.value;
                    }               
                }else{
                    if(this.chosenAttrValue === 'Certificate of Good Standing'){
                        field.isReq = false;   
                    }
                    else{
                        field.isReq = true;
                        this.breakSave = true;
                        field.errMSg = 'Please enter the value';
                        field.classList.add('slds-has-error');
                    }
                }            
                tempVal.push({key:field.fieldName,isReq:field.isReq,errMSg:field.errMSg});
            }); 
            this.listOfFieldsError = [];            
            this.listOfFieldsError= tempVal;            
            tempValFields = this.listOfFields;
            this.listOfFields = [];            
            for(const k in tempValFields){                
                if(tempValFields.hasOwnProperty(k)){
                    let ele = tempValFields[k];                    
                    for(const assKey in this.listOfFieldsError){
                        if(this.listOfFieldsError.hasOwnProperty(assKey)){                            
                            let errorEle = this.listOfFieldsError[assKey];                              
                            if(errorEle.key === ele.key){
                                if(this.chosenAttrValue === 'Certificate of Good Standing'){
                                    this.listOfFields.push({value:ele.value, key:ele.key, isReq:errorEle.isReq, errMSg:errorEle.errMSg, required:false}); 
                                }else{
                                    this.listOfFields.push({value:ele.value, key:ele.key, isReq:errorEle.isReq, errMSg:errorEle.errMSg, required:true}); 
                                }          
                            }
                        }           
                    }
                }
            }
            dtChecker({
                dtValues: JSON.stringify(valDateCheck)})
                .then(result =>{
                    this.spinner = true;
                    if(result){
                        this.listOfFieldsDateCheck = [];
                        for(let key in result){                    
                            if(result.hasOwnProperty(key)){
                                this.listOfFieldsDateCheck.push({value:result[key], key:key});                                                       
                            }
                        }
                        let tempDateCheckFld = [];
                        inputFields.forEach(field=>{
                            field.isReq = false;
                            field.dtErrormsg = '';
                            for(const k in this.listOfFieldsDateCheck){
                                if(this.listOfFieldsDateCheck.hasOwnProperty(k)){
                                    let eleDtErr = this.listOfFieldsDateCheck[k];
                                    if(eleDtErr.key === field.fieldName){
                                        this.breakSave = true;	
                                        field.isReq = true;	
                                        field.dtErrormsg = eleDtErr.value;				
                                        field.classList.add('slds-has-error');                                                		
                                    }
                                }
                            }
                            tempDateCheckFld.push({isReq:field.isReq, key:field.fieldName, value:field.dtErrormsg});  
                        });
                        let tempDt = [];
                        tempDt = this.listOfFields;
                        this.listOfFields = []; 
                        for(const fld in tempDateCheckFld){
                            if(tempDateCheckFld.hasOwnProperty(fld)){
                                let eleDt = tempDateCheckFld[fld];                                 
                                    for(const key in tempDt){
                                        if(tempDt.hasOwnProperty(key)){                            
                                            let errorEle = tempDt[key];    
                                            if(errorEle.key === eleDt.key){
												if(eleDt.isReq){
                                                    if(this.chosenAttrValue === 'Certificate of Good Standing'){
                                                        this.listOfFields.push({value:errorEle.value, key:errorEle.key, isReq:eleDt.isReq, errMSg:eleDt.value, fieldValue:errorEle.fieldValue, required:false});
                                                    }else{
                                                        this.listOfFields.push({value:errorEle.value, key:errorEle.key, isReq:eleDt.isReq, errMSg:eleDt.value, fieldValue:errorEle.fieldValue, required:true});
                                                    }
												}
												else{
                                                    if(this.chosenAttrValue === 'Certificate of Good Standing'){
                                                        this.listOfFields.push({value:errorEle.value, key:errorEle.key, isReq:errorEle.isReq, errMSg:errorEle.errMSg, fieldValue:errorEle.fieldValue, required:false});
                                                    }else{
                                                        this.listOfFields.push({value:errorEle.value, key:errorEle.key, isReq:errorEle.isReq, errMSg:errorEle.errMSg, fieldValue:errorEle.fieldValue, required:true});
                                                    }
												} 
                                                this.spinner = false;                                                
                                            }
                                        }                                        		
                                    }
                                }
                            }
                        if(!this.breakSave){
                            this.uploadSection = false;
                            this.saveCATandAsst();
                        }                       
                    }  
            }).catch(error =>{
                window.console.log('Error'+JSON.stringify(error));
                this.spinner = false;
            });
        }
    }
    cancelButtonToOpen(){
        this.template.querySelector('[data-id="newModalAlert"]').show();
    }
    closeModal(){
        this.template.querySelector('[data-id="newModalAlert"]').hide();
    }
    clearSearchBox(){
        this.selectedAccountName = '';
    }
    handleCreateNewAcc(event){
        this.selectedRec = event.detail;
        this.selectedEntityId = this.selectedRec.Id;
        this.showEntitySearch = true;
        this.selectedRecord = false;
        this.showEntitySearch = false;
        this.selectedRecord = true;
        if(this.selectedEntityId){
            const successevt = new ShowToastEvent({
                title: "Success",
                message: 'Entity has been added',
                variant: "Success"
                });
            this.dispatchEvent(successevt);
        }
    }
    handleChangeForAuthSearch(event){
        const searchKey = event.detail.value;
        this.authRecordsList = [];
        this.authRecords = [];
        searchRegOrg({
            searchKey:searchKey,
            issuedEntity: this.selectedEntityId
        }).then(result =>{
            this.authRecords = result;
            this.authRecordsList = [];
            for(let i=0; i < this.authRecords.length; i++){
                let rec = this.authRecords[i];
                let dupCheck = false;
                //iteration to avoid duplicate list.
                for(let keyNew in this.authRecordsList){
                    if(this.authRecordsList[keyNew].Id === rec['Id']){
                        dupCheck = true;
                        break;
                    }
                }
                if(rec !== undefined && dupCheck === false){
                    this.authRecordsList.push(rec);
                    this.authRecordsList[i].Name = rec[this.searchfield];
                    this.authRecordsList[i].Id = rec['Id'];
                }
            }
        }).catch(error =>{
            this.authRecordsList = undefined;
        });
        if(!searchKey){
            this.authRecordsList = [];
        }
    }
    handleAuthSelect(event){
        this.selectedAuthRec = event.detail;
        this.selectedAuthEntityId = this.selectedAuthRec.Id;
        this.selectedAuthorityName = this.selectedAuthRec.Name;
        this._stylePresent = false; 
        this.template.querySelector('.addAuthScreenModal').show();
    }
    handleAuthYesClick(){
        this.showAuthEntitySearch = false;
        this.selectedAuthRecord = true;
        this.breakSave = false;
        if(this.selectedAuthRec.Parent_Authority__c != null && this.selectedAuthRec.Parent_Authority__r.Use_same_instruction_for_child_entities__c == true){
            this.specialIntruction = this.selectedAuthRec.Parent_Authority__r.EPIC_Client_Special_Instructions_Languag__c;
        }else{
            this.specialIntruction = this.selectedAuthRec.EPIC_Client_Special_Instructions_Languag__c;
        }
        const successevt = new ShowToastEvent({
                                title: "Success",
                                message: 'Entity has been added',
                                variant: "Success"
                                });
        this.dispatchEvent(successevt);
    }
    handleDeleteAuthOnClick(){
        this.template.querySelector('.removeAuthScreenModal').title = 'Remove this entity?';
        this.template.querySelector('.removeAuthScreenModal').show();
    }
    handleYesAuthDeleteClick(){
        this.authRecordsList = [];
        this.referenceNumber = '';
        this.selectedAuthRecord = false;
        this.showAuthEntitySearch = true;
        this.selectedAuthEntityId = '';
        this.selectedAuthorityName = '';
        this.specialIntruction = '';
        const successevt = new ShowToastEvent({
                                title: "Success",
                                message: 'Entity has been removed',
                                variant: "Success"
                                });
        this.dispatchEvent(successevt);
    }
    handleChangeCheckboxOrg(event){
        this.regOrgDoNotKnow = event.target.checked;
        if(event.target.checked){
            this.authRecordsList = [];
            this.selectedAuthRecord = false;
            this.showAuthEntitySearch = false;
            this.selectedAuthEntityId = '';
            this.selectedEntErr = false;
            this.breakSave = false;
            this.selectedAuthorityName = '';
            this.referenceNumber = '';
        }else{
            this.showAuthEntitySearch = true;
        }   
    }
    saveCATandAsst(){         
        this.wrapRecValues = '';  
        this.catRecValues = ''; 
        this.recordIdEdit = null;
        this.recordId = null;
        const inputFields = this.template.querySelectorAll('lightning-input-field');  
        let catsRecord = {Id: this.recordId};        
        if(inputFields && inputFields.length !== 0){
            catsRecord.Degree_Issue_Date__c = null;
            catsRecord.Degree_Title__c ='';
            catsRecord.Graduation_Year__c = '';
            catsRecord.Degree_expected_to_be_issued_Year__c = '';
            catsRecord.Degree_expected_to_be_issued_Month__c = '';
            catsRecord.Attendance_Start_Date__c = null;
            catsRecord.Attendance_End_Date__c = null;
            catsRecord.Program_Start_Date__c = null;
            catsRecord.Program_End_Date__c = null;
            catsRecord.Title__c = '';
            catsRecord.Issue_Date__c = null;
            catsRecord.Expiration_Date__c = null;
            inputFields.forEach(field=>{
                if(field.fieldName === 'Degree_Issue_Date__c'){
                    catsRecord.Degree_Issue_Date__c = field.value;
                }
                if(field.fieldName === 'Degree_Title__c'){
                    catsRecord.Degree_Title__c = field.value;
                }
                if(field.fieldName === 'Graduation_Year__c'){
                    catsRecord.Graduation_Year__c = field.value;
                }
                if(field.fieldName === 'Degree_expected_to_be_issued_Year__c'){
                    catsRecord.Degree_expected_to_be_issued_Year__c = field.value;
                }
                if(field.fieldName === 'Degree_expected_to_be_issued_Month__c'){
                    catsRecord.Degree_expected_to_be_issued_Month__c = field.value;
                }
                if(field.fieldName === 'Attendance_Start_Date__c'){
                    catsRecord.Attendance_Start_Date__c = field.value;
                }
                if(field.fieldName === 'Attendance_End_Date__c'){
                    catsRecord.Attendance_End_Date__c = field.value;
                }
                if(field.fieldName === 'Program_Start_Date__c'){
                    catsRecord.Program_Start_Date__c = field.value;
                }
                if(field.fieldName === 'Program_End_Date__c'){
                    catsRecord.Program_End_Date__c = field.value;
                }
                if(field.fieldName === 'Title__c'){
                    catsRecord.Title__c = field.value;
                }
                if(field.fieldName === 'Issue_Date__c'){
                    catsRecord.Issue_Date__c = field.value;
                }
                if(field.fieldName === 'Expiration_Date__c'){
                    catsRecord.Expiration_Date__c = field.value;
                } 
            });
        }
        catsRecord.Credential_Type__c = this.chosenAttrValue;
        catsRecord.Name_on_Document__c = this.nameOnDoc;
        catsRecord.Issued_in_the_last_90_days__c = this.haveCertificate;
        catsRecord.Requested_to_be_sent_to_ECFMG__c = this.requestedToSend;
        catsRecord.account__c = this.selectedEntityId;            
        catsRecord.Courier_service_for_an_additional_fee__c = this.sendViaCourier;         
        let credUploadWrapper ={
            credUrl: this.credUrl,
            transUrl: this.transUrl,
            nameUrl: this.nameUrl,
            nameOnDoc: this.nameOnDoc,
            nameDifferent: this.showNameUploadButton,
            translationRequired: this.showTransUploadButton,
            requestedToSend: this.requestedToSend,
            haveCertificate: this.haveCertificate,
            caseId: null,
            catsId: null,
            entityId: this.selectedEntityId
        }
        this.wrapRecValues = JSON.stringify(credUploadWrapper);  
        this.catRecValues = JSON.stringify(catsRecord);
        let tempList = [];
        for(let i=0; i < this.listOfFields.length; i++){
            let tempRecord = this.listOfFields[i];
            if(tempRecord){
                tempList.push({value:tempRecord.value, key:tempRecord.key,isReq:tempRecord.isisReq,fieldValue:catsRecord[tempRecord.key]});
            }
        }
        this.listOfFields = tempList;
    }
    handleChangeForReferenceNumber(event){
        this.referenceNumber = event.target.value;
    }
    showConfirmWindow(){
        if(this.uploadSection === false && this.showAuthEntitySearch === true && this.selectedAuthEntityId === ''){
            this.breakSave = true;
            this.selectedEntErr = true;
        }else{
            this.confirmContent = 'You have selected the '+this.selectedAuthorityName+' to receive an EPIC Verification Report.The report will be sent automatically when your credential has been verified. Do you want to continue?';
            this.template.querySelector('[data-id="confirmationWindow"]').show();
        }
    }
    backFromReport(){
        this._stylePresent = false;
        this.uploadSection = true;
        this.authRecordsList = [];
        this.breakSave = false;
        this.selectedEntErr = false;
    }  
    showDoNotKnowConfirm(){
        if(this.uploadSection === false && this.showAuthEntitySearch === true && this.selectedAuthEntityId === ''){
            this.breakSave = true;
            this.selectedEntErr = true;
        }else{
            this.confirmContent = ' You have not selected a report recipient. Do you want to continue?';
            this.template.querySelector('[data-id="confirmationWindow"]').show();
        }
    }            
}