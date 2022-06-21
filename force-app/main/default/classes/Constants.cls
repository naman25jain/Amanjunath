/**
 * @description Constants
 * Class for Constants
 *
 * @author        Enable Consulting
 * @version       1.0
 */
public class Constants{
  public static final String ACCOUNT_OBJECT_PREFIX = '001';
  public static final String CONTACT_OBJECT_PREFIX = '003';
  public static final String MED_EDU_FORM = 'Medical Education Form';
  //Code added by Shailaja Yerneni - 1/4/2021. User Story#850. aka_Names__c object prefix
  public static final String AKANAMES_OBJECT_PREFIX = 'a1P';
  public static final String CREDENTIAL_REVIEW = 'Credential Review';
  public static final String IN_PROGRESS = 'In Progress';
  //Group Types
  public static final String GROUP_TYPE_QUEUE = 'Queue';
  // Account record Types
  public static final String ACCOUNT_RECORD_TYPE_MEDICAL_SCHOOL = 'Medical School';
  public static final String ACCOUNT_RECORD_TYPE_REGULATORY_ORG = 'Regulatory_Organization';
  public static final String ACCOUNT_RECORD_TYPE_UNAPPROVED_ENTITY = 'Unapproved_New_Entity';
  public static final String ACCOUNT_NAME_MCC='MEDICAL COUNCIL OF CANADA';
  public static final String ACCOUNT_NAME_FSMB='FEDERATION OF STATE MEDICAL BOARDS';
  public static final String ACCOUNT_NAME_NBME='NATIONAL BOARD OF MEDICAL EXAMINERS';
  //Exception handling error message
  public static final String EXCEPTION_HANDLING_ERROR_MESSAGE = 'Error Occured';
  // asset record types
  public static final String ASSET_RECORD_TYPE_IDENTITY = 'Identity';
  public static final String ASSET_RECORD_TYPE_CREDENTIAL = 'Credential';
  public static final String ASSET_RECORD_TYPE_APP_FOR_CERT = 'Application_for_Certification';
  public static final String ASSET_RECORD_TYPE_EXAM_REG = 'Exam_Registration';
  public static final String ASSET_RECORD_TYPE_ENTITY_DOC = 'Entity_Document';
  public static final String ASSET_RECORD_TYPE_MARKED_FOR_DELETION = 'Marked_for_Deletion';
  public static final String ASSET_RECORD_TYPE_ENROLLMENT_VERIFICATION = 'Enrollment_Verification';
  public static final String ASSET_RECORD_TYPE_SCORE_REPORT = 'Score_Report';
  public static final String ASSET_RECORD_TYPE_ENTITY_DOCUMENT = 'Entity Document';
  public static final String ASSET_RECORD_TYPE_ENTITY_DOCUMENT_DEVNAME = 'Entity_Document';
  public static final String ASSET_RECORD_TYPE_SHIPMENT = 'Shipment';
  public static final String ASSET_RECORD_TYPE_ECFMG_CERTIFICATION = 'ECFMG_Certification';
  public static final String ASSET_RECORD_TYPE_VERIFICATION = 'Verification';
  public static final String ASSET_RECORD_TYPE_SUPP_DOCUMENT = 'Supporting_Documents';
  public static final String ASSET_RECORD_TYPE_CORRESPONDENCE = 'Correspondence';
  public static final String ASSET_RECORD_TYPE_MED_EDU_FORM = 'Medical_Education_Form';
  public static final String ASSET_RECORD_TYPE_ATTESTATION = 'Attestation';
  public static final String ASSET_RECORD_TYPE_INVESTIGATION = 'Investigation';
  public static final String ASSET_RECORD_TYPE_PETITION_FOR_RECONSDN= 'Petition_for_Reconsideration';
  public static final String ASSET_RECORD_TYPE_DECISION_APPEAL = 'Decision_Appeal';
  public static final String CASE_DOCUMENT_TYPE_ASSET_EVIDENCE= 'Evidence';
  public static final String ASSET_RECORD_TYPE_SUMMARY = 'Summary';
  // asset status
  public static final String ASSET_STATUS_IN_PROGRESS = IN_PROGRESS;
  public static final String ASSET_STATUS_INCOMPLETE = 'Incomplete';
  public static final String ASSET_STATUS_ACCEPTED = 'Accepted';
  public static final String ASSET_STATUS_VERIFIED = 'Verified';
  public static final String ASSET_STATUS_OUTDATED = 'Outdated';
  public static final String ASSET_STATUS_EXPIRED = 'Expired';
  public static final String ASSET_STATUS_REJECTED = 'Rejected';
  public static final String ASSET_STATUS_MARKED_FOR_DELETION = 'Marked for Deletion';
  public static final String ASSET_STATUS_INPROGRESS = IN_PROGRESS;
  public static final String ASSET_STATUS_APPROVED = 'Approved';
  public static final String ASSET_STATUS_INVALIDATED = 'Invalidated';
  public static final String ASSET_STATUS_NEW = 'New';
  public static final String ASSET_STATUS_SUBMITTED = 'Submitted';
  public static final String ASSET_STATUS_CANCELLED = 'Cancelled';
  public static final String ASSET_STATUS_UNVERIFIED = 'Unverified';
  public static final String ASSET_STATUS_SENT = 'Sent';
  public static final String ASSET_NOT_AUTHENTIC = 'Not Authentic';
  public static final String ASSET_INACTIVE = 'Inactive';
  // Asset Status LWC
  @AuraEnabled
  public final String LWC_ASSET_STATUS_INCOMPLETE = 'Incomplete';
  @AuraEnabled
  public final String LWC_ASSET_STATUS_INPROGRESS = IN_PROGRESS;

  // asset type
  public static final String ASSET_TYPE_TCT = 'Transfer Credit Transcript';
  public static final String ASSET_TYPE_TRANSLATION = 'Translation';
  public static final String ASSET_TYPE_CREDENTIAL_REQUEST = 'Credential Request';
  public static final String ASSET_TYPE_NAME_DOC = 'Name Document';
  public static final String ASSET_TYPE_PRE_MED_LETTER = 'Pre-Med Letter';
  public static final String ASSET_TYPE_PRE_MED_LETTER_TRANSLATION = 'Pre-Med Letter Translation Document';
  public static final String ASSET_TYPE_PRE_MED_LETTER_TRANS = 'Pre-Med Letter Translation';
  public static final String ASSET_TYPE_PRE_MED_LETTER_NAME = 'Pre-Med Letter Name Document';
  public static final String ASSET_TYPE_PRE_MED_LETTER_DOCUMENT = 'Pre-Med Letter Document';
  public static final String ASSET_TYPE_DEAN_LETTER = 'Alternate Graduation Document';
  public static final String ASSET_TYPE_FINAL_MED_DIPLOMA = 'Final Medical Diploma';
  public static final String ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT = 'Final Medical School Transcript';
  public static final String ASSET_TYPE_SCHEDULING_PERMIT = 'Scheduling Permit';
  public static final String ASSET_TYPE_VISA_LETTER = 'Visa Letter';
  public static final String ASSET_TYPE_IDENTITY_VERIFICATION = 'ID Verification';
  public static final String ASSET_TYPE_SIGNED_SERVICE_FORM = 'Signed Service Form';
  public static final String ASSET_TYPE_SIGNED_PIA = 'Signed PIA';
  public static final String ASSET_TYPE_NEW_SERVICE_TEMPLATE = 'New Service Template';
  public static final String ASSET_TYPE_PIA_TEMPLATE = 'PIA Template';
  public static final String ASSET_ENTITY_CONTACT_SIGNED_SIGNATURE_FORM = 'Signed Signature Form';
  public static final String ASSET_ENTITY_CONTACT_USER_SIGNATURE = 'User Signature';
  public static final String ASSET_TYPE_ENROLLMENT_VERIFICATION = 'Enrollment Verification Form';
  public static final String ASSET_TYPE_BIRTH_CERTIFICATE = 'Birth Certificate';
  public static final String ASSET_TYPE_MARRIAGE_CERTIFICATE = 'Marriage Certificate';
  public static final String ASSET_TYPE_OFFICIAL_COURT_ORDER = 'Official Court Order';
  public static final String ASSET_TYPE_US_RESIDENT_ALIEN_CARD = 'U.S. Resident Alien Card';
  public static final String ASSET_TYPE_US_NATURALIZATION_CERTIFICATE = 'U.S. Naturalization Certificate';
  public static final String ASSET_TYPE_US_PASSPORT_CARD = 'U.S. Passport Card';
  public static final String ASSET_TYPE_NON_USMLE_TRANSCRIPT = 'Non-USMLE Transcript';
  public static final String ASSET_TYPE_ENROLLMENT_REVERIFICATION = 'Enrollment Re-verification Form';
  public static final String ASSET_TYPE_VISA_EXCEPTION_DOCUMENTATION = 'Visa Exception Documentation';
  public static final String ASSET_TYPE_USMLE_TRANSCRIPT = 'USMLE Transcript';
  public static final String ASSET_TYPE_SCORE_RECHECK_LETTER = 'Score Recheck Letter';
  public static final String ASSET_TYPE_TCT_DOCUMENT = 'Transfer Credit Transcript Document';
  public static final String ASSET_NAME_DEAN_LETTER = 'Letter from Dean';
  public static final String ASSET_TYPE_COVER_LETTER = 'Cover Letter';
  public static final String ASSET_NAME_COVER_LETTER = 'Enrollment Re-verification Deficiency Cover Letter';
  public static final String ASSET_NAME_ENROLLREV_COVER_LETTER = 'EnrollReverification Cover Letter';
  public static final String ASSET_NAME_VERIFICATION_COVER_LETTER = 'Verification Cover Letter';
  public static final String ASSET_NAME_UNIVERSAL_VERIFICATION_FORM = 'Universal Verification Form';
  public static final String ASSET_NAME_EVIDENCE_FROM_APPLICANT = 'Evidence from applicant';
  public static final String ASSET_NAME_ERAS_FMST = 'ERAS Final Medical School Transcript';
  public static final String ASSET_NAME_MSPE = 'Medical School Performance Evaluation';
  public static final String ASSET_TYPE_RETURNED_ENROLLMENT_VERIFICATION = 'Returned Enrollment Verification';
  public static final String ASSET_TYPE_RETURNED_ENROLLMENT_REVERIFICATION = 'Returned Enrollment Re-verification';
  public static final String ASSET_TYPE_SHIPPING_LABEL = 'Shipping Label';
  public static final String ASSET_TYPE_DUPLICATE_ECFMG_CERTIFICATE = 'Duplicate ECFMG Certificate';
  public static final String ASSET_TYPE_ECFMG_CERTIFICATE = 'ECFMG Certificate';
  public static final String ASSET_TYPE_REPRINTED_ECFMG_CERTIFICATE = 'Reprinted ECFMG Certificate';
  public static final String ASSET_TYPE_FINAL_DIPLOMA_VERIFICATION_FORM = 'Final Diploma Verification Form';
  public static final String ASSET_TYPE_VERIFIED_FINAL_DIPLOMA = 'Verified Final Diploma';
  public static final String ASSET_TYPE_FINAL_TRANSCRIPT_VERIFICATION_FORM = 'Final Transcript Verification Form';
  public static final String ASSET_TYPE_VERIFIED_FINAL_TRANSCRIPT_CREDENTIAL = 'Verified Final Transcript Credential';
  public static final String ASSET_TYPE_TRANSFER_CREDIT_TRANSCRIPT_VERIFICATION_FORM = 'Transfer Credit Transcript Verification Form';
  public static final String ASSET_TYPE_VERIFIED_TRANSFER_CREDIT_TRANSCRIPT = 'Verified Transfer Credit Transcript';
  public static final String ASSET_TYPE_SPECIALIST_QUALIFICATION = 'Specialist Qualification';
  public static final String ASSET_TYPE_VERIFICATION_FORM = 'Verification Form';
  public static final String ASSET_TYPE_ONLINE_VERIFICATION = 'Online Verification';
  public static final String ASSET_TYPE_ONLINE_VERIFICATION_COVER_LETTER = 'Online Verification Cover Letter';
  public static final String ASSET_TYPE_ACCEPTED_VERIFICATION_FORM = 'Accepted Verification Form';
  public static final String ASSET_TYPE_SUPPORTING_DOCUMENTS = 'Supporting Documents';
  public static final String ASSET_TYPE_ENTITY_SEAL = 'Entity Seal';
  public static final String ASSET_TYPE_RETURNED_VERIFICATION_FORM = 'Returned Verification Form';
  public static final String ASSET_TYPE_ENTITY_SUPPORTING_DOCUMENTS = 'Entity Supporting Documents';
  public static final String ASSET_TYPE_RETURNED_CREDENTIAL = 'Returned Credential';
  public static final String ASSET_TYPE_VERIFICATION_PACKET = 'Verification Packet';
  public static final String ASSET_TYPE_DOB_DOCUMENT = 'DOB Document';
  public static final String ASSET_TYPE_INCOMING_CORRESPONDENCE = 'Incoming Correspondence';
  public static final String ASSET_TYPE_EMAIL = 'Email';
  public static final String ASSET_TYPE_MED_EDU_FORM = MED_EDU_FORM;
  public static final String ASSET_TYPE_ATTEST_FORM = 'Attestation Form';
  public static final String ASSET_TYPE_CHARGE_LETTER = 'Charge Letter';
  public static final String ASSET_TYPE_POLICY_LETTER = 'Policy Letter';
  public static final String ASSET_TYPE_SUPPORTING_DOCUMENT = 'Supporting Document';
  public static final String ASSET_TYPE_DECISION_LETTER = 'Decision Letter';
  public static final String ASSET_TYPE_EVIDENCE_DOCUMENT = 'Evidence document';
  public static final String ASSET_TYPE_DECISION_APPEAL_LETTER = 'Decision Appeal Letter';
  public static final String ASSET_TYPE_VERIFICATION_REPORT = 'Verification Report';
  public static final String ASSET_TYPE_PHOTO = 'Photo';
  public static final String ASSET_TYPE_RELEASE = 'Release';
  public static final String ASSET_TYPE_AUTHORIZED_SIGNATURE_LIST = 'Authorized Signature List';
  public static final String ASSET_TYPE_APPLICATION_SUMMARY = 'Application Summary';
  public static final String ASSET_TYPE_INTERIM_CERTIFICATE = 'Interim Certificate';
  public static final String ASSET_TYPE_ADVANCED_DEGREE_IN_MEDSCIENCE = 'Advanced Degree in the Medical Sciences';
  public static final String ASSET_TYPE_MED_REG_CERT_LIC_PRAC_MED = 'Medical Registration Certificate/License to Practice Medicine';
  public static final String ASSET_TYPE_POSTGRADUATE_MEDICAL_EDUCATION_CREDENTIAL = 'Postgraduate Medical Education Credential';
  public static final String ASSET_TYPE_PREGRADUATE_INTERNSHIP_CREDENTIAL = 'Pregraduate Internship Credential';
  public static final String ASSET_TYPE_EIF = 'EIF';
  public static final String ASSET_TYPE_NOTARIZED_IDFORM = 'Notarized ID Form';
  public static final String ASSET_TYPE_ATTEST = 'Attestation';
  public static final String ASSET_TYPE_INCOMPLETE_ATTEST_LETTER = 'Incomplete Attestation Letter';
  public static final String ASSET_TYPE_ATTEST_ACKNOWLEDGMENT_LETTER = 'Acknowledgment Letter';
  
  public static final String ASSET_UPLOAD_LOCATION_DOCEDITTAB = 'DocumentEditingTab';
  public static final String ASSET_UPLOAD_LOCATION_RELATEDTAB = 'RelatedTab';
  //asset name
  public static final String ASSET_NAME_ID_FORM_NOTARIZED = 'ID Form Notarized';
  public static final String ASSET_NAME_ID_FORM_TEMPLATE = 'ID Form Template';
  public static final String ASSET_NAME_PASSPORT = 'Passport';
  public static final String ASSET_NAME_PHOTO = 'Photo';
  public static final String ASSET_NAME_PASSPORT_TRANSLATION = 'Passport Translation Page';
  public static final String ASSET_NAME_PASSPORT_EXPIRATION = 'Passport Expiration Page';
  public static final String ASSET_NAME_TCT_TRANSLATION = 'TCT Translation';
  public static final String ASSET_NAME_TCT_NAME_DOCUMENT = 'TCT Name Document';
  public static final String ASSET_NAME_FINAL_DIPLOMA_TRANSLATION = 'Final Diploma Translation';
  public static final String ASSET_NAME_FINAL_DIPLOMA_NAME_DOCUMENT = 'Final Diploma Name Document';
  public static final String ASSET_NAME_FINAL_TRANSCRIPT_TRANSLATION = 'Final Transcript Translation';
  public static final String ASSET_NAME_FINAL_TRANSCRIPT_NAME_DOCUMENT = 'Final Transcript Name Document';
  public static final String ASSET_NAME_DEAN_LETTER_TRANSLATION = 'Letter from Dean Translation';
  public static final String ASSET_NAME_DEAN_LETTER_NAME_DOCUMENT = 'Letter from Dean Name Document';
  public static final String ASSET_NAME_PML_TRANSLATION = 'Pre-Med Letter Translation';
  public static final String ASSET_NAME_ENREV_COVER_LETTER = 'Enrollment Re-verification Cover Letter';
  public static final String ASSET_NAME_REDACTED_ID_FORM = 'Redacted ID Form';
  public static final String ASSET_NAME_CREDENTIAL_REQUEST = 'Credential Request';
  public static final String ASSET_NAME_CRED_TYPE_TRANSLATION = 'Credential type - Translation';
  public static final String ASSET_NAME_MCC_RELEASE_FORM = 'MCC Release Form';
  public static final String ASSET_NAME_RETURNED_VERIFICATION_PACKET = 'Returned Verification Packet';
  public static final String ASSET_NAME_RETURNED_VERIFICATION_FORM = 'Returned Verification Form';
  public static final String ASSET_NAME_RETURNED_SUPPORTING_DOCUMENTS = 'Returned Supporting Documents';
  public static final String ASSET_NAME_SUPPORTING_DOCUMENTS = 'Supporting Documents';
  public static final String ASSET_NAME_DOB_DOCUMENT = 'DOB Document';
  public static final String ASSET_NAME_RETURNED_EMAIL_RESPONSE = 'Returned Email Response';
  public static final String ASSET_NAME_RETURNED_MED_EDU_FORM = 'Returned Medical Education Form';
  public static final String ASSET_NAME_MED_EDU_COVER = 'Medical Education Form Cover Letter';
  public static final String ASSET_NAME_ACCEPTED_MED_EDU_FORM = 'Accepted Medical Education Form';
  public static final String ASSET_NAME_ATTESTATION_FORM = 'Attestation Form';
  public static final String ASSET_NAME_ATTESTATION_COVER_LETTER = 'Attestation Cover Letter';
  public static final String ASSET_NAME_RETURNED_ATTESTATION_FORM = 'Returned Attestation Form';
  public static final String ASSET_NAME_IB_DECISION_LETTER = 'IB Decision letter';
  public static final String ASSET_NAME_NO_IB_DECISION_LETTER = 'No IB Decision letter';
  public static final String ASSET_NAME_APPEAL_LETTER = 'Appeal Letter';
  public static final String ASSET_NAME_COMMITTEE_CHAIR_DECISION = 'Committee Chair Decision';
  public static final String ASSET_NAME_COMMITTEE_DECISION_GRANTED = 'Committee Decision - Granted';
  public static final String ASSET_NAME_COMMITTEE_DECISION_DENIED = 'Committee Decision - Denied';
  public static final String ASSET_NAME_COMMITTEE_DECISION_MODIFIED = 'Committee Decision - Modified';
  public static final String ASSET_NAME_EPIC_VERIFICATION_REPORT = 'EPIC Verification Report';
  public static final String ASSET_NAME_EPIC_REPORT_PAGE = 'EPIC Report Page';
  public static final String ASSET_NAME_DOCUMENT = 'Name Document';
  public static final String ASSET_NAME_APPLICATION_FOR_CERTIFICATION_SUMMARY = 'Application for Certification Summary';
  public static final String ASSET_DOB_DOCUMENT = 'DOB Document';
  public static final String ASSET_NAME_ASL_TEMPLATE = 'ASL Template 1';
  public static final String ASSET_NAME_ACCOUNT_ESTABLISHMENT_APPLICATION_SUMMARY = 'Account Establishment Application Summary';
  public static final String ASSET_NAME_EXAM_APPLICATION_SUMMARY = 'Exam Application Summary';
  // PDF Butler Template Name
  public static final String PDFBUTLER_NEW_SERVICE_TEMPLATE_1 = 'New Service Template - 1';
  public static final String PDFBUTLER_NEW_SERVICE_TEMPLATE_2 = 'New Service Template - 2';
  public static final Integer PDFBUTLER_NEW_SERVICE_TEMPLATE_FLAG = 6;

  //asset name - LWC
  @AuraEnabled
  public final String LWC_ASSET_NAME_ID_FORM_TEMPLATE = 'ID Form Template';

  // asset keyval
  public static final String ASSET_KEYVAL_VISA_EXCEPTION_DOC = 'Visa Exception Documentation Document';

  // case Deficiency_Reason_RTF__c
  public static final String CASE_DEFICIENCY_REASON_NO_LONGER_ELIGIBLE = 'No Longer Eligible';
  public static final String CASE_DEFICIENCY_REASON_DEGREE_SCHOOL_CHANGED = 'Degree school changed';

  // Case Document Type
  public static final String CASE_DOCUMENT_TYPE_MED_EDU_FORM = MED_EDU_FORM;
  public static final String CASE_DOCUMENT_TYPE_TCT = 'Transcript to Document Transfer Credits';

  // Case send method
  public static final String CASE_SEND_METHOD_ENTITY_PORTAL = 'Entity Portal';
  public static final String CASE_SEND_METHOD_EMAIL = 'Email';
  public static final String CASE_SEND_METHOD_PAPER = 'Paper';
  // Error Message DeveloperName
  public static final String ERROR_SEND_METHOD_COMMENTS = 'Send_Method_Comments';
  public static final String ERROR_SEND_METHOD_ENTITY = 'Send_Method_Entity';
  // case status
  public static final String CASE_STATUS_OPEN = 'Open';
  public static final String CASE_STATUS_NEW = 'New';
  public static final String CASE_STATUS_ON_HOLD_PENDING_INSTITUTION_ADD = 'On Hold - Pending institution Add';
  public static final String CASE_STATUS_CREDENTIAL_REVIEW = CREDENTIAL_REVIEW;
  public static final String CASE_STATUS_PENDING_CREDENTIAL_REVIEW = 'Pending Credential Review';
  public static final String CASE_STATUS_DUPLICATE_CHECK = 'Duplicate Check';
  public static final String CASE_STATUS_ACCOUNT_ESTABLISHED = 'Account Established';
  public static final String CASE_STATUS_PENDING_SUBMISSION = 'Pending Submission';
  @AuraEnabled
  public final String LWC_CASE_STATUS_PENDING_SUBMISSION = 'Pending Submission';
  public static final String CASE_STATUS_CV_ACCEPTED = 'CV Accepted';
  public static final String CASE_STATUS_CV_INCOMPLETE = 'CV Incomplete';
  public static final String CASE_STATUS_CV_REJECTED = 'CV Rejected';
  public static final String CASE_STATUS_ACCEPTED = 'Accepted';
  public static final String CASE_STATUS_REJECTED = 'Rejected';
  public static final String CASE_STATUS_PENDING_CV = 'Pending Credential Verification';
  public static final String CASE_STATUS_PENDING_REVIEW = 'Pending Review';
  public static final String CASE_STATUS_PENDING_CIBIS = 'Pending CIBIS';
  public static final String CASE_STATUS_ERROR_CIBIS = 'Error CIBIS';
  public static final String CASE_STATUS_CIBIS_SEARCH_RESULTS_RECEIVED = 'CIBIS Search Results Received';
  public static final String CASE_STATUS_PENDING_ENROLLMENT = 'Pending Enrollment Verification';
  public static final String CASE_STATUS_REGISTERED = 'Registered';
  public static final String CASE_STATUS_SUBMITTED = 'Submitted';
  public static final String CASE_STATUS_SUBMITTED_IN_REVIEW = 'Submitted - In Review at ECFMG';
  public static final String CASE_STATUS_CLOSED_SCHOOL_CHANGED = 'Closed - School Changed';
  public static final String CASE_STATUS_ENROLLMENT_VERIFICATION_COMPLETE = 'Enrollment Verification Complete';
  public static final String CASE_STATUS_ENROLLMENT_VERIFICATION_INCOMPLETE = 'Enrollment Verification Incomplete';
  public static final String CASE_STATUS_MANUAL_REVIEW_REQUIRED = 'Manual Review Required for Enrollment Verification';
  public static final String CASE_STATUS_RECEIVED_IN_REVIEW = 'Received - In Review at ECFMG';
  public static final String CASE_STATUS_ENROLLMENT_VERIFICATION_RECEIVED = 'Enrollment Verification Received - In Review at ECFMG';
  public static final String CASE_STATUS_ENROLLMENT_VERIFICATION_COMPLETE_MEDSCL = 'Enrollment Verification Complete at Medical School';
  public static final String CASE_STATUS_ENROLLMENT_NOT_VERIFIED_MEDSCL = 'Enrollment Not Verified at Medical School';
  public static final String CASE_STATUS_PENDING_PRINT = 'Pending Print';
  public static final String CASE_STATUS_PENDING_PRINT_VERIFICATION_INCOMPLETE = 'Pending Print - Verification Incomplete';
  public static final String CASE_STATUS_PENDING_PRINT_RESEND = 'Pending Print - Resend';
  public static final String CASE_STATUS_CANCELLED = 'Cancelled';
  public static final String CASE_STATUS_CANCELLED_BY_APPLICANT = 'Cancelled By Applicant';
  public static final String CASE_STATUS_CANCELLED_BY_ECFMG = 'Cancelled by ECFMG';
  public static final String CASE_STATUS_ENROLLMENT_VERIFIED = 'Enrollment Verified';
  public static final String CASE_STATUS_ENROLLMENT_COMPLETED = 'Complete';
  public static final String CASE_STATUS_PENDING_ADDRESS_REVIEW = 'Pending Address Review';
  public static final String CASE_STATUS_RESUBMITTED_IN_REVIEW = 'Resubmitted - In Review';
  public static final String CASE_STATUS_IN_REVIEW = 'In Review';
  public static final String CASE_STATUS_IN_PROGRESS = 'In Progress';
  public static final String CASE_STATUS_RESUBMITTED_PENDING_REVIEW = 'Resubmitted - Pending Review';
  public static final String CASE_STATUS_SENT = 'Sent';
  public static final String CASE_STATUS_PENDING_INITIAL_REVIEW = 'Pending Initial Review';
  public static final String CASE_STATUS_APPROVED = 'Approved';
  public static final String CASE_STATUS_PENDING_SIGNATURE_UPLOAD = 'Pending Signature Upload';
  public static final String CASE_STATUS_EXPIRED = 'Expired';
  public static final String CASE_STATUS_POSTED_TO_ENTITY_PORTAL = 'Posted to Entity Portal';
  public static final String CASE_STATUS_PENDING_USER_ACCESS = 'Pending User Access';
  public static final String CASE_STATUS_PENDING_COORDINATOR_APPROVAL = 'Pending Coordinator Approval';
  public static final String CASE_STATUS_PENDING_SIGNATURE_CHECK = 'Pending Signature Check';
  public static final String CASE_STATUS_PENDING_NEW_SERVICE = 'Pending New Service';
  public static final String CASE_STATUS_DUPLICATE_REVIEW_COMPLETE = 'Duplicate Review Complete';
  public static final String CASE_STATUS_INCOMPLETE = 'Incomplete';
  public static final String CASE_STATUS_INTERNAL_PENDING_APPLICANT_ACTION_NOTARIZE_ID = 'Pending Applicant Action-Notarize ID Form';
  public static final String CASE_STATUS_INTERNAL_PENDING_APPLICANT_ACTION_RESUBMIT_NOTARIZE_ID = 'Pending Applicant Action-Resubmit Notarized ID Form';
  public static final String CASE_STATUS_CLOSED_NO_LONGER_ELIGIBLE = 'Closed - No Longer Eligible';
  public static final String CASE_STATUS_RESUBMITTED_PENDING_ID_REVIEW = 'Resubmitted-Pending ID Review';
  public static final String CASE_STATUS_RETURN_ECFMG_CERTIFICATE = 'Pending Applicant Action - Return ECFMG Certificate';
  public static final String CASE_MANUAL_REJECTION_REASON_ENROLLED = 'Applicant is not enrolled at the medical school';
  public static final String CASE_MANUAL_REJECTION_REASON_BASIC_SCIENCE = 'Applicant has not completed their basic sciences requirement';
  public static final String CASE_STATUS_ONLINE_NOTARY_SESSION_INITIATED = 'Online Notary Session Initiated';
  public static final String CASE_STATUS_ONLINE_NOTARY_SESSION_REINITIATED = 'Online Notary Session Reinitiated';
  public static final String CASE_STATUS_ONLINE_NOTARY_SESSION_CREATED = 'Online Notary Session Created';
  public static final String CASE_STATUS_ONLINE_NOTARY_SESSION_COMPLETED = 'Online Notary Session Completed';
  public static final String CASE_STATUS_ONLINE_NOTARY_SESSION_REJECTED = 'Online Notary Session Rejected';
  public static final String CASE_STATUS_ONLINE_NOTARY_SESSION_FAILED = 'Online Notary Session Failed';
  public static final String CASE_STATUS_COMPILE_PACKET = 'Compile Packet';
  public static final String CASE_STATUS_COMPILE_VF_PACKET = 'Compile Verification Packet';
  public static final String CASE_STATUS_PENDING_APPLICANT_ACTION_RESUBMIT_DOCUMENTS = 'Pending Applicant Action - Resubmit Documents';
  public static final String CASE_STATUS_RESENT_FOR_VERIFICATION = 'Resent for Verification';
  public static final String CASE_STATUS_VERIFICATION_EXTRACTION_COMPLETE = 'Verification Extraction Complete';
  public static final String CASE_STATUS_SENT_FOR_VERIFICATION = 'Sent for Verification';
  public static final String CASE_STATUS_INCOMPLETE_RESENT_FOR_VERIFICATION = 'Incomplete - Resent for Verification';
  public static final String CASE_STATUS_PENDING_CREDENTIAL_FROM_ENTITY = 'Pending Credential from Entity';
  public static final String CASE_STATUS_IN_REVIEW_AT_ECFMG = 'In Review at ECFMG';
  public static final String CASE_STATUS_INCOMPLETE_RESENT_TO_APPLICANT = 'Incomplete - Resent to Applicant';
  public static final String CASE_STATUS_PENDING_BIO_REVIEW = 'Pending Biographic Review';
  @AuraEnabled
  public final String LWC_CASE_STATUS_ONLINE_NOTARY_SESSION_CREATED = 'Online Notary Session Created';
  public static final String CASE_STATUS_PENDING_ID_VERIFICATION_REVIEW = 'Pending ID Verification Review';
  public static final String CASE_STATUS_FINAL_QA_COMPLETE = 'Final QA Complete';
  public static final String CASE_STATUS_PENDING_EMAIL_CREATION = 'Pending Email Creation';
  public static final String CASE_STATUS_PENDING_VER_REVIEW = 'Pending Verification Review';
  public static final String CASE_STATUS_PENDING_RES_REVIEW = 'Pending Restrictions Review';
  public static final String CASE_STATUS_NOT_VERIFIED = 'Not Verified';
  public static final String CASE_STATUS_PENDING_ID_REVIEW = 'Pending ID Review';
  public static final String CASE_STATUS_RESUBMITTED_PENDING_ID_VERIFICATION_REVIEW = 'Resubmitted-Pending ID Verification Review';
  public static final String CASE_STATUS_ADDED = 'Added';
  public static final String CASE_STATUS_DUPLICATE_RECORD = 'Duplicate Record';
  public static final String CASE_STATUS_PENDING_RESEND = 'Pending Resend';
  public static final String CASE_STATUS_RESENT = 'Resent';
  public static final String CASE_STATUS_MANUAL_REV_EV = 'Manual Review Started for Enrollment Verification';
  public static final String CASE_STATUS_TRANSCRIPTS_PRINTED = 'Transcripts Printed';
  public static final String CASE_STATUS_RECEIVED = 'Received';
  public static final String CASE_STATUS_INTERNAL_PENDING_APPLICANT_ACTION_RESUBMIT_ID_DOC = 'Pending Applicant Action-Resubmit ID Documents';
  public static final String CASE_STATUS_ID_REVIEW = 'ID Review';
  public static final String CASE_STATUS_ID_VER = 'ID Verification';
  public static final String CASE_STATUS_PREV_VERIFIED_ACCEPTED = 'Previously Verified - Accepted';
  public static final String CASE_STATUS_PARTIAL_PREVIOUSLY_VERIFIED = 'Partially Previously Verified';
  public static final String CASE_STATUS_VERIFICATION_IN_REVIEW = 'Verification In Review at ECFMG';
  public static final String CASE_STATUS_VERIFICATION_INCOMPLETE = 'Verification Incomplete';
  public static final String CASE_STATUS_IN_REVIEW_AT_ENTITY = 'In Review at Entity';
  public static final String CASE_STATUS_DUPLICATE_REVIEW = 'Duplicate Review';
  public static final String CASE_STATUS_INST_ADD_COMPLETE = 'Institution Add Complete';
  public static final String CASE_STATUS_INST_ADD_REJECTED = 'Institution Add Rejected';
  public static final String CASE_STATUS_UNABLE_TO_VERIFY_CRED = 'Unable to Verify Credential';
  public static final String CASE_STATUS_ON_HOLD_PENDING_TRANS = 'On-hold Pending Translation';
  public static final String CASE_STATUS_CLOSED_NOT_AUTHENTIC = 'Closed - Not Authentic';
  public static final String CASE_ENTITY_EXTERNAL_STATUS_NOT_REVIWED = 'Not Reviewed';
  public static final String CASE_ENTITY_EXTERNAL_STATUS_REVIWED = 'Reviewed';
  public static final String CASE_STATUS_MARKED_FOR_DELETION = 'Marked for Deletion';
  public static final String CASE_STATUS_PENDING_AAMC_REVIEW = 'Pending AAMC Review';
  @AuraEnabled
  public final String LWC_CASE_STATUS_IN_REVIEW_AT_ENTITY = 'In Review at Entity';
  // Case Status Standard
  public static final String CASE_STATUS_CLOSED = 'Closed';
  public static final String CASE_STATUS_NOT_APPLICABLE = 'Not Applicable';
  //Transcript Short Text Field ValueS
  public static final String TRANSCRIPT_ANOTATION_NBME_PART_HISTORY = 'NBME - Part History';
  public static final String TRANSCRIPT_ANOTATION_ECFMG_PART_HISTORY = 'ECFMG - Part History';
  public static final String TRANSCRIPT_ANOTATION_FSMB_FLEX_HISTORY = 'FSMB - FLEX History';
  public static final String TRANSCRIPT_ANOTATION_FSMB_NO_BOARD_ACTION = 'FSMB - No Board Action Info';
  public static final String TRANSCRIPT_ANOTATION_FSMB_BOARD_ACTION = 'FSMB - Board Action Info';
  public static final String TRANSCRIPT_ANOTATION_IRREGULAR_BEHAVIOR_NON_ADMIN_PROACTIVE = 'Irregular Behavior - Non-Administrative, Proactive';
  public static final String TRANSCRIPT_ANOTATION_IRREGULAR_BEHAVIOR_ADMIN_PROACTIVE = 'Irregular Behavior - Administrative, Proactive';
  public static final String TRANSCRIPT_ANOTATION_INTERPRETATION_OF_SCORES = 'Interpretation of scores';
  public static final String TRANSCRIPT_ANOTATION_APPEARING_UNDER_COMMENTS = 'Annotations appearing under comments';
  public static final String TRANSCRIPT_ANOTATION_ANNOTATIONS_APPEARING_AS_NOTE = 'Annotations appearing as note';
  public static final String TRANSCRIPT_ANOTATION_IRREGULAR_BEHAVIOR_NON_ADMIN_REGULAR = 'Irregular Behavior - Non-Administrative, Regular';
  public static final String TRANSCRIPT_ANOTATION_STEP2_CS_HISTORY = 'Step 2 CS History';
  public static final String TRANSCRIPT_ANOTATION_ECFMG_CSA_HISTORY = 'ECFMG - CSA History';
  public static final String TRANSCRIPT_ANOTATION_TEST_ACCOM_SPOKEN_ENGLISH_PROFICIENCY = 'Test Accommodation - Spoken English Proficiency';
  // case verification status
  public static final String CASE_VERIFICATION_STATUS_ENROLLED = 'Enrolled';
  public static final String CASE_VERIFICATION_STATUS_GRADUATED = 'Graduated';
  public static final String CASE_VERIFICATION_DECEASED = 'Deceased';
  public static final String CASE_VERIFICATION_ENROLLED = 'Enrolled';
  public static final String CASE_VERIFICATION_STATUS_NOT_REVIEWED = 'Not Reviewed';
  public static final String CASE_VERIFICATION_WITHDRAWN = 'Withdrawn';
  public static final String CASE_VERIFICATION_DISMISSED = 'Dismissed';
  public static final String CASE_VERIFICATION_TRANSFERRED = 'Transferred';
  public static final String CASE_VERIFICATION_NEVER_ATT_NOT_STUDENT = 'Never attended; Not our student';
  // Send Request
  public static final String SEND_METHOD_ENTITY_PORTAL = 'Entity Portal';
  public static final String SEND_METHOD_PAPER = 'Paper';
  public static final String SEND_METHOD_EMAIL = 'Email';
  public static final String COURIER_FEE_PAYABLE_BY_ECFMG = 'ECFMG';
  public static final String SEND_METHOD_WEBSITE = 'Website';
  public static final String COURIER_TYPE_FEDEX = 'FedEx';
  public static final String COURIER_TYPE_DHL = 'DHL';
  // case external status
  public static final String CASE_EXTERNAL_STATUS_NOT_REVIEWED = 'Not Reviewed';
  public static final String CASE_EXTERNAL_STATUS_SUBMITTED_TO_ECFMG = 'Submitted to ECFMG';
  public static final String CASE_EXTERNAL_STATUS_RESUBMITTED_IN_REVIEW_ECFMG = 'Resubmitted; In Review at ECFMG';
  public static final String CASE_EXTERNAL_STATUS_INTERNAL_PENDING_APPLICANT_ACTION_NOTARIZE_ID = 'Pending Applicant Action-Notarize Identity Form';
  public static final String CASE_EXTERNAL_STATUS_INTERNAL_PENDING_APPLICANT_ACTION_RESUBMIT_ID = 'Pending Applicant Action-Resubmit Identification Documents';
  public static final String CASE_EXTERNAL_STATUS_PENDING_APPLICANT_ACTION_RESUBMIT_NOT_ID = 'Pending Applicant Action-Resubmit Notarized Identity Form';
  public static final String CASE_EXTERNAL_STATUS_RESUBMITTED_ID_REVIEW = 'Resubmitted for Identification Review';
  public static final String CASE_EXTERNAL_STATUS_SUBMITTED_ID_REVIEW = 'Submitted for Identification Review';
  public static final String CASE_EXTERNAL_STATUS_RESUBMITTED_ID_VER_REVIEW = 'Resubmitted for Identity Verification Review';
  public static final String CASE_EXTERNAL_STATUS_SUBMITTED_ID_VER_REVIEW = 'Submitted for Identity Verification Review';
  public static final String CASE_EXTERNAL_STATUS_PENDING_ACTION_REV = 'Pending Applicant Action';
  public static final String CASE_EXTERNAL_STATUS_PENDING_DOC = 'Pending Documentation';
  // case Entity External Status
  public static final String CASE_ENTITY_EXTERNAL_STATUS_IN_PROCESS = 'In Process';
  public static final String CASE_ENTITY_EXTERNAL_STATUS_NEW = 'New';
  public static final String CASE_ENTITY_EXTERNAL_STATUS_COMPLETE = 'Complete';

  //case document tyupe4
  public static final String CASE_DOC_TYPE_FINAL_MED_DIPLOMA = 'Final Medical Diploma';
  public static final String CASE_DOC_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT = 'Final Medical School Transcript';
  public static final String CASE_DOC_TYPE_MEDICAL_SCHOOL_FORM = MED_EDU_FORM;
  public static final String CASE_DOC_TYPE_PREGRADUATE_INTERNSHIP_CREDENTIAL = 'Pregraduate Internship Credential';
  public static final String CASE_DOC_TYPE_POSTGRADUATE_MEDICAL_EDUCATION_CREDENTIAL = 'Postgraduate Medical Education Credential';

  //Case applicant selected document type
   public static final String CASE_APP_SELECTED_DOC_TYPE_PREGRADUATE_INTERNSHIP_CERTIFICATE = 'Pregraduate Internship Certificate';
   public static final String CASE_APP_SELECTED_DOC_TYPE_POSTGRADUATE_TRAINING_CREDENTIAL = 'Postgraduate Training Credential';


  // verification request status
  public static final String VERIFICATION_REQUEST_STATUS_PENDING = 'Pending';
  public static final String VERIFICATION_REQUEST_STATUS_SCORED = 'Scored';
  public static final String VERIFICATION_REQUEST_STATUS_PROCESSED = 'Processed';
  public static final String VERIFICATION_REQUEST_STATUS_ERROR = 'Error';

  // verification request file status
  public static final String VERIFICATION_REQUEST_FILE_STATUS_PENDING = 'Pending';
  public static final String VERIFICATION_REQUEST_FILE_STATUS_PROCESSED = 'Processed';
  public static final String VERIFICATION_REQUEST_FILE_STATUS_ERROR = 'Error';

  //verification request record types
  public static final String VERIFICATION_REQUEST_RECORD_TYPE_CREDENTIAL_REVIEW = 'Credential_Review_Request';
  public static final String VERIFICATION_REQUEST_RECORD_TYPE_IFOM = 'IFOM_Request';

  // account record types
  public static final String ACCOUNT_RECORD_TYPE_HOUSEHOLD = 'Household Account';
  public static final String ACCOUNT_RECORD_TYPE_ENTITY = 'Entity';

  // account record types developer name
  public static final String ACCOUNT_RECORD_TYPE_DEV_ENTITY = 'Entity';

  // contact record types
  public static final String CONTACT_RECORD_TYPE_EICS_APPLICANT = 'EICS Applicant';
  public static final String CONTACT_RECORD_TYPE_REG_USR = 'Registered User';
  public static final String CONTACT_RECORD_TYPE_IFOM_APP = 'IFOM Applicant';
  public static final String CONTACT_RECORD_TYPE_ENTITY_CONT = 'Entity Contact';
  public static final String CONTACT_RECORD_TYPE_ENTITY_USER = 'New Entity User';

  public static final String CONTACT_RECORD_TYPE_DEACTIVATE = 'Deactivated-Duplicated';
  public static final String CONTACT_RECORD_TYPE_IFOM_APPLICANT = 'IFOM_Applicant';
  public static final String CONTACT_RECORD_TYPE_ENTITY_CONTACT = 'Entity_Contact';
  public static final String CONTACT_RECORD_TYPE_ENTITYUSER = 'New_Entity_User';
  public static final String CONTACT_RECORD_TYPE_APPLICANT = 'Applicant';
  public static final String CONTACT_RECORD_TYPE_REGISTERED = 'Registered_User';

  //contact Current Citizenship Country
  public static final String CONTACT_CURRENT_CITIZENSHIP = 'USA';

  // case record types
  public static final String CASE_RECORD_TYPE_ENTITY_SERVICE_REQUEST = 'Entity Service Request';
  public static final String CASE_RECORD_TYPE_NEW_ENTITY_REQUEST = 'New Entity Request';
  public static final String CASE_RECORD_TYPE_CREDENTIAL_REVIEW = CREDENTIAL_REVIEW;
  //Secretariat Document request platform event
  public static final String PAYLOAD_ENTITY = 'candidate';
  public static final String PAYLOAD_SUBENTITY = '';
  public static final String PAYLOAD_TRANSACTIONID = 'c407e88bfe1c-403c-bf3b-c18147722a93';
  public static final String PAYLOAD_OPERATION = 'GET';
  public static final String PAYLOAD_SECRETARIATDOCUMENTINFO = 'secretariatDocumentInfo';

  //case record types developer name
  public static final String CASE_RECORD_TYPE_IDENTITY_VERIFICATION = 'Identity_Verification';
  public static final String CASE_RECORD_TYPE_APP_BIO_CHANGE = 'Applicant_Biographic_Change';
  public static final String CASE_RECORD_TYPE_APP_FOR_CERT = 'Application_For_Certification';
  public static final String CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION = 'Credential_Verification';
  public static final String CASE_RECORD_TYPE_EXAM_REGISTRATION = 'Exam_Registration';
  public static final String CASE_RECORD_TYPE_REGION_CHANGE = 'Region_Change';
  public static final String CASE_RECORD_TYPE_ELIGIBILITY_PERIOD = 'Eligibility_Period_Extension';
  public static final String CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION = 'Enrollment_Verification';
  public static final String CASE_RECORD_TYPE_USMLE_TRANSCRIPT = 'USMLE_Transcript';
  public static final String CASE_RECORD_TYPE_ENROLLMENT_REVERIFICATION = 'Enrollment_Reverification';
  public static final String CASE_RECORD_TYPE_SCORE_REPORT = 'Score_Report';
  public static final String CASE_RECORD_TYPE_NON_USMLE_TRANSCRIPT = 'Non_USMLE_Transcript';
  public static final String CASE_RECORD_TYPE_SCORE_RECHECK = 'Score_Recheck';
  public static final String CASE_RECORD_TYPE_IFOM_REQUEST = 'IFOM_Request';
  public static final String CASE_RECORD_TYPE_ENTITY_USER_REQUEST = 'Entity_User_Request';
  public static final String CASE_RECORD_TYPE_ECFMG_CERTIFICATION = 'ECFMG_Certification';
  public static final String CASE_RECORD_TYPE_DUPLICATE_CERTIFICATE = 'Duplicate_Certificate';
  public static final String CASE_RECORD_TYPE_J1_INVITATION = 'J1_Invitation';
  public static final String CASE_RECORD_TYPE_DEV_ENTITY_SERVICE_REQUEST = 'Entity_Service_Request';
  public static final String CASE_RECORD_TYPE_NAME_REVIEW = 'Name_Review';
  public static final String CASE_RECORD_TYPE_EPIC_EXTRACTION = 'Epic_Extraction';
  public static final String CASE_RECORD_TYPE_BIOGRAPHIC_REVIEW = 'Biographic_Review';
  public static final String CASE_RECORD_TYPE_EXTRACTION_SUB_CASE = 'Extraction_Sub_case';
  public static final String CASE_RECORD_TYPE_ENTITY_CON_DETAILS_UPDATE = 'Entity_Contact_Details_Update';
  public static final String CASE_RECORD_TYPE_DEV_NEW_ENTITY_REQUEST = 'New_Entity_Request';
  public static final String CASE_RECORD_TYPE_NOTIFICATION = 'Notification';
  public static final String CASE_RECORD_TYPE_PAPER_FILE_REQ = 'Paper_File_Request';
  public static final String CASE_RECORD_TYPE_AUTH_SIGN_LIST = 'Authorized_Signature_List';
  public static final String CASE_RECORD_TYPE_MED_EDU_RES = 'Medical_Education_Resources';
  public static final String CASE_RECORD_TYPE_MED_EDU_FORM = 'Medical_Education_Form';
  public static final String CASE_RECORD_TYPE_FCVS_REQUEST = 'FCVS_Request';
  public static final String CASE_RECORD_TYPE_ATTESTATION = 'Attestation';
  public static final String CASE_RECORD_TYPE_INVESTIGATION = 'Investigation_Case';
  public static final String CASE_RECORD_TYPE_PETITION_FOR_RECONSN = 'Petition_for_Reconsideration';
  public static final String CASE_RECORD_TYPE_DECISION_APPEAL = 'Decision_Appeal';
  public static final String CASE_RECORD_TYPE_EPIC_VER_REPORT_REQUEST = 'EPIC_Verification_Report_Request';
  public static final String CASE_RECORD_TYPE_ERAS = 'ERAS';
  //case status
  public static final String CASE_STATUS = 'Incomplete';
  public static final String CASE_STATUS_RESUBMITTED = 'Resubmitted - Pending Review';
  //Case Service
  public static final String CASE_SERVICE_ECFMG_CERT = 'ECFMG_Certification';
  // case queues
  public static final String CASE_QUEUE_ENTITY_SERVICE_REQUESTS = 'Entity Service Request Queue';
  public static final String CASE_QUEUE_CREDENTIAL_REVIEW = 'Credential Review Queue';
  public static final String CASE_QUEUE_DUPLICATE_CHECK = 'Duplicate Check Queue';
  public static final String CASE_QUEUE_ENROLLMENT_VERIFICATION = 'Enrollment Verification';
  public static final String CASE_QUEUE_ENROLLMENT_RE_VERIFICATION = 'Enrollment Reverification';
  public static final String CASE_QUEUE_MANUAL_REVIEW = 'Manual Review';
  public static final String CASE_QUEUE_MANUAL_REVIEW_ENROLLMENT_RE_VERIFICATION = 'Manual Review Enrollment Reverification';
  public static final String CASE_QUEUE_SCORE_REPORTS = 'Score_Reports';
  public static final String CASE_QUEUE_ENTITY_USER_REQUESTS = 'Entity User Requests';
  public static final String CASE_QUEUE_APP_FOR_CERT = 'Application for Certification';
  public static final String CASE_QUEUE_EXAM_REG = 'Exam Registration';
  public static final String CASE_QUEUE_USMLE_TRANSCRIPTS = 'Exam Transcripts';
  public static final String CASE_SPECIAL_INVESTIGATIONS_QUEUE = 'Special Investigations Queue';
  public static final String CASE_QUEUE_ECFMG_CERTIFICATION = 'ECFMG Certification';
  public static final String CASE_QUEUE_BIOGRAPHIC_REVIEW = 'Biographic Review';
  public static final String CASE_QUEUE_CREDENTIAL_VERIFICATION = 'Credential_Verification';
  public static final String CASE_QUEUE_CREDENTIAL_VERIFICATION_NAME = 'Credential Verification';
  public static final String CASE_QUEUE_CREDENTIAL_REVIEW_QUEUE = 'Credential_Review_Queue';
  public static final String CASE_QUEUE_VERIFICATION_REVIEW_QUEUE = 'Verification_Review';
  public static final String CASE_QUEUE_PRINT_QUEUE = 'Print Queue';
  public static final String CASE_QUEUE_NOT_AUTHENTIC_LIST = 'Not_Authentic';
  public static final String CASE_QUEUE_VERIFICATION_REVIEW = 'Verification_Review';
  public static final String CASE_QUEUE_NOT_VERIFIED = 'Not_Verified';
  public static final String CASE_QUEUE_ENTITY_UPDATE_REQUESTS = 'Entity Update Requests Queue';
  public static final String CASE_QUEUE_NOTIFICATION = 'Notifications Queue';
  public static final String CASE_QUEUE_AUTH_SIGN_LIST = 'Authorized Signature List Queue';
  public static final String CASE_QUEUE_MED_EDU_RES = 'Medical Education Resources Queue';
  public static final String CASE_QUEUE_NOT_VERIFIED_NAME = 'Not Verified';
  public static final String CASE_QUEUE_MED_EDU_FORM = MED_EDU_FORM;
  public static final String CASE_QUEUE_EPIC_REP_REQ = 'EPIC Reports Request';
  public static final String CASE_QUEUE_VERIFICATION_PENDING = 'Verification Pending';
  public static final String CASE_QUEUE_VER_PROCESS_COMPLETE = 'Verification Processing Complete';
  //guest user
  public static final String ENTITY360_SITE_GUEST_USER = 'Entity 360 Site Guest User';

  // case types
  public static final String CASE_TYPE_NEW_ENTITY_REQUEST = 'New Entity Request';
  public static final String CASE_TYPE_ENTITY_DETAILS_CHANGE = 'Entity Details Change';
  public static final String CASE_TYPE_NEW_PAPER_FILE_REQUEST = 'New Paper File Request';
  public static final String CASE_TYPE_NEW_AUTH_SIGN_LIST_REQ = 'New Authorized Signature List Request';
  public static final String CASE_TYPE_NEW_MED_EDU_RES_REQ = 'New Medical Education Resources Request';
  public static final String CASE_TYPE_ATTESTATION_CASE = 'Attestation Case';
  public static final String CASE_TYPE_ATTESTATION_SUB_CASE = 'Attestation Sub-case';
  public static final String CASE_TYPE_DOB_REVIEW = 'DOB Review';
  public static final String CASE_TYPE_ERAS = 'ERAS';

  // case services
  public static final String CASE_SERVICE_ECFMG_CERTIFICATION = 'ECFMG_Certification';
  public static final String CASE_SERVICE_EPIC = 'EPIC';
  public static final String CASE_SERVICE_FCVS = 'FCVS';
  public static final String CASE_SERVICE_EICS = 'EICS';
  // Case Report Type
  public static final String CASE_REPORT_TYPE_VOLUME_ENTITY = 'Volume Entity';
  // Case EPIC Report Status
  public static final String CASE_EPIC_REPORT_STATUS_REPORT_SENT = 'Report Sent';
  public static final String CASE_EPIC_REPORT_STATUS_REPORT_REQUESTED = 'Report Requested';
  public static final String CASE_EPIC_REPORT_STATUS_REQUESTED = 'Requested';
  // Case EPIC Payment History
  public static final String CASE_PAYMENT_HISTORY_FREE_REPORT = 'Free report';
  //Custom notification types
  public static final String CUSTOM_NOTIFICATION_TYPE_CRED_VER_CASE_RESUBMITTED = 'Credential_Verification_Case_is_Resubmitted';
  public static final String CUSTOM_NOTIFICATION_TYPE_CRED_VER_CASE_TASK_COMPLETED = 'CV_Case_Document_is_rescan_and_Task_is_completed';
  public static final String CUSTOM_NOTIFICATION_TYPE_ATTESTATION_CASE_COMPLETED = 'The_Returned_Attestation_Form_has_been_saved';
  // content document link
  public static final String CONTENT_DOCUMENT_LINK_SHARE_TYPE_INFERRED = 'I';
  public static final String CONTENT_DOCUMENT_LINK_VISIBILITY_ALL_USERS = 'AllUsers';

  // misc
  public static final String REQUEST_VERIFICATION_LINKED_ENTITY_ID_ATTRIBUTE_NAME = 'Linked Entity ID';
  public static final String PERCENT_CHARACTER = '%';
  // Contact Association Credential Typs
  public static final String CONASCTYPE_CRED_TYPES_MED_REG_CERT_LIC_PRAC_MED  ='Medical Registration Certificate/License to Practice Medicine';


  //Contact Association Type recordtypes
  public static final String CONASCTYPE_RECORD_TYPE_DEGREE_MED_SCHOOL = 'Degree Medical School';
  public static final String CONASCTYPE_TYPE_DEGREE_SCHOOL = 'Degree School';

  //Contact Association Type Recordtypes Devname
  public static final String CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL = 'Degree_Medical_School';
  public static final String CONASCTYPE_RECORD_TYPE_MEDICAL_SCHOOL = 'Medical_School';
  public static final String CONASCTYPE_RECORD_TYPE_OTHER_INSTITUTION = 'Other_Institution';
  public static final String CONASCTYPE_RECORD_TYPE_REGULATORY_ORGANIZATION = 'Regulatory_Organization';
  public static final String CONASCTYPE_RECORD_TYPE_CREDENTIAL_INTAKE = 'Credential_Intake';
  //Contact Association Type Staging Status
  public static final String CONASCTYPESTG_STATUS_GRADUATE = 'Graduate';
  public static final String CONASCTYPESTG_STATUS_STUDENT = 'Student';
  //Contact Association Type Staging Recordtypes
  public static final String CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL = 'Degree_Medical_School';
  public static final String CONASCTYPESTG_RECORD_TYPE_MEDICAL_SCHOOL = 'Medical_School';
  public static final String CONASCTYPESTG_RECORD_TYPE_OTHER_INSTITUTION = 'Other_Institution';
  public static final String CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL_EXAM_REG = 'Exam_Registration_Degree_Medical_School';
  public static final String CONASCTYPESTG_RECORD_TYPE_MEDICAL_SCHOOL_EXAM_REG = 'Exam_Registration_Medical_School';
  public static final String CONASCTYPESTG_RECORD_TYPE_OTHER_INSTITUTION_EXAM_REG = 'Exam_Registration_Other_Institution';
  public static final String CONASCTYPESTG_RECORD_TYPE_CREDENTIAL_INTAKE = 'Credential_Intake';
  public static final String CONASCTYPESTG_RECORD_TYPE_REGULATORY_ORGANIZATION = 'Regulatory_Organization';
  //Contact Association Type Staging Field Labels
  public static final String CONASCTYPESTG_FIELD_LABEL_ISSUE_DATE = 'Issue Date';
  public static final String CONASCTYPESTG_FIELD_LABEL_DEGREE_ISSUE_DATE = 'Degree Issue Date';
  public static final String CONASCTYPESTG_FIELD_LABEL_DEGREE_EXP_ISSUE_DATE = 'Date degree expected to be issued';
  public static final String CONASCTYPESTG_FIELD_LABEL_DEGREE_TITLE = 'Degree Title';
  public static final String CONASCTYPESTG_FIELD_LABEL_TITLE = 'Title';
  //Store the default Portal Account
  public static final Id PORTAL_ACCOUNT_ID = System.Label.Portal_Account_ID;
  //Store the Profile Name
  public static final String COMMUNITY_USER_INACTIVE_PROFILE = '5-Inactive-Unknown-Community';
  public static final String Entity_360_USER_PROFILE = '4-Customer Community Entity 360';
  public static final String Applicant_360_USER_PROFILE = '4-Customer Community Plus Login';
  public static final String SYSTEM_ADMIN_USER_PROFILE = 'System Administrator';

  //Store the Content version Id
  public static final Id ECFMG_LOGO = System.Label.ECFMG_LOGO;

  //Static Resources
  public static final String PDF_LOGO = 'PDF_logo';

  //Day value for start and end dates.
  public static final String CONASCTYPE_START_END_DAY = '01';

  //Confirmation message metadata type
  public static final String CONFIRMATION_MESSAGE_APP_FOR_CERT = 'Confirm_App_Cert';
  public static final String CONFIRMATION_MESSAGE_ENTITY_SERVICE_REQUEST = 'Entity_Service_Request_Confirmation';
  public static final String CONFIRMATION_MESSAGE_EPIC_CRE_VERI = 'Confirm_Epic_Cred_Verification';
  public static final String CONFIRMATION_MESSAGE_CRED_INTAKE = 'Confirm_Credential_Intake';
  //Product Name List
  public static final String PRODUCT_NAME_APP_FOR_CERT_LEGAL_TERMS = 'End User Legal Terms - AppForCert';
  public static final String PRODUCT_NAME_EXAM_REGISTRATION_LEGAL_TERMS = 'End User Legal Terms - ExamReg';
  public static final String PRODUCT_NAME_REGION_CHANGE_LEGAL_TERMS = 'End User Legal Terms - RegionChange';
  public static final String PRODUCT_NAME_EPEX_LEGAL_TERMS = 'End User Legal Terms - EPeX';
  public static final String PRODUCT_NAME_TRANSCRIPT_REQUEST_LEGAL_TERMS = 'End User Legal Terms - TranscriptRequest';
  public static final String PRODUCT_NAME_SCORE_RECHECK_LEGAL_TERMS = 'End User Legal Terms - ScoreRecheck';
  public static final String PRODUCT_NAME_EPIC_LEGAL_TERMS = 'End User Legal Terms - EPIC';
  public static final String PRODUCT_NAME_CRED_INTAKE_LEGAL_TERMS = 'End User Legal Terms - CredentialIntake';
  @AuraEnabled
  public final String PRODUCT_NAME_ONLINE_NOTARY_CONFIRMATION_LEGAL_TERMS = 'End User Legal Terms - IDForm';
  //Product Code
  public static final String PRODUCT_CODE_ID_FORM = 'ID Form';
  @AuraEnabled
  public final String LWC_PRODUCT_NAME_APP_FOR_CERT_LEGAL_TERMS = 'End User Legal Terms - AppForCert';
  @AuraEnabled
  public final String LWC_PRODUCT_NAME_EXAM_REGISTRATION_LEGAL_TERMS = 'End User Legal Terms - ExamReg';
  @AuraEnabled
  public final String LWC_PRODUCT_NAME_REGION_CHANGE_LEGAL_TERMS = 'End User Legal Terms - RegionChange';
  @AuraEnabled
  public final String LWC_PRODUCT_NAME_EPEX_LEGAL_TERMS = 'End User Legal Terms - EPeX';
  @AuraEnabled
  public final String LWC_PRODUCT_NAME_TRANSCRIPT_REQUEST_LEGAL_TERMS = 'End User Legal Terms - TranscriptRequest';
  @AuraEnabled
  public final String LWC_PRODUCT_NAME_SCORE_RECHECK_LEGAL_TERMS = 'End User Legal Terms - ScoreRecheck';
  @AuraEnabled
  public final String LWC_PRODUCT_NAME_EPIC_LEGAL_TERMS = 'End User Legal Terms - EPIC';
  @AuraEnabled
  public final String LWC_PRODUCT_NAME_CRED_INTAKE_LEGAL_TERMS = 'End User Legal Terms - CredentialIntake';
  //Terms and Conditions Status
  public static final String TERMS_AND_COND_STATUS_ACTIVE = 'Active';
  //Terms and Conditions Agreement Status
  public static final String TERMS_AND_COND_AGR_STATUS_ACTIVE = 'Active';
  public static final String TERMS_AND_COND_AGR_STATUS_INACTIVE = 'Inactive';
  //Affirmation Record Types
  public static final String AFFIRMATION_RECORD_TYPE_TCT = 'Transfer_Credit_Transcript';
  public static final String AFFIRMATION_RECORD_TYPE_TCT_NAME = 'Transfer_Credit_Transcript_Name';
  public static final String AFFIRMATION_RECORD_TYPE_TCT_TRANSLATION = 'Transfer_Credit_Transcript_Translation';
  public static final String AFFIRMATION_RECORD_TYPE_PRE_MED_LETTER = 'Pre_Med_Letter';
  public static final String AFFIRMATION_RECORD_TYPE_CREDENTIAL_VERIFICATION = 'Credential_Verification';
  public static final String AFFIRMATION_RECORD_TYPE_DEGREE_SCHOOL = 'Degree_School';
  public static final String AFFIRMATION_RECORD_TYPE_NOT_VERIFIED = 'Not_Verified';
  public static final String AFFIRMATION_RECORD_TYPE_VERIFICATION_REVIEW = 'Verification_Review';
  public static final String AFFIRMATION_RECORD_TYPE_MED_EDU_FORM = 'Medical_Education_Form';
  public static final String AFFIRMATION_RECORD_TYPE_ATTESTATION = 'Attestation';
  //Affirmation Status
  public static final String AFFIRMATION_STATUS_REJECTED = 'Rejected';
  public static final String AFFIRMATION_CRED_EVAL_STATUS_INCOMPLETE = 'Incomplete';
  public static final String AFFIRMATION_TRANSL_EVAL_STATUS_INCOMPLETE = 'Incomplete';
  public static final String AFFIRMATION_CRED_EVAL_STATUS_ACCEPTED = 'Accepted';
  public static final String AFFIRMATION_TRANSL_EVAL_STATUS_ACCEPTED = 'Accepted';
  public static final String AFFIRMATION_DOC_ACTION_REQ_NEW = 'Request a New Document from Applicant';
  public static final String AFFIRMATION_DOC_ACTION_DOC_CHG = 'Document cannot be verified by ECFMG';
  public static final String AFFIRMATION_NOT_AUTHENTIC = 'Not Authentic';
  //Affirmation Asset Types
  public static final String AFFIRMATION_ASSET_TYPE_FINAL_DIPLOMA = 'Final Diploma';
  public static final String AFFIRMATION_ASSET_TYPE_FINAL_TRANSCRIPT = 'Final Transcript';
  public static final String AFFIRMATION_ASSET_TYPE_TCT = 'TCT';

  //Affirmation picklist values
  public static final String AFFIRMATION_INCOMPLETE = 'Incomplete';
  public static final String AFFIRMATION_PICKLIST_VALUE_NO = 'No';
  public static final String AFFIRMATION_PICKLIST_VALUE_YES = 'Yes';
  public static final String AFFIRMATION_TRANSLATION_REQUIRED_NOT_PROVIDED = 'Translation required, not provided';
  public static final String AFFIRMATION_TCT_REQUIRED_NOT_PROVIDED = 'TCT required, not provided';
  public static final String AFFIRMATION_NAME_DOC_REQUIRES_REVIEW = 'Name on document is not a match; name documentation requires review';
  public static final String AFFIRMATION_NAME_DOC_NOT_RECEIVED = 'Name on document is not a match; name documentation not received';
  public static final String AFFIRMATION_DOB_PRESENT_NOT_MATCH_NO_DOC = 'Date of Birth present on credential; not a match, and no documentation on file';
  //Queue Names
  public static final String QUEUE_APP_FOR_CERT = 'Application_for_Certification';
  public static final String QUEUE_EXAM_REG = 'Exam_Registration';
  public static final String QUEUE_USMLE_TRANSCRIPTS = 'Exam_Transcripts';
  public static final String QUEUE_EXAM_USMLE_TRANSCRIPT = 'USMLE_Transcripts';
  public static final String QUEUE_EPIC_EXTRACTIONS = 'EPIC_Extractions';
  public static final String QUEUE_PRINT_QUEUE = 'Print_Queue';
  //Task Queue
  public static final String QUEUE_ERAS_TRANSCRIPT_REQ_TASK_QUEUE = 'ERAS_Transcript_Request';
  // Constants using in LWC component
  @AuraEnabled
  public final String LWC_CASE_STATUS_ACCEPTED = 'Accepted';

  //Community Name
  public static final String COMMUNITY_NAME = 'Applicant 360';

  //Email Template Name
  public static final String CASE_EMAIL_TEMPLATE_NAME = 'Case_Status_update_Template';
  public static final String SCORE_WITHHELD_EMAIL_TEMPLATE_NAME = 'Score_Withheld_Notification';
  public static final String EV_NOT_REVIEWED_DAILY_TEMPLATE = 'Enrollment_Verification_Not_Reviewed_Daily_Template';
  public static final String EV_NOT_REVIEWED_WEEKLY_TEMPLATE = 'Enrollment_Verification_Not_Reviewed_Weekly_Template';
  public static final String CASE_EMAIL_DEFICIENCY_TEMPLATE = 'New_Service_Request_Form_Deficiency_Template';
  public static final String DOCCONFIG_EVCASE_TEMPLATE_NAME = 'EnrollReverification Case Template';
  public static final String EMAIL_TEMPLATE_ECFMG_CERTIFICATE = 'ECFMG_Certificate_Template';
  public static final String EMAIL_TEMPLATE_ECFMG_DUP_CERTIFICATE = 'Duplicate_ECFMG_Certificate_Template';
  public static final String EMAIL_TEMPLATE_VP_SPEC_INSTR = 'VP_Special_Instructions_Template';
  public static final String EMAIL_TEMPLATE_CASE_STATUS_UPDATE_CV = 'Case_status_update_CV_template';
  public static final String EMAIL_TEMPLATE_VP_CASE_UPDATE = 'VP_Case_Update_Template';
  public static final String EMAIL_CASE_STATUS_UPDATE_ON_CV_ACCEPTED = 'Case_Status_Update_to_CV_Accepted';
  public static final String EMAIL_SENDER_DISPLAY_NAME = 'ECFMG Portal';
  public static final String EMAIL_TEMPLATE_ATTEST_CASE_STATUS_UPDATE = 'Attestation_Case_Status_Update';
  public static final String EMAIL_TEMPLATE_ONE_TIME_EPIC_VR = 'One_time_EPIC_Verification_Report';
  // PDF Butler Doc Config
  public static final String DOCCONFIG_CUSTOMERDOCCONFIG_ID = '46b34380-9e1a-4401-a102-07ec5d4d66ad';
  public static final String DOCCONFIG_APD_FAIMERREPORT_5_YEARS = '64fb9be7-7509-47b2-91d4-fa9021d9c8c9';
  public static final String DOCCONFIG_APD_FAIMERREPORT_3_YEARS = 'adbc25e7-d8a6-4cd9-99fd-ff366d85a454';
  public static final String DOCCONFIGID_PIATEMPLATE = '4d1e7dfe-68c0-4b85-83eb-43ca6f7de7a0';
  public static final String DOCCONFIGID_NEWSERVICETEMPLATE1 = '6e0e2af4-965e-4718-839f-25aa3f3247ef';
  public static final String DOCCONFIGID_NEWSERVICETEMPLATE2 = '5301b42e-446b-4b25-9b77-6b32901bbcfc';
  public static final String UPDATE_APPLICANT_ON_DEBIT = 'Update_User_On_Debit';
  public static final String UPDATE_MAILING_ADDRESS_TEMPLATE = 'Update_Mailing_Address_Template';
  public static final String DOCCONFIG_ECFMGDUPLICATECERT_ID = '494e2954-f537-433d-849a-4cf222d62977';
  public static final String DOCCONFIG_ECFMGREPRINTEDCERT_ID = '559b7bf0-1329-41b4-8ae9-e54bd044f2c4';
  public static final String DOCCONFIG_CREDVERFORM_ID = '89259d89-2306-44a9-abf2-f550f1cf7ceb';
  public static final String DOCCONFIG_EPIC_EXTRACTION_VERIFICATION_FORM = 'a2bf5399-97e2-4db7-9533-165c2f127e4e';
  public static final String DOCCONFIG_USMLE_TRANSCRIPT = '8c4fc17b-52b1-4ede-84d6-467a21473311';
  public static final String DOCCONFIG_NON_USMLE_TRANSCRIPT = '5288cdac-883d-4a8f-aab7-edccbcef915a';
  public static final String DOCCONFIG_EV_FORM = '451ce5c1-31da-4d30-a6a8-62623c7194e4';
  public static final String DOCCONFIG_ID_FORM_TEMPLATE = 'ac1dd94a-5db1-4d8e-8598-3a9056cfe2d8';
  public static final String DOCCONFIG_DEF_COV_LETTER = '6aea4ece-45c7-4b74-a5d5-b0c30805b212';
  public static final String DOCCONFIG_SCORE_RECHECK = 'f96413e7-4420-45f0-8c52-4279747dc31e';
  public static final String DOCCONFIG_ECFMG_CERT = 'ed2d41ca-9439-4b43-bb58-31e9c496bef7';
  public static final String MEDEDUFORM_CL_ENTITYADDR_IDENTIFIER = '00D17000000Y47m_a2Q17000001hMRQ';
  public static final String MEDEDUFORM_FORM_ENTITYADDR_IDENTIFIER = '00D17000000Y47m_a2Q17000001hMRV';
  public static final String EPIC_REPORT_DATASOURCE_IDENTIFIER = '00D54000000OdEA_a2Q54000000vAGY';
  public static final String DOCCONFIG_ACCOUNT_ESTABLISHMENT_SUMMARY = 'b5f3addf-4db9-4c18-857f-e14d7ae15099';
  public static final String DOCCONFIG_ASL_TEMPLATE ='95ed2db3-1066-48a6-9257-101c057a81cb';

  public static final String DOCCONFIG_ATTESTATION_FORM = '0cf224e5-9b65-473e-bc89-0919977ba7cd';
  public static final String DOCCONFIG_ATTESTATION_COVER_LETTER = 'a271453f-74c2-4074-adae-2c8bebcdd9ea';
  public static final String DOCCONFIG_EPIC_VERIFICATION_REPORT = '9e980695-c09e-4d5b-a6ec-6b1757208b45';
  public static final String EPICREPORT_DATASOURCE_IDENTIFIER = '00D54000000OdEA_a2Q54000000vAGY';
  public static final String NAME_ON_DOCUMENT_DATASOURCE_IDENTIFIER = '00D2i0000008hQk_a2Q2i000000P7Gm';

  // App For Cert - test class variables
  public static final String APPFORCERT_TESTCLS_RECORDIDVAL = 'recordIdVal';
  public static final String ENTITYCREDVERCTRL_TESTCLS_RETURNED = 'Returned ';

  // CaseTriggerHelper - test class variables
  public static final String TEST_EMAIL_ID = 'testuser@xyz.com';

  //File Download URL
  public static final String FILE_DOWNLOAD_URL = '/sfc/servlet.shepherd/document/download/';
  public static final String FILE_VERSION_DOWNLOAD_URL = '/sfc/servlet.shepherd/version/download/';
  public static final String ENTITY_COMMUNITY_URL = '/entity360';

  //Contact Staging RecordType
  public static final String CONTACT_STAGING_RECORDTYPE_EXAMREGISTRATION = 'Exam_Registration';

  //Exam Registration Exam Statuses
  public static final String EXAM_REGISTRATION_EXAM_STATUS_PASSED = 'Pass';
  public static final String EXAM_REGISTRATION_EXAM_STATUS_FAILED = 'Fail';
  public static final String EXAM_REGISTRATION_EXAM_STATUS_WITHHELD = 'Withheld';
  public static final String EXAM_REGISTRATION_EXAM_STATUS_NOSHOW = 'No Show';
  public static final String EXAM_REGISTRATION_EXAM_STATUS_INCOMPLETE = 'Incomplete';
  public static final String EXAM_REGISTRATION_EXAM_STATUS_INDETERMINATE = 'INDETERMINATE';

  //Exam Registration Exam Types
  public static final String EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE = 'USMLE Step 1';
  public static final String EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK = 'USMLE Step 2 CK';
  public static final String EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCS = 'USMLE Step 2 CS';

  //Exam Registration Record Types
  public static final String EXAM_REGISTRATION_RECORD_TYPES_USMLE = 'USMLE';
  public static final String EXAM_REGISTRATION_RECORD_TYPES_NON_USMLE = 'NON_USMLE';
  
  //Exam Registration Object
  public static final String EXAM_REGISTRATION_OBJECT = 'Exam_Registration__c';
  public static final String EXAM_REGISTRATION_FIELD_EXAM_TYPES = 'Exam_Types__c';
  public static final String EXAM_REGISTRATION_FIELD_TESTACCOMMODATIONS = 'Test_Accommodations_needed__c';

  //Exam Registration Exam Types
  @AuraEnabled
  public final String LWC_EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE = 'USMLE Step 1';
  @AuraEnabled
  public final String LWC_EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK = 'USMLE Step 2 CK';
  @AuraEnabled
  public final String LWC_EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCS = 'USMLE Step 2 CS';

  // Constants using in LWC component
  @AuraEnabled
  public final String LWC_METADATA_CONFIRMATIONSCREEN_SECONDLINE = 'You have successfully submitted your application for USMLE.';
  @AuraEnabled
  public final String LWC_METADATA_CONFIRMATIONSCREEN_SECONDLINE_REGION_CHANGE = 'You have successfully completed Region Change.';
  @AuraEnabled
  public final String LWC_METADATA_CONFIRMATIONSCREEN_SECONDLINE_EPEX = 'You have successfully completed Eligibility Period Extension.';
  @AuraEnabled
  public final String LWC_METADATA_CONFIRMATIONSCREEN_SECONDLINE_TRANSCRIPT_REQ = 'You have successfully completed Transcript Request.';
  @AuraEnabled
  public final String LWC_METADATA_CONFIRMATIONSCREEN_SECONDLINE_NON_USMLE_TRANSCRIPT_REQ = 'You have successfully completed Non-USMLE Transcript Request.';
  @AuraEnabled
  public final String LWC_METADATA_CONFIRMATIONSCREEN_SECONDLINE_SCORE_RECHECK = 'You have successfully completed Score Recheck.';
  @AuraEnabled
  public final String LWC_METADATA_CONFIRMATIONSCREEN_SECONDLINE_DUP_CERT = 'You have successfully submitted your request for a duplicate ECFMG Certificate.';
  // Date Format
  public static final String DATE_FORMAT = 'yyyy-MM-dd';
  public static final String LINE_BREAK = '\n';
  //Exam Registration Setting metadata type
  public static final String EXAM_REGISTRATION_SETTING = 'Exam_Registration_Setting';

  // YES / NO
  public static final String STATUS_YES = 'Yes';
  public static final String STATUS_NO = 'No';

  //score withheld reason
  public static final String SCORE_WITHHELD_REASON_ID_VERIFICATION = 'Pending Id Verification';
  public static final String SCORE_WITHHELD_REASON_ENROLLMENT_REVERIFICATION = 'Pending Enrollment Verification';
  public static final String SCORE_WITHHELD_REASON_REQUESTED_BY_NBME = 'WH by NBME';
  public static final String SCORE_WITHHELD_REASON_APPLICANT_RESTRICTED = 'Applicant Restricted';

  public static final String SCORE_WITHHELD_REASON_ID_VERIFICATION_SCORE_RECHECK = 'Your score is available, but we are unable to report it as we are still in the process of verifying your identity.';
  public static final String SCORE_WITHHELD_REASON_ENROLLMENT_REVERIFICATION_SCORE_RECHECK = 'Your score is available, but we are unable to report it as we are in the process of verifying your enrollment at your medical school.';

  //org-wide email address display name
  public static final String ORG_WIDE_ADDRESS = 'Salesforce Admin';

  //Varsha Hariharan - ECFMG Changes
  public static final String GOOGLE_API_ADDRESS_PLACE = 'https://maps.googleapis.com/maps/api/place/details/json?placeid=';
  public static final String GOOGLE_API_ADDRESS_AUTOCOMPLETE = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=';
  //Varsha Hariharan - End of ECFMG changes

  // score report error record queues
  public static final String ERROR_SCORE_REPORTS_QUEUE = 'Score Report Errors';

  // NBME Email goes to Stev Mail
  public static final String ECFMG_EMAIL_NBME = 'bmahn.b2test+777@gmail.com';

  //Metdata details for USMLE Generation
  public static final String USMLE_SEQUENCE_START_VALUE = '1000001';

  //Exception message
  public static final String QUEUE_NOT_FOUND_MSG = 'Could not find case queue named ';

  //Entity Contact Status for LWC
  @AuraEnabled
  public final String LWC_CASE_STATUS_APPROVED = 'Approved';
  @AuraEnabled
  public final String LWC_CASE_STATUS_PENDING_SIGNATURE_UPLOAD = 'Pending Signature Upload';
  @AuraEnabled
  public final String LWC_CASE_STATUS_PENDING_REVIEW = 'Pending Review';
  @AuraEnabled
  public final String LWC_CASE_STATUS_PENDING_USER_ACCESS = 'Pending User Access';
  @AuraEnabled
  public final String LWC_CASE_STATUS_INCOMPLETE = 'Incomplete';

  //Lead RecordTypes
  public static final String LEAD_RECORD_TYPE_IDENTITY = 'Entity_User';

  //Lead Status
  public static final String LEAD_STATUS_NEW = 'New';
  public static final String LEAD_STATUS_CLOSED_NOTCONVERTED = 'Closed - Not Converted';
  public static final String LEAD_STATUS_CLOSED_CONVERTED = 'Closed - Converted';

  //Case Request Types
  public static final String CASE_REQUEST_TYPE_ADD_SERVICE = 'Add Service';
  public static final String CASE_REQUEST_TYPE_ADD_USER = 'Add User';

  //Case Role
  public static final String CASE_ROLE_USER = 'User';

  //Case Source
  public static final String CASE_SOURCE_PORTAL_USER = 'Portal User';
  public static final String CASE_SOURCE_COORDINATOR_OR_DEAN = 'Coordinator/Dean';
  public static final String CASE_SOURCE_COORDINATOR = 'Coordinator';

  //Service Names
  public static final String SERVICE_NAME_ENROLLMENT_VERIFICATION = 'Enrollment Verification';
  public static final String SERVICE_NAME_CREDENTIAL_REVIEW = 'Credential Review';
  public static final String SERVICE_NAME_CREDENTIAL_VERIFICATION = 'Credential Verification';
  public static final String SERVICE_NAME_PERFORMANCE_DATA = 'Performance Data';
  public static final String SERVICE_NAME_MEDICAL_EDU_FORM = 'Medical Education Form';

  //Date Format
  public static final String Eligibility_Date_Format = 'MMMM d,  yyyy';

  //Minimum curriculum years value for graduate
  public static final Decimal CURRICULUM_YEARS_GRADUATE = 3.5;

  // Object2Degree record types
  public static final String OBJECT2DEGREE_RECORD_TYPE_SCHOOL = 'School';

  //Terms and Conditions Names
  @AuraEnabled
  public final String TERMS_AND_COND_NAME_ONLINE_NOTARY_CONFIRMATION = 'Online Notary Confirmation';
  // Manual Review Reasons
  public static final String REVIEWREASON_TOTALYEARSATTEND = 'The Applicant has less than 18 months of medical school attendance.';
  public static final String REVIEWREASON_USMEDICALLICENSE = 'The Applicant indicated they have a US Medical License.';
  public static final String REVIEWREASON_PREVIOUSPASSED = 'The Applicant has requested a previous pass exception.';
  public static final String REVIEWREASON_OFACWARNING = 'The Applicant resides in a potential OFAC region.';

  // Aggregate Performance Data Record Types
  public static final String APD_RECORD_TYPE_SPECIALREPORTPD = 'Special_Report_PD';
  public static final String APD_RECORD_TYPE_AGGREGAETPD_COUNTRY = 'Aggregate_PD_Country';
  public static final String APD_RECORD_TYPE_AGGREGAETPD_ALL = 'Aggregate_PD_All';
  public static final String APD_RECORD_TYPE_AGGREGAETPD_SCHOOL = 'Aggregate_PD_School';

  //Doc config id values for APD reports
  public static final String DOCCONFIG_APD_SCHOOL_STEP1_1_YEAR = 'a0502108-af75-4fcb-91f6-5137a3cd80d4';
  public static final String DOCCONFIG_APD_SCHOOL_STEP1_5_YEAR = '04f37364-8ad8-4eb7-82dd-62ce767d325b';
  public static final String DOCCONFIG_APD_COUNTRY_STEP1_1_YEAR = '0cf44ad9-cb48-486f-9936-d74dfaa2bc42';
  public static final String DOCCONFIG_APD_COUNTRY_STEP1_5_YEAR = '829116e3-9d35-471a-aedb-6ecdce88dfb6';
  public static final String DOCCONFIG_APD_SCHOOL_STEP2CK_1_YEAR = '63adeb00-7894-4099-89c7-ee61f9c895f4';
  public static final String DOCCONFIG_APD_SCHOOL_STEP2CK_5_YEAR = '7dda7cb9-d20c-431a-a79e-1b5aa69f8390';
  public static final String DOCCONFIG_APD_COUNTRY_STEP2CK_1_YEAR = '2df5a7c6-91b5-4ab7-8bd7-a6b5d0678f73';
  public static final String DOCCONFIG_APD_COUNTRY_STEP2CK_5_YEAR = 'ebbe6df4-b1bc-42f5-9fbe-88e166c9e04c';
  public static final String DOCCONFIG_APD_SCHOOL_STEP2CS_1_YEAR = '06072335-a734-4243-bed1-8fceb8314ef6';
  public static final String DOCCONFIG_APD_SCHOOL_STEP2CS_5_YEAR = '5029de9a-bc94-4611-85f1-7eccab5412fb';
  public static final String DOCCONFIG_APD_COUNTRY_STEP2CS_1_YEAR = 'f19c1238-c0ca-4324-a4f6-41811e00f918';
  public static final String DOCCONFIG_APD_COUNTRY_STEP2CS_5_YEAR = '82b83a49-7016-4386-bf43-0731833a7634';
  public static final String DOCCONFIG_APD_COVER_LETTER = 'a57be0aa-2c72-4f21-a4f5-3f95f883c747';
  public static final String DOCCONFIG_CERTIFIED_ECFMG_VERFORM = '485a84ac-86db-4513-96e4-104fc2c53dae';
  public static final String DOCCONFIG_NONCERT_ECFMG_VERFORM = '33a2347a-578d-4196-9e40-be256113118a';
  public static final String DOCCONFIG_NO_CREDENTIAL_VERFORM = '3afac6b3-13c8-46ad-a43f-70901f83050c';
  public static final String DOCCONFIG_MED_EDU_FORM = '2cb1eedf-7a80-464d-af28-a15fa22656b0';
  //Faimer Report types values
  public static final String APD_FAIMERREPORT_AGGREGATE = 'Aggregate Report';
  public static final String APD_FAIMERREPORT_SPECIAL = 'Special Report';

  //Current date manipulation for testing
  public static final Date TODAY_DATE = System.today();
  //use the value Date.newInstance(2020, 8, 27); format for testing other dates or System.today(); for current date

  //Values for Remarks field in entity portal
  public static final String REMARKS_TA = 'Test Accommodations';
  public static final String REMARKS_IB = 'Irregular Behavior';
  public static final String REMARKS_IN = 'Indeterminate';
  public static final String REMARKS_WH = 'Withheld at Request of Examinee';

  //Value in Type OFAC
  public static final String RESTRICTED_BY_ECFMG = 'Restricted_by_ECFMG';

  //Notary Transaction Update Event
  public static final String NOTARY_TRANSACTION_UPDATE_CREATED_STARTED = 'Transaction Created';
  public static final String NOTARY_TRANSACTION_UPDATE_EVENT_COMPLETE_SUCCESS = 'Complete - Success';

  // Affirmation
  public static final String AFFIRMATION_STATUS_IN_PROGRESS = IN_PROGRESS;
  public static final String AFFIRMATION_RECORD_TYPE_ID_VERIFICATION = 'ID_Verification';

  //Document Content Types
  public static final String PDF_CONTENT_TYPE = 'application/pdf';
  public static final String ZPL_CONTENT_TYPE = 'x-application/zpl';

  //API Parameter Types
  public static final String PARAMETER_TYPE_EPERMIT = 'E-Permit';
  public static final String PARAMETER_TYPE_SCORE_REPORTING = 'Score Reporting';

  //Billing/lines Status
  public static final String BILL_STATUS_NEW = 'New';
  public static final String BILL_STATUS_OPEN = 'Open';
  public static final String BILL_STATUS_IN_PROCESS = 'In Process';
  public static final String BILL_STATUS_FULFILLED = 'Fulfilled';
  public static final String BILL_STATUS_PARTIALLY_REFUNDED = 'Partially Refunded';
  public static final String BILL_STATUS_REFUNDED = 'Refunded';
  public static final String BILL_STATUS_CANCELLED = 'Cancelled';
  public static final String EPIC_SERVICENAME = 'Volume Report Recipients';
  public static final String CREDENTIAL_VERF_EXIST_ERROR = 'Credential Type already exists for the Account Service.';
  //Document Type Field Mapping Field API Name
  public static final String DOCTYPFIELDMAP_DEGREE_ISSUE_DATE = 'Degree_Issue_Date__c';
  public static final String DOCTYPFIELDMAP_ISSUE_DATE = 'Issue_Date__c';
  public static final String DOCTYPFIELDMAP_DEGREE_TITLE = 'Degree_Title__c';
  public static final String DOCTYPFIELDMAP_TITLE = 'Title__c';
  public static final String DOCTYPFIELDMAP_DEG_EXP_YEAR = 'Degree_expected_to_be_issued_Year__c';
  public static final String DOCTYPFIELDMAP_GRADUATION_YEAR = 'Graduation_Year__c';
  public static final String DOCTYPFIELDMAP_EXPIRATION_DATE = 'Expiration_Date__c';
  public static final String DOCTYPFIELDMAP_ATTENDANCE_START_DATE = 'Attendance_Start_Date__c';
  public static final String DOCTYPFIELDMAP_ATTENDANCE_END_DATE = 'Attendance_End_Date__c';
  public static final String DOCTYPFIELDMAP_PROGRAM_START_DATE = 'Program_Start_Date__c';
  public static final String DOCTYPFIELDMAP_PROGRAM_END_DATE = 'Program_End_Date__c';
  //Document Type Field Mapping Field Error Messages
  public static final String EPIC_ATT_ST_END_DATE = 'Attendance End Date cannot be before the Attendance Start Date';
  public static final String EPIC_ATT_ST_DEG_ISS_DATE = 'Degree Issue Date cannot be before Attendance Start Date';
  public static final String EPIC_ATT_END_DEG_ISS_DATE = 'Degree Issue Date cannot be before Attendance End Date';
  public static final String EPIC_PRG_ST_END_DATE = 'Program End Date Cannot be before Program Start Date';
  public static final String EPIC_PRG_ST_ISS_DATE = 'Issue Date cannot be before Program Start Date';
  public static final String EPIC_PRG_END_ISS_DATE = 'Issue Date cannot be before Program End Date';
  public static final String EPIC_EXP_ISS_DATE = 'Expiration Date cannot be before Issue Date';
  public static final String EPIC_EXP_DEG_GRD_DATE = 'Expected degree date cannot be before January 1 of the Graduation Year';
  public static final String EPIC_GRD_ATT_ST_DATE = 'Graduation Year cannot be less than Attendance Start date';
  public static final String EPIC_GRD_ATT_END_DATE = 'Graduation Year cannot be less than Attendance End date';
  public static final String EPIC_GRD_FRMT = 'Please enter valid year as YYYY';
  public static final String EPIC_ISS_DATE_FUT_DATE = 'Issue Date cannot be a future date';
  public static final String EPIC_ATT_ST_DATE_FUT_DATE = 'Attendance Start Date cannot be a future date';
  //Asset2Verification Object
  public static final String ASSET2VER_DOCTYPE_SOURCE = 'Source';
  public static final String ASSET2VER_DOCTYPE_ACC_VER_FORM = 'Accepted Verification Form';
  public static final String ASSET2VER_DOCTYPE_COVER_LETTER = 'Cover Letter';
  public static final String ASSET2VER_DOCTYPE_SUPPORTING_DOCUMENT = 'Supporting document';
  public static final String ASSET2VER_DOCTYPE_RETURNED_VER_FORM = 'Returned Verification form';
  public static final String ASSET2VER_DOCTYPE_VERIFIED = 'Verified';
  public static final String ASSET2VER_DOCTYPE_NEW_VER_FORM = 'New Verification form';
  //Task Status
  public static final String TASK_STATUS_COMPLETED = 'Completed';
  //WDOMS Object Type
  public static final String WDOMS_OBJ_SCHOOL = 'School';
  public static final String WDOMS_OBJ_SCHOOL_LANGUAGE = 'schoolLanguage';
  public static final String WDOMS_OBJ_SCHOOL_CONT_CONT_INFO = 'schoolContactContactInfo';
  public static final String WDOMS_OBJ_SCHOOL_CONTACT_INFO = 'schoolContactInfo';
  public static final String WDOMS_OBJ_SCHOOL_AFFILIATION = 'schoolAffiliation';
  public static final String WDOMS_OBJ_SCHOOL_PROGRAM = 'schoolprogram';
  public static final String WDOMS_OBJ_SCHOOL_AKA = 'schoolAka';
  public static final String WDOMS_OBJ_SCHOOL_URL = 'schoolURL';
  public static final String WDOMS_OBJ_MDT_PROGRAM = 'MDTProgram';
  public static final String WDOMS_OBJ_MDT_PROGRAM_LANGUAGE = 'MDTProgramLanguage';
  public static final String WDOMS_OBJ_MDT_PROGRAM_DEGREE_TYPE = 'MDTProgramDegreeType';
  public static final String WDOMS_OBJ_MDT_PROGRAM_DEGREE = 'MDTProgramDegree';
  public static final String WDOMS_OBJ_MDT_GRAD_YEAR = 'MDTGradYear';
  public static final String WDOMS_COMMENT_TYPE_IMED = 'IMED';
  public static final String WDOMS_COMMENT_TYPE_CURRICULUM = 'Curriculum';
  public static final String WDOMS_COMMENT_TYPE_INTERNAL = 'Internal';
  public static final String WDOMS_PLATFORM_OPERATION_POST = 'POST';
  public static final String WDOMS_PLATFORM_OPERATION_PATCH = 'PATCH';

  //WDOMS Related Constants
  public static final String TASK_RECORD_TYPE_COMMENTS = 'Comments';
  public static final String SOBJECT_TYPE_ACCOUNT = 'Account';
  public static final String SOBJECT_TYPE_PROGRAM = 'Program__c';
  public static final Integer WDOMS_SEQUENCE_INCREMENT_VALUE = 1;

  //Record type
  public static final String ACCOUNT_AFFILIATION_TYPE_EDUCATIONAL_PROGRAM = 'Educational Program';
  public static final String ACCOUNT_AFFILIATION_TYPE_ACADEMIC_AFFILIATION = 'Academic Affiliation';
  public static final String ADDITIONAL_INFO_TYPE_URL = 'URL';
  public static final String PROGRAM_TYPE_EDUCATIONAL_PROGRAM = 'Educational Program';

  public static final string CERTIFIED_VERIFICATION_ENTITY = 'I Certify This Document';
  public static final string NON_CERTIFIED_VERIFICATION_ENTITY = 'I Cannot Certify This Document';
  public static final string CANNOT_CERTIFY_ENTITY = 'Cannot certify';
  public static final string NO_CREDENTIAL = 'No Credential';
  public static final string CERTIFY_ENTITY = 'Certify';

  // Case Send Method validation flag
  public static Boolean isnotUpdatedbySendMethodFlow = true;
  // Update updated by not verified Entity flag
  public static Boolean isupdatedbyNotVerifiedEntity = true;
  //API status
  public static final string API_TRANSACTION_STATUS_SUCCESS = 'Success';
  public static final string API_TRANSACTION_STATUS_FAILURE = 'Failure';
  public static final string API_TRANSACTION_STATUS_PARTIAL_SUCCESS = 'Partial Success';
  // Credential Type
  public static final String CREDENTIAL_TYPE_CGS = 'Certificate of Good Standing';
  //Azure Cloud Document
  public static final Integer AZURE_FILE_DELETE_NO_OF_DAYS_OUT = 60;
  public static final string AZURE_STORAGE_CONTAINER = 'ecfmglocal001';
  public static final Id SCORERECHECKRDTYPEID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_SCORE_RECHECK).getRecordTypeId();
  public static final Id USMLETRANSCRIPTCASERECORDTYPEID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_USMLE_TRANSCRIPT).getRecordTypeId();
  public static final Id NONUSMLETRANSCCASERDTYPEID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_NON_USMLE_TRANSCRIPT).getRecordTypeId();
  public static final Id APPFORCERTRECORDTYPEID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
  public static final Id EXAMREGRTID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
  public static final Id EVCASERECORDTYPEID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION).getRecordTypeId();
  public static final Id CVRECORDTYPEID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
  public static final Id DUPCERTRTID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_DUPLICATE_CERTIFICATE).getRecordTypeId();
  public static final Id EPEXRTID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD).getRecordTypeId();
  public static final Id ENUSRREQRECORDTYPEID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENTITY_USER_REQUEST).getRecordTypeId();
  public static final Id REGIONCHANGERDTYPEID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_REGION_CHANGE).getRecordTypeId();
  public static final Id ENTITY_CON_DETAILS_UPDATE_RDTYPEID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENTITY_CON_DETAILS_UPDATE).getRecordTypeId();
  public static final Id ID_VER_RDTYPEID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_IDENTITY_VERIFICATION).getRecordTypeId();
  public static final Id ENTITY_SERVICE_REQUEST_RDTYPEID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_DEV_ENTITY_SERVICE_REQUEST).getRecordTypeId();
  public static final Id J1_INVITATION_RDTYPEID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_J1_INVITATION).getRecordTypeId();
  public static final Id EPIC_EXTRACTION_RDTYPEID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_EXTRACTION).getRecordTypeId();
  public static final Id DUP_CERTIFICATE_RDTYPEID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_DUPLICATE_CERTIFICATE).getRecordTypeId();
  public static final Id NEW_ENTITY_REQUEST_RDTYPEID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_DEV_NEW_ENTITY_REQUEST).getRecordTypeId();
  public static final Id ECFMG_CERTIFICATE_RDTYPEID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ECFMG_CERTIFICATION).getRecordTypeId();
  public static final Id NOTIFICATION_RDTYPEID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_NOTIFICATION).getRecordTypeId();
  public static final Id APP_BIO_CHANGE_RDTYPEID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_BIO_CHANGE).getRecordTypeId();
  public static final Id ERVCASERECORDTYPEID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_REVERIFICATION).getRecordTypeId();
  public static final Id PAPERFILEREQRTID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_PAPER_FILE_REQ).getRecordTypeId();
  public static final Id AUTHSIGNLISTRTID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_AUTH_SIGN_LIST).getRecordTypeId();
  public static final Id MEDEDURESRTID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_MED_EDU_RES).getRecordTypeId();
  public static final Id MEDEDUFORMID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_MED_EDU_FORM).getRecordTypeId();
  public static final Id ATTESTRECORDTYPEID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ATTESTATION).getRecordTypeId();
  public static final Id PETITIONFORRECONSRDTYPEID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_PETITION_FOR_RECONSN).getRecordTypeId();
  public static final Id EPICVERREPORTREQRTID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_VER_REPORT_REQUEST).getRecordTypeId();
  public static final Id INVESTIGATIONRTID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_INVESTIGATION).getRecordTypeId();
  public static final Group APPFORCERTQUEUE = CaseTriggerUtility.groupMap.get(Constants.CASE_QUEUE_APP_FOR_CERT);
  public static final Group EXAMREGQUEUE = CaseTriggerUtility.groupMap.get(Constants.CASE_QUEUE_EXAM_REG);
  public static final Group EVQUEUE = CaseTriggerUtility.groupMap.get(Constants.CASE_QUEUE_ENROLLMENT_VERIFICATION);
  public static final Group USMLTRANSCRIPTQUEUE = CaseTriggerUtility.groupMap.get(Constants.CASE_QUEUE_USMLE_TRANSCRIPTS);
  public static final Group MEDEDUFORMQUEUE = CaseTriggerUtility.groupMap.get(Constants.CASE_QUEUE_MED_EDU_FORM);

  //
  public static final Id MEDEDUFORMRTID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_MED_EDU_FORM).getRecordTypeId();

  public static final string SCH_JOB_AZURE_FILE_DELETE = 'Azure file Delete';

  public static final String VERIFICATION_REQUEST_CLIENT_PCRC = 'PCRC';
  public static final String VERIFICATION_REQUEST_CLIENT_FSMB = 'FSMB';
  public static final String VERIFICATION_REQUEST_CLIENT_MCC = 'MCC'; //alternate name of PCRC

  /*Cibis Constants*/
  public static final String CIBIS_EXAM_REG_HISTORY_USMLE = 'USMLE';
  public static final String CIBIS_EXAM_REG_HISTORY_NON_USMLE = 'NON_USMLE';
  public static final String CASE_QUEUE_ID_Review_Queue = 'ID_Review_Queue';
  public static final String CASE_QUEUE_ID_Verification_Queue = 'ID_Verification_Queue';
    //Cibis interaction Request Types  & Fields
  public static final String CIBIS_CANDIDATE_TYPE = 'candidate';
  public static final String CIBIS_EXAM_TYPE = 'registrations';
  public static final String CIBIS_REG_CHANGE_TYPE = 'exams';
  public static final String CIBIS_EPEX_TYPE = 'eligibility';
  public static final String CIBIS_NBME_POST_CHECK = 'NBME_Post_Check';
  public static final String CIBIS_NBME_PRE_CHECK = 'NBME_Pre_Check';
  public static final String CIBIS_STEP3_PRE_CHECK = 'STEP3_Pre_Check';
  public static final String CIBIS_STEP3_POST_CHECK = 'STEP3_Post_Check';
  public static final String CIBIS_NBME_TRANSCRIPT_NOTES_FIELD = 'NBMEInfo';
  public static final String CIBIS_FSMB_TRANSCRIPT_NOTES_FIELD = 'FSMBInfo';
  public static final String CIBIS_ECFMG_TRANSCRIPT_NOTES_FIELD = 'ECFMGInfo';
  public static final String CIBIS_USMLE_TRANSCRIPT_NOTES_FIELD = 'USMLEInfo';
  Public static final string CIBIS_IRREGULAR_BEHAVIOR_FIELD = 'irregularBehavior';
  public static final String CIBIS_SECR_DOCURL_FIELD = 'secretariatDocumentInfoWithURL';
  public static final String CIBIS_SECR_DOCINFO_FIELD = 'secretariatDocumentInfo';
  public static final String CIBIS_TRANSCRIPT_TOTAL_STATUS = 'APP IRREGULAR;EXAM IRREGULAR;FSMB;NBME;USMLE;SECR DOC;ECFMG;';
  //Cibis Response Types
  public static final String CIBIS_ELIGIBILITY_EVENT = 'CIBIS_ELIGIBILITY_EVENT';
  public static final String CIBIS_OVER_ALL_MATCH_EVENT = 'CIBIS_OVER_ALL_MATCH_EVENT';
  public static final String CIBIS_CANDIDATE_EVENT = 'CIBIS_CANDIDATE_EVENT';
  public static final String CIBIS_REGISTRATION_EVENT = 'CIBIS_REGISTRATION_EVENT';
  public static final String CIBIS_EXAM_EVENT = 'CIBIS_EXAM_EVENT';
  public static final String CIBIS_ELIGIBILITY_EVALUATION_EVENT = 'CIBIS_ELIGIBILITY_EVALUATION_EVENT';
  public static final String CIBIS_ELIGIBILITY_REVISION_EVENT = 'CIBIS_ELIGIBILITY_REVISION_EVENT';
  public static final String CIBIS_SCHEDULE_LIMIT_EVENT = 'CIBIS_SCHEDULE_LIMIT_EVENT';
  public static final String CIBIS_EXAM_REG_HISTORY_EVENT = 'CIBIS_EXAM_REG_HISTORY_EVENT';
  public static final String CIBIS_SECR_DOCURL_EVENT = 'CIBIS_SECR_DOCURL_EVENT';
  public static final String CIBIS_SECR_DOCINFO_EVENT = 'CIBIS_SECR_DOCINFO_EVENT';
  public static final String CIBIS_SECR_DOCINFO_EVENT_NA = 'CIBIS_SECR_DOCINFO_EVENT_NA';
  Public static final String CIBIS_EXAM_IRREGULAR_BEHAVIOR_EVENT = 'CIBISEXAMIRREGULARBEHAVIOREVENT123';
  public static final String CIBIS_USMLE_TRANSCRIPT_EXAM_HISTORY_CHECK_EVENT = 'CIBISUSMLETRANSCRIPTEXAMHISTORYCHECKEVENT1';
  public static final String CIBIS_NBME_TRANSCRIPT_NOTES_EVENT = 'CIBIS_NBME_TRANSCRIPT_NOTES_EVENT';
  public static final String CIBIS_FSMB_TRANSCRIPT_NOTES_EVENT = 'CIBIS_FSMB_TRANSCRIPT_NOTES_EVENT';
  public static final String CIBIS_ECFMG_TRANSCRIPT_NOTES_EVENT = 'CIBIS_ECFMG_TRANSCRIPT_NOTES_EVENT';
  public static final String CIBIS_USMLE_TRANSCRIPT_NOTES_EVENT = 'CIBIS_USMLE_TRANSCRIPT_NOTES_EVENT';
  public static final String CIBIS_SCORE_REPORT_EVENT = 'CIBIS_SCORE_EVENT';
  Public static final String CIBIS_APPLICANT_IRREGULAR_BEHAVIOR_EVENT = 'CIBIS_APPLICANT_IRREGULAR_BEHAVIOR_EVENT';
  Public static final String CIBIS_EXAM_HISTORY_IRREGULAR_BEHAVIOR_EVENT = 'CIBIS_EXAM_HISTORY_IRREGULAR_BEHAVIOR_EVENT';
  public static final String CIBIS_USMLE_TRANSCRIPT_REQUEST_PRE_CHECK_EVENT = 'CIBIS_USMLE_TRANSCRIPT_REQUEST_PRE_CHECK_EVENT';
  public static final String CIBIS_USMLE_TRANSCRIPT_REQUEST_POST_CHECK_EVENT = 'CIBIS_USMLE_TRANSCRIPT_REQUEST_POST_CHECK_EVENT';
  public static final String CIBIS_NOTES_REQUEST_EVENT = 'CIBIS_NOTES_REQUEST_EVENT';
  public static final String CANCELATION_REASON='Cancelled due to region change';
  public static final String TRANSCRIPT_EVALUATION_INFO = 'TranscriptEvaluationInfo';

  //Transcript Status values
  public static final String TRANSCRIPT_STATUS_STANDARD = 'Standard';
  public static final String TRANSCRIPT_STATUS_STANDARDPROACTIVE = 'Standard Proactive';
  public static final String TRANSCRIPT_STATUS_SPECIALIZED = 'Specialized';

  public static final String TRANSCRIPT_REQUEST_CHECK = 'TranscriptRequestCheck';
  public static final String EXAM_IRREGULAR = 'EXAM IRREGULAR';
  public static final String CAND_IRREGULAR = 'CAND IRREGULAR';
  public static final String APP_IRREGULAR = 'APP IRREGULAR';
  public static final String EXAM_HISTORY_IRREGULAR = 'USMLE';
  public static final String EXAM_HISTORY = 'NBME';
  public static final String TRANSCRIPT_LINK_SOURCE = 'Transcript Request';
  // CIBIS Metadata retrieval string
  public static final String Exam_IRREGULAR_Notes = 'Irregular Behavior - Administrative, Pro';
  // CIBIS Static Messages
  public static final String CIBIS_USMLE_TRANSCRIPT_NOT_ELIGIBLE_MSG = 'You are not eligible for USMLE Exam';
  public static final String CIBIS_USMLE_TRANSCRIPT_ELIGIBLE_CHECK_MSG = 'USMLE Transcript Eligibilty Check Initiated';
  //FieldSet API Name
  public static final String CASE_EXAM_REGISTRATION_FIELD_SET = 'Exam_Registration_Case_Clone_Set';
  public static final String EXAM_REGISTRATION_FIELD_SET = 'Exam_Registration_Clone_Set';
  public static final String ELIGIBILITY_EXTENSION_EVALUATION_INFO = 'eligibilityExtensionEvaluationInfo';

  public static final Id CRED_VER_RDTYPEID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();

  public static final String STATUS_SEPARATOR = '-@-';
  public static final String REQUEST = 'Request';
  public static final String RESPONSE = 'Response';

  public static final Map<Id,Group> QUEUE_MAP = GenericUtilities.getQueueMap();
  public static final Map<String,Id> QUEUE_DEV_ID_MAP = GenericUtilities.getQueueDevNameIdMap();
  // Stores the current Month, year
  public static final Integer CURRENT_MONTH = TODAY_DATE.month();
  public static final Integer CURRENT_YEAR = TODAY_DATE.year();
  public static final Integer NEXT_MONTH = TODAY_DATE.addMonths(1).month();
  public static final Integer NEXT_YEAR = TODAY_DATE.addMonths(1).year();

  // Eligibility Period record Types
  public static final String ELIGIBILITY_PERIOD_RECORD_TYPE_ERAS = 'ERAS';
  public static final String ELIGIBILITY_PERIOD_RECORD_TYPE_EXAM_REG = 'Exam_Registration';
}