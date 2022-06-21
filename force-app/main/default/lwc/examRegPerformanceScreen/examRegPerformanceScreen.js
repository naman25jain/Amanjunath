import { LightningElement,track } from 'lwc';

import createExamRegCase from '@salesforce/apex/ExamRegistrationController.createExamRegCase';
import getCheckBoxValue from '@salesforce/apex/ExamRegistrationController.getCheckBoxValue';

export default class ExamRegPerformanceScreen extends LightningElement {
    @track btnDisabled;
    @track accepted;
    @track successMessageText = 'Successfully updated';
    @track showMsg;
    @track spinner = false;

    connectedCallback(){
        getCheckBoxValue().then(data=>{
            this.accepted = data;
            if(this.accepted){
                this.btnDisabled = false;
            }else{
                this.btnDisabled = true;
            }
        });
        
        
    }

    handleChange(event) {
        this.btnDisabled = true;
        if(event.target.checked){
            this.btnDisabled = false;
        } 
    }
    handleClick() {
        this.spinner = true;
        createExamRegCase()
        .then(saveresult => {
            if(saveresult !==undefined){
                this.spinner = false;
                this.showMsg=true;
                this.template.querySelector('.slds-is-relative').scrollIntoView();
            }
                
        }
        )
        .catch(error => {
            this.spinner = false;
            window.console.log('Error: ' + JSON.stringify(error));
        });
        
    }
    nextButton() {
        this.spinner = true;
        createExamRegCase()
        .then(saveresult => {
            if (saveresult !== undefined) {
                this.spinner = false;
                const selectEvent = new CustomEvent('nextevent', {});
                this.dispatchEvent(selectEvent);
            }
                
        }
        )
        .catch(error => {
            this.spinner = false;
            window.console.log('Error: ' + JSON.stringify(error));
        });
        
    }
    prevButton(event) {
        event.preventDefault();
        const selectEvent = new CustomEvent("previousevent", {});
        this.dispatchEvent(selectEvent);
    }
    cancelButton(event) {
        event.preventDefault();
        const selectEvent = new CustomEvent("cancelevent", {});
        this.dispatchEvent(selectEvent);
    }
    
}