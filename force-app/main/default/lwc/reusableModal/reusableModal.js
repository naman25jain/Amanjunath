import { LightningElement, api } from 'lwc';

export default class ReusableModal extends LightningElement {
    @api title;
    @api isModalOpen = false;
    @api modelSize;
    
    modeltype = '';
    @api showclosebtn = false;

    connectedCallback() {
        this.modeltype = 'slds-modal slds-fade-in-open'+ (this.modelSize ? ' slds-modal_'+this.modelSize : '');
    }
    @api open() {
        this.isModalOpen = true;
        const selectEvent = new CustomEvent('modalOpen', {
            detail: true
        });
        // Fire the custom event
        this.dispatchEvent(selectEvent);
    }
    @api close() {
        this.isModalOpen = false;
        const selectEvent = new CustomEvent('modalclose', {
            detail: true
        });
        // Fire the custom event
        this.dispatchEvent(selectEvent);
    }
}