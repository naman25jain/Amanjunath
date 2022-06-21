import{LightningElement, track, wire, api} from 'lwc';
import{NavigationMixin} from 'lightning/navigation';
import{getPicklistValues, getObjectInfo} from 'lightning/uiObjectInfoApi';
import diplomaDocument from '@salesforce/label/c.App_for_Cert_DIPLOMA_DOCUMENT';
import diplomaDocumentUpload from '@salesforce/label/c.App_for_Cert_Upload_Diploma';
import diplomaisMandatory from '@salesforce/label/c.App_for_Cert_Error_Upload_Diploma';
import transcriptUpload from '@salesforce/label/c.App_for_Cert_Upload_Final_Transcript';
import getSchoolRecords from '@salesforce/apex/AppForCertController.getOtherMedicalSchoolRecords';
import CONTACT_ASSOCIATION_TYPE_STAGING_OBJECT from '@salesforce/schema/Contact_Association_Type_Staging__c';
import START_MONTH_FIELD from '@salesforce/schema/Contact_Association_Type_Staging__c.Start_Month__c';
import END_MONTH_FIELD from '@salesforce/schema/Contact_Association_Type_Staging__c.End_Month__c';
import GRADUATION_MONTH_FIELD from '@salesforce/schema/Contact_Association_Type_Staging__c.Graduation_Month__c';
import finalMedicalSchoolTranscriptTranslationDocument from '@salesforce/label/c.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_TRANSLATION_DOCUMENT';
import finalMedicalSchoolTranscriptNameDocument from '@salesforce/label/c.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_NAME_DOCUMENT';
import finalMedicalSchoolTranscriptDocument from '@salesforce/label/c.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_DOCUMENT';
import diplomaDocumentUploadNameDocumentation from '@salesforce/label/c.App_for_Cert_Upload_Name_Documentation';
import diplomaDocumentUploadTranslation from '@salesforce/label/c.App_for_Cert_Upload_Diploma_Translation';
import graduateScreenNameonDocMessage from '@salesforce/label/c.App_for_Cert_Name_on_Document';
import diplomaNameDocument from '@salesforce/label/c.App_for_Cert_DIPLOMA_NAME_DOCUMENT';
import transcriptTranslationUpload from '@salesforce/label/c.App_for_Cert_Upload_Transcript_Translation';
import diplomaTranslationDocument from '@salesforce/label/c.App_for_Cert_DIPLOMA_TRANSLATION_DOCUMENT';
import diplomaDocumentTranslationMandatory from '@salesforce/label/c.App_for_Cert_Error_Upload_Diploma_Translation';
import finalMedicalSchoolTranscriptTranslationMandatory from '@salesforce/label/c.App_for_Cert_Error_Upload_Final_Transcript_Translation';
import getContact from '@salesforce/apex/AppForCertController.getContactName';
import getContactId from '@salesforce/apex/AppForCertController.getContactId';
import checkRejectedAffirmations from '@salesforce/apex/EcfmgCertDefScreenController.checkRejectedAffirmations';
import getECFMGCertCase from '@salesforce/apex/EcfmgCertDefScreenController.getECFMGCertCase';
import getMedicalSchoolWithTc from '@salesforce/apex/EcfmgCertDefScreenController.getMedicalSchoolWithTc';
import markAssetsForDeletionGivenConId from '@salesforce/apex/EcfmgCertDefScreenController.markAssetsForDeletion';
import markAssetsForDeletionGivenAssetIds from '@salesforce/apex/EpicCredVerController.markAssetsForDeletion';
import getRejectedAffirmationLang from '@salesforce/apex/EcfmgCertDefScreenController.getRejectedAffirmationLang';
import resubmitCredential from '@salesforce/apex/EcfmgCertDefScreenController.resubmitCredential';
import getCaseStatus from '@salesforce/apex/CloudStorageController.getCaseStatus';
import endDateGreaterThanStartDate from '@salesforce/label/c.End_date_always_greater_than_Start_date';
export default class EcfmgCertDeficiencyScreen extends NavigationMixin(LightningElement){
    label ={
        diplomaDocumentUpload,
        diplomaisMandatory,
        diplomaDocumentUploadNameDocumentation,
        graduateScreenNameonDocMessage,
        diplomaDocumentUploadTranslation,
        diplomaDocumentTranslationMandatory,
        transcriptUpload,
        transcriptTranslationUpload,
        finalMedicalSchoolTranscriptTranslationMandatory
    };
    @track deficiencyLanguage = 'Deficiency language will be placed here.'
    @track diplomaRejected = false;
    @track isErrMsgFinalMedTransDetails = false;
    @track isFinalMedicalTranscriptDifferent = false;
    @track payloadFinalMedDiploma;
    @track nameonDiplomaDocumentVal;
    @track nameonDiplomaDocument;
    @track isFinalMedicalTranscriptinEnglish;
    @track nameonFinalTranscriptDocument;
    @track payloadFinalMedSchoolTranscript;
    @track showTranscriptNameDocButton;
    @track payloadFMTranscriptNameDoc;
    @track tctPayload;
    @track tctTransNeeded = false;
    @track tctTransPayload;
    @track rejLangTCT = [];
    @track rejLangFD = [];
    @track rejLangFT = [];
    @track tempPayloadFinalDiploma ={
        documentType: 'Final Medical Diploma',
        assetRecordType: 'Credential',
        createOrReplace: 'Create',
        assetStatus: 'In Progress',
        assetCreationRequired: 'true',
        assetId: null,
        caseId: null,
        key: diplomaDocument,
        createFromPB: 'true'
    };
    @track tempPayloadTct ={
        documentType: 'Transfer Credit Transcript',
        assetRecordType: 'Credential',
        createOrReplace: 'Create',
        assetStatus: 'In Progress',
        assetCreationRequired: 'true',
        assetId: null,
        caseId: null,
        key:'Transfer Credit Transcript Document',
        createFromPB: 'true'
    };
    @track tempPayloadTctTrans ={
        documentType: 'TCT Translation',
        assetRecordType: 'Credential',
        createOrReplace: 'Create',
        assetStatus: 'In Progress',
        assetCreationRequired: 'true',
        assetId: null,
        caseId: null,
        key: 'Transfer Credit Transcript Translation Document',
        parentKey: 'Transfer Credit Transcript Document',
        createFromPB: 'true'
    };
    @track tempPayloadFMT ={
        documentType: "Final Medical School Transcript",
        assetRecordType: 'Credential',
        createOrReplace: 'Create',
        assetStatus: 'In Progress',
        assetCreationRequired: 'true',
        assetId: null,
        caseId: null,
        key: finalMedicalSchoolTranscriptDocument,
        createFromPB: 'true'
    };
    @track tempPayloadtctNameDoc ={
        documentType: 'Name Document',
        assetRecordType: 'Identity',
        createOrReplace: 'Create',
        assetStatus: 'In Progress',
        assetCreationRequired: 'true',
        assetId: null,
        caseId: null,
        key: 'Transfer Credit Transcript Name Document',
        parentKey: 'Transfer Credit Transcript Document',
        createFromPB: 'true'
    };
    @track tempPayloadfmdNameDoc ={
        documentType: 'Name Document',
        assetRecordType: 'Identity',
        createOrReplace: 'Create',
        assetStatus: 'In Progress',
        assetCreationRequired: 'true',
        assetId: null,
        caseId: null,
        key: diplomaNameDocument,
        parentKey: diplomaDocument,
        createFromPB: 'true'
    };
    @track tempPayloadfmtNameDoc ={
        documentType: 'Name Document',
        assetRecordType: 'Identity',
        createOrReplace: 'Create',
        assetStatus: 'In Progress',
        assetCreationRequired: 'true',
        assetId: null,
        caseId: null,
        key: finalMedicalSchoolTranscriptNameDocument,
        parentKey: finalMedicalSchoolTranscriptDocument,
        createFromPB: 'true'
    };
    @track tempPayloadFMDTrans ={
        documentType: 'Final Diploma Translation',
        assetRecordType: 'Credential',
        createOrReplace: 'Create',
        assetStatus: 'In Progress',
        assetCreationRequired: 'true',
        assetId: null,
        caseId: null,
        key: diplomaTranslationDocument,
        parentKey: diplomaDocument,
        createFromPB: 'true'
    };
    @track tempPayloadFMTTrans ={
        documentType: 'Final Transcript Translation',
        assetRecordType: 'Credential',
        createOrReplace: 'Create',
        assetStatus: 'In Progress',
        assetCreationRequired: 'true',
        assetId: null,
        caseId: null,
        key: finalMedicalSchoolTranscriptTranslationDocument,
        parentKey: finalMedicalSchoolTranscriptDocument,
        createFromPB: 'true'
    };
    @track payloadFMDTransDoc;
    @track spinner = false;
    @track transferCreditsCheckbox = true;
    @track payloadFMDNameDoc;
    @track contactId;
    @track selectedMedicalSchoolId;
    @track showFMTranscriptTransDocButton;
    @track contactName;
    @track isPrimaryDiplomaUploaded = false;
    @track isDiplomaNameDifferent;
    @track isDiplomaNameinEnglish;
    @track isErrMsgDipTransDetails = false;
    @track showDipTransDocButton;
    @track isErrMsgDipDetails = false;
    @track isErrMsgDipName = false;
    @track showDipNameDocButton;
    @track isDiplomaEnglishUploaded = false;
    @track transcriptRejected = false;
    @track isPrimaryTranscriptUploaded = false;
    @track isErrMsgTranscriptDetails;
    @track isErrMsgTranscriptName = false;
    @track isTranscriptEnglishUploaded = false;
    @track nameonFinalDocumentVal;
    @track payloadFMTranscriptTransDoc;
    @track tctNameDocPayload;
    @track validSchoolRecords;
    validSchoolRecordIds = [];
    @track medicalSchool = '';
    @track placeholder = 'Select';
    @track tctRejected = false;
    @track startMonthPicklistOptions = [];
    @track endMonthPicklistOptions = [];
    @track startMonth;
    @track readOnly = false;
    @track endMonth;
    @track startYear;
    @track endYear;
    @track numberOfYears;
    @track program;
    @track caseId;
    @api recordId;
    @track studentId;
    @track speciality;
    @track nameonTctDocument;
    @track tctAssetIdUpdated = true;
    @track tctNameDocNeeded = false;
    @track tctUploaded = false;
    @track isErrMsgTctDetails = false;
    @track isErrMsgTctName = false;
    @track isTctEnglishUploaded = false;
    @track isErrMsgTctTransDetails = false;
    @track showTable = true;
    @track recordIdVal;
    @track tctUrl = null;
    @track tctNameUrl = null;
    @track tctTransUrl = null;
    @track FMDUrl = null;
    @track FMDTransUrl = null;
    @track FMDNameUrl = null;
    @track FMTUrl = null;
    @track FMTTransUrl = null;
    @track FMTNameUrl = null;
    tcWrapperList = [{
        tcId: '1',
        transferCreditCourse: '',
        transferCreditGrade: '',
        courseOutcome: '',
        creditsEarnedMonth: '',
        creditsEarnedYear: ''
    }];
    get options(){
        return [{
            label: 'Pass',
            value: 'Pass'
        },{
            label: 'Fail',
            value: 'Fail'
        }, ];
    }
    @wire(getObjectInfo,{
        objectApiName: CONTACT_ASSOCIATION_TYPE_STAGING_OBJECT
    })
    objectInfo;
    @track monthPicklistOptions = [];
    @wire(getSchoolRecords) schoolRecordValues({
        error,
        data
    }){
        if(data){
            this.validSchoolRecords = data;
            for(let schoolRecord of data){
                this.validSchoolRecordIds.push(schoolRecord.Id);
            }
        }else if(error){
            window.console.log('Error: ' + JSON.stringify(error));
        }
    }
    @wire(getPicklistValues,{
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: START_MONTH_FIELD
    }) startMonthPicklistValues({
        error,
        data
    }){
        if(data){
            this.startMonthPicklistOptions = data.values;
        }else if(error){
            window.console.log('Error: ' + JSON.stringify(error));
        }
    }
    @wire(getPicklistValues,{
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: END_MONTH_FIELD
    }) endMonthPicklistValues({
        error,
        data
    }){
         if(data){
             this.endMonthPicklistOptions = data.values;
        }else if(error){
            window.console.log('Error: ' + JSON.stringify(error));
        }
    }
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
            window.console.log('Error: ' + JSON.stringify(error));
        }
    }
    loadDefLanguages(){
        getRejectedAffirmationLang({
            caseId: this.caseId,
            affrmType: 'TCT'
        }).then(rejectedListLangTCT =>{
            this.rejLangTCT = rejectedListLangTCT;
        })
        getRejectedAffirmationLang({
            caseId: this.caseId,
            affrmType: 'FD'
        }).then(rejectedListLangFD =>{
            this.rejLangFD = rejectedListLangFD;
        })
        getRejectedAffirmationLang({
            caseId: this.caseId,
            affrmType: 'FT'
        }).then(rejectedListLangFT =>{
            this.rejLangFT = rejectedListLangFT;
        })
    }
    connectedCallback(){
        this.spinner = true;
        getContactId().then(result =>{
            if(result){
                this.contactId = result;
                this.tempPayloadFinalDiploma.contactId = this.contactId;
                this.tempPayloadtctNameDoc.contactId = this.contactId;
                this.tempPayloadfmdNameDoc.contactId = this.contactId;
                this.tempPayloadfmtNameDoc.contactId = this.contactId;
                this.tempPayloadFMDTrans.contactId = this.contactId;
                this.tempPayloadFMT.contactId = this.contactId;
                this.tempPayloadFMTTrans.contactId = this.contactId;
                this.tempPayloadTct.contactId = this.contactId;
                this.tempPayloadTctTrans.contactId = this.contactId;
                this.payloadFinalMedDiploma = JSON.stringify(this.tempPayloadFinalDiploma);
                this.payloadFMDNameDoc = JSON.stringify(this.tempPayloadfmdNameDoc);
                this.payloadFMDTransDoc = JSON.stringify(this.tempPayloadFMDTrans);
                this.payloadFinalMedSchoolTranscript = JSON.stringify(this.tempPayloadFMT);
                this.payloadFMTranscriptNameDoc = JSON.stringify(this.tempPayloadfmtNameDoc);
                this.payloadFMTranscriptTransDoc = JSON.stringify(this.tempPayloadFMTTrans);
                this.tctPayload = JSON.stringify(this.tempPayloadTct);
                this.tctTransPayload = JSON.stringify(this.tempPayloadTctTrans);
                this.tctNameDocPayload = JSON.stringify(this.tempPayloadtctNameDoc);
                markAssetsForDeletionGivenConId({
                    contactId: this.contactId
                });
                getContact({
                    contactId: this.contactId
                }).then(result1 =>{
                     if(result1 !== '' && result1 !== undefined && result1 !== null){
                        this.contactName = JSON.stringify(result1).replace('"', '').replace('"', '');
                    }
                 })
                getECFMGCertCase({                    
                    contactId: this.contactId
                }).then(caseId =>{
                    if(caseId === null){
                        this.navigateToMyCases();
                    }else{
                        getCaseStatus({
                            caseId: caseId
                        }).then(caseStatus =>{
                            if(!caseStatus.includes('Pending Applicant Action - Resubmit Documents')){
                                this.navigateToMyCases();
                            }
                        });
                    }
                    this.caseId = caseId;
                    this.recordId = caseId;
                    this.loadDefLanguages();
                    checkRejectedAffirmations({
                        caseId: this.caseId
                    }).then(rejectedList =>{
                         if(rejectedList.includes('Final Diploma')){
                             this.diplomaRejected = true;
                        }
                        if(rejectedList.includes('Final Transcript')){
                            this.transcriptRejected = true;
                        }
                        if(rejectedList.includes('TCT')){
                            getMedicalSchoolWithTc({
                                contactId: this.contactId
                            }).then(medSchool =>{
                                this.tctRejected = true;
                                if(medSchool){
                                    this.readOnly = true;
                                    this.recordIdVal = medSchool.recordIdVal;
                                    this.medicalSchool = medSchool.otherSchool;
                                    this.selectedMedicalSchoolId = medSchool.otherSchoolId;
                                    this.numberOfYears = medSchool.numberOfYearsAttended;
                                    this.program = medSchool.schoolProgram;
                                    this.speciality = medSchool.specialty;
                                    this.studentId = medSchool.studentId;
                                    this.endMonth = medSchool.endMonth;
                                    this.startMonth = medSchool.startMonth;
                                    this.endYear = medSchool.endYear;
                                    this.startYear = medSchool.startYear;
                                     if(medSchool.hasOwnProperty('tcWrapperList')){
                                        this.tcWrapperList = [];
                                        for(let i = 0; i < medSchool.tcWrapperList.length; i++){
                                            let tempTc ={
                                                tcId: medSchool.tcWrapperList[i].recordIdVal,
                                                transferCreditCourse: medSchool.tcWrapperList[i].transferCreditCourse,
                                                transferCreditGrade: medSchool.tcWrapperList[i].transferCreditGrade,
                                                courseOutcome: medSchool.tcWrapperList[i].courseOutcome,
                                                creditsEarnedMonth: medSchool.tcWrapperList[i].creditsEarnedMonth === undefined ? '' : medSchool.tcWrapperList[i].creditsEarnedMonth,
                                                creditsEarnedYear: medSchool.tcWrapperList[i].creditsEarnedYear === undefined ? '' : medSchool.tcWrapperList[i].creditsEarnedYear,
                                            }
                                            this.tcWrapperList.push(tempTc);
                                        }
                                    }
                                }
                            })
                        }
                        this.spinner = false;
                    })
                })
            }
        })
    }
    navigateToMyCases(){
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes:{
                url: '/s/my-cases'
            }
        });
    }
    renderedCallback(){
        if(this.template.querySelector('datalist.schoolRecordDatalist') !== null){
            let listId = this.template.querySelector('datalist.schoolRecordDatalist').id;
            this.template.querySelector("input.schoolRecord").setAttribute("list", listId);
        }
        // rendering js for table
        this.template.querySelectorAll('.tcMainSection').forEach(elem =>{
            if(!elem.classList.contains('creditsDate')){
                elem.style.display = 'block';
            }else{
                elem.style.display = 'flex';
            }
        });
        // code to set maxlength for Year fields
        if(this.template.querySelectorAll('.creditEarnedYearInput') !== null){
            this.template.querySelectorAll('.creditEarnedYearInput').forEach(element =>{
                element.setAttribute("maxlength", "4");
            });
        }
        // code to hide delete icon for only one TC Row
        if(this.template.querySelectorAll('.tcTable') !== null){
            this.template.querySelectorAll('.tcTable').forEach(element =>{
                if(element.querySelectorAll('.tcDetailsRow').length === 1){
                    element.querySelectorAll('.delete-icon').forEach(elem =>{
                        elem.style.display = 'none';
                    });
                }else{
                    element.querySelectorAll('.delete-icon').forEach(elem =>{
                        elem.style.display = 'block';
                    });
                }
            });
        }
    }
    handleDiplomaUpload(event){
        this.FMDUrl = event.detail.url;
        this.tempPayloadfmdNameDoc.parentUrl = event.detail.url;
        this.tempPayloadFMDTrans.parentUrl = event.detail.url;
        this.payloadFMDNameDoc = JSON.stringify(this.tempPayloadfmdNameDoc);
        this.payloadFMDTransDoc = JSON.stringify(this.tempPayloadFMDTrans);
        this.isPrimaryDiplomaUploaded = true;
        this.isErrMsgDipDetails = false;
    }
    handleChangeDiplomaNameDifferent(event){
        this.isDiplomaNameDifferent = event.target.checked;
        if(event.target.checked){
            this.showDipNameDocButton = true;
        }else{
            let tempPayload = JSON.parse(this.payloadFMDNameDoc);
             if(this.FMDNameUrl){
                markAssetsForDeletionGivenAssetIds({
                    azureUrl: this.FMDNameUrl
                });
                this.FMDNameUrl = null;
                this.payloadFMDNameDoc = JSON.stringify(tempPayload);
            }
        }
    }
    handleChangeDiplomaInEnglish(event){
        this.isDiplomaNameinEnglish = event.target.checked;
        if(event.target.checked){
            this.showDipTransDocButton = true;
        }else{
             if(this.FMDTransUrl){
                markAssetsForDeletionGivenAssetIds({
                    azureUrl: this.FMDTransUrl
                });
                this.FMDTransUrl = null;
            }
        }
    }
    handleChangeForInputFields(event){
        if(event.target.name === 'nameonDiplomaDocument'){
            this.nameonDiplomaDocument = event.target.value;
            this.isErrMsgDipName = false;
        }
        if(event.target.name === 'nameonFinalTranscriptDocument'){
            this.nameonFinalTranscriptDocument = event.target.value;
            this.isErrMsgTranscriptName = false;
        }
        if(event.target.name === 'nameonTctDocument'){
            this.nameonTctDocument = event.target.value;
            this.isErrMsgTctName = false;
        }
    }
    handleOnDiplomaEnglish(event){
        this.FMDTransUrl = event.detail.url;
        this.isErrMsgDipTransDetails = false;
        this.isDiplomaEnglishUploaded = true;
    }
    handleOnDiplomaNameDoc(event){
        this.FMDNameUrl = event.detail.url;
    }
    handleOnTranscript(event){
        this.FMTUrl = event.detail.url;
        this.tempPayloadFMTTrans.parentUrl = event.detail.url;
        this.tempPayloadfmtNameDoc.parentUrl = event.detail.url;
        this.payloadFMTranscriptTransDoc = JSON.stringify(this.tempPayloadFMTTrans);
        this.payloadFMTranscriptNameDoc = JSON.stringify(this.tempPayloadfmtNameDoc);
        this.isPrimaryTranscriptUploaded = true;
        this.isErrMsgTranscriptDetails = false;
     }
    handleChangeFMTNameDifferent(event){
        this.isFinalMedicalTranscriptDifferent = event.target.checked;
        if(event.target.checked){
            this.showTranscriptNameDocButton = true;
        }else{
            let tempPayload = JSON.parse(this.payloadFMTranscriptNameDoc);
             if(this.FMTNameUrl){
                markAssetsForDeletionGivenAssetIds({
                    azureUrl: this.FMTNameUrl
                });
                this.FMTNameUrl = null;
                this.payloadFMTranscriptNameDoc = JSON.stringify(tempPayload);
            }
        }
    }
    handleChangeFinalMedicalTranscriptinEnglish(event){
        this.isFinalMedicalTranscriptinEnglish = event.target.checked;
        if(event.target.checked){
            this.showFMTranscriptTransDocButton = true;
        }else{
            let tempPayload = JSON.parse(this.payloadFMTranscriptTransDoc);
             if(this.FMTTransUrl){
                markAssetsForDeletionGivenAssetIds({
                    azureUrl: this.FMTTransUrl
                });
                this.FMTTransUrl = null;
                this.payloadFMTranscriptTransDoc = JSON.stringify(tempPayload);
            }
        }
    }
    handleOnTranscriptEnglish(event){
        this.FMTTransUrl = event.detail.url;
        this.isErrMsgFinalMedTransDetails = false;
        this.isTranscriptEnglishUploaded = true;
    }
    handleOnTranscriptNameDoc(event){
        this.FMTNameUrl = event.detail.url;
    }
    handleSchoolChange(event){
        this.medicalSchool = event.target.value;
        this.selectedMedicalSchoolId = this.template.querySelector(".schoolRecordDatalist option[value=\"" + event.target.value + "\"]").getAttribute("data-entityid");
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
        if(event.target.name === 'numberOfYears'){
            this.numberOfYears = event.target.value;
        }
        if(event.target.name === 'program'){
            this.program = event.target.value;
        }
        if(event.target.name === 'studentId'){
            this.studentId = event.target.value;
        }
        if(event.target.name === 'speciality'){
            this.speciality = event.target.value;
        }
    }
    preventDecimal(event){
        if(event.key === '.'){
            event.preventDefault();
        }
    }
    addTcRow(){
        this.showTable = false;
        let newId = this.tcWrapperList.length + 1;
        let newTc ={
            tcId: newId.toString(),
            transferCreditCourse: '',
            transferCreditGrade: '',
            courseOutcome: '',
            creditsEarnedMonth: '',
            creditsEarnedYear: ''
        }
        this.tcWrapperList.push(newTc);
        this.showTable = true;
     }
    deleteTcRow(event){
        this.showTable = false;
        let closestTcElem = this.getClosest(event.target, '.tcDetailsRow');
        let currentTcId = closestTcElem.getAttribute('data-tcid');
        for(let i in this.tcWrapperList){
            if(this.tcWrapperList[i].tcId === currentTcId){
                this.tcWrapperList.splice(i, 1);
                break;
            }
        }
        this.showTable = true;
    }
    changeTcCourse(event){
        let closestTcElem = this.getClosest(event.target, '.tcDetailsRow');
        let currentTcId = closestTcElem.getAttribute('data-tcid');
        for(let i in this.tcWrapperList){
            if(this.tcWrapperList[i].tcId === currentTcId){
                this.tcWrapperList[i].transferCreditCourse = event.target.value;
                break;
            }
        }
    }
    changeTcGrade(event){
        let closestTcElem = this.getClosest(event.target, '.tcDetailsRow');
        let currentTcId = closestTcElem.getAttribute('data-tcid');
        for(let i in this.tcWrapperList){
            if(this.tcWrapperList[i].tcId === currentTcId){
                this.tcWrapperList[i].transferCreditGrade = event.target.value;
                break;
            }
        }
    }
    changeTcOutcome(event){
        let closestTcElem = this.getClosest(event.target, '.tcDetailsRow');
        let currentTcId = closestTcElem.getAttribute('data-tcid');
        for(let i in this.tcWrapperList){
            if(this.tcWrapperList[i].tcId === currentTcId){
                this.tcWrapperList[i].courseOutcome = event.target.value;
                break;
            }
        }
    }
    changeTcMonth(event){
        let closestTcElem = this.getClosest(event.target, '.tcDetailsRow');
        let currentTcId = closestTcElem.getAttribute('data-tcid');
        for(let i in this.tcWrapperList){
            if(this.tcWrapperList[i].tcId === currentTcId){
                this.tcWrapperList[i].creditsEarnedMonth = event.target.value;
                break;
            }
        }
    }
    changeTcYear(event){
        let closestTcElem = this.getClosest(event.target, '.tcDetailsRow');
        let currentTcId = closestTcElem.getAttribute('data-tcid');
        for(let i in this.tcWrapperList){
            if(this.tcWrapperList[i].tcId === currentTcId){
                this.tcWrapperList[i].creditsEarnedYear = event.target.value;
                break;
            }
        }
    }
    getClosest(elem, selector){
        // Element.matches() polyfill
        if(!Element.prototype.matches){
            Element.prototype.matches =
                Element.prototype.matchesSelector ||
                Element.prototype.mozMatchesSelector ||
                Element.prototype.msMatchesSelector ||
                Element.prototype.oMatchesSelector ||
                Element.prototype.webkitMatchesSelector ||
                function (s){
                    var matches = (this.document || this.ownerDocument).querySelectorAll(s),
                        i = matches.length;
                    // eslint-disable-next-line no-empty
                    while(--i >= 0 && matches.item(i) !== this){
                        //loop to check i value
                    }
                    return i > -1;
                };
        }
        // Get closest match
        for(; elem && elem !== document; elem = elem.parentNode){
            if(elem.matches(selector)) return elem;
        }
        return null;
    }
    handleTransferCreditInnerCheckboxClick(event){
        this.tctNameDocNeeded = event.target.checked;
        if(!event.target.checked){
            let tempPayload = JSON.parse(this.tctNameDocPayload);
             if(this.tctNameUrl){
                markAssetsForDeletionGivenAssetIds({
                    azureUrl: this.tctNameUrl
                });
                this.tctNameUrl = null;
                this.tctNameDocPayload = JSON.stringify(tempPayload);
            }
        }
    }
    handleTransferCreditTrans(event){
        this.tctTransNeeded = event.target.checked;
         if(!event.target.checked){
            let tempPayload = JSON.parse(this.tctTransPayload);
             if(this.tctTransUrl){
                markAssetsForDeletionGivenAssetIds({
                    azureUrl: this.tctTransUrl
                });
                this.tctTransUrl = null;
                this.tctTransPayload = JSON.stringify(tempPayload);
            }
        }
    }
    handleTctTranslationUploaded(event){
        this.tctTransUrl = event.detail.url;
        this.isErrMsgTctTransDetails = false;
        this.isTctEnglishUploaded = true;
    }
    handleNameDocUploaded(event){
        this.tctNameUrl = event.detail.url;
    }
    handleTctUploaded(event){
        this.tctUrl = event.detail.url;
        this.tempPayloadtctNameDoc.parentUrl = event.detail.url;
        this.tempPayloadTctTrans.parentUrl = event.detail.url;
        this.tctNameDocPayload = JSON.stringify(this.tempPayloadtctNameDoc);
        this.tctTransPayload = JSON.stringify(this.tempPayloadTctTrans);
        this.tctUploaded = true;
        this.isErrMsgTctDetails = false;
    }
    cancelButton(){
        markAssetsForDeletionGivenConId({
            contactId: this.contactId
        });
        this.navigateToMyCases();
    }
    calculateMonthValHelper(monthVar){
         let monthVal = 0;
        if(monthVar === 'January'){
            monthVal = 1;
        }else if(monthVar === 'February'){
            monthVal = 2;
        }else if(monthVar === 'March'){
            monthVal = 3;
        }else if(monthVar === 'April'){
            monthVal = 4;
        }else if(monthVar === 'May'){
            monthVal = 5;
        }else if(monthVar === 'June'){
            monthVal = 6;
        }else if(monthVar === 'July'){
            monthVal = 7;
        }else if(monthVar === 'August'){
            monthVal = 8;
        }else if(monthVar === 'September'){
            monthVal = 9;
        }else if(monthVar === 'October'){
            monthVal = 10;
        }else if(monthVar === 'November'){
            monthVal = 11;
        }else if(monthVar === 'December'){
            monthVal = 12;
        }
        return monthVal;
    }
    showOtherMedSchoolErrorFunc(){
        // Remove the Error Elements by Class Name
         this.template.querySelectorAll('.medSchoolNameError').forEach(element => element.remove());
         if(this.selectedMedicalSchoolId || !this.validSchoolRecordIds.includes(this.selectedMedicalSchoolId)){
             let elem = document.createElement("div");
            elem.id = 'medSchoolError';
            elem.setAttribute('class', 'medSchoolNameError');
            elem.textContent = 'Please enter a valid Medical School from the available options';
            elem.style = 'color:#ff0000; clear:both;';
             this.template.querySelector(".schoolRecord").classList.add('slds-has-error');
             this.template.querySelector(".schoolRecord").parentNode.insertBefore(elem, this.template.querySelector(".schoolRecord").nextSibling);
         }
        this.template.querySelector('.slds-has-error').scrollIntoView();
    }
    showNewDateErrorFunc(){
         if(this.template.querySelectorAll('.blankStartMonthError') !== null){
            this.template.querySelectorAll('.blankStartMonthError').forEach(element => element.remove());
        }
        this.template.querySelectorAll('.startMonth').forEach(element =>{
             //code for start month validation
            if(!element.value){
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
        this.template.querySelectorAll('.startYear').forEach(element =>{
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
        this.template.querySelectorAll('.endMonth').forEach(element =>{
            if(!element.value){
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
        this.template.querySelectorAll('.endYear').forEach(element =>{
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
        this.template.querySelectorAll('.endMonth').forEach(element =>{
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
                        elem.textContent = 'End date cannot be a future date';
                        elem.style = 'color:#ff0000; clear:both;';
                        element.classList.add('slds-has-error');
                        element.parentNode.insertBefore(elem, element.nextSibling);
                    }
                }
            }
        });
        this.template.querySelector('.slds-has-error').scrollIntoView();
    }
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
        this.template.querySelectorAll('.endMonth').forEach(element =>{
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
        this.template.querySelectorAll('.attendedYears').forEach(element =>{
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
    showYearBlankError(){
        // Remove the Error Elements by Class Name
        if(this.template.querySelectorAll('.blankYearError') !== null){
            this.template.querySelectorAll('.blankYearError').forEach(element => element.remove());
        }
        if(this.template.querySelectorAll('.futureYearError') !== null){
            this.template.querySelectorAll('.futureYearError').forEach(element => element.remove());
        }
        this.template.querySelectorAll('.creditEarnedYearInput').forEach(element =>{
            if(element.value === ''){
                let elem = document.createElement("div");
                elem.id = 'blankYearError';
                elem.setAttribute('class', 'blankYearError');
                elem.textContent = 'Please enter year';
                elem.style = 'color:#ff0000; clear:both;';
                element.classList.add('slds-has-error');
                let wrapperTable = this.getClosest(element, ".tcTableWrapper");
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
        this.template.querySelectorAll('.creditEarnedYearInput').forEach(element =>{
            yearnum++;
            let futuredateerror = false;
            if(element.value !== '' && parseInt(element.value, 10) > parseInt(year, 10)){
                futuredateerror = true;
            }else if(element.value !== '' && parseInt(element.value, 10) === parseInt(year, 10)){
                let monthnum = 0;
                this.template.querySelectorAll('.monthPicklist').forEach(element1 =>{
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
    showCourseBlankError(){
        // Remove the Error Elements by Class Name
        if(this.template.querySelectorAll('.blankCourseError') !== null){
            this.template.querySelectorAll('.blankCourseError').forEach(element => element.remove());
        }
        this.template.querySelectorAll('.transferCreditCourseInput').forEach(element =>{
            if(element.value === ''){
                let elem = document.createElement("div");
                elem.id = 'blankCourseError';
                elem.setAttribute('class', 'blankCourseError');
                elem.textContent = 'Please enter a Course Title';
                elem.style = 'color:#ff0000; clear:both;';
                element.classList.add('slds-has-error');
                let wrapperTable = this.getClosest(element, ".tcTableWrapper");
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
        this.template.querySelectorAll('.transferCreditGradeInput').forEach(element =>{
            if(element.value === '' || element.value === '0' || element.getAttribute("data-normalizedGradeInput") === '0'){
                let elem = document.createElement("div");
                elem.id = 'blankGradeError';
                elem.setAttribute('class', 'blankGradeError');
                elem.textContent = 'Please enter valid number of Credits earned';
                elem.style = 'color:#ff0000; clear:both;';
                element.classList.add('slds-has-error');
                let wrapperTable = this.getClosest(element, ".tcTableWrapper");
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
        this.template.querySelectorAll('.transferCreditCourseOutcomeInput').forEach(element =>{
            if(element.value === ''){
                let elem = document.createElement("div");
                elem.id = 'blankOutcomeError';
                elem.setAttribute('class', 'blankOutcomeError');
                elem.textContent = 'Please select the outcome of the course';
                elem.style = 'color:#ff0000; clear:both;';
                element.classList.add('slds-has-error');
                let wrapperTable = this.getClosest(element, ".tcTableWrapper");
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
        this.template.querySelectorAll('.monthPicklist').forEach(element =>{
            if(element.value === ''){
                let elem = document.createElement("div");
                elem.id = 'blankMonthError';
                elem.setAttribute('class', 'blankMonthError');
                elem.textContent = 'Please enter month';
                elem.style = 'color:#ff0000; clear:both;';
                element.classList.add('slds-has-error');
                let wrapperTable = this.getClosest(element, ".tcTableWrapper");
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
    saveButton(){
        this.spinner = true;
        let hasErrors = false;
        if(this.diplomaRejected){
            if(!this.isPrimaryDiplomaUploaded){
                hasErrors = true;
                this.isErrMsgDipDetails = true;
            }else{
                if(!this.nameonDiplomaDocument){
                    hasErrors = true;
                    this.isErrMsgDipName = true;
                }
                if(this.isDiplomaNameinEnglish && !this.isDiplomaEnglishUploaded){
                    hasErrors = true;
                    this.isErrMsgDipTransDetails = true;
                }
            }
        }
        if(this.transcriptRejected){
            if(!this.isPrimaryTranscriptUploaded){
                hasErrors = true;
                this.isErrMsgTranscriptDetails = true;
            }else{
                if(!this.nameonFinalTranscriptDocument){
                    hasErrors = true;
                    this.isErrMsgTranscriptName = true;
                }
                if(this.isFinalMedicalTranscriptinEnglish && !this.isTranscriptEnglishUploaded){
                    hasErrors = true;
                    this.isErrMsgFinalMedTransDetails = true;
                }
            }
        }
        if(this.tctRejected){
            if(!this.tctUploaded){
                hasErrors = true;
                this.isErrMsgTctDetails = true;
            }else{
                if(!this.nameonTctDocument){
                    hasErrors = true;
                    this.isErrMsgTctName = true;
                }
                if(this.tctTransNeeded && !this.isTctEnglishUploaded){
                    hasErrors = true;
                    this.isErrMsgTctTransDetails = true;
                }
            }
        }
        let tempSchoolValues ={
            recordIdVal: this.recordIdVal,
            numberOfYearsAttended: this.numberOfYears,
            otherSchool: this.medicalSchool,
            otherSchoolId: this.selectedMedicalSchoolId,
            schoolProgram: this.program,
            studentId: this.studentId,
            speciality: this.speciality,
            startMonth: this.startMonth,
            endMonth: this.endMonth,
            startYear: this.startYear,
            endYear: this.endYear,
            transferCreditsCheckbox: true
        }
        if(!this.readOnly && this.tctRejected){
            tempSchoolValues.tcWrapperList = this.tcWrapperList;
            let today = new Date();
            let dd = String(today.getDate()).padStart(2, '0');
            let mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
            let yyyy = today.getFullYear();
            today = yyyy + '-' + mm + '-' + dd;
            let showOtherMedSchoolError = false;
            let showDateError = false,
                tcCourseBlank = false,
                tcGradeBlank = false,
                tcCourseOutcome = false,
                tcCourseMonth = false,
                tcCourseYear = false,
                tcDateCond = false,
                showfromToError = false,
                showAttendedYearsError = false,
                decimalCount = 0;
            if(this.template.querySelectorAll('.slds-has-error') !== null){
                this.template.querySelectorAll('.slds-has-error').forEach(element => element.classList.remove('slds-has-error'));
            }
            if(!tempSchoolValues.otherSchoolId){
                showOtherMedSchoolError = true;
            }else{
                if(!this.validSchoolRecordIds.includes(tempSchoolValues.otherSchoolId)){
                    showOtherMedSchoolError = true;
                }
            }
            if(!tempSchoolValues.startMonth || !tempSchoolValues.startYear){
                showDateError = true;
            }
            if(!tempSchoolValues.endMonth || !tempSchoolValues.endYear){
                showDateError = true;
            }
            if(tempSchoolValues.endMonth && tempSchoolValues.endYear){
                //construct a endadte and compare with current date
                //construct new enddate
                //compare startdate & enddate
                //construct start & end dates.
                let newStartEndDay = '01';
                let tempStrSDate = tempSchoolValues.startYear + '-' + tempSchoolValues.startMonth + '-' + newStartEndDay
                let tempNewStartDate = new Date(tempStrSDate);
                let tempStrEDate = tempSchoolValues.endYear + '-' + tempSchoolValues.endMonth + '-' + newStartEndDay;
                let tempNewEndDate = new Date(tempStrEDate);
                if(Date.parse(tempNewEndDate) >= Date.parse(today)){
                    showDateError = true;
                }
                if(Date.parse(tempNewEndDate) < Date.parse(tempNewStartDate) || Date.parse(tempNewEndDate) === Date.parse(tempNewStartDate)){
                    showfromToError = true;
                }
            }
            if(tempSchoolValues.numberOfYearsAttended === undefined || tempSchoolValues.numberOfYearsAttended === '' || parseFloat(tempSchoolValues.numberOfYearsAttended) <= parseFloat('0') || parseFloat(tempSchoolValues.numberOfYearsAttended) > parseFloat('20')){
                showAttendedYearsError = true;
            }else{
                if((Math.floor(parseFloat(tempSchoolValues.numberOfYearsAttended)) === parseFloat(tempSchoolValues.numberOfYearsAttended))){
                    decimalCount = 0;
                }else{
                    decimalCount = tempSchoolValues.numberOfYearsAttended.split(".")[1].length;
                }
                if(decimalCount > 2){
                    showAttendedYearsError = true;
                }
            }
            for(let k = 0; k < tempSchoolValues.tcWrapperList.length; k++){
                if(!tempSchoolValues.tcWrapperList[k].transferCreditCourse){
                    tcCourseBlank = true;
                }
                if(tempSchoolValues.tcWrapperList[k].transferCreditGrade === undefined || tempSchoolValues.tcWrapperList[k].transferCreditGrade === '' || tempSchoolValues.tcWrapperList[k].transferCreditGrade === null || tempSchoolValues.tcWrapperList[k].transferCreditGrade === '0' || tempSchoolValues.tcWrapperList[k].transferCreditGrade === 0){
                    tcGradeBlank = true;
                }
                if(!tempSchoolValues.tcWrapperList[k].courseOutcome){
                    tcCourseOutcome = true;
                }
                if(!tempSchoolValues.tcWrapperList[k].creditsEarnedMonth){
                    tcCourseMonth = true;
                }
                if(!tempSchoolValues.tcWrapperList[k].creditsEarnedYear){
                    tcCourseYear = true;
                }else{
                    if(parseInt(tempSchoolValues.tcWrapperList[k].creditsEarnedYear, 10) > parseInt(yyyy, 10)){
                        tcDateCond = true;
                    }else if(parseInt(tempSchoolValues.tcWrapperList[k].creditsEarnedYear, 10) === parseInt(yyyy, 10)){
                        if(tcCourseMonth === false){
                            let monthVal;
                            if(tempSchoolValues.tcWrapperList[k].creditsEarnedMonth === 'January'){
                                monthVal = 1;
                            }else if(tempSchoolValues.tcWrapperList[k].creditsEarnedMonth === 'February'){
                                monthVal = 2;
                            }else if(tempSchoolValues.tcWrapperList[k].creditsEarnedMonth === 'March'){
                                monthVal = 3;
                            }else if(tempSchoolValues.tcWrapperList[k].creditsEarnedMonth === 'April'){
                                monthVal = 4;
                            }else if(tempSchoolValues.tcWrapperList[k].creditsEarnedMonth === 'May'){
                                monthVal = 5;
                            }else if(tempSchoolValues.tcWrapperList[k].creditsEarnedMonth === 'June'){
                                monthVal = 6;
                            }else if(tempSchoolValues.tcWrapperList[k].creditsEarnedMonth === 'July'){
                                monthVal = 7;
                            }else if(tempSchoolValues.tcWrapperList[k].creditsEarnedMonth === 'August'){
                                monthVal = 8;
                            }else if(tempSchoolValues.tcWrapperList[k].creditsEarnedMonth === 'September'){
                                monthVal = 9;
                            }else if(tempSchoolValues.tcWrapperList[k].creditsEarnedMonth === 'October'){
                                monthVal = 10;
                            }else if(tempSchoolValues.tcWrapperList[k].creditsEarnedMonth === 'November'){
                                monthVal = 11;
                            }else if(tempSchoolValues.tcWrapperList[k].creditsEarnedMonth === 'December'){
                                monthVal = 12;
                            }
                            if(monthVal > parseInt(mm, 10)){
                                tcDateCond = true;
                            }
                        }
                    }
                }
            }
            if(showOtherMedSchoolError){
                hasErrors = true;
                this.showOtherMedSchoolErrorFunc();
            }
            if(showDateError){
                hasErrors = true;
                this.showNewDateErrorFunc();
            }else{
                this.template.querySelectorAll('.blankStartMonthError').forEach(element => element.remove());
                this.template.querySelectorAll('.blankStartYearError').forEach(element => element.remove());
                this.template.querySelectorAll('.blankEndMonthError').forEach(element => element.remove());
                this.template.querySelectorAll('.blankEndYearError').forEach(element => element.remove());
                this.template.querySelectorAll('.EndDateError').forEach(element => element.remove());
            }
            if(showfromToError){
                hasErrors = true;
                this.showStartEndErrorFunc();
            }else{
                this.template.querySelectorAll('.startEndDateError').forEach(element => element.remove());
            }
            if(showAttendedYearsError){
                hasErrors = true;
                this.showAttendedYearsFunc();
            }else{
                this.template.querySelectorAll('.attendedYearsError').forEach(element => element.remove());
            }
            if(tcCourseYear){
                hasErrors = true;
                this.showYearBlankError();
            }else{
                if(this.template.querySelectorAll('.blankYearError') !== null){
                    this.template.querySelectorAll('.blankYearError').forEach(element => element.remove());
                }
            }
            if(tcDateCond){
                hasErrors = true;
                this.showYearFutureError();
            }else{
                if(this.template.querySelectorAll('.futureYearError') !== null){
                    this.template.querySelectorAll('.futureYearError').forEach(element => element.remove());
                }
            }
            if(tcCourseMonth){
                hasErrors = true;
                this.showMonthBlankError();
            }else{
                if(this.template.querySelectorAll('.blankMonthError') !== null){
                    this.template.querySelectorAll('.blankMonthError').forEach(element => element.remove());
                }
            }
            if(tcCourseOutcome){
                hasErrors = true;
                this.showOutcomeBlankError();
            }else{
                if(this.template.querySelectorAll('.blankOutcomeError') !== null){
                    this.template.querySelectorAll('.blankOutcomeError').forEach(element => element.remove());
                }
            }
            if(tcGradeBlank){
                hasErrors = true;
                this.showGradeBlankError();
            }else{
                if(this.template.querySelectorAll('.blankGradeError') !== null){
                    this.template.querySelectorAll('.blankGradeError').forEach(element => element.remove());
                }
            }
            if(tcCourseBlank){
                hasErrors = true;
                this.showCourseBlankError();
            }else{
                if(this.template.querySelectorAll('.blankCourseError') !== null){
                    this.template.querySelectorAll('.blankCourseError').forEach(element => element.remove());
                }
            }
        }
        if(!hasErrors){
            resubmitCredential({
                caseId: this.caseId,
                contactId: this.contactId,
                medschoolJson: JSON.stringify(tempSchoolValues)
            }).then(result =>{
                 if(result){
                    this.spinner = false;
                    this.navigateToMyCases();
                }
            });
        }else{
            this.spinner = false;
        }
        this.template.querySelector('.slds-has-error').scrollIntoView();
    }
}