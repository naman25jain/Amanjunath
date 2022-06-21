import {LightningElement, track, wire, api} from 'lwc';
import createTranscriptRequestCases from '@salesforce/apex/TranscriptRequestController.createTranscriptRequestCases';
import getTranscriptContactDetails from '@salesforce/apex/TranscriptRequestController.getTranscriptContactDetails';
import fatchPickListValue from '@salesforce/apex/TranscriptRequestController.fatchPickListValue';
import getTranscriptRequest from '@salesforce/apex/TranscriptRequestController.getTranscriptRequest';
import getInitialAddress from "@salesforce/apex/TranscriptRequestController.getAddressSet";
import getAddressByPlaceId from "@salesforce/apex/TranscriptRequestController.getAddressDetailsByPlaceId";
import checkOFACRestriction from "@salesforce/apex/TranscriptRequestController.checkOFACRestriction";
import {CurrentPageReference} from "lightning/navigation";
import {fireEvent} from "c/pubsub";
import {refreshApex} from '@salesforce/apex';
import errorNameofReceipt from '@salesforce/label/c.Name_of_Receipt_is_Required';
import errorOrganization from '@salesforce/label/c.Organization_is_Required';
import errorStreet from '@salesforce/label/c.Street_is_Required';
import errorCity from '@salesforce/label/c.City_is_Required';
import errorState from '@salesforce/label/c.State_is_Required';
import errorCountry from '@salesforce/label/c.Country_is_Required';
import errorTelephone from '@salesforce/label/c.Telephone_number_is_Required';
import errorCourier from '@salesforce/label/c.Courier_is_Required';
import sendToSelfMsg from '@salesforce/label/c.Send_To_Self_Message';
import applicationNotSaved from '@salesforce/label/c.Application_will_not_be_saved';
import OFACCountryValidation from '@salesforce/label/c.OFAC_Country_Validation';
export default class TranscriptRequestForm extends LightningElement{
    label = {errorNameofReceipt,errorOrganization,errorStreet,errorCity,errorState,errorCountry,
        errorTelephone,errorCourier,applicationNotSaved,sendToSelfMsg, OFACCountryValidation};
    @wire(CurrentPageReference) pageRef;
    @api needHelpText;
    @api isGlobal;
    @track addressList;
    @track showDropdown;
    @track showDropdownSec;
    @track selectedPlaceId;
    @track selectedPlaceName;
    @track selectedAddress;
    @track initSearchStatus;
    @track placeVerified;
    @api whichComponent;
    @api addressType;
    @api showInternationalAddresses=false;
	@track primaryTranscriptId;
    @track primaryNameOfReceipt;
    @track primaryOrganization;
    @track primaryStreet;
    @track primaryCity;
    @track primaryState;
    @track primaryCountry;
    @track primaryPostalCode;
    @track primaryTelephoneNumber;
    @track primaryCourier;
    @track primarySendToSelf;
    @track primaryRequestAnotherTranscript;
    @track secondaryTranscriptId;
    @track secondaryNameOfReceipt;
    @track secondaryOrganization;
    @track secondaryStreet;
    @track secondaryCity;
    @track secondaryState;
    @track secondaryCountry;
    @track secondaryPostalCode;
    @track secondaryTelephoneNumber;
    @track secondaryCourier;
    @track secondarySendToSelf;
    @track secondaryRequestAnotherTranscript;
    @track primarySendToSameAddressTranscript;
    @track numberOfCopMorethanOne;
    @track countryOptions;
    @track stateSecondaryOptions;
    @track showPrimaryTelephone = false;
    @track showSecondaryTelephone = false;
    @track formSubmit = false;
    @track errprimaryNameOfReceipt = false;
    @track errprimaryNameOrOrg = false;
    @track errprimaryStreet = false;
    @track errprimaryCity = false;
    @track errprimaryCountry = false;
    @track errprimaryTelephoneNumber = false;
    @track errprimaryCourier = false;
    @track errsecondaryNameOfReceipt = false;
    @track errsecondaryNameOrOrg = false;
    @track errsecondaryStreet = false;
    @track errsecondaryCity = false;
    @track errsecondaryCountry = false;
    @track errsecondaryTelephoneNumber = false;
    @track errsecondaryCourier = false;
    @track prevButton = false;
    @api prevButtonFromTranscriptSummary;
    initialized = false;
    @track secondaryCountryOFAC = false;
    @track primaryCountryOFAC = false;
    @api linkSource;
    @track linkSourceValue;
    @track spinner = false;
    get options() {
        return [{
            label: 'Yes',
            value: 'Yes'
        },
        {
            label: 'No',
            value: 'No'
        },
        ];
    }

    @wire(fatchPickListValue, {objInfo: {'sobjectType' : 'Transcript_Request__c'},
        picklistFieldApi: 'Country__c'}) stageNameValues(result) {        
        let dataList = [];
        if (result.data !== undefined) {
            let tempVal = [];
            dataList = result.data;
            for(let i=0; i<dataList.length; i++)  {                              
                let tempTcRecord = {value: dataList[i].svalue , label: dataList[i].slabel}               
                tempVal.push(tempTcRecord);
            }            
            this.countryOptions = tempVal;             
        }
    }

    wiredContactDetails;
    
    @wire(getTranscriptContactDetails) conDetails(result){
        this.wiredContactDetails = result;
    }
    connectedCallback(){
        this.prevButton = this.prevButtonFromTranscriptSummary;
        this.linkSourceValue = this.linkSource;
        this.initialization();
        this.loadTranscriptDetails();
        this.displayPrimaryTelephone();
    }
    renderedCallback() {

        if (this.initialized) {
            return;
        }
        this.initialized = true;
        refreshApex(this.wiredContactDetails);    
    }
    onprimaryCountryValueSelection(event){
        
        this.primaryCountry = event.target.value;
        this.primaryCountryOFAC = false;
    }  
    onprimaryStateValueSelection(event) {
        this.primaryState = event.target.value;
    }

    onsecondaryCountryValueSelection(event){
        
        this.secondaryCountry = event.target.value;
        this.secondaryCountryOFAC = false;
    }  
    onsecondaryStateValueSelection(event) {
        this.secondaryState = event.target.value;
    }

    initialization(){
        this.primaryTranscriptId = '';
        this.primaryNameOfReceipt = '';
        this.primaryOrganization = '';
        this.primaryStreet = '';
        this.primaryCity = '';
        this.primaryState = '';
        this.primaryCountry = '';
        this.primaryPostalCode = '';
        this.primaryTelephoneNumber = '';
        this.primaryCourier = '';
        this.primarySendToSelf = false;
        this.primaryRequestAnotherTranscript = false;
        this.secondaryTranscriptId = '';
        this.secondaryNameOfReceipt = '';
        this.secondaryOrganization = '';
        this.secondaryStreet = '';
        this.secondaryCity = '';
        this.secondaryState = '';
        this.secondaryCountry = '';
        this.secondaryPostalCode = '';
        this.secondaryTelephoneNumber = '';
        this.secondaryCourier = '';
        this.secondarySendToSelf = false;
        this.secondaryRequestAnotherTranscript = false;
        this.primarySendToSameAddressTranscript = false;
        this.numberOfCopMorethanOne = false;
        this.showPrimaryTelephone = false;
        this.showSecondaryTelephone = false;

        this.errprimaryNameOfReceipt = false;
        this.errprimaryNameOrOrg = false;
        this.errprimaryStreet = false;
        this.errprimaryCity = false;
        this.errprimaryCountry = false;
        this.errprimaryTelephoneNumber = false;
        this.errprimaryCourier = false;
        this.errsecondaryNameOfReceipt = false;
        this.errsecondaryNameOrOrg = false;
        this.errsecondaryStreet = false;
        this.errsecondaryCity = false;
        this.errsecondaryCountry = false;
        this.errsecondaryTelephoneNumber = false;
        this.errsecondaryCourier = false;
        this.secondaryCountryOFAC = false;
        this.primaryCountryOFAC = false;

        this.spinner = false;
    }

    handleFocus(event){
        if(event.target.name == 'primaryStreet'){
            this.showDropdownSec = false;
        }
        else if(event.target.name == 'secondaryStreet'){
            this.showDropdown = false;
        }
        else{
            this.showDropdown = false;
            this.showDropdownSec = false;
        }
    }

    handleChangeForInputFields(event) {
        if (event.target.name === 'primaryNameOfReceipt') {
            this.primaryNameOfReceipt = event.target.value;
        }
        if (event.target.name === 'primaryOrganization') {
            this.primaryOrganization = event.target.value;
        }
        if (event.target.name === 'primaryStreet') {
            this.selectedPlaceId = undefined;
			this.selectedAddress = undefined;

			fireEvent(this.pageRef, "inputchange", this.whichComponent);

            this.inputString = event.target.value;
            if (this.inputString && this.inputString !== null && this.inputString !== '') {
				this.showInternationalAddresses = true;
                getInitialAddress({ searchText: this.inputString, showInternationalAddresses : this.showInternationalAddresses })
					.then(result => {
						let predictions = JSON.parse(result).predictions;
						this.initSearchStatus = JSON.parse(result).status;

						let addresses = [];
						
						if (predictions.length > 0) {
							fireEvent(this.pageRef, 'somesuggestions', null);
							for (let i = 0; i < predictions.length; i++) {
								let countryCheck = '';
								if(predictions[i].structured_formatting.secondary_text)
									countryCheck = predictions[i].structured_formatting.secondary_text;

								if (this.showInternationalAddresses || countryCheck.endsWith(', USA')) {
									addresses.push(
										{
											main_text: predictions[i].structured_formatting.main_text,
											secondary_text: predictions[i].structured_formatting.secondary_text,
											place_id: predictions[i].place_id
										});
									}
							}
							if (addresses.length > 0) {
								this.addressList = addresses;
								this.showDropdown = true;

							} else {
								this.addressList = undefined;
								this.showDropdown = false;
								fireEvent(this.pageRef, 'zerosuggestions', null);
							}

						}
						else {
							this.addressList = undefined;
							this.showDropdown = false;
							fireEvent(this.pageRef, 'zerosuggestions', null);
						}
					})
					.catch(error=>{
                        window.console.error('Error in Search results ---> ' + error);
					});
			}
			else {
				this.addressList = undefined;
				this.showDropdown = false;
			}
			this.primaryStreet = event.target.value;
        }
        if (event.target.name === 'primaryCity') {
            this.primaryCity = event.target.value;
        }
        if (event.target.name === 'primaryState') {
            this.primaryState = event.target.value;
        }
        if (event.target.name === 'primaryCountry') {
            this.primaryCountry = event.target.value;
            this.primaryCountryOFAC = false;
        }
        if (event.target.name === 'primaryPostalCode') {
            this.primaryPostalCode = event.target.value;
        }
        if (event.target.name === 'primaryTelephoneNumber') {
            this.primaryTelephoneNumber = event.target.value;
        }
        if (event.target.name === 'secondaryNameOfReceipt') {
            this.secondaryNameOfReceipt = event.target.value;
        }
        if (event.target.name === 'secondaryOrganization') {
            this.secondaryOrganization = event.target.value;
        }
        if (event.target.name === 'secondaryStreet') {
            this.selectedPlaceId = undefined;
			this.selectedAddress = undefined;

			fireEvent(this.pageRef, "inputchange", this.whichComponent);

			this.inputString = event.target.value;
			if (this.inputString && this.inputString !== null && this.inputString !== '') {
				this.showInternationalAddresses = true;
				getInitialAddress({ searchText: this.inputString, showInternationalAddresses : this.showInternationalAddresses })
					.then(result => {
						let predictions = JSON.parse(result).predictions;
						this.initSearchStatus = JSON.parse(result).status;

						let addresses = [];
						
						if (predictions.length > 0) {
							fireEvent(this.pageRef, 'somesuggestions', null);
							for (let i = 0; i < predictions.length; i++) {
								let countryCheck = '';
								if(predictions[i].structured_formatting.secondary_text)
									countryCheck = predictions[i].structured_formatting.secondary_text;

								if (this.showInternationalAddresses || countryCheck.endsWith(', USA')) {
									addresses.push(
										{
											main_text: predictions[i].structured_formatting.main_text,
											secondary_text: predictions[i].structured_formatting.secondary_text,
											place_id: predictions[i].place_id
										});
									}
							}
							if (addresses.length > 0) {
								this.addressList = addresses;
								this.showDropdownSec = true;

							} else {
								this.addressList = undefined;
								this.showDropdownSec = false;
								fireEvent(this.pageRef, 'zerosuggestions', null);
							}

						}
						else {
							this.addressList = undefined;
							this.showDropdownSec = false;
							fireEvent(this.pageRef, 'zerosuggestions', null);
						}
					})
					.catch(error=>{
                        window.console.error('Error in Search results ---> ' + error);
					});
			}
			else {
				this.addressList = undefined;
				this.showDropdownSec = false;
			}
			this.secondaryStreet = event.target.value;
        }
        if (event.target.name === 'secondaryCity') {
            this.secondaryCity = event.target.value;
        }
        if (event.target.name === 'secondaryState') {
            this.secondaryState = event.target.value;
        }
        if (event.target.name === 'secondaryCountry') {
            this.secondaryCountry = event.target.value;
            this.secondaryCountryOFAC = false;
        }
        if (event.target.name === 'secondaryPostalCode') {
            this.secondaryPostalCode = event.target.value;
        }
        if (event.target.name === 'secondaryTelephoneNumber') {
            this.secondaryTelephoneNumber = event.target.value;
        }
           
    }
    handleChangeprimaryCourier(event) {        
        this.primaryCourier = event.target.value;         
        this.displayPrimaryTelephone();
    }
    handleChangesecondaryCourier(event) {        
        this.secondaryCourier = event.target.value; 
        this.displaySecondaryTelephone();
}

    handleChangeprimarySendToSelf(event) {
        this.primarySendToSelf = false;
        this.primarySendToSelf = event.target.checked;
        this.getContactPrimaryDetails();
        if(this.primarySendToSelf === false){
            this.clearPrimaryContactDetails();
        }
        if(this.primaryCountryOFAC === true){
            this.primaryCountryOFAC = false;
        }
        
    }

    handleChangeprimaryRequestAnotherTranscript(event) {
        this.primaryRequestAnotherTranscript = event.target.checked;
        
        this.clearSecondaryDetails();
        
    }
    handleChangesecondarySendToSelf(event) {
        this.secondarySendToSelf = false;
        this.secondarySendToSelf = event.target.checked;
        this.getContactSecondaryDetails();
        if(this.secondarySendToSelf === false){
            this.clearSecondaryContactDetails();
        }
        if(this.secondaryCountryOFAC === true){
            this.secondaryCountryOFAC = false;
        }
    }
    handleChangeprimarySendToSameAddressTranscript(event) {
        this.primarySendToSameAddressTranscript = event.target.checked; 
        this.numberOfCopMorethanOne = event.target.checked;
        this.copyPrimaryDetailsToSecondary();
        if(this.secondaryCountryOFAC === true){
            this.secondaryCountryOFAC = false;
        }
        
    }

    loadTranscriptDetails(){
        getTranscriptRequest({linkSource: this.linkSourceValue})
        .then(result=>{
            if(result !== '' && result !== undefined && result !== null){               
                if(result.primaryNameOfReceipt !== '' && result.primaryNameOfReceipt !== undefined && result.primaryNameOfReceipt !== null){
                    this.primaryNameOfReceipt = result.primaryNameOfReceipt;
                } 
				if(result.primaryOrganization !== '' && result.primaryOrganization !== undefined && result.primaryOrganization !== null){
                    this.primaryOrganization = result.primaryOrganization;
                } 
                if(result.primaryStreet !== '' && result.primaryStreet !== undefined && result.primaryStreet !== null){
                    this.primaryStreet = result.primaryStreet;
                }
                if(result.primaryCity !== '' && result.primaryCity !== undefined && result.primaryCity !== null){
                    this.primaryCity = result.primaryCity;
                }
                if(result.primaryCountry !== '' && result.primaryCountry !== undefined && result.primaryCountry !== null){
                    this.primaryCountry = result.primaryCountry;
                    
                }
                if(result.primaryState !== '' && result.primaryState !== undefined && result.primaryState !== null){
                    this.primaryState = result.primaryState;
                } 
                if(result.primaryPostalCode !== '' && result.primaryPostalCode !== undefined && result.primaryPostalCode !== null){
                    this.primaryPostalCode = result.primaryPostalCode;
                } 
				if(result.primaryTelephoneNumber !== '' && result.primaryTelephoneNumber !== undefined && result.primaryTelephoneNumber !== null){
                    this.primaryTelephoneNumber = result.primaryTelephoneNumber;
                } 
                if(result.primaryCourier !== '' && result.primaryCourier !== undefined && result.primaryCourier !== null){
                    this.primaryCourier = result.primaryCourier;
                    this.displayPrimaryTelephone();
                }
                if(result.primarySendToSelf !== undefined && result.primarySendToSelf !== null) {
                    this.primarySendToSelf = result.primarySendToSelf;
                } 
				if(result.primaryRequestAnotherTranscript !== undefined && result.primaryRequestAnotherTranscript !== null){
                    this.primaryRequestAnotherTranscript = result.primaryRequestAnotherTranscript;
                } 
                if(result.primarySendToSameAddressTranscript !== undefined && result.primarySendToSameAddressTranscript !== null){
                    this.primarySendToSameAddressTranscript = result.primarySendToSameAddressTranscript;
                }
                if(result.numberOfCopMorethanOne !== undefined && result.numberOfCopMorethanOne !== null){
                    this.numberOfCopMorethanOne = result.numberOfCopMorethanOne;
                }
                if(result.secondaryNameOfReceipt !== '' && result.secondaryNameOfReceipt !== undefined && result.secondaryNameOfReceipt !== null){
                    this.secondaryNameOfReceipt = result.secondaryNameOfReceipt;
                } 
				if(result.secondaryOrganization !== '' && result.secondaryOrganization !== undefined && result.secondaryOrganization !== null){
                    this.secondaryOrganization = result.secondaryOrganization;
                } 
                if(result.secondaryStreet !== '' && result.secondaryStreet !== undefined && result.secondaryStreet !== null){
                    this.secondaryStreet = result.secondaryStreet;
                }
                if(result.secondaryCity !== '' && result.secondaryCity !== undefined && result.secondaryCity !== null){
                    this.secondaryCity = result.secondaryCity;
                }
                if(result.secondaryCountry !== '' && result.secondaryCountry !== undefined && result.secondaryCountry !== null){
                    this.secondaryCountry = result.secondaryCountry;
                }
                if(result.secondaryState !== '' && result.secondaryState !== undefined && result.secondaryState !== null){
                    this.secondaryState = result.secondaryState;
                } 
                if(result.secondaryPostalCode !== '' && result.secondaryPostalCode !== undefined && result.secondaryPostalCode !== null){
                    this.secondaryPostalCode = result.secondaryPostalCode;
                } 
				if(result.secondaryTelephoneNumber !== '' && result.secondaryTelephoneNumber !== undefined && result.secondaryTelephoneNumber !== null){
                    this.secondaryTelephoneNumber = result.secondaryTelephoneNumber;
                } 
                if(result.secondaryCourier !== '' && result.secondaryCourier !== undefined && result.secondaryCourier !== null){
                    this.secondaryCourier = result.secondaryCourier;
                    this.displaySecondaryTelephone();
                }
                if(result.secondarySendToSelf !== undefined && result.secondarySendToSelf !== null){
                    this.secondarySendToSelf = result.secondarySendToSelf;
                }   
            }
    })
    .catch();
    }
    copyPrimaryDetailsToSecondary(){
        this.secondaryNameOfReceipt = '';
        this.secondaryOrganization = '';
        this.secondaryStreet = '';
        this.secondaryCity = '';
        this.secondaryState = '';
        this.secondaryCountry = '';
        this.secondaryPostalCode = '';
        this.secondaryTelephoneNumber = '';
        this.secondaryCourier = '';
        this.secondarySendToSelf = false;
        if(this.primarySendToSameAddressTranscript === true){
            this.secondaryNameOfReceipt = this.primaryNameOfReceipt;
            this.secondaryOrganization = this.primaryOrganization;
            this.secondaryStreet = this.primaryStreet;
            this.secondaryCity = this.primaryCity;
            this.secondaryState = this.primaryState;
            this.secondaryCountry = this.primaryCountry;
            this.secondaryPostalCode = this.primaryPostalCode;
            this.secondaryTelephoneNumber = this.primaryTelephoneNumber;
            this.secondaryCourier = this.primaryCourier;
            this.secondarySendToSelf = this.primarySendToSelf;

        }

    }

    clearSecondaryDetails(){
            this.secondaryNameOfReceipt = '';
            this.secondaryOrganization = '';
            this.secondaryStreet = '';
            this.secondaryCity = '';
            this.secondaryState = '';
            this.secondaryCountry = '';
            this.secondaryPostalCode = '';
            this.secondaryTelephoneNumber = '';
            this.secondaryCourier = '';
            this.secondarySendToSelf = false;
            this.primarySendToSameAddressTranscript = false;     
            if(this.secondaryCountryOFAC == true){
                this.secondaryCountryOFAC = false;
            }
        
    }

    displayPrimaryTelephone(){
        if(this.primaryCourier === 'Yes'){
            this.showPrimaryTelephone = true;
        }
        else{
            this.showPrimaryTelephone = false;
        }
        
    }
    displaySecondaryTelephone(){
        if(this.secondaryCourier === 'Yes'){
            this.showSecondaryTelephone = true;
        }
        else{
            this.showSecondaryTelephone = false;
        }
        
    }
    
    clearPrimaryContactDetails(){
        this.primaryStreet = '';
        this.primaryCity = '';
        this.primaryState = '';
        this.primaryCountry = '';
        this.primaryPostalCode = '';
        this.primaryNameOfReceipt = '';
        this.primaryOrganization = '';
    }

    getContactPrimaryDetails(){

        if(this.primarySendToSelf === true){
            this.clearPrimaryContactDetails();
            
            
            if (this.wiredContactDetails !== '' && this.wiredContactDetails !== undefined && this.wiredContactDetails !== null) {
                if(this.wiredContactDetails.data.split('^$??^')[0] !== 'NULL'){
                    this.primaryStreet = this.wiredContactDetails.data.split('^$??^')[0];
                }
                if(this.wiredContactDetails.data.split('^$??^')[1] !== 'NULL'){
                    this.primaryCity = this.wiredContactDetails.data.split('^$??^')[1];
                }
                if(this.wiredContactDetails.data.split('^$??^')[2] !== 'NULL'){
                    this.primaryState = this.wiredContactDetails.data.split('^$??^')[2];
                }
                if(this.wiredContactDetails.data.split('^$??^')[3] !== 'NULL'){
                    this.primaryCountry = this.wiredContactDetails.data.split('^$??^')[3];
                }
                if(this.wiredContactDetails.data.split('^$??^')[4] !== 'NULL'){
                    this.primaryPostalCode = this.wiredContactDetails.data.split('^$??^')[4];
                }
                if(this.wiredContactDetails.data.split('^$??^')[5] !== 'NULL'){
                    this.primaryNameOfReceipt = this.wiredContactDetails.data.split('^$??^')[5];
                }

            }
        }
    }
    clearSecondaryContactDetails(){
        this.secondaryStreet = '';
        this.secondaryCity = '';
        this.secondaryState = '';
        this.secondaryCountry = '';
        this.secondaryPostalCode = '';
        this.secondaryNameOfReceipt = '';
        this.secondaryOrganization = '';
    }

    getContactSecondaryDetails(){

        if(this.secondarySendToSelf === true){
            this.clearSecondaryContactDetails();
           
            
            if (this.wiredContactDetails !== '' && this.wiredContactDetails !== undefined && this.wiredContactDetails !== null) {
                if(this.wiredContactDetails.data.split('^$??^')[0] !== 'NULL'){
                    this.secondaryStreet = this.wiredContactDetails.data.split('^$??^')[0];
                }
                if(this.wiredContactDetails.data.split('^$??^')[1] !== 'NULL'){
                    this.secondaryCity = this.wiredContactDetails.data.split('^$??^')[1];
                }
                if(this.wiredContactDetails.data.split('^$??^')[2] !== 'NULL'){
                    this.secondaryState = this.wiredContactDetails.data.split('^$??^')[2];
                }
                if(this.wiredContactDetails.data.split('^$??^')[3] !== 'NULL'){
                    this.secondaryCountry = this.wiredContactDetails.data.split('^$??^')[3];
                }
                if(this.wiredContactDetails.data.split('^$??^')[4] !== 'NULL'){
                    this.secondaryPostalCode = this.wiredContactDetails.data.split('^$??^')[4];
                }
                if(this.wiredContactDetails.data.split('^$??^')[5] !== 'NULL'){
                    this.secondaryNameOfReceipt = this.wiredContactDetails.data.split('^$??^')[5];
                }

            }
        }
        if(this.secondaryCountry === ''){
            this.stateSecondaryOptions = [];         
        }

    } 
    saveAllValues(){
        this.formSubmit = true;
        this.errprimaryNameOfReceipt = false;
        this.errprimaryNameOrOrg = false;
        this.errprimaryStreet = false;
        this.errprimaryCity = false;
        this.errprimaryCountry = false;
        this.errprimaryTelephoneNumber = false;
        this.errprimaryCourier = false;
        this.errsecondaryNameOfReceipt = false;
        this.errsecondaryNameOrOrg = false;
        this.errsecondaryStreet = false;
        this.errsecondaryCity = false;
        this.errsecondaryCountry = false;
        this.errsecondaryTelephoneNumber = false;
        this.errsecondaryCourier = false;
        this.secondaryCountryOFAC = false;
        this.primaryCountryOFAC = false;
        if(this.primarySendToSameAddressTranscript === true){
            this.secondaryNameOfReceipt = this.primaryNameOfReceipt;
            this.secondaryOrganization = this.primaryOrganization;
            this.secondaryStreet = this.primaryStreet;
            this.secondaryCity = this.primaryCity;
            this.secondaryState = this.primaryState;
            this.secondaryCountry = this.primaryCountry;
            this.secondaryPostalCode = this.primaryPostalCode;
            this.secondaryTelephoneNumber = this.primaryTelephoneNumber;
            this.secondaryCourier = this.primaryCourier;
            this.secondarySendToSelf = this.primarySendToSelf;
        }
        if(this.primarySendToSelf === false){
            if(this.template.querySelector(".trPrimaryStreet") !== null){
                let tempVal = this.template.querySelector(".trPrimaryStreet").value;
                if(!(tempVal !== '' && tempVal !== null)){
                    this.formSubmit = false;
                    this.errprimaryStreet = true;
                    this.template.querySelector('.trPrimaryStreet').classList.add('slds-has-error');
                }
            }
            if(this.template.querySelector(".trPrimaryCity") !== null){
                let tempVal = this.template.querySelector(".trPrimaryCity").value;
                if(!(tempVal !== '' && tempVal !== null)){
                    this.formSubmit = false;
                    this.errprimaryCity = true;
                    this.template.querySelector('.trPrimaryCity').classList.add('slds-has-error');
                }
            }
            if(this.template.querySelector(".trPrimaryCountry") !== null){
                let tempVal = this.template.querySelector(".trPrimaryCountry").value;
                if(!(tempVal !== '' && tempVal !== null)){
                    this.formSubmit = false;
                    this.errprimaryCountry = true;
                    this.template.querySelector('.trPrimaryCountry').classList.add('slds-has-error');
                }
            }
            if(this.template.querySelector(".trPrimaryName") !== null &&            
            this.template.querySelector(".trPrimaryCourier") !== null){                
            let trPriNameValue = this.template.querySelector(".trPrimaryName").value;            
            let trPriCourierValue = this.template.querySelector(".trPrimaryCourier").value;
            if(trPriCourierValue === 'Yes'){
                if(!(trPriNameValue !== '' && trPriNameValue !== null)){                        
                        this.formSubmit = false;
                        if(!(trPriNameValue !== '' && trPriNameValue !== null)){
                            this.template.querySelector('.trPrimaryName').classList.add('slds-has-error');
                            this.errprimaryNameOfReceipt = true;
                        }                        
                }
            }          
            }
        }
        if(this.template.querySelector(".trPrimaryName") !== null &&
        this.template.querySelector(".trPrimaryOrg") !== null){
        let trPriNameValue = this.template.querySelector(".trPrimaryName").value;
        let trPriOrgValue = this.template.querySelector(".trPrimaryOrg").value;
        if(this.template.querySelector(".trPrimaryCourier") !== null){
            let trPriCourierValue = this.template.querySelector(".trPrimaryCourier").value;
        if(trPriCourierValue !== 'Yes'){
            if(!((trPriNameValue !== '' && trPriNameValue !== null) || (trPriOrgValue !== '' && trPriOrgValue !== null))){                        
                    this.formSubmit = false;
                    if(!(trPriNameValue !== '' && trPriNameValue !== null)){
                        this.template.querySelector('.trPrimaryName').classList.add('slds-has-error');
                        this.errprimaryNameOrOrg = true;
                    }
                    if(!(trPriOrgValue !== '' && trPriOrgValue !== null)){
                        this.template.querySelector('.trPrimaryOrg').classList.add('slds-has-error');
                        this.errprimaryNameOrOrg = true;
                    }                   
            } 
        }  
    }          
        }
        if(this.template.querySelector(".trPrimaryCourier") !== null){
            let tempVal = this.template.querySelector(".trPrimaryCourier").value;
            if(!(tempVal !== '' && tempVal !== null)){
                this.formSubmit = false;
                this.errprimaryCourier = true;
                this.template.querySelector('.trPrimaryCourier').classList.add('slds-has-error');
            }
        }
        if(this.template.querySelector(".trPrimaryTelephone") !== null && this.template.querySelector(".trPrimaryCourier") !== null){
            let tempVal = this.template.querySelector(".trPrimaryTelephone").value;
            let tempValcourier = this.template.querySelector(".trPrimaryCourier").value;
            if(!(tempVal !== '' && tempVal !== null && tempValcourier === 'Yes')){
                this.formSubmit = false;
                this.errprimaryTelephoneNumber = true;
                this.template.querySelector('.trPrimaryTelephone').classList.add('slds-has-error');
            }
        }
        if(this.primarySendToSameAddressTranscript === false){
            if(this.secondarySendToSelf === false){
                if(this.template.querySelector(".trSecondaryStreet") !== null){
                    let tempVal = this.template.querySelector(".trSecondaryStreet").value;
                    if(!(tempVal !== '' && tempVal !== null)){
                        this.formSubmit = false;
                        this.errsecondaryStreet = true;
                        this.template.querySelector('.trSecondaryStreet').classList.add('slds-has-error');
                    }
                }
                if(this.template.querySelector(".trSecondaryCity") !== null){
                    let tempVal = this.template.querySelector(".trSecondaryCity").value;
                    if(!(tempVal !== '' && tempVal !== null)){
                        this.formSubmit = false;
                        this.errsecondaryCity = true;
                        this.template.querySelector('.trSecondaryCity').classList.add('slds-has-error');
                    }
                }
                if(this.template.querySelector(".trSecondaryCountry") !== null){
                    let tempVal = this.template.querySelector(".trSecondaryCountry").value;
                    if(!(tempVal !== '' && tempVal !== null)){
                        this.formSubmit = false;
                        this.errsecondaryCountry = true;
                        this.template.querySelector('.trSecondaryCountry').classList.add('slds-has-error');
                    }
                }     
                if(this.template.querySelector(".trSecondaryName") !== null &&                    
                    this.template.querySelector(".trSecondaryCourier") !== null){
                    let trSecNameValue = this.template.querySelector(".trSecondaryName").value;                    
                    let trSecCourierValue = this.template.querySelector(".trSecondaryCourier").value;
                    if(trSecCourierValue === 'Yes'){
                        if(!(trSecNameValue !== '' && trSecNameValue !== null)){                                
                            this.formSubmit = false;
                            if(!(trSecNameValue !== '' && trSecNameValue !== null)){
                                this.template.querySelector('.trSecondaryName').classList.add('slds-has-error');
                                this.errsecondaryNameOfReceipt = true;
                            }         
                        }
                    }               
                }
            }
            if(this.template.querySelector(".trSecondaryName") !== null &&
            this.template.querySelector(".trSecondaryOrg") !== null 
            ){
            let trSecNameValue = this.template.querySelector(".trSecondaryName").value;
            let trSecOrgValue = this.template.querySelector(".trSecondaryOrg").value;
            if(this.template.querySelector(".trSecondaryCourier") !== null){
                let trSecCourierValue = this.template.querySelector(".trSecondaryCourier").value;
                if(trSecCourierValue !== 'Yes'){
                if(!((trSecNameValue !== '' && trSecNameValue !== null) || (trSecOrgValue !== '' && trSecOrgValue !== null))){                                
                    this.formSubmit = false;
                    if(!(trSecNameValue !== '' && trSecNameValue !== null)){
                        this.template.querySelector('.trSecondaryName').classList.add('slds-has-error');
                        this.errsecondaryNameOrOrg = true;
                    }
                    if(!(trSecOrgValue !== '' && trSecOrgValue !== null)){
                        this.template.querySelector('.trSecondaryOrg').classList.add('slds-has-error');
                        this.errsecondaryNameOrOrg = true;
                    }
                }                 

            } 
        }                              
        }
            if(this.template.querySelector(".trSecondaryCourier") !== null){
                let tempVal = this.template.querySelector(".trSecondaryCourier").value;
                if(!(tempVal !== '' && tempVal !== null)){
                    this.formSubmit = false;
                    this.errsecondaryCourier = true;
                    this.template.querySelector('.trSecondaryCourier').classList.add('slds-has-error');
                }
            }
            if(this.template.querySelector(".trSecondaryTelephone") !== null && this.template.querySelector(".trSecondaryCourier") !== null){
                let tempVal = this.template.querySelector(".trSecondaryTelephone").value;
                let tempValCourier = this.template.querySelector(".trSecondaryCourier").value;
                if(!(tempVal !== '' && tempVal !== null && tempValCourier === 'Yes')){
                    this.formSubmit = false;
                    this.errsecondaryTelephoneNumber = true;
                    this.template.querySelector('.trSecondaryTelephone').classList.add('slds-has-error');
                }
            }
        }
        checkOFACRestriction({
            prCountry: this.primaryCountry, 
            secCountry: this.secondaryCountry
        })
        .then(validationResult=>{
            if (validationResult !== '') {
                if(validationResult[0] == true){
                    this.primaryCountryOFAC = true;
                    this.formSubmit = false;
                }
                if(validationResult[1] == true){    
                    this.secondaryCountryOFAC = true;
                    this.formSubmit = false;
                }
            }
            if(this.formSubmit){
                this.spinner = true;
                let tempTcRecord = {
                    primaryTranscriptId : this.primaryTranscriptId,
                    primaryNameOfReceipt : this.primaryNameOfReceipt,
                    primaryOrganization : this.primaryOrganization,
                    primaryStreet : this.primaryStreet,
                    primaryCity : this.primaryCity,
                    primaryState : this.primaryState,
                    primaryCountry : this.primaryCountry,
                    primaryPostalCode : this.primaryPostalCode,
                    primaryTelephoneNumber : this.primaryTelephoneNumber,
                    primaryCourier : this.primaryCourier,
                    primarySendToSelf : this.primarySendToSelf,
                    primaryRequestAnotherTranscript : this.primaryRequestAnotherTranscript,
                    secondaryTranscriptId : this.secondaryTranscriptId,
                    secondaryNameOfReceipt : this.secondaryNameOfReceipt,
                    secondaryOrganization : this.secondaryOrganization,
                    secondaryStreet : this.secondaryStreet,
                    secondaryCity : this.secondaryCity,
                    secondaryState : this.secondaryState,
                    secondaryCountry : this.secondaryCountry,
                    secondaryPostalCode : this.secondaryPostalCode,
                    secondaryTelephoneNumber : this.secondaryTelephoneNumber,
                    secondaryCourier : this.secondaryCourier,
                    secondarySendToSelf : this.secondarySendToSelf,
                    primarySendToSameAddressTranscript : this.primarySendToSameAddressTranscript,
                    numberOfCopMorethanOne : this.numberOfCopMorethanOne,
                    linkSource : this.linkSourceValue
                }              
                createTranscriptRequestCases({
                    jsonString: JSON.stringify(tempTcRecord)
                })
                    .then(result=>{           
                        if (result) {
                            this.prevButton = false;
                            this.spinner = false;
                            const selectEvent = new CustomEvent('nextevent', {});
                            this.dispatchEvent(selectEvent);      
                        }
                    })
                    .catch(error=>{
                        this.spinner = false;
                        window.console.error('Error: ' + JSON.stringify(error));
                    });
            }
        })   
    }
    nextButton(event) {
        event.preventDefault();        
        this.saveAllValues();
        
    }

    cancelButtonToOpen(){
        this.template.querySelector('c-modal-component').show();
    }
    closeModal(){
        this.template.querySelector('c-modal-component').hide();
    }
    cancelButton(event) {
        event.preventDefault();
        const selectEvent = new CustomEvent('cancelevent', {});
        this.dispatchEvent(selectEvent);
    }
    handlePredictionSelect(event) {
        this.selectedPlaceId = event.detail.data.placeId;
        this.selectedPlaceName = event.detail.data.placeName;
        this.showDropdown = false;

        if (this.selectedPlaceId) {
            getAddressByPlaceId({ placeId: this.selectedPlaceId })
                .then(result => {
                    let response = JSON.parse(result).result;

                    let postalCode = '', state = '', stateCode = '', country = '', countryCode = '', city = '';
                    let street = '', street_number = '', route = '', subLocal1 = '', subLocal2 = '';

                    if (response.address_components.length > 0) {
                        for (let key in response.address_components) {
                            var fieldLabel = response.address_components[key].types[0];
                            if (fieldLabel === 'sublocality_level_2' || fieldLabel === 'sublocality_level_1' || fieldLabel === 'street_number' ||
                                fieldLabel === 'route' || fieldLabel === 'locality' || fieldLabel === 'country' || fieldLabel === 'postal_code' ||
                                fieldLabel === 'administrative_area_level_1' || fieldLabel === 'postal_town') {
                                switch (fieldLabel) {
                                    case 'sublocality_level_2':
                                        subLocal2 = response.address_components[key].long_name;
                                        break;
                                    case 'sublocality_level_1':
                                        subLocal1 = response.address_components[key].long_name;
                                        break;
                                    case 'street_number':
                                        street_number = response.address_components[key].long_name;
                                        break;
                                    case 'route':
                                        route = response.address_components[key].long_name;
                                        break;
                                    case 'postal_code':
                                        postalCode = response.address_components[key].long_name;
                                        break;
                                    case 'administrative_area_level_1':
                                        state = response.address_components[key].long_name;
                                        stateCode = response.address_components[key].short_name;
                                        break;
                                    case 'country':
                                        country = response.address_components[key].long_name;
                                        countryCode = response.address_components[key].short_name;
                                        break;
                                    case 'locality':
                                    case 'postal_town':    
                                        city = response.address_components[key].long_name;
                                        break;
                                    default:
                                        break;
                                }
                            }
                        }

                        if (street_number && route) {
                            street = street_number + ' ' + route;
                        }
                        else {
                            street = street_number;
                        }
                        if (street == null) {
                            if (subLocal2 && subLocal1) {
                                street = subLocal2 + ', ' + subLocal1;
                            }
                            else {
                                street = subLocal2 + ' ' + subLocal1;
                            }
                        }
                        if(this.initSearchStatus === 'OK' && street_number)
                        {
                            this.placeVerified = true;
                        }
                        else
                        {
                            this.placeVerified = false;
                            street = this.selectedPlaceName;
                        }
                    }

                    let address = {
                        name: response.name ? response.name : this.selectedPlaceName,
                        street: street,
                        city: city,
                        state: state,
                        stateCode: stateCode,
                        country: country,
                        countryCode: countryCode,
                        postalCode: postalCode,
                        phone: response.formatted_phone_number,
                        lat: response.geometry.location.lat,
                        lon: response.geometry.location.lng,
                        verified:this.placeVerified,
                        whichComponent: this.whichComponent
                    };
                    this.selectedAddress = address;
                    fireEvent(this.pageRef, "apilocationselected",{selectedAddress : this.selectedAddress, type : this.addressType} );
                    this.primaryStreet = street;
					this.primaryCity = city;
                    this.primaryCountry = country;
					this.primaryState = state;
					this.primaryPostalCode = postalCode;
					
                })
                .catch(error=>{
                    window.console.error('Error while getting place details --> ' + JSON.stringify(error));
                });
        }

    }
    handlePredictionSelectSec(event) {
        this.selectedPlaceId = event.detail.data.placeId;
        this.selectedPlaceName = event.detail.data.placeName;
        this.showDropdownSec = false;

        if (this.selectedPlaceId) {
            getAddressByPlaceId({ placeId: this.selectedPlaceId })
                .then(result => {
                    let response = JSON.parse(result).result;

                    let postalCode = '', state = '', stateCode = '', country = '', countryCode = '', city = '';
                    let street = '', street_number = '', route = '', subLocal1 = '', subLocal2 = '';

                    if (response.address_components.length > 0) {
                        for (let key in response.address_components) {
                            var fieldLabel = response.address_components[key].types[0];
                            if (fieldLabel === 'sublocality_level_2' || fieldLabel === 'sublocality_level_1' || fieldLabel === 'street_number' ||
                                fieldLabel === 'route' || fieldLabel === 'locality' || fieldLabel === 'country' || fieldLabel === 'postal_code' ||
                                fieldLabel === 'administrative_area_level_1' || fieldLabel === 'postal_town') {
                                switch (fieldLabel) {
                                    case 'sublocality_level_2':
                                        subLocal2 = response.address_components[key].long_name;
                                        break;
                                    case 'sublocality_level_1':
                                        subLocal1 = response.address_components[key].long_name;
                                        break;
                                    case 'street_number':
                                        street_number = response.address_components[key].long_name;
                                        break;
                                    case 'route':
                                        route = response.address_components[key].long_name;
                                        break;
                                    case 'postal_code':
                                        postalCode = response.address_components[key].long_name;
                                        break;
                                    case 'administrative_area_level_1':
                                        state = response.address_components[key].long_name;
                                        stateCode = response.address_components[key].short_name;
                                        break;
                                    case 'country':
                                        country = response.address_components[key].long_name;
                                        countryCode = response.address_components[key].short_name;
                                        break;
                                    case 'locality':
                                    case 'postal_town':
                                        city = response.address_components[key].long_name;
                                        break;
                                    default:
                                        break;
                                }
                            }
                        }

                        if (street_number && route) {
                            street = street_number + ' ' + route;
                        }
                        else {
                            street = street_number;
                        }
                        if (street == null) {
                            if (subLocal2 && subLocal1) {
                                street = subLocal2 + ', ' + subLocal1;
                            }
                            else {
                                street = subLocal2 + ' ' + subLocal1;
                            }
                        }
                        if(this.initSearchStatus === 'OK' && street_number)
                        {
                            this.placeVerified = true;
                        }
                        else
                        {
                            this.placeVerified = false;
                            street = this.selectedPlaceName;
                        }
                    }

                    let address = {
                        name: response.name ? response.name : this.selectedPlaceName,
                        street: street,
                        city: city,
                        state: state,
                        stateCode: stateCode,
                        country: country,
                        countryCode: countryCode,
                        postalCode: postalCode,
                        phone: response.formatted_phone_number,
                        lat: response.geometry.location.lat,
                        lon: response.geometry.location.lng,
                        verified:this.placeVerified,
                        whichComponent: this.whichComponent
                    };
                    this.selectedAddress = address;
                    fireEvent(this.pageRef, "apilocationselected",{selectedAddress : this.selectedAddress, type : this.addressType} );
                    this.secondaryStreet = street;
					this.secondaryCity = city;
					this.secondaryCountry = country;
					this.secondaryState = state;
					this.secondaryPostalCode = postalCode;
					
                })
                .catch(error=>{
                    window.console.error('Error while getting place details --> ' + JSON.stringify(error));
                });
        }

    }
}