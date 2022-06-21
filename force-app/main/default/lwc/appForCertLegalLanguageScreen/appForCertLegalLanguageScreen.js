import { LightningElement, wire, track, api } from 'lwc';
import getTermsandConditionsData from '@salesforce/apex/AppForCertController.getTermsandConditionsData';
import createTermsRecord from '@salesforce/apex/AppForCertController.createTermsRecord';
import termsTitle from '@salesforce/label/c.App_For_Cert_Legal_Terms_Title';
import termsError from '@salesforce/label/c.App_For_Cert_Legal_Terms_Error';
import getAllConstants from '@salesforce/apex/AppForCertController.getAllConstants';
export default class AppForCertLegalLanguageScreen extends LightningElement {

    @track recordsList = [];
    @track showError = false;
    @track errorMessagesText = '';
    @track checkedcount = 0;
    @track spinner = false;

    @track btnNotDisabled = false;

    @api appForCertVar;
    @api showExamRegActionButton;
    @api directlyToNext;
    
    @wire(getAllConstants) 
    allConstants ({error, data}) {
        if (data) {
        this.appForCertVar = data.LWC_PRODUCT_NAME_APP_FOR_CERT_LEGAL_TERMS;
        } else {
        this.error = error;
    }
} 

      handleChange(event) {
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

    @wire(getTermsandConditionsData) objectValues({
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
        } else if (error) {
            this.recordsList = [{
                termsId : '',
                termsContent : '',
                termsCheckboxCont : ''
            }];
            window.console.log('Error: ' + JSON.stringify(error));
        }
    }

    label = {
        termsTitle
    };

    handleClick() {
        this.showError = false;
        this.spinner = true;
        this.errorMessagesText = '';
        if(this.recordsList.length===this.checkedcount) {
            createTermsRecord({
                examRegVar : this.appForCertVar
            })
            .then(saveresult => {
                window.console.log('Success: ' + saveresult);
                this.nextButton();
            }
            )
            .catch(error => {
                this.spinner = false;
                window.console.log('Error: ' + JSON.stringify(error));
            });
        } else {
            this.showError = true;
            this.spinner = false;
            this.errorMessagesText = termsError;
        }
        
    }

    prevButton(event) {
        event.preventDefault();
        if (this.directlyToNext) {
            const selectEvent = new CustomEvent('previousevent', { detail: this.directlyToNext });
            this.dispatchEvent(selectEvent);
        } else {
            const selectEvent = new CustomEvent('previousevent', {detail: ''});
            this.dispatchEvent(selectEvent);    
        }
        
    }
    
        nextButton() {
            const selectEvent = new CustomEvent('nextevent', {});
            this.dispatchEvent(selectEvent);
        }
    
   

    cancelButton(event) {
        event.preventDefault();
        const selectEvent = new CustomEvent('cancelevent', {});
        this.dispatchEvent(selectEvent);
    }

    handleClickForIncompleteCase() {
        this.showError = false;
        this.spinner = true;
        this.errorMessagesText = '';
        if(this.recordsList.length===this.checkedcount) {
            createTermsRecord({
                examRegVar : this.appForCertVar
            })
            .then(saveresult => {
                window.console.log('Success: ' + saveresult);
                this.nextConfirmation();
            }
            )
            .catch(error => {
                this.spinner = false;
                window.console.log('Error: ' + JSON.stringify(error));
            });
        } else {
            this.showError = true;
            this.spinner = false;
            this.errorMessagesText = termsError;
        }
        
    }
    nextConfirmation(){
        //event.preventDefault();
        const selectEvent = new CustomEvent('nextconfirmation', {});
        this.dispatchEvent(selectEvent);
    }

    acceptButton(event) {
        const selectEvent = new CustomEvent('acceptevent', {});
        this.dispatchEvent(selectEvent);
    }

    discardButton(event) {
        event.preventDefault();
        const selectEvent = new CustomEvent('discardevent', {});
        this.dispatchEvent(selectEvent);
    }

}