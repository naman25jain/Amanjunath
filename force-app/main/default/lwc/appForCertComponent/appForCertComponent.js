import {LightningElement, wire,  track, api} from "lwc";
import {refreshApex} from "@salesforce/apex";
import getOFACAccessCheck from "@salesforce/apex/ServicesComponentController.getOFACAccessCheck";
import getAccountEstablishment from "@salesforce/apex/ServicesComponentController.getAccountEstablishment";
import getContactId from "@salesforce/apex/ServicesComponentController.getContactId";
import headerMessage from "@salesforce/label/c.App_For_Cert_Heading_Message";
import discardMessage from "@salesforce/label/c.App_For_Cert_Discard_Message";
import restrictionServiceErrorMessage from "@salesforce/label/c.Restriction_Service_Error_Message";
import getContactAssociationOrStaging from "@salesforce/apex/AppForCertController.getContactAssociationOrStaging";
import getStepNumber from "@salesforce/apex/ServicesComponentController.getStepNumber";
import isApplicantStudentOrGraduate from "@salesforce/apex/AppForCertController.isApplicantStudentOrGraduate";
import deleteExamRegRecordTypeRecords from "@salesforce/apex/AppForCertController.deleteExamRegRecordTypeRecords";
import getApplicationStatus from "@salesforce/apex/AppForCertController.getApplicationStatus";
import checkIfCertified from "@salesforce/apex/AppForCertController.checkIfCertified";
import checkValidationUpdateMyAppClick from "@salesforce/apex/ServicesComponentController.checkValidationUpdateMyAppClick";
import getRestrictedMessage from '@salesforce/apex/RestrictedMessage.getMessage';
import {ShowToastEvent} from 'lightning/platformShowToastEvent'; 
export default class AppForCertComponent extends LightningElement{
  @track appForCertError = "";
  @track ofacReturnMsg = "";
  @track accountReturnMsg = "";
  @track showError;
  @track showButton;
  @api showContact;
  @api showMedicalDetails;
  @api showExamRegScrTwo;
  @api showOtherMedSchool;
  @api showOtherInstitutions;
  @api showGraduateOnly;
  @api showReporterQuestion;
  @api showSummaryPage;
  @api showLegalLanguage;
  @api showHeader;
  @api showPaymentPage;
  @api showConfirmationPage;
  @track contactId;
  @track spinner = false;
  @track appStatus;
  @track examRegDiscard;
  @api objectId;
  @api objectType;
  @api showButtonsBasedOnExamReg = false;
  @api showExamRegActionButton;
  @track showExamRegButton;
  @api examRegId;
  @api linkSource;
  @track isGraduate;
  @track headerMethodCalled = true;
  @api directlyToNext;
  @api showAlreadyDiplomaUploaded;
  @api showNewlyDeanUploaded;
  _wiredAccResult;
  _wiredOfacResult;
  @api casesListConfScreen;
  @api transcriptCaseNumbers;
  @track showUpdateMyAppButton = false;
  @api reSubmitFromAppForCert = false;
  @track modalTitle = 'Alert';
  @track modalContent = 'Are you sure you want to continue? If you agree, all your changes to this Application for Certification case would be discarded.';
  @track showErrorUpdateButton = false;
  @track serviceValue = 'Application for Certification - Internal and External';
  @track caseRecordId;
  discardEvent;
  constructor() {
    super();
    this.getContactAssocObjIdAndName(false);
  }
  @wire(getContactId)
  contactIdfromController({
    data
  }) {
    this.contactId = data;
  }
  @wire(getOFACAccessCheck)
  ofacChecked(result) {
    this._wiredOfacResult = result;
    this.ofacReturnMsg = result.data;
    if (result.data !== "Success" && result.data !== undefined) {
      this.appForCertError = result.data;
    }
  }
  @wire(getStepNumber)
  stepNumberProgress(result) {
    if (result.data === "AccountEst") {
      this.stepNumber = "1";
      this.showButton = true;
      this.showExamRegButton = false;
      this.showRegionChangeButton = false;
    } else if (result.data === "AppForCert") {
      this.stepNumber = "2";
      this.showExamRegButton = false;
      this.showButton = true;
      this.showRegionChangeButton = false;
    } else if (result.data === "ExamReg") {
      this.stepNumber = "3";
      this.showExamRegButton = true;
      this.showButton = false;
    }
  }
  @wire(getAccountEstablishment)
  accountEstablished(result) {
    this._wiredAccResult = result;
    this.accountReturnMsg = result.data;
    if (this.stepNumber === "2" || this.stepNumber === "1" && result.data !== undefined) {
      if (result.data !== "Success") {
        this.appForCertError = result.data;
      }
    }
  }
  label = {
    headerMessage
  };
  validateApplink(){    
    let messageWrapper = {"accountId" : '', "contactId" : this.contactId, "caseId" : '', "service" : this.serviceValue};
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
          if(this.accountReturnMsg === "Success" && this.ofacReturnMsg === "Success"){
            this.showProfileReivew();
            this.linkSource = "Application For Certification";
          }else{
            this.showError = true;
          }
        }
    });
  }
  // Added by Ajoy
  showHeaderSection() {
    this.showMedicalDetails = false;
    this.showHeader = true;
    if (this.showButtonsBasedOnExamReg) {
      this.showMedicalDetails = true;
      this.showHeader = false;
    }
    this.showContact = false;
    this.showOtherMedSchool = false;
    this.showOtherInstitutions = false;
    this.showGraduateOnly = false;
    this.showReporterQuestion = false;
    this.showSummaryPage = false;
    this.showLegalLanguage = false;
    this.showPaymentPage = false;
    this.showConfirmationPage = false;
    this.showError = false;
    this.examRegDiscard = false;
  }
  showProfileReivew() {
    this.showContact = true;
    this.showMedicalDetails = false;
    this.showOtherMedSchool = false;
    this.showOtherInstitutions = false;
    this.showGraduateOnly = false;
    this.showReporterQuestion = false;
    this.showSummaryPage = false;
    this.showLegalLanguage = false;
    this.showPaymentPage = false;
    this.showConfirmationPage = false;
    this.showHeader = false;
    this.examRegDiscard = false;
  }
  showDegMedSchoolDetails() {
    this.showContact = false;
    this.showMedicalDetails = true;
    if (this.linkSource === "Exam Registration") {
      this.showMedicalDetails = false;
      this.examRegDiscard = true;
    }
    this.showAppForCertSummary = false;
    this.showOtherMedSchool = false;
    this.showOtherInstitutions = false;
    this.showGraduateOnly = false;
    this.showReporterQuestion = false;
    this.showSummaryPage = false;
    this.showLegalLanguage = false;
    this.showPaymentPage = false;
    this.showConfirmationPage = false;
    this.showHeader = false;
  }
  showOtherMedSchoolDetails(event) {
    this.getContactAssocObjIdAndName(false);
    this.caseRecordId = event.detail.caserecordid;
    this.examRegDiscard = false;
    this.showContact = false;
    this.showMedicalDetails = false;
    this.showOtherMedSchool = true;
    this.showOtherInstitutions = false;
    this.showGraduateOnly = false;
    this.showReporterQuestion = false;
    this.showSummaryPage = false;
    this.showPaymentPage = false;
    this.showLegalLanguage = false;
    this.showConfirmationPage = false;
    this.showHeader = false;
  }
  showOtherInst() {
    this.showContact = false;
    this.examRegDiscard = false;
    this.showMedicalDetails = false;
    this.showOtherMedSchool = false;
    this.showOtherInstitutions = true;
    this.showGraduateOnly = false;
    this.showReporterQuestion = false;
    this.showSummaryPage = false;
    this.showLegalLanguage = false;
    this.showPaymentPage = false;
    this.showConfirmationPage = false;
    this.showHeader = false;
  }
  showGradOnlyScreen(event) {
    this.showAlreadyDiplomaUploaded = event.detail;
    this.showContact = false;
    this.examRegDiscard = false;
    this.showMedicalDetails = false;
    this.showOtherMedSchool = false;
    this.showOtherInstitutions = false;
    this.showGraduateOnly = true;
    this.showReporterQuestion = false;
    this.showSummaryPage = false;
    this.showLegalLanguage = false;
    this.showPaymentPage = false;
    this.showConfirmationPage = false;
    this.showHeader = false;
  }
  showRepQuestion() {
    this.showContact = false;
    this.examRegDiscard = false;
    this.showMedicalDetails = false;
    this.showOtherMedSchool = false;
    this.showOtherInstitutions = false;
    this.showGraduateOnly = false;
    this.showReporterQuestion = true;
    this.showSummaryPage = false;
    this.showLegalLanguage = false;
    this.showPaymentPage = false;
    this.showConfirmationPage = false;
    this.showHeader = false;
  }
  showSummary(event) {
    this.directlyToNext = event.detail; //this is used when called from Graduate screen summaryevent event only
    if (event.detail.source === 'graduateScreen') {
      if (event.detail.uploadDiploma != '' && event.detail.uploadDiploma != null && event.detail.uploadDiploma != undefined) {
        this.showAlreadyDiplomaUploaded = event.detail.uploadDiploma;
      } else {
        this.showAlreadyDiplomaUploaded = false;
      }
      if (event.detail.uploadDean != '' && event.detail.uploadDean != null && event.detail.uploadDean != undefined) {
        this.showNewlyDeanUploaded = event.detail.uploadDean;
      } else {
        this.showNewlyDeanUploaded = false;
      }
      if (this.showNewlyDeanUploaded || this.showAlreadyDiplomaUploaded) {
        this.directlyToNext = false;
      }
    }
    this.showContact = false;
    this.showMedicalDetails = false;
    this.showOtherMedSchool = false;
    this.showOtherInstitutions = false;
    this.showGraduateOnly = false;
    this.showReporterQuestion = false;
    this.showSummaryPage = true;
    this.showLegalLanguage = false;
    this.showPaymentPage = false;
    this.showConfirmationPage = false;
    this.examRegDiscard = false;
    this.showHeader = false;
  }
  showLegalLang() {
    this.showContact = false;
    this.showMedicalDetails = false;
    this.showOtherMedSchool = false;
    this.showOtherInstitutions = false;
    this.showGraduateOnly = false;
    this.showReporterQuestion = false;
    this.showSummaryPage = false;
    this.showLegalLanguage = true;
    this.showPaymentPage = false;
    this.examRegDiscard = false;
    this.showConfirmationPage = false;
    this.showHeader = false;
  }
  showPayment() {
    this.showContact = false;
    this.showMedicalDetails = false;
    this.showOtherMedSchool = false;
    this.showOtherInstitutions = false;
    this.showGraduateOnly = false;
    this.showReporterQuestion = false;
    this.showSummaryPage = false;
    this.showLegalLanguage = false;
    this.showPaymentPage = true;
    this.showConfirmationPage = false;
    this.examRegDiscard = false;
    this.showHeader = false;
  }
  showConfirmation(event) {
    this.casesListConfScreen = event.detail;
    this.transcriptCaseNumbers = event.detail;
    this.showContact = false;
    this.showMedicalDetails = false;
    this.showOtherMedSchool = false;
    this.showOtherInstitutions = false;
    this.showGraduateOnly = false;
    this.showReporterQuestion = false;
    this.showSummaryPage = false;
    this.showLegalLanguage = false;
    this.showPaymentPage = false;
    this.showConfirmationPage = true;
    this.examRegDiscard = false;
    this.showHeader = false;
  }
  cancelAppForCert() {
    window.location.reload();
  }
  getContactAssocObjIdAndName(showExamRegActionButtonParam) {
    // Getting Object Id and Object Name
    getContactAssociationOrStaging({
        showExamRegActionButton: showExamRegActionButtonParam
      })
      .then(result => {
        if (result) {
          this.objectId = result.split(",")[0];
          this.objectType = result.split(",")[1];
          this.caseStatus = result.split(",")[2];
          if (showExamRegActionButtonParam === true) {
            this.showButtonsBasedOnExamReg = true;
            this.linkSource = "Application For Certification";
          }
        } else {
          this.showHeaderSection();
        }
      })
      .catch(error => {
        window.console.log("Error: " + JSON.stringify(error));
      });
  }
  showAppForCertScreen1(){
    let messageWrapper = {"accountId" : '', "contactId" : this.contactId, "caseId" : '', "service" : this.serviceValue};
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
        checkValidationUpdateMyAppClick()
        .then(result=>{
          if(result != '' && result != undefined){
            this.appForCertError = result;
            this.showErrorUpdateButton = true;
          }else{
            this.showProfileReivew();
            this.getContactAssocObjIdAndName(true);
            this.reSubmitFromAppForCert = true;
          }
        })
      }
    })
  }
  handleYesClick() {
    this.spinner = true;
    // Delete the record in Contact Association Type Staging. Record Type - Exam Registration - Degree Medical School
    if (this.reSubmitFromAppForCert) {
      deleteExamRegRecordTypeRecords()
        .then(delresult => {
          if (delresult === "true") {
            window.location.reload();
          } else {
            window.console.log("Delete Error:", delresult);
          }
        })
        .catch(error => {
          window.console.log("Error: " + JSON.stringify(error));
        });
    } else {
      deleteExamRegRecordTypeRecords()
        .then(delresult => {
          if (delresult === "true") {
            this.spinner = false;
            this.linkSource = "Exam Registration";
            this.showDegMedSchoolDetails();
          } else {
            window.console.log("Delete Error:", delresult);
          }
        })
        .catch(error => {
          window.console.log("Error: " + JSON.stringify(error));
        });
    }
    if (this.discardEvent.eventSource === 'otherMedSchool') {
      if (this.discardEvent.performDelete) {
        this.template.querySelector('c-other-med-school').deleteOnDiscardEvent(this.discardEvent.assetIdsToBeDeleted);
      }
    }
  }
  discardAppForCert(event) {
    this.spinner = true;
    this.discardEvent = event;
    if (this.reSubmitFromAppForCert) {
      this.template.querySelector('c-modal-component').show();
    } else {
      this.modalContent = discardMessage;
      this.template.querySelector('c-modal-component').show();
    }
  }
  connectedCallback() {
    //check if applicant is graduate or not on load of page
    isApplicantStudentOrGraduate().then(data => {
      this.isGraduate = data;
    });
    getApplicationStatus().then(result => {
      this.appStatus = result;
      checkIfCertified().then(certifiedResult =>{
        if(certifiedResult){
          this.showUpdateMyAppButton = false;
        }else if(this.appStatus === 'Accepted'){
          this.showUpdateMyAppButton = true;
        }
      });
    });
  }
  getUrlParamValue(url, key) {
    return new URL(url).searchParams.get(key);
  }
  renderedCallback() {
    if (this.headerMethodCalled === true) {
      this.showHeaderSection();
      this.headerMethodCalled = false;
    }
    if (this._wiredOfacResult.data !== undefined) {
      refreshApex(this._wiredOfacResult);
    }
    if (this._wiredAccResult.data !== undefined) {
      refreshApex(this._wiredAccResult);
    }
  }
}