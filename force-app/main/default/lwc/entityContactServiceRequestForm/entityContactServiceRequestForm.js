import { LightningElement, track, wire, api} from 'lwc';
import subHeading from '@salesforce/label/c.Entity_Service_Request_Heading';
import shareWithCo from '@salesforce/label/c.Entity_Service_Request_Share_With_Coordinators';
import fatchPickListValue from '@salesforce/apex/TranscriptRequestController.fatchPickListValue';
import findRecords from '@salesforce/apex/EntityServiceRequestController.findRecords';
import getMetadataId from '@salesforce/apex/EntityServiceRequestController.getEntityMetadataId';
import getEntityServices from '@salesforce/apex/EntityServiceRequestController.getEntityServices';
import { getRecord } from 'lightning/uiRecordApi';
import insertContactandCaseEntityRqeuest from '@salesforce/apex/EntityServiceRequestController.insertContactandCaseEntityRqeuest';
import { validateEmail } from 'c/util';


export default class EntityContactServiceRequestForm extends LightningElement {

    @track salutationOptions;
    @track countryOptions;
    @api searchfield = 'Name';
    @api iconname = "standard:account";
    @track records;
    @track error;
    @track selectedRecord;
    @track showConfirmationScreen = false;
    @track formSubmit = false;
    @track errEntityName = false;
    @track restOfNameVisible = true;
    @track finalSelectedRecordId;
    @track serviceOfInterest;
    @track serviceValue;

    @track errEntityLastName = false;
    @track errEntityDateofBirth = false;
    @track errEntityDOBFutureDate = false;
    @track errEntityEmailAddress = false;
    @track errEntityEmailAddressDomain = false;
    @track errEntityPhoneNumber = false;
    @track errEntityDepartment = false;
    @track errEntityJobTitle = false;
    @track errEntityCountryResidence = false;
    @track errEntityServiceInterest = false;
    @track errEntityCheckbox = false;
    @track errEntityRestName = false;
    @track errEntityNameToSelectEntity = false;

    @track entityLastName;
    @track restOfName;
    @track generationalSuffix;
    @track dateOfBirth;
    @track emailAddress;
    @track phoneNumber;
    @track department;
    @track jobTitle;
    @track countryVal;
    @track checkBoxValueOnlyOneName = false;
    @track spinner = false;
   
    @track enableSubmitutton = false;

    label = { subHeading, shareWithCo };
    
    /*Start of Confirmation screen code */
        
    @track metarecordId;
    @track firstLine;
    @track secondLine;
    @track thirdLine;
    @track fourthLine;
    @track fifthLine;
    @track showMessage = false;

    @track caseNumber;
    
    @wire(getMetadataId)
    metadatafromController(result){ 
        console.log('1 --- Test');
        if(result.data !== undefined){
            console.log('2 --- '+result.data);
            this.metarecordId = result.data;
            console.log('3 --- '+this.metarecordId);
        }        
    }

    @wire(getRecord, { recordId: '$metarecordId', fields: ['Confirmation_Message__mdt.First_Line__c', 'Confirmation_Message__mdt.Second_Line__c', 'Confirmation_Message__mdt.Third_Line__c','Confirmation_Message__mdt.Fourth_Line__c','Confirmation_Message__mdt.Fifth_Line__c'] })
    getMetadata(result){
        console.log('4 --- '+JSON.stringify(result));
        if(result.data !== undefined){
            console.log('5 --- '+JSON.stringify(result.data));
            this.firstLine = result.data.fields.First_Line__c.value;
            this.secondLine = result.data.fields.Second_Line__c.value;
            this.thirdLine = result.data.fields.Third_Line__c.value;
            this.fourthLine = result.data.fields.Fourth_Line__c.value;
            this.fifthLine = result.data.fields.Fifth_Line__c.value;
            this.showMessage = true;
        }
    }

    cancelButton(event) {
        window.location.reload();
    }

/*End of Confirmation screen code */
    
    onlyNumberKey(event) {
        if ( event.which > 31 && ( event.which < 48 ||  event.which > 57)) { 
            event.preventDefault();
        }
    }
    
    @wire(fatchPickListValue, {objInfo: {'sobjectType' : 'Contact'},
        picklistFieldApi: 'Generational_Suffix__c'}) salutationValues(result) {        
        let dataList = [];
        if (result.data !== undefined) {
            let tempVal = [];
            dataList = result.data;
            for (let i = 0; i < dataList.length; i++)  {  
                let tempTcRecord = {value: dataList[i].svalue , label: dataList[i].slabel}               
                tempVal.push(tempTcRecord);
            }            
            this.salutationOptions = tempVal;             
        }
    }
	
	 @wire(fatchPickListValue, {objInfo: {'sobjectType' : 'Contact'},
         picklistFieldApi: 'Passport_Country__c'
     }) countryValues(result) {  
        let dataList = [];
        if (result.data !== undefined) {
        let tempVal = [];
        dataList = result.data;
        for (let i = 0; i < dataList.length; i++)  {  
            let tempTcRecord = {value: dataList[i].svalue , label: dataList[i].slabel}               
            tempVal.push(tempTcRecord);
            }            
        this.countryOptions = tempVal;             
        }
    }

    handleChangeForInputFields(event) {
        const searchKey = event.detail.value;
        /* Call the Salesforce Apex class method to find the Records */
        findRecords({
            searchKey : searchKey, 
        })
        .then(result => {
            this.records = result;
            for(let i=0; i < this.records.length; i++){
                const rec = this.records[i];
                this.records[i].Name = rec[this.searchfield];
            }
            this.error = undefined;
        })
        .catch(error => {
            this.error = error;
            this.records = undefined;
        });

    }

    handleChangeForInputValue(event) {
        if (event.target.name === 'lastName') {
            this.entityLastName = event.target.value;
        }
        if (event.target.name === 'restOfName' && this.restOfNameVisible === true) {
            this.restOfName = event.target.value;
        }
        if (event.target.name === 'generationalSuffix') {
            this.generationalSuffix = event.target.value;
        }
        if (event.target.name === 'dateOfBirth') {
            this.dateOfBirth = event.target.value;
        }
        if (event.target.name === 'emailAddress') {
            this.emailAddress = event.target.value;
        }
        if (event.target.name === 'phoneNumber') {
            this.phoneNumber = event.target.value;
        }
        if (event.target.name === 'department') {
            this.department = event.target.value;
        }
        if (event.target.name === 'jobTitle') {
            this.jobTitle = event.target.value;
        }      
    }

    handleChangeCountryValue(event){
        this.countryVal = event.target.value;
    }
        
    handleChangeCheckBox(event) {
        if (event.target.checked) {
            this.restOfNameVisible = false;
            this.restOfName = '';
            this.checkBoxValueOnlyOneName = true;
        }
        else {
            this.checkBoxValueOnlyOneName = false;
            this.restOfNameVisible = true;
        }
    }
    
    handleChangeCheckBoxShareWithCo(event) {
        if (event.target.checked) { 
            this.enableSubmitutton = true;
        }
        else {
            this.enableSubmitutton = false;
        }
        
    }
    handleChangeOfInterest(event) {
        this.serviceValue = event.detail.value;
    }

    handleSelect(event){
        const selectedRecordId = event.detail;
        this.finalSelectedRecordId = selectedRecordId;
        this.serviceValue = undefined;

        getEntityServices({ finalSelectedRecordId: this.finalSelectedRecordId })
            .then(result => {
                if (result !== undefined) {
                    let dataList = [];
                    if (result !== '' ) {
                        let tempVal = [];
                        dataList = result;
                        for(var key in dataList){
                            let tempTcRecord = {value: result[key], label: key }
                            tempVal.push(tempTcRecord);
                        }
                        this.serviceOfInterest = tempVal;
                    }
                }
            })

        this.selectedRecord = this.records.find(record => record.Id === selectedRecordId);
        /* fire the event with the value of RecordId for the Selected RecordId */
        const selectedRecordEvent = new CustomEvent(
            "selectedrec",
            {
                detail : { recordId : selectedRecordId, index : this.index, relationshipfield : this.relationshipfield}
            }
        );
        this.dispatchEvent(selectedRecordEvent);
    }

    handleRemove(event){
        event.preventDefault();
        this.selectedRecord = undefined;
        this.records = undefined;
        this.error = undefined;
        this.serviceOfInterest = '';
        this.serviceValue = undefined;
        /* fire the event with the value of undefined for the Selected RecordId */
        const selectedRecordEvent = new CustomEvent(
            "selectedrec",
            {
                detail : { recordId : undefined, index : this.index, relationshipfield : this.relationshipfield}
            }
        );
        this.dispatchEvent(selectedRecordEvent);
    }

    nextButton() {
        this.formSubmit = true;
        this.errEntityName = false;
        this.errEntityLastName = false;
        this.errEntityDateofBirth = false;
        this.errEntityDOBFutureDate = false;
        this.errEntityEmailAddress = false;
        this.errEntityEmailAddressDomain = false;
        this.errEntityPhoneNumber = false;
        this.errEntityDepartment = false;
        this.errEntityJobTitle = false;
        this.errEntityCountryResidence = false;
        this.errEntityServiceInterest = false;
        this.errEntityCheckbox = false;
        this.errEntityRestName = false;
        this.errEntityNameToSelectEntity = false;
        
       
        if(this.template.querySelector(".entityCheckbox") !== null){
            let tempVal = this.template.querySelector(".entityCheckbox").value;
            if(tempVal === '' || tempVal === null || tempVal === undefined){
                this.formSubmit = false;
                this.errEntityCheckbox = true;
                this.template.querySelector('.entityCheckbox').classList.add('slds-has-error');
            }
        } 
        if(this.template.querySelector(".entityServiceInterest") !== null){
            let tempVal = this.template.querySelector(".entityServiceInterest").value;
            if(tempVal === '' || tempVal === null || tempVal === undefined){
                this.formSubmit = false;
                this.errEntityServiceInterest= true;
                this.template.querySelector('.entityServiceInterest').classList.add('slds-has-error');
            }
        } 
        if(this.template.querySelector(".entityCountryResidence") !== null){
            let tempVal = this.template.querySelector(".entityCountryResidence").value;
            if(tempVal === '' || tempVal === null || tempVal === undefined){
                this.formSubmit = false;
                this.errEntityCountryResidence= true;
                this.template.querySelector('.entityCountryResidence').classList.add('slds-has-error');
            }
        }
        if(this.template.querySelector(".entityJobTitle") !== null){
            let tempVal = this.template.querySelector(".entityJobTitle").value;
            if(!(tempVal !== '' && tempVal !== null)){
                this.formSubmit = false;
                this.errEntityJobTitle = true;
                this.template.querySelector('.entityJobTitle').classList.add('slds-has-error');
            }
        }
        if(this.template.querySelector(".entityDepartment") !== null){
            let tempVal = this.template.querySelector(".entityDepartment").value;
            if(!(tempVal !== '' && tempVal !== null)){
                this.formSubmit = false;
                this.errEntityDepartment = true;
                this.template.querySelector('.entityDepartment').classList.add('slds-has-error');
            }
        }
        if(this.template.querySelector(".entityPhoneNumber") !== null){
            let tempVal = this.template.querySelector(".entityPhoneNumber").value;
            if(!(tempVal !== '' && tempVal !== null)){
                this.formSubmit = false;
                this.errEntityPhoneNumber = true;
                this.template.querySelector('.entityPhoneNumber').classList.add('slds-has-error');
            }
        }
        if (this.template.querySelector(".entityEmailAddress") !== null) {
            let tempVal = this.template.querySelector(".entityEmailAddress").value;
            let valEmail = validateEmail(tempVal);
            if(!(tempVal !== '' && tempVal !== null)){
                this.formSubmit = false;
                this.errEntityEmailAddress = true;
                this.template.querySelector('.entityEmailAddress').classList.add('slds-has-error');
            }
            else if (valEmail === false) {
                this.formSubmit = false;
                this.errEntityEmailAddressDomain = true;
                this.template.querySelector('.entityEmailAddress').classList.add('slds-has-error');
            }
        }
        if (this.template.querySelector(".entityDateofBirth") !== null) {
            this.template.querySelector('.entityDateofBirth').classList.remove('slds-has-error');
            let tempVal = this.template.querySelector(".entityDateofBirth").value;
            
            if (!(tempVal !== '' && tempVal !== null)) {
                this.formSubmit = false;
                this.errEntityDateofBirth = true;
                this.template.querySelector('.entityDateofBirth').classList.add('slds-has-error');
            }

            var today = new Date();
            var dd = String(today.getDate()).padStart(2, '0');
            var mm = String(today.getMonth() + 1).padStart(2, '0');
            var yyyy = today.getFullYear();
            today =  yyyy + '-' + mm + '-' + dd;
            if (tempVal > today) {
                this.formSubmit = false;
                this.errEntityDOBFutureDate = true;
                this.template.querySelector('.entityDateofBirth').classList.add('slds-has-error');
            }
        }
        if(this.template.querySelector(".entityRestName") !== null){
            let tempVal = this.template.querySelector(".entityRestName").value;
            if(tempVal === '' || tempVal === null || tempVal === undefined){
                this.formSubmit = false;
                this.errEntityRestName = true;
                this.template.querySelector('.entityRestName').classList.add('slds-has-error');
            }
        }
        if(this.template.querySelector(".entityLastName") !== null){
            let tempVal = this.template.querySelector(".entityLastName").value;
            if(tempVal === '' || tempVal === null || tempVal === undefined){
                this.formSubmit = false;
                this.errEntityLastName = true;
                this.template.querySelector('.entityLastName').classList.add('slds-has-error');
            }
        }
        if(this.template.querySelector(".entityName") !== null){
            let tempVal = this.template.querySelector(".entityName").value;
            if(tempVal === '' || tempVal === null || tempVal ===undefined ){
                this.formSubmit = false;
                this.errEntityName = true;
                this.template.querySelector('.entityName').classList.add('slds-has-error');
            }
            else if ((this.selectedRecord === null || this.selectedRecord === '' || this.selectedRecord === undefined)&&(tempVal !== '' || tempVal !== null || tempVal === undefined)) {
                this.formSubmit = false;
                this.errEntityNameToSelectEntity = true;
                this.template.querySelector('.entityName').classList.add('slds-has-error');
                
            }
        }
        if (this.formSubmit === false) {
            if (this.errEntityNameToSelectEntity === true || this.errEntityName === true || this.errEntityLastName === true || this.errEntityRestName === true) {
                this.template.querySelector('.modContHdr').scrollIntoView();
            } else if(this.errEntityDateofBirth === true || this.errEntityEmailAddress === true || this.errEntityEmailAddressDomain === true || this.errEntityDOBFutureDate === true){
                this.template.querySelector('.entityEmailAddress').scrollIntoView();
            }
            else {
                this.template.querySelector('.entityCheckbox').scrollIntoView();
            }
        }
        
        if (this.formSubmit) {
            this.spinner = true;
            let tempTcRecord = {
                entityLastName: this.entityLastName,
                restOfName: this.restOfName,
                generationalSuffix: this.generationalSuffix,
                dateOfBirth: this.dateOfBirth,
                emailAddress: this.emailAddress,
                phoneNumber: this.phoneNumber,
                department: this.department,
                jobTitle: this.jobTitle,
                finalSelectedRecordId: this.finalSelectedRecordId,
                serviceValue: this.serviceValue,
                countryVal: this.countryVal,
                onlyOneName: this.checkBoxValueOnlyOneName,
            }
        
            insertContactandCaseEntityRqeuest({
                jsonString: JSON.stringify(tempTcRecord)
            })
                .then(result => {
                    window.console.log('Result', result);
                    this.showConfirmationScreen = true;       
                    this.spinner = false;
                    this.caseNumber = result;
                })
                .catch(error => {
                    window.console.log('error',error);
                    this.spinner = false;
                    
                });
            
        }
        
    }

}