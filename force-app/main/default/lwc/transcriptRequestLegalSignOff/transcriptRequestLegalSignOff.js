import {LightningElement, track, wire} from 'lwc';
import createTermsRecord from '@salesforce/apex/AppForCertController.createTermsRecord';
import getTermsandConditionsTranscripts from '@salesforce/apex/TranscriptRequestController.getTermsandConditionsTranscripts';
import getTransscriptRequestCases from '@salesforce/apex/TranscriptRequestController.getTransscriptRequestCases';
import getAllConstants from '@salesforce/apex/AppForCertController.getAllConstants';
import termsTitle from '@salesforce/label/c.App_For_Cert_Legal_Terms_Title';
export default class TranscriptRequestLegalSignOff extends LightningElement{
    @track recordsList = [];
    @track showError = false;
    @track errorMessagesText = '';
    @track checkedcount = 0;
    @track spinner = false;
    @track transReqCaseRecordIds;
    @track btnNotDisabled = false;
    @track examRegVar;    
    @wire(getAllConstants) 
        allConstants ({error, data}) {
            if (data) {
            this.examRegVar = data.LWC_PRODUCT_NAME_TRANSCRIPT_REQUEST_LEGAL_TERMS;
            } else {
            this.error = error;
        }
    } 

    label = {
        termsTitle
    };

    @wire(getTermsandConditionsTranscripts) objectValues({
        error,
        data
    }) {
        if (data) {            
            for(let key in data){                              
                if(data.hasOwnProperty(key)){
                    let tempRecord = {
                                termsId : data[key].termsId,
                                termsContent : data[key].termsContent,
                                termsCheckboxCont : data[key].termsCheckboxContent
                            };
                    
                    if(this.recordsList.length > 0 ){
                        this.recordsList = [...this.recordsList,tempRecord];
                    } else {
                    this.recordsList = [tempRecord];
                    }                    
                }
            } 
        }else if(error){
            this.recordsList = [{
                termsId : '',
                termsContent : '',
                termsCheckboxCont : ''
            }];
            window.console.error('Error: ' + JSON.stringify(error));
        }
    }
    connectedCallback(){
        this.transcriptRequestCases();
    }
    transcriptRequestCases(){
        getTransscriptRequestCases()
        .then(result => {
            if(result){
                this.transReqCaseRecordIds = result;
            }
        })
        .catch(error => {
            window.console.log('Error: ' + JSON.stringify(error));
        });
    }
    prevButton(event) {
        event.preventDefault();
        const selectEvent = new CustomEvent("previousevent", {});
        this.dispatchEvent(selectEvent);
    }    
    handleClick() {
        this.showError = false;
        this.spinner = true;
        this.errorMessagesText = '';
        if(this.recordsList.length===this.checkedcount) {
            createTermsRecord({
                examRegVar : this.examRegVar
            })
            .then(saveresult => {
                this.nextButton();
            }
            )
            .catch(error => {
                this.spinner = false;
                window.console.error('Error: ' + JSON.stringify(error));
            });
        } else {
            this.showError = true;
            this.spinner = false;
        }        
    }
    handleChangeCheckBox(event) {
        this.btnNotDisabled = false;
        if(event.target.checked){
            this.checkedcount = this.checkedcount+1;
        } else {
            this.checkedcount = this.checkedcount-1;
        }
        if(this.recordsList.length===this.checkedcount) {
            this.btnNotDisabled = true;
        }
    }
    cancelButton(event){
        event.preventDefault();
        const selectEvent = new CustomEvent("cancelevent", {});
        this.dispatchEvent(selectEvent);
    }
    nextButton(){
        const selectEvent = new CustomEvent('nextevent', {detail:{caserecordidtransreq:this.transReqCaseRecordIds}});
        this.dispatchEvent(selectEvent);
    }
    cancelButtonToOpen(){
        this.template.querySelector('[data-id="newModalAlert"]').show();
    }
    closeModal(){
        this.template.querySelector('[data-id="newModalAlert"]').hide();
    }
}