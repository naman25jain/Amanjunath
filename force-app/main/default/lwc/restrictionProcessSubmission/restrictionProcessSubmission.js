import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { reduceErrors } from 'c/lwcUtilities';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import ContentManagerRecords from '@salesforce/apex/ContentManagerRecords.FetchContentManagerRecords';
import compareDates from '@salesforce/apex/RestrictionBulkProcessController.compareDates';
import updateRestrictionRequest from '@salesforce/apex/RestrictionBulkProcessController.updateRestrictionRequest';

export default class RestrictionProcessSubmission extends LightningElement {
    @api recordId;
    //alertMessage;
    isSpinner = true;
    contentManagerRecords = {};
    hasRendered = false;
    validDate = false;
    restrictionType;

    get options() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }

    @wire(getRecord, { recordId: '$recordId', fields: ['Restriction_Request__c.RestrictionStatus__c', 'Restriction_Request__c.Request_Type__c', 'Restriction_Request__c.Restriction_Start_Date__c', 'Restriction_Request__c.Restriction_End_Date__c', 'Restriction_Request__c.Restriction_Level__c', 'Restriction_Request__c.Applicant_ID_List__c', 'Restriction_Request__c.Entity_ID_List__c', 'Restriction_Request__c.RecordTypeId'] })
    response;

    async connectedCallback() {
        await this.recordId;
        await this.response;
        //this.fetchContentManagerRecords();
        setTimeout(() => {
            this.compareTwoDates();
            this.fetchContentManagerRecords();
        }, 1000);
    }

    fetchContentManagerRecords() {
        var unqiueRecords = ['NonDraftRestrictionRequest', 'FutureStartDateMakeItToToday', 'applyRestrictions', 'emptyApplicants', 'emptyEntities'];
        ContentManagerRecords({ cmUniqueNames: unqiueRecords })
            .then(result => {
                this.contentManagerRecords = result;
                if (this.response !== null && this.response !== undefined && this.response.data !== null && this.response.data !== undefined
                    && this.response.data.fields.RestrictionStatus__c !== null && this.response.data.fields.RestrictionStatus__c !== undefined) {
                    if (this.response.data.fields.RestrictionStatus__c.value === 'Draft' || this.response.data.fields.RestrictionStatus__c.value === 'Processing Error') {
                        if (this.response.data.fields.Restriction_Level__c.value !== null && this.response.data.fields.Restriction_Level__c.value !== undefined) {
                            if (this.response.data.fields.Restriction_Level__c.value === 'Applicant' && (this.response.data.fields.Applicant_ID_List__c.value === null || this.response.data.fields.Applicant_ID_List__c.value === undefined)) {
                                this.template.querySelector('.message').innerHTML = this.contentManagerRecords.emptyApplicants;
                                this.isSpinner = false;
                                return;
                            } else if (this.response.data.fields.Restriction_Level__c.value === 'Entity' && (this.response.data.fields.Entity_ID_List__c.value === null || this.response.data.fields.Entity_ID_List__c.value === undefined)) {
                                this.template.querySelector('.message').innerHTML = this.contentManagerRecords.emptyEntities;
                                this.isSpinner = false;
                                return;
                            }
                        }

                        if (this.response.data.fields.Request_Type__c.value == 'New' && this.response.data.fields.Restriction_Start_Date__c.value !== null && this.response.data.fields.Restriction_Start_Date__c.value !== undefined) {
                            if (!this.validDate) {
                                this.template.querySelector('.message').innerHTML = this.contentManagerRecords.FutureStartDateMakeItToToday;
                                this.enableUserChoice = true;
                                this.isSpinner = false;
                                return;
                            }
                            else {
                                this.template.querySelector('.message').innerHTML = this.contentManagerRecords.applyRestrictions;
                                this.enableUserChoice = true;
                                this.isSpinner = false;
                                return;
                            }
                        }
                        else {
                            this.template.querySelector('.message').innerHTML = this.contentManagerRecords.applyRestrictions;
                            this.enableUserChoice = true;
                            this.isSpinner = false;
                            return;
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

    validatesDate(startDate, endDate) {
        return compareDates({ startDate: startDate, endDate: endDate }).then(result => {
            return result;
            console.log('result +++ ' + result);
        }).catch(error => {
            this.isSpinner = false;
            this.showToastMessage('error', (reduceErrors(error) ? reduceErrors(error) : ''), 'Error!');
            return false;
        });
    }


    compareTwoDates() {
        if (this.response !== null && this.response !== undefined && this.response.data !== null && this.response.data !== undefined
            && this.response.data.fields.RestrictionStatus__c !== null && this.response.data.fields.RestrictionStatus__c !== undefined) {
            if (this.response.data.fields.RestrictionStatus__c.value === 'Draft') {
                this.restrictionType = this.response.data.fields.Request_Type__c.value;
                if (this.response.data.fields.Restriction_Start_Date__c.value !== null && this.response.data.fields.Restriction_Start_Date__c.value !== undefined) {
                    this.validatesDate(this.response.data.fields.Restriction_Start_Date__c.value, null).then(res => this.validDate = res);
                }
            }
        }
    }

    handleUserChoice() {
        this.isSpinner = true;
        if (this.template.querySelector('lightning-radio-group').value === 'Yes') {
            updateRestrictionRequest({rrID : this.recordId, requestType : this.restrictionType })
            .then(() => {
                this.isSpinner = false;
                this.showToastMessage('Processing', 'Request sent for Processing. Please check back in a while', 'SUCCESS');
                getRecordNotifyChange([{recordId: this.recordId}]);
                this.closeAction();
            }).catch(error => {
                this.showToastMessage('error', (reduceErrors(error) ? reduceErrors(error) : ''), 'Error!');
                this.processError(error);
                this.isSpinner = false;
                this.closeAction();
            })       
        } else if (this.template.querySelector('lightning-radio-group').value === 'No') {
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