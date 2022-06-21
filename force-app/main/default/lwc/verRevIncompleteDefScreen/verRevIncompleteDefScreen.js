import {LightningElement,api,track} from 'lwc';
import getIncAffirmations from "@salesforce/apex/VerificationRevIncomController.getIncAffirmations";
import getVerReviewAffirm from "@salesforce/apex/VerificationRevIncomController.getVerReviewAffirm";
import getCase from '@salesforce/apex/VerificationRevIncomController.getCase';
import saveAffirmationRec from '@salesforce/apex/VerificationRevIncomController.saveAffirmationRec';
import {FlowNavigationBackEvent, FlowNavigationNextEvent} from 'lightning/flowSupport';
export default class VerRevIncompleteDefScreen extends LightningElement{
@api caseId;
@api affirmId;
@track incAffirmations = [];
@track auth;
@track compMedform;
@track compVerForm;
@track cred;
@track envelope;
@track grade;
@track nameMatch;
@track nameMissing;
@track offSealMiss;
@track offSealNotMatch;
@track otherReason;
@track response;
@track returnReason;
@track signMatch;
@track signMissing;
@track titleMatch;
@track titleMissing;
@track transcript;
@track transSeal;
@track verif;
@track credType;
@track sendMethod;
@track showFrstSect;
@track showMedForm;
@track showfinalTr;
@track comments;
@track affirmId;
@track spinner;
@track showErrorMsg;
getAllIncAffirm(){
    getIncAffirmations({caseId: this.caseId}).then(incomAffirm=>{
        this.incAffirmations = incomAffirm;
    }).catch(error=>{
        window.console.error('Error: ', error);
    })
    getCase({caseId: this.caseId}).then(result=>{
        this.credType = result.Document_Type__c;
        this.sendMethod = result.Send_Method__c;
        if(this.credType == 'Alternate Graduation Document' || this.credType == 'Final Medical Diploma' || this.credType == 'Final Medical School Transcript'
            || this.credType == 'Student Medical School Transcript' || this.credType == 'Pregraduate Internship Certificate'){
                this.showFrstSect = true;
                if(this.credType == 'Final Medical School Transcript'){
                    this.showfinalTr = true;
                }
        }
        else if(this.credType == 'Medical Education Form'){
            this.showMedForm = true;
        }
    })
    getVerReviewAffirm({caseId: this.caseId}).then(result=>{
        this.affirmId = result.Id;
        this.auth = result.Incomplete_Reason_Authorization__c;
        this.compMedform = result.Incomplete_Reason_Completion_Med_Ed_form__c;
        this.compVerForm = result.Incomplete_Reason_Completion_Verform__c;
        this.cred = result.Incomplete_Reason_Credential__c;
        this.envelope = result.Incomplete_Reason_Envelope__c;
        this.grade = result.Incomplete_Reason_Grades__c;
        this.nameMatch = result.Incomplete_Reason_Name_Match__c;
        this.nameMissing = result.Incomplete_Reason_Name_Missing__c;
        this.offSealMiss = result.Incomplete_Reason_OfficeSeal_Stamp_Miss__c;
        this.offSealNotMatch = result.Incomplete_Reason_OfficeSeal_StampNotMat__c;
        this.otherReason = result.Incomplete_Reason_Other__c;
        this.response = result.Incomplete_Reason_Response__c;
        this.returnReason = result.Incomplete_Reason_Return__c;
        this.signMatch = result.Incomplete_Reason_Signature_Match__c;
        this.signMissing = result.Incomplete_Reason_Signature_Missing__c;
        this.titleMatch = result.Incomplete_Reason_Title_Match__c;
        this.titleMissing = result.Incomplete_Reason_Title_Missing__c;
        this.transcript = result.Incomplete_Reason_Transcript__c;
        this.transSeal = result.Incomplete_Reason_Transcript_Seal__c;
        this.verif = result.Incomplete_Reason_Verification__c;
        this.comments = result.Comments__c;
    }).catch(error=>{
        window.console.error('Error: ', error);
    })
}
connectedCallback(){
    this.getAllIncAffirm();
}
@api
get caseIdFromFlow(){
    return this.caseId;
}
set caseIdFromFlow(val){
    this.caseId = val;
}
handleCheckbox(event){
    if(event.target.name == 'incAuth'){
        this.auth = event.target.checked;
    }
    if(event.target.name == 'incNameMatch'){
        this.nameMatch = event.target.checked;
    }
    if(event.target.name == 'incSealNotMatch'){
        this.offSealNotMatch = event.target.checked;
    }
    if(event.target.name == 'incSealMissing'){
        this.offSealMiss = event.target.checked;
    }
    if(event.target.name == 'incSignMatch'){
        this.signMatch = event.target.checked;
    }
    if(event.target.name == 'incTitleMatch'){
        this.titleMatch = event.target.checked;
    }
    if(event.target.name == 'incVerform'){
        this.compVerForm = event.target.checked;
    }
    if(event.target.name == 'incCredential'){
        this.cred = event.target.checked;
    }
    if(event.target.name == 'incEnvelope'){
        this.envelope = event.target.checked;
    }
    if(event.target.name == 'incNameMiss'){
        this.nameMissing = event.target.checked;
    }
    if(event.target.name == 'incResponse'){
        this.response = event.target.checked;
    }
    if(event.target.name == 'incReturn'){
        this.returnReason = event.target.checked;
    }
    if(event.target.name == 'incSignMiss'){
        this.signMissing = event.target.checked;
    }
    this.handleOtherCheckboxes(event);
}
handleOtherCheckboxes(event){
    if(event.target.name == 'incTitleMiss'){
        this.titleMissing = event.target.checked;
    }
    if(event.target.name == 'incVerification'){
        this.verif = event.target.checked;
    }
    if(event.target.name == 'incOther'){
        this.otherReason = event.target.checked;
    }
    if(event.target.name == 'incMedform'){
        this.compMedform = event.target.checked;
    }
    if(event.target.name == 'incGrade'){
        this.grade = event.target.checked;
    }
    if(event.target.name == 'incTrans'){
        this.transcript = event.target.checked;
    }
    if(event.target.name == 'incTransSeal'){
        this.transSeal = event.target.checked;
    }
}
handletextbox(event){
    this.comments = event.detail.value;
}
handleBackEvent(event){
    this.dispatchEvent(new FlowNavigationBackEvent());
}
handleNextEvent(event){
    this.saveAllAffirmation(this.affirmId);
}
saveAllAffirmation(){
    var otherChecked = this.template.querySelector('.IncReasonOther');
    if(!otherChecked.checked || (otherChecked.checked && this.comments != null)){
        this.showErrorMsg = false;
        this.spinner = true;
        let valuesTosave = {
            currentCaseid : this.caseId,
            affirmId : this.affirmId,
            authorization : this.auth === undefined ? false : this.auth,
            nameMatch : this.nameMatch === undefined ? false : this.nameMatch,
            officeSealNotMatch : this.offSealNotMatch === undefined ? false : this.offSealNotMatch,
            OfficeSealMissing : this.offSealMiss === undefined ? false : this.offSealMiss,
            signatureMatch : this.signMatch === undefined ? false : this.signMatch,
            titleMatching : this.titleMatch === undefined ? false : this.titleMatch,
            completionVerform: this.compVerForm === undefined ? false : this.compVerForm,
            credential : this.cred === undefined ? false : this.cred,
            envelope : this.envelope === undefined ? false : this.envelope,
            nameMissing : this.nameMissing === undefined ? false : this.nameMissing,
            response : this.response === undefined ? false : this.response,
            returnR : this.returnReason === undefined ? false : this.returnReason,
            signMiss : this.signMissing === undefined ? false : this.signMissing,
            titleMiss : this.titleMissing === undefined ? false : this.titleMissing,
            verification : this.verif === undefined ? false : this.verif,
            other : this.otherReason === undefined ? false : this.otherReason,
            completionMedform : this.compMedform === undefined ? false : this.compMedform,
            grades : this.grade === undefined ? false : this.grade,
            transc : this.transcript === undefined ? false : this.transcript,
            transcrSeal : this.transSeal === undefined ? false : this.transSeal,
            comments : this.comments
        }
        saveAffirmationRec({
            affirmDetails : JSON.stringify(valuesTosave)
        }).then(result=>{
            this.spinner = false;
            if(result){
                this.dispatchEvent(new FlowNavigationNextEvent());
            }
        }).catch(error=>{
            window.console.error('Error: ' + JSON.stringify(error));
        }); 
    }
    else{
        this.showErrorMsg = true;
    }
}}