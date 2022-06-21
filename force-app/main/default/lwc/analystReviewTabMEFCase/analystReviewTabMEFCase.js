import { LightningElement,api,track,wire } from 'lwc';
import getEntityFieldsCase from "@salesforce/apex/EntityReviewController.getEntityFieldsCase";
import getActiveEntities from "@salesforce/apex/EntityReviewController.getActiveEntities";
import getCountryInst from "@salesforce/apex/EntityReviewController.getCountryInst";
import updateEntityValuesCaseRec from "@salesforce/apex/EntityReviewController.updateEntityValuesCaseRec";
import getCaseDetails from "@salesforce/apex/EntityReviewController.getCaseDetails";
import getAKANames from "@salesforce/apex/EntityReviewController.getAKANames";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
export default class AnalystReviewTabMEFCase extends LightningElement{
    @api recordId;
    @api caseRec;
    @track entityName;
    @track selectedAltEntName;
    @track entInt;
    @track entExt;
    @track entCountry;
    @track alternEntity = null;
    @track selectedAltEntName;
    @track alternEntInt;
    @track alternEntExt;
    @track clientSpecInstr;
    @track selectedEntityId;
    @track selectedAltEntlId = null;
    @track akaNameList;
    @track documentTypeId;
    @track sendMethod;
    @track countryInst;
    @track contactName;
    _wiredEntityVal;
    @track parentEnt = null;
    @track updateasst = false;
    @track checkUpdate = false;
    @track showSaveButton = false;
    @track showErrorMsg = false;
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
            updateEntityValuesCaseRec({caseId:this.caseRec, entId:this.selectedEntityId, altentId:this.selectedAltEntlId})
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
        getEntityFieldsCase({caseId:this.recordId})
        .then(result=>{
            if(result){
                this._wiredEntityVal = result;
                console.log('getEntityFields - result is '+JSON.stringify(result));
                this.caseRec = result.Id;
                console.log('getEntityFields - result is '+this.caseRec);
                this.selectedEntityId = result.Entity__r.Id;
                this.entityName = result.Entity__r.Name;
                this.selectedEntityName = result.Entity__r.Name;
                this.entInt = result.Entity__r.Internal_Instructions__c;
                this.entExt = result.Entity__r.External_Instructions__c;
                this.entCountry = result.Entity__r.Country__c;
                if(result.Entity__r.Parent_Entity__c){
                    this.parentEnt = result.Entity__r.Parent_Entity__r.Name;
                }else{
                    this.parentEnt = null;
                }
                if(result.Alternate_Entity__c){
                    this.alternEntity = result.Alternate_Entity__r.Name;
                    this.selectedAltEntName = result.Alternate_Entity__r.Name;
                    this.alternEntInt = result.Alternate_Entity__r.Internal_Instructions__c;
                    this.alternEntExt = result.Alternate_Entity__r.External_Instructions__c;
                }
                else{
                    this.alternEntity = null;
                    this.alternEntInt = null;
                    this.alternEntExt = null;
                }
                this.documentTypeId = result.Document_Type__c;
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
    }
}