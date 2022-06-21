import {LightningElement, track, wire, api} from 'lwc';
import checkAccountEstablishment from "@salesforce/apex/EpicCredVerController.checkAccountEstablishment";
import getEpicExtrCaseStatus from "@salesforce/apex/EpicCredVerController.getEpicExtrCaseStatus";
import getContactId from "@salesforce/apex/ServicesComponentController.getContactId";
import checkValidationUpdateMyAppClick from "@salesforce/apex/ServicesComponentController.checkValidationUpdateMyAppClick";
import getMessage from "@salesforce/apex/RestrictedMessage.getMessage";
import restrictionError from '@salesforce/label/c.Credential_Verification_Restriction_Message';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; 

export default class EpicCredentialVerification extends LightningElement{
    @track showEpicButton = false;
    @track showBioInfo = false;
    @track showMainPage = true;
    @track contactId;
    @track epicExtrStatus;
    @track accEstCompleted;
    @track showCredVerButton;
    @track showValidationMsg;   
    @track showOrgSelection;
    @track showEpicLegalPage;
    @track showEpicPaymentPage;
    @track showEpicConfirmationPage
    @track showCredIntake;
    @track program = 'EPIC';
    @track initiateEpicError = '';
    @track showErrorInitiateButton = false;
    @track spinner = false;
    @track restrictedServiceName = 'EPIC Credentials Verification - Internal and External';
    @track caseRecordId;
    @wire(getContactId)
    setContactId(result){
        this.contactId = result.data;
    }
    showInitiateEpicService(){
        this.showMainPage = true;
        this.showEpicButton = true;
        this.showBioInfo = false;
        this.showOrgSelection = false;
        this.showEpicLegalPage = false;
        this.showEpicPaymentPage = false;
        this.showEpicConfirmationPage = false;
        this.showCredIntake = false;
        this.showCredVerButton = false;
    }
    showBioInfoScreen(){
        this.showBioInfo = true;
        this.showEpicButton = false; 
        this.showMainPage = false;
        this.showOrgSelection = false;
        this.showEpicLegalPage = false;
        this.showEpicPaymentPage = false;
        this.showEpicConfirmationPage = false;
        this.showCredIntake = false;
        this.showCredVerButton = false;
    }
    showOrgSelectionScreen(){
        this.showBioInfo = false;
        this.showEpicButton = false; 
        this.showMainPage = false;
        this.showOrgSelection = true;
        this.showEpicLegalPage = false;
        this.showEpicPaymentPage = false;
        this.showEpicConfirmationPage = false;
        this.showCredIntake = false;
        this.showCredVerButton = false;
    }
    showEpicLegal(event){
        this.caseRecordId = event.detail.caserecordid;
        this.showCredIntake = false;
        this.showCredVerButton = false;
        this.showBioInfo = false;
        this.showEpicButton = false; 
        this.showMainPage = false;
        this.showOrgSelection = false;
        this.showEpicLegalPage = true;
        this.showEpicPaymentPage = false;
        this.showEpicConfirmationPage = false;
    }
    showCredIntakeScreen(){
        this.showBioInfo = false;
        this.showEpicButton = false; 
        this.showMainPage = false;
        this.showOrgSelection = false;
        this.showEpicLegalPage = false;
        this.showEpicPaymentPage = false;
        this.showEpicConfirmationPage = false;
        this.showCredIntake = true;
        this.showCredVerButton = false;
    }
    showEpicPayment(){
        this.showBioInfo = false;
        this.showEpicButton = false; 
        this.showMainPage = false;
        this.showOrgSelection = false;
        this.showEpicLegalPage = false;
        this.showEpicPaymentPage = true;
        this.showEpicConfirmationPage = false;
        this.showCredIntake = false;
        this.showCredVerButton = false;
    }
    showEpicConfirmation(){
        this.showBioInfo = false;
        this.showEpicButton = false; 
        this.showMainPage = false;
        this.showOrgSelection = false;
        this.showEpicLegalPage = false;
        this.showEpicPaymentPage = false;
        this.showEpicConfirmationPage = true;
        this.showCredIntake = false;
        this.showCredVerButton = false;
    }
    showCredVerButtonScreen(){
        this.showMainPage = true;
        this.showEpicButton = false;
        this.showBioInfo = false;
        this.showOrgSelection = false;
        this.showEpicLegalPage = false;
        this.showEpicPaymentPage = false;
        this.showEpicConfirmationPage = false;
        this.showCredIntake = false;
        this.showCredVerButton = true;
    }
    validateInitiateEpicService(event){
        let params = {"contactId": this.contactId, "service": this.restrictedServiceName};
        let paramsString = JSON.stringify(params);
        getMessage({ jsonInput : paramsString })
        .then((result) => {
            this.error = undefined;
            if(result !='' && result != undefined){
                const evt = new ShowToastEvent({
                    title: 'Restriction Applied',
                    message: restrictionError,
                    variant: 'error'
                });
                this.dispatchEvent(evt);
            }else{
                this.initiateEpicValidation();
            }
        })
        .catch((error) => {
            this.error = error;
        });
    }    
    validateCredVerificationService(event){
        let params = {"contactId": this.contactId, "service": this.restrictedServiceName};
        let paramsString = JSON.stringify(params);
        getMessage({ jsonInput : paramsString })
        .then((result) => {
            this.error = undefined;
            //Null value in result means there is no restriction
            if(result !='' && result != undefined){
                const evt = new ShowToastEvent({
                    title: 'Restriction Applied',
                    message: restrictionError,
                    variant: 'error'
                });
                this.dispatchEvent(evt);
            }else{
                this.showCredIntakeScreen();
            }
        })
        .catch((error)=>{
            this.error = error;
        });        
    }
    initiateEpicValidation(){
        checkValidationUpdateMyAppClick().then(result=>{
            if(result != '' && result != undefined){
                this.initiateEpicError = result;
                this.showErrorInitiateButton = true;
            }else{
                this.showErrorInitiateButton = false;
                this.showBioInfoScreen();
            }
        })
    }
    connectedCallback(){
        this.spinner = true;
        checkAccountEstablishment().then((result)=>{
            this.accEstCompleted = result;
            getEpicExtrCaseStatus().then((result1)=>{
                this.epicExtrStatus = result1;
                if(this.accEstCompleted === true && this.epicExtrStatus === 'Case not created'){
                    this.showEpicButton = true;
                }else if(this.accEstCompleted === true && this.epicExtrStatus === 'Verification Extraction Complete'){
                    this.showCredVerButton = true;
                }else if(this.accEstCompleted === true && this.epicExtrStatus === 'Not Complete'){
                    this.showValidationMsg = true;
                }
                this.spinner = false;
            });
        });
    }
}