import {LightningElement, track, wire, api} from 'lwc';
import {getPicklistValues, getObjectInfo} from 'lightning/uiObjectInfoApi';
import getSchoolRecords from '@salesforce/apex/AppForCertController.getOtherMedicalSchoolRecords';
import getOtherMedSchoolRecords from '@salesforce/apex/AppForCertController.getOtherMedSchoolRecords';
import saveOtherMedicalSchools from '@salesforce/apex/AppForCertController.saveOtherMedicalSchools';
import getContactId from '@salesforce/apex/AppForCertController.getContactId';
import getCaseId from '@salesforce/apex/AppForCertController.getCaseId';
import getContactName from '@salesforce/apex/AppForCertController.getContactName';
import deleteOrphanedAssets from '@salesforce/apex/AppForCertController.deleteOrphanedAssets';
import deleteUncheckedTransferCreditAndAsset from '@salesforce/apex/AppForCertController.deleteUncheckedTransferCreditAndAsset';
import getContactAssociationOrStaging from "@salesforce/apex/AppForCertController.getContactAssociationOrStaging";
import getAssetsAndDocuments from '@salesforce/apex/AppForCertController.getAssetsAndDocuments';
import getAssetsAndDocumentsExamReg from '@salesforce/apex/ExamRegistrationController.getAssetsAndDocuments';
import CONTACT_ASSOCIATION_TYPE_STAGING_OBJECT from '@salesforce/schema/Contact_Association_Type_Staging__c';
import GRADUATION_MONTH_FIELD from '@salesforce/schema/Contact_Association_Type_Staging__c.Graduation_Month__c';
//code added by Shailaja. Date Format stories.
import START_MONTH_FIELD from '@salesforce/schema/Contact_Association_Type_Staging__c.Start_Month__c';
import END_MONTH_FIELD from '@salesforce/schema/Contact_Association_Type_Staging__c.End_Month__c';
import endDateGreaterThanStartDate from '@salesforce/label/c.End_date_always_greater_than_Start_date';
import startDateAndEndDateNotSame from '@salesforce/label/c.Start_date_and_End_date_should_not_be_same'
//code added by Chinmay. PDFTron Retrofit
import markAssetsForDeletion from '@salesforce/apex/AppForCertController.markAssetsForDeletion';
import markAssetsForDeletionWithUrlList from '@salesforce/apex/AppForCertController.markAssetsForDeletionFromUrls';
import markTctAssetsForDeletion from '@salesforce/apex/AppForCertController.markTctAssetsForDeletion';
import checkAppForCertStatus from '@salesforce/apex/AppForCertHelper.checkAppForCertStatus';
import deleteCATRecAndAssets from '@salesforce/apex/AppForCertHelper.deleteCATRecAndAssets';
import markAssetsForDeletionFromUrl from '@salesforce/apex/AppForCertHelper.markAssetsForDeletionFromUrl';
import updateCATDeletedOnResubmission from '@salesforce/apex/AppForCertHelper.updateCATDeletedOnResubmission';
import {getClosest, getCurrentSchoolIndex, arrayEquals, emptyRecordsListHelper, getNewRecordsLists, getNewChangedSchools, 
    updatedChangedSchools, markAssetsForDeletionWithUrlHelper, emptyMedChangeSchoolObj, removeTransferCreditsErrors, 
    clearTransferCreditsFields, updateRecordsListUncheckedTC, hideTransferCreditSection, sectionsRenderer,
    tempTctPayloadHelper, tempTctTranslationPayloadHelper, tempNameDocPayloadHelper, deleteUncheckedTCAsset, showOtherMedSchoolErrorFunc} from './otherMedSchoolHelper.js';
import { refreshApex } from '@salesforce/apex';
import getRecTypeId from '@salesforce/apex/GenericUtilities.getRecordTypeIdByDevName';
import FROM_YEAR from '@salesforce/schema/Contact_Association_Type__c.Personal_Family_from_year__c';
export default class OtherMedSchool extends LightningElement {
    @api uploadFileCheck = false;
    @track recordsList = [];
    @track recordsListAfterDelete = [];
    @track recordsListExamRegReadOnly = [];
    @track assetInsertedList = [];
    @track assetsList = [];
    @track tcsToDel = [];
    @track wiredParameters = {
        error: '',
        data: null
    };
    @track clickedBtn;
    @track tctNameCond = false;
    @track tctTransCond = false;
    @track tctTransNameCond = false;
    @track showOtMedFile = false;
    @track changedSchools = {};
    @track objectType;
    @api contactId;
    @api caseId;
    @api contactAssociationTypeStagingId;
    @track showError = false;
    @track errorMessagesText = '';
    @track successMessageText = '';
    //Added by Ajith
    @track showTcFields = false;
    @track deleteOtherSchoolId;
    @track eventDataOtherSchool;
    initialized = false;
    refreshCase;
    refreshContact;
    refreshContactAssociationType;
    newRecordAdded = false;
    @track contactName;
    @track monthPicklistOptions = [];
    @api showExamRegActionButton;
    @track showOtherMedicalDetailSection = true;
    @track spinner = false;
    //Code added by Shailaja. Date Format stories. User Story
    @track endMonth = '';
    @track startMonth = '';
    @track startYear = '';
    @track endYear = '';
    @track startMonthPicklistOptions = [];
    @track endMonthPicklistOptions = [];
    @track validSchoolRecords;
    validSchoolRecordIds = [];
    @track maxsize = 10;
    @track assetIdsCollection = [];
    @track assetUrlsCollection = [];
    @track mandateUploadNewDoc = false;
    @track upload = true;
    @track markedAssetsForDeletion = false;
    @track showDeleteSchoolOption = false;
    @track emptyRecordsList = emptyRecordsListHelper();
    @track deleteSchoolFlag = false;
    @track refreshApexFlag = true;
    @track recordListLoaded = false;
    @track showReadOnlySection = false;
    @track optionsYears = [];
    @track rejOrCancel;
    recordTypeDevName = 'Degree_Medical_School';
    get options(){
        return [{
            label: 'Pass',
            value: 'Pass'
        }, {
            label: 'Fail',
            value: 'Fail'
        }, ];
    }
    constructor(){
        super();
        this.getContactAssocObjName();
    }
    getContactAssocObjName(){
        // Getting Object Id and Object Name
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
    @wire(getSchoolRecords) schoolRecordValues({
        error,
        data
    }){
        if(data){
            this.validSchoolRecords = data;
            for(let schoolRecord of data){
                this.validSchoolRecordIds.push(schoolRecord.Id);
            }
        } else if(error){
            window.console.error('Error: ' + JSON.stringify(error));
        }
    }
    // object info using wire service
    @wire(getObjectInfo, {
        objectApiName: CONTACT_ASSOCIATION_TYPE_STAGING_OBJECT
    })
    objectInfo;
    @wire(getPicklistValues, {
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
    //Code added by Shailaja. Date format stories. 9/30/2020
    // object info using wire service
    @wire(getPicklistValues, {
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
    @wire(getPicklistValues, {
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
    getOtherMedSchoolRecords(){
        checkAppForCertStatus({recordTypeName: 'Medical_School'})
        .then(result => {
            this.mandateUploadNewDoc = result;
            getOtherMedSchoolRecords({showExamRegActionButton: this.showExamRegActionButton})
            .then(valueData => {
                this.recordsList = [];
                this.recordsListExamRegReadOnly = [];
                // Show/Hide the section as READ ONLY or EDITABLE based on the App For Cert/Exam Reg
                if(valueData){
                    // If App For Cert, valueData.length should be 2. 
                    // 1 > Object -> Contact Association Type Records | Record Type -> Medical_School - always null
                    // 2 > Object -> Contact Association Type Staging Records | Record Type -> Medical_School
                    // If Exam Reg, valueData.length should be 2. 
                    // 1 > Object -> Contact Association Type Records | Record Type -> Medical_School
                    // 2 > Object -> Contact Association Type Staging Records | Record Type -> Exam_Registration_Medical_School 
                    if(valueData.length > 0){
                        // Show/Hide the section as READ ONLY or EDITABLE based on the App For Cert/Exam Reg
                        if(valueData[0].otherSchoolWrapperList !== undefined){
                            this.showReadOnlySection = true;
                        }
                        if((this.showReadOnlySection === true || this.showExamRegActionButton === true) && (valueData[0].otherSchoolWrapperList === undefined || valueData[1].otherSchoolWrapperList !== undefined)){
                            this.showOtherMedicalDetailSection = true;
                        }else if((this.showReadOnlySection === true || this.showExamRegActionButton === true) && (valueData[0].otherSchoolWrapperList !== undefined && valueData[1].otherSchoolWrapperList === undefined)){
                            this.showOtherMedicalDetailSection = false;
                        }                       
                        if(valueData[0].otherSchoolWrapperList !== undefined || valueData[1].otherSchoolWrapperList !== undefined){               
                            let count = 0;
                            // eslint-disable-next-line guard-for-in
                            for(let keymain in valueData){
                                let recordData = valueData[keymain].otherSchoolWrapperList;
                                if(valueData.length > 2 || recordData === undefined)
                                    continue;
                                for(let key in recordData){
                                    let tempTctId = '',
                                        tempTctTranslationId = '',
                                        tempNameDocId = '';
                                    if(recordData.hasOwnProperty(key)){
                                        let recordIdValNew = '';
                                        if(this.showReadOnlySection === true || this.showExamRegActionButton === true){
                                            recordIdValNew = recordData[key].recordIdVal;
                                        }else{
                                            recordIdValNew = recordData[key].objectType === 'Contact_Association_Type__c' ? '' : recordData[key].recordIdVal;                                    
                                        }
                                        let tempRecord = {
                                            sno: count + 1,
                                            recordIdVal: recordIdValNew,
                                            otherSchool: recordData[key].otherSchool,
                                            otherSchoolId: recordData[key].otherSchoolId,
                                            schoolProgram: recordData[key].schoolProgram,
                                            numberOfYearsAttended: recordData[key].numberOfYearsAttended,
                                            studentId: recordData[key].studentId,
                                            Specialty: recordData[key].specialty,
                                            fromDate: recordData[key].fromDate,
                                            endDate: recordData[key].endDate,
                                            //new code added by Shailaja. date format stories
                                            startMonth: recordData[key].startMonth,
                                            startYear: recordData[key].startYear,
                                            endMonth: recordData[key].endMonth,
                                            endYear: recordData[key].endYear,
                                            transferCreditsCheckbox: recordData[key].transferCreditsCheckbox === 'true',
                                            inputOtherSchoolId: 'inputOtherSchool' + String(recordData[key].recordIdVal),
                                            valueListId: 'valueList' + String(recordData[key].recordIdVal)
                                        };
                                        this.startMonth = tempRecord.startMonth;
                                        this.startYear = tempRecord.startYear;
                                        this.endMonth = tempRecord.endMonth;
                                        this.endYear = tempRecord.endYear;
                                        tempRecord.tcWrapperList = [];
                                        if(recordData[key].hasOwnProperty('tcWrapperList')){
                                            for(let i = 0; i < recordData[key].tcWrapperList.length; i++){
                                                let tempTc = {
                                                    tcId: recordData[key].tcWrapperList[i].recordIdVal,
                                                    transferCreditCourse: recordData[key].tcWrapperList[i].transferCreditCourse,
                                                    transferCreditGrade: recordData[key].tcWrapperList[i].transferCreditGrade,
                                                    courseOutcome: recordData[key].tcWrapperList[i].courseOutcome,
                                                    creditsEarnedMonth: recordData[key].tcWrapperList[i].creditsEarnedMonth === undefined ? '' : recordData[key].tcWrapperList[i].creditsEarnedMonth,
                                                    creditsEarnedYear: recordData[key].tcWrapperList[i].creditsEarnedYear === undefined ? '' : recordData[key].tcWrapperList[i].creditsEarnedYear,
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
                                        let tempTctPayload = {
                                            contactId: this.contactId,
                                            parentCaseId: String(this.parentCaseId),
                                            caseId: this.caseId,
                                            catsId: tempRecord.recordIdVal,
                                            documentType: 'Transfer Credit Transcript',
                                            assetName: 'Transfer Credit Transcript',
                                            assetRecordType: 'Credential',
                                            createOrReplace: 'Create',
                                            assetStatus: 'In Progress',
                                            assetCreationRequired: 'true',
                                            assetId: null,
                                            type: 'Transfer Credit Transcript',
                                            key: 'Transfer Credit Transcript Document',
                                            parentKey: '',
                                            createFromPB: 'true'
                                        };
                                        let tctTranslationPayloadJson = {
                                            contactId: String(this.contactId),
                                            parentCaseId: String(this.parentCaseId),
                                            caseId: String(this.caseId),
                                            catsId: tempRecord.recordIdVal,
                                            documentType: 'TCT Translation',
                                            assetName: 'TCT Translation',
                                            assetRecordType: 'Credential',
                                            createOrReplac: 'Create',
                                            assetStatus: 'In Progress',
                                            assetCreationRequired: 'true',
                                            assetId: null,
                                            type: 'Translation',
                                            key: 'Transfer Credit Transcript Translation Document',
                                            parentKey: 'Transfer Credit Transcript Document',
                                            createFromPB: 'true'
                                        };
                                        let nameDocPayloadJson = {
                                            contactId: String(this.contactId),
                                            parentCaseId: String(this.parentCaseId),
                                            caseId: String(this.caseId),
                                            catsId: tempRecord.recordIdVal,
                                            documentType: 'Name Document',
                                            assetName: 'Name Document',
                                            assetRecordType: 'Identity',
                                            createOrReplace: 'Create',
                                            assetStatus: 'In Progress',
                                            assetCreationRequired: 'true',
                                            assetId: null,
                                            type: 'Name Document',
                                            key: 'Transfer Credit Transcript Name Document',
                                            parentKey: 'Transfer Credit Transcript Document',
                                            createFromPB: 'true'
                                        };
                                        if(recordData[key].hasOwnProperty('assets')){
                                            //Get the Assets with files on load of page on FED
                                            this.otherMedicalSchoolRecId = recordData[key].recordIdVal;
                                            if(this.showExamRegActionButton === true){
                                                getAssetsAndDocumentsExamReg({recId: this.otherMedicalSchoolRecId})
                                                .then(result => {
                                                    if(result){
                                                        this.assetsList = result;
                                                        if(this.assetsList.tctNameDiff === 'Yes' && this.assetsList.tctNameDoc !== ''){
                                                            this.tctNameCond = true;
                                                        }
                                                        if(this.assetsList.tctTrans === 'Yes' && this.assetsList.tctTransFile !== ''){
                                                            this.tctTransCond = true;
                                                        }
                                                        if(this.assetsList.tctTransNameDiff === 'Yes' && this.assetsList.tctTransNameDoc !== ''){
                                                            this.tctTransNameCond = true;
                                                        }
                                                        if(this.assetsList.tctFile !== ''){
                                                            this.showOtMedFile = true;
                                                        }
                                                    }
                                                })
                                                .catch(error => {
                                                    window.console.error('Error: ' + JSON.stringify(error) + error);
                                                })
                                            } else{
                                                getAssetsAndDocuments({recId: this.otherMedicalSchoolRecId})
                                                .then(result => {
                                                    if(result){
                                                        this.assetsList = result;
                                                        if(this.assetsList.tctNameDiff === 'Yes' && this.assetsList.tctNameDoc !== ''){
                                                            this.tctNameCond = true;
                                                        }
                                                        if(this.assetsList.tctTrans === 'Yes' && this.assetsList.tctTransFile !== ''){
                                                            this.tctTransCond = true;
                                                        }
                                                        if(this.assetsList.tctTransNameDiff === 'Yes' && this.assetsList.tctTransNameDoc !== ''){
                                                            this.tctTransNameCond = true;
                                                        }
                                                        if(this.assetsList.tctFile !== ''){
                                                            this.showOtMedFile = true;
                                                        }
                                                    }
                                                })
                                                .catch(error => {
                                                    window.console.error('Error: ' + JSON.stringify(error));
                                                })
                                            }
                                            for(let i = 0; i < recordData[key].assets.length; i++){
                                                if(recordData[key].caseInternalStatus === 'CV Rejected'){
                                                    this.rejOrCancel = 'Rejected';
                                                }else if(recordData[key].caseInternalStatus === 'Cancelled'){
                                                    this.rejOrCancel = 'Cancelled';
                                                }
                                                if(recordData[key].caseInternalStatus === 'CV Rejected' || recordData[key].caseInternalStatus === 'Cancelled'){
                                                    if(recordData[key].assets[i].type === 'Transfer Credit Transcript'){
                                                        tempTctId = recordData[key].assets[i].recordIdVal;
                                                        tempTctPayload.assetId = null;
                                                        tempRecord.tctUrlRej = recordData[key].assets[i].azureUrl;
                                                        nameDocPayloadJson.parentUrl = recordData[key].assets[i].azureUrl;
                                                        tctTranslationPayloadJson.parentUrl = recordData[key].assets[i].azureUrl;
                                                        if(recordData[key].assets[i].azureUrl){
                                                            this.assetInsertedList.push(recordData[key].assets[i].azureUrl);
                                                            this.assetUrlsCollection.push(recordData[key].assets[i].azureUrl);
                                                        }
                                                        tempRecord.tctPayloadRej = JSON.stringify(tempTctPayload);
                                                        tempRecord.tctAssetIdUpdatedRej = true;
                                                        tempRecord.tctName = '';
                                                    }
                                                    if(recordData[key].assets[i].type === 'Name Document' && recordData[key].assets[i].parentval === 'Transfer Credit Transcript Document'){
                                                        tempNameDocId = recordData[key].assets[i].recordIdVal;
                                                        nameDocPayloadJson.assetId = null;
                                                        tempRecord.nameDocUrlRej = recordData[key].assets[i].azureUrl;
                                                        if(recordData[key].assets[i].azureUrl){
                                                            this.assetInsertedList.push(recordData[key].assets[i].azureUrl);
                                                            this.assetUrlsCollection.push(recordData[key].assets[i].azureUrl);
                                                        }
                                                        tempRecord.tctNamePayloadRej = JSON.stringify(nameDocPayloadJson);
                                                        tempRecord.tctNameAssetIdUpdatedRej = true;
                                                    }
                                                    if(recordData[key].assets[i].type === 'Translation' && recordData[key].assets[i].parentval === 'Transfer Credit Transcript Document'){
                                                        tempRecord.nameOnTranslationDocCheckbox = recordData[key].assets[i].nameOnDocIsDifferent === 'true';
                                                        tempTctTranslationId = recordData[key].assets[i].recordIdVal;
                                                        tempRecord.tctTransUrlRej = recordData[key].assets[i].azureUrl;
                                                        if(recordData[key].assets[i].azureUrl){
                                                            this.assetInsertedList.push(recordData[key].assets[i].azureUrl);
                                                            this.assetUrlsCollection.push(recordData[key].assets[i].azureUrl);
                                                        }
                                                        tctTranslationPayloadJson.assetId = null;
                                                        tempRecord.tctTrnPayloadRej = JSON.stringify(tctTranslationPayloadJson);
                                                        tempRecord.tctTrnAssetIdUpdatedRej = true;
                                                    }
                                                }else{
                                                    if(recordData[key].assets[i].type === 'Transfer Credit Transcript'){
                                                        tempRecord.tctAssetId = recordData[key].assets[i].recordIdVal;
                                                        tempRecord.tctUrl = recordData[key].assets[i].azureUrl;
                                                        tempTctId = tempRecord.tctAssetId;
                                                        tempTctPayload.assetId = null;
                                                        this.assetIdsCollection.push(String(tempTctId));
                                                        if(recordData[key].assets[i].azureUrl){
                                                            this.assetInsertedList.push(recordData[key].assets[i].azureUrl);
                                                            this.assetUrlsCollection.push(recordData[key].assets[i].azureUrl);
                                                        }
                                                        tempRecord.nameOnTranscriptCheckbox = recordData[key].assets[i].nameOnDocIsDifferent === 'true';
                                                        tempRecord.isTranscriptInEnglishCheckbox = recordData[key].assets[i].docNotInEnglish === 'true';
                                                        if(recordData[key].assets[i].nameOnDoc !== null){
                                                            tempRecord.tctName = recordData[key].assets[i].nameOnDoc !== undefined ? recordData[key].assets[i].nameOnDoc : '';
                                                        } else {
                                                            tempRecord.tctName = '';
                                                        }
                                                    }
                                                    if(recordData[key].assets[i].type === 'Name Document' && recordData[key].assets[i].parentval === 'Transfer Credit Transcript Document'){
                                                        tempRecord.tctNameDocId = recordData[key].assets[i].recordIdVal;
                                                        tempRecord.nameDocUrl = recordData[key].assets[i].azureUrl;
                                                        tempNameDocId = tempRecord.tctNameDocId;
                                                        nameDocPayloadJson.assetId = null;
                                                        this.assetIdsCollection.push(String(tempNameDocId));
                                                        if(recordData[key].assets[i].azureUrl){
                                                            this.assetInsertedList.push(recordData[key].assets[i].azureUrl);
                                                            this.assetUrlsCollection.push(recordData[key].assets[i].azureUrl);
                                                        }
                                                    }else{
                                                        tempRecord.tctNameDocId = '';
                                                    }
                                                    if(recordData[key].assets[i].type === 'Translation' && recordData[key].assets[i].parentval === 'Transfer Credit Transcript Document'){
                                                        tempRecord.nameOnTranslationDocCheckbox = recordData[key].assets[i].nameOnDocIsDifferent === 'true';
                                                        tempRecord.tctTranslationId = recordData[key].assets[i].recordIdVal;
                                                        tempRecord.tctTransUrl = recordData[key].assets[i].azureUrl;
                                                        tempTctTranslationId = tempRecord.tctTranslationId;
                                                        tctTranslationPayloadJson.assetId = null;
                                                        this.assetIdsCollection.push(String(tempTctTranslationId));
                                                        if(recordData[key].assets[i].azureUrl){
                                                            this.assetInsertedList.push(recordData[key].assets[i].azureUrl);
                                                            this.assetUrlsCollection.push(recordData[key].assets[i].azureUrl);
                                                        }
                                                        if(recordData[key].assets[i].nameOnDoc !== null &&
                                                            recordData[key].assets[i].nameOnDoc !== '' &&
                                                            recordData[key].assets[i].nameOnDoc !== undefined){
                                                            tempRecord.tctTranslationName = recordData[key].assets[i].nameOnDoc;
                                                        }else{
                                                            tempRecord.tctTranslationName = '';
                                                        }
                                                    }                                                
                                                }
                                            }
                                        }else{
                                            tempRecord.tctAssetId = '';
                                            tempRecord.nameOnTranscriptCheckbox = false;
                                            tempRecord.isTranscriptInEnglishCheckbox = false;
                                            tempRecord.tctName = '';
                                            tempRecord.nameOnTranslationDocCheckbox = false;
                                            tempRecord.tctTranslationId = '';
                                            tempRecord.tctTranslationName = ''; 
                                        }
                                        if(recordData[key].caseInternalStatus === 'CV Rejected' || recordData[key].caseInternalStatus === 'Cancelled'){
                                            tempTctPayload.assetId = null;
                                            nameDocPayloadJson.assetId = null;
                                            tctTranslationPayloadJson.assetId = null;
                                            tempRecord.tctPayload = JSON.stringify(tempTctPayload);
                                            tempRecord.tctTranslationPayload = JSON.stringify(tctTranslationPayloadJson);
                                            tempRecord.nameDocPayload = JSON.stringify(nameDocPayloadJson);
                                        }else{
                                            tempRecord.tctPayload = JSON.stringify(tempTctPayload);
                                            tempRecord.tctTranslationPayload = JSON.stringify(tctTranslationPayloadJson);
                                            tempRecord.nameDocPayload = JSON.stringify(nameDocPayloadJson);                                    
                                        }            
                                        tempRecord.tctAssetIdUpdated = true;
                                        tempRecord.tctTranslationAssetIdUpdated = true;
                                        tempRecord.nameDocAssetIdUpdated = true;
                                        if(this.recordsList.length > 0){
                                            this.recordsList = [...this.recordsList, tempRecord];
                                        }else{
                                            this.recordsList = [tempRecord];
                                        }
                                        count++;
                                    }
                                }
                                // Records are set in other object for Exam Reg READ ONLY Section
                                if(this.showReadOnlySection === true || this.showExamRegActionButton === true){
                                    // eslint-disable-next-line eqeqeq
                                    if(keymain == 0){
                                        this.recordsListExamRegReadOnly = this.recordsList;
                                        this.recordsList = [];
                                    } 
                                }                       
                            }
                            this.showDeleteSchoolOption = true;
                        }else{
                            this.recordsList = this.emptyRecordsList;
                        }
                    }else{
                        this.recordsList = this.emptyRecordsList;
                    }
                    this.recordListLoaded = true;            
                }else if(value.error){
                    this.recordsList = this.emptyRecordsList;
                    this.recordsListExamRegReadOnly = this.recordsList;
                    window.console.error('Error: ' + JSON.stringify(value.error));
                }        
                if(this.recordsList.length === 0 && this.recordsListAfterDelete.length > 0){
                    this.recordsList.push(this.recordsListAfterDelete);
                }
            })
        })    
    }
    connectedCallback(){
        this.recordsList = [];
        this.getOtherMedSchoolRecords();
        deleteOrphanedAssets();
    }
    renderedCallback(){        
        if(this.contactId && this.caseId && !this.markedAssetsForDeletion){
            //delete unsaved TCT assets
            markTctAssetsForDeletion({
                contactId: this.contactId,
                caseId: this.caseId
            }).then(updateResult =>{
                this.markedAssetsForDeletion = true;
            });
        }
        //get current user name
        getContactName({contactId: this.contactId})
        .then(result => {
            if(result !== ''){
                this.contactName = JSON.stringify(result).replace('"', '').replace('"', '');
            }
        })
        .catch();
        //scroll to latest section on add new record
        if(this.newRecordAdded){
            let nodes = this.template.querySelectorAll('.recordFieldsWrapper');
            nodes[nodes.length - 1].scrollIntoView();
            //Added By Ajith to fix the Bug of the Add New School not working on second click
            this.template.querySelectorAll('.recordFieldsWrapper').forEach(element=>{
                element.style.display = '';
            });
            this.template.querySelectorAll('.recordFieldsWrapper').forEach(element=>{
                element.removeAttribute("style");
            });
            this.newRecordAdded = false;
        }
        if(this.deleteSchoolFlag === false && this.refreshApexFlag === true){            
            refreshApex(this.wiredParameters);
        }     
        // repopulating schools after rerender       
        if(this.recordsList.length > 0){
            for(let i in this.recordsList){
                if(Object.keys(this.changedSchools).length > 0){
                    let j = this.recordsList[i].sno;                    
                    if(this.changedSchools[this.recordsList[i].sno] !== undefined){
                        this.recordsList[i].otherSchool = this.changedSchools[j].schoolInput;
                        this.recordsList[i].otherSchoolId = this.changedSchools[j].schoolId;                    
                        if(this.deleteSchoolFlag === true){                                             
                            if(this.changedSchools[j].schoolProgram !== undefined){
                                this.recordsList[i].schoolProgram = this.changedSchools[j].schoolProgram;
                                this.recordsList[i].studentId = this.changedSchools[j].studentId;
                                this.recordsList[i].Specialty = this.changedSchools[j].Specialty;
                                this.recordsList[i].startMonth = this.changedSchools[j].startMonth;
                                this.recordsList[i].startYear = this.changedSchools[j].startYear;
                                this.recordsList[i].endMonth = this.changedSchools[j].endMonth;
                                this.recordsList[i].endYear = this.changedSchools[j].endYear;
                                this.recordsList[i].numberOfYearsAttended = this.changedSchools[j].numberOfYearsAttended;
                                this.recordsList[i].transferCreditsCheckbox = this.changedSchools[j].transferCreditsCheckbox;
                                this.recordsList[i].tcWrapperList = this.changedSchools[j].tcWrapperList;
                                this.recordsList[i].tctAssetIdUpdated = true;
                                this.recordsList[i].tctName = this.changedSchools[j].tctName;
                                this.recordsList[i].tctUrl = this.changedSchools[j].tctUrl;
                                this.recordsList[i].tctAssetId = this.changedSchools[j].tctAssetId;
                                this.recordsList[i].nameOnTranscriptCheckbox = this.changedSchools[j].nameOnTranscriptCheckbox;
                                this.recordsList[i].nameDocAssetIdUpdated = this.changedSchools[j].nameDocAssetIdUpdated;
                                this.recordsList[i].tctNameDocId = this.changedSchools[j].tctNameDocId;
                                this.recordsList[i].nameDocUrl = this.changedSchools[j].nameDocUrl;
                                this.recordsList[i].isTranscriptInEnglishCheckbox = this.changedSchools[j].isTranscriptInEnglishCheckbox;
                                this.recordsList[i].tctTranslationAssetIdUpdated = this.changedSchools[j].tctTranslationAssetIdUpdated;
                                this.recordsList[i].tctTransUrl = this.changedSchools[j].tctTransUrl;
                                this.recordsList[i].tctTranslationId = this.changedSchools[j].tctTranslationId;
                            }
                        }
                    }
                }                
                if(this.changedSchools[this.recordsList[i].sno] === undefined){                    
                    this.changedSchools[this.recordsList[i].sno] = emptyMedChangeSchoolObj(this.recordsList[i]);
                }                
            }
        }        
        // code to set the medical school dropdowns
        if(this.template.querySelectorAll('datalist.otherSchoolRecordDatalist') !== null){
            this.template.querySelectorAll('datalist.otherSchoolRecordDatalist').forEach(element => {
                let idToSet = element.parentNode.querySelector(".otherSchoolRecord").getAttribute("id");
                element.setAttribute("id", idToSet + 'dataListSchool');
                element.parentNode.querySelector(".otherSchoolRecord").setAttribute("list", element.id);
            });
        }
        // code to set seleced month on load
        if(this.template.querySelectorAll('.monthPicklist') !== null){
            this.template.querySelectorAll('.monthPicklist').forEach(element => {
                if(element.getAttribute('data-selected-month') !== '' &&
                    element.getAttribute('data-selected-month') !== 'true' &&
                    element.getAttribute('data-selected-month') !== null){
                    element.value = element.getAttribute('data-selected-month');
                }
            });
        }
        // code to set maxlength for Year fields
        if(this.template.querySelectorAll('.creditEarnedYearInput') !== null){
            this.template.querySelectorAll('.creditEarnedYearInput').forEach(element => {
                element.setAttribute("maxlength", "4");
            });
        }
        // method to display transfer credit sections based on checkbox
        hideTransferCreditSection(this);
        sectionsRenderer(this);        
        // code to hide delete icon for only one TC Row
        if(this.template.querySelectorAll('.tcTable') !== null){
            this.template.querySelectorAll('.tcTable').forEach(element => {
                if(element.querySelectorAll('.tcDetailsRow').length === 1){
                    element.querySelectorAll('.delete-icon').forEach(elem => {
                        elem.style.display = 'none';
                    });
                }else{
                    element.querySelectorAll('.delete-icon').forEach(elem => {
                        elem.style.display = 'block';
                    });
                }
            });
        }
        if(this.parentCaseId !== undefined && this.caseId !== undefined && this.contactId !== undefined){
            let tctPayloadJson = tempTctPayloadHelper(this.contactId, this.parentCaseId, this.caseId); 
            let tctTranslationPayloadJson = tempTctTranslationPayloadHelper(this.contactId, this.parentCaseId, this.caseId); 
            let nameDocPayloadJson = tempNameDocPayloadHelper(this.contactId, this.parentCaseId, this.caseId);
            if(!this.emptyRecordsList[0].hasOwnProperty('tctPayload')){
                this.emptyRecordsList[0].tctPayload = JSON.stringify(tctPayloadJson);
                this.emptyRecordsList[0].tctTranslationPayload = JSON.stringify(tctTranslationPayloadJson);
                this.emptyRecordsList[0].nameDocPayload = JSON.stringify(nameDocPayloadJson);
                this.emptyRecordsList[0].tctAssetIdUpdated = true;
                this.emptyRecordsList[0].tctTranslationAssetIdUpdated = true;
                this.emptyRecordsList[0].nameDocAssetIdUpdated = true;
            }
        }
    }    
    // method to  hide the sections given the parent element and class name
    hideSection(elem, clsName){
        let cls = '.' + clsName;
        elem.querySelectorAll(cls).forEach(element => {
            element.style.display = 'none';
        });
    }
    // method to  show the sections given the parent element and class name
    showSection(elem, clsName){
        let cls = '.' + clsName;
        elem.querySelectorAll(cls).forEach(element => {
            element.style.display = 'block';
        });
    }
    handleSchoolOnChange(event){
        this.deleteSchoolFlag = false;             
        event.target.classList.add('currentSchoolInput');
        let currentSchoolInput = this.template.querySelector('.otherSchoolRecord.currentSchoolInput').value;
        let closestElem = getClosest(event.target, '.recordFieldsWrapper'); 
        let currentSchoolIndex = parseInt(closestElem.getAttribute('data-record-index'), 10);
        if(Object.keys(this.changedSchools).length > 0){    
            let medChangedSchoolsObj = {};
            for(let j in this.changedSchools){
                if(parseInt(j) !== currentSchoolIndex){
                    medChangedSchoolsObj[j] = this.changedSchools[j];
                }
            }
            this.changedSchools = medChangedSchoolsObj; 
        }               
        if(currentSchoolInput !== ''){
            this.showDeleteSchoolOption = true;            
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
                    if(this.template.querySelector('#medSchoolError') !== null){
                        let elem = this.template.querySelector('#medSchoolError');
                        elem.parentNode.removeChild(elem);
                    }
                }
                this.changedSchools[currentSchoolIndex] = currentChangedSchoolDetails;                
            }else{
                this.changedSchools[currentSchoolIndex] = currentChangedSchoolDetails; 
            }
        }else{
            event.target.setAttribute("data-otherschool-id", '');
        } 
        event.target.classList.remove('currentSchoolInput');
    }
    showNextSectionsForTCT(event){
        this.deleteSchoolFlag = false;
        this.refreshApexFlag = false;
        let eventElement = event;
        eventElement.target.parentNode.classList.add('currentTransferCreditTranscript');
        this.showSection(this.template.querySelector('.currentTransferCreditTranscript').parentNode, 'tcNameSection');
        this.showSection(this.template.querySelector('.currentTransferCreditTranscript').parentNode, 'tcTranslationSection');
        this.template.querySelector('.currentTransferCreditTranscript').classList.remove('currentTransferCreditTranscript');
    }
    handleTctUploaded(event){
        this.deleteSchoolFlag = false;
        this.refreshApexFlag = false;
        let eventElement = event;
        eventElement.target.parentNode.classList.add('currentTransferCreditTranscript');
        let index = getCurrentSchoolIndex(event.target, this.recordsList);
        this.recordsList[index].tctUrl = event.detail.url;
        this.recordsList[index].tctAssetIdUpdated = true;
        let tempPayload = JSON.parse(this.recordsList[index].tctPayload);
        tempPayload.azureUrl = event.detail.url;
        this.recordsList[index].tctPayload = JSON.stringify(tempPayload);
        // setting parent url for name documentation
        tempPayload = JSON.parse(this.recordsList[index].nameDocPayload);
        tempPayload.parentUrl = event.detail.url;
        this.recordsList[index].nameDocPayload = JSON.stringify(tempPayload);
        // setting parent url for translation document
        tempPayload = JSON.parse(this.recordsList[index].tctTranslationPayload);
        tempPayload.parentUrl = event.detail.url;
        this.recordsList[index].tctTranslationPayload = JSON.stringify(tempPayload);
        this.assetInsertedList.push(event.detail.url);
        if(!this.assetUrlsCollection.includes(event.detail.url)){
            this.assetUrlsCollection.push(event.detail.url);
        }        
        this.template.querySelector('.currentTransferCreditTranscript').parentNode.querySelector('.tctName').setAttribute("data-asset-url", event.detail.url);
        this.template.querySelector('.currentTransferCreditTranscript').parentNode.querySelector('.nameOnTranscriptCheckbox').setAttribute("data-asset-url", event.detail.url);
        this.template.querySelector('.currentTransferCreditTranscript').parentNode.querySelector('.isTranscriptInEnglishCheckbox').setAttribute("data-asset-url", event.detail.url);
        if(this.template.querySelector('.currentTransferCreditTranscript').parentNode.querySelector('.tctMissingError') !== null){
            this.template.querySelector('.currentTransferCreditTranscript').parentNode.querySelector('.tctMissingError').remove();
        }
        this.template.querySelector('.currentTransferCreditTranscript').parentNode.querySelector('.tctName').value = '';
        this.template.querySelector('.currentTransferCreditTranscript').classList.remove('currentTransferCreditTranscript');
        this.template.querySelector(".cloudTransferCreditTranscript").auraThumbnailLoaderAzureURL();
    }
    handleNameDocUploaded(event){
        this.deleteSchoolFlag = false;
        this.refreshApexFlag = false;
        let eventElement = event;
        eventElement.target.parentNode.classList.add('currentTctNameDocumenatationSectionUploadId');
        let index = getCurrentSchoolIndex(event.target, this.recordsList);
        this.recordsList[index].nameDocUrl = event.detail.url;
        this.recordsList[index].nameDocAssetIdUpdated = true;
        let tempPayload = JSON.parse(this.recordsList[index].nameDocPayload);
        tempPayload.azureUrl = event.detail.url;
        this.recordsList[index].nameDocPayload = JSON.stringify(tempPayload);
        this.assetInsertedList.push(event.detail.url);
        if(!this.assetUrlsCollection.includes(event.detail.url)){
            this.assetUrlsCollection.push(event.detail.url);
        }
        this.template.querySelector('.currentTctNameDocumenatationSectionUploadId').setAttribute("data-asset-url", event.detail.url);
        if(this.template.querySelector('.currentTctNameDocumenatationSectionUploadId').parentNode.querySelector('.nameDocMissingError') !== null){
            this.template.querySelector('.currentTctNameDocumenatationSectionUploadId').parentNode.querySelector('.nameDocMissingError').remove();
        }
        this.template.querySelector('.currentTctNameDocumenatationSectionUploadId').classList.remove('currentTctNameDocumenatationSectionUploadId');        
        this.template.querySelector(".cloudTCTNameDocumentation").auraThumbnailLoaderAzureURL();
    }
    handleTctTranslationUploaded(event){
        this.deleteSchoolFlag = false;
        this.refreshApexFlag = false;
        let eventElement = event;
        eventElement.target.parentNode.classList.add('currentTctTranslationDoc');
        let index = getCurrentSchoolIndex(event.target, this.recordsList);
        this.recordsList[index].tctTransUrl = event.detail.url;
        this.recordsList[index].tctTranslationAssetIdUpdated = true;
        let tempPayload = JSON.parse(this.recordsList[index].tctTranslationPayload);
        tempPayload.azureUrl = event.detail.url;
        this.recordsList[index].tctTranslationPayload = JSON.stringify(tempPayload);
        this.assetInsertedList.push(event.detail.url);
        if(!this.assetUrlsCollection.includes(event.detail.url)){
            this.assetUrlsCollection.push(event.detail.url);
        }
        this.template.querySelector('.currentTctTranslationDoc').parentNode.querySelector('.tctTranslationId').setAttribute("data-asset-url", event.detail.url);
        if(this.template.querySelector('.currentTctTranslationDoc').parentNode.querySelector('.translationDocMissingError') !== null){
            this.template.querySelector('.currentTctTranslationDoc').parentNode.querySelector('.translationDocMissingError').remove();
        }
        this.template.querySelector('.currentTctTranslationDoc').classList.remove('currentTctTranslationDoc');
        this.template.querySelector(".cloudTCTTransDoc").auraThumbnailLoaderAzureURL();
    }
    handleTransferCreditCheckboxClick(event){
        this.deleteSchoolFlag = false;
        event.target.classList.add('currentCheckbox');
        let breakFunc = false;
        let index = getCurrentSchoolIndex(event.target, this.recordsList);
        this.template.querySelectorAll('.transferCreditsDegreeCheckbox').forEach(element => {
            if(element.checked){
                if(!element.classList.contains('currentCheckbox')){
                    this.showTransferCreditError();
                    breakFunc = true;
                }
            }
        });
        if(breakFunc){
            event.target.classList.remove('currentCheckbox');
            event.target.checked = false;
            return false;
        }
        this.removeTransferCreditError();
        let closestOtherMedSchool = getClosest(event.target, '.recordFieldsWrapper');
        if(event.target.checked){
            sectionsRenderer(this);
            this.recordsList[index].tctAssetIdUpdated = true;
            removeTransferCreditsErrors(closestOtherMedSchool);
        }else{
            this.template.querySelector('[data-id="newModalAlertTCT"]').show();
            // window below has been replaced with a modal window in otherMedSchool.html
            /*
            // eslint-disable-next-line no-alert
            if(window.confirm("Transfer credit data for this school will be removed. Are you sure you want to continue?")){
                this.template.querySelector('.transferCreditsDegreeCheckbox.currentCheckbox').parentNode.querySelectorAll('.transferCreditSection').forEach(element=>{
                    element.style.display = 'none';
                });
                markAssetsForDeletionWithUrlList({
                    assetUrlsString: JSON.stringify(this.assetUrlsCollection)
                });
                this.handleUncheckTransferCredits(event, index, closestOtherMedSchool);
            }else{
                event.target.checked = true;
            } */
        }
        event.target.classList.remove('currentCheckbox');
        return true;
    }
    handleUncheckTransferCredits(event, index, closestOtherMedSchool){
        this.recordsList[index] = updateRecordsListUncheckedTC(this.recordsList[index]);
        // Removing Error texts
        removeTransferCreditsErrors(closestOtherMedSchool);
        // Clearing the Transfer Credits fields
        clearTransferCreditsFields(closestOtherMedSchool);
        // When uncheck the checkbox, delete the Transfer Credits Transcript Details // hide TCT sections
        deleteUncheckedTCAsset(this);
    }
    deleteNameAsset(event){        
        this.deleteSchoolFlag = false;
        this.refreshApexFlag = false;        
        let index = getCurrentSchoolIndex(event.target, this.recordsList);        
        let currentNameDocAssetUrl = getClosest(event.target, '.recordFieldsWrapper').querySelector(".tctNameDocumenatationSectionUploadId").getAttribute('data-asset-url');                   
        if(currentNameDocAssetUrl){
            markAssetsForDeletionFromUrl({azureUrl : currentNameDocAssetUrl});
            getClosest(event.target, '.recordFieldsWrapper').querySelector(".tctNameDocumenatationSectionUploadId").setAttribute("data-asset-url", '');
        }
        this.recordsList[index].nameDocAssetIdUpdated = true;
        let tempPayload = JSON.parse(this.recordsList[index].nameDocPayload);
        tempPayload.azureUrl = null;
        this.recordsList[index].nameDocPayload = JSON.stringify(tempPayload);
        this.recordsList[index].nameDocUrl = '';
    }
    handleTransferCreditInnerCheckboxClick(event){
        this.deleteSchoolFlag = false;
        this.refreshApexFlag = false;
        event.target.parentNode.classList.add('currentTransferCreditSection');
        let index = getCurrentSchoolIndex(event.target, this.recordsList);
        if(event.target.parentNode.classList.contains('tcNameSection')){
            let currentNameDocAssetUrl = getClosest(event.target, '.recordFieldsWrapper').querySelector(".tctNameDocumenatationSectionUploadId").getAttribute('data-asset-url');
            if(event.target.checked){
                this.showSection(event.target.parentNode.parentNode, 'tcNameSectionUpload');
                this.recordsList[index].nameDocAssetIdUpdated = true;
            }else{
                this.hideSection(event.target.parentNode.parentNode, 'tcNameSectionUpload');
                if(currentNameDocAssetUrl){
                    markAssetsForDeletionFromUrl({azureUrl : currentNameDocAssetUrl});
                    getClosest(event.target, '.recordFieldsWrapper').querySelector(".tctNameDocumenatationSectionUploadId").setAttribute("data-asset-url", '');
                }
                this.recordsList[index].nameDocAssetIdUpdated = false;
                let tempPayload = JSON.parse(this.recordsList[index].nameDocPayload);
                tempPayload.azureUrl = null;
                this.recordsList[index].nameDocPayload = JSON.stringify(tempPayload);
                this.recordsList[index].nameDocUrl = '';
                this.template.querySelector(".cloudTCTNameDocumentation").auraThumbnailLoaderAzureURL();
            }
        }
        if(event.target.parentNode.classList.contains('tcTranslationSection')){
            let currentTctTransDocAssetUrl = getClosest(event.target, '.recordFieldsWrapper').querySelector(".tctTranslationId").getAttribute('data-asset-url');
            if(event.target.checked){
                this.showSection(event.target.parentNode.parentNode, 'tcTranslationSectionUpload');
                this.recordsList[index].tctTranslationAssetIdUpdated = true;
            }else{
                this.hideSection(event.target.parentNode.parentNode, 'tcTranslationSectionUpload');
                if(currentTctTransDocAssetUrl){
                    markAssetsForDeletionFromUrl({azureUrl : currentTctTransDocAssetUrl});
                    getClosest(event.target, '.recordFieldsWrapper').querySelector(".tctTranslationId").setAttribute('data-asset-url', '');
                }
                this.recordsList[index].tctTranslationAssetIdUpdated = false;
                let tempPayload = JSON.parse(this.recordsList[index].tctTranslationPayload); 
                tempPayload.azureUrl = null;
                this.recordsList[index].tctTranslationPayload = JSON.stringify(tempPayload);
                this.recordsList[index].tctTransUrl = '';
                this.template.querySelector(".cloudTCTTransDoc").auraThumbnailLoaderAzureURL();
            }
        }
        event.target.parentNode.classList.remove('currentTransferCreditSection');
    }
    addTcRow(event){
        this.deleteSchoolFlag = false;
        this.refreshApexFlag = false;
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
        this.deleteSchoolFlag = false;
        this.refreshApexFlag = false;
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
    addNewRecord(){
        this.addNewMedicalSchoolRecord('click');
    }
    addNewMedicalSchoolRecord(optType){ 
        this.deleteSchoolFlag = false;
        this.refreshApexFlag = true;
        this.showOtherMedicalDetailSection = true;
        this.showDeleteSchoolOption = true;
        let currentCount = 0;
        currentCount = this.recordsList.length;
        if(this.showReadOnlySection === true || this.showExamRegActionButton === true){
            currentCount = this.recordsListExamRegReadOnly.length + this.recordsList.length;
        }
        if(this.recordsList.length === 0){
            this.changedSchools = {};
            this.recordsListAfterDelete = [];
        }
        this.recordsList = [...this.recordsList, {
            sno: currentCount + 1,
            recordIdVal: '',
            otherSchool: '',
            otherSchoolId: '',
            numberOfYearsAttended: '',
            schoolProgram: '',
            studentId: '',
            Specialty: '',
            inputOtherSchoolId: '',
            valueListId: '',
            startMonth: '',
            startYear: '',
            endMonth: '',
            endYear: '',
            transferCreditsCheckbox: false,
            nameOnTranscriptCheckbox: false,
            isTranscriptInEnglishCheckbox: false,
            tctName: '',
            nameOnTranslationDocCheckbox: false,
            tctTranslationName: '',
            tctAssetId: '',
            tctNameDocId: '',
            tctTranslationId: '',
            tctUrl: '',
            nameDocUrl: '',
            tctTransUrl: '',
            tcWrapperList: [{
                tcId: '',
                transferCreditCourse: '',
                transferCreditGrade: '',
                courseOutcome: '',
                creditsEarnedMonth: '',
                creditsEarnedYear: ''
            }],
            tctAssetIdUpdated: false,
            tctTranslationAssetIdUpdated: false,
            nameDocAssetIdUpdated: false
        }];
        if(this.parentCaseId !== undefined && this.caseId !== undefined && this.contactId !== undefined){
            let tctPayloadJson = {
                "contactId": String(this.contactId),
                "parentCaseId": String(this.parentCaseId),
                "caseId": String(this.caseId),
                "catsId": "",
                "documentType": "Transfer Credit Transcript",
                "assetName": "Transfer Credit Transcript",
                "assetRecordType": "Credential",
                "createOrReplace": "Create",
                "assetStatus": "In Progress",
                "assetCreationRequired": "true",
                "assetId": "null",
                "type": "Transfer Credit Transcript",
                "key": "Transfer Credit Transcript Document",
                "parentKey": "",
                "createFromPB": "true"
            };
            let tctTranslationPayloadJson = {
                "contactId": String(this.contactId),
                "parentCaseId": String(this.parentCaseId),
                "caseId": String(this.caseId),
                "catsId": "",
                "documentType": "TCT Translation",
                "assetName": "TCT Translation",
                "assetRecordType": "Credential",
                "createOrReplace": "Create",
                "assetStatus": "In Progress",
                "assetCreationRequired": "true",
                "assetId": "null",
                "type": "Translation",
                "key": "Transfer Credit Transcript Translation Document",
                "parentKey": "Transfer Credit Transcript Document",
                "createFromPB": "true"
            };
            let nameDocPayloadJson = {
                "contactId": String(this.contactId),
                "parentCaseId": String(this.parentCaseId),
                "caseId": String(this.caseId),
                "catsId": "",
                "documentType": "Name Document",
                "assetName": "Name Document",
                "assetRecordType": "Identity",
                "createOrReplace": "Create",
                "assetStatus": "In Progress",
                "assetCreationRequired": "true",
                "assetId": "null",
                "type": "Name Document",
                "key": "Transfer Credit Transcript Name Document",
                "parentKey": "Transfer Credit Transcript Document",
                "createFromPB": "true"
            };
            if(!this.recordsList[this.recordsList.length - 1].hasOwnProperty('tctPayload')){
                this.recordsList[this.recordsList.length - 1].tctPayload = JSON.stringify(tctPayloadJson);
                this.recordsList[this.recordsList.length - 1].tctTranslationPayload = JSON.stringify(tctTranslationPayloadJson);
                this.recordsList[this.recordsList.length - 1].nameDocPayload = JSON.stringify(nameDocPayloadJson);
                this.recordsList[this.recordsList.length - 1].tctAssetIdUpdated = false;
                this.recordsList[this.recordsList.length - 1].tctTranslationAssetIdUpdated = false;
                this.recordsList[this.recordsList.length - 1].nameDocAssetIdUpdated = false;
                this.recordsList[this.recordsList.length - 1].nameOnTranscriptCheckbox = false;
                this.recordsList[this.recordsList.length - 1].isTranscriptInEnglishCheckbox = false;
                this.recordsList[this.recordsList.length - 1].nameOnTranslationDocCheckbox = false;
                this.recordsList[this.recordsList.length - 1].otherSchool = '';
                this.recordsList[this.recordsList.length - 1].otherSchoolId = '';
            }
        }
        this.newRecordAdded = true;
        if(this.recordsList.length==1){
            this.newRecordAdded = false;
        }  
        that.spinner = false;      
    }
    saveRecords(){
        this.deleteSchoolFlag = false;
        this.spinner = true;
        let breakSaveFunc = false;
        let checkedCounter = 0;
        let showOtherMedSchoolError = false;
        this.template.querySelectorAll('.transferCreditsDegreeCheckbox').forEach(element => {
            if(element.checked){
                checkedCounter++;
                if(checkedCounter > 1){
                    this.showTransferCreditError();
                    breakSaveFunc = true;
                }
            }
        });
        this.template.querySelectorAll('.otherSchoolRecord').forEach(element => {
            if(element.getAttribute('data-otherschool-id') === '' || element.getAttribute('data-otherschool-id') === true){
                showOtherMedSchoolError = true;
                breakSaveFunc = true;
            }else{
                if(!this.validSchoolRecordIds.includes(element.getAttribute('data-otherschool-id'))){
                    showOtherMedSchoolError = true;
                    breakSaveFunc = true;
                }
            }
        });
        let allWrapper = this.template.querySelectorAll(".recordFieldsWrapper");
        let recordValuesToSave = [];
        allWrapper.forEach(function (element){
            let tempSchoolRecord = {
                recordIdVal: element.getAttribute('data-record-id'),
                otherSchool: element.querySelector(".otherSchoolRecord").value,
                otherSchoolId: element.querySelector(".otherSchoolRecord").getAttribute('data-otherschool-id'),
                schoolProgram: element.querySelector(".schoolProgram").value,
                studentId: element.querySelector(".studentId").value,
                Specialty: element.querySelector(".speciality").value,
                startMonth: element.querySelector(".startMonth").value,
                startYear: element.querySelector(".startYear").value,
                endMonth: element.querySelector(".endMonth").value,
                endYear: element.querySelector(".endYear").value,
                numberOfYearsAttended: element.querySelector(".attendedYears").value,
                transferCreditsCheckbox: element.querySelector(".transferCreditsCheckbox").checked
            }
            if(tempSchoolRecord.transferCreditsCheckbox){
                let tempFromSchool = element.querySelector(".otherSchoolRecord").getAttribute('data-otherschool-id');
                tempSchoolRecord.tcWrapperList = [];
                let tcDetailsRow = element.querySelectorAll(".tcDetailsRow");
                tcDetailsRow.forEach(function (elem){
                    let regex = /^(\d{0,2}\.?\d{0,2})/g; // regex to limit decimals to 2 digits and 2 decimals
                    let decimalCheckerRegex = /^\d*\.?\d+$/; // regex to check if value is of a decimal format
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
                let temptctMainAssetRecord = {
                    azureUrl: element.querySelector(".tctName").getAttribute('data-asset-url'),
                    docNotInEnglish: element.querySelector(".isTranscriptInEnglishCheckbox").checked,
                    nameOnDoc: element.querySelector(".tctName").value,
                    nameOnDocIsDifferent: element.querySelector(".nameOnTranscriptCheckbox").checked,
                    type: 'Transfer Credit Transcript',
                    parentAssetAzureUrl: ''
                }
                tempSchoolRecord.assets = [];
                if(temptctMainAssetRecord.azureUrl !== '' && temptctMainAssetRecord.azureUrl !== null){
                    tempSchoolRecord.assets.push(temptctMainAssetRecord);
                }
                if(temptctMainAssetRecord.nameOnDocIsDifferent){
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
                }
                if(temptctMainAssetRecord.docNotInEnglish){
                    let tempTranslationAssetRecord = {
                        azureUrl: element.querySelector(".tctTranslationId").getAttribute('data-asset-url'),
                        docNotInEnglish: '',
                        nameOnDoc: '',
                        nameOnDocIsDifferent: '',
                        type: 'Translation',
                        parentAssetAzureUrl: element.querySelector(".tctName").getAttribute('data-asset-url')
                    }
                    if(tempTranslationAssetRecord.azureUrl !== '' && tempTranslationAssetRecord.azureUrl !== null){
                        tempSchoolRecord.assets.push(tempTranslationAssetRecord);
                    }
                }
            }
            recordValuesToSave.push(tempSchoolRecord);
        });
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
            showfromToError = false,
            showAttendedYearsError = false,
            decimalCount = 0;
        if(this.template.querySelectorAll('.slds-has-error') !== null){
            this.template.querySelectorAll('.slds-has-error').forEach(element => element.classList.remove('slds-has-error'));
        }
        for(let i = 0; i < recordValuesToSave.length; i++){
            if(recordValuesToSave[i].startMonth === '' || recordValuesToSave[i].startMonth === null || recordValuesToSave[i].startYear === '' || recordValuesToSave[i].startYear === null){
                showDateError = true;
            }
            if(recordValuesToSave[i].endMonth === '' || recordValuesToSave[i].endMonth === null || recordValuesToSave[i].endYear === '' || recordValuesToSave[i].endYear === null){
                showDateError = true;
            }
            if(recordValuesToSave[i].endMonth !== '' && recordValuesToSave[i].endMonth !== null && recordValuesToSave[i].endYear !== '' && recordValuesToSave[i].endYear !== null){
                //construct a endadte and compare with current date
                //construct new enddate
                //compare startdate & enddate
                //construct start & end dates.
                let newStartEndDay = '01';
                let tempStrSDate = recordValuesToSave[i].startYear + '-' + recordValuesToSave[i].startMonth + '-' + newStartEndDay
                let tempNewStartDate = new Date(tempStrSDate);
                let tempStrEDate = recordValuesToSave[i].endYear + '-' + recordValuesToSave[i].endMonth + '-' + newStartEndDay;
                let tempNewEndDate = new Date(tempStrEDate);
                if(Date.parse(tempNewEndDate) >= Date.parse(today)){
                    showDateError = true;
                }
                if(Date.parse(tempNewEndDate) < Date.parse(tempNewStartDate) || Date.parse(tempNewEndDate) === Date.parse(tempNewStartDate)){
                    showfromToError = true;
                }
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
            if(recordValuesToSave[i].transferCreditsCheckbox){
                for(let j = 0; j < recordValuesToSave[i].assets.length; j++){
                    if(recordValuesToSave[i].assets[j].type === 'Transfer Credit Transcript'){
                        if(recordValuesToSave[i].assets[j].nameOnDoc === ''){
                            showBlankNameError = true;
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
                        if(parseInt(recordValuesToSave[i].tcWrapperList[k].creditsEarnedYear, 10) > parseInt(yyyy, 10)){
                            tcDateCond = true;
                        }else if(parseInt(recordValuesToSave[i].tcWrapperList[k].creditsEarnedYear, 10) === parseInt(yyyy, 10)){
                            if(tcCourseMonth === false){
                                let monthVal;
                                if(recordValuesToSave[i].tcWrapperList[k].creditsEarnedMonth === 'January'){
                                    monthVal = 1;
                                } else if(recordValuesToSave[i].tcWrapperList[k].creditsEarnedMonth === 'February'){
                                    monthVal = 2;
                                } else if(recordValuesToSave[i].tcWrapperList[k].creditsEarnedMonth === 'March'){
                                    monthVal = 3;
                                } else if(recordValuesToSave[i].tcWrapperList[k].creditsEarnedMonth === 'April'){
                                    monthVal = 4;
                                } else if(recordValuesToSave[i].tcWrapperList[k].creditsEarnedMonth === 'May'){
                                    monthVal = 5;
                                } else if(recordValuesToSave[i].tcWrapperList[k].creditsEarnedMonth === 'June'){
                                    monthVal = 6;
                                } else if(recordValuesToSave[i].tcWrapperList[k].creditsEarnedMonth === 'July'){
                                    monthVal = 7;
                                } else if(recordValuesToSave[i].tcWrapperList[k].creditsEarnedMonth === 'August'){
                                    monthVal = 8;
                                } else if(recordValuesToSave[i].tcWrapperList[k].creditsEarnedMonth === 'September'){
                                    monthVal = 9;
                                } else if(recordValuesToSave[i].tcWrapperList[k].creditsEarnedMonth === 'October'){
                                    monthVal = 10;
                                } else if(recordValuesToSave[i].tcWrapperList[k].creditsEarnedMonth === 'November'){
                                    monthVal = 11;
                                } else if(recordValuesToSave[i].tcWrapperList[k].creditsEarnedMonth === 'December'){
                                    monthVal = 12;
                                }
                                if(monthVal > parseInt(mm, 10)){
                                    tcDateCond = true;
                                }
                            }
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
                    if(elem.parentNode.parentNode.querySelector('.transferCreditsCheckbox').checked){
                        showTctMissing = true;
                    }
                }
            });
        }
        if(this.template.querySelectorAll('.isTranscriptInEnglishCheckbox') !== null){
            this.template.querySelectorAll('.isTranscriptInEnglishCheckbox').forEach(elem => {
                if(elem.checked && !elem.disabled){
                    let schoolWrapper = getClosest(elem, '.recordFieldsWrapper');
                    if(schoolWrapper.querySelector('.tctTranslationId').getAttribute('data-asset-url') === '' ||
                        schoolWrapper.querySelector('.tctTranslationId').getAttribute('data-asset-url') === 'true' ||
                        schoolWrapper.querySelector('.tctTranslationId').getAttribute('data-asset-url') === null ||
                        schoolWrapper.querySelector('.tctTranslationId').getAttribute('data-asset-url') === 'undefined'){
                        showTranslationDocMissing = true;
                    }
                }
            });
        }
        if(showDateError){
            breakSaveFunc = true;
            this.showNewDateErrorFunc();
        }else{
            this.template.querySelectorAll('.blankStartMonthError').forEach(element => element.remove());
            this.template.querySelectorAll('.blankStartYearError').forEach(element => element.remove());
            this.template.querySelectorAll('.blankEndMonthError').forEach(element => element.remove());
            this.template.querySelectorAll('.blankEndYearError').forEach(element => element.remove());
            this.template.querySelectorAll('.EndDateError').forEach(element => element.remove());
        }
        if(showfromToError){
            breakSaveFunc = true;
            this.showStartEndErrorFunc();
        }else{
            this.template.querySelectorAll('.startEndDateError').forEach(element => element.remove());
        }
        if(showAttendedYearsError){
            breakSaveFunc = true;
            this.showAttendedYearsFunc();
        }else{
            this.template.querySelectorAll('.attendedYearsError').forEach(element => element.remove());
        }
        if(showBlankNameError){
            breakSaveFunc = true;
            this.showBlankNameErrorFunc();
        }else{
            this.template.querySelectorAll('.blankNameError').forEach(element => element.remove());
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
        if(showOtherMedSchoolError){
            showOtherMedSchoolErrorFunc(this);
        }
        if(!breakSaveFunc){
            saveOtherMedicalSchools({
                jsonString: JSON.stringify(recordValuesToSave),
                assetsUrlsList: JSON.stringify(this.assetInsertedList),
                parentCaseId: this.parentCaseId,
                caseId: this.caseId,
                tcsToDelList: JSON.stringify(this.tcsToDel),
                showExamRegActionButton: this.showExamRegActionButton
            }).then(saveresult => {
                this.spinner = false;
                this.tcsToDel = [];
                if(saveresult){
                    this.updateCATDeletedOnResubmission();
                    deleteUncheckedTransferCreditAndAsset({
                        contactId: this.contactId,
                        parentCaseId: this.parentCaseId,
                        caseId: this.caseId
                    }).then(delresult => {
                        if(delresult === 'true'){
                            this.showSuccessfulSave();
                            refreshApex(this.wiredParameters);
                        }else{
                            window.console.error('Delete Error:', delresult);
                        }
                    }).catch(error => {
                        window.console.error('Error: ' + JSON.stringify(error));
                    });
                }
                if(this.clickedBtn === 'Next'){
                    const selectEvent = new CustomEvent('nextevent', {});
                    this.dispatchEvent(selectEvent);
                }
            })
            .catch(error => {
                this.tcsToDel = [];
                window.console.error('Error: ' + JSON.stringify(error));
            });
        }else{            
            this.spinner = false;
        }
        return true;
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
    showNewDateErrorFunc(){
        if(this.template.querySelectorAll('.blankStartMonthError') !== null){
            this.template.querySelectorAll('.blankStartMonthError').forEach(element => element.remove());
        }
        this.template.querySelectorAll('.startMonth').forEach(element => {
            //code for start month validation
            if(element.value === '' || element.value === null){
                //create a div tag and display the error
                let elem = document.createElement("div");
                elem.id = 'blankStartMonthError';
                elem.setAttribute('class', 'blankStartMonthError');
                elem.textContent = 'Please enter a Start Month';
                elem.style = 'color:#ff0000; clear:both;';
                element.classList.add('slds-has-error');
                element.parentNode.insertBefore(elem, element.nextSibling);
            }
        });
        //Blank Start Year
        if(this.template.querySelectorAll('.blankStartYearError') !== null){
            this.template.querySelectorAll('.blankStartYearError').forEach(element => element.remove());
        }
        this.template.querySelectorAll('.startYear').forEach(element => {
            if(element.value === '' || element.value === null){
                let elem = document.createElement("div");
                elem.id = 'blankStartYearError';
                elem.setAttribute('class', 'blankStartYearError');
                elem.textContent = 'Please enter a Start Year';
                elem.style = 'color:#ff0000; clear:both;';
                element.classList.add('slds-has-error');
                element.parentNode.insertBefore(elem, element.nextSibling);
            }
        });
        //Blank End Month
        if(this.template.querySelectorAll('.blankEndMonthError') !== null){
            this.template.querySelectorAll('.blankEndMonthError').forEach(element => element.remove());
        }
        this.template.querySelectorAll('.endMonth').forEach(element => {
            if(element.value === '' || element.value === null){
                let elem = document.createElement("div");
                elem.id = 'blankEndMonthError';
                elem.setAttribute('class', 'blankEndMonthError');
                elem.textContent = 'Please enter a End Month';
                elem.style = 'color:#ff0000; clear:both;';
                element.classList.add('slds-has-error');
                element.parentNode.insertBefore(elem, element.nextSibling);
            }
        });
        //Blank End Year
        // Remove the Error Elements by Class Name
        if(this.template.querySelectorAll('.blankEndYearError') !== null){
            this.template.querySelectorAll('.blankEndYearError').forEach(element => element.remove());
        }
        this.template.querySelectorAll('.endYear').forEach(element => {
            if(element.value === '' || element.value === null){
                let elem = document.createElement("div");
                elem.id = 'blankEndYearError';
                elem.setAttribute('class', 'blankEndYearError');
                elem.textContent = 'Please enter End Year';
                elem.style = 'color:#ff0000; clear:both;';
                element.classList.add('slds-has-error');
                element.parentNode.insertBefore(elem, element.nextSibling);
            }
        });
        //Check End Date against Current Date.
        let today = new Date();
        let tempEndMonthVal = '';
        let tempEndYearVal = '';
        let tempStrEDate = '';
        let tempNewEDate = new Date();
        // Remove the Error Elements by Class Name
        if(this.template.querySelectorAll('.EndDateError') !== null){
            this.template.querySelectorAll('.EndDateError').forEach(element => element.remove());
        }
        this.template.querySelectorAll('.endMonth').forEach(element => {
            if(element.value !== '' || element.value !== null){
                //construct the dates
                tempEndMonthVal = element.value;
                tempEndYearVal = element.parentNode.parentNode.querySelector('.endYear').value;
                //Now that we have end year & end month. compare it with current date
                if(tempEndMonthVal !== '' && tempEndYearVal !== '' && tempEndMonthVal !== null && tempEndYearVal !== null){
                    tempStrEDate = tempEndYearVal + '-' + tempEndMonthVal + '-' + '01';
                    tempNewEDate = new Date(tempStrEDate);
                    if(Date.parse(tempNewEDate) >= Date.parse(today)){
                        let elem = document.createElement("div");
                        elem.id = 'EndDateError';
                        elem.setAttribute('class', 'EndDateError');
                        elem.textContent = 'Start and End dates for a graduate should not be in the future.';
                        elem.style = 'color:#ff0000; clear:both;';
                        element.classList.add('slds-has-error');
                        element.parentNode.insertBefore(elem, element.nextSibling);
                    }
                }
            }
        });
        this.template.querySelector('.slds-has-error').scrollIntoView();
    }
    //New code added by Shailaja. Date format stories.
    showStartEndErrorFunc(){
        let startMonthVal = '';
        let startYearVal = '';
        let endMonthVal = '';
        let endYearVal = '';
        let newEndDateStr = '';
        let newEndDate = new Date();
        let newStartDateStr = '';
        let newStartDate = new Date();
        // Remove the Error Elements by Class Name
        if(this.template.querySelectorAll('.startEndDateError') !== null){
            this.template.querySelectorAll('.startEndDateError').forEach(element => element.remove());
        }
        this.template.querySelectorAll('.endMonth').forEach(element => {
            if(element.value !== '' || element.value !== null){
                endMonthVal = element.value;
                //get end year
                endYearVal = element.parentNode.parentNode.querySelector('.endYear').value;
                //start month & start year
                startMonthVal = element.parentNode.parentNode.parentNode.querySelector('.startMonth').value;
                startYearVal = element.parentNode.parentNode.parentNode.querySelector('.startYear').value;
                //construct end date
                if(endMonthVal !== '' && endMonthVal !== null && endYearVal !== '' && endYearVal !== null && startMonthVal !== '' && startMonthVal !== null && startYearVal !== '' && startYearVal !== null){
                    newEndDateStr = endYearVal + '-' + endMonthVal + '-' + '01';
                    newEndDate = new Date(newEndDateStr);
                    //start date
                    newStartDateStr = startYearVal + '-' + startMonthVal + '-' + '01';
                    newStartDate = new Date(newStartDateStr);
                    if(Date.parse(newEndDate) < Date.parse(newStartDate)){
                        //add the code for tags
                        let elem = document.createElement("div");
                        elem.id = 'startEndDateError';
                        elem.setAttribute('class', 'startEndDateError');
                        elem.textContent = endDateGreaterThanStartDate;
                        elem.style = 'color:#ff0000; clear:both;';
                        element.classList.add('slds-has-error');
                        element.parentNode.insertBefore(elem, element.nextSibling);
                    }
                    if(Date.parse(newEndDate) === Date.parse(newStartDate)){
                        //dates are same
                        let elem = document.createElement("div");
                        elem.id = 'startEndDateError';
                        elem.setAttribute('class', 'startEndDateError');
                        elem.textContent = startDateAndEndDateNotSame;
                        elem.style = 'color:#ff0000; clear:both;';
                        element.classList.add('slds-has-error');
                        element.parentNode.insertBefore(elem, element.nextSibling);
                    }
                }
            }
        });
        this.template.querySelector('.slds-has-error').scrollIntoView();
    }
    showAttendedYearsFunc(){
        this.template.querySelectorAll('.attendedYearsError').forEach(element => element.remove());
        this.template.querySelectorAll('.attendedYears').forEach(element => {
            let decimalCount;
            if(element.value === '' || parseFloat(element.value) <= parseFloat('0') || parseFloat(element.value) > parseFloat('20')){
                let elem = document.createElement("div");
                elem.id = 'attendedYearsError';
                elem.setAttribute('class', 'attendedYearsError');
                elem.textContent = 'Please enter valid number of years attended';
                if(parseFloat(element.value) > parseFloat('20')){
                    elem.textContent = 'Maximum number of years allowed is 20';
                }
                elem.style = 'color:#ff0000; clear:both;';
                element.classList.add('slds-has-error');
                element.parentNode.insertBefore(elem, element.nextSibling);
            }else{
                if((Math.floor(parseFloat(element.value)) === parseFloat(element.value))){
                    decimalCount = 0;
                }else{
                    decimalCount = element.value.split(".")[1].length;
                }
                if(decimalCount > 2){
                    element.classList.add('slds-has-error');
                }
            }
        });
        this.template.querySelector('.slds-has-error').scrollIntoView();
    }
    showBlankNameErrorFunc(){
        // Remove the Error Elements by Class Name
        this.template.querySelectorAll('.blankNameError').forEach(element => element.remove());
        this.template.querySelectorAll('.tctName').forEach(element => {
            if(element.value === ''){
                let elem = document.createElement("div");
                elem.id = 'blankNameError';
                elem.setAttribute('class', 'blankNameError');
                elem.textContent = 'Please enter your name exactly as it appears on the document.';
                elem.style = 'color:#ff0000; clear:both;';
                element.classList.add('slds-has-error');
                element.parentNode.insertBefore(elem, element.nextSibling);
            }
        });
        this.template.querySelector('.slds-has-error').scrollIntoView();
    }
    showTctMissingError(){
        // Remove the Error Elements by Class Name
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
                }
            });
        }
        this.template.querySelector('.tctMissingError').scrollIntoView();
    }
    showTranslationDocMissingError(){
        // Remove the Error Elements by Class Name
        if(this.template.querySelectorAll('.translationDocMissingError') !== null){
            this.template.querySelectorAll('.translationDocMissingError').forEach(element => element.remove());
        }
        if(this.template.querySelectorAll('.tctTranslationId') !== null){
            this.template.querySelectorAll('.tctTranslationId').forEach(elem => {
                if(elem.getAttribute('data-asset-url') === '' ||
                    elem.getAttribute('data-asset-url') === 'true' ||
                    elem.getAttribute('data-asset-url') === null ||
                    elem.getAttribute('data-asset-url') === 'undefined'){
                    let errorElem = document.createElement("div");
                    errorElem.id = 'translationDocMissingError';
                    errorElem.setAttribute('class', 'translationDocMissingError');
                    errorElem.textContent = 'Please upload the Transfer Credit Transcript Translation Document';
                    errorElem.style = 'color:#ff0000; clear:both;';
                    if(getClosest(elem, '.recordFieldsWrapper').querySelectorAll('.translationDocMissingError').length === 0){
                        getClosest(elem, '.recordFieldsWrapper').querySelector('.tctTranslationDoc').appendChild(errorElem);
                    }
                }
            });
        }
        this.template.querySelector('.translationDocMissingError').scrollIntoView();
    }
    showCourseBlankError(){
        // Remove the Error Elements by Class Name
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
        // Remove the Error Elements by Class Name
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
        // Remove the Error Elements by Class Name
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
        // Remove the Error Elements by Class Name
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
        // Remove the Error Elements by Class Name
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
        // Remove the Error Elements by Class Name
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
            if(element.value !== '' && parseInt(element.value, 10) > parseInt(year, 10)){
                futuredateerror = true;
            }else if(element.value !== '' && parseInt(element.value, 10) === parseInt(year, 10)){
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
                        if(monthVal1 > parseInt(mon, 10)){
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
    showTransferCreditError(){
        this.template.querySelector(".notificationMessageDiv").textContent = '';
        let elem = document.createElement("span");
        elem.id = 'errorDiv';
        elem.setAttribute('class', 'errorDiv');
        elem.textContent = 'You can transfer Credits only from one Medical School';
        let errorText = 'You can transfer Credits only from one Medical School.';
        if(this.showExamRegActionButton){
            errorText += ' Please contact ECFMG Admin Team.';
        }
        elem.textContent = errorText;
        elem.style = 'color:#ff0000; clear:both;';
        this.template.querySelector(".notificationMessageDiv").appendChild(elem);
        window.scrollTo(0, 0);
    }
    removeTransferCreditError(){
        this.template.querySelector(".notificationMessageDiv").textContent = '';
    }
    showSuccessfulSave(){
        this.template.querySelector(".notificationMessageDiv").textContent = '';
        let elem = document.createElement("span");
        elem.id = 'successDiv';
        elem.setAttribute('class', 'successDiv');
        elem.textContent = 'Data Successfully Saved';
        elem.style = 'color:#4BB543;font-size: 13px;';
        this.template.querySelector(".notificationMessageDiv").appendChild(elem);
        window.scrollTo(0, 0);
    }
    prevButton(event){
        event.preventDefault();
        this.recordsList = [];
        this.changedSchools = {};
        this.recordsListAfterDelete = [];
        //delete unsaved TCT assets
        markTctAssetsForDeletion({
            contactId: this.contactId,
            caseId: this.caseId
        });
        const selectEvent = new CustomEvent('previousevent', {});
        this.dispatchEvent(selectEvent);
    }
    nextButton(event){
        event.preventDefault();
        this.clickedBtn = 'Next';
        let allWrapper = this.template.querySelectorAll(".recordFieldsWrapper");
        let proceedNext = true;
        allWrapper.forEach(function (element){
            let tempSchoolRecord = {
                recordIdVal: element.getAttribute('data-record-id'),
                otherSchool: element.querySelector(".otherSchoolRecord").value,
                otherSchoolId: element.querySelector(".otherSchoolRecord").getAttribute('data-otherschool-id'),
                schoolProgram: element.querySelector(".schoolProgram").value,
                studentId: element.querySelector(".studentId").value,
                Specialty: element.querySelector(".speciality").value,
                startMonth: element.querySelector(".startMonth").value,
                startYear: element.querySelector(".startYear").value,
                endMonth: element.querySelector(".endMonth").value,
                endYear: element.querySelector(".endYear").value,
                transferCreditsCheckbox: element.querySelector(".transferCreditsCheckbox").checked
            }
            if(tempSchoolRecord.recordIdVal !== '' ||
                tempSchoolRecord.otherSchool !== '' ||
                tempSchoolRecord.otherSchoolId !== '' ||
                tempSchoolRecord.schoolProgram !== '' ||
                tempSchoolRecord.studentId !== '' ||
                tempSchoolRecord.Specialty !== '' ||
                tempSchoolRecord.startMonth !== '' ||
                tempSchoolRecord.startYear !== '' ||
                tempSchoolRecord.endMonth !== '' ||
                tempSchoolRecord.endYear !== '' ||
                tempSchoolRecord.transferCreditsCheckbox !== false){
                proceedNext = false;
            }
        });
        if(!proceedNext){
            this.saveRecords();
        }else{
            this.updateCATDeletedOnResubmission();
            const selectEvent = new CustomEvent('nextevent', {});
            this.dispatchEvent(selectEvent);
        }
    }
    updateCATDeletedOnResubmission(){
        updateCATDeletedOnResubmission({recordTypeDevName : 'Medical_School'});
    }
    saveButton(event){
        event.preventDefault();
        this.clickedBtn = 'Save';
        this.saveRecords();
    }
    cancelButton(event){
        event.preventDefault();
        //delete unsaved TCT assets
        markTctAssetsForDeletion({
            contactId: this.contactId,
            caseId: this.caseId
        });
        const selectEvent = new CustomEvent('cancelevent', {});
        this.dispatchEvent(selectEvent);
    }
    discardButton(event){
        event.preventDefault();
        let assetIdsToBeDeleted = this.template.querySelector(".assetIdsCollection").getAttribute("data-asset-id");
        const selectEvent = new CustomEvent('discardevent', {
            detail: {
                eventSource: 'otherMedSchool',
                performDelete: !arrayEquals(assetIdsToBeDeleted.split(','), this.assetIdsCollection),
                assetIdsToBeDeleted: assetIdsToBeDeleted
            }
        });
        this.dispatchEvent(selectEvent);
    }
    @api deleteOnDiscardEvent(assetIdsToBeDeleted){
        markAssetsForDeletion({
            assetIdsString: assetIdsToBeDeleted
        });
    }
    validateTransferCreditGradeInput(event){
        // prevent letter e which is considered as exponential in number field, minus symbol and hyphen
        if(event.which === 69 || event.which === 109 || event.which === 189){
            event.preventDefault();
        }
        //prevent extra decimal points
        if(event.which === 110 && event.target.value.includes(".")){
            event.preventDefault();
        }
        if(event.target.value.includes(".")){
            // prevent more than 5 characters if it's a decimal number i.e. xx.xx format; but allow backspace/tab
            if(event.target.value.length === 5 && event.which !== 8 && event.which !== 9){
                event.preventDefault();
            }
        }else{
            // prevent more than 2 characters if it's a non-decimal number i.e. xx format; but allow backspace/tab or decimal
            if(event.target.value.length === 2 && event.which !== 8 && event.which !== 9 && event.which !== 110 && event.which !== 190){
                event.preventDefault();
            }
        }
    }
    deleteSchoolRecord(event){
        this.removeTransferCreditError();
        this.deleteOtherSchoolId = event.currentTarget.getAttribute('data-deleteotherschool-id');
        this.eventDataOtherSchool = getClosest(event.target, '.recordFieldsWrapper');
        this.eventDataOtherSchool.classList.add('currentRecordFieldsWrapper');
        this.template.querySelector('[data-id="newModalAlert"]').show();
    }
    deleteCATRecords(event){
        this.spinner = true;
        let currentSchoolRecordId = this.eventDataOtherSchool.getAttribute('data-record-id');
        let currentSchoolRecordIndex = parseInt(this.eventDataOtherSchool.getAttribute('data-record-index'), 10);
        if(currentSchoolRecordId != ''){
            // Deleting CATS record (Contact_Association_Type_Staging__c) and Asset        
            deleteCATRecAndAssets({
                catsRecordId: currentSchoolRecordId,
                caseId: this.caseId
            }).catch(error => {
                this.spinner = false;
                window.console.error('Error: ' + JSON.stringify(error));
            });
            // Getting Data Asset URL and markAssetsForDeletionWithUrlList
            let assetsToBeUpdated = markAssetsForDeletionWithUrlHelper(this.eventDataOtherSchool);        
            if(assetsToBeUpdated.length){
                markAssetsForDeletionWithUrlList({
                    assetUrlsString: JSON.stringify(assetsToBeUpdated)
                });
            }
        }
        // Other Medical School - Creating new array with missing recordsList Index
        let newChangedSchools = updatedChangedSchools(this, currentSchoolRecordIndex, this.changedSchools);
        if(this.recordsList.length !== Object.keys(this.changedSchools).length){
            for(let i in this.recordsList){
                if(newChangedSchools[this.recordsList[i].sno] === undefined){
                    let emptyMedChangeSchool = {
                        index: this.recordsList[i].sno,
                        schoolInput: '',
                        schoolId: ''
                    };
                    newChangedSchools[this.recordsList[i].sno] = emptyMedChangeSchool;
                }
            }
        }
        // Recordlist new array
        let newsetRecordsList = [];
        let newMedChangedSchools = {};
        for(let i in this.recordsList){
            if(this.recordsList[i].sno !== currentSchoolRecordIndex){
                newsetRecordsList.push(this.recordsList[i]);
                // Changed School new array                
                newMedChangedSchools[this.recordsList[i].sno] = newChangedSchools[this.recordsList[i].sno];
            }
        }
        this.refreshApexFlag = false;
        if(newsetRecordsList.length === 0){
            this.template.querySelectorAll('.otherSchoolRecord').forEach(element=>{
                element.setAttribute('data-otherschool-id','');
            });
            this.recordsList = [];
            this.changedSchools = {};
            this.recordsListAfterDelete = [];
            this.spinner = false;
            if(this.showExamRegActionButton === false){
                this.addNewMedicalSchoolRecord('auto');
            }
        }else{
            let recordsListExamRegLength = 0;
            if(this.showExamRegActionButton === true){
                recordsListExamRegLength = this.recordsListExamRegReadOnly.length;
            }
            // Other Medical School - Sorting Array by keys           
            this.changedSchools = getNewChangedSchools(newsetRecordsList, newMedChangedSchools, recordsListExamRegLength);
            this.recordsList = getNewRecordsLists(newsetRecordsList, newMedChangedSchools, recordsListExamRegLength);            
        }
        this.recordsListAfterDelete = this.recordsList;
        this.deleteSchoolFlag = true;
        this.spinner = false;
    }
    closeModal(event){
        this.template.querySelector('[data-id="newModalAlert"]').hide();
    }
    closeModalTCT(event){
        this.template.querySelector('[data-id="newModalAlertTCT"]').hide();
        event.target.checked = true;
    }
    deleteTCTRecords(event){
        this.template.querySelector('.transferCreditsDegreeCheckbox.currentCheckbox').parentNode.querySelectorAll('.transferCreditSection').forEach(element=>{
            element.style.display = 'none';
        });
        markAssetsForDeletionWithUrlList({
            assetUrlsString: JSON.stringify(this.assetUrlsCollection)
        });
        this.handleUncheckTransferCredits(event, index, closestOtherMedSchool);
    }
}