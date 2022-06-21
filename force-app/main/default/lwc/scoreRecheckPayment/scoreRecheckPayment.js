import {LightningElement, track, api} from 'lwc';
import paymentCompletion from '@salesforce/apex/ScoreReportController.paymentCompletion';
export default class ScoreRecheckPayment extends LightningElement{
    @track spinner = false;
    @api casesListConfScreen;
    @api caseRecordId;
    renderedCallback(){
        console.log('Case Record Id - '+this.caseRecordId);
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
        this.spinner = true;
        event.preventDefault();
        paymentCompletion().then(result=>{
            if(result){
                this.casesListConfScreen = result;
                const selectEvent = new CustomEvent('nextevent', {detail : this.casesListConfScreen});
                this.dispatchEvent(selectEvent);
                this.spinner = false;
            }
        })
        .catch(error=>{
            window.console.error('Error: ' + JSON.stringify(error));
            this.spinner = false;
        });
    }
    prevButton(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('previousevent', {});
        this.dispatchEvent(selectEvent);
    }    
}