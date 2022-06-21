import {LightningElement,track,api,wire} from 'lwc';
import getEpicCaseList from "@salesforce/apex/EPICVerRepController.getEpicCaseList";
import searchRegOrg from "@salesforce/apex/EPICVerRepController.searchRegOrg";
import saveRecord from "@salesforce/apex/EPICVerRepController.saveRecord";
import fatchPickListValue from "@salesforce/apex/TranscriptRequestController.fatchPickListValue";
import {ShowToastEvent} from "lightning/platformShowToastEvent";
export default class EpicVerReportDetails extends LightningElement{
    @track epicVerList = [];    
    @track chosenValue;
    @track showAuthEntitySearch = false;
    @track authRecordsList = [];
    @track authRecords = [];
    @track selectedAuthorityName= '';
    @api searchfield = 'Name';
    @api iconname = "standard:account";
    @track modalTitle = 'Add New Entity';
    @track backTitle = 'Attention!'
    @track modalContent = '';
    @track selectedAuthRec;
    @track selectedAuthEntityId;  
    @track showAddEntity = false;  
    @track selectedAuthRecord =  false;  
    @track showDelEntity = false;
    @track referenceNumber = '';
    @track showNewAuthCreation = false;
    @track emailAddress;
    @track verifyEmailAddress;
    @track contactPersonName;
    @track nameOfEntity;
    @track entityAddress;
    @track referenceNum;
    @track ItemsCountry=[];
    @track formProceed = true;
    @track spinner = false;
    @track chosenValErr = false;
    @track epicVerErr = false;
    @track cvAccptedErr = false;
    @track showAll = true;
    @track emailAddressErr = false;
    @track verifyEmailAddressErr = false;
    @track contactPersonNameErr = false;
    @track nameOfEntityErr = false;
    @track entityAddressErr = false;
    @track referenceNumErr = false;
    @track countryErr = false;
    @track emailAddressVerifyErr = false;
    @track assetIdToShow = '';
    @track docType = '';
    @track data = [];
    alreadyInprocess = false;
    inProgressCase = '';
    @wire(fatchPickListValue,{objInfo: {'sobjectType': 'Case'}, picklistFieldApi: 'EPIC_Report_Entity_Country__c'})
    countryValues(result){
        let dataList = [];
        this.ItemsCountry = [];
        if(result.data !== undefined){
            let tempVal = [];
            dataList = result.data;
            for(let i = 0; i < dataList.length; i++){  
                let tempTcRecord = {value: dataList[i].svalue , label: dataList[i].slabel}               
                tempVal.push(tempTcRecord);
                }            
            this.ItemsCountry = tempVal;             
        }
}
    connectedCallback(){
        this.formProceed = true;
        this.loadFields();             
    }
    loadFields(){ 
        this.spinner = true;   
        this.initialize();             
        getEpicCaseList()
            .then(
            result=>{                
                this.epicVerList = [];  
                this.data = [];
                if(result){
                    if(result.length > 0){
                        this.showAll = true
                        this.spinner = false;
                        for(let key in result){                                                 
                            if(result.hasOwnProperty(key)){ // Filtering the data in the loop                                                          
                                let tempRecord = {key:result[key].key,casNum:result[key].casNum,docType:result[key].docType,selected:result[key].selected,status:result[key].status,recType:result[key].recType,asst:result[key].asst,asstExist:result[key].asstExist,type:result[key].type};                                 
                                if(this.data.length > 0){
                                    this.data = [...this.data, tempRecord];
                                }else{
                                    this.data = [tempRecord];
                                }
                                if(result[key].selected === true){
                                if(result[key].reportType === 'Self'){
                                    this.chosenValue = 'Applicants receive a report for themselves';
                                }else if(result[key].reportType === 'Volume Entity'){
                                    this.chosenValue = 'Applicant can search for an Entity which will receive the report';
                                    this.selectedAuthEntityId = result[key].selectedAuthEntityId;
                                    this.referenceNumber = result[key].referenceNumber;                                  
                                    this.selectedAuthRecord = true;
                                    let selectedRec ={
                                        Id:this.selectedAuthEntityId,
                                        Name : result[key].billName,
                                        BillingStreet:result[key].billStreet,
                                        BillingCity:result[key].billCity,
                                        BillingState:result[key].billState,
                                        BillingCountry:result[key].billCountry,
                                        BillingPostalCode:result[key].billPostal
                                    };                                                                       
                                    this.selectedAuthRec = selectedRec;
                                    this.selectedAuthorityName = this.selectedAuthRec.Name;                                                                                                           
                                }else if(result[key].reportType === 'Other Entity'){
                                    this.showNewAuthCreation = true;
                                    this.chosenValue = 'Applicant select option to send to report to an Entity that is not found in search';                                      
                                    this.emailAddress = result[key].emailAddress;
                                    this.verifyEmailAddress =result[key].verifyEmailAddress;
                                    this.contactPersonName = result[key].contactPersonName;
                                    this.nameOfEntity = result[key].nameOfEntity;
                                    this.entityAddress = result[key].entityAddress;
                                    this.referenceNum = result[key].referenceNum;
                                    this.country = result[key].country;
                                }   
                            }                           
                            }
                        }
                        this.epicVerList = this.data;                                                                    
                    }
                    else{
                        this.showAll = false;
                        this.spinner = false;
                    }
                }                
           })           
    }
        isRend = true;
    renderedCallback(){        
        if(this.isRend){
            this.formProceed = true;
            this.loadFields(); 
            this.isRend = false; 
        }
    }
    initialize(){                
        this.selectedEntErr = false;
        this.showAuthEntitySearch = false;
        this.showNewAuthCreation = false;
        this.authRecordsList = [];
        this.referenceNumber = '';
        this.selectedAuthRecord = false;       
        this.showDelEntity = false;
        this.showAddEntity = false;
        this.selectedAuthEntityId = '';
        this.selectedAuthorityName = '';         
        this.emailAddress = '';
        this.verifyEmailAddress ='';
        this.contactPersonName = '';
        this.nameOfEntity = '';
        this.entityAddress = '';
        this.referenceNum = '';
        this.country = '';     
        this.chosenValErr = false;
        this.epicVerErr = false;
        this.cvAccptedErr = false;  
        this.emailAddressErr = false;
		this.verifyEmailAddressErr = false;
		this.contactPersonNameErr = false;
		this.nameOfEntityErr = false;
		this.entityAddressErr = false;
		this.referenceNumErr = false;
		this.countryErr = false;
		this.emailAddressVerifyErr = false;
        this.alreadyInprocess = false;
        this.inProgressCase = '';
    }
    onCheckedRow(event){      
        this.initialize();
        this.chosenValue = '';
        let idx = event.currentTarget.dataset.selectedRep;             
        for (const key in this.epicVerList){               
            if (this.epicVerList.hasOwnProperty(key)){
                let ele = this.epicVerList[key];
                if (ele.key === idx){                        
                    this.epicVerList[key].selected = event.target.checked;
                }
            }
        } 
    } 
    viewSource(event){
        this.assetIdToShow = '';
        this.docType = '';
        let idx = event.currentTarget.dataset.selectedAsst;
        let doc = event.currentTarget.dataset.selectedAsstDoc;             
        this.assetIdToShow = idx;
        this.docType = doc;
        let tempPayload = {
            contactId: null,
            caseId: null,
            catsId: null,
            documentType: null,
            assetRecordType: null,
            createOrReplace: null,
            assetStatus: null,
            assetCreationRequired: null,
            assetId: null
        };
        tempPayload.assetId = idx;
        tempPayload.documentType = doc;
        this.assetIdToShow = JSON.stringify(tempPayload);
        this.template.querySelector('.addAuthScreenModalAsset').show();        
    }
    get Items(){
        return[
        { label: 'Send Report to Myself', value: 'Applicants receive a report for themselves' },
         { label: 'Send Report to EPIC Partner Organization', value: 'Applicant can search for an Entity which will receive the report' },
        { label: 'Send Report to One Time Report Recipient', value: 'Applicant select option to send to report to an Entity that is not found in search' },
         ];
    }        
    preventBackslash(event){
        if(event.which === 8 || event.which === 46){
            event.preventDefault();
        }
    }
    handleChangeRadio(event){
       this.chosenValue = event.detail.value;
       this.initialize();      
       if(this.chosenValue === 'Applicant can search for an Entity which will receive the report'){
           this.showAuthEntitySearch = true;
       }
       else if(this.chosenValue === 'Applicant select option to send to report to an Entity that is not found in search'){
           this.showNewAuthCreation = true;
       }
    }
    handleChangeForAuthSearch(event){
        const searchKey = event.detail.value;        
        this.authRecordsList = [];
        this.authRecords = [];        
        searchRegOrg({
            searchKey:searchKey,
            epicList:JSON.stringify(this.epicVerList)
        }).then(result =>{
            this.authRecords = result;
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
                if(rec !== undefined && dupCheck === false){
                    this.authRecordsList.push(rec);
                    this.authRecordsList[i].Name = rec[this.searchfield];
                    this.authRecordsList[i].Id = rec['Id'];
                }
            }
        }).catch(error =>{
            this.authRecordsList = undefined;
        });
        if(!searchKey){
            this.authRecordsList = [];
        }
    }
    handleAuthSelect(event){
        this.selectedAuthRec = event.detail;
        this.selectedAuthEntityId = this.selectedAuthRec.Id;
        this.selectedAuthorityName = this.selectedAuthRec.Name;
        this.showAddEntity = true;        
        this.template.querySelector('.addAuthScreenModal').show();
    }
    requestRep(event){
        this.formProceed = true;
        this.spinner = true;
        this.chosenValErr = false;
        this.epicVerErr = false;
        this.cvAccptedErr = false;
        this.emailAddressErr = false;
		this.verifyEmailAddressErr = false;
		this.contactPersonNameErr = false;
		this.nameOfEntityErr = false;
		this.entityAddressErr = false;
		this.referenceNumErr = false;
		this.countryErr = false;
		this.emailAddressVerifyErr = false;
        if(!this.chosenValue){
            this.formProceed = false;
            this.chosenValErr = true;
        }
        let checkEpicSelection = false;
        for (const key in this.epicVerList){               
            if (this.epicVerList.hasOwnProperty(key)){
                if(this.epicVerList[key].selected){
                    checkEpicSelection = true;
                }
            }
        }        
        if(!checkEpicSelection){            
            this.formProceed = false;
            this.epicVerErr = true;
        }
        if(this.chosenValue && this.chosenValue === 'Applicant can search for an Entity which will receive the report' && !this.selectedAuthEntityId){
            this.selectedEntErr = true;
            this.formProceed = false;
        }
        if(this.chosenValue && (this.chosenValue === 'Applicants receive a report for themselves' ||
            this.chosenValue === 'Applicant select option to send to report to an Entity that is not found in search')){                        
            for (const key in this.epicVerList){                            
                if (this.epicVerList.hasOwnProperty(key)){                                           
                    if(this.epicVerList[key].selected && this.epicVerList[key].status != 'CV Accepted' && this.epicVerList[key].recType === 'Credential_Verification'){                        
                        this.formProceed = false;
                        this.cvAccptedErr = true;                         
                    }
                    else if(this.epicVerList[key].selected && this.epicVerList[key].status != 'Accepted' && this.epicVerList[key].recType === 'Extraction_Sub_case'){                        
                        this.formProceed = false;
                        this.cvAccptedErr = true;                         
                    }                                     
                }
            }            
        }                   
        if(this.chosenValue && this.chosenValue === 'Applicant select option to send to report to an Entity that is not found in search'){        
            if(!this.emailAddress && this.template.querySelector('.emailAddress') !== null){
                this.formProceed = false;
                this.emailAddressErr = true;
                this.template.querySelector('.emailAddress').classList.add('slds-has-error'); 
            }
            else{
                this.emailAddressErr = false;
                if(this.template.querySelector('.emailAddress') !== null){
                    this.template.querySelector('.emailAddress').classList.remove('slds-has-error');
                } 
            }
            if(!this.verifyEmailAddress && this.template.querySelector('.verifyEmailAddress') !== null){
                this.formProceed = false;
                this.verifyEmailAddressErr = true;
                this.template.querySelector('.verifyEmailAddress').classList.add('slds-has-error');
            }
            else{
                this.verifyEmailAddressErr = false;
                if(this.template.querySelector('.verifyEmailAddress') !== null){
                    this.template.querySelector('.verifyEmailAddress').classList.remove('slds-has-error');
                } 
            }
            if(!this.contactPersonName && this.template.querySelector('.contactPersonName') !== null){
                this.formProceed = false;
                this.contactPersonNameErr = true;
                this.template.querySelector('.contactPersonName').classList.add('slds-has-error');
            }
            else{
                this.contactPersonNameErr = false;
                if(this.template.querySelector('.contactPersonName') !== null){
                    this.template.querySelector('.contactPersonName').classList.remove('slds-has-error');
                } 
            }
            if(!this.nameOfEntity && this.template.querySelector('.nameOfEntity') !== null){
                this.formProceed = false;
                this.nameOfEntityErr = true;
                this.template.querySelector('.nameOfEntity').classList.add('slds-has-error');
            }
            else{
                this.nameOfEntityErr = false;
                if(this.template.querySelector('.nameOfEntity') !== null){
                    this.template.querySelector('.nameOfEntity').classList.remove('slds-has-error');
                } 
            }
            if(!this.entityAddress && this.template.querySelector('.entityAddress') !== null){
                this.formProceed = false;
                this.entityAddressErr = true;
                this.template.querySelector('.entityAddress').classList.add('slds-has-error');
            }
            else{
                this.entityAddressErr = false;
                if(this.template.querySelector('.entityAddress') !== null){
                    this.template.querySelector('.entityAddress').classList.remove('slds-has-error');
                } 
            }            
            if(!this.country && this.template.querySelector('.country') !== null){
                this.formProceed = false;
                this.countryErr = true;
                this.template.querySelector('.country').classList.add('slds-has-error');
            }
            else{
                this.countryErr = false;
                if(this.template.querySelector('.country') !== null){
                    this.template.querySelector('.country').classList.remove('slds-has-error');
                } 
            }
            if(this.emailAddress && this.verifyEmailAddress){
                if(this.verifyEmailAddress !== this.emailAddress && this.template.querySelector('.emailAddress') !== null && this.template.querySelector('.verifyEmailAddress') !== null){
                    this.formProceed = false;
                    this.emailAddressVerifyErr = true;
                    this.template.querySelector('.emailAddress').classList.add('slds-has-error');
                }
                else{
                    this.emailAddressVerifyErr = false;
                        if(this.template.querySelector('.emailAddress') !== null){
                        this.template.querySelector('.emailAddress').classList.remove('slds-has-error');
                    }
                } 
            }
        }         
        if(this.formProceed){
            this.alreadyInprocess = false;
            this.inProgressCase = '';
            let fieldvals = {};
            fieldvals.referenceNumber = this.referenceNumber;
            fieldvals.emailAddress = this.emailAddress;
            fieldvals.verifyEmailAddress = this.verifyEmailAddress;
            fieldvals.contactPersonName = this.contactPersonName;
            fieldvals.nameOfEntity = this.nameOfEntity;
            fieldvals.entityAddress = this.entityAddress;
            fieldvals.referenceNum = this.referenceNum;
            fieldvals.country = this.country;
            fieldvals.selectedAuthEntityId = this.selectedAuthEntityId;
            saveRecord({
                action:this.chosenValue,
                epicList:JSON.stringify(this.epicVerList),
                epicVerFields:JSON.stringify(fieldvals)
            }).then(result =>{
                event.preventDefault();                
                if(result){                    
                    let det = result;
                    if(det.epicCase){                  
                    const selectEvent = new CustomEvent('nextevent', {detail: det.existingcase});
                    this.dispatchEvent(selectEvent);
                    this.spinner = false;
                    }
                    else{
                        this.inProgressCase = det.existingcase;
                        this.alreadyInprocess = true;
                        this.spinner = false;
                    }
                }
            }).catch(error =>{
                this.spinner = false;
                window.console.error(error);
            });
        }
        else{
            this.spinner = false;
        }
    }
    backToRep(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('backevent', {});
        this.dispatchEvent(selectEvent);
    }
    handleAuthYesClick(){
        this.showAuthEntitySearch = false;
        this.showAddEntity = false;
        this.selectedAuthRecord = true;
        if(this.selectedAuthRec.Parent_Authority__c != null && this.selectedAuthRec.Parent_Authority__r.Use_same_instruction_for_child_entities__c == true){
            this.specialIntruction = this.selectedAuthRec.Parent_Authority__r.EPIC_Client_Special_Instructions_Languag__c;
        }else{
            this.specialIntruction = this.selectedAuthRec.EPIC_Client_Special_Instructions_Languag__c;
        }
        const successevt = new ShowToastEvent({
            title: "Success",
            message: 'Entity has been added',
            variant: "Success"
            });
        this.dispatchEvent(successevt);
    }
    handleDeleteAuthOnClick(){
        this.showDelEntity = true;
        this.selectedEntErr = false;
        this.template.querySelector('.removeAuthScreenModal').title = 'Remove this entity?';
        this.template.querySelector('.removeAuthScreenModal').show();
    }
    handleChangeForReferenceNumber(event){
        this.referenceNumber = event.target.value;
    }
    handleChangeText(event){        
        if(event.target.name === 'emailAddress'){
            this.emailAddress = event.target.value;
        }  
        if(event.target.name === 'verifyEmailAddress'){
            this.verifyEmailAddress = event.target.value;
        }  
        if(event.target.name === 'contactPersonName'){
            this.contactPersonName = event.target.value;
        }  
        if(event.target.name === 'nameOfEntity'){
            this.nameOfEntity = event.target.value;
        }  
        if(event.target.name === 'entityAddress'){
            this.entityAddress = event.target.value;
        }    
        if(event.target.name === 'referenceNum'){
            this.referenceNum = event.target.value;
        }    
    }
    handleChangeCountry(event){
        this.country = event.detail.value;
    }    
    handleYesAuthDeleteClick(){
        this.authRecordsList = [];
        this.referenceNumber = '';
        this.selectedAuthRecord = false;
        this.showAuthEntitySearch = true;
        this.showNewAuthCreation = false;
        this.showDelEntity = false;
        this.showAddEntity = false;
        this.selectedAuthEntityId = '';
        this.selectedAuthorityName = '';        
        const successevt = new ShowToastEvent({
                                title: "Success",
                                message: 'Entity has been removed',
                                variant: "Success"
                                });
        this.dispatchEvent(successevt);
    }
}