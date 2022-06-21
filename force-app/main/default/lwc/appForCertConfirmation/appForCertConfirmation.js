import { LightningElement, api,wire,track} from 'lwc';
import getCaseNumber from '@salesforce/apex/AppForCertController.getCaseNumber';
import getMetadataId from '@salesforce/apex/AppForCertController.getMetadataId';
import getExamRegCaseNumberRegionChange from '@salesforce/apex/RegionChangeController.getCaseNumber';
import getEPExCaseNumber from '@salesforce/apex/EPExController.getEPExCaseNumber';
import { getRecord } from 'lightning/uiRecordApi';
import getConstantsClass from '@salesforce/apex/ExamRegistrationController.getConstantsClass';

export default class AppForCertConfirmation extends LightningElement {

    @api caseNumber;
    @track metarecordId;
    @track firstLine;
    @track secondLine;
    @track thirdLine;
    @track fourthLine;
    @track fifthLine;
    @track summaryLanguageLine;
    @track examApplicationSummaryLanguageLine;
    @api linkSource;
    @api showExamRegActionButton;
    @track secondLineVar;
    @track secondLineVarRegionchange;
    @track secondLineVarEPEx;
    @track secondLineVarTranscriptReq;
    @api casesListConfScreen;
    @api transcriptCaseNumbers;    

    @track showMessage = false;
    @track spinner = false;
    @track showPageReload = false;
    
    @wire(getMetadataId)
    metadatafromController(result){ 
        if(result.data !== undefined){
        this.metarecordId = result.data;
        }        
    }
     
    @wire(getConstantsClass) 
    allConstants ({error, data}) {
        if (data) {
        this.secondLineVar = data.LWC_METADATA_CONFIRMATIONSCREEN_SECONDLINE;
        this.secondLineVarRegionchange = data.LWC_METADATA_CONFIRMATIONSCREEN_SECONDLINE_REGION_CHANGE;
        this.secondLineVarEPEx = data.LWC_METADATA_CONFIRMATIONSCREEN_SECONDLINE_EPEX;
        this.secondLineVarTranscriptReq = data.LWC_METADATA_CONFIRMATIONSCREEN_SECONDLINE_TRANSCRIPT_REQ;
        this.secondLineVarNonUsmleTranscriptReq = data.LWC_METADATA_CONFIRMATIONSCREEN_SECONDLINE_NON_USMLE_TRANSCRIPT_REQ;
        } else {
        this.error = error;
    }
} 

    @wire(getRecord, { recordId: '$metarecordId', fields: ['Confirmation_Message__mdt.First_Line__c', 'Confirmation_Message__mdt.Second_Line__c', 'Confirmation_Message__mdt.Third_Line__c','Confirmation_Message__mdt.Fourth_Line__c','Confirmation_Message__mdt.Fifth_Line__c','Confirmation_Message__mdt.Summary_Language_Line__c','Confirmation_Message__mdt.Exam_Application_Summary_Language_Line__c'] })
    getMetadata(result){
        if(result.data !== undefined){
            this.firstLine = result.data.fields.First_Line__c.value;
            if(this.linkSource === 'Exam Registration'){
                this.secondLine = this.secondLineVar ;    
                this.caseNumber = this.casesListConfScreen;
                this.examApplicationSummaryLanguageLine = result.data.fields.Exam_Application_Summary_Language_Line__c.value;
            }
            else if(this.linkSource === 'Region Change Request'){
                this.secondLine = this.secondLineVarRegionchange;
            }
            else if(this.linkSource === 'EPEx Request'){
                this.secondLine = this.secondLineVarEPEx;
            }
            else if(this.linkSource === 'Transcript Request'){
                this.secondLine = this.secondLineVarTranscriptReq;
                this.caseNumber = this.transcriptCaseNumbers;
            }
            else if(this.linkSource === 'Non Usmle Transcript Request'){
                this.secondLine = this.secondLineVarNonUsmleTranscriptReq;
                this.caseNumber = this.transcriptCaseNumbers;
            }
            else{
                this.secondLine = result.data.fields.Second_Line__c.value;
                }
            this.thirdLine = result.data.fields.Third_Line__c.value;
            this.fourthLine = result.data.fields.Fourth_Line__c.value;
            this.fifthLine = result.data.fields.Fifth_Line__c.value;
            if(this.linkSource === 'Application For Certification'){
                this.summaryLanguageLine = result.data.fields.Summary_Language_Line__c.value;
            }
            this.showMessage = true;
        }
        this.fetchCaseNumber();
    }

    fetchCaseNumber() {
        if(this.linkSource === 'Region Change Request'){
            this.spinner = true;
            getExamRegCaseNumberRegionChange().then(data=>{
                this.caseNumber = data;  
                this.spinner = false;              
                })
            .catch(error => {
                this.spinner = false;
            });
        } else if(this.linkSource === 'EPEx Request') {
            this.spinner = true;
            getEPExCaseNumber().then(data=>{
                this.caseNumber = data;    
                this.spinner = false;           
                })     
                .catch(error => {
                    this.spinner = false;
                });           
        } else if(this.linkSource === 'Application For Certification') {
            this.spinner = true;
            getCaseNumber().then(data=>{
                this.caseNumber = data;  
                this.spinner = false;              
                })
            .catch(error => {
                this.spinner = false;
            });
        }        
        else {
            if (this.linkSource !== 'Transcript Request' && this.linkSource !== 'Non Usmle Transcript Request' && this.linkSource !== 'Exam Registration' && this.linkSource !== '' && this.linkSource !== undefined) {
                this.spinner = true;
                getCaseNumber().then(data=>{
                    
                    this.caseNumber = data;  
                    this.spinner = false;              
                    })
                .catch(error => {
                    
                    this.spinner = false;
                    });
            }
        }
    }

    connectedCallback() {
        if(this.showExamRegActionButton || this.linkSource === 'EPEx Request' ||  this.linkSource === 'Region Change Request' ||  this.linkSource === 'Transcript Request' || this.linkSource === 'Non Usmle Transcript Request') {
            this.showPageReload = true;
            if (this.showExamRegActionButton) {
                this.linkSource = "Application For Certification";
            }
        }
    }

    cancelButton(event) {
        event.preventDefault();
        const selectEvent = new CustomEvent('cancelevent', {});
        this.dispatchEvent(selectEvent);
    }

    cancelButtonExamReg(event) {
        window.location.reload();
    }
}