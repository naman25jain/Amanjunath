import {LightningElement, api, track} from 'lwc';
export default class CredIntakeConfirm extends LightningElement{
    @api casesListConfScreen;    
    @track spinner = false;
    @track showPageReload = false;
    cancelButton(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('cancelevent', {});
        this.dispatchEvent(selectEvent);
    }
}