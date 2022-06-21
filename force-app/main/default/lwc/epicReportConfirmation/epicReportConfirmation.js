import {LightningElement,api,track} from 'lwc';
export default class EpicReportConfirmation extends LightningElement{
    @api caseNumbers;    
    @track spinner = false;
    @track showPageReload = false;
    cancelButton(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('closeevent', {});
        this.dispatchEvent(selectEvent);
    }
}