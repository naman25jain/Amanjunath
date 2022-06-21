import {LightningElement, api, track, wire} from 'lwc';
import fatchPickListValue from '@salesforce/apex/TranscriptRequestController.fatchPickListValue';
import insertNewRegOrg from "@salesforce/apex/EpicCredVerController.insertNewRegOrg";
import getGeoData from "@salesforce/apex/ApplicantCommunityController.getGeoData";
export default class EpicOrgSelectionScreenRecordList extends LightningElement{
    @track spinner = false;
    @api record;
    @api fieldname;
    @api iconname;
    @track showRecordsList = false;
    @track modalTitle = "Submit New Organization";
    @track countryOptions;
    @track regOrgName;
    @track countryName;
    @track streetName;
    @track cityName;
    @track postalCode;
    @track stateName;
    @track enableState = false;
    @track stateOptions;
    isCountrySelected = false;
    countryAndStateMap;
    @api recordsExistSubmitButton; //variable to show submit button when there are records.
    @track showBillingAddress = true;
    @wire(fatchPickListValue,{objInfo: {'sobjectType': 'User'}, picklistFieldApi: 'CountryCode'})
        countryValues(result){
            let dataList = [];
            if(result.data !== undefined){
                let tempVal = [];
                dataList = result.data;
                for(let i = 0; i < dataList.length; i++){  
                    let tempTcRecord = {value: dataList[i].svalue , label: dataList[i].slabel}               
                    tempVal.push(tempTcRecord);
                    }            
                this.countryOptions = tempVal;             
            }
    }
    connectedCallback(){
        if(this.record.length <= 0 && !this.recordsExistSubmitButton){
            this.showRecordsList = false; //show only new submit button
        }
        else if(this.record.length <= 0 && this.recordsExistSubmitButton){
            this.showRecordsList = true;
            this.showBillingAddress = false; //show new submit button where there are records
        }
        else{
            this.showRecordsList = true; //show records
        }
        getGeoData()
            .then(result =>{
                if(result){
                    this.countryAndStateMap = result;
                }    
            })
    }
    submitNewOrg(){
        this.template.querySelector('.submitNewOrgModal').show();
    }
    handleSelect(event){
        event.preventDefault();
        const selectedRecord = new CustomEvent("select",{detail : this.record});
        /* fire the event to be handled on the Parent Component */
        this.dispatchEvent(selectedRecord);
    }
    onNameChange(event){
        this.regOrgName = event.detail.value;
    }
    handleChangeCountryValue(event){
        this.countryName = event.detail.value;
        if(this.countryName){
            var stateEntries = this.countryAndStateMap[this.countryName];
            var parsed;
            let tempVal = [];
            if(stateEntries){
                this.enableState = true;
                for(var i = 0; i < stateEntries.length; i++){
                    parsed = JSON.parse(stateEntries[i]);
                    let tempTcRecord = {value: parsed.value, label: parsed.label};
                    tempVal.push(tempTcRecord);
                }
                this.stateOptions = tempVal;
            }
        }
        else{
            this.enableState = false;
        }
    }
    onStreetNameChange(event){
        this.streetName = event.detail.value;
    }
    onCityNameChange(event){
        this.cityName = event.detail.value;
    }
    onStateNameChange(event){
        this.stateName = event.detail.value;
    }
    onPostalCodeChange(event){
        this.postalCode = event.detail.value;
    }
    handleInsertAccountCats(){
        if(!this.template.querySelector('.entityCountryResidence').checkValidity()){
            this.template.querySelector('.entityCountryResidence').reportValidity();
        }
        else{
            this.template.querySelector('.entityCountryResidence').classList.remove("slds-has-error");
        }
        const isInputsCorrect = [...this.template.querySelectorAll('lightning-input'),this.template.querySelector('.entityCountryResidence')]
            .reduce((validSoFar, inputField) =>{
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
        if(isInputsCorrect){
            this.spinner = true;
            let tempAccountRecord = {
                regOrgName: this.regOrgName,
                countryName: this.countryName,
                streetName: this.streetName,
                cityName: this.cityName,
                stateName: this.stateName,
                postalCode: this.postalCode
            }
            insertNewRegOrg({
                jsonString: JSON.stringify(tempAccountRecord)
            })
                .then(result =>{
                    if(result){
                        const submittedOrg = new CustomEvent("submitedneworg",{detail : result});
                        /* fire the event to be handled on the Parent Component with the newly created account record details*/
                        this.dispatchEvent(submittedOrg);
                        this.spinner = false;
                    }    
                })
        }
    }
    handleClose(){
        this.template.querySelector('.submitNewOrgModal').hide();
        const clearSearchBox = new CustomEvent("clearsearchbox", {});
        /* fire the event to be handled on the Parent Component to clear the search box*/
        this.dispatchEvent(clearSearchBox);
    }
}