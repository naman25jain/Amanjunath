import { LightningElement, track, api } from 'lwc';
import paymentCompletion from '@salesforce/apex/DupEcfmgCertificateController.paymentCompletion';
export default class DupCertPayment extends LightningElement {
    @track spinner = false;
    @api reasonDuplicate;
    @api additionalDtl;
    @api caseRecordId;
    renderedCallback(){
        console.log('Case Record Id - '+this.caseRecordId);
        const style = document.createElement('style');
        style.innerText = 'input::-webkit-outer-spin-button {display:none;}input::-webkit-inner-spin-button {display:none;}';
        this.template.querySelector('lightning-input').appendChild(style);
    }
    alertFunc(event){
        if(event.which === 38 || event.which === 40 || event.which === 69 || event.which === 101){
            window.console.error('Keypress');
            event.preventDefault();
        }
    }
    nextButton(event){
        event.preventDefault();
        this.spinner = true;
        paymentCompletion()
        .then(result => {
            if(result){
            const selectEvent = new CustomEvent('nextevent', {});
            this.dispatchEvent(selectEvent);
            }
        })
        .catch(error => {
            this.spinner = false;
            window.console.error('System Error:  ' + JSON.stringify(error));
        });
    }
    prevButton(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('prevevent', {});
        this.dispatchEvent(selectEvent);
    }
}