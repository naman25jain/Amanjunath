import {LightningElement,track,wire,api} from 'lwc';
import getProgDocTypeMap from '@salesforce/apex/EpicCredVerController.getProgDocTypeMap';
import getCredentialAttributes from '@salesforce/apex/EpicCredVerController.getCredentialAttributes';
import getEntities from '@salesforce/apex/EpicCredVerController.getEntities';
import createCATRec from '@salesforce/apex/EpicCredVerController.createCATRec';
import updateExtSubCase from '@salesforce/apex/EpicCredVerController.updateExtSubCase';
import getEpicExtSubCaseStatus from '@salesforce/apex/EpicCredVerController.getEpicExtSubCaseStatus';
import dtChecker from '@salesforce/apex/EpicCredVerController.dtChecker';
export default class AnalyzeExtSubCase extends LightningElement{
    _stylePresent = false;
    @track showCredDetail;
    @track caseStatus;
    @track credAttError;
    @track chosenAttrValue = '';
    @track credItems = [];
    program = 'EPIC';
    @track nameOnDoc;
    @track nameOnDocErr = false;
    @track dobErr = false;
    @track showCredAttrFields = false;
    @track selectedEntErr;
    @track recordIdEdit = null;
    @track records = [];
    @track catRecValues = '';
    @track listOfFieldsDateCheck = [];
    @track listOfFields = [];
    @track listOfFieldsError = [];
    @api recordId;
    @track catRecId;
    @track spinner = false;
    @track breakSave;
    @track dateVals;
    @track entityName = '';
    initialized = false;
    @track selectedEntityId = '';
    @api searchfield = 'Name';
    @track savedCat = false;
    @track verFormNotAvail = false;
    @wire(getEntities) EntityRecordValues;
    @wire(getCredentialAttributes,{
        programName: '$program'
    })
    wiredCredAttr({error, data}){
        if(data){
            for(var i=0; i<data.length; i++){
                this.credItems = [...this.credItems ,{value: data[i], label: data[i]}];  
            }                                 
        }
        else if(error){
            this.credItems = [];
        }
    } 
    connectedCallback(){
        getEpicExtSubCaseStatus({caseId:this.recordId})
        .then(result=>{
            if(result){
                this.caseStatus = result;
                if(this.caseStatus == 'Accepted'){
                    this.showCredDetail = false;
                }
                else{
                    this.showCredDetail = true;
                }
            }
        }).catch(error=>{
            window.console.error('Error: ', error);
        })
    }
    loadMappedFields(){
        if(this.chosenAttrValue){
            this._stylePresent = false;
            getProgDocTypeMap({docName:this.chosenAttrValue,programName: this.program})
            .then(
            result=>{                   
                this.listOfFields = [];                 
                if(result){
                    for(let key in result){                    
                        if(result.hasOwnProperty(key)){
                            if(key == 'Expiration_Date__c' && this.chosenAttrValue == 'Certificate of Good Standing'){
                                this.listOfFields.push({value:result[key], key:key, isReq:false, errMSg:'', required:false});
                            }else{
                                this.listOfFields.push({value:result[key], key:key, isReq:false, errMSg:'', required:true});
                            }                                                       
                        }
                    }
                    this.dobErr = false;
                    this.showCredAttrFields = true;
                    this.spinner = false;  
                    this.initialized = false;        
                }
           })
        }         
    }
    validateInputForDate(event){
        if(event.target.fieldName.includes("Date__c")){
            if(event.which > 7 &&  event.which < 222){
                event.preventDefault();
            }
        }
        if(event.target.fieldName.includes("Year")){
            if(!((event.keyCode >= 48 && event.keyCode <= 57) || event.keyCode == 8 || event.keyCode == 46)){
                event.preventDefault();
            }
        } 
    }
    preventDefaultMethod(event){
        event.preventDefault();
    }
    handleChangeCredential(event){
        this.chosenAttrValue = event.detail.value;
        this.recordIdEdit = null;
        this.selectedAccountName = '';
        this.entityName = null;
        this.nameOnDoc = null;
        this.showCredAttrFields = false;
        if(this.chosenAttrValue){
            this.credAttError = false;
        }
        this.nameOnDocErr = false;
        this.selectedEntErr = false;
        this.template.querySelector('.entityRecord').classList.remove('slds-has-error');
        this.spinner = true;
        this.loadMappedFields();
    }
    handleEntityChange(event){
        this.entityName = event.target.value;
        if(event.target.value){
            this.selectedEntityId = this.template.querySelector(".EntityList option[value=\"" + event.target.value + "\"]").getAttribute("data-entityid");
            this.selectedAccountName = false;
            this.selectedEntErr = false;
        }
        else{
            this.selectedEntityId = null;
            this.selectedEntErr = true;
        }
    }
    handleChangeForInputFields(event){
        this.nameOnDoc = event.target.value;
        this.nameOnDocErr = false;
    }
    validateDob(event){
        if(event.target.value){
            var dob = new Date(event.target.value);
            var today = new Date();
            if(dob>today){
                this.dobErr = true;
                this.template.querySelector('.dob').classList.add('slds-has-error');
            }
            else{
                this.dobErr = false;
                this.template.querySelector('.dob').classList.remove('slds-has-error');
            }
        }
        else{
            this.dobErr = false;
            this.template.querySelector('.dob').classList.remove('slds-has-error');
        }
    }
    renderedCallback(){
        if(this.initialized){
            return;
        }
        if(this.showCredDetail){
            this.initialized = true;
            let listId = this.template.querySelector('datalist.EntityList').id;
            this.template.querySelector("input.entityRecord").setAttribute("list", listId);
        }
        if(this.template.querySelector('lightning-input-field') !== null && !this._stylePresent){
            const style = document.createElement('style');
            style.innerText = `c-analyze-ext-sub-case .slds-form-element__icon{
                display: none;
            }.accountName .slds-input{
                padding-left: 6%;
            }.slds-has-error .slds-form-element__help{
                display: none;
            }`;
            this.template.querySelector('lightning-input-field').appendChild(style);            
            this._stylePresent = true;
        }
    }
    handleCheckbox(event){
        if(event.target.checked === true){ 
            this.verFormNotAvail = true;
        }
        else{
            this.verFormNotAvail = false;
        }
    }
    handleSave(){
        this.spinner = true;
        this.validateFields();
    }
    validateFields(){
        this.nameOnDocErr = false;
        this.credAttError = false;
        this.breakSave = false;
        this.selectedEntErr = false;
        const inputFields = this.template.querySelectorAll('lightning-input-field');
        if(!this.chosenAttrValue && this.template.querySelector('.credAtt') !== null){
            this.credAttError = true;
            this.spinner = false;
            this.breakSave = true;
            this.template.querySelector('.credAtt').classList.add('slds-has-error');            
        }
        else{
            if(this.template.querySelector('.credAtt') !== null){
                this.credAttError = false;
                this.template.querySelector('.credAtt').classList.remove('slds-has-error');
            }            
        }
        if(!this.selectedEntityId){
            this.selectedEntErr = true;
            this.breakSave = true;
            this.template.querySelector('.entityRecord').classList.add('slds-has-error');
        }
        else{
            this.selectedEntErr = false;
            this.template.querySelector('.entityRecord').classList.remove('slds-has-error');
        }
        if(!this.nameOnDoc && this.template.querySelector('.nameOnDoc') !== null){
            this.nameOnDocErr = true;
            this.breakSave = true;
            this.template.querySelector('.nameOnDoc').classList.add('slds-has-error');  
        }
        else{
            this.nameOnDocErr = false;
            if(this.template.querySelector('.nameOnDoc') !== null){
                this.template.querySelector('.nameOnDoc').classList.remove('slds-has-error');
            }            
        }    
        if(inputFields && inputFields.length !== 0){
            let tempVal = [];
            let tempValFields = [];        
            let valDateCheck = {} 
            inputFields.forEach(field => {
                if(field.value){   
                    field.classList.remove('slds-has-error');
                    field.isReq = false; 
                    field.errMSg = '';
                    if(field.fieldName === 'Degree_Issue_Date__c'){
                        valDateCheck.degIssueDt = field.value;
                    }
                    if(field.fieldName === 'Graduation_Year__c'){
                        valDateCheck.gradYrDt = field.value;
                    }
                    if(field.fieldName === 'Degree_expected_to_be_issued_Year__c'){
                        valDateCheck.degExpYrDt = field.value;
                    }
                    if(field.fieldName === 'Attendance_Start_Date__c'){
                        valDateCheck.attStDt = field.value;
                    }
                    if(field.fieldName === 'Attendance_End_Date__c'){
                        valDateCheck.attEndDt = field.value;
                    }
                    if(field.fieldName === 'Program_Start_Date__c'){
                        valDateCheck.prStDt = field.value;
                    }
                    if(field.fieldName === 'Program_End_Date__c'){
                        valDateCheck.prEndDt = field.value;
                    }                
                    if(field.fieldName === 'Issue_Date__c'){
                        valDateCheck.issDt = field.value;
                    }
                    if(field.fieldName === 'Expiration_Date__c'){
                        valDateCheck.expDt = field.value;
                    }
                    if(field.value && field.fieldName == 'DOB_on_Document__c'){
                        var today = new Date();
                        var dob = new Date(field.value);
                        if(dob>today){
                            this.breakSave = true;
                            this.dobErr = true;
                            this.template.querySelector('.dob').classList.add('slds-has-error');
                        }
                    }  
                }else{
                    if(field.fieldName !== 'DOB_on_Document__c' && !(field.fieldName == 'Expiration_Date__c' && this.chosenAttrValue == 'Certificate of Good Standing')){
                        field.classList.add('slds-has-error');
                        field.isReq = true;
                        this.breakSave = true;
                        field.errMSg = 'Please enter the value';
                    }
                    else{
                        field.isReq = false;
                    }    
                }                  
                tempVal.push({key:field.fieldName, isReq:field.isReq, errMSg:field.errMSg});
            }); 
            this.listOfFieldsError = [];            
            this.listOfFieldsError= tempVal;            
            tempValFields = this.listOfFields;
            this.listOfFields = [];            
            for(const k in tempValFields){                
                if(tempValFields.hasOwnProperty(k)){
                    let ele = tempValFields[k];                    
                    for(const assKey in this.listOfFieldsError){
                        if(this.listOfFieldsError.hasOwnProperty(assKey)){                            
                            let errorEle = this.listOfFieldsError[assKey];                              
                            if(errorEle.key === ele.key){
                                if(ele.key == 'Expiration_Date__c' && this.chosenAttrValue == 'Certificate of Good Standing'){
                                    this.listOfFields.push({value:ele.value, key:ele.key, isReq:errorEle.isReq, errMSg:errorEle.errMSg, required:false}); 
                                }else{
                                    this.listOfFields.push({value:ele.value, key:ele.key, isReq:errorEle.isReq, errMSg:errorEle.errMSg, required:true}); 
                                } 
                            }
                        }           
                    }
                }
            }
            this.spinner = false;
            this.dateVals = JSON.stringify(valDateCheck);
            this.checkDateFields();
        }
    }
    checkDateFields(){
        const inputFields = this.template.querySelectorAll('lightning-input-field');
        dtChecker({
            dtValues: this.dateVals})
            .then(result=>{
                this.spinner = true;
                if(result){
                    this.listOfFieldsDateCheck = [];
                    for(let key in result){                    
                        if(result.hasOwnProperty(key)){
                            this.listOfFieldsDateCheck.push({value:result[key], key:key});                                                       
                        }
                    }
                    let tempDateCheckFld = [];
                    inputFields.forEach(field=>{
                        field.isReq = false;
                        field.dtErrormsg = '';
                        for(const k in this.listOfFieldsDateCheck){
                            if(this.listOfFieldsDateCheck.hasOwnProperty(k)){
                                let eleDtErr = this.listOfFieldsDateCheck[k];
                                if(eleDtErr.key === field.fieldName){
                                    this.breakSave = true;	
                                    field.isReq = true;	
                                    field.dtErrormsg = eleDtErr.value;				
                                    field.classList.add('slds-has-error');                                                		
                                }
                            }
                        }
                        tempDateCheckFld.push({isReq:field.isReq, key:field.fieldName, value:field.dtErrormsg});  
                    });
                    let tempDt = [];
                    tempDt = this.listOfFields;
                    this.listOfFields = []; 
                    for(const fld in tempDateCheckFld){
                        if(tempDateCheckFld.hasOwnProperty(fld)){
                            let eleDt = tempDateCheckFld[fld];                                 
                                for(const key in tempDt){
                                    if(tempDt.hasOwnProperty(key)){                            
                                        let errorEle = tempDt[key];    
                                        if(errorEle.key === eleDt.key){
                                            if(eleDt.isReq){
                                                if(errorEle.key == 'Expiration_Date__c' && this.chosenAttrValue == 'Certificate of Good Standing'){
                                                    this.listOfFields.push({value:errorEle.value, key:errorEle.key, isReq:eleDt.isReq, errMSg:eleDt.value, fieldValue:errorEle.fieldValue, required:false});
                                                }else{
                                                    this.listOfFields.push({value:errorEle.value, key:errorEle.key, isReq:eleDt.isReq, errMSg:eleDt.value, fieldValue:errorEle.fieldValue, required:true});
                                                }
                                            }
                                            else{
                                                if(errorEle.key == 'Expiration_Date__c' && this.chosenAttrValue == 'Certificate of Good Standing'){
                                                    this.listOfFields.push({value:errorEle.value, key:errorEle.key, isReq:errorEle.isReq, errMSg:errorEle.errMSg, fieldValue:errorEle.fieldValue, required:false});
                                                }else{
                                                    this.listOfFields.push({value:errorEle.value, key:errorEle.key, isReq:errorEle.isReq, errMSg:errorEle.errMSg, fieldValue:errorEle.fieldValue, required:true});
                                                }
                                            } 
                                            this.spinner = false;                                                
                                        }
                                    }                                        		
                                }
                            }
                        }
                    if(!this.breakSave){
                        this.getCATfieldVals();
                    }                       
                }  
        }).catch(error =>{
            this.spinner = false;
        });
    }
    getCATfieldVals(){
        this.spinner = true;
        this.catRecValues = ''; 
        this.catRecId = null;
        const inputFields = this.template.querySelectorAll('lightning-input-field');  
        let catRecord = {Id:this.catRecId};        
        if(inputFields && inputFields.length !== 0){
            catRecord.Degree_Issue_Date__c = null;
            catRecord.Degree_Title__c ='';
            catRecord.Graduation_Year__c = '';
            catRecord.Degree_expected_to_be_issued_Year__c = '';
            catRecord.Degree_expected_to_be_issued_Month__c = '';
            catRecord.Attendance_Start_Date__c = null;
            catRecord.Attendance_End_Date__c = null;
            catRecord.Program_Start_Date__c = null;
            catRecord.Program_End_Date__c = null;
            catRecord.Title__c = '';
            catRecord.Issue_Date__c = null;
            catRecord.Expiration_Date__c = null;
            catRecord.DOB_on_Document__c = null;
            inputFields.forEach(field=>{
                if(field.fieldName === 'Degree_Issue_Date__c'){
                    catRecord.Degree_Issue_Date__c = field.value;
                }
                if(field.fieldName === 'Degree_Title__c'){
                    catRecord.Degree_Title__c = field.value;
                }
                if(field.fieldName === 'Graduation_Year__c'){
                    catRecord.Graduation_Year__c = field.value;
                }
                if(field.fieldName === 'Degree_expected_to_be_issued_Year__c'){
                    catRecord.Degree_expected_to_be_issued_Year__c = field.value;
                }
                if(field.fieldName === 'Degree_expected_to_be_issued_Month__c'){
                    catRecord.Degree_expected_to_be_issued_Month__c = field.value;
                }
                if(field.fieldName === 'Attendance_Start_Date__c'){
                    catRecord.Attendance_Start_Date__c = field.value;
                }
                if(field.fieldName === 'Attendance_End_Date__c'){
                    catRecord.Attendance_End_Date__c = field.value;
                }
                if(field.fieldName === 'Program_Start_Date__c'){
                    catRecord.Program_Start_Date__c = field.value;
                }
                if(field.fieldName === 'Program_End_Date__c'){
                    catRecord.Program_End_Date__c = field.value;
                }
                if(field.fieldName === 'Title__c'){
                    catRecord.Title__c = field.value;
                }
                if(field.fieldName === 'Issue_Date__c'){
                    catRecord.Issue_Date__c = field.value;
                }
                if(field.fieldName === 'Expiration_Date__c'){
                    catRecord.Expiration_Date__c = field.value;
                } 
                if(field.fieldName === 'DOB_on_Document__c'){
                    catRecord.DOB_on_Document__c = field.value;
                } 
            });
        }
        catRecord.Credential_Type__c = this.chosenAttrValue;
        catRecord.account__c = this.selectedEntityId;  
        catRecord.Case__c = this.recordId;
        this.catRecValues = JSON.stringify(catRecord);
        this.createCatrec();
    }
    createCatrec(){
        createCATRec({
            fieldvals:this.catRecValues, caseId:this.recordId, nameOnDoc:this.nameOnDoc
        }).then(result=>{
            this.savedCat = result;
            updateExtSubCase({
                caseId:this.recordId, entityId:this.selectedEntityId, verform:this.verFormNotAvail
            }).then(result=>{
                console.log('createCatrec Result from update extsubcase '+result);
                this.updExtCase = result;
                if(this.updExtCase){
                    this.spinner = false;
                    window.location.reload();
                }
            }).catch(error=>{
                window.console.error('Error: ', error);
            })

        }).catch(error=>{
            window.console.error('Error: ', error);
        })
    }
}