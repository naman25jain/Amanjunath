import {LightningElement,api,track} from 'lwc';
import createMedEduForm from '@salesforce/apex/MedEduController.createMedEduForm';
import updateCaseStatus from '@salesforce/apex/MedEduController.updateCaseStatus';
import getCaseRecords from '@salesforce/apex/CredVerificationListViewController.getCaseRecords';
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import {updateScreenNumer} from 'c/util';
export default class MedEduFormSummary extends LightningElement{
    @track spinner = false;
    @api caseId;
    @api currentEntity;
    @api applicantId;
    @track showMedEduForm = false;
    @track azureDocUrl;
    @track tempPayload =  {
        contactId: null,
        caseId: null,
        catsId: null,
        documentType: null,
        assetRecordType: null,
        createOrReplace: null,
        assetStatus: null,
        assetCreationRequired: null,
        assetId: null,
        createFromPB: 'true'
    };
    connectedCallback(){
        this.spinner = true;
        updateScreenNumer(this.caseId,3);
        createMedEduForm({caseRecordId : this.caseId}).then(result=>{
            if(result){
                this.azureDocUrl = result;
                this.finalPayload = JSON.stringify(this.tempPayload);
                this.showMedEduForm = true;
            }
            this.spinner = false; 
        })
    }
    showQuestionnaire(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('showquest', {});
        this.dispatchEvent(selectEvent);
    }
    showCredReviewList(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('showlist', {});
        this.dispatchEvent(selectEvent);
    } 
    showConfirmation(event){
        event.preventDefault();
        this.template.querySelector('[data-id="confirmationWindow"]').show();
    }
    cancelSubmit(){
        this.template.querySelector('[data-id="confirmationWindow"]').hide();
    }
    proceedSubmit(event){
        this.template.querySelector('[data-id="confirmationWindow"]').hide();
        const evt = new ShowToastEvent({
            title: "Success",
            message: "Your Response was successfully submitted",
            variant: "success",
            mode: "dismissable"
        });
        this.dispatchEvent(evt);
        this.spinner = true;
        updateCaseStatus({caseRecordId : this.caseId})
        .then(result=>{
            if(result){
                getCaseRecords({currentEntityId: this.currentEntity, applicantId: this.applicantId, currCaseId: this.caseId})
                .then(data=>{
                    if(data.length == 0){
                        this.spinner = false;
                        this.showCredReviewList(event);
                    }else{
                        this.spinner = false;
                        this.showActiveCaseList();
                    }
                })
            }
        }).catch(error=>{
            window.console.error('Error: ',error);
        })
    }
    showActiveCaseList(){
        const selectEvent = new CustomEvent('activecaseslist');
        this.dispatchEvent(selectEvent);
    }
}