import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import ContentManagerRecords from '@salesforce/apex/ContentManagerRecords.FetchContentManagerRecords';

export default class RestrictionStatusCheck extends LightningElement {
    @api recordId;
    //alertMessage;
    isSpinner = true;
    contentManagerRecords = {};
    hasRendered = false;

    get options() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }

    @wire(getRecord, { recordId: '$recordId', fields: ['Restriction_Request__c.RestrictionStatus__c', 'Restriction_Request__c.Restriction_Start_Date__c', 'Restriction_Request__c.Restriction_End_Date__c'] })
    response;

    async renderedCallback(){
        if (this.hasRendered) {
            return;
        }
        await this.recordId;
        //this.fetchContentManagerRecords();
        await this.fetchContentManagerRecords();
        await this.response;
        
    }

    fetchContentManagerRecords(){
        var unqiueRecords = ['NonDraftRestrictionRequest','FutureStartDateMakeItToToday','applyRestrictions'];
        ContentManagerRecords({ cmUniqueNames: unqiueRecords })
        .then(result => {
            this.contentManagerRecords = result;
            if(this.response !== null && this.response !== undefined && this.response.data !== null && this.response.data !== undefined
                && this.response.data.fields.RestrictionStatus__c !== null && this.response.data.fields.RestrictionStatus__c !== undefined){
                if(this.response.data.fields.RestrictionStatus__c.value === 'Draft'){
                    if(this.response.data.fields.Restriction_Start_Date__c.value !== null && this.response.data.fields.Restriction_Start_Date__c.value !== undefined){
                        if(new Date(this.response.data.fields.Restriction_Start_Date__c.value) > new Date()){
                            this.template.querySelector('.message').innerHTML = this.contentManagerRecords.FutureStartDateMakeItToToday;
                            //this.alertMessage = 'Start date is in future. Would like to make it to today and continue?';
                            this.enableUserChoice = true;
                        } else {
                            this.template.querySelector('.message').innerHTML = this.contentManagerRecords.applyRestrictions;
                            this.enableUserChoice = true;
                        }
                    }
                } else {
                    this.template.querySelector('.message').innerHTML = this.contentManagerRecords.NonDraftRestrictionRequest;
                    //this.alertMessage = this.contentManagerRecords.NonDraftRestrictionRequest;
                    //this.alertMessage = 'Testing';
                }
            }
            this.isSpinner = false;
            this.hasRendered = true;
        })
    }

    handleUserChoice(){
        this.isSpinner = true;
        if(this.template.querySelector('lightning-radio-group').value === 'Yes'){
            //Update Record Start Date
            const fields = {};
            fields['Id'] = this.recordId;
            fields['Restriction_Start_Date__c'] = new Date().toISOString();
            fields['RestrictionStatus__c'] = 'Ready to Process';
            updateRecord({fields})
            .then(() => {
                this.isSpinner = false;
                this.showToastMessage('success', 'Updated', 'SUCCESS');
                this.closeAction();
            })
            .catch(error => {
                this.processError(error);
                this.isSpinner = false;
                this.closeAction();
            })
        } else if(this.template.querySelector('lightning-radio-group').value === 'No'){
            //Close Popup
            this.isSpinner = false;
            this.closeAction();
        } else {
            this.showToastMessage('warning', 'Please select a value to proceed further', 'Warning');
            this.isSpinner = false;
        }
    }

    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    processError(message) {
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
        this.showToastMessage('error', errorMsg, 'Error!');
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
}