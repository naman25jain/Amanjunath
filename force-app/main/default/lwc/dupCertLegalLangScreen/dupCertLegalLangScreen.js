import {LightningElement,wire,track,api} from 'lwc';
import getTermsandConditionsData from '@salesforce/apex/AppForCertController.getTermsandConditionsData';
import getDupCertCases from '@salesforce/apex/DupEcfmgCertificateController.getDupCertCases';
import termsTitle from '@salesforce/label/c.App_For_Cert_Legal_Terms_Title';
import termsError from '@salesforce/label/c.App_For_Cert_Legal_Terms_Error';
import getAllConstants from '@salesforce/apex/AppForCertController.getAllConstants';
import reSubmitAppforCert from '@salesforce/apex/AppForCertController.reSubmitAppforCert';
export default class DupCertLegalLangScreen extends LightningElement{
    @track recordsList = [];
    @track showError = false;
    @track errorMessagesText = '';
    @track checkedcount = 0;
    @track spinner = false;
    @track btnNotDisabled = false;
    @api appForCertVar;
    @api showExamRegActionButton;
    @api directlyToNext;
    @api reasonDuplicate;
    @api additionalDtl;
    @track dupCertCaseId;
    connectedCallback(){
        this.dupCertCases();
    }
    dupCertCases(){
        getDupCertCases()
        .then(result => {
            if(result){
                this.dupCertCaseId = result;
            }
        })
        .catch(error => {
            window.console.log('Error: ' + JSON.stringify(error));
        });
    }
    @wire(getAllConstants) 
    allConstants ({error, data}){
        if (data){
            this.appForCertVar = data.LWC_PRODUCT_NAME_APP_FOR_CERT_LEGAL_TERMS;
        } 
        else{
            this.error = error;
        }
    }    
    handleChange(event){
        this.btnNotDisabled = false;
        if(event.target.checked){
            this.checkedcount = this.checkedcount+1;
        }
        else{
            this.checkedcount = this.checkedcount-1;
        }
        if(this.recordsList.length===this.checkedcount){
            this.btnNotDisabled = true;
        }
    }
    @wire(getTermsandConditionsData) objectValues({
        error,
        data
    }){
        if (data){
            for(let key in data){
                if(data.hasOwnProperty(key)){
                    let tempRecord = {
                                termsId : data[key].termsId,
                                termsContent : data[key].termsContent,
                                termsCheckboxCont : data[key].termsCheckboxContent
                            };           
                    if(this.recordsList.length > 0){
                        this.recordsList = [...this.recordsList,tempRecord];
                    }
                    else{
                        this.recordsList = [tempRecord];
                    }
                }
            } 
        }
        else if (error) {
            this.recordsList = [{
                termsId : '',
                termsContent : '',
                termsCheckboxCont : ''
            }];
            window.console.error('Error: ' + JSON.stringify(error));
        }
    }
    label = {
        termsTitle
    };
    handleClick(){
        this.showError = false;
        this.spinner = true;
        this.errorMessagesText = '';
        if(this.recordsList.length===this.checkedcount){
            this.nextButton();
        } 
        else{
            this.showError = true;
            this.spinner = false;
            this.errorMessagesText = termsError;
        }
    }    
    prevButton(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('prevevent', {detail: ''});
        this.dispatchEvent(selectEvent);    
    }
    nextButton(){
        const selectEvent = new CustomEvent('nextevent', {detail:{caserecordid:this.dupCertCaseId}});
        this.dispatchEvent(selectEvent);
    }
    cancelButton(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('cancelevent', {});
        this.dispatchEvent(selectEvent);
    }
    handleClickForIncompleteCase(){
        this.showError = false;
        this.spinner = true;
        this.errorMessagesText = '';
        if(this.recordsList.length===this.checkedcount){
            createTermsRecord({
                examRegVar : this.appForCertVar
            })
            .then(saveresult => {
                window.console.error('Success: ' + saveresult);
                this.nextConfirmation();
            }
            )
            .catch(error => {
                this.spinner = false;
                window.console.error('Error: ' + JSON.stringify(error));
            });
        }
        else{
            this.showError = true;
            this.spinner = false;
            this.errorMessagesText = termsError;
        }       
    }
    nextConfirmation(){
        const selectEvent = new CustomEvent('nextconfirmation', {});
        this.dispatchEvent(selectEvent);
    }
    acceptButton(event){
        event.preventDefault();
        this.spinner = true;
        reSubmitAppforCert()
        .then(result => {
            if(result){
                const selectEvent = new CustomEvent('acceptevent', {});
                this.dispatchEvent(selectEvent);
            }
        })
        .catch(error => {
            this.spinner = false;
            window.console.error('Error: ' + JSON.stringify(error));
        });
    }
    discardButton(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('discardevent', {});
        this.dispatchEvent(selectEvent);
    }
}