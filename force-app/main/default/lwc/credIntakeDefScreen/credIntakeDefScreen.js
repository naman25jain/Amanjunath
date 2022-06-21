import {LightningElement,track} from 'lwc';
import getDocType from '@salesforce/apex/CredIntakeDefScreenController.getDocType';
import getEvalStatus from '@salesforce/apex/CredIntakeDefScreenController.getEvalStatus';
import updateCredentials from '@salesforce/apex/CredIntakeDefScreenController.updateCredentials';
import getContactId from '@salesforce/apex/AppForCertController.getContactId';
import getContact from '@salesforce/apex/AppForCertController.getContactName';
import markAssetsForDeletion from '@salesforce/apex/EpicCredVerController.deleteAssetsWithoutCase';
import{NavigationMixin} from 'lightning/navigation';
import getAssetUrls from '@salesforce/apex/EpicCredVerController.getAssetUrls';
import assetsDeletionOnPageLoad from '@salesforce/apex/EpicCredVerController.assetsDeletionOnPageLoad';
import getDocNotAcceptableForClient from '@salesforce/apex/CredIntakeDefScreenController.getDocNotAcceptableForClient';
import getPicklistValues from '@salesforce/apex/CredIntakeDefScreenController.getPicklistValues';
import getCaseDetail from "@salesforce/apex/AssetCreationWrapperController.getCaseDetail";
export default class CredIntakeDefScreen extends NavigationMixin(LightningElement){
    @track caseId;
    @track showUploadSection = false;
    @track showCredUploadButton = false;
    @track contactId = null;
    @track payloadCredential;
    @track payloadCredTrans;
    @track payloadCredName;
    @track credUrl = null;
    @track showTranslationSection = false;
    @track showTransUploadButton = false;
    @track showNameSection = false;
    @track isErrCredUpload = false;
    @track contactName = '' ;
    @track showNameUploadButton = false;
    @track nameUrl = null;
    @track checkBoxValue = false;
    @track translationRequired = false;
    @track nameIsDifferent = false;
    @track isErrTransUpload = false;
    @track transUrl = null;
    @track evalStatus;
    @track nameOnDoc;
    @track nameOnDocErr = false;
    @track isErrProceed = false;
    @track breakSave;
    @track spinner = false;
    @track transDeficiency = false;
    @track docNotAccForClient = false;
    @track showProceedSection = false;
    @track picklistOptions = [];
    @track selectedValue = null;
    @track urlMapCredReq = null;
    @track showBtn = false;
    @track tempPayloadCredential = {
        documentType: '',
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
    connectedCallback(){
        this.caseId = new URL(window.location.href).searchParams.get("id");        
        getCaseDetail({caseId:this.caseId})
        .then(result=>{
            if(result.Internal_Status__c == 'CV Incomplete' || result.Internal_Status__c == 'Incomplete' ){
            getDocType({caseId : this.caseId}).then(result=>{
            this.tempPayloadCredential.documentType = result;
            this.tempPayloadCredTrans.assetName = result + ' - Translation';
            getPicklistValues().then(data=>{
                if(data){
                    for(var picklistValue of data){
                        this.picklistOptions = [...this.picklistOptions ,{value: picklistValue, label: picklistValue}];  
                    }                                 
                }
                getDocNotAcceptableForClient({caseId : this.caseId}).then(docNotAcc=>{
                    this.docNotAccForClient = docNotAcc;                    
                    getEvalStatus({caseId : this.caseId}).then(result1=>{
                        this.showBtn = false;
                        this.evalStatus = result1;
                        if(this.docNotAccForClient && (this.evalStatus === 'credIncomplete' || this.evalStatus === 'credTransIncomplete')){
                            this.showBtn = true;
                            this.showProceedSection = true;                            
                        }else if(this.evalStatus === 'credIncomplete' || this.evalStatus === 'credTransIncomplete'){
                            this.showBtn = true;
                            this.showUploadSection = true;
                            this.showCredUploadButton = true;                            
                        }else if(this.evalStatus === 'transIncomplete'){
                            this.showBtn = true;
                            this.showTransUploadButton = true;
                            this.transDeficiency = true;
                            this.showUploadSection = false;                            
                        }  
                        this.callBackHelper();
                    });
                });
            });
        });
     }else{
        this.navigateToMyCases();
      }
     })
    } 
    callBackHelper(){
        getAssetUrls({caseId: this.caseId}).then(urlMap=>{
            if(urlMap){
                this.urlMapCredReq = urlMap['Credential Request'];
                getContactId().then(result2=>{
                    if((this.credUrl === null || this.credUrl === undefined) && (this.nameUrl === null || this.nameUrl === undefined) && 
                       (this.transUrl === null || this.transUrl === undefined)){
                        assetsDeletionOnPageLoad({contactId: result2});
                        this.tempPayloadCredTrans.parentUrl = urlMap['Credential Request'];
                        this.tempPayloadCredName.parentUrl = urlMap['Credential Request'];
                    }
                    this.contactId = result2;
                    this.tempPayloadCredential.contactId = this.contactId;
                    this.tempPayloadCredTrans.contactId = this.contactId;
                    this.tempPayloadCredName.contactId = this.contactId;
                    this.payloadCredName = JSON.stringify(this.tempPayloadCredName);
                    this.payloadCredential = JSON.stringify(this.tempPayloadCredential);
                    this.payloadCredTrans = JSON.stringify(this.tempPayloadCredTrans);
                    getContact({contactId : this.contactId}).then(result3=>{
                         if(result3){
                            this.contactName = JSON.stringify(result3).replace('"', '').replace('"', '');
                        }
                    })
                });
            }
        });
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
    handleUploadTransOrNot(event){
        this.checkBoxValue = event.target.checked;
        this.translationRequired = event.target.checked;
        this.isErrTransUpload = false;
        this.payloadCredTrans = JSON.stringify(this.tempPayloadCredTrans);
        if(this.checkBoxValue){
            this.showTransUploadButton = true;
        }else{
            this.showTransUploadButton = false;
            if(this.transUrl){
                markAssetsForDeletion({azureUrl : this.transUrl});
                this.transUrl = null;
            }
        }
    }
    handleOnCredTransUpload(event){
        this.isErrTransUpload = false;
        this.showTransUploadButton = false;
        this.transUrl = event.detail.url;
        this.showTransUploadButton = true;
    }
    handleChangeForInputFields(event){
        this.nameOnDoc = event.target.value;
        this.nameOnDocErr = false;
    }
    saveButton(event){
        this.breakSave = false;
        if((this.credUrl === null || this.credUrl === undefined) && this.showUploadSection === true){            
            this.isErrCredUpload = true;
            this.breakSave = true;
        }
        if(!this.nameOnDoc && this.template.querySelector('.nameOnDoc') !== null){
            this.nameOnDocErr = true;
            this.breakSave = true;
            this.template.querySelector('.nameOnDoc').classList.add('slds-has-error');  
        }
        if(this.showTransUploadButton === true && this.transUrl === null){
            this.isErrTransUpload = true;
            this.breakSave = true;
        }
        if(this.showProceedSection === true && this.selectedValue === null){
            this.isErrProceed = true;
            this.breakSave = true; 
        }
        if(!this.breakSave){  
            this.saveHelper();
        }
    }
    saveHelper(){
        this.spinner = true;
            if(this.caseId){
                this.spinner = true;
                let credUploadWrapper ={
                    credUrl: this.credUrl,
                    transUrl: this.transUrl,
                    nameUrl: this.nameUrl,
                    nameOnDoc: this.nameOnDoc,
                    nameDifferent: this.showNameUploadButton,
                    translationRequired: this.showTransUploadButton,
                    caseId: this.caseId,
                    proceedWithCredVer: this.selectedValue
                }
                updateCredentials({inputJSON: JSON.stringify(credUploadWrapper)}).then(saveResult=>{
                    if(saveResult){
                        this.spinner = false;
                        this.navigateToMyCases();
                    }
                })
            }
    }
    cancelButton(event){
        this.deleteCurrentAssets();
        event.preventDefault();
        this.navigateToMyCases();
    }
    navigateToMyCases(){
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes:{
                url: '/s/my-cases'
            }
        });
    }
    deleteNameAsset(){
        this.nameUrl = null;
    }
    handlePicklistChange(event){
        this.isErrProceed = false;
        this.deleteCurrentAssets();
        this.selectedValue = event.detail.value;
        this.nameIsDifferent = false;
        this.nameOnDoc = null;
        this.translationRequired = false;
        this.showNameSection = false;
        this.showTranslationSection = false;
        this.showNameUploadButton = false;
        if(this.selectedValue === 'Upload a Revised Document'){
            this.showUploadSection = true;
            this.showCredUploadButton = true; 
            this.showTransUploadButton = false;
            this.transDeficiency = false;     
        }else if(this.selectedValue === 'Yes' && (this.evalStatus === 'credTransIncomplete' || this.evalStatus === 'transIncomplete')){
            this.tempPayloadCredTrans.parentUrl = this.urlMapCredReq;
            this.payloadCredTrans = JSON.stringify(this.tempPayloadCredTrans);
            this.showTransUploadButton = true;
            this.transDeficiency = true;
            this.showUploadSection = false;
            this.showCredUploadButton = false;
        }else{
            this.showUploadSection = false;
            this.showCredUploadButton = false;
            this.showTransUploadButton = false;
            this.transDeficiency = false;
        }
    }
    deleteCurrentAssets(){
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
    preventBackslash(event){
        if(event.which === 8 || event.which === 46){
            event.preventDefault();
        }
    }
}