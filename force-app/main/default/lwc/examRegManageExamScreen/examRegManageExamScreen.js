import {
    LightningElement,
    track,
    api,
    wire
} from 'lwc';
//import required apex methods
import getContactId from '@salesforce/apex/AppForCertController.getContactId';
import checkExamConditions from "@salesforce/apex/ExamRegistrationController.checkExamConditions";
import fetchAvailableExamTypes from "@salesforce/apex/ExamRegistrationController.fetchAvailableExamTypes";
import passedExamExceptions from "@salesforce/apex/ExamRegistrationController.passedExamExceptions";
import fetchDocumentedDisabilities from "@salesforce/apex/ExamRegistrationController.fetchDocumentedDisabilities";
import getExamRegionSurcharges from "@salesforce/apex/ExamRegistrationController.getExamRegionSurcharges";
import manageExamRegistration from "@salesforce/apex/ExamRegistrationController.manageExamRegistration";
import getExamEligibilityDate from '@salesforce/apex/ExamRegistrationController.getExamEligibilityDate';
import getAllConstants from '@salesforce/apex/AppForCertController.getAllConstants';
import getExamRegistrationDetail from '@salesforce/apex/ExamRegistrationController.getExamRegistrationDetail';
import deleteVisaExceptionDoc from '@salesforce/apex/ExamRegistrationController.deleteVisaExceptionDoc';
import checkPacingRuleApplied from '@salesforce/apex/ExamRegistrationController.checkPacingRuleApplied';
import retrieveExceptionAssetIdOnPageLoad from '@salesforce/apex/ExamRegistrationController.retExcAssetIdOnPageload';
import markAssetsForDeletionCase from '@salesforce/apex/EpicCredVerController.deleteAssetsWithoutCase';
//Custom Labels
import examAlreadyRegisteredError from '@salesforce/label/c.Exam_Registration_Already_Registered_Error';
import examStep1NotPassedError from '@salesforce/label/c.Exam_Registration_USMLE_Step_1_not_passed_Error';
import examWithheldError from '@salesforce/label/c.Exam_Registration_Exam_Withheld_Error';
import tooManyAttemptsError from '@salesforce/label/c.Exam_Registration_Too_many_attempts_error';
import passedExamExceptionWarning from '@salesforce/label/c.Passed_Exam_Exception_Warning';
import step2CS from '@salesforce/label/c.Exam_Registration_Step2CS';
import step2csMsg from '@salesforce/label/c.Exam_Registration_Step2CSMsg';
import exceptionDocUploadMissingError from '@salesforce/label/c.Exam_Registration_Exception_Upload_Documentation_Missing_Error';
import blankApplicantReasonError from '@salesforce/label/c.Exam_Registration_Exception_Blank_Applicant_Reason_Error';
import Blank_Eligibility_Period_Error_Message from '@salesforce/label/c.Blank_Eligibility_Period_Error_Message';
import Blank_Testing_Region_Error_Message from '@salesforce/label/c.Blank_Testing_Region_Error_Message';
import Blank_Documented_Disabilities_Error_Message from '@salesforce/label/c.Blank_Documented_Disabilities_Error_Message';
import Exam_Registration_saved from '@salesforce/label/c.Exam_Registration_Saved';
import checkLastAttempt from "@salesforce/apex/ExamRegistrationController.checkLastAttempt";
export default class ExamRegManageExamScreen extends LightningElement{
    @track spinner = false;
    @track formsubmit = false;
    @track showError = false;
    @track examTypes = [];
    @track selectedExamType;
    @track fetchedSelectedExamType = '';
    @track btnDisabled = true;
    @track showVisaCheck = false;
    @track selectedExceptionType;
    @track needVisa = false;
    @track errorMessagesText = '';
    @track successMessageText = '';
    @track exceptionMessageText = '';
    @track showExceptions = false;
    @track modalTitle = '';
    @track modalContent = '';
    @track showFileUpload = false;
    showFileUploadCloud = false;
    @track showReasonInput = false;
    @track applicantReason = '';
    @track ecResult = [];
    @track ecResultVal = '';
    @track isEC = false;
    @track showEC = false;
    @track step2CSVal = '';
    @track isNotCS = false;
    @track USMLEStep1 = '';
    @track USMLEStep2CK = '';
    @track USMLEStep2CS = '';
    @track showUSMLEStep2CS = false;
    @track showRegionSurchargeSection = false;
    @track showTestCentersSection = false;
    @track showDocDisabilitiesSection = false;
    @track selectedExamRegionSurcharge = '';
    @track selectedExamRegion = ''; 
    @track erSurchargeLists = [];
    @track selectedTestAccomadation;
    @track showTestAccomadationText = false;
    @track testAccomadationOptions = [];
    @api editExamRegistration = false;
    @api examRegId;
    @api showBackToSummary;
    @track contactId;
    @track passedExamExceptionId = '';
    @track assetId = '';
    @track parentId = '';
    @track visaExceptionDocumentationPayload;
    @track maxsize = 10;
    @track uploadWarningMessage = 'Note: You can only upload one file for this document.  If you upload a different file it will replace the existing document you uploaded.  If you are editing an exam you have already added you will not be able to revert this upload unless you delete the exam from the list.';
    assetInserted = false;
    examRegCaseExists = false;
    previousException = null;
    currentException = null;
    setInitialException = false;
    @track visaLetterUrl = null;
    @track showLastAttemptError;
    @track showLimitError;
    label = {
        examAlreadyRegisteredError,
        examStep1NotPassedError,
        examWithheldError,
        step2CS,
        step2csMsg
    };
    loadInitialLabel(){
        getAllConstants().then(data=>{
            if(data !== undefined){
                this.USMLEStep1 = data.LWC_EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE;
                this.USMLEStep2CK = data.LWC_EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK;
                this.USMLEStep2CS = data.LWC_EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCS;
            }
        }).catch();
    }
    @wire(getContactId)
    contactIdfromController(result){
        if(result.data !== undefined){
            this.contactId = result.data;
            this.parentId = result.data;
            deleteVisaExceptionDoc({contactId: this.contactId});
        }
    }
    connectedCallback(){
        this.showEC = false;
        this.step2CSVal = '';
        this.loadInitialLabel();
        let examRegistrationEditId = '';
        if(this.examRegId !== undefined){
            this.editExamRegistration = true;
            examRegistrationEditId = this.examRegId;
        }
        fetchAvailableExamTypes({
            'examRegId': examRegistrationEditId
        }).then(result=>{
            let fetchedValues = [];
            // eslint-disable-next-line guard-for-in
            for(let i in result){
                if(result[i] !== 'STEP 3'){
                let tempOption = {
                    label: result[i],
                    value: result[i]
                };
                fetchedValues.push(tempOption);
                }
            }
            this.examTypes = fetchedValues;
        }).catch();
        // List of Picklist values - Field Test_Accommodations_needed__c
        fetchDocumentedDisabilities().then(resultval=>{
            let fetchedValuesDocumented = [];
            // eslint-disable-next-line guard-for-in
            for(let i in resultval){
                let tempOption = {
                    label: resultval[i],
                    value: resultval[i]
                };
                fetchedValuesDocumented.push(tempOption);
            }
            this.testAccomadationOptions = fetchedValuesDocumented;
        }).catch();
        if(this.examRegId){
            // Exam Registration - Edit Section
            this.fetchExamRegistrationDetail();
        }
    }
    // method to fetch exam registration details if exam reg exists
    fetchExamRegistrationDetail(){
        this.spinner = true;
        getExamRegistrationDetail({
                examRegId: this.examRegId
            })
            .then(examInfo=>{
                if(examInfo){
                    this.parentId = examInfo.Case__c;
                    this.examRegCaseExists = true;
                    this.selectedExamType = examInfo.Exam_Types__c;
                    this.fetchedSelectedExamType = this.selectedExamType;
                    this.selectedExamRegionSurcharge = examInfo.Product_Detail__c;
                    this.selectedExamRegion = examInfo.ExamRegion;
                    this.selectedTestAccomadation = examInfo.Test_Accommodations_needed__c;
                    if(this.selectedExamType === this.USMLEStep2CS){
                        this.showVisaCheck = true;
                        this.needVisa = examInfo.Visa_Letter_Needed__c === 'true';
                    }
                    this.ecResultVal = examInfo.eligibilityDate;
                    this.isNotCS = false;
                    this.showEC = true;
                    this.btnDisabled = false;
                    this.applicantReason = examInfo.Exception_Reason__c;
                    if(examInfo.Passed_Exam_Exception__c){
                        this.passedExamExceptionId = examInfo.Passed_Exam_Exception__c;
                        passedExamExceptions({
                            selectedExam: this.selectedExamType
                        }).then(exceptionResult=>{
                            let fetchedExceptions = [];
                            for(let i in exceptionResult){
                                let tempOption = {
                                    label: exceptionResult[i].Exception_Name__c,
                                    value: exceptionResult[i].Id,
                                    documentRequired: exceptionResult[i].Documents_Required__c,
                                    examType: exceptionResult[i].Exam_Type__c,
                                    exceptionContent: exceptionResult[i].Exception_Content__c,
                                    exceptionName: exceptionResult[i].Exception_Name__c,
                                    applicantReasonRequired: exceptionResult[i].Applicant_Reason_Required__c
                                };
                                fetchedExceptions.push(tempOption);
                                if(tempOption.value === this.passedExamExceptionId){
                                    if(tempOption.documentRequired === true){
                                        this.showFileUpload = true;
                                    }else{
                                        this.showFileUpload = false;
                                    }
                                    if(tempOption.applicantReasonRequired === true){
                                        this.showReasonInput = true;
                                    }else{
                                        this.showReasonInput = false;
                                    }
                                }
                            }
                            this.exceptionTypes = fetchedExceptions;
                            this.showExceptions = true;
                            this.exceptionMessageText = passedExamExceptionWarning;
                        });
                    }
                    if(this.selectedExamType === this.USMLEStep1 || this.selectedExamType === this.USMLEStep2CK){
                        this.isNotCS = true;
                        this.loadECTemplate();
                        this.loadExamRegionSurcharges();
                        this.showRegionSurchargeSection = true;
                        this.showTestCentersSection = false;
                        this.showDocDisabilitiesSection = true;
                        if(this.selectedTestAccomadation === 'Yes'){
                            this.showTestAccomadationText = true;
                        }else{
                            this.showTestAccomadationText = false;
                        }
                    }else{
                        this.isNotCS = false;
                        this.loadECTemplate();
                        this.showRegionSurchargeSection = false;
                        this.showTestCentersSection = true;
                        this.showDocDisabilitiesSection = true;
                        if(this.selectedTestAccomadation === 'Yes'){
                            this.showTestAccomadationText = true;
                        }else{
                            this.showTestAccomadationText = false;
                        }
                    }
                    this.showFileUploadCloud = false;
                    retrieveExceptionAssetIdOnPageLoad({
                        contactId: this.contactId,
                        examRegId: this.examRegId
                    }).then(exceptionAssetUrl=>{
                        this.spinner = true;
                        this.visaLetterUrl = exceptionAssetUrl;
                        this.visaExceptionDocumentationPayload = JSON.stringify({
                            contactId: this.contactId,
                            caseId: null,
                            catsId: null,
                            documentType: 'Visa Exception Documentation',
                            assetRecordType: 'Exam_Registration',
                            createOrReplace: 'Create',
                            assetStatus: 'In Progress',
                            assetCreationRequired: 'true',
                            createFromPB: 'true',
                            selectedExamType: this.selectedExamType,
                            key:'Visa Exception Documentation Document'
                        });
                        if(this.visaLetterUrl){
                            this.showFileUploadCloud = true;
                            this.assetInserted = true;
                        }
                        this.spinner = false;
                    });
                    this.spinner = false;
                }
            })
            .catch(error=>{
                window.console.log('Error: ' + JSON.stringify(error));
                this.spinner = false;
            });
    }
    renderedCallback(){
        if(this.examRegId && !this.setInitialException){
            this.template.querySelectorAll(".exception-option").forEach(element=>{
                if(element.value === this.passedExamExceptionId){
                    element.checked = true;
                    this.currentException = element;
                    this.setInitialException = true;
                }
            });
        }
        if(this.showVisaCheck){
            if(this.template.querySelector('.visa-checkbox') !== null){
                this.template.querySelector('.visa-checkbox').checked = this.needVisa;
            }
        }
        if(this.contactId !== undefined && !this.examRegCaseExists){
            this.visaExceptionDocumentationPayload = JSON.stringify({
                contactId: this.contactId,
                caseId: null,
                catsId: null,
                documentType: 'Visa Exception Documentation',
                assetRecordType: 'Exam_Registration',
                createOrReplace: 'Create',
                assetStatus: 'In Progress',
                assetCreationRequired: 'true',
                assetId: null,
                createFromPB: 'true',
                selectedExamType: this.selectedExamType,
                key:'Visa Exception Documentation Document'
            });
        }
    }
    handleExceptionUploaded(event){
        this.showFileUploadCloud = false;
        this.showFileUpload = false;
        this.visaLetterUrl = event.detail.url;
        this.showFileUpload = true;
        this.showFileUploadCloud = true;
        this.template.querySelector("c-cloud-document-upload-wrapper").auraThumbnailLoaderAzureURL();
        this.assetInserted = true;
    }
    handleExamSelection(event){
        this.examRegCaseExists = false;
        this.passedExamExceptionId = null;
        if(this.visaLetterUrl){
            markAssetsForDeletionCase({
                azureUrl: this.visaLetterUrl
            });
            this.visaLetterUrl = null;
            this.assetInserted = false;
        }
        if(this.contactId){
            this.visaExceptionDocumentationPayload = JSON.stringify({
                contactId: this.contactId,
                caseId: null,
                catsId: null,
                documentType: 'Visa Exception Documentation',
                assetRecordType: 'Exam_Registration',
                createOrReplace: 'Create',
                assetStatus: 'In Progress',
                assetCreationRequired: 'true',
                assetId: null,
                createFromPB: 'true',
                selectedExamType: this.selectedExamType,
                key:'Visa Exception Documentation Document'
            });
        }
        this.selectedExamType = event.target.value;
        this.showEC = false;
        this.ecResultVal = '';
        this.showRegionSurchargeSection = false;
        this.showTestCentersSection = false;
        this.showDocDisabilitiesSection = false;
        this.showTestAccomadationText = false;
        this.btnDisabled = true;
        this.selectedExamRegionSurcharge = '';
        this.selectedExamRegion = ''; 
        this.selectedTestAccomadation = '';
        this.showExceptions = false;
        this.showFileUpload = false;
        this.showFileUploadCloud = false;
        this.assetInserted = false;
        this.showLastAttemptError = false;
        this.showLimitError = false;
        if(this.selectedExamType === this.fetchedSelectedExamType){
            this.setInitialException = false;
            this.fetchExamRegistrationDetail();
        }else{
            checkExamConditions({
                selectedExam: this.selectedExamType,
                examRegId: this.examRegId
            }).then(result=>{
                this.showVisaCheck = false;
                this.errorMessagesText = '';
                this.showError = false;
                this.showExceptions = false;
                if(result !== 'Success'){
                    this.showError = true;
                    if(result === 'A'){
                        this.errorMessagesText = examStep1NotPassedError;
                    }
                    if(result === 'B' || result === 'G'){
                        this.showError = false;
                        this.showVisaCheck = true;
                        if(result === 'B'){
                            this.checkExamConditionsValidationsPassed();
                        }
                    }
                    if(result === 'C'){
                        this.errorMessagesText = examAlreadyRegisteredError;
                    }
                    if(result === 'D'){
                        this.errorMessagesText = examWithheldError;
                    }
                    if(result === 'E'){
                        if(this.selectedExamType === this.USMLEStep1 || this.selectedExamType === this.USMLEStep2CK){
                            this.showLimitError = true;
                        }                        
                        else{
                            this.errorMessagesText = tooManyAttemptsError;
                        }
                    }
                    if(result === 'F' || result === 'G' || result === 'H'){
                        this.showError = false;
                        this.exceptionMessageText = '';
                        passedExamExceptions({
                            selectedExam: this.selectedExamType
                        }).then(exceptionResult=>{
                            let fetchedExceptions = [];
                            for(let i in exceptionResult){
                                let tempOption = {
                                    label: exceptionResult[i].Exception_Name__c,
                                    value: exceptionResult[i].Id,
                                    documentRequired: exceptionResult[i].Documents_Required__c,
                                    examType: exceptionResult[i].Exam_Type__c,
                                    exceptionContent: exceptionResult[i].Exception_Content__c,
                                    exceptionName: exceptionResult[i].Exception_Name__c,
                                    applicantReasonRequired: exceptionResult[i].Applicant_Reason_Required__c
                                };
                                fetchedExceptions.push(tempOption);
                            }
                            this.exceptionTypes = fetchedExceptions;
                            this.showExceptions = true;
                            this.exceptionMessageText = passedExamExceptionWarning;
                        });
                    }else{
                        this.showExceptions = false;
                    }
                }else if(result === 'Success'){
                    this.checkExamConditionsValidationsPassed();
                }
            }).catch();
            checkLastAttempt({
                selectedExam: this.selectedExamType,
                contactId: this.contactId
            }).then(result=>{
                if(result === 'warning'){
                    this.showLastAttemptError = true;
                }
            });
        }
    }
    checkExamConditionsValidationsPassed(){
        this.isNotCS = false;
        this.showEC = true;
        this.btnDisabled = false;
        if(this.selectedExamType === this.USMLEStep1 || this.selectedExamType === this.USMLEStep2CK){
            this.isNotCS = true;
            this.loadECTemplate();
            this.loadExamRegionSurcharges();
            this.showRegionSurchargeSection = true;
            this.showTestCentersSection = false;
            this.showDocDisabilitiesSection = true;
        }else{
            this.isNotCS = false;
            this.loadECTemplate();
            this.showRegionSurchargeSection = false;
            this.showTestCentersSection = true;
            this.showDocDisabilitiesSection = true;
        }
        if(this.selectedExamType === this.USMLEStep2CS && this.errorMessagesText == ''){
            this.showEC = true;
            this.isNotCS = false;
            this.loadECTemplate();
            this.showTestCentersSection = true;
            this.btnDisabled = false;
        }
    }
    handleTestAccomadations(event){
        this.selectedTestAccomadation = event.target.value;
        // eslint-disable-next-line eqeqeq
        if(this.selectedTestAccomadation == 'Yes'){
            this.showTestAccomadationText = true;
        }else{
            this.showTestAccomadationText = false;
        }
    }
    handleExceptionSelection(event){
        this.examRegCaseExists = false;
        this.previousException = this.currentException;
        this.currentException = event.target;
        this.template.querySelectorAll(".exception-option").forEach(element=>{
            element.checked = false;
        });
        event.target.checked = true;
        this.passedExamExceptionId = event.target.value;
        if(this.assetInserted){
            this.template.querySelector('.warningModal').title = "Please Note!";
            this.template.querySelector('.warningModal').message = "The previously uploaded file would be deleted once you confirm your changes. Do you want to continue?";
            this.template.querySelector('.warningModal').show();
        }else{
            this.exceptionSelectionHandler(this.currentException);
        }
    }
    @api markAssetsForDeletionOnPreviousEvent(assetIdsToBeDeleted){
        markAssetsForDeletionCase({
            azureUrl: assetIdsToBeDeleted
        });
    }
    exceptionSelectionHandler(param){
        this.selectedExceptionType = param.value;
        this.showFileUpload = false;
        this.showFileUploadCloud = false;
        this.template.querySelectorAll(".exception-option").forEach(element=>{
            if(element.value === this.selectedExceptionType){
                element.checked = true;
            }else{
                element.removeAttribute("checked");
                element.checked = false
            }
        });
        let docRequired = param.getAttribute("data-document-required");
        if(docRequired === 'true'){
            this.showFileUpload = true;
            this.showFileUploadCloud = true;
        }else{
            this.showFileUpload = false;
            this.showFileUploadCloud = false;
        }
        let reasonRequired = param.getAttribute("data-applicant-reason-required");
        if(reasonRequired === 'true'){
            this.showReasonInput = true;
        }else{
            this.showReasonInput = false;
        }
        this.checkExamConditionsValidationsPassed();
        if(this.template.querySelectorAll('#blankApplicantReasonErrorId') !== null){
            this.template.querySelectorAll('#blankApplicantReasonErrorId').forEach(element=>element.remove());
        }
    }
    handleYesClick(){
        this.assetInserted = false;
        markAssetsForDeletionCase({
            azureUrl: this.visaLetterUrl
        });
        this.visaLetterUrl = null;
        this.showFileUpload = false;
        this.exceptionSelectionHandler(this.currentException);
    }
    handleCloseClick(){
        this.currentException = this.previousException;
        this.previousException = null;
        this.exceptionSelectionHandler(this.currentException);
    }
    handleRegionSurcharge(event){
        this.selectedExamRegionSurcharge = event.target.value;
        this.getExamRegion(); 
    }
    // fetch the list of Exam Regions and Surcharges based on the selected Exam Type
    loadExamRegionSurcharges(){
        getExamRegionSurcharges({
            selectedExam: this.selectedExamType
        }).then(regionresult=>{
            this.erSurchargeLists = [];
            // eslint-disable-next-line guard-for-in
            for(let key in regionresult){
                let selectedExamRegionSurchargeJS = '';
                let selectedExamRegionJS = ''; 
                if(regionresult[key].Id === this.selectedExamRegionSurcharge){
                    selectedExamRegionSurchargeJS = this.selectedExamRegionSurcharge;
                    selectedExamRegionJS = regionresult[key].Exam_Region__c; 
                }
                let tempRecord = {
                    recordId: regionresult[key].Id,
                    RegionName: regionresult[key].Exam_Region__r.Region_Name__c,
                    RegionShortDescription: regionresult[key].Exam_Region__r.Region_Short_Description__c,
                    RegionSurcharge: regionresult[key].Surcharge__c,
                    selectedRecordId: selectedExamRegionSurchargeJS,
                    selectedExamRegion: selectedExamRegionJS
                };
                this.erSurchargeLists.push(tempRecord);
            }
            this.regionLists = this.erSurchargeLists; 
        }).catch(error=>{
            window.console.log('Error: ' + JSON.stringify(error));
        });
    }

    getExamRegion(){
        getExamRegionSurcharges({
            selectedExam: this.selectedExamType
        }).then(regionresult=>{                    
            for(let key in regionresult){
                if(regionresult[key].Id === this.selectedExamRegionSurcharge){                    
                    this.selectedExamRegion = regionresult[key].Exam_Region__c;                     
                }
            }
        }).catch(error=>{
            window.console.log('Error: ' + JSON.stringify(error));
        });
    }
    
    loadECTemplate(){
        this.step2CSVal = '';
        this.showUSMLEStep2CS = false;
        getExamEligibilityDate({
                type: this.selectedExamType
            })
            .then(result=>{
                if(result){
                    let optionsValues = [];
                    if(result.length > 0){
                        if(this.selectedExamType === this.USMLEStep1 || this.selectedExamType === this.USMLEStep2CK){
                            this.isEC = true;
                            for(let i = 0; i < result.length; i++){
                                let dateString = result[i];
                                let dateStringValue = dateString.split('||||');
                                optionsValues.push({
                                    label: dateStringValue[0],
                                    value: dateStringValue[1]
                                })
                            }
                        }
                        if(this.selectedExamType === this.USMLEStep2CS){
                            let dateString = result[0];
                            let dateStringValue = dateString.split('||||');
                            let csVal = JSON.stringify(dateStringValue[0]).split('-')[0].replace(/"/g, '');
                            this.step2CSVal = csVal;
                            checkPacingRuleApplied({
                                    type: this.selectedExamType
                                })
                                .then(result1=>{
                                    if(result1 !== undefined){
                                        this.showUSMLEStep2CS = result1;
                                    }
                                }).catch(error1=>{
                                    window.console.log('Error: ' + JSON.stringify(error1));
                                });
                        }
                    }else{
                        this.isEC = false;
                    }
                    this.ecResult = optionsValues;
                }
            }).catch(error=>{
                window.console.log('Error: ' + JSON.stringify(error));
            });
    }
    handleVisaCheckbox(event){
        this.needVisa = event.target.checked;
    }
    prevButton(event){
        event.preventDefault();
        // eslint-disable-next-line no-alert
        if(window.confirm("All the changes you have made will be lost. Are you sure you want to continue?")){
            const selectEvent = new CustomEvent('previousevent', {
                detail: {
                    showBackToSummary: this.showBackToSummary,
                    performDelete: !this.examRegCaseExists || (this.assetInserted && this.visaLetterUrl && !this.showFileUpload),
                    visaExceptionAssetId: this.visaLetterUrl
                }
            });
            this.dispatchEvent(selectEvent);
        }
    }
    confirmButton(event){
        event.preventDefault();
    }
    handleSubmit(event){
        event.preventDefault(); // stop the form from submitting
        const fieldvals = event.detail.fields;
        this.formsubmit = true;
        this.spinner = true;
        let eligibilityPeriods = '';
        let testAccommodationsNeededc = '';
        let visaLetterNeededc = 'false';
        let exceptionReason = '';
        // documentation uploaded check
        if(this.showFileUpload && !this.assetInserted){
            this.showError = true;
            this.formsubmit = false;
            this.spinner = false;
            if(this.template.querySelectorAll('#fileUploadMissingError') !== null){
                this.template.querySelectorAll('#fileUploadMissingError').forEach(element=>element.remove());
            }
            if(this.template.querySelector('.fileUploadSection') !== null){
                let elem = document.createElement("div");
                elem.id = 'fileUploadMissingError';
                elem.textContent = exceptionDocUploadMissingError;
                elem.style = 'color:#ff0000; clear:both;';
                this.template.querySelector('.fileUploadSection').appendChild(elem);
            }
        }else{
            if(this.template.querySelectorAll('#fileUploadMissingError') !== null){
                this.template.querySelectorAll('#fileUploadMissingError').forEach(element=>element.remove());
            }
        }
        // applicant reason blank check
        if(this.showReasonInput){
            if(this.template.querySelector('.applicant-reason') !== null){
                exceptionReason = this.template.querySelector('.applicant-reason').value;
                if(this.template.querySelectorAll('#blankApplicantReasonErrorId') !== null){
                    this.template.querySelectorAll('#blankApplicantReasonErrorId').forEach(element=>element.remove());
                }
                if(exceptionReason === ""){
                    this.showError = true;
                    this.formsubmit = false;
                    this.spinner = false;
                    let elem = document.createElement("div");
                    elem.id = 'blankApplicantReasonErrorId';
                    elem.textContent = blankApplicantReasonError;
                    elem.style = 'color:#ff0000; clear:both;';
                    this.template.querySelector('.applicant-reason').classList.add('slds-has-error');
                    this.template.querySelector('.applicant-reason').parentNode.insertBefore(elem, this.template.querySelector('.applicant-reason').nextSibling);
                }
            }else{
                if(this.template.querySelectorAll('#blankApplicantReasonErrorId') !== null){
                    this.template.querySelectorAll('#blankApplicantReasonErrorId').forEach(element=>element.remove());
                }
            }
        }else{
            if(this.template.querySelectorAll('#blankApplicantReasonErrorId') !== null){
                this.template.querySelectorAll('#blankApplicantReasonErrorId').forEach(element=>element.remove());
            }
        }
        // blank EligibilityPeriods check
        if(this.template.querySelector('[data-eligibilityperiods]') !== null){
            eligibilityPeriods = this.template.querySelector('[data-eligibilityperiods]').value;
            if(eligibilityPeriods === "" || eligibilityPeriods === undefined){
                this.showError = true;
                this.formsubmit = false;
                this.spinner = false;
                if(this.template.querySelector('#eligibilityperiodsError') === null){
                    let elem = document.createElement("div");
                    elem.id = 'eligibilityperiodsError';
                    elem.textContent = Blank_Eligibility_Period_Error_Message;
                    elem.style = 'color:#ff0000; clear:both;';
                    this.template.querySelector('[data-eligibilityperiods]').classList.add('slds-has-error');
                    this.template.querySelector('[data-eligibilityperiods]').parentNode.insertBefore(elem, this.template.querySelector('[data-eligibilityperiods]').nextSibling);
                }
            }else{
                this.template.querySelector('[data-eligibilityperiods]').classList.remove('slds-has-error');
                if(this.template.querySelector('#eligibilityperiodsError') !== null){
                    let elem = this.template.querySelector('#eligibilityperiodsError');
                    elem.parentNode.removeChild(elem);
                }
            }
        }
        // blank Testing Region and Surcharge check
        if(this.template.querySelector('.regionradio') !== null){
            if(this.selectedExamRegionSurcharge === ''){
                this.showError = true;
                this.formsubmit = false;
                this.spinner = false;
                if(this.template.querySelector('#regionradioError') === null){
                    let elem = document.createElement("div");
                    elem.id = 'regionradioError';
                    elem.textContent = Blank_Testing_Region_Error_Message;
                    elem.style = 'color:#ff0000; clear:both;';
                    this.template.querySelector('.regiontable').classList.add('slds-has-error');
                    this.template.querySelector('.regiontable').parentNode.insertBefore(elem, this.template.querySelector('.regiontable').nextSibling);
                }
            }else{
                this.template.querySelector('.regiontable').classList.remove('slds-has-error');
                if(this.template.querySelector('#regionradioError') !== null){
                    let elem = this.template.querySelector('#regionradioError');
                    elem.parentNode.removeChild(elem);
                }
            }
        }
        // blank Examinees with Documented Disabilities
        if(this.template.querySelector('[data-testaccoptions]') !== null){
            testAccommodationsNeededc = this.template.querySelector('[data-testaccoptions]').value;
            if(testAccommodationsNeededc === "" || testAccommodationsNeededc === undefined){
                this.showError = true;
                this.formsubmit = false;
                this.spinner = false;
                if(this.template.querySelector('#accomadationoptionsError') === null){
                    let elem = document.createElement("div");
                    elem.id = 'accomadationoptionsError';
                    elem.textContent = Blank_Documented_Disabilities_Error_Message;
                    elem.style = 'color:#ff0000; clear:both;';
                    this.template.querySelector('.testaccomsec').classList.add('slds-has-error');
                    this.template.querySelector('.testaccomsec').parentNode.insertBefore(elem, this.template.querySelector('.testaccomsec').nextSibling);
                }
            }else{
                this.template.querySelector('.testaccomsec').classList.remove('slds-has-error');
                if(this.template.querySelector('#accomadationoptionsError') !== null){
                    let elem = this.template.querySelector('#accomadationoptionsError');
                    elem.parentNode.removeChild(elem);
                }
            }
        }
        if(this.template.querySelector('.visa-checkbox') !== null){
            if(this.template.querySelector('.visa-checkbox').checked){
                visaLetterNeededc = 'true';
            }
        }
        if(this.formsubmit){
            fieldvals.Exam_Types__c = this.template.querySelector('[data-examtypes]').value;
            if(eligibilityPeriods !== "" && eligibilityPeriods !== undefined){
                let eligibilityDate = eligibilityPeriods.split('----');
                fieldvals.EP_start_Date__c = eligibilityDate[0];
                fieldvals.EP_end_Date__c = eligibilityDate[1];
                fieldvals.Eligibility_Period__c = eligibilityDate[2];
            }else{
                fieldvals.EP_start_Date__c = '';
                fieldvals.EP_end_Date__c = '';
                fieldvals.Eligibility_Period__c = '';
            }
            fieldvals.Product_Detail__c = this.selectedExamRegionSurcharge;
            fieldvals.examRegion = this.selectedExamRegion;             
            fieldvals.Test_Accommodations_needed__c = testAccommodationsNeededc;
            fieldvals.Visa_Letter_Needed__c = visaLetterNeededc;
            if(this.editExamRegistration === true){
                fieldvals.examRegId = this.examRegId;
            }else{
                fieldvals.examRegId = '';
            }
            // Passed Exam Exception
            fieldvals.passedExamExceptionId = this.passedExamExceptionId;
            fieldvals.exceptionReason = exceptionReason;
            // Asset
            fieldvals.assetUrl = this.visaLetterUrl;
            fieldvals.assetInserted = this.assetInserted;
            manageExamRegistration({
                    fieldvals: JSON.stringify(fieldvals)
                })
                .then(saveresult=>{
                    this.spinner = false;
                    if(saveresult){
                        this.showError = true;
                        if(this.errorMessagesText === ''){
                            this.successMessageText = Exam_Registration_saved;
                            const selectEvent = new CustomEvent('confirmevent', {});
                            this.dispatchEvent(selectEvent);
                        }else{
                            this.successMessageText += '<br/>' + Exam_Registration_saved;
                        }
                    }
                })
                .catch(error=>{
                    this.spinner = false;
                    window.console.log('Error: ' + JSON.stringify(error));
                });
        }
    }
    openModal(event){
        let exceptionName = event.target.getAttribute('data-exception-name');
        let exceptionContent = event.target.getAttribute('data-exception-description');
        this.template.querySelector('.exceptionModal').title = exceptionName;
        this.template.querySelector('.exceptionModal').message = exceptionContent;
        this.template.querySelector('.exceptionModal').showPrimaryButton = "false";
        this.template.querySelector('.exceptionModal').show();
    }
    handleOnAssetInserted(event){
        this.assetInserted = true;
        this.assetId = event.detail.assetId;
    }
}