import {LightningElement, track, api} from 'lwc';
import paymentCompletion from '@salesforce/apex/TranscriptRequestController.updateCaseStatus';
export default class TranscriptRequestPayment extends LightningElement{    
    @track spinner = false;
    transcriptCaseNumbers;
    @api linkSource;
    @api caseRecordId;
    @track transcriptReq;
    connectedCallback(){
        console.log('CaseRecordId -- '+this.caseRecordId);
    }
    renderedCallback(){
        const style = document.createElement('style');
         style.innerText = 'input::-webkit-outer-spin-button {display:none;}input::-webkit-inner-spin-button {display:none;}';
         this.template.querySelector('lightning-input').appendChild(style);
    }
    alertFunc(event){
           if (event.which === 38 || event.which === 40 || event.which === 69 || event.which === 101) {
              event.preventDefault();
          }
     }     
    nextButton(event){
        event.preventDefault();
        this.spinner = true;
        paymentCompletion()
        .then(result=>{
            if(result){
                this.transcriptCaseNumbers = result;
                const selectEvent = new CustomEvent('nextevent', {detail : this.transcriptCaseNumbers});
                this.dispatchEvent(selectEvent);
            }
        })
        .catch(error=>{
            this.spinner = false;
            window.console.error('System Error:  ' + JSON.stringify(error));
        });
    }    
    prevButton(event){
         event.preventDefault();
         const selectEvent = new CustomEvent('previousevent', {});
         this.dispatchEvent(selectEvent);
    }    
}