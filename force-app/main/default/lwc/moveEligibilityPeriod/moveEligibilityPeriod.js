import { LightningElement, api, track } from 'lwc';
import getEligibilityPeriods from "@salesforce/apex/MoveEligibilityPeriodController.getEligibilityPeriods";
import getCurrentEligibilityPeriod from "@salesforce/apex/MoveEligibilityPeriodController.getCurrentEligibilityPeriod";
import submitMoveEP from "@salesforce/apex/MoveEligibilityPeriodController.submitMoveEP";
import { showMessage } from "c/common";

export default class MoveEligibilityPeriod extends LightningElement {
    @api recordId;
    @track eligibilityPeriods =[];
    @track currentEligibilityPeriod;
    @track selectedEligibilityPeriod;
    @track reason;
    @track btnDisabled = true;
    @track spinner = true;
    connectedCallback() {
        getCurrentEligibilityPeriod({recordId:this.recordId}).then(value=>{
            if (value) {
                this.currentEligibilityPeriod = value;
            }
            this.spinner = false;
        });
        getEligibilityPeriods({recordId:this.recordId}).then(value=>{
				this.eligibilityPeriods = value;
        });
    }
    handleType(event){
        this.selectedEligibilityPeriod = event.detail.value;
        this.btnDisabled = false;
    }
    changeReason(event){
        this.reason = event.detail.value;
    }
    cancel(){
        this.dispatchEvent(new CustomEvent('close'));
    }
    submit(){
        this.spinner = true;
        this.btnDisabled = true;
        submitMoveEP({recordId:this.recordId, selectedEP:this.selectedEligibilityPeriod, reason:this.reason}).then(value=>{
            if(value===true){
                this.spinner = false;
                //show success message
                showMessage(
                null,
                "Success",
                "Your changes have been submitted.",
                "success"
                );
                this.dispatchEvent(new CustomEvent('close'));
                window.location.reload();
            }else{
                this.spinner = false;
                showMessage(
                    null,
                    "Error Saving",
                    "An error occurred while saving document.",
                    "error"
                );
                this.dispatchEvent(new CustomEvent('close'));

            }
        });
    }
}