import{LightningElement, api, track, wire} from 'lwc';
import getContactId from "@salesforce/apex/ServicesComponentController.getContactId";
import getSchoolRecords from '@salesforce/apex/ERASController.getSchoolRecords';
import getSelectedValues from '@salesforce/apex/ERASController.getSelectedValues';
import blankConfirmationValue from '@salesforce/label/c.Blank_Degree_Medical_School_Confirmation_Value';
import degreeMedicalSchoolConfirmationLanguage from '@salesforce/label/c.Confirmation_Of_Degree_Medical_School_Screen_Language';
import wrongDegreeMedicalSchool from '@salesforce/label/c.Confirmed_Wrong_Degree_Medical_School';
export default class ErasDegreeMedicalSchoolConfirmation extends LightningElement {
    @api objectType;
    @api objectId;
    @api contactId;
    label = {
        degreeMedicalSchoolConfirmationLanguage
    };
    @wire(getContactId)
    contactIdfromController({  data }) {
        this.contactId = data;
    }
    @wire(getSchoolRecords) schoolRecordValues;
    @track showMedSchool = false;
    @track disabledMedSchoolDetails = false;
    @track statusOptions = [];
    @track showNextScreen=false;
    @track showBackScreen=false;
    @track confirmedValue;
    @track medicalSchool;    
    @track selectedMedicalSchoolId;
    connectedCallback() {
        this.showMedSchool = true;
        this.disabledMedSchoolDetails = true;
     }
    get confirmDegreeMedicalSchool(){
        return[
            {label: 'Yes', value: 'Yes'},
            {label: 'No', value: 'No'},
        ];
    }
    handleSelection(event) {
        this.confirmedValue = event.detail.value;
    }       
    handleBackClick(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('prevevent',{});
        this.dispatchEvent(selectEvent);
    }
    handleNextClick(event){            
        if(this.confirmedValue === null || this.confirmedValue === undefined){
            if (this.template.querySelector('#confirmationError') === null) {
                let elem = document.createElement("div");
                elem.id = 'confirmationError';
                elem.textContent = blankConfirmationValue;
                elem.style = 'color:#ff0000; clear:both;';
                this.template.querySelector('[data-radiogroup]').classList.add('slds-has-error');
                this.template.querySelector('[data-radiogroup]').parentNode.insertBefore(elem, this.template.querySelector('[data-radiogroup]').nextSibling);            
            } 
        }else {
            this.template.querySelector('[data-radiogroup]').classList.remove('slds-has-error');
            if (this.template.querySelector('#confirmationError') !== null) {
                let elem = this.template.querySelector('#confirmationError');
                elem.parentNode.removeChild(elem);
            }            
            if(this.confirmedValue === 'Yes'){
                event.preventDefault();
                const selectEvent = new CustomEvent('nextevent',{});
                this.dispatchEvent(selectEvent);
            }
            if(this.confirmedValue === 'No'){
                let elem = document.createElement("div");
                elem.id = 'wrongDegreeMedicalSchool';
                elem.textContent = wrongDegreeMedicalSchool;
                this.template.querySelector('[data-radiogroup]').classList.add('slds-has-error');
                this.template.querySelector('[data-radiogroup]').parentNode.insertBefore(elem, this.template.querySelector('[data-radiogroup]').nextSibling);
            }
        }
    } 
    //Medical School
    @wire(getSelectedValues, {
    }) objectValues(result) {
        if (result.data) {            
            if (result.data.Account_Name__c !== undefined) {
                this.medicalSchool = result.data.Account_Name__c;
                this.selectedMedicalSchoolId = result.data.Account__c;
            }            
        } else if (result.error) {
            window.console.log('Error: ' + JSON.stringify(result.error));
        }
    }
}