import { LightningElement, track, api } from 'lwc';
import contactInformationMessage from '@salesforce/label/c.App_for_Cert_Contact_Information';
import dateValidate from "@salesforce/apex/ERASController.checkERASLockdownDate";
import getContactAssociationOrStaging from "@salesforce/apex/ERASController.getContactAssociationOrStaging";
export default class ErasTokenRequestContactInfo extends LightningElement {
    @api getIdFromParent;
    @track lockDown=false;
    @track showError=false;
    @track contactInfo=false;
    @api objectId;
    @api objectType;
    label = {
        contactInformationMessage
    };
    constructor() {
        super();
        this.getContactAssocObjIdAndName();
    }
    connectedCallback() {
        dateValidate()
            .then(validate => {
                if(validate == 'true') {
                    this.showError=false;
                    this.contactInfo=true;
                }
                if(validate == 'false'){
                    this.showError=true;
                    this.contactInfo=false;
                }
            })
    }
    handleBackClick(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('prevevent',{});
        this.dispatchEvent(selectEvent);
    }
    handleNextClick(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('nextevent',{});
        this.dispatchEvent(selectEvent);
    }
    getContactAssocObjIdAndName() {
        // Getting Object Id and Object Name for school review component
        getContactAssociationOrStaging().then(result => {
            if (result) {
                this.objectId = result.split(",")[0];
                this.objectType = result.split(",")[1];
            }
        })
        .catch(error => {
        window.console.log("Error: " + JSON.stringify(error));
        });
    }

}