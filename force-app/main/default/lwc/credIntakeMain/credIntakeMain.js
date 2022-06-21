import {LightningElement,track,api} from 'lwc';
export default class CredIntakeMain extends LightningElement{
    @track showCredIntakeLandingPage = true;
    @track showCredentialIntake = false;
    @track showSummary = false;
    @track showCredLegal = false;
    @track showPayment = false;
    @track showConfirm = false;
    @track catStagId;
    @api program;
    @api casesListConfScreen;
    @track showCredentialIntakeEdit;
    @track caseRecordId;
    cancelCredIntake(event){
        event.preventDefault();
        const selectEvent = new CustomEvent("cancelevent", {});
        this.dispatchEvent(selectEvent);
    }
    showCredEditScreen(event){
        event.preventDefault();
        this.catStagId = event.detail.catStagId;
        this.showCredentialIntake = false;
        this.showCredIntakeLandingPage = false;
        this.showSummary = false;
        this.showCredentialIntakeEdit = true;
        this.showCredLegal = false;
        this.showPayment = false;
        this.showConfirm = false;
    }
    addCredRedirect(){
        this.showCredIntakeLandingPage = false;
        this.showCredentialIntake = true;
        this.showSummary = false;
        this.showCredentialIntakeEdit = false;
        this.showCredLegal = false;
        this.showPayment = false;
        this.showConfirm = false;
    }
    showCredIntakeLand(){
        this.showCredIntakeLandingPage = true;
        this.showCredentialIntake = false;
        this.showSummary = false;
        this.showCredentialIntakeEdit = false;
        this.showCredLegal = false;
        this.showPayment = false;
        this.showConfirm = false;
    }
    showSummaryScreen(event){
        this.caseRecordId = event.detail.caserecordid;
        this.showCredIntakeLandingPage = false;
        this.showCredentialIntake = false;
        this.showCredentialIntakeEdit = false;
        this.showSummary = true;
        this.showCredLegal = false;
        this.showPayment = false;
        this.showConfirm = false;
    }
    showCredLegalScreen(){
        this.showCredIntakeLandingPage = false;
        this.showCredentialIntake = false;
        this.showCredentialIntakeEdit = false;
        this.showSummary = false;
        this.showCredLegal = true;
        this.showPayment = false;
        this.showConfirm = false;
    }
    showPaymentScreen(){
        this.showCredIntakeLandingPage = false;
        this.showCredentialIntake = false;
        this.showCredentialIntakeEdit = false;
        this.showSummary = false;
        this.showCredLegal = false;
        this.showPayment = true;
        this.showConfirm = false;
    }
    showConfirmPage(event){
        this.casesListConfScreen = event.detail;
        this.showCredIntakeLandingPage = false;
        this.showCredentialIntake = false;
        this.showCredentialIntakeEdit = false;
        this.showSummary = false;
        this.showCredLegal = false;
        this.showPayment = false;
        this.showConfirm = true;
    }
    cancelCredIn(){
        window.location.reload();
    }
}