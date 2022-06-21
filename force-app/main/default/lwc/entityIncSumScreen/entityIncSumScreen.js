import {LightningElement,api,track} from 'lwc';
import getVerRevAffirm from '@salesforce/apex/EntityCredVerController.getVerRevAffirm';
export default class EntityIncSumScreen extends LightningElement{
    @api caseId;
    @api stepNumber;
    @api caseNumber;
    @track incReasons = [];
    connectedCallback(){
        getVerRevAffirm({caseId: this.caseId})
        .then(result=>{
            this.incReasons = result;
        }).catch(error=>{
            window.console.error('Error: ',error);
        })
    }
    returnCredRevList(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('backevent',{});
        this.dispatchEvent(selectEvent);
    }
    handlenextButton(event){
        event.preventDefault();
        let caseInfo = {caseId: this.caseId, stepNumber: this.stepNumber, caseNumber: this.caseNumber};
        const selectEvent = new CustomEvent('nextevent', {detail: caseInfo});
        this.dispatchEvent(selectEvent);
    }
}