/** Test classes to be included for this class
 * AppBioChangeCaseTriggerHandlerTest
 * AppForCertTriggerHandlerTest
 * AttestationTriggerHandlerTest
 * AuthorizedSignListTriggerHandlerTest
 * BiographicReviewCaseTriggerHandlerTest
 * CredentialVerificationTriggerHandlerTest
 * DuplicateCertificateTriggerHandlerTest
 * ECFMGCertificateTriggerHandlerTest
 * EligiblePrdExtnTriggerHandlerTest
 * EnrollmentReVerCaseTriggerHandlerTest
 * EnrollmentVerificationTriggerHandlerTest
 * EntityServiceRequestTriggerHandlerTest
 * EntityUserRequestTriggerHandlerTest
 * EPICExtractionTriggerHandlerTest
 * EpicVerReportReqTriggerHandlerTest
 * ExamRegistrationTriggerHandlerTest
 * IdentityVerificationCaseTriggerTest
 * IFOMRequestTriggerHandlerTest
 * InvestigationCaseTriggerHandlerTest
 * MedEduFormCaseTriggerHandlerTest
 * MedEduResourceCaseTriggerHandlerTest
 * NameReviewCaseTriggerHandlerTest
 * NewEntityRequestTriggerHandlerTest
 * NonUSMLETranscriptTriggerHandlerTest
 * NotificationCaseTriggerHandlerTest
 * PaperFileRequestTriggerHandlerTest
 * PetitionForReconsCaseTriggerHandlerTest
 * RegionChangeCaseTriggerHandlerTest
 * ScoreRecheckTriggerHandlerTest
 * ScoreReportTriggerHandlerTest
 * USMLETranscriptRequestTriggerHandlerTest
 * CaseTriggerUtilityTest
 * ERASTriggerHandlerTest
*/
// This class will be initialized and it computes data for the trigger.new records.
public with sharing class CaseTriggerDataInitialize{
    // Stores Security Enforced text
    static final String WITH_SEC_ENFORCED = ' WITH SECURITY_ENFORCED';
    // Stores the Application for Certification Record Type of Case object
    static final String REC_TYPE_APP_FOR_CERT = Constant_Case__mdt.getInstance('REC_TYPE_DEV_APPFORCERT').Value__c;
    // Stores the Medical Education Form Record Type of Case object
    static final String REC_TYPE_MED_EDU_FORM = Constant_Case__mdt.getInstance('REC_TYPE_MED_EDU_FORM').Value__c;
    // stores the record type developer name
    static final String REC_TYPE_EXAM_REGISTRATION = Constant_Case__mdt.getInstance('REC_TYPE_DEV_EXAM_REGISTRATION').Value__c;
    //Stores the Entity User Request Record Type of Case Object
    static final String REC_TYPE_ENTITY_USER_REQUEST = Constant_Case__mdt.getInstance('REC_TYPE_DEV_ENTITY_USER_REQUEST').Value__c;
    //Stores the Epic Verification Report Request Record Type of Case Object
    static final String REC_TYPE_EPIC_VER_REPORT_REQUEST = Constant_Case__mdt.getInstance('REC_TYPE_EPIC_VER_REPORT_REQUEST').Value__c;
    // Stores the Credential Verification Record Type of Case Object
    static final String REC_TYPE_CRED_VER = Constant_Case__mdt.getInstance('REC_TYPE_CREDENTIAL_VERIFICATION').Value__c;
    // Stores the Attestation Record Type of Case object
    static final String REC_TYPE_ATTESTATION = Constant_Case__mdt.getInstance('REC_TYPE_ATTESTATION').Value__c;
    // Stores the Entity Service Request Record Type of Case object
    static final String REC_TYPE_ENTSERVREQ = Constant_Case__mdt.getInstance('REC_TYPE_ENTSERVREQ').Value__c;
    // Stores the Authorized Signature List Record Type of Case object
    static final String REC_TYPE_AUTHSIGNLIST = Constant_Case__mdt.getInstance('REC_TYPE_DEV_AUTHSIGNLIST').Value__c;
    // Stores the Eligibility Period Extension Record Type of Case object
    static final String REC_TYPE_ELIGIBILITY_PERIOD = Constant_Case__mdt.getInstance('REC_TYPE_ELIGIBILITY_PERIOD').Value__c;
    // Stores the Investigation Case Record Type of Case object
    static final String REC_TYPE_DEV_INVESTIGATION_CASE = Constant_Case__mdt.getInstance('REC_TYPE_DEV_INVESTIGATION_CASE').Value__c;
    // Stores the USMLE Transcript Case Record Type of Case object
    static final String REC_TYPE_USMLE_TRANSCRIPT = Constant_Case__mdt.getInstance('REC_TYPE_USMLE_TRANSCRIPT').Value__c;
    //Stores the Enrollent Verification Record Type of Case Object
    static final String REC_TYPE_ENROLLMENT_VERIFICATION  = Constant_Case__mdt.getInstance('REC_TYPE_DEV_ENROLLMENT_VERIFICATION').Value__c;
    // Stores the ERAS Record Type of Case object
    static final String REC_TYPE_ERAS = Constant_Case__mdt.getInstance('REC_TYPE_ERAS').Value__c;
    // private static variable referencing the class
    private static CaseTriggerDataInitialize instance = null;
    // private static variable referencing the CaseTriggerDataWrapper class
    private static CaseTriggerDataWrapper ctDataWrap = null;
    // This method will be initialized and checks if the object instance is null or the list of cases is not null
    // in order to process the records to compute data.
    public static CaseTriggerDataInitialize getInstance(List<Case> newCases,Boolean isAfter){
        try{
            if(instance == null || (!newCases.isEmpty()) && !isAfter){
                instance = new CaseTriggerDataInitialize();
                ctDataWrap = new CaseTriggerDataWrapper();
                GetCommonQueries.getInstance();
                computeData(newCases);
            }else if(isAfter && !newCases.isEmpty()){
                computeDataAfter(newCases);
            }
            return instance;
        }catch(Exception ex){
            throw ex;
        }
    }
    // returns data stored in the wrapper
    public CaseTriggerDataWrapper fetchData(){
        try{
            return ctDataWrap;
        }catch(Exception ex){
            throw ex;
        }
    }
    // Fetches the required data for after insert/update
    private static void computeDataAfter(List<Case> newCases){
        try{
            // Stores Exam registration record parent verification parent Id.
            Set<Id> enrollmentVerParent = new Set<Id>();
            // collects Exam registration caseId
            Set<Id> examRegCaseId = new Set<Id>();
            //Collect the Entity User Request CaseId
            Set<Id> entityUserReqCaseId = new Set<Id>();
            // Collects the parentIds
            Set<Id> parentIds = new Set<Id>();
            // Collects the Secondary parentIds
            Set<Id> secParentIds = new Set<Id>();
            // Collects case ids for querying asset
            Set<Id> caseIdsAsset = new Set<Id>();
            // Collects Ids to fetch the Exam Registrtion object records
            Set<String> examRegIds = new Set<String>();
            // Collects the contactIds
            Set<Id> contactIds = new Set<Id>();
            // collects ERAS caseIds
            Set<Id> erasCaseIds = new Set<Id>();
            // Fetches and stores record type Id, and developer name.
            Map<Id,String> mapRecordTypes = GenericUtilities.retriveRecordTypeIdDevNames('Case');
            Set<String> recTypesSet = new Set<String>{REC_TYPE_MED_EDU_FORM,Constant_Case__mdt.getInstance('REC_TYPE_DEV_NAME_REVIEW').Value__c,Constant_Case__mdt.getInstance('REC_TYPE_DEV_BIOGRAPHIC_REVIEW').Value__c,Constant_Case__mdt.getInstance('REC_TYPE_DEV_NEW_ENTITY_REQUEST').Value__c,REC_TYPE_USMLE_TRANSCRIPT,Constant_Case__mdt.getInstance('REC_TYPE_NON_USMLE_TRANSCRIPT').Value__c,REC_TYPE_ELIGIBILITY_PERIOD};
            for(Case newCase : newCases){
                if(String.isNotBlank(newCase.ContactId)){
                    contactIds.add(newCase.ContactId);
                }
                String rtDevName = mapRecordTypes.get(newCase.recordTypeId);
                if(rtDevName == REC_TYPE_APP_FOR_CERT){
                    caseIdsAsset.add(newCase.Id);
                }
                if(rtDevName == REC_TYPE_EXAM_REGISTRATION){
                    caseIdsAsset.add(newCase.Id);
                    parentIds.add(newCase.Id);
                    examRegCaseId.add(newCase.Id);
                    if(newCase.Enrollment_Verification_Parent__c != null){
                        enrollmentVerParent.add(newCase.Enrollment_Verification_Parent__c);
                    }
                }
                if(rtDevName == REC_TYPE_ENTITY_USER_REQUEST){
                    entityUserReqCaseId.add(newCase.Id);
                }
                if(rtDevName == REC_TYPE_EPIC_VER_REPORT_REQUEST && String.isNotBlank(newCase.Secondary_Parent_Case__c)){
                    secParentIds.add(newCase.Secondary_Parent_Case__c);
                }
                if(rtDevName == REC_TYPE_CRED_VER){
                    secParentIds.add(newCase.Id);
                    caseIdsAsset.add(newCase.Id);
                    if(String.isNotBlank(newCase.ParentId)){
                        caseIdsAsset.add(newCase.parentId);
                        parentIds.add(newCase.parentId);
                    }
                }                
                if(recTypesSet.contains(rtDevName) && String.isNotBlank(newCase.ParentId)){
                    parentIds.add(newCase.ParentId);    
                }
                if(rtDevName == REC_TYPE_ELIGIBILITY_PERIOD){
                    examRegIds.add(newCase.ParentId);
                    caseIdsAsset.add(newCase.Id);
                }
                if(rtDevName == REC_TYPE_ENROLLMENT_VERIFICATION){
                    enrollmentVerParent.add(newCase.Id);
                }
                if(rtDevName == REC_TYPE_ERAS){
                    erasCaseIds.add(newCase.Id);
                }
            }
            if(!enrollmentVerParent.isEmpty() || !examRegCaseId.isEmpty()){
                Set<String> exRegIds = examRegistrationCompDataAfter(enrollmentVerParent,examRegCaseId);
                examRegIds.addAll(exRegIds);
                if(!exRegIds.isEmpty()){
                    Set<Id> exRegIdSet = (Set<Id>)JSON.deserialize(JSON.serialize(exRegIds), Set<Id>.class);
                    parentIds.addAll(exRegIdSet);
                }
            }
            if(!entityUserReqCaseId.isEmpty()){
                getCase2ServiceRecords(entityUserReqCaseId);
            }
            if(!parentIds.isEmpty()){
                getChildParent(parentIds);
            }
            if(!secParentIds.isEmpty()){
                getEpicVerRep(secParentIds);
            }
            if(!caseIdsAsset.isEmpty() || (!contactIds.isEmpty() && ctDataWrap.rtCases.containsKey(REC_TYPE_DEV_INVESTIGATION_CASE))){
                getAsset(caseIdsAsset,ctDataWrap.rtCases.containsKey(REC_TYPE_DEV_INVESTIGATION_CASE)?contactIds:new Set<Id>());
            }
            if(!examRegIds.isEmpty()){
                getExamReg(examRegIds);
            }
            if(!erasCaseIds.isEmpty() && !contactIds.isEmpty() && (ctDataWrap.rtCases.containsKey(Constant_Case__mdt.getInstance('REC_TYPE_ERAS').Value__c))){
                getPreviousErasCase(erasCaseIds, contactIds);
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // Fetches the required data
    private static void computeData(List<Case> newCases){
        try{
            // Stores Credential Verification case Ids
            Set<Id> cvCaseIds = new Set<Id>();
            // Fetches and stores record type Id, and developer name.
            Map<Id,String> mapRecordTypes = GenericUtilities.retriveRecordTypeIdDevNames('Case');
            // Stores the case's contact Ids.
            Set<Id> contactIds = new Set<Id>();
            // collects caseId for fetching transcript annotation records
            Set<Id> transAnnotationCaseIds = new Set<Id>();
            // collects USMLE Transcript case caseId
            Set<Id> usmleTransCaseId = new Set<Id>();
            // collects Medical Education Form/Credential Verification caseIds
            Set<Id> medEduFormOrCVCaseId = new Set<Id>();
            // collects Entity user Request case caseId
            Set<Id> entityUserReqCaseId = new Set<Id>();
            // Collects entity Ids and Alternate entity Ids from Credential Verification and Medical Education form
            Set<Id> entityIds = new Set<Id>();
            // Collects the parent Ids
            Set<Id> parentIds = new Set<Id>();
            // Collects Ids to fetch the Exam Registrtion object records
            Set<String> examRegIds = new Set<String>();
            Set<String> recTypesSet = new Set<String>{REC_TYPE_MED_EDU_FORM,Constant_Case__mdt.getInstance('REC_TYPE_DEV_MEDICAL_EDUCATION_RESOURCES').Value__c,Constant_Case__mdt.getInstance('REC_TYPE_ATTESTATION').Value__c,Constant_Case__mdt.getInstance('REC_TYPE_ENTSERVREQ').Value__c,Constant_Case__mdt.getInstance('REC_TYPE_PAPER_FILE_REQUEST').Value__c,REC_TYPE_AUTHSIGNLIST, REC_TYPE_ELIGIBILITY_PERIOD,Constant_Case__mdt.getInstance('REC_TYPE_NON_USMLE_TRANSCRIPT').Value__c};
            // collects ERAS caseIds
            Set<Id> erasCaseId = new Set<Id>();
            for(Case newCase : newCases){
                if(String.isNotBlank(newCase.ContactId)){
                    contactIds.add(newCase.ContactId);
                }
                String rtDevName = mapRecordTypes.get(newCase.recordTypeId);
                if(ctDataWrap.rtCases.containsKey(rtDevName)){
                    ctDataWrap.rtCases.get(rtDevName).add(newCase);
                }else{
                    ctDataWrap.rtCases.put(rtDevName,new List<Case>{newCase});
                }
                if(rtDevName == REC_TYPE_DEV_INVESTIGATION_CASE || rtDevName == REC_TYPE_USMLE_TRANSCRIPT){
                    transAnnotationCaseIds.add(newCase.Id);                
                }
                if(rtDevName == REC_TYPE_USMLE_TRANSCRIPT){
                    usmleTransCaseId.add(newCase.Id);                
                }
                if(rtDevName == REC_TYPE_MED_EDU_FORM){
                    medEduFormOrCVCaseId.add(newCase.Id);                
                }
                if(rtDevName == REC_TYPE_CRED_VER){
                    medEduFormOrCVCaseId.add(newCase.Id);
                    cvCaseIds.add(newCase.Id);
                    if(String.isNotBlank(newCase.Entity__c)){
                        entityIds.add(newCase.Entity__c);
                    }
                    if(String.isNotBlank(newCase.Alternate_Entity__c)){
                        entityIds.add(newCase.Alternate_Entity__c);
                    }
                }
                if(rtDevName == REC_TYPE_ENTITY_USER_REQUEST){
                    entityUserReqCaseId.add(newCase.Id);                
                }                
                if(rtDevName == REC_TYPE_ENTITY_USER_REQUEST){
                    entityIds.add(newCase.AccountId);
                    entityIds.add(newCase.Entity__c);
                }
                if(recTypesSet.contains(rtDevName) && String.isNotBlank(newCase.ParentId)){
                    parentIds.add(newCase.ParentId);    
                }
                if(rtDevName == REC_TYPE_EXAM_REGISTRATION){
                    examRegIds.add(newCase.Id);
                }
                if(rtDevName == REC_TYPE_ERAS){
                    erasCaseId.add(newCase.Id);
                }
            }
            if(!contactIds.isEmpty()){
                ctDataWrap.genericData.put(Constant_Data_Key__mdt.getInstance('CONTACT_REC').Value__c,new Map<String,Contact>([SELECT Id,School_Enrollment_Status__c,Name,Birthdate,Email,Firstname
                ,Generational_Suffix__c,Gender__c,Graduation_Year__c,LastName,Account.Medschool_Code__c,National_Identification__c,RecordType.DeveloperName
                ,USMLE_ID__c,US_Social_Security__c,npsp__Deceased__c,National_ID_Country__c,MiddleName,is_CIBIS_Origin__c,Attestation_Prerequisite_met__c,OFAC_Scan_Required__c FROM Contact WHERE Id IN :contactIds]));
            }
            if(!transAnnotationCaseIds.isEmpty()){
                transAnnotation(transAnnotationCaseIds);
            }
            if(ctDataWrap.rtCases.containsKey(Constant_Case__mdt.getInstance('REC_TYPE_USMLE_TRANSCRIPT').Value__c)){
                usmleTransCaseCompData(usmleTransCaseId);
            }
            if(ctDataWrap.rtCases.containsKey(REC_TYPE_MED_EDU_FORM) || 
               ctDataWrap.rtCases.containsKey(REC_TYPE_CRED_VER)){                
                medEduFormAndCVCompData(medEduFormOrCVCaseId);
            }
            if(ctDataWrap.rtCases.containsKey(REC_TYPE_CRED_VER)){
                getAsset2verification(cvCaseIds);
                getVerificationPacket(cvCaseIds);
            }
            if(!entityIds.isEmpty()){
                getAccount2Service(entityIds);
            }
            if(!contactIds.isEmpty() && (ctDataWrap.rtCases.containsKey(REC_TYPE_ATTESTATION) || ctDataWrap.rtCases.containsKey(REC_TYPE_DEV_INVESTIGATION_CASE))){
                getContCase(contactIds); 
            }
            if(!contactIds.isEmpty() && ctDataWrap.rtCases.containsKey(REC_TYPE_ENTITY_USER_REQUEST)){
                getAsset(new Set<Id>(), contactIds);
            }
            if(ctDataWrap.rtCases.containsKey(REC_TYPE_ENTITY_USER_REQUEST)){
                getService();
            }
            if(!entityUserReqCaseId.isEmpty()){
                getCase2ServiceRecords(entityUserReqCaseId);
            }
            if(!parentIds.isEmpty()){
                getChildParent(parentIds);
            }
            if(!contactIds.isEmpty() && (ctDataWrap.rtCases.containsKey(Constant_Case__mdt.getInstance('REC_TYPE_ECFMG_CERTIFICATION').Value__c)||ctDataWrap.rtCases.containsKey(REC_TYPE_ATTESTATION) || ctDataWrap.rtCases.containsKey(REC_TYPE_ENROLLMENT_VERIFICATION))){
                getCATrecord(contactIds);
            }
            if(!examRegIds.isEmpty()){
                getExamReg(examRegIds);
            }
            if(!erasCaseId.isEmpty() && !contactIds.isEmpty() && (ctDataWrap.rtCases.containsKey(Constant_Case__mdt.getInstance('REC_TYPE_ERAS').Value__c))){                
                getPreviousErasCase(erasCaseId, contactIds);
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }
    // Fetches Contact Association Type record based on contact Id
    private static void getCATrecord(Set<Id> contactIds){
        try{
            Map<String,List<Contact_Association_Type__c>> conCAT = new Map<String,List<Contact_Association_Type__c>>();
            String catQuery = 'SELECT Id,Account__c,RecordTYpe.DeveloperName,Contact__c,Number_of_Years_Attended__c,Transfer_Credit_to_Degree_School__c FROM Contact_Association_Type__c WHERE Contact__c IN: contactIds';
            if(UserInfo.getName() != Constant_other__mdt.getInstance('ENTITY360_SITE_GUEST_USER').Value__c){
                catQuery += ' WITH SECURITY_ENFORCED';
            }
            for(Contact_Association_Type__c catRec : Database.Query(catQuery)){
                if(conCAT.containsKey(catRec.Contact__c)){
                    conCAT.get(catRec.Contact__c).add(catRec);
                }else{
                    conCAT.put(catRec.Contact__c, new List<Contact_Association_Type__c>{catRec});
                }
            }
            ctDataWrap.genericDataList.put(Constant_Data_Key__mdt.getInstance('CAT_CONTACT').Value__c,conCAT);
        }catch(Exception ex){
            throw ex;
        }
    }
    // Fetches the existing App for cert records based on contacts
    private static void getContCase(Set<Id> contactIds){
        try{
            Map<String,List<Case>> conCase = new Map<String,List<Case>>();
            Set<String> recType = new Set<String>{Constant_Case__mdt.getInstance('REC_TYPE_DEV_APPFORCERT').Value__c,REC_TYPE_EPIC_VER_REPORT_REQUEST,REC_TYPE_ATTESTATION};
            //for(Case caseRec : [SELECT Id,Internal_Status__c,contactId FROM Case WHERE ContactId IN: contactIds AND RecordType.DeveloperName =: REC_TYPE_ATTESTATION AND Internal_Status__c NOT IN: intStatus WITH SECURITY_ENFORCED]){
            for(Case caseRec : [SELECT Id,Internal_Status__c,contactId,RecordType.DeveloperName,Irregular_Behavior_Annotated__c FROM Case WHERE ContactId IN: contactIds AND RecordType.DeveloperName IN: recType WITH SECURITY_ENFORCED]){
                if(conCase.containsKey(caseRec.contactId)){
                    conCase.get(caseRec.contactId).add(caseRec);
                }else{
                    conCase.put(caseRec.contactId,new List<Case>{caseRec});
                }
            }
            if(!conCase.isEmpty()){
                ctDataWrap.genericDataList.put(Constant_Data_Key__mdt.getInstance('CONTACT_CASE').Value__c,conCase);
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // Fetches the EPIC Verification report
    private static void getEpicVerRep(Set<Id> parentIds){
        try{
            Map<String,Case> epicVerRep = new Map<String,Case>([SELECT Id, Internal_Status__c, Service__c,Do_Not_Know_Orgs_to_send_EPIC_Reports__c, (SELECT Id, Entity__c, Internal_Status__c, Service__c, Report_Type__c, EPIC_Report_Status__c, EPIC_Report_Received_Date__c, First_Verification_Request_Sent_Date__c, Verification_Request_Send_Date__c FROM Secondary_Child_Cases__r) FROM Case WHERE Id IN: parentIds WITH SECURITY_ENFORCED]);
            if(!epicVerRep.isEmpty()){
                ctDataWrap.genericData.put(Constant_Data_Key__mdt.getInstance('CASE_EPIC_VER_REPORT').Value__c,epicVerRep);
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // Fetches Asset records
    private static void getAsset(Set<Id> caseIds,Set<Id> contactIds){
        try{
            // Collects Asset Rec List against Case
            Map<String,List<Asset>> mapAssetCase = new Map<String,List<Asset>>();
            // Collects Asset Rec List against Contact
            Map<String,List<Asset>> mapAssetContact = new Map<String,List<Asset>>();
            String query = 'SELECT Id,Case__c,Status,Type__c,Name,ContactId,Revocation_Date__c,Reinstatement_Date__c,Recordtype.DeveloperName,Azure_Storage_URL__c,Parent_Case__c FROM Asset WHERE (Case__c IN: caseIds OR ContactId IN: contactIds)';
            if(UserInfo.getName() != Constant_other__mdt.getInstance('ENTITY360_SITE_GUEST_USER').Value__c){
                query +=WITH_SEC_ENFORCED;
            }
            // Queries all the assets related to the Case.
            for(Asset assetRec : Database.Query(String.escapeSingleQuotes(query))){
                if(String.isNotBlank(assetRec.Case__c) && caseIds.contains(assetRec.Case__c)){
                    if(mapAssetCase.containsKey(assetRec.Case__c)){
                        mapAssetCase.get(assetRec.Case__c).add(assetRec);
                    }else{
                        mapAssetCase.put(assetRec.Case__c,new List<Asset>{assetRec});
                    }
                }
                if(String.isNotBlank(assetRec.ContactId) && contactIds.contains(assetRec.ContactId)){
                    if(mapAssetContact.containsKey(assetRec.ContactId)){
                        mapAssetContact.get(assetRec.ContactId).add(assetRec);
                    }else{
                        mapAssetContact.put(assetRec.ContactId,new List<Asset>{assetRec});
                    }
                }
            }
            if(!mapAssetCase.isEmpty()){
                ctDataWrap.genericDataList.put(Constant_Data_Key__mdt.getInstance('ASSET_REC_CASE').Value__c,mapAssetCase);
            }
            if(!mapAssetContact.isEmpty()){
                ctDataWrap.genericDataList.put(Constant_Data_Key__mdt.getInstance('ASSET_REC_CONTACT').Value__c,mapAssetContact);
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // Fetches transcript annotation records
    private static void transAnnotation(Set<Id> caseIds){
        try{
            if(!caseIds.isEmpty()){
                Map<String,Transcript_Anotation__c> transAnnotList = new Map<String,Transcript_Anotation__c>([SELECT Id,Cibis_Transcript_Status__c,Contact__c,Transcript_Case__c,ANNOTATION_TEXT__c
                ,USMLE_Transcripts_Notes__c,Transcript_Case__r.Related_Transcript_Case__r.Internal_Status__c,Transcript_Case__r.Related_Transcript_Case__r.External_Status__c,Transcript_Case__r.Related_Transcript_Case__r.OwnerId
                ,ACTIVE__c,SORT_ORDER__c,ANNOTATION_CODE__c,SHORT_TEXT__c,Transcript_Case__r.Cibis_Transcript_Status__c,Transcript_Case__r.Internal_Status__c FROM Transcript_Anotation__c WHERE Transcript_Case__c IN:caseIds WITH SECURITY_ENFORCED]);
                if(!transAnnotList.isEmpty()){
                    ctDataWrap.genericData.put(Constant_Data_Key__mdt.getInstance('CASE_TRANSCRIPT_ANOTATION').Value__c,transAnnotList);
                }
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // USMLE Transcript Case compute Data
    private static void usmleTransCaseCompData(Set<Id> usmleTransCaseId){
        try{
            if(!usmleTransCaseId.isEmpty()){
                Map<String,List<Exam_Registration__c>> examRegMap = new Map<String,List<Exam_Registration__c>>();
                for(Exam_Registration__c examReg : [SELECT Id, Exam_Status__c, Test_Accommodations__c, 
                Transcript_Comments__c,Applicant__c FROM Exam_Registration__c WHERE Exam_Types__c != null AND Exam_Status__c != null AND 
                Exam_Status__c != : Constant_Exam_Registration__mdt.getInstance('EXAM_STATUS_NOSHOW').Value__c AND Exam_taken_date__c != null AND
                 Applicant__c IN(SELECT ContactId FROM Case WHERE Id =:usmleTransCaseId) WITH SECURITY_ENFORCED]){
                     if(examRegMap.containsKey(examReg.Applicant__c)){
                        examRegMap.get(examReg.Applicant__c).add(examReg);
                     }else{
                        examRegMap.put(examReg.Applicant__c,new List<Exam_Registration__c>{examReg});
                     }
                 }
                if(!examRegMap.isEmpty()){
                    rtPopulateDataList(Constant_Case__mdt.getInstance('REC_TYPE_USMLE_TRANSCRIPT').Value__c,examRegMap,Constant_Data_Key__mdt.getInstance('CASE_EXAM_REGISTRATION').Value__c);
                }
                
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // Medical Education Form/Credential Verification compute data
    private static void medEduFormAndCVCompData(Set<Id> medEduFormOrCredVerCaseId){
        try{
            Set<String> recordTypes = new Set<String>{Constant_Affirmation__mdt.getInstance('REC_TYPE_DEV_MEDICAL_EDUCATION_FORM').Value__c
            ,Constant_Affirmation__mdt.getInstance('REC_TYPE_DEV_CREDENTIAL_VERIFICATION').Value__c,
            Constant_Affirmation__mdt.getInstance('REC_TYPE_DEV_NOT_VERIFIED').Value__c,
            Constant_Affirmation__mdt.getInstance('REC_TYPE_DEV_VERIFICATION_REVIEW').Value__c};
            if(!medEduFormOrCredVerCaseId.isEmpty()){
                //Creating map with Key:Case Id and Value: List of Affirmations
                Map<String,List<sObject>> affirmationMap = new Map<String,List<sObject>>();            
                for(Affirmation__c affirmation : [SELECT Id,Verify_with_Alternate_Entity__c,Case__c,RecordType.DeveloperName,Not_Verified_Next_Step__c,Status__c  
                                                 FROM Affirmation__c WHERE Case__c IN: medEduFormOrCredVerCaseId AND RecordType.DeveloperName IN: recordTypes
                                                 WITH SECURITY_ENFORCED]){
                    if(affirmationMap.containsKey(affirmation.Case__c)){
                        affirmationMap.get(affirmation.Case__c).add(affirmation);
                    }else{
                        affirmationMap.put(affirmation.Case__c,new List<sObject>{affirmation});
                    }
                }
                if(!affirmationMap.isEmpty()){
                    ctDataWrap.genericDataList.put(Constant_Data_Key__mdt.getInstance('CASE_AFFIRMATION').Value__c,affirmationMap);
                }
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // Gets the account2service records based on entity Ids collected
    static void getAccount2Service(Set<Id> entityIds){
        try{
            // This map stores the acc2Service records based on account Id
            Map<String,List<Account2service__c>> acc2serMap = new Map<String,List<Account2service__c>>();
            if(!entityIds.isEmpty()){
                String query = 'SELECT Account__r.Id,Account__r.ECFMG_Acceptable__c,Active__c,Service__r.Name FROM Account2Service__c WHERE Account__c IN: entityIds';
                if(UserInfo.getName() != Constant_other__mdt.getInstance('ENTITY360_SITE_GUEST_USER').Value__c){
                    query +=WITH_SEC_ENFORCED;
                }
                for(Account2Service__c accSer:Database.Query(String.escapeSingleQuotes(query))){
                    if(acc2serMap.containsKey(accSer.Account__r.Id)){
                        acc2serMap.get(accSer.Account__r.Id).add(accSer);
                    }else{
                        acc2serMap.put(accSer.Account__r.Id,new List<Account2service__c>{accSer});
                    }
                }
            }
            if(!acc2serMap.isEmpty()){
                ctDataWrap.genericDataList.put(Constant_Data_Key__mdt.getInstance('ACCOUNT2SERVICE').Value__c,acc2serMap);
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // Gets the Asset2Verification records for the corresponding Case Ids
    static void getAsset2verification(Set<Id> caseIds){
        try{
            Map<String,List<Asset2Verification__c>> asset2VerMap = new Map<String,List<Asset2Verification__c>>();
            for(Asset2Verification__c asset2Ver:[SELECT Id,Asset__c,Asset__r.Case__r.Document_Type__c,Asset__r.RecordType.DeveloperName
            ,Asset__r.Name,Asset__r.Type__c,Document_Type__c,Verification_Packet__r.Case__c,Verification_Packet__r.Is_Active__c
            ,Asset__r.Status FROM Asset2Verification__c WHERE Verification_Packet__r.Case__c IN: caseIds WITH SECURITY_ENFORCED]){
                if(asset2VerMap.containsKey(asset2Ver.Verification_Packet__r.Case__c)){
                    asset2VerMap.get(asset2Ver.Verification_Packet__r.Case__c).add(asset2Ver);
                }else{
                    asset2VerMap.put(asset2Ver.Verification_Packet__r.Case__c,new List<Asset2Verification__c>{asset2Ver});
                }
            }
            if(!asset2VerMap.isEmpty()){
                rtPopulateDataList(REC_TYPE_CRED_VER,asset2VerMap,Constant_Data_Key__mdt.getInstance('ASSET2VERPACKET').Value__c);
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // Gets the Verification Packet records for the corresponding Case Ids
    static void getVerificationPacket(Set<Id> caseIds){
        try{
            Map<String,List<Verification_Packet__c>> verPackMap = new Map<String,List<Verification_Packet__c>>();
            for(Verification_Packet__c verPack:[SELECT Id,Is_Active__c,Case__c FROM Verification_Packet__c WHERE Case__c IN: caseIds WITH SECURITY_ENFORCED]){
                if(verPackMap.containsKey(verPack.Case__c)){
                    verPackMap.get(verPack.Case__c).add(verPack);
                }else{
                    verPackMap.put(verPack.Case__c,new List<Verification_Packet__c>{verPack});
                }
            }
            if(!verPackMap.isEmpty()){
                rtPopulateDataList(REC_TYPE_CRED_VER,verPackMap,Constant_Data_Key__mdt.getInstance('VERIFICATION_PACKET').Value__c);
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // Gets child records based on parentId records
    static void getChildParent(Set<Id> parentIds){
        try{
            // Stores the child records groupd by parent Id
            // Parent Id, List of child records
            Map<String,Case> caseChildMap = new Map<String,Case>([SELECT Id,
                                                                        RecordType.DeveloperName,
                                                                        Internal_Status__c,
                                                                        Service__c,
                                                                        Entity__c,
                                                                        Document_Type__c,
                                                                        Document_URL__c,
                                                                        AccountId,
                                                                        ContactId,
                                                                        Enrollment_Verification_Parent__c, 
                                                                        Enrollment_Verification_Parent__r.Enrolled_in_Entity_Portal__c,
                                                                        Enrollment_Verification_Parent__r.AccountId,
                                                                        (SELECT Id,
                                                                            Internal_Status__c,
                                                                            Service__c, 
                                                                            ParentId, 
                                                                            Is_Removed_From_EV__c, 
                                                                            RecordType.DeveloperName,
                                                                            parent.Enrollment_Verification_Parent__r.AccountId,
                                                                            Enrollment_Verification_Parent__c
                                                                        FROM Cases) 
                                                                    FROM Case 
                                                                    WHERE Id =: parentIds 
                                                                    WITH SECURITY_ENFORCED]);
            if(!caseChildMap.isEmpty()){
                ctDataWrap.genericData.put(Constant_Data_Key__mdt.getInstance('CHILD_CASE_RECORDS').Value__c,caseChildMap);
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // Exam Registration compute data for after update/insert
    // This will be used for processing the records to get count.
    static Set<String> examRegistrationCompDataAfter(Set<Id> enrollmentVerParent,Set<Id> examRegCaseId){
        try{
            Set<String> examRegIds = new Set<String>();
            if(!examRegCaseId.isEmpty()){
                Map<String,List<CaseHistory>> csHistMap = new Map<String,List<CaseHistory>>();
                //for(CaseHistory csHist: [SELECT CaseId, Field, NewValue, OldValue FROM CaseHistory WHERE field = 'Internal_Status__c' AND caseId IN:examRegCaseId WITH SECURITY_ENFORCED]){
                for(CaseHistory csHist: [SELECT CaseId, Field, NewValue, OldValue FROM CaseHistory WHERE field = 'Status' AND caseId IN:examRegCaseId WITH SECURITY_ENFORCED]){
                    if(csHistMap.containsKey(csHist.CaseId)){
                        (csHistMap.get(csHist.CaseId)).add(csHist);
                    }else{
                        csHistMap.put(csHist.CaseId,new List<CaseHistory>{csHist});
                    }
                }
                if(!csHistMap.isEmpty()){
                    rtPopulateDataList(REC_TYPE_EXAM_REGISTRATION,csHistMap,Constant_Data_Key__mdt.getInstance('CASE_EXAM_REGISTRATION_HISTORY').Value__c);
                }
                Map<String,Eligibility_Period__c> eligibilityPeriodMap = new Map<String,Eligibility_Period__c>();
                for(Eligibility_Period__c eligPerRec:[SELECT Id, Deadline_Date__c, EP_Start_Date__c, EP_End_Date__c, Exam_Type__c, Active__c 
                FROM Eligibility_Period__c WHERE RecordType.DeveloperName =: Constants.ELIGIBILITY_PERIOD_RECORD_TYPE_EXAM_REG AND Active__c = 'Y' AND Extension_Flag__c = 'N' AND (EXAM_TYPE__C =: Constant_Exam_Registration__mdt.getInstance('EXAM_TYPES_USMLESTEPONE').Value__c OR 
                EXAM_TYPE__c =: Constant_Exam_Registration__mdt.getInstance('EXAM_TYPES_USMLESTEPTWOCK').Value__c) AND 
                ((CALENDAR_MONTH(EP_Start_Date__c) =: Constants.CURRENT_MONTH AND CALENDAR_YEAR(EP_Start_Date__c) =: Constants.CURRENT_YEAR) OR
                 (CALENDAR_MONTH(EP_Start_Date__c) =: Constants.NEXT_MONTH AND CALENDAR_YEAR(EP_Start_Date__c) =: Constants.NEXT_YEAR)) WITH SECURITY_ENFORCED ORDER BY EP_Start_Date__c]){
                    eligibilityPeriodMap.put(eligPerRec.EXAM_TYPE__c+'-'+(eligPerRec.EP_Start_Date__c).month()+'-'+(eligPerRec.EP_Start_Date__c).year(),eligPerRec);
                 }
                if(!eligibilityPeriodMap.isEmpty()){
                    rtPopulateData(REC_TYPE_EXAM_REGISTRATION,eligibilityPeriodMap,Constant_Data_Key__mdt.getInstance('ELIGIBILITY_PERIOD').Value__c);
                }
            }
            if(!enrollmentVerParent.isEmpty()){
                Map<String,Case> examEligMap = new Map<String,Case>([SELECT Id,Exam_Outcome_Report__c,Enrollment_Verification_Parent__c,Enrollment_Verification_Parent__r.AccountId,RecordType.DeveloperName,Deficiency_Reason_RTF__c,Internal_Status__c,Signature_Date__c,Is_First_time_Exam_Case__c
                 FROM Case WHERE Enrollment_Verification_Parent__c IN: enrollmentVerParent WITH SECURITY_ENFORCED]);
                if(!examEligMap.isEmpty()){
                    rtPopulateData(REC_TYPE_EXAM_REGISTRATION,examEligMap,Constant_Data_Key__mdt.getInstance('CHILD_CASE_EXAM_REGISTRATION').Value__c);
                }
                examRegIds.addAll(examEligMap.keySet());
                enrollmentVerCompDataAfter(examEligMap);
            }
            return examRegIds;
        }catch(Exception ex){
            throw ex;
        }
    }
    // Enrollment Verification compute data for after update/insert
    static void enrollmentVerCompDataAfter(Map<String,Case> enrollVerParMap){
        try{
            Map<String,List<Case>> evChildExamRegMap = new Map<String,List<Case>>();
            Map<String,List<Case>> enrollVerChildMap = new Map<String,List<Case>>();
            for(case childCase : enrollVerParMap.values()){
                if(enrollVerChildMap.containsKey(childCase.Enrollment_Verification_Parent__c)){	
                    enrollVerChildMap.get(childCase.Enrollment_Verification_Parent__c).add(childCase);	
                }else{
                    enrollVerChildMap.put(childCase.Enrollment_Verification_Parent__c, new List<Case>{childCase});	
                }
                if(childCase.RecordType.DeveloperName == REC_TYPE_EXAM_REGISTRATION){
                    if(evChildExamRegMap.containsKey(childCase.Enrollment_Verification_Parent__c)){	
                        evChildExamRegMap.get(childCase.Enrollment_Verification_Parent__c).add(childCase);	
                    }else{
                        evChildExamRegMap.put(childCase.Enrollment_Verification_Parent__c, new List<Case>{childCase});	
                    }
                }
            }
            if(!enrollVerChildMap.isEmpty()){
                ctDataWrap.genericDataList.put(Constant_Data_Key__mdt.getInstance('EV_CHILD_CASES').Value__c,enrollVerChildMap);
            }
            if(!evChildExamRegMap.isEmpty()){
                ctDataWrap.genericDataList.put(Constant_Data_Key__mdt.getInstance('EV_CHILD_EXAM_REG_CASES').Value__c,evChildExamRegMap);
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }
    // Fetch Child Exam Registrstion object records
    static void getExamReg(Set<String> examRegIds){
        try{
            Map<String,SObject> childExamRegMap = new Map<String,SObject>([SELECT Id,
                                                                                    CreatedDate,
                                                                                    Exam_Outcome_Report__c,
                                                                                    Enrollment_Verification_Parent__c,
                                                                                    Enrollment_Verification_Parent__r.AccountId,
                                                                                    Enrollment_Verification_Parent__r.Enrolled_in_Entity_Portal__c,
                                                                                    (SELECT Id,
                                                                                        Exam_Status__c,
                                                                                        Test_Accommodations_needed__c,
                                                                                        Visa_Letter_Needed__c,
                                                                                        Case__c,
                                                                                        EP_start_Date__c,
                                                                                        EP_end_Date__c,
                                                                                        Exam_Types__c,
                                                                                        SLA_Date__c 
                                                                                    FROM Exam_Registrations__r) 
                                                                            FROM Case 
                                                                            WHERE Id IN: examRegIds 
                                                                            WITH SECURITY_ENFORCED]);
            if(!childExamRegMap.isEmpty()){
                ctDataWrap.genericData.put(Constant_Data_Key__mdt.getInstance('CHILD_CASE_EXAM_REGISTRATION').Value__c,childExamRegMap);
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    //Get all services
    static void getService(){
        try{
            String query = 'SELECT Id, Name, Signature_Required__c FROM Service__c';
            if(UserInfo.getName() != Constant_other__mdt.getInstance('ENTITY360_SITE_GUEST_USER').Value__c){
                query +=WITH_SEC_ENFORCED;
            }
            Map<String, sObject> serviceMap = new Map<String, sObject>(Database.Query(String.escapeSingleQuotes(query)));
            if(!serviceMap.isEmpty()){
                ctDataWrap.genericData.put(Constant_Data_Key__mdt.getInstance('ALLSERVICE').Value__c,serviceMap);
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    //Retrieve the Entity User Request Case's Case2Service  records
    private static void getCase2ServiceRecords(Set<Id> entityUserReqId){
        try{
            if(!entityUserReqId.isEmpty()){	
                String query = 'SELECT Id,Service__c, Service__r.name, Service__r.Signature_Required__c, Case__c,case__r.RecordTypeId,Case__r.Entity__c, role__c'+
                ' FROM Case2Service__c WHERE Case__c IN: entityUserReqId';
                if(UserInfo.getName() != Constant_other__mdt.getInstance('ENTITY360_SITE_GUEST_USER').Value__c){
                    query +=WITH_SEC_ENFORCED;
                }
                Map<String, List<Case2Service__c>> case2ServiceMap = new Map<String, List<Case2Service__c>>();
                for(Case2Service__c case2SerIns : Database.Query(String.escapeSingleQuotes(query))){	
                    if(case2ServiceMap.containsKey(case2SerIns.Case__c)){	
                        case2ServiceMap.get(case2SerIns.Case__c).add(case2SerIns);	
                    }else{
                        case2ServiceMap.put(case2SerIns.Case__c, new List<Case2Service__c>{case2SerIns});	
                    }
                }
                if(!case2ServiceMap.isEmpty()){
                    rtPopulateDataList(REC_TYPE_ENTITY_USER_REQUEST, case2ServiceMap, Constant_Data_Key__mdt.getInstance('CASE_TO_SERVICE').Value__c);	
                }
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    //Method to get prior ERAS Cases in before insert and after update
    private static void getPreviousErasCase(Set<Id> erasIds, Set<Id> contactIds){
        try{        
            Id erasRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get(REC_TYPE_ERAS).getRecordTypeId();
            List<case> erasCaseList = new List<case>();
            if(!erasIds.isEmpty()){
                erasCaseList = [SELECT Id, ContactId, Eligibility_Period__c FROM Case 
                                    WHERE contactId IN:contactIds AND 
                                    RecordtypeId =: erasRecordTypeId AND Id NOT IN:erasIds 
                                    WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1];
            }
            else {
                erasCaseList = [SELECT Id, ContactId, Eligibility_Period__c FROM Case 
                                    WHERE contactId IN:contactIds AND 
                                    RecordtypeId =: erasRecordTypeId  
                                    WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1];
            }
            Set<Id> priorSeasonCaseId = new Set<Id>(); 
            Map<String,Case> priorSeasonErasCaseMap = new Map<String,Case>();              
            if(!erasCaseList.isEmpty()){
                for(case priorSeasonCase : erasCaseList){
                    priorSeasonErasCaseMap.put(priorSeasonCase.ContactId,priorSeasonCase);
                    priorSeasonCaseId.add(priorSeasonCase.Id);
                }
            }
            if(!priorSeasonErasCaseMap.isEmpty()){
                rtPopulateData(REC_TYPE_ERAS,priorSeasonErasCaseMap,Constant_Data_Key__mdt.getInstance('ERAS').Value__c);
            }     
            //getting the active eligibility period       
            Map<String,List<Eligibility_Period__c>> activeEligibilityPeriodMap = new Map<String,List<Eligibility_Period__c>>();    
            Id erasEPRecordTypeId = Schema.SObjectType.Eligibility_Period__c.getRecordTypeInfosByDeveloperName().get('ERAS').getRecordTypeId();        
            for(Eligibility_Period__c erasEPRecord : [SELECT Id, Season__c, Earlier_Season_Id__c FROM Eligibility_Period__c 
                                                      WHERE RecordTypeId = :erasEPRecordTypeId 
                                                      AND ERAS_Active__c = TRUE  
                                                      WITH SECURITY_ENFORCED]){
                if(activeEligibilityPeriodMap.containsKey(erasEPRecord.Season__c)){
                    activeEligibilityPeriodMap.get(erasEPRecord.Season__c).add(erasEPRecord);
                }else{
                    activeEligibilityPeriodMap.put(erasEPRecord.Season__c,new List<sObject>{erasEPRecord});
                }
            }
            if(!activeEligibilityPeriodMap.isEmpty()){
                ctDataWrap.genericDataList.put(Constant_Data_Key__mdt.getInstance('ERAS_ELIGIBILITY_PERIOD').Value__c,activeEligibilityPeriodMap);
            } 
            //getting the assets of the prior season Eras case      
            Map<String,List<Asset>> mapAssetCase = new Map<String,List<Asset>>();
            String query = 'SELECT Id, ParentId, Case__c,Status,Type__c,Name,ContactId,Revocation_Date__c,Reinstatement_Date__c,Recordtype.DeveloperName,Azure_Storage_URL__c,Parent_Case__c FROM Asset WHERE (Case__c IN: priorSeasonCaseId)';
            if(UserInfo.getName() != Constant_other__mdt.getInstance('ENTITY360_SITE_GUEST_USER').Value__c){
                query +=WITH_SEC_ENFORCED;
            }
            // Queries all the assets related to the previous ERAS Case.
            for(Asset assetRec : Database.Query(String.escapeSingleQuotes(query))){
                if(String.isNotBlank(assetRec.Case__c)){
                    if(mapAssetCase.containsKey(assetRec.Case__c)){
                        mapAssetCase.get(assetRec.Case__c).add(assetRec);
                    }else{
                        mapAssetCase.put(assetRec.Case__c,new List<Asset>{assetRec});
                    }
                }
            }
            if(!mapAssetCase.isEmpty()){
                ctDataWrap.genericDataList.put(Constant_Data_Key__mdt.getInstance('ASSET_REC_CASE').Value__c,mapAssetCase);
            }     
        }catch(Exception ex){
            throw ex;
        }           
    }
    // Upserts the records
    public void upsertDML(){
        try{
            List<sObject> upsertList = new List<sObject>();
            if(!(ctDataWrap.updateDML).isEmpty()){
                upsertList.addAll((ctDataWrap.updateDML).values());
            }
            if(!(ctDataWrap.insertDML).isEmpty()){
                upsertList.addAll((ctDataWrap.insertDML));
            }
            if(!upsertList.isEmpty()){
                Integer i =0;
                for(Database.UpsertResult upsRes :Database.upsert(upsertList,false)){
                    if(!upsRes.isSuccess()){
                        system.debug(upsertList[i]);
                        system.debug(upsRes.getErrors());
                    }
                    i++;
                }
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }
    // Deletes the records
    public void deleteDML(){
        try{
           for(Database.DeleteResult deleteRes: Database.delete(new List<Id>(ctDataWrap.deleteDML),false)){
               if(!deleteRes.isSuccess()){
                   system.debug(deleteRes.getErrors());
                }
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // Triggers email
    public void sendEmail(){
        if(!(ctDataWrap.sendEmail).isEmpty()){
            Messaging.sendEmail(ctDataWrap.sendEmail);
        }
    }
    // Stores data related to the record type
    static void rtPopulateData(String rtDevName,Map<String,sObject> recordMap,String key){
        try{
            if(ctDataWrap.rtKeyrelatedRec.containsKey(rtDevName)){
                (ctDataWrap.rtKeyrelatedRec.get(rtDevName)).put(key,recordMap);
            }else{
                (ctDataWrap.rtKeyrelatedRec).put(rtDevName,new Map<String,Map<String,sObject>>{key=>recordMap});
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // Stores data related to the record type
    static void rtPopulateDataList(String rtDevName,Map<String,List<sObject>> mapRecordList,String key){
        try{
            if(ctDataWrap.rtKeyrelatedRecList.containsKey(rtDevName)){
                (ctDataWrap.rtKeyrelatedRecList.get(rtDevName)).put(key,mapRecordList);
            }else{
                (ctDataWrap.rtKeyrelatedRecList).put(rtDevName,new Map<String,Map<String,List<sObject>>>{key=>mapRecordList});
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // Returns record type related data with return type as Map<String,sObject>
    public static Map<String,sObject> fetchRTDataSObject(String recTypeDevName,String objKey){
        try{
            if(ctDataWrap.rtKeyrelatedRec.containsKey(recTypeDevName) && (ctDataWrap.rtKeyrelatedRec.get(recTypeDevName)).containsKey(objKey)){
                return (ctDataWrap.rtKeyrelatedRec.get(recTypeDevName)).get(objKey);
            }else{
                return new Map<String,sObject>();
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // Returns record type related data with return type as Map<String,List<sObject>>
    public static Map<String,List<sObject>> fetchRTDataSObjectList(String recTypeDevName,String objKey){
        try{
            if(ctDataWrap.rtKeyrelatedRecList.containsKey(recTypeDevName) && (ctDataWrap.rtKeyrelatedRecList.get(recTypeDevName)).containsKey(objKey)){
                return (ctDataWrap.rtKeyrelatedRecList.get(recTypeDevName)).get(objKey);
            }else{
                return new Map<String,List<sObject>>();
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // Returns generic data related data with return type as Map<String,sObject>
    public static Map<String,sObject> fetchGenericDataSObject(String objKey){
        try{
            if(ctDataWrap.genericData.containsKey(objKey)){
                return ctDataWrap.genericData.get(objKey);
            }else{
                return new Map<String,sObject>();
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // Returns generic data related data with return type as Map<String,List<sObject>>
    public static Map<String,List<sObject>> fetchGenericDataSObjectList(String objKey){
        try{
            if(ctDataWrap.genericDataList.containsKey(objKey)){
                return ctDataWrap.genericDataList.get(objKey);
            }else{
                return new Map<String,List<sObject>>();
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // This class stores the data that will be used in the respective handler.
    public class CaseTriggerDataWrapper{
        // Stores the record type developer name and its corresponding records that has to be processed.
        public Map<String,List<Case>> rtCases = new Map<String,List<Case>>();
        // Stores the records that has to be updated.
        public Map<Id,sObject> updateDML = new Map<Id,sObject>();
        // Stores the records that has to be inserted.
        public List<sObject> insertDML = new List<sObject>();
        // Stores the set of Ids that has to be deleted.
        public Set<Id> deleteDML = new Set<Id>();
        // Stores record type, Key(to identify the list of records), record Id/Case Id and the corresponding record
        public Map<String,Map<String,Map<String,sObject>>> rtKeyrelatedRec = new Map<String,Map<String,Map<String,sObject>>>();
        // Stores record type, Key(to identify the list of records), parent record Id/Case Id and the corresponding records
        public Map<String,Map<String,Map<String,List<sObject>>>> rtKeyrelatedRecList = new Map<String,Map<String,Map<String,List<sObject>>>>();
        // Stores object name, recordId, sObject
        public Map<String,Map<String,sObject>> genericData = new Map<String,Map<String,sObject>>();
        // Stores object name, recordId/parent recordId, list sObject
        public Map<String,Map<String,List<sObject>>> genericDataList = new Map<String,Map<String,List<sObject>>>();
        // Stores the service, accountId, CaseIds to be used for inserting caseShare
        public Map<string,Map<Id,set<Id>>> insServiceAccCaseMap = new Map<string,Map<Id,set<Id>>>();
        // Stores the service, accountId, CaseIds to be used for deleting caseShare
        public Map<string,Map<Id,set<Id>>> delServiceAccCaseMap = new Map<string,Map<Id,set<Id>>>();
        // Stores the set of account Ids to be used for inserting/deleting caseShare
        public Set<Id> accountIdSet = new Set<Id>();
        // Stores the list of send email message
        public List<Messaging.SingleEmailMessage> sendEmail = new List<Messaging.SingleEmailMessage>();
    }
}