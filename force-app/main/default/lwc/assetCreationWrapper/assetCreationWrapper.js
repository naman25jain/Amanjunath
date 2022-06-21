import {LightningElement, api, track} from "lwc";
import {bytesToSize,base64ToArrayBuffer,showMessage} from "c/common";
import { saveDocument, covertToBase64 } from "c/cloudStorageSave";
import getSobjectType from "@salesforce/apex/AssetCreationWrapperController.getSobjectType";
import getCaseDetail from "@salesforce/apex/AssetCreationWrapperController.getCaseDetail";
import getContactDetail from "@salesforce/apex/AssetCreationWrapperController.getContactDetail";
import fileNameGenerator from '@salesforce/apex/CloudStorageController.fileNameGenerator';
import createAsse2VerRecord from '@salesforce/apex/AssetCreationWrapperController.createAsse2VerRecord';
import getRequestHeaders from "@salesforce/apex/CloudStorageController.getRequestHeaders";
import CloudUploadWrapperStyle from '@salesforce/resourceUrl/CloudUploadWrapperStyle';
import { loadStyle } from 'lightning/platformResourceLoader';
const ONLINE_VERIF = 'Online Verification';
const ONLINE_VERIF_COVER_LETTER= 'Online Verification Cover Letter';
const SUPPORTING_DOC = 'Supporting Documents';
const ADVANCED_DEGREE_IN_MEDICAL_SCIENCES = 'Advanced Degree in the Medical Sciences';
const ALTERNATE_GRADUATION_DOCUMENT = 'Alternate Graduation Document';
const ATTESTATION = 'Attestation';
const CERTIFICATE_OF_GOOD_STANDING = 'Certificate of Good Standing';
const DEANS_LETTER = 'Letter from Dean';
const EIF = 'EIF';
const FINAL_MEDICAL_DIPLOMA = 'Final Medical Diploma';
const FINAL_MEDICAL_SCHOOL_TRANSCRIPT = 'Final Medical School Transcript';
const MED_REG_CERTIFICATE='Medical Registration Certificate/License to Practice Medicine';
const NON_USMLE_TRANSCRIPT='Non-USMLE Transcript';
const NOTARIZED_ID_FORM_DOC = 'Notarized ID Form';
const PREGRADUATE_INTERNSHIP_CREDENTIAL_DOC = 'Pregraduate Internship Credential';
const POSTGRADUATE_MEDICAL_EDUCATION_CREDENTIAL_DOC = 'Postgraduate Medical Education Credential';
const RELEASE_DOC = 'Release';
const SPECIALIST_QUALIFICATION_DOC = 'Specialist Qualification';
const STUDENT_MEDICAL_SCHOOL_TRANSCRIPT_DOC = 'Student Medical School Transcript';
const TRANSFER_CREDIT_TRANSCRIPT_DOC = 'Transfer Credit Transcript';
const USMLE_TRANSCRIPT_DOC = 'USMLE Transcript';
const INCOMPLETE_ATTEST_LETTER = 'Incomplete Attestation Letter';
const ACKNOWLEDGMENT_LETTER = 'Acknowledgment Letter';
const CHARGE_LETTER = 'Charge Letter';
const POLICY_LETTER = 'Policy Letter';
const SUPPORTING_DOCUMENT = 'Supporting Document';
const IB_DECISION_LETTER = 'IB Decision letter';
const NO_IB_DECISION_LETTER = 'No IB Decision letter';
const DOB_DOCUMENT = 'DOB Document';
const CASE_CORRESPONDENCE_ENTITY = 'Case Correspondence - Entity';
const CASE_STATUS_ON_HOLD_PENDING_TRANSLATION = 'On-hold Pending Translation';
const CASE_STATUS_SENT_FOR_VERIFICATION = 'Sent for Verification';
const CASE_STATUS_RESENT_FOR_VERIFICATION = 'Resent for Verification';
const CASE_STATUS_PENDING_VERIFICATION_REVIEW = 'Pending Verification Review';
const CASE_STATUS_VERIFICATION_IN_REVIEW_AT_ECFMG = 'Verification In Review at ECFMG';
const CASE_STATUS_NOT_VERIFIED = 'Not Verified';
const CASE_STATUS_SUBMITTED_IN_REVIEW = 'Submitted - In Review at ECFMG';
const CASE_STATUS_PENDING_CRED_FROM_ENTITY = 'Pending Credential from Entity';
const ASSET_TYPE_CGS = 'Certificate of Good Standing';
const CASE_STATUS_CANCELLED_BY_APPLICANT = 'Cancelled By Applicant';
const CASE_STATUS_CANCELLED_BY_ECFMG = 'Cancelled by ECFMG';
const CASE_STATUS_PENDING_PRINT = 'Pending Print';
const CASE_STATUS_PENDING_EMAIL_CREATION = 'Pending Email Creation';
const CASE_STATUS_IN_REVIEW_AT_ECFMG = 'In Review at ECFMG';
const CASE_STATUS_SENT_TO_APPLICANT = 'Sent to Applicant';
const CASE_STATUS_INCOMPLETE  = 'Incomplete';
const CASE_STATUS_ACCEPTED = 'Accepted';
const CASE_STATUS_PENDING_REVIEW = 'Pending Review';
const CASE_STATUS_IN_REVIEW = 'In Review';
const CASE_STATUS_IRREGULAR_BEHAVIOR = 'Charged with Irregular Behavior';
const CASE_STATUS_SUBMITTED = 'Submitted';
const CASE_STATUS_REJECTED_BY_COMMITTEE_CHAIR = 'Rejected by Committee Chair';
const CASE_STATUS_CLOSED = 'Closed';
const ASSET_RECTYPE_SUPPORTING_DOC = 'Supporting_Documents'
const AUTHORIZED_SIGN_LIST = 'Authorized Signature List';
const ENTITY_SEAL = 'Entity Seal';
const COMPLETED_PIA = 'Completed PIA';
const ASSET_STATUS_ACCEPTED = 'Accepted';
const ASSET_RECTYPE_ENTITY_DOCUMENT = 'Entity_Document';
const ASSET_RECTYPE_ECFMG_CERTIFICATION = 'ECFMG_Certification';
const ASSET_STATUS_IN_PROGRESS = 'In Progress';
const ASSET_RECTYPE_CREDENTIAL = 'Credential';
const ASSET_RECTYPE_IDENTITY = 'Identity';
const ASSET_RECTYPE_ENTITY = 'Entity';
const ASSET_RECTYPE_INVESTIGATION = 'Investigation';
const ASSET_STATUS_SUBMITTED ='Submitted'; 
const ASSET_RECTYPE_ATTESTATION = 'Attestation';
const ASSET_STATUS_SENT = 'Sent';
const ASSET_RECTYPE_SCORE_REPORT = 'Score_Report';
const ASSET_RECTYPE_DECISION_APPEAL = 'Decision_Appeal';
const ASSET_NAME_APPEAL_LETTER = 'Appeal Letter';
const ASSET_NAME_INTERIM_CERTIFICATE ='Interim Certificate';
const ASSET_TYPE_USER_SIGNATURE = 'User Signature';
const ASSET_STATUS_NEW = 'New';
const ERAS_MS_TRANSCRIPT = 'MS Transcript';
const ERAS_MSPE = 'MSPE';
const ERAS_PHOTO = 'Photo';
const picklist1 = [{ label: "User Signature", value: "User Signature" }];
const picklist2 = [
  { label: "Completed PIA", value: "Completed PIA" },
  { label: "Entity Seal", value: "Entity Seal" },
  {label:"Authorized Signature List", value:"Authorized Signature List"},
];
const picklist3 = [
  { label: "Signed Service Form", value: "Signed Service Form" },
  { label: "Signed PIA", value: "Signed PIA" },
];
const ID_VERIFICATION_PICKLIST = [
  { label: "ID Form Notarized", value: "ID Form Notarized" },
];
const picklist4 = [{label: "Returned Enrollment Verification",  value:"Returned Enrollment Verification"}];
const picklist5 = [{ label: "Interim Certificate", value: "Interim Certificate" }];
const picklist6 = [{label: "Name Document", value: "Name Document"}]
const CASE_RECORD_TYPE_IDENTITY_VERIFICATION = "Identity_Verification";
const CASE_RECORD_TYPE_APPLICANT_BIOGRAPHIC_CHANGE = "Applicant_Biographic_Change";
const CASE_RECORD_TYPE_IFOM_REQUEST = "IFOM_Request";
const CASE_RECORD_TYPE_NAME_REVIEW = "Name_Review";
const CASE_RECORD_TYPE_CRED_VERIF = "Credential_Verification";
const CASE_RECORD_TYPE_MED_EDU_FORM = "Medical_Education_Form";
const CASE_RECORD_TYPE_ATTESTATION = 'Attestation';
const CASE_RECORD_TYPE_INVESTIGATION = 'Investigation_Case';
const CASE_RECORD_TYPE_PETITIONFORRECONSDN = 'Petition_for_Reconsideration';
const CASE_RECORD_TYPE_DECISION_APPEAL = 'Decision_Appeal';
const CASE_RECORD_TYPE_BIOGRAPHIC_REVIEW ='Biographic_Review';
const EPIC_VERIFICATION_REPORT_REQUEST = 'EPIC_Verification_Report_Request';
const CASE_RECORD_TYPE_AUTH_SIGN_LIST = 'Authorized_Signature_List';
const CASE_RECORD_TYPE_ERAS = 'ERAS';
const CASE_STATUS_PENDING_SUBMISSION = 'Pending Submission';
const picklist8 = [{label:"Online Verification",value:"Online Verification"},
                   {label:"Online Verification Cover Letter",value:"Online Verification Cover Letter"}];
const picklist9 = [{label:"Advanced Degree in the Medical Sciences",value:"Advanced Degree in the Medical Sciences"},
                  {label:"Alternate Graduation Document",value:"Alternate Graduation Document"},
                  {label:"Attestation",value:"Attestation"},
                  {label:"Certificate of Good Standing",value:"Certificate of Good Standing"},
                  {label:"Dean's Letter",value:"Letter from Dean"},
                  {label:"EIF",value:"EIF"},
                  {label:"Final Medical Diploma",value:"Final Medical Diploma"},
                  {label:"Final Medical School Transcript",value:"Final Medical School Transcript"},
                  {label:"Medical Registration Certificate/License to Practice Medicine",value:"Medical Registration Certificate/License to Practice Medicine"},
                  {label:"Non-USMLE Transcript",value:"Non-USMLE Transcript"},
                  {label:"Notarized ID Form",value:"Notarized ID Form"},
                  {label:"Postgraduate Medical Education Credential",value:"Postgraduate Medical Education Credential"},
                  {label:"Pregraduate Internship Credential",value:"Pregraduate Internship Credential"},                  
                  {label:"Release",value:"Release"},
                  {label:"Specialist Qualification",value:"Specialist Qualification"},
                  {label:"Supporting Documents",value:"Supporting Documents"},
                  {label:"Student Medical School Transcript",value:"Student Medical School Transcript"},
                  {label:"Transfer Credit Transcript",value:"Transfer Credit Transcript"},
                  {label:"USMLE Transcript",value:"USMLE Transcript"}];
const picklist10 = [{label:"Translation",value:"Translation"}];
const picklist11 = [{label:"Returned Verification Packet",value:"Returned Verification Packet"}];
const picklist12 = [{label:"Case Correspondence - Entity", value:"Case Correspondence - Entity"},
{label:"Returned Verification Packet",value:"Returned Verification Packet"}, {label:"Returned Email Response",value:"Returned Email Response"}];
const picklist13 = [{label:"DOB Document",value:"DOB Document"}];
const picklist14 = [{label:"Case Correspondence - Entity", value:"Case Correspondence - Entity"}];
const picklist17 = [{label:"Certificate of Good Standing", value:"Certificate of Good Standing"}];
const picklist15 = [{label:"Incoming Correspondence", value:"Incoming Correspondence"}];
const picklist16 = [{label:"Returned Email Response",value:"Returned Email Response"},
{label:"Returned Verification Packet",value:"Returned Verification Packet"}];
const picklist18 = [{label:"Returned Medical Education Form", value:"Medical Education Form"}];
const picklist19 = [{label:"Online Verification", value:"Online Verification"}];
const picklist20 = [{label:"Returned Attestation Form", value:"Returned Attestation Form"}];
const picklist21 = [{label:"Incomplete Attestation Letter", value:"Incomplete Attestation Letter"}];
const picklist22 = [{label:"Acknowledgment Letter", value:"Acknowledgment Letter"}];
const picklist23 = [{label:"Charge Letter", value:"Charge Letter"}, {label:"Policy Letter", value:"Policy Letter"}, {label:"Supporting Document", value:"Supporting Document"},{label:"Incoming Correspondence", value:"Incoming Correspondence"},
{label:"Evidence", value:"Evidence"}, {label:"IB Decision letter", value:"IB Decision letter"}, {label:"No IB Decision letter", value:"No IB Decision letter"}];
const picklist24 = [{label:"Evidence document", value:"Evidence document"}];
const picklist25 = [{label: "Decision Appeal Letter", value: "Decision Appeal Letter"}];
const picklist26 = [{label:"Committee Chair Decision", value:"Committee Chair Decision"}];
const picklist27 = [{label:"Committee Decision - Granted", value:"Committee Decision - Granted"}];
const picklist28 = [{label:"Committee Decision - Denied", value:"Committee Decision - Denied"}];
const picklist29 = [{label:"Committee Decision - Modified", value:"Committee Decision - Modified"}];
const picklist30 = [{label:"EPIC Verification Report", value:"Verification Report"}];
const picklist31 = [{label:"Authorized Signature List", value:"Authorized Signature List"}];
const picklist32 = [{label:"Photo", value:"Photo"}, {label:"MSPE", value:"MSPE"}, {label:"MS Transcript", value:"MS Transcript"}];
const INCOMING_CORRESPONDENCE = 'Incoming Correspondence';
const EVIDENCE = 'Evidence';
const DECISION_APPEAL_LETTER = 'Decision Appeal Letter';
const actions = [
  { label: "View", name: "view" },
  { label: "Delete", name: "delete" },
  { label: "Save", name: "save" },
];
const columns = [
  { label: "Title", fieldName: "name" },
  { label: "Size", fieldName: "size" },
  {
    type: "button-icon",
    fixedWidth: 48,
    typeAttributes: {
      label: "View",
      name: "view",
      title: "View",
      disabled: false,
      value: "view",
      iconName: "utility:preview",
    },
  },
  {
    type: "button-icon",
    fixedWidth: 48,
    typeAttributes: {
      label: "Delete",
      name: "delete",
      title: "Delete",
      disabled: false,
      value: "delete",
      iconName: "utility:delete",
    },
  },
  {
    type: "button-icon",
    fixedWidth: 48,
    typeAttributes: {
      label: "Save",
      name: "save",
      title: "Save",
      disabled: false,
      value: "save",
      iconName: "utility:save",
    },
  },
  {
    type: "action",
    fixedWidth: 48,
    typeAttributes: { rowActions: actions },
  },
];
export default class AssetCreationWrapper extends LightningElement{
  constructor(){
    super();
    let stylePath = CloudUploadWrapperStyle;
    loadStyle(this, stylePath);
  }
  // Class declaration
  documents = [];
  columns = columns;
  header;
  document;
  assetType = ""; //set as PHOTO or PASSPORT to save the file as JPEG image; otherwise it will be saved as PDF (default)
  // Public properties exposed as Design Parameters
  @api maxAllowedFileSize;
  @api acceptedFileFormats = "";
  @api enableRedaction = false;
  @api enableAnnotation = false;
  @api enableSaving = false;
  // Example payload
  @api payLoad = { recordId: "1234abcd" };
  @track selectedType;
  @track displayUpload = false;
  @track sealContent = false;
  @api recordId;
  @track recordType;
  @track spinner = false;
  @track typePicklist = [];
  @track caseDetail;
  @track caseRecordType;
  connectedCallback(){
    getSobjectType({ recordId: this.recordId }).then((data) => {
      this.recordType = data;
      if(this.recordType === "Contact"){
        getContactDetail({ contactId: this.recordId }).then((conData) => {
          if(conData.RecordType.DeveloperName === "Applicant"){
            this.typePicklist = picklist5;
          } else{ 
            this.typePicklist = picklist1; 
          }
        });
      }else if(this.recordType === "Account"){
        this.typePicklist = picklist2;
      }else if(this.recordType === "Case"){
        getCaseDetail({ caseId: this.recordId }).then((caseData) => {
          this.caseRecordType = caseData.RecordType.DeveloperName;
          this.assignPickListForCase(caseData);
        });
      }
    });
  }
  assignPickListForCase(caseData){
    if(caseData.RecordType.DeveloperName === CASE_RECORD_TYPE_IDENTITY_VERIFICATION || caseData.RecordType.DeveloperName === CASE_RECORD_TYPE_APPLICANT_BIOGRAPHIC_CHANGE){
      this.typePicklist = ID_VERIFICATION_PICKLIST;
    }else if(caseData.RecordType.DeveloperName === CASE_RECORD_TYPE_IFOM_REQUEST){
      this.typePicklist = picklist4;
    }else if(caseData.RecordType.DeveloperName === CASE_RECORD_TYPE_NAME_REVIEW){
      this.typePicklist = picklist6;
    }else if(caseData.RecordType.DeveloperName === EPIC_VERIFICATION_REPORT_REQUEST){
      this.typePicklist = picklist30;
    }else if(caseData.RecordType.DeveloperName === CASE_RECORD_TYPE_BIOGRAPHIC_REVIEW){
      this.typePicklist = picklist13;
    }else if(caseData.RecordType.DeveloperName === CASE_RECORD_TYPE_CRED_VERIF){
      this.pickForCredVerification(caseData);
    }else if(caseData.RecordType.DeveloperName === CASE_RECORD_TYPE_MED_EDU_FORM){
      this.picklistForMedEduForm(caseData);
    }else if(caseData.RecordType.DeveloperName === CASE_RECORD_TYPE_ATTESTATION){
      this.picklistForAttestation(caseData);
    }else if(caseData.RecordType.DeveloperName === CASE_RECORD_TYPE_INVESTIGATION){
      this.picklistForInvestigation(caseData);
    }else if(caseData.RecordType.DeveloperName === CASE_RECORD_TYPE_PETITIONFORRECONSDN){
      this.picklistForPetitionForReconsrn(caseData);
    }else if(caseData.RecordType.DeveloperName === CASE_RECORD_TYPE_DECISION_APPEAL){
      this.typePicklist = picklist25;
    }else if(caseData.RecordType.DeveloperName === CASE_RECORD_TYPE_AUTH_SIGN_LIST){
      this.typePicklist = picklist31;
    }else if(caseData.RecordType.DeveloperName === CASE_RECORD_TYPE_ERAS){
      console.log('caseData.Internal_Status__c ' + caseData.Internal_Status__c);
      if(caseData.Internal_Status__c === CASE_STATUS_PENDING_SUBMISSION || caseData.Internal_Status__c === CASE_STATUS_CLOSED){
        this.typePicklist = {};
      }else{      
      this.typePicklist = picklist32;
      }
    }else{
      this.typePicklist = picklist3;
    }
  }
  picklistForPetitionForReconsrn(caseData){
    var caseInternalStatus = caseData.Internal_Status__c; 
    var caseOutcome = caseData.Case_Outcome__c;
    if(caseInternalStatus === CASE_STATUS_SUBMITTED){
      this.typePicklist = picklist24;
    }else if(caseInternalStatus === CASE_STATUS_REJECTED_BY_COMMITTEE_CHAIR){
      this.typePicklist = picklist26;
    }else if(caseInternalStatus === CASE_STATUS_CLOSED && caseOutcome === 'Granted'){
      this.typePicklist = picklist27;
    }else if(caseInternalStatus === CASE_STATUS_CLOSED && caseOutcome === 'Denied'){
      this.typePicklist = picklist28;
    }else if(caseInternalStatus === CASE_STATUS_CLOSED && caseOutcome === 'Sanction modified'){
        this.typePicklist = picklist29;
    }
  }
  picklistForInvestigation(caseData){
    var caseInternalStatus = caseData.Internal_Status__c;
    if(caseData.RecordType.DeveloperName === CASE_RECORD_TYPE_INVESTIGATION){
      if(caseInternalStatus === CASE_STATUS_IN_REVIEW || caseInternalStatus === CASE_STATUS_PENDING_REVIEW || caseInternalStatus === CASE_STATUS_IRREGULAR_BEHAVIOR){
        this.typePicklist = picklist23;
        this.caseContactId = caseData.ContactId;
      }
    }
  }
  picklistForAttestation(caseData){
    var caseInternalStatus = caseData.Internal_Status__c;
    if(caseData.Case_Type__c === 'Attestation Sub-case'){
      if(caseInternalStatus === CASE_STATUS_IN_REVIEW_AT_ECFMG){
        this.typePicklist = picklist19;
        this.caseContactId = caseData.ContactId;
      }
      else if(caseInternalStatus === CASE_STATUS_SENT_TO_APPLICANT){
        this.typePicklist = picklist20;
        this.caseContactId = caseData.ContactId;
      }
      else if(caseInternalStatus === CASE_STATUS_INCOMPLETE){
        this.typePicklist = picklist21;
        this.caseContactId = caseData.Parent.ContactId;
      }
      else if(caseInternalStatus === CASE_STATUS_ACCEPTED){
        this.typePicklist = picklist22;
        this.caseContactId = caseData.Parent.ContactId;
      }
    }
  }
  pickForCredVerification(caseData){
    var caseInternalStatus = caseData.Internal_Status__c;
    this.caseContactId = caseData.ContactId;
    if(caseInternalStatus === CASE_STATUS_ON_HOLD_PENDING_TRANSLATION){
      this.typePicklist = picklist10;
    }else if(caseInternalStatus === CASE_STATUS_SENT_FOR_VERIFICATION || caseInternalStatus === CASE_STATUS_RESENT_FOR_VERIFICATION){
      this.typePicklist = picklist11;
    }else if(caseInternalStatus === CASE_STATUS_VERIFICATION_IN_REVIEW_AT_ECFMG){
      this.typePicklist = picklist12;
    }else if(caseInternalStatus === CASE_STATUS_NOT_VERIFIED){
      this.typePicklist = picklist14;
    }else if(caseInternalStatus === CASE_STATUS_SUBMITTED_IN_REVIEW){
      this.typePicklist = picklist13;
    }else if(caseInternalStatus === CASE_STATUS_PENDING_CRED_FROM_ENTITY){
      this.typePicklist = picklist17;
    }else if(caseInternalStatus === CASE_STATUS_CANCELLED_BY_APPLICANT || caseInternalStatus === CASE_STATUS_CANCELLED_BY_ECFMG){
      this.picklistForCredVer(caseData.Send_Method__c);
      this.typePicklist = this.typePicklist.concat(picklist15);
    }else if(caseInternalStatus === CASE_STATUS_PENDING_VERIFICATION_REVIEW ){
      this.typePicklist = picklist16;
    }else{
      this.picklistForCredVer(caseData.Send_Method__c);
    }
  }
  picklistForCredVer(sendMethod){
    if(sendMethod === 'Website'){
      this.typePicklist = picklist8;
    }else{
      this.typePicklist = picklist9;
    }    
  }
  picklistForMedEduForm(caseData){
    if(caseData.Internal_Status__c === CASE_STATUS_PENDING_PRINT || caseData.Internal_Status__c === CASE_STATUS_PENDING_EMAIL_CREATION){
      this.typePicklist = picklist18;
    }  
  }  
  // Event to convert modified document from base64 -> blob -> file and add it to the data-table
  async handleSaveDocument(event){
    try {
      let strBase64Data;
      // base64 string document
      if(this.sealContent){
        strBase64Data = await covertToBase64(this.document);
        strBase64Data = strBase64Data.split("base64,")[1]
        this.assetType =  "image/png";
        if(this.document.file.name.split('.').pop() === 'gif'){
          this.assetType =  "image/gif";
        }
        if(this.document.file.name.split('.').pop() === 'jpg'){
          this.assetType =  "image/jpg";
        }
        if(this.document.file.name.split('.').pop() === 'jpeg'){
          this.assetType =  "image/jpeg";
        }
      }else{
        strBase64Data = event.detail.doc;
        this.assetType =  "application/pdf";
      }
      // delete previous document
      this.deleteRow(this.findRowIndexById(event.detail.id));
      // covert base64 to binary (blob)
      let blob = new Blob([base64ToArrayBuffer(strBase64Data)], {
        encoding: "UTF-8",
        type: this.assetType,
      });
      // convert to file
      fileNameGenerator({
        contactId: this.recordId,
        documentType: this.selectedType,
        azureDocUrl: null,
        createOrReplace: 'Create',
        assetId: null
      }).then(data => {
        let fileName = data + '.' + blob.type.substr(blob.type.lastIndexOf("/") + 1, blob.type.length);
        let newfile = new File([blob], fileName, {
          lastModified: Date.now(),
          type: blob.type,
        });
        //add document to data-table
        this.documents = [
          ...this.documents,
          {
            id: Date.now(),
            name: newfile.name,
            size: bytesToSize(newfile.size),
            type: newfile.type,
            file: newfile,
          },
        ];
      })
      //hide modal window
      this.template.querySelector("c-modal").hide();
    } catch (err){
      showMessage(
        err,
        "Error Saving",
        "An error occurred while saving document.",
        "error"
      );
    }
  }
  // Event to show uploaded document in viewer
  handleFileUploaded(event){
    try{
      // set global
      this.document = {
        id: Date.now(),
        name: event.detail.document.name,
        size: bytesToSize(event.detail.document.size),
        type: event.detail.document.type,
        file: event.detail.document,
      };
      //show modal window
      this.header = this.document.name;
      this.template.querySelector("c-modal").show();
    }catch (err){
      showMessage(
        err,
        "Error Uploading",
        "An error occurred while uploading document.",
        "error"
      );
    }
  }
  // Event to show document
  handleMainDocument(){
    this.template.querySelector("c-document-viewer").viewDocument();
  }
  // Event of an action taken on data-table
  handleRowAction(event){
    const actionName = event.detail.action.name;
    const row = event.detail.row;
    switch (actionName){
      case "delete":
        this.deleteDocument(row);
        break;
      case "view":
        this.showDocument(row);
        break;
      case "save":
        this.saveDocument(row);
        break;
      default:
    }
  }
  // Delete document from data-table by row
  deleteDocument(row){
    const { id } = row;
    const index = this.findRowIndexById(id);
    this.deleteRow(index);
  }
  // Delete document from data-table by row index
  deleteRow(index){
    if (index !== -1){
      this.documents = this.documents
        .slice(0, index)
        .concat(this.documents.slice(index + 1));
    }
  }
  // Get data-table row idex
  findRowIndexById(id){
    let ret = -1;
    this.documents.some((row, index) => {
      if (row.id === id){
        ret = index;
        return true;
      }
      return false;
    });
    return ret;
  }
  // Show selected document in viewer
  showDocument(row){
    try{
      //get selected file
      this.document = this.documents.find((x) => x.id === row.id);
      //show modal window
      this.header = this.document.name;
      this.template.querySelector("c-modal").show();
    }catch (err){
      showMessage(
        err,
        "Error Displaying",
        "An error occurred while displaying document.",
        "error"
      );
    }
  }
  async saveDocument(row){
    try {
      this.spinner = true;
      this.document = this.documents.find((x) => x.id === row.id).file;
      let tempPayload = {
        contactId: this.caseContactId,
        caseId: this.recordId,
        type : this.selectedType,
        documentType: 'Online Verification',
        assetRecordType: 'Verification',
        createOrReplace: 'Create',
        assetStatus: 'New',
        assetCreationRequired: 'true',
        assetId: null,
        createFromPB: 'true',
        assetName: null,
        size: this.document.size
      };
      
      if(this.selectedType === ONLINE_VERIF && this.caseRecordType === CASE_RECORD_TYPE_ATTESTATION){
        tempPayload.documentType = ONLINE_VERIF;
        tempPayload.assetStatus = ASSET_STATUS_ACCEPTED;
      }else if(this.selectedType === ONLINE_VERIF){
        tempPayload.documentType = ONLINE_VERIF;
      }else if(this.selectedType === ONLINE_VERIF_COVER_LETTER){
        tempPayload.documentType = ONLINE_VERIF_COVER_LETTER;
      }else if(this.selectedType === SUPPORTING_DOC){
        tempPayload.documentType = SUPPORTING_DOC;
        tempPayload.assetRecordType = ASSET_RECTYPE_SUPPORTING_DOC;
        tempPayload.assetStatus = ASSET_STATUS_IN_PROGRESS;
      }else if(this.selectedType === ALTERNATE_GRADUATION_DOCUMENT){
        tempPayload.documentType = ALTERNATE_GRADUATION_DOCUMENT;
        tempPayload.assetRecordType = ASSET_RECTYPE_CREDENTIAL;
        tempPayload.assetStatus = ASSET_STATUS_IN_PROGRESS;
        tempPayload.assetName = ALTERNATE_GRADUATION_DOCUMENT;
      }else if(this.selectedType === ADVANCED_DEGREE_IN_MEDICAL_SCIENCES){
        tempPayload.documentType = ADVANCED_DEGREE_IN_MEDICAL_SCIENCES;
        tempPayload.assetRecordType = ASSET_RECTYPE_CREDENTIAL;
        tempPayload.assetStatus = ASSET_STATUS_IN_PROGRESS;
        tempPayload.assetName = ADVANCED_DEGREE_IN_MEDICAL_SCIENCES;
      }else if(this.selectedType === ATTESTATION){
        tempPayload.documentType = ATTESTATION;
        tempPayload.assetRecordType = ATTESTATION;
        tempPayload.assetStatus = ASSET_STATUS_IN_PROGRESS;
        tempPayload.assetName = ATTESTATION;
      }else if(this.selectedType === CERTIFICATE_OF_GOOD_STANDING){
        tempPayload.documentType = CERTIFICATE_OF_GOOD_STANDING;
        tempPayload.assetRecordType = ASSET_RECTYPE_CREDENTIAL;
        tempPayload.assetStatus = ASSET_STATUS_SUBMITTED;
        tempPayload.assetName = CERTIFICATE_OF_GOOD_STANDING;
      }else if(this.selectedType === DEANS_LETTER){
        tempPayload.documentType = DEANS_LETTER;
        tempPayload.assetRecordType = ASSET_RECTYPE_CREDENTIAL;
        tempPayload.assetStatus = ASSET_STATUS_IN_PROGRESS;
        tempPayload.assetName = DEANS_LETTER;
      }else if(this.selectedType === EIF){
        tempPayload.documentType = EIF;
        tempPayload.assetRecordType = ASSET_RECTYPE_IDENTITY;
        tempPayload.assetStatus = ASSET_STATUS_IN_PROGRESS;
        tempPayload.assetName = EIF;
      }else if(this.selectedType === FINAL_MEDICAL_DIPLOMA){
        tempPayload.documentType = FINAL_MEDICAL_DIPLOMA;
        tempPayload.assetRecordType = ASSET_RECTYPE_CREDENTIAL;
        tempPayload.assetStatus = ASSET_STATUS_IN_PROGRESS;
        tempPayload.assetName = FINAL_MEDICAL_DIPLOMA;
      }else if(this.selectedType === FINAL_MEDICAL_SCHOOL_TRANSCRIPT){
        tempPayload.documentType = FINAL_MEDICAL_SCHOOL_TRANSCRIPT;
        tempPayload.assetRecordType = ASSET_RECTYPE_CREDENTIAL;
        tempPayload.assetStatus =ASSET_STATUS_IN_PROGRESS;
        tempPayload.assetName = FINAL_MEDICAL_SCHOOL_TRANSCRIPT;
      }else if(this.selectedType === MED_REG_CERTIFICATE){
        tempPayload.documentType = MED_REG_CERTIFICATE;
        tempPayload.assetRecordType = ASSET_RECTYPE_CREDENTIAL;
        tempPayload.assetStatus = ASSET_STATUS_IN_PROGRESS;
        tempPayload.assetName = MED_REG_CERTIFICATE;
      }else if(this.selectedType === NON_USMLE_TRANSCRIPT){
        tempPayload.documentType = NON_USMLE_TRANSCRIPT;
        tempPayload.assetRecordType = ASSET_RECTYPE_SCORE_REPORT;
        tempPayload.assetStatus = ASSET_STATUS_IN_PROGRESS;
        tempPayload.assetName = NON_USMLE_TRANSCRIPT;
      }else if(this.selectedType === NOTARIZED_ID_FORM_DOC){
        tempPayload.documentType = NOTARIZED_ID_FORM_DOC;
        tempPayload.assetRecordType = ASSET_RECTYPE_IDENTITY;
        tempPayload.assetStatus = ASSET_STATUS_IN_PROGRESS;
      }else if(this.selectedType === PREGRADUATE_INTERNSHIP_CREDENTIAL_DOC){
        tempPayload.documentType = PREGRADUATE_INTERNSHIP_CREDENTIAL_DOC;
        tempPayload.assetRecordType = ASSET_RECTYPE_CREDENTIAL;
        tempPayload.assetStatus = ASSET_STATUS_IN_PROGRESS;
      }else if(this.selectedType === POSTGRADUATE_MEDICAL_EDUCATION_CREDENTIAL_DOC){
        tempPayload.documentType = POSTGRADUATE_MEDICAL_EDUCATION_CREDENTIAL_DOC;
        tempPayload.assetRecordType = ASSET_RECTYPE_CREDENTIAL;
        tempPayload.assetStatus = ASSET_STATUS_IN_PROGRESS;
      }else if(this.selectedType === RELEASE_DOC){
        tempPayload.documentType = RELEASE_DOC;
        tempPayload.assetRecordType = ASSET_RECTYPE_IDENTITY;
        tempPayload.assetStatus = ASSET_STATUS_IN_PROGRESS;
      }else if(this.selectedType === SPECIALIST_QUALIFICATION_DOC){
        tempPayload.documentType = SPECIALIST_QUALIFICATION_DOC;
        tempPayload.assetRecordType = ASSET_RECTYPE_CREDENTIAL;
        tempPayload.assetStatus = ASSET_STATUS_IN_PROGRESS;
      }else if(this.selectedType === STUDENT_MEDICAL_SCHOOL_TRANSCRIPT_DOC){
        tempPayload.documentType = STUDENT_MEDICAL_SCHOOL_TRANSCRIPT_DOC;
        tempPayload.assetRecordType = ASSET_RECTYPE_CREDENTIAL;
        tempPayload.assetStatus = ASSET_STATUS_IN_PROGRESS;
      }else if(this.selectedType === TRANSFER_CREDIT_TRANSCRIPT_DOC){
        tempPayload.documentType = TRANSFER_CREDIT_TRANSCRIPT_DOC;
        tempPayload.assetRecordType = ASSET_RECTYPE_CREDENTIAL;
        tempPayload.assetStatus = ASSET_STATUS_IN_PROGRESS;
      }else if(this.selectedType === USMLE_TRANSCRIPT_DOC){
        tempPayload.documentType = USMLE_TRANSCRIPT_DOC;
        tempPayload.assetRecordType = ASSET_RECTYPE_SCORE_REPORT;
        tempPayload.assetStatus = ASSET_STATUS_IN_PROGRESS;
      }else if(this.selectedType === CASE_CORRESPONDENCE_ENTITY){
        tempPayload.documentType = SUPPORTING_DOC;
        tempPayload.assetRecordType = ASSET_RECTYPE_SUPPORTING_DOC;
        tempPayload.assetStatus = ASSET_STATUS_SUBMITTED;
        tempPayload.assetName = CASE_CORRESPONDENCE_ENTITY;
      }else if(this.selectedType === ASSET_TYPE_CGS){
        tempPayload.documentType = ASSET_TYPE_CGS;
        tempPayload.assetRecordType = ASSET_RECTYPE_CREDENTIAL;
        tempPayload.assetStatus = ASSET_STATUS_SUBMITTED;
        tempPayload.assetName = ASSET_TYPE_CGS;
      }else if(this.selectedType === INCOMPLETE_ATTEST_LETTER){
        tempPayload.documentType = INCOMPLETE_ATTEST_LETTER;
        tempPayload.assetRecordType = ASSET_RECTYPE_ATTESTATION;
        tempPayload.assetStatus = ASSET_STATUS_SENT;
        tempPayload.assetName = INCOMPLETE_ATTEST_LETTER;
      }else if(this.selectedType === ACKNOWLEDGMENT_LETTER){
        tempPayload.documentType = ACKNOWLEDGMENT_LETTER;
        tempPayload.assetRecordType = ASSET_RECTYPE_ATTESTATION;
        tempPayload.assetStatus = ASSET_STATUS_SENT;
        tempPayload.assetName = ACKNOWLEDGMENT_LETTER;
      }else if(this.selectedType === INCOMING_CORRESPONDENCE){
        tempPayload.documentType = INCOMING_CORRESPONDENCE;
        tempPayload.assetRecordType = ASSET_RECTYPE_INVESTIGATION;
        tempPayload.assetStatus = ASSET_STATUS_ACCEPTED;
        tempPayload.assetName = INCOMING_CORRESPONDENCE;
      }else if(this.selectedType === EVIDENCE){
        tempPayload.documentType = EVIDENCE;
        tempPayload.assetRecordType = ASSET_RECTYPE_INVESTIGATION;
        tempPayload.assetStatus = ASSET_STATUS_ACCEPTED;
        tempPayload.assetName = EVIDENCE;
      }else if(this.selectedType === AUTHORIZED_SIGN_LIST || this.selectedType === COMPLETED_PIA || this.selectedType === ENTITY_SEAL){
        tempPayload.assetRecordType = ASSET_RECTYPE_ENTITY_DOCUMENT;
        tempPayload.type = this.selectedType;
        tempPayload.assetStatus = ASSET_STATUS_ACCEPTED;
        tempPayload.assetName = this.selectedType;
        tempPayload.accountId = this.recordId;
        tempPayload.caseId = '';
      }else if(this.selectedType === ASSET_NAME_INTERIM_CERTIFICATE){
        tempPayload.assetName = ASSET_NAME_INTERIM_CERTIFICATE
        tempPayload.assetStatus = ASSET_STATUS_ACCEPTED;
        tempPayload.contactId = this.recordId;
        tempPayload.recordType = ASSET_RECTYPE_ECFMG_CERTIFICATION;
        tempPayload.accountId = '';
        tempPayload.caseId = '';
      }else if(this.selectedType === ASSET_TYPE_USER_SIGNATURE){
        tempPayload.assetName = this.selectedType;
        tempPayload.type = this.selectedType;
        tempPayload.assetStatus = ASSET_STATUS_ACCEPTED;
        tempPayload.assetRecordType = ASSET_RECTYPE_ENTITY_DOCUMENT;
        tempPayload.contactId = this.recordId;
        tempPayload.accountId = '';
        tempPayload.caseId = '';
      }else if(this.selectedType === CHARGE_LETTER && this.caseRecordType === CASE_RECORD_TYPE_INVESTIGATION){
        tempPayload.documentType = CHARGE_LETTER;
        tempPayload.assetType = CHARGE_LETTER;
        tempPayload.assetRecordType = ASSET_RECTYPE_INVESTIGATION;
        tempPayload.assetStatus = CASE_STATUS_ACCEPTED;
        tempPayload.assetName = CHARGE_LETTER;
      }else if(this.selectedType === POLICY_LETTER && this.caseRecordType === CASE_RECORD_TYPE_INVESTIGATION){
        tempPayload.documentType = POLICY_LETTER;
        tempPayload.assetType = POLICY_LETTER;
        tempPayload.assetRecordType = ASSET_RECTYPE_INVESTIGATION;
        tempPayload.assetStatus = CASE_STATUS_ACCEPTED;
        tempPayload.assetName = POLICY_LETTER;
      }else if(this.selectedType === SUPPORTING_DOCUMENT && this.caseRecordType === CASE_RECORD_TYPE_INVESTIGATION){
        tempPayload.documentType = SUPPORTING_DOCUMENT;
        tempPayload.assetType = SUPPORTING_DOCUMENT;
        tempPayload.assetRecordType = ASSET_RECTYPE_INVESTIGATION;
        tempPayload.assetStatus = CASE_STATUS_ACCEPTED;
        tempPayload.assetName = SUPPORTING_DOCUMENT;
      }else if(this.selectedType === IB_DECISION_LETTER && this.caseRecordType === CASE_RECORD_TYPE_INVESTIGATION){
        tempPayload.documentType = IB_DECISION_LETTER;
        tempPayload.assetType = IB_DECISION_LETTER;
        tempPayload.assetRecordType = ASSET_RECTYPE_INVESTIGATION;
        tempPayload.assetStatus = CASE_STATUS_ACCEPTED;
        tempPayload.assetName = IB_DECISION_LETTER;
      }else if(this.selectedType === NO_IB_DECISION_LETTER && this.caseRecordType === CASE_RECORD_TYPE_INVESTIGATION){
        tempPayload.documentType = NO_IB_DECISION_LETTER;
        tempPayload.assetType = NO_IB_DECISION_LETTER;
        tempPayload.assetRecordType = ASSET_RECTYPE_INVESTIGATION;
        tempPayload.assetStatus = CASE_STATUS_ACCEPTED;
        tempPayload.assetName = NO_IB_DECISION_LETTER;
      }else if(this.selectedType === DECISION_APPEAL_LETTER && this.caseRecordType === CASE_RECORD_TYPE_DECISION_APPEAL){
        tempPayload.assetRecordType = ASSET_RECTYPE_DECISION_APPEAL;
        tempPayload.assetType = DECISION_APPEAL_LETTER;
        tempPayload.assetStatus = ASSET_STATUS_ACCEPTED;
        tempPayload.assetName = ASSET_NAME_APPEAL_LETTER;
      }else if(this.selectedType === CASE_RECORD_TYPE_AUTH_SIGN_LIST){
        tempPayload.assetRecordType = ASSET_RECTYPE_ENTITY;
        tempPayload.type = AUTHORIZED_SIGN_LIST;
        tempPayload.assetStatus = ASSET_STATUS_ACCEPTED;
        tempPayload.assetName = AUTHORIZED_SIGN_LIST;
      }else if(this.selectedType === DOB_DOCUMENT && this.recordType !== "Contact"){
        tempPayload.assetRecordType = ASSET_RECTYPE_IDENTITY;
        tempPayload.type = DOB_DOCUMENT;
        tempPayload.assetStatus = ASSET_STATUS_IN_PROGRESS;
        tempPayload.assetName = DOB_DOCUMENT;
      }else if(this.selectedType === ERAS_PHOTO){
        tempPayload.assetRecordType = ASSET_RECTYPE_IDENTITY;
        tempPayload.type = ERAS_PHOTO;
        tempPayload.assetStatus= ASSET_STATUS_NEW;
        tempPayload.caseId = this.recordId;
      }else if(this.selectedType === ERAS_MSPE){
        tempPayload.assetRecordType = ASSET_RECTYPE_CREDENTIAL;
        tempPayload.type = 'Medical School Performance Evaluation';
        tempPayload.assetStatus = ASSET_STATUS_NEW;
        tempPayload.caseId = this.recordId;
      }else if(this.selectedType === ERAS_MS_TRANSCRIPT){
        tempPayload.assetRecordType = ASSET_RECTYPE_CREDENTIAL;
        tempPayload.type = FINAL_MEDICAL_SCHOOL_TRANSCRIPT;
        tempPayload.assetStatus = ASSET_STATUS_NEW;
        tempPayload.caseId = this.recordId;
      }
      if(this.selectedType === ONLINE_VERIF && this.caseRecordType === CASE_RECORD_TYPE_ATTESTATION){
        this.payLoad = tempPayload;
      }else if(this.selectedType === ONLINE_VERIF || this.selectedType === ONLINE_VERIF_COVER_LETTER || 
        this.selectedType === SUPPORTING_DOC || this.selectedType === NOTARIZED_ID_FORM_DOC || 
        this.selectedType === PREGRADUATE_INTERNSHIP_CREDENTIAL_DOC || 
        this.selectedType === POSTGRADUATE_MEDICAL_EDUCATION_CREDENTIAL_DOC || 
        this.selectedType === RELEASE_DOC || this.selectedType === SPECIALIST_QUALIFICATION_DOC || 
        this.selectedType === STUDENT_MEDICAL_SCHOOL_TRANSCRIPT_DOC ||
        this.selectedType === TRANSFER_CREDIT_TRANSCRIPT_DOC || this.selectedType === USMLE_TRANSCRIPT_DOC || this.selectedType === EIF || 
        this.selectedType === ALTERNATE_GRADUATION_DOCUMENT || this.selectedType === ADVANCED_DEGREE_IN_MEDICAL_SCIENCES || this.selectedType === ATTESTATION || 
        this.selectedType === CERTIFICATE_OF_GOOD_STANDING || this.selectedType === DEANS_LETTER || this.selectedType === FINAL_MEDICAL_DIPLOMA || 
        this.selectedType === FINAL_MEDICAL_SCHOOL_TRANSCRIPT || this.selectedType === MED_REG_CERTIFICATE || 
        this.selectedType === NON_USMLE_TRANSCRIPT){
        this.payLoad = tempPayload;
        let fullfileUrl;
        getRequestHeaders({documentAccessLevel:'CREATE_UPDATE',fileName:this.document.name,fileExt:'',payLoad:''}).then(result=>{
          if(result){
            fullfileUrl = JSON.parse(result).FileUrl;
            createAsse2VerRecord({url: fullfileUrl,recordId: this.recordId,selectedType: this.selectedType});
          }
        });
      }      
      this.payLoad = tempPayload;
      this.payLoad.isUploadLocation = 'RelatedTab';
      this.payLoad.caseNumber = '';
      let url = await saveDocument(this.document, this.payLoad);
      if(url != null){
        this.spinner = false;
        //show success message
        showMessage(
          null,
          "Success",
          "Your file has been successfully uploaded",
          "success"
        );
        window.location.reload();
      }  
    }catch (err){
      this.spinner = false;
      showMessage(
        err,
        "Error Saving",
        "An error occurred while saving document to Cloud.",
        "error"
      );
    }
  }
  handleType(event){
    this.selectedType = event.detail.value;
    if(this.caseRecordType === CASE_RECORD_TYPE_ATTESTATION && this.caseContactId === undefined){
      this.spinner = false;
      showMessage(
        null,
        "Error Saving",
        "Please select a contact before saving the asset.",
        "error"
      );
    }else{
      this.displayUpload = true;
    }
    if(event.detail.value == 'Entity Seal' || event.detail.value == 'User Signature'){
      this.acceptedFileFormats = '.gif, .png, .jpg, .jpeg';
      this.sealContent = true;
    }else if(event.detail.value == 'Evidence' || event.detail.value == 'Incoming Correspondence' || event.detail.value == 'Charge Letter' || event.detail.value == 'Policy Letter' || event.detail.value == 'Supporting Document' || event.detail.value == 'No IB Decision letter' || event.detail.value == 'IB Decision letter' || event.detail.value == 'Decision Appeal Letter'|| event.detail.value == 'Evidence document' || event.detail.value == 'Committee Chair Decision' || event.detail.value == 'Committee Decision - Granted' || event.detail.value == 'Committee Decision - Denied' || event.detail.value == 'Committee Decision - Modified' || event.detail.value == 'MSPE' || event.detail.value == 'MS Transcript'){
      this.acceptedFileFormats = '.pdf';
      this.sealContent = false;
      if(event.detail.value == ERAS_MSPE || event.detail.value == ERAS_MS_TRANSCRIPT){
        this.maxAllowedFileSize = '1.2';
        }
      }else if(event.detail.value == ERAS_PHOTO){
        this.acceptedFileFormats = '.jpeg';
        this.sealContent = false;
        this.maxAllowedFileSize = '0.150';
      }else{
      this.acceptedFileFormats = '.pdf, .jpeg, .jpg';
      this.sealContent = false;
    }
  }
  handleCloseModal(){
    this.document = null;
  }
}