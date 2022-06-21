import { LightningElement, track, api } from 'lwc';
import manageReporterQuestionValue from '@salesforce/apex/AppForCertController.manageReporterQuestionValue';
import getReporterQuestionValue from '@salesforce/apex/AppForCertController.getReporterQuestionValue';
import isApplicantGraduate from '@salesforce/apex/AppForCertController.isApplicantGraduate';
import successMsg from '@salesforce/label/c.App_For_Cert_Default_Success_Message';
export default class AppForCertReporterQuesScreen extends LightningElement {
    @api getIdFromParent;
    @track successMessageText = '';
    @track showMessage = false;
    @track clickedBtn;
    @track spinner = false;
    @track subscription;
    @track accepted;
    @track showCaseDetail = false;
    @track showExamRegActionButton = false;
    connectedCallback() {
        getReporterQuestionValue().then(data=>{
            this.accepted = data;
            if(this.accepted){
                this.subscription = 'true';
            }else{
                this.subscription = 'false';
            }
        });
        //check if applicant is graduate or not on load of page
        isApplicantGraduate({
            showExamRegActionButton: this.showExamRegActionButton,
            showCaseDetail: this.showCaseDetail
        })
        .then(data => {
            this.isGraduate = data;
        })
    }
    handleChange(event) {
        this.subscription = 'false';
        if(event.target.checked){
            this.subscription = 'true';
        } 
    }
    saveContact() { // stop the form from submitting
        this.successMessageText = '';
        this.showMessage = false;
        this.spinner = true;

        manageReporterQuestionValue({
            fieldvals: this.subscription
        })
        .then(saveresult => {
            if (saveresult) {
                this.spinner = false;
                this.showMessage = true;
                this.successMessageText = successMsg;
                if(this.clickedBtn==='Next') {
                    const selectEvent = new CustomEvent('nextevent', {detail: ''});
                    this.dispatchEvent(selectEvent);
                }
            }
        })
        .catch(error => {
            this.spinner = false;
            window.console.log('Error: ' + JSON.stringify(error));
        });
    }
    prevButton(event) {
        event.preventDefault();
        if(this.isGraduate) {
            const selectEvent = new CustomEvent('previousgradevent', {});
            this.dispatchEvent(selectEvent);
        } else {
            const selectEvent = new CustomEvent('previousinstevent', {});
            this.dispatchEvent(selectEvent);
        }
    }
    nextButton(event) {
        event.preventDefault();
        this.clickedBtn = 'Next';
        this.saveContact();
    }
    saveButton(event) {
        event.preventDefault();
        this.clickedBtn = 'Save';
        this.saveContact();
    }
    cancelButton(event) {
        event.preventDefault();
        const selectEvent = new CustomEvent('cancelevent', {});
        this.dispatchEvent(selectEvent);
    }
}