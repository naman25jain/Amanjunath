import { LightningElement, api, wire, track } from 'lwc';
import updateCatIDinAssetFMD from '@salesforce/apex/AppForCertController.updateCatIDinAssetFMD';
import createGradNameOrTransDocPayloadFMD from '@salesforce/apex/AppForCertController.createGradNameOrTransDocPayloadFMD';
import updateParentAsset from '@salesforce/apex/AppForCertController.updateParentAsset';
import checkIsDeanLetter from '@salesforce/apex/AppForCertController.checkIsDeanLetter';
import getContact from '@salesforce/apex/AppForCertController.getContactName';
import getAssetNameonDocument from '@salesforce/apex/AppForCertController.getAssetNameonDocument';
import deleteAssetAndRelatedDocument from '@salesforce/apex/AppForCertController.deleteAssetAndRelatedDocument';
import { refreshApex } from '@salesforce/apex';
import getContactId from '@salesforce/apex/AppForCertController.getContactId';
import getCaseId from '@salesforce/apex/AppForCertController.getCaseId';
import getContactAssociationTypeStaging from '@salesforce/apex/AppForCertController.getContactAssociationTypeStaging';
import getContactAssociationType from '@salesforce/apex/AppForCertHelper.getContactAssociationType';
import getConAssocTypeStageCredIntake from '@salesforce/apex/AppForCertHelper.getConAssocTypeStageCredIntake';
import checkIsFinalTranscriptRequired from '@salesforce/apex/AppForCertController.checkFinalTranscript';
import getPrimaryAssets from '@salesforce/apex/AppForCertController.getPrimaryAssets';
import diplomaDocument from '@salesforce/label/c.App_for_Cert_DIPLOMA_DOCUMENT';
import diplomaNameDocument from '@salesforce/label/c.App_for_Cert_DIPLOMA_NAME_DOCUMENT';
import diplomaTranslationDocument from '@salesforce/label/c.App_for_Cert_DIPLOMA_TRANSLATION_DOCUMENT';
import diplomaTranslationNameDocument from '@salesforce/label/c.App_for_Cert_DIPLOMA_TRANSLATION_NAME_DOCUMENT';
import deanLetterDocument from '@salesforce/label/c.App_for_Cert_DEAN_LETTER_DOCUMENT';
import deanLetterNameDocument from '@salesforce/label/c.App_for_Cert_DEAN_LETTER_NAME_DOCUMENT';
import deanLetterTranslationDocument from '@salesforce/label/c.App_for_Cert_DEAN_LETTER_TRANSLATION_DOCUMENT';
import deanLetterTranslationMandatory from '@salesforce/label/c.App_for_Cert_Error_Upload_Dean_Letter_Translation';
import deanLetterTranslationNameDocument from '@salesforce/label/c.App_for_Cert_DEAN_LETTER_TRANSLATION_NAME_DOCUMENT';
import finalMedicalSchoolTranscriptDocument from '@salesforce/label/c.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_DOCUMENT';
import finalMedicalSchoolTranscriptNameDocument from '@salesforce/label/c.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_NAME_DOCUMENT';
import finalMedicalSchoolTranscriptTranslationDocument from '@salesforce/label/c.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_TRANSLATION_DOCUMENT';
import finalMedicalSchoolTranscriptTranslationNameDocument from '@salesforce/label/c.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_TRANSLATION_NAME_DOCUMENT';
import finalMedicalSchoolTranscriptTranslationMandatory from '@salesforce/label/c.App_for_Cert_Error_Upload_Final_Transcript_Translation';
import deanMessage from "@salesforce/label/c.App_for_Cert_Dean_s_Letter_Confimation_Message";
import diplomaisMandatory from '@salesforce/label/c.App_for_Cert_Error_Upload_Diploma';
import graduateScreenStep from '@salesforce/label/c.App_for_Cert_Step_5';
import graduateScreenErrorMessage from '@salesforce/label/c.App_for_Cert_Error_Message';
import graduateScreenSuccessMessage from '@salesforce/label/c.App_for_Cert_Graduation_Screen_Success_Message';
import graduateScreenNameonDocMessage from '@salesforce/label/c.App_for_Cert_Name_on_Document';
import graduateScreenDeanLetDateMessage from '@salesforce/label/c.App_for_Cert_Dean_Letter_Date';
import graduateScreenDeanDegreeDateMessage from '@salesforce/label/c.App_for_Cert_Dean_Expected_Degree_Issue_Date';
import diplomaDocumentUpload from '@salesforce/label/c.App_for_Cert_Upload_Diploma';
import diplomaDocumentFinalMedicalType from '@salesforce/label/c.App_for_Cert_Final_Medical_Diploma';
import diplomaDocumentUploadNameDocumentation from '@salesforce/label/c.App_for_Cert_Upload_Name_Documentation';
import diplomaDocumentNameDocumentType from '@salesforce/label/c.App_for_Cert_Name_Document';
import diplomaDocumentUploadTranslation from '@salesforce/label/c.App_for_Cert_Upload_Diploma_Translation';
import diplomaDocumentTranslationType from '@salesforce/label/c.App_for_Cert_Translation';
import diplomaDocumentTranslationMandatory from '@salesforce/label/c.App_for_Cert_Error_Upload_Diploma_Translation';
import diplomaDocumentUploadTranslationNameDocumentation from '@salesforce/label/c.App_for_Cert_Upload_Diploma_Documentation';
import transcriptUpload from '@salesforce/label/c.App_for_Cert_Upload_Final_Transcript';
import transcriptFinalMedicalType from '@salesforce/label/c.App_for_Cert_Final_Medical_School_Transcript';
import transcriptTranslationUpload from '@salesforce/label/c.App_for_Cert_Upload_Transcript_Translation';
import deanUpload from '@salesforce/label/c.App_for_Cert_Upload_Letter_From_Dean';
import deanLetterType from '@salesforce/label/c.App_for_Cert_Letter_from_Dean';
import deanTranslationUpload from '@salesforce/label/c.App_for_Cert_Upload_Letter_Transalation';
import getCATGraduateOnlyRecords from '@salesforce/apex/AppForCertHelper.getCATGraduateOnlyRecords';
import getAssetStatusAndType from '@salesforce/apex/AppForCertController.getAssetStatusAndType';
import getDeanLetterExpiredStatus from '@salesforce/apex/AppForCertController.getDeanLetterExpiredStatus';
import getDlDateForExistingCAT from '@salesforce/apex/AppForCertController.getDlDateForExistingCAT';
import createFMDTranscriptDeanPayload from '@salesforce/apex/AppForCertController.createFMDTranscriptDeanPayload';
import updateCatIDinAsset from '@salesforce/apex/AppForCertController.updateCatIDinAsset';
import createFMDAcceptedPayload from '@salesforce/apex/AppForCertController.createFMDAcceptedPayload';
import createGradNameOrTransDocPayload from '@salesforce/apex/AppForCertController.createGradNameOrTransDocPayload';
import createGradAcceptedPayload from '@salesforce/apex/AppForCertController.createGradAcceptedPayload'; 
import deleteDeanLetterOrDiplomaRelatedDoc from '@salesforce/apex/AppForCertHelper.delDeanLetOrDipDocs';
import getGraduateRejectedDocs from '@salesforce/apex/AppForCertHelper.getGraduateRejectedDocs';
import isStudorGrad from '@salesforce/apex/AppForCertHelper.isStudorGrad';
import checkVerifictn from '@salesforce/apex/AppForCertController.checkVerifictn';
import getCatCheckboxValues from '@salesforce/apex/EpicCredVerController.getCatCheckboxValues'; 
import getCatCourierFMST from '@salesforce/apex/AppForCertHelper.getCatCourierFMST';
import deleteCredIntakeCATS from '@salesforce/apex/AppForCertHelper.deleteCredIntakeCATS';
import getFMSTAssetStatusAndType from '@salesforce/apex/AppForCertHelper.getFMSTAssetStatusAndType';
import getCATGraduateFMSTRecord from '@salesforce/apex/AppForCertHelper.getCATGraduateFMSTRecord';
export default class AppForCertGraduateOnly extends LightningElement {
    label = {
        diplomaDocument, diplomaNameDocument, diplomaTranslationDocument, diplomaTranslationNameDocument,
        deanLetterDocument, deanLetterNameDocument, deanLetterTranslationDocument, deanLetterTranslationNameDocument,
        finalMedicalSchoolTranscriptDocument, finalMedicalSchoolTranscriptNameDocument, finalMedicalSchoolTranscriptTranslationDocument,
        finalMedicalSchoolTranscriptTranslationNameDocument,
        finalMedicalSchoolTranscriptTranslationMandatory, deanLetterTranslationMandatory, diplomaDocumentTranslationMandatory, diplomaisMandatory,
        graduateScreenNameonDocMessage, graduateScreenDeanLetDateMessage,graduateScreenDeanDegreeDateMessage,
        graduateScreenStep, graduateScreenErrorMessage, graduateScreenSuccessMessage, diplomaDocumentUpload, diplomaDocumentFinalMedicalType,
        diplomaDocumentUploadNameDocumentation, diplomaDocumentNameDocumentType, diplomaDocumentUploadTranslation,
        diplomaDocumentTranslationType, diplomaDocumentUploadTranslationNameDocumentation, transcriptUpload,
        transcriptFinalMedicalType, transcriptTranslationUpload, deanUpload, deanLetterType, deanTranslationUpload,deanMessage
    };
    @api isErrMsg;
    @api isSucMsg;
    @api isDiplomaNameDifferent;
    @api isDiplomaNameinEnglish;
    @api isDeanLetter = false;
    @api isDeanLetterDifferent;
    @api isDeanLetterNameinEnglish;
    @api isFinalMedicalTranscriptDifferent;
    @api isFinalMedicalTranscriptinEnglish;
    @api contactId;
    @api caseId;
    @api contactAssociationTypeStagingId;
    @api nameonDiplomaDocument;
    @api nameonDiplomaSystem;
    @api dateonDeanLetterDocument;
    @api nameonDeanLetterDocument;
    @api nameonDeanLetterSystem;
    @api nameonFinalTranscriptDocument;
    @api nameonFinalTranscriptSystem;
    initialized = false;
    @api nameonSystem;
    @api contactName;
    @api nameonDiplomaDocumentVal;    
    @api nameonFinalDocumentVal;    
    @api nameonDeanLetterDocumentVal;
    @api nameonDocumentTransVal;
    @api deanLetterDateVal;
    @api deanlettervalueassigned;
    @api deanletterEngvalueassigned;
    @api isFinalTranscriptRequired;
    @api uploadFileCheck = false;
    @api isPrimaryDiplomaUploaded = false;
    @api isPrimaryTranscriptUploaded = false;
    @api isPrimaryDeanUploaded = false;
    @api isDiplomaEnglishUploaded = false;
    @api isTranscriptEnglishUploaded = false;
    @api isDeanEnglishUploaded = false;
    @track clickedBtn;
    @api showExamRegActionButton;
    @track isFormSubmit = false;
    @track isErrMsgDipName = false;    
    @track isErrMsgFinName = false;    
    @track isErrMsgDeanName = false;    
    @track isErrMsgDeanLetDate = false;
    @track isErrMsgDeanLetDatePast = false;
    @track isErrMsgDeanLetGreaterthanCurDate = false;
    @track isErrMsgDipDetails = false;
    @track isErrMsgTransDetails = false;
    @track isErrMsgDipTransDetails = false;
    @track isErrMsgFinalMedTransDetails = false;
    @track isErrMsgDeanLetTransDetails = false
    @track spinner = false;
    @track uploadFileCheckCase = false;
    @track uploadFileCheckContact = false;
    @api reSubmitFromAppForCert;
    @track showExamRegActionButtonTempValue = false;
    @track disableEditing = false; //it display separate section for new dean letter upload or disable uploading,if deanletter is expired or Final Medical Diploma is accepted
    @track gradAssetsList = [];
    @track gradFMSTAssetsList = [];
    @track tctNameCond = false;
    @track tctTransCond = false;
    @track fmdNameCond = false;
    @track fmdTransCond = false;
    @track dlNameCond = false;
    @track dlTransCond = false;
    @track ftNameCond = false;
    @track ftTransCond = false;
    @track showDeanLetterReadOnly = false;
    @track showFMDReadOnly = false;
    @track showFMSTReadOnly = false;
    @track showCheckboxVisible = true;
    @track ftReqdCond = false;
    @track isDeanLet = false; //If isDeanLet is false, it implies, there is a already an accepted diploma doc.
    @track showFtFile = false;
    @track showdlFile = false;
    @track showfmdFile = false;
    @track showOtMedFile = false;
    @track dlDate;
    @track valueChangeNewUpload = false; //to identify whether a new diploma is uploaded. 
    @track modalTitle = 'Alert';
    @track modalContent = 'Are you sure you want to continue?';
    prevVal = false;
    @track contactAssociationTypeId;
    @track conAssocTypeStagCredIntakeId;
    @api directlyToNext = false;
    @track resubAppAddDiploma = false;
    @track isDeanLetterAddition = false;
    @track isPrimaryDeanNewlyUploaded = false;
    isDeanLettertemp = false;
    @api showAlreadyDiplomaUploaded;
    newlyUploadedMethodRan = false;
    @track isDeanLetterMandatoryUpload = false;
    @track showFinalTranscriptHeadingOnly = false;
    //variables to load Final Medical Diploma Doc 
    @track payloadFinalMedDiploma;
    @track showDipUploadButton = false;
    @track payloadFMDiplomaAccepted;
    @track showUploadedDiploma = false;
    @track upload = true;
    //variables to load Final Medical Diploma Name Different Doc
    @track payloadFMDNameDoc;
    @track showDipNameDocButton = false;
    @track payloadFMDNameDocAccepted;
    @track showAcceptdDiplomaNameDoc = false;
    @track payloadFMDTransDoc;
    @track showDipTransDocButton = false;
    @track payloadFMDTransDocAccepted;
    @track showAcceptdDiplomaTransDoc = false;
    @track payloadFinalMedSchoolTranscript;
    @track showMedSchoolTranscriptUploadButton = false;
    @track payloadFMSchoolTranscriptAccepted;
    @track showUploadedFMSchoolTranscript = false;
    @track uploadFMSchoolTranscript = true;
    @track payloadFMTranscriptNameDoc;
    @track showTranscriptNameDocButton = false;
    @track payloadFMTranscriptNameDocAccepted;
    @track showAcceptdTranscriptNameDoc = false;
    @track payloadFMTranscriptTransDoc;
    @track showFMTranscriptTransDocButton = false;
    @track payloadFMTranscriptTransDocAccepted;
    @track showAcceptdFMTranscriptTransDoc = false;
    @track showDeanLetUploadButton = false;
    @track payloadDeanLetterDoc;
    @track showUploadedDean = false;
    @track payloadDeanExpiredOrAccepted;
    @track showDeanLetNameDiffButton = false;
    @track payloadDeanLetterNameDiffDoc;
    @track showUploadedDeanLetNameDiff = false;
    @track payloadDeanLetNameDiffExpiredOrAccepted;
    @track showDeanLetEnglishButton = false;
    @track payloadDeanLetterEnglishDoc;
    @track showUploadedDeanLetEnglishDoc = false;
    @track payloadDeanLetEnglishExpiredOrAccepted;
    //to show rejected docs
    @track showRejectedSection = false;
    @track rejFMDPayload;
    @track showRejFmd = false;
    @track rejFMDTransPayload;
    @track showRejFmdName = false;
    @track rejFMDNamePayload;
    @track showRejFmdTrans = false;
    @track showRejTranscriptTrans = false;
    @track showRejTranscriptName = false;
    @track showRejTranscript = false;
    @track showRejDeanTrans = false;
    @track showRejDeanName = false;
    @track showRejDean = false;
    @track rejDeanPayload;
    @track rejDeanNamePayload;
    @track rejDeanTransPayload;
    @track rejTranscriptPayload;
    @track rejTranscriptNamePayload;
    @track rejTranscriptTransPayload;
    @track sendViaCourier = false;
    @track isNonPortalPaperFMST = false;
    @track sendViaCourierFMST = false;
    @track sendViaCourierUpdateFlow = false;
    @track isPortal = false;
    @track isNonPortalWeb = false;
    @track isNonPortalPaper = false;
    @track selectedEntityId = '';
    @api recordId;
    @api parentCaseId;
    @track fmdAzureUrl=null;
    @track fmdNameAzureUrl=null;
    @track fmdTranAzureUrl=null;
    @track fmstAzureUrl=null;
    @track fmstNameAzureUrl=null;
    @track fmstTranAzureUrl=null;
    @track deanLetUrl=null;
    @track deanLetNameAzureUrl=null;
    @track deanLetTranAzureUrl=null;
    @track rejOrCancelFMD;
    @track rejOrCancelFMST;
    @track rejOrCancel;
    refreshCase;
    refreshContact;
    refreshContactAssociationType;
    refreshContactAssocTypeIntake;
    @wire(getContactId)
    contactIdfromController(result){
        this.refreshContact = result;
        if(result.data !== undefined){
            this.contactId = result.data;
            this.uploadFileCheckContact = true;
            getContact({contactId: this.contactId})
            .then(result1 => {
                if(result1 !== '' && result1 !== undefined && result1 !== null){
                    this.contactName = JSON.stringify(result1).replace('"', '').replace('"', '');
                }
            })
            .catch();
        }
    }
    @wire(getCaseId)
    caseIdfromController(result){
        this.refreshCase = result;
        if(result.data !== undefined){
            this.caseId = result.data;
            this.parentCaseId = result.data;
            this.uploadFileCheckCase = true;
        }
    }
    @wire(getContactAssociationTypeStaging, {showExamRegActionButton : '$showExamRegActionButton'})
    contactAssociationTypeStagingIdfromController(result){
        this.refreshContactAssociationType = result;
        if(result.data !== undefined){
            this.contactAssociationTypeStagingId = result.data; //holds the newly created CATS record with record type=Exam_Registration_Degree_medical_school 
            if(this.reSubmitFromAppForCert){
                if(this.uploadFileCheckCase && this.uploadFileCheckContact){
                    if(this.showAlreadyDiplomaUploaded){
                        isStudorGrad({
                            contactAssociationTypeId : this.contactAssociationTypeStagingId
                        }).then(result2=>{
                            if(result2){
                                this.resubAppAddDiploma = false;
                            }
                            else {
                                this.resubAppAddDiploma = true;
                            }
                        })
                        this.uploadFileCheck = true;
                        this.getCatCheckbox();
                    }
                    else {
                        //this.getAssetNameStatus();
                    }                                
                }                 
            }
            else {
                if(this.uploadFileCheckCase && this.uploadFileCheckContact){
                    this.uploadFileCheck = true;    
                    this.checkPrimaryDetails();
                    this.checkDeanLetter();
                    this.contactNameDetails();
                    this.getCatCheckbox();
                }        
            }
        }
    }
    // Get Contact Association Type Staging Id for Credential Intake
    @wire(getConAssocTypeStageCredIntake)
    contactAssocTypeStagingIntakeIdfromController(result){
        this.refreshContactAssocTypeIntake = result;
        if(result.data !== undefined){
            this.conAssocTypeStagCredIntakeId = result.data;
        }
    }    
    renderedCallback(){
        if(!this.newlyUploadedMethodRan){
            this.newlyUploadedDocLoading();
        }
        if(this.initialized){
            return;
        }
        this.initialized = true;
        this.firstLoad(); 
        this.getCatCheckbox();                
    }
    firstLoad(){
        if(this.refreshCase.data !== undefined){
            refreshApex(this.refreshCase);
        }
        if(this.refreshContact.data !== undefined){
            refreshApex(this.refreshContact);
        }       
        if(this.refreshContactAssociationType.data !== undefined){
            refreshApex(this.refreshContactAssociationType);
        }
        if(this.refreshContactAssocTypeIntake.data !== undefined){
            refreshApex(this.refreshContactAssocTypeIntake);
        }
        if(this.uploadFileCheck){
            this.checkPrimaryDetails();
            this.checkDeanLetter();
            this.contactNameDetails();
            this.getCatCheckbox();
        }
    }
    connectedCallback(){
        if(!this.contactAssociationTypeStagingId){
            getContactAssociationTypeStaging({
                showExamRegActionButton: this.showExamRegActionButton
            })
            .then(result1 => {       
                if(result1 !== undefined){
                    this.contactAssociationTypeStagingId = result1;
                    this.checkIsFinalTransRequired();
                }
            })
        }else{
            this.checkIsFinalTransRequired();
        }
        // Getting CAT id if exist
        if(!this.contactAssociationTypeId){
            getContactAssociationType() // CAT - Degree Medical School
            .then(catResult => {
                if(catResult !== undefined){
                    this.contactAssociationTypeId = catResult[0].Id;
                    if(catResult[0].Credential_Type__c != ''){
                        this.getAssetNameStatus(catResult[0].Credential_Type__c, catResult[0].Account__r.Is_Final_Transcript_Required__c);            
                    }                    
                }
            })
            .catch() 
        }
        /* Get Contact Association Type Staging Id for 'Credential Intake' */
        if(!this.conAssocTypeStagCredIntakeId){
            getConAssocTypeStageCredIntake()
            .then(credIntakeresult => {
                if(credIntakeresult !== undefined){
                    this.conAssocTypeStagCredIntakeId = credIntakeresult;
                }
            })
        }else{
            this.checkIsFinalTransRequired();
        }
        if(!this.contactId){
            getContactId()
                .then(result12 => {
                   if(result12){
                    this.contactId = result12;
                    getContact({
                        contactId: this.contactId
                    })
                    .then(result =>{
                        if(result !== '' && result !== undefined && result !== null){
                            this.contactName = JSON.stringify(result).replace('"', '').replace('"', '');
                        }
                    })
                    .catch();
                    this.callPayloadCreation();
                   }
                })    
        }
        else {
            this.callPayloadCreation();            
        }
        this.isErrMsg = false;
        this.isSucMsg = false;
        this.deanlettervalueassigned = false;
        this.deanletterEngvalueassigned = false;
        this.isDiplomaNameDifferent = false;
        this.isDiplomaNameinEnglish = false;
        this.isDeanLetter = false;
        this.isDeanLetterDifferent = false;
        this.isDeanLetterNameinEnglish = false;        
        this.isFinalMedicalTranscriptDifferent = false;
        this.isFinalMedicalTranscriptinEnglish = false;        
        this.isFinalTranscriptRequired = false;
        this.isFormSubmit = false;
        this.isErrMsgDipName = false;        
        this.isErrMsgFinName = false;        
        this.isErrMsgDeanName = false;        
        this.isErrMsgDeanLetDate = false;
        this.isErrMsgDeanLetGreaterthanCurDate = false;
        this.isErrMsgDipDetails = false;
        this.isErrMsgTransDetails = false;
        this.isErrMsgDipTransDetails = false;
        this.isErrMsgFinalMedTransDetails = false;
        this.isErrMsgDeanLetTransDetails = false;
        this.sendViaCourier = false;
        this.sendViaCourierUpdateFlow = false;
        this.sendViaCourierFMST = false;
        if(this.uploadFileCheck){
            this.checkPrimaryDetails();
            this.checkDeanLetter();
            this.contactNameDetails();
            this.getCatCheckbox();
        } 
        //this.newlyUploadedDocLoading(); //to load the newly uploaded doc with status-in progress.        
    }
    checkIsFinalTransRequired(){
        checkIsFinalTranscriptRequired({showExamRegActionButton : this.showExamRegActionButton})
        .then(result => {
            if(result){
                this.isFinalTranscriptRequired = true;
            }
        })
    }
    callPayloadCreation(){
        createFMDTranscriptDeanPayload({
            contactId: this.contactId,
            assetName: "Final Medical Diploma"
        })
        .then(result => {
            if(result){                
                this.showDipUploadButton = true;
                let assetUrl= result.azureUrl; 
                this.fmdAzureUrl = assetUrl;
                this.payloadFinalMedDiploma = JSON.stringify(result);                                
            }
        })        
        createGradNameOrTransDocPayloadFMD({
            contactId: this.contactId,
            keyName: diplomaNameDocument,
            parentKey:diplomaDocument
        })
        .then(result => {
            if(result){
                let assetUrl= result.azureUrl; 
                this.fmdNameAzureUrl = assetUrl;
                this.payloadFMDNameDoc = JSON.stringify(result);
                this.showDipNameDocButton = true;                
            }            
        })        
        createGradNameOrTransDocPayloadFMD({
            contactId: this.contactId,
            keyName: diplomaTranslationDocument,
            parentKey:diplomaDocument
        })
        .then(result => {
            if(result){
                let assetUrl= result.azureUrl; 
                this.fmdTranAzureUrl = assetUrl;
                this.payloadFMDTransDoc = JSON.stringify(result);
                this.showDipTransDocButton = true;
            }
        })
        createFMDTranscriptDeanPayload({
            contactId: this.contactId,
            assetName: "Final Medical School Transcript"
        }).then(result => {
            if(result){
                this.showMedSchoolTranscriptUploadButton = true;
                let assetUrl= result.azureUrl; 
                this.fmstAzureUrl = assetUrl;
                this.payloadFinalMedSchoolTranscript = JSON.stringify(result);
            }
        })
        createGradNameOrTransDocPayloadFMD({
            contactId: this.contactId,
            keyName: finalMedicalSchoolTranscriptNameDocument,
            parentKey:finalMedicalSchoolTranscriptDocument
        }).then(result => {
            if(result){
                let assetUrl= result.azureUrl; 
                this.fmstNameAzureUrl = assetUrl;
                this.payloadFMTranscriptNameDoc = JSON.stringify(result);
                this.showTranscriptNameDocButton = true;
            }
        })
        createGradNameOrTransDocPayloadFMD({
            contactId: this.contactId,
            keyName: finalMedicalSchoolTranscriptTranslationDocument,
            parentKey:finalMedicalSchoolTranscriptDocument
        }).then(result => {
            if(result){
                let assetUrl= result.azureUrl; 
                this.fmstTranAzureUrl = assetUrl;
                this.payloadFMTranscriptTransDoc = JSON.stringify(result);
                this.showFMTranscriptTransDocButton = true;
            }
        })
        createFMDTranscriptDeanPayload({
            contactId: this.contactId,
            assetName: "Letter from Dean"
        }).then(result=>{
            if(result){
                this.showDeanLetUploadButton = true;
                let assetUrl = result.azureUrl; 
                this.deanLetUrl = assetUrl;
                this.payloadDeanLetterDoc = JSON.stringify(result);
            }
        })
        createGradNameOrTransDocPayloadFMD({
            contactId: this.contactId,
            keyName: deanLetterNameDocument,
            parentKey: deanLetterDocument
        }).then(result=>{
            if(result){
                let assetUrl = result.azureUrl; 
                this.deanLetNameAzureUrl = assetUrl;
                this.payloadDeanLetterNameDiffDoc = JSON.stringify(result);
                this.showDeanLetNameDiffButton = true;
            }
        })
        createGradNameOrTransDocPayloadFMD({
            contactId: this.contactId,
            keyName: deanLetterTranslationDocument,
            parentKey: deanLetterDocument
        }).then(result => {
            if(result){
                let assetUrl= result.azureUrl; 
                this.deanLetTranAzureUrl = assetUrl;
                this.payloadDeanLetterEnglishDoc = JSON.stringify(result);
                this.showDeanLetEnglishButton = true;
            }
        })
        getGraduateRejectedDocs({
            recordTypeName: 'Degree_Medical_School',
            assetName: "Final Medical Diploma"
        })
        .then(result=>{           
            if(result.length > 0){
                let rejPayloadTemp = {
                    contactId: this.contactId,
                    caseId: this.caseId,
                    documentType: 'Final Medical Diploma',
                    assetRecordType: 'Credential',
                    createOrReplace: 'Create',
                    assetStatus: 'In Progress',
                    assetCreationRequired: 'true',
                    assetId: null
                };
                for(let keyMain in result){
                    let assetId = result[keyMain].Id;
                    if(result[keyMain].Case__r.Internal_Status__c === 'CV Rejected'){
                        this.rejOrCancelFMD = 'Rejected';
                    }else{
                        this.rejOrCancelFMD = 'Cancelled';
                        this.isPrimaryDeanUploaded = false;
                        this.isPrimaryTranscriptUploaded = false;
                        this.isPrimaryDiplomaUploaded = false;
                    }                                      
                    if(result[keyMain].Type__c ==='Final Medical Diploma'){
                        rejPayloadTemp.assetId = assetId;
                        this.rejFMDPayload = JSON.stringify(rejPayloadTemp);
                        this.showRejFmd = true;
                    }
                    else if(result[keyMain].Parent_Key__c ==='DIPLOMA DOCUMENT' && result[keyMain].Type__c ==='Name Document'){
                        rejPayloadTemp.assetId = assetId;
                        rejPayloadTemp.documentType = 'Final Medical Diploma Name Document';
                        this.rejFMDNamePayload = JSON.stringify(rejPayloadTemp);
                        this.showRejFmdName = true;
                    }
                    else if(result[keyMain].Parent_Key__c ==='DIPLOMA DOCUMENT' && result[keyMain].Type__c ==='Translation'){
                        rejPayloadTemp.assetId = assetId;
                        rejPayloadTemp.documentType = 'Final Medical Diploma Translation Document';
                        this.rejFMDTransPayload = JSON.stringify(rejPayloadTemp);
                        this.showRejFmdTrans = true;
                    }
                    else if(result[keyMain].Type__c ==='Letter from Dean'){
                        rejPayloadTemp.assetId = assetId;
                        rejPayloadTemp.documentType = 'Letter from Dean';
                        this.rejDeanPayload = JSON.stringify(rejPayloadTemp);
                        this.showRejDean = true;
                    }
                    else if(result[keyMain].Parent_Key__c ==='DEAN LETTER DOCUMENT' && result[keyMain].Type__c ==='Name Document'){
                        rejPayloadTemp.assetId = assetId;
                        rejPayloadTemp.documentType = 'Letter from Dean Name Document';
                        this.rejDeanNamePayload = JSON.stringify(rejPayloadTemp);
                        this.showRejDeanName = true;
                    }
                    else if(result[keyMain].Parent_Key__c ==='DEAN LETTER DOCUMENT' && result[keyMain].Type__c ==='Translation'){
                        rejPayloadTemp.assetId = assetId;
                        rejPayloadTemp.documentType = 'Letter from Dean Translation Document';
                        this.rejDeanTransPayload = JSON.stringify(rejPayloadTemp);
                        this.showRejDeanTrans = true;
                    }                    
                }
                if(this. showRejFmd ||  this.showRejFmdName ||  this.showRejFmdTrans||  this.showRejDean ||  this.showRejDeanName ||  this.showRejDeanTrans){
                   this.showRejectedSection = true;
                }
                if(this.rejOrCancelFMD === 'Cancelled' || this.rejOrCancelFMD === 'Rejected'){
                    this.rejOrCancel = this.rejOrCancelFMD;
                }
            }
        })
        getGraduateRejectedDocs({
            recordTypeName: 'Credential_Intake',
            assetName: "Final Medical School Transcript"
        })
        .then(result=>{
            if(result.length > 0){
                let rejPayloadTemp = {
                    contactId: this.contactId,
                    caseId: this.caseId,
                    documentType: 'Final Medical School Transcript',
                    assetRecordType: 'Credential',
                    createOrReplace: 'Create',
                    assetStatus: 'In Progress',
                    assetCreationRequired: 'true',
                    assetId: null
                };
                for(let keyMain in result){
                    let assetId = result[keyMain].Id;
                    if(result[keyMain].Case__r.Internal_Status__c === 'CV Rejected'){
                        this.rejOrCancelFMST = 'Rejected';
                    }else{
                        this.rejOrCancelFMST = 'Cancelled';
                        this.isPrimaryDeanUploaded = false;
                        this.isPrimaryTranscriptUploaded = false;
                        this.isPrimaryDiplomaUploaded = false;
                    } 
                    if(result[keyMain].Type__c ==='Final Medical School Transcript'){                        
                        rejPayloadTemp.assetId = assetId;
                        rejPayloadTemp.documentType = 'Final Medical School Transcript';
                        this.rejTranscriptPayload = JSON.stringify(rejPayloadTemp);
                        this.showRejTranscript = true;
                    }
                    else if(result[keyMain].Parent_Key__c ==='FINAL MEDICAL SCHOOL TRANSCRIPT DOCUMENT' && result[keyMain].Type__c ==='Name Document'){
                        rejPayloadTemp.assetId = assetId;
                        rejPayloadTemp.documentType = 'Final Medical School Transcript Name Document';
                        this.rejTranscriptNamePayload = JSON.stringify(rejPayloadTemp);
                        this.showRejTranscriptName = true;
                    }
                    else if(result[keyMain].Parent_Key__c ==='FINAL MEDICAL SCHOOL TRANSCRIPT DOCUMENT' && result[keyMain].Type__c ==='Translation'){
                        rejPayloadTemp.assetId = assetId;
                        rejPayloadTemp.documentType = 'Final Medical School Transcript Translation Document';
                        this.rejTranscriptTransPayload = JSON.stringify(rejPayloadTemp);
                        this.showRejTranscriptTrans = true;
                    }                    
                }
                if(this.showRejTranscript || this.showRejTranscriptName || this.showRejTranscriptTrans){
                   this.showRejectedSection = true;
                }
                if((this.rejOrCancelFMD === 'Cancelled' && this.rejOrCancelFMST === 'Rejected') || (this.rejOrCancelFMD === 'Rejected' && this.rejOrCancelFMST === 'Cancelled')){
                    this.rejOrCancel = 'Rejected/Cancelled';
                }else if(this.rejOrCancelFMST === 'Cancelled' || this.rejOrCancelFMST === 'Rejected'){
                    this.rejOrCancel = this.rejOrCancelFMST;
                }
            }
        });        
    }
    newlyUploadedDocLoading(){
        if(this.contactAssociationTypeStagingId != null && this.contactAssociationTypeStagingId != '' && this.contactAssociationTypeStagingId != undefined){
            getAssetNameonDocument({ contactId: this.contactId, keyVal: diplomaDocument, contactAssociationStagingId: this.contactAssociationTypeStagingId })
            .then(result => {
                if(result !== '' && result !== undefined && result !== null){
                    let nameonDipVal = JSON.stringify(result).split(',')[0];
                    if(nameonDipVal !== '' && nameonDipVal !== undefined && nameonDipVal !== null){
                        if(JSON.stringify(result).split(',')[0].replace(/"/g, '').replace('[', '').replace(']', '') !== 'EMPTY'){
                            this.nameonDiplomaDocumentVal = JSON.stringify(result).split(',')[0].replace(/"/g, '').replace('[', '').replace(']', '');
                            this.nameonDiplomaDocument = JSON.stringify(result).split(',')[0].replace(/"/g, '').replace('[', '').replace(']', '');
                            if(this.nameonDiplomaDocumentVal != '' && this.nameonDiplomaDocumentVal != null){
                                this.isPrimaryDiplomaUploaded = true;
                            }
                        }
                    }
                    const nameonDiplomaDocumentDifferentconstant = this.template.querySelector('[data-id="diplomaDiff"]');
                    const nameonDiplomaDocumentEnglishconstant = this.template.querySelector('[data-id="diplomaEng"]');
                    let nameonDip = JSON.stringify(result).split(',')[1];
                    if(nameonDip !== '' && nameonDip !== undefined && nameonDip !== null && nameonDiplomaDocumentDifferentconstant !== null){
                        this.newlyUploadedMethodRan = true;
                        if(nameonDip.replace(/"/g, '') === 'true'){
                            this.isDiplomaNameDifferent = true;
                            nameonDiplomaDocumentDifferentconstant.checked = true;
                        } else {
                            this.isDiplomaNameDifferent = false;
                            nameonDiplomaDocumentDifferentconstant.checked = false;
                        }
                    }
                    let nameonDipEng = JSON.stringify(result).split(',')[2];
                    if(nameonDipEng !== '' && nameonDipEng !== undefined && nameonDipEng !== null && nameonDiplomaDocumentEnglishconstant !== null){
                        if(nameonDipEng.replace(/"/g, '').replace(']', '') === 'true'){
                            this.isDiplomaNameinEnglish = true;
                            nameonDiplomaDocumentEnglishconstant.checked = true;
                            this.isDiplomaEnglishUploaded = true;
                        } else {
                            this.isDiplomaNameinEnglish = false;
                            nameonDiplomaDocumentEnglishconstant.checked = false;
                        }
                    }

                }
            })
            .catch();        
            // Contact Association Type Staging - Credential Intake           
            checkIsFinalTranscriptRequired({showExamRegActionButton : this.showExamRegActionButton})
            .then(result => {
                if(result){
                    this.isFinalTranscriptRequired = true;
                    let catsCredIntakeId = '';
                    if(this.conAssocTypeStagCredIntakeId != null && this.conAssocTypeStagCredIntakeId != '' && this.conAssocTypeStagCredIntakeId != undefined){        
                        catsCredIntakeId = this.conAssocTypeStagCredIntakeId;
                        getAssetNameonDocument({ contactId: this.contactId, keyVal: finalMedicalSchoolTranscriptDocument, contactAssociationStagingId: catsCredIntakeId})
                        .then(result1 => {
                            if(result1 !== '' && result1 !== undefined && result1 !== null){
                                let nameonFinalTranVal = JSON.stringify(result1).split(',')[0];
                                if(nameonFinalTranVal !== '' && nameonFinalTranVal !== undefined && nameonFinalTranVal !== null){
                                    if(nameonFinalTranVal.replace(/"/g, '').replace('[', '').replace(']', '') !== 'EMPTY'){
                                        this.nameonFinalDocumentVal = JSON.stringify(result1).split(',')[0].replace(/"/g, '').replace('[', '').replace(']', '');
                                        this.nameonFinalTranscriptDocument = JSON.stringify(result1).split(',')[0].replace(/"/g, '').replace('[', '').replace(']', '');
                                    }
                                }
                                const nameonFinalDocumentDifferentconstant = this.template.querySelector('[data-id="finalDiff"]');
                                const nameonFinalDocumentEnglishconstant = this.template.querySelector('[data-id="finalEng"]');
                                let nameonFinalTranDiffVal = JSON.stringify(result1).split(',')[1];
                                if(nameonFinalTranDiffVal !== '' && nameonFinalTranDiffVal !== undefined && nameonFinalTranDiffVal !== null && nameonFinalDocumentDifferentconstant !== null){
                                    if(nameonFinalTranDiffVal.replace(/"/g, '') === 'true'){
                                        this.isFinalMedicalTranscriptDifferent = true;
                                        nameonFinalDocumentDifferentconstant.checked = true;
                                    } else {
                                        this.isFinalMedicalTranscriptDifferent = false;
                                        nameonFinalDocumentDifferentconstant.checked = false;
                                    }
                                }
                                let nameonFinalTranEngVal = JSON.stringify(result1).split(',')[2];
                                if(nameonFinalTranEngVal !== '' && nameonFinalTranEngVal !== undefined && nameonFinalTranEngVal !== null && nameonFinalDocumentEnglishconstant !== null){
                                    if(nameonFinalTranEngVal.replace(/"/g, '').replace(']', '') === 'true'){
                                        this.isFinalMedicalTranscriptinEnglish = true;
                                        nameonFinalDocumentEnglishconstant.checked = true;
                                    } else {
                                        this.isFinalMedicalTranscriptinEnglish = false;
                                        nameonFinalDocumentEnglishconstant.checked = false;
                                    }
                                }
                            }
                        })
                        .catch();
                    }
                }
                else {
                    this.isFinalTranscriptRequired = false;
                }
            })
            .catch();
            getAssetNameonDocument({ contactId: this.contactId, keyVal: deanLetterDocument, contactAssociationStagingId: this.contactAssociationTypeStagingId })
            .then(result4 => {
                if(result4 !== '' && result4 !== undefined && result4 !== null){
                    let deanLetVal = JSON.stringify(result4).split(',')[0];
                    if(deanLetVal !== '' && deanLetVal !== undefined && deanLetVal !== null){
                        if(deanLetVal.replace(/"/g, '').replace('[', '').replace(']', '') !== 'EMPTY'){
                            this.nameonDeanLetterDocumentVal = JSON.stringify(result4).split(',')[0].replace(/"/g, '').replace('[', '').replace(']', '');
                            this.nameonDeanLetterDocument = JSON.stringify(result4).split(',')[0].replace(/"/g, '').replace('[', '').replace(']', '');
                            if(this.nameonDeanLetterDocumentVal != '' && this.nameonDeanLetterDocumentVal != null){
                                this.isPrimaryDeanUploaded = true;
                                if(this.showDeanLetterReadOnly === true){
                                    this.isPrimaryDeanNewlyUploaded = true;
                                }
                            }
                        }
                    }
                    this.newlyUploadedMethodRan = true;
                    let deanLetDifVal = JSON.stringify(result4).split(',')[1];
                    if(deanLetDifVal !== '' && deanLetDifVal !== undefined && deanLetDifVal !== null){
                        if(deanLetDifVal.replace(/"/g, '') === 'true'){                                
                            this.isDeanLetterDifferent = true;
                            this.deanlettervalueassigned = true;
                        } else {
                            this.isDeanLetterDifferent = false;
                            this.deanlettervalueassigned = false;
                        }
                    }
                    let deanLetDifEngVal = JSON.stringify(result4).split(',')[2];
                    if(deanLetDifEngVal !== '' && deanLetDifEngVal !== undefined && deanLetDifEngVal !== null){
                        if(deanLetDifEngVal.replace(/"/g, '').replace(']', '') === 'true'){
                            this.isDeanLetterNameinEnglish = true;
                            this.deanletterEngvalueassigned = true;
                            this.isDeanEnglishUploaded = true;
                        } else {
                            this.isDeanLetterNameinEnglish = false;
                            this.deanletterEngvalueassigned = false;
                        }
                    }
                    let deanLetDateVal = JSON.stringify(result4).split(',')[3];
                    if(deanLetDateVal !== '' && deanLetDateVal !== undefined && deanLetDateVal !== null){
                        let dateConvert = JSON.stringify(result4).split(',')[3].replace(/"/g, '').replace('[', '').replace(']', '');
                        this.deanLetterDateVal = dateConvert;
                        this.dateonDeanLetterDocument = dateConvert;
                    }
                }
            })
            .catch();
        }
    }
    // It is processing when Asset is Accepted
    getAssetNameStatus(credentialType, isFinalTranscriptRequired){
        // Checking CAT - Asset is Accepted | getting Asset details
        if(isFinalTranscriptRequired){
            // Final Medical School Transcript
            getFMSTAssetStatusAndType({
                contactId: this.contactId
            }).then(fmstresult =>{
                if(fmstresult){
                    this.showFMSTReadOnly = true;
                    this.showCheckboxVisible = false;
                    //Get the graduate only screen records
                    getCATGraduateFMSTRecord({
                        showExamRegActionButton: false,
                        showCaseDetail: true,
                        resubmitAppForCert: true
                    }).then(data =>{
                        if(data){
                            this.gradFMSTAssetsList = data;
                            this.isDeanLet = false;                            
                            if(this.gradFMSTAssetsList.isCourierServiceFMST === 'Yes'){
                                this.sendViaCourierFMST = true;
                            }
                            if(this.gradFMSTAssetsList.ftNameDiff === 'Yes' && this.gradFMSTAssetsList.ftNameDoc !== ''){
                                createGradAcceptedPayload({
                                    contactId: this.contactId,
                                    keyName: finalMedicalSchoolTranscriptNameDocument
                                }).then(result =>{
                                    if(result){
                                        this.payloadFMTranscriptNameDocAccepted = JSON.stringify(result);
                                        this.showAcceptdTranscriptNameDoc = true;
                                    }
                                })
                                this.ftNameCond = true;
                            }
                            if(this.gradFMSTAssetsList.ftTrans === 'Yes' && this.gradFMSTAssetsList.ftTransFile !== ''){
                                createGradAcceptedPayload({
                                    contactId: this.contactId,
                                    keyName: finalMedicalSchoolTranscriptTranslationDocument
                                }).then(result =>{
                                    if(result){
                                        this.payloadFMTranscriptTransDocAccepted = JSON.stringify(result);
                                        this.showAcceptdFMTranscriptTransDoc = true;
                                    }
                                })
                                this.ftTransCond = true;
                            }
                            if(this.gradFMSTAssetsList.isFTReqd === 'Yes'){
                                this.isFinalTranscriptRequired = true;
                                this.ftReqdCond = true;
                                this.showFtFile = false;
                            }
                            if(this.gradFMSTAssetsList.ftFile !== ''){
                                createFMDAcceptedPayload({
                                    contactId: this.contactId,
                                    assetName: "Final Medical School Transcript"
                                }).then(result =>{
                                    if(result){
                                        this.payloadFMSchoolTranscriptAccepted = JSON.stringify(result);
                                        this.showUploadedFMSchoolTranscript = true;
                                    }
                                })
                                this.showFtFile = true;
                            }
                            if((this.showFtFile || this.showdlFile || this.showfmdFile) && this.isGraduate){
                                this.isGraduate = true;
                            }else{
                                this.isGraduate = false;
                            }
                            this.getCATSRecordInUpdateFlow(this.contactAssociationTypeId);
                            this.getCatCheckbox();
                        }
                    });
                }
            });
        }
        // Final Medical Diploma || Letter from Dean
        getAssetStatusAndType({
            contactId: this.contactId, contactAssociationType: this.contactAssociationTypeId, assetName : credentialType
        }).then(result1 =>{
            if(result1){
                if(credentialType === 'Final Medical Diploma'){
                    this.showFMDReadOnly = true;
                }else if(credentialType === 'Letter from Dean'){
                    this.showDeanLetterReadOnly = true;
                }
                this.showCheckboxVisible = false;
                //Get the graduate only screen records
                getCATGraduateOnlyRecords({
                    showExamRegActionButton: false,
                    showCaseDetail: true,
                    resubmitAppForCert: true,
                    catId: this.contactAssociationTypeId
                }).then(data =>{
                    if(data){
                        this.gradAssetsList = data;
                        this.isDeanLet = false;
                        if(this.gradAssetsList.dlDate !== ''){
                            this.getDletterDate();
                        }
                        if(credentialType === 'Final Medical Diploma' && this.gradAssetsList.isCourierService === 'Yes'){ 
                            this.sendViaCourier = true;
                        }
                        if(credentialType === 'Letter from Dean' && this.gradAssetsList.isCourierService === 'Yes'){ 
                            this.sendViaCourierUpdateFlow = true;
                        }
                        if(this.gradAssetsList.fmdNameDiff === 'Yes' && this.gradAssetsList.fmdNameDoc !== '' && this.gradAssetsList.fmdNameDoc !== undefined){
                            createGradAcceptedPayload({
                                contactId: this.contactId,
                                keyName: diplomaNameDocument
                            }).then(result =>{
                                    if(result){
                                        this.payloadFMDNameDocAccepted = JSON.stringify(result);
                                        this.showAcceptdDiplomaNameDoc = true;
                                    }
                                })
                            this.fmdNameCond = true;
                        }
                        if(this.gradAssetsList.fmdTrans === 'Yes' && this.gradAssetsList.fmdTransFile !== ''){
                            createGradAcceptedPayload({
                                contactId: this.contactId,
                                keyName: diplomaTranslationDocument
                            }).then(result =>{
                                    if(result){
                                        this.payloadFMDTransDocAccepted = JSON.stringify(result);
                                        this.showAcceptdDiplomaTransDoc = true;
                                    }
                                })
                            this.fmdTransCond = true;
                        }                
                        if(this.gradAssetsList.dlNameDiff === 'Yes' && this.gradAssetsList.dlNameDoc !== '' && this.gradAssetsList.dlNameDoc !== undefined){
                            createGradAcceptedPayload({
                                contactId: this.contactId,
                                keyName: deanLetterNameDocument
                            }).then(result =>{
                                    if(result){
                                        this.payloadDeanLetNameDiffExpiredOrAccepted = JSON.stringify(result);
                                        this.showUploadedDeanLetNameDiff = true;
                                    }
                                })
                            this.dlNameCond = true;
                        }
                        if(this.gradAssetsList.dlTrans === 'Yes' && this.gradAssetsList.dlTransFile !== ''){
                            createGradAcceptedPayload({
                                contactId: this.contactId,
                                keyName: deanLetterTranslationDocument
                            }).then(result =>{
                                    if(result){
                                        this.payloadDeanLetEnglishExpiredOrAccepted = JSON.stringify(result);
                                        this.showUploadedDeanLetEnglishDoc = true;
                                    }
                                })
                            this.dlTransCond = true;
                        }               
                        if(this.gradAssetsList.isDeanLetter === 'Yes'){
                            this.showDeanLetterReadOnly = true;
                            this.isDeanLet = true;
                            this.isDeanLetterAddition = true;
                            this.isDeanLetter = true;
                            getDeanLetterExpiredStatus({ contactId: this.contactId, contactAssociationType: this.contactAssociationTypeId })
                                .then(result2 =>{
                                    if(result2){
                                        this.isDeanLetterMandatoryUpload = true;
                                    }
                                    else{
                                        this.isDeanLetterMandatoryUpload = false;
                                    }
                            })
                        }                        
                        if(this.gradAssetsList.dlFile !== ''){
                            createFMDAcceptedPayload({
                                contactId: this.contactId,
                                assetName: "Letter from Dean"
                            }).then(result =>{
                                    if(result){
                                        this.payloadDeanExpiredOrAccepted = JSON.stringify(result);
                                        this.showUploadedDean = true;
                                    }
                                })      
                            this.showdlFile = true;
                        }
                        if(this.gradAssetsList.fmdFile !== ''){
                            createFMDAcceptedPayload({
                                contactId: this.contactId,
                                assetName: "Final Medical Diploma"
                            }).then(result =>{
                                    if(result){
                                        this.payloadFMDiplomaAccepted = JSON.stringify(result);
                                        this.showUploadedDiploma = true;
                                    }
                                })                                
                            this.showfmdFile = true;
                        }
                        if((this.showFtFile || this.showdlFile || this.showfmdFile) && this.isGraduate){
                            this.isGraduate = true;
                        }else{
                            this.isGraduate = false;
                        }
                        this.getCATSRecordInUpdateFlow(this.contactAssociationTypeId);
                        this.getCatCheckbox();
                    }
                })
                .catch(error =>{
                    this.spinner = false;
                    window.console.error('Error: ' + JSON.stringify(error));
                })
            }else{
                this.uploadFileCheck = true;
                this.checkPrimaryDetails();
                this.checkDeanLetter();
                this.contactNameDetails();
                this.getCatCheckbox();
            }
        })
        if(this.showFMDReadOnly === true || this.showFMSTReadOnly === true || this.showDeanLetterReadOnly === true){
            this.showCheckboxVisible = false;
        }     
    }
    getDletterDate(){
        getDlDateForExistingCAT({ contactAssociationType: this.contactAssociationTypeId } ).then(data => {
            if(data){
                this.dlDate = data;
            }
        });
    }
    getCatCheckbox(){
        if(this.contactAssociationTypeStagingId !== undefined){
            getCatCheckboxValues({catsId: this.contactAssociationTypeStagingId} ).then(catsRecord=>{
                if(catsRecord){
                    this.selectedEntityId = catsRecord.Account__c;
                    this.sendViaCourier = catsRecord.Courier_service_for_an_additional_fee__c;
                    this.checkCourierAvail();
                }
            });
        }
    }    
    getCATSRecordInUpdateFlow(contactAssociationTypeId){
        if(contactAssociationTypeId !== undefined){
            getCatCheckboxValues({catsId: this.contactAssociationTypeId} ).then(catsRecord=>{
                if(catsRecord){
                    this.selectedEntityId = catsRecord.Account__c;
                    this.sendViaCourierUpdateFlow = catsRecord.Courier_service_for_an_additional_fee__c;
                    this.checkCourierAvail();
                }
            });
        }
    } 
    checkCourierAvail(){
        this.isPortal = false;
        this.isNonPortalWeb = false;
        this.isNonPortalPaper = false;
        this.isNonPortalPaperFMST = false;        
        if(this.selectedEntityId){  
            checkVerifictn({
                accId: this.selectedEntityId, isdeancheckbox: this.isDeanLetter})
                .then(result =>{ 
                    if(result){
                        if(result === 'PORTAL'){
                            this.sendViaCourierFMST = false;
                            this.sendViaCourier = false;
                            this.sendViaCourierUpdateFlow = false;
                            this.isPortal = true;
                            this.isNonPortalWeb = false;
                            this.isNonPortalPaper = false;
                            this.isNonPortalPaperFMST = false;
                        }else if(result === 'NONPORTAL_EM_Web'){
                            this.isPortal = false;
                            this.isNonPortalWeb = true;
                            this.isNonPortalPaper = false;
                            this.sendViaCourier = false;
                            this.sendViaCourierUpdateFlow = false;
                            this.sendViaCourierFMST = false;
                            this.isNonPortalPaperFMST = false;
                        }else if(result === 'NONPORTAL_PAPER'){
                            this.isPortal = false;
                            this.isNonPortalWeb = false;
                            this.isNonPortalPaper = true;
                            this.isNonPortalPaperFMST = false;
                        }else if(result === 'NONPORTAL_PAPER_FMD_FMST'){
                            this.isPortal = false;
                            this.isNonPortalWeb = false;
                            this.isNonPortalPaper = true;
                            this.isNonPortalPaperFMST = true;
                        }
                    }
            }).catch(error=>{
                window.console.error('error'+JSON.stringify(error));
            });            
            getCatCourierFMST({selectedEntityId: this.selectedEntityId} ).then(courFMST=>{
                if(courFMST){
                    this.sendViaCourierFMST = courFMST;
            }});
        }   
    }
    handleVerReqCourier(event){        
        this.sendViaCourier = event.target.checked;
    }
    handleVerReqCourierFMST(event){        
        this.sendViaCourierFMST = event.target.checked;
    }
    checkPrimaryDetails(){
        if(this.contactId !== undefined){
            getPrimaryAssets({
                contactId: this.contactId, keyVal: diplomaDocument
            })
            .then(result =>{
                if(result){
                    this.isPrimaryDiplomaUploaded = true;
                    getPrimaryAssets({
                        contactId: this.contactId, keyVal: diplomaTranslationDocument
                    })
                    .then(result1 =>{
                        if(result1){
                            this.isDiplomaEnglishUploaded = true;
                        }else{
                            this.isDiplomaEnglishUploaded = false;
                        }
                    })
                    .catch()
                } else {
                    this.isPrimaryDiplomaUploaded = false;
                }
            })
            .catch();
            getPrimaryAssets({
                contactId: this.contactId, keyVal: finalMedicalSchoolTranscriptDocument
            })
            .then(result =>{
                if(result){
                    this.isPrimaryTranscriptUploaded = true;
                    getPrimaryAssets({
                        contactId: this.contactId, keyVal: finalMedicalSchoolTranscriptTranslationDocument
                    })
                        .then(result1 =>{
                            if(result1){
                                this.isTranscriptEnglishUploaded = true;
                            } else {
                                this.isTranscriptEnglishUploaded = false;
                            }
                        })
                        .catch()
                } else {
                    this.isPrimaryTranscriptUploaded = false;
                }
            })
            .catch();
            getPrimaryAssets({
                contactId: this.contactId, keyVal: deanLetterDocument
            })
            .then(result =>{
                if(result){
                    this.isPrimaryDeanUploaded = true;
                    getPrimaryAssets({
                        contactId: this.contactId, keyVal: deanLetterTranslationDocument
                    })
                    .then(result1 =>{
                        if(result1){
                            this.isDeanEnglishUploaded = true;
                        } else {
                            this.isDeanEnglishUploaded = false;
                        }
                    })
                    .catch()
                } else {
                    this.isPrimaryDeanUploaded = false;
                }
            })
            .catch();
        }
    }
    checkDeanLetter(){
        if(this.contactAssociationTypeStagingId !== undefined){
            checkIsDeanLetter({
                contactAssociationStagingId: this.contactAssociationTypeStagingId
            })
            .then(result => {
                if(this.showCheckboxVisible === true){
                    const deanLetterCheck = this.template.querySelector('[data-id="deanLet"]');
                    if(result){                        
                        deanLetterCheck.checked = true;                        
                    }else{
                        deanLetterCheck.checked = false;
                    }
                }
                if(result){
                    this.isDeanLetter = true;
                }else{
                    this.isDeanLetter = false;
                }
            })
            .catch();
        }
    }
    contactNameDetails(){
    }
    handleChangeDiplomaNameDifferent(event){
        this.isDiplomaNameDifferent = event.target.checked;
        if(this.isDiplomaNameDifferent === false){
            this.clearAssetIdFMDNamePayload();
            this.deleteDiplomaNameAssetAndRelatedDoc();
        }
    }
    handleChangeDiplomaNameinEnglish(event){
        this.isDiplomaNameinEnglish = event.target.checked;  
        if(this.isDiplomaNameinEnglish === false){
            this.isDiplomaEnglishUploaded = false; 
            this.clearAssetIdFMDTranslationPayload();
            this.deleteDiplomaTranAssetAndRelatedDoc();         
        }        
    }
    handleChangeDeanLetter(event){
        let isDeanCon = window.confirm(deanMessage);
        const deanLetterDataCheck = this.template.querySelector('[data-id="deanLet"]');       
        if(isDeanCon){            
            this.isDeanLetter = event.target.checked;            
            this.isErrMsg = false;
            this.isSucMsg = false;
            this.isErrMsgDipDetails = false;
            this.isErrMsgTransDetails = false;
            this.sendViaCourierFMST = false;
            if(this.isDeanLetter){
                this.clearAssetIdFMDPayload();
                this.clearAssetIdFMDNamePayload();
                this.clearAssetIdFMDTranslationPayload();
                this.clearAssetIdFMSTranscriptPayload();
                this.clearAssetIdFMSTranscriptNamePayload();
                this.clearAssetIdFMSTranscriptTransPayload();
                this.deleteDiplomaDocFunction();
            }
            else{
                this.isDeanLetterDifferent = false;
                this.isDeanLetterNameinEnglish = false;                
                this.isPrimaryDeanUploaded = false;
                if(this.isPrimaryDeanUploaded === false){
                    this.clearAssetIdDeanPayload();
                    this.deleteDeanAssetAndRelatedDoc();
                    this.dateonDeanLetterDocument = '';
                    this.deanLetterDateVal = '';
                    this.nameonDeanLetterDocument = '';
                    this.nameonDeanLetterDocumentVal = '';
                }
                if(this.isDeanLetterDifferent === false){
                    this.clearAssetIdDeanLetterNameDiffDocPayload();
                    this.deleteDeanNameAssetAndRelatedDoc();
                }
                if(this.isDeanLetterNameinEnglish === false){
                    this.isDeanEnglishUploaded = false;
                    this.clearAssetIdDeanLetEnglishPayload();
                    this.deleteDeanTranAssetAndRelatedDoc();                
                }
            }
            this.contactNameDetails();
            this.getCatCheckbox();
        }
        deanLetterDataCheck.checked = this.isDeanLetter;
    }
    deleteDiplomaDocFunction(){
        this.isDiplomaNameDifferent = false;
        this.isDiplomaNameinEnglish = false;
        this.isFinalMedicalTranscriptDifferent = false;
        this.isFinalMedicalTranscriptinEnglish = false;
        this.isPrimaryDiplomaUploaded = false;
        this.isPrimaryTranscriptUploaded = false;
        if(this.isPrimaryDiplomaUploaded === false){
            this.deleteDiplomaAssetAndRelatedDoc();
            this.nameonDiplomaDocument = '';
            this.nameonDiplomaDocumentVal = '';
        }
        if(this.isPrimaryTranscriptUploaded === false){
            this.nameonFinalTranscriptDocument = '';
            this.nameonFinalDocumentVal = '';
            this.deleteTranscriptAssetAndRelatedDoc();
        }
        if(this.isDiplomaNameDifferent === false){
            this.deleteDiplomaNameAssetAndRelatedDoc();
        }
        if(this.isDiplomaNameinEnglish === false){
            this.isDiplomaEnglishUploaded = false;               
            this.deleteDiplomaTranAssetAndRelatedDoc();                    
        }    
        if(this.isFinalMedicalTranscriptDifferent === false){
            this.deleteTransciptNameAssetAndRelatedDoc();
        }        
        if(this.isFinalMedicalTranscriptinEnglish === false){
            this.isTranscriptEnglishUploaded = false;                    
            this.deleteTransciptTranAssetAndRelatedDoc();
        }
        deleteCredIntakeCATS({
            contactId: this.contactId,
            parentCaseId: this.parentCaseId
        })  
    }
    deleteDiplomaDocFunctionNewUploaded(){
        this.isDiplomaNameDifferent = false;
        this.isDiplomaNameinEnglish = false;
        this.isFinalMedicalTranscriptDifferent = false;
        this.isFinalMedicalTranscriptinEnglish = false;
        this.isPrimaryDiplomaUploaded = false;
        this.isPrimaryTranscriptUploaded = false;
        if(this.isPrimaryDiplomaUploaded === false){
            this.deleteDiplomaAssetAndRelatedDocNewUploaded();
            this.nameonDiplomaDocument = '';
            this.nameonDiplomaDocumentVal = '';
        }
        if(this.isPrimaryTranscriptUploaded === false){
            this.nameonFinalTranscriptDocument = '';
            this.nameonFinalDocumentVal = '';
            this.deleteTranscriptAssetAndRelatedDocNewUploaded();
        }
        if(this.isDiplomaNameDifferent === false){
            this.deleteDiplomaNameAssetAndRelatedDocNewUploaded();
        }
        if(this.isDiplomaNameinEnglish === false){
            this.isDiplomaEnglishUploaded = false;               
            this.deleteDiplomaTranAssetAndRelatedDocNewUploaded();                    
        }   
        if(this.isFinalMedicalTranscriptDifferent === false){
            this.deleteTransciptNameAssetAndRelatedDocNewUploaded();
        }        
        if(this.isFinalMedicalTranscriptinEnglish === false){
            this.isTranscriptEnglishUploaded = false;                    
            this.deleteTransciptTranAssetAndRelatedDocNewUploaded();
        }
        deleteCredIntakeCATS({
            contactId: this.contactId,
            parentCaseId: this.parentCaseId
        })
    }
    handleChangeDeanLetter1(event){
        this.prevVal = !event.target.checked;
        this.template.querySelector('[data-id="deanLet1"]').checked = this.prevVal;
        this.template.querySelector('c-modal-component').show();
    }
    handleYesClick(){
        this.spinner = true;
        this.template.querySelector('[data-id="deanLet1"]').checked = !this.prevVal;
        this.newlyUploadedDocLoading();
        if(this.isDeanLet){
            if(this.template.querySelector('[data-id="deanLet1"]').checked === false){
                this.valueChangeNewUpload = true;
            } 
            else {
                this.valueChangeNewUpload = false;
            }
        }
        this.showDeanLetterReadOnly = false;
        this.isDeanLetterAddition = false;
        this.showCheckboxVisible = true;
        this.showfmdFile = false;
        this.ftReqdCond = false;
        this.resubAppAddDiploma = true;
        this.isDeanLetter = false;
        this.disableEditing = false;
        this.uploadFileCheck = true;
        this.isPrimaryDeanNewlyUploaded = false;
        this.isDeanLetterMandatoryUpload = false;
        if(this.template.querySelector('[data-id="deanLet1"]').checked === false){
            checkIsFinalTranscriptRequired({showExamRegActionButton : this.showExamRegActionButton})
            .then(result => {
                this.spinner = false;
                if(result){
                    this.isFinalTranscriptRequired = true;
                }
            })
        }
        //To delete the dean letter uploaded
        this.isDeanLetterDifferent = false;
        this.isDeanLetterNameinEnglish = false;
        this.isPrimaryDeanUploaded = false;
        if(this.isPrimaryDeanUploaded === false){
            this.clearAssetIdDeanPayload();
            this.deleteDeanAssetAndRelatedDocNewUploaded();
            this.dateonDeanLetterDocument = '';
            this.deanLetterDateVal = '';
            this.nameonDeanLetterDocument = '';
            this.nameonDeanLetterDocumentVal = '';
        }
        if(this.isDeanLetterDifferent === false){
            this.clearAssetIdDeanLetterNameDiffDocPayload();
            this.deleteDeanNameAssetAndRelatedDocNewUploaded();
        }
        if(this.isDeanLetterNameinEnglish === false){
            this.isDeanEnglishUploaded = false;
            this.clearAssetIdDeanLetEnglishPayload();
            this.deleteDeanTranAssetAndRelatedDocNewUploaded();
        }        
        if(this.template.querySelector('[data-id="deanLet1"]').checked){
            this.uploadFileCheck = false;
            this.isDeanLet = true;
            this.isDeanLetter = true;
            this.showDeanLetterReadOnly = true;
            this.disableEditing = true;
            this.isDeanLetterAddition = true;
            this.isPrimaryDiplomaUploaded = false;
            this.isFinalTranscriptRequired = false;
            this.clearAssetIdFMDPayload();
            this.clearAssetIdFMDNamePayload();
            this.clearAssetIdFMDTranslationPayload();
            this.clearAssetIdFMSTranscriptPayload();
            this.clearAssetIdFMSTranscriptNamePayload();
            this.clearAssetIdFMSTranscriptTransPayload();
            //this.getAssetNameStatus();
            //To delete diploma documents
            this.deleteDiplomaDocFunctionNewUploaded(); //to delete only the newly uploaded assets associated to new CATS
            this.spinner = false;
        }
    }
    clearAssetIdFMDPayload(){
        this.showDipUploadButton = false;
        let tempPayload = JSON.parse(this.payloadFinalMedDiploma);
        tempPayload.assetId = '';
        tempPayload.azureUrl = '';
        this.fmdAzureUrl = '';
        this.payloadFinalMedDiploma = JSON.stringify(tempPayload);
        this.showDipUploadButton = true;
    }
    clearAssetIdFMSTranscriptPayload(){
        this.showMedSchoolTranscriptUploadButton = false;
        let tempPayLoadFinalMedSchoolTranscript= JSON.parse(this.payloadFinalMedSchoolTranscript);
        tempPayLoadFinalMedSchoolTranscript.assetId = '';
        tempPayLoadFinalMedSchoolTranscript.azureUrl = '';
        this.fmstAzureUrl = '';
        this.payloadFinalMedSchoolTranscript = JSON.stringify(tempPayLoadFinalMedSchoolTranscript);
        this.showMedSchoolTranscriptUploadButton = true;
    }
    clearAssetIdFMDNamePayload(){
        this.showDipNameDocButton = false;
        let tempPayload = JSON.parse(this.payloadFMDNameDoc);
        tempPayload.assetId = '';
        tempPayload.azureUrl = '';
        this.fmdNameAzureUrl = '';
        this.payloadFMDNameDoc = JSON.stringify(tempPayload);
        this.showDipNameDocButton = true;
    }
    clearAssetIdFMDTranslationPayload(){
        this.showDipTransDocButton = false;
        let tempPayload = JSON.parse(this.payloadFMDTransDoc);
        tempPayload.assetId = '';
        tempPayload.azureUrl = '';
        this.fmdTranAzureUrl = '';
        this.payloadFMDTransDoc = JSON.stringify(tempPayload);
        this.showDipTransDocButton = true;
    }
    clearAssetIdFMSTranscriptNamePayload(){
        this.showTranscriptNameDocButton = false;
        let tempPayload = JSON.parse(this.payloadFMTranscriptNameDoc);
        tempPayload.assetId = '';
        tempPayload.azureUrl = '';
        this.fmstNameAzureUrl = '';
        this.payloadFMTranscriptNameDoc = JSON.stringify(tempPayload);
        this.showTranscriptNameDocButton = true;
    }
    clearAssetIdFMSTranscriptTransPayload(){
        this.showFMTranscriptTransDocButton = false;
        let tempPayload = JSON.parse(this.payloadFMTranscriptTransDoc);
        tempPayload.assetId = '';
        tempPayload.azureUrl = '';
        this.fmstTranAzureUrl = '';
        this.payloadFMTranscriptTransDoc = JSON.stringify(tempPayload);
        this.showFMTranscriptTransDocButton = true;
    }
    clearAssetIdDeanPayload(){
        this.showDeanLetUploadButton = false;
        let tempPayload = JSON.parse(this.payloadDeanLetterDoc);
        tempPayload.assetId = '';
        tempPayload.azureUrl = '';
        this.deanLetUrl = '';
        this.payloadDeanLetterDoc = JSON.stringify(tempPayload);
        this.showDeanLetUploadButton = true;
    }
    clearAssetIdDeanLetterNameDiffDocPayload(){
        this.showDeanLetNameDiffButton = false;
        let tempPayload = JSON.parse(this.payloadDeanLetterNameDiffDoc);
        tempPayload.assetId = '';
        tempPayload.azureUrl = '';
        this.deanLetNameAzureUrl = '';
        this.payloadDeanLetterNameDiffDoc = JSON.stringify(tempPayload);
        this.showDeanLetNameDiffButton = true;
    }
    clearAssetIdDeanLetEnglishPayload(){
        this.showDeanLetEnglishButton = false;
        let tempPayload = JSON.parse(this.payloadDeanLetterEnglishDoc);
        tempPayload.assetId = '';
        tempPayload.azureUrl = '';
        this.deanLetTranAzureUrl = '';
        this.payloadDeanLetterEnglishDoc = JSON.stringify(tempPayload);
        this.showDeanLetEnglishButton = true;
    }
    deleteDiplomaAssetAndRelatedDocNewUploaded(){               
        deleteAssetAndRelatedDocument({
            contactId: this.contactId,
            keyval:diplomaDocument,
            contactAssociationTypeStagingId: this.contactAssociationTypeStagingId
        })
            .then()
            .catch()
    }
    deleteDiplomaNameAssetAndRelatedDocNewUploaded(){
        if(this.isDiplomaNameDifferent===false){
            deleteAssetAndRelatedDocument({
                contactId: this.contactId,
                keyval:diplomaNameDocument,
                contactAssociationTypeStagingId: this.contactAssociationTypeStagingId
            })
                .then()
                .catch()
        }
    }
    deleteDiplomaTranAssetAndRelatedDocNewUploaded(){
        if(this.isDiplomaNameinEnglish===false){
            deleteAssetAndRelatedDocument({
                contactId: this.contactId,
                keyval:diplomaTranslationDocument,
                contactAssociationTypeStagingId: this.contactAssociationTypeStagingId
            })
                .then()
                .catch()
        }
    }
    deleteTranscriptAssetAndRelatedDocNewUploaded(){               
        deleteAssetAndRelatedDocument({
            contactId: this.contactId,
            keyval:finalMedicalSchoolTranscriptDocument,
            contactAssociationTypeStagingId: this.contactAssociationTypeStagingId
        })
            .then()
            .catch()
	} 
	deleteTransciptNameAssetAndRelatedDocNewUploaded(){        
        if(this.isFinalMedicalTranscriptDifferent===false){
            deleteAssetAndRelatedDocument({
                contactId: this.contactId,
                keyval:finalMedicalSchoolTranscriptNameDocument,
                contactAssociationTypeStagingId: this.contactAssociationTypeStagingId
            })
                .then()
                .catch()
        }
    }				
	deleteTransciptTranAssetAndRelatedDocNewUploaded(){
        if(this.isFinalMedicalTranscriptinEnglish===false){
            deleteAssetAndRelatedDocument({
                contactId: this.contactId,
                keyval:finalMedicalSchoolTranscriptTranslationDocument,
                contactAssociationTypeStagingId: this.contactAssociationTypeStagingId
            })
                .then()
                .catch()
        }
    }
    deleteDeanAssetAndRelatedDocNewUploaded(){
        deleteAssetAndRelatedDocument({
            contactId: this.contactId,
            keyval:deanLetterDocument,
            contactAssociationTypeStagingId: this.contactAssociationTypeStagingId
        })
            .then()
            .catch()
    }
    deleteDeanNameAssetAndRelatedDocNewUploaded(){
        if(this.isDeanLetterDifferent===false){
            deleteAssetAndRelatedDocument({
                contactId: this.contactId,
                keyval:deanLetterNameDocument,
                contactAssociationTypeStagingId: this.contactAssociationTypeStagingId
            })
                .then()
                .catch()
        }
    }
    deleteDeanTranAssetAndRelatedDocNewUploaded(){
        if(this.isDeanLetterNameinEnglish===false){
            deleteAssetAndRelatedDocument({
                contactId: this.contactId,
                keyval:deanLetterTranslationDocument,
                contactAssociationTypeStagingId: this.contactAssociationTypeStagingId
            })
                .then()
                .catch()
        }
    }
    handleChangeDeanLetterDifferent(event){
        this.isDeanLetterDifferent = event.target.checked;
        if(this.isDeanLetterDifferent === false){
            this.clearAssetIdDeanLetterNameDiffDocPayload();
            this.deleteDeanNameAssetAndRelatedDoc();
        }
    }
    handleChangeDeanLetterinEnglish(event){
        this.isDeanLetterNameinEnglish = event.target.checked;
        if(this.isDeanLetterNameinEnglish === false){
            this.isDeanEnglishUploaded = false;            
            this.clearAssetIdDeanLetEnglishPayload();
            this.deleteDeanTranAssetAndRelatedDoc();            
        }
    }
    handleChangeDeanLetterDifferentNewly(event){
        this.isDeanLetterDifferent = event.target.checked;
        this.isPrimaryDeanNewlyUploaded = true;
        if(this.isDeanLetterDifferent === false){
            this.clearAssetIdDeanLetterNameDiffDocPayload();
            this.deleteDeanNameAssetAndRelatedDoc();
        }
    }
    handleChangeDeanLetterinEnglishNewly(event){
        this.isDeanLetterNameinEnglish = event.target.checked;
        this.isPrimaryDeanNewlyUploaded = true;
        if(this.isDeanLetterNameinEnglish === false){
            this.isDeanEnglishUploaded = false;            
            this.clearAssetIdDeanLetEnglishPayload();
            this.deleteDeanTranAssetAndRelatedDoc();            
        }
    }
    handleChangeFinalMedicalTranscriptDifferent(event){
        this.isFinalMedicalTranscriptDifferent = event.target.checked;
        if(this.isFinalMedicalTranscriptDifferent === false){
            this.clearAssetIdFMSTranscriptNamePayload();
            this.deleteTransciptNameAssetAndRelatedDoc();
        }
    }
    handleChangeFinalMedicalTranscriptinEnglish(event){
        this.isFinalMedicalTranscriptinEnglish = event.target.checked;
        if(this.isFinalMedicalTranscriptinEnglish === false){
            this.isTranscriptEnglishUploaded = false;
            this.clearAssetIdFMSTranscriptTransPayload();
            this.deleteTransciptTranAssetAndRelatedDoc();
        }
    }
    handleChangeForInputFields(event){
        if(event.target.name === 'nameonDiplomaDocument'){
            this.nameonDiplomaDocument = event.target.value;
        }
        if(event.target.name === 'nameonDeanLetterDocument'){
            this.nameonDeanLetterDocument = event.target.value;
        }
        if(event.target.name === 'nameonFinalTranscriptDocument'){
            this.nameonFinalTranscriptDocument = event.target.value;
        }
        if(event.target.name === 'dateonDeanLetterDocument'){
            this.dateonDeanLetterDocument = event.target.value;
        }
    }
    handleOnDiploma(event){        
        let fmdUrl = event.detail.url;             
        updateCatIDinAssetFMD({catsId: this.contactAssociationTypeStagingId, key: diplomaDocument, parentKey: '',azure : fmdUrl});
        this.isPrimaryDiplomaUploaded = true;
        this.isErrMsgDipDetails = false;
    }
    handleOnDiplomaNameDoc(event){        
        let fmdUrl = event.detail.url;          
        updateCatIDinAssetFMD({catsId: this.contactAssociationTypeStagingId, key: diplomaNameDocument, parentKey: diplomaDocument,azure : fmdUrl})
            .then(assetId => {
            if(assetId){
                this.showDipNameDocButton = false;
                let tempPayload = JSON.parse(this.payloadFMDNameDoc);
                let currentId = tempPayload.assetId;
                if(currentId === 'null' || !currentId){
                    tempPayload.assetId = assetId;
                    tempPayload.azureUrl = fmdUrl;
                    this.fmdNameAzureUrl = fmdUrl;
                    this.payloadFMDNameDoc = JSON.stringify(tempPayload);
                }
                this.showDipNameDocButton = true;
            }
        });
    }
    handleOnTranscript(event){
        let fmstUrl = event.detail.url;             
        updateCatIDinAssetFMD({catsId: this.contactAssociationTypeStagingId, key: finalMedicalSchoolTranscriptDocument, parentKey: '',azure : fmstUrl});
        //updateCatIDinAsset({catsId: '', contactId: this.contactId, key: finalMedicalSchoolTranscriptDocument, parentKey: ''});
        this.isPrimaryTranscriptUploaded = true;
        this.isErrMsgTransDetails = false;
    }
    handleOnTranscriptNameDoc(event){
        let fmstUrl = event.detail.url;          
        updateCatIDinAssetFMD({catsId: this.contactAssociationTypeStagingId, key: finalMedicalSchoolTranscriptNameDocument, parentKey: finalMedicalSchoolTranscriptDocument, azure : fmstUrl})
        //updateCatIDinAsset({catsId: '', contactId: this.contactId, key: finalMedicalSchoolTranscriptNameDocument, parentKey: finalMedicalSchoolTranscriptDocument})
            .then(assetId => {
            if(assetId){
                this.showTranscriptNameDocButton = false;
                let tempPayload = JSON.parse(this.payloadFMTranscriptNameDoc);
                let currentId = tempPayload.assetId;
                if(currentId === 'null' || !currentId){
                    tempPayload.assetId = assetId;
                    tempPayload.azureUrl = fmstUrl;
                    this.fmdNameAzureUrl = fmstUrl;
                    this.payloadFMTranscriptNameDoc = JSON.stringify(tempPayload);
                }
                this.showTranscriptNameDocButton = true;
            }
        });
    }
    handleOnDean(event){
        let deanurl = event.detail.url;
        updateCatIDinAssetFMD({catsId: this.contactAssociationTypeStagingId, contactId: this.contactId, key: deanLetterDocument, parentKey: '', azure: deanurl});
        this.isPrimaryDeanUploaded = true;
        if(this.reSubmitFromAppForCert || this.showDeanLetterReadOnly === true){
            this.isPrimaryDeanNewlyUploaded = true;
        }
    }
    handleOnDeanLetNameDiff(event){
        let deanNameUrl = event.detail.url;
        updateCatIDinAssetFMD({catsId: this.contactAssociationTypeStagingId, contactId: this.contactId, key: deanLetterNameDocument, parentKey: deanLetterDocument, azure: deanNameUrl})
        .then(assetId => {
        if(assetId){
            this.showDeanLetNameDiffButton = false;
            let tempPayload = JSON.parse(this.payloadDeanLetterNameDiffDoc);
            let currentId = tempPayload.assetId;
            if(currentId === 'null' || !currentId){
                tempPayload.assetId = assetId;
                tempPayload.azureUrl = deanNameUrl;
                this.deanLetNameAzureUrl = deanNameUrl;
                this.payloadDeanLetterNameDiffDoc = JSON.stringify(tempPayload);
            }
            this.showDeanLetNameDiffButton = true;
        }
    });
    }
    handleOnDiplomaEnglish(event){
        let fmdUrl = event.detail.url;         
        updateCatIDinAssetFMD({catsId: this.contactAssociationTypeStagingId, key: diplomaTranslationDocument, parentKey: diplomaDocument,azure : fmdUrl})
        //updateCatIDinAsset({catsId: this.contactAssociationTypeStagingId, contactId: this.contactId, key: diplomaTranslationDocument, parentKey: diplomaDocument })
            .then(assetId => {
            if(assetId){
                this.showDipTransDocButton = false;
                let tempPayload = JSON.parse(this.payloadFMDTransDoc);
                let currentId = tempPayload.assetId;
                if(currentId === 'null' || !currentId){
                    tempPayload.assetId = assetId;
                    tempPayload.azureUrl = fmdUrl;
                    this.fmdTranAzureUrl = fmdUrl;
                    this.payloadFMDTransDoc = JSON.stringify(tempPayload);
                }
                this.showDipTransDocButton = true;
            }
        });
        this.isDiplomaEnglishUploaded = true;
    }
    handleOnTranscriptEnglish(event){       
       let fmstUrl = event.detail.url;         
       updateCatIDinAssetFMD({catsId: this.contactAssociationTypeStagingId, key: finalMedicalSchoolTranscriptTranslationDocument, parentKey: finalMedicalSchoolTranscriptDocument, azure : fmstUrl})         
       .then(assetId => {
            if(assetId){
                this.showFMTranscriptTransDocButton = false;
                let tempPayload = JSON.parse(this.payloadFMTranscriptTransDoc);
                let currentId = tempPayload.assetId;
                if(currentId === 'null' || !currentId){
                    tempPayload.assetId = assetId;
                    tempPayload.azureUrl = fmstUrl;
                    this.fmstTranAzureUrl = fmstUrl;
                    this.payloadFMTranscriptTransDoc = JSON.stringify(tempPayload);
                }
                this.showFMTranscriptTransDocButton = true;
            }
        });
        this.isTranscriptEnglishUploaded = true;
    }
    handleOnDeanEnglish(event){
        let deanTransurl = event.detail.url;
        updateCatIDinAssetFMD({catsId: this.contactAssociationTypeStagingId, contactId: this.contactId, key: deanLetterTranslationDocument, parentKey: deanLetterDocument, azure: deanTransurl})
        .then(assetId => {
        if(assetId){
            this.showDeanLetEnglishButton = false;
            let tempPayload = JSON.parse(this.payloadDeanLetterEnglishDoc);
            let currentId = tempPayload.assetId;
            if(currentId === 'null' || !currentId){
                tempPayload.assetId = assetId;
                tempPayload.azureUrl = deanTransurl;
                this.deanLetTranAzureUrl = deanTransurl;
                this.payloadDeanLetterEnglishDoc = JSON.stringify(tempPayload);
            }
            this.showDeanLetEnglishButton = true;
        }
    });
        this.isDeanEnglishUploaded = true;
    }
    deleteDiplomaAssetAndRelatedDoc(){               
        deleteAssetAndRelatedDocument({
            contactId: this.contactId,
            keyval:diplomaDocument,
            contactAssociationTypeStagingId:''
        })
            .then()
            .catch()    
    }
    deleteDeanAssetAndRelatedDoc(){               
        deleteAssetAndRelatedDocument({
            contactId: this.contactId,
            keyval:deanLetterDocument,
            contactAssociationTypeStagingId:''
        })
            .then()
            .catch()    
    }
    deleteTranscriptAssetAndRelatedDoc(){               
        deleteAssetAndRelatedDocument({
            contactId: this.contactId,
            keyval:finalMedicalSchoolTranscriptDocument,
            contactAssociationTypeStagingId:''
        })
            .then()
            .catch()    
    }
    deleteDiplomaNameAssetAndRelatedDoc(){
        if(this.isDiplomaNameDifferent===false){
            deleteAssetAndRelatedDocument({
                contactId: this.contactId,
                keyval:diplomaNameDocument,
                contactAssociationTypeStagingId:''
            })
                .then()
                .catch()
        }
    }
    deleteDiplomaTranAssetAndRelatedDoc(){        
        if(this.isDiplomaNameinEnglish===false){
            deleteAssetAndRelatedDocument({
                contactId: this.contactId,
                keyval:diplomaTranslationDocument,
                contactAssociationTypeStagingId:''
            })
                .then()
                .catch()
        }
    }
    deleteDeanNameAssetAndRelatedDoc(){        
        if(this.isDeanLetterDifferent===false){
            deleteAssetAndRelatedDocument({
                contactId: this.contactId,
                keyval:deanLetterNameDocument,
                contactAssociationTypeStagingId:''
            })
                .then()
                .catch()
        }
    }				
    deleteDeanTranAssetAndRelatedDoc(){        
        if(this.isDeanLetterNameinEnglish===false){
            deleteAssetAndRelatedDocument({
                contactId: this.contactId,
                keyval:deanLetterTranslationDocument,
                contactAssociationTypeStagingId:''
            })
                .then()
                .catch()
        }
    }
    deleteTransciptNameAssetAndRelatedDoc(){        
        if(this.isFinalMedicalTranscriptDifferent===false){
            deleteAssetAndRelatedDocument({
                contactId: this.contactId,
                keyval:finalMedicalSchoolTranscriptNameDocument,
                contactAssociationTypeStagingId:''
            })
                .then()
                .catch()
        }
    }				
	deleteTransciptTranAssetAndRelatedDoc(){        
        if(this.isFinalMedicalTranscriptinEnglish===false){
            deleteAssetAndRelatedDocument({
                contactId: this.contactId,
                keyval:finalMedicalSchoolTranscriptTranslationDocument,
                contactAssociationTypeStagingId:''
            })
                .then()
                .catch()
        }
    }
    completeGraduationProcess(){
        this.isErrMsg = false;
        this.isSucMsg = false;
        this.isFormSubmit = true;
        this.spinner = true;
        this.isErrMsgDipName = false;
        this.isErrMsgFinName = false;
        this.isErrMsgDeanName = false;
        this.isErrMsgDeanLetDate = false;
        this.isErrMsgDeanLetDatePast = false;
        this.isErrMsgDeanLetGreaterthanCurDate = false;
        this.isErrMsgDipDetails = false;
        this.isErrMsgTransDetails = false;
        if(this.isDeanLetter){
            if(this.showDeanLetterReadOnly){
                if(this.isPrimaryDeanNewlyUploaded === false && this.isDeanLetterMandatoryUpload === false){
                    this.isFormSubmit = true;
                    this.directlyToNext = true;
                }else{
                    this.checkValidationBeforeSubmit();
                }
            }else{
                this.checkValidationBeforeSubmit();
            }            
        }else{
            if(this.isFinalTranscriptRequired){
                if(this.showFMDReadOnly === true && this.showFMSTReadOnly === true){
                    this.isFormSubmit = true;
                    this.directlyToNext = true;
                }else{
                    this.checkValidationBeforeSubmit();
                }
            }else{
                if(this.showFMDReadOnly === true){
                    this.isFormSubmit = true;
                    this.directlyToNext = true;
                }else{
                    this.checkValidationBeforeSubmit();
                }
            }
        }
        this.submitDetails();
        window.scrollTo(0, 0);
    }
    checkValidationBeforeSubmit(){
        if(this.showFMDReadOnly === false && this.isDeanLetter === false){
            if(this.isPrimaryDiplomaUploaded === false && this.isDeanLetter === false){
                this.isErrMsgDipDetails = true;
                this.isFormSubmit = false;
                this.spinner = false;
            }
            if(this.isPrimaryDiplomaUploaded === true && this.isDeanLetter === false && (this.nameonDiplomaDocument === null ||
                this.nameonDiplomaDocument === '' || this.nameonDiplomaDocument === undefined)){
                this.isErrMsgDipName = true;
                this.isFormSubmit = false;
                this.spinner = false;
                this.template.querySelector('.diplomaName').classList.add('slds-has-error');
            }
            if(this.isPrimaryDiplomaUploaded === true && this.isDiplomaNameinEnglish === true && this.isDiplomaEnglishUploaded === false){
                this.isErrMsgDipTransDetails = true;
                this.isFormSubmit = false;
                this.spinner = false;
            }
        }
        if(this.isFinalTranscriptRequired === true && this.showFMSTReadOnly === false && this.isDeanLetter === false){
            if(this.isPrimaryTranscriptUploaded === false && this.isDeanLetter === false && this.isFinalTranscriptRequired){
                this.isErrMsgTransDetails = true;
                this.isFormSubmit = false;
                this.spinner = false;
            }
            if(this.isPrimaryTranscriptUploaded === true && this.isDeanLetter === false && (this.nameonFinalTranscriptDocument === null ||
                this.nameonFinalTranscriptDocument === '' || this.nameonFinalTranscriptDocument === undefined)){
                this.isErrMsgFinName = true;
                this.isFormSubmit = false;
                this.spinner = false;
                this.template.querySelector('.finalName').classList.add('slds-has-error');
            }
            if(this.isPrimaryTranscriptUploaded === true && this.isFinalMedicalTranscriptinEnglish === true && this.isTranscriptEnglishUploaded === false){
                this.isErrMsgFinalMedTransDetails = true;
                this.isFormSubmit = false;
                this.spinner = false;
            }
        }
        if(this.isDeanLetter === true){
            if(this.isPrimaryDeanUploaded && this.isPrimaryDiplomaUploaded !== true){
                if((this.isPrimaryDeanUploaded === true || this.isPrimaryDeanNewlyUploaded === true) && (this.nameonDeanLetterDocument === null ||
                    this.nameonDeanLetterDocument === '' || this.nameonDeanLetterDocument === undefined)){
                    this.isErrMsgDeanName = true;
                    this.isFormSubmit = false;
                    this.spinner = false;
                    this.template.querySelector('.deanName').classList.add('slds-has-error');
                }
                if((this.isPrimaryDeanUploaded === true || this.isPrimaryDeanNewlyUploaded === true) && this.isDeanLetterNameinEnglish === true && this.isDeanEnglishUploaded === false){
                    this.isErrMsgDeanLetTransDetails = true;
                    this.isFormSubmit = false;
                    this.spinner = false;
                }
                if(((this.isPrimaryDeanUploaded === true && this.isDeanLetter === true) || this.isPrimaryDeanNewlyUploaded === true)
                    && (this.dateonDeanLetterDocument === null || this.dateonDeanLetterDocument === '' || this.dateonDeanLetterDocument === undefined)){
                    this.isErrMsgDeanLetDate = true;
                    this.isFormSubmit = false;
                    this.spinner = false;
                    this.template.querySelector('.deanDateName').classList.add('slds-has-error');
                }
                if(this.dateonDeanLetterDocument !== null || this.dateonDeanLetterDocument !== ''){
                    var today = new Date();
                    var dd = today.getDate();
                    var mm = today.getMonth() + 1; //January is 0!
                    var yyyy = today.getFullYear();
                    // if date is less then 10, then append 0 before date   
                    if(dd < 10){
                        dd = '0' + dd;
                    } 
                    // if month is less then 10, then append 0 before date    
                    if(mm < 10){
                        mm = '0' + mm;
                    }
                    var todayFormattedDate = yyyy+'-'+mm+'-'+dd;
                    if(this.dateonDeanLetterDocument < todayFormattedDate) {
                        this.isErrMsgDeanLetDatePast = true;
                        this.isFormSubmit = false;
                        this.spinner = false;
                        this.template.querySelector('.deanDateName').classList.add('slds-has-error');
                    }
                    else {
                        this.template.querySelectorAll('.DeanDateValidationError').forEach(element => element.remove());  
                    }  
                }
            }
        }
    }
    submitDetails(){
        if(this.isFormSubmit){
            if(this.directlyToNext){
                if(this.clickedBtn === 'Next'){
                    if(this.showExamRegActionButton){
                        if(this.isPrimaryDeanUploaded || this.isPrimaryDiplomaUploaded || this.isPrimaryTranscriptUploaded){
                            this.checkValidationBeforeSubmit();
                            if(this.isFormSubmit){                                
                                this.updateParentAssetFunction();
                                const selectEvent = new CustomEvent('summaryevent', {detail : false});
                                this.dispatchEvent(selectEvent);    
                            }
                        }else{                        
                            const selectEvent = new CustomEvent('summaryevent', {detail : this.directlyToNext});
                            this.dispatchEvent(selectEvent);
                        }                        
                    }else{
                        const selectEvent = new CustomEvent('nextevent', {});
                        this.dispatchEvent(selectEvent);        
                    }                                
                }
            }else{
                this.updateParentAssetFunction();
            }           
        }
    }
    updateParentAssetFunction(){
        this.isDeanLettertemp = false;
        if(this.dateonDeanLetterDocument === '' || this.dateonDeanLetterDocument === undefined){
            this.dateonDeanLetterDocument= null;
        }
        if((this.isDeanLetterAddition && this.dateonDeanLetterDocument != null) || this.isDeanLetter || this.isDeanLetterMandatoryUpload){
            this.isDeanLettertemp = true;       
        }
        let tempTcRecord = {
            contactId: this.contactId,
            isDeanLetter: this.isDeanLettertemp,
            nameonDiplomaDocument: this.nameonDiplomaDocument,
            isDiplomaNameDifferent: this.isDiplomaNameDifferent,
            isDiplomaNameinEnglish: this.isDiplomaNameinEnglish,
            nameonDeanLetterDocument: this.nameonDeanLetterDocument,
            isDeanLetterDifferent: this.isDeanLetterDifferent,
            isDeanLetterNameinEnglish: this.isDeanLetterNameinEnglish,
            isFinalTranscriptRequired: this.isFinalTranscriptRequired,
            nameonFinalTranscriptDocument: this.nameonFinalTranscriptDocument,
            isFinalMedicalTranscriptDifferent: this.isFinalMedicalTranscriptDifferent,
            isFinalMedicalTranscriptinEnglish: this.isFinalMedicalTranscriptinEnglish,
            dateonDeanLetterDocument: this.dateonDeanLetterDocument,
            showExamRegActionButton: this.showExamRegActionButton,
            reSubmitFromAppForCert: this.reSubmitFromAppForCert
        }
        updateParentAsset({
            jsonString: JSON.stringify(tempTcRecord), couriercheckbox: this.sendViaCourier, courierFMST: this.sendViaCourierFMST
        })
        .then(result => {
            this.spinner = false;
            if(result !== ''){
                this.isErrMsg = false;
                if(JSON.stringify(result).replace('"', '').replace('"', '') === 'true'){
                    this.isErrMsg = true;
                }else{                        
                    this.isErrMsg = false;
                    this.isSucMsg = true;
                    this.checkPrimaryDetails(); 
                    let diplomaObj = { uploadDiploma: this.isPrimaryDiplomaUploaded, uploadDean: this.isPrimaryDeanNewlyUploaded, uploadDiploma: this.isPrimaryDiplomaUploaded, source: 'graduateScreen'}
                    if(this.clickedBtn === 'Next'){
                        if(this.showExamRegActionButton){
                            const selectEvent = new CustomEvent('summaryevent', {detail : diplomaObj});
                            this.dispatchEvent(selectEvent);
                        } else {
                            const selectEvent = new CustomEvent('nextevent', {});
                            this.dispatchEvent(selectEvent);        
                        }                                
                    }
                }
            }
        })
        .catch(error => {
            window.console.error('error',error);
            this.spinner = false;                
        });
    }
    prevButton(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('previousevent', {});
        this.dispatchEvent(selectEvent);
        this.checkPrimaryDetails();
        this.checkDeanLetter();
        this.contactNameDetails();
        deleteDeanLetterOrDiplomaRelatedDoc({
            contactId: this.contactId,
            parentCaseId: this.parentCaseId
        })        
    }
    nextButton(event){
        event.preventDefault();
        this.clickedBtn = 'Next';
        this.completeGraduationProcess();
    }
    saveButton(event){
        event.preventDefault();
        this.clickedBtn = 'Save';
        this.completeGraduationProcess();
    }
    cancelButton(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('cancelevent', {});
        this.dispatchEvent(selectEvent);
        deleteDeanLetterOrDiplomaRelatedDoc({
            contactId: this.contactId,
            parentCaseId: this.parentCaseId
        })
    }
    discardButton(event){
        event.preventDefault();
        const selectEvent = new CustomEvent('discardevent', {});
        this.dispatchEvent(selectEvent);
    }
}