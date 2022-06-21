import { LightningElement,track,api,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import {refreshApex} from '@salesforce/apex';
import {getPicklistValues} from 'lightning/uiObjectInfoApi';
import {getObjectInfo} from 'lightning/uiObjectInfoApi';
import {validateTransferCreditGradeInputHelper,handleUploadTCTHelper,handleUploadTCTNameHelper,handleUploadTCTTransHelper,handleUploadPremedHelper,
    handleUploadPremedNameHelper,handleUploadPremedTransHelper,handleUploadfmdHelper,handleUploadfmdNameHelper,
    handleUploadfmdTransHelper,handleUploaddlHelper,handleUploaddlNameHelper,handleUploaddlTransHelper,
    handleUploadftHelper,handleUploadftNameHelper,handleUploadftTransHelper,handleChangeTCTNameHelper,handleChangeTCTTransHelper,
    handleChangePreNameHelper,handleChangePreTransHelper,handleChangefmdNameHelper,handleChangefmdTransHelper,
    handleChangeftNameHelper,handleChangeftTransHelper,handleChangedlNameHelper,handleChangedlTransHelper,showDelbtn,navHel,updateSave,
    checkDegreeDateHelper,gradDateHelper,createGradDateHel,loadPayload,calculateMonthValHelper,statusErrHel,degMedSchl,degMedNameErr,
    endDateErrHel,valErrorHel,degTitleErrHel,degTitleErrHel2,gradDateErrHel,blankDegDateErr,endDateFutErrHel,
    newDateValHel} from './appForCertIncompleteCaseProcessingHelper.js';
import getOtherMedicalSchool from '@salesforce/apex/AppForCertController.getOtherMedicalSchool';
import getInCompleteCaseId from '@salesforce/apex/AppForCertController.getCaseId';
import saveIncompleteRecords from '@salesforce/apex/AppForCertController.saveIncompleteRecords';
import getAssetsAndDocumentsForOtherMedical from '@salesforce/apex/AppForCertController.getAssetsAndDocumentsForOtherMedical';
import blankStartDateLabel from '@salesforce/label/c.Blank_Start_Date_Label';
import unacceptableTCT from '@salesforce/label/c.App_for_Cert_Unacceptable_TCT';
import unacceptableTCTTranslation from '@salesforce/label/c.App_for_Cert_Unacceptable_TCT_Translation';
import unacceptableTCTNameDocumentation from '@salesforce/label/c.App_for_Cert_Unacceptable_Name_Documentation';
import unacceptablePreMedLetter from '@salesforce/label/c.App_for_Cert_Unacceptable_Pre_Med_Letter';
import unacceptableTCTCourses from '@salesforce/label/c.App_for_Cert_Unacceptable_TCT_Courses_Distinctly_Identified';
import deficiencyForm from '@salesforce/label/c.App_for_Cert_Deficiency_Form';
import deficiencyFormSubHeader from '@salesforce/label/c.App_for_Cert_Deficiency_Form_Sub_Header';
import unacceptableGraduate from '@salesforce/label/c.App_for_Cert_Unacceptable_Graduate';
import diplomaDocumentFinalMedicalType from '@salesforce/label/c.App_for_Cert_Final_Medical_Diploma';
import diplomaDocumentNameDocumentType from '@salesforce/label/c.App_for_Cert_Name_Document';
import diplomaDocumentTranslationType from '@salesforce/label/c.App_for_Cert_Translation';
import transcriptFinalMedicalType from '@salesforce/label/c.App_for_Cert_Final_Medical_School_Transcript';
import deanLetterType from '@salesforce/label/c.App_for_Cert_Letter_from_Dean';
import tctType from '@salesforce/label/c.App_for_Cert_Transfer_Credit_Transcript';
import premedType from '@salesforce/label/c.App_for_Cert_Pre_Med_Letter';
import unacceptableDiploma from '@salesforce/label/c.App_for_Cert_Diploma';
import unacceptableTranscript from '@salesforce/label/c.App_for_Cert_Final_Medical_Transcript';
import unacceptableDeanLetter from '@salesforce/label/c.App_for_Cert_Dean_s_Letter';
import errorNameDocument from '@salesforce/label/c.App_for_Cert_Error_Name_on_Document_for_all';
import errorDeanDate from '@salesforce/label/c.App_for_Cert_Error_Dean_Date';
import errorAllDocument from '@salesforce/label/c.App_for_Cert_Upload_All_documents';
import errorTranslationDocument from '@salesforce/label/c.App_for_Cert_Upload_Translation_Documents';
import graduateScreenNameonDocMessage from '@salesforce/label/c.App_for_Cert_Name_on_Document';
import graduateScreenDeanLetDateMessage from '@salesforce/label/c.App_for_Cert_Dean_Letter_Date';
import Pleaseuploadfile from '@salesforce/label/c.App_for_Cert_Please_upload_the_file';
import tcCourseTitMessage from '@salesforce/label/c.App_for_Cert_Please_enter_a_Course_Title';
import tcCourseNumMessage from '@salesforce/label/c.App_for_Cert_Please_enter_valid_Number_of_Credits_Earned';
import tcCourseOutMessage from '@salesforce/label/c.App_for_Cert_Please_select_the_outcome_of_the_Course';
import tcCourseMonMessage from '@salesforce/label/c.App_for_Cert_Please_enter_month';
import tcCourseYrMessage from '@salesforce/label/c.App_for_Cert_Please_enter_year';
import tcCoursefutureDate from '@salesforce/label/c.App_for_Cert_Credits_earned_date_should_not_be_in_future';
import getTermsandConditionsData from '@salesforce/apex/AppForCertController.getTermsandConditionsData';
import createTermsRecord from '@salesforce/apex/AppForCertController.createTermsRecord';
import termsTitle from '@salesforce/label/c.App_For_Cert_Legal_Terms_Title';
import termsError from '@salesforce/label/c.App_For_Cert_Legal_Terms_Error';
import getAllConstants from '@salesforce/apex/AppForCertController.getAllConstants';
//Degree school change
import START_MONTH_FIELD from '@salesforce/schema/Contact_Association_Type_Staging__c.Start_Month__c';
import END_MONTH_FIELD from '@salesforce/schema/Contact_Association_Type_Staging__c.End_Month__c';
import DEGREE_ISSUE_MONTH_FIELD from '@salesforce/schema/Contact_Association_Type_Staging__c.Degree_Issue_Month__c';
import Status_FIELD from '@salesforce/schema/Contact_Association_Type_Staging__c.Status__c';
import CONTACT_ASSOCIATION_TYPE_STAGING_OBJECT from '@salesforce/schema/Contact_Association_Type_Staging__c';
import GraduationMonth_FIELD from '@salesforce/schema/Contact_Association_Type_Staging__c.Graduation_Month__c';
import getSelectedValues from '@salesforce/apex/AppForCertHelper.getSelectedValuesPart';
import getSchoolRecords from '@salesforce/apex/AppForCertController.getSchoolRecords';
import getGradYearValues from '@salesforce/apex/AppForCertController.getGradYearValues';
import getDegreeRecords from '@salesforce/apex/AppForCertController.getDegreeRecords';
import errorMessageOFACSoft from '@salesforce/apex/AppForCertController.errorMessageOFACSoft';
import manageAppforCertCases from '@salesforce/apex/AppForCertController.manageAppforCertCases';
//code added by Shailaja. Date Format STories
import errorMessageNewStartDateEndDate from '@salesforce/apex/AppForCertController.errorMessageNewStartDateEndDate';
import errorMessageNewGraduationDate from '@salesforce/apex/AppForCertController.errorMessageNewGraduationDate';
import errorMessageNewCurrentDate from '@salesforce/apex/AppForCertController.errorMessageNewCurrentDate';
import startAndEndDateValidation from '@salesforce/apex/AppForCertController.startAndEndDateValidation';
import countryWarning from '@salesforce/label/c.OFAC_warning_error_message';
//code added by Shailaja. Date Format stories.
import degDisabledLabel from '@salesforce/label/c.Degree_disabled_message';
import gradYearDisabledLabel from '@salesforce/label/c.Graduation_Year_disabled_message';
import MedicalEducationTypeGraduate from '@salesforce/label/c.Medical_Education_type_Graduate';
export default class AppForCertIncompleteCaseProcessing extends NavigationMixin(LightningElement) {
    label = {
        unacceptableTCT,
        unacceptableTCTTranslation,
        unacceptableTCTNameDocumentation,
        unacceptablePreMedLetter,
        unacceptableTCTCourses,
        diplomaDocumentFinalMedicalType,
        diplomaDocumentNameDocumentType,
        diplomaDocumentTranslationType,
        transcriptFinalMedicalType,
        deanLetterType,
        tctType,
        premedType,
        errorNameDocument,
        errorDeanDate,
        errorAllDocument,
        errorTranslationDocument,
        graduateScreenNameonDocMessage,
        graduateScreenDeanLetDateMessage,
        Pleaseuploadfile,
        unacceptableDiploma,
        unacceptableTranscript,
        unacceptableDeanLetter,
        deficiencyForm,
        deficiencyFormSubHeader,
        termsTitle,
        tcCourseTitMessage,
        tcCourseNumMessage,
        tcCourseOutMessage,
        tcCourseMonMessage,
        tcCourseYrMessage,
        tcCoursefutureDate,
        unacceptableGraduate
    };
    @api caseId;
    @api getIdFromParent;
    @api objectType;
    @api objectId;
    @track multiple = true;
    @track parameters = {};
    @track getOtherInstitutionData;
    @track isOthIns = false;
    @track instAssetsList = [];
    @track showMultiple = true;
    @track activeSections = ['contactSection'];
    @track showMedDetails = false;
    @track formSubmit = false;
    @track isLegalPage = false;
    @track isnotLegalPage = false;
    @track caseValues = '';
    @track displayblock = '';
    @track displaynone = '';
    @track isErrMsgDeanDate = false;
    @track isErrMsgTran = false;
    @track isErrMsgMainFiles = false;
    @track isErrMsgName = false;
    @track showAll = false;
    @track showAllTCT = false;
    @track fileNameReqMap = [];
    refreshCase;
    //Legal screen
    @track recordsList = [];
    @track showErrorLeg = false;
    @track errorMessagesText = '';
    @track checkedcount = 0;
    @track spinner = false;
    @track btnNotDisabled = false;
    @track showConfirmation = false;
    //Degree Screen
    @track degreeSchoolValue = '';
    @track objectIdDegreeName = '';
    @track showDegreeSchool = false;
    @track objectIdDegree;
    @track degreeComment = '';
    @api showExamRegActionButton = false;
    @track statusOptions = [];
    @track spinnerDeg = false;
    @api name = '';
    required = true;
    @api placeholder = '';
    initialized = false;
    @track medicalSchool;
    @track degreetitle = '';
    @track selectedStatus;
    graduationDateFetched;
    @track selectedMedicalSchoolId;
    @track selectedGradYear = '';
    @track selectedGradMonth = '';    
    @track endMonth = '';
    @track startMonth = '';
    @track selectedStartYear = '';
    @track selectedEndYear = '';
    @track degreeMonth = '';
    @track selectedDegreeIssueYear = '';
    @track startMonthPicklistOptions = [];
    @track endMonthPicklistOptions = [];
    @track degreeIssueMonthPicklistOptions = [];
    @track degreeDisabled = true;
    @track gradYearDisabled = true;
    @track formsubmitdegree;
    @track selectedValue;
    @track attdate;
    @track degdate;
    @track clickedBtn;
    @track fromdate;
    @track todate;
    @track degreeissuedate;
    @track schoolprog;
    @track numberOfYearsAttended;
    @track studentid;
    @track specialty;
    _wiredstatusval;
    @track degreeDisabledMessage = degDisabledLabel;
    @track gradYearDisabledMessage = gradYearDisabledLabel;
    @track schoolRecordValues = [];
    @track wiredParameters = {
        error: '',
        data: null
    };
    @track showError = false;
    @track successMessageText = '';
    @track showWarning = false;
    @track warningMessagesText = "";
    @track hasTwentyNine = true;
    @track hasThirty = true;
    @track hasThirtyOne = true;
    @api reSubmitFromAppForCert;
    @track disabledMedSchoolDetails = false;
    @track maxsize = 10;     
    @wire(getGradYearValues, {
        entityId: '$selectedMedicalSchoolId'
    }) gradYearRecordValues(value) {        
        this.wiredParameters = value;  
    }    
    @wire(getDegreeRecords, {
        entityId: '$selectedMedicalSchoolId',
        graduationYear: '$selectedGradYear'
    }) degreeRecordValues;    
    @wire(getObjectInfo, {
        objectApiName: CONTACT_ASSOCIATION_TYPE_STAGING_OBJECT
    })
    objectInfo;
    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: Status_FIELD
    })
    statusPicklistValues({
        error,
        data
    }) {
        if (data) {
            this.statusOptions = data.values;
        } else if (error) {
            console.error('Error: ' + JSON.stringify(error));
        }
    }   
    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: START_MONTH_FIELD
    })
    startMonthPicklistValues({
        error,
        data
    }) {
        if (data) {
            this.startMonthPicklistOptions = data.values;
        } else if (error) {
            console.error('Error: ' + JSON.stringify(error));
        }
    }
    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: END_MONTH_FIELD
    })
    endMonthPicklistValues({
        error,
        data
    }) {
        if (data) {
            this.endMonthPicklistOptions = data.values;
        } else if (error) {
            console.error('Error: ' + JSON.stringify(error));
        }
    }
    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: DEGREE_ISSUE_MONTH_FIELD
    })
    degreeIssueMonthPicklistValues({
        error,
        data
    }) {
        if (data) {
            this.degreeIssueMonthPicklistOptions = data.values;
        } else if (error) {
            console.error('Error: ' + JSON.stringify(error));
        }
    }
    @wire(getObjectInfo, {
        objectApiName: CONTACT_ASSOCIATION_TYPE_STAGING_OBJECT
    }) objectMonthInfo;
    @wire(getPicklistValues, {
        recordTypeId: '$objectMonthInfo.data.defaultRecordTypeId',
        fieldApiName: GraduationMonth_FIELD
    }) monthPicklistValues;
    @wire(getSelectedValues) objectValuesone(result) {
        this._wiredstatusval = result;
        if (result.data) {
            this.selectedValue = result.data.Status__c;          
            //Date format stories. #7596 & 7597
            this.startMonth = result.data.Start_Month__c;
            this.endMonth = result.data.End_Month__c; 
            this.selectedStartYear = result.data.Start_Year__c; 
            this.selectedEndYear = result.data.End_Year__c; 
            this.selectedDegreeIssueYear = result.data.Degree_Issue_Year__c; 
            this.degreeMonth = result.data.Degree_Issue_Month__c; 
            this.schoolprog = result.data.School_Program__c;
            this.numberOfYearsAttended = result.data.Number_of_Years_Attended__c;
            this.studentid = result.data.Student_ID__c;
            this.specialty = result.data.Specialty__c;
            this.selectedGradYear = result.data.Graduation_Year__c;
            this.selectedGradMonth = result.data.Graduation_Month__c;
            if (result.data.Account_Name__c !== undefined) {
                this.medicalSchool = result.data.Account_Name__c;
                this.selectedMedicalSchoolId = result.data.Account__c;
                if (this.medicalSchool && !this.selectedGradYear) {
                    this.gradYearDisabled = false;
                } else if (this.selectedGradYear) {
                    this.gradYearDisabled = false;
                }
            }
            if (result.data.Degree_Title__c) {
                this.degreetitle = result.data.Degree_Title__c;
                this.degreeDisabled = false;
            }
            if (this.schoolprog === undefined) {
                this.schoolprog = '';
            }
            if (this.numberOfYearsAttended === undefined) {
                this.numberOfYearsAttended = '';
            }
            if (this.studentid === undefined) {
                this.studentid = '';
            }
            if (this.specialty === undefined) {
                this.specialty = '';
            }
            if (this.selectedGradYear === undefined) {
                this.selectedGradYear = '';
            }
            if (this.selectedGradMonth === undefined) {
                this.selectedGradMonth = '';
            }
        } else if (result.error) {
            console.error('Error: ' + JSON.stringify(result.error));
        }
    }
    renderedCallback() {
        if (this._wiredstatusval.data) {
            refreshApex(this._wiredstatusval);
        }
        if (this.initialized) {
            return;
        }
        this.initialized = true;
        if (this.showDegreeSchool) {
            let listId = this.template.querySelector('datalist.schoolRecordDatalist').id;
            this.template.querySelector("input.schoolRecord").setAttribute("list", listId);
            let listId2 = this.template.querySelector('datalist.degreeRecordDatalist').id;
            this.template.querySelector("input.degreeRecord").setAttribute("list", listId2);
            let listId3 = this.template.querySelector('datalist.gradYearRecordDatalist').id;
            this.template.querySelector("input.gradYearRecord").setAttribute("list", listId3);
        }
    }
    handleSchoolChange(event) {
        this.medicalSchool = event.target.value;
        this.selectedGradYear = '';
        this.selectedGradMonth = '';
        this.degreetitle = '';
        this.selectedMedicalSchoolId = this.template.querySelector(".schoolRecordDatalist option[value=\"" + event.target.value + "\"]").getAttribute("data-entityid");
        if (this.selectedMedicalSchoolId) {
            // For Year Field
            this.gradYearDisabled = false;
            this.gradYearDisabledMessage = '';
        } else {
            // For Year Field
            this.gradYearDisabled = true;
            this.gradYearDisabledMessage = gradYearDisabledLabel;
        }
        getGradYearValues({
                entityId: this.selectedMedicalSchoolId
            })
            .then(() => {
                refreshApex(this.wiredParameters);
            })
            .catch((error) => {
                this.message = 'Error received: code' + error.errorCode + ', ' + 'message ' + error.body.message;
            });
    }
    handleGradYearChange(event) {
        this.selectedGradYear = event.target.value;
        this.degreetitle = '';
        if (event.target.value) {
            this.degreeDisabled = false;
            this.degreeDisabledMessage = '';
        } else {
            this.degreeDisabled = true;
            this.degreeDisabledMessage = degDisabledLabel;
        }
        getDegreeRecords({
                entityId: this.selectedMedicalSchoolId,
                graduationYear: this.selectedGradYear
            })
            .then(() => {
                return refreshApex(this.degreeRecordValues);
            })
            .catch((error) => {
                this.message = 'Error received: code' + error.errorCode + ', ' + 'message ' + error.body.message;
            });
    }
    handleDegreeChange(event) {
        this.degreetitle = event.target.value;
    }
    handleChangeForInputValue(event) {
        if (event.target.name === 'startMonth') {
            this.startMonth = event.target.value;
        }
        if (event.target.name === 'startYear') {
            this.selectedStartYear = event.target.value;
        }
        if (event.target.name === 'endMonth') {
            this.endMonth = event.target.value;
        }
        if (event.target.name === 'endYear') {
            this.selectedEndYear = event.target.value;
        }
        if (event.target.name === 'degreeMonth') {
            this.degreeMonth = event.target.value;
        }
        if (event.target.name === 'degreeYear') {
            this.selectedDegreeIssueYear = event.target.value;
        }
    }
    handleSubmit() {
        if (this.showDegreeSchool) {
            let fieldvals = {};
            this.attdate = true;
            this.degdate = true;
            this.spinnerDeg = true;
            this.degreeSchoolValue = '';
            fieldvals.Number_of_Years_Attended__c = this.template.querySelector('[data-num]').value;
            fieldvals.School_Program__c = this.template.querySelector('[data-sch]').value;
            fieldvals.Graduation_Month__c = this.template.querySelector('[data-gradmonth]').value;
            fieldvals.Student_ID__c = this.template.querySelector('[data-stu]').value;
            fieldvals.Specialty__c = this.template.querySelector('[data-spc]').value;
            fieldvals.Status__c = this.template.querySelector('[data-radiogroup]').value;
            this.selectedValue = this.template.querySelector('[data-radiogroup]').value;
            fieldvals.Account__c = this.selectedMedicalSchoolId;
            fieldvals.Degree_Title__c = this.template.querySelector("input.degreeRecord").value;
            fieldvals.gradYear = this.template.querySelector("input.gradYearRecord").value;
            this.selectedGradYear = this.template.querySelector("input.gradYearRecord").value;
            fieldvals.gradMonth = fieldvals.Graduation_Month__c;
            this.selectedGradMonth = fieldvals.Graduation_Month__c;
            //code added by shailaja
            fieldvals.Start_Month__c = this.startMonth;
            fieldvals.Start_Year__c = this.selectedStartYear;
            fieldvals.End_Month__c = this.endMonth;
            fieldvals.End_Year__c = this.selectedEndYear;
            fieldvals.Degree_Issue_Month__c = this.degreeMonth;
            fieldvals.Degree_Issue_Year__c = this.selectedDegreeIssueYear;
            this.numberOfYearsAttended = fieldvals.Number_of_Years_Attended__c;
            fieldvals.showExamRegActionButton = this.showExamRegActionButton;
            this.successMessageText = '';
            this.formsubmitdegree = true;
            this.showError = false;
            if (fieldvals.Status__c === undefined) {
                this.showError = true;
                this.formsubmitdegree = false;
                this.spinnerDeg = false;
                if (this.template.querySelector('#statusError') === null) {
                    statusErrHel(this.template);
                }
            } else {
                this.template.querySelector('[data-radiogroup]').classList.remove('slds-has-error');
                if (this.template.querySelector('#statusError') !== null) {
                    let elem = this.template.querySelector('#statusError');
                    elem.parentNode.removeChild(elem);
                }
            }
            // Number of years attended check
            if (fieldvals.Number_of_Years_Attended__c === undefined || fieldvals.Number_of_Years_Attended__c === '' || fieldvals.Number_of_Years_Attended__c <= parseFloat('0') || fieldvals.Number_of_Years_Attended__c > parseFloat('20')) {
                this.showError = true;
                this.formsubmitdegree = false;
                this.spinnerDeg = false;
                let elem2 = document.createElement("div");
                elem2.id = 'attendedYearsError';
                elem2.textContent = 'Enter valid number of years attended';
                if (fieldvals.Number_of_Years_Attended__c > parseFloat('20')) {
                    elem2.textContent = 'Maximum number of years allowed is 20';
                }
                elem2.style = 'color:#ff0000; clear:both;';
                this.template.querySelector('.attendedYears').classList.add('slds-has-error');
                if (this.template.querySelector('#attendedYearsError') === null) {
                    this.template.querySelector('.attendedYears').parentNode.insertBefore(elem2, this.template.querySelector('.attendedYears').nextSibling);
                } else {
                    let elem = this.template.querySelector('#attendedYearsError');
                    elem.parentNode.removeChild(elem);
                    this.template.querySelector('.attendedYears').parentNode.insertBefore(elem2, this.template.querySelector('.attendedYears').nextSibling);
                }
            } else {
                if (this.template.querySelector('#attendedYearsError') !== null) {
                    let elem = this.template.querySelector('#attendedYearsError');
                    elem.parentNode.removeChild(elem);
                    this.template.querySelector('.attendedYears').classList.remove('slds-has-error');
                }
            }
            // blank Degree Medical School check
            if (fieldvals.Account__c === undefined || fieldvals.Account__c === '') {
                this.showError = true;
                this.formsubmitdegree = false;
                this.spinnerDeg = false;
                if (this.template.querySelector('#degMedSchoolError') === null) {
                    degMedSchl(this.template);
                }
            } else {
                //Select valid Degree Medical School         
                const medicalSchoolList = [];
                this.template.querySelectorAll('.schoolRecordDatalist option').forEach(element => {
                    medicalSchoolList.push(element.value);
                });
                this.template.querySelector('input.schoolRecord').classList.remove('slds-has-error');
                if (this.template.querySelector('#degMedSchoolError') !== null) {
                    let elem = this.template.querySelector('#degMedSchoolError');
                    elem.parentNode.removeChild(elem);
                }
                if (medicalSchoolList.indexOf(this.medicalSchool) === -1) {
                    this.showError = true;
                    this.formsubmitdegree = false;
                    this.spinnerDeg = false;
                    if (this.template.querySelector('#degMedSchoolError') === null) {
                        degMedNameErr(this.template);
                    }
                }
            }
            //code added by shailaja. 9/15/2020. Date format stories.#7596 & #7597
            //Blank Attendance Start Month & Year validations
            if (fieldvals.Start_Month__c === undefined || fieldvals.Start_Month__c === '' || fieldvals.Start_Month__c === null ||
                fieldvals.Start_Year__c === undefined || fieldvals.Start_Year__c === '' || fieldvals.Start_Year__c === null) {
                this.showError = true;
                this.formsubmitdegree = false;
                this.attdate = false;
                this.spinnerDeg = false;
                if(this.template.querySelector('#startDateError') === null) {
                    let elem = document.createElement("div");
                    elem.id = 'startDateError';
                    elem.textContent = blankStartDateLabel;
                    elem.style = 'color:#ff0000; clear:both;';
                    this.template.querySelector('.start-date-error').appendChild(elem);
                }
            } else {
                if (this.template.querySelector('#startDateError') !== null && this.attdate) {
                    let elem = this.template.querySelector('#startDateError');
                    elem.parentNode.removeChild(elem);
                }
            }
            //code added by shailaja. 9/15/2020. Date format stories.User story$7596 & 7597
            //Blank Attendance End Month & Year validations        
            if (fieldvals.End_Month__c === undefined || fieldvals.End_Month__c === '' || fieldvals.End_Month__c === null ||
                fieldvals.End_Year__c === undefined || fieldvals.End_Year__c === '' || fieldvals.End_Year__c === null) {
                this.showError = true;
                this.formsubmitdegree = false;
                this.attdate = false;
                this.spinnerDeg = false;
                if (this.template.querySelector('#endDateError') === null) {
                    endDateErrHel(this.template);
                }
            } else {
                if (this.template.querySelector('#endDateError') !== null && this.attdate) {
                    let elem = this.template.querySelector('#endDateError');
                    elem.parentNode.removeChild(elem);
                }
            }
            //Code added by Shailaja. 9/16/2020. Date Format stories.
            //Attendance End Date greater than Attendance Start Date.
            errorMessageNewStartDateEndDate({
                    startMonth: fieldvals.Start_Month__c,
                    startYear: fieldvals.Start_Year__c,
                    endMonth: fieldvals.End_Month__c,
                    endYear: fieldvals.End_Year__c
                })
                .then(result => {
                    if (result) {
                        this.showError = true;
                        this.formsubmitdegree = false;
                        this.attdate = false;
                        this.spinnerDeg = false;
                        if (this.template.querySelector('#startEndDateError') === null) {
                            valErrorHel(this.template);
                        }
                    } else {
                        if (this.template.querySelector('#startEndDateError') !== null && this.attdate) {
                            let elem = this.template.querySelector('#startEndDateError');
                            elem.parentNode.removeChild(elem);
                        }
                    }
                })
                .catch(error => {
                    this.spinnerDeg = false;
                    console.error('Error: ' + JSON.stringify(error));
                });           
            if (fieldvals.Degree_Title__c === undefined || fieldvals.Degree_Title__c === '') {
                this.showError = true;
                this.formsubmitdegree = false;
                this.spinnerDeg = false;
                if (this.template.querySelector('#degTitleError') === null) {
                    degTitleErrHel(this.template);
                }
            } else {
                //Select valid Degree Title    
                this.template.querySelector('input.degreeRecord').classList.remove('slds-has-error');
                if (this.template.querySelector('#degTitleError') !== null) {
                    let elem = this.template.querySelector('#degTitleError');
                    elem.parentNode.removeChild(elem);
                }
                const degreeTitleList = [];
                this.template.querySelectorAll('.degreeRecordDatalist option').forEach(element => {
                    degreeTitleList.push(element.value);
                });
                if (degreeTitleList.indexOf(this.degreetitle) === -1) {
                    this.showError = true;
                    this.formsubmitdegree = false;
                    this.spinnerDeg = false;
                    if (this.template.querySelector('#degTitleError') === null) {
                        degTitleErrHel2(this.template);
                    }
                }
            }
            // blank Graduation Year check
            if (fieldvals.gradYear === undefined || fieldvals.gradYear === '' ||
                fieldvals.gradMonth === undefined || fieldvals.gradMonth === '') {
                this.showError = true;
                this.formsubmitdegree = false;
                this.spinnerDeg = false;
                if (this.template.querySelector('#gradDateError') === null) {
                    gradDateErrHel(this.template);
                }
            } else {
                this.template.querySelector('.gradYearRecord').classList.remove('slds-has-error');
                this.template.querySelector('.gradMonthRecord').classList.remove('slds-has-error');
                if (this.template.querySelector('#gradDateError') !== null) {
                    let elem = this.template.querySelector('#gradDateError');
                    elem.parentNode.removeChild(elem);
                }
                const yearList = [];
                this.template.querySelectorAll('.gradYearRecordDatalist option').forEach(element => {
                    yearList.push(element.value);
                });
                if (yearList.indexOf(this.template.querySelector("input.gradYearRecord").value) === -1) {
                    this.showError = true;
                    this.formsubmitdegree = false;
                    this.spinnerDeg = false;
                    if (this.template.querySelector('#gradDateError') === null) {
                        gradDateHelper(this.template);
                    }
                }
            }
            //Add code to validate Degree Issue Year & Month.
            //Code added below by Shailaja. 9/29/2020.
            if (fieldvals.Degree_Issue_Month__c === undefined || fieldvals.Degree_Issue_Month__c === '' || fieldvals.Degree_Issue_Month__c === null ||
                fieldvals.Degree_Issue_Year__c === undefined || fieldvals.Degree_Issue_Year__c === '' || fieldvals.Degree_Issue_Year__c === null) {
                this.showError = true;
                this.formsubmitdegree = false;
                this.degdate = false;
                this.spinnerDeg = false;
                if (this.template.querySelector('#degDateError') === null) {
                    blankDegDateErr(this.template);
                }
            } else {
                if (this.template.querySelector('#degDateError') !== null && this.degdate) {
                    let elem = this.template.querySelector('#degDateError');
                    elem.parentNode.removeChild(elem);
                }
            }
            this.checkDegreeDate(fieldvals.End_Month__c, fieldvals.End_Year__c, fieldvals.Degree_Issue_Month__c, fieldvals.Degree_Issue_Year__c);
            errorMessageOFACSoft({
                    accountId: fieldvals.Account__c
                })
                .then(result => {
                    if (result) {
                        this.spinnerDeg = false;
                        this.showWarning = true;
                        this.warningMessagesText = countryWarning;
                    }
                })
                .catch(error => {
                    this.spinnerDeg = false;
                    console.error('Error: ' + JSON.stringify(error));
                });
            //New code by Shailaja. Date format stories. New Start Month & Year & End Month & Year
            //Checking From Date and To Date Validation for Student  - New Start & End Dates        
            //Code added to calculate the month index and construct the date.
            var startMonthIndex;
            var endMonthIndex;
            if (fieldvals.Start_Year__c !== '' && fieldvals.Start_Year__c !== null && fieldvals.Start_Month__c !== '' && fieldvals.Start_Month__c !== null) {
                let sTempDate = fieldvals.Start_Year__c + '-' + fieldvals.Start_Month__c + '-' + '01';
                var sDate = new Date(sTempDate);
                startMonthIndex = String(sDate.getMonth() + 1).padStart(2, '0');
            }
            if (fieldvals.End_Year__c !== '' && fieldvals.End_Year__c !== null && fieldvals.End_Month__c !== '' && fieldvals.End_Month__c !== null) {
                let eTempDate = fieldvals.End_Year__c + '-' + fieldvals.End_Month__c + '-' + '01';
                var eDate = new Date(eTempDate);
                endMonthIndex = String(eDate.getMonth() + 1).padStart(2, '0');
            }
            errorMessageNewCurrentDate({
                    type: fieldvals.Status__c,
                    startMonth: startMonthIndex,
                    startYear: fieldvals.Start_Year__c,
                    endMonth: endMonthIndex,
                    endYear: fieldvals.End_Year__c
                })
                .then(result => {
                    if (result) {
                        this.showError = true;
                        this.formsubmitdegree = false;
                        this.degdate = false;
                        this.spinnerDeg = false;
                        if (this.template.querySelector('#endDatefutureErrorStudent') === null) {
                            endDateFutErrHel(this.template);
                        }
                    } else {
                        if (this.template.querySelector('#endDatefutureError') != null) {
                            let elem = this.template.querySelector('#endDatefutureError');
                            elem.parentNode.removeChild(elem);
                        }
                        if (this.template.querySelector('#endDatefutureErrorStudent') != null) {
                            let elem = this.template.querySelector('#endDatefutureErrorStudent');
                            elem.parentNode.removeChild(elem);
                        }
                        if (fieldvals.Status__c === MedicalEducationTypeGraduate) {
                            startAndEndDateValidation({
                                startMonth: fieldvals.Start_Month__c,
                                startYear: fieldvals.Start_Year__c,
                                endMonth: fieldvals.End_Month__c,
                                endYear: fieldvals.End_Year__c
                            }).then(value => {
                                if (value) {
                                    this.showError = true;
                                    this.formsubmitdegree = false;
                                    this.degdate = false;
                                    this.spinnerDeg = false;
                                    if (this.template.querySelector('#endDatefutureError') === null) {
                                        newDateValHel(this.template);
                                    }
                                } else {
                                    if (this.template.querySelector('#endDatefutureError') != null) {
                                        let elem = this.template.querySelector('#endDatefutureError');
                                        elem.parentNode.removeChild(elem);
                                    }
                                    this.formSubmitDegreeMedicalSchool(fieldvals.gradMonth, fieldvals.gradYear, fieldvals.End_Month__c, fieldvals.End_Year__c, fieldvals);
                                }
                            })
                        } else {
                            this.formSubmitDegreeMedicalSchool(fieldvals.gradMonth, fieldvals.gradYear, fieldvals.End_Month__c, fieldvals.End_Year__c, fieldvals);
                        }
                    }
                })
                .catch(error => {
                    this.spinnerDeg = false;
                    console.error('Error: ' + JSON.stringify(error));
                });

        } else {
            this.saveAllValues();
        }
        window.scrollTo(0, 0);
    }
    checkDegreeDate(endMonth, endYear, degMonth, degYear) {
        var addtendaceEndDate = new Date(endMonth + "-" + "01" + "-" + endYear)
        var degreeDate = new Date(degMonth + "-" + "01" + "-" + degYear)
        if (degreeDate < addtendaceEndDate) {
            this.showError = true;
            this.formsubmitdegree = false;
            this.degdate = false;
            this.spinnerDeg = false;
            if (this.template.querySelector('#degDateErrorNew') === null) {
                checkDegreeDateHelper(this.template);
            }
        }else{
            if (this.template.querySelector('#degDateErrorNew') !== null && this.degdate) {
                let elem = this.template.querySelector('#degDateErrorNew');
                elem.parentNode.removeChild(elem);
            }
        }
    }
    formSubmitDegreeMedicalSchool(gradMonth, gradYear, endMonth, endYear, fieldvals) {
        // Graduation date always greater than TO date        
        errorMessageNewGraduationDate({
                gradMonth: gradMonth,
                gradYear: gradYear,
                endMonth: endMonth,
                endYear: endYear
            })
            .then(result1 => {
                if (result1) {
                    this.showError = true;
                    this.formsubmitdegree = false;
                    this.spinnerDeg = false;
                    if (this.template.querySelector('#gradDateError') === null) {
                        createGradDateHel(this.template);
                    }
                } else {
                    if (this.formsubmitdegree) {
                        this.showError = false;
                        this.template.querySelector('.gradYearRecord').classList.remove('slds-has-error');
                        this.template.querySelector('.gradMonthRecord').classList.remove('slds-has-error');
                        if (this.template.querySelector('#gradDateError') !== null) {
                            let elem5 = this.template.querySelector('#gradDateError');
                            elem5.parentNode.removeChild(elem5);
                        }
                        this.spinnerDeg = false;
                        this.degreeSchoolValue = JSON.stringify(fieldvals);
                        if (this.showAllTCT) {
                            this.saveAllValues();
                        } else {
                            this.isnotLegalPage = false;
                            this.isLegalPage = false;
                        }
                    }
                }
            })
            .catch(error => {
                this.spinnerDeg = false;
                console.error('Error: ' + JSON.stringify(error));
            });
    }
    @wire(getAllConstants)
    allConstants({
        error,
        data
    }) {
        if (data) {
            this.appForCertVar = data.LWC_PRODUCT_NAME_APP_FOR_CERT_LEGAL_TERMS;

        } else {
            this.error = error;
        }
    }
    get options() {
        return [{
                label: 'Pass',
                value: 'Pass'
            },
            {
                label: 'Fail',
                value: 'Fail'
            },
        ];
    }
    get monthoptions() {
        return [{
                label: 'January',
                value: 'January'
            },
            {
                label: 'Febraury',
                value: 'Febraury'
            },
            {
                label: 'March',
                value: 'March'
            },
            {
                label: 'April',
                value: 'April'
            },
            {
                label: 'May',
                value: 'May'
            },
            {
                label: 'June',
                value: 'June'
            },
            {
                label: 'July',
                value: 'July'
            },
            {
                label: 'August',
                value: 'August'
            },
            {
                label: 'September',
                value: 'September'
            },
            {
                label: 'October',
                value: 'October'
            },
            {
                label: 'November',
                value: 'November'
            },
            {
                label: 'December',
                value: 'December'
            }
        ];
    }
    // accepted parameters
    get acceptedFormats() {
        return ['.pdf', '.png', '.jpg', '.jpeg'];
    }
    @wire(getInCompleteCaseId)
    caseIdfromController(result) {
        this.refreshCase = result;
        if (result.data !== undefined) {
            this.caseId = result.data;
        }
    }
    connectedCallback() {
        this.isErrMsgDeanDate = false;
        this.isErrMsgName = false;
        this.isErrMsgTran = false;
        this.isErrMsgMainFiles = false;
        this.isnotLegalPage = true;
        this.isLegalPage = true;
        this.loadDetails();
    }
    get tabClass() {
        return this.isLegalPage ? 'displayblock' : 'displaynone';
    }
    get tabnegClass() {
        return this.isnotLegalPage ? 'displaynone' : 'displayblock';
    }
    loadDetails() {
        this.showConfirmation = false;
        this.showDegreeSchool = false;
        getOtherMedicalSchool()
            .then(data => {
                if (data) {
                    if (data.length > 0) {
                        this.getOtherInstitutionData = data;
                        this.isOthIns = true;
                    }
                }
            })
            .catch()
        getAssetsAndDocumentsForOtherMedical()
            .then(data => {
                if (data) {
                    this.instAssetsList = data;
                    this.showAll = false;
                    for (const key in this.getOtherInstitutionData) {
                        if (this.getOtherInstitutionData.hasOwnProperty(key)) {
                            let ele = this.getOtherInstitutionData[key];
                            for (const assKey in this.instAssetsList) {
                                if (this.instAssetsList.hasOwnProperty(assKey)) {
                                    if (ele.Id === assKey) {
                                        let assEle = this.instAssetsList[assKey];
                                        if (assEle.showGraduate === 'Yes') {
                                            ele.isGraduate = true;
                                            ele.fmdId = '';
                                            ele.fmdFile = '';
                                            ele.fmdName = '';
                                            ele.fmdNameDiff = '';
                                            ele.fmdNameDoc = '';
                                            ele.fmdTransId = '';
                                            ele.fmdTrans = '';
                                            ele.fmdTransFile = '';
                                            ele.fmdTransName = '';
                                            ele.fmdTransNameDiff = '';
                                            ele.fmdTransNameDoc = '';
                                            ele.dlId = '';
                                            ele.dlFile = '';
                                            ele.dlName = '';
                                            ele.dlNameDiff = '';
                                            ele.dlNameDoc = '';
                                            ele.dlTransId = '';
                                            ele.dlTrans = '';
                                            ele.dlTransFile = '';
                                            ele.dlTransName = '';
                                            ele.dlTransNameDiff = '';
                                            ele.dlTransNameDoc = '';
                                            ele.dlDate = '';
                                            ele.ftId = '';
                                            ele.ftFile = '';
                                            ele.ftName = '';
                                            ele.ftNameDiff = '';
                                            ele.ftNameDoc = '';
                                            ele.ftTransId = '';
                                            ele.ftTrans = '';
                                            ele.ftTransFile = '';
                                            ele.ftTransName = '';
                                            ele.ftTransNameDiff = '';
                                            ele.ftTransNameDoc = '';
                                            ele.isDeanLetter = assEle.isDeanLetter;
                                            ele.isFTReqd = assEle.isFTReqd;
                                            ele.fmdFileName = '';
                                            ele.fmdNameDocName = '';
                                            ele.fmdTransFileName = '';
                                            ele.fmdTransNameDocName = '';
                                            ele.dlFileName = '';
                                            ele.dlNameDocName = '';
                                            ele.dlTransFileName = '';
                                            ele.dlTransNameDocName = '';
                                            ele.ftFileName = '';
                                            ele.ftNameDocName = '';
                                            ele.ftTransFileName = '';
                                            ele.ftTransNameDocName = '';
                                            ele.fmdFileType = '';
                                            ele.fmdNameDocType = '';
                                            ele.fmdTransFileType = '';
                                            ele.fmdTransNameDocType = '';
                                            ele.dlFileType = '';
                                            ele.dlNameDocType = '';
                                            ele.dlTransFileType = '';
                                            ele.dlTransNameDocType = '';
                                            ele.ftFileType = '';
                                            ele.ftNameDocType = '';
                                            ele.ftTransFileType = '';
                                            ele.ftTransNameDocType = '';
                                            ele.fmdNameId = '';
                                            ele.fmdTransNameId = '';
                                            ele.dlNameId = '';
                                            ele.dlTransNameId = '';
                                            ele.ftNameId = '';
                                            ele.ftTransNameId = '';
                                            ele.fmdNameErrorFlag = false;
                                            ele.ftNameErrorFlag = false;
                                            ele.dlNameErrorFlag = false;
                                            ele.fmdFileErrorFlag = false;
                                            ele.fmdTransFileErrorFlag = false;
                                            ele.ftFileErrorFlag = false;
                                            ele.ftTransFileErrorFlag = false;
                                            ele.dlFileErrorFlag = false;
                                            ele.dlTransFileErrorFlag = false;
                                            ele.dlDateErrorFlag = false;
                                            ele.tcCourseTitErrorFlag = false;
                                            ele.tcCourseNumErrorFlag = false;
                                            ele.tcCourseOutErrorFlag = false;
                                            ele.tcCourseMonErrorFlag = false;
                                            ele.tcCourseYrErrorFlag = false;
                                            if (assEle.isDeanLetter === 'Yes') {
                                                ele.isDeanLet = true;
                                            }
                                            if (assEle.isFTReqd === 'Yes') {
                                                ele.ftReqdCond = true;
                                            }
                                        }
                                        ele.tctId = '';
                                        ele.tctFile = '';
                                        ele.tctName = '';
                                        ele.tctNameDiff = '';
                                        ele.tctNameDoc = '';
                                        ele.tctTransId = '';
                                        ele.tctTrans = '';
                                        ele.tctTransFile = '';
                                        ele.tctTransName = '';
                                        ele.tctTransNameDiff = '';
                                        ele.tctTransNameDoc = '';
                                        ele.tctFileName = '';
                                        ele.tctNameDocName = '';
                                        ele.tctTransFileName = '';
                                        ele.tctTransNameDocName = '';
                                        ele.tctFileType = '';
                                        ele.tctNameDocType = '';
                                        ele.tctTransFileType = '';
                                        ele.tctTransNameDocType = '';
                                        ele.tctFileAffirmation = assEle.tctFileAffirmation;
                                        ele.tctNameDocAffirmation = assEle.tctNameDocAffirmation;
                                        ele.tctTransFileAffirmation = assEle.tctTransFileAffirmation;
                                        ele.courceDetailsAffirmation = assEle.courceDetailsAffirmation;
                                        ele.tctNameId = '';
                                        ele.tctTransNameId = '';
                                        ele.oldtctFile = assEle.tctFile;
                                        ele.oldtctNameDoc = assEle.tctNameDoc;
                                        ele.oldtctTransFile = assEle.tctTransFile;
                                        ele.oldpmlFile = assEle.pmlFile;
                                        ele.oldpmlNameDoc = assEle.pmlNameDoc;
                                        ele.oldpmlTransFile = assEle.pmlTransFile;
                                        ele.oldftFile = assEle.ftFile;
                                        ele.oldftNameDoc = assEle.ftNameDoc;
                                        ele.oldftTransFile = assEle.ftTransFile;
                                        ele.olddlFile = assEle.dlFile;
                                        ele.olddlNameDoc = assEle.dlNameDoc;
                                        ele.olddlTransFile = assEle.dlTransFile;
                                        ele.oldfmdFile = assEle.fmdFile;
                                        ele.oldfmdNameDoc = assEle.fmdNameDoc;
                                        ele.oldfmdTransFile = assEle.fmdTransFile;
                                        loadPayload(assEle,ele,this.caseId);
                                        let oldfmdFilePayloadJson = {
                                            "contactId": ele.Contact__c,
                                            "caseId": String(this.caseId),
                                            "catId": ele.Id,
                                            "documentType": "Final Medical Diploma",
                                            "assetRecordType": "Credential",
                                            "createOrReplace": "null",
                                            "assetStatus": "null",
                                            "assetCreationRequired": "null",
                                            "assetId": assEle.fmdId
                                        };
                                        ele.oldfmdFilePayload = JSON.stringify(oldfmdFilePayloadJson);
                                        ele.oldfmdNameDocId = assEle.fmdNameId;
                                        let oldfmdNamePayloadJson = {
                                            "contactId": ele.Contact__c,
                                            "caseId": String(this.caseId),
                                            "catId": ele.Id,
                                            "documentType": "Final Diploma Name Document",
                                            "assetRecordType": "Identity",
                                            "createOrReplace": "null",
                                            "assetStatus": "null ",
                                            "assetCreationRequired": "null",
                                            "assetId": ele.oldfmdNameDocId
                                        };
                                        ele.oldfmdNamePayload = JSON.stringify(oldfmdNamePayloadJson);
                                        ele.oldfmdTransId = assEle.fmdTransId;
                                        let oldfmdTrnPayloadJson = {
                                            "contactId": ele.Contact__c,
                                            "caseId": String(this.caseId),
                                            "catId": ele.Id,
                                            "documentType": "Final Diploma Translation",
                                            "assetRecordType": "Credential",
                                            "createOrReplace": "null",
                                            "assetStatus": "null",
                                            "assetCreationRequired": "null",
                                            "assetId": ele.oldfmdTransId
                                        };
                                        ele.oldfmdTrnPayload = JSON.stringify(oldfmdTrnPayloadJson);
                                        let fmdPayloadJson = {
                                            "contactId": ele.Contact__c,
                                            "caseId": String(this.caseId),
                                            "catId": ele.Id,
                                            "documentType": "Final Medical Diploma",
                                            "assetRecordType": "Credential",
                                            "createOrReplace": "Create",
                                            "assetStatus": "In Progress",
                                            "assetCreationRequired": "true",
                                            "assetId": "null"
                                        };
                                        ele.fmdPayload = JSON.stringify(fmdPayloadJson);
                                        let fmdNamePayloadJson = {
                                            "contactId": ele.Contact__c,
                                            "caseId": String(this.caseId),
                                            "catId": ele.Id,
                                            "documentType": "Final Diploma Name Document",
                                            "assetRecordType": "Identity",
                                            "createOrReplace": "Create",
                                            "assetStatus": "In Progress",
                                            "assetCreationRequired": "true",
                                            "assetId": "null"
                                        };
                                        ele.fmdNamePayload = JSON.stringify(fmdNamePayloadJson);
                                        let fmdTrnPayloadJson = {
                                            "contactId": ele.Contact__c,
                                            "caseId": String(this.caseId),
                                            "catId": ele.Id,
                                            "documentType": "Final Diploma Translation",
                                            "assetRecordType": 'Credential',
                                            "createOrReplace": "Create",
                                            "assetStatus": "In Progress",
                                            "assetCreationRequired": "true",
                                            "assetId": "null"
                                        };
                                        ele.fmdTrnPayload = JSON.stringify(fmdTrnPayloadJson);
                                        let oldftFilePayloadJson = {
                                            "contactId": ele.Contact__c,
                                            "caseId": String(this.caseId),
                                            "catId": ele.Id,
                                            "documentType": "Final Medical School Transcript",
                                            "assetRecordType": "Credential",
                                            "createOrReplace": "null",
                                            "assetStatus": "null",
                                            "assetCreationRequired": "null",
                                            "assetId": assEle.ftId
                                        };
                                        ele.oldftFilePayload = JSON.stringify(oldftFilePayloadJson);
                                        ele.oldftNameDocId = assEle.ftNameId;
                                        let oldftNamePayloadJson = {
                                            "contactId": ele.Contact__c,
                                            "caseId": String(this.caseId),
                                            "catId": ele.Id,
                                            "documentType": "Final Transcript Name Document",
                                            "assetRecordType": "Identity",
                                            "createOrReplace": "null",
                                            "assetStatus": "null ",
                                            "assetCreationRequired": "null",
                                            "assetId": ele.oldftNameDocId
                                        };
                                        ele.oldftNamePayload = JSON.stringify(oldftNamePayloadJson);
                                        ele.oldftTransId = assEle.ftTransId;
                                        let oldftTrnPayloadJson = {
                                            "contactId": ele.Contact__c,
                                            "caseId": String(this.caseId),
                                            "catId": ele.Id,
                                            "documentType": "Final Transcript Translation",
                                            "assetRecordType": "Credential",
                                            "createOrReplace": "null",
                                            "assetStatus": "null",
                                            "assetCreationRequired": "null",
                                            "assetId": ele.oldftTransId
                                        };
                                        ele.oldftTrnPayload = JSON.stringify(oldftTrnPayloadJson);
                                        let ftPayloadJson = {
                                            "contactId": ele.Contact__c,
                                            "caseId": String(this.caseId),
                                            "catId": ele.Id,
                                            "documentType": "Final Medical School Transcript",
                                            "assetRecordType": "Credential",
                                            "createOrReplace": "Create",
                                            "assetStatus": "In Progress",
                                            "assetCreationRequired": "true",
                                            "assetId": "null"
                                        };
                                        ele.ftPayload = JSON.stringify(ftPayloadJson);
                                        let ftNamePayloadJson = {
                                            "contactId": ele.Contact__c,
                                            "caseId": String(this.caseId),
                                            "catId": ele.Id,
                                            "documentType": "Final Transcript Name Document",
                                            "assetRecordType": "Identity",
                                            "createOrReplace": "Create",
                                            "assetStatus": "In Progress",
                                            "assetCreationRequired": "true",
                                            "assetId": "null"
                                        };
                                        ele.ftNamePayload = JSON.stringify(ftNamePayloadJson);
                                        let ftTrnPayloadJson = {
                                            "contactId": ele.Contact__c,
                                            "caseId": String(this.caseId),
                                            "catId": ele.Id,
                                            "documentType": "Final Transcript Translation",
                                            "assetRecordType": "Credential",
                                            "createOrReplace": "Create",
                                            "assetStatus": "In Progress",
                                            "assetCreationRequired": "true",
                                            "assetId": "null"
                                        };
                                        ele.ftTrnPayload = JSON.stringify(ftTrnPayloadJson);
                                        if (ele.oldtctFile !== '' && ele.oldtctFile !== undefined) {
                                            ele.oldtctFileFlag = true;
                                        }
                                        if (ele.oldtctNameDocId) {
                                            ele.oldtctNameDocFlag = true;
                                        }
                                        if (ele.oldtctTransId) {
                                            ele.oldtctTransFileFlag = true;
                                        }
                                        if (ele.oldpmlFile !== '' && ele.oldpmlFile !== undefined) {
                                            ele.oldpmlFileFlag = true;
                                        }
                                        if (ele.oldpmlNameDocId) {
                                            ele.oldpmlNameDocFlag = true;
                                        }
                                        if (ele.oldpmlTransId) {
                                            ele.oldpmlTransFileFlag = true;
                                        }
                                        if (ele.oldftFile !== '' && ele.oldftFile !== undefined) {
                                            ele.oldftFileFlag = true;
                                        }
                                        if (ele.oldftNameDocId) {
                                            ele.oldftNameDocFlag = true;
                                        }
                                        if (ele.oldftTransId) {
                                            ele.oldftTransFileFlag = true;
                                        }
                                        if (ele.olddlFile !== '' && ele.olddlFile !== undefined) {
                                            ele.olddlFileFlag = true;
                                        }
                                        if (ele.olddlNameDocId) {
                                            ele.olddlNameDocFlag = true;
                                        }
                                        if (ele.olddlTransId) {
                                            ele.olddlTransFileFlag = true;
                                        }
                                        if(ele.oldfmdFile !== '' && ele.oldfmdFile !== undefined){
                                            ele.oldfmdFileFlag = true;
                                        }                                     
                                        if(ele.oldfmdNameDocId){
                                            ele.oldfmdNameDocFlag = true;
                                        }
                                        if(ele.oldfmdTransId){
                                            ele.oldfmdTransFileFlag = true;
                                        }
                                        ele.tctNameErrorFlag = false;
                                        ele.pmlNameErrorFlag = false;
                                        ele.tctFileErrorFlag = false;
                                        ele.tctTransFileErrorFlag = false;
                                        ele.pmlFileErrorFlag = false;
                                        ele.pmlTransFileErrorFlag = false;
                                        ele.tctNameDocFileErrorFlag = false;
                                        ele.tctTransDocFileErrorFlag = false;
                                        if (assEle.courceDetailsAffirmation === 'Yes') {
                                            ele.showCourse = true;
                                            let tccourse = ele.Transfer_Credits__r;
                                            for (var i = 0; i < tccourse.length; i++) {
                                                tccourse[i].showTCAdd = true;
                                                if (tccourse.length > 1) {
                                                    tccourse[i].showTCDel = true;
                                                } else {
                                                    tccourse[i].showTCDel = false;
                                                }
                                            }
                                        }
                                        if (assEle.tctFileAffirmation === 'Yes' && assEle.tctFileAffirmation !== 'undefined') {
                                            ele.showtctFile = true;
                                        }
                                        if (assEle.tctNameCondLabAffr === 'Yes' && assEle.tctNameCondLabAffr !== 'undefined') {
                                            ele.tctNameCondLabAffr = true;
                                        }
                                        if (assEle.tctTranslationLabAffr === 'Yes' && assEle.tctTranslationLabAffr !== 'undefined') {
                                            ele.tctTranslationLabAffr = true;
                                        }
                                        if (ele.tctTranslationLabAffr === true || ele.tctNameCondLabAffr === true) {
                                            ele.tctLabAffr = true;
                                        }
                                        if (assEle.tctFileAffirmation === 'No' && assEle.tctNameDocAffirmation === 'Yes' && assEle.tctNameDocAffirmation !== 'undefined' && assEle.tctNameDiff === 'Yes' && assEle.tctFile !== '') {
                                            ele.tctNameCond = true;
                                            ele.tctId = assEle.tctId;
                                        }
                                        if (assEle.tctFileAffirmation === 'No' && assEle.tctTransFileAffirmation === 'Yes' && assEle.tctTransFileAffirmation !== 'undefined' && assEle.tctTrans === 'Yes' && assEle.tctFile !== '') {
                                            ele.tctTransCond = true;
                                            ele.tctId = assEle.tctId;
                                        }
                                        ele.pmlId = '';
                                        ele.pmlFile = '';
                                        ele.pmlName = '';
                                        ele.pmlNameDiff = '';
                                        ele.pmlNameDoc = '';
                                        ele.pmlTransId = '';
                                        ele.pmlTrans = '';
                                        ele.pmlTransFile = '';
                                        ele.pmlTransName = '';
                                        ele.pmlTransNameDiff = '';
                                        ele.pmlTransNameDoc = '';
                                        ele.pmlFileName = '';
                                        ele.pmlNameDocName = '';
                                        ele.pmlTransFileName = '';
                                        ele.pmlTransNameDocName = '';
                                        ele.pmlFileType = '';
                                        ele.pmlNameDocType = '';
                                        ele.pmlTransFileType = '';
                                        ele.pmlTransNameDocType = '';
                                        ele.pmlNameId = '';
                                        ele.pmlTransNameId = '';
                                        ele.pmlFileAffirmation = '';
                                        ele.pmlNameDocAffirmation = '';
                                        ele.pmlTransFileAffirmation = '';
                                        ele.pmlTransNameDocAffirmation = '';
                                        if (assEle.pmlFileAffirmation === 'Yes' && assEle.pmlFileAffirmation !== 'undefined') {
                                            ele.showpmlFile = true;
                                        }                                       
                                        if (assEle.degreeSchool === 'Yes') {
                                            this.showDegreeSchool = true;
                                            this.objectIdDegree = ele.Id;
                                            this.degreeComment = assEle.comment;
                                            this.objectIdDegreeName = ele.Account_Name__c;
                                        }
                                        if (ele.showtctFile === true || ele.showpmlFile === true ||
                                            ele.showCourse === true || ele.tctNameCond === true || ele.tctTransCond === true ||
                                            assEle.showGraduate === 'Yes') {
                                            ele.showHeader = true;
                                            this.showAllTCT = true;
                                        }
                                        if (ele.showtctFile === true || ele.showpmlFile === true ||
                                            ele.showCourse === true || ele.tctNameCond === true || ele.tctTransCond === true ||
                                            assEle.showGraduate === 'Yes' || assEle.degreeSchool === 'Yes') {
                                            this.showAll = true;
                                            if (assEle.degreeSchool === 'Yes') {
                                                getSchoolRecords()
                                                    .then(dataSch => {
                                                        if (dataSch && dataSch.length > 0) {                                                           
                                                                this.schoolRecordValues = dataSch;
                                                                let listId = this.template.querySelector('datalist.schoolRecordDatalist').id;
                                                                this.template.querySelector("input.schoolRecord").setAttribute("list", listId);
                                                                let listId2 = this.template.querySelector('datalist.degreeRecordDatalist').id;
                                                                this.template.querySelector("input.degreeRecord").setAttribute("list", listId2);
                                                                let listId3 = this.template.querySelector('datalist.gradYearRecordDatalist').id;
                                                                this.template.querySelector("input.gradYearRecord").setAttribute("list", listId3);                                                        
                                                        }
                                                    })
                                                    .catch()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            })
            .catch()
    }
    handleUploadTCT(event) {
        handleUploadTCTHelper(event, this.getOtherInstitutionData);
    }
    handleUploadTCTName(event) {
        handleUploadTCTNameHelper(event, this.getOtherInstitutionData);
    }
    handleUploadTCTTrans(event) {
        handleUploadTCTTransHelper(event, this.getOtherInstitutionData);
    }
    handleUploadPremed(event) {
        handleUploadPremedHelper(event, this.getOtherInstitutionData);
    }
    handleUploadPremedName(event) {
        handleUploadPremedNameHelper(event, this.getOtherInstitutionData);
    }
    handleUploadPremedTrans(event) {
        handleUploadPremedTransHelper(event, this.getOtherInstitutionData);
    }
    handleUploadfmd(event) {
        handleUploadfmdHelper(event, this.getOtherInstitutionData);
    }
    handleUploadfmdName(event) {
        handleUploadfmdNameHelper(event, this.getOtherInstitutionData);
    }
    handleUploadfmdTrans(event) {
        handleUploadfmdTransHelper(event, this.getOtherInstitutionData);
    }
    handleUploaddl(event) {
        handleUploaddlHelper(event, this.getOtherInstitutionData);
    }
    handleUploaddlName(event) {
        handleUploaddlNameHelper(event, this.getOtherInstitutionData);
    }
    handleUploaddlTrans(event) {
        handleUploaddlTransHelper(event, this.getOtherInstitutionData);
    }
    handleUploadFt(event) {
        handleUploadftHelper(event, this.getOtherInstitutionData);
    }
    handleUploadftName(event) {
        handleUploadftNameHelper(event, this.getOtherInstitutionData);
    }
    handleUploadftTrans(event) {
        handleUploadftTransHelper(event, this.getOtherInstitutionData);
    }
    handleChangeTCTName(event) {
        handleChangeTCTNameHelper(event, this.getOtherInstitutionData, this.instAssetsList);
    }
    handleChangeTCTTrans(event) {
        handleChangeTCTTransHelper(event, this.getOtherInstitutionData, this.instAssetsList);
    }
    handleChangePreName(event) {
        handleChangePreNameHelper(event, this.getOtherInstitutionData, this.instAssetsList);
    }
    handleChangePreTrans(event) {
        handleChangePreTransHelper(event, this.getOtherInstitutionData, this.instAssetsList);
    }
    handleChangefmdName(event) {
        handleChangefmdNameHelper(event, this.getOtherInstitutionData, this.instAssetsList);
    }
    handleChangefmdTrans(event) {
        handleChangefmdTransHelper(event, this.getOtherInstitutionData, this.instAssetsList);
    }
    handleChangeftName(event) {
        handleChangeftNameHelper(event, this.getOtherInstitutionData, this.instAssetsList);
    }
    handleChangeftTrans(event) {
        handleChangeftTransHelper(event, this.getOtherInstitutionData, this.instAssetsList);
    }
    handleChangedlName(event) {
        handleChangedlNameHelper(event, this.getOtherInstitutionData, this.instAssetsList);
    }
    handleChangedlTrans(event) {
        handleChangedlTransHelper(event, this.getOtherInstitutionData, this.instAssetsList);
    }
    validateTransferCreditGradeInput(event) {
        validateTransferCreditGradeInputHelper(event);
    }
    nextButton(event) {
        event.preventDefault();
        this.formSubmit = false;
        this.formsubmitdegree = false;
        this.handleSubmit();
    }
    saveAllValues() {
        let allWrapper = this.template.querySelectorAll(".recordFieldsWrapper");
        this.formSubmit = true;
        this.isErrMsgDeanDate = false;
        this.isErrMsgTran = false;
        this.isErrMsgMainFiles = false;
        this.isErrMsgName = false;
        let errorCounter = [];
        let errCount = 0;
        let errorCounterDeanDate = [];
        let errDlCount = 0;
        let errorCounterTran = [];
        let errTrCount = 0;
        let errorCounterMainFiles = [];
        let counter = 0;
        let errorCounterCourseDetails = [];
        let courseCounter = 0;
        let recordValuesToSave = [];
        let tctNameReqVal = false;
        let pmlNameReqVal = false;
        let fmdNameReqVal = false;
        let ftNameReqVal = false;
        let dlNameReqVal = false;
        let tctFileReqVal = false;
        let tctTransFileReqVal = false;
        let pmlFileReqVal = false;
        let pmlTransFileReqVal = false;
        let fmdFileReqVal = false;
        let fmdTransFileReqVal = false;
        let ftTransFileReqVal = false;
        let dlFileReqVal = false;
        let dlTransFileReqVal = false;
        let dlDateReqVal = false;
        let tctNameDocFileReqVal = false;
        let tctTransDocFileReqVal = false;
        let tcCourseTitVal = false;
        let tcCourseNumVal = false;
        let tcCourseOutVal = false;
        let tcCourseMonVal = false;
        let tcCourseYrVal = false;
        let fileReqKey = '';
        let fileNameReq = [];
        allWrapper.forEach(function (element) {
            let tempSchoolRecord = {recordIdVal: element.getAttribute('data-record-id')}
            tctNameReqVal = false;
            pmlNameReqVal = false;
            fmdNameReqVal = false;
            ftNameReqVal = false;
            dlNameReqVal = false;
            tctFileReqVal = false;
            tctTransFileReqVal = false;
            pmlFileReqVal = false;
            pmlTransFileReqVal = false;
            fmdFileReqVal = false;
            fmdTransFileReqVal = false;
            ftTransFileReqVal = false;
            dlFileReqVal = false;
            dlTransFileReqVal = false;
            dlDateReqVal = false;
            tcCourseTitVal = false;
            tcCourseNumVal = false;
            tcCourseOutVal = false;
            tcCourseMonVal = false;
            tcCourseYrVal = false;
            fileReqKey = '';
            tempSchoolRecord.tcWrapperList = [];
            let tcDetailsRow = element.querySelectorAll(".tcDetailsRow");
            let tcCourseNameReq = [];
            if (element.querySelector(".otherSchoolRecord") !== null) {
                let tempFromSchool = element.querySelector(".otherSchoolRecord").getAttribute('data-otherschool-id');
                if (tcDetailsRow.length > 0) {                    
                    let errorCouTit = [],errorCouNum = [],errorCouOut = [],errorCouMon = [],errorCouYr = [],errorCouTCGreater = [];
                    let tcCourse,tcGrade,tcOutcome,tcMon,tcYear,tcDate,tcIndexCounter = 0;
                    let tcCourseChecker = false;
                    tcDetailsRow.forEach(function (elem) {
                        tcCourseChecker = false;
                        let tempTcRecord = {
                            recordIdVal: elem.getAttribute('data-tcid'),
                            fromSchool: tempFromSchool,
                            transferCreditCourse: elem.querySelector(".transferCreditCourseInput").value,
                            transferCreditGrade: elem.querySelector(".transferCreditGradeInput").value,
                            courseOutcome: elem.querySelector(".transferCreditCourseOutcomeInput").value,
                            creditsEarnedMonth: elem.querySelector(".creditEarnedMonthInput").value,
                            creditsEarnedYear: elem.querySelector(".creditEarnedYearInput").value
                        }                        
                        if (tempTcRecord.transferCreditCourse !== '' && tempTcRecord.transferCreditCourse !== null && tempTcRecord.transferCreditGrade !== '' && tempTcRecord.transferCreditGrade !== null && tempTcRecord.courseOutcome !== '' && tempTcRecord.courseOutcome !== null && tempTcRecord.creditsEarnedMonth !== '' && tempTcRecord.creditsEarnedMonth !== null && tempTcRecord.creditsEarnedYear !== '' && tempTcRecord.creditsEarnedYear !== null) {                            
                            if (tempTcRecord.creditsEarnedMonth !== '' && tempTcRecord.creditsEarnedMonth !== null &&
                                tempTcRecord.creditsEarnedYear !== '' && tempTcRecord.creditsEarnedYear !== null) {                                    
                                let checkMonthYear = false;
                                let today = new Date();
                                let mon = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
                                let yr = today.getFullYear();
                                let prYear = parseInt(tempTcRecord.creditsEarnedYear);
                                let monthVal = 0;                                
                                monthVal = calculateMonthValHelper(tempTcRecord.creditsEarnedMonth);
                                let dateOne = new Date(yr, mon, "01");
                                let dateTwo = new Date(prYear, monthVal, "01");                                
                                if (dateOne >= dateTwo) {
                                    checkMonthYear = false;
                                } else {
                                    checkMonthYear = true;
                                }
                                tcCourseChecker = checkMonthYear;
                                if (checkMonthYear) {
                                    elem.querySelector('.creditEarnedMonthInput').classList.add('slds-has-error');
                                    elem.querySelector('.creditEarnedYearInput').classList.add('slds-has-error');
                                    errorCouTCGreater.push(tcDate + 1);
                                } else {
                                    tempSchoolRecord.tcWrapperList.push(tempTcRecord);
                                }                                
                            }
                        } else {                            
                            if (tempTcRecord.transferCreditCourse === '' || tempTcRecord.transferCreditCourse === null) {
                                elem.querySelector('.transferCreditCourseInput').classList.add('slds-has-error');
                                errorCouTit.push(tcCourse + 1);
                            }
                            if (tempTcRecord.transferCreditGrade === '' || tempTcRecord.transferCreditGrade === null) {
                                elem.querySelector('.transferCreditGradeInput').classList.add('slds-has-error');
                                errorCouNum.push(tcGrade + 1);
                            }
                            if (tempTcRecord.courseOutcome === '' || tempTcRecord.courseOutcome === null) {
                                elem.querySelector('.transferCreditCourseOutcomeInput').classList.add('slds-has-error');
                                errorCouOut.push(tcOutcome + 1);
                            }
                            if (tempTcRecord.creditsEarnedMonth === '' || tempTcRecord.creditsEarnedMonth === null) {
                                elem.querySelector('.creditEarnedMonthInput').classList.add('slds-has-error');
                                errorCouMon.push(tcMon + 1);
                            }
                            if (tempTcRecord.creditsEarnedYear === '' || tempTcRecord.creditsEarnedYear === null) {
                                elem.querySelector('.creditEarnedYearInput').classList.add('slds-has-error');
                                errorCouYr.push(tcYear + 1);
                            }
                        }
                        tcCourseNameReq.push({
                            indexcounter: tcIndexCounter,
                            tcCourseChecker: tcCourseChecker
                        });
                        tcIndexCounter++;
                    });
                    if (errorCouTit.length > 0 || errorCouNum.length > 0 || errorCouOut.length > 0 || errorCouMon.length > 0 || errorCouYr.length > 0 || errorCouTCGreater.length > 0) {
                        errorCounterCourseDetails.push(courseCounter + 1);
                        if (errorCouTit.length > 0) {
                            tcCourseTitVal = true;
                        }
                        if (errorCouNum.length > 0) {
                            tcCourseNumVal = true;
                        }
                        if (errorCouOut.length > 0) {
                            tcCourseOutVal = true;
                        }
                        if (errorCouMon.length > 0) {
                            tcCourseMonVal = true;
                        }
                        if (errorCouYr.length > 0) {
                            tcCourseYrVal = true;
                        }
                    }                    
                }
                tempSchoolRecord.assets = [];
                fileReqKey = tempSchoolRecord.recordIdVal;
                if (element.querySelector(".tctFileDetails") !== null) {
                    tctFileReqVal = false;
                    if (element.querySelector(".tctFileDetails").getAttribute('data-asset-id') === '') {
                        errorCounterMainFiles.push(counter + 1);
                        tctFileReqVal = true;
                    }
                }
                if (element.querySelector(".pmlFileDetails") !== null) {
                    pmlFileReqVal = false;
                    if (element.querySelector(".pmlFileDetails").getAttribute('data-asset-id') === '') {
                        errorCounterMainFiles.push(counter + 1);
                        pmlFileReqVal = true;
                    }
                }
                if (element.querySelector(".fmdFileDetails") !== null) {
                    fmdFileReqVal = false;
                    if (element.querySelector(".fmdFileDetails").getAttribute('data-asset-id') === '') {
                        errorCounterMainFiles.push(counter + 1);
                        fmdFileReqVal = true;
                    }
                }
                if (element.querySelector(".dlFileDetails") !== null) {
                    dlFileReqVal = false;
                    if (element.querySelector(".dlFileDetails").getAttribute('data-asset-id') === '') {
                        errorCounterMainFiles.push(counter + 1);
                        dlFileReqVal = true;
                    }
                }
                if (element.querySelector(".tctFileId") !== null) {
                    let tempTctAssetRecord = {
                        recordIdVal: element.querySelector(".tctFileId").getAttribute('data-asset-id'),
                        docNotInEnglish: element.querySelector(".isTranscriptInEnglishCheckbox").checked,
                        nameOnDoc: element.querySelector(".tctName").value,
                        nameOnDocIsDifferent: element.querySelector(".tctNameDifferentCheckbox").checked,
                        type: tctType,
                        deanDate: '',
                        parentAssetId: ''
                    }
                    if (tempTctAssetRecord.recordIdVal !== '' && tempTctAssetRecord.recordIdVal !== null) {
                        if (tempTctAssetRecord.nameOnDoc !== '' && tempTctAssetRecord.nameOnDoc !== null) {
                            tempSchoolRecord.assets.push(tempTctAssetRecord);
                            tctNameReqVal = false;
                        } else {
                            errorCounter.push(errCount + 1);
                            element.querySelector('.tctName').classList.add('slds-has-error');
                            tctNameReqVal = true;
                        }
                        tctTransFileReqVal = false;
                        if (tempTctAssetRecord.docNotInEnglish === true && element.querySelector(".tctFileId").getAttribute('data-asset-tran-id') === '') {
                            errorCounterTran.push(errTrCount + 1);
                            tctTransFileReqVal = true;
                        }
                    }
                }
                if (element.querySelector(".tctNameDocumenatationSectionUploadId") !== null) {
                    let tempTctNameRecord = {
                        recordIdVal: element.querySelector(".tctNameDocumenatationSectionUploadId").getAttribute('data-asset-id'),
                        docNotInEnglish: '',
                        nameOnDoc: '',
                        nameOnDocIsDifferent: '',
                        type: diplomaDocumentNameDocumentType,
                        deanDate: '',
                        parentAssetId: element.querySelector(".tctNameDocumenatationSectionUploadId").getAttribute('data-parentasset-id')
                    }
                    if (tempTctNameRecord.recordIdVal !== '' && tempTctNameRecord.recordIdVal !== null) {
                        tempSchoolRecord.assets.push(tempTctNameRecord);
                    }
                }
                if (element.querySelector(".tctTranslationClassId") !== null) {
                    let tempTctTranslationAssetRecord = {
                        recordIdVal: element.querySelector(".tctTranslationClassId").getAttribute('data-asset-id'),
                        docNotInEnglish: '',
                        nameOnDoc: '',
                        nameOnDocIsDifferent: '',
                        type: diplomaDocumentTranslationType,
                        deanDate: '',
                        parentAssetId: element.querySelector(".tctTranslationClassId").getAttribute('data-parentasset-id')
                    }
                    if (tempTctTranslationAssetRecord.recordIdVal !== '' && tempTctTranslationAssetRecord.recordIdVal !== null) {
                        tempSchoolRecord.assets.push(tempTctTranslationAssetRecord);
                    }
                }
                if (element.querySelector(".pmlFileId") !== null) {
                    let tempPmlAssetRecord = {
                        recordIdVal: element.querySelector(".pmlFileId").getAttribute('data-asset-id'),
                        docNotInEnglish: element.querySelector(".isPreMedLetterInEnglishCheckbox").checked,
                        nameOnDoc: element.querySelector(".pmlName").value,
                        nameOnDocIsDifferent: element.querySelector(".pmlNameDifferentCheckbox").checked,
                        type: premedType,
                        deanDate: '',
                        parentAssetId: ''
                    }
                    if (tempPmlAssetRecord.recordIdVal !== '' && tempPmlAssetRecord.recordIdVal !== null) {
                        if (tempPmlAssetRecord.nameOnDoc !== '' && tempPmlAssetRecord.nameOnDoc !== null) {
                            tempSchoolRecord.assets.push(tempPmlAssetRecord);
                            pmlNameReqVal = false;
                        } else {
                            errorCounter.push(errCount + 1);
                            element.querySelector('.pmlName').classList.add('slds-has-error');
                            pmlNameReqVal = true;
                        }
                        pmlTransFileReqVal = false;
                        if (tempPmlAssetRecord.docNotInEnglish == true && element.querySelector(".pmlFileId").getAttribute('data-asset-tran-id') == '') {
                            errorCounterTran.push(errTrCount + 1);
                            pmlTransFileReqVal = true;
                        }
                    }
                }
                if (element.querySelector(".pmlNameDocumentUploadId") !== null) {
                    let tempPmlNameRecord = {
                        recordIdVal: element.querySelector(".pmlNameDocumentUploadId").getAttribute('data-asset-id'),
                        docNotInEnglish: '',
                        nameOnDoc: '',
                        nameOnDocIsDifferent: '',
                        type: diplomaDocumentNameDocumentType,
                        deanDate: '',
                        parentAssetId: element.querySelector(".pmlNameDocumentUploadId").getAttribute('data-parentasset-id')
                    }
                    if (tempPmlNameRecord.recordIdVal !== '' && tempPmlNameRecord.recordIdVal !== null) {
                        tempSchoolRecord.assets.push(tempPmlNameRecord);
                    }
                }
                if (element.querySelector(".pmlTranslationNameId") !== null) {
                    let tempPmlTranslationAssetRecord = {
                        recordIdVal: element.querySelector(".pmlTranslationNameId").getAttribute('data-asset-id'),
                        docNotInEnglish: '',
                        nameOnDoc: '',
                        nameOnDocIsDifferent: '',
                        type: diplomaDocumentTranslationType,
                        deanDate: '',
                        parentAssetId: element.querySelector(".pmlTranslationNameId").getAttribute('data-parentasset-id')
                    }
                    if (tempPmlTranslationAssetRecord.recordIdVal !== '' && tempPmlTranslationAssetRecord.recordIdVal !== null) {
                        tempSchoolRecord.assets.push(tempPmlTranslationAssetRecord);
                    }
                }
                if (element.querySelector(".fmdFileId") !== null) {
                    let tempfmdAssetRecord = {
                        recordIdVal: element.querySelector(".fmdFileId").getAttribute('data-asset-id'),
                        docNotInEnglish: element.querySelector(".isfmdInEnglishCheckbox").checked,
                        nameOnDoc: element.querySelector(".fmdName").value,
                        nameOnDocIsDifferent: element.querySelector(".fmdNameDifferentCheckbox").checked,
                        type: diplomaDocumentFinalMedicalType,
                        deanDate: '',
                        parentAssetId: ''
                    }
                    if (tempfmdAssetRecord.recordIdVal !== '' && tempfmdAssetRecord.recordIdVal !== null) {
                        if (tempfmdAssetRecord.nameOnDoc !== '' && tempfmdAssetRecord.nameOnDoc !== null) {
                            tempSchoolRecord.assets.push(tempfmdAssetRecord);
                            fmdNameReqVal = false;
                        } else {
                            errorCounter.push(errCount + 1);
                            element.querySelector('.fmdName').classList.add('slds-has-error');
                            fmdNameReqVal = true;
                        }
                        fmdTransFileReqVal = false;
                        if (tempfmdAssetRecord.docNotInEnglish === true && element.querySelector(".fmdFileId").getAttribute('data-asset-tran-id') === '') {
                            errorCounterTran.push(errTrCount + 1);
                            fmdTransFileReqVal = true;
                        }
                    }
                }
                if (element.querySelector(".fmdNameDocumenatationSectionUploadId") !== null) {
                    let tempfmdNameRecord = {
                        recordIdVal: element.querySelector(".fmdNameDocumenatationSectionUploadId").getAttribute('data-asset-id'),
                        docNotInEnglish: '',
                        nameOnDoc: '',
                        nameOnDocIsDifferent: '',
                        type: diplomaDocumentNameDocumentType,
                        deanDate: '',
                        parentAssetId: element.querySelector(".fmdNameDocumenatationSectionUploadId").getAttribute('data-parentasset-id')
                    }
                    if (tempfmdNameRecord.recordIdVal !== '' && tempfmdNameRecord.recordIdVal !== null) {
                        tempSchoolRecord.assets.push(tempfmdNameRecord);
                    }
                }
                if (element.querySelector(".fmdTranslationClassId") !== null) {
                    let tempfmdTranslationAssetRecord = {
                        recordIdVal: element.querySelector(".fmdTranslationClassId").getAttribute('data-asset-id'),
                        docNotInEnglish: '',
                        nameOnDoc: '',
                        nameOnDocIsDifferent: '',
                        type: diplomaDocumentTranslationType,
                        deanDate: '',
                        parentAssetId: element.querySelector(".fmdTranslationClassId").getAttribute('data-parentasset-id')
                    }
                    if (tempfmdTranslationAssetRecord.recordIdVal !== '' && tempfmdTranslationAssetRecord.recordIdVal !== null) {
                        tempSchoolRecord.assets.push(tempfmdTranslationAssetRecord);
                    }
                }
                if (element.querySelector(".ftFileId") !== null) {
                    let tempftAssetRecord = {
                        recordIdVal: element.querySelector(".ftFileId").getAttribute('data-asset-id'),
                        docNotInEnglish: element.querySelector(".isftInEnglishCheckbox").checked,
                        nameOnDoc: element.querySelector(".ftName").value,
                        nameOnDocIsDifferent: element.querySelector(".ftNameDifferentCheckbox").checked,
                        type: transcriptFinalMedicalType,
                        deanDate: '',
                        parentAssetId: ''
                    }
                    if (tempftAssetRecord.recordIdVal !== '' && tempftAssetRecord.recordIdVal !== null) {
                        if (tempftAssetRecord.nameOnDoc !== '' && tempftAssetRecord.nameOnDoc !== null) {
                            tempSchoolRecord.assets.push(tempftAssetRecord);
                            ftNameReqVal = false;
                        } else {
                            errorCounter.push(errCount + 1);
                            element.querySelector('.ftName').classList.add('slds-has-error');
                            ftNameReqVal = true;
                        }
                        ftTransFileReqVal = false;
                        if (tempftAssetRecord.docNotInEnglish === true && element.querySelector(".ftFileId").getAttribute('data-asset-tran-id') === '') {
                            errorCounterTran.push(errTrCount + 1);
                            ftTransFileReqVal = true;
                        }
                    }
                }
                if (element.querySelector(".ftNameDocumenatationSectionUploadId") !== null) {
                    let tempftNameRecord = {
                        recordIdVal: element.querySelector(".ftNameDocumenatationSectionUploadId").getAttribute('data-asset-id'),
                        docNotInEnglish: '',
                        nameOnDoc: '',
                        nameOnDocIsDifferent: '',
                        type: diplomaDocumentNameDocumentType,
                        deanDate: '',
                        parentAssetId: element.querySelector(".ftNameDocumenatationSectionUploadId").getAttribute('data-parentasset-id')
                    }
                    if (tempftNameRecord.recordIdVal !== '' && tempftNameRecord.recordIdVal !== null) {
                        tempSchoolRecord.assets.push(tempftNameRecord);
                    }
                }
                if (element.querySelector(".ftTranslationClassId") !== null) {
                    let tempftTranslationAssetRecord = {
                        recordIdVal: element.querySelector(".ftTranslationClassId").getAttribute('data-asset-id'),
                        docNotInEnglish: '',
                        nameOnDoc: '',
                        nameOnDocIsDifferent: '',
                        type: diplomaDocumentTranslationType,
                        deanDate: '',
                        parentAssetId: element.querySelector(".ftTranslationClassId").getAttribute('data-parentasset-id')
                    }
                    if (tempftTranslationAssetRecord.recordIdVal !== '' && tempftTranslationAssetRecord.recordIdVal !== null) {
                        tempSchoolRecord.assets.push(tempftTranslationAssetRecord);
                    }
                }
                if (element.querySelector(".dlFileId") !== null) {
                    let tempdlAssetRecord = {
                        recordIdVal: element.querySelector(".dlFileId").getAttribute('data-asset-id'),
                        docNotInEnglish: element.querySelector(".isdlInEnglishCheckbox").checked,
                        nameOnDoc: element.querySelector(".dlName").value,
                        nameOnDocIsDifferent: element.querySelector(".dlNameDifferentCheckbox").checked,
                        type: deanLetterType,
                        deanDate: element.querySelector(".dlDate").value,
                        parentAssetId: ''
                    }
                    if (tempdlAssetRecord.recordIdVal !== '' && tempdlAssetRecord.recordIdVal !== null) {
                        if (tempdlAssetRecord.nameOnDoc !== '' && tempdlAssetRecord.nameOnDoc !== null) {
                            dlNameReqVal = false;
                            if (tempdlAssetRecord.deanDate !== '' && tempdlAssetRecord.deanDate !== null) {
                                tempSchoolRecord.assets.push(tempdlAssetRecord);
                                dlDateReqVal = false;
                            } else {
                                errorCounterDeanDate.push(errDlCount + 1);
                                element.querySelector('.dlDate').classList.add('slds-has-error');
                                dlDateReqVal = true;
                            }
                        } else {
                            errorCounter.push(errCount + 1);
                            element.querySelector('.dlName').classList.add('slds-has-error');
                            dlNameReqVal = true;
                        }
                        dlTransFileReqVal = false;
                        if (tempdlAssetRecord.docNotInEnglish === true && element.querySelector(".dlFileId").getAttribute('data-asset-tran-id') === '') {
                            errorCounterTran.push(errTrCount + 1);
                            dlTransFileReqVal = true;
                        }
                    }
                }
                if (element.querySelector(".dlNameDocumenatationSectionUploadId") !== null) {
                    let tempdlNameRecord = {
                        recordIdVal: element.querySelector(".dlNameDocumenatationSectionUploadId").getAttribute('data-asset-id'),
                        docNotInEnglish: '',
                        nameOnDoc: '',
                        nameOnDocIsDifferent: '',
                        type: diplomaDocumentNameDocumentType,
                        deanDate: '',
                        parentAssetId: element.querySelector(".dlNameDocumenatationSectionUploadId").getAttribute('data-parentasset-id')
                    }
                    if (tempdlNameRecord.recordIdVal !== '' && tempdlNameRecord.recordIdVal !== null) {
                        tempSchoolRecord.assets.push(tempdlNameRecord);
                    }
                }
                if (element.querySelector(".dlTranslationClassId") !== null) {
                    let tempdlTranslationAssetRecord = {
                        recordIdVal: element.querySelector(".dlTranslationClassId").getAttribute('data-asset-id'),
                        docNotInEnglish: '',
                        nameOnDoc: '',
                        nameOnDocIsDifferent: '',
                        type: diplomaDocumentTranslationType,
                        deanDate: '',
                        parentAssetId: element.querySelector(".dlTranslationClassId").getAttribute('data-parentasset-id')
                    }
                    if (tempdlTranslationAssetRecord.recordIdVal !== '' && tempdlTranslationAssetRecord.recordIdVal !== null) {
                        tempSchoolRecord.assets.push(tempdlTranslationAssetRecord);
                    }
                }                
                recordValuesToSave.push(tempSchoolRecord);
                fileNameReq.push({
                    keyd: fileReqKey,
                    tctNameReqVal: tctNameReqVal,
                    pmlNameReqVal: pmlNameReqVal,
                    fmdNameReqVal: fmdNameReqVal,
                    ftNameReqVal: ftNameReqVal,
                    dlNameReqVal: dlNameReqVal,
                    tctFileReqVal: tctFileReqVal,
                    tctTransFileReqVal: tctTransFileReqVal,
                    pmlFileReqVal: pmlFileReqVal,
                    pmlTransFileReqVal: pmlTransFileReqVal,
                    fmdFileReqVal: fmdFileReqVal,
                    fmdTransFileReqVal: fmdTransFileReqVal,
                    ftTransFileReqVal: ftTransFileReqVal,
                    dlFileReqVal: dlFileReqVal,
                    dlTransFileReqVal: dlTransFileReqVal,
                    dlDateReqVal: dlDateReqVal,
                    tctNameDocFileReqVal: tctNameDocFileReqVal,
                    tctTransDocFileReqVal: tctTransDocFileReqVal,
                    tcCourseTitVal: tcCourseTitVal,
                    tcCourseNumVal: tcCourseNumVal,
                    tcCourseOutVal: tcCourseOutVal,
                    tcCourseMonVal: tcCourseMonVal,
                    tcCourseYrVal: tcCourseYrVal,
                    tcCourseNameReq: tcCourseNameReq
                });
            }
        });
        this.fileNameReqMap = fileNameReq;        
        updateSave(this.getOtherInstitutionData,this.fileNameReqMap);
        if (errorCounter.length > 0 || errorCounterDeanDate.length > 0 || errorCounterTran.length > 0 || errorCounterMainFiles.length > 0 || errorCounterCourseDetails.length > 0) {
            this.formSubmit = false;
            if (errorCounter.length > 0) {
                this.isErrMsgName = true;
            }
            if (errorCounterDeanDate.length > 0) {
                this.isErrMsgDeanDate = true;
            }
            if (errorCounterTran.length > 0) {
                this.isErrMsgTran = true;
            }
            if (errorCounterMainFiles.length > 0) {
                this.isErrMsgMainFiles = true;
            }
        }
        if (this.formSubmit) {
            this.caseValues = JSON.stringify(recordValuesToSave);  
            this.isnotLegalPage = false;
            this.isLegalPage = false;
        }
        window.scrollTo(0, 0);
    }
    cancelButton(event) {
        event.preventDefault();
    }
    prevbtn(event) {
        event.preventDefault();
        this.isnotLegalPage = true;
        this.isLegalPage = true;
    }
    addRow(event) {
        let idx = event.currentTarget.dataset.stagingId;
        for (const key in this.getOtherInstitutionData) {
            if (this.getOtherInstitutionData.hasOwnProperty(key)) {
                let ele = this.getOtherInstitutionData[key];
                if (ele.Id === idx) {
                    let tempTcRecord = {
                        "Contact_Association_Type_Staging__c": idx,
                        "Id": "",
                        "From_School__c": "",
                        "From_School_Name__c": "",
                        "Transfer_Credit_Course__c": "",
                        "Transfer_Credit_Grade__c": "",
                        "Course_Outcome__c": "",
                        "Credits_Earned_Month__c": "",
                        "Credits_Earned_Year__c": ""
                    }
                    this.getOtherInstitutionData[key].Transfer_Credits__r.push(tempTcRecord);
                }
            }
        }
        showDelbtn(this.getOtherInstitutionData);
    }
    removeRow(event) {
        let idx = event.currentTarget.dataset.stagingId;
        let ind = event.currentTarget.dataset.tcindex;
        for (const key in this.getOtherInstitutionData) {
            if (this.getOtherInstitutionData.hasOwnProperty(key)) {
                let ele = this.getOtherInstitutionData[key];
                if (ele.Id === idx) {
                    this.getOtherInstitutionData[key].Transfer_Credits__r.splice(ind, 1);
                }
            }
        }
        showDelbtn(this.getOtherInstitutionData);
    }
    navigateToWebPage() {
        navHel(this.caseId);
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/s/my-cases'
            }
        });
    }
    handleChange(event) {
        this.btnNotDisabled = false;
        if (event.target.checked) {
            this.checkedcount = this.checkedcount + 1;
        } else {
            this.checkedcount = this.checkedcount - 1;
        }
        if (this.recordsList.length === this.checkedcount) {
            this.btnNotDisabled = true;
        }
    }
    @wire(getTermsandConditionsData) objectValues({
        error,
        data
    }) {
        if (data) {
            for (let key in data) {
                if (data.hasOwnProperty(key)) {
                    let tempRecord = {
                        termsId: data[key].termsId,
                        termsContent: data[key].termsContent,
                        termsCheckboxCont: data[key].termsCheckboxContent
                    };
                    if (this.recordsList.length > 0) {
                        this.recordsList = [...this.recordsList, tempRecord];
                    } else {
                        this.recordsList = [tempRecord];
                    }
                }
            }
        } else if (error) {
            this.recordsList = [{
                termsId: '',
                termsContent: '',
                termsCheckboxCont: ''
            }];
        }
    }
    handleClick() {
        this.showErrorLeg = false;
        this.spinner = true;
        this.errorMessagesText = '';
        if (this.recordsList.length === this.checkedcount) {
            if (this.showDegreeSchool) {
                manageAppforCertCases({
                        fieldvals: this.degreeSchoolValue,
                        defscreen: true
                    })
                    .then(saveresultDeg => {
                        this.spinnerDeg = false;
                        if (saveresultDeg) {
                            if (this.showAllTCT) {
                                saveIncompleteRecords({
                                        values: this.caseValues,
                                        caseId: this.caseId
                                    }).then(result => {
                                        if (result) {
                                            createTermsRecord({
                                                    examRegVar: this.appForCertVar
                                                })
                                                .then(saveresult => {
                                                    this.showConfirmation = true;
                                                })
                                                .catch(error => {
                                                    console.error('Error', JSON.stringify(error));
                                                    this.spinner = false;
                                                });
                                        }
                                    })
                                    .catch(error1 => {
                                        console.error('Deficiency error variable', JSON.stringify(error1));
                                        this.spinner = false;
                                    })
                            } else {
                                createTermsRecord({
                                        examRegVar: this.appForCertVar
                                    })
                                    .then(saveresultCreate => {
                                        this.showConfirmation = true;
                                    })
                                    .catch(errorCreate => {
                                        console.error('Error', JSON.stringify(errorCreate));
                                        this.spinner = false;
                                    });
                            }
                        }
                    })
                    .catch(errordeg => {
                        this.spinnerDeg = false;
                        console.error('Error: ' + JSON.stringify(errordeg));
                    });
            } else {
                saveIncompleteRecords({
                        values: this.caseValues,
                        caseId: this.caseId
                    }).then(result => {
                        if (result) {
                            createTermsRecord({
                                    examRegVar: this.appForCertVar
                                })
                                .then(saveresult => {
                                    this.showConfirmation = true;
                                })
                                .catch(error => {
                                    console.error('Error', JSON.stringify(error));
                                    this.spinner = false;
                                });
                        }
                    })
                    .catch(error1 => {
                        console.error('Deficiency error variable', JSON.stringify(error1));
                        this.spinner = false;
                    })
            }
        } else {
            this.showErrorLeg = true;
            this.spinner = false;
            this.errorMessagesText = termsError;
        }
    }
    cancelAppForCert() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/s/services'
            }
        });
    }
    cancelButtonToOpen() {
        this.template.querySelector('[data-id="newModalAlert"]').show();
    }
    closeModal() {
        this.template.querySelector('[data-id="newModalAlert"]').hide();
    }
}