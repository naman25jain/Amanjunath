import { LightningElement, wire, api, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import ACCOUNT_NOTIFICATION_FIELD from '@salesforce/schema/Account.EPIC_Notifications__c';
import Id from '@salesforce/user/Id';
import getContact from '@salesforce/apex/EpicReportsController.getContact';
import getMessage from '@salesforce/apex/RestrictedMessage.getMessage';
import EPICReportErrormsg from '@salesforce/label/c.Restriction_Service_Error_Message';
export default class EntityEPICPortal extends LightningElement{
    @track showNotificationsTab = false;
    @track record;
    @track restrictedAccess;
    @track EPICReportErrormsg;
    @track tempJson = {
        accountId: '',
        contactId: '',
        service: ''
    };
    @track errorMessages;
    @api
    get currentEntity(){
        return this._currentEnt;
    }
    set currentEntity(value){
        this.setAttribute('currentEntity', value);
        this._currentEnt = value;
        this.restrictedAccessCheck();
    }
    @wire(getRecord,{recordId: '$currentEntity', fields: [ACCOUNT_NOTIFICATION_FIELD]})
    wiredAccount({error, data}){
        if(data){
            this.record = data;
            this.showNotificationsTab = data.fields.EPIC_Notifications__c.value;
        }else if(error){
            this.error = error;
            this.record = undefined;
        }
    }
    connectedCallback(){
        this.restrictedAccessCheck();
    }
    @api refreshSetup(){
        this.restrictedAccessCheck();
        this.template.querySelector('c-entity-E-P-I-C-Reports').refreshSetup();
    }
    restrictedAccessCheck(){
        getContact({
            userId: Id
        }).then(conResult => {
            let tempJson = {
                accountId: this.currentEntity,
                contactId: conResult,
                service: 'EPIC Reports - Internal and External'
            };
            getMessage({jsonInput: JSON.stringify(tempJson)}).then(result => {
                if(result){
                    this.restrictedAccess = true;
                    this.errorMessages = EPICReportErrormsg;
                }else{
                    this.restrictedAccess = false;
                }
            }
            )
        })
            .catch(error => {
                window.console.error(error);
            });
    }
}