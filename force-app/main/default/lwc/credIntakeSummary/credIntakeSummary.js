import {LightningElement, track, api, wire} from 'lwc';
import getCredProgDocTypeMap from '@salesforce/apex/EpicCredVerController.getCredProgDocTypeMap';
import getCredDocumentTypes from '@salesforce/apex/EpicCredVerController.getCredDocumentTypes';
import getAllConstants from '@salesforce/apex/AppForCertController.getAllConstants';
export default class CredIntakeSummary extends LightningElement{
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
        var credVerCaseId = null;
        if(this.credVerificationCaseId){
            credVerCaseId=this.credVerificationCaseId;
        }        
        getCredDocumentTypes()
            .then(result1 =>{
                if(result1){
                    if(credVerCaseId){
                        for(let key in result1){
                            if(result1[key].Case__c == credVerCaseId){                                
                            this.catRecords.push({key: result1[key].Credential_Type__c, value: result1[key]});
                            this.credentialTypeList.push(result1[key].Credential_Type__c);
                            }
                        }
                    }else{
                        for(let key in result1){
                            if(result1[key].Case__r.Internal_Status__c == this.caseStatusConstant){
                                this.catRecords.push({key: result1[key].Credential_Type__c, value: result1[key]});
                                this.credentialTypeList.push(result1[key].Credential_Type__c);
                            }                            
                        }
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
                                        if(this.catRecords[index].key === this.listOfFields[keyFields].key){
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
                                        for(let i = 0; i < this.showAllRecords[index].key.Assets__r.length; i++){
                                            this.assetsList = this.showAllRecords[index].key.Assets__r[i];
                                            if(this.assetsList.Type__c !== 'Name Document' && this.assetsList.Type__c !== 'Translation'){
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
                                            if(this.assetsList.Type__c === 'Translation'){
                                                this.assetsList.mainDocTransCond = true;
                                                tempPayload.assetId = this.assetsList.Id;
                                                tempPayload.documentType = "Translation";
                                                this.assetsList.transDocPayload = JSON.stringify(tempPayload);
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
    showCredIntLandPage(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('showscredintland', {});
        this.dispatchEvent(selectEvent);
    }
    showCredLegpage(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('nextevent', {});
        this.dispatchEvent(selectEvent);
    }
    cancelCredVer(event){
        event.preventDefault();
        const selectEvent = new CustomEvent("cancelevent", {});
        this.dispatchEvent(selectEvent);
    }    
}