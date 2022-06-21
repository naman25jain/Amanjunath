import {LightningElement,track} from 'lwc';
import checkUploadDisabled from '@salesforce/apex/ERASController.checkApplicantDocUploadDisabled';
import checkMedSchoolPortalAccess from '@salesforce/apex/ERASController.checkMedSchoolPortalAccess';
import getContactId from '@salesforce/apex/AppForCertController.getContactId';
import checkTranReqEligible from '@salesforce/apex/ERASController.checkTranReqEligible';
export default class ErasDocUpload extends LightningElement{
    @track disableUpload = true;
    @track portalAccess;
    @track photoUrl;
    @track mspeUrl;
    @track fmstUrl;
    @track showLandingScreen = true;
    @track showUploadMain = true;
    @track showReqTransLink;
    @track showScreen1 = false;
    @track showScreen2 = false;
    @track showConfirmScreen = false;
    @track contactId;
    @track caseId;
    @track caseNumber;
    @track payloadPhoto;
    @track payloadMspe;
    @track payloadFmst;
    @track size = '0.150';
    @track mspeSize = '1.2';
    @track spinner = false;
    @track tempPayloadPhoto = {
            documentType: 'Photo',
            assetRecordType: 'Identity',
            createOrReplace: 'Create',
            assetStatus: 'New',
            assetCreationRequired: 'true',
            assetName: 'ERAS Photo',
            assetId: null,
            caseId: null,
            createFromPB: 'true',
            uploadedByApplicant: 'true'
        };
    @track tempPayloadMspe = {
            documentType: 'Medical School Performance Evaluation',
            assetRecordType: 'Credential',
            createOrReplace: 'Create',
            assetStatus: 'New',
            assetCreationRequired: 'true',
            assetName: 'Medical School Performance Evaluation',
            assetId: null,
            caseId: null,
            createFromPB: 'true',
            uploadedByApplicant: 'true'
        };
    @track tempPayloadFmst = {
            documentType: 'Final Medical School Transcript',
            assetRecordType: 'Credential',
            createOrReplace: 'Create',
            assetStatus: 'New',
            assetCreationRequired: 'true',
            assetName: 'ERAS Final Medical School Transcript',
            assetId: null,
            caseId: null,
            createFromPB: 'true',
            uploadedByApplicant: 'true'
        };
    connectedCallback(){
        this.spinner = true;
        checkUploadDisabled().then(result=>{
            if(result){
                this.caseId = result;
                this.disableUpload = false;
                this.checkPortalAccess();
            }else{
                this.spinner = false;
            }
        });
        checkTranReqEligible().then(result=>{
            this.spinner = true;
            if(result != null){
                if(result){
                    this.caseNumber = result;
                    this.showReqTransLink = true;
                }
            }else{
                this.showReqTransLink = false;
            }
            this.spinner = false;
        });
    }
    checkPortalAccess(){
        checkMedSchoolPortalAccess().then(result=>{
            this.portalAccess = result;
            this.getContact();
        });
    }
    handleOnPhotoUpload(event){
        this.photoUrl = event.detail.url;
    }
    handleOnMspeUpload(event){
        this.mspeUrl = event.detail.url;
    }
    handleOnFmstUpload(event){
        this.fmstUrl = event.detail.url;
    }
    handleSubmit(){
        this.photoUrl = null;
        this.mspeUrl = null;
        this.fmstUrl = null;
        this.showUploadMain = true;
        //this.showReqTransLink = true;
        //Bugfix#21341
        checkTranReqEligible().then(result=>{
            console.log('handleSubmit '+result);
            this.spinner = true;
            if(result != null){
                if(result){
                    this.caseNumber = result;
                    this.showReqTransLink = true;
                }
            }else{
                this.showReqTransLink = false;
            }
            this.spinner = false;
        });
    }
    handleClick(){
        this.spinner = true;
        this.showUploadMain = false;
        this.showReqTransLink = false;
        this.showScreen1 = false;
        this.showScreen2 = false;
        this.spinner = false;
    }
    getContact(){
        getContactId().then(result=>{
            this.contactId = result;
            this.tempPayloadPhoto.contactId = this.contactId;
            this.tempPayloadPhoto.caseId = this.caseId;
            this.payloadPhoto = JSON.stringify(this.tempPayloadPhoto);
            if(!this.portalAccess){
                this.tempPayloadMspe.contactId = this.contactId;
                this.tempPayloadMspe.caseId = this.caseId;
                this.payloadMspe = JSON.stringify(this.tempPayloadMspe);
                this.tempPayloadFmst.contactId = this.contactId;
                this.tempPayloadFmst.caseId = this.caseId;
                this.payloadFmst = JSON.stringify(this.tempPayloadFmst);
            }
            this.spinner = false;
        });
    }
    handleReqClick(){
        this.showLandingScreen = false;
        this.showScreen1 = true;
        this.showScreen2 = false;
    }
    showNextScreen(){
        this.showLandingScreen = false;
        this.showScreen1 = false;
        this.showScreen2 = true;
        this.showConfirmScreen = false;
    }
    showFirstScreen(){
        this.showLandingScreen = false;
        this.showScreen1 = true;
        this.showScreen2 = false;
        this.showConfirmScreen = false;
    }
    showConfScreen(){
        this.showLandingScreen = false;
        this.showScreen1 = false;
        this.showScreen2 = false;
        this.showConfirmScreen = true;
    }
    showLandScreen(){
        window.location.reload();
    }
}