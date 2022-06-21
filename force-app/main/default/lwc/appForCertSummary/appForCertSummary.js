import {LightningElement, track, wire, api} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
//import required custom labels
import identityInformationMessage from '@salesforce/label/c.App_for_Cert_Identity_Information';
import contactInformationMessage from '@salesforce/label/c.App_for_Cert_Contact_Information';
import headerMessage from '@salesforce/label/c.App_For_Cert_Reporter_Screen';
//import required apex methods
import getOtherMedicalSchoolRecords from '@salesforce/apex/AppForCertController.getOtherMedicalSchoolsWithTransferCredits';
import getOtherInstitutionRecords from '@salesforce/apex/AppForCertController.getOtherInstitutionsWithTransferCredits';
import isApplicantGraduate from '@salesforce/apex/AppForCertController.isApplicantGraduate';
import getAssetsAndDocuments from '@salesforce/apex/AppForCertController.getAssetsAndDocuments';
import getInstAssetsAndDocuments from '@salesforce/apex/AppForCertController.getInstAssetsAndDocuments';
import getGraduateOnlyRecords from '@salesforce/apex/AppForCertController.getGraduateOnlyRecords';
import getDlDate from '@salesforce/apex/AppForCertController.getDlDate';
import getMedSchoolExamReg from '@salesforce/apex/AppForCertController.getContactAssociationStagingExamReg';
import getReporterQuestionValue from '@salesforce/apex/AppForCertController.getReporterQuestionValue';
import getOtherMedicalSchoolRecordsExamReg from "@salesforce/apex/ExamRegistrationController.getOtherMedicalSchoolsWithTransferCredits";
import getOtherInstitutionRecordsExamReg from "@salesforce/apex/ExamRegistrationController.getOtherInstitutionsWithTransferCredits";
import getAssetsAndDocumentsExamReg from "@salesforce/apex/ExamRegistrationController.getAssetsAndDocuments";
import getInstAssetsAndDocumentsExamReg from "@salesforce/apex/ExamRegistrationController.getInstAssetsAndDocuments";
import getStartDateAndEndDate from '@salesforce/apex/AppForCertController.getStartDateAndEndDate';
import getContactDetails from '@salesforce/apex/AppForCertController.getContactDetails';
import getMedSchoolCaseDetail from '@salesforce/apex/AppForCertController.getContactAssociationForCaseDetail';
//code added by Shailaja
import getStartEndAndDegreeMonthYear from '@salesforce/apex/AppForCertController.getStartEndAndDegreeMonthYear';
import checkGradValOnSummary from '@salesforce/apex/AppForCertController.checkGradValOnSummary';
import checkStudValOnSummary from '@salesforce/apex/AppForCertController.checkStudValOnSummary';
import {getRecord} from 'lightning/uiRecordApi';
const TYPE = ['Contact_Association_Type__c', 'Contact_Association_Type_Staging__c'];
export default class AppForCertSummary extends NavigationMixin(LightningElement) {
    //api variables
    @api getIdFromParent;
    @api objectType;
    @api objectId;
    @api showExamRegActionButton;
    @api showCaseDetail;
    //track variables
    @track multiple = true;
    @track parameters = {};
    @track degMedSchooData = new Object();
    @track contactData = new Object();
    @track getOtherMedSchoolData = [];
    @track otherMedicalSchoolRecId;
    @track getOtherInstitutionData = [];
    @track isGraduate;
    @track isOthIns = false;
    @track isOthMed = false;
    @track assetsList = [];
    @track dlDate;
    @track instAssetsList = [];
    @track gradAssetsList = [];
    @track tctNameCond = false;
    @track tctTransCond = false;
    @track fmdNameCond = false;
    @track fmdTransCond = false;
    @track dlNameCond = false;
    @track dlTransCond = false;
    @track ftNameCond = false;
    @track ftTransCond = false;
    @track deanLetterCond = false;
    @track ftReqdCond = false;
    @track isDeanLet = false;
    @track medSchoolId;
    @track medSchoolObject;
    @track reporterQstn;
    @track showFtFile = false;
    @track showdlFile = false;
    @track showfmdFile = false;
    @track showOtMedFile = false;
    @track showtctFile = false;
    @track showpmlFile = false;
    @track showMultiple = true;
    @track showContactBtn = true;
    @track activeSections = ['contactSection'];
    @track spinner = false;
    @track formMargin = '';
    @track showMedDetails = false;
    @track birthDate = new Date();
    @track degreeIssueDate = new Date();
    @track startDate = new Date();
    @track endDate = new Date();
    //Code added by Shailaja. Date format stories.
    @track startMonth = '';
    @track startYear = '';
    @track endMonth = '';
    @track endYear = '';
    @track degreeIssueMonth = '';
    @track degreeIssueYear = '';
    @track courierCheckbox;
    @track courierCheckboxFMST;
    @track isCourierService;
    @track isCourierServiceFMST;
    @api directlyToNext;
    @api showAlreadyDiplomaUploaded;
    @api showNewlyDeanUploaded;
    @track errorTrue = false;
    @track errorSecTrue = false;
    @track validationMessage = "You have not made any changes to your Application for Certification and will be unable to submit this request.  Return to a previous screen to make any necessary edits to your Application for Certification before proceeding.";
    @track validationMessageGrad = "You have not made any changes that will impact your Application for Certification.  Return to a previous screen to make any additional edits to your Application for Certification before proceeding, or contact ECFMG.";
    @api caseRecordId;
    showAssets = false;
    label = {
        identityInformationMessage,
        contactInformationMessage,
        headerMessage
    };
    @wire(getRecord, {
        recordId: '$getIdFromParent',
        fields: ['Contact.Birthdate']
    })
    getContact(result) {
        if (result.data !== undefined) {
            this.birthDate = result.data.fields.Birthdate.value;
            if (!this.showExamRegActionButton) {
                getStartDateAndEndDate({
                    objectId: this.objectId,
                    objectType: this.objectType
                }).then(value => {
                    this.startDate = value.Start_Date__c;
                    this.endDate = value.End_Date__c;
                    this.degreeIssueDate = value.Degree_Issue_Date__c;
                });
                //code added by Shailaja.
                getStartEndAndDegreeMonthYear({
                    objectId: this.objectId,
                    objectType: this.objectType
                }).then(value => {
                    this.startMonth = value.Start_Month__c;
                    this.startYear = value.Start_Year__c;
                    this.endMonth = value.End_Month__c;
                    this.endYear = value.End_Year__c;
                    this.degreeIssueMonth = value.Degree_Issue_Month__c;
                    this.degreeIssueYear = value.Degree_Issue_Year__c;
                });
            }
        }
    }
    getDletterDate() {
        getDlDate().then(data => {
            if (data) {
                this.dlDate = data;
            }
        });
    }
    connectedCallback(){
        let otherMedSchoolExamRegPromise;
        let otherInstExamRegPromise;
        let assetExamRegPromise;
        let medSchoolPromise;
        this.spinner = true;
        if (!this.showCaseDetail) {
            this.formMargin = 'formMargin';
            this.showCaseDetail = false;
        }
        if (this.showCaseDetail || this.showExamRegActionButton) {
            this.showContactBtn = false;
        }
        //check if applicant is graduate or not on load of page on FED
        let isGraduatePromise = isApplicantGraduate({
                showExamRegActionButton: this.showExamRegActionButton,
                showCaseDetail: this.showCaseDetail
            })
            .then(data => {
                this.isGraduate = data;
            })
        //Check if redirected from Exam Registration or not
        if (this.showExamRegActionButton) {
            //Get the medical school records from Contact Association Type on load of page
            otherMedSchoolExamRegPromise = getOtherMedicalSchoolRecordsExamReg()
                .then(data => {
                    if (data) {
                        if (data.length > 0) {
                            this.getOtherMedSchoolData = this.getOtherMedSchoolData.concat(data.map((item) => {
                                item.objectApiName = TYPE[0];
                                return item;
                            }));
                            this.isOthMed = true;
                        }
                        if (this.isOthMed) {
                            for (const key in this.getOtherMedSchoolData) {
                                if (this.getOtherMedSchoolData.hasOwnProperty(key)) {
                                    let ele = this.getOtherMedSchoolData[key];
                                    if (ele.Transfer_Credit_to_Degree_School__c) {
                                        this.otherMedicalSchoolRecId = ele.Id;
                                        //Get the Assets with files from Contact Association Type on load of page
                                        getAssetsAndDocumentsExamReg({
                                                recId: this.otherMedicalSchoolRecId
                                            })
                                            .then(result => {
                                                if (result.tctId) {
                                                    this.assetsList = result;
                                                    let tempPayload = {
                                                        contactId: null,
                                                        caseId: null,
                                                        catsId: null,
                                                        documentType: null,
                                                        assetRecordType: null,
                                                        createOrReplace: null,
                                                        assetStatus: null,
                                                        assetCreationRequired: null,
                                                        assetId: null
                                                    };
                                                    if (this.assetsList.tctNameDiff === 'Yes' && this.assetsList.tctNameDoc !== '' && this.assetsList.tctNameDoc !== undefined) {
                                                        this.tctNameCond = true;
                                                        tempPayload.assetId = this.assetsList.tctNameDocId;
                                                        tempPayload.documentType = "Name Document";
                                                        this.assetsList.nameDocPayload = JSON.stringify(tempPayload);
                                                    }
                                                    if (this.assetsList.tctTrans === 'Yes' && this.assetsList.tctTransFile !== '') {
                                                        this.tctTransCond = true;
                                                        tempPayload.assetId = this.assetsList.tctTransId;
                                                        tempPayload.documentType = "TCT Translation";
                                                        this.assetsList.tctTranslationPayload = JSON.stringify(tempPayload);
                                                    }
                                                    if (this.assetsList.tctFile !== '') {
                                                        this.showOtMedFile = true;
                                                        tempPayload.assetId = this.assetsList.tctId;
                                                        tempPayload.documentType = "Transfer Credit Transcript";
                                                        this.assetsList.tctPayload = JSON.stringify(tempPayload);
                                                    }
                                                }
                                            })
                                            .catch()
                                    }
                                }
                            }
                        }
                    }
                })
                .catch(error => {
                    this.spinner = false;
                    window.console.log('Error: ' + JSON.stringify(error));
                })
            //Get the other institution records on load of page on FED
            otherInstExamRegPromise = getOtherInstitutionRecordsExamReg()
                .then(data => {
                    if (data) {
                        if (data.length > 0) {
                            this.getOtherInstitutionData = this.getOtherInstitutionData.concat(data.map((item) => {
                                item.objectApiName = TYPE[0];
                                return item;
                            }));
                            this.isOthIns = true;
                        }
                    }
                })
                .catch(error => {
                    this.spinner = false;
                    window.console.log('Error: ' + JSON.stringify(error));
                })
            //Get the Institution Assets with files on load of page on FED
            assetExamRegPromise = getInstAssetsAndDocumentsExamReg()
                .then(data => {
                    if (data) {
                        this.instAssetsList = data;
                        for (const key in this.getOtherInstitutionData) {
                            if (this.getOtherInstitutionData.hasOwnProperty(key)) {
                                let ele = this.getOtherInstitutionData[key];
                                for (const assKey in this.instAssetsList) {
                                    if (this.instAssetsList.hasOwnProperty(assKey)) {
                                        if (ele.Id === assKey) {
                                            let assEle = this.instAssetsList[assKey];
                                            ele.tctId = assEle.tctId;
                                            ele.tctFile = assEle.tctFile;
                                            ele.tctName = assEle.tctName;
                                            ele.tctNameDiff = assEle.tctNameDiff;
                                            ele.tctNameDoc = assEle.tctNameDoc;
                                            ele.tctTransId = assEle.tctTransId;
                                            ele.tctTrans = assEle.tctTrans;
                                            ele.tctTransFile = assEle.tctTransFile;
                                            ele.pmlId = assEle.pmlId;
                                            ele.pmlFile = assEle.pmlFile;
                                            ele.pmlName = assEle.pmlName;
                                            ele.pmlNameDiff = assEle.pmlNameDiff;
                                            ele.pmlNameDoc = assEle.pmlNameDoc;
                                            ele.pmlTransId = assEle.pmlTransId;
                                            ele.pmlTrans = assEle.pmlTrans;
                                            ele.pmlTransFile = assEle.pmlTransFile;
                                            let tempPayload = {
                                                contactId: null,
                                                caseId: null,
                                                catsId: null,
                                                documentType: null,
                                                assetRecordType: null,
                                                createOrReplace: null,
                                                assetStatus: null,
                                                assetCreationRequired: null,
                                                assetId: null
                                            };
                                            if (assEle.tctNameDiff === 'Yes' && assEle.tctNameDoc !== '' && assEle.tctNameDoc !== undefined) {
                                                ele.tctNameCond = true;
                                                tempPayload.assetId = assEle.tctNameDocId;
                                                tempPayload.documentType = "Name Document";
                                                ele.nameDocPayload = JSON.stringify(tempPayload);
                                            }
                                            if (assEle.tctTrans === 'Yes' && assEle.tctTransFile !== '') {
                                                ele.tctTransCond = true;
                                                tempPayload.assetId = assEle.tctTransId;
                                                tempPayload.documentType = "TCT Translation";
                                                ele.tctTranslationPayload = JSON.stringify(tempPayload);
                                            }
                                            if (assEle.pmlNameDiff === 'Yes' && assEle.pmlNameDoc !== '' && assEle.pmlNameDoc !== undefined) {
                                                ele.pmlNameCond = true;
                                                tempPayload.assetId = assEle.pmlNameDocId;
                                                tempPayload.documentType = "Name Document";
                                                ele.pmlNameDocPayload = JSON.stringify(tempPayload);
                                            }
                                            if (assEle.pmlTrans === 'Yes' && assEle.pmlTransFile !== '') {
                                                ele.pmlTransCond = true;
                                                tempPayload.assetId = assEle.pmlTransId;
                                                tempPayload.documentType = "Pre-Med Letter Translation";
                                                ele.pmlTranslationPayload = JSON.stringify(tempPayload);
                                            }
                                            if (assEle.tctFile !== '') {
                                                ele.showtctFile = true;
                                                tempPayload.assetId = assEle.tctId;
                                                tempPayload.documentType = "Transfer Credit Transcript";
                                                ele.tctPayload = JSON.stringify(tempPayload);
                                            }
                                            if (assEle.pmlFile !== '') {
                                                ele.showpmlFile = true;
                                                tempPayload.assetId = assEle.pmlId;
                                                tempPayload.documentType = "Pre-Med Letter";
                                                ele.pmlPayload = JSON.stringify(tempPayload);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                })
                .catch(error => {
                    this.spinner = false;
                    window.console.log('Error: ' + JSON.stringify(error));
                })
        }
        //Get the degree medical school record
        if (this.showExamRegActionButton && this.showCaseDetail) {
            medSchoolPromise = getMedSchoolCaseDetail()
                .then(data => {
                    if (data) {
                        this.degMedSchooData = data;
                        this.medSchoolId = data.Id;
                        this.medSchoolObject = TYPE[0];
                        this.startDate = data.Start_Date__c;
                        this.endDate = data.End_Date__c;
                        this.degreeIssueDate = data.Degree_Issue_Date__c;
                        //code added by Shailaja. Date Format Stories.
                        this.startMonth = data.Start_Month__c;
                        this.startYear = data.Start_Year__c;
                        this.endMonth = data.End_Month__c;
                        this.endYear = data.End_Year__c;
                        this.degreeIssueMonth = data.Degree_Issue_Month__c;
                        this.degreeIssueYear = data.Degree_Issue_Year__c;
                        this.showMedDetails = true;
                    }
                })
                .catch(error => {
                    this.spinner = false;
                    window.console.log('Error: ' + JSON.stringify(error) + error);
                })
        } else {
            medSchoolPromise = getMedSchoolExamReg({
                    showExamRegActionButton: this.showExamRegActionButton,
                    showCaseDetail: this.showCaseDetail
                })
                .then(data => {
                    if (data) {
                        this.degMedSchooData = data;
                        this.medSchoolId = data.Id;
                        this.medSchoolObject = TYPE[1];
                        this.startDate = data.Start_Date__c;
                        this.endDate = data.End_Date__c;
                        this.degreeIssueDate = data.Degree_Issue_Date__c;
                        //code added by Shailaja. Date Format Stories.
                        this.startMonth = data.Start_Month__c;
                        this.startYear = data.Start_Year__c;
                        this.endMonth = data.End_Month__c;
                        this.endYear = data.End_Year__c;
                        this.degreeIssueMonth = data.Degree_Issue_Month__c;
                        this.degreeIssueYear = data.Degree_Issue_Year__c;
                        this.showMedDetails = true;
                    }
                })
                .catch(error => {
                    this.spinner = false;
                    window.console.log('Error: ' + JSON.stringify(error) + error);
                })
        }
        //Get the medical school records on load of page on FED
        let otherMedSchoolPromise = getOtherMedicalSchoolRecords({
                showExamRegActionButton: this.showExamRegActionButton,
                showCaseDetail: this.showCaseDetail,
                caseRecordId: this.caseRecordId
            })
            .then(data => {
                if (data) {
                    if (data.length > 0) {
                        this.getOtherMedSchoolData = this.getOtherMedSchoolData.concat(data.map((item) => {
                            item.objectApiName = TYPE[1];
                            return item;
                        }));
                        this.isOthMed = true;
                    }
                    if (this.isOthMed) {
                        for (const key in this.getOtherMedSchoolData) {
                            if (this.getOtherMedSchoolData.hasOwnProperty(key)) {
                                let ele = this.getOtherMedSchoolData[key];
                                if (ele.Transfer_Credit_to_Degree_School__c) {
                                    this.otherMedicalSchoolRecId = ele.Id;
                                    //Get the Assets with files on load of page on FED
                                    getAssetsAndDocuments({
                                            recId: this.otherMedicalSchoolRecId
                                        })
                                        .then(result => {
                                            if (result.tctId) {
                                                this.assetsList = result;
                                                let tempPayload = {
                                                    contactId: null,
                                                    caseId: null,
                                                    catsId: null,
                                                    documentType: null,
                                                    assetRecordType: null,
                                                    createOrReplace: null,
                                                    assetStatus: null,
                                                    assetCreationRequired: null,
                                                    assetId: null
                                                };
                                                if (this.assetsList.tctNameDiff === 'Yes' && this.assetsList.tctNameDoc !== '' && this.assetsList.tctNameDoc !== undefined) {
                                                    this.tctNameCond = true;
                                                    tempPayload.assetId = this.assetsList.tctNameDocId;
                                                    tempPayload.documentType = "Name Document";
                                                    this.assetsList.nameDocPayload = JSON.stringify(tempPayload);
                                                }
                                                if (this.assetsList.tctTrans === 'Yes' && this.assetsList.tctTransFile !== '') {
                                                    this.tctTransCond = true;
                                                    tempPayload.assetId = this.assetsList.tctTransId;
                                                    tempPayload.documentType = "TCT Translation";
                                                    this.assetsList.tctTranslationPayload = JSON.stringify(tempPayload);
                                                }
                                                if (this.assetsList.tctFile !== '') {
                                                    this.showOtMedFile = true;
                                                    tempPayload.assetId = this.assetsList.tctId;
                                                    tempPayload.documentType = "Transfer Credit Transcript";
                                                    this.assetsList.tctPayload = JSON.stringify(tempPayload);
                                                }
                                            }
                                        })
                                        .catch()
                                }
                            }
                        }
                    }
                }
            })
            .catch(error => {
                this.spinner = false;
                window.console.log('Error: ' + JSON.stringify(error));
            })
        let assetPromise;
        //Get the other institution records on load of page on FED
        let otherInstPromise = getOtherInstitutionRecords({
                showExamRegActionButton: this.showExamRegActionButton,
                showCaseDetail: this.showCaseDetail,
                caseRecordId: this.caseRecordId
            })
            .then(data => {
                if (data) {
                    if (data.length > 0) {
                        this.getOtherInstitutionData = this.getOtherInstitutionData.concat(data.map((item) => {
                            item.objectApiName = TYPE[1];
                            if(item.Account__r.RecordType.DeveloperName === 'Unapproved_New_Entity'){
                                item.newEntity = true;
                            }else{
                                item.newEntity = false;
                            }
                            return item;
                        }));
                        this.isOthIns = true;
                    }
                    if (this.isOthIns) {
                         //Get the Institution Assets with files on load of page on FED
                        assetPromise = getInstAssetsAndDocuments({
                            showExamRegActionButton: this.showExamRegActionButton,
                            showCaseDetail: this.showCaseDetail
                        })
                            .then(data1 => {
                            if (data1) {
                                this.instAssetsList = data1;
                                for (const key in this.getOtherInstitutionData) {
                                    if (this.getOtherInstitutionData.hasOwnProperty(key)) {
                                        let ele = this.getOtherInstitutionData[key];
                                        for (const assKey in this.instAssetsList) {
                                            if (this.instAssetsList.hasOwnProperty(assKey)) {
                                                if (ele.Id === assKey) {
                                                    let assEle = this.instAssetsList[assKey];
                                                    ele.tctId = assEle.tctId;
                                                    ele.tctFile = assEle.tctFile;
                                                    ele.tctName = assEle.tctName;
                                                    ele.tctNameDiff = assEle.tctNameDiff;
                                                    ele.tctNameDoc = assEle.tctNameDoc;
                                                    ele.tctTransId = assEle.tctTransId;
                                                    ele.tctTrans = assEle.tctTrans;
                                                    ele.tctTransFile = assEle.tctTransFile;
                                                    ele.pmlId = assEle.pmlId;
                                                    ele.pmlFile = assEle.pmlFile;
                                                    ele.pmlName = assEle.pmlName;
                                                    ele.pmlNameDiff = assEle.pmlNameDiff;
                                                    ele.pmlNameDoc = assEle.pmlNameDoc;
                                                    ele.pmlTransId = assEle.pmlTransId;
                                                    ele.pmlTrans = assEle.pmlTrans;
                                                    ele.pmlTransFile = assEle.pmlTransFile;
                                                    let tempPayload = {
                                                        contactId: null,
                                                        caseId: null,
                                                        catsId: null,
                                                        documentType: null,
                                                        assetRecordType: null,
                                                        createOrReplace: null,
                                                        assetStatus: null,
                                                        assetCreationRequired: null,
                                                        assetId: null
                                                    };
                                                    if (assEle.tctNameDiff === 'Yes' && assEle.tctNameDoc !== '' && assEle.tctNameDoc !== undefined) {
                                                        ele.tctNameCond = true;
                                                        tempPayload.assetId = assEle.tctNameDocId;
                                                        tempPayload.documentType = "Name Document";
                                                        ele.nameDocPayload = JSON.stringify(tempPayload);
                                                    }
                                                    if (assEle.tctTrans === 'Yes' && assEle.tctTransFile !== '') {
                                                        ele.tctTransCond = true;
                                                        tempPayload.assetId = assEle.tctTransId;
                                                        tempPayload.documentType = "TCT Translation";
                                                        ele.tctTranslationPayload = JSON.stringify(tempPayload);
                                                    }
                                                    if (assEle.pmlNameDiff === 'Yes' && assEle.pmlNameDoc !== '' && assEle.pmlNameDoc !== undefined) {
                                                        ele.pmlNameCond = true;
                                                        tempPayload.assetId = assEle.pmlNameDocId;
                                                        tempPayload.documentType = "Name Document";
                                                        ele.pmlNameDocPayload = JSON.stringify(tempPayload);
                                                    }
                                                    if (assEle.pmlTrans === 'Yes' && assEle.pmlTransFile !== '') {
                                                        ele.pmlTransCond = true;
                                                        tempPayload.assetId = assEle.pmlTransId;
                                                        tempPayload.documentType = "Pre-Med Letter Translation";
                                                        ele.pmlTranslationPayload = JSON.stringify(tempPayload);
                                                    }
                                                    if (assEle.tctFile !== '') {
                                                        ele.showtctFile = true;
                                                        tempPayload.assetId = assEle.tctId;
                                                        tempPayload.documentType = "Transfer Credit Transcript";
                                                        ele.tctPayload = JSON.stringify(tempPayload);
                                                    }
                                                    if (assEle.pmlFile !== '') {
                                                        ele.showpmlFile = true;
                                                        tempPayload.assetId = assEle.pmlId;
                                                        tempPayload.documentType = "Pre-Med Letter";
                                                        ele.pmlPayload = JSON.stringify(tempPayload);
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        })
                        .catch(error => {
                            this.spinner = false;
                            window.console.log('Error: ' + JSON.stringify(error));
                        })
                    }
                }
            })
            .catch(error => {
                this.spinner = false;
                window.console.log('Error: ' + JSON.stringify(error));
            })
        //Get the graduate only screen records on load of page on FED
        if (this.showAlreadyDiplomaUploaded === '' || this.showAlreadyDiplomaUploaded === null || this.showAlreadyDiplomaUploaded === undefined) {
            this.showAlreadyDiplomaUploaded = false;
        }
        if (this.showNewlyDeanUploaded === '' || this.showNewlyDeanUploaded === null || this.showNewlyDeanUploaded === undefined) {
            this.showNewlyDeanUploaded = false;
        }
        if (this.directlyToNext === '' || this.directlyToNext === null || this.directlyToNext === undefined || this.showAlreadyDiplomaUploaded || this.showNewlyDeanUploaded) {
            this.directlyToNext = false; //false will fetch the record from newly created CAT record
        }
        if (typeof this.directlyToNext === 'object') {
            this.directlyToNext = false;
        }
        let graduateRecordPromise = getGraduateOnlyRecords({
                showExamRegActionButton: this.showExamRegActionButton,
                showCaseDetail: this.showCaseDetail,
                resubmitAppForCert: this.directlyToNext
            })
            .then(data => {
                if (data) {
                    //user story#15591
                    this.isCourierService = data.isCourierService;
                    if(this.isCourierService == 'Yes'){
                        this.courierCheckbox = true;
                    }else if(this.isCourierService == 'No'){
                        this.courierCheckbox = false;
                    }
                    this.isCourierServiceFMST = data.isCourierServiceFMST;
                    if(this.isCourierServiceFMST == 'Yes'){
                        this.courierCheckboxFMST = true;
                    }else if(this.isCourierServiceFMST == 'No'){
                        this.courierCheckboxFMST = false;
                    }
                    this.gradAssetsList = data;                    
                    this.isDeanLet = false;
                    let tempPayload = {
                        contactId: null,
                        caseId: null,
                        catsId: null,
                        documentType: null,
                        assetRecordType: null,
                        createOrReplace: null,
                        assetStatus: null,
                        assetCreationRequired: null,
                        assetId: null
                    };
                    if (this.gradAssetsList.dlDate !== '') {
                        this.getDletterDate();
                    }
                    if (this.gradAssetsList.fmdNameDiff === 'Yes' && this.gradAssetsList.fmdNameDoc !== '' && this.gradAssetsList.fmdNameDoc !== undefined) {
                        this.fmdNameCond = true;
                        tempPayload.assetId = this.gradAssetsList.fmdNameDocId;
                        tempPayload.documentType = "Name Document";
                        this.gradAssetsList.fmdNameDocPayload = JSON.stringify(tempPayload);
                    }
                    if (this.gradAssetsList.fmdTrans === 'Yes' && this.gradAssetsList.fmdTransFile !== '') {
                        this.fmdTransCond = true;
                        tempPayload.assetId = this.gradAssetsList.fmdTransId;
                        tempPayload.documentType = "Final Diploma Translation";
                        this.gradAssetsList.fmdTranslationPayload = JSON.stringify(tempPayload);
                    }
                    if (this.gradAssetsList.dlNameDiff === 'Yes' && this.gradAssetsList.dlNameDoc !== '' && this.gradAssetsList.dlNameDoc !== undefined) {
                        this.dlNameCond = true;
                        tempPayload.assetId = this.gradAssetsList.dlNameDocId;
                        tempPayload.documentType = "Name Document";
                        this.gradAssetsList.dlNameDocPayload = JSON.stringify(tempPayload);
                    }
                    if (this.gradAssetsList.dlTrans === 'Yes' && this.gradAssetsList.dlTransFile !== '') {
                        this.dlTransCond = true;
                        tempPayload.assetId = this.gradAssetsList.dlTransId;
                        tempPayload.documentType = "Letter from Dean Translation";
                        this.gradAssetsList.dlTranslationPayload = JSON.stringify(tempPayload);
                    }
                    if (this.gradAssetsList.ftNameDiff === 'Yes' && this.gradAssetsList.ftNameDoc !== '') {
                        this.ftNameCond = true;
                        tempPayload.assetId = this.gradAssetsList.ftNameDocId;
                        tempPayload.documentType = "Name Document";
                        this.gradAssetsList.ftNameDocPayload = JSON.stringify(tempPayload);
                    }
                    if (this.gradAssetsList.ftTrans === 'Yes' && this.gradAssetsList.ftTransFile !== '') {
                        this.ftTransCond = true;
                        tempPayload.assetId = this.gradAssetsList.ftTransId;
                        tempPayload.documentType = "Final Transcript Translation";
                        this.gradAssetsList.ftTranslationPayload = JSON.stringify(tempPayload);
                    }
                    if (this.gradAssetsList.isDeanLetter === 'Yes') {
                        this.deanLetterCond = true;
                        this.isDeanLet = true;
                    }
                    if (this.gradAssetsList.isFTReqd === 'Yes') {
                        this.ftReqdCond = true;
                    }
                    if (this.gradAssetsList.dlFile !== '') {
                        this.showdlFile = true;
                        tempPayload.assetId = this.gradAssetsList.dlId;
                        tempPayload.documentType = "Letter from Dean";
                        this.gradAssetsList.dlPayload = JSON.stringify(tempPayload);
                    }
                    if (this.gradAssetsList.fmdFile !== '') {
                        this.showfmdFile = true;
                        tempPayload.assetId = this.gradAssetsList.fmdId;
                        tempPayload.documentType = "Final Medical Diploma";
                        this.gradAssetsList.fmdPayload = JSON.stringify(tempPayload);
                    }
                    if (this.gradAssetsList.ftFile !== '') {
                        this.showFtFile = true;
                        tempPayload.assetId = this.gradAssetsList.ftId;
                        tempPayload.documentType = "Final Medical School Transcript";
                        this.gradAssetsList.ftPayload = JSON.stringify(tempPayload);
                    }
                    if ((this.showFtFile || this.showdlFile || this.showfmdFile) && this.isGraduate) {
                        this.isGraduate = true;
                    } else {
                        this.isGraduate = false;
                    }
                }
            })
            .catch(error => {
                this.spinner = false;
                window.console.log('Error: ' + JSON.stringify(error));
            })
        let reporterQstnPromise = getReporterQuestionValue()
            .then(result => {
                this.reporterQstn = result;
            })
            .catch(error => {
                this.spinner = false;
                window.console.log('Error: ' + JSON.stringify(error));
            })
        let contactPromise = getContactDetails()
            .then(result => {
                this.contactData = result;
            })
            .catch(error => {
                this.spinner = false;
                window.console.log('Error: ' + JSON.stringify(error));
            })
        if (this.showExamRegActionButton) {
            Promise.all([isGraduatePromise, medSchoolPromise, otherMedSchoolExamRegPromise,
                otherInstExamRegPromise, assetExamRegPromise, otherMedSchoolPromise, otherInstPromise,
                assetPromise, graduateRecordPromise, reporterQstnPromise, contactPromise
            ]).then(() => {
                this.spinner = false;
                this.showAssets = true;
            });
        } else {
            Promise.all([isGraduatePromise, otherMedSchoolPromise, medSchoolPromise,
                otherInstPromise, assetPromise, graduateRecordPromise, reporterQstnPromise, contactPromise
            ]).then(() => {
                this.spinner = false;
                this.showAssets = true;
            });
        }
    }
    navigateToFiles(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                recordIds: event.target.value,
                selectedRecordId: event.target.value
            }
        })
    }
    downloadFiles(event) {
        let fileId = event.target.value;
        window.open(window.location.origin + `/sfc/servlet.shepherd/document/download/${fileId}?operationContext=S1`);
    }
    navigateToProfilePage(event) {
        event.preventDefault();
        const selectEvent = new CustomEvent('profilereviewredirect', {});
        this.dispatchEvent(selectEvent);
    }
    navigateToDegMedSchoolPage(event) {
        event.preventDefault();
        const selectEvent = new CustomEvent('degmedschoolredirect', {});
        this.dispatchEvent(selectEvent);
    }
    navigateToOtherMedSchoolPage(event) {
        event.preventDefault();
        const selectEvent = new CustomEvent('othermedschoolredirect', {});
        this.dispatchEvent(selectEvent);
    }
    navigateToOtherInstitutionPage(event) {
        event.preventDefault();
        const selectEvent = new CustomEvent('otherinstredirect', {});
        this.dispatchEvent(selectEvent);
    }
    navigateToGradOnlyPage(event) {
        event.preventDefault();
        const selectEvent = new CustomEvent('gradonlyredirect', {
            detail: this.showAlreadyDiplomaUploaded
        });
        this.dispatchEvent(selectEvent);
    }
    prevButton(event) {
        event.preventDefault();
        const selectEvent = new CustomEvent('previousevent', {});
        this.dispatchEvent(selectEvent);
    }
    prevButtonExamReg(event) {
        event.preventDefault();
        if (this.isGraduate) {
            const selectEvent = new CustomEvent('previousgradevent', {
                detail: this.showAlreadyDiplomaUploaded
            });
            this.dispatchEvent(selectEvent);
        } else {
            const selectEvent = new CustomEvent('previousinstevent', {});
            this.dispatchEvent(selectEvent);
        }
    }
    nextButton(event) {
        event.preventDefault();
        this.spinner = true;
        if (!this.showExamRegActionButton) {
            const selectEvent = new CustomEvent('nextevent', {});
            this.dispatchEvent(selectEvent);
            this.spinner = false;
        } else {
            if (this.isGraduate) {
                checkGradValOnSummary()
                    .then(result => {
                        if (result === 'PrimaryValidation') {
                            this.errorTrue = true;
                            this.errorSecTrue = false;
                            this.spinner = false;
                        } else if (result === 'SecondaryValidation') {
                            this.errorTrue = false;
                            this.errorSecTrue = true;
                            this.spinner = false;
                        } else {
                            this.errorTrue = false;
                            this.errorSecTrue = false;
                            const selectEvent = new CustomEvent('nextevent', {});
                            this.dispatchEvent(selectEvent);
                            this.spinner = false;
                        }
                    })
            } else {
                checkStudValOnSummary()
                    .then(result => {
                        if (result) {
                            this.errorTrue = true;
                            this.errorSecTrue = false;
                            this.spinner = false;
                        } else {
                            this.errorTrue = false;
                            this.errorSecTrue = false;
                            const selectEvent = new CustomEvent('nextevent', {});
                            this.dispatchEvent(selectEvent);
                            this.spinner = false;
                        }
                    })
            }
        }
    }
    cancelButton(event) {
        event.preventDefault();
        const selectEvent = new CustomEvent('cancelevent', {});
        this.dispatchEvent(selectEvent);
    }
    discardButton(event) {
        event.preventDefault();
        const selectEvent = new CustomEvent('discardevent', {});
        this.dispatchEvent(selectEvent);
    }
}