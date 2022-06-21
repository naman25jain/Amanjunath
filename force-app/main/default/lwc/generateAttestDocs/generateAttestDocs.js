import {LightningElement,wire} from 'lwc';
import {CloseActionScreenEvent} from 'lightning/actions';
import {CurrentPageReference} from 'lightning/navigation';
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import checkAttestDocExists from '@salesforce/apex/GenerateAttestFormandLetter.checkAttestAsstExists';
import updateCaseStatus from '@salesforce/apex/GenerateAttestFormandLetter.updateCaseStatus';
import generateAttestFormAndLetterCallOut from '@salesforce/apex/GenerateAttestFormandLetter.generateAttestFormAndLetterCallOut';
import {updateRecord} from 'lightning/uiRecordApi';
export default class GenerateAttestDocs extends LightningElement{
    recordId;
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference){
        if(currentPageReference){
            this.recordId = currentPageReference.state.recordId;
        }
    }
    connectedCallback(){
        this.spinner = true;
        checkAttestDocExists({recordId: this.recordId})
        .then(result=>{
            if(result){
                updateCaseStatus({recordId: this.recordId})
                .then(res=>{
                    if(res){
                        this.spinner = false;
                        this.dispatchEvent(new CloseActionScreenEvent());
                        updateRecord({fields: {Id: this.recordId}});
                    }
                }).catch(error=>{
                    window.console.error('Error: ', error);
                })
                const errorEvent = new ShowToastEvent({
                    title: "Error",
                    message: "Attestation Form and Cover Letter already generated once",
                    variant: "error"
                });
                this.dispatchEvent(errorEvent);
            }
            else{
                this.spinner = true;
                generateAttestFormAndLetterCallOut({caseId: this.recordId})
                const successMsg = new ShowToastEvent({
                    title: "Success",
                    message: "Attestation Form and Cover Letter Generated successfully",
                    variant: "success"
                });
                this.dispatchEvent(successMsg);
                updateCaseStatus({recordId: this.recordId})
                .then(res=>{
                    if(res){
                        this.spinner = false;
                        this.dispatchEvent(new CloseActionScreenEvent());
                        updateRecord({fields: {Id: this.recordId}});
                    }
                }).catch(error=>{
                    window.console.error('Error: ', error);
                })
            }
        })
    }

}