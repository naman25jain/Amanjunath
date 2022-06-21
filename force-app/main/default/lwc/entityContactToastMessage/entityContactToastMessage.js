import { LightningElement } from 'lwc';
import {
    ShowToastEvent
  } from "lightning/platformShowToastEvent";
import entityContactSubmitButtonSuccessMessage from '@salesforce/label/c.Entity_Contact_Signature_Upload_Submit_Message';

export default class EntityContactToastMessage extends LightningElement {
    constructor() {
        super();
        this.loadFileDetails();
    }
    connectedCallback() {
        this.loadFileDetails();
    }
    
    loadFileDetails() {

        let currentWindowUrl    =   window.location.href;
        var splitPathArray      =   currentWindowUrl.split( '?status=' );
        var messageStatus       =   splitPathArray[1];

        if(messageStatus == 'success') {
            const evt = new ShowToastEvent({
                title: "Success",
                message: entityContactSubmitButtonSuccessMessage,
                variant: "success"
            });
            this.dispatchEvent(evt);
        }
    }
}