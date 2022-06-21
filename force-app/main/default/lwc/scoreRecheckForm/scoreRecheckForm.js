import { LightningElement, track } from 'lwc';
import getScoreRecheckExams from "@salesforce/apex/ScoreReportController.getScoreRecheckExams";
import manageScoreRecheck from "@salesforce/apex/ScoreReportController.manageScoreRecheck";
import createSRCase from "@salesforce/apex/ScoreReportController.createSRCase";
export default class ScoreRecheckForm extends LightningElement{
    @track scoreRecheckList = [];
    @track checkedcount = 0;
    @track spinner = false;
    @track btnDisabled = true;
    connectedCallback(){
        getScoreRecheckExams() 
            .then(result=>{
                if(result.length > 0){
                    this.scoreRecheckList = result;
                    for(let key in result){
                        if(result.hasOwnProperty(key)){
                            if(result[key].Is_Score_Rechecked__c){
                                this.btnDisabled = false;
                                this.checkedcount = this.checkedcount+1
                            }
                        }
                    }
                }
            })
            .catch(error=>{
                window.console.error('Error: ' + JSON.stringify(error));
            });
    }
    handleScoreRecheckChange(event){
        this.btnDisabled = true;
        if(event.target.checked){
            this.checkedcount = this.checkedcount+1;
        }else{
            this.checkedcount = this.checkedcount-1;
        }
        if(this.checkedcount > 0){
            this.btnDisabled = false;
        }
    }
    cancelButton(event){
        event.preventDefault();
        const selectEvent = new CustomEvent("cancelevent", {});
        this.dispatchEvent(selectEvent);
    }
    cancelButtonToOpen(){
        this.template.querySelector('c-modal-component').show();
    }
    closeModal(){
        this.template.querySelector('c-modal-component').hide();
    }
    nextButton(event){
        event.preventDefault();
        let recordValuesToSave = [];
        this.template.querySelectorAll('.scorerecheckloop').forEach(element=>{
            if(element.querySelector('.scorecheckbox').checked){ 
                let dataExamId = element.getAttribute('data-examidval');
                recordValuesToSave.push(dataExamId);
            }
        });
        this.spinner = true;
        // Save Records
        manageScoreRecheck({
            examIdsList : JSON.stringify(recordValuesToSave)
        })
        .then(saveresult=>{
        if(saveresult){
                createSRCase()
                .then(result=>{
                    if(result != null){
                        this.spinner = false;
                        const selectEvent = new CustomEvent("nextevent", {});
                        this.dispatchEvent(selectEvent);
                    }
                }) 
            }                        
        })
        .catch(error=>{
            window.console.error('Error: ' + JSON.stringify(error),error);
        });    
    }
}