import { LightningElement,track,wire,api } from 'lwc';
import getContactId from "@salesforce/apex/ServicesComponentController.getContactId";
import getContactAssociationOrStaging from "@salesforce/apex/ERASController.getContactAssociationOrStaging";
export default class ErasTokenRequestDisclosure extends LightningElement{
    @track errorMessagesText = 'You must check the box indicating that you have read the disclosures before a token can be requested';
    @track contactId;
    @track showError = false;
    @track acceptDisclosure = false;
    @track showNextScreen=false;
    @track showDisclosureScreen=true;
    @track degreeSchoolScreen=false;
    @track showBackScreen=false;
    @track showdegSummaryScreen=false;
    @api objectId;
    @api objectType;
    @wire(getContactId)
    contactIdfromController({  data }) {
        this.contactId = data;
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
    handleBackClick(){
        this.showError = false;
        this.showBackScreen=true;
        this.showDisclosureScreen=false;
        this.showNextScreen=false;
        this.degreeSchoolScreen=false;
        this.acceptDisclosure=false;
    }
    handleNextClick(){
        if(this.acceptDisclosure === false){
            this.showError = true;
        }else{
            this.acceptDisclosure=false;
            this.showError = false;
            this.showNextScreen=true;
            this.showDisclosureScreen=false;
            this.showBackScreen=false;
            this.degreeSchoolScreen=false;
            this.showdegSummaryScreen=false;
        }
    }
    handleCheckBoxChange(){
        this.acceptDisclosure = !this.acceptDisclosure; 
    }
    handleBackscreen(){
        this.degreeSchoolScreen=false;
        this.showNextScreen=false;
        this.showDisclosureScreen=true;
        this.showBackScreen=false;
        this.showdegSummaryScreen=false;
        this.showError = false;
        this.acceptDisclosure=false;
    }
    handleNextscreen(){
        this.degreeSchoolScreen=true;
        this.showNextScreen=false;
        this.showDisclosureScreen=false;
        this.showBackScreen=false;
        this.showdegSummaryScreen=false;
        this.showError = false;
    }
    showSummaryScreen(){
        this.showdegSummaryScreen=true;
        this.degreeSchoolScreen=false;
        this.showNextScreen=false;
        this.showDisclosureScreen=false;
        this.showBackScreen=false;
        this.showError = false;
    }
    showContactInfoScreen(){
        this.showNextScreen=true;
        this.showDisclosureScreen=false;
        this.showBackScreen=false;
        this.degreeSchoolScreen=false;
        this.showdegSummaryScreen=false;
        this.showError = false;
    }
}