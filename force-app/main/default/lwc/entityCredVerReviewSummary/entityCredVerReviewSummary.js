import {LightningElement,api,track,wire} from 'lwc';
import getAsset from '@salesforce/apex/EntityCredVerController.getAsset';
import getVerificationPacket from '@salesforce/apex/EntityCredVerController.getVerificationPacket';
import getCredentialUrl from '@salesforce/apex/EntityCredVerController.getCredentialUrl';
import getVerifiedCredUrl from '@salesforce/apex/EntityCredVerController.getVerifiedCredUrl';
import getSupportAssetUrl from '@salesforce/apex/EntityCredVerController.getSupportAssetUrl';
import getCredUploaded from '@salesforce/apex/EntityCredVerController.getCredUploaded';
import checkVerResAccOrNot from '@salesforce/apex/EntityCredVerController.checkVerResAccOrNot';
import getCaseRecords from '@salesforce/apex/CredVerificationListViewController.getCaseRecords';
import {getObjectInfo, getPicklistValues} from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';
import credReason from '@salesforce/schema/Case.No_Credential_Reason__c';
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import {updateScreenNumer} from 'c/util';
export default class EntityCredVerReviewSummary extends LightningElement{
    @api caseId; 
    @api currentEntity;
    @api applicantId;
    @api azureDocUrlVerForm;
    @track payLoadList = [];
    @track showVerForm = false;
    @track entityRequested;
    @track credType;
    @track reasonComment = null;
    @track showReasonComment = false;
    @track reason = null;
    @track selectedValue = null;
    @track selectedValueCredRev = null;
    @track credCertified = null;
    @track credReviewCertified = false;
    @track credRevReasonNotCert = null;
    @track showOtherComCredRev = false;
    @track credRevComNotCert = null;
    @track verPacketId = null;
    @track verCredUrl = null;
    @track showReasonPicklist = false;
    @track credUrl = null;
    @track checkbox = false;
    @track supportUrl1 = null;
    @track supportUrl2 = null;
    @track supportUrl3 = null;
    @track showSupportUploadSection1;
    @track showSupportUploadSection2;
    @track showSupportUploadSection3;
    @track showMainCredUploaded = false;
    @track havePicklistValues = false;
    @track picklistValues;
    @track showUploadSection = false;
    @track finalPayloadVerForm;
    @track payloadCredential;
    @track payloadCredReviewed;
    @track supportPayload;
    @track spinner = false;
    @track tempPayload ={
        contactId: null,
        caseId: null,
        catsId: null,
        documentType: null,
        assetRecordType: null,
        createOrReplace: null,
        assetStatus: null,
        assetCreationRequired: null,
        assetId: null,
        createFromPB: 'true'
    };
    @track tempPayloadCredential ={
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
    @track tempPayloadSuppDoc ={
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
    get options(){
        return [
            {label: 'Yes', value: 'Yes'},
            {label: 'No', value: 'No'},
        ];
    }
    @wire(getObjectInfo, {objectApiName: CASE_OBJECT})
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
        updateScreenNumer(this.caseId,5);
        getAsset({
            caseId: this.caseId
        }).then(result=>{
            if(result){
                let temppayLoadAsset = [];
                result.forEach(item=>{
                    let payLoadItems = JSON.parse(JSON.stringify(item));
                    payLoadItems.payLoad = JSON.stringify(item);
                    temppayLoadAsset.push(payLoadItems);
                });
                this.payLoadList = temppayLoadAsset;
                this.getVerForm();
                this.getVerificationPacketjs();
            }
        }).catch(err=>window.console.error('Error: ',err));
    }
    getVerForm(){
        if(this.azureDocUrlVerForm){
            this.finalPayloadVerForm = JSON.stringify(this.tempPayload);
            this.showVerForm = true;
        }
    }
    getVerificationPacketjs(){
        getVerificationPacket({caseId : this.caseId}).then(result1=>{
            if(result1){
                this.tempPayloadCredential.contactId = result1.Case__r.ContactId;
                this.tempPayloadCredential.caseId = result1.Case__c;
                this.tempPayloadCredential.documentType = result1.Case__r.Document_Type__c;
                this.payloadCredential = JSON.stringify(this.tempPayloadCredential);
                this.tempPayloadSuppDoc.contactId = result1.Case__r.ContactId;
                this.tempPayloadSuppDoc.caseId = result1.Case__c;
                this.supportPayload = JSON.stringify(this.tempPayloadSuppDoc);
                this.entityRequested = result1.Entity_provide_the_credential__c;
                this.credType = result1.Case__r.Document_Type__c;
                this.reasonComment = result1.Case__r.No_Credential_Reason_Comment__c;
                this.reason = result1.Case__r.No_Credential_Reason__c;
                this.selectedValue = result1.Case__r.Credential_Available__c;
                this.verPacketId = result1.Id;
                if(this.entityRequested){
                    this.showMainCredUploaded = true;
                    if(result1.Case__r.Credential_Available__c == 'Yes'){
                        this.getCredentialUrljs();
                    }
                    if(result1.Case__r.Credential_Available__c == 'No'){
                        this.showReasonPicklist = true;
                        if(this.reason == 'Other'){
                            this.showReasonComment = true;
                        }
                    }
                }else{
                    this.getCredReviewDetails();
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
        }
    }
    showApplicantInfoScreen(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('applicantinfo',{});
        this.dispatchEvent(selectEvent);
    }
    showVerFormScreen(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('verform',{});
        this.dispatchEvent(selectEvent);
    }
    showCredUploadScreen(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('credupload',{});
        this.dispatchEvent(selectEvent);
    }
    showCredentialReviewScreen(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('credreview',{});
        this.dispatchEvent(selectEvent);
    }
    showCredRevLandPage(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('credreviewlist',{});
        this.dispatchEvent(selectEvent);
    }
    showConfirmation(event){
        this.template.querySelector('[data-id="confirmationWindow"]').show();
    }
    cancelSubmit(){
        this.template.querySelector('[data-id="confirmationWindow"]').hide();
    }
    proceedSubmit(event){
        this.template.querySelector('[data-id="confirmationWindow"]').hide();
        const evt = new ShowToastEvent({
            title: "Success",
            message: "Your verification response was successfully submitted",
            variant: "success",
            mode: "dismissable"
        });
        this.dispatchEvent(evt);
        this.spinner = true;
        checkVerResAccOrNot({caseId:this.caseId})
        .then(result=>{
            if(result){
                getCaseRecords({currentEntityId: this.currentEntity, applicantId: this.applicantId, currCaseId: this.caseId})
                .then(data=>{
                    if(data.length == 0){
                        this.spinner = false;
                        this.showCredRevLandPage(event);
                    }
                    else{
                        this.spinner = false;
                        this.showActiveCaseList();
                    }
                })
            }
        }).catch(error=>{
            window.console.error('Error: ',error);
        })
    }
    showActiveCaseList(){
        let caseInform = {currcaseId:this.caseId};
        const selectEvent = new CustomEvent('activecaseslist',{detail:caseInform});
        this.dispatchEvent(selectEvent);
    }
    getCredReviewDetails(){ 
        getCredUploaded({caseId:this.caseId})
        .then(result=>{       
            if(result){                                           
                this.getCredReviewDetailsHelper(result);
            }
        })
    }
    getCredReviewDetailsHelper(result){
        for(let key in result){                 
            if(result.hasOwnProperty(key)){  
                if(key === 'assDocCertifiedSoc'){
                    this.selectedValueCredRev = result[key];                             
                }   
                if(key === 'assReasonNotCertSoc'){
                    this.credRevReasonNotCert = result[key];                        
                } 
                if(key === 'assComNotCertSoc'){
                    this.credRevComNotCert = result[key];                            
                }
            }
        }
        this.getCredReviewHelper();                               
    }
    getCredReviewHelper(){
        if(this.selectedValueCredRev === 'Certify'){
            this.credCertified = 'I Certify This Document';
            this.getVerifiedCred();                               
        }else if(this.selectedValueCredRev === 'Cannot certify'){
            this.credCertified = 'I Cannot Certify This Document';
            this.credReviewCertified = false;
        }
        if(this.credRevReasonNotCert === 'Other' || this.credRevReasonNotCert === 'Applicant action is required'){
            this.showOtherComCredRev = true;
        }  
    }
    getVerifiedCred(){
        let returnedCredName = 'Returned ' + this.credType;
        getVerifiedCredUrl({caseId: this.caseId, retName: returnedCredName}).then(verifiedCredUrl=>{
            if(verifiedCredUrl){
                this.verCredUrl = verifiedCredUrl;
                this.credReviewCertified = true; 
            }
        })
    }
}