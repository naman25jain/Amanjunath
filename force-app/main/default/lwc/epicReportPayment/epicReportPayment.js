import {LightningElement,track,api} from 'lwc';
import payCompletion from '@salesforce/apex/EPICVerRepController.epicReportStatusUpdate';
export default class EpicReportPayment extends LightningElement{
    @track spinner = false;
    @track casesListConfScreen;
    @api parentCvCases;
    renderedCallback(){
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
        payCompletion({parentCVCases: this.parentCvCases})
        .then(result=>{
            if(result){
                this.casesListConfScreen = result;
                const selectEvent = new CustomEvent('nextevent', {detail : this.casesListConfScreen});
                this.dispatchEvent(selectEvent);
            }
        })
        .catch(error=>{
            window.console.error('System Error:  ' + JSON.stringify(error));
        });
    }    
    prevButton(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('previousevent', {detail: this.parentCvCases});
        this.dispatchEvent(selectEvent);
    }    
}