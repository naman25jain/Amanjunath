import {LightningElement,track,wire} from 'lwc';
import {CloseActionScreenEvent} from 'lightning/actions';
import {CurrentPageReference} from 'lightning/navigation';
import checkCVCaseStatus from '@salesforce/apex/CancelCVCaseController.checkCVCaseStatus';
import updateCVCase from '@salesforce/apex/CancelCVCaseController.updateCVCase';
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import {updateRecord} from 'lightning/uiRecordApi';
export default class CancelCVCase extends LightningElement{
    @track selectedValue = ' ';
    @track showReasonBox = false;
    @track showCancelSection = false;
    @track showCancelForEICS = false;
    @track ErrorMsg;
    @track spinner = false;
    @track reasonForCancel = '';
    recordId;
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference){
        if(currentPageReference){
            this.recordId = currentPageReference.state.recordId;
        }
    }
    get CancelByOpt(){
        return[
            {label: 'Cancelled by Applicant', value: 'Cancelled By Applicant'},
            {label: 'Cancelled by ECFMG', value: 'Cancelled by ECFMG'},
        ];
    }
    connectedCallback(){
        this.spinner = true;
        checkCVCaseStatus({caseId: this.recordId})
        .then(result=>{
            if(result.Internal_Status__c === 'CV Accepted' || result.Internal_Status__c === 'CV Rejected' || result.Internal_Status__c === 'Rejected' 
                || result.Internal_Status__c === 'Previously Verified - Accepted' || result.Internal_Status__c === 'Complete'){
                this.ErrorMsg = 'This case is already closed.';
                this.handleThrowError(this.ErrorMsg);
                this.spinner = false;
                this.dispatchEvent(new CloseActionScreenEvent());
            }
            else if(result.Internal_Status__c === 'In Review at Entity'){
                this.ErrorMsg = 'This case is already in review at entity. Please confirm with Entity first.';
                this.handleThrowError(this.ErrorMsg);
                this.spinner = false;
                this.dispatchEvent(new CloseActionScreenEvent());
            }
            else if(result.Internal_Status__c === 'Cancelled By Applicant' || result.Internal_Status__c === 'Cancelled by ECFMG' || result.Internal_Status__c === 'Cancelled'){
                this.ErrorMsg = 'This case is already cancelled.';
                this.handleThrowError(this.ErrorMsg);
                this.spinner = false;
                this.dispatchEvent(new CloseActionScreenEvent());
            }else if((result.Service__c === 'EICS' && (result.Internal_Status__c === 'Sent for Verification' || result.Internal_Status__c === 'Resent for Verification' 
                || result.Internal_Status__c === 'Pending Verification Review' || result.Internal_Status__c === 'Verification In Review at ECFMG' || result.Internal_Status__c === 'Verification Incomplete' 
                || result.Internal_Status__c === 'Compile Verification Packet' || result.Internal_Status__c === 'Incomplete - Resent for Verification' )) 
                || (result.Service__c === 'FCVS' && result.RecordType.Name === 'FCVS Request')){
                this.showCancelForEICS = true;
                this.spinner = false;
            }
            else if(result.Service__c === 'EICS'){
                this.ErrorMsg = 'Unable to cancel case at this status, if client requests cancellation please use the affirmations accordingly.';
                this.handleThrowError(this.ErrorMsg);
                this.spinner = false;
                this.dispatchEvent(new CloseActionScreenEvent());
            }else{
                this.spinner = false;
                this.showCancelSection = true;
            }
        }).catch(error=>{
            window.console.error('Error: ', error);
        })
    }
    handleSelection(event){
        var finButton = this.template.querySelector(".finButton");
        this.selectedValue = event.target.value;
        this.showReasonBox = true;
        this.reasonForCancel = '';
        if(this.reasonForCancel){
            finButton.disabled = false;
        }
        else{
            finButton.disabled = true;
        }
    }
    enableFinish(){
        var reaElement = this.template.querySelector(".reasonforCancel");
        var reaElementEICS = this.template.querySelector(".reasonforCancelEICS");
        var finButton = this.template.querySelector(".finButton");
        if(reaElement != null && typeof(reaElement) != 'undefined'){
            this.reasonForCancel = reaElement.value;
        }
        if(reaElementEICS != null && typeof(reaElementEICS) != 'undefined'){
            this.reasonForCancel = reaElementEICS.value;
        }
        if(this.reasonForCancel){
            finButton.disabled = false;
        }
        else{
            finButton.disabled = true;
        }
    }
    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    handleFinish(){
        this.spinner = true;
        updateCVCase({caseId: this.recordId, selectedValue: this.selectedValue, reason: this.reasonForCancel})
        .then(result=>{
            if(result){
                this.spinner = false;
                this.showCancelSection = false;
                const successMsg = new ShowToastEvent({
                    title: "Success",
                    message: "Case has been successfully Cancelled!",
                    variant: "success"
                });
                this.dispatchEvent(successMsg);
                this.dispatchEvent(new CloseActionScreenEvent());
                updateRecord({fields: {Id: this.recordId}});
            }
        })
        .catch(error=>{
            window.console.error('Error: ', error);
        })
    }
    handleThrowError(){
        const errorEvent = new ShowToastEvent({
            title: "Error",
            message: this.ErrorMsg,
            variant: "error"
        });
        this.dispatchEvent(errorEvent);
    }
}