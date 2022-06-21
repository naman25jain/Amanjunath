import {LightningElement,api,track,wire} from 'lwc';
import getAppBioDetail from '@salesforce/apex/EntityCredVerController.getAppBioDetail';
import checkDisplayCondition from '@salesforce/apex/EntityCredVerController.checkDisplayCondition';
import showReviewScreen from '@salesforce/apex/EntityCredVerController.showReviewScreen';
import showReviewScreenForTrans from '@salesforce/apex/EntityCredVerController.showReviewScreenForTrans';
import createEcfmgVerForm from '@salesforce/apex/EntityCredVerController.createEcfmgVerForm';
export default class EntityCredVerReview extends LightningElement{
    @api currentEntity;
    @api recordId;
    @api stepNumber;
    @api currentCaseId;
    @api showBackButton;
    @track contactName;
    @track birthDate;
    @track nameOnDoc;
    @track myIntealthId;
    @track uniMedSchId;
    @track spinner = false;
    entityCredVerReviewAsset = true;
    @track showReview = false;
	@track showCredVerRevForm = false;
    @track showAddlDoc = false;
    @track detailObj = null;
    @track selectedValue;
    @track showSummary = false;
    activeCaseLabel = 'Active Cases (0)';
    @api caseNumber;
    @api contactId;
    @wire(getAppBioDetail, {caseId: '$recordId'})
    getAppBioDetail(result,error){
        if(result && result.data){
            this.contactName = result.data.Contact__r.Name;
            this.birthDate = result.data.Contact__r.Birthdate;
            this.nameOnDoc = result.data.Name_on_Document__c;
            this.myIntealthId = result.data.Case__r.MyIntealth_ID__c;
            this.uniMedSchId = result.data.Case__r.Unique_Medical_School_ID__c;
            switch(this.stepNumber){
                case 2: this.handleFromAssetNextButton();
                break;
                case 3: this.showCredReviewScreen();
                break;
                case 4: this.showCredVerRevFormScreen();
                break;
                case 5: this.showSummaryScreen();
                break;
                default: this.previousFromAdditionalDocReview();
            }
        }else if(error){
            window.console.error('Error: ',error);
        }
    }
    handleCredVerReviewList(event){
        this.entityCredVerReviewAsset = false;
        this.showCredVerRevForm = false;
        this.showSummary = false;	
		this.showReview = false;
		this.showAddlDoc = false;
        event.preventDefault();
        const selectEvent = new CustomEvent('credverreviewlist');
        this.dispatchEvent(selectEvent);
    }
    handleFromAssetNextButton(){
        this.entityCredVerReviewAsset = false;
        this.showReview = false;
        this.showCredVerRevForm = false;
        this.showSummary = false;	
        this.showAddlDoc = false;
        this.spinner = true;
        checkDisplayCondition({caseId:this.recordId}).then(display=>{
            if(display){
                this.showAddlDoc = true;
                this.spinner = false;
            }else{
                this.showAddlDoc = false;
                showReviewScreen({caseId:this.recordId}).then(review=>{
                    if(review){
                        this.showReview = true;
                        this.spinner = false;
                    }else{
                        this.spinner = false;
                    }
                })
            }
        })
    }
    showCredVerReviewFormScreen(event){
		this.detailObj = event.detail;
        this.entityCredVerReviewAsset = false;
		this.showCredVerRevForm = true;	
        this.showSummary = false;
		this.showReview = false;
		this.showAddlDoc = false;
	}
	showAddtnDocScreen(){
		this.entityCredVerReviewAsset = false;
		this.showAddlDoc = false;
		this.showCredVerRevForm = false;
        this.showSummary = false;	
		this.showReview = false;
        this.spinner = true;
        checkDisplayCondition({caseId:this.recordId}).then(display=>{
            if(display){
                this.showAddlDoc = true;
                this.spinner = false;
            }else{
                this.showAddlDoc = false;
                this.entityCredVerReviewAsset = true;
                this.spinner = false;
            }
        })	
	}
    nextFromAdditionalDocReview(event){
        this.entityCredVerReviewAsset = false;
        this.showReview = false;
        this.showSummary = false;	
        this.showAddlDoc = false;
        this.showCredVerRevForm = false;
        this.spinner = true;
        if(event.detail === 'Yes'){
            this.selectedValue = 'I Certify This Document';
        }
        else{
            this.selectedValue = 'No Credential';
        }
        showReviewScreen({caseId:this.recordId}).then(review=>{
            if(review){
                showReviewScreenForTrans({caseId:this.recordId}).then(revTrans=>{
                    if(revTrans){
                        createEcfmgVerForm({caseRecordId : this.recordId, selectedEntityId : this.currentEntity, certifiedValue : this.selectedValue}).then(resultForm =>{
                            if(resultForm){
                                this.detailObj = resultForm;
                                const selectEvent = new CustomEvent('nextevent', {});
                                this.dispatchEvent(selectEvent);
                                this.showReview = true;
                                this.spinner = false;
                            }
                        });                
                    }else{
                        this.showReview = true;
                        this.spinner = false;
                    }
                })
            }else{
                createEcfmgVerForm({caseRecordId : this.recordId, selectedEntityId : this.currentEntity, certifiedValue : this.selectedValue}).then(resultForm =>{
                    if(resultForm){
                        this.detailObj = resultForm;
                        const selectEvent = new CustomEvent('nextevent', {});
                        this.dispatchEvent(selectEvent);
                        this.showCredVerRevForm = true;	
                        this.spinner = false;
                    }
                });
            }
        })
    }
    previousFromAdditionalDocReview(){
        this.showReview = false;
        this.showCredVerRevForm = false;
        this.showSummary = false;
        this.showAddlDoc = false;
        this.entityCredVerReviewAsset = true;
    }
    showSummaryScreen(){
        this.entityCredVerReviewAsset = false;
		this.showCredVerRevForm = false;	
		this.showReview = false;
		this.showAddlDoc = false;
        this.showSummary = true;
    }
    showCredUploadScreen(){
        this.entityCredVerReviewAsset = false;
        this.showReview = false;
        this.showCredVerRevForm = false;
        this.showSummary = false;	
        this.showAddlDoc = true;
    }
    showCredVerRevFormScreen(){
        this.entityCredVerReviewAsset = false;
        this.showReview = false;
        this.showCredVerRevForm = true;
        this.showSummary = false;	
        this.showAddlDoc = false;
    }
    showCredReviewScreen(){
        this.entityCredVerReviewAsset = false;
        this.showReview = true;
        this.showCredVerRevForm = false;
        this.showSummary = false;	
        this.showAddlDoc = false;
    }
    handleBacktoSum(event){
        this.entityCredVerReviewAsset = false;
        this.showCredVerRevForm = false;
        this.showSummary = false;	
		this.showReview = false;
		this.showAddlDoc = false;
        event.preventDefault();
        const selectEvent = new CustomEvent('incsummary');
        this.dispatchEvent(selectEvent);

    }
    showCaseDet(event){
        const selectEvent = new CustomEvent('nextevent',{detail:event.detail});
        this.dispatchEvent(selectEvent);
    }
    removeComp(){
        this.showReview = false;
        this.showCredVerRevForm = false;
        this.showSummary = false;
        this.showAddlDoc = false;
        this.entityCredVerReviewAsset = false;
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
        this.currentCaseId = event.detail.currcaseId;
        let currcase = {currId: this.currentCaseId, appId: this.contactId};
        const selectEvent = new CustomEvent('activecases', {detail: currcase});
        this.dispatchEvent(selectEvent);
    }
}