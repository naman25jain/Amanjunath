import {LightningElement,wire, track, api} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import fetchPickListValue from '@salesforce/apex/EntityAddUser.fetchPickListValue';
import getAllRecs from '@salesforce/apex/EntityAddUser.getServices';
import createContactCase from '@salesforce/apex/EntityAddUser.createContactCase';
import deleteAssetList from "@salesforce/apex/EntityAddUser.deleteAssetList";
import delAssetOnCancel from "@salesforce/apex/EntityAddUser.delAssetOnCancel";
import Id from '@salesforce/user/Id';
export default class EntityAddUser extends LightningElement{
    @api contactId = Id;
    @api assetSignatureForm = false;
    @track countryOptions;
    @track suffixOptions;
    @track recsList;
    @track checkboxVal;
    @track signRequired = false;
    @track records = [];
    @track lastName = '';
    @track restOfName = '';
    @track checkBoxValue = false;
    @track dob = '';
    @track suffixVal;
    @track emailAddress = '';
    @track phoneNumber ='';
    @track department = '';
    @track jobTitle = '';
    @track countryVal;
    @track nameFlag = true;
    @track serviceSelected = true;
    @track fileUpload = true;
    @track fileUploadFlag = true;
    @track yesClicked = false;
    @track enabledServices = [];
    @track mandatoryFlag = true;
    @track errorFlag = false;
    @track spinner = false;
    @track dateError = false;
    @track dateFuture = true;
    @track disableLastName = false;
    @track errRestName = false;
    _currentEnt;
    @api
    get curEntity(){
        return this._currentEnt;
    }
    set curEntity(value){
        if (this.contactSignAssetUrl){
            delAssetOnCancel({assetUrl : this.contactSignAssetUrl});
            this.contactSignAssetUrl = '';
        }
        this.setAttribute('curEntity', value);
        this._currentEnt = value; 
    }
    @track lastNameFlag = false;
    @track dobFlag = false;
    @track emailFlag = false;
    @track phoneFlag = false;
    @track deptFlag = false;
    @track titleFlag = false;
    @track countryFlag = false;
    @track serviceSelectedFlag = false;    
    @track contactSignAssetUrl;
    @track serviceFlag = false;
    @track signatureFlag = false;
    @track payloadSignedSignatureForm;
    @track showSignUploadButton = true;
    @track signUrl = null;    
    @wire(fetchPickListValue, {objInfo: {'sobjectType' : 'Contact'},
        picklistFieldApi: 'Passport_Country__c'}) stageValues(result){        
        let dataList = [];
        if(result.data !== undefined){
            let tempVal = [];
            dataList = result.data;
            for(let i=0; i<dataList.length; i++){                              
                let tempTcRecord = {value: dataList[i].svalue , label: dataList[i].slabel}               
                tempVal.push(tempTcRecord);
            }            
            this.countryOptions = tempVal;            
        }
    }
    @wire(fetchPickListValue, {objInfo: {'sobjectType' : 'Contact'},
        picklistFieldApi: 'Generational_Suffix__c'}) stageNameValues(result){        
        let dataList = [];
        if(result.data !== undefined){
            let tempVal = [];
            dataList = result.data;
            for(let i=0; i<dataList.length; i++){                              
                let tempTcRecord = {value: dataList[i].svalue , label: dataList[i].slabel}               
                tempVal.push(tempTcRecord);
            }            
            this.suffixOptions = tempVal;             
        }
    }
    get acceptedFormats(){
        return ['.pdf', '.png','.jpg','.jpeg'];
    }
    connectedCallback(){
        deleteAssetList({accountId : this._currentEnt});
    }
    handleChange(event){
        this.countryVal = event.detail.value; 
    }
    handleChangeSuffix(event){
        this.suffixVal = event.detail.value; 
    }
    checkBoxEvent(event){
        this.checkboxVal = event.target.checked;
        let classList = this.template.querySelectorAll('.servicecheckbox');
        var flag;
        for(let loopVar = 0; loopVar < classList.length; loopVar++){
            if(classList[loopVar].checked == false){
                flag = false;
            }
            else{
                flag = true;
                this.serviceSelected = false;
                break;
            }
        }
        if(flag == false){
            this.signRequired = false;
            this.serviceSelected = true;
        }
        else{
            for(let count = 0; count < this.records.length; count++){
                if(classList[count].checked == true && this.records[count].signReqd == true){
                    this.signRequired = true;
                    break;
                }
                else{
                    this.signRequired = false;
                }
            }
        }
    }
    handleOnAssetInserted(event){
        this.fileUpload = false;
        this.signatureFlag = false;  
        this.signUrl = event.detail.url;        
        this.contactSignAssetUrl = this.signUrl;
        this.payloadSignedSignatureForm =  JSON.stringify({
            contactId: null,
            caseId: 'Add a New User Request',
            documentType: 'Signed Signature Form',
            assetRecordType: 'Entity_Document',
            createOrReplace: 'Replace',
            assetStatus: 'In Progress',
            accountId: this._currentEnt,
            assetCreationRequired: 'true',
            assetId: null,
            createFromPB: 'true'
        });   
    }
    @wire (getAllRecs,{currentEntityId : '$_currentEnt'}) 
    stageName({ error, data }){
        if(data){
        if(data.length > 0){
            this.recsList = [];
            for(let key in data){
                if(data.hasOwnProperty(key)){
                    let tempRecordValues = {
                        name: data[key].name,
                        id: data[key].id,
                        signReqd : data[key].signReqd
                    };
                    this.recsList.push(tempRecordValues);
                }
            }
            this.template.querySelectorAll(".servicecheckbox")
            .forEach(elem => {
                elem.checked = false;
            });
            this.records = this.recsList;
            this.signRequired = false;
            this.payloadSignedSignatureForm =  JSON.stringify({
                contactId: this._currentEnt,
                caseId: 'Add a New User Request',
                documentType: 'Signed Signature Form',
                assetRecordType: 'Entity_Document',
                createOrReplace: 'Replace',
                assetStatus: 'In Progress',
                accountId: this._currentEnt,
                assetCreationRequired: 'true',
                assetId: null
            });
        }
        else{
            this.recsList = [];
        }
    }
    }
    lastNamechanged(event){
        this.lastName = event.detail.value;
    }
    restOfNameChanged(event){
        this.restOfName = event.detail.value;
    }
    dobChanged(event){
        this.dob = event.detail.value;
        let dateToday = new Date().toISOString().slice(0, 10);
        if(this.dob > dateToday){
            this.dateFuture = true;
            this.dateError = true;
        }
        else{
            this.dateFuture = false;
            this.dateError = false;
        }
    }
    emailChanged(event){
        this.emailAddress = event.detail.value;
    }
    phoneChanged(event){        
	let entry = event.detail.value;
        let lastChar = entry.slice(-1);
        if(!(isFinite(lastChar))){
            this.template.querySelector('.entityPhoneNumber').value = entry.slice(0,-1);
            entry = entry.slice(0,-1);
        }
        this.phoneNumber = entry;
    }
    deptChanged(event){
        this.department = event.detail.value;
    }
    jobTitleChanged(event){
        this.jobTitle = event.detail.value;
    }
    checkChanged(event){
        this.checkBoxValue = event.target.checked;
        if(this.checkBoxValue == true){
            this.restOfName = '';
            this.disableLastName = true;
        }
        else{
            this.disableLastName = false;
        }
    }
    cancelButton(){
        this.template.querySelector('c-modal-component').show();
    }
    nextButton(){
        this.spinner = true;
        if(this.restOfName == ''){
            if(this.checkBoxValue == true){
                this.nameFlag = false; //Good to submit
            }
            else{
                this.nameFlag = true;
            }
        }
        else{
            if(this.checkBoxValue == true){
                this.nameFlag = true;
            }
            else{
                this.nameFlag = false; //Good to submit
            }
        }
        if(this.signRequired == true){
            if(this.fileUpload == true){
                this.fileUploadFlag = true;
            }
            else{
                this.fileUploadFlag = false;
            }
        }
        else if(this.signRequired == false){
            this.fileUploadFlag = false;
        }
        if(this.lastName == '' || this.dob == '' || this.emailAddress == '' || this.phoneNumber=='' || this.department == '' || this.jobTitle == '' || this.countryVal == '' || this.countryVal == undefined){
            if(this.lastName == ''){
                this.lastNameFlag = true;
            }
            else{
                this.lastNameFlag = false;
            }
            if(this.dob == ''){
                this.dobFlag = true;
            }
            else{
                this.dobFlag = false;
            }
            if(this.emailAddress == ''){
                this.emailFlag = true;
            }
            else{
                this.emailFlag = false;
            }
            if(this.phoneNumber == ''){
                this.phoneFlag = true;
            }
            else{
                this.phoneFlag = false;
            }
            if(this.department == ''){
                this.deptFlag = true;
            }
            else{
                this.deptFlag = false;
            }
            if(this.jobTitle == ''){
                this.titleFlag = true;
            }
            else{
                this.titleFlag = false;
            }
            if(this.countryVal == '' || this.countryVal == undefined){
                this.countryFlag = true;
            }
            else{
                this.countryFlag = false;
            }
            this.mandatoryFlag = true; //mandatory field is empty
        }
        else{
            this.mandatoryFlag = false; //Mandatory fields filled. Good to submit
        }
        if(this.nameFlag || this.serviceSelected || this.fileUploadFlag || this.mandatoryFlag || this.dateError){
            if(this.serviceSelected){
                this.serviceFlag = true;
            }
            else{
                this.serviceFlag = false;
            }
            if(this.fileUploadFlag){
                this.signatureFlag = true;
            }
            else{
                this.signatureFlag = false;
            }
            if(this.serviceSelected){
                this.serviceSelectedFlag = true;
            }
            else{
                this.serviceSelectedFlag = false;
            }
            if(this.nameFlag){
                this.errRestName = true;
            }
            else{
                this.errRestName = false;
            }
            this.spinner = false;
            this.errorFlag = true;
            //Has error, throw error message.
        }
        else{
            //no errors, submit the records.
            this.errorFlag = false;
            this.lastNameFlag = false;
            this.dobFlag = false;
            this.emailFlag = false;
            this.phoneFlag = false;
            this.deptFlag = false;
            this.titleFlag = false;
            this.countryFlag = false;
            this.serviceSelectedFlag = false;
            this.serviceFlag = false;
            this.signatureFlag = false;
            var lastName = this.lastName;
            var nameRemaining = this.restOfName;
            var checkBoxVal = this.checkBoxValue;
            var dateofbirth = this.dob;
            var genSuf = this.suffixVal;
            var email = this.emailAddress;
            var phone = this.phoneNumber;
            var dep = this.department;
            var titlejob = this.jobTitle;
            var country = this.countryVal;
            var name = lastName.concat('&&&').concat(nameRemaining).concat('&&&').concat(checkBoxVal);
            var userData;
            if(genSuf != undefined)
                userData = dateofbirth.concat('&&&').concat(genSuf).concat('&&&').concat(email);
            else
                userData = dateofbirth.concat('&&&').concat('NO VALUE').concat('&&&').concat(email);    
            var userData2 = phone.concat('&&&').concat(dep).concat('&&&').concat(titlejob);
            var con;
            if(country != undefined)
                con = country;
            else
                con = 'NO VALUE';    
            let classList = this.template.querySelectorAll('.servicecheckbox');
            for(let loopVar = 0; loopVar < classList.length; loopVar++){
                if(classList[loopVar].checked == true){
                    this.enabledServices.push(this.records[loopVar].id);
                }
            }
            if(this.signRequired == false && this.contactSignAssetUrl != '' && this.contactSignAssetUrl != null && this.contactSignAssetUrl != undefined){
                delAssetOnCancel({ assetId: this.contactSignAssetUrl });
                this.contactSignAssetUrl = '';
            }
            createContactCase({
                arg1 : name,
                arg2 : userData,
                arg3 : userData2,
                arg4 : con,
                arg5 : this.enabledServices,
		        arg6 : this._currentEnt,
                arg7 : this.contactSignAssetUrl
            })
            .then(result=>{
                if(result !== ''){
                    if(result == 'true'){
                        this.spinner = false;
                        this.yesClicked = true;
                        const selectEvent = new CustomEvent("previousevent", {});
                        this.dispatchEvent(selectEvent);
                    }
                }
            })
            .catch(error=>{
                this.spinner = false;
                if(JSON.stringify(error).includes('DUPLICATES_DETECTED')){
                    const evt = new ShowToastEvent({
                        title: 'Error - Duplicate Alert',
                        message: 'There is already a Contact request submitted for this User. Please validate.',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);                    
                }
            });
        }
    }
    closeModal(){
        this.template.querySelector('c-modal-component').hide();
    }
    confirmModal(){
        this.yesClicked = true;
        delAssetOnCancel({assetUrl : this.contactSignAssetUrl});
        const selectEvent = new CustomEvent("previousevent", {});
        this.dispatchEvent(selectEvent);
    }
}