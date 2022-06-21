import {LightningElement, track, api, wire} from 'lwc';
import fetchPickListValue from '@salesforce/apex/TranscriptRequestController.fatchPickListValue';
import createCnt2AccServiceRecs from "@salesforce/apex/Contact2AccServiceController.createCnt2AccServiceRecs";
import findRecords from '@salesforce/apex/Contact2AccServiceController.findRecords';
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import ACC_SERVICE_NAME from '@salesforce/schema/Account2Service__c.Service__r.Name';
import ACC_AUTO_NUMBER from '@salesforce/schema/Account2Service__c.Name';
export default class Contact2AcctService extends LightningElement{
    @api accServiceRecordId;
    @track roleOptions;
    @track preferrredModeOfComOptions;
    @track credentialtypeOptions;
    @track credentialtypeDefaultOptions = [];
    @track selectedRecord;
    @track records;
    @api searchfield = 'Name';
    @api iconname = "standard:contact";
    @track error;
    @track contactService;
    @track roleName;
    @track preferrredModeOfCommunication;
    @track physicalAddress;
    @track listOfEmails;
    @track verificationWebsiteURL;
    @track credentialType;
    @track errContactService = false;
    @track errRoleName = false;
    @track errPreferrredModeOfCommunication = false;
    @track errPhysicalAddress = false;
    @track errListOfEmails = false;
    @track errVerificationWebsiteURL = false;
    @track errCredentialType = false;
    @track errorCredentialTypeValue = false;
    @track enableSubmitutton = true;
    @track formSubmit = false;
    @track spinner = false;
    @track errCatch = false;
    @track finalSelectedRecordId;
    @track serviceOfInterest;
    @track serviceValue;
    @track streetName;
    @track cityName;
    @track stateName;
    @track stateOptions;
    @track postalCode;
    @track countryName;
    @track countryOptions;
    @track errStreet = false;
    @track errCity = false;
    @track errCountry = false;
    @track errState = false;
    @track errPostalCode = false;
    @track errStateClear = false;
    @track errPostalCodeClear = false;
    @wire(getRecord, { recordId: '$accServiceRecordId', fields: [ACC_AUTO_NUMBER], optionalFields: [ACC_SERVICE_NAME] })
    Account2Service__c;
    get accServiceName(){
        return getFieldValue(this.Account2Service__c.data, ACC_SERVICE_NAME);
    }
    @wire(fetchPickListValue,{objInfo: {'sobjectType' : 'CONTACT2ACCTSERVICE__c'},
         picklistFieldApi: 'Role__c'
     }) roleValues(result){  
        let dataList = [];
        if(result.data !== undefined){
            let tempVal = [];
            dataList = result.data;
            let tempTcRecord1 = {value:'', label: '--None--'}
            tempVal.push(tempTcRecord1);
            for(let i = 0; i < dataList.length; i++){
                let tempTcRecord = {value: dataList[i].svalue , label: dataList[i].slabel}               
                tempVal.push(tempTcRecord);
            }            
            this.roleOptions = tempVal;             
        }
    }
    @wire(fetchPickListValue,{objInfo: {'sobjectType' : 'CONTACT2ACCTSERVICE__c'},
         picklistFieldApi: 'Preferred_mode_of_communication__c'
     }) preferredmodeValues(result){  
        let dataList = [];
        if(result.data !== undefined){
        let tempVal = [];
        dataList = result.data;
        let tempTcRecord1 = {value:'', label: '--None--'}
        tempVal.push(tempTcRecord1);
        for(let i = 0; i < dataList.length; i++){  
            let tempTcRecord = {value: dataList[i].svalue , label: dataList[i].slabel}               
            tempVal.push(tempTcRecord);
            }            
        this.preferrredModeOfComOptions = tempVal;             
        }
    }
    @wire(fetchPickListValue,{objInfo: {'sobjectType' : 'CONTACT2ACCTSERVICE__c'},
         picklistFieldApi: 'Credential_Type__c'
     }) credentialtypeValues(result){  
        let dataList = [];
        if(result.data !== undefined){
            let tempVal = [];
            dataList = result.data;
            for(let i = 0; i < dataList.length; i++){  
                let tempTcRecord = {value: dataList[i].svalue , label: dataList[i].slabel}               
                tempVal.push(tempTcRecord);
            }            
            this.credentialtypeOptions = tempVal;             
        }
    }
    @wire(fetchPickListValue,{objInfo: {'sobjectType': 'CONTACT2ACCTSERVICE__c'}, picklistFieldApi: 'Country__c'})
        countryValues(result){
            let dataList = [];
            if(result.data !== undefined){
                let tempVal = [];
                dataList = result.data;
                for(let i = 0; i < dataList.length; i++){  
                    let tempTcRecord = {value: dataList[i].svalue, label: dataList[i].slabel}  
                    tempVal.push(tempTcRecord);
                } 
                this.countryOptions = tempVal;
            }
    }
    @wire(fetchPickListValue,{objInfo: {'sobjectType': 'CONTACT2ACCTSERVICE__c'}, picklistFieldApi: 'State__c'})
        stateValues(result){
            let dataList = [];
            if(result.data !== undefined){
                let tempVal = [];
                tempVal.push({value:'', label:'--None--'});
                dataList = result.data;
                for(let i = 0; i < dataList.length; i++){  
                    let tempTcRecord = {value: dataList[i].svalue, label: dataList[i].slabel}  
                    tempVal.push(tempTcRecord);
                } 
                this.stateOptions = tempVal;
            }
    }

    handleChangeForContactService(event){
        const searchKey = event.detail.value;
        /* Call the Salesforce Apex class method to find the Records */
        findRecords({
            searchKey : searchKey, 
        })
        .then(result=>{
            this.records = result;
            for(let i=0; i < this.records.length; i++){
                const rec = this.records[i];
                this.records[i].Name = rec[this.searchfield];
            }
            this.error = undefined;
        })
        .catch(error =>{
            this.error = error;
            this.records = undefined;
        });
    }
    handleSelect(event){
        const selectedRecordId = event.detail;
        this.finalSelectedRecordId = selectedRecordId;
        this.selectedRecord = this.records.find(record => record.Id === selectedRecordId);
        this.errContactService = false;
    }
    handleRemove(event){
        event.preventDefault();
        this.selectedRecord = undefined;
        this.records = undefined;
        this.error = undefined;        
    }
    handleSubmit(event){
        event.preventDefault(); // stop the form from submitting
        this.formSubmit = true;
        this.errContactService = false;
        this.errRoleName = false;
        this.errPreferrredModeOfCommunication = false;
        this.errPhysicalAddress = false;
        this.errListOfEmails = false;
        this.errVerificationWebsiteURL = false;
        this.errCredentialType = false;
        this.errorCredentialTypeValue = false;
        this.errCatch = false;
        this.errStreet = false;
        this.errCity = false;
        this.errCountry = false;
        this.errState = false;
        this.errPostalCode = false;
        this.errStateClear = false;
        this.errPostalCodeClear = false;
        this.template.querySelector('.entityPhysicalAddress').classList.remove('slds-has-error');
        this.template.querySelector('.entityListOfEmails').classList.remove('slds-has-error');
        this.template.querySelector('.entityVerificationWebsiteURL').classList.remove('slds-has-error');
        if(this.template.querySelector(".entityPhysicalAddress") !== null){
            let tempVal = this.template.querySelector(".entityPhysicalAddress").value;
            let preferrredMode = this.template.querySelector(".entityPreferrredModeOfCommunication").value;
            if(preferrredMode == 'Paper' && (tempVal === '' || tempVal === null || tempVal === undefined)){
                this.formSubmit = false;
                this.errPhysicalAddress = true;
                this.template.querySelector('.entityPhysicalAddress').classList.add('slds-has-error');
            }
        }
        if(this.template.querySelector(".streetName") !== null){
            let tempVal = this.template.querySelector(".streetName").value;
            let preferrredMode = this.template.querySelector(".entityPreferrredModeOfCommunication").value;
            if(preferrredMode == 'Paper' && (tempVal === '' || tempVal === null || tempVal === undefined)){
                this.formSubmit = false;
                this.errStreet = true;
                this.template.querySelector('.streetName').classList.add('slds-has-error');
            }
        }
        if(this.template.querySelector(".cityName") !== null){
            let tempVal = this.template.querySelector(".cityName").value;
            let preferrredMode = this.template.querySelector(".entityPreferrredModeOfCommunication").value;
            if(preferrredMode == 'Paper' && (tempVal === '' || tempVal === null || tempVal === undefined)){
                this.formSubmit = false;
                this.errCity = true;
                this.template.querySelector('.cityName').classList.add('slds-has-error');
            }
        }
        if(this.template.querySelector(".countryName") !== null){
            let tempVal = this.template.querySelector(".countryName").value;
            let preferrredMode = this.template.querySelector(".entityPreferrredModeOfCommunication").value;
            if(preferrredMode == 'Paper' && (tempVal === '' || tempVal === null || tempVal === undefined)){
                this.formSubmit = false;
                this.errCountry = true;
                this.template.querySelector('.countryName').classList.add('slds-has-error');
            }
        }
        if(this.template.querySelector(".countryName") !== null){
            let countryVal = this.template.querySelector(".countryName").value;
            let stateVal = this.template.querySelector(".stateName").value;
            let preferrredMode = this.template.querySelector(".entityPreferrredModeOfCommunication").value;
            let zipVal = this.template.querySelector(".postalCode").value;
            if(preferrredMode == 'Paper' && countryVal === 'United States' && (stateVal === '' || stateVal === null || stateVal === undefined)){
                this.formSubmit = false;
                this.errState = true;
                this.template.querySelector('.stateName').classList.add('slds-has-error');
            }
            if(countryVal && countryVal !== 'United States' && stateVal){
                this.formSubmit = false;
                this.errStateClear = true;
                this.template.querySelector('.stateName').classList.add('slds-has-error');
            }
            if(preferrredMode == 'Paper' && countryVal === 'United States' && (zipVal === '' || zipVal === null || zipVal === undefined)){
                this.formSubmit = false;
                this.errPostalCode = true;
                this.template.querySelector('.postalCode').classList.add('slds-has-error');
            }
            if(countryVal && countryVal !== 'United States' && zipVal){
                this.formSubmit = false;
                this.errPostalCodeClear = true;
                this.template.querySelector('.postalCode').classList.add('slds-has-error');
            }
        }
        if(this.template.querySelector(".entityListOfEmails") !== null){
            let tempVal = this.template.querySelector(".entityListOfEmails").value;
            let preferrredMode = this.template.querySelector(".entityPreferrredModeOfCommunication").value;
            if(preferrredMode == 'Email' && (tempVal === '' || tempVal === null || tempVal === undefined)){
                this.formSubmit = false;
                this.errListOfEmails = true;
                this.template.querySelector('.entityListOfEmails').classList.add('slds-has-error');
            }
        }
        if(this.template.querySelector(".entityVerificationWebsiteURL") !== null){
            let tempVal = this.template.querySelector(".entityVerificationWebsiteURL").value;
            let preferrredMode = this.template.querySelector(".entityPreferrredModeOfCommunication").value;
            if(preferrredMode == 'Website' && (tempVal === '' || tempVal === null || tempVal === undefined)){
                this.formSubmit = false;
                this.errVerificationWebsiteURL = true;
                this.template.querySelector('.entityVerificationWebsiteURL').classList.add('slds-has-error');
            }
        }
        if(this.template.querySelector(".entityCredentialType") !== null){
            let credentialTypeVal = this.template.querySelector(".entityCredentialType").value;
            if(this.accServiceName == 'Credential Verification'){
                if(credentialTypeVal.length == 0){
                    this.formSubmit = false;
                    this.errCredentialType = true;
                    this.template.querySelector('.entityCredentialType').classList.add('slds-has-error');
                }
            }
        }        
        if(this.formSubmit){
            this.spinner = true;
            let credentialTypeObj = this.template.querySelector(".entityCredentialType").value;
            let credentialTypeValue = credentialTypeObj.join(',');
            let fieldvals={
                contactId : this.finalSelectedRecordId,
                roleName : this.template.querySelector('.entityRoleName').value,
                preferrredModeOfCommunication : this.template.querySelector('.entityPreferrredModeOfCommunication').value,
                physicalAddress : this.template.querySelector('.entityPhysicalAddress').value,
                streetName : this.template.querySelector('.streetName').value,
                cityName : this.template.querySelector('.cityName').value,
                countryName : this.template.querySelector('.countryName').value,
                stateName : this.template.querySelector('.stateName').value,
                postalCode : this.template.querySelector('.postalCode').value,
                listOfEmails : this.template.querySelector('.entityListOfEmails').value,
                verificationWebsiteURL : this.template.querySelector('.entityVerificationWebsiteURL').value,
                credentialType : credentialTypeValue
            };
            createCnt2AccServiceRecs({
                jsonString : JSON.stringify(fieldvals), accServiceRecordId : this.accServiceRecordId
            })
            .then(saveresult =>{
                this.spinner = false;
                if(saveresult == 'true'){
                    const successevt = new ShowToastEvent({
                        title: "Success",
                        message: 'Contact Service is created successfully for the Account Service',
                        variant: "Success"
                        });
                    this.dispatchEvent(successevt);
                    this.selectedRecord = undefined;
                    this.records = undefined;
                    this.error = undefined;
                    this.roleName = '';
                    this.preferrredModeOfCommunication = '';
                    this.physicalAddress = '';
                    this.listOfEmails = '';
                    this.verificationWebsiteURL = '';
                    this.credentialtypeDefaultOptions = [];
                    this.streetName = '';
                    this.cityName = '';
                    this.stateName = '';
                    this.postalCode = '';
                    this.countryName = '';
                }else{
                    this.formSubmit = false;
                    this.template.querySelector('.credentialTypeValueError').innerHTML = saveresult+' already exists for the Account Service.';
                    this.template.querySelector('.entityCredentialType').classList.add('slds-has-error');                   
                }
            })
            .catch(error => {
                this.spinner = false;
                const errorMsg = JSON.stringify(error);
                const str = errorMsg.substring(errorMsg.lastIndexOf("message\":")+9, errorMsg.lastIndexOf("\"}]"));
                const errorEvt = new ShowToastEvent({
                    title: "Error",
                    message: str,
                    variant: "Error"
                });
                this.dispatchEvent(errorEvt);
                window.console.log('Error: ' + JSON.stringify(error));
            });
        }
    }
}