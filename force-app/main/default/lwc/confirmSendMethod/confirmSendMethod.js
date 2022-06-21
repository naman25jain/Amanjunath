import {LightningElement,api,track,wire} from 'lwc';
import {getRecord} from 'lightning/uiRecordApi';
import getDefaultSendMethod from "@salesforce/apex/EntityReviewController.getDefaultSendMethod";
export default class ConfirmSendMethod extends LightningElement{
    @api recordId;
    @track caseSendMethod = '';
    @track defaultSendMethod = '';
    @wire(getRecord, {recordId:'$recordId', fields:'Case.Send_Method__c'})
    wiredSendMethod(result){
        if(result.data){
            this.caseSendMethod = result.data.fields.Send_Method__c.value;
        }
    }
    @wire(getDefaultSendMethod, {caseId:'$recordId'})
    defaultSendMethod(result){
        if(result.data){
            this.defaultSendMethod = result.data;
        }
    }
    nextButton(){
        const selectEvent = new CustomEvent('nextevent', {});
        this.dispatchEvent(selectEvent);
    }
}