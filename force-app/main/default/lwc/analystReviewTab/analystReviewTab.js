import { LightningElement,api,track,wire } from 'lwc';
import getEntityFields from "@salesforce/apex/EntityReviewController.getEntityFields";
import getAuthority from "@salesforce/apex/EntityReviewController.getAuthority";
import getActiveEntities from "@salesforce/apex/EntityReviewController.getActiveEntities";
import getCountryInst from "@salesforce/apex/EntityReviewController.getCountryInst";
import updateEntityValues from "@salesforce/apex/EntityReviewController.updateEntityValues";
import getCaseDetails from "@salesforce/apex/EntityReviewController.getCaseDetails";
import getAKANames from "@salesforce/apex/EntityReviewController.getAKANames";
import getAsset from "@salesforce/apex/EntityReviewController.getAsset";
import updateAssetNOD from "@salesforce/apex/EntityReviewController.updateAssetNOD";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import Analyst_review_Tab_Unapproved_Entity_Message from "@salesforce/label/c.Analyst_review_Tab_Unapproved_Entity_Message";
export default class AnalystReviewTab extends LightningElement{
    @api recordId;
    @api catsRec;
    @track metarecordId;
    @track entityName;
    @track selectedAltEntName;
    @track entInt;
    @track entExt;
    @track entCountry;
    @track alternEntity = null;
    @track selectedAltEntName;
    @track alternEntInt;
    @track alternEntExt;
    @track authority;
    @track clientSpecInstr;
    @track selectedEntityId;
    @track selectedAltEntlId = null;
    @track akaNameList;
    @track credTypeId;
    @track sendMethod;
    @track nameOnDocument;
    @track iniNOD;
    @track assertId;
    @track countryInst;
    @track contactName;
    _wiredEntityVal;
    @track parentEnt = null;
    @track updateasst = false;
    @track checkUpdate = false;
    @track showSaveButton = false;
    @track showErrorMsg = false;
    @track entityRecordType;
    @track notifyAnalyst;
    label = {
        Analyst_review_Tab_Unapproved_Entity_Message
      };
    
    initialized = false;
    connectedCallback(){
        this.getAllVals();
    }
    @wire(getActiveEntities) EntityRecordValues;
    handleEntityChange(event){
        if(this.selectedEntityName != event.target.value){
            this.showSaveButton = true; 
        }else{
            this.showSaveButton = false;
        }
        this.entityName = event.target.value;
        if(event.target.value){
            this.selectedEntityId = this.template.querySelector(".EntityList option[value=\"" + event.target.value + "\"]").getAttribute("data-entityid");
            this.showErrorMsg = false;
        }
        else{
            this.selectedEntityId = null;
            this.showErrorMsg = true;
        }
    }
    handleNODChange(event){
        if(this.iniNOD != event.target.value){
            this.showSaveButton = true;
        }else{
            this.showSaveButton = false;
        }
        this.nameOnDocument = event.target.value;
    }
    handleAltEntityChange(event){
        if(this.selectedAltEntName != event.target.value){
            this.showSaveButton = true;
        }else{
            this.showSaveButton = false;
        }
        this.alternEntity = event.target.value;
        if(event.target.value){
            this.selectedAltEntlId = this.template.querySelector(".AlternateEntityList option[value=\"" + event.target.value + "\"]").getAttribute("data-entityid");
        }
        else{
            this.selectedAltEntlId = null;
        }
    }
    handleSave(){
        if(this.selectedEntityId){
            updateEntityValues({catsId:this.catsRec, entId:this.selectedEntityId, altentId:this.selectedAltEntlId})
            .then(result=>{
                if(result){
                    const evt = new ShowToastEvent({
                        title: "Success",
                        message: "Data saved successfully",
                        variant: "success",
                        mode: "dismissable"
                    });
                    this.dispatchEvent(evt);
                    this.checkUpdate = result;
                    this.getAllVals();
                    this.showSaveButton = false;
                }
            }).catch(error=>{
                window.console.error('Error: ', error);
            })
        }
        updateAssetNOD({asstId:this.assertId, nameOnDoc:this.nameOnDocument})
        .then(result =>{
            if(result){ 
                this.updateasst = result;
            }
        }).catch(error => {
            window.console.error('Error: ', error);
        })
    }
    handleCancel(){
        this.getAllVals();
        this.showSaveButton = false;
        this.showErrorMsg = false;
    }
    renderedCallback(){
        if(this.initialized){
            return;
        }
        this.initialized = true;
        let listId = this.template.querySelector('datalist.EntityList').id;
        this.template.querySelector("input.entityRecord").setAttribute("list", listId);
        let listId1 = this.template.querySelector('datalist.AlternateEntityList').id;
        this.template.querySelector("input.altentityRecord").setAttribute("list", listId1);
    }
    getAllVals(){
        getCaseDetails({caseId:this.recordId})
        .then(result=>{
            if(result){
                this.contactName = result.Contact.Name;
                this.sendMethod = result.Send_Method__c;
            }
        }).catch(error=>{
            window.console.error('Error: ', error);
        })
        getEntityFields({caseId:this.recordId})
        .then(result=>{
            if(result){
                this._wiredEntityVal = result;
                this.catsRec = result.key;
                this.selectedEntityId = result.accountId;
                this.entityName = result.accName;
                this.selectedEntityName = result.accName;
                this.entInt = result.intInst;
                this.entExt = result.extInst;
                this.entCountry = result.accCountry;
                if(result.accParentEnt){
                    this.parentEnt = result.accParentEntName;
                }else{
                    this.parentEnt = null;
                }
                if(result.altEntity){
                    this.alternEntity = result.altEntityName;
                    this.selectedAltEntName = result.altEntityName;
                    this.alternEntInt = result.altIntInst;
                    this.alternEntExt = result.altExtInst;
                }
                else{
                    this.alternEntity = null;
                    this.alternEntInt = null;
                    this.alternEntExt = null;
                }
                this.credTypeId = result.credType;
                this.entityRecordType = result.accRecordTypeName;
                if(this.entityRecordType === 'Unapproved New Entity'){
                this.NotifyAnalyst = true;
                }else{
                this.NotifyAnalyst = false;
                }
                this.getSend();
            }   
        }).catch(error=>{
            window.console.error('Error: ', error);
        })
    }
    getSend(){
        getAKANames({entityId:this.selectedEntityId})
        .then(result=>{
            if(result){
                this.akaNameList = result;
            }
        }).catch(error=>{
            this.akaNameList = null;
        })
        getCountryInst({countryName:this.entCountry})
        .then(result=>{
            if(result){
                this.countryInst = result;
            }
        }).catch(error=>{
            this.countryInst = null;
        })
        getAuthority({caseId:this.recordId})
        .then(result=>{
            if(result){
                this.authority = result.Entity__r.Name;
                this.clientSpecInstr = result.Entity__r.EPIC_Client_Special_Instructions_Languag__c;
            }
        }).catch(error=>{
            this.authority = null;
            this.clientSpecInstr = null;
        })
        getAsset({caseId:this.recordId})
        .then(result => {
            if(result){ 
                this.nameOnDocument = result.Name_on_Document__c;
                this.iniNOD = result.Name_on_Document__c;
                this.assertId = result.Id;
            }
        }).catch(error => {
            this.nameOnDocument = null;
        })
    }
}