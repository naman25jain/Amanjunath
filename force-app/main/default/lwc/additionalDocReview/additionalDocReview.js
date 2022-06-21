import {LightningElement, track, api, wire} from 'lwc';
import getAdditionalDocuments from '@salesforce/apex/EntityCredVerController.getAdditionalDocuments';
import getVerificationPacket from '@salesforce/apex/EntityCredVerController.getVerificationPacket';
import updateVerificationPacket from '@salesforce/apex/EntityCredVerController.updateVerificationPacket';
import getCredentialUrl from '@salesforce/apex/EntityCredVerController.getCredentialUrl';
import getSupportAssetUrl from '@salesforce/apex/EntityCredVerController.getSupportAssetUrl';
import deleteDocuments from '@salesforce/apex/EntityCredVerController.deleteDocuments';
import deleteSupportDocuments from '@salesforce/apex/EntityCredVerController.deleteSupportDocuments';
import {getObjectInfo, getPicklistValues} from 'lightning/uiObjectInfoApi';
import {updateScreenNumer} from 'c/util';
import credReason from '@salesforce/schema/Case.No_Credential_Reason__c';
import CASE_OBJECT from '@salesforce/schema/Case';
export default class AdditionalDocReview extends LightningElement{
    @api caseId;
    @track contactId;
    @track additionalDocs = [];
    @track entityRequested;
    @track additionalInfo;
    @track showAdditionalDocSection = false;
    @track showEntityQuestion = false;
    @track spinner;
    @track selectedValue = null;
    @track showUploadSection = false;
    @track credType;
    @track supportPayload;
    @track credUrl = null;
    @track error;
    @track disableButton = false;
    @track supportUrl1 = null;
    @track supportUrl2 = null;
    @track supportUrl3 = null;
    @track payloadCredential;
    @track noReasonError = false;
    @track showSupportUploadSection1;
    @track showSupportUploadSection2;
    @track showSupportUploadSection3;
    @track showReasonPicklist = false;
    @track reason = null;
    @track showReasonComment = false;
    @track reasonComment = null;
    @track showUploadError = false;
    @track showCertifyError = false;
    @track breakSave = false;
    @track reasonError = false;
    @track checkbox = false;
    @track verPacketId = null;
    @track questionError = false;
    @track tempPayloadCredential = {
        assetRecordType: 'Credential',
        createOrReplace: 'Create',
        assetStatus: 'In Progress',
        assetCreationRequired: 'true',
        assetName: 'Credential Request',
        assetId: null,
        caseId: null,
        createFromPB: 'true',
        createAsset2Ver: 'true'
    };
    @track tempPayload = {
        documentType: 'Supporting Documents',
        assetRecordType: 'Supporting_Documents',
        createOrReplace: 'Create',
        assetStatus: 'New',
        assetCreationRequired: 'true',
        assetName: 'Entity Supporting Documents',
        assetId: null,
        caseId: null,
        createFromPB: 'true',
        createAsset2Ver: 'true'
    };
    @track picklistValues;
    @track havePicklistValues = false;
    get options() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }
    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    caseInfo;

    @wire(getPicklistValues,
        {
            recordTypeId: '$caseInfo.data.defaultRecordTypeId',
            fieldApiName: credReason
        }
    )
    wiredPicklist({error, data}){
        if(data){
            this.picklistValues = data;
            this.havePicklistValues = true;
        }
        if(error){
            this.error = error;
        }
    }
    connectedCallback(){
        this.spinner = true;
        updateScreenNumer(this.caseId,2);
        deleteDocuments({caseId: this.caseId});
        getAdditionalDocuments({caseId : this.caseId}).then(result=>{
            let payload = JSON.stringify(this.tempPayload);
            let sNumber = 1;
            for(let key in result){                    
                if(result.hasOwnProperty(key)){ 
                    this.showAdditionalDocSection = true;
                    let tempAsst = {
                        payload : payload,
                        azureUrl : result[key].Azure_Storage_URL__c,
                        serialNumber : sNumber
                    }
                    this.additionalDocs.push(tempAsst);
                    sNumber = sNumber+1;
                }
            }
            this.getVerificationPacketjs();
        })
    }
    getVerificationPacketjs(){
        getVerificationPacket({caseId : this.caseId}).then(result1=>{
            if(result1){
                this.contactId = result1.Case__r.ContactId;
                this.tempPayloadCredential.contactId = result1.Case__r.ContactId;
                this.tempPayloadCredential.caseId = result1.Case__c;
                this.tempPayloadCredential.documentType = result1.Case__r.Document_Type__c;
                this.payloadCredential = JSON.stringify(this.tempPayloadCredential);
                this.tempPayload.contactId = result1.Case__r.ContactId;
                this.tempPayload.caseId = result1.Case__c;
                this.supportPayload = JSON.stringify(this.tempPayload);
                this.entityRequested = result1.Entity_provide_the_credential__c;
                this.additionalInfo = result1.Request_additional_information__c;
                this.credType = result1.Case__r.Document_Type__c;
                this.reasonComment = result1.Case__r.No_Credential_Reason_Comment__c;
                this.reason = result1.Case__r.No_Credential_Reason__c;
                this.selectedValue = result1.Case__r.Credential_Available__c;
                this.verPacketId = result1.Id;
                if(result1.Case__r.Credential_Available__c == 'Yes'){
                    this.getCredentialUrljs();
                }
                if(result1.Case__r.Credential_Available__c == 'No'){
                    this.showReasonPicklist = true;
                    if(this.reason == 'Other'){
                        this.showReasonComment = true;
                    }
                }
                if(this.entityRequested){
                    this.showEntityQuestion = true;
                }
            }
            this.spinner = false;
        })
    }
    getCredentialUrljs(){
        getCredentialUrl({verificationPackageId: this.verPacketId}).then(credentialUrl=>{
            this.credUrl = credentialUrl;
            this.checkbox = true;
            getSupportAssetUrl({verificationPackageId: this.verPacketId}).then(supportUrls=>{
                for(let key in supportUrls){                    
                    if(supportUrls.hasOwnProperty(key)){ 
                        this.assignSupportUrls(supportUrls, key);
                    }
                }
                this.showUploadSection = true;
            })
        })
    }
    assignSupportUrls(supportUrls, key){
        if(key == 0){
            this.supportUrl1 = supportUrls[key];
            this.showSupportUploadSection1 = true;
        }
        if(key == 1){
            this.supportUrl2 = supportUrls[key];
            this.showSupportUploadSection2 = true;
        }
        if(key == 2){
            this.supportUrl3 = supportUrls[key];
            this.showSupportUploadSection3 = true;
            this.disableButton = true;
        }
    }
    handleAnsChange(event){
        this.selectedValue = event.detail.value;
        if(event.detail.value == 'Yes'){
            this.showUploadSection = true;
            this.showReasonPicklist = false;
            this.reason = null;
            this.showReasonComment = false;
            this.reasonComment = null;
        }else{
            this.checkbox = false;
            this.disableButton = false;
            this.showUploadSection = false;
            this.showReasonPicklist = true;
            deleteDocuments({caseId: this.caseId});
            this.showSupportUploadSection1 = false;
            this.showSupportUploadSection2 = false;
            this.showSupportUploadSection3 = false;
            this.supportUrl1 = null;
            this.supportUrl2 = null;
            this.supportUrl3 = null;
            this.credUrl = null;
        }
    }
    addSupportingDoc(){
        if(!this.showSupportUploadSection1){
            this.showSupportUploadSection1 = true;
            return;
        }
        if(this.showSupportUploadSection1 && this.supportUrl1 && !this.showSupportUploadSection2 && !this.showSupportUploadSection3){
            this.showSupportUploadSection2 = true;
            return;
        }
        if(this.showSupportUploadSection1 && !this.supportUrl1){
            this.error = true;
            return;
        }
        if(this.showSupportUploadSection1 && this.showSupportUploadSection2 && this.supportUrl2 && !this.showSupportUploadSection3){
            this.showSupportUploadSection3 = true;
            this.disableButton = true;
            return;
        }
        if(this.showSupportUploadSection1 && this.showSupportUploadSection2 && !this.supportUrl2 && !this.showSupportUploadSection3){
            this.error = true;
        }
    }
    handleOnSupportUpload1(event){
        if(!this.supportUrl1){
            this.error = false;
        }
        this.supportUrl1 = event.detail.url
    }
    handleOnSupportUpload2(event){
        if(!this.supportUrl2){
            this.error = false;
        }
        this.supportUrl2 = event.detail.url
    }
    handleOnSupportUpload3(event){
        this.supportUrl3 = event.detail.url
    }
    handleOnCredentialUpload(event){
        this.credUrl = event.detail.url
    }
    handleChangeReason(event){
        this.reason = event.detail.value;
        if(event.detail.value == 'Other'){
            this.showReasonComment = true;
        }else{
            this.showReasonComment = false;
            this.reasonComment = null;
        }
    }
    handleReasonComment(event){
        this.reasonComment = event.detail.value;
    }
    handleCheckbox(event){
        this.checkbox = event.detail.checked;
    }
    checkValidation(){
        this.breakSave = false;
        this.showUploadError = false;
        this.showCertifyError = false;
        this.reasonError = false;
        this.noReasonError = false;
        this.questionError = false;
        if(this.showEntityQuestion == true && this.selectedValue == null){
            this.questionError = true;
            this.breakSave = true;
        }
        if(this.credUrl == null && this.selectedValue == 'Yes'){
            this.showUploadError = true;
            this.breakSave = true;
        }
        if(!this.checkbox && this.selectedValue == 'Yes'){
            this.showCertifyError = true;
            this.breakSave = true;
        }
        if(this.selectedValue == 'No' && this.reason == 'Other' && (this.reasonComment == null || this.reasonComment == '')){
            this.reasonError = true;
            this.breakSave = true;
        }
        if(this.selectedValue == 'No' && (this.reason == null||this.reason == '')){
            this.noReasonError = true;
            this.breakSave = true;
        }
    }
    submitInputs(event){
        this.spinner = true;
        this.checkValidation();
        if(!this.breakSave){
            let supportUrls =[];
            if(this.supportUrl1){
                supportUrls.push(this.supportUrl1);
            }
            if(this.supportUrl2){
                supportUrls.push(this.supportUrl2);
            }
            if(this.supportUrl3){
                supportUrls.push(this.supportUrl3);
            }
            let addCredWrapper = {
                supportDocUrlList: JSON.stringify(supportUrls),
                credUrl: this.credUrl,
                reason: this.reason,
                reasonComment: this.reasonComment,
                credAvailable: this.selectedValue
            };
            updateVerificationPacket({caseId: this.caseId, inputJSON: JSON.stringify(addCredWrapper)}).then(result=>{
                if(result){
                    this.spinner = false;
                    event.preventDefault();
                    const selectEvent = new CustomEvent('nextevent',{detail: this.selectedValue});
                    this.dispatchEvent(selectEvent);
                }
            })
        }else{
            this.spinner = false;
        }
    }
    showCredRevLandPage(event){
        deleteDocuments({caseId: this.caseId});
        event.preventDefault();
        const selectEvent = new CustomEvent('showscredintland',{});
        this.dispatchEvent(selectEvent);
    }
    showCredRevPrevPage(event){
        deleteDocuments({caseId: this.caseId});
        event.preventDefault();
        const selectEvent = new CustomEvent("previousevent",{});
        this.dispatchEvent(selectEvent);
    } 
    deleteSupportDoc1(){
        this.spinner = true;
        let tempValue = this.showSupportUploadSection2;
        this.showSupportUploadSection1 = false;
        this.showSupportUploadSection2 = false;
        this.showSupportUploadSection3 = false;
        this.disableButton = false;
        deleteSupportDocuments({assetUrl: this.supportUrl1}).then(response=>{
            if(response){
                this.supportUrl1 = null;
                this.showSupportUploadSection1 = tempValue;
                if(this.supportUrl2){
                    this.supportUrl1 = this.supportUrl2;
                    this.showSupportUploadSection1 = true;
                }
                if(this.supportUrl3){
                    this.supportUrl2 = this.supportUrl3;
                    this.showSupportUploadSection2 = true;
                    this.supportUrl3 = null;
                    this.showSupportUploadSection3 = false;
                }
            }
            this.spinner = false;
        })
    }
    deleteSupportDoc2(){
        this.spinner = true;
        this.disableButton = false;
        let tempValue = this.showSupportUploadSection3;
        this.showSupportUploadSection1 = false;
        this.showSupportUploadSection2 = false;
        this.showSupportUploadSection3 = false;
        deleteSupportDocuments({assetUrl: this.supportUrl2}).then(response=>{
            if(response){
                this.supportUrl2 = null;
                this.showSupportUploadSection2 = tempValue;
                if(this.supportUrl1){
                    this.showSupportUploadSection1 = true;
                }
                if(this.supportUrl3){
                    this.supportUrl2 = this.supportUrl3;
                    this.showSupportUploadSection2 = true;
                    this.supportUrl3 = null;
                    this.showSupportUploadSection3 = false;
                }
            }
            this.spinner = false;
        })
    }
    deleteSupportDoc3(){
        this.spinner = true;
        this.disableButton = false;
        this.showSupportUploadSection1 = false;
        this.showSupportUploadSection2 = false;
        this.showSupportUploadSection3 = false;
        deleteSupportDocuments({assetUrl: this.supportUrl3}).then(response=>{
            if(response){
                this.supportUrl3 = null;
                this.showSupportUploadSection3 = false;
                if(this.supportUrl1){
                    this.showSupportUploadSection1 = true;
                }
                if(this.supportUrl2){
                    this.showSupportUploadSection2 = true;
                }
            }
            this.spinner = false;
        })
    }
}