import {LightningElement, track, api, wire} from 'lwc';
import getCredProgDocTypeMap from '@salesforce/apex/EPICVerRepController.getCredProgDocTypeMap';
import getCredDocumentTypes from '@salesforce/apex/EPICVerRepController.getCredDocumentTypes';
import getEPICCaseList from '@salesforce/apex/EPICVerRepController.getEPICCaseList';
import getCredDocumentTypesCAT from '@salesforce/apex/EPICVerRepController.getCredDocumentTypesCAT';
import getExtractionSubCase from '@salesforce/apex/EPICVerRepController.getExtractionSubCase';
import getAllConstants from '@salesforce/apex/AppForCertController.getAllConstants';
export default class EpicVerReportSummary extends LightningElement{
        @api cas = [];
        @track spinner = false;
        @track listOfFields = [];
        @track credentialTypeList = [];
        @track catRecords = [];
        @track showAllRecords = [];
        @track mainDocCond = false;
        @track mainDocNameCond = false;
        @track mainDocTransCond = false;
        @track assetsList = [];
        @track requestedToSend;
        @track issuedIn90Days;
        @track showButtonsAndSummary = true;
        @api hideButtonsForCredVerCase;
        @api credVerificationCaseId;
        @track showCredSummScreen = true;
        @track caseStatusConstant;        
        @track repTypTwo = false;
        @track repTypThree = false;
        @track repType;
        @track ent;
        @track ref;
        @track entEmail;
        @track entCon;
        @track entRep;
        @track entAdd;
        @track entCoun;
        @track listOfFieldsCAT = [];
        @track credentialTypeListCAT = [];
        @track catRecordsCAT = [];
        @track showAllRecordsCAT = [];
        @track mainDocCondCAT = false;
        @track mainDocNameCondCAT = false;
        @track mainDocTransCondCAt = false;
        @track assetsListCAT = [];
        @track requestedToSendCAT;
        @track issuedIn90DaysCAT;
        @track casRecordsCAT = [];
        @track refShow = false;
        @track cvParentCases = [];
        @wire(getAllConstants) 
        allConstants({error, data}){
            if(data){
            this.caseStatusConstant = data.LWC_CASE_STATUS_PENDING_SUBMISSION;
            }else{
            this.error = error;
            }
        } 
        connectedCallback(){
            if(this.hideButtonsForCredVerCase){
                this.showButtonsAndSummary = false;
            }     
            getEPICCaseList({epicList:JSON.stringify(this.cas)
            }).then(rst=>{                
                this.repTypTwo = false;
                this.repTypThree = false;
                if(rst){                    
                    for(let key in rst){
                        this.repType = rst[key].Report_Type__c;                     
                    if(this.repType === 'Volume Entity'){
                        this.repTypTwo = true;   
                        this.ent = rst[key].Entity__r.Name;
                        if(rst[key].Reference_Number__c !== undefined){
                            this.ref = rst[key].Reference_Number__c; 
                            this.refShow = true;
                        }else{
                            this.refShow = false;
                        }                                          
                    }
                    if(this.repType === 'Other Entity'){
                        this.repTypThree = true;
                        if(rst[key].Reference_Number__c !== undefined){
                            this.ref = rst[key].Reference_Number__c; 
                            this.refShow = true;
                        }else{
                            this.refShow = false;
                        } 
                        this.entEmail = rst[key].EPIC_Report_Entity_Email__c;
                        this.entCon = rst[key].EPIC_Report_Entity_Contact__c;
                        this.entRep = rst[key].EPIC_Report_Entity__c;
                        this.entAdd = rst[key].EPIC_Report_Entity_Address__c;
                        this.entCoun = rst[key].EPIC_Report_Entity_Country__c;  
                    }
                }
                }
            })
            getCredDocumentTypes({
                epicList:JSON.stringify(this.cas)
            })
            .then(result1 =>{
                    if(result1){                                               
                        for(let key in result1){  
                            this.cvParentCases.push(result1[key].Case__c);                             
                            this.catRecords.push({key: result1[key].Id,ct:result1[key].Credential_Type__c,value: result1[key]});                               
                            this.credentialTypeList.push(result1[key].Credential_Type__c);
                        }                                
                        getCredProgDocTypeMap({docName: this.credentialTypeList, programName: "EPIC"})
                            .then(result=>{                                
                                this.listOfFields = [];
                                if(result){
                                    for(let key in result){
                                        if(result.hasOwnProperty(key)){ // Filtering the data in the loop
                                            this.listOfFields.push({value: result[key], key: key});
                                        }
                                    }
                                    for(let index in this.catRecords){                                        
                                        for(let keyFields in this.listOfFields){
                                            if(this.catRecords[index].ct === this.listOfFields[keyFields].key){
                                                let fieldName = this.listOfFields[keyFields].value;
                                                let fieldList = [];
                                                for(const property in fieldName){
                                                    fieldList.push(`${property}`);
                                                }
                                                this.showAllRecords.push({key: this.catRecords[index].value, value: fieldList});
                                            }
                                        }
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
                                        if(this.showAllRecords[index].key.Credential_Type__c === 'Certificate of Good Standing' && this.showAllRecords[index].key.Requested_to_be_sent_to_ECFMG__c){
                                            this.requestedToSend = 'Yes';
                                        }
                                        else{
                                            if(this.showAllRecords[index].key.Credential_Type__c === 'Certificate of Good Standing' && this.showAllRecords[index].key.Issued_in_the_last_90_days__c){
                                                this.issuedIn90Days = 'Yes';
                                            }                                            
                                            if(this.showAllRecords[index].key.Assets__r){
                                                let parentAssetId = '';                                               
                                                for(let i = 0; i < this.showAllRecords[index].key.Assets__r.length; i++){                                                    
                                                    if(this.showAllRecords[index].key.Assets__r[i].Type__c !== 'Name Document' && this.showAllRecords[index].key.Assets__r[i].Type__c !== 'Translation' && this.showAllRecords[index].key.Assets__r[i].RecordType.DeveloperName === 'Credential'){
                                                        parentAssetId = this.showAllRecords[index].key.Assets__r[i].Id;
                                                    }
                                                }                                                    
                                                for(let i = 0; i < this.showAllRecords[index].key.Assets__r.length; i++){
                                                this.assetsList = this.showAllRecords[index].key.Assets__r[i];
                                                if(this.assetsList.Type__c !== 'Name Document' && this.assetsList.Type__c !== 'Translation' && this.assetsList.RecordType.DeveloperName === 'Credential'){
                                                    this.assetsList.mainDocCond = true;
                                                    tempPayload.assetId = this.assetsList.Id;
                                                    tempPayload.documentType = this.assetsList.Type__c;
                                                    this.assetsList.mainDocPayload = JSON.stringify(tempPayload);
                                                    if(this.assetsList.Name_on_Document_is_Different__c){
                                                        this.showAllRecords[index].key.nameOnDocDiffWithoutUpload = true;
                                                    }                                                   
                                                }
                                                if(this.assetsList.Type__c === 'Name Document'){
                                                    this.assetsList.mainDocNameCond = true;
                                                    tempPayload.assetId = this.assetsList.Id;
                                                    tempPayload.documentType = "Name Document";
                                                    this.assetsList.nameDocPayload = JSON.stringify(tempPayload);
                                                    this.assetsList.nameOnDocDiffWithoutUpload = false;
                                                    this.showAllRecords[index].key.nameOnDocDiffWithoutUpload = false;
                                                }
                                                if(this.assetsList.Type__c === 'Translation' && this.assetsList.ParentId === parentAssetId){
                                                    this.assetsList.mainDocTransCond = true;
                                                    tempPayload.assetId = this.assetsList.Id;
                                                    tempPayload.documentType = "Translation";
                                                    this.assetsList.transDocPayload = JSON.stringify(tempPayload);
                                                }
                                                }
                                            }
                                        }
                                    }
                                    this.spinner = false;
                                }
                            })
                    }
            })
//epic case
getExtractionSubCase({epicList:JSON.stringify(this.cas)})
.then(dt=>{
    if(dt){        
        for(let k in dt){                               
            this.casRecordsCAT.push({key: dt[k].Id,value: dt[k]});                                           
        }
        getCredDocumentTypesCAT({
            epicList:JSON.stringify(this.cas)
        })
        .then(result1 =>{
            if(result1){                                 
                for(let key in result1){   
                    let dobToShow = false;    
                    if(result1[key].DOB_on_Document__c !== undefined){
                        dobToShow = true;
                    }
                    this.cvParentCases.push(result1[key].Case__c);
                    this.catRecordsCAT.push({key: result1[key].Id,ct:result1[key].Credential_Type__c,value: result1[key],dobToShow:dobToShow});                               
                    this.credentialTypeListCAT.push(result1[key].Credential_Type__c);
                }                   
            getCredProgDocTypeMap({docName: this.credentialTypeListCAT, programName: "EPIC"})
                .then(result=>{                    
                    this.listOfFieldsCAT = [];
                    if(result){
                        for(let key in result){
                            if(result.hasOwnProperty(key)){ // Filtering the data in the loop
                                this.listOfFieldsCAT.push({value: result[key], key: key});
                            }
                        }
                        for(let index in this.catRecordsCAT){                                        
                            for(let keyFields in this.listOfFieldsCAT){
                                if(this.catRecordsCAT[index].ct === this.listOfFieldsCAT[keyFields].key){
                                    let fieldName = this.listOfFieldsCAT[keyFields].value;
                                    let fieldList = [];
                                    for(const property in fieldName){
                                        fieldList.push(`${property}`);
                                    }
                                    this.showAllRecordsCAT.push({key: this.catRecordsCAT[index].value, value: fieldList,dobToShow:this.catRecordsCAT[index].dobToShow});
                                }
                            }
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
                            if(this.showAllRecordsCAT[index].key.Credential_Type__c === 'Certificate of Good Standing' && this.showAllRecordsCAT[index].key.Requested_to_be_sent_to_ECFMG__c){
                                this.requestedToSendCAT = 'Yes';
                            }
                            else{
                                if(this.showAllRecordsCAT[index].key.Credential_Type__c === 'Certificate of Good Standing' && this.showAllRecordsCAT[index].key.Issued_in_the_last_90_days__c){
                                    this.issuedIn90DaysCAT = 'Yes';
                                }                                
                                for(let indexCS in this.casRecordsCAT){ 
                                    if(this.casRecordsCAT[indexCS].key === this.showAllRecordsCAT[index].key.Case__c){
                                        this.showAllRecordsCAT[index].key.Assets__r =this.casRecordsCAT[indexCS].value.Assets__r;                                       
                                        if(this.showAllRecordsCAT[index].key.Assets__r){
                                            let parentAssetId = '';                                              
                                            for(let i = 0; i < this.casRecordsCAT[indexCS].value.Assets__r.length; i++){
                                                if(this.casRecordsCAT[indexCS].value.Assets__r[i].Type__c !== 'Name Document' && this.casRecordsCAT[indexCS].value.Assets__r[i].Type__c !== 'Translation' && this.casRecordsCAT[indexCS].value.Assets__r[i].RecordType.DeveloperName === 'Credential'){
                                                    parentAssetId = this.casRecordsCAT[indexCS].value.Assets__r[i].Id ;
                                                }
                                            }
                                            for(let i = 0; i < this.casRecordsCAT[indexCS].value.Assets__r.length; i++){
                                            this.assetsListCAT = this.casRecordsCAT[indexCS].value.Assets__r[i];                                                                                                                                   
                                            if(this.assetsListCAT.Type__c !== 'Name Document' && this.assetsListCAT.Type__c !== 'Translation' && this.assetsListCAT.RecordType.DeveloperName === 'Credential'){
                                                this.assetsListCAT.mainDocCond = true;
                                                tempPayload.assetId = this.assetsListCAT.Id;
                                                tempPayload.documentType = this.assetsListCAT.Type__c;
                                                this.assetsListCAT.mainDocPayload = JSON.stringify(tempPayload);
                                                if(this.assetsListCAT.Name_on_Document_is_Different__c){
                                                    this.showAllRecordsCAT[index].key.nameOnDocDiffWithoutUpload = true;
                                                }                                                  
                                                if(this.assetsListCAT.Name_on_Document__c !== undefined){
                                                    this.assetsListCAT.nameOnDoc = this.assetsListCAT.Name_on_Document__c;
                                                    this.assetsListCAT.nameOnDocShow = true;                                                    
                                                } 
                                                else{                                                    
                                                    this.assetsListCAT.nameOnDoc = '';
                                                    this.assetsListCAT.nameOnDocShow = false;
                                                }                                                 
                                            }
                                            if(this.assetsListCAT.Type__c === 'Name Document'){
                                                this.assetsListCAT.mainDocNameCond = true;
                                                tempPayload.assetId = this.assetsListCAT.Id;
                                                tempPayload.documentType = "Name Document";
                                                this.assetsListCAT.nameDocPayload = JSON.stringify(tempPayload);
                                                this.assetsListCAT.nameOnDocDiffWithoutUpload = false;
                                                this.showAllRecordsCAT[index].key.nameOnDocDiffWithoutUpload = false;
                                            }
                                            if(this.assetsListCAT.Type__c === 'Translation' && this.assetsListCAT.ParentId === parentAssetId){
                                                this.assetsListCAT.mainDocTransCond = true;
                                                tempPayload.assetId = this.assetsListCAT.Id;
                                                tempPayload.documentType = "Translation";
                                                this.assetsListCAT.transDocPayload = JSON.stringify(tempPayload);
                                            }
                                            }
                                        }
                                    }
                                }
                                
                            }
                        }                        
                        this.spinner = false;
                    }
                })
            }
        })
    }
})     
}
showPrevPage(event){
    event.preventDefault();
    const selectEvent = new CustomEvent('backevent',{});
    this.dispatchEvent(selectEvent);
}
showCredLegpage(event){
    event.preventDefault();
    const selectEvent = new CustomEvent('nextevent',{detail: this.cvParentCases});
    this.dispatchEvent(selectEvent);
}
cancelCredVer(event){
    event.preventDefault();
    const selectEvent = new CustomEvent("cancelevent",{});
    this.dispatchEvent(selectEvent);
}    
}