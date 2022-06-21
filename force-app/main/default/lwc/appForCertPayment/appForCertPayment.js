import {LightningElement, track, api} from 'lwc';
import paymentCompletion from '@salesforce/apex/AppForCertController.paymentCompletion';
import reSubmitAppforCert from '@salesforce/apex/AppForCertController.reSubmitAppforCert';
export default class AppForCertPayment extends LightningElement {
    @track spinner = false;
    @api caseRecordId;
    @api showExamRegActionButton;
    renderedCallback(){
        console.log('CaseRecordId -- '+this.caseRecordId);
        const style = document.createElement('style');
         style.innerText = 'input::-webkit-outer-spin-button {display:none;}input::-webkit-inner-spin-button {display:none;}';
         this.template.querySelector('lightning-input').appendChild(style);
    }
    alertFunc(event){
           if (event.which === 38 || event.which === 40 || event.which === 69 || event.which === 101) {
               window.console.log('Keypress');
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
            window.console.log('System Error:  ' + JSON.stringify(error));
        });
    }
    updateMyApplnButton(event){
        event.preventDefault();
        this.spinner = true;
        reSubmitAppforCert()
        .then(resultval => {
            if(resultval){
                const selectEvent = new CustomEvent('nextevent', {});
                this.dispatchEvent(selectEvent);
            }
        })
        .catch(error => {
            this.spinner = false;
            window.console.log('System Error:  ' + JSON.stringify(error));
        });
    }
    prevButton(event){
         event.preventDefault();
         const selectEvent = new CustomEvent('previousevent', {});
         this.dispatchEvent(selectEvent);
     }   
}