import {LightningElement,api,track,wire} from 'lwc';
import getAppBioDetail from '@salesforce/apex/EntityCredVerController.getAppBioDetailMEF';
import getNameDoc from '@salesforce/apex/EntityCredVerController.getNameOnDocMEF';
export default class MedEduFormMain extends LightningElement{
    @api accountId;
    @api recordId;
    @track contactName;
    @track birthDate;
    @track nameOnDoc;
    @track myIntealthId;
    @track uniMedSchId;
    @track spinner = false;
    @track entityMedFormReviewAsset = true;
    @track showquest = false;
    @track showSummary = false;
    @api caseId;
    @api contactId;
    @api stepNumber;
    @api caseNumber;
    activeCaseLabel = 'Active Cases (0)';
    @wire(getAppBioDetail, {caseId: '$recordId'})
    getAppBioDetail(result,error){
        if(result && result.data){
            this.contactName = result.data.Contact.Name;
            this.birthDate = result.data.Contact.Birthdate;
            this.myIntealthId = result.data.MyIntealth_ID__c;
            this.uniMedSchId = result.data.Unique_Medical_School_ID__c;
            switch(this.stepNumber){
                case 2: this.showQuestionnaire();
                break;
                case 3: this.showSummaryScreen();
                break;
                default: this.showReviewDocuments();
            }
        }else if(error){
            window.console.error('Error: ',error);
        }
    }
    @wire(getNameDoc,{caseId: '$caseId'})
    getNameDoc(result,error){
        if(result && result.data){
            this.nameOnDoc = result.data;
        }else if(error){
            window.console.error('Error: ',error);
        }
    }
    showQuestionnaire(){
        this.showquest = true;
        this.showSummary = false;
        this.entityMedFormReviewAsset = false;
    }
    showSummaryScreen(){
        this.showquest = false;
        this.showSummary = true;
        this.entityMedFormReviewAsset = false;
    }
    showCredRevCaseList(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('credrevlist', {});
        this.dispatchEvent(selectEvent);
    }
    showReviewDocuments(){
        this.showquest = false;
        this.showSummary = false;
        this.entityMedFormReviewAsset = true;
    }
    showCaseDet(event){
        const selectEvent = new CustomEvent('nextevent',{detail:event.detail});
        this.dispatchEvent(selectEvent);
    }
    removeComp(){
        this.showquest = false;
        this.showSummary = false;
        this.entityMedFormReviewAsset = false;
    }
    activecount(event){
        this.activeCaseLabel = 'Active Cases ('+event.detail+')';
    }
    handleactiveCaselist(event){
        this.entityCredVerReviewAsset = false;
        this.showCredVerRevForm = false;
        this.showSummary = false;   
        this.showReview = false;
        this.showAddlDoc = false;
        event.preventDefault();
        const selectEvent = new CustomEvent('activecases');
        this.dispatchEvent(selectEvent);
    }
}