import {LightningElement, track, api} from 'lwc';
export default class EPExPayment extends LightningElement{
    @track spinner = false;
    @api caseRecordId;
    renderedCallback(){
        console.log('CaseRecordId -- '+this.caseRecordId);
        const style = document.createElement('style');
        style.innerText = 'input::-webkit-outer-spin-button {display:none;}input::-webkit-inner-spin-button {display:none;}';
        this.template.querySelector('lightning-input').appendChild(style);
    }
    alertFunc(event){
        if(event.which === 38 || event.which === 40 || event.which === 69 || event.which === 101){
            event.preventDefault();
        }
     }
    nextButton(event){
        event.preventDefault();
        this.spinner = true;
        const selectEvent = new CustomEvent('nextevent', {});
        this.dispatchEvent(selectEvent);
    }
    prevButton(event){
         event.preventDefault();
         const selectEvent = new CustomEvent('previousevent', {});
         this.dispatchEvent(selectEvent);
     } 
}