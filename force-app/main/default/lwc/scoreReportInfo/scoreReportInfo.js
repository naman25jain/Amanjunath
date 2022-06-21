import { LightningElement, track, api, wire } from 'lwc';
import getScoreReportInfo from "@salesforce/apex/ScoreReportController.getScoreReportInfo";
import conditionForScoreRecheck from "@salesforce/apex/ScoreReportController.conditionForScoreRecheck";
import checkValidationForWithholdExams from "@salesforce/apex/ScoreReportController.checkValidationForWithholdExams";
import USMLETranscriptLink from "@salesforce/apex/ServicesComponentController.enableUSMLETranscriptLink";
import USMLTranscriptEligibility from "@salesforce/apex/ServicesComponentController.checkUSMLTranscriptEligibility";
import transcriptLinkValidation from "@salesforce/apex/ServicesComponentController.transcriptLinkValidation";
import enableUSMLETranscriptRequestLink from "@salesforce/apex/TranscriptRequestController.enableUSMLETranscriptRequestLink";
import checkValNonUSMLETranLink from "@salesforce/apex/ServicesComponentController.checkValNonUSMLETranLink";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getBase64Pdf from "@salesforce/apex/NBMEScoreReporting.getBase64Pdf";
import PDF_ICON from '@salesforce/resourceUrl/PDF_logo';
import SCORE_REPORT from '@salesforce/resourceUrl/Score_Report_PDF';
import updateOptoutFlag from "@salesforce/apex/ScoreReportController.updateOptoutFlag";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import CONTACT_ID from "@salesforce/schema/User.ContactId";
import getDispContent from '@salesforce/apex/GContentManager.getContentValues';
// this gets you the logged in user
import USER_ID from "@salesforce/user/Id";
const EXAM_TYPE = ['USMLE Step 1','USMLE Step 2 CK','USMLE Step 2 CS'];
import getRestrictedMessage from '@salesforce/apex/RestrictedMessage.getMessage';
import restrictionServiceErrorMessage from "@salesforce/label/c.Restriction_Service_Error_Message";
export default class ScoreReportInfo extends LightningElement {
    @track usmleStep1ScoreList = [];
    @track usmleStep2CKScoreList = [];
    @track usmleStep2CSScoreList = [];
    @track showusmleStep1Score = false;
    @track showusmleStep2CKScore = false;
    @track showusmleStep2CSScore = false;
    @track showNoScoreMessage = false;
    @track showScoreRecheckButton = false;
    @track showScoreRecheck = false;
    @api transcriptCaseNumbers;
    @api showContact;
    @api showConfirmationPage;
    @api linkSource;
    @api casesListConfScreen;
    @api showButtonsBasedOnExamReg = false;
    @api showNonUSMLETranscriptReqButton = false;
    @track scoreReportIcon = PDF_ICON;
    @track scoreReportPdf = SCORE_REPORT;

    @track showScoreReportInfoPage = false;
    @track showScoreRecheckFormPage = false;
    @track showScoreRechkLegalSignOffPage = false;
    @track showScoreRecheckPaymentPage = false;
    @track showScoreRecheckConfirmationPage = false;

    @track showWithholdExaminationResults = false;
    @track showWithholdErrorMessage = false;
    
    @track modalTitle = 'Alert';
    @track modalContent = 'Are you sure you want to cancel? All changes will be lost.';
    @track caseNums = [];
    @track examsList = [];
    @track sbmtButtonEnabled = false;
    @track selectdExm = [];
    @track spinner = false;
    displayContent;
    reversereContent;
    
    //Transcript Requestform
    @track showTranscriptReqButton;
    @track showTranscriptReqError;
    @track transcriptReqError = ''; 
    @track showTranscriptRequestFormPage;
    @track showTranscriptRequestSummaryPage;
    @api showTranscriptRequestfromSummaryPage;
    @track showTranscriptRequestLegalPage;
    @track showTranscriptRequestPaymentPage;

    @track nonUsmletranscriptReqError;
    @track showNonUsmleTranscriptReqError;
    @track caserecordidscore;
    @track caserecordidtransreq;
    USMLECssClass;
    CheckTranscriptReqButton;
    showUSMLETranscriptCheck;
    @api eligibilityMsg;
    intervalId;
    counter = 1;


    @wire(getRecord, { recordId: USER_ID, fields: [CONTACT_ID] })
    user;

    get contactId() {
        return getFieldValue(this.user.data, CONTACT_ID);
    }

    checkUSMLETranscript() {
        USMLETranscriptLink({strContactId : this.contactId})
        .then(data => {
            console.log('result.data => ',data);
            let objData = data;
            console.log(this.counter);
            if(this.counter > 6) {
                clearInterval(this.intervalId);
            }
            if(objData.USMLE_Transcript_Eligible__c) { 
                clearInterval(this.intervalId);
                this.showTranscriptReqButton = true;
                this.showUSMLETranscriptCheck = true;
                this.eligibilityMsg = '';
            }
            else if(objData.USMLE_Transcript_Eligibility_Message__c && !objData.USMLE_Transcript_Eligible__c) {
                this.showTranscriptReqButton = false;
                this.CheckTranscriptReqButton = true;
                this.showUSMLETranscriptCheck = false;
                if(objData.USMLE_Transcript_Eligibility_Message__c != 'We’re checking your eligibility to request a USMLE transcript now. The check may take up to 30 minutes to complete.') {
                    this.USMLECssClass = 'customUSMLCard';
                    clearInterval(this.intervalId);
                }
                else {
                    this.USMLECssClass = 'customCard';
                }

                this.eligibilityMsg = objData.USMLE_Transcript_Eligibility_Message__c;
            }
            else if(!objData.USMLE_Transcript_Eligibility_Message__c && !objData.USMLE_Transcript_Eligible__c) {
                this.CheckTranscriptReqButton = false;
                this.showUSMLETranscriptCheck = false;

            }
        })
        .catch(error => {
            console.log('error => ', error);
            clearInterval(this.intervalId);
        })
    }

    checkEnableTranscriptLink(event) {
        this.spinner = true;
        console.log('this.displayContent ==> '+this.displayContent);
        USMLTranscriptEligibility({strContactId : this.contactId, mapContentData: this.displayContent})
        .then(data => {
            if(data) {
                this.spinner = false;
                this.CheckTranscriptReqButton = true;
                this.USMLECssClass = 'customCard';

                this.eligibilityMsg = data.USMLE_Transcript_Eligibility_Message__c;

                if(!data.USMLE_Transcript_Eligible__c) {
                    this.intervalId = setInterval(() => { 
                        this.counter += 1;
                        this.checkUSMLETranscript();
                    }, 10000);
                }
            }
  
        })
        .catch(error => {
            this.spinner = false;
            console.log('error => ', error);
        })
    }
    transcriptReqlink(){
        let messageWrapper = {"accountId" : '', "contactId" : this.contactId, "caseId" : '', "service" : "USMLE Transcripts - Internal and External"};
        let jsonMessageWrapper = JSON.stringify(messageWrapper);
        getRestrictedMessage({jsonInput: jsonMessageWrapper})
        .then(restrictionresult=>{
            if(restrictionresult){
                const evt = new ShowToastEvent({
                title: 'Restriction Applied',
                message: restrictionServiceErrorMessage,
                variant: 'error'
                });
                this.dispatchEvent(evt);
            }else{
                transcriptLinkValidation()
                .then(result =>{
                    if(result === 'true'){
                        this.linkSource = "Transcript Request";
                        this.showScoreReportInfoPage = false;
                        this.showTranscriptRequestFormPage = true;
                    }else{
                        this.transcriptReqError = result;
                        this.showTranscriptReqError = true;
                    }
                })
            }
        })
    }

    @wire(enableUSMLETranscriptRequestLink)
    showUSMLETranscriptRequestLink(result) {
        if (result.data === 'true') {
            this.showNonUSMLETranscriptReqButton = true;
        }
    }
  
    nonUsmletranscriptReqlink(){
        let messageWrapper = {"accountId" : '', "contactId" : this.contactId, "caseId" : '', "service" : "Non-USMLE Transcripts - Internal and External"};
        let jsonMessageWrapper = JSON.stringify(messageWrapper);
        getRestrictedMessage({jsonInput: jsonMessageWrapper})
        .then(restrictionresult=>{
            if(restrictionresult){
                const evt = new ShowToastEvent({
                title: 'Restriction Applied',
                message: restrictionServiceErrorMessage,
                variant: 'error'
                });
                this.dispatchEvent(evt);
            }else{
                checkValNonUSMLETranLink()
                .then(resultNonUsmle => {
                    if(resultNonUsmle === 'true'){
                        this.linkSource = "Non Usmle Transcript Request";   
                        this.showTranscriptRequestFormPage = true;
                        this.showScoreReportInfoPage = false;
                        this.showWithholdExaminationResults = false;
                        this.showScoreRecheckFormPage = false;
                        this.showScoreRecheckLegalSignOffPage= false;
                        this.showScoreRecheckPaymentPage = false;
                        this.showScoreRecheckConfirmationPage = false;
                        this.showTranscriptRequestSummaryPage = false;
                        this.showTranscriptRequestLegalPage = false;
                        this.showTranscriptRequestPaymentPage = false;
                        this.showConfirmationPage = false;
                    }else{
                        this.nonUsmletranscriptReqError = resultNonUsmle;
                        this.showNonUsmleTranscriptReqError = true;
                    }
                })
            }
        })  
    }



    connectedCallback() {
        getDispContent({lstUniqueNames:['CIBIS_USMLE_TRANSCRIPT_ELIGIBLE_CHECK_MSG', 'CIBIS_USMLE_TRANSCRIPT_NOT_ELIGIBLE_MSG']}).then(data => {
            this.displayContent = data;
            let mapData = new Map(Object.entries(data));
            this.reversereContent = new Map();
            for(let [key, value] of mapData) {
                this.reversereContent = this.reversereContent.set(value.replace(/<[^>]*>/g, ''), key);
            }

            console.log('reverse ===> ', this.reversereContent);
        });

        this.checkUSMLETranscript();

        this.showScoreReportInfoPage = true;
          getScoreReportInfo()
            .then(result => {
                if(result.length > 0) {
                    for(let key in result) {
                        if(result.hasOwnProperty(key)) {
                            let tempRecord = {
                                examId : result[key].examId,
                                examType : result[key].examType,
                                examDate : result[key].examDate,
                                availableUntil : result[key].availableUntil,
                                isAvailable: result[key].isAvailable,
                                pdOptOutFlag: result[key].pdOptOutFlag,
                                withHeldReason: result[key].withHeldReason,
                                withHeldScore: result[key].withHeldScore
                            };
                            
                            if(tempRecord.examType === EXAM_TYPE[0]) {
                                if(this.usmleStep1ScoreList.length > 0 ){
                                    this.usmleStep1ScoreList = [...this.usmleStep1ScoreList,tempRecord];
                                } else {
                                this.usmleStep1ScoreList = [tempRecord];
                                }
                                this.showusmleStep1Score = true; 
                                this.showScoreRecheck = true;
                            }
                            else if(tempRecord.examType === EXAM_TYPE[1]) {
                                if(this.usmleStep2CKScoreList.length > 0 ){
                                    this.usmleStep2CKScoreList = [...this.usmleStep2CKScoreList,tempRecord];
                                } else {
                                this.usmleStep2CKScoreList = [tempRecord];
                                }
                                this.showusmleStep2CKScore = true;
                                this.showScoreRecheck = true;
                            }
                            else if(tempRecord.examType === EXAM_TYPE[2]) {
                                if(this.usmleStep2CSScoreList.length > 0 ){
                                    this.usmleStep2CSScoreList = [...this.usmleStep2CSScoreList,tempRecord];
                                } else {
                                this.usmleStep2CSScoreList = [tempRecord];
                                }
                                this.showusmleStep2CSScore = true;
                                this.showScoreRecheck = true;
                            }
                        }
                    } 
                }
                else {
                    this.showNoScoreMessage = true;
                }

                conditionForScoreRecheck()
                    .then(resultval => {
                        if (resultval && this.showScoreRecheck === true) {
                            this.showScoreRecheckButton = true;
                        }
                        else { 
                            this.showScoreRecheckButton = false;
                        }
                    })
                    .catch(error => {
                        window.console.log('Error: ' + JSON.stringify(error));
                    });
                })
            .catch(error => {
                window.console.log('Error: ' + JSON.stringify(error));
            });    
    }
    

    showApplicableExams() {
        checkValidationForWithholdExams()
        .then(result => {
            if (result.length > 0) {
                this.examsList = [];
                for (let key in result) {
                    if (result.hasOwnProperty(key)) {
                        let tempRecord = {
                            examId: result[key].examId,
                            examType: result[key].examType,
                            examDate: result[key].examDate,
                            testAccomodation: result[key].testAccomodation,
                            regionName: result[key].regionName,
                        };
                        this.examsList.push(tempRecord);
                        this.showWithholdExaminationResults = true;
                        this.showScoreReportInfoPage = false;
                    }
                }
            }
            else {
                this.showWithholdErrorMessage = true;
            }
        })
    }

    handleCheckboxChange(event) {
        let tempShowButton = 0;
        let selectedExams = [];
        this.template.querySelectorAll(".withholdcheckbox")
            .forEach(elem => {
                if (elem.checked === true) {
                    tempShowButton = tempShowButton + 1;
                    this.sbmtButtonEnabled = true;
                    selectedExams.push(elem.name);
                }
                else {
                    if (tempShowButton === 0) {
                        this.sbmtButtonEnabled = false;
                    }
                }
                   
            });
        this.selectdExm = JSON.stringify(selectedExams);
    }

    openModal(){
        this.template.querySelector('c-modal-component').show();
    }
    
    handleYesClick() {
        this.showWithholdExaminationResults = false;
        this.showScoreReportInfoPage = true;
        this.showWithholdErrorMessage = false;
        this.sbmtButtonEnabled = false;
    }

    nextButton() {
        this.spinner = true;
        updateOptoutFlag({
            examsSelected : this.selectdExm
        })
            .then(result => {
                this.spinner = false;
                this.showWithholdExaminationResults = false;
                this.showScoreReportInfoPage = true;
                this.showWithholdErrorMessage = false;
        })
        .catch(error => {
            this.spinner = false;
            
        });
    }

    showScoreRecheckForm(){
        let messageWrapper = {"accountId" : '', "contactId" : this.contactId, "caseId" : '', "service" : "Score Rechecks - Internal and External"};
        let jsonMessageWrapper = JSON.stringify(messageWrapper);
        getRestrictedMessage({jsonInput: jsonMessageWrapper})
        .then(restrictionresult=>{
            if(restrictionresult){
                const evt = new ShowToastEvent({
                title: 'Restriction Applied',
                message: restrictionServiceErrorMessage,
                variant: 'error'
                });
                this.dispatchEvent(evt);
            }else{
                this.showScoreReportInfoPage = false;
                this.showScoreRecheckFormPage = true;
                this.showScoreRecheckLegalSignOffPage = false;
                this.showScoreRecheckPaymentPage = false;
                this.showScoreRecheckConfirmationPage = false;
                this.showConfirmationPage = false;
                this.showTranscriptRequestFormPage = false;
                this.showTranscriptRequestSummaryPage = false;
                this.showTranscriptRequestfromSummaryPage = false;
                this.showTranscriptRequestLegalPage = false;
                this.showTranscriptRequestPaymentPage = false;
            }
        })
    }
    showScoreRecheckLegalSignOff(){
        this.showScoreReportInfoPage = false;
        this.showScoreRecheckFormPage = false;   
        this.showScoreRecheckLegalSignOffPage = true;  
        this.showScoreRecheckPaymentPage = false;
        this.showScoreRecheckConfirmationPage = false;
        this.showConfirmationPage = false;
        this.showTranscriptRequestFormPage = false;
        this.showTranscriptRequestSummaryPage = false;
        this.showTranscriptRequestfromSummaryPage = false;
        this.showTranscriptRequestLegalPage = false;
        this.showTranscriptRequestPaymentPage = false;
    }
    showScoreRecheckPayment(event){
        this.caserecordidscore = event.detail.caserecordidscore;
        this.showScoreReportInfoPage = false;
        this.showScoreRecheckFormPage = false;   
        this.showScoreRecheckLegalSignOffPage = false;  
        this.showScoreRecheckPaymentPage = true; 
        this.showScoreRecheckConfirmationPage = false;  
        this.showConfirmationPage = false;
        this.showTranscriptRequestFormPage = false;
        this.showTranscriptRequestSummaryPage = false;
        this.showTranscriptRequestfromSummaryPage = false;
        this.showTranscriptRequestLegalPage = false;
        this.showTranscriptRequestPaymentPage = false;
    }
    showScoreRecheckConfirmation(event){
        this.caseNums = event.detail;
        this.showScoreReportInfoPage = false;
        this.showScoreRecheckFormPage = false;   
        this.showScoreRecheckLegalSignOffPage = false;  
        this.showScoreRecheckPaymentPage = false; 
        this.showScoreRecheckConfirmationPage = true;
        this.showConfirmationPage = false;
        this.showTranscriptRequestFormPage = false;
        this.showTranscriptRequestSummaryPage = false;
        this.showTranscriptRequestfromSummaryPage = false;
        this.showTranscriptRequestLegalPage = false;
        this.showTranscriptRequestPaymentPage = false;  
    }
    showTranscriptRequestForm(){
        this.showScoreReportInfoPage = false;
        this.showScoreRecheckFormPage = false;   
        this.showScoreRecheckLegalSignOffPage = false;  
        this.showScoreRecheckPaymentPage = false; 
        this.showScoreRecheckConfirmationPage = false;
        this.showConfirmationPage = false;
        this.showTranscriptRequestFormPage = true;
        this.showTranscriptRequestfromSummaryPage = true;
        this.showTranscriptRequestSummaryPage = false;
        this.showTranscriptRequestLegalPage = false;
        this.showTranscriptRequestPaymentPage = false;
    }
    showTranscriptRequestSummary(){
        this.showScoreReportInfoPage = false;
        this.showScoreRecheckFormPage = false;   
        this.showScoreRecheckLegalSignOffPage = false;  
        this.showScoreRecheckPaymentPage = false; 
        this.showScoreRecheckConfirmationPage = false;
        this.showConfirmationPage = false;
        this.showTranscriptRequestFormPage = false;
        this.showTranscriptRequestfromSummaryPage = false;
        this.showTranscriptRequestSummaryPage = true;
        this.showTranscriptRequestLegalPage = false;
        this.showTranscriptRequestPaymentPage = false;

    }
    showTranscriptRequestLegal(){
        this.showScoreReportInfoPage = false;
        this.showScoreRecheckFormPage = false;   
        this.showScoreRecheckLegalSignOffPage = false;  
        this.showScoreRecheckPaymentPage = false; 
        this.showScoreRecheckConfirmationPage = false;
        this.showConfirmationPage = false;
        this.showTranscriptRequestFormPage = false;
        this.showTranscriptRequestfromSummaryPage = false;
        this.showTranscriptRequestSummaryPage = false;
        this.showTranscriptRequestLegalPage = true;
        this.showTranscriptRequestPaymentPage = false;
    }
    showTranscriptRequestPayment(event){
        this.caserecordidtransreq = event.detail.caserecordidtransreq;
        this.showScoreReportInfoPage = false;
        this.showScoreRecheckFormPage = false;   
        this.showScoreRecheckLegalSignOffPage = false;  
        this.showScoreRecheckPaymentPage = false; 
        this.showScoreRecheckConfirmationPage = false;
        this.showConfirmationPage = false;
        this.showTranscriptRequestFormPage = false;
        this.showTranscriptRequestfromSummaryPage = false;
        this.showTranscriptRequestSummaryPage = false;
        this.showTranscriptRequestLegalPage = false;
        this.showTranscriptRequestPaymentPage = true;
    }
    showConfirmation(event){
        this.casesListConfScreen = event.detail;
        this.transcriptCaseNumbers = event.detail;
        window.console.log('this.transcriptCaseNumbers',this.transcriptCaseNumbers);
        this.showScoreReportInfoPage = false;
        this.showScoreRecheckFormPage = false;   
        this.showScoreRecheckLegalSignOffPage = false;  
        this.showScoreRecheckPaymentPage = false; 
        this.showScoreRecheckConfirmationPage = false;
        this.showConfirmationPage = true;
        this.showTranscriptRequestFormPage = false;
        this.showTranscriptRequestfromSummaryPage = false;
        this.showTranscriptRequestSummaryPage = false;
        this.showTranscriptRequestLegalPage = false;
        this.showTranscriptRequestPaymentPage = false;
    }
    //Cancel Transcript Request
  
    cancelTranscriptRequest() {
        this.showScoreReportInfoPage = true;
        this.showScoreRecheckFormPage = false;   
        this.showScoreRecheckLegalSignOffPage = false;  
        this.showScoreRecheckPaymentPage = false; 
        this.showScoreRecheckConfirmationPage = false;
        this.showConfirmationPage = false;
        this.showTranscriptRequestFormPage = false;
        this.showTranscriptRequestfromSummaryPage = false;
        this.showTranscriptRequestSummaryPage = false;
        this.showTranscriptRequestLegalPage = false;
        this.showTranscriptRequestPaymentPage = false;   
    }
    confirmAndCancel(){
        window.location.reload();
    }
    cancelScoreRecheck(){
        this.showScoreReportInfoPage = true;
        this.showScoreRecheckFormPage = false;
        this.showScoreRecheckLegalSignOffPage = false;
        this.showScoreRecheckPaymentPage = false;
        this.showScoreRecheckConfirmationPage = false;
        window.location.reload();
    }
    downloadScoreReport(event){
        let tempFileName = 'ScoreReporting.pdf';
        var id = this.template.querySelector("div.exam").id;         
        var eid = id.substring(0, 18); 
        getBase64Pdf({  
            examId: eid    
        }).then(data=>{
          var bbody = data; 
          var byteCharacters = atob(bbody);
          var byteCharacters = atob(bbody.replace(/^data:image\/(png|jpeg|jpg);base64,/, ''));                
          const buf = new Array(byteCharacters.length);
          for (var i = 0; i != byteCharacters.length; ++i) buf[i] = byteCharacters.charCodeAt(i);      
          const view = new Uint8Array(buf);      
          const blob = new Blob([view], {
              type: 'application/octet-stream'
          });
          const a = window.document.createElement('a');
          a.href = window.URL.createObjectURL(blob);
          a.download = tempFileName;
          document.body.appendChild(a);
          a.click();
          document.body.removeChild(a);
        }).catch(error => {
            dispatchEvent(
                new ShowToastEvent({
                    title: 'Error downloading Score Reporting!',
                    message: error.message,
                    variant: 'error',
                })
            );
        })
      } 
}