import {LightningElement} from 'lwc';
export default class EpicVerReport extends LightningElement{
    requestRep(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('requestrep', {});
        this.dispatchEvent(selectEvent);
    }
}