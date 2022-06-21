import {LightningElement, track, wire, api} from 'lwc';
import {getPicklistValues, getObjectInfo} from 'lightning/uiObjectInfoApi';
import getSchoolRecords from '@salesforce/apex/AppForCertController.getSchoolRecordsOthers';
import getOtherInstitutionRecords from '@salesforce/apex/AppForCertController.getOtherInstitutionRecords';
import searchOtherInstitutions from '@salesforce/apex/AppForCertController.searchOtherInstitutions';
import getContactId from '@salesforce/apex/AppForCertController.getContactId';
import getCaseId from '@salesforce/apex/AppForCertController.getCaseId';
import getContactName from '@salesforce/apex/AppForCertController.getContactName';
import isApplicantGraduate from '@salesforce/apex/AppForCertController.isApplicantGraduate';
import getContactAssociationOrStaging from "@salesforce/apex/AppForCertController.getContactAssociationOrStaging";
import getInstAssetsAndDocumentsRecBased from '@salesforce/apex/ExamRegistrationController.getInstAssetsAndDocuments';
import saveOtherInstitutionRecords from '@salesforce/apex/AppForCertController.saveOtherInstitutionRecords';
import yearsAttended from '@salesforce/apex/AppForCertController.yearsAttended';
import markAssetsForDeletionFromUrl from '@salesforce/apex/EpicCredVerController.markAssetsForDeletion';
import markTctAssetsForDeletion from '@salesforce/apex/AppForCertController.markTctAssetsForDeletion';
import markPmlAssetsForDeletion from '@salesforce/apex/AppForCertHelper.markPmlAssetsForDeletion';
import deleteOrphanedAssets from '@salesforce/apex/AppForCertController.deleteOrphanedAssets';
import deleteOtherInstitutions from '@salesforce/apex/AppForCertController.deleteOtherInstitutions';
import CurriculumYearsError from '@salesforce/label/c.Curriculum_Years_Error';
import CONTACT_ASSOCIATION_TYPE_STAGING_OBJECT from '@salesforce/schema/Contact_Association_Type_Staging__c';
import GRADUATION_MONTH_FIELD from '@salesforce/schema/Contact_Association_Type_Staging__c.Graduation_Month__c';
import START_MONTH_FIELD from '@salesforce/schema/Contact_Association_Type_Staging__c.Start_Month__c';
import END_MONTH_FIELD from '@salesforce/schema/Contact_Association_Type_Staging__c.End_Month__c';
import checkAppForCertStatus from '@salesforce/apex/AppForCertHelper.checkAppForCertStatus';
import getRecTypeId from '@salesforce/apex/GenericUtilities.getRecordTypeIdByDevName';
import FROM_YEAR from '@salesforce/schema/Contact_Association_Type__c.Personal_Family_from_year__c';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {getClosest, getCurrentSchoolIndex, showSection, hideSection, showNewDateErrorFunc, showAttendedYearsFunc, showStartEndErrorFunc, sectionsRendererHelper, clearErrorMessage, manageShowSection, emptyRecordsListHelper, tempTctPayloadHelper, tempTctNamePayloadHelper, tempTctTrnPayloadHelper, tempPmlPayloadHelper, tempPmlNamePayloadHelper, tempPmlTrnPayloadHelper} from './appForCertOtherInstitutionsHelper.js';
export default class AppForCertOtherInstitutions extends LightningElement {
    @api uploadFileCheck = false;
    @track recordsList = [];
    @track assetInsertedList = [];
    @track assetUrlsCollection = [];
    @track tcsToDel = [];
    @track wiredParameters = {
        error: '',
        data: null
    };
    @track clickedBtn;
    @track changedSchools = [];
    @api contactId;
    @api parentCaseId;
    @api caseId;
    @api contactAssociationTypeStagingId;
    @track showError = false;
    @track errorMessagesText = '';
    @track successMessageText = '';
    initialized = false;
    @track transferCreditsCheckboxMain = false;
    refreshCase;
    refreshContact;
    refreshContactAssociationType;
    @track newRecordAdded = false;
    savePassedWithoutErrors = true;
    @track showAddNew = false;
    @track showSaveAdd = false;
    @track showSaveAddClicked = false;
    //Code added by Shailaja. Date Format stories. User Story
    @track endMonth = '';
    @track startMonth = '';
    @track startYear = '';
    @track endYear = '';
    @track startMonthPicklistOptions = [];
    @track endMonthPicklistOptions = [];
    @track transferredCreditsFromNonMedSchool;
    @track contactName;
    @track isGraduate;
    @track monthPicklistOptions = [];
    @track assetInserted = false;
    @api showExamRegActionButton;
    @track showOtherInstiReadOnlySection = false;
    @track showOtherInstiEditSection = false;
    @track showCaseDetail = false;
    @track maxsize = 10;
    @track recordsListExamRegReadOnly = [];
    @track payloadPreMedLetter;
    @api isPreMedLetterUploaded = false;
    @track mandateUploadNewDoc = false;
    @track upload = true;
    @track emptyRecordsList = emptyRecordsListHelper();
    @track currentEvent;
    @track showReadOnlySection = false;
    @track optionsYears = [];
    @api caseRecordId;
    @track rejOrCancel;
    recordTypeDevName = 'Degree_Medical_School';
    @api searchfield = 'Name';
    @api iconname = "standard:account";
    @track entityRecordsList = [];
    @api recordsExistSubmitButton = false;
    @track selectedAccountName = '';
    @track selectedRec = [];
    @track selectedEntityId = '';
    @track hideNextButton = false;
    @track handleRendering = true;
    timeout;
    get options(){
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
    get transferredFromNonMedicalSchoolOptions(){
        return [{
                label: 'Yes',
                value: true
            },
            {
                label: 'No',
                value: false
            },
        ];
    }
    constructor(){
        super();
        this.getContactAssocObjName();
    }
    getContactAssocObjName(){
        getContactAssociationOrStaging()
        .then(result=>{
            if(result){
                this.objectType = result.split(",")[1];
            }
        })
        .catch(error=>{
            window.console.error("Error: " + JSON.stringify(error));
        });
    }
    @wire(getRecTypeId, {objectName: 'Contact_Association_Type__c', recordTypeDevName: '$recordTypeDevName'})
    getRecordTypeId(data,error){
        if(data.data){
            this.recordTypeId = data.data;
        }else if(error){
            window.console.error(error);
        }
    }
    @wire(getPicklistValues, {recordTypeId: '$recordTypeId', fieldApiName: FROM_YEAR})
    optionsYearsPickVal(data,error){
        if(data.data){
            this.optionsYears = data.data.values;
        }else if(error){
            window.console.error(error);
        }
    }
    @wire(getSchoolRecords) schoolRecordValues;
    @wire(getObjectInfo,{
        objectApiName: CONTACT_ASSOCIATION_TYPE_STAGING_OBJECT
    })
    objectInfo;
    @wire(getPicklistValues,{
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: GRADUATION_MONTH_FIELD
    })
    monthPicklistValues({
        error,
        data
    }){
        if(data){
            this.monthPicklistOptions = data.values;
        }else if(error){
            window.console.error('Error: ' + JSON.stringify(error));
        }
    }
    @wire(getPicklistValues,{
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: START_MONTH_FIELD
    })
    startMonthPicklistValues({
        error,
        data
    }){
        if(data){
            this.startMonthPicklistOptions = data.values;
        }else if(error){
            window.console.error('Error: ' + JSON.stringify(error));
        }
    }
    @wire(getPicklistValues,{
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: END_MONTH_FIELD
    })
    endMonthPicklistValues({
        error,
        data
    }){
        if(data){
            this.endMonthPicklistOptions = data.values;
        }else if(error){
            window.console.error('Error: ' + JSON.stringify(error));
        }
    }
    @wire(getContactId)
    contactIdfromController(result){
        this.refreshContact = result;
        if(result.data !== undefined){
            this.contactId = result.data;
            this.uploadFileCheck = true;
        }
    }
    @wire(getCaseId)
    caseIdfromController(result){
        this.refreshCase = result;
        if(result.data !== undefined){
            this.parentCaseId = result.data;
            this.caseId = result.data;
            this.uploadFileCheck = true;
        }
        let tempTctPayload = tempTctPayloadHelper(this.contactId, this.parentCaseId, this.caseId);
        let tempTctNamePayload = tempTctNamePayloadHelper(this.contactId, this.parentCaseId, this.caseId);
        let tempTctTrnPayload = tempTctTrnPayloadHelper(this.contactId, this.parentCaseId, this.caseId);
	    let tempPmlPayload = tempPmlPayloadHelper(this.contactId, this.parentCaseId, this.caseId);
        let tempPmlNamePayload = tempPmlNamePayloadHelper(this.contactId, this.parentCaseId, this.caseId);
        let tempPmlTrnPayload = tempPmlTrnPayloadHelper(this.contactId, this.parentCaseId, this.caseId);
        this.emptyRecordsList[0].tctPayload = JSON.stringify(tempTctPayload);
        this.emptyRecordsList[0].tctNamePayload = JSON.stringify(tempTctNamePayload);
        this.emptyRecordsList[0].tctTrnPayload = JSON.stringify(tempTctTrnPayload);
		this.emptyRecordsList[0].pmlPayload = JSON.stringify(tempPmlPayload);
        this.emptyRecordsList[0].pmlNamePayload = JSON.stringify(tempPmlNamePayload);
        this.emptyRecordsList[0].pmlTrnPayload = JSON.stringify(tempPmlTrnPayload);
    }
    getOtherInstitutionRecordsFunc(showExamRegActionButton){
        checkAppForCertStatus({recordTypeName: 'Other_Institution'})
        .then(result=>{
            this.mandateUploadNewDoc = result;
        })
        getOtherInstitutionRecords({
            showExamRegActionButton: showExamRegActionButton
        })
        .then(valueData=>{
            if(valueData){
                let count = 0;
                let proceedCheck = true;
                if(this.template.querySelectorAll('.slds-has-error') !== null){
                    if(this.template.querySelectorAll('.slds-has-error').length > 0){
                        proceedCheck = false;
                    }
                }
                if(proceedCheck && this.savePassedWithoutErrors){
                    this.showAddNew = true;
                }
                if(valueData.length > 0){
                    this.savePassedWithoutErrors = false;
                    this.recordsList = [];
                    if(valueData[0].otherSchoolWrapperList !== undefined){
                        this.showReadOnlySection = true;
                    }
                    if((this.showReadOnlySection === true || this.showExamRegActionButton === true) && valueData[0].otherSchoolWrapperList !== undefined){
                        this.showOtherInstiReadOnlySection = true;
                    }
                    if(valueData[0].otherSchoolWrapperList !== undefined || valueData[1].otherSchoolWrapperList !== undefined){
                        if(valueData[0].otherSchoolWrapperList !== undefined){
                            this.transferCreditsCheckboxMain = true;
                        }
                        if(valueData[1].otherSchoolWrapperList !== undefined){
                            this.transferCreditsCheckboxMain = true;
                            this.showOtherInstiEditSection = true;
                        }
                        this.showAddNew = true;
                        // eslint-disable-next-line guard-for-in
                        for(let keymain in valueData){
                            if(valueData.length > 2)
                                continue;
                            let value = valueData[keymain].otherSchoolWrapperList;
                            for(let key in value){
                                if(value.hasOwnProperty(key)){
                                    let tempRecord = {
                                        sno: ++count,
                                        recordIdVal: value[key].recordIdVal,
                                        otherSchool: value[key].otherSchool,
                                        otherSchoolId: value[key].otherSchoolId,
                                        schoolProgram: value[key].schoolProgram,
                                        fromDate: value[key].fromDate,
                                        numberOfYearsAttended: value[key].numberOfYearsAttended,
                                        endDate: value[key].endDate,
                                        startMonth: value[key].startMonth,
                                        startYear: value[key].startYear,
                                        endMonth: value[key].endMonth,
                                        endYear: value[key].endYear,
                                    };
                                    this.startMonth = tempRecord.startMonth;
                                    this.startYear = tempRecord.startYear;
                                    this.endMonth = tempRecord.endMonth;
                                    this.endYear = tempRecord.endYear;
                                    tempRecord.tcWrapperList = [];
                                    if(value[key].hasOwnProperty('tcWrapperList')){
                                        for(let i = 0; i < value[key].tcWrapperList.length; i++){
                                            let tempTc = {
                                                tcId: value[key].tcWrapperList[i].recordIdVal,
                                                transferCreditCourse: value[key].tcWrapperList[i].transferCreditCourse,
                                                transferCreditGrade: value[key].tcWrapperList[i].transferCreditGrade,
                                                courseOutcome: value[key].tcWrapperList[i].courseOutcome,
                                                creditsEarnedMonth: value[key].tcWrapperList[i].creditsEarnedMonth === undefined ? '' : value[key].tcWrapperList[i].creditsEarnedMonth,
                                                creditsEarnedYear: value[key].tcWrapperList[i].creditsEarnedYear === undefined ? '' : value[key].tcWrapperList[i].creditsEarnedYear,
                                            }
                                            tempRecord.tcWrapperList.push(tempTc);
                                        }
                                    }else{
                                        let tempTc = {
                                            tcId: '',
                                            transferCreditCourse: '',
                                            transferCreditGrade: '',
                                            courseOutcome: '',
                                            creditsEarnedMonth: '',
                                            creditsEarnedYear: ''
                                        }
                                        tempRecord.tcWrapperList.push(tempTc);
                                    }
                                    tempRecord.assetsList = [];
                                    if(value[key].hasOwnProperty('assets')){
                                        tempRecord.showNameSection = false;
                                        tempRecord.showTranslationSection = false;
                                        tempRecord.showTranslationNameSection = false;
                                        tempRecord.showPmlNameSection = false;
                                        tempRecord.showPmlTranslationSection = false;
                                        let tempTctPayload = tempTctPayloadHelper(this.contactId, this.parentCaseId, this.caseId);
                                        let tempTctNamePayload = tempTctNamePayloadHelper(this.contactId, this.parentCaseId, this.caseId);
                                        let tempTctTrnPayload = tempTctTrnPayloadHelper(this.contactId, this.parentCaseId, this.caseId);
                                        let tempPmlPayload = tempPmlPayloadHelper(this.contactId, this.parentCaseId, this.caseId);
                                        let tempPmlNamePayload = tempPmlNamePayloadHelper(this.contactId, this.parentCaseId, this.caseId);
                                        let tempPmlTrnPayload = tempPmlTrnPayloadHelper(this.contactId, this.parentCaseId, this.caseId);
                                        this.otherInstituteSchoolRecId = value[key].recordIdVal;
                                        if(value[key].caseInternalStatus === 'CV Rejected'){
                                            this.rejOrCancel = 'Rejected';
                                        }else if(value[key].caseInternalStatus === 'Cancelled'){
                                            this.rejOrCancel = 'Cancelled';
                                        }
                                        if(value[key].caseInternalStatus === 'CV Rejected' || value[key].caseInternalStatus === 'Cancelled'){
                                            tempRecord.tctPayload = JSON.stringify(tempTctPayload);
                                            tempRecord.tctNamePayload = JSON.stringify(tempTctNamePayload);
                                            tempRecord.tctTrnPayload = JSON.stringify(tempTctTrnPayload);
                                            tempRecord.pmlPayload = JSON.stringify(tempPmlPayload);
                                            tempRecord.pmlNamePayload = JSON.stringify(tempPmlNamePayload);
                                            tempRecord.pmlTrnPayload = JSON.stringify(tempPmlTrnPayload);
                                            tempRecord.pmlName = '';
                                            tempRecord.tctName = '';
                                            for(let i = 0; i < value[key].assets.length; i++){
                                                if(value[key].assets[i].type === 'Transfer Credit Transcript'){
                                                    tempTctPayload.assetId = null;
                                                    tempRecord.tctUrlRej = value[key].assets[i].azureUrl;
                                                    tempTctNamePayload.parentUrl = value[key].assets[i].azureUrl;
                                                    tempTctTrnPayload.parentUrl = value[key].assets[i].azureUrl;
                                                    tempRecord.tctPayloadRej = JSON.stringify(tempTctPayload);
                                                    tempRecord.tctAssetIdUpdatedRej = true;
                                                    tempRecord.tctAssetIdUpdated = true;
                                                    tempRecord.tctTrnAssetIdUpdated = true;
                                                    tempRecord.tctNameAssetIdUpdated = true;
                                                    if(value[key].assets[i].azureUrl){
                                                        this.assetInsertedList.push(value[key].assets[i].azureUrl);
                                                        this.assetUrlsCollection.push(value[key].assets[i].azureUrl);
                                                    }
                                                }
                                                if(value[key].assets[i].type === 'Name Document' && value[key].assets[i].parentval === 'Transfer Credit Transcript Document'){
                                                    tempTctNamePayload.assetId = null;
                                                    tempRecord.tctNameDocUrlRej = value[key].assets[i].azureUrl;
                                                    tempRecord.tctNamePayloadRej = JSON.stringify(tempTctNamePayload);
                                                    tempRecord.tctNameAssetIdUpdatedRej = true;
                                                    if(value[key].assets[i].azureUrl){
                                                        this.assetInsertedList.push(value[key].assets[i].azureUrl);
                                                        this.assetUrlsCollection.push(value[key].assets[i].azureUrl);
                                                    }
                                                }
                                                if(value[key].assets[i].type === 'Translation' && value[key].assets[i].parentval === 'Transfer Credit Transcript Document'){
                                                    tempTctTrnPayload.assetId = null;
                                                    tempRecord.tctTranslationUrlRej = value[key].assets[i].azureUrl;
                                                    tempRecord.tctTrnPayloadRej = JSON.stringify(tempTctTrnPayload);
                                                    tempRecord.tctTrnAssetIdUpdatedRej = true;
                                                    if(value[key].assets[i].azureUrl){
                                                        this.assetInsertedList.push(value[key].assets[i].azureUrl);
                                                        this.assetUrlsCollection.push(value[key].assets[i].azureUrl);
                                                    }
                                                }
                                                if(value[key].assets[i].type === 'Pre-Med Letter'){
                                                    tempPmlPayload.assetId = null;
                                                    tempRecord.pmlUrlRej = value[key].assets[i].azureUrl;
                                                    tempPmlNamePayload.parentUrl = value[key].assets[i].azureUrl;
                                                    tempPmlTrnPayload.parentUrl = value[key].assets[i].azureUrl;
                                                    tempRecord.pmlPayloadRej = JSON.stringify(tempPmlPayload);
                                                    tempRecord.pmlAssetIdUpdatedRej = true;
                                                    if(value[key].assets[i].azureUrl){
                                                        this.assetInsertedList.push(value[key].assets[i].azureUrl);
                                                        this.assetUrlsCollection.push(value[key].assets[i].azureUrl);
                                                    }
                                                    tempRecord.pmlAssetIdUpdated = true;
                                                    tempRecord.pmlTrnAssetIdUpdated = true;
                                                    tempRecord.pmlNameAssetIdUpdated = true;
                                                }
                                                if(value[key].assets[i].type === 'Name Document' && value[key].assets[i].parentval === 'Pre-Med Letter Document'){
                                                    tempRecord.pmlNameAssetIdUpdatedRej = true;
                                                    tempPmlNamePayload.assetId = null;
                                                    tempRecord.pmlNameDocumenatationUrlRej = value[key].assets[i].azureUrl;
                                                    tempRecord.pmlNamePayloadRej = JSON.stringify(tempPmlNamePayload);
                                                    if(value[key].assets[i].azureUrl){
                                                        this.assetInsertedList.push(value[key].assets[i].azureUrl);
                                                        this.assetUrlsCollection.push(value[key].assets[i].azureUrl);
                                                    }
                                                }
                                                if(value[key].assets[i].type === 'Translation' && value[key].assets[i].parentval === 'Pre-Med Letter Document'){
                                                    tempRecord.pmlTrnAssetIdUpdatedRej = true;
                                                    tempPmlTrnPayload.assetId = null;
                                                    tempRecord.pmlTranslationUrlRej = value[key].assets[i].azureUrl;
                                                    tempRecord.pmlTrnPayloadRej = JSON.stringify(tempPmlTrnPayload);
                                                    if(value[key].assets[i].azureUrl){
                                                        this.assetInsertedList.push(value[key].assets[i].azureUrl);
                                                        this.assetUrlsCollection.push(value[key].assets[i].azureUrl);
                                                    }
                                                }
                                            }
                                        }else{
                                            tempRecord.tctPayload = JSON.stringify(tempTctPayload);
                                            tempRecord.tctNamePayload = JSON.stringify(tempTctNamePayload);
                                            tempRecord.tctTrnPayload = JSON.stringify(tempTctTrnPayload);
                                            tempRecord.pmlPayload = JSON.stringify(tempPmlPayload);
                                            tempRecord.pmlNamePayload = JSON.stringify(tempPmlNamePayload);
                                            tempRecord.pmlTrnPayload = JSON.stringify(tempPmlTrnPayload);
                                            for(let i = 0; i < value[key].assets.length; i++){
                                                if(value[key].assets[i].type === 'Transfer Credit Transcript'){
                                                    tempRecord.nameOnTranscriptCheckbox = value[key].assets[i].nameOnDocIsDifferent === 'true';
                                                    tempRecord.isTranscriptInEnglishCheckbox = value[key].assets[i].docNotInEnglish === 'true';
                                                    tempRecord.showNameSection = true;
                                                    tempRecord.tctId = value[key].assets[i].recordIdVal;
                                                    tempTctPayload.assetId = null;
                                                    tempRecord.tctUrl = value[key].assets[i].azureUrl;
                                                    tempRecord.tctPayload = JSON.stringify(tempTctPayload);
                                                    tempTctNamePayload.parentUrl = value[key].assets[i].azureUrl;
                                                    tempTctTrnPayload.parentUrl = value[key].assets[i].azureUrl;
                                                    if(value[key].assets[i].azureUrl){
                                                        this.assetInsertedList.push(value[key].assets[i].azureUrl);
                                                        this.assetUrlsCollection.push(value[key].assets[i].azureUrl);
                                                    }
                                                    tempRecord.tctAssetIdUpdated = true;
                                                    tempRecord.tctTrnAssetIdUpdated = true;
                                                    tempRecord.tctNameAssetIdUpdated = true;
                                                    if(value[key].assets[i].nameOnDoc !== null){
                                                        tempRecord.tctName = value[key].assets[i].nameOnDoc !== null ? value[key].assets[i].nameOnDoc : '';
                                                    }else{
                                                        tempRecord.tctName = '';
                                                    }
                                                }
                                                if(value[key].assets[i].type === 'Name Document' && value[key].assets[i].parentval === 'Transfer Credit Transcript Document'){
                                                    tempRecord.tctNameDocumenatationId = value[key].assets[i].recordIdVal;
                                                    tempRecord.tctNameDocUrl = value[key].assets[i].azureUrl;
                                                    tempTctNamePayload.assetId = null;
                                                    tempRecord.tctNamePayload = JSON.stringify(tempTctNamePayload);
                                                    if(value[key].assets[i].azureUrl){
                                                        this.assetInsertedList.push(value[key].assets[i].azureUrl);
                                                        this.assetUrlsCollection.push(value[key].assets[i].azureUrl);
                                                    }
                                                }
                                                if(value[key].assets[i].type === 'Translation' && value[key].assets[i].parentval === 'Transfer Credit Transcript Document'){
                                                    tempRecord.nameOnTranslationDocCheckbox = value[key].assets[i].nameOnDocIsDifferent === 'true';
                                                    tempRecord.showTranslationSection = true;
                                                    tempRecord.tctTranslationId = value[key].assets[i].recordIdVal;
                                                    tempRecord.tctTranslationUrl = value[key].assets[i].azureUrl;
                                                    tempTctTrnPayload.assetId = null;
                                                    tempRecord.tctTrnPayload = JSON.stringify(tempTctTrnPayload);
                                                    if(value[key].assets[i].azureUrl){
                                                        this.assetInsertedList.push(value[key].assets[i].azureUrl);
                                                        this.assetUrlsCollection.push(value[key].assets[i].azureUrl);
                                                    }
                                                }
                                                if(value[key].assets[i].type === 'Pre-Med Letter'){
                                                    tempRecord.nameOnPreMedLetterCheckbox = value[key].assets[i].nameOnDocIsDifferent === 'true';
                                                    tempRecord.isPreMedLetterInEnglishCheckbox = value[key].assets[i].docNotInEnglish === 'true';
                                                    tempRecord.showPmlNameSection = true;
                                                    tempRecord.pmlId = value[key].assets[i].recordIdVal;
                                                    tempRecord.pmlUrl = value[key].assets[i].azureUrl;
                                                    if(value[key].assets[i].azureUrl){
                                                        this.assetInsertedList.push(value[key].assets[i].azureUrl);
                                                        this.assetUrlsCollection.push(value[key].assets[i].azureUrl);
                                                    }
                                                    tempPmlPayload.assetId = null;
                                                    tempRecord.pmlPayload = JSON.stringify(tempPmlPayload);
                                                    tempPmlNamePayload.parentUrl = value[key].assets[i].azureUrl;
                                                    tempPmlTrnPayload.parentUrl = value[key].assets[i].azureUrl;
                                                    if(value[key].assets[i].nameOnDoc !== null){
                                                        tempRecord.pmlName = value[key].assets[i].nameOnDoc !== null ? value[key].assets[i].nameOnDoc : '';
                                                    }else{
                                                        tempRecord.pmlName = '';
                                                    }
                                                    tempRecord.pmlAssetIdUpdated = true;
                                                    tempRecord.pmlTrnAssetIdUpdated = true;
                                                    tempRecord.pmlNameAssetIdUpdated = true;
                                                }
                                                if(value[key].assets[i].type === 'Name Document' && value[key].assets[i].parentval === 'Pre-Med Letter Document'){
                                                    tempRecord.pmlNameDocumenatationId = value[key].assets[i].recordIdVal;
                                                    tempRecord.pmlNameDocumenatationUrl = value[key].assets[i].azureUrl;
                                                    tempPmlNamePayload.assetId = null;
                                                    tempRecord.pmlNamePayload = JSON.stringify(tempPmlNamePayload);
                                                    if(value[key].assets[i].azureUrl){
                                                        this.assetInsertedList.push(value[key].assets[i].azureUrl);
                                                        this.assetUrlsCollection.push(value[key].assets[i].azureUrl);
                                                    }
                                                }
                                                if(value[key].assets[i].type === 'Translation' && value[key].assets[i].parentval === 'Pre-Med Letter Document'){
                                                    tempRecord.nameOnPmlTranslationCheckbox = value[key].assets[i].nameOnDocIsDifferent === 'true';
                                                    tempRecord.showPmlTranslationSection = true;
                                                    tempRecord.pmlTranslationId = value[key].assets[i].recordIdVal;
                                                    tempRecord.pmlTranslationUrl = value[key].assets[i].azureUrl;
                                                    tempPmlTrnPayload.assetId = null;
                                                    tempRecord.pmlTrnPayload = JSON.stringify(tempPmlTrnPayload);
                                                    if(value[key].assets[i].azureUrl){
                                                        this.assetInsertedList.push(value[key].assets[i].azureUrl);
                                                        this.assetUrlsCollection.push(value[key].assets[i].azureUrl);
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    if(this.recordsList.length > 0){
                                        this.recordsList = [...this.recordsList, tempRecord];
                                    }else{
                                        this.recordsList = [tempRecord];
                                    }
                                }
                            }
                            if(this.showReadOnlySection === true || this.showExamRegActionButton === true){
                                // eslint-disable-next-line eqeqeq
                                if(keymain == 0){
                                    this.recordsListExamRegReadOnly = this.recordsList;
                                    this.recordsList = [];
                                }
                            }
                        }
                    }else{
                        this.recordsList = this.emptyRecordsList;
                    }
                }else{
                    this.recordsList = this.emptyRecordsList;
                }
            }
        })
        .catch(error=>{
            this.recordsList = this.emptyRecordsList;
            window.console.error('System Error: ' + JSON.stringify(error));
        });
        getInstAssetsAndDocumentsRecBased()
            .then(data=>{
                if(data){
                    this.instAssetsList = data;
                    for(const key in this.recordsListExamRegReadOnly){
                        if(this.recordsListExamRegReadOnly.hasOwnProperty(key)){
                            let ele = this.recordsListExamRegReadOnly[key];
                            for(const assKey in this.instAssetsList){
                                if(this.instAssetsList.hasOwnProperty(assKey)){
                                    if(ele.recordIdVal === assKey){
                                        let assEle = this.instAssetsList[assKey];
                                        ele.tctId = assEle.tctId;
                                        ele.tctFile = assEle.tctFile;
                                        ele.tctName = assEle.tctName;
                                        ele.tctNameDiff = assEle.tctNameDiff;
                                        ele.tctNameDoc = assEle.tctNameDoc;
                                        ele.tctTransId = assEle.tctTransId;
                                        ele.tctTrans = assEle.tctTrans;
                                        ele.tctTransInEng = assEle.tctTransInEng;
                                        ele.tctTransFile = assEle.tctTransFile;
                                        ele.pmlId = assEle.pmlId;
                                        ele.pmlFile = assEle.pmlFile;
                                        ele.pmlName = assEle.pmlName;
                                        ele.pmlNameDiff = assEle.pmlNameDiff;
                                        ele.pmlNameDoc = assEle.pmlNameDoc;
                                        ele.pmlTransId = assEle.pmlTransId;
                                        ele.pmlTrans = assEle.pmlTrans;
                                        ele.pmlTransInEng = assEle.pmlTransInEng;
                                        ele.pmlTransFile = assEle.pmlTransFile;
                                        if(
                                            assEle.tctNameDiff === "Yes" &&
                                            assEle.tctNameDoc !== ""
                                        ){
                                            ele.tctNameCond = true;
                                        }
                                        if(
                                            assEle.tctTrans === "Yes" &&
                                            assEle.tctTransFile !== ""
                                        ){
                                            ele.tctTransCond = true;
                                        }
                                        if(
                                            assEle.pmlNameDiff === "Yes" &&
                                            assEle.pmlNameDoc !== ""
                                        ){
                                            ele.pmlNameCond = true;
                                        }
                                        if(
                                            assEle.pmlTrans === "Yes" &&
                                            assEle.pmlTransFile !== ""
                                        ){
                                            ele.pmlTransCond = true;
                                        }
                                        if(assEle.tctFile !== ""){
                                            ele.showtctFile = true;
                                        }
                                        if(assEle.pmlFile !== ""){
                                            ele.showpmlFile = true;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            })
            .catch(error=>{
                window.console.error("Error: " + JSON.stringify(error));
            });
    }
    assetMarkForDeletion(){
        markTctAssetsForDeletion({
            contactId: this.contactId,
            parentCaseId: this.parentCaseId
        });
        markPmlAssetsForDeletion({
            contactId: this.contactId,
            parentCaseId: this.parentCaseId
        });
    }
    connectedCallback(){
        deleteOrphanedAssets();
        this.assetMarkForDeletion();
        isApplicantGraduate({
                showExamRegActionButton: this.showExamRegActionButton,
                showCaseDetail: this.showCaseDetail
            })
            .then(data=>{
                this.isGraduate = data;
            });
        this.getOtherInstitutionRecordsFunc(this.showExamRegActionButton);
    }
    renderedCallback(){
        if(this.handleRendering === true){
            this.sectionsRenderer();
        }        
        getContactName({
            contactId: this.contactId
        })
        .then(result=>{
            if(result !== ''){
                this.contactName = JSON.stringify(result).replace('"', '').replace('"', '');
            }
        })
        .catch(error=>{
            window.console.error('Error: ' + JSON.stringify(error));
        });
        if(this.newRecordAdded){
            if(this.showSaveAddClicked){
                this.addNewReordInstitute();
                this.showAddNew = false;
                this.showSaveAdd = true;
                this.showSaveAddClicked = false;
            }
            let nodes = this.template.querySelectorAll('.recordFieldsWrapper');
            nodes[nodes.length - 1].scrollIntoView();
            this.newRecordAdded = false;
        }
        if(this.recordsList.length > 0){
            for(let i in this.recordsList){
                if(this.changedSchools.length > 0){
                    for(let j in this.changedSchools){
                        if(this.recordsList[i].sno === this.changedSchools[j].index){
                            this.recordsList[i].otherSchool = this.changedSchools[j].schoolInput;
                            this.recordsList[i].otherSchoolId = this.changedSchools[j].schoolId;
                        }
                    }
                }
            }
        }
        if(this.template.querySelectorAll('datalist.otherSchoolRecordDatalist') !== null){
            this.template.querySelectorAll('datalist.otherSchoolRecordDatalist').forEach(element => {
                let idToSet = element.parentNode.querySelector(".otherSchoolRecord").getAttribute("id");
                element.setAttribute("id", idToSet + 'dataListSchool');
                element.parentNode.querySelector(".otherSchoolRecord").setAttribute("list", element.id);
            });
        }
        manageShowSection(this);
    }
    handleRadioClick(event){
        this.transferredCreditsFromNonMedSchool = event.target.value;
    }
    handleChangeForInputValue(event){
        if(event.target.name === 'startMonth'){
            this.startMonth = event.target.value;
        }
        if(event.target.name === 'endMonth'){
            this.endMonth = event.target.value;
        }
        if(event.target.name === 'startYear'){
            this.startYear = event.target.value;
        }
        if(event.target.name === 'endYear'){
            this.endYear = event.target.value;
        }
    }
    handleMainTransferCreditCheckboxClick(event){
        this.showOtherInstiEditSection = event.target.checked;
        this.transferCreditsCheckboxMain = event.target.checked;
    }
    handleSchoolOnChange(event){
        event.target.classList.add('currentSchoolInput');
        let currentSchoolInput = this.template.querySelector('.otherSchoolRecord.currentSchoolInput').value;
        if(currentSchoolInput !== ''){
            let closestElem = getClosest(event.target, '.recordFieldsWrapper');
            let currentSchoolIndex = parseInt(closestElem.getAttribute('data-record-index'), 10);
            let currentChangedSchoolDetails = {
                index: currentSchoolIndex,
                schoolInput: currentSchoolInput,
                schoolId: ''
            }
            let selectedSchoolId = event.target.parentNode.querySelector(".otherSchoolRecordDatalist option[value=\"" + currentSchoolInput + "\"]").getAttribute("data-entityid");
            event.target.setAttribute("data-otherschool-id", selectedSchoolId);
            if(selectedSchoolId !== null && selectedSchoolId !== ''){
                currentChangedSchoolDetails.schoolId = selectedSchoolId;
                if(this.template.querySelector('.otherSchoolRecord.currentSchoolInput').classList.contains('slds-has-error')){
                    this.template.querySelector('.otherSchoolRecord.currentSchoolInput').classList.remove('slds-has-error');
                    if(this.template.querySelector('.otherSchoolRecord.currentSchoolInput').parentNode.querySelector('#otherInstBlankError') !== null){
                        let elem = this.template.querySelector('#otherInstBlankError');
                        elem.parentNode.removeChild(elem);
                    }
                }
            }
            this.changedSchools.push(currentChangedSchoolDetails);
        }else{
            event.target.setAttribute("data-otherschool-id", '');
        }
        event.target.classList.remove('currentSchoolInput');
    }
    handleOnAssetInserted(event){
        this.assetInserted = true;
        this.currentEvent = event;
        let index = getCurrentSchoolIndex(event.target, this.recordsList);
        if(event.target.parentNode.classList.contains("transferCreditTranscriptUpload")){
			event.target.parentNode.classList.add('currentTransferCreditTranscript');
            this.recordsList[index].tctUrl = event.detail.url;
            this.recordsList[index].tctAssetIdUpdated = true;
            let tempPayload = JSON.parse(this.recordsList[index].tctPayload);
            tempPayload.azureUrl = event.detail.url;
            this.recordsList[index].tctPayload = JSON.stringify(tempPayload);
            // setting parent url for name documentation
            tempPayload = JSON.parse(this.recordsList[index].tctNamePayload);
            tempPayload.parentUrl = event.detail.url;
            this.recordsList[index].tctNamePayload = JSON.stringify(tempPayload);
            // setting parent url for translation document
            tempPayload = JSON.parse(this.recordsList[index].tctTrnPayload);
            tempPayload.parentUrl = event.detail.url;
            this.recordsList[index].tctTrnPayload = JSON.stringify(tempPayload);
            if(!this.assetUrlsCollection.includes(event.detail.url)){
                this.assetUrlsCollection.push(event.detail.url);
            }
            this.template.querySelector('.currentTransferCreditTranscript').parentNode.querySelector('.tctName').setAttribute("data-asset-url", event.detail.url);
			if(this.template.querySelector('.currentTransferCreditTranscript').parentNode.querySelector('.tctMissingError') !== null){
				this.template.querySelector('.currentTransferCreditTranscript').parentNode.querySelector('.tctMissingError').remove();
			}
			showSection(this.template.querySelector('.currentTransferCreditTranscript').parentNode, 'tcNameSection');
			showSection(this.template.querySelector('.currentTransferCreditTranscript').parentNode, 'tcTranslationSection');
			event.target.parentNode.classList.remove('currentTransferCreditTranscript');
		}
		if(event.target.parentNode.classList.contains("tctNameDocumenatationSectionUploadId")){
			event.target.parentNode.classList.add('currentTctNameDocumenatationSectionUploadId');
            this.recordsList[index].tctNameDocUrl = event.detail.url;
            this.recordsList[index].handleTransferCreditInnerCheckboxClick = true;
            let tempPayload = JSON.parse(this.recordsList[index].tctNamePayload);
            tempPayload.azureUrl = event.detail.url;
            this.recordsList[index].tctNamePayload = JSON.stringify(tempPayload);
            if(!this.assetUrlsCollection.includes(event.detail.url)){
                this.assetUrlsCollection.push(event.detail.url);
            }
            this.template.querySelector('.currentTctNameDocumenatationSectionUploadId').parentNode.querySelector('.tctNameDocumenatationSectionUploadId').setAttribute("data-asset-url", event.detail.url);
			if(this.template.querySelector('.currentTctNameDocumenatationSectionUploadId').parentNode.querySelector('.nameDocMissingError') !== null){
                this.template.querySelector('.currentTctNameDocumenatationSectionUploadId').parentNode.querySelector('.nameDocMissingError').remove();
            }
            this.template.querySelector('.currentTctNameDocumenatationSectionUploadId').classList.remove('currentTctNameDocumenatationSectionUploadId');
		}
		if(event.target.parentNode.classList.contains("tcTranslationSectionUpload")){
            event.target.parentNode.classList.add('currentTranslationTCT');
            this.recordsList[index].tctTranslationUrl = event.detail.url;
            this.recordsList[index].tctTrnAssetIdUpdated = true;
            let tempPayload = JSON.parse(this.recordsList[index].tctTrnPayload);
            tempPayload.azureUrl = event.detail.url;
            this.recordsList[index].tctTrnPayload = JSON.stringify(tempPayload);
            if(!this.assetUrlsCollection.includes(event.detail.url)){
                this.assetUrlsCollection.push(event.detail.url);
            }
            this.template.querySelector('.currentTranslationTCT').parentNode.querySelector('.tctTranslationId').setAttribute("data-asset-url", event.detail.url);
            if(this.template.querySelector('.currentTranslationTCT').parentNode.querySelector('.translationDocMissingError') !== null){
                this.template.querySelector('.currentTranslationTCT').parentNode.querySelector('.translationDocMissingError').remove();
            }
            event.target.parentNode.classList.remove('currentTranslationTCT');
		}
		if(event.target.parentNode.classList.contains("preMedLetterUpload")){
            event.target.parentNode.classList.add('currentPreMedLetterSection');
            let indexPMD = getCurrentSchoolIndex(event.target, this.recordsList);
            this.recordsList[indexPMD].pmlUrl = event.detail.url;
            this.recordsList[indexPMD].pmlAssetIdUpdated = true;
            let tempPayload = JSON.parse(this.recordsList[indexPMD].pmlPayload);
            tempPayload.azureUrl = event.detail.url;
            this.recordsList[indexPMD].pmlPayload = JSON.stringify(tempPayload);
            // setting parent url for name documentation
            tempPayload = JSON.parse(this.recordsList[indexPMD].pmlNamePayload);
            tempPayload.parentUrl = event.detail.url;
            this.recordsList[indexPMD].pmlNamePayload = JSON.stringify(tempPayload);
            // setting parent url for translation document
            tempPayload = JSON.parse(this.recordsList[indexPMD].pmlTrnPayload);
            tempPayload.parentUrl = event.detail.url;
            this.recordsList[index].pmlTrnPayload = JSON.stringify(tempPayload);
            if(!this.assetUrlsCollection.includes(event.detail.url)){
                this.assetUrlsCollection.push(event.detail.url);
            }
            this.template.querySelector('.currentPreMedLetterSection').parentNode.querySelector('.pmlName').setAttribute("data-asset-url", event.detail.url);
			if(this.template.querySelector('.currentPreMedLetterSection').parentNode.querySelector('.pmlMissingError') !== null){
				this.template.querySelector('.currentPreMedLetterSection').parentNode.querySelector('.pmlMissingError').remove();
			}
			showSection(this.template.querySelector('.currentPreMedLetterSection').parentNode, 'pmlNameSection');
			showSection(this.template.querySelector('.currentPreMedLetterSection').parentNode, 'pmTranslationSection');
			event.target.parentNode.classList.remove('currentPreMedLetterSection');
		}
		if(event.target.parentNode.classList.contains("pmlNameSectionUpload")){
            event.target.parentNode.classList.add('currentPmlNameDocumenatationSectionUploadId');
            let indexPML = getCurrentSchoolIndex(event.target, this.recordsList);
            this.recordsList[indexPML].pmlNameDocumenatationUrl = event.detail.url;
            this.recordsList[indexPML].pmlNameAssetIdUpdated = true;
            let tempPayload = JSON.parse(this.recordsList[indexPML].pmlNamePayload);
            tempPayload.azureUrl = event.detail.url;
            this.recordsList[indexPML].pmlNamePayload = JSON.stringify(tempPayload);
            if(!this.assetUrlsCollection.includes(event.detail.url)){
                this.assetUrlsCollection.push(event.detail.url);
            }
            this.template.querySelector('.currentPmlNameDocumenatationSectionUploadId').parentNode.querySelector('.pmlNameSectionUploadId').setAttribute("data-asset-url", event.detail.url);
            if(this.template.querySelector('.currentPmlNameDocumenatationSectionUploadId').parentNode.querySelector('.nameDocMissingError') !== null){
                this.template.querySelector('.currentPmlNameDocumenatationSectionUploadId').parentNode.querySelector('.nameDocMissingError').remove();
            }
            this.template.querySelector('.currentPmlNameDocumenatationSectionUploadId').classList.remove('currentPmlNameDocumenatationSectionUploadId');
		}
		if(event.target.parentNode.classList.contains("pmlTranslationSectionUpload")){
            event.target.parentNode.classList.add('currentPreMedLetterTransSection');
            let indexTCTRN = getCurrentSchoolIndex(event.target, this.recordsList);
            this.recordsList[indexTCTRN].pmlTranslationUrl = event.detail.url;
            this.recordsList[indexTCTRN].pmlTrnAssetIdUpdated = true;
            let tempPayload = JSON.parse(this.recordsList[indexTCTRN].pmlTrnPayload);
            tempPayload.azureUrl = event.detail.url;
            this.recordsList[indexTCTRN].pmlTrnPayload = JSON.stringify(tempPayload);
            if(!this.assetUrlsCollection.includes(event.detail.url)){
                this.assetUrlsCollection.push(event.detail.url);
            }
            this.template.querySelector('.currentPreMedLetterTransSection').parentNode.querySelector('.pmlTranslationId').setAttribute("data-asset-url", event.detail.url);
            if(this.template.querySelector('.currentPreMedLetterTransSection').parentNode.querySelector('.translationDocMissingError') !== null){
                this.template.querySelector('.currentPreMedLetterTransSection').parentNode.querySelector('.translationDocMissingError').remove();
            }
            event.target.parentNode.classList.remove('currentPreMedLetterTransSection');
		}
        this.assetInsertedList.push(event.detail.url);
	}
    handleTransferCreditInnerCheckboxClick(event){
        let index = getCurrentSchoolIndex(event.target, this.recordsList);
        if(event.target.classList.contains('tctNameDifferentCheckbox')){
            let currentNameDocAssetUrl = getClosest(event.target, '.recordFieldsWrapper').querySelector(".tctNameDocumenatationSectionUploadId").getAttribute('data-asset-url');
            if(event.target.checked){
                showSection(event.target.parentNode.parentNode, 'tctNameDocumenatationSectionUpload');
                this.recordsList[index].tctNameAssetIdUpdated = true;
                this.recordsList[index].nameOnTranscriptCheckbox = true;
            }else{
                hideSection(event.target.parentNode.parentNode, 'tctNameDocumenatationSectionUpload');
                if(currentNameDocAssetUrl){
                    markAssetsForDeletionFromUrl({azureUrl : currentNameDocAssetUrl});
                    getClosest(event.target, '.recordFieldsWrapper').querySelector(".tctNameDocumenatationSectionUploadId").setAttribute("data-asset-url", '');
                }
                this.recordsList[index].tctNameAssetIdUpdated = false;
                this.recordsList[index].nameOnTranscriptCheckbox = false;
                let tempTctNamePayload = JSON.parse(this.recordsList[index].tctNamePayload);
                tempTctNamePayload.azureUrl = null;
                this.recordsList[index].tctNamePayload = JSON.stringify(tempTctNamePayload);
                this.recordsList[index].tctNameDocUrl = '';
                this.template.querySelector(".cloudTCTNameDocumentation").auraThumbnailLoaderAzureURL();
            }
        }
        if(event.target.classList.contains('isTranscriptInEnglishCheckbox')){
            let currentTctTransDocAssetUrl = getClosest(event.target, '.recordFieldsWrapper').querySelector(".tctTranslationId").getAttribute('data-asset-url');
            if(event.target.checked){
                showSection(event.target.parentNode.parentNode, 'tcTranslationSectionUpload');
                this.recordsList[index].tctTrnAssetIdUpdated = true;
                this.recordsList[index].isTranscriptInEnglishCheckbox = true;
            }else{
                hideSection(event.target.parentNode.parentNode, 'tcTranslationSectionUpload');
                if(currentTctTransDocAssetUrl){
                   markAssetsForDeletionFromUrl({azureUrl : currentTctTransDocAssetUrl});
                   getClosest(event.target, '.recordFieldsWrapper').querySelector(".tctTranslationId").setAttribute('data-asset-url', '');
                }
                this.recordsList[index].tctTrnAssetIdUpdated = false;
                this.recordsList[index].isTranscriptInEnglishCheckbox = false;
                let tempPayload = JSON.parse(this.recordsList[index].tctTrnPayload);
                tempPayload.azureUrl = null;
                this.recordsList[index].tctTrnPayload = JSON.stringify(tempPayload);
                this.recordsList[index].tctTranslationUrl = '';
                this.template.querySelector(".cloudTCTTransDoc").auraThumbnailLoaderAzureURL();
            }
        }
        if(event.target.classList.contains('pmlNameDifferentCheckbox')){
            let currentTctTransDocAssetUrl = getClosest(event.target, '.recordFieldsWrapper').querySelector(".pmlNameSectionUploadId").getAttribute('data-asset-url');
            if(event.target.checked){
                showSection(event.target.parentNode.parentNode, 'pmlNameSectionUpload');
                this.recordsList[index].pmlNameAssetIdUpdated = true;
                this.recordsList[index].nameOnPreMedLetterCheckbox = true;
            }else{
                hideSection(event.target.parentNode.parentNode, 'pmlNameSectionUpload');
                this.recordsList[index].pmlNameAssetIdUpdated = false;
                this.recordsList[index].nameOnPreMedLetterCheckbox = false;
                if(currentTctTransDocAssetUrl){
                    markAssetsForDeletionFromUrl({azureUrl : currentTctTransDocAssetUrl});
                    getClosest(event.target, '.recordFieldsWrapper').querySelector(".pmlNameSectionUploadId").setAttribute('data-asset-url', '');
                }
                let tempPayload = JSON.parse(this.recordsList[index].pmlNamePayload);
                tempPayload.azureUrl = null;
                this.recordsList[index].pmlNamePayload = JSON.stringify(tempPayload);
                this.recordsList[index].pmlNameDocumenatationUrl = '';
                this.template.querySelector(".cloudPMLNameDocumentation").auraThumbnailLoaderAzureURL();
            }
        }
        if(event.target.classList.contains('isPreMedLetterInEnglishCheckbox')){
            let currentTctTransDocAssetUrl = getClosest(event.target, '.recordFieldsWrapper').querySelector(".pmlTranslationId").getAttribute('data-asset-url');
            if(event.target.checked){
                showSection(event.target.parentNode.parentNode, 'pmlTranslationSectionUpload');
                this.recordsList[index].pmlTrnAssetIdUpdated = true;
                this.recordsList[index].isPreMedLetterInEnglishCheckbox = true;
            }else{
                hideSection(event.target.parentNode.parentNode, 'pmlTranslationSectionUpload');
                this.recordsList[index].pmlTrnAssetIdUpdated = false;
                this.recordsList[index].isPreMedLetterInEnglishCheckbox = false;
                if(currentTctTransDocAssetUrl){
                    markAssetsForDeletionFromUrl({azureUrl : currentTctTransDocAssetUrl});
                    getClosest(event.target, '.recordFieldsWrapper').querySelector(".pmlNameSectionUploadId").setAttribute('data-asset-url', '');
                }
                let tempPayload = JSON.parse(this.recordsList[index].pmlTrnPayload);
                tempPayload.azureUrl = null;
                this.recordsList[index].pmlTrnPayload = JSON.stringify(tempPayload);
                this.recordsList[index].pmlTranslationUrl = '';
                this.template.querySelector(".cloudPMLTransDoc").auraThumbnailLoaderAzureURL();
            }
        }
    }
    getNextSiblings(element){
        var arraySib = [];
        while (element){
            arraySib.push(element);
            element = element.nextSibling;
        }
        return arraySib;
    }
    onloadRenderer(clsName){
        let cls = '.' + clsName;
        if(this.template.querySelectorAll(cls) !== null){
            this.template.querySelectorAll(cls).forEach(elem => {
                if(elem.getAttribute('data-showthissectiononload')){
                    showSection(elem.parentNode, clsName);
                }else{
                    hideSection(elem.parentNode, clsName);
                }
            });
        }
    }
    sectionsRenderer(){
        if(this.transferCreditsCheckboxMain){
            sectionsRendererHelper(this);
        }
    }
    addTcRow(event){
        let closestElem = getClosest(event.target, '.recordFieldsWrapper');
        let currentSchoolRecordId = closestElem.getAttribute('data-record-id');
        let currentSchoolRecordIndex = parseInt(closestElem.getAttribute('data-record-index'), 10);
        let requiredObj;
        if(currentSchoolRecordId === ""){
            for(let i in this.recordsList){
                if(this.recordsList[i].sno === currentSchoolRecordIndex){
                    requiredObj = this.recordsList[i];
                    break;
                }
            }
        }else{
            for(let i in this.recordsList){
                if(this.recordsList[i].recordIdVal === currentSchoolRecordId){
                    requiredObj = this.recordsList[i];
                    break;
                }
            }
        }
        let newTc = {
            tcId: '',
            transferCreditCourse: '',
            transferCreditGrade: '',
            courseOutcome: '',
            creditsEarnedMonth: '',
            creditsEarnedYear: ''
        }
        if(requiredObj !== null && requiredObj !== undefined){
            requiredObj.tcWrapperList.push(newTc);
        }
    }
    deleteTcRow(event){
        let closestWrapElem = getClosest(event.target, '.recordFieldsWrapper');
        let currentSchoolRecordId = closestWrapElem.getAttribute('data-record-id');
        let currentSchoolRecordIndex = parseInt(closestWrapElem.getAttribute('data-record-index'), 10);
        let requiredObj;
        if(currentSchoolRecordId === ""){
            for(let i in this.recordsList){
                if(this.recordsList[i].sno === currentSchoolRecordIndex){
                    requiredObj = this.recordsList[i];
                    break;
                }
            }
        }else{
            for(let i in this.recordsList){
                if(this.recordsList[i].recordIdVal === currentSchoolRecordId){
                    requiredObj = this.recordsList[i];
                    break;
                }
            }
        }
        let closestTcElem = getClosest(event.target, '.tcDetailsRow');
        let currentTcId = closestTcElem.getAttribute('data-tcid');
        this.tcsToDel.push(currentTcId);
        if(requiredObj !== null && requiredObj !== undefined){
            for(let i in requiredObj.tcWrapperList){
                if(requiredObj.tcWrapperList[i].tcId === currentTcId){
                    requiredObj.tcWrapperList.splice(i, 1);
                    break;
                }
            }
        }
    }
    addNewReordInstitute(){
        let count = this.recordsList.length;
        if(this.showReadOnlySection === true || this.showExamRegActionButton === true){
            count = this.recordsListExamRegReadOnly.length + this.recordsList.length;
        }
        let tempTctPayload = tempTctPayloadHelper(this.contactId, this.parentCaseId, this.caseId);
        let tempTctNamePayload = tempTctNamePayloadHelper(this.contactId, this.parentCaseId, this.caseId);
        let tempTctTrnPayload = tempTctTrnPayloadHelper(this.contactId, this.parentCaseId, this.caseId);
	    let tempPmlPayload = tempPmlPayloadHelper(this.contactId, this.parentCaseId, this.caseId);
        let tempPmlNamePayload = tempPmlNamePayloadHelper(this.contactId, this.parentCaseId, this.caseId);
        let tempPmlTrnPayload = tempPmlTrnPayloadHelper(this.contactId, this.parentCaseId, this.caseId);
        this.recordsList = [...this.recordsList, {
            sno: count + 1,
            recordIdVal: "",
            otherSchool: "",
            otherSchoolId: "",
            numberOfYearsAttended: '',
            fromDate: "",
            endDate: "",
            startMonth:'',
            startYear:'',
            endMonth:'',
            endYear:'',
            schoolProgram: "",
            showNameSection: false,
            showTranslationSection: false,
            showTranslationNameSection: false,
            showPmlNameSection: false,
            showPmlTranslationSection: false,
            nameOnTranscriptCheckbox: false,
            isTranscriptInEnglishCheckbox: false,
            tctId: "",
            tctName: "",
            tctNameDocumenatationId: "",
            nameOnTranslationDocCheckbox: false,
            tctTranslationId: "",
            nameOnPreMedLetterCheckbox: "",
            isPreMedLetterInEnglishCheckbox: "",
            pmlId: "",
            pmlUrl: "",
            pmlName: "",
            pmlNameDocumenatationId: "",
            nameOnPmlTranslationCheckbox: false,
            pmlTranslationId: "",
            tcWrapperList: [{
                tcId: '',
                transferCreditCourse: '',
                transferCreditGrade: '',
                courseOutcome: '',
                creditsEarnedMonth: '',
                creditsEarnedYear: ''
            }],
            tctPayload: JSON.stringify(tempTctPayload),
            tctTrnPayload: JSON.stringify(tempTctTrnPayload),
            tctNamePayload: JSON.stringify(tempTctNamePayload),
            pmlPayload: JSON.stringify(tempPmlPayload),
            pmlTrnPayload: JSON.stringify(tempPmlTrnPayload),
            pmlNamePayload: JSON.stringify(tempPmlNamePayload),
            tctAssetIdUpdated: true,
            tctTrnAssetIdUpdated:true,
            tctNameAssetIdUpdated:true,
            pmlAssetIdUpdated:true,
            pmlTrnAssetIdUpdated:true,
            pmlNameAssetIdUpdated:true,
            tctAssetIdUpdatedRej:false,
            tctTrnAssetIdUpdatedRej:false,
            tctNameAssetIdUpdatedRej:false,
            pmlAssetIdUpdatedRej:false,
            pmlTrnAssetIdUpdatedRej:false,
            pmlNameAssetIdUpdatedRej: false,
        }];
    }
    addNewRecord(){
        if(this.showAddNew){
            this.showOtherInstiEditSection = true;
            this.addNewReordInstitute();
            this.showAddNew = false;
            this.showSaveAdd = true;
            this.newRecordAdded = true;
        }else if(this.showSaveAdd){
            this.showAddNew = false;
            this.showSaveAdd = true;
            this.showSaveAddClicked = true;
            this.saveRecords();
        }
    }
    showOtherInstErrorFunc(){
        this.template.querySelectorAll('.otherInstBlankError').forEach(element => element.remove());
        this.template.querySelectorAll('.otherSchoolRecord').forEach(element => {
            if(element.getAttribute('data-otherschool-id') === '' || element.getAttribute('data-otherschool-id') === true){
                let elem = document.createElement("div");
                elem.id = 'otherInstBlankError';
                elem.setAttribute('class', 'otherInstBlankError');
                elem.textContent = 'Please enter a valid Institution from the available options';
                elem.style = 'color:#ff0000; clear:both;';
                element.classList.add('slds-has-error');
                element.parentNode.insertBefore(elem, element.nextSibling);
                this.hideNextButton = true;
            }
        });
        this.template.querySelector('.slds-has-error').scrollIntoView();
    }
    saveRecords(){
        this.spinner = true;
        let breakSaveFunc = false;
        let showOtherInstError = false;
        this.savePassedWithoutErrors = false;
        this.template.querySelectorAll('.otherSchoolRecord').forEach(element => {
            if(element.getAttribute('data-otherschool-id') === '' || element.getAttribute('data-otherschool-id') === true){
                showOtherInstError = true;
                breakSaveFunc = true;
            }
        });
        let allWrapper = this.template.querySelectorAll(".recordFieldsWrapper");
        let recordValuesToSave = [];
        allWrapper.forEach(function (element){
            let tempSchoolRecord = {
                recordIdVal: element.getAttribute('data-record-id'),
                otherSchool: element.querySelector(".otherSchoolRecord").value,
                otherSchoolId: element.querySelector(".otherSchoolRecord").getAttribute('data-otherschool-id'),
                schoolProgram: '',
                studentId: '',
                Specialty: '',
                numberOfYearsAttended: element.querySelector(".attendedYears").value,
                startMonth: element.querySelector(".startMonth").value,
                startYear: element.querySelector(".startYear").value,
                endMonth: element.querySelector(".endMonth").value,
                endYear: element.querySelector(".endYear").value,
                transferCreditsCheckbox: true
            }
            tempSchoolRecord.tcWrapperList = [];
            let tempFromSchool = element.querySelector(".otherSchoolRecord").getAttribute('data-otherschool-id');
            let tcDetailsRow = element.querySelectorAll(".tcDetailsRow");
            tcDetailsRow.forEach(function (elem){
                let regex = /^(\d{0,2}\.?\d{0,2})/g;
                let decimalCheckerRegex = /^\d*\.?\d+$/;
                let normalizedGradeInput = 0;
                if(decimalCheckerRegex.test(elem.querySelector(".transferCreditGradeInput").value)){
                    let decimalValue = parseFloat(elem.querySelector(".transferCreditGradeInput").value);
                    if(decimalValue > 0 && decimalValue < 100){
                        normalizedGradeInput = elem.querySelector(".transferCreditGradeInput").value.match(regex)[0];
                    }
                }
                elem.querySelector(".transferCreditGradeInput").setAttribute('data-normalizedGradeInput', normalizedGradeInput);
                let tempTcRecord = {
                    recordIdVal: elem.getAttribute('data-tcid'),
                    fromSchool: tempFromSchool,
                    transferCreditCourse: elem.querySelector(".transferCreditCourseInput").value,
                    transferCreditGrade: normalizedGradeInput,
                    courseOutcome: elem.querySelector(".transferCreditCourseOutcomeInput").value,
                    creditsEarnedMonth: elem.querySelector(".monthPicklist").value,
                    creditsEarnedYear: elem.querySelector(".creditEarnedYearInput").value
                }
                tempSchoolRecord.tcWrapperList.push(tempTcRecord);
            });
            let tempTctAssetRecord = {
                azureUrl: element.querySelector(".tctName").getAttribute('data-asset-url'),
                docNotInEnglish: element.querySelector(".isTranscriptInEnglishCheckbox").checked,
                nameOnDoc: element.querySelector(".tctName").value,
                nameOnDocIsDifferent: element.querySelector(".tctNameDifferentCheckbox").checked,
                type: 'Transfer Credit Transcript',
                parentAssetAzureUrl: ''
            }
            tempSchoolRecord.assets = [];
            if(tempTctAssetRecord.azureUrl !== '' && tempTctAssetRecord.azureUrl !== null){
                tempSchoolRecord.assets.push(tempTctAssetRecord);
            }
            let tempTctNameRecord = {
                azureUrl: element.querySelector(".tctNameDocumenatationSectionUploadId").getAttribute('data-asset-url'),
                docNotInEnglish: '',
                nameOnDoc: '',
                nameOnDocIsDifferent: '',
                type: 'Name Document',
                parentAssetAzureUrl: element.querySelector(".tctName").getAttribute('data-asset-url')
            }
            if(tempTctNameRecord.azureUrl !== '' && tempTctNameRecord.azureUrl !== null){
                tempSchoolRecord.assets.push(tempTctNameRecord);
            }
            let tempTctTranslationAssetRecord = {
                azureUrl: element.querySelector(".tctTranslationId").getAttribute('data-asset-url'),
                docNotInEnglish: '',
                nameOnDoc: '',
                nameOnDocIsDifferent: '',
                type: 'Translation',
                parentAssetAzureUrl: element.querySelector(".tctName").getAttribute('data-asset-url')
            }
            if(tempTctTranslationAssetRecord.azureUrl !== '' && tempTctTranslationAssetRecord.azureUrl !== null){
                tempSchoolRecord.assets.push(tempTctTranslationAssetRecord);
            }
            let tempPmlAssetRecord = {
                azureUrl: element.querySelector(".pmlName").getAttribute('data-asset-url'),
                docNotInEnglish: element.querySelector(".isPreMedLetterInEnglishCheckbox").checked,
                nameOnDoc: element.querySelector(".pmlName").value,
                nameOnDocIsDifferent: element.querySelector(".pmlNameDifferentCheckbox").checked,
                type: 'Pre-Med Letter',
                parentAssetAzureUrl: ''
            }
            if(tempPmlAssetRecord.azureUrl !== '' && tempPmlAssetRecord.azureUrl !== null){
                tempSchoolRecord.assets.push(tempPmlAssetRecord);
            }
            let tempPmlNameRecord = {
                azureUrl: element.querySelector(".pmlNameSectionUploadId").getAttribute('data-asset-url'),
                docNotInEnglish: '',
                nameOnDoc: '',
                nameOnDocIsDifferent: '',
                type: 'Name Document',
                parentAssetAzureUrl: element.querySelector(".pmlName").getAttribute('data-asset-url')
            }
            if(tempPmlNameRecord.azureUrl !== '' && tempPmlNameRecord.azureUrl !== null){
                tempSchoolRecord.assets.push(tempPmlNameRecord);
            }
            let tempPmlTranslationAssetRecord = {
                azureUrl: element.querySelector(".pmlTranslationId").getAttribute('data-asset-url'),
                docNotInEnglish: '',
                nameOnDoc: '',
                nameOnDocIsDifferent: '',
                type: 'Translation',
                parentAssetAzureUrl: element.querySelector(".pmlName").getAttribute('data-asset-url')
            }
            if(tempPmlTranslationAssetRecord.azureUrl !== '' && tempPmlTranslationAssetRecord.azureUrl !== null){
                tempSchoolRecord.assets.push(tempPmlTranslationAssetRecord);
            }
            recordValuesToSave.push(tempSchoolRecord);
        });
        if(this.template.querySelectorAll('.slds-has-error') !== null){
            this.template.querySelectorAll('.slds-has-error').forEach(element => element.classList.remove('slds-has-error'));
        }
        let today = new Date();
        let dd = String(today.getDate()).padStart(2, '0');
        let mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        let yyyy = today.getFullYear();
        today = yyyy + '-' + mm + '-' + dd;
        let showDateError = false,
            showBlankNameError = false,
            tcCourseBlank = false,
            tcGradeBlank = false,
            tcCourseOutcome = false,
            tcCourseMonth = false,
            tcCourseYear = false,
            tcDateCond = false,
            showTctMissing = false,
            showTranslationDocMissing = false,
            showPmlLetterMissing = false,
            showPmlTranslationDocMissing = false,
            showfromToError = false,
            showAttendedYearsError = false,
            decimalCount = 0;
        for(let i = 0; i < recordValuesToSave.length; i++){
            if(recordValuesToSave[i].startMonth === '' || recordValuesToSave[i].startMonth === null || recordValuesToSave[i].startYear === '' || recordValuesToSave[i].startYear === null){
                showDateError = true;
            }
            if(recordValuesToSave[i].endMonth === '' || recordValuesToSave[i].endMonth === null || recordValuesToSave[i].endYear === '' || recordValuesToSave[i].endYear === null){
                showDateError = true;
            }
            if(recordValuesToSave[i].numberOfYearsAttended === undefined || recordValuesToSave[i].numberOfYearsAttended === '' || parseFloat(recordValuesToSave[i].numberOfYearsAttended) <= parseFloat('0') || parseFloat(recordValuesToSave[i].numberOfYearsAttended) > parseFloat('20')){
                showAttendedYearsError = true;
            }else{
                if((Math.floor(parseFloat(recordValuesToSave[i].numberOfYearsAttended)) === parseFloat(recordValuesToSave[i].numberOfYearsAttended))){
                    decimalCount = 0;
                }else{
                    decimalCount = recordValuesToSave[i].numberOfYearsAttended.split(".")[1].length;
                }
                if(decimalCount > 2){
                    showAttendedYearsError = true;
                }
            }
            if(recordValuesToSave[i].endMonth !== '' && recordValuesToSave[i].endMonth !== null && recordValuesToSave[i].endYear !== '' && recordValuesToSave[i].endYear !== null){
                let newStartEndDay = '01';
                let tempStrSDate = recordValuesToSave[i].startYear + '-' + recordValuesToSave[i].startMonth +'-' +  newStartEndDay
                let tempNewStartDate = new Date(tempStrSDate);
                let tempStrEDate = recordValuesToSave[i].endYear + '-' +recordValuesToSave[i].endMonth + '-' + newStartEndDay;
                let tempNewEndDate = new Date(tempStrEDate);
                if(Date.parse(tempNewEndDate) >= Date.parse(today)){
                    showDateError = true;
                }
                else {
                    if(this.template.querySelectorAll('.startEndDateError') !== null){
                        this.template.querySelectorAll('.startEndDateError').forEach(element => element.remove());
                    }
                }
                if(Date.parse(tempNewEndDate) < Date.parse(tempNewStartDate) || Date.parse(tempNewEndDate) === Date.parse(tempNewStartDate)){
                    showfromToError = true;
                }
                else {
                    if(this.template.querySelectorAll('.startEndDateError') !== null){
                        this.template.querySelectorAll('.startEndDateError').forEach(element => element.remove());
                    }
                }
            }
            for(let k = 0; k < recordValuesToSave[i].tcWrapperList.length; k++){
                if(recordValuesToSave[i].tcWrapperList[k].transferCreditCourse === '' || recordValuesToSave[i].tcWrapperList[k].transferCreditCourse === null){
                    tcCourseBlank = true;
                }
                if(recordValuesToSave[i].tcWrapperList[k].transferCreditGrade === '' || recordValuesToSave[i].tcWrapperList[k].transferCreditGrade === null || recordValuesToSave[i].tcWrapperList[k].transferCreditGrade === '0' || recordValuesToSave[i].tcWrapperList[k].transferCreditGrade === 0){
                    tcGradeBlank = true;
                }
                if(recordValuesToSave[i].tcWrapperList[k].courseOutcome === '' || recordValuesToSave[i].tcWrapperList[k].courseOutcome === null){
                    tcCourseOutcome = true;
                }
                if(recordValuesToSave[i].tcWrapperList[k].creditsEarnedMonth === '' || recordValuesToSave[i].tcWrapperList[k].creditsEarnedMonth === null){
                    tcCourseMonth = true;
                }
                if(recordValuesToSave[i].tcWrapperList[k].creditsEarnedYear === '' || recordValuesToSave[i].tcWrapperList[k].creditsEarnedYear === null){
                    tcCourseYear = true;
                }else{
                    // eslint-disable-next-line radix
                    if(parseInt(recordValuesToSave[i].tcWrapperList[k].creditsEarnedYear) > parseInt(yyyy)){
                        tcDateCond = true;
                        // eslint-disable-next-line radix
                    }else if(parseInt(recordValuesToSave[i].tcWrapperList[k].creditsEarnedYear) === parseInt(yyyy)){
                        if(tcCourseMonth === false){
                            let monthVal;
                            if(recordValuesToSave[i].tcWrapperList[k].creditsEarnedMonth === 'January'){
                                monthVal = 1;
                            }else if(recordValuesToSave[i].tcWrapperList[k].creditsEarnedMonth === 'February'){
                                monthVal = 2;
                            }else if(recordValuesToSave[i].tcWrapperList[k].creditsEarnedMonth === 'March'){
                                monthVal = 3;
                            }else if(recordValuesToSave[i].tcWrapperList[k].creditsEarnedMonth === 'April'){
                                monthVal = 4;
                            }else if(recordValuesToSave[i].tcWrapperList[k].creditsEarnedMonth === 'May'){
                                monthVal = 5;
                            }else if(recordValuesToSave[i].tcWrapperList[k].creditsEarnedMonth === 'June'){
                                monthVal = 6;
                            }else if(recordValuesToSave[i].tcWrapperList[k].creditsEarnedMonth === 'July'){
                                monthVal = 7;
                            }else if(recordValuesToSave[i].tcWrapperList[k].creditsEarnedMonth === 'August'){
                                monthVal = 8;
                            }else if(recordValuesToSave[i].tcWrapperList[k].creditsEarnedMonth === 'September'){
                                monthVal = 9;
                            }else if(recordValuesToSave[i].tcWrapperList[k].creditsEarnedMonth === 'October'){
                                monthVal = 10;
                            }else if(recordValuesToSave[i].tcWrapperList[k].creditsEarnedMonth === 'November'){
                                monthVal = 11;
                            }else if(recordValuesToSave[i].tcWrapperList[k].creditsEarnedMonth === 'December'){
                                monthVal = 12;
                            }
                            // eslint-disable-next-line radix
                            if(monthVal > parseInt(mm)){
                                tcDateCond = true;
                            }
                        }
                    }
                }
            }
            if(recordValuesToSave[i].transferCreditsCheckbox){
                for(let j = 0; j < recordValuesToSave[i].assets.length; j++){
                    if(recordValuesToSave[i].assets[j].type === 'Transfer Credit Transcript'){
                        if(recordValuesToSave[i].assets[j].nameOnDoc === ''){
                            showBlankNameError = true;
                        }
                    }
                    if(recordValuesToSave[i].assets[j].type === 'Pre-Med Letter'){
                        if(recordValuesToSave[i].assets[j].nameOnDoc === ''){
                            showBlankNameError = true;
                        }
                    }
                }
            }
        }
        if(this.template.querySelectorAll('.tctName') !== null){
            this.template.querySelectorAll('.tctName').forEach(elem => {
                if(elem.getAttribute('data-asset-url') === '' ||
                    elem.getAttribute('data-asset-url') === 'true' ||
                    elem.getAttribute('data-asset-url') === null){
                    showTctMissing = true;
                }
            });
        }
        if(this.template.querySelectorAll('.isTranscriptInEnglishCheckbox') !== null){
            this.template.querySelectorAll('.isTranscriptInEnglishCheckbox').forEach(elem => {
                if(elem.checked){
                    let schoolWrapper = getClosest(elem, ".recordFieldsWrapper");
                    if(schoolWrapper.querySelector('.tctTranslationId').getAttribute('data-asset-url') === '' ||
                        schoolWrapper.querySelector('.tctTranslationId').getAttribute('data-asset-url') === 'true' ||
                        schoolWrapper.querySelector('.tctTranslationId').getAttribute('data-asset-url') === null){
                        showTranslationDocMissing = true;
                    }
                }
            });
        }
        if(this.template.querySelectorAll('.pmlName') !== null){
            this.template.querySelectorAll('.pmlName').forEach(elem => {
                if(elem.getAttribute('data-asset-url') === '' ||
                    elem.getAttribute('data-asset-url') === 'true' ||
                    elem.getAttribute('data-asset-url') === null){
                    showPmlLetterMissing = true;
                }
            });
        }
        if(this.template.querySelectorAll('.isPreMedLetterInEnglishCheckbox') !== null){
            this.template.querySelectorAll('.isPreMedLetterInEnglishCheckbox').forEach(elem => {
                if(elem.checked){
                    let schoolWrapper = getClosest(elem, ".recordFieldsWrapper");
                    if(schoolWrapper.querySelector('.pmlTranslationId').getAttribute('data-asset-url') === '' ||
                        schoolWrapper.querySelector('.pmlTranslationId').getAttribute('data-asset-url') === 'true' ||
                        schoolWrapper.querySelector('.pmlTranslationId').getAttribute('data-asset-url') === null){
                        showPmlTranslationDocMissing = true;
                    }
                }
            });
        }
        if(showDateError){
            breakSaveFunc = true;
			showNewDateErrorFunc(this.template);
        }else{
            if(this.template.querySelectorAll('.EndDateError') !== null){
                this.template.querySelectorAll('.EndDateError').forEach(element => element.remove());
            }
        }
        if(showfromToError){
            breakSaveFunc = true;
			showStartEndErrorFunc(this.template);
        }else{
            if(this.template.querySelectorAll('.startEndDateError') !== null){
                this.template.querySelectorAll('.startEndDateError').forEach(element => element.remove());
            }
        }
        if(showAttendedYearsError){
            breakSaveFunc = true;
			showAttendedYearsFunc(this.template);
        }else{
            if(this.template.querySelectorAll('.attendedYearsError') !== null){
                this.template.querySelectorAll('.attendedYearsError').forEach(element => element.remove());
            }
        }
        if(showBlankNameError){
            breakSaveFunc = true;
            this.showBlankNameErrorFunc();
        }else{
            if(this.template.querySelectorAll('.blankNameError') !== null){
                this.template.querySelectorAll('.blankNameError').forEach(element => element.remove());
            }
        }
        if(tcCourseYear){
            breakSaveFunc = true;
            this.showYearBlankError();
        }else{
            if(this.template.querySelectorAll('.blankYearError') !== null){
                this.template.querySelectorAll('.blankYearError').forEach(element => element.remove());
            }
        }
        if(tcDateCond){
            breakSaveFunc = true;
            this.showYearFutureError();
        }else{
            if(this.template.querySelectorAll('.futureYearError') !== null){
                this.template.querySelectorAll('.futureYearError').forEach(element => element.remove());
            }
        }
        if(tcCourseMonth){
            breakSaveFunc = true;
            this.showMonthBlankError();
        }else{
            if(this.template.querySelectorAll('.blankMonthError') !== null){
                this.template.querySelectorAll('.blankMonthError').forEach(element => element.remove());
            }
        }
        if(tcCourseOutcome){
            breakSaveFunc = true;
            this.showOutcomeBlankError();
        }else{
            if(this.template.querySelectorAll('.blankOutcomeError') !== null){
                this.template.querySelectorAll('.blankOutcomeError').forEach(element => element.remove());
            }
        }
        if(tcGradeBlank){
            breakSaveFunc = true;
            this.showGradeBlankError();
        }else{
            if(this.template.querySelectorAll('.blankGradeError') !== null){
                this.template.querySelectorAll('.blankGradeError').forEach(element => element.remove());
            }
        }
        if(tcCourseBlank){
            breakSaveFunc = true;
            this.showCourseBlankError();
        }else{
            if(this.template.querySelectorAll('.blankCourseError') !== null){
                this.template.querySelectorAll('.blankCourseError').forEach(element => element.remove());
            }
        }
        if(showTctMissing){
            breakSaveFunc = true;
            this.showTctMissingError();
        }else{
            if(this.errorMessagesText === 'Missing Transfer Credit Transcript'){
                this.errorMessagesText = '';
            }
        }
        if(showTranslationDocMissing){
            breakSaveFunc = true;
            this.showTranslationDocMissingError();
        }else{
            if(this.template.querySelectorAll('.translationDocMissingError') !== null){
                this.template.querySelectorAll('.translationDocMissingError').forEach(element => element.remove());
            }
        }
        if(showPmlLetterMissing){
            breakSaveFunc = true;
            this.showPmlLetterMissingError();
        }else{
            if(this.errorMessagesText === 'Missing Pre-Med Letter'){
                this.errorMessagesText = '';
            }
        }
        if(showPmlTranslationDocMissing){
            breakSaveFunc = true;
            this.showPmlTranslationDocMissingError();
        }else{
            if(this.template.querySelectorAll('.pmlTranslationDocMissingError') !== null){
                this.template.querySelectorAll('.pmlTranslationDocMissingError').forEach(element => element.remove());
            }
        }
        if(showOtherInstError){
            this.showOtherInstErrorFunc();
            this.hideNextButton = false;
        }
        if(!breakSaveFunc){
            saveOtherInstitutionRecords({
                values: JSON.stringify(recordValuesToSave),
                assetsUrlsList: JSON.stringify(this.assetInsertedList),
                parentCaseId: this.parentCaseId,
                caseId: this.caseId,
                tcsToDelList: JSON.stringify(this.tcsToDel),
                showExamRegActionButton: this.showExamRegActionButton
            }).then(saveresult => {
                this.spinner = false;
                this.tcsToDel = [];
                if(saveresult){
                    yearsAttended({
                        caseId: this.caseId,
                        showExamRegActionButton: this.showExamRegActionButton
                    })
                    .then(resultVal => {
                        if(resultVal){
                            this.showSuccessfulSave();
                            this.savePassedWithoutErrors = true;
                            this.changedSchools = [];
                            this.getOtherInstitutionRecordsFunc(this.showExamRegActionButton);
                            if(this.clickedBtn === 'Next'){
                                if(this.isGraduate){
                                    const selectEvent = new CustomEvent('nextgradevent', {});
                                    this.dispatchEvent(selectEvent);
                                }else{
                                    if(this.showExamRegActionButton){
                                        const selectEvent = new CustomEvent('summaryevent', {detail: ''});
                                        this.dispatchEvent(selectEvent);
                                    }else{
                                        const selectEvent = new CustomEvent('nextrepevent', {});
                                        this.dispatchEvent(selectEvent);
                                    }
                                }
                            }
                            if(this.showSaveAddClicked){
                                this.newRecordAdded = true;
                            }else{
                                this.showAddNew = true;
                                this.showSaveAdd = false;
                            }
                        }else{
                            this.showYearsAttendedError();
                            this.getOtherInstitutionRecordsFunc(this.showExamRegActionButton);
                        }
                    })
                    .catch(error=>{
                        window.console.error('Error: ' + JSON.stringify(error));
                    });
                }
            })
            .catch(error=>{
                this.tcsToDel = [];
                window.console.error('Error: ' + JSON.stringify(error));
            });
        }
        if(breakSaveFunc){
            this.showSaveAddClicked = false;
            this.spinner = false;
            return false;
        }
        return true;
    }
    showBlankNameErrorFunc(){
        if(this.template.querySelectorAll('.blankNameError') !== null){
            this.template.querySelectorAll('.blankNameError').forEach(element => element.remove());
        }
        this.template.querySelectorAll('.tctName').forEach(element => {
            if(element.value === ''){
                let elem = document.createElement("div");
                elem.id = 'blankNameError';
                elem.setAttribute('class', 'blankNameError');
                elem.textContent = 'Please enter your name exactly as it appears on the document.';
                elem.style = 'color:#ff0000; clear:both;';
                element.classList.add('slds-has-error');
                element.parentNode.insertBefore(elem, element.nextSibling);
                this.hideNextButton = false;
            }else{
                if(element.classList.contains('slds-has-error')){
                    element.classList.remove('slds-has-error');
                }
            }
        });
        this.template.querySelectorAll('.pmlName').forEach(element => {
            if(element.value === ''){
                let elem = document.createElement("div");
                elem.id = 'blankNameError';
                elem.setAttribute('class', 'blankNameError');
                elem.textContent = 'Please enter your name exactly as it appears on the document.';
                elem.style = 'color:#ff0000; clear:both;';
                element.classList.add('slds-has-error');
                element.parentNode.insertBefore(elem, element.nextSibling);
                this.hideNextButton = false;
            }else{
                if(element.classList.contains('slds-has-error')){
                    element.classList.remove('slds-has-error');
                }
            }
        });
        if(this.template.querySelector('.slds-has-error') !== null){
            this.template.querySelector('.slds-has-error').scrollIntoView();
        }
    }
    showTctMissingError(){
        if(this.template.querySelectorAll('.tctMissingError') !== null){
            this.template.querySelectorAll('.tctMissingError').forEach(element => element.remove());
        }
        if(this.template.querySelectorAll('.tctName') !== null){
            this.template.querySelectorAll('.tctName').forEach(elem => {
                if(elem.getAttribute('data-asset-url') === '' ||
                    elem.getAttribute('data-asset-url') === 'true' ||
                    elem.getAttribute('data-asset-url') === null){
                    let errorElem = document.createElement("div");
                    errorElem.id = 'tctMissingError';
                    errorElem.setAttribute('class', 'tctMissingError');
                    errorElem.textContent = 'Please upload your Transcript.';
                    errorElem.style = 'color:#ff0000; clear:both;';
                    if(elem.parentNode.parentNode.querySelectorAll('.tctMissingError').length === 0){
                        elem.parentNode.parentNode.querySelector('.transferCreditTranscriptUpload').appendChild(errorElem);
                    }
                    this.hideNextButton = false;
                }
            });
        }
        this.template.querySelector('.tctMissingError').scrollIntoView();
    }
    showTranslationDocMissingError(){
        if(this.template.querySelectorAll('.translationDocMissingError') !== null){
            this.template.querySelectorAll('.translationDocMissingError').forEach(element => element.remove());
        }
        if(this.template.querySelectorAll('.tctTranslationId') !== null){
            this.template.querySelectorAll('.tctTranslationId').forEach(elem => {
                if(elem.getAttribute('data-asset-url') === '' ||
                    elem.getAttribute('data-asset-url') === 'true' ||
                    elem.getAttribute('data-asset-url') === null){
                    let errorElem = document.createElement("div");
                    errorElem.id = 'translationDocMissingError';
                    errorElem.setAttribute('class', 'translationDocMissingError');
                    errorElem.textContent = 'Please upload the Transfer Credit Transcript Translation Document';
                    errorElem.style = 'color:#ff0000; clear:both;';
                    if(elem.parentNode.querySelectorAll('.translationDocMissingError').length === 0){
                        elem.parentNode.querySelector('.tctTranslationDoc').appendChild(errorElem);
                    }
                    this.hideNextButton = false;
                }
            });
        }
        this.template.querySelector('.translationDocMissingError').scrollIntoView();
    }
    showPmlLetterMissingError(){
        if(this.template.querySelectorAll('.pmlMissingError') !== null){
            this.template.querySelectorAll('.pmlMissingError').forEach(element => element.remove());
        }
        if(this.template.querySelectorAll('.pmlName') !== null){
            this.template.querySelectorAll('.pmlName').forEach(elem => {
                if(elem.getAttribute('data-asset-url') === '' ||
                    elem.getAttribute('data-asset-url') === 'true' ||
                    elem.getAttribute('data-asset-url') === null){
                    let errorElem = document.createElement("div");
                    errorElem.id = 'pmlMissingError';
                    errorElem.setAttribute('class', 'pmlMissingError');
                    errorElem.textContent = 'Please upload your Pre-medical letter.';
                    errorElem.style = 'color:#ff0000; clear:both;';
                    if(elem.parentNode.parentNode.querySelectorAll('.pmlMissingError').length === 0){
                        elem.parentNode.parentNode.querySelector('.preMedLetterUpload').appendChild(errorElem);
                    }
                    this.hideNextButton = false;
                }
            });
        }
        this.template.querySelector('.pmlMissingError').scrollIntoView();
    }
    showPmlTranslationDocMissingError(){
        if(this.template.querySelectorAll('.pmlTranslationDocMissingError') !== null){
            this.template.querySelectorAll('.pmlTranslationDocMissingError').forEach(element => element.remove());
        }
        if(this.template.querySelectorAll('.pmlTranslationId') !== null){
            this.template.querySelectorAll('.pmlTranslationId').forEach(elem => {
                if(elem.getAttribute('data-asset-url') === '' ||
                    elem.getAttribute('data-asset-url') === 'true' ||
                    elem.getAttribute('data-asset-url') === null){
                    let errorElem = document.createElement("div");
                    errorElem.id = 'pmlTranslationDocMissingError';
                    errorElem.setAttribute('class', 'pmlTranslationDocMissingError');
                    errorElem.textContent = 'Please upload your Pre-medical letter Translation Document';
                    errorElem.style = 'color:#ff0000; clear:both;';
                    if(elem.parentNode.querySelectorAll('.pmlTranslationDocMissingError').length === 0){
                        elem.parentNode.querySelector('.pmlTranslationDoc').appendChild(errorElem);
                    }
                    this.hideNextButton = false;
                }
            });
        }
        this.template.querySelector('.pmlTranslationDocMissingError').scrollIntoView();
    }
    showCourseBlankError(){
        if(this.template.querySelectorAll('.blankCourseError') !== null){
            this.template.querySelectorAll('.blankCourseError').forEach(element => element.remove());
        }
        this.template.querySelectorAll('.transferCreditCourseInput').forEach(element => {
            if(element.value === ''){
                let elem = document.createElement("div");
                elem.id = 'blankCourseError';
                elem.setAttribute('class', 'blankCourseError');
                elem.textContent = 'Please enter a course title.';
                elem.style = 'color:#ff0000; clear:both;';
                element.classList.add('slds-has-error');
                let wrapperTable = getClosest(element, ".tcTableWrapper");
                if(wrapperTable.querySelectorAll('.blankCourseError').length === 0){
                    wrapperTable.insertBefore(elem, wrapperTable.firstChild);
                }
                this.hideNextButton = false;
            }else{
                if(element.classList.contains('slds-has-error')){
                    element.classList.remove('slds-has-error');
                }
            }
        });
        if(this.template.querySelector('.slds-has-error') !== null){
            this.template.querySelector('.slds-has-error').scrollIntoView();
        }
    }
    showGradeBlankError(){
        if(this.template.querySelectorAll('.blankGradeError') !== null){
            this.template.querySelectorAll('.blankGradeError').forEach(element => element.remove());
        }
        this.template.querySelectorAll('.transferCreditGradeInput').forEach(element => {
            if(element.value === '' || element.value === '0' || element.getAttribute("data-normalizedGradeInput") === '0'){
                let elem = document.createElement("div");
                elem.id = 'blankGradeError';
                elem.setAttribute('class', 'blankGradeError');
                elem.textContent = 'Please enter a valid number of credits earned.';
                elem.style = 'color:#ff0000; clear:both;';
                element.classList.add('slds-has-error');
                let wrapperTable = getClosest(element, ".tcTableWrapper");
                if(wrapperTable.querySelectorAll('.blankGradeError').length === 0){
                    wrapperTable.insertBefore(elem, wrapperTable.firstChild);
                }
                this.hideNextButton = false;
            }else{
                if(element.classList.contains('slds-has-error')){
                    element.classList.remove('slds-has-error');
                }
            }
        });
        if(this.template.querySelector('.slds-has-error') !== null){
            this.template.querySelector('.slds-has-error').scrollIntoView();
        }
    }
    showOutcomeBlankError(){
        if(this.template.querySelectorAll('.blankOutcomeError') !== null){
            this.template.querySelectorAll('.blankOutcomeError').forEach(element => element.remove());
        }
        this.template.querySelectorAll('.transferCreditCourseOutcomeInput').forEach(element => {
            if(element.value === ''){
                let elem = document.createElement("div");
                elem.id = 'blankOutcomeError';
                elem.setAttribute('class', 'blankOutcomeError');
                elem.textContent = 'Please select the outcome of the course.';
                elem.style = 'color:#ff0000; clear:both;';
                element.classList.add('slds-has-error');
                let wrapperTable = getClosest(element, ".tcTableWrapper");
                if(wrapperTable.querySelectorAll('.blankOutcomeError').length === 0){
                    wrapperTable.insertBefore(elem, wrapperTable.firstChild);
                }
                this.hideNextButton = false;
            }else{
                if(element.classList.contains('slds-has-error')){
                    element.classList.remove('slds-has-error');
                }
            }
        });
        if(this.template.querySelector('.slds-has-error') !== null){
            this.template.querySelector('.slds-has-error').scrollIntoView();
        }
    }
    showMonthBlankError(){
        if(this.template.querySelectorAll('.blankMonthError') !== null){
            this.template.querySelectorAll('.blankMonthError').forEach(element => element.remove());
        }
        this.template.querySelectorAll('.monthPicklist').forEach(element => {
            if(element.value === ''){
                let elem = document.createElement("div");
                elem.id = 'blankMonthError';
                elem.setAttribute('class', 'blankMonthError');
                elem.textContent = 'Please enter a month.';
                elem.style = 'color:#ff0000; clear:both;';
                element.classList.add('slds-has-error');
                let wrapperTable = getClosest(element, ".tcTableWrapper");
                if(wrapperTable.querySelectorAll('.blankMonthError').length === 0){
                    wrapperTable.insertBefore(elem, wrapperTable.firstChild);
                }
                this.hideNextButton = false;
            }else{
                if(element.classList.contains('slds-has-error')){
                    element.classList.remove('slds-has-error');
                }
            }
        });
        if(this.template.querySelector('.slds-has-error') !== null){
            this.template.querySelector('.slds-has-error').scrollIntoView();
        }
    }
    showYearBlankError(){
        if(this.template.querySelectorAll('.blankYearError') !== null){
            this.template.querySelectorAll('.blankYearError').forEach(element => element.remove());
        }
        if(this.template.querySelectorAll('.futureYearError') !== null){
            this.template.querySelectorAll('.futureYearError').forEach(element => element.remove());
        }
        this.template.querySelectorAll('.creditEarnedYearInput').forEach(element => {
            if(element.value === ''){
                let elem = document.createElement("div");
                elem.id = 'blankYearError';
                elem.setAttribute('class', 'blankYearError');
                elem.textContent = 'Please enter a year.';
                elem.style = 'color:#ff0000; clear:both;';
                element.classList.add('slds-has-error');
                let wrapperTable = getClosest(element, ".tcTableWrapper");
                if(wrapperTable.querySelectorAll('.blankYearError').length === 0){
                    wrapperTable.insertBefore(elem, wrapperTable.firstChild);
                }
                this.hideNextButton = false;
            }else{
                if(element.classList.contains('slds-has-error')){
                    element.classList.remove('slds-has-error');
                }
            }
        });
        if(this.template.querySelector('.slds-has-error') !== null){
            this.template.querySelector('.slds-has-error').scrollIntoView();
        }
    }
    showYearFutureError(){
        if(this.template.querySelectorAll('.blankYearError') !== null){
            this.template.querySelectorAll('.blankYearError').forEach(element => element.remove());
        }
        if(this.template.querySelectorAll('.futureYearError') !== null){
            this.template.querySelectorAll('.futureYearError').forEach(element => element.remove());
        }
        let today = new Date();
        let mon = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        let year = today.getFullYear();
        let yearnum = 0;
        this.template.querySelectorAll('.creditEarnedYearInput').forEach(element => {
            yearnum++;
            let futuredateerror = false;
            // eslint-disable-next-line radix
            if(element.value !== '' && parseInt(element.value) > parseInt(year)){
                futuredateerror = true;
                // eslint-disable-next-line radix
            }else if(element.value !== '' && parseInt(element.value) === parseInt(year)){
                let monthnum = 0;
                this.template.querySelectorAll('.monthPicklist').forEach(element1 => {
                    monthnum++;
                    if(yearnum === monthnum){
                        let monthVal1;
                        if(element1.value === 'January'){
                            monthVal1 = 1;
                        }else if(element1.value === 'February'){
                            monthVal1 = 2;
                        }else if(element1.value === 'March'){
                            monthVal1 = 3;
                        }else if(element1.value === 'April'){
                            monthVal1 = 4;
                        }else if(element1.value === 'May'){
                            monthVal1 = 5;
                        }else if(element1.value === 'June'){
                            monthVal1 = 6;
                        }else if(element1.value === 'July'){
                            monthVal1 = 7;
                        }else if(element1.value === 'August'){
                            monthVal1 = 8;
                        }else if(element1.value === 'September'){
                            monthVal1 = 9;
                        }else if(element1.value === 'October'){
                            monthVal1 = 10;
                        }else if(element1.value === 'November'){
                            monthVal1 = 11;
                        }else if(element1.value === 'December'){
                            monthVal1 = 12;
                        }
                        // eslint-disable-next-line radix
                        if(monthVal1 > parseInt(mon)){
                            futuredateerror = true;
                        }
                    }
                });
            }
            if(futuredateerror){
                let elem = document.createElement("div");
                elem.id = 'futureYearError';
                elem.setAttribute('class', 'futureYearError');
                elem.textContent = 'Credits earned date should not be in future';
                elem.style = 'color:#ff0000; clear:both;';
                element.classList.add('slds-has-error');
                element.parentNode.insertBefore(elem, element.nextSibling);
                this.hideNextButton = false;
            }else{
                if(element.classList.contains('slds-has-error')){
                    element.classList.remove('slds-has-error');
                }
            }
        });
        if(this.template.querySelector('.slds-has-error') !== null){
            this.template.querySelector('.slds-has-error').scrollIntoView();
        }
    }
    showSuccessfulSave(){
        this.template.querySelector(".notificationMessage").textContent = '';
        let elem = document.createElement("span");
        elem.id = 'successDiv';
        elem.setAttribute('class', 'successDiv');
        elem.textContent = 'Data Successfully Saved';
        elem.style = 'color:#4BB543;font-size: 13px;';
        this.template.querySelector(".notificationMessage").appendChild(elem);
        window.scrollTo(0, 0);
    }
    showYearsAttendedError(){
        this.template.querySelector(".notificationMessage").textContent = '';
        let elem = document.createElement("span");
        elem.id = 'errorDiv';
        elem.setAttribute('class', 'errorDiv');
        elem.textContent = CurriculumYearsError;
        elem.style = 'color:#ff0000; clear:both;';
        this.template.querySelector(".notificationMessage").appendChild(elem);
        this.hideNextButton = false;
        window.scrollTo(0, 0);
    }
    prevButton(event){
        this.assetMarkForDeletion();
        event.preventDefault();
        const selectEvent = new CustomEvent('previousevent', {detail:{caserecordid:this.caseRecordId}});
        this.dispatchEvent(selectEvent);
    }
    nextButton(event){
        this.hideNextButton = true;
        event.preventDefault();
        clearErrorMessage(this);
        this.clickedBtn = 'Next';
        if(this.transferCreditsCheckboxMain == true || this.showOtherInstiEditSection == true){
            if(this.showExamRegActionButton == true && this.showOtherInstiEditSection == false){
                this.manageRedirection();
            }else{
                this.saveRecords();
            }
        }else{
            yearsAttended({
                caseId: this.caseId,
                showExamRegActionButton: this.showExamRegActionButton
            })
            .then(resultVal => {
                if(resultVal){
                    deleteOtherInstitutions({
                        contactId: this.contactId,
                        parentCaseId: this.parentCaseId,
                        caseId: this.caseId
                    }).then(delresult => {
                        if(delresult === 'true'){
                            this.manageRedirection();
                        }else{
                            window.console.error('Delete Error:', delresult);
                        }
                    }).catch(error=>{
                        window.console.error('Error: ' + JSON.stringify(error));
                    });
                }else{
                    this.showYearsAttendedError();
                }
            })
            .catch(error=>{
                window.console.error('Error: ' + JSON.stringify(error));
            });
            // Change status as Mark for Deletion for unwanted Assets //delete unsaved TCT assets
            this.assetMarkForDeletion();
        }
    }
    manageRedirection(){
        if(this.isGraduate){
            const selectEvent = new CustomEvent('nextgradevent', {});
            this.dispatchEvent(selectEvent);
        }else{
            if(this.showExamRegActionButton){
                const selectEvent = new CustomEvent('summaryevent', {detail: ''});
                this.dispatchEvent(selectEvent);
            }else{
                const selectEvent = new CustomEvent('nextrepevent', {});
                this.dispatchEvent(selectEvent);
            }
        }
    }
    saveButton(event){
        event.preventDefault();
        clearErrorMessage(this);
        this.clickedBtn = 'Save';
        this.saveRecords();
    }
    cancelButton(event){
        //delete unsaved TCT assets
        this.assetMarkForDeletion();
        event.preventDefault();
        const selectEvent = new CustomEvent('cancelevent', {});
        this.dispatchEvent(selectEvent);
    }
    discardButton(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('discardevent', {});
        this.dispatchEvent(selectEvent);
    }
    validateTransferCreditGradeInput(event){
        if(event.which === 69 || event.which === 109 || event.which === 189){
            event.preventDefault();
        }
        if(event.which === 110 && event.target.value.includes(".")){
            event.preventDefault();
        }
        if(event.target.value.includes(".")){
            if(event.target.value.length === 5 && event.which !== 8 && event.which !== 9){
                event.preventDefault();
            }
        }else{
            if(event.target.value.length === 2 && event.which !== 8 && event.which !== 9 && event.which !== 110 && event.which !== 190){
                event.preventDefault();
            }
        }
    }
    handleTctNameChange(event){
        let index = getCurrentSchoolIndex(event.target, this.recordsList);
        this.recordsList[index].tctName = event.target.value;
    }
    handlePmlNameChange(event){
        let index = getCurrentSchoolIndex(event.target, this.recordsList);
        this.recordsList[index].pmlName = event.target.value;
    }
    deleteNameAsset(event){
        let index = getCurrentSchoolIndex(event.target, this.recordsList);
        this.recordsList[index].tctNameAssetIdUpdated = false;
        let currentNameDocAssetUrl = getClosest(event.target, '.recordFieldsWrapper').querySelector(".tctNameDocumenatationSectionUploadId").getAttribute('data-asset-url');
        if(currentNameDocAssetUrl){
            markAssetsForDeletionFromUrl({azureUrl : currentNameDocAssetUrl});
            getClosest(event.target, '.recordFieldsWrapper').querySelector(".tctNameDocumenatationSectionUploadId").setAttribute("data-asset-url", '');
        }
        let tempPayload = JSON.parse(this.recordsList[index].tctNamePayload);
        tempPayload.azureUrl = null;
        this.recordsList[index].tctNamePayload = JSON.stringify(tempPayload);
        this.recordsList[index].tctNameAssetIdUpdated = true;
        this.recordsList[index].tctNameDocUrl = '';
    }
    deletePmlNameAsset(event){
        let index = getCurrentSchoolIndex(event.target, this.recordsList);
        this.recordsList[index].pmlNameAssetIdUpdated = false;
        let currentNameDocAssetUrl = getClosest(event.target, '.recordFieldsWrapper').querySelector(".pmlNameSectionUploadId").getAttribute('data-asset-url');
        if(currentNameDocAssetUrl){
            markAssetsForDeletionFromUrl({azureUrl : currentNameDocAssetUrl});
            getClosest(event.target, '.recordFieldsWrapper').querySelector(".pmlNameSectionUploadId").setAttribute("data-asset-url", '');
        }
        let tempPayload = JSON.parse(this.recordsList[index].pmlNamePayload);
        tempPayload.azureUrl = null;
        this.recordsList[index].pmlNamePayload = JSON.stringify(tempPayload);
        this.recordsList[index].pmlNameAssetIdUpdated = true;
        this.recordsList[index].pmlNameDocumenatationUrl = '';
    }
    handleChangeForSearch(event){
        this.handleRendering = false;
        let eventValue = event.target.value;
        let closestElem = getClosest(event.target, '.recordFieldsWrapper');
        clearTimeout(this.timeout);
        this.timeout = setTimeout(() =>{
            const searchKey = eventValue;
            this.entityRecordsList = [];
            this.records = [];
            this.recordsExistSubmitButton = false;
            searchOtherInstitutions({
                searchKey: searchKey
            }).then(result =>{
                if(result){
                    this.records = result;
                    this.entityRecdsList = [];
                    if(this.records.length > 0){
                        for(let i=0; i < this.records.length; i++){
                            let rec = this.records[i];
                            this.entityRecdsList.push(rec);
                            this.entityRecdsList[i].Name = rec[this.searchfield];
                            this.entityRecdsList[i].Id = this.records[i].Id;
                        }
                        this.entityRecordsList = this.entityRecdsList;
                    }else{
                        this.entityRecordsList = [];
                        closestElem.querySelector('.otherSchoolRecord').setAttribute("data-otherschool-id", '');
                    }                    
                }else{
                    this.entityRecordsList = [];                    
                }
                if(searchKey){
                    this.recordsExistSubmitButton = true;
                }
                if(!searchKey){
                    this.entityRecordsList = [];
                }
            }).catch(error =>{
                this.records = undefined;
            });
        }, 500);
    }
    clearSearchBox(){
        this.entityRecordsList = [];
        this.recordsExistSubmitButton = false;
    }
    handleSelect(event){
        this.handleRendering = true;
        this.entityRecordsList = [];
        this.recordsExistSubmitButton = false;
        this.selectedRec = event.detail;
        this.selectedEntityId = this.selectedRec.Id;
        let closestElem = getClosest(event.target, '.recordFieldsWrapper');
        let currentSchoolIndex = parseInt(closestElem.getAttribute('data-record-index'), 10);
        closestElem.querySelector('.otherSchoolRecord').setAttribute("data-otherschool-id", this.selectedEntityId);
        if(closestElem.querySelectorAll('.otherInstBlankError') !== null){
            closestElem.querySelectorAll('.otherInstBlankError').forEach(element => element.remove());
        }
        let currentChangedSchoolDetails = {
            index: currentSchoolIndex,
            schoolInput: this.selectedRec.Name,
            schoolId: this.selectedRec.Id
        }
        var indexPresent = false;
        for(let j in this.changedSchools){
            if(currentChangedSchoolDetails.index === this.changedSchools[j].index){
                this.changedSchools[j].schoolInput = currentChangedSchoolDetails.schoolInput;
                this.changedSchools[j].schoolId = currentChangedSchoolDetails.schoolId;
                indexPresent = true;
            }
        }
        if(this.changedSchools.length === 0 || indexPresent === false){
            this.changedSchools.push(currentChangedSchoolDetails);
        }
    }
    handleCreateNewAcc(event){
        this.entityRecordsList = [];
        this.recordsExistSubmitButton = false;
        this.selectedRec = event.detail;
        this.selectedEntityId = this.selectedRec.Id;
        let closestElem = getClosest(event.target, '.recordFieldsWrapper');
        let currentSchoolIndex = parseInt(closestElem.getAttribute('data-record-index'), 10);
        let currentChangedSchoolDetails = {
            index: currentSchoolIndex,
            schoolInput: this.selectedRec.Name,
            schoolId: this.selectedRec.Id
        }
        var indexPresent = false;
        for(let j in this.changedSchools){
            if(currentChangedSchoolDetails.index === this.changedSchools[j].index){
                this.changedSchools[j].schoolInput = currentChangedSchoolDetails.schoolInput;
                this.changedSchools[j].schoolId = currentChangedSchoolDetails.schoolId;
                indexPresent = true;
            }
        }
        if(this.changedSchools.length === 0 || indexPresent === false){
            this.changedSchools.push(currentChangedSchoolDetails);
        }
        if(this.selectedEntityId){
            const successevt = new ShowToastEvent({
                title: "Success",
                message: 'Entity has been added',
                variant: "Success"
                });
            this.dispatchEvent(successevt);
        }
    }
}