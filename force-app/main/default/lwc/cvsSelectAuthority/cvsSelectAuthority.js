import {LightningElement, api, track, wire} from 'lwc';
import fatchPickListValue from '@salesforce/apex/TranscriptRequestController.fatchPickListValue';
import getGeoData from "@salesforce/apex/ApplicantCommunityController.getGeoData";
import searchAuthorityOnCountry from "@salesforce/apex/CVSRequestController.searchAuthorityOnCountry";
import getUnpaidCvs from "@salesforce/apex/CVSRequestController.getUnpaidCVS";
import checkModeOfComm from "@salesforce/apex/CVSRequestController.checkModeOfComm";
import createCvsCase from "@salesforce/apex/CVSRequestController.createCvsCase";
import getCaseDetails from "@salesforce/apex/EntityReviewController.getCaseDetails";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class cvsSelectAuthority extends LightningElement{
    @track showAuthSelectionScreen;
    @track countryName = '';
    @track streetName;
    @track cityName;
    @track postalCode;
    @track stateName = '';
    @track countryOptions;
    @track stateOptions;
    @track enableState = false;
    @track enableNext = false;
    @track authoritySelected = false;
    @track showDefaultChecked = false;
    @track showDefaultUnChecked = false;
    @track showDefaultEditable = false;
    @track hideDeleteButton = false;
    @track selectedAuthorityName= '';
    @track selectedAuthEntityId = '';
    @track selectedAuthEntOldValId;
    @track authRecordsList = [];
    @track authRecords = [];
    @track modeOfComm;
    @track spinner = false;
    @api caseId;
    @track attentionToValue;
    @track sendPaperCopy = false;
    @track showCvsNewRequestScreen = false;
    @api searchfield = 'Name';
    @track selectedRecord = false;
    @track selectedAuthRecord;
    @track showAuthEntitySearch = true;
    @track hasRestriction = false;
    @track modalTitle = 'Add New Entity';
    @track modalContent = '';
    @api user;
    @track selectedAuthRec = [{
        Name: null,
        BillingStreet: null,
        BillingCity: null,
        BillingState: null,
        BillingCountry: null,
        BillingPostalCode: null
    }];
    @track selectedRec;
    @track showSearchAuthority = true;
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
        if(this.caseId !== null && this.caseId !== undefined){
            this.showAuthSelectionScreen = true;
            getGeoData()
            .then(result =>{
                if(result){
                    this.countryAndStateMap = result;
                    this.getStateOptions();
                }    
            })
            getCaseDetails({caseId: this.caseId}).then(caseRec=>{
                this.countryName = caseRec.Alternate_Entity__r.BillingCountryCode;
                this.stateName = caseRec.Alternate_Entity__r.BillingStateCode;
                this.enableState = true;
                this.selectedAuthEntityId = caseRec.Alternate_Entity__c;
                this.selectedAuthEntOldValId = caseRec.Alternate_Entity__c;
                this.selectedAuthorityName = caseRec.Alternate_Entity__r.Name;
                this.attentionToValue = caseRec.Attention_To__c;
                this.selectedAuthRec.Name = caseRec.Alternate_Entity__r.Name;
                this.selectedAuthRec.BillingCountry = caseRec.Alternate_Entity__r.BillingCountry;
                this.selectedAuthRec.BillingState = caseRec.Alternate_Entity__r.BillingState;
                this.selectedAuthRec.BillingStreet = caseRec.Alternate_Entity__r.BillingStreet;
                this.selectedAuthRec.BillingCity = caseRec.Alternate_Entity__r.BillingCity;
                this.selectedAuthRec.BillingPostalCode = caseRec.Alternate_Entity__r.BillingPostalCode;
                this.showSearchAuthority = false;
                this.selectedAuthRecord = true;
                this.getModeOfComm(false);
                this.enableNext = true;
            });
        }else{
            this.countryName = 'US';
            this.showAuthSelectionScreen = true;
            getGeoData()
            .then(result =>{
                if(result){
                    this.countryAndStateMap = result;
                    this.getStateOptions();
                }    
            })
        }
    }
    handleChangeCountryValue(event){
        this.countryName = event.detail.value;
        this.getStateOptions();
        this.selectedAuthRecord = null;
        this.selectedAuthorityName = '';
        this.selectedAuthRecord = false;
        this.showDefaultChecked = false; 
        this.showDefaultUnChecked = false; 
        this.showDefaultEditable = false;
        this.enableNext = false;
        this.hasRestriction = false;
        if(this.stateOptions.length < 1){
            this.enableState = false;
            this.stateName = null;
            this.getAuthoritySearchResult();
        }
    }
    getStateOptions(){
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
    handleChangeForAuthSearch(event){
        const searchKey = event.detail.value;
        const searchKeyLower = searchKey.toLowerCase();
        this.authRecordsList = [];
        for(let i=0; i < this.authRecords.length; i++){
            let rec = this.authRecords[i];
            let dupCheck = false;
            //iteration to avoid duplicate list.
            for(let keyNew in this.authRecordsList){
                if(this.authRecordsList[keyNew].Id === rec['Id']){
                    dupCheck = true;
                    break;
                }
            }
            const nameLower = rec.Name.toLowerCase();
            if(rec !== undefined && dupCheck === false && nameLower.includes(searchKeyLower)){
                this.authRecordsList.push(rec);
                this.authRecordsList[i].Name = rec[this.searchfield];
                this.authRecordsList[i].Id = rec['Id'];
            }
        }
        if(this.authRecordsList.length === 0){
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Search cannot find valid match',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
        if(!searchKey){
            this.authRecordsList = [];
        }
    }
    onStateNameChange(event){
        this.stateName = event.detail.value;
        this.selectedAuthRecord = false;
        this.selectedAuthorityName = '';
        this.selectedAuthRecord = false;
        this.showDefaultChecked = false; 
        this.showDefaultUnChecked = false; 
        this.showDefaultEditable = false;
        this.enableNext = false;
        this.hasRestriction = false;
        this.getAuthoritySearchResult();
    }
    getAuthoritySearchResult(){
        if(this.countryName){
            searchAuthorityOnCountry({
                bCountry: this.countryName,
                bState: this.stateName
            }).then(result =>{
                this.authRecords = result;
                this.selectedAuthRec = [{
                    Name: null,
                    BillingStreet: null,
                    BillingCity: null,
                    BillingState: null,
                    BillingCountry: null,
                    BillingPostalCode: null
                }];
                this.authRecordsList = [];
                this.hideDeleteButton = false;
                if(this.authRecords.length === 1){
                    this.hideDeleteButton = true;
                    console.log('this.hideDeleteButton:',this.hideDeleteButton);
                    this.showSearchAuthority = false;
                    this.selectedAuthRecord = true;
                    this.selectedAuthRec.Name = this.authRecords[0].Name;
                    this.selectedAuthRec.BillingStreet = this.authRecords[0].BillingStreet;
                    this.selectedAuthRec.BillingCity = this.authRecords[0].BillingCity;
                    this.selectedAuthRec.BillingState = this.authRecords[0].BillingState;
                    this.selectedAuthRec.BillingCountry = this.authRecords[0].BillingCountry;
                    this.selectedAuthRec.BillingPostalCode = this.authRecords[0].BillingPostalCode;
                    this.selectedAuthEntityId = this.authRecords[0].Id;
                    this.enableNext = true;
                    this.getModeOfComm(false);
                }
                else{
                    this.showSearchAuthority = true;
                }
            }).catch(error =>{
                this.authRecordsList = undefined;
            });
        }
    }
    handleAuthSelect(event){
        this.authoritySelected = true;
        this.showSearchAuthority = false;
        this.selectedAuthRec = event.detail;
        this.selectedRec = event.detail;
        this.selectedAuthEntityId = this.selectedAuthRec.Id;
        this.selectedAuthorityName = this.selectedAuthRec.Name;
        this.streetName = this.selectedAuthRec.BillingStreet;
        this.cityName = this.selectedAuthRec.BillingCity;
        this.postalCode = this.selectedAuthRec.BillingPostalCode;
        this._stylePresent = false; 
        this.getModeOfComm(true);
    }
    getModeOfComm(showModal){
        checkModeOfComm({
            authId:this.selectedAuthEntityId
        }).then(result =>{
            this.modeOfComm = result;
            if(this.modeOfComm === 'Paper and Entity Portal'){
                this.showDefaultChecked = true;
                this.showDefaultEditable = true;
                this.sendPaperCopy = true; 
            }else{
                this.sendPaperCopy = false;
                if(this.user === 'Applicant'){
                    this.showDefaultUnChecked = true;
                    this.showDefaultEditable = true;
                }else{
                    this.showDefaultEditable = false;
                }
            }
            if(showModal){
                this.template.querySelector('.addAuthScreenModal').show();
            }
        }).catch(error =>{
            this.showDefaultChecked = undefined;
        });
    }
    handleAuthYesClick(){
        this.showAuthEntitySearch = false;
        this.selectedAuthRecord = true;
        this.enableNext = true;
        this.breakSave = false;
        const successevt = new ShowToastEvent({
                                title: "Success",
                                message: 'Entity has been added',
                                variant: "Success"
                                });
        this.dispatchEvent(successevt);
    }
    handleAuthCancelClick(){
        this.showSearchAuthority = true;
    }
    handleDeleteOnClick(event){
        this.showSearchAuthority = true;
        this.selectedAuthRecord = null;
        this.selectedAuthorityName = '';
        this.selectedAuthRecord = false;
        this.showDefaultChecked = false; 
        this.showDefaultUnChecked = false; 
        this.showDefaultEditable = false;
        this.enableNext = false;
        this.hasRestriction = false;
        this.authRecordsList = [];
        this.getAuthoritySearchResult();
        this.template.querySelector('.removeScreenModal').title = 'Remove this entity?';
        this.template.querySelector('.removeScreenModal').show();
    }
    handleSendCopyChange(event){
        this.sendPaperCopy = event.detail.checked;  
    }
    onAttentionToChange(event){
        this.attentionToValue = event.detail.value;
    }
    handleClose(){
        this.showSearchAuthority = true;
        this.authRecordsList = [];
        this.selectedAuthRecord = false;
        this.showDefaultChecked = false; 
        this.showDefaultUnChecked = false; 
        this.showDefaultEditable = false;
        this.selectedAuthRec = [{
            Name: null,
            BillingStreet: null,
            BillingCity: null,
            BillingState: null,
            BillingCountry: null,
            BillingPostalCode: null
        }];
        this.countryName = 'US';
        this.stateName = null;
        this.selectedAuthorityName = '';
        this.sendPaperCopy = null;
        this.attentionToValue = null;
        this.enableNext = false;
        this.hasRestriction = false;
        this.getStateOptions();

        const selectEvent = new CustomEvent("cancelevent",{});
        this.dispatchEvent(selectEvent);
    } 
    handleNext(){
        this.spinner = true;
        let sendMethod;
        if(this.user === 'Applicant'){
            sendMethod = this.modeOfComm;
        }
        let cvsCaseDetails ={
            caseId : this.caseId,
            entityId : this.selectedAuthEntityId,
            requestor : this.user,
            sendMethod : sendMethod,
            attentionTo : this.attentionToValue
        }
        if(this.caseId !== null && this.caseId !== undefined && this.selectedAuthEntOldValId === this.selectedAuthEntityId){
            createCvsCase({
                inputJSON : JSON.stringify(cvsCaseDetails)
            }).then(res=>{
                if(res){
                    this.spinner = false;
                    const selectEvent = new CustomEvent("nextevent",{});
                    this.dispatchEvent(selectEvent);
                }       
            }).catch(error =>{
                window.console.error('Error: '+ JSON.stringify(error));
            });
        }else{
            getUnpaidCvs({
                entityId : this.selectedAuthEntityId
            }).then(result=>{
                if(result.length > 0){
                    this.spinner = false;
                    this.hasRestriction = true;
                }else{
                    createCvsCase({
                        inputJSON : JSON.stringify(cvsCaseDetails)
                    }).then(res=>{
                        if(res){
                            this.spinner = false;
                            const selectEvent = new CustomEvent("nextevent",{});
                            this.dispatchEvent(selectEvent);
                        }       
                    }) 
                } 
            })

        }
    }  
    handlePrevious(event){
        const selectEvent = new CustomEvent("prevevent",{});
        this.dispatchEvent(selectEvent);
        this.showCvsNewRequestScreen = true;
        this.showAuthSelectionScreen = false;
    }    
}