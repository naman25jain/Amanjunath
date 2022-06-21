import {LightningElement, api, track} from 'lwc';
import searchRegOrg from "@salesforce/apex/EpicCredVerController.searchRegOrg";
import insertNewCatsRecord from "@salesforce/apex/EpicCredVerController.insertNewCatsRecord";
import getRegOrgCatsRecord from "@salesforce/apex/EpicCredVerController.getRegOrgCatsRecord";
import insertAlreadyEstOrgInCat from "@salesforce/apex/EpicCredVerController.insertAlreadyEstOrgInCat";
import deleteSelectedOrg from "@salesforce/apex/EpicCredVerController.deleteSelectedOrg";
import deleteAllSelectedOrg from "@salesforce/apex/EpicCredVerController.deleteAllSelectedOrg";
import getRegOrgDontKnow from "@salesforce/apex/EpicCredVerController.getRegOrgDontKnow";
import updateContact from "@salesforce/apex/EpicCredVerController.updateContactRegOrgField";
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import createEpicExtractionCase from '@salesforce/apex/EpicCredVerController.createEpicExtractionCase';
export default class EpicOrgSelectionScreen extends LightningElement{
    @track spinner = false;
    @track selectedRecord = false;
    @track records;
    @track recordsList = [];
    @api searchfield = 'Name';
    @api iconname = "standard:account";
    @track modalTitle = 'Add New Organization';
    @track modalContent = '';
    @track selectedRec = [];
    @track showAddedOrgs = false;
    @track selectedAccountName;
    @track catsRecordList = [];
    @track catRecordToRemove = [];
    @track showSearchButton = true;
    @track showNewSubmitButton = false;
    @api recordsExistSubmitButton = false; //to pass it to child component to show submit button along with recordslist
    @track enableNextButton = false;
    @track orgUnconfirmed = false;
    connectedCallback(){
        getRegOrgDontKnow()
            .then(result =>{
                if(result){
                    this.orgUnconfirmed = true;
                    this.handleDelAllSelectedOrg();
                }
                else{
                    insertAlreadyEstOrgInCat({})
                        .then(data =>{
                            if(data){
                                this.showRegOrgsOnLoad();
                            }
                    })
                }
        })
    }
    handleChangeForInputFields(event){
        const searchKey = event.detail.value;
        this.recordsList = [];
        this.records = [];
        searchRegOrg({
            searchKey : searchKey, 
        })
            .then(result =>{
            this.records = result;
            for(let i=0; i < this.records.length; i++){
                let rec = this.records[i];
                let containsId = false;
                let dupCheck = false;
                //iteration to not to show the accounts, which is already in CATS recordlist of that contact
                for(let key in this.catsRecordList){
                    if(this.catsRecordList[key].AccountId === rec['Id']){
                        containsId = true;
                        break;
                    }
                }
                //iteration to avoid duplicate list.
                for(let keyNew in this.recordsList){
                    if(this.recordsList[keyNew].Id === rec['Id']){
                        dupCheck = true;
                        break;
                    }
                }
                if(!containsId && !dupCheck){
                    this.recordsList.push(rec);
                    this.recordsList[i].Name = rec[this.searchfield];
                }
            }
            if(this.recordsList.length <= 0 && searchKey){
                this.showNewSubmitButton = true; //show only submit new button if there is no recordslist and there is keyword entered
            }
            else{
                this.showNewSubmitButton = false;
            }
            if(this.recordsList.length > 0){
                this.recordsExistSubmitButton = true; //show submit new button along with recordslist
            }
            else{
                this.recordsExistSubmitButton = false;
            }
            this.error = undefined;
        })
        .catch(error =>{
            this.error = error; 
            this.records = undefined;
        });
    }
    handleSelect(event){
        this.template.querySelector('.addScreenModal').show();
        this.selectedRec = event.detail;
    }
    handleYesClick(){
        this.spinner = true;
        this.selectedAccountName = '';
        this.recordsList = '';
        this.selectedRecord = true;
        insertNewCatsRecord({
            selectedRecId: this.selectedRec.Id
        })
            .then(result =>{
                if(result){
                    this.showRegOrgsOnLoad();
                    this.selectedRecord = false;
                    const successevt = new ShowToastEvent({
                        title: "Success",
                        message: 'Organization has been added',
                        variant: "Success"
                        });
                        this.dispatchEvent(successevt);
                }
            })
    }
    showRegOrgsOnLoad(){
        getRegOrgCatsRecord()
            .then(result =>{
                if(result){
                    if(result.length === 0){
                        if(this.orgUnconfirmed && !this.showSearchButton){
                            this.enableNextButton = true; 
                        }
                        else{
                            this.enableNextButton = false;    
                        }
                    }
                    else{
                        this.enableNextButton = true;    
                    }
                    this.catsRecordList = result;
                    this.showAddedOrgs = true;
                    this.spinner = false;
                }
            })
    }
    handleDeleteOnClick(event){
        let catRecordId = event.target.getAttribute("data-catrec-id");
        for(let key in this.catsRecordList){
            if(this.catsRecordList[key].Id === catRecordId){
                this.catRecordToRemove = this.catsRecordList[key];
            }
        }
        
        this.template.querySelector('.removeScreenModal').title = 'Remove this Organization?';
        this.template.querySelector('.removeScreenModal').show();
    }
    handleYesDeleteClick(){
        this.selectedRecord = true;
        this.recordsList = '';
        this.spinner = true;
        deleteSelectedOrg({
            catsRecordId: this.catRecordToRemove.Id
        })
        .then(result =>{
            if(result){
                this.showRegOrgsOnLoad();
                const successevt = new ShowToastEvent({
                    title: "Success",
                    message: 'Organization has been removed.',
                    variant: "Success"
                });
                this.dispatchEvent(successevt);
                this.selectedRecord = false;
            }
        })
    }
    
    handleChangeCheckboxOrg(event){
        if(event.target.checked){
            this.template.querySelector('.checkboxOrgModal').title = 'Are you sure? ';
            this.template.querySelector('.checkboxOrgModal').message = 'Checking this option will remove the organizations you have already added. Click OK to confirm this option. Otherwise, click Cancel to continue adding organizations to which you intend to apply.';
            this.template.querySelector('.checkboxOrgModal').show();    
        }
        else{
            this.showSearchButton = true;
            this.showNewSubmitButton = false;
            this.recordsList = '';
            this.enableNextButton = false;
        }
    }
    handleUncheckbox(){
        this.template.querySelector(".checkboxOrg").checked = false;
        this.enableNextButton = false;
    }
    handleDelAllSelectedOrg(){
        this.enableNextButton = true;
        this.selectedRec = true;
        this.showSearchButton = false;
        this.showAddedOrgs = false;
        deleteAllSelectedOrg();
    }
    handleCreateNewAcc(event){
        this.selectedRec = event.detail;
        this.showNewSubmitButton = false;
        this.handleYesClick();
    }
    clearSearchBox(){
        this.showNewSubmitButton = false;
        this.selectedAccountName = "";
    }
    prevButton(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('previousevent', {});
        this.dispatchEvent(selectEvent);
    }
    nextButton(event){
        const regOrgCheck = this.template.querySelector(".checkboxOrg").checked;
        updateContact({regOrgChecked : regOrgCheck});
        event.preventDefault();
        this.spinner = true;
        createEpicExtractionCase()
        .then(result => {
            if(result != ''){
                const selectEvent = new CustomEvent('nextevent', {detail:{caserecordid:result}});
                this.dispatchEvent(selectEvent);
            }
        })
        .catch(error => {
            this.spinner = false;
            window.console.log('System Error:  ' + JSON.stringify(error));
        });
    }
    cancelButton(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('cancelevent', {});
        this.dispatchEvent(selectEvent);
    }
}