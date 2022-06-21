import { LightningElement, wire, api } from 'lwc';
import {CloseActionScreenEvent} from 'lightning/actions';
import {CurrentPageReference} from 'lightning/navigation';
import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import publishEvent from '@salesforce/apex/DeliverEvents.publishEvents';

export default class DeliverEvents extends LightningElement {

    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: ['Case.Internal_Status__c', 'Case.RecordTypeId'] })
    caseRecord;

    async connectedCallback() {
        //await this.recordId;
        await this.caseRecord;
        //setTimeout(() => {
            if(this.caseRecord && this.caseRecord.data && this.caseRecord.data.fields.Internal_Status__c  && this.caseRecord.data.fields.Internal_Status__c.value !== 'Error CIBIS'){
                this.showToastMessage('Warning', 'Sorry cannot publish event at this time. Please come back later', 'Warning');
            } else {
                //Invoke apex method publish related Event
                publishEvent({ recordId: this.recordId, recordTypeId : this.caseRecord.data.fields.RecordTypeId.value, status: this.caseRecord.data.fields.Internal_Status__c.value})
                .then(data => {
                    console.log('Sucess');
                    this.showToastMessage('Success', 'Published succesfully', 'Success');
                    this.closeAction();
                })
                .catch(Error => {
                    console.log('Error '+error);
                    this.processErrorMessage(error);
                    this.closeAction();
                })
            }
        //}, 1000);
        setTimeout(() => {
            window.location.reload();
        }, 3000);
        console.log('Record Id '+this.recordId);
    }

    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    showToastMessage(variant, message, title) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }

    processErrorMessage(message) {
        let errorMsg = '';
        if (message) {
            if (message.body) {
                if (Array.isArray(message.body)) {
                    errorMsg = message.body.map(e => e.message).join(', ');
                } else if (typeof message.body.message === 'string') {
                    errorMsg = message.body.message;
                }
            }
            else {
                errorMsg = message;
            }

        }
        this.showToastMessage('Error!', errorMsg, 'error');
    }
}