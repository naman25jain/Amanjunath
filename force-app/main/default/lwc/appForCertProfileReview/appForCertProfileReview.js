import { LightningElement, api } from 'lwc';
import identityInformationMessage from '@salesforce/label/c.App_for_Cert_Identity_Information';
import contactInformationMessage from '@salesforce/label/c.App_for_Cert_Contact_Information';
import countryWarning from "@salesforce/label/c.OFAC_Profile_Review_warning_error_message";
import errorMessageOFACContact from "@salesforce/apex/AppForCertController.errorMessageOFACContact";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
export default class appForCertProfileReview extends LightningElement {
    @api getIdFromParent;
    @api getLinkSource;
    label = {
        identityInformationMessage, contactInformationMessage
    };
    connectedCallback() {
        errorMessageOFACContact()
        .then(result => {
            if(result) {
                const warnevt = new ShowToastEvent({
                    title: "Warning",
                    message: countryWarning,
                    variant: "warning"
                  });
                  this.dispatchEvent(warnevt);
            }
        })        
    }
}