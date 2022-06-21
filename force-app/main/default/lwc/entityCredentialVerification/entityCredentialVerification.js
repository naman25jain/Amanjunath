import {LightningElement,api,track} from 'lwc';
import getCaseDetail from '@salesforce/apex/CaseController.getCaseDetail';
import getPriorCaseStatus from '@salesforce/apex/EntityCredVerController.getPriorCaseStatus';
export default class EntityCredentialVerification extends LightningElement{
    @track curEntity;
    credVerReviewListView = true;
    @api recordId;
    @api val = false;
    @api showBack = false;
    stepNumber;
    contactId;
    @track caseRecordType;
    @track showCredVerCase = false;
    @track showMedEduCase = false;
    @track showIncSumScreen = false;
    @track insIncScreen = 0;
    @track showActiveCases = false;
    @api
    get currentEntity(){
        return this.curEntity;
    }
    set currentEntity(value){
        this.setAttribute('currentEntity', value);
        this.curEntity = value;
    }
    handleCredVerReviewList(){
        this.showCredVerCase = false;
        this.showMedEduCase = false;
        this.showIncSumScreen = false;
        this.credVerReviewListView = true;
        this.showActiveCases = false;
    }
    handleback(){
        this.showCredVerCase = false;
        this.showMedEduCase = false;
        this.showIncSumScreen = true;
        this.credVerReviewListView = false;
        this.showActiveCases = false;
    }
    showActiveCaseList(event){
        this.showCredVerCase = false;
        this.showMedEduCase = false;
        this.showIncSumScreen = false;
        this.credVerReviewListView = false;
        this.showActiveCases = true;
    }
    showCaseDet(event){
        this.recordId = event.detail.caseId;
        this.stepNumber = event.detail.stepNumber;
        this.caseNumber = event.detail.caseNumber;
        getPriorCaseStatus({caseId: this.recordId})
        .then(data=>{
            if((data.OldValue == 'Verification In Review at ECFMG' && data.NewValue != 'Sent for Verification' || data.OldValue == 'Incomplete - Resent for Verification') && (this.stepNumber == 0 || this.stepNumber == undefined) && this.insIncScreen == 0){
                this.val = true;
                this.showBack = true;
                this.showIncSumScreen = true;
                this.showActiveCases = false;
                this.credVerReviewListView = false;
                this.insIncScreen = this.insIncScreen + 1;
            }
            else{
                if(!(data.OldValue == 'Incomplete - Resent for Verification' && data.NewValue == 'In Review at Entity')){
                    this.val = false;
                }
                else if((data.OldValue == 'Incomplete - Resent for Verification' && data.NewValue == 'In Review at Entity' && this.stepNumber != 0 && this.showBack == true)){
                    this.val = true;
                }
                getCaseDetail({caseId: this.recordId})
                .then(result=>{
                    if(result){
                        this.showCredVerCase = false;
                        this.showMedEduCase = false;
                        this.caseRecordType = result.RecordType.DeveloperName;
                        if(this.caseRecordType == 'Credential_Verification'){
                            this.showCredVerCase = true;
                        }else if(this.caseRecordType == 'Medical_Education_Form'){
                            this.showMedEduCase = true;
                        }
                        this.contactId = result.ContactId;
                        this.credVerReviewListView = false;
                        this.showIncSumScreen = false;
                        this.showActiveCases = false;
                    }
                })
            }
        }).catch(error=>{
            window.console.error('Error: ',error);
        })
    }
}