import { LightningElement, wire, track, api } from "lwc";
import { refreshApex } from "@salesforce/apex";
import getOFACAccessCheck from "@salesforce/apex/ServicesComponentController.getOFACAccessCheck";
import getAccountEstablishment from "@salesforce/apex/ServicesComponentController.getAccountEstablishment";
import getContactId from "@salesforce/apex/ServicesComponentController.getContactId";
import getExamRegistrations from "@salesforce/apex/ExamRegistrationController.getExamRegistrationsForStatus";
import getPriorExamRegistrations from "@salesforce/apex/ExamRegistrationController.getExamRegistrationPriorRecords";
import enableEligPeriodExtRequestOnBiographic from "@salesforce/apex/EPExController.extRequestOnBiographic";
// Custom Labels
import headerMessage from "@salesforce/label/c.App_For_Cert_Heading_Message";
import discardMessage from "@salesforce/label/c.App_For_Cert_Discard_Message";
// Custom Apex
import getContactAssociationOrStaging from "@salesforce/apex/AppForCertController.getContactAssociationOrStaging";
import getStepNumber from "@salesforce/apex/ServicesComponentController.getStepNumber";
import isApplicantStudentOrGraduate from "@salesforce/apex/AppForCertController.isApplicantStudentOrGraduate";
import deleteExamRegRecordTypeRecords from "@salesforce/apex/AppForCertController.deleteExamRegRecordTypeRecords";
import getEligibleRegionChangeCases from "@salesforce/apex/ExamRegistrationController.getEligibleRegionChangeCases";
import regionChangeCasesValidation from "@salesforce/apex/ExamRegistrationController.regionChangeCasesValidation";
import enableEligPeriodExtRequest from "@salesforce/apex/EPExController.enableEligPeriodExtRequest";
import cancelRegionChangeRequest from "@salesforce/apex/RegionChangeController.cancelRegionChangeRequest";
import getFileUrlWithSAS from '@salesforce/apex/CloudStorageUtils.getFileUrlWithSAS';
import downloadEpermit from "@salesforce/apex/NBMEEPermit.getBase64Pdf";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRestrictedMessage from '@salesforce/apex/RestrictedMessage.getMessage';
import restrictionServiceErrorMessage from "@salesforce/label/c.Restriction_Service_Error_Message";
import checkUSMLEStepLimitAttempted from "@salesforce/apex/ExamRegistrationController.checkUSMLEStepLimitAttempted";
export default class ExamRegistrationComponent extends LightningElement {
  @track stepNumber;
  @track showPrior;
  @track ofacError = "";
  @track ofacReturnMsg = "";
  @track accountReturnMsg = "";
  @track showError;
  @track showLimitError;
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
  @api showAppForCertSummary;
  @api showPreviousLicense;
  @api showBackToSummary;
  @track contactId;
  @track showSixthScreen;
  @track spinner = false;
  @track showExamRegList;
  @track showPriorExamRegList;
  @track showExamRegMsg;
  @track showPriorExamRegMsg;
  @track showAppForSertMsg;
  @api objectId;
  @api objectType;
  @api showButtonsBasedOnExamReg = false;
  @track showExamRegActionButton = false;
  @track showExamRegButton;
  @api examRegId;
  @api linkSource;
  @track isGraduate;
  @track showPerformanceScreen;
  @track showManageExamScreen;
  @track showExamRegScrFour;
  @track showExamRegLandingPage;
  @track showExamRegSummary;
  // Region Change Request
  @track regionChangeSection;
  @track showRegionChangeManageScreenPage;
  @track showRegionChangeSummaryPage;
  @track showRegionChangeLegalPage;
  @track showShoppingCartPage;
  @track showRegionChangePaymentPage;
  @track showEPExForm;
  @track showEPExSummaryPage;
  @track showEPExLegalPage;
  @track showEPExPaymentPage;
  @track headerMethodCalled = true;

  _wiredAccResult;
  _wiredOfacResult;

  @track showRegionChangeButton;
  @track regionChangeError = '';
  @track showRegionError;
  @api casesListConfScreen;
  @api transcriptCaseNumbers;
  @track showEPeriodExtButton;
  @track showEPeriodError;
  @track showEPeriodErrorVal;
  @track ePeriodExtError = '';
  @track ePeriodExtErrorVal = '';
  @track caserecordidepex;
  @track caserecordidexamreg;
  @track caserecordidregionchange;
  constructor(){
    super();
    this.getContactAssocObjIdAndName(false);
  }
  @wire(getContactId)
  contactIdfromController({ data }) {
    this.contactId = data;
  }
  @wire(getOFACAccessCheck)
  ofacChecked(result) {
    this._wiredOfacResult = result;
    this.ofacReturnMsg = result.data;
    if (result.data !== "Success" && result.data !== undefined) {
      this.ofacError = result.data;
    }
  }
  @wire(getStepNumber)
  stepNumberProgress(result) {
    if (result.data === "AccountEst") {
      this.stepNumber = "1";
      this.showButton = true;
      this.showAppForSertMsg = true;
      this.showExamRegButton = false;
      this.showRegionChangeButton = false;
    } else if (result.data === "AppForCert") {
      this.stepNumber = "2";
      this.showExamRegButton = false;
      this.showAppForSertMsg = true;
      this.showButton = true;
      this.showRegionChangeButton = false;
    } else if (result.data === "ExamReg") {
      this.stepNumber = "3";
      this.showExamRegButton = true;
      this.showButton = false;
      this.showAppForSertMsg = false;
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
  validateApplink() {
    if (this.accountReturnMsg === "Success" && this.ofacReturnMsg === "Success") {
      this.showProfileReivew();
      this.linkSource = "Application For Certification";
    } else {
      this.showError = true;
    }
  }
  validateExamReglink(){
    let messageWrapper = {"accountId" : '', "contactId" : this.contactId, "caseId" : '', "service" : "USMLE Exam Registration - Internal and External"};
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
        if(this.ofacReturnMsg === "Success"){
          this.validateLimitAttempted();
        }else{
          this.showError = true;
        }
      }
    });
  }
  validateLimitAttempted(){
    this.showLimitError = false;
    checkUSMLEStepLimitAttempted({conId : this.contactId, selectedExam : ''})
    .then(result=>{
      if(result === true){
        this.linkSource = "Exam Registration";
        this.showProfileReivew();
      }else{
        this.showLimitError = true;
      }
    });
  }
  @wire(getEligibleRegionChangeCases)
  regionChangeCases(result) {
    if (result && this.stepNumber === "3") {
      if (result.data !== undefined && result.data.length > 0) {
        this.showRegionChangeButton = true;
        this.showEPeriodExtButton = true;
      }
    }
  }
  regionChangelink(){
    let messageWrapper = {"accountId" : '', "contactId" : this.contactId, "caseId" : '', "service" : "Region Change - Internal and External"};
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
        if(this.showRegionChangeButton === true){
          regionChangeCasesValidation()
            .then(result=>{
              if(result && result != undefined){
                if(result === "true"){
                    this.linkSource = "Region Change Request";
                    this.showProfileReivew();
                }
                else{
                    this.regionChangeError = result;
                    this.showRegionError = true;
                }
              }
          })
          .catch(error => {
            window.console.log("Error: " + JSON.stringify(error));
          });
        }
      }
    })
  }
  ePeriodExtensionlink(){
    let messageWrapper = {"accountId" : '', "contactId" : this.contactId, "caseId" : '', "service" : "Eligibility Period Extension - Internal and External"};
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
        enableEligPeriodExtRequest()
        .then(result=>{
          if (result && result != undefined) {
            if (result === "true") {
              //Commenting existing code for additional condition check
              /*this.linkSource = "EPEx Request";
              this.showProfileReivew();*/
            }
            else {
              this.ePeriodExtError = result;
              this.showEPeriodError = true;
            }
          }
          enableEligPeriodExtRequestOnBiographic()
          .then(resultValue =>{
            if(resultValue && resultValue != undefined){
              if(resultValue === "true"){
                if(result != undefined && result){
                  if(result === "true"){
                    this.linkSource = "EPEx Request";
                    this.showProfileReivew();
                  }
                }
              }
              else if(resultValue !== "true"){
                  this.ePeriodExtErrorVal = resultValue;
                  this.showEPeriodErrorVal = true;
              }
            }
          })
        })
      }
    })
  }
  // Added by Ajoy
  showHeaderSection() {
    this.showHeader = true;
    this.showPrior = true;
    this.showAppForCertSummary = false;
    if(this.showButtonsBasedOnExamReg){
      this.showAppForCertSummary = true;
      this.showHeader = false;
      this.showPrior = false;
    }
    this.showContact = false;
    this.showMedicalDetails = false;
    this.showOtherMedSchool = false;
    this.showOtherInstitutions = false;
    this.showGraduateOnly = false;
    this.showReporterQuestion = false;
    this.showSummaryPage = false;
    this.showLegalLanguage = false;
    this.showPaymentPage = false;
    this.showConfirmationPage = false;
    this.showError = false;
    this.showPerformanceScreen = false;
    this.showManageExamScreen = false;
    this.showExamRegScrFour = false;
    this.showExamRegLegalSignOffPage = false;
    this.showExamRegPaymentpage = false;
    this.showExamRegLandingPage = false;
    this.showSixthScreen = false;
    this.showExamRegSummary = false;
    this.regionChangeSection = false;
    this.showEPExForm = false;
    this.showEPExSummaryPage = false;
    this.showEPExLegalPage = false;
    this.showEPExPaymentPage = false;

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
    this.showAppForCertSummary = false;
    this.showPreviousLicense = false;
    this.showHeader = false;
    this.showPrior = false;
    this.showPerformanceScreen = false;
    this.showExamRegScrFour = false;
    this.showExamRegLegalSignOffPage = false;
    this.showExamRegPaymentpage = false;
    this.showExamRegLandingPage = false;
    this.showSixthScreen = false;
    this.showExamRegSummary = false;
    this.regionChangeSection = false;
    this.showEPExForm = false;
    this.showEPExSummaryPage = false;
    this.showEPExLegalPage = false;
    this.showEPExPaymentPage = false;


  }

  showDegMedSchoolDetails() {
    this.showContact = false;
    if (this.linkSource === "Application For Certification") {
      this.showMedicalDetails = true;
      this.showAppForCertSummary = false;
    } else if (this.linkSource === "Exam Registration") {
      this.showMedicalDetails = false;
      if (this.isGraduate) {
        this.showPerformanceScreen = true;
        this.showAppForCertSummary = false;
      } else {
        this.showAppForCertSummary = true;
        this.showPerformanceScreen = false;
      }
    } else if (this.linkSource === "Region Change Request") {
        this.showMedicalDetails = false;
        this.showAppForCertSummary = false;
        this.showRegionChangeManageScreen();
    } else if(this.linkSource === "EPEx Request") {
      this.showMedicalDetails = false;
      this.showAppForCertSummary = false;
      this.showEPExForm = true;
    }
    this.showOtherMedSchool = false;
    this.showOtherInstitutions = false;
    this.showGraduateOnly = false;
    this.showReporterQuestion = false;
    this.showSummaryPage = false;
    this.showLegalLanguage = false;
    this.showPaymentPage = false;
    this.showConfirmationPage = false;
    this.showPreviousLicense = false;
    this.showHeader = false;
    this.showPrior = false;
    this.showExamRegScrFour = false;
    this.showExamRegLegalSignOffPage = false;
    this.showExamRegPaymentpage = false;
    this.showExamRegLandingPage = false;
    this.showSixthScreen = false;
    this.showExamRegSummary = false;
    this.showRegionChangeSummaryPage = false;
    this.showRegionChangeLegalPage = false;
    this.showShoppingCartPage = false;
    this.showRegionChangePaymentPage = false;
    this.showEPExSummaryPage = false;
    this.showEPExLegalPage = false;
    this.showEPExPaymentPage = false;

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
    this.showAppForCertSummary = false;
    this.showPreviousLicense = false;
    this.showHeader = false;
    this.showPrior = false;
    this.showPerformanceScreen = false;
    this.showExamRegScrFour = false;
    this.showExamRegLegalSignOffPage = false;
    this.showExamRegPaymentpage = false;
    this.showExamRegLandingPage = false;
    this.showSixthScreen = false;
    this.showExamRegSummary = false;
    this.regionChangeSection = false;
    this.showEPExForm = false;
    this.showEPExSummaryPage = false;
    this.showEPExLegalPage = false;
    this.showEPExPaymentPage = false;

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
    this.showAppForCertSummary = false;
    this.showPreviousLicense = false;
    this.showHeader = false;
    this.showPrior = false;
    this.showPerformanceScreen = false;
    this.showExamRegScrFour = false;
    this.showExamRegLegalSignOffPage = false;
    this.showShoppingCartPage = false;
    this.showExamRegPaymentpage = false;
    this.showExamRegLandingPage = false;
    this.showSixthScreen = false;
    this.showExamRegSummary = false;
    this.regionChangeSection = false;
    this.showEPExForm = false;
    this.showEPExSummaryPage = false;
    this.showEPExLegalPage = false;
    this.showEPExPaymentPage = false;

  }

  showExamAppForCertSummary() {
    this.showContact = false;
    this.showMedicalDetails = false;
    this.showOtherMedSchool = false;
    this.showOtherInstitutions = false;
    this.showGraduateOnly = false;
    this.showReporterQuestion = false;
    this.showSummaryPage = false;
    this.showLegalLanguage = false;
    this.showPaymentPage = false;
    this.showConfirmationPage = false;
    this.showAppForCertSummary = true;
    this.showPreviousLicense = false;
    this.showPerformanceScreen = false;
    this.showHeader = false;
    this.showPrior = false;
    this.showExamRegLegalSignOffPage = false;
    this.showShoppingCartPage = false;
    this.showExamRegPaymentpage = false;
    this.showExamRegLandingPage = false;
    this.showSixthScreen = false;
    this.showExamRegSummary = false;
    this.regionChangeSection = false;
    this.showEPExForm = false;
    this.showEPExSummaryPage = false;
    this.showEPExLegalPage = false;
    this.showEPExPaymentPage = false;

  }
  showExamRegPrevLicFromSummary() {
    this.showContact = false;
    this.showMedicalDetails = false;
    this.showOtherMedSchool = false;
    this.showOtherInstitutions = false;
    this.showGraduateOnly = false;
    this.showReporterQuestion = false;
    this.showSummaryPage = false;
    this.showLegalLanguage = false;
    this.showPaymentPage = false;
    this.showConfirmationPage = false;
    this.showAppForCertSummary = false;
    this.showPreviousLicense = true;
    this.showHeader = false;
    this.showPrior = false;
    this.showPerformanceScreen = false;
    this.showExamRegScrFour = false;
    this.showExamRegLegalSignOffPage = false;
    this.showShoppingCartPage = false;
    this.showExamRegPaymentpage = false;
    this.showExamRegLandingPage = false;
    this.showSixthScreen = false;
    this.showExamRegSummary = false;
    this.showBackToSummary = true;
    this.regionChangeSection = false;
    this.showEPExForm = false;
    this.showEPExSummaryPage = false;
    this.showEPExLegalPage = false;
    this.showEPExPaymentPage = false;

  }

  showExamRegPreviousLicense() {
    this.showContact = false;
    this.showMedicalDetails = false;
    this.showOtherMedSchool = false;
    this.showOtherInstitutions = false;
    this.showGraduateOnly = false;
    this.showReporterQuestion = false;
    this.showSummaryPage = false;
    this.showLegalLanguage = false;
    this.showPaymentPage = false;
    this.showConfirmationPage = false;
    this.showAppForCertSummary = false;
    this.showPreviousLicense = true;
    this.showHeader = false;
    this.showPrior = false;
    this.showPerformanceScreen = false;
    this.showExamRegScrFour = false;
    this.showExamRegLegalSignOffPage = false;
    this.showShoppingCartPage = false;
    this.showExamRegPaymentpage = false;
    this.showExamRegLandingPage = false;
    this.showSixthScreen = false;
    this.showExamRegSummary = false;
    this.showBackToSummary = false;
    this.regionChangeSection = false;
    this.showEPExForm = false;
    this.showEPExSummaryPage = false;
    this.showEPExLegalPage = false;
    this.showEPExPaymentPage = false;

  }

  showPerformanceDataScreen() {
    this.showContact = false;
    this.showMedicalDetails = false;
    this.showOtherMedSchool = false;
    this.showOtherInstitutions = false;
    this.showGraduateOnly = false;
    this.showReporterQuestion = false;
    this.showSummaryPage = false;
    this.showLegalLanguage = false;
    this.showPaymentPage = false;
    this.showConfirmationPage = false;
    this.showAppForCertSummary = false;
    this.showPreviousLicense = false;
    this.showHeader = false;
    this.showPrior = false;
    this.showPerformanceScreen = true;
    this.showExamRegScrFour = false;
    this.showExamRegLegalSignOffPage = false;
    this.showShoppingCartPage = false;
    this.showExamRegPaymentpage = false;
    this.showExamRegLandingPage = false;
    this.showSixthScreen = false;
    this.showExamRegSummary = false;
    this.regionChangeSection = false;
    this.showEPExForm = false;
    this.showEPExSummaryPage = false;
    this.showEPExLegalPage = false;
    this.showEPExPaymentPage = false;

  }

  showManageExamScreenHandler(event) {
    this.examRegId = event.detail.examRegId;
    this.showContact = false;
    this.showMedicalDetails = false;
    this.showOtherMedSchool = false;
    this.showOtherInstitutions = false;
    this.showGraduateOnly = false;
    this.showReporterQuestion = false;
    this.showSummaryPage = false;
    this.showLegalLanguage = false;
    this.showPaymentPage = false;
    this.showConfirmationPage = false;
    this.showAppForCertSummary = false;
    this.showHeader = false;
    this.showPrior = false;
    this.showPerformanceScreen = false;
    this.showPreviousLicense = false;
    this.showManageExamScreen = true;
    this.showExamRegLandingPage = false;
    this.showSixthScreen = false;
    this.showExamRegSummary = false;
    this.regionChangeSection = false;
    this.showEPExForm = false;
    this.showEPExSummaryPage = false;
    this.showEPExLegalPage = false;
    this.showEPExPaymentPage = false;

  }

  prevOfPerformaceDataScreen() {
    if (this.isGraduate) {
      this.showProfileReivew();
    } else {
      this.showExamAppForCertSummary();
    }

  }
  showExamRegScreenSix(event){
    this.caserecordidexamreg = event.detail.caserecordidexamreg;
    this.showContact = false;
    this.showMedicalDetails = false;
    this.showOtherMedSchool = false;
    this.showOtherInstitutions = false;
    this.showGraduateOnly = false;
    this.showReporterQuestion = false;
    this.showSummaryPage = false;
    this.showLegalLanguage = false;
    this.showPaymentPage = false;
    this.showConfirmationPage = false;
    this.showAppForCertSummary = false;
    this.showPreviousLicense = false;
    this.showHeader = false;
    this.showPrior = false;
    this.showPerformanceScreen = false;
    this.showExamRegScrFour =false;
    this.showExamRegLegalSignOffPage =false;
    this.showShoppingCartPage = false;
    this.showExamRegPaymentpage = false;
    this.showExamRegLandingPage = false;
    this.showSixthScreen = true;
    this.showExamRegSummary = false;
    this.showBackToSummary = false;
    this.regionChangeSection = false;
    this.showEPExForm = false;
    this.showEPExSummaryPage = false;
    this.showEPExLegalPage = false;
    this.showEPExPaymentPage = false;

  }
  showExamRegScrSixFromSummary(){
    this.showContact = false;
    this.showMedicalDetails = false;
    this.showOtherMedSchool = false;
    this.showOtherInstitutions = false;
    this.showGraduateOnly = false;
    this.showReporterQuestion = false;
    this.showSummaryPage = false;
    this.showLegalLanguage = false;
    this.showPaymentPage = false;
    this.showConfirmationPage = false;
    this.showAppForCertSummary = false;
    this.showPreviousLicense = false;
    this.showHeader = false;
    this.showPrior = false;
    this.showPerformanceScreen = false;
    this.showExamRegScrFour =false;
    this.showExamRegLegalSignOffPage =false;
    this.showShoppingCartPage = false;
    this.showExamRegPaymentpage = false;
    this.showExamRegLandingPage = false;
    this.showSixthScreen = true;
    this.showExamRegSummary = false;
    this.showBackToSummary = true;
    this.regionChangeSection = false;
    this.showEPExForm = false;
    this.showEPExSummaryPage = false;
    this.showEPExLegalPage = false;
    this.showEPExPaymentPage = false;

  }

  cancelAppForCert() {
    this.showContact = false;
    this.showMedicalDetails = false;
    this.showOtherMedSchool = false;
    this.showOtherInstitutions = false;
    this.showGraduateOnly = false;
    this.showReporterQuestion = false;
    this.showSummaryPage = false;
    this.showLegalLanguage = false;
    this.showPaymentPage = false;
    this.showConfirmationPage = false;
    this.showAppForCertSummary = false;
    this.showPreviousLicense = false;
    this.showHeader = true;
    this.showPrior = true;
    this.showPerformanceScreen = false;
    this.showExamRegScrFour = false;
    this.showExamRegLegalSignOffPage = false;
    this.showShoppingCartPage = false;
    this.showExamRegPaymentpage = false;
    this.showExamRegLandingPage = false;
    this.showSixthScreen = false;
    this.showExamRegSummary = false;
    this.showExamRegLandingPage = false;
    this.regionChangeSection = false;
    this.showEPExForm = false;
    this.showEPExSummaryPage = false;
    this.showEPExLegalPage = false;
    this.showEPExPaymentPage = false;
    this.showPrior = true;
  }
  confirmAndCancel() {
    window.location.reload();
  }
  showExamRegScreenFour() {
    this.showContact = false;
    this.showMedicalDetails = false;
    this.showOtherMedSchool = false;
    this.showOtherInstitutions = false;
    this.showGraduateOnly = false;
    this.showReporterQuestion = false;
    this.showSummaryPage = false;
    this.showLegalLanguage = false;
    this.showPaymentPage = false;
    this.showConfirmationPage = false;
    this.showAppForCertSummary = false;
    this.showPreviousLicense = false;
    this.showHeader = false;
    this.showPrior = false;
    this.showPerformanceScreen = false;
    this.showExamRegScrFour = true;
    this.showExamRegLegalSignOffPage = false;
    this.showShoppingCartPage = false;
    this.showExamRegPaymentpage = false;
    this.showExamRegLandingPage = false;
    this.showSixthScreen = false;
    this.showExamRegSummary = false;
    this.regionChangeSection = false;
    this.showEPExForm = false;
    this.showEPExSummaryPage = false;
    this.showEPExLegalPage = false;
    this.showEPExPaymentPage = false;

  }

  showExamRegLegalSignOff() {
    this.showContact = false;
    this.showMedicalDetails = false;
    this.showOtherMedSchool = false;
    this.showOtherInstitutions = false;
    this.showGraduateOnly = false;
    this.showReporterQuestion = false;
    this.showSummaryPage = false;
    this.showLegalLanguage = false;
    this.showPaymentPage = false;
    this.showConfirmationPage = false;
    this.showAppForCertSummary = false;
    this.showPreviousLicense = false;
    this.showHeader = false;
    this.showPrior = false;
    this.showPerformanceScreen = false;
    this.showExamRegScrFour = false;
    this.showExamRegLegalSignOffPage = true;
    this.showShoppingCartPage = false;
    this.showExamRegPaymentpage = false;
    this.showExamRegLandingPage = false;
    this.showSixthScreen = false;
    this.showExamRegSummary = false;
    this.regionChangeSection = false;
    this.showEPExForm = false;
    this.showEPExSummaryPage = false;
    this.showEPExLegalPage = false;
    this.showEPExPaymentPage = false;
  }

  showExamRegPayment() {
    this.showContact = false;
    this.showMedicalDetails = false;
    this.showOtherMedSchool = false;
    this.showOtherInstitutions = false;
    this.showGraduateOnly = false;
    this.showReporterQuestion = false;
    this.showSummaryPage = false;
    this.showLegalLanguage = false;
    this.showPaymentPage = false;
    this.showConfirmationPage = false;
    this.showAppForCertSummary = false;
    this.showPreviousLicense = false;
    this.showHeader = false;
    this.showPrior = false;
    this.showPerformanceScreen = false;
    this.showExamRegScrFour = false;
    this.showExamRegLegalSignOffPage = false;
    this.showShoppingCartPage = false;
    this.showExamRegLandingPage = false;
    this.showExamRegPaymentpage = true;
    this.showSixthScreen = false;
    this.showExamRegSummary = false;
    this.regionChangeSection = false;
    this.showEPExForm = false;
    this.showEPExSummaryPage = false;
    this.showEPExLegalPage = false;
    this.showEPExPaymentPage = false;
  }

  showExamRegLandingPageHandler(event) {
    this.showContact = false;
    this.showMedicalDetails = false;
    this.showOtherMedSchool = false;
    this.showOtherInstitutions = false;
    this.showGraduateOnly = false;
    this.showReporterQuestion = false;
    this.showSummaryPage = false;
    this.showLegalLanguage = false;
    this.showPaymentPage = false;
    this.showConfirmationPage = false;
    this.showAppForCertSummary = false;
    this.showPreviousLicense = false;
    this.showHeader = false;
    this.showPrior = false;
    this.showPerformanceScreen = false;
    this.showExamRegScrFour = false;
    this.showExamRegLegalSignOffPage = false;
    this.showShoppingCartPage = false;
    this.showExamRegPaymentpage = false;
    this.showExamRegLandingPage = true;
    this.showManageExamScreen = false;
    this.showSixthScreen = false;
    this.showExamRegSummary = false;
    this.regionChangeSection = false;
    this.showEPExForm = false;
    this.showEPExSummaryPage = false;
    this.showEPExLegalPage = false;
    this.showEPExPaymentPage = false;
    if (event.detail.performDelete) {
      this.template.querySelector('c-exam-reg-manage-exam-screen').markAssetsForDeletionOnPreviousEvent(event.detail.visaExceptionAssetId);
    }
  }
  showExamRegLandingPageFromSummary() {
    this.showContact = false;
    this.showMedicalDetails = false;
    this.showOtherMedSchool = false;
    this.showOtherInstitutions = false;
    this.showGraduateOnly = false;
    this.showReporterQuestion = false;
    this.showSummaryPage = false;
    this.showLegalLanguage = false;
    this.showPaymentPage = false;
    this.showConfirmationPage = false;
    this.showAppForCertSummary = false;
    this.showPreviousLicense = false;
    this.showHeader = false;
    this.showPrior = false;
    this.showPerformanceScreen = false;
    this.showExamRegScrFour = false;
    this.showExamRegLegalSignOffPage = false;
    this.showShoppingCartPage = false;
    this.showExamRegPaymentpage = false;
    this.showExamRegLandingPage = true;
    this.showManageExamScreen = false;
    this.showSixthScreen = false;
    this.showExamRegSummary = false;
    this.showBackToSummary = true;
    this.regionChangeSection = false;
    this.showEPExForm = false;
    this.showEPExSummaryPage = false;
    this.showEPExLegalPage = false;
    this.showEPExPaymentPage = false;
  }
  showExamRegSummaryPageHandler() {
    this.showContact = false;
    this.showMedicalDetails = false;
    this.showOtherMedSchool = false;
    this.showOtherInstitutions = false;
    this.showGraduateOnly = false;
    this.showReporterQuestion = false;
    this.showSummaryPage = false;
    this.showLegalLanguage = false;
    this.showPaymentPage = false;
    this.showConfirmationPage = false;
    this.showAppForCertSummary = false;
    this.showPreviousLicense = false;
    this.showHeader = false;
    this.showPrior = false;
    this.showPerformanceScreen = false;
    this.showExamRegScrFour = false;
    this.showExamRegLegalSignOffPage = false;
    this.showShoppingCartPage = false;
    this.showExamRegPaymentpage = false;
    this.showExamRegLandingPage = false;
    this.showManageExamScreen = false;
    this.showSixthScreen = false;
    this.showExamRegSummary = true;
    this.regionChangeSection = false;
    this.showEPExForm = false;
    this.showEPExSummaryPage = false;
    this.showEPExLegalPage = false;
    this.showEPExPaymentPage = false;
  }

  showRegionChangeManageScreen() {
      this.regionChangeSection = true;
      this.showRegionChangeManageScreenPage = true;
      this.showRegionChangeSummaryPage = false;
      this.showRegionChangeLegalPage = false;
      this.showShoppingCartPage = false;
      this.showRegionChangePaymentPage = false;
  }

  showRegionChangeSummary(event){
      this.caserecordidregionchange = event.detail.caserecordidregionchange;
      this.showExamRegActionButton = false;
      this.showContact = false;
      this.showMedicalDetails = false;
      this.showOtherMedSchool = false;
      this.showOtherInstitutions = false;
      this.showGraduateOnly = false;
      this.showReporterQuestion = false;
      this.showSummaryPage = false;
      this.showLegalLanguage = false;
      this.showPaymentPage = false;
      this.showConfirmationPage = false;
      this.showAppForCertSummary = false;
      this.showPreviousLicense = false;
      this.showHeader = false;
      this.showPrior = false;
      this.showPerformanceScreen = false;
      this.showExamRegScrFour = false;
      this.showExamRegLegalSignOffPage = false;
      this.showShoppingCartPage = false;
      this.showExamRegPaymentpage = false;
      this.showExamRegLandingPage = false;
      this.showSixthScreen = false;
      this.showExamRegSummary = false;
      this.regionChangeSection = true;
      this.showRegionChangeManageScreenPage = false;
      this.showRegionChangeSummaryPage = true;
      this.showRegionChangeLegalPage = false;
      this.showRegionChangePaymentPage = false;
      this.showEPExForm = false;
      this.showEPExSummaryPage = false;
      this.showEPExLegalPage = false;
      this.showEPExPaymentPage = false;
    }

    showRegionChangeLegal() {
      this.showContact = false;
      this.showMedicalDetails = false;
      this.showOtherMedSchool = false;
      this.showOtherInstitutions = false;
      this.showGraduateOnly = false;
      this.showReporterQuestion = false;
      this.showSummaryPage = false;
      this.showLegalLanguage = false;
      this.showPaymentPage = false;
      this.showConfirmationPage = false;
      this.showAppForCertSummary = false;
      this.showPreviousLicense = false;
      this.showHeader = false;
      this.showPrior = false;
      this.showPerformanceScreen = false;
      this.showExamRegScrFour = false;
      this.showExamRegLegalSignOffPage = false;
      this.showShoppingCartPage = false;
      this.showExamRegPaymentpage = false;
      this.showExamRegLandingPage = false;
      this.showSixthScreen = false;
      this.showExamRegSummary = false;
      this.regionChangeSection = true;
      this.showRegionChangeManageScreenPage = false;
      this.showRegionChangeSummaryPage = false;
      this.showRegionChangeLegalPage = true;
      this.showRegionChangePaymentPage = false;
      this.showEPExForm = false;
      this.showEPExSummaryPage = false;
      this.showEPExLegalPage = false;
      this.showEPExPaymentPage = false;
    }

    showShoppingCart() {
      this.showContact = false;
      this.showMedicalDetails = false;
      this.showOtherMedSchool = false;
      this.showOtherInstitutions = false;
      this.showGraduateOnly = false;
      this.showReporterQuestion = false;
      this.showSummaryPage = false;
      this.showLegalLanguage = false;
      this.showPaymentPage = false;
      this.showConfirmationPage = false;
      this.showAppForCertSummary = false;
      this.showPreviousLicense = false;
      this.showHeader = false;
      this.showPrior = false;
      this.showPerformanceScreen = false;
      this.showExamRegScrFour = false;
      this.showExamRegLegalSignOffPage = false;
      this.showShoppingCartPage = true;
      this.showExamRegPaymentpage = false;
      this.showExamRegLandingPage = false;
      this.showSixthScreen = false;
      this.showExamRegSummary = false;
      this.regionChangeSection = false;
      this.showRegionChangeManageScreenPage = false;
      this.showRegionChangeSummaryPage = false;
      this.showRegionChangeLegalPage = false;
      this.showRegionChangePaymentPage = false;
      this.showEPExForm = false;
      this.showEPExSummaryPage = false;
      this.showEPExLegalPage = false;
      this.showEPExPaymentPage = false;
  }

    showRegionChangePayment() {
      this.showContact = false;
      this.showMedicalDetails = false;
      this.showOtherMedSchool = false;
      this.showOtherInstitutions = false;
      this.showGraduateOnly = false;
      this.showReporterQuestion = false;
      this.showSummaryPage = false;
      this.showLegalLanguage = false;
      this.showPaymentPage = false;
      this.showConfirmationPage = false;
      this.showAppForCertSummary = false;
      this.showPreviousLicense = false;
      this.showHeader = false;
      this.showPrior = false;
      this.showPerformanceScreen = false;
      this.showExamRegScrFour = false;
      this.showExamRegLegalSignOffPage = false;
      this.showShoppingCartPage = false;
      this.showExamRegPaymentpage = false;
      this.showExamRegLandingPage = false;
      this.showSixthScreen = false;
      this.showExamRegSummary = false;
      this.regionChangeSection = true;
      this.showRegionChangeManageScreenPage = false;
      this.showRegionChangeSummaryPage = false;
      this.showRegionChangeLegalPage = false;
      this.showRegionChangePaymentPage = true;
      this.showEPExForm = false;
      this.showEPExSummaryPage = false;
      this.showEPExLegalPage = false;
      this.showEPExPaymentPage = false;
  }

  showEPExSummary(event){
    this.caserecordidepex = event.detail.caserecordidepex;
    this.showContact = false;
    this.showMedicalDetails = false;
    this.showOtherMedSchool = false;
    this.showOtherInstitutions = false;
    this.showGraduateOnly = false;
    this.showReporterQuestion = false;
    this.showSummaryPage = false;
    this.showLegalLanguage = false;
    this.showPaymentPage = false;
    this.showConfirmationPage = false;
    this.showAppForCertSummary = false;
    this.showPreviousLicense = false;
    this.showHeader = false;
    this.showPrior = false;
    this.showPerformanceScreen = false;
    this.showExamRegScrFour = false;
    this.showExamRegLegalSignOffPage = false;
    this.showShoppingCartPage = false;
    this.showExamRegPaymentpage = false;
    this.showExamRegLandingPage = false;
    this.showManageExamScreen = false;
    this.showSixthScreen = false;
    this.showExamRegSummary = false;
    this.regionChangeSection = false;
    this.showEPExForm = false;
    this.showEPExSummaryPage = true;
    this.showEPExLegalPage = false;
    this.showEPExPaymentPage = false;
  }

  showEPExLegal() {
    this.showContact = false;
    this.showMedicalDetails = false;
    this.showOtherMedSchool = false;
    this.showOtherInstitutions = false;
    this.showGraduateOnly = false;
    this.showReporterQuestion = false;
    this.showSummaryPage = false;
    this.showLegalLanguage = false;
    this.showPaymentPage = false;
    this.showConfirmationPage = false;
    this.showAppForCertSummary = false;
    this.showPreviousLicense = false;
    this.showHeader = false;
    this.showPrior = false;
    this.showPerformanceScreen = false;
    this.showExamRegScrFour = false;
    this.showExamRegLegalSignOffPage = false;
    this.showShoppingCartPage = false;
    this.showExamRegPaymentpage = false;
    this.showExamRegLandingPage = false;
    this.showManageExamScreen = false;
    this.showSixthScreen = false;
    this.showExamRegSummary = false;
    this.regionChangeSection = false;
    this.showEPExForm = false;
    this.showEPExSummaryPage = false;
    this.showEPExLegalPage = true;
    this.showEPExPaymentPage = false;

  }

  showEPExPayment() {
    this.showContact = false;
    this.showMedicalDetails = false;
    this.showOtherMedSchool = false;
    this.showOtherInstitutions = false;
    this.showGraduateOnly = false;
    this.showReporterQuestion = false;
    this.showSummaryPage = false;
    this.showLegalLanguage = false;
    this.showPaymentPage = false;
    this.showConfirmationPage = false;
    this.showAppForCertSummary = false;
    this.showPreviousLicense = false;
    this.showHeader = false;
    this.showPrior = false;
    this.showPerformanceScreen = false;
    this.showExamRegScrFour = false;
    this.showExamRegLegalSignOffPage = false;
    this.showShoppingCartPage = false;
    this.showExamRegPaymentpage = false;
    this.showExamRegLandingPage = false;
    this.showManageExamScreen = false;
    this.showSixthScreen = false;
    this.showExamRegSummary = false;
    this.regionChangeSection = false;
    this.showEPExForm = false;
    this.showEPExSummaryPage = false;
    this.showEPExLegalPage = false;
    this.showEPExPaymentPage = true;
  }


  getContactAssocObjIdAndName(showExamRegActionButtonParam) {
    // Getting Object Id and Object Name
    getContactAssociationOrStaging({ showExamRegActionButton: showExamRegActionButtonParam })
      .then(result => {
        if (result) {
          this.objectId = result.split(",")[0];
          this.objectType = result.split(",")[1];
          this.caseStatus = result.split(",")[2];

          if (showExamRegActionButtonParam === true) {
            this.showButtonsBasedOnExamReg = true;
            this.linkSource = "Application For Certification";
            this.showDegMedSchoolDetails();
          }
        } else {
          this.showHeaderSection();
        }
      })
      .catch(error => {
        window.console.log("Error: " + JSON.stringify(error));
      });
  }

  showAppForCertSc2FrmExamReg() {
    this.getContactAssocObjIdAndName(true);
  }

  discardAppForCert() {
    this.spinner = true;
    // eslint-disable-next-line no-alert
    if (window.confirm(discardMessage)) {
      // Delete the record in Contact Association Type Staging. Record Type - Exam Registration - Degree Medical School
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
  }

  // Cancel Region Change Request
  cancelRegionChangeRequest() {
    this.spinner = true;
    // eslint-disable-next-line no-alert
    this.template.querySelector('[data-id="newModalAlert"]').show();
  }

  //Cancel Transcript Request

    cancelTranscriptRequest() {
      this.spinner = true;
      this.showHeaderSection();
      this.showTranscriptReqButton = true;
      this.spinner = false;
    }

  connectedCallback() {
    //check if applicant is graduate or not on load of page
    isApplicantStudentOrGraduate().then(data => {
      this.isGraduate = data;
    });

      getExamRegistrations()
              .then(value => {
                  if (value) {
                      if (value.length > 0) {
                          this.showExamRegList = true;
                          this.showExamRegMsg = false;
                          this.examRegistrationsList = [];
                          for (let key in value) {
                              if (value.hasOwnProperty(key)) {
                                  let hasPermit = false;
                                  let hasVisa = false;
                                  let hasPaperForm = false;
                                  if(value[key].showSchedulingPermit == 'true'){
                                    hasPermit = true;
                                  }
                                  if(value[key].pEvUrl == 'Yes'){
                                    hasPaperForm = true;
                                  }
                                  if(value[key].showVisa == 'true'){
                                    hasVisa = true;
                                  }
                                  let tempRecord = {
                                      recordIdVal: value[key].recordIdVal,
                                      examType: value[key].examType,
                                      eligibilityPeriod: value[key].eligibilityPeriod,
                                      testingRegion: value[key].testingRegion,
                                      testAccomodations: value[key].testAccomodations,
                                      applicationStatus: value[key].applicationStatus,
                                      schedulingPermit: value[key].permitUrl,
                                      paperForm: value[key].pEvUrl,
                                      visaLetter: value[key].visaUrl,
                                      hasPaperForm:hasPaperForm,
                                      hasVisa:hasVisa,
                                      hasPermit:hasPermit,
                                      peUrl: value[key].paperEnrollment,
                                  };
                                  this.examRegistrationsList.push(tempRecord);
                              }
                          }
                      }
                      else {
                          this.examRegistrationsList = [];
                          this.showExamRegList = false;
                          this.showExamRegMsg = true;
                      }
                  }
              })
              .catch(error => {
                  window.console.log('Error: ' + JSON.stringify(error));
              });

              getPriorExamRegistrations().then(resVal => {
                if (resVal) {
                    if (resVal.length > 0) {
                        this.showPriorExamRegList = true;
                        this.showPriorExamRegMsg = false;
                        this.priorExamRegistrationsList = [];
                        for (let key in resVal) {
                            if (resVal.hasOwnProperty(key)) {
                                let temporRecord = {
                                    recordIdVal: resVal[key].recordIdVal,
                                    examType: resVal[key].examType,
                                    eligibilityPeriod: resVal[key].eligibilityPeriod,
                                    testingRegion: resVal[key].testingRegion,
                                    testAccomodations: resVal[key].testAccomodations,
                                    applicationStatus: resVal[key].applicationStatus,
                                    pdOptOut: resVal[key].pdOptOut
                                };
                                this.priorExamRegistrationsList.push(temporRecord);
                            }
                        }
                    }
                    else {
                        this.priorExamRegistrationsList = [];
                        this.showPriorExamRegList = false;
                        this.showPriorExamRegMsg = true;
                    }
                }
            })
            .catch(error => {
                window.console.log('Error: ' + JSON.stringify(error));
            });
  }

  getUrlParamValue(url, key) {
    return new URL(url).searchParams.get(key);
  }

  renderedCallback() {
    if(this.headerMethodCalled === true){
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

  closeModal(){
    this.template.querySelector('[data-id="newModalAlert"]').hide();
  }

  cancelButton(event) {
    cancelRegionChangeRequest()
    .then(delresult => {
      if (delresult === "true") {
        this.spinner = false;
        this.showHeaderSection();
      } else {
        window.console.log("Delete Error:", delresult);
      }
    })
    .catch(error => {
      window.console.log("Error: " + JSON.stringify(error));
    });
    event.preventDefault();
    const selectEvent = new CustomEvent('cancelevent', {});
    this.dispatchEvent(selectEvent);
  }

  downloadPEForm(event){
    let tempFileName = event.currentTarget.dataset.key;
    getFileUrlWithSAS({
      fileName: tempFileName
    }).then(result => {
      console.log(result);
      var a = document.createElement("a");
      a.href = result;
      a.target = "_blank";
      a.setAttribute('download', tempFileName);
      a.click();
    })
  }


  downloadEpermit(event){
    let tempFileName = 'EPermit.pdf';
    downloadEpermit({
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
              title: 'Error downloading E-Permit!',
              message: error.message,
              variant: 'error',
          })
      );
    })
  }
}