import {LightningElement,api,wire,track} from 'lwc';
import getMessage from '@salesforce/apex/RestrictedMessage.getMessage';
export default class RestrictedMessage extends LightningElement{
    @api recordId;
    @api objectApiName;
    @track messageWrapper = {"accountId" : this.accountId,
                            "contactId" : this.contactId,
                            "caseId" : this.caseId,
                            "restrictionRequestId" : this.restrictionRequestId};
    jsonMessageWrapper;
    errorMsg = '';
    @wire(getMessage, {jsonInput: '$jsonMessageWrapper'})
    getRestrictedMessage(data,error){
        if(data && data.data){
            this.errorMsg = data.data;
        }else if(error){
            window.console.error(error);
        }
    }
    connectedCallback(){
        if(this.recordId && this.objectApiName){
            switch(this.objectApiName){
                case 'Account':
                    this.messageWrapper.accountId = this.recordId;
                    break;
                case 'Case':
                    this.messageWrapper.caseId = this.recordId;
                    break;
                case 'Contact':
                    this.messageWrapper.contactId = this.recordId;
                    break;
                case 'Restriction_Request__c':
                    this.messageWrapper.restrictionRequestId = this.recordId;
                    break;
            }
        }
        this.jsonMessageWrapper = JSON.stringify(this.messageWrapper);
    }
}