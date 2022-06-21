import {LightningElement, track, wire, api} from 'lwc';
import getAssetCatStagList from "@salesforce/apex/EpicCredVerController.getAssetCatStagList";
import deleteCredVerCase from "@salesforce/apex/EpicCredVerController.deleteCredVerCase";
import getSpecInstrDetails from "@salesforce/apex/EpicCredVerController.getSpecInstrDetails";
import updateEvr from "@salesforce/apex/EpicCredVerController.updateEvr";
export default class CredIntakeLanding extends LightningElement{
    @track specInstr;
    @track credList;
    @track credListRecordId;
    @track credListRecordIdStr;
    @track showCredList;
    @track showSpecInstr;
    @api program;
    @api recordId;
    @track deleteCATSId = null;
    @track spinner = false;
    @track selectedAuthEntityId;
    @track referenceNumber;
    @track caseIdVal;
    @wire(getSpecInstrDetails)
    setSpecInstrDetails({error, data}){
        if(data){
            this.specInstr = data;
            if(this.program === 'EPIC' && data != ''){
                this.showSpecInstr = true;
            }
        }else if(error){
            this.specInstr = [];
        }
    }
    removeCred(event){
        event.preventDefault();
        this.deleteCATSId = null;
        let closestId = this.getClosest(event.target, '.cred-id');
        this.deleteCATSId = closestId.getAttribute('data-record-id');
        this.template.querySelector('[data-id="newModalAlert"]').show();        
    }
    removeReportRecipient(event){
        let evr = {
            program : this.program,
            authId : this.selectedAuthEntityId,
            ref : this.referenceNumber,
            regOrgDNK : true
        }    
        let closestId = this.getClosest(event.target, '.cred-id');
        this.caseIdVal = closestId.getAttribute('data-case-id-val');
        updateEvr({evrWrapString: JSON.stringify(evr), evrId: this.caseIdVal})
                .then(result =>{
                    if(result){
                    this.getCredList();
                    
                }});
    }
    deleteYesButton(){
        this.spinner = true;
        deleteCredVerCase({catStagId: this.deleteCATSId})
                .then(result =>{
                    this.getCredList();
                    this.deleteCATSId = null;
                });
    }
    connectedCallback(){
       this.getCredList();
    }
    getCredList(){
        getAssetCatStagList({program: this.program}).then(value =>{
            if(value){
                if(value.length > 0){
                    this.showCredList = true; 
                    this.spinner = false;
                    this.credList = [];
                    this.credListRecordId = [];
                    for(let key in value){
                        if(value.hasOwnProperty(key)){
                            if(value[key].reportRecipient === undefined){
                                value[key].reportRecipient='No Report Requested';
                            }
                            let tempRecord = {
                                caseIdVal : value[key].caseIdVal,
                                recordIdVal : value[key].recordIdVal,
                                documentType : value[key].documentType,
                                issuingEntity : value[key].issuingEntity,
                                issueDate : value[key].issueDate,
                                title : value[key].title,
                                reportRecipient : value[key].reportRecipient,
                            };
                            this.credList.push(tempRecord);
                            this.credListRecordId.push(value[key].cvId);
                        }                                               
                    }
                }else{
                    this.credList = [];
                    this.credListRecordId = [];
                    this.showCredList = false;
                }
            }
            this.spinner = false;
        });
    }
    getClosest(elem, selector){
        if(!Element.prototype.matches){
            Element.prototype.matches =
                Element.prototype.matchesSelector ||
                Element.prototype.mozMatchesSelector ||
                Element.prototype.msMatchesSelector ||
                Element.prototype.oMatchesSelector ||
                Element.prototype.webkitMatchesSelector ||
                function(s){
                    var matches = (this.document || this.ownerDocument).querySelectorAll(s),
                        i = matches.length;
                    while(--i >= 0 && matches.item(i) !== this){
                        //loop to check i value
                    }
                    return i > -1;
                };
        }
        // Get closest match
        for(; elem && elem !== document; elem = elem.parentNode){
            if(elem.matches(selector)){
                return elem;
            }
        }
        return null;
    }
    cancelCred(event){
        event.preventDefault();
        const selectEvent = new CustomEvent("cancelevent", {});
        this.dispatchEvent(selectEvent);
    }
    editCred(event){
        event.preventDefault();
        let closestId = this.getClosest(event.target, '.cred-id');
        let asstCatStagId = closestId.getAttribute('data-record-id');
        const selectEvent = new CustomEvent('editcredevent', {detail : {catStagId: asstCatStagId}});
        this.dispatchEvent(selectEvent);
    }
    addCredRedirect(){
        const selectEvent = new CustomEvent("addcredential", {});
        this.dispatchEvent(selectEvent);
    }
    showSummary(event){
        event.preventDefault();
        this.credListRecordIdStr = this.credListRecordId.toString();
        const selectEvent = new CustomEvent('showsummaryevent', {detail:{caserecordid:this.credListRecordIdStr}});
        this.dispatchEvent(selectEvent);
    }
    closeModal(){
        this.template.querySelector('[data-id="newModalAlert"]').hide();
    }
}