import {LightningElement, track, api} from 'lwc';
import payCompletion from '@salesforce/apex/EpicCredVerController.payCompletion';
export default class CredIntakePayment extends LightningElement{
    @track spinner = false;
    @api casesListConfScreen;
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
        this.spinner = true;
        event.preventDefault();
        payCompletion()
        .then(result => {
            if(result){
                this.casesListConfScreen = result;
                const selectEvent = new CustomEvent('nextevent', {detail : this.casesListConfScreen});
                this.dispatchEvent(selectEvent);
            }
        })
        .catch(error => {
            window.console.log('System Error:  ' + JSON.stringify(error));
        });
    }    
    prevButton(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('previousevent', {});
        this.dispatchEvent(selectEvent);
    }    
}