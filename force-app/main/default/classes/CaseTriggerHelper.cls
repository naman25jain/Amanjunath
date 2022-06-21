/**
 * Test Classes
 * CaseTriggerHelperTest
 * EntityReviewControllerTest
 * MedEduControllerTest
 */
public with sharing class CaseTriggerHelper{
    /**
* @author: Jofrin
* @methodname: casePerformanceDataMapCheck
* @description: Method to retrieve case2services 
* @Parameters: set of case id
* @return type: MAP<Id, Boolean>
*/
public static MAP<Id, Boolean> casePerformanceDataMapCheck(List<Case> newCases){
    MAP<Id, Boolean> casePerformanceDataMap = new MAP<Id, Boolean>();
    for(Case2Service__c case2ServiceObj : [SELECT ID, Case__c, Service__c, Service__r.name FROM Case2Service__c 
                                           WHERE Service__r.name =: Constants.SERVICE_NAME_PERFORMANCE_DATA 
                                           AND Case__c IN: newCases]){            
                                               casePerformanceDataMap.put(case2ServiceObj.Case__c, true);                                                        
                                           }
    return casePerformanceDataMap;
}
//Generate USMLE Id for contact records which doesnt have USMLE Id UserStory:2134
public static void generateUsmleId(Case newCase, Case oldCase){
    if(oldCase.Internal_Status__c != newCase.Internal_Status__c && newCase.Internal_Status__c == Constants.CASE_STATUS_SUBMITTED){           
        List<string> usmleIds = genUsmleId();
        List<Contact> contactList = [SELECT id FROM Contact where USMLE_ID__c =:UsmleIds[0] WITH SECURITY_ENFORCED];
        if(!contactList.isEmpty()){
            updateSequence(usmleIds[1]);
            usmleIds.clear();
            usmleIds = genUsmleId();
            if(![SELECT id FROM Contact where USMLE_ID__c =:usmleIds[0] WITH SECURITY_ENFORCED].isEmpty()){
                CalloutException e = new CalloutException();
                e.setMessage('Error generating New USMLE_ID!');
                throw e;
            }                
        }
        Contact applicant = [SELECT id FROM Contact where id=: newCase.ContactId WITH SECURITY_ENFORCED];            
        applicant.USMLE_ID__c = usmleIds[0];
        try{
            update applicant; //Do not use CRUD check since logged in user doesn't have access.
        }
        catch(Exception e){
            System.debug('Exception-'+e.getMessage());
        }
        updateSequence(usmleIds[1]);
    }
}
// method to prepare email
public static Messaging.SingleEmailMessage prepareEmail(Case caseRec,OrgWideEmailAddress addr,EmailTemplate emailTemplate){
    try{
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setTargetObjectId(caseRec.ContactId);
        message.setTemplateID(emailTemplate.Id);
        message.setOrgWideEmailAddressId(addr.Id);
        message.setSubject(emailTemplate.Subject);
        message.toAddresses = new String[]{caseRec.ContactEmail};
            return message;
    }
    catch(Exception ex){
        throw ex;
    }
}
/**
* @author: Chinmay Menon
* @methodname : getMapOfCaseIdCase2Service
* @description: Method to get map of all case2service records for corresponding incoming Entity User Request Cases
* @Parameters : List of Entity User Request Case
* @return type: Map<Id, List<Case2Service__c>> - Map of Entity User Request Case id and listg of corresponding case2service record
*/
public static Map<Id, List<Case2Service__c>> getMapOfCaseIdCase2Service(List<Case> entityUserRequestCaseList){
    List<Id> entityUserRequestCaseIdList = new List<Id>();
    for(Case c : entityUserRequestCaseList){
        entityUserRequestCaseIdList.add(c.Id);
    }
    
    List<Case2Service__c> case2serviceList = new List<Case2Service__c>([SELECT Id, Case__c, Service__c, Service__r.Name, Service__r.Signature_Required__c FROM Case2Service__c WHERE Case__c IN :entityUserRequestCaseIdList]);
    
    Map<Id, List<Case2Service__c>> caseIdCase2ServiceMap = new Map <Id, List<Case2Service__c>>();
    
    for(Case c : entityUserRequestCaseList){
        for(Case2Service__c c2a : case2serviceList){
            if(c2a.Case__c == c.Id){
                if(caseIdCase2ServiceMap.containsKey(c.Id)){
                    caseIdCase2ServiceMap.get(c.Id).add(c2a);
                } 
                else{
                    caseIdCase2ServiceMap.put(c.Id, new List<Case2Service__c>{c2a});
                }
            }
        }
    }
    return caseIdCase2ServiceMap;
}
// Changes the List to Map and calls formatGetAltCaseIds
public static Set<Id> getAltCaseIds(List<case> newCase){
    Set<Id> altCaseIds = new Set<Id>();
    for(Case caseRecord : newCase){
        if(caseRecord.Alternate_Entity__c != null){
            altCaseIds.add(caseRecord.Id);
        }
    }
    return formatGetAltCaseIds(altCaseIds);
}
// This method fetches corresponding entity of all child records (except the current case) of parent caseId.
public static Map<Id,Set<Id>> getParentCaseChildCaseEntity(Set<Id> shareCredVerCases,Set<Id> cvParentCaseIds){
    List<Case> childCaseList = [SELECT Id,ParentId,Entity__c,Alternate_Entity__c FROM Case WHERE Id NOT IN:shareCredVerCases AND ParentId IN: cvParentCaseIds AND Parent.RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_APP_FOR_CERT AND RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION];
    Set<Id> aleternateAccCaseIds = new Set<Id>(getAltCaseIds(childCaseList));
    Map<Id,Set<Id>> parentCaseEntity = new Map<Id,Set<Id>>();
    for(Case childCaseRecord:childCaseList){
        Set<Id> entityIds = new Set<Id>();
        if(parentCaseEntity.containsKey(childCaseRecord.ParentId)){
            entityIds.addAll(parentCaseEntity.get(childCaseRecord.ParentId));
        }
        if(aleternateAccCaseIds.contains(childCaseRecord.Id)){
            entityIds.add(childCaseRecord.Alternate_Entity__c);
        }else{
            entityIds.add(childCaseRecord.Entity__c);
        }
        parentCaseEntity.put(childCaseRecord.ParentId,entityIds);
    }
    return parentCaseEntity;
}
// This method checks if the CV parent caseId has access to entity passed.
public static boolean checkParentCaseEntityAccess(Id parentCaseId, Id entityId,Map<Id,Set<Id>> parentCaseEntity){
    if(parentCaseEntity.containsKey(parentCaseId) && parentCaseEntity.get(parentCaseId).contains(entityId)){
        return true;
    }
    return false;
}
public static List<string> genUsmleId(){
    String nextUsmleId = getSequence();
    List<String> uSMLE_Digits = new List<String>{'0','0','0','0','0','0','0'};
        Integer length = nextUsmleId.length();
    for(Integer i=0;i<length;i++){
        uSMLE_Digits[i] = nextUsmleId.substring(length-i-1,length-i);
    }
    Integer n_evenSum = Integer.valueOf(uSMLE_Digits[1]) + Integer.valueOf(uSMLE_Digits[3]) + Integer.valueOf(uSMLE_Digits[5]);
    Integer n_oddCat = Integer.valueOf(uSMLE_Digits[0] + uSMLE_Digits[2] + uSMLE_Digits[4] + uSMLE_Digits[6])*2;
    Integer n_oddSum = 0;
    while(n_oddCat >= 1){
        n_oddSum = n_oddSum + (Math.Mod(n_oddCat,10));
        n_oddCat = n_oddCat/10;
    }
    Integer valueX = n_oddSum + n_evenSum;
    Integer n_checkDigit = getCheckDigit(valueX);
    String n_checkDigitStr = String.valueOf(n_checkDigit).substring(0,1);            
    if(nextUsmleId.length() < 7){
        for(Integer i=0; i < 7-nextUsmleId.length();i++){
            nextUsmleId ='0'+nextUsmleId;
        }
    }
    String newUsmleId = nextUsmleId + n_checkDigitStr;
    return new List<string>{newUsmleId,nextUsmleId};
        }
        /* 18 May 2020  
* @author Femi  
* @name: updateSequence 
* Purpose : To update usmle sequence value  
* @return type: void    
*/    
    public static void updateSequence(String currentValue){
        String nextValue = String.valueOf(Integer.valueOf(currentValue) + 1);
        if(nextValue.length() < 7){
            for(Integer i=0; i < 7-nextValue.length();i++){
                nextValue ='0'+nextValue;
            }
        }
        USMLE_Sequence__c t = USMLE_Sequence__c.getInstance(UserInfo.getOrganizationId());
        t.Sequence__c = nextValue;
        update t;
    }
    // gets case Id which are marked as verify with alternate entity
    public static Set<Id> formatGetAltCaseIds(Set<Id> caseIds){
        Set<Id> aleternateAccCaseIds = new Set<Id>();
        if(Affirmation__c.SObjectType.getDescribe().isAccessible() && !caseIds.isEmpty()){
            List<Affirmation__c> affirmationList = [SELECT Id,Verify_with_Alternate_Entity__c,Case__r.Id FROM Affirmation__c WHERE Case__r.Id IN: caseIds AND RecordType.DeveloperName =: Constants.AFFIRMATION_RECORD_TYPE_CREDENTIAL_VERIFICATION AND Verify_with_Alternate_Entity__c = true WITH SECURITY_ENFORCED];
            for(Affirmation__c affirmation : affirmationList){
                aleternateAccCaseIds.add(affirmation.case__r.Id);
            }
        }
        return aleternateAccCaseIds;
    }
    /* 27 May 2020
* @author Femi
* @name: getSequence
* Purpose : To get usmle sequence value
* @return type: String
*/
public static String getSequence(){
    USMLE_Sequence__c t = USMLE_Sequence__c.getInstance(UserInfo.getOrganizationId());
    if(t.Sequence__c ==null){
        USMLE_Sequence__c obj = new USMLE_Sequence__c(Name = 'Sequence');
        obj.Sequence__c = Constants.USMLE_SEQUENCE_START_VALUE;
        insert obj;
        t = USMLE_Sequence__c.getInstance(UserInfo.getOrganizationId());
    }
    return t.Sequence__c;
    
}
/* 18 May 2020
* @author Femi
* @name: getCheckDigit
* Purpose : To get check digit for usmle id generation
* @return type: Integer
*/
public static Integer getCheckDigit(Integer valueX){
    Integer valueQ = 0;
    Integer valueZ = 0;
    Integer valueY = 0;
    if(valueX < 10){
        valueQ = 10;
    }
    else{
        valueY = valueX/10;
        valueZ = Math.mod(valueX, 10);
        if(valueZ > 0){
            valueQ = 10*(valueY+1);
        }
        else{
            valueQ = 10*valueY;
        }
    }
    
    Integer n_checkDigit = valueQ - valueX;
    return n_checkDigit;
}

public class PopulateParentCase{
    public Map<Id,Set<Id>> accCaseMap = new Map<Id,set<Id>>();
    public Map<Id,Set<Id>> parentCaseEntity = new Map<Id,Set<Id>>();
}
//     // Purpose : To optimise after insert context code
//     public static void afterInsertHelper(List<Case> newCases){
//         Id epexRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD).getRecordTypeId();
//         Id examRegRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();        
//         Id epexChangeRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD).getRecordTypeId(); 
//         Set<Id> examRegCaseIds = new Set<Id>();
//         List<Case> newCasesAdded = new List<Case>();
//         List<Case> newEpexCaseList = new List<Case>();
//         List<Case> epexCases = new List<Case>();
//         List<Case> newCibisCases = new List<Case>();
        
//         for(Case newCase : newCases){ 
//             if(newCase.RecordTypeId == epexRTId){
//                 // User story 3212 Update Enrollment Verification Case for EPEx
//                 if(newCase.Internal_Status__c == Constants.CASE_STATUS_PENDING_ENROLLMENT){
//                     examRegCaseIds.add(newCase.ParentId);
//                     epexCases.add(newCase);
//                 }
//             }
//             //Get ECFMG Portal Url and update in Case field. This is used for email notification to applicant
//             if(String.isBlank(newCase.ECFMG_Portal_Case_Url__c)){
//                 newCasesAdded.add(newCase);
//             }
//             if(newCase.Internal_Status__c == Constants.CASE_STATUS_PENDING_CIBIS){
//                 newCibisCases.add(newCase);
//             }
//         }
//         // invoke Cibis platform event publish logic
//         if(RecursiveTriggerHandler.isFirstTimeCibis && !newCibisCases.isEmpty()){
//             RecursiveTriggerHandler.isFirstTimeCibis = false;          
//             system.debug('invokeCibisPlatformEventLogic after Insert');
//             CibisUtility.invokeCibisPlatformEventLogic(newCibisCases, null);
//         }
//         // To avoiding SonarCloud issues - calling as seperate method
//         system.debug('afterInsert helper-26'+RecursiveTriggerHandler.isFirstTimeCibis);
//         afterInsertHelperRefactor(examRegCaseIds, newCasesAdded, newEpexCaseList, epexCases);          
//         CasePBActionsHandler.afterTriggerHandler(newCases, new Map<Id, Case>());        
        
//     }
    
    
//     // To optimise, avoiding Sonar Cloud issue fixes
//     public static void afterInsertHelperRefactor(Set<Id> examRegCaseIds, List<Case> newCasesAdded, List<Case> newEpexCaseList, List<Case> epexCases){
//         if(!examRegCaseIds.isEmpty()){
//             EnrollmentVerificationCaseHandler.updateSLADateEPEx(examRegCaseIds);
//         }
//         if(!newCasesAdded.isEmpty()){
//             updatePortalCaseUrl(newCasesAdded);
//         }
//         if(!epexCases.isEmpty()){
//             updateEpexCasesForEV(epexCases);
//         }
//     }
//     // Purpose : Method to allowing recursive update on Case
//     public static void afterUpdateHelperRecursive(List<Case> newCases, Map<Id, Case> oldCasesMap){
//         Id enUsrReqRecordTypeId =   Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENTITY_USER_REQUEST).getRecordTypeId();
//         Id examRegRTId          =   Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();        
//         List<Case> entityContactNewCases        =   new List<Case>();
//         List<Case> examRegCaseList              =   new List<Case>();
//         MAP<ID, Case> entityContactOldCasesMap  =   new MAP<ID, Case>();
//         List<Id> evCaseShrLs              =   new List<Id>();
//         if(!newCases.isEmpty()){
//             for(Case newCase : newCases){                         
//                 if(newCase.RecordTypeId == enUsrReqRecordTypeId){             
//                     entityContactNewCases.add(newCase);
//                     entityContactOldCasesMap.put(newCase.Id, oldCasesMap.get(newCase.Id));
//                 }
//                 if(newCase.RecordTypeId == examRegRTId && oldCasesMap.get(newCase.Id).Internal_Status__c != newCase.Internal_Status__c){
//                     examRegCaseList.add(newCase);
//                 }                
//                 if(newCase.RecordTypeId == Constants.EXAMREGRTID && newCase.Enrollment_Verification_Parent__c != null && (oldCasesMap.isEmpty() || (oldCasesMap.containsKey(newCase.Id) && (newCase.Enrollment_Verification_Parent__c != oldCasesMap.get(newCase.Id).Enrollment_Verification_Parent__c || newCase.OwnerId != oldCasesMap.get(newCase.Id).OwnerId)))){
//                     evCaseShrLs.add(newCase.Enrollment_Verification_Parent__c);
//                 }
//             }            
//         }      
        
//         // Update EP Start & End Date when Exam Reg Case is changing status as Pending CIBIS
//         if(!examRegCaseList.isEmpty()){
//             MAP<ID, Exam_Registration__c> examRegMap = new MAP<ID, Exam_Registration__c>();
//             Map<Id, Case> examRegCaseMap =   getPendingCibisExamRegCases(oldCasesMap, examRegCaseList);
//             if(!examRegCaseMap.isEmpty()){
//                 List<Id> examCaseIdList =   new List<Id>(examRegCaseMap.keySet());
//                 examRegMap = getExamRegistrationRefactor(examCaseIdList);
//                 if(!examRegMap.isEmpty()){
//                     managePendingCibisEP(examRegCaseMap, oldCasesMap, examRegMap);
//                 }
//             }
//         }
//         checkIfOwnerChanged(newCases,oldCasesMap);
//         if(!entityContactNewCases.isEmpty()){
//             entityContactCheckNewServiceForm(entityContactNewCases, entityContactOldCasesMap);
//         }
//         // User story - 7604 -- creating new method for refactor - Cognitive complexity fixes
//         handleEVCaseToUpdateCAT(newCases, oldCasesMap);
//         updateSharingEVRule(evCaseShrLs);
        
//     }   
//     //Bug fix 17430 
//     public static void updateSharingEVRule(List<Id> evCaseShrLs){
//         if(!evCaseShrLs.isEmpty()){
//             SharingRuleEVCase.updateSharingRules(evCaseShrLs);
//         }
//     }
//     // User story - 7604 -- creating new method for refactor - Cognitive complexity fixes
//     public static void handleEVCaseToUpdateCAT(List<Case> newCases, Map<Id, Case> oldCasesMap){
//         Id evRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION).getRecordTypeId();
//         List<Case> evCaseList  =   new List<Case>();
//         if(!newCases.isEmpty()){
//             for(Case newCase : newCases){
//                 if(newCase.RecordTypeId == evRTId && oldCasesMap.get(newCase.Id).Internal_Status__c != newCase.Internal_Status__c && newCase.Internal_Status__c == Constants.CASE_STATUS_ENROLLMENT_VERIFICATION_COMPLETE){
//                     evCaseList.add(newCase);
//                 }
//             }
//         }
//         // User story - 7604 -- creating new method for refactor - Cognitive complexity fixes
//         if(!evCaseList.isEmpty()){
//             handleEVCaseVerificationStatus(evCaseList);
//         }     
//     }
    
//     // User story - 7604 -- creating new method for refactor - Cognitive complexity fixes
//     public static void handleEVCaseVerificationStatus(List<Case> evCaseList){
//         SET<Id> enrolledVCaseIdSet  =   new SET<Id>();
//         SET<Id> graduatedVCaseIdSet =   new SET<Id>();
//         SET<Id> withdrawnVCaseIdSet =   new SET<Id>();
//         SET<Id> contactIdSet        =   new SET<Id>();
//         MAP<ID, ID> catMap          =   new  MAP<ID, ID>();
//         for(Case newCase : evCaseList){
//             if(newCase.Verification_Status__c == Constants.CASE_VERIFICATION_STATUS_ENROLLED || newCase.Verification_Status__c == Constants.CASE_VERIFICATION_DECEASED){
//                 enrolledVCaseIdSet.add(newCase.Id);       
//             } 
//             else if(newCase.Verification_Status__c == Constants.CASE_VERIFICATION_STATUS_GRADUATED){
//                 graduatedVCaseIdSet.add(newCase.Id);       
//             } 
//             else if(newCase.Verification_Status__c == Constants.CASE_VERIFICATION_WITHDRAWN || newCase.Verification_Status__c == Constants.CASE_VERIFICATION_DISMISSED || newCase.Verification_Status__c == Constants.CASE_VERIFICATION_TRANSFERRED){
//                 withdrawnVCaseIdSet.add(newCase.Id);       
//             }
//             contactIdSet.add(newCase.ContactId);
//         }
//         catMap  =   getCATMap(contactIdSet);
//         if(!enrolledVCaseIdSet.isEmpty()){
//             updateCATEnrolled(enrolledVCaseIdSet, catMap);
//         }
//         if(!graduatedVCaseIdSet.isEmpty()){
//             updateCATGraduated(graduatedVCaseIdSet, catMap);
//         }
//         if(!withdrawnVCaseIdSet.isEmpty()){
//             updateCATWithdrawn(withdrawnVCaseIdSet, catMap);
//         }
//     }
    
//     // Get Contact Association Type - Degree Medical School
//     public static MAP<ID, ID> getCATMap(Set<Id> contactIdSet){ 
//         MAP<ID, ID> catMap = new MAP<ID, ID>();
//         if(!contactIdSet.isEmpty()){
//             Id conAssocTypeRecordTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL).getRecordTypeId();
//             for(Contact_Association_Type__c catRecord : [SELECT Contact__c, Id FROM Contact_Association_Type__c WHERE RecordTypeId =: conAssocTypeRecordTypeId AND Contact__c IN: contactIdSet WITH SECURITY_ENFORCED]){
//                 catMap.put(catRecord.Contact__c, catRecord.Id);
//             }                                                          
//         }
//         return catMap;
//     }
    
//     // USER STORY 7604 - If "Enrolled" or "Deceased" is the Verification Status, then update the following fields on the CAT record
//     public static void updateCATEnrolled(Set<Id> enrolledVCaseIdSet, MAP<ID, ID> catMap){        
//         List<Case> evCaseList = [SELECT Id, ContactId, Attendance_Start_Month__c, Attendance_Start_Year__c, Attendance_End_Month__c, Attendance_End_Year__c,
//                                  Graduation_Month__c, Graduation_Year__c, Number_of_Years_Attended__c, Degree_Month__c, Degree_Year__c
//                                  FROM Case 
//                                  WHERE Id IN :enrolledVCaseIdSet WITH SECURITY_ENFORCED];
//         List<Contact_Association_Type__c> catList = new List<Contact_Association_Type__c>();
//         for(Case enrolledCase : evCaseList){
//             if(catMap.get(enrolledCase.ContactId) != null){
//                 Contact_Association_Type__c catObj  =   new Contact_Association_Type__c();  
//                 catObj.Id                           =   catMap.get(enrolledCase.ContactId);       
//                 catObj.Start_Month__c               =   enrolledCase.Attendance_Start_Month__c;
//                 catObj.Start_Year__c                =   enrolledCase.Attendance_Start_Year__c;
//                 catObj.End_Month__c                 =   enrolledCase.Attendance_End_Month__c;
//                 catObj.End_Year__c                  =   enrolledCase.Attendance_End_Year__c;
//                 catObj.Graduation_Month__c          =   enrolledCase.Graduation_Month__c;
//                 catObj.Graduation_Year__c           =   enrolledCase.Graduation_Year__c;
//                 catObj.Degree_Issue_Month__c        =   enrolledCase.Degree_Month__c;
//                 catObj.Degree_Issue_Year__c         =   enrolledCase.Degree_Year__c;
//                 catObj.Number_of_Years_Attended__c  =   enrolledCase.Number_of_Years_Attended__c;
//                 catList.add(catObj);
//             }
//         }
//         if(!catList.isEmpty() && Contact_Association_Type__c.SObjectType.getDescribe().isUpdateable()){
//             update catList;
//         }        
//     }
    
//     // USER STORY 7604 - If "Graduated" is the Verification Status, then update the following fields on the CAT record
//     public static void updateCATGraduated(Set<Id> graduatedVCaseIdSet, MAP<ID, ID> catMap){
//         List<Case> evCaseList = [SELECT Id, ContactId, Attendance_Start_Month__c, Attendance_Start_Year__c, Attendance_End_Month__c, Attendance_End_Year__c,
//                                  Graduation_Month__c, Graduation_Year__c, Number_of_Years_Attended__c, Degree_Month__c, Degree_Year__c, Verification_Status_Month__c, Verification_Status_Year__c
//                                  FROM Case 
//                                  WHERE Id IN :graduatedVCaseIdSet WITH SECURITY_ENFORCED];
//         List<Contact_Association_Type__c> catList = new List<Contact_Association_Type__c>();
//         for(Case graduatedCase : evCaseList){
//             if(catMap.get(graduatedCase.ContactId) != null){
//                 Contact_Association_Type__c catObj  =   new Contact_Association_Type__c(); 
//                 catObj.Id                           =   catMap.get(graduatedCase.ContactId);
//                 catObj.Start_Month__c               =   graduatedCase.Attendance_Start_Month__c;
//                 catObj.Start_Year__c                =   graduatedCase.Attendance_Start_Year__c;
//                 catObj.End_Month__c                 =   graduatedCase.Attendance_End_Month__c;
//                 catObj.End_Year__c                  =   graduatedCase.Attendance_End_Year__c;
//                 catObj.Degree_Issue_Month__c        =   graduatedCase.Degree_Month__c;
//                 catObj.Degree_Issue_Year__c         =   graduatedCase.Degree_Year__c;
//                 catObj.Number_of_Years_Attended__c  =   graduatedCase.Number_of_Years_Attended__c;
//                 catObj.Graduation_Month__c          =   graduatedCase.Verification_Status_Month__c;
//                 catObj.Graduation_Year__c           =   graduatedCase.Verification_Status_Year__c;
//                 catList.add(catObj);
//             }
//         }
//         if(!catList.isEmpty() && Contact_Association_Type__c.SObjectType.getDescribe().isUpdateable()){
//             update catList;
//         }
//     }
    
//     // USER STORY 7604 - If "Withdrawn" or "Dismissed" or "Transferred" is the Verification Status, then update the following fields on the CAT record
//     public static void updateCATWithdrawn(Set<Id> withdrawnVCaseIdSet, MAP<ID, ID> catMap){
//         List<Case> evCaseList = [SELECT Id, ContactId, Attendance_Start_Month__c, Attendance_Start_Year__c, Attendance_End_Month__c, Attendance_End_Year__c,
//                                  Graduation_Month__c, Graduation_Year__c, Number_of_Years_Attended__c, Degree_Month__c, Degree_Year__c, 
//                                  Verification_Status_Date__c, Verification_Status_Month__c, Verification_Status_Year__c
//                                  FROM Case 
//                                  WHERE Id IN :withdrawnVCaseIdSet WITH SECURITY_ENFORCED];
//         List<Contact_Association_Type__c> catList = new List<Contact_Association_Type__c>();
//         for(Case withdrawnCase : evCaseList){
//             if(catMap.get(withdrawnCase.ContactId) != null){
//                 Date verStDt = withdrawnCase.Verification_Status_Date__c;
//                 String verStMonth = getMonthAsText(verStDt.Month());
//                 String verStYear = String.valueOf(verStDt.Year());
//                 Contact_Association_Type__c catObj  =   new Contact_Association_Type__c();       
//                 catObj.Id                           =   catMap.get(withdrawnCase.ContactId);
//                 catObj.Start_Month__c               =   withdrawnCase.Attendance_Start_Month__c;
//                 catObj.Start_Year__c                =   withdrawnCase.Attendance_Start_Year__c;
//                 catObj.End_Month__c                 =   verStMonth;
//                 catObj.End_Year__c                  =   verStYear;
//                 catObj.Graduation_Month__c          =   withdrawnCase.Graduation_Month__c;
//                 catObj.Graduation_Year__c           =   withdrawnCase.Graduation_Year__c;
//                 catObj.Degree_Issue_Month__c        =   withdrawnCase.Degree_Month__c;
//                 catObj.Degree_Issue_Year__c         =   withdrawnCase.Degree_Year__c;
//                 catObj.Number_of_Years_Attended__c  =   withdrawnCase.Number_of_Years_Attended__c;
//                 catList.add(catObj);
//             }
//         }
//         if(!catList.isEmpty() && Contact_Association_Type__c.SObjectType.getDescribe().isUpdateable()){
//             update catList;
//         }
//     }
    
//     public static String getMonthAsText(Integer intMonth){
//         Map<Integer,String> monthMap = new  Map<Integer,String>();
//         monthMap.put(1,'January');
//         monthMap.put(2,'February');
//         monthMap.put(3,'March');
//         monthMap.put(4,'April');
//         monthMap.put(5,'May');
//         monthMap.put(6,'June');
//         monthMap.put(7,'July');
//         monthMap.put(8,'August');
//         monthMap.put(9,'September');
//         monthMap.put(10,'October');
//         monthMap.put(11,'November');
//         monthMap.put(12,'December');
//         return monthMap.get(intMonth);
//     }
//     public static void checkIfOwnerChanged(List<Case> newCases,Map<Id, Case> oldCasesMap){
//         Group specialInvQueue = CaseTriggerUtility.groupMap.get(Constants.CASE_SPECIAL_INVESTIGATIONS_QUEUE);
//         Id examRegRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
//         List<Id> ownerChangedList = new List<Id>();
//         if(!newCases.isEmpty()){
//             for(Case newCase : newCases){
//                 if(newCase.RecordTypeId == examRegRTId && oldCasesMap.get(newCase.Id).OwnerId != newCase.OwnerId && newCase.OwnerId == specialInvQueue.Id){
//                     ownerChangedList.add(newCase.Enrollment_Verification_Parent__c);
//                 }
//             }
//         }
//         if(!ownerChangedList.isEmpty()){
//             SharingRuleEVCase.updateSharingRules(ownerChangedList);
//         }
//     }
//     // Purpose : To optimise after update context code
//     public static void afterUpdateHelper(List<Case> newCases, Map<Id, Case> oldCasesMap){
//         Id examRegRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
//         Id evCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION).getRecordTypeId();
//         Id rgnChngeRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_REGION_CHANGE).getRecordTypeId();
//         Id epexRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD).getRecordTypeId();
//         Id ervRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_REVERIFICATION).getRecordTypeId();
//         Id enUsrReqRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENTITY_USER_REQUEST).getRecordTypeId();
//         Id ecfmgCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ECFMG_CERTIFICATION).getRecordTypeId();
//         Id dupCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_DUPLICATE_CERTIFICATE).getRecordTypeId();
//         MAP<ID, Exam_Registration__c> examRegMap = new MAP<ID, Exam_Registration__c>();
//         List<Id> examCaseList = new List<Id>();
//         List<Case> examRegCaseList = new List<Case>();
//         List<Case> newEntityUserReqCaseList = new List<Case>();
//         List<Case> newCaseList = new List<Case>();
//         Map<Id,Case> attestCaseMap = new Map<Id,Case>();
//         Set<Id> attestContactIds = new Set<Id>();
//         MAP<ID, Case> oldCaseValuesMap = new MAP<ID, Case>();
        
//         //Code added by Shailaja. New fields for Month & Year for Start & End Dates.
//         newCases = [SELECT id, Internal_Status__c, Case_Type__c, ContactId, AccountId, ParentId, Scheduling_Permit_Hold__c, recordType.DeveloperName,
//                     ECFMG_Portal_Case_Url__c, Enrolled_in_Entity_Portal__c, Entity__c, Source__c, Verification_Status__c, Passed_basic_sciences_course__c,
//                     Attendance_Start_Date__c, Attendance_Start_Month__c, Attendance_Start_Year__c, Attendance_End_Date__c, Attendance_End_Month__c, Attendance_End_Year__c, Graduation_Month__c, Graduation_Year__c, Degree_Date__c,
//                     Number_of_Years_Attended__c, Enrollment_Verification_Parent__c,Signature_Date__c, Is_Removed_From_EV__c, Is_First_time_Exam_Case__c, Contact.USMLE_ID__c,
//                     Service_Name__r.Signature_Required__c, Verification_Status_Month__c, Verification_Status_Year__c,  Degree_Month__c, Degree_Year__c, Eligibility_Period__c, Exam_Registration__c, OwnerId,
//                     Verification_Status_Date__c, ContactEmail, Contact.Name, Deficiency_Reason_RTF__c, Incomplete_Status_Date__c, Service__c FROM Case WHERE id IN:oldCasesMap.keySet()];
//         for(Case newCase : newCases){
            
//             //examreg case ids for exam reg record query
//             if(newCase.RecordTypeId == examRegRTId){
//                 examCaseList.add(newCase.Id);
//                 examRegCaseList.add(newCase);
//             }            
//             // User story 3270,3271 Update Enrollment Verification Case for exam registration * Merging into single condition for avoiding coginitive error - sonarint issues  * Exam Reg Case || EPEX Case || Enrollment Verification Case            
//             if(newCase.RecordTypeId == examRegRTId || newCase.RecordTypeId == epexRecordTypeId ||  newCase.RecordTypeId == evCaseRecordTypeId || newCase.RecordTypeId == ervRecordTypeId || newCase.RecordTypeId == rgnChngeRecordTypeId || newCase.RecordTypeId == enUsrReqRecordTypeId){
//                 newCaseList.add(newCase);
//                 oldCaseValuesMap.put(newCase.Id, oldCasesMap.get(newCase.Id));
//             }
//             if(newCase.RecordTypeId == Constants.ATTESTRECORDTYPEID){
//                 if(newCase.Case_Type__c == Constants.CASE_TYPE_ATTESTATION_SUB_CASE && newCase.Internal_Status__c == Constants.CASE_STATUS_INCOMPLETE_RESENT_TO_APPLICANT &&
//                    newCase.Internal_Status__c != oldCasesMap.get(newCase.Id).Internal_Status__c){
//                        attestCaseMap.put(newCase.ParentId,newCase);
//                    }
//                 if(newCase.Case_Type__c == Constants.CASE_TYPE_ATTESTATION_CASE && newCase.Internal_Status__c == Constants.CASE_STATUS_ACCEPTED &&
//                    newCase.Internal_Status__c != oldCasesMap.get(newCase.Id).Internal_Status__c){
//                        attestContactIds.add(newCase.ContactId);
//                    }
//             }
//             // Modified 7 July 2020 to change it from afterinsert to afterupdate * User story 5574 EP8: Progress the case from status "New"
//             newEntityUserReqCaseList = checkEntityUserReqCaseConditions(newCase, newEntityUserReqCaseList, enUsrReqRecordTypeId);
//             updateEpexCasesOnManualReview(newCase, oldCasesMap.get(newCase.Id));
//             generateUsmleId(newCase, oldCasesMap.get(newCase.Id));
//             generateMailOnPaperEnrollment(newCases, oldCasesMap);            
//         }
        
//         if(!newCaseList.isEmpty()){  
//             // Email and Asset creation of 'Visa letter' and 'scheduling permit' for 'Registered' exam registration cases.            
//             examRegMap = getExamRegistrationRefactor(examCaseList);
//             manageExamRegManualReview(newCaseList, oldCasesMap);
//             system.debug('Inside Case trigger Helper');
//             manageSchedulingPermit(newCaseList, oldCasesMap, examRegMap);
//             EnrollmentVerificationCaseHandler.systemManageNewCases(newCaseList, oldCaseValuesMap);
//             // US 6122 :Send "New Service Template" and "PIA Template" to contact on Entity User Request deficiency            
//             sendEntityUserRequestDeficiency(newCaseList, enUsrReqRecordTypeId);
//         }
//         // Modified to change it from afterinsert to afterupdate * User story 5574 EP8: Progress the case from status "New"
//         if(!newEntityUserReqCaseList.isEmpty()){
//             updateEntityUserRequestCaseStatus(newEntityUserReqCaseList);
//         } 
//         if (!attestCaseMap.values().isEmpty()){
//             updateParentAttestation(attestCaseMap);
//         }
//         if (!attestContactIds.isEmpty()){
//             updateAttestPrereqMet(attestContactIds);
//         }
//         // To avoiding SonarCloud issues - calling as seperate method
//         afterUpdateHelperRefactorOne(newCases, oldCasesMap);
//         // Send an email to the Applicant when the ECFMG Certification case has been marked as "Sent"
//         sendMailEcfmgCertIssued(newCases, oldCasesMap);
//     }
//     public static void updateAttestPrereqMet(Set<Id> attestContactIds){
//         List<Contact> attestContacts = [SELECT Id,Attestation_Prerequisite_met__c FROM Contact WHERE Id IN : attestContactIds];
//         for(Contact con : attestContacts){
//             con.Attestation_Prerequisite_met__c = true;
//         }
//         if(Contact.SObjectType.getDescribe().isUpdateable() && !attestContacts.isEmpty()){
//             UPDATE attestContacts;
//         }
//     }
//     public static void updateParentAttestation(Map<Id,Case> attestCaseMap){
//         List<Case> parentCases = [SELECT Id, Internal_Status__c FROM Case WHERE Id IN :attestCaseMap.keySet() WITH SECURITY_ENFORCED];
//         for(case parentCase : parentCases){
//             parentCase.Internal_Status__c = attestCaseMap.get(parentCase.Id).Internal_Status__c;
//         }
//         if(Case.SObjectType.getDescribe().isUpdateable()){
//             UPDATE parentCases;
//         }
//     }
//     // US 6122 :Send "New Service Template" and "PIA Template" to contact on Entity User Request deficiency
//     public static void sendEntityUserRequestDeficiency(List<Case> newCases, Id enUsrReqRecordTypeId){
//         Case eurCase = new Case();
//         if(!newCases.isEmpty() && newCases[0].Internal_Status__c == Constants.CASE_STATUS_INCOMPLETE && newCases[0].RecordTypeId == enUsrReqRecordTypeId){
//             eurCase = newCases[0];
//             getAssetAttachments(eurCase.Id, enUsrReqRecordTypeId);
//         }
//     }
//     //@description: US 6122 :Get attached asset files
//     @future(Callout=True)
//     public static void getAssetAttachments(Id caseId, Id enUsrReqRecordTypeId){
//         try{
//             Map<String,Asset> assetTypeMap = new Map<String,Asset>();
//             List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
//             for(Asset assetRec :[SELECT Id, Type__c, Status, Azure_Storage_URL__c 
//                                  FROM Asset 
//                                  WHERE Case__c = :caseId 
//                                  AND Status != :Constants.ASSET_STATUS_OUTDATED 
//                                  AND status != :constants.ASSET_STATUS_MARKED_FOR_DELETION 
//                                  AND (Status = :Constants.ASSET_STATUS_INCOMPLETE OR Type__c = :Constants.ASSET_TYPE_NEW_SERVICE_TEMPLATE OR Type__c = :Constants.ASSET_TYPE_PIA_TEMPLATE)
//                                  WITH SECURITY_ENFORCED]){
//                                      assetTypeMap.put(assetRec.Type__c, assetRec);
//                                  }
//             if(assetTypeMap.containsKey(Constants.ASSET_TYPE_SIGNED_SERVICE_FORM) && assetTypeMap.containsKey(Constants.ASSET_TYPE_NEW_SERVICE_TEMPLATE) && assetTypeMap.get(Constants.ASSET_TYPE_SIGNED_SERVICE_FORM).Status == Constants.ASSET_STATUS_INCOMPLETE){
//                 Asset newSerAsset = assetTypeMap.get(Constants.ASSET_TYPE_NEW_SERVICE_TEMPLATE);
//                 if(String.isNotBlank(newSerAsset.Azure_Storage_URL__c)){
//                     String fileName = newSerAsset.Azure_Storage_URL__c.split('/')[4];
//                     attachments.add(getAttachment(fileName));
//                 }
//             }
//             if(assetTypeMap.containsKey(Constants.ASSET_TYPE_SIGNED_PIA) && assetTypeMap.containsKey(Constants.ASSET_TYPE_PIA_TEMPLATE) && assetTypeMap.get(Constants.ASSET_TYPE_SIGNED_PIA).Status == Constants.ASSET_STATUS_INCOMPLETE){
//                 Asset piaAsset = assetTypeMap.get(Constants.ASSET_TYPE_PIA_TEMPLATE);
//                 if(String.isNotBlank(piaAsset.Azure_Storage_URL__c)){
//                     String fileName = piaAsset.Azure_Storage_URL__c.split('/')[4];
//                     attachments.add(getAttachment(fileName));
//                 }
//             }
//             if(!attachments.isEmpty()){
//                 EmailTemplate template = [SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE DeveloperName =:Constants.CASE_EMAIL_DEFICIENCY_TEMPLATE WITH SECURITY_ENFORCED];
//                 List<OrgWideEmailAddress> addr = [SELECT Id FROM OrgWideEmailAddress WHERE displayname =:Constants.ORG_WIDE_ADDRESS WITH SECURITY_ENFORCED];
//                 Case eurCase = [SELECT Id,Contact.Name,ContactEmail,Deficiency_Reason_RTF__c,Internal_Status__c FROM Case WHERE Id =:caseId WITH SECURITY_ENFORCED];
//                 Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
//                 message.setTemplateId(template.Id);
//                 message.setSubject(template.Subject);
//                 String htmlBody = template.HtmlValue;
//                 htmlBody = htmlBody.replace('{!Case.Contact}', eurCase.Contact.Name);
//                 htmlBody = htmlBody.replace('{!Case.Deficiency_Reason_RTF__c}', eurCase.Deficiency_Reason_RTF__c);
//                 htmlBody = htmlBody.replaceAll('<!\\[CDATA\\[', '');
//                 htmlBody = htmlBody.replaceAll('\\]\\]>', '');
//                 message.setHtmlBody(htmlBody);
//                 message.setOrgWideEmailAddressId(addr[0].Id);
//                 message.setToAddresses(new String[] {eurCase.ContactEmail});
//                 message.setFileAttachments(attachments);
//                 Messaging.sendEmail(new Messaging.SingleEmailMessage[] {message});
//                 if(Case.SObjectType.getDescribe().isUpdateable()){
//                     eurCase.Internal_Status__c = Constants.CASE_STATUS_SENT;
//                     UPDATE eurCase;
//                 }
//             }
//         }
//         catch(Exception e){
//             throw new ControllerException(e.getMessage());
//         }
//     }
//     public static Messaging.EmailFileAttachment getAttachment(String fileName){
//         try{
//             String url = CloudStorageUtils.getFileUrlWithSAS(fileName);
//             Http h = new Http();
//             HttpRequest req = new HttpRequest();
//             req.setMethod('GET');
//             req.setHeader('Content-Length', '0');
//             req.setHeader('x-ms-blob-type', 'BlockBlob');
//             req.setHeader('Content-Type', 'application/pdf');
//             req.setHeader('x-ms-version', '2019-02-02');
//             req.setEndpoint(url);
//             HttpResponse res = h.send(req);
//             Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
//             efa.setFileName(fileName);
//             efa.setBody(res.getBodyAsBlob());
//             return efa;
//         }
//         catch(Exception e){
//             throw new ControllerException(e.getMessage());
//         }
//     }
//     /**
// * @author: Chinmay Menon
// * @methodname: checkEntityUserReqCaseConditions
// * @description: Method to add cases to list of cases if they satisfy the condition for entity user request case criteria;
// *               Method created to reduced cognitive complexity
// * @Parameters: Loop iterator case, list of entity user request case and recordtype id for entity user request case
// * @return type: list<Case>
// */
//     public static List<Case> checkEntityUserReqCaseConditions(Case newCase, List<Case> newEntityUserReqCaseList, Id enUsrReqRecordTypeId){
//         if(newCase.Internal_Status__c == Constants.CASE_STATUS_DUPLICATE_REVIEW_COMPLETE && newCase.RecordTypeId == enUsrReqRecordTypeId){
//             newEntityUserReqCaseList.add(newCase);
//         }
        
//         return newEntityUserReqCaseList;
//     }
    
//     public static void afterUpdateHelperRefactorOne(List<Case> newCases, Map<Id, Case> oldCasesMap){
//         Id epexRecordTypeId     =   Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD).getRecordTypeId();
//         Id iformRequestRTId     =   Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_IFOM_REQUEST).getRecordTypeId();
        
//         List<Case> newCasesAdded=   new List<Case>();     
//         List<Case> newEpexCaseList = new List<Case>();
//         List<Case> newIfomCaseList = new List<Case>();
        
//         for(Case newCase : newCases){
//             /* 21 Feb 2020
// * Get ECFMG Portal Url and update in Case field. This is used for email notification to applicant
// * Update by Reshma Ravi for UserStory 993
// */
//             if(String.isBlank(newCase.ECFMG_Portal_Case_Url__c)){
//                 newCasesAdded.add(newCase);
//             }
//             /* 27 Apr 2020
// * User story 3965 EV29: Scenarios for taking a child case(Exam Reg/EPEx) off the enrollment verification case.
// * Update by Reshma Ravi
// */
//             if(newCase.RecordTypeId == epexRecordTypeId && newCase.Internal_Status__c != oldCasesMap.get(newCase.Id).Internal_Status__c && (newCase.Internal_Status__c == Constants.CASE_STATUS_PENDING_CIBIS || newCase.Internal_Status__c == Constants.CASE_STATUS_REJECTED)){
//                 newEpexCaseList.add(newCase);
//             }
//             /* 22 May 2020
// * User story 3782 IFOM7: Processing after Receipt of Paper Response from School for IFOM EV Request
// * Update by Praveen
// */
//             if(newCase.RecordTypeId == iformRequestRTId){
//                 newIfomCaseList.add(newCase);
//             }          
//         } 
//         if(!newCasesAdded.isEmpty()){
//             updatePortalCaseUrl(newCasesAdded);
//         }      
//         if(!newEpexCaseList.isEmpty()){
//             updateEpexCases(newEpexCaseList);
//         }
//         if(!newIfomCaseList.isEmpty()){
//             updateIFOMCases(newIfomCaseList, oldCasesMap);
//         }
//         CasePBActionsHandler.afterTriggerHandler(newCases, oldCasesMap);
//     }
    
//     /* 16 Mar 2020
// * Email and Asset creation of 'Visa letter' and 'scheduling permit' for 'Registered' exam registration,EPEx and Regionchange cases.
// */
//     public static void manageSchedulingPermit(List<Case> newCases, Map<Id, Case> oldCasesMap, MAP<ID, Exam_Registration__c> examRegMap){
//         for(Case newCase : newCases){
//             system.debug('Case ID>>>'+newCase.Id);
//             system.debug('Case Status>>>'+newCase.Internal_Status__c);
//             system.debug('Case Rec Type>>>'+newCase.recordType.DeveloperName);
//             system.debug('Sch Perm Hold>>>'+newCase.Scheduling_Permit_Hold__c);
//             system.debug('Case Old Status>>>'+oldCasesMap.get(newCase.Id).Internal_Status__c);
//             if(newCase.Internal_Status__c == Constants.CASE_STATUS_ACCEPTED && oldCasesMap.get(newCase.Id).Internal_Status__c != newCase.Internal_Status__c && (newCase.recordType.DeveloperName == Constants.CASE_RECORD_TYPE_REGION_CHANGE ||newCase.recordType.DeveloperName == Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD)){
//                 ExamRegistrationController.manageSchedulingPermit(newCase.Id);
//             }
//             if(newCase.Internal_Status__c == Constants.CASE_STATUS_REGISTERED && newCase.recordType.DeveloperName == Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION && (oldCasesMap.get(newCase.Id).Internal_Status__c != newCase.Internal_Status__c || oldCasesMap.get(newCase.Id).Scheduling_Permit_Hold__c != newCase.Scheduling_Permit_Hold__c) && newCase.Scheduling_Permit_Hold__c != true){
//                 system.debug('Helper - Inside SECOND If');
//                 ExamRegistrationController.manageSchedulingPermit(newCase.Id);
//             }
//             if(newCase.Internal_Status__c == Constants.CASE_STATUS_REGISTERED && newCase.recordType.DeveloperName == Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION && examRegMap.get(newCase.Id).Visa_Letter_Needed__c && oldCasesMap.get(newCase.Id).Internal_Status__c != newCase.Internal_Status__c){
//                 ExamRegistrationController.manageVisaLetter(newCase.Id);
//             }
//         }
//     }
    
//     /* 21 Feb 2020
// * Get ECFMG Portal Url and update in Case field. This is used for email notification to applicant
// * Update by Reshma Ravi for UserStory 993
// */
//     public static void updatePortalCaseUrl(List<Case> newCases){
//         try{
//             Network myNetwork = [SELECT Id FROM Network WHERE Name =: Constants.COMMUNITY_NAME];
//             String portalUrl = Network.getLoginUrl(myNetwork.Id);
//             portalUrl = portalUrl.substringBefore('login');
//             List<Case> caseToUpdate = new List<Case>();
//             for(Case newCase : newCases){
//                 String caseUrl = portalUrl+'s/case/'+newCase.Id;
//                 caseToUpdate.add(new Case(Id=newCase.Id, ECFMG_Portal_Case_Url__c=caseUrl));
//             }
//             update caseToUpdate;
//         }
//         catch(Exception e){
//             System.debug('Exception caught. '+e.getMessage());
//         }
//     }
    
//     /**
// * Updated by Chinmay on March 31st, 2020
// * Purpose : To update case deficiency reason on rejection of USMLE Transcript case
// */
//     public static void updateDeficiencyReson(List<Case> newCases, Map<Id, Case> oldCasesMap){
//         Id usmleTranscriptCaseRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_USMLE_TRANSCRIPT).getRecordTypeId();
//         for(Case newCase : newCases){
//             if (newCase.recordTypeId == usmleTranscriptCaseRecordtypeId && newCase.Internal_Status__c == Constants.CASE_STATUS_REJECTED){
//                 if(!oldCasesMap.isEmpty() && oldCasesMap.get(newCase.Id).Internal_Status__c != Constants.CASE_STATUS_REJECTED){
//                     newCase.Deficiency_Reason_RTF__c = 'We were unable to process your request.';
//                 }
//                 else if(oldCasesMap.isEmpty()){
//                     newCase.Deficiency_Reason_RTF__c = 'We were unable to process your request.';
//                 }
//             }
//         }
//     }
    
    
    
    
//     /** 06 Apr 2020
// * Created by Femi
// * Method Name: manageExamRegManualReview
// * Purpose : check and update impacted exam reg case(s) needs manual review from Enrollment Verification
// */
//     public static void manageExamRegManualReview(List<Case> newCases, Map<Id, Case> oldCasesMap){
//         for(Case newCase : newCases){
//             if(newCase.Internal_Status__c == Constants.CASE_STATUS_RECEIVED_IN_REVIEW && oldCasesMap.get(newCase.Id).Internal_Status__c != newCase.Internal_Status__c && newCase.recordType.DeveloperName == Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION && newCase.Enrolled_in_Entity_Portal__c == false){
//                 updateFirstTimeExamCases(newCase,Constants.CASE_STATUS_ENROLLMENT_VERIFICATION_RECEIVED, null);
//                 allImpactedEpexCases(newCase,Constants.CASE_STATUS_ENROLLMENT_VERIFICATION_RECEIVED);
//                 Group evQueue =  CaseTriggerUtility.groupMap.get(Constants.CASE_QUEUE_ENROLLMENT_VERIFICATION);
//                 newCase.OwnerId = evQueue.Id;
//                 newCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_REVIEW;
                
//             }
//             if(oldCasesMap.get(newCase.Id).Verification_Status__c != newCase.Verification_Status__c && newCase.Enrolled_in_Entity_Portal__c == true && newCase.recordType.DeveloperName == Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION && newCase.Verification_Status__c != Constants.CASE_VERIFICATION_STATUS_NOT_REVIEWED){
//                 newCase.Internal_Status__c = Constants.CASE_STATUS_RECEIVED_IN_REVIEW;
//                 manageEVFromEntityportal(newCase,oldCasesMap.get(newCase.Id));
                
//             }
//         }
//         try{
//             update newCases;
//         }
//         catch(Exception e){
//             System.debug('Exception caught.'+e.getMessage());
//         } 
//     }
//     /**
// * 06 Apr 2020
// * Created by Femi
// * Method Name: updateFirstTimeExamCases
// * Purpose : check and update impacted first time exam reg case(s) needs manual review 
// */
//     public static void updateFirstTimeExamCases(Case newCase, String newStatus, String reviewReason){
//         List<Case> examRegCases = [SELECT id FROM Case where recordType.DeveloperName =: Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION AND Enrollment_Verification_Parent__c =:newCase.Id AND (Internal_Status__c =: Constants.CASE_STATUS_PENDING_ENROLLMENT OR Internal_Status__c =: Constants.CASE_STATUS_ENROLLMENT_VERIFICATION_INCOMPLETE)];
//         Group evQueue =  CaseTriggerUtility.groupMap.get(Constants.CASE_QUEUE_MANUAL_REVIEW);
//         for(case eRCase :examRegCases){
//             eRCase.Internal_Status__c = newStatus;
//             if(newStatus == Constants.CASE_STATUS_MANUAL_REVIEW_REQUIRED){
//                 eRCase.OwnerId = evQueue.Id;
//                 eRCase.Manual_Review_Reasons__c = reviewReason;
//             } 
//             if(newStatus == Constants.CASE_STATUS_ENROLLMENT_VERIFICATION_RECEIVED){
//                 eRCase.Is_First_time_Exam_Case__c = True;  // to identify first time exam reg case
//             } 
//         }
//         try{
//             update examRegCases;
//         }
//         catch(Exception e){
//             System.debug('Exception caught. '+e.getMessage());
//         }
//     }
//     // check and update impacted follow-up exam reg case(s) needs manual review
//     public static void updateFollowUpExamCases(Case newCase, String newStatus, String reviewReason){
//         List<Case> examRegCases = [SELECT id,(SELECT id, Exam_Status__c, Case__r.Id FROM Exam_Registrations__r) FROM Case where recordType.DeveloperName =: Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION AND Enrollment_Verification_Parent__c =:newCase.Id AND Internal_Status__c !=: Constants.CASE_STATUS_PENDING_ENROLLMENT WITH SECURITY_ENFORCED];
//         Group evQueue =  CaseTriggerUtility.groupMap.get(Constants.CASE_QUEUE_MANUAL_REVIEW);
//         Map<String, Exam_Registration__c> examRegMap = New Map<String, Exam_Registration__c>();
//         for(case eRCase :examRegCases){
//             for(Exam_Registration__c exam : eRCase.Exam_Registrations__r){
//                 examRegMap.put(exam.Case__r.Id, exam);
//             }
//             if(examRegMap.get(eRCase.Id).Exam_Status__c==null){
//                 eRCase.Internal_Status__c = newStatus;
//                 if(newStatus == Constants.CASE_STATUS_MANUAL_REVIEW_REQUIRED){
//                     eRCase.OwnerId = evQueue.Id;
//                     eRCase.Manual_Review_Reasons__c = reviewReason;
//                 }
//             }
//         }
//         try{
//             update examRegCases;
//         }
//         catch(Exception e){
//             throw e;
//         }
//     }
//     // check and update impacted exam reg case(s) and needs manual review
//     public static void allImpactedExamCases(Case newCase, String newStatus){
//         List<Case> examRegCases = [SELECT id,(SELECT id, Exam_Status__c, Case__r.Id FROM Exam_Registrations__r) FROM Case where recordType.DeveloperName =: Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION AND Enrollment_Verification_Parent__c =:newCase.Id WITH SECURITY_ENFORCED];
//         Group evQueue =  CaseTriggerUtility.groupMap.get(Constants.CASE_QUEUE_MANUAL_REVIEW);
//         Map<String, Exam_Registration__c> examRegMap = New Map<String, Exam_Registration__c>();
//         for(case eRCase :examRegCases){
//             for(Exam_Registration__c exam : eRCase.Exam_Registrations__r){
//                 examRegMap.put(exam.Case__r.Id, exam);
//             }
//             if(examRegMap.get(eRCase.Id).Exam_Status__c ==null){
//                 eRCase.Internal_Status__c = newStatus;
//                 if(newStatus == Constants.CASE_STATUS_MANUAL_REVIEW_REQUIRED){
//                     eRCase.OwnerId = evQueue.Id;
//                     eRCase.Manual_Review_Reasons__c = 'Applicant is not enrolled at the medical school.';
//                 }
//             }
//         }
//         try{
//             update examRegCases;
//         }
//         catch(Exception e){
//             throw e;
//         }
//     }
//     /**
// * 15 Apr 2020
// * Created by Femi
// * Method Name: allImpactedEpexCases
// * Purpose : check and update impacted epex case(s) needs manual review 
// */
//     public static void allImpactedEpexCases(Case newCase, String newStatus){
//         List<Case> epexCases = [SELECT id,Internal_Status__c FROM Case where recordType.DeveloperName =: Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD AND Parent.Enrollment_Verification_Parent__c =:newCase.Id AND Parent.recordType.DeveloperName =: Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION AND Internal_Status__c=:Constants.CASE_STATUS_PENDING_ENROLLMENT];
//         for(case eRCase :epexCases){
//             eRCase.Internal_Status__c = newStatus; 
//         }
//         try{
//             update epexCases;
//         }
//         catch(Exception e){
//             System.debug('Exception:'+e.getMessage());
//         }
//     }
//     //Method to check and update impacted exam reg case(s) needs manual review from Enrollment Verification 
//     public static void manageEVFromEntityportal(Case newCase, Case oldCase){
//         if(((newCase.Verification_Status__c != Constants.CASE_VERIFICATION_DECEASED && newCase.Verification_Status__c != Constants.CASE_VERIFICATION_ENROLLED && newCase.Verification_Status__c != null && newCase.Verification_Status__c != Constants.CASE_VERIFICATION_STATUS_GRADUATED)|| newCase.Passed_basic_sciences_course__c==Constants.STATUS_NO)){
//             updateFollowUpExamCases(newCase,Constants.CASE_STATUS_MANUAL_REVIEW_REQUIRED,null); 
//         }
//         Decimal minYears = Decimal.valueOf(System.Label.Minimum_number_of_years_attended);
//         if(newCase.Verification_Status__c == Constants.CASE_VERIFICATION_ENROLLED && newCase.Passed_basic_sciences_course__c==Constants.STATUS_YES && 
//            (oldCase.Attendance_Start_Month__c != newCase.Attendance_Start_Month__c||oldCase.Attendance_Start_Year__c != newCase.Attendance_Start_Year__c || 
//             oldCase.Attendance_End_Month__c != newCase.Attendance_End_Month__c ||oldCase.Attendance_End_Year__c != newCase.Attendance_End_Year__c || 
//             oldCase.Graduation_Month__c != newCase.Graduation_Month__c|| oldCase.Graduation_Year__c != newCase.Graduation_Year__c||
//             oldCase.Degree_Month__c != newCase.Degree_Month__c|| oldCase.Degree_Year__c != newCase.Degree_Year__c|| 
//             (oldCase.Number_of_Years_Attended__c != newCase.Number_of_Years_Attended__c && newCase.Number_of_Years_Attended__c < minYears))){           
//                 String reviewReason = generateManualReviewReason(newCase, oldCase);
//                 updateFollowUpExamCases(newCase,Constants.CASE_STATUS_MANUAL_REVIEW_REQUIRED, reviewReason);
//                 updateFirstTimeExamCases(newCase,Constants.CASE_STATUS_MANUAL_REVIEW_REQUIRED, reviewReason); 
//             } 
//         if(newCase.Verification_Status__c == Constants.CASE_VERIFICATION_DECEASED){
//             allImpactedExamCases(newCase,Constants.CASE_STATUS_MANUAL_REVIEW_REQUIRED);
//             allImpactedEpexCases(newCase,Constants.CASE_STATUS_MANUAL_REVIEW_REQUIRED);
//         }
//     }
    
//     /**
// * @author: Reshma Ravi
// * @name: updateEpexCases
// * @description: Method to update Epex cases to remove from Enrollment Verification
// * @return type: void
// */
//     public static void updateEpexCases(List<Case> newEpexCaseList){
//         List<Case> epexCasesToUpdate = new List<Case>();
//         for(Case newCase :newEpexCaseList){
//             newCase = [SELECT id, Is_Removed_From_EV__c,Enrollment_Verification_Parent__r.Enrolled_in_Entity_Portal__c FROM Case WHERE id =:newCase.id];
//             if(newCase.Enrollment_Verification_Parent__r.Enrolled_in_Entity_Portal__c == true){
//                 newCase.Is_Removed_From_EV__c = TRUE;
//                 epexCasesToUpdate.add(newCase);
//             }
//         }
//         if(!epexCasesToUpdate.isEmpty()){
//             UPDATE epexCasesToUpdate;
//         }
//     }
//     // Method to update Epex cases to remove from Enrollment Verification
//     public static void updateEpexCaseRecords(Map<Id,List<Case>> enrollmentVerCaseMap){
//         for(Case enrollmentVerPar:[SELECT Id,Enrolled_in_Entity_Portal__c FROM Case where Id in:enrollmentVerCaseMap.keySet() AND Enrolled_in_Entity_Portal__c = TRUE]){
//             for(Case newCase:enrollmentVerCaseMap.get(enrollmentVerPar.Id)){
//                 newCase.Is_Removed_From_EV__c = TRUE;
//             }
//         }
//     }
//     /**
// * 06 May 2020
// * @author Femi
// * @name: updateEpexCasesOnManualReview
// * Purpose : check and update impacted epex case(s) after manual review of exam reg case 
// * @return type: void
// */
//     public static void updateEpexCasesOnManualReview(Case newCase, Case oldCase){
//         if(newCase.recordType.DeveloperName == Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION && oldCase.Internal_Status__c == Constants.CASE_STATUS_MANUAL_REVIEW_REQUIRED && (newCase.Internal_Status__c == Constants.CASE_STATUS_ENROLLMENT_NOT_VERIFIED_MEDSCL || newCase.Internal_Status__c == Constants.CASE_STATUS_PENDING_CIBIS) ){
//             List<Case> epexCases = [SELECT id,Internal_Status__c,Is_Removed_From_EV__c FROM Case where recordType.DeveloperName =: Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD AND ParentId =:newCase.Id AND Internal_Status__c=:Constants.CASE_STATUS_PENDING_ENROLLMENT];
//             String newStatus;
//             if(newCase.Internal_Status__c == Constants.CASE_STATUS_ENROLLMENT_NOT_VERIFIED_MEDSCL){
//                 newStatus = Constants.CASE_STATUS_REJECTED;
//             }
//             else{
//                 newStatus = Constants.CASE_STATUS_PENDING_CIBIS;
//             }
//             for(case eRCase :epexCases){
//                 eRCase.Internal_Status__c = newStatus;
//                 eRCase.Is_Removed_From_EV__c = TRUE;
//             }
//             try{
//                 update epexCases;
//             }
//             catch(Exception e){
//                 System.debug('Exception:'+e.getMessage());
//             }
//         }
//     }
//     /**
// * @author: Ajoydhas
// * @methodname: sendMailCaseStatus
// * @description: Method to send mail when the Case Status is Accepted or Rejected
// * @Parameters: caseList
// * @return type: no
// */
//     public static void sendMailCaseStatus(List<Case> caseList, SET<ID> contactIdSet){
//         EmailTemplate emailTemplate = [Select Id, Subject, Description, HtmlValue, DeveloperName, Body from EmailTemplate where DeveloperName =: Constants.CASE_EMAIL_TEMPLATE_NAME];
//         List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
//         List<OrgWideEmailAddress> addr  = [select Id from OrgWideEmailAddress where displayname =: Constants.ORG_WIDE_ADDRESS];
//         MAP<ID, STRING> contactMap = new MAP<ID, STRING>();
//         for(Contact con : [SELECT ID, Name FROM Contact WHERE ID IN: contactIdSet]){
//             contactMap.put(con.ID, con.Name);
//         }
        
//         for(Case caseRecord : caseList){
//             if(caseRecord.ContactEmail != null){
//                 Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
//                 message.setTargetObjectId(caseRecord.ContactId);
//                 message.setTemplateID(emailTemplate.Id);
//                 message.setOrgWideEmailAddressId(addr[0].Id);
//                 String htmlBody = emailTemplate.HtmlValue;
//                 htmlBody = htmlBody.replace('{!Case.Internal_Status__c}', caseRecord.Internal_Status__c);
//                 htmlBody = htmlBody.replace('{!Case.Contact}', contactMap.get(caseRecord.ContactId));
//                 htmlBody = htmlBody.replace('[Link]', '<a href="' + caseRecord.ECFMG_Portal_Case_Url__c + '">Case Status</a>');
//                 htmlBody = htmlBody.replaceAll('<!\\[CDATA\\[', '');
//                 htmlBody = htmlBody.replaceAll('\\]\\]>', '');
//                 message.setHtmlBody(htmlBody);
//                 message.toAddresses = new String[] {
//                     caseRecord.ContactEmail
//                         };
                            
//                             messages.add(message);
//             }            
//         }
//         try{
//             Messaging.sendEmail(messages);
//         }
//         catch(exception e){
//             system.debug('results: e' + e.getMessage());
//         }     
//     }
//     // Method to send mail when the Case Status is Accepted or Rejected
//     public static List<Messaging.SingleEmailMessage> sendCaseStatusMail(List<SendMailWrapper> sendMailWrapperList,Map<Id,Contact> conMap){
//         try{
//             List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
//             for(SendMailWrapper sendMailWrapRec:sendMailWrapperList){
//                 for(Case caseRecord : sendMailWrapRec.caseList){
//                     Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
//                     message = prepareEmail(caseRecord,sendMailWrapRec.addr,sendMailWrapRec.emailTemplate);
//                     PrepareHtmlWrapper prepHtmlWrap = new PrepareHtmlWrapper();
//                     prepHtmlWrap.caseRecord = caseRecord;
//                     prepHtmlWrap.htmlBody = sendMailWrapRec.emailTemplate.HtmlValue;
//                     prepHtmlWrap.con = conMap.get(caseRecord.ContactId);
//                     prepHtmlWrap.message = message;
//                     message = htmlContent(prepHtmlWrap);
//                     messages.add(message);
//                 }
//             }
//             return messages;
//         }
//         catch(Exception ex){
//             throw ex;            
//         }
//     }
//     // Method to build html content
//     public static Messaging.SingleEmailMessage htmlContent(PrepareHtmlWrapper prepHtmlWrap){
//         string htmlBody = prepHtmlWrap.htmlBody;
//         htmlBody = htmlBody.replace('{!Case.Internal_Status__c}',prepHtmlWrap.caseRecord.Internal_Status__c);
//         htmlBody = htmlBody.replace('{!Case.Contact}', prepHtmlWrap.con.Name);
//         htmlBody = htmlBody.replace('{!Case.CaseNumber}', prepHtmlWrap.caseRecord.CaseNumber);
//         htmlBody = htmlBody.replace('[Link]', '<a href="' + prepHtmlWrap.caseRecord.ECFMG_Portal_Case_Url__c + '">Case Status</a>');        
//         htmlBody = htmlBody.replaceAll('<!\\[CDATA\\[', '');
//         htmlBody = htmlBody.replaceAll('\\]\\]>', '');
//         prepHtmlWrap.message.setHtmlBody(htmlBody);
//         return prepHtmlWrap.message;
//     }
//     public static List<string> genUsmleId(){
//         String nextUsmleId = getSequence();
//         List<String> uSMLE_Digits = new List<String>{'0','0','0','0','0','0','0'};
//             Integer length = nextUsmleId.length();
//         for(Integer i=0;i<length;i++){
//             uSMLE_Digits[i] = nextUsmleId.substring(length-i-1,length-i);
//         }
//         Integer n_evenSum = Integer.valueOf(uSMLE_Digits[1]) + Integer.valueOf(uSMLE_Digits[3]) + Integer.valueOf(uSMLE_Digits[5]);
//         Integer n_oddCat = Integer.valueOf(uSMLE_Digits[0] + uSMLE_Digits[2] + uSMLE_Digits[4] + uSMLE_Digits[6])*2;
//         Integer n_oddSum = 0;
//         while(n_oddCat >= 1){
//             n_oddSum = n_oddSum + (Math.Mod(n_oddCat,10));
//             n_oddCat = n_oddCat/10;
//         }
//         Integer valueX = n_oddSum + n_evenSum;
//         Integer n_checkDigit = getCheckDigit(valueX);
//         String n_checkDigitStr = String.valueOf(n_checkDigit).substring(0,1);            
//         if(nextUsmleId.length() < 7){
//             for(Integer i=0; i < 7-nextUsmleId.length();i++){
//                 nextUsmleId ='0'+nextUsmleId;
//             }
//         }
//         String newUsmleId = nextUsmleId + n_checkDigitStr;
//         return new List<string>{newUsmleId,nextUsmleId};
//             }
//     //Generate USMLE Id for contact records which doesnt have USMLE Id UserStory:2134
//     public static void generateUsmleId(Case newCase, Case oldCase){
//         if((newCase.recordType.DeveloperName == Constants.CASE_RECORD_TYPE_APP_FOR_CERT && oldCase.Internal_Status__c != newCase.Internal_Status__c && newCase.Internal_Status__c == Constants.CASE_STATUS_SUBMITTED && newCase.Contact.USMLE_ID__c == null && Label.Disable_New_Case_Trigger == 'True')
//         || (oldCase.Internal_Status__c != newCase.Internal_Status__c && newCase.Internal_Status__c == Constants.CASE_STATUS_SUBMITTED && Label.Disable_New_Case_Trigger == 'False')){           
//             List<string> usmleIds = genUsmleId();
//             List<Contact> contactList = [SELECT id FROM Contact where USMLE_ID__c =:UsmleIds[0] WITH SECURITY_ENFORCED];
//             if(!contactList.isEmpty()){
//                 updateSequence(usmleIds[1]);
//                 usmleIds.clear();
//                 usmleIds = genUsmleId();
//                 if(![SELECT id FROM Contact where USMLE_ID__c =:usmleIds[0] WITH SECURITY_ENFORCED].isEmpty()){
//                     CalloutException e = new CalloutException();
//                     e.setMessage('Error generating New USMLE_ID!');
//                     throw e;
//                 }                
//             }
//             Contact applicant = [SELECT id FROM Contact where id=: newCase.ContactId WITH SECURITY_ENFORCED];            
//             applicant.USMLE_ID__c = usmleIds[0];
//             try{
//                 update applicant; //Do not use CRUD check since logged in user doesn't have access.
//             }
//             catch(Exception e){
//                 System.debug('Exception-'+e.getMessage());
//             }
//             updateSequence(usmleIds[1]);
//         }
//     }
//     /* 18 May 2020
// * @author Femi
// * @name: getCheckDigit
// * Purpose : To get check digit for usmle id generation
// * @return type: Integer
// */
//     public static Integer getCheckDigit(Integer valueX){
//         Integer valueQ = 0;
//         Integer valueZ = 0;
//         Integer valueY = 0;
//         if(valueX < 10){
//             valueQ = 10;
//         }
//         else{
//             valueY = valueX/10;
//             valueZ = Math.mod(valueX, 10);
//             if(valueZ > 0){
//                 valueQ = 10*(valueY+1);
//             }
//             else{
//                 valueQ = 10*valueY;
//             }
//         }
        
//         Integer n_checkDigit = valueQ - valueX;
//         return n_checkDigit;
//     }
//     /* 18 May 2020  
// * @author Femi  
// * @name: updateSequence 
// * Purpose : To update usmle sequence value  
// * @return type: void    
// */    
//     public static void updateSequence(String currentValue){
//         String nextValue = String.valueOf(Integer.valueOf(currentValue) + 1);
//         if(nextValue.length() < 7){
//             for(Integer i=0; i < 7-nextValue.length();i++){
//                 nextValue ='0'+nextValue;
//             }
//         }
//         USMLE_Sequence__c t = USMLE_Sequence__c.getInstance(UserInfo.getOrganizationId());
//         t.Sequence__c = nextValue;
//         update t;
//     }
//     /* @author Reshma   
// * @name: updateIFOMCases    
// * @description : User story 3782 IFOM7: Processing after Receipt of Paper Response from School for IFOM EV Request  
// * @returntype: void 
// * @createddate: 20 May 2020 
// */
//     public static void updateIFOMCases(List<Case> newCases, Map<Id, Case> oldCasesMap){
//         Group evQueue =  CaseTriggerUtility.groupMap.get(Constants.CASE_QUEUE_ENROLLMENT_VERIFICATION);
//         List<Case> newIFOMCaseList = new List<Case>();
        
//         for(Case newCase : newCases){
//             newCase = [SELECT Id, Internal_Status__c, RecordTypeId, OwnerId, Updated_in_NBME_system__c FROM Case wHERE id = :newCase.id];
//             if(newCase != null && newCase.Internal_Status__c != oldCasesMap.get(newCase.Id).Internal_Status__c && oldCasesMap.get(newCase.Id).Internal_Status__c == Constants.CASE_STATUS_ENROLLMENT_VERIFICATION_INCOMPLETE && newCase.Internal_Status__c == Constants.CASE_STATUS_RECEIVED_IN_REVIEW){
//                 newCase.Updated_in_NBME_system__c = false;
//                 newCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_REVIEW;
//                 newcase.OwnerId = evQueue.Id;
//                 newIFOMCaseList.add(newCase);
//             }
//         }
//         if(!newIFOMCaseList.isEmpty()){
//             UPDATE newIFOMCaseList;
//         }
//     }
//     /* 27 May 2020
// * @author Femi
// * @name: getSequence
// * Purpose : To get usmle sequence value
// * @return type: String
// */
//     public static String getSequence(){
//         USMLE_Sequence__c t = USMLE_Sequence__c.getInstance(UserInfo.getOrganizationId());
//         if(t.Sequence__c ==null){
//             USMLE_Sequence__c obj = new USMLE_Sequence__c(Name = 'Sequence');
//             obj.Sequence__c = Constants.USMLE_SEQUENCE_START_VALUE;
//             insert obj;
//             t = USMLE_Sequence__c.getInstance(UserInfo.getOrganizationId());
//         }
//         return t.Sequence__c;
        
//     }
    
//     // US 6111, 5448, 5449 : Method to Check for New Service Form
//     public static void entityContactCheckNewServiceForm(List<Case> newCases, Map<Id, Case> oldCasesMap){
//         List<Service__c> servicesList = getAllServices();
//         Id docConfigIdPIATemplate = EntityServiceRequestSharingDisabled.getPiaTemplateID();
//         Id docConfigIdNewServiceTemplate;
//         if(servicesList.size() <= Constants.PDFBUTLER_NEW_SERVICE_TEMPLATE_FLAG){
//             docConfigIdNewServiceTemplate = EntityServiceRequestSharingDisabled.getNewServiceTemplateID(Constants.PDFBUTLER_NEW_SERVICE_TEMPLATE_1);
//         } 
//         else{
//             docConfigIdNewServiceTemplate = EntityServiceRequestSharingDisabled.getNewServiceTemplateID(Constants.PDFBUTLER_NEW_SERVICE_TEMPLATE_2);
//         }                
//         MAP<Id, Boolean> casePerformanceDataMap = new MAP<Id, Boolean>();
//         casePerformanceDataMap = casePerformanceDataMapCheck(newCases);        
//         for(Case newCase : newCases){
//             if(oldCasesMap.get(newCase.Id).Internal_Status__c != newCase.Internal_Status__c && newCase.Internal_Status__c == Constants.CASE_STATUS_PENDING_NEW_SERVICE){                
//                 if(!casePerformanceDataMap.isEmpty() && casePerformanceDataMap.containsKey(newCase.Id) && casePerformanceDataMap.get(newCase.Id)){
//                     PDFButlerCallout calloutClass = new PDFButlerCallout(docConfigIdPIATemplate,newCase.Id);
//                     System.enqueueJob(calloutClass);
//                     PDFButlerCallout calloutClassNewService = new PDFButlerCallout(docConfigIdNewServiceTemplate, newCase.Id);
//                     System.enqueueJob(calloutClassNewService);                   
//                 } 
//                 else{
//                     PDFButlerCallout calloutClassNewService = new PDFButlerCallout(docConfigIdNewServiceTemplate, newCase.Id);
//                     System.enqueueJob(calloutClassNewService);
//                 }
//             }
//         }
//     }
    
//     // Get List of services
//     public static List<Service__c> getAllServices(){
//         List<Service__c> servicesList = new List<Service__c>([SELECT Id, Name FROM Service__c]);
//         return servicesList;
//     }
    
//     /**
// * @author: Jofrin
// * @methodname: casePerformanceDataMapCheck
// * @description: Method to retrieve case2services 
// * @Parameters: set of case id
// * @return type: MAP<Id, Boolean>
// */
//     public static MAP<Id, Boolean> casePerformanceDataMapCheck(List<Case> newCases){
//         MAP<Id, Boolean> casePerformanceDataMap = new MAP<Id, Boolean>();
//         for(Case2Service__c case2ServiceObj : [SELECT ID, Case__c, Service__c, Service__r.name FROM Case2Service__c 
//                                                WHERE Service__r.name =: Constants.SERVICE_NAME_PERFORMANCE_DATA 
//                                                AND Case__c IN: newCases]){            
//                                                    casePerformanceDataMap.put(case2ServiceObj.Case__c, true);                                                        
//                                                }
//         return casePerformanceDataMap;
//     }
    
//     /**
// * @author: Chinmay Menon
// * @methodname: getEntityPortalUserContactIds
// * @description: Method to retrieve contact ids of all Entity Portal Users
// * @Parameters: none
// * @return type: list<String>
// */
//     public static list<String> getEntityPortalUserContactIds(){
//         List<string> contactIdsToReturn = new List<string>();
//         List<User> existingPortalUsers = new List<User>([SELECT id, Name, Contactid
//                                                          FROM User
//                                                          WHERE user.profile.name= :Constants.Entity_360_USER_PROFILE]);
//         for(User u : existingPortalUsers){
//             contactIdsToReturn.add(u.Contactid);
//         }
//         return contactIdsToReturn;
//     }
    
//     /**
// * @author: Chinmay Menon
// * @methodname: updateEntityUserRequestCaseStatus
// * @description: Method to update Entity User Request Case Status based on conditions
// * @Parameters: List of Entity User Request Case and List of Existing Portal User Contact ids
// * @return type: None
// */
//     public static void updateEntityUserRequestCaseStatus(List<Case> entityUserRequestCaseList){
//         Map<Id, List<Id>> activeEntityServicesMap = getMapOfActiveEntityServices(entityUserRequestCaseList);
//         Map<Id, Service__c> serviceIdServiceMap = new Map<Id, Service__c>([SELECT Id, Name, Signature_Required__c FROM Service__c]);
//         Map<Id, List<Case2Service__c>> caseIdCase2ServiceMap = getMapOfCaseIdCase2Service(entityUserRequestCaseList);
//         List<Account> ecfmgAcceptableEntities = new List<Account>([SELECT Id, Name FROM Account WHERE RecordType.DeveloperName = :Constants.ACCOUNT_RECORD_TYPE_ENTITY AND ECFMG_Acceptable__c = true ]);
//         Map<Id, Asset> entityContactSignatureAssetMap = getMapOfEntityContactSignatureAsset(entityUserRequestCaseList);
//         Boolean updateStatus = false, sendMail = false;
//         List<String> contactIdsToSendMailTo = new List<String>();
//         List<Case> entityUserRequestCaseToUpdateList = new List<Case>();
//         for(Case tempCase : entityUserRequestCaseList){
//             if(tempCase.Internal_Status__c == Constants.CASE_STATUS_DUPLICATE_REVIEW_COMPLETE && tempCase.Source__c == Constants.CASE_SOURCE_PORTAL_USER){
//                 if(existingService(tempCase)){
//                     updateStatus = true;
//                     Case newCaseToUpdate = new Case();
//                     newCaseToUpdate.id = tempCase.id;
//                     newCaseToUpdate.Internal_Status__c = Constants.CASE_STATUS_PENDING_COORDINATOR_APPROVAL;
//                     entityUserRequestCaseToUpdateList.add(newCaseToUpdate);
//                 } 
//                 else{
//                     updateStatus = true;
//                     Case newCaseToUpdate = new Case();
//                     newCaseToUpdate.id = tempCase.id;
//                     newCaseToUpdate = getStatusAndRejectionReasonForNonExistingService(tempCase, serviceIdServiceMap, activeEntityServicesMap, ecfmgAcceptableEntities, caseIdCase2ServiceMap);
//                     entityUserRequestCaseToUpdateList.add(newCaseToUpdate);
//                     if(newCaseToUpdate.Internal_Status__c == Constants.CASE_STATUS_REJECTED){
//                         sendMail = true;
//                         contactIdsToSendMailTo.add(tempCase.contactId);
//                     }
//                 }
//             }
//             if(tempCase.Internal_Status__c == Constants.CASE_STATUS_DUPLICATE_REVIEW_COMPLETE && tempCase.Source__c == Constants.CASE_SOURCE_COORDINATOR){
//                 updateStatus = true;
//                 Case newCaseToUpdate = new Case();
//                 newCaseToUpdate.id = tempCase.id;
//                 newCaseToUpdate = getStatusIfCoordinator(tempCase, serviceIdServiceMap, caseIdCase2ServiceMap, entityContactSignatureAssetMap);
//                 entityUserRequestCaseToUpdateList.add(newCaseToUpdate);
//             }
//         }
        
//         // To avoiding SonarCloud issues calling as seperate method
//         updateEntityUserRequestCaseStatusRefactor(entityUserRequestCaseToUpdateList, updateStatus, sendMail, contactIdsToSendMailTo);
//     }
    
//     /**
// * @author: Chinmay Menon
// * @methodname : getMapOfEntityContactSignatureAsset
// * @description: Method to get Map of all entities which have Assets of type User Signature
// * @Parameters : 1. Entity User Request Case
// * @return type: Map<Id, Asset>
// */
//     public static Map<Id, Asset> getMapOfEntityContactSignatureAsset(List<Case> entityUserRequestCaseList){
//         List<Id> entityUserRequestCaseListContactIds = new List<Id>();
//         for(Case c : entityUserRequestCaseList){
//             entityUserRequestCaseListContactIds.add(c.ContactId);
//         }
        
//         List<Asset> signatureAssets = new List<Asset>([SELECT Id, ContactId FROM Asset WHERE ContactId IN :entityUserRequestCaseListContactIds AND Type__c = :Constants.ASSET_ENTITY_CONTACT_USER_SIGNATURE  AND status != :constants.ASSET_STATUS_MARKED_FOR_DELETION]);
//         Map<Id, Asset> mapToReturn = new Map<Id, Asset>();
//         for(Id conId : entityUserRequestCaseListContactIds){
//             for(Asset signAsset : signatureAssets){
//                 if(signAsset.ContactId == conId && !mapToReturn.containsKey(conId) ){
//                     mapToReturn.put(conId, signAsset);
//                 }
//             }
//         }
//         return mapToReturn;
//     }
//     /**
// * @author: Chinmay Menon
// * @methodname : getStatusIfCoordinator
// * @description: Method to set internal status of case based on whether the requested service is Performance Data or not and set the rejection reason if status is rejected
// * @Parameters : 1. Entity User Request Case
// *               2. Map of service Id with the corresponding service record
// *               3. Map of case Id and corresponding Case2Service records
// * @return type: Case
// */
//     public static Case getStatusIfCoordinator(Case entityUserRequestCase, Map<Id, Service__c> serviceIdServiceMap, Map<Id, List<Case2Service__c>> caseIdCase2ServiceMap, Map<Id, Asset> entityContactSignatureAssetMap){
//         List<Case2Service__c> requestedCase2Services = caseIdCase2ServiceMap.get(entityUserRequestCase.Id);
//         List<Id> requestedServiceIds = new List<Id> ();
        
//         for(Case2Service__c c2a : requestedCase2Services){
//             requestedServiceIds.add(c2a.Service__c);
//         }
        
//         Boolean signatureRequired = false;
        
//         for(Id serviceId : requestedServiceIds){
//             if(serviceIdServiceMap.get(serviceId).Signature_Required__c){
//                 signatureRequired = true;
//                 break;
//             }
//         }
        
//         if(signatureRequired){
//             if(entityContactSignatureAssetMap.containsKey(entityUserRequestCase.ContactId)){
//                 entityUserRequestCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_USER_ACCESS;
//             } 
//             else{
//                 entityUserRequestCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_REVIEW;
//             }
//         } 
//         else{
//             entityUserRequestCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_USER_ACCESS;
//         }
//         return entityUserRequestCase;
//     }
    
//     /**
// * @author: Chinmay Menon
// * @methodname : getStatusAndRejectionReasonForNonExistingService
// * @description: Method to set internal status of case based on whether the requested service is Performance Data or not and set the rejection reason if status is rejected
// * @Parameters : 1. Entity User Request Case
// *               2. Map of service Id with the corresponding service record
// *               3. Map of entities and their active services
// *               4. List of ECFMG Acceptable Entities
// *               5. Map of case Id and corresponding Case2Service record
// * @return type: Case
// */
//     public static Case getStatusAndRejectionReasonForNonExistingService(Case entityUserRequestCase, Map<Id, Service__c> serviceIdServiceMap, Map<Id, List<Id>> activeEntityServicesMap, List<Account> ecfmgAcceptableEntities, Map<Id, List<Case2Service__c>> caseIdCase2ServiceMap){
//         Id performanceDataServiceId = null,
//             enrollmentVerificationServiceId = null,
//             credentialReviewServiceId = null;
        
//         // loop to get ids of services to be compared later
//         for(Service__c s : serviceIdServiceMap.values()){
//             if(s.Name == Constants.SERVICE_NAME_PERFORMANCE_DATA){
//                 performanceDataServiceId = s.id;
//             }
//             if(s.Name == Constants.SERVICE_NAME_ENROLLMENT_VERIFICATION){
//                 enrollmentVerificationServiceId = s.id;
//             }
//             if(s.Name == Constants.SERVICE_NAME_CREDENTIAL_VERIFICATION){
//                 credentialReviewServiceId = s.id;
//             }
//         }
//         if(performanceDataServiceId != null && caseIdCase2ServiceMap.get(entityUserRequestCase.Id)[0].Service__c != performanceDataServiceId){
//             entityUserRequestCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_NEW_SERVICE;
//             return entityUserRequestCase;
//         }
//         List<Id> ecfmgAcceptableEntitiesIdList = new List<Id>();
//         for (Account entity : ecfmgAcceptableEntities){
//             ecfmgAcceptableEntitiesIdList.add(entity.Id);
//         }
//         if(caseIdCase2ServiceMap.get(entityUserRequestCase.Id)[0].Service__c == performanceDataServiceId){
//             entityUserRequestCase.Deficiency_Reason_RTF__c = '';
//             entityUserRequestCase = getStatusAndRejectionReasonForPerformanceDataService(entityUserRequestCase, activeEntityServicesMap, enrollmentVerificationServiceId, credentialReviewServiceId, ecfmgAcceptableEntitiesIdList);
//             return entityUserRequestCase;
//         }
//         // dummy return statement
//         return null;
//     }
    
//     /**
// * @author: Chinmay Menon
// * @methodname : getStatusAndRejectionReasonForPerformanceDataService
// * @description: Method to set internal status of case when the requested service is Performance Data and set the rejection reason if status is rejected
// * @Parameters : 1. Entity User Request Case
// *               2. Map of entities and their active services
// *               3. Record id of Enrollment Verification Service
// *               4. Record id of Credential Review Service
// *               5. List of ECFMG Acceptable Entities
// * @return type: Case
// */
//     public static Case getStatusAndRejectionReasonForPerformanceDataService(Case entityUserRequestCase, Map<Id, List<Id>> activeEntityServicesMap, Id enrollmentVerificationServiceId, Id credentialReviewServiceId, List<Id> ecfmgAcceptableEntitiesIdList){
        
//         Boolean hasEVService,
//             hasCRService,
//             isECFMGAcceptable;
        
//         // check if entity has active enrollment verification service
//         if(activeEntityServicesMap.containsKey(entityUserRequestCase.Entity__c) && activeEntityServicesMap.get(entityUserRequestCase.Entity__c).contains(enrollmentVerificationServiceId)){
//             hasEVService = true;
//         } 
//         else{
//             hasEVService = false;
//             entityUserRequestCase.Deficiency_Reason_RTF__c += 'Not Enrolled in Enrollment Verification<br/>';
//         }
        
//         // check if entity has active Credential Verification service
//         if(activeEntityServicesMap.containsKey(entityUserRequestCase.Entity__c) && activeEntityServicesMap.get(entityUserRequestCase.Entity__c).contains(credentialReviewServiceId)){
//             hasCRService = true;
//         } 
//         else{
//             hasCRService = false;
//             entityUserRequestCase.Deficiency_Reason_RTF__c += 'Not Enrolled in Credential Verification<br/>';
//         }
        
//         // check if entity is ECFMG Acceptable
//         if(ecfmgAcceptableEntitiesIdList.contains(entityUserRequestCase.Entity__c)){
//             isECFMGAcceptable = true;
//         } 
//         else{
//             isECFMGAcceptable = false;
//             entityUserRequestCase.Deficiency_Reason_RTF__c += 'Organization does not meet ECFMG requirements for Performance Data<br/>';
//         }
//         if(hasEVService && hasCRService && isECFMGAcceptable){
//             entityUserRequestCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_NEW_SERVICE;
//             return entityUserRequestCase;
//         } 
//         else{
//             entityUserRequestCase.Internal_Status__c = Constants.CASE_STATUS_REJECTED;
//             return entityUserRequestCase;
//         }
//     }
//     /**
// * @author: Chinmay Menon
// * @methodname : getMapOfCaseIdCase2Service
// * @description: Method to get map of all case2service records for corresponding incoming Entity User Request Cases
// * @Parameters : List of Entity User Request Case
// * @return type: Map<Id, List<Case2Service__c>> - Map of Entity User Request Case id and listg of corresponding case2service record
// */
//     public static Map<Id, List<Case2Service__c>> getMapOfCaseIdCase2Service(List<Case> entityUserRequestCaseList){
//         List<Id> entityUserRequestCaseIdList = new List<Id>();
//         for(Case c : entityUserRequestCaseList){
//             entityUserRequestCaseIdList.add(c.Id);
//         }
        
//         List<Case2Service__c> case2serviceList = new List<Case2Service__c>([SELECT Id, Case__c, Service__c, Service__r.Name, Service__r.Signature_Required__c FROM Case2Service__c WHERE Case__c IN :entityUserRequestCaseIdList]);
        
//         Map<Id, List<Case2Service__c>> caseIdCase2ServiceMap = new Map <Id, List<Case2Service__c>>();
        
//         for(Case c : entityUserRequestCaseList){
//             for(Case2Service__c c2a : case2serviceList){
//                 if(c2a.Case__c == c.Id){
//                     if(caseIdCase2ServiceMap.containsKey(c.Id)){
//                         caseIdCase2ServiceMap.get(c.Id).add(c2a);
//                     } 
//                     else{
//                         caseIdCase2ServiceMap.put(c.Id, new List<Case2Service__c>{c2a});
//                     }
//                 }
//             }
//         }
//         return caseIdCase2ServiceMap;
//     }
    
//     /**
// * @author: Chinmay Menon
// * @methodname : getMapOfActiveEntityServices
// * @description: Method to get map of all active services for entities corresponding to incoming Entity User Request Cases
// * @Parameters : List of Entity User Request Case
// * @return type: Map<Id, List<id>> - Map of entity id and list of corresponding service ids of active services
// */
//     public static Map<Id, List<id>> getMapOfActiveEntityServices(List<Case> entityUserRequestCaseList){
        
//         Map<Id, List<id>> valuesToReturn = new Map<Id, List<id>>();
        
//         Set<Id> entitiesSet = new Set<Id>();
//         // loop to get all entities of incoming cases
//         for(Case tempCase : entityUserRequestCaseList){
//             entitiesSet.add(tempCase.Entity__c);
//         }
        
//         // query to get list of active services from Account2Service__c object
//         List<Account2Service__c> activeServices = new List<Account2Service__c>([SELECT id, Account__c, Service__c
//                                                                                 FROM Account2Service__c
//                                                                                 WHERE Account__c IN :entitiesSet AND
//                                                                                 Active__c = true]);
        
//         // loop to populate map
//         for(Case tempCase : entityUserRequestCaseList){
//             for(Account2Service__c tempA2S : activeServices){
//                 if(tempA2S.Account__c == tempCase.Entity__c){
//                     if(valuesToReturn.keySet().contains(tempCase.Entity__c)){
//                         valuesToReturn.get(tempCase.Entity__c).add(tempA2S.Service__c);
//                     } 
//                     else{
//                         valuesToReturn.put(tempCase.Entity__c, new List<id>{tempA2S.Service__c});
//                     }
//                 }
//             }
//         }
//         return valuesToReturn;
//     }
    
//     /**
// * @author: Chinmay Menon
// * @Modified : Ajoydhas (To solve Sonar Lint Issue)
// * @methodname: updateEntityUserRequestCaseStatus
// * @description: Method to update Entity User Request Case Status based on conditions
// * @Parameters: List of Entity User Request Case and List of Existing Portal User Contact ids
// * @return type: None
// */
//     public static void updateEntityUserRequestCaseStatusRefactor(List<Case> entityUserRequestCaseToUpdateList, Boolean updateStatus, Boolean sendMail, List<String> contactIdsToSendMailTo){
//         try{
//             if(updateStatus){
//                 UPDATE entityUserRequestCaseToUpdateList;
//             }
//         } 
//         catch(exception e){
//             system.debug('updateEntityUserRequestCaseStatus error: '+ e);
//         }
        
//         if(sendMail){
//             sendRequestRejectionMail(entityUserRequestCaseToUpdateList, contactIdsToSendMailTo);
//         }
//     }
    
//     /**
// * @author: Chinmay Menon
// * @methodname: existingService
// * @description: Method to check if the requested service already exists for the associated
// * @Parameters: Entity User Request Case
// * @return type: Boolean
// */
//     public static Boolean existingService(Case entityUserRequestCase){
//         List<Account2Service__c> existingServicesForEntityList = new list<Account2Service__c>([SELECT id FROM Account2Service__c WHERE Account__c = :entityUserRequestCase.AccountId AND Service__c = :entityUserRequestCase.Service_Name__c AND Active__c = true]);
//         return existingServicesForEntityList.size() > 0;
//     }
    
//     /**
// * @author: Chinmay Menon
// * @methodname: sendRequestRejectionMail
// * @description: Method to send rejection mail to entity user request maker
// * @Parameters: 1. List of Entity User Request Case
// *              2. list of String containing mail ids
// * @return type: none
// */
//     public static void sendRequestRejectionMail(List<Case> entityUserRequestCaseToUpdateList, List<String> contactIdsToSendMailTo){
        
//         Map<Id, Case> caseIdCaseMap = new Map<Id, Case>();
//         Map<Id, Contact> contactIdEmailMap = new Map<Id, Contact>([SELECT Email, FirstName, LastName  FROM Contact WHERE Id IN :contactIdsToSendMailTo]);
//         List<OrgWideEmailAddress> addr  = [select Id from OrgWideEmailAddress where displayname =: Constants.ORG_WIDE_ADDRESS];
//         List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
//         for(case c : entityUserRequestCaseToUpdateList){
//             if(c.Internal_Status__c == Constants.CASE_STATUS_REJECTED){
//                 caseIdCaseMap.put(c.Id,c);
//                 Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
//                 if(addr.size() > 0){
//                     mail.setOrgWideEmailAddressId(addr[0].Id);
//                 }
//                 mail.setToAddresses(new String[]{contactIdEmailMap.get(c.contactId).Email});
//                 mail.setSubject('Request Not Accepted');
//                 String combinedReasonsString = c.Deficiency_Reason_RTF__c;
//                 String nameOfContact = contactIdEmailMap.get(c.contactId).FirstName == null ? contactIdEmailMap.get(c.contactId).LastName : contactIdEmailMap.get(c.contactId).FirstName + ' ' + contactIdEmailMap.get(c.contactId).LastName;
//                 String body = '<html><body>Dear '+ nameOfContact +',<br/><br/>Thank you for contacting ECFMG about access to one of our Entity Portal services. We were unable to fulfill your request due to the following reasons<br/>' + combinedReasonsString + '<br/>Please contact us if you have any questions.<br/><br/>Thank you,<br/>ECFMG Staff</body></html>';
//                 mail.setHtmlBody(body);
//                 mails.add(mail);
//             }
//         }
        
//         try{
//             Messaging.sendEmail(mails);
//         } 
//         catch (Exception e){
//             system.debug(e);
//         }
//     }
//     /**
// * @author: Chinmay Menon
// * @methodname: checkIfExistingPortalUserForGivenEntity
// * @description: Method to check if the contact of a given case is an Existing Portal User
// * @Parameters: Entity User Request Case and List of Existing Portal User Contact ids
// * @return type: Boolean
// */
//     public static Boolean checkIfExistingPortalUserForGivenEntity(Case entityUserRequestCase, List<String> existingPortalUserContactIdsList){
        
//         List<contact> entityContactList = new list<contact>([SELECT Id FROM Contact WHERE AccountId = :entityUserRequestCase.AccountId]);
//         List<String> entityContactIdsList = new List<String>();
//         for(Contact con : entityContactList){
//             entityContactIdsList.add(con.Id);
//         }
//         Boolean existingContactUnderEntity = false;
//         Boolean existingPortalUser = false;
//         for(String existingEntityContactId : entityContactIdsList){
//             // condition to check if the id of contact of received case is an existing contact under the given entity
//             if(String.valueOf(entityUserRequestCase.contactId ).equals(existingEntityContactId)){
//                 existingContactUnderEntity = true;
//             }
//         }
//         for(String existingPortalUserContactId : existingPortalUserContactIdsList){
            
//             // condition to check if string value of id of contact of received case is equal to any one of the existing portal user contact id
//             if(String.valueOf(entityUserRequestCase.contactId ).equals(existingPortalUserContactId)){
//                 existingPortalUser = true;
//             }
//         }
//         return existingContactUnderEntity && existingPortalUser;
//     }
    
//     /* 
// * @author: Varsha Hariharan
// * @name: generateMailOnPaperEnrollment
// * Purpose : Method to generate mail on Paper Enrollment Verification Case status change
// * @return type: void
// */
//     public static void generateMailOnPaperEnrollment(List<Case> caseList, Map<Id, Case> oldCaseMap){
//         List<Case> newUpdateCaseList    =   new List<Case>();        
//         SET<ID> contactIdSet            =   new SET<ID>();
//         for(Case newCase : caseList){
//             if(newCase.recordType.DeveloperName == Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION && oldCaseMap.get(newCase.Id).Internal_Status__c != newCase.Internal_Status__c && newCase.Enrolled_in_Entity_Portal__c == false && (newCase.Internal_Status__c == Constants.CASE_STATUS_PENDING_ENROLLMENT || newCase.Internal_Status__c == Constants.CASE_STATUS_ENROLLMENT_VERIFICATION_INCOMPLETE)){
//                 contactIdSet.add(newCase.ContactId);
//                 newUpdateCaseList.add(newCase);
//             }
//         }
//         if(!newUpdateCaseList.isEmpty()){
//             try{        
//                 sendMailCaseStatus(newUpdateCaseList, contactIdSet);  // used existing method to send email                
//             }
//             catch(Exception e){
//                 System.debug('Exception Caught '+e.getMessage());
//             } 
//         }
//     }
    
//     /**
// * Created by Ajoydhas
// * Method Name: getExamRegistrationRefactor
// * Purpose : Get Exam Registration Lists
// */
//     public static Map<Id, Exam_Registration__c> getExamRegistrationRefactor(List<Id> examCaseList){
//         MAP<ID, Exam_Registration__c> examRegMap = new MAP<ID, Exam_Registration__c>();
//         // Exam Registration Object                    
//         List<Exam_Registration__c> examRecords =[SELECT id, Test_Accommodations_needed__c, Visa_Letter_Needed__c, Case__c, EP_start_Date__c, EP_end_Date__c, Exam_Types__c FROM Exam_Registration__c WHERE Case__c IN:examCaseList];
//         for(Exam_Registration__c examRcd: examRecords){
//             examRegMap.put(examRcd.Case__c, examRcd);
//         }
//         return examRegMap;
//     }
//     /**
// * Created by Ajoydhas
// * Method Name: getPendingCibisExamRegCases
// * Purpose : Get Pending Cibis Exam Reg Cases Only
// */
//     public static Map<Id, Case> getPendingCibisExamRegCases(Map<Id, Case> oldCasesMap, List<Case> examCaseList){
//         Map<Id, Case> examRegCaseMap =   new Map<Id, Case>();
//         for(Case newCase : examCaseList){
//             if(newCase.Internal_Status__c == Constants.CASE_STATUS_PENDING_CIBIS){
//                 examRegCaseMap.put(newCase.Id, newCase);
//             }            
//         }
//         return examRegCaseMap;
//     }
//     /**
// * 13 AUG 2020
// * Created by Femi
// * Modified by Ajoydhas (for US 7972)
// * Method Name: managePendingCibisEP
// * Purpose : check and update EP when exam reg changed to pending CIBIS for first time
// */
//     public static void managePendingCibisEP(Map<Id, Case> examRegCaseMap, Map<Id, Case> oldCasesMap, MAP<ID, Exam_Registration__c> examRegMap){
//         List<Id> examCaseIdList =   new List<Id>(examRegCaseMap.keySet());
//         List<Id> historyList = getHistoryList(examCaseIdList); // PendingCibisExamRegCase Id is passing here as parameters        
//         List<Case> pendingCibisCaseList = new List<Case>();
//         for(Case newCase : examRegCaseMap.values()){
//             if(!historyList.contains(newCase.Id)){
//                 pendingCibisCaseList.add(newCase);
//             }
//         }
//         if(!pendingCibisCaseList.isEmpty()){
//             managePendingCibisEPRefactor(pendingCibisCaseList, examRegMap);
//         }
//     }
//     public static void managePendingCibisEPRefactor(List<Case> pendingCibisCaseList, MAP<ID, Exam_Registration__c> examRegMap){
//         Date ePStartDate;
//         Date ePEndDate;
//         Id eligibilityPeriodRecordId;
//         List<Exam_Registration__c> examRegList = new List<Exam_Registration__c>();
//         List<Case> epCaseList = new List<Case>();
//         MAP<String, Eligibility_Period__c> examTypeEPMap = getCurrentEligibilityPeriod(examRegMap);
//         for(Case newCase : pendingCibisCaseList){
//             if(examRegMap.get(newCase.Id).Exam_Types__c == Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE || examRegMap.get(newCase.Id).Exam_Types__c == Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK){
//                 ePStartDate                 =   examTypeEPMap.get(examRegMap.get(newCase.Id).Exam_Types__c).EP_Start_Date__c;
//                 ePEndDate                   =   examTypeEPMap.get(examRegMap.get(newCase.Id).Exam_Types__c).EP_End_Date__c;
//                 eligibilityPeriodRecordId   =   examTypeEPMap.get(examRegMap.get(newCase.Id).Exam_Types__c).Id;
//             } 
//             else{
//                 ePStartDate =   System.today();
//                 ePEndDate   =   ePStartDate.addMonths(12);
//             }
//             if(examRegMap.get(newCase.Id).EP_start_Date__c < ePStartDate && ePStartDate != null){
//                 Exam_Registration__c examreg = new Exam_Registration__c();
//                 examreg.Id = examRegMap.get(newCase.Id).Id;
//                 examreg.EP_start_Date__c = ePStartDate;
//                 examreg.EP_end_Date__c = ePEndDate;
//                 examRegList.add(examreg);
//                 // Get record id from Eligibility_Period__c object and updating Eligibility_Period__c lookup field in Case Object  
//                 if(eligibilityPeriodRecordId != null){
//                     Case caseEPObj = new Case();
//                     caseEPObj.Id = newCase.Id;
//                     caseEPObj.Eligibility_Period__c = eligibilityPeriodRecordId;
//                     epCaseList.add(caseEPObj);
//                 }                    
//             }                       
//         }
//         // Update Caselist for Eligibility_Period__c Lookup field in Case Object
//         updateExamRegistrationRefactor(examRegList);   
//         // Update Caselist for Eligibility_Period__c Lookup field in Case Object
//         updateCaseEligibilityPeriodRefactor(epCaseList);   
//     }    
//     /**
// * Created by Ajoydhas
// * Method Name: updateExamRegistrationRefactor
// * Purpose : Update Exam Registration for EP Start Date & End Date in Exam_Registration__c Object (US 7972)
// * Parameters: examRegList
// * return type: no
// */
//     public static void updateExamRegistrationRefactor(List<Exam_Registration__c> examRegList){
//         if(!examRegList.isEmpty()){
//             try{
//                 update examRegList;
//             }
//             catch(Exception e){
//                 System.debug('Exception caught.'+e.getMessage());
//             } 
//         }
//     }
//     /**
// * Created by Ajoydhas
// * Method Name: updateCaseEligibilityPeriodRefactor
// * Purpose : Update Caselist for Eligibility_Period__c Lookup field in Case Object (US 7972)
// * Parameters: CaseList
// * return type: no
// */
//     public static void updateCaseEligibilityPeriodRefactor(List<Case> epCaseList){
//         if(!epCaseList.isEmpty()){
//             try{
//                 update epCaseList;
//             }
//             catch(Exception e){
//                 System.debug('Exception epCaseList caught.'+e.getMessage());
//             } 
//         }
//     }
//     /**
// * Created by Ajoydhas
// * Method Name: getEligibilityPeriod
// * Purpose : get EP start date for the current date (US 7972)
// * Parameters: examRegMap
// * return type: MAP<String, Eligibility_Period__c>
// */
//     public static MAP<String, Eligibility_Period__c> getCurrentEligibilityPeriod(MAP<ID, Exam_Registration__c> examRegMap){
//         MAP<String, Eligibility_Period__c> examTypeEPMap = new MAP<String, Eligibility_Period__c>();
//         for(Exam_Registration__c examReg : examRegMap.values()){
//             if(examReg.Exam_Types__c == Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE || examReg.Exam_Types__c == Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK){
//                 Eligibility_Period__c epObj = getEligibilityPeriodRefactor(examReg.Exam_Types__c);
//                 examTypeEPMap.put(examReg.Exam_Types__c, epObj);                
//             }
//         }
//         return examTypeEPMap;
//     }
//     /**
// * Created by Ajoydhas
// * Method Name: getEligibilityPeriodRefactor
// * Purpose : get EP start date for the current date (this method is created to avoid sonarcloud issue) (US 7972)
// * Parameters: examType
// * return type: Eligibility_Period__c
// */
//     public static Eligibility_Period__c getEligibilityPeriodRefactor(String examType){
//         Date today              =   Constants.TODAY_DATE;
//         Integer currentMonth    =   today.month();
//         Integer currentYear     =   today.year();
//         Eligibility_Period__c epObj = new Eligibility_Period__c();
//         List<Eligibility_Period__c> eligibilityPeriodList = new List<Eligibility_Period__c>();
//         // Get Eligibility_Period__c record by examtype, currentMonth and currentYear
//         eligibilityPeriodList       =   getEligibilityPeriodFromObject(examType, currentMonth, currentYear);
//         if(!eligibilityPeriodList.isEmpty()){
//             Date deadLineDate           =   eligibilityPeriodList[0].Deadline_Date__c;
//             if(today <= deadLineDate){
//                 epObj = eligibilityPeriodList[0];
//             } 
//             else{
//                 Date nextMonthToday     =   today.addMonths(1);
//                 Integer nextMonth       =   nextMonthToday.month();
//                 Integer nextMonthYear   =   nextMonthToday.year();
//                 // Get Eligibility_Period__c record by examtype, currentMonth and currentYear
//                 eligibilityPeriodList   =   getEligibilityPeriodFromObject(examType, nextMonth, nextMonthYear);
//                 if(!eligibilityPeriodList.isEmpty()){
//                     epObj               =   eligibilityPeriodList[0];        
//                 }
//             }
//         }        
//         return epObj;        
//     }
//     /**
// * Created by Ajoydhas
// * Method Name: getEligibilityPeriodFromObject
// * Purpose : get EP start date for the current date (this method is created to avoid sonarcloud issue)  (US 7972)
// * Parameters: examType, currentMonth, currentYear
// * return type: List<Eligibility_Period__c>
// */
//     public static List<Eligibility_Period__c> getEligibilityPeriodFromObject(String examType, Integer currentMonth, Integer currentYear){
//         List<Eligibility_Period__c> eligibilityPeriodList = new List<Eligibility_Period__c>();
        
//         eligibilityPeriodList = [SELECT Id, Deadline_Date__c, EP_Start_Date__c,  EP_End_Date__c, Exam_Type__c, Active__c 
//                                  FROM Eligibility_Period__c 
//                                  WHERE Active__c = 'Y' 
//                                  AND Exam_Type__c = :examType
//                                  AND CALENDAR_MONTH(EP_Start_Date__c) = :currentMonth
//                                  AND CALENDAR_YEAR(EP_Start_Date__c) = :currentYear
//                                  AND Extension_Flag__c = 'N'];
//         return eligibilityPeriodList;
//     }
//     /**
// * 14 AUG 2020
// * Created by Femi
// * Method Name: getHistoryList
// * Purpose : get list of case with had registered status previously
// */
//     public static List<Id> getHistoryList(List<Id> examCaseList){
//         List<Id> historyList = new List<Id>();
//         List<CaseHistory> caseHistoryList = [SELECT CaseId, Field, NewValue, OldValue FROM CaseHistory WHERE field = 'Status' AND caseId IN:examCaseList];
//         for(CaseHistory caseHistory: caseHistoryList){
//             if(caseHistory.NewValue == Constants.CASE_STATUS_REGISTERED || caseHistory.OldValue == Constants.CASE_STATUS_REGISTERED){
//                 historyList.add(caseHistory.CaseId);
//             }
//         }
//         return historyList;
//     }
    
//     /* 
// * @author: Reshma
// * @name: updateEpexCasesForEV
// * @description: US 5955 - Update EPEx case for electronic and paper enrollment verification
// * @return type: void
// * @param: List of EPEx cases
// */
//     public static void updateEpexCasesForEV(List<Case> epexCases){
//         List<Contact_Association_Type__c> catRecord = new List<Contact_Association_Type__c>();
//         Set<Id> contactIds = new Set<Id>();
//         Set<Id> accountIds = new Set<Id>();
//         Set<Id> account2ServiceSet = new Set<Id>();
//         Map<Id, Case> caseMap = new Map<Id, Case>();
//         Map<Id, Id> examEVMap = new Map<Id, Id>();
//         Id evRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION).getRecordTypeId();
//         Group evQueue = CaseTriggerUtility.groupMap.get(Constants.CASE_QUEUE_ENROLLMENT_VERIFICATION);        
//         List<Case> newEpexCases = [SELECT Id, ParentId, ContactId, AccountId, Enrollment_Verification_Parent__c, Parent.Enrollment_Verification_Parent__c FROM Case WHERE Id =:epexCases];                
//         for(Case newCase : newEpexCases){
//             contactIds.add(newCase.ContactId);  
//             catRecord.add(CaseTriggerUtility.catMap.get(newCase.ContactId));
//             accountIds.add(catRecord[0].Account__c);
//             examEVMap.put(newCase.ParentId, newCase.Parent.Enrollment_Verification_Parent__c);
//         }       
//         for(Account2Service__c a2s : [SELECT Id, Account__c FROM Account2Service__c WHERE Account__c IN :accountIds AND Active__c = True]){
//             account2ServiceSet.add(a2s.Account__c);
//         }        
//         Map<Id, Case> evCases = new Map<Id, Case>([SELECT Id, Internal_Status__c, OwnerId, ContactId, AccountId, Enrolled_in_Entity_Portal__c, Account.IsCustomerPortal
//                                                    FROM Case
//                                                    WHERE RecordTypeId =: evRTId AND ContactId IN :contactIds AND AccountId IN :accountIds AND Id IN :examEVMap.values()]);
//         for(Case newCase : newEpexCases){
//             if(examEVMap.containsKey(newCase.ParentId) && evCases.containsKey(examEVMap.get(newCase.ParentId))){
//                 Case evCase = evCases.get(examEVMap.get(newCase.ParentId));
//                 if(newCase.ContactId == evCase.ContactId && catRecord[0].Account__c == evCase.AccountId && account2ServiceSet.contains(evCase.AccountId)){
//                     newCase.Enrollment_Verification_Parent__c = evCase.Id;
//                     caseMap.put(newCase.Id, newCase);                    
//                     Case evCaseToUpdate = new Case();
//                     evCaseToUpdate.Id = evCase.Id;
//                     evCaseToUpdate.Internal_Status__c = Constants.CASE_STATUS_NEW;
//                     evCaseToUpdate.Enrolled_in_Entity_Portal__c = account2ServiceSet.contains(evCase.AccountId);
//                     caseMap.put(evCaseToUpdate.Id, evCaseToUpdate);
//                 }
//                 if(!account2ServiceSet.contains(evCase.AccountId)){
//                     createEVCaseForEpex(newCase, evQueue.Id, catRecord[0], evRTId);
//                 }
//             }
//             else{
//                 if(!catRecord.isEmpty()){
//                     createEVCaseForEpex(newCase, evQueue.Id, catRecord[0], evRTId);
//                 }
//             }
//         }
//         if(!caseMap.isEmpty()){
//             UPDATE caseMap.values();
//             reUpdateEVCaseForEpex(caseMap.values());
//         }
//     }
    
//     /* 
// * @author: Reshma
// * @name: reUpdateEVCaseForEpex
// * @description: Update verification status and status of EV
// * @return type: void
// * @param: List of EV cases
// */
//     public static void reUpdateEVCaseForEpex(List<Case> evCases){
//         Id evRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION).getRecordTypeId();
//         List<Case> evCaseToUpdate = new List<Case>();
//         for(Case evCase : [SELECT Id, Internal_Status__c, External_Status__c, Verification_Status__c, Status_Not_Reviewed_Date__c FROM Case WHERE Id IN :evCases AND RecordTypeId =:evRTId]){
//             evCase.External_Status__c = Constants.CASE_EXTERNAL_STATUS_NOT_REVIEWED;
//             evCase.Status_Not_Reviewed_Date__c = System.today();
//             evCase.Verification_Status__c = Constants.CASE_VERIFICATION_STATUS_NOT_REVIEWED;
//             evCase.Internal_Status__c = Constants.CASE_STATUS_POSTED_TO_ENTITY_PORTAL;
//             evCaseToUpdate.add(evCase);
//         }
//         if(!evCaseToUpdate.isEmpty()){
//             UPDATE evCaseToUpdate;
//         }
//     }
    
//     /* 
// * @author: Reshma
// * @name: createEVCaseForEpex
// * @description: US 5955 - Create paper enrollment verification for EPEx
// * @return type: void
// * @param: EPEx case, EV queueId, Contact_Association_Type__c record, EV record type id
// */
//     public static void createEVCaseForEpex(Case epexCase, String queueId, Contact_Association_Type__c catRecord, String evRTId){
//         Case caseObj = new Case();
//         caseObj.ContactId                    =   epexCase.ContactId;                
//         caseObj.RecordTypeId                 =   evRTId;
//         caseObj.Internal_Status__c           =   Constants.CASE_STATUS_NEW;
//         caseObj.OwnerId                      =   queueId;
//         caseObj.AccountId                    =   catRecord.Account__c;
//         caseObj.Enrolled_in_Entity_Portal__c =   False;
//         caseObj.School_Program__c            =   catRecord.School_Program__c;
//         caseObj.Attendance_Start_Date__c     =   catRecord.Start_Date__c;
//         caseObj.Attendance_End_Date__c       =   catRecord.End_Date__c;
//         //code added by Shailaja. DateFormat stories.
//         caseObj.Attendance_Start_Month__c     =   catRecord.Start_Month__c;
//         caseObj.Attendance_Start_Year__c     =   catRecord.Start_Year__c;
//         caseObj.Attendance_End_Month__c       =   catRecord.End_Month__c;
//         caseObj.Attendance_End_Year__c       =   catRecord.End_Year__c;
//         caseObj.Graduation_Month__c          =   catRecord.Graduation_Month__c;
//         caseObj.Graduation_Year__c           =   catRecord.Graduation_Year__c;
//         caseObj.Degree_Date__c               =   catRecord.Degree_Issue_Date__c;
//         //code added by Shailaja. DateFormat stories.
//         caseObj.Degree_Month__c               =   catRecord.Degree_Issue_Month__c;
//         caseObj.Degree_Year__c               =   catRecord.Degree_Issue_Year__c;
//         caseObj.Number_of_Years_Attended__c  =   catRecord.Number_of_Years_Attended__c;
//         caseObj.Unique_Medical_School__c     =   catRecord.Student_ID__c;
//         INSERT caseObj;
//         caseObj.Internal_Status__c           =   Constants.CASE_STATUS_PENDING_ENROLLMENT;
//         UPDATE caseObj;
//         epexCase.Enrollment_Verification_Parent__c = caseObj.Id;
//         UPDATE epexCase;
//     }
//     /**
// * 17 AUG 2020
// * Created by Femi
// * Method Name: generateManualReviewReason
// * Purpose : update ManualReviewReason for manual review of exam registration cases
// */
//     public static String generateManualReviewReason(Case newCase, Case oldCase){
//         String reviewReason = '';
//         if((oldCase.Attendance_Start_Month__c != newCase.Attendance_Start_Month__c)||(oldCase.Attendance_Start_Year__c != newCase.Attendance_Start_Year__c)){
//             reviewReason = 'Attendance Start Date was updated.';
//         }
//         if((oldCase.Attendance_End_Month__c != newCase.Attendance_End_Month__c )||(oldCase.Attendance_End_Year__c != newCase.Attendance_End_Year__c )){
//             if(reviewReason != ''){
//                 reviewReason = reviewReason+'<br/>';
//             }
//             reviewReason = reviewReason+'Attendance End Date was updated.';
//         }
//         if(oldCase.Graduation_Month__c != newCase.Graduation_Month__c || oldCase.Graduation_Year__c != newCase.Graduation_Year__c){
//             if(reviewReason != ''){
//                 reviewReason = reviewReason+'<br/>';
//             }
//             reviewReason = reviewReason+'Graduation Date was updated.';
//         }
//         if((oldCase.Degree_Month__c != newCase.Degree_Month__c)|| (oldCase.Degree_Year__c != newCase.Degree_Year__c)){ 
//             if(reviewReason != ''){
//                 reviewReason = reviewReason+'<br/>';
//             }
//             reviewReason = reviewReason+'Degree Issue Date was updated.';
//         }
//         if(oldCase.Number_of_Years_Attended__c != newCase.Number_of_Years_Attended__c && newCase.Number_of_Years_Attended__c < 1.5){
//             if(reviewReason != ''){
//                 reviewReason = reviewReason+'<br/>';
//             }
//             reviewReason = reviewReason+'Number of Years Attended was updated and is now less than 18 months.';
//         }
//         return reviewReason;
//     }
//     //update all related assets of appforcert case to rejected/cancelled/expired when the case is rejected/cancelled/expired
//     public static void updateAppforcertAssets(List<Id> caseIds, String assetStatus){
//         if(Asset.SObjectType.getDescribe().isAccessible() && !caseIds.isEmpty()){
//             List<Asset> assetList = new List<Asset>();
//             assetList = [SELECT Id, Status FROM Asset WHERE case__c IN: caseIds AND Status !=: Constants.ASSET_STATUS_REJECTED AND Status !=: Constants.ASSET_STATUS_CANCELLED AND Status !=: Constants.ASSET_STATUS_EXPIRED];
//             for(Asset asset:assetList){
//                 asset.status = assetStatus;
//             }
//             if(!assetList.isEmpty() && Asset.SObjectType.getDescribe().isUpdateable()){
//                 update assetList;
//             }
//         }
//     }
//     // Send an email to the Applicant when the ECFMG Certification case has been marked as "Sent"
//     public static void sendMailEcfmgCertIssued(List<Case> newCases, Map<Id, Case> oldCasesMap){
//         EmailTemplate emailTemplate = [Select Id, Subject, Description, HtmlValue, DeveloperName, Body from EmailTemplate where DeveloperName =: Constants.EMAIL_TEMPLATE_ECFMG_CERTIFICATE]; //Donot add WITH SECURITY_ENFORCED 
//         List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
//         List<OrgWideEmailAddress> addr = [select Id from OrgWideEmailAddress where displayname =: Constants.ORG_WIDE_ADDRESS]; //Donot add WITH SECURITY_ENFORCED
//         Id ecfmgCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ECFMG_Certification).getRecordTypeId();        
//         List<Case> ecfmgCertCaseLists = new List<Case>();
//         for(Case newCase : newCases){            
//             if(newCase.RecordTypeId == ecfmgCertRecordTypeId && newCase.Internal_Status__c != oldCasesMap.get(newCase.Id).Internal_Status__c && newCase.Internal_Status__c == Constants.CASE_STATUS_SENT){
//                 ecfmgCertCaseLists.add(newCase);
//             }
//         }
//         if(!ecfmgCertCaseLists.isEmpty()){
//             for(Case caseRecord : ecfmgCertCaseLists){
//                 if(caseRecord.ContactEmail != null){
//                     Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
//                     message.setTargetObjectId(caseRecord.ContactId);
//                     message.setTemplateID(emailTemplate.Id);
//                     message.setOrgWideEmailAddressId(addr[0].Id);
//                     String htmlBody = emailTemplate.Body;
//                     message.setPlainTextBody(htmlBody);
//                     message.toAddresses = new String[]{
//                         caseRecord.ContactEmail
//                             };
//                                 messages.add(message);
//                 }            
//             }
//             try{
//                 if(!messages.isEmpty()){
//                     Messaging.sendEmail(messages);
//                 }
//             }
//             catch(exception e){               
//                 saveLogMessage(e.getMessage());
//             }
//         }     
//     }
//     // To avoiding cognitive complexity issues  - calling as seperate method
//     public static void saveLogMessage(String getMessage){
//         if(Schema.sObjectType.Log_Message__c.isCreateable()){
//             Log_Message__c logMsg = new Log_Message__c();
//             logMsg.Exception__c = 'Unhandled Exception while sending update mailing address email:'+getMessage;
//             logMsg.Date_Time_Logged__c = DateTime.now();
//             INSERT logMsg;
//         }
//     }
//     // method to prepare email
//     public static Messaging.SingleEmailMessage prepareEmail(Case caseRec,OrgWideEmailAddress addr,EmailTemplate emailTemplate){
//         try{
//             Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
//             message.setTargetObjectId(caseRec.ContactId);
//             message.setTemplateID(emailTemplate.Id);
//             message.setOrgWideEmailAddressId(addr.Id);
//             message.setSubject(emailTemplate.Subject);
//             message.toAddresses = new String[]{caseRec.ContactEmail};
//                 return message;
//         }
//         catch(Exception ex){
//             throw ex;
//         }
//     }
//     //Method to update Parent ECFMG Cert case based on Child records values
//     public static void updateParentCertCase(List<Case> newCases, Map<Id, Case> oldCasesMap){
//         Set<Id> caseListToParentVal = new Set<Id>();
//         Id credVerRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
//         Id nameRevRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_NAME_REVIEW).getRecordTypeId();
//         // Include DOB Review cases as part of US 20411
//         Id dobRevRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_BIOGRAPHIC_REVIEW).getRecordTypeId();
//         Id ecfmgCertRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ECFMG_CERTIFICATION).getRecordTypeId();
//         for(Case newCase : newCases){
//             if(((newCase.RecordTypeId == credVerRTId) || (newCase.RecordTypeId == nameRevRTId) || (newCase.RecordTypeId == dobRevRTId)) && newCase.Internal_Status__c != oldCasesMap.get(newCase.Id).Internal_Status__c && newCase.Internal_Status__c == Constants.CASE_STATUS_ACCEPTED){
//                 caseListToParentVal.add(newCase.ParentId);
//             }
//         }
//         if(!caseListToParentVal.isEmpty()){
//             caseListToParentVal.remove(null);
//             List<Case> caseList = new List<Case>();
//             caseList = [Select Id, Internal_Status__c, ParentId from Case where ParentId IN : caseListToParentVal AND (RecordTypeId =: credVerRTId OR RecordTypeId=: nameRevRTId OR RecordTypeId=: dobRevRTId ) AND (Parent.Internal_Status__c =: Constants.CASE_STATUS OR Parent.Internal_Status__c =: Constants.CASE_STATUS_RECEIVED_IN_REVIEW) AND Parent.RecordTypeId =: ecfmgCertRTId WITH SECURITY_ENFORCED];
//             updateParentCaseRefactor(caseList);
//         }
//     }
//     public static void updateParentCaseRefactor(List<Case> caseList){
//         Map<Id, List<Case>> caseMap = new Map<Id, List<Case>>();
//         for(Case loopVar : caseList){
//             if(caseMap.containsKey(loopVar.ParentId)){
//                 List<Case> caseVal = new List<Case>();
//                 caseVal = caseMap.get(loopVar.ParentId);
//                 caseVal.add(loopVar);
//                 caseMap.put(loopVar.ParentId, caseVal);
//             }
//             else{
//                 List<Case> caseValList = new List<Case>();
//                 caseValList.add(loopVar);
//                 caseMap.put(loopVar.ParentId, caseValList);
//             }
//         }
//         callValidation(caseMap);        
//     }
//     public static void callValidation(Map<Id, List<Case>> caseMap){
//         List<Id> caseIdToUpdate = new List<Id>();
//         for(Id idVal : caseMap.keySet()){
//             Boolean allCaseAccepted = false;
//             for(Case loopVariable : caseMap.get(idVal)){
//                 if(loopVariable.Internal_Status__c != Constants.CASE_STATUS_ACCEPTED){
//                     allCaseAccepted = false;
//                     break;
//                 }
//                 else{
//                     allCaseAccepted = true;
//                 }
//             }
//             if(allCaseAccepted){
//                 caseIdToUpdate.add(idVal);
//             }
//         }
//         caseParentRefactor(caseIdToUpdate);
//     }
//     public static void caseParentRefactor(List<Id> caseIdToUpdate){
//         List<Case> updateCaseList = new List<Case>();
//         if(!caseIdToUpdate.isEmpty()){
//             Group grp = CaseTriggerUtility.groupMap.get(Constants.CASE_QUEUE_ECFMG_CERTIFICATION);
//             for(Integer count = 0; count < caseIdToUpdate.size(); count++){
//                 Case updateCase = new Case();
//                 updateCase.Id = caseIdToUpdate[count];
//                 updateCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_REVIEW;
//                 updateCase.OwnerId = grp.Id;
//                 updateCaseList.add(updateCase);
//             }
//         }
//         if(!updateCaseList.isEmpty() && Schema.sObjectType.Case.isUpdateable()){
//             update updateCaseList;
//         }
//     }
//     // US 11136 & US 16089-To check if Send method is changed to Entity Portal without changing the Entity/Alternate Entity, then Entity's Account2Service should be active else throw error.
//     public static void caseCheckEntity(List<case> newCase,map<id,case> oldCase){
//         map<Id,List<case>> entityIdCase = new map<Id,List<case>>();
//         set<Id> entityIds = new set<Id>();
//         set<Id> allEntityId = new set<Id>();
//         set<Id> aleternateAccCaseIds = new set<Id>();
//         try{
//             aleternateAccCaseIds.addAll(getAltCaseIds(newCase));                      
//             entityIdCase.putAll(mapsEntityCasetocheck(newCase,oldCase,aleternateAccCaseIds));
//             allEntityId.addAll(entityIdCase.keyset());
//             if(!allEntityId.isEmpty() && Account2Service__c.SObjectType.getDescribe().isAccessible()){
//                 for(Account2Service__c accSer : [SELECT Account__r.Id,Active__c FROM Account2Service__c WHERE Account__c in: allEntityId AND Service__r.Name=:Constants.SERVICE_NAME_CREDENTIAL_VERIFICATION AND Active__c=true WITH SECURITY_ENFORCED]){
//                     entityIds.add(accSer.Account__r.Id);
//                 }
//             }
//             // Removes the Entity having Account2Service which is Active and its service is Credential Verification. 
//             allEntityId.removeAll(entityIds);
//             string errorMsg = [SELECT Error_Message__c FROM Error_Message__mdt WHERE DeveloperName=:Constants.ERROR_SEND_METHOD_ENTITY LIMIT 1].Error_Message__c;
//             for(Id entityId:allEntityId){
//                 for(Case errorCase:entityIdCase.get(entityId)){
//                     errorCase.addError(errorMsg);
//                 }
//             }
//         }
//         catch(Exception ex){
//             throw ex;
//         }
//     }
//     // US 11136 & US 16089- maps the entity/alternate entity and cases that has to be checked for entity portal 
//     public static map<Id,List<case>> mapsEntityCasetocheck(List<case> newCase,map<id,case> oldCase,set<Id> aleternateAccCaseIds){
//         map<Id,List<case>> entityIdCase = new map<Id,List<case>>();
//         for(Case cs : newCase){
//             if(cs.Entity__c == (oldCase.get(cs.Id)).Entity__c
//                && cs.Alternate_Entity__c == (oldCase.get(cs.Id)).Alternate_Entity__c
//                && cs.Send_Method__c != (oldCase.get(cs.Id)).Send_Method__c
//                && cs.Send_Method__c == Constants.CASE_SEND_METHOD_ENTITY_PORTAL){
//                    Id entityId = cs.Entity__c; 
//                    if(aleternateAccCaseIds.contains(cs.Id)){
//                        entityId = cs.Alternate_Entity__c;
//                    }
//                    List<Case> caseList = new List<case>();
//                    if(entityIdCase.containsKey(entityId)){
//                        caseList.addAll(entityIdCase.get(entityId));
//                    }
//                    caseList.add(cs);
//                    entityIdCase.put(entityId,caseList);                   
//                }
//         }
//         return entityIdCase;
//     }
//     // Changes the List to Map and calls formatGetAltCaseIds
//     public static Set<Id> getAltCaseIds(List<case> newCase){
//         Set<Id> altCaseIds = new Set<Id>();
//         for(Case caseRecord : newCase){
//             if(caseRecord.Alternate_Entity__c != null){
//                 altCaseIds.add(caseRecord.Id);
//             }
//         }
//         return formatGetAltCaseIds(altCaseIds);
//     }
//     // gets case Id which are marked as verify with alternate entity
//     public static Set<Id> formatGetAltCaseIds(Set<Id> caseIds){
//         Set<Id> aleternateAccCaseIds = new Set<Id>();
//         if(Affirmation__c.SObjectType.getDescribe().isAccessible() && !caseIds.isEmpty()){
//             List<Affirmation__c> affirmationList = [SELECT Id,Verify_with_Alternate_Entity__c,Case__r.Id FROM Affirmation__c WHERE Case__r.Id IN: caseIds AND RecordType.DeveloperName =: Constants.AFFIRMATION_RECORD_TYPE_CREDENTIAL_VERIFICATION AND Verify_with_Alternate_Entity__c = true WITH SECURITY_ENFORCED];
//             for(Affirmation__c affirmation : affirmationList){
//                 aleternateAccCaseIds.add(affirmation.case__r.Id);
//             }
//         }
//         return aleternateAccCaseIds;
//     }
//     public static set<Id> getMedAltCaseIds(List<case> newCase){
//         set<Id> aleternateAccCaseIds = new set<Id>();
//         if(Affirmation__c.SObjectType.getDescribe().isAccessible() && !newCase.isEmpty()){
//             for(Affirmation__c affirmation : [SELECT Id,Verify_with_Alternate_Entity__c,Case__r.Id FROM Affirmation__c WHERE Case__r.Id in:newCase AND RecordType.DeveloperName=:Constants.AFFIRMATION_RECORD_TYPE_MED_EDU_FORM AND Verify_with_Alternate_Entity__c=true WITH SECURITY_ENFORCED]){
//                 aleternateAccCaseIds.add(affirmation.case__r.Id);
//             }
//         }
//         return aleternateAccCaseIds;
//     }
//     // US 13410 - To update assets under VP of credential verification case records when its accepted
//     public static void updateAssetOfVP(List<Case> newCases, Map<Id, Case> oldCasesMap){
//         try{
//             Id cvCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
//             Set<Id> caseIdSet = new Set<Id>();  
//             if(!oldCasesMap.isEmpty() && Case.SObjectType.getDescribe().isAccessible()){   
//                 newCases = [SELECT Id, Internal_Status__c, RecordTypeId FROM Case WHERE Id IN: oldCasesMap.keySet() AND RecordTypeId =: cvCaseRecordTypeId AND Internal_Status__c =: constants.CASE_STATUS_CV_ACCEPTED AND Send_Method__c =: constants.SEND_METHOD_WEBSITE WITH SECURITY_ENFORCED];
//                 for(Case cse: newCases){
//                     if(oldCasesMap.containsKey(cse.Id) && cse.Internal_Status__c != oldCasesMap.get(cse.Id).Internal_Status__c){
//                         caseIdSet.add(cse.Id);
//                     }
//                 }
//                 if(!caseIdSet.isEmpty() && Verification_Packet__c.SObjectType.getDescribe().isAccessible()){
//                     Map<Id, Verification_Packet__c> vpMap = new Map<Id, Verification_Packet__c>([SELECT Id FROM Verification_Packet__c WHERE Case__c IN: caseIdSet WITH SECURITY_ENFORCED]);
//                     updateAssetOfVPRefactor(vpMap);
//                 } 
//             }           
//         }
//         catch(Exception e){
//             throw e;
//         }        
//     } 
//     // refactor method for updateAssetOfVP - US 13410
//     public static void updateAssetOfVPRefactor(Map<Id, Verification_Packet__c> verfPacketMap){
//         try{            
//             Id assetCredentialRecTypId = Schema.SObjectType.asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_CREDENTIAL).getRecordTypeId();
//             Id assetVerificationRecTypId = Schema.SObjectType.asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_VERIFICATION).getRecordTypeId();            
//             List<Asset2Verification__c> asset2VPList = new List<Asset2Verification__c>();  
//             List<Asset> assetsToUpdate = new List<Asset>();          
//             if(!verfPacketMap.isEmpty() && asset.SObjectType.getDescribe().isAccessible()){ 
//                 asset2VPList = [SELECT Id, Asset__c, Asset__r.Status, Asset__r.Type__c, Asset__r.Name, Asset__r.RecordTypeId, Asset__r.Case__r.Document_Type__c  FROM Asset2Verification__c WHERE Verification_Packet__c IN: verfPacketMap.keySet() AND (Asset__r.RecordTypeId =: assetCredentialRecTypId OR Asset__r.RecordTypeId =: assetVerificationRecTypId)  WITH SECURITY_ENFORCED];
//                 assetsToUpdate = updateAssetOfVPRefactor2(asset2VPList, assetVerificationRecTypId, assetCredentialRecTypId);
//                 if(!assetsToUpdate.isEmpty() && Asset.SObjectType.getDescribe().isUpdateable()){
//                     UPDATE assetsToUpdate;
//                 }
//             }
//         }
//         catch(Exception e){
//             throw e;
//         }
//     }
//     // refactor method for updateAssetOfVPRefactor - US 13410
//     public static List<Asset> updateAssetOfVPRefactor2(List<Asset2Verification__c> asset2VPList, Id assetVerificationRecTypId, Id assetCredentialRecTypId){
//         final String assetType1 = 'Online Verification Cover Letter';
//         final String assetType2 = 'Verification Form';            
//         final String assetName1 = 'Online Verification';
//         final String assetNameSet = 'Accepted Online Verification';
//         List<Asset> assetListToUpdate = new List<Asset>();
//         Set<Id> ignoreAsset = new Set<Id>();
//         for(Asset2Verification__c ast2VP: asset2VPList){  
//             Asset aset = new Asset();  
//             Boolean updateFlag = false;                
//             if(ast2VP.Asset__r.RecordTypeId == assetVerificationRecTypId &&  
//                ast2VP.Asset__r.Name == assetType1 && ast2VP.Asset__r.Type__c == assetType1){                        
//                    aset.Id = ast2VP.Asset__c;
//                    aset.Status = Constants.ASSET_STATUS_ACCEPTED;
//                    updateFlag = true;
//                }
//             else if(ast2VP.Asset__r.RecordTypeId == assetVerificationRecTypId &&  
//                     ast2VP.Asset__r.Name == assetName1 && ast2VP.Asset__r.Type__c == assetName1){
//                         aset.Id = ast2VP.Asset__c;
//                         aset.Status = Constants.ASSET_STATUS_ACCEPTED;
//                         aset.Name = assetNameSet;
//                         aset.Type__c = assetType2;
//                         updateFlag = true;
//                     }
//             else if(ast2VP.Asset__r.RecordTypeId == assetCredentialRecTypId){                        
//                 aset.Id = ast2VP.Asset__c;
//                 aset.Name = Constants.ASSET_STATUS_VERIFIED+' '+ast2VP.Asset__r.Case__r.Document_Type__c;
//                 aset.Status = Constants.ASSET_STATUS_VERIFIED;
//                 aset.Type__c = ast2VP.Asset__r.Case__r.Document_Type__c;
//                 updateFlag = true;
//             }
//             if(updateFlag && !ignoreAsset.contains(aset.Id)){
//                 assetListToUpdate.add(aset);
//                 ignoreAsset.add(aset.Id);
//             }
//         }
//         return assetListToUpdate;
//     }
//     // Updates date in case record
//     public static void updateCaseRecordDate(Case newCase,Case oldCase){
//         try{
//             set<string> statusSet = new set<string>{Constants.CASE_STATUS_PENDING_ID_REVIEW,Constants.CASE_STATUS_PENDING_REVIEW,Constants.CASE_STATUS_RESUBMITTED_PENDING_ID_REVIEW,Constants.CASE_STATUS_PENDING_ID_VERIFICATION_REVIEW,Constants.CASE_STATUS_RESUBMITTED_PENDING_ID_VERIFICATION_REVIEW};
//                 if(statusSet.contains(newCase.Internal_Status__c) && (oldCase == null || oldCase.Internal_Status__c != newCase.Internal_Status__c)){
//                     newCase.Applicant_Last_Submission_Date__c = Date.today();
//                 }
//             if(((newCase.RecordTypeId == Constants.EVCASERECORDTYPEID && newCase.Internal_Status__c == Constants.CASE_STATUS_NEW)||(newCase.RecordTypeId == Constants.CVRECORDTYPEID && newCase.Internal_Status__c == Constants.CASE_STATUS_SENT_FOR_VERIFICATION)||(newCase.RecordTypeId == Constants.MEDEDUFORMID && newCase.Internal_Status__c == Constants.CASE_STATUS_SENT_FOR_VERIFICATION))
//                &&(oldCase == null || oldCase.RecordTypeId != newCase.RecordTypeId || oldCase.Internal_Status__c != newCase.Internal_Status__c)){
//                    newCase.Record_Available_Date__c = Date.today();
//                }
//             if(newCase.Internal_Status__c == Constants.CASE_STATUS_INCOMPLETE && newCase.RecordTypeId == Constants.APPFORCERTRECORDTYPEID && (oldCase == null || oldCase.Internal_Status__c != newCase.Internal_Status__c || oldCase.RecordTypeId != newCase.RecordTypeId)){
//                 newCase.Incomplete_Status_Date__c = Date.today();
//             }
//         }
//         catch(Exception ex){
//             throw ex;
//         }
//     }
//     // Update case status to closed/Not Applicable
//     public static void updateCaseRecordStatusFlag(Case newCase, Case oldCase){
//         set<string> statusSet = new set<string>{Constants.CASE_STATUS_ACCEPTED,Constants.CASE_STATUS_ADDED,Constants.CASE_STATUS_CANCELLED_BY_APPLICANT
//             ,Constants.CASE_STATUS_CANCELLED_BY_ECFMG,Constants.CASE_STATUS_CLOSED_SCHOOL_CHANGED,Constants.CASE_STATUS_ENROLLMENT_COMPLETED,Constants.CASE_STATUS_CV_ACCEPTED
//             ,Constants.CASE_STATUS_CV_REJECTED,Constants.CASE_STATUS_DUPLICATE_RECORD,Constants.CASE_STATUS_ENROLLMENT_VERIFICATION_COMPLETE
//             ,Constants.CASE_STATUS_ENROLLMENT_VERIFIED,Constants.CASE_STATUS_EXPIRED,Constants.CASE_STATUS_FINAL_QA_COMPLETE,Constants.CASE_STATUS_REJECTED
//             };
//                 if(statusSet.contains(newCase.Internal_Status__c) && newCase.Status != Constants.CASE_STATUS_CLOSED){
//                     newCase.Status = Constants.CASE_STATUS_CLOSED;
//                 }
//         else if(!statusSet.contains(newCase.Internal_Status__c) && newCase.Status != Constants.CASE_STATUS_NOT_APPLICABLE){
//             newCase.Status = Constants.CASE_STATUS_NOT_APPLICABLE;
//         }
//     }
//     // Updates Case status to closed/Not Applicable and external status
//     public static void updateCaseRecordStatus(Case newCase, Case oldCase){
//         try{            
//             if((oldCase == null || oldCase.Internal_Status__c != newCase.Internal_Status__c)){
//                 updateCaseRecordStatusFlag(newCase,oldCase);                
//                 if(newCase.recordTypeId == GenericUtilities.getRecordTypeIdByDevName('Case',Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION) && newCase.Internal_Status__c == Constants.CASE_STATUS_CV_REJECTED && (newCase.Service__c == Constants.CASE_SERVICE_FCVS || newCase.Service__c == Constants.CASE_SERVICE_EICS)){
//                     newCase.External_Status__c = null;
//                 }else if(newCase.recordTypeId == GenericUtilities.getRecordTypeIdByDevName('Case',Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION) && (newCase.Internal_Status__c == Constants.CASE_STATUS_RECEIVED_IN_REVIEW || newCase.Internal_Status__c == Constants.CASE_STATUS_ENROLLMENT_VERIFICATION_COMPLETE)){
//                     newCase.External_Status__c = newCase.Verification_Status__c;
//                 }else{
//                     updateCaseExtStatus(newCase,oldCase);
//                 }
//             }
//         }
//         catch(Exception ex){
//             throw ex;
//         }
//     }
//     // Updates External Status field for case record
//     public static void updateCaseExtStatus(Case newCase,Case oldCase){
//         GetCaseInternalStatus getInternalStatusObj = GetCaseInternalStatus.getInstance();
//         map<string,map<string,Internal_Status_External_Status_Mapping__mdt>> recIdIntExtStatus = getInternalStatusObj.getIntExtStatus();
//         if(recIdIntExtStatus.containsKey(newCase.recordTypeId)){
//             Internal_Status_External_Status_Mapping__mdt intExtStatusItem = null;
//             map<string,Internal_Status_External_Status_Mapping__mdt> intExtStatus = recIdIntExtStatus.get(newCase.recordTypeId);
//             if(oldCase != null && intExtStatus.containsKey(newCase.Internal_Status__c+Constants.STATUS_SEPARATOR+oldCase.Internal_Status__c)){
//                 intExtStatusItem = intExtStatus.get(newCase.Internal_Status__c+Constants.STATUS_SEPARATOR+oldCase.Internal_Status__c);
//             }else if(intExtStatus.containsKey(newCase.Internal_Status__c)){
//                 intExtStatusItem = intExtStatus.get(newCase.Internal_Status__c);
//             }
//             if(intExtStatusItem != null){
//                 newCase.External_Status__c = intExtStatusItem.External_Status__c;
//                 updateEntityExtStatus(newCase,intExtStatusItem);
//             }
//         }
//     }
//     // Updates Entity External Status
//     public static void updateEntityExtStatus(case newCase,Internal_Status_External_Status_Mapping__mdt intExtStatusItem){
//         set<string> noExtEntStatusRecType = new set<string>{Constants.CASE_RECORD_TYPE_MED_EDU_FORM,Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION};
//         if(intExtStatusItem.Entity_External_Status__c!=null && (!noExtEntStatusRecType.contains(intExtStatusItem.Record_Type_Developer_Name__c) || (noExtEntStatusRecType.contains(intExtStatusItem.Record_Type_Developer_Name__c) && newCase.Service__c != Constants.CASE_SERVICE_FCVS))){                    
//             newCase.Entity_External_Status__c = intExtStatusItem.Entity_External_Status__c;
//         }
//     }
//     //Checks if there is an existing AppforCert case for the new case contact
//     public static void checkAppForCertCaseForAttestation(List<case> newCases){
//         Map<case,Id> caseContactIdMap = new Map<case,Id>();
//         Map<Id,Case> contactIdCaseMap = new Map<Id,Case>();
//         for(Case newCse:newCases){
//             if(newCse.recordTypeId == Constants.ATTESTRECORDTYPEID && newCse.Internal_Status__c == Constants.CASE_STATUS_NEW && newCse.Case_Type__c == Constants.CASE_TYPE_ATTESTATION_CASE && newCse.ContactId != null){
//                 caseContactIdMap.put(newCse,newCse.ContactId);  
//             }
//         }
//         If(caseContactIdMap.size()>0){
//             List<Id> contactIds = new List<Id>();
//             contactIds = caseContactIdMap.values();
//             String errorMsg = 'This Applicant does not have an open Application for Certification case.';
//             for(case appForCertCase :[Select Id, Internal_Status__c, ContactId from Case where ContactId IN :contactIds AND recordTypeId = :Constants.APPFORCERTRECORDTYPEID AND Internal_status__c != :Constants.CASE_STATUS_ACCEPTED AND Internal_status__c != :Constants.CASE_STATUS_REJECTED AND Internal_Status__c != :Constants.CASE_STATUS_CANCELLED AND Internal_Status__c != :Constants.CASE_STATUS_EXPIRED]){
//                 contactIdCaseMap.put(appForCertCase.ContactId,appForCertCase);
//             }
//             for(Case newCase:newCases){
//                 if(!contactIdCaseMap.containsKey(newCase.ContactId) && contactIds.contains(newCase.ContactId)){
//                     newCase.addError(errorMsg); 
//                 }
//             }
//         } 
//     }
//     // US 11951- Updates Affirmation Next Step to null
//     public static void updateAffirmation(set<Id> cvNotVerifiedCaseId){
//         List<Affirmation__c> affList = new List<Affirmation__c>();
//         try{
//             for(Affirmation__c affRec:[SELECT Id FROM Affirmation__c WHERE Case__c in: cvNotVerifiedCaseId AND Not_Verified_Next_Step__c != null AND recordType.DeveloperName =: Constants.AFFIRMATION_RECORD_TYPE_NOT_VERIFIED WITH SECURITY_ENFORCED]){
//                 affRec.Not_Verified_Next_Step__c = null;
//                 affRec.Comments__c = null;
//                 affRec.Status__c = 'In Progress';
//                 affList.add(affRec);
//             }
//             if(!affList.isEmpty() && Affirmation__c.SObjectType.getDescribe().isUpdateable()){
//                 update affList;
//             }
//         }
//         catch(Exception ex){
//             throw ex;
//         }
//     }
//     // US 11952- Updates Asset record to Unverified
//     public static void updateAssetUnverified(set<Id> cvUnverified){
//         List<Asset> assetList = new List<Asset>();
//         try{
//             for(Asset2Verification__c ass2Ver:[SELECT Id,Asset__c FROM Asset2Verification__c WHERE (Document_Type__c =: Constants.ASSET2VER_DOCTYPE_SOURCE OR Document_Type__c LIKE 'Returned%') AND Verification_Packet__r.Case__c in: cvUnverified AND Verification_Packet__r.Is_Active__c = TRUE AND Asset__r.Status !=: Constants.ASSET_STATUS_UNVERIFIED WITH SECURITY_ENFORCED]){
//                 Asset assetRec = new Asset(Id = ass2Ver.Asset__c, Status = Constants.ASSET_STATUS_UNVERIFIED);
//                 assetList.add(assetRec);
//             }
//             if(!assetList.isEmpty() && Asset.SObjectType.getDescribe().isUpdateable()){
//                 update assetList;
//             }
//         }
//         catch(Exception ex){
//             throw ex;
//         }
//     }
//     // Prepares data for sharing entity user request case records
//     public static SharingRecWrapper entityUserUpdateSharingRules(set<Id> serviceIdset,List<Case> newEntityUserCases,Map<Id,Case> oldCaseMap){
//         try{
//             Map<Id,Service__c> serviceMap = new Map<Id,Service__c>([SELECT Id,Name FROM Service__c WHERE Id in: serviceIdset]);
//             Map<string,Map<Id,set<Id>>> insServiceAccCaseMap = new Map<string,Map<Id,set<Id>>>();
//             Map<string,Map<Id,set<Id>>> delServiceAccCaseMap = new Map<string,Map<Id,set<Id>>>();
//             set<Id> accountIdSet = new set<Id>();
//             Id epicRepReqRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constants.CASE_RECORD_TYPE_EPIC_VER_REPORT_REQUEST);
//             SharingRecWrapper sharingRecWrapperObj = new SharingRecWrapper();
//             for(Case caseRec:newEntityUserCases){
//                 if(serviceMap.containsKey(caseRec.Service_Name__c) && caseRec.RecordTypeId == epicRepReqRecTypeId){
//                     PopServiceAccCaseMapWrapper popServiceAccCaseMapWrapperObj = new PopServiceAccCaseMapWrapper();
//                     string serviceName = serviceMap.get(caseRec.Service_Name__c).Name;                    
//                     popServiceAccCaseMapWrapperObj.serviceName = serviceName;
//                     popServiceAccCaseMapWrapperObj.serviceAccCaseMap = insServiceAccCaseMap;
//                     popServiceAccCaseMapWrapperObj.entityId = caseRec.Entity__c;
//                     popServiceAccCaseMapWrapperObj.caseId = caseRec.Id;
//                     insServiceAccCaseMap.putAll(populateServiceAccCaseMap(popServiceAccCaseMapWrapperObj));
//                     accountIdSet.add(caseRec.Entity__c);
//                     //Added the line 2292 - 2301 to give epic report access to the parent entity while creating the Epic report with child entity
//                     //Adding one more condition to check the record type as per the regression bug 19399
//                     if(caseRec.Entity_ID__c != null && caseRec.RecordType.DeveloperName == Constants.CASE_RECORD_TYPE_EPIC_VER_REPORT_REQUEST){
//                         PopServiceAccCaseMapWrapper popServiceAccCaseMapWrapperObj1 = new PopServiceAccCaseMapWrapper();
//                         string serviceName1 = serviceMap.get(caseRec.Service_Name__c).Name;                    
//                         popServiceAccCaseMapWrapperObj1.serviceName = serviceName1;
//                         popServiceAccCaseMapWrapperObj1.serviceAccCaseMap = insServiceAccCaseMap;
//                         popServiceAccCaseMapWrapperObj1.entityId = caseRec.Entity_ID__c;
//                         popServiceAccCaseMapWrapperObj1.caseId = caseRec.Id;
//                         insServiceAccCaseMap.putAll(populateServiceAccCaseMap(popServiceAccCaseMapWrapperObj1));
//                         accountIdSet.add(caseRec.Entity_ID__c);
//                     }
//                     if(!oldCaseMap.isEmpty() && caseRec.Entity__c != oldCaseMap.get(caseRec.Id).Entity__c){
//                         popServiceAccCaseMapWrapperObj = new PopServiceAccCaseMapWrapper();
//                         popServiceAccCaseMapWrapperObj.serviceName = serviceName;
//                         popServiceAccCaseMapWrapperObj.entityId = oldCaseMap.get(caseRec.Id).Entity__c;
//                         popServiceAccCaseMapWrapperObj.serviceAccCaseMap = delServiceAccCaseMap;
//                         popServiceAccCaseMapWrapperObj.caseId = caseRec.Id;
//                         delServiceAccCaseMap.putAll(populateServiceAccCaseMap(popServiceAccCaseMapWrapperObj));
//                         accountIdSet.add(oldCaseMap.get(caseRec.Id).Entity__c);
//                     }
//                 }
//             }
//             entUsrReq(newEntityUserCases,insServiceAccCaseMap,delServiceAccCaseMap,accountIdSet,serviceIdset,oldCaseMap);
//             if(!insServiceAccCaseMap.isEmpty()){
//                 sharingRecWrapperObj.insServiceAccCaseMap = insServiceAccCaseMap;
//                 sharingRecWrapperObj.delServiceAccCaseMap = delServiceAccCaseMap;
//                 sharingRecWrapperObj.accountIdSet = accountIdSet;
//             }
//             return sharingRecWrapperObj;
//         }
//         catch(Exception ex){
//             throw ex;
//         }
//     }
//      //sharing entity user request cog issues
//      public static void entUsrReq(List<Case> newEntityUserCases,Map<String,Map<Id,Set<Id>>> insServiceAccCaseMap,Map<String,Map<Id,Set<Id>>> delServiceAccCaseMap,Set<Id> accountIdSet,Set<Id> serviceIdset,Map<Id,Case> oldCaseMap){        
//         Id entityUserRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constants.CASE_RECORD_TYPE_ENTITY_USER_REQUEST);        
//         for(case2service__c entUserCs : [SELECT Id,Name,Service__c,case__c,case__r.RecordTypeId,role__c,
//             Case__r.Entity__c,Service__r.Name
//             FROM case2service__c WHERE case__c IN:newEntityUserCases WITH SECURITY_ENFORCED]){
//             if(entUserCs.case__r.RecordTypeId == entityUserRecTypeId && serviceIdset.contains(entUserCs.Service__c)){
//                 PopServiceAccCaseMapWrapper popServiceAccCaseMapWrapperObj = new PopServiceAccCaseMapWrapper();
//                 string serviceName = entUserCs.Service__r.Name;                    
//                 popServiceAccCaseMapWrapperObj.serviceName = serviceName;
//                 popServiceAccCaseMapWrapperObj.serviceAccCaseMap = insServiceAccCaseMap;
//                 popServiceAccCaseMapWrapperObj.entityId = entUserCs.Case__r.Entity__c;
//                 popServiceAccCaseMapWrapperObj.caseId = entUserCs.Case__c;
//                 insServiceAccCaseMap.putAll(populateServiceAccCaseMap(popServiceAccCaseMapWrapperObj));
//                 accountIdSet.add(entUserCs.Case__r.Entity__c);
//                 //Added the line 2292 - 2301 to give epic report access to the parent entity while creating the Epic report with child entity
//                 if(entUserCs.Case__r.Entity__c != null){
//                     PopServiceAccCaseMapWrapper popServiceAccCaseMapWrapperObj1 = new PopServiceAccCaseMapWrapper();
//                     string serviceName1 = entUserCs.Service__r.Name;                    
//                     popServiceAccCaseMapWrapperObj1.serviceName = serviceName1;
//                     popServiceAccCaseMapWrapperObj1.serviceAccCaseMap = insServiceAccCaseMap;
//                     popServiceAccCaseMapWrapperObj1.entityId = entUserCs.Case__r.Entity__c;
//                     popServiceAccCaseMapWrapperObj1.caseId = entUserCs.Case__c;
//                     insServiceAccCaseMap.putAll(populateServiceAccCaseMap(popServiceAccCaseMapWrapperObj1));
//                     accountIdSet.add(entUserCs.Case__r.Entity__c);
//                 }
//                 if(!oldCaseMap.isEmpty() && entUserCs.Case__r.Entity__c != oldCaseMap.get(entUserCs.Case__c).Entity__c){
//                     popServiceAccCaseMapWrapperObj = new PopServiceAccCaseMapWrapper();
//                     popServiceAccCaseMapWrapperObj.serviceName = serviceName;
//                     popServiceAccCaseMapWrapperObj.entityId = oldCaseMap.get(entUserCs.Case__c).Entity__c;
//                     popServiceAccCaseMapWrapperObj.serviceAccCaseMap = delServiceAccCaseMap;
//                     popServiceAccCaseMapWrapperObj.caseId = entUserCs.Case__c;
//                     delServiceAccCaseMap.putAll(populateServiceAccCaseMap(popServiceAccCaseMapWrapperObj));
//                     accountIdSet.add(oldCaseMap.get(entUserCs.Case__c).Entity__c);
//                 }                    
//             }
//         }
//     }   
//     // Populates service account case map
//     public static Map<string,Map<Id,set<Id>>> populateServiceAccCaseMap(PopServiceAccCaseMapWrapper popServiceAccCaseMapWrapperObj){
//         if(popServiceAccCaseMapWrapperObj.serviceAccCaseMap.containsKey(popServiceAccCaseMapWrapperObj.serviceName)){
//             map<Id,set<Id>> accCase = popServiceAccCaseMapWrapperObj.serviceAccCaseMap.get(popServiceAccCaseMapWrapperObj.serviceName);
//             accCase.putAll(populateAccCaseMap(accCase,popServiceAccCaseMapWrapperObj.entityId,popServiceAccCaseMapWrapperObj.caseId));
//             popServiceAccCaseMapWrapperObj.serviceAccCaseMap.put(popServiceAccCaseMapWrapperObj.serviceName,accCase);
//         }
//         else{
//             popServiceAccCaseMapWrapperObj.serviceAccCaseMap.put(popServiceAccCaseMapWrapperObj.serviceName, new map<Id,set<Id>>{popServiceAccCaseMapWrapperObj.entityId=>new set<Id>{popServiceAccCaseMapWrapperObj.caseId}});
//         }
//         return popServiceAccCaseMapWrapperObj.serviceAccCaseMap;
//     }
//     // Prepares data for sharing credential verification rules
//     public static SharingRecWrapper credVerUpdateSharingRules(List<Case> newCredVerCases,Map<Id,Case> oldCaseMap,Map<id,Set<Id>> parentCaseEntity){
//         try{
//             Set<Id> aleternateAccCaseIds = new Set<Id>();
//             Set<Id> accountIdSet = new Set<Id>();
//             Map<Id,set<Id>> newAccCaseMap = new Map<Id,set<Id>>();
//             Map<Id,set<Id>> oldAccCaseMap = new Map<Id,set<Id>>();
//             aleternateAccCaseIds.addAll(getAltCaseIds(newCredVerCases));      
//             SharingRecWrapper sharingRecWrapperObj = new SharingRecWrapper();
//             PopulateParentCase popParentCase = new PopulateParentCase();
//             popParentCase.parentCaseEntity = parentCaseEntity;
//             if(oldCaseMap.isEmpty()){
//                 for(Case caseRec:newCredVerCases){
//                     if(!aleternateAccCaseIds.contains(caseRec.Id)){
//                         populateAccCaseMap(newAccCaseMap,caseRec.Entity__c,caseRec.Id);
//                         accountIdSet.add(caseRec.Entity__c);
//                         popParentCase.accCaseMap = newAccCaseMap;
//                         includeParentCase(caseRec,popParentCase,caseRec.Entity__c);                        
//                     }
//                 }
//             }
//             else{
//                 PopulateAccCaseOld popAccCaseOld = new PopulateAccCaseOld();
//                 popAccCaseOld.parentCaseEntity = parentCaseEntity;
//                 popAccCaseOld.aleternateAccCaseIds = aleternateAccCaseIds;
//                 popAccCaseOld.newCredVerCases = newCredVerCases;
//                 popAccCaseOld.oldCaseMap = oldCaseMap;
//                 AccCaseMapWrapper accCaseMapWrapperobj = populateAccCaseMapWOld(popAccCaseOld);
//                 newAccCaseMap.putAll(accCaseMapWrapperobj.newAccCaseMap);
//                 oldAccCaseMap.putAll(accCaseMapWrapperobj.oldAccCaseMap);
//                 accountIdSet.addAll(accCaseMapWrapperobj.accountIdSet);
//             }        
//             if(!newAccCaseMap.isEmpty()){
//                 sharingRecWrapperObj.insServiceAccCaseMap = new map<string,map<Id,set<Id>>>{Constants.SERVICE_NAME_CREDENTIAL_VERIFICATION=>newAccCaseMap};
//                 sharingRecWrapperObj.delServiceAccCaseMap = new map<string,map<Id,set<Id>>>{Constants.SERVICE_NAME_CREDENTIAL_VERIFICATION=>oldAccCaseMap};
//                 sharingRecWrapperObj.accountIdSet = accountIdSet;
//             }
//             return sharingRecWrapperObj;
//         }
//         catch(Exception ex){
//             throw ex;
//         }
//     }
//     // Prepares data for sharing Medical Educational Form rules
//     public static SharingRecWrapper medFormUpdateSharingRules(List<Case> newmedFormCases,Map<Id,Case> oldCaseMap){
//         try{
//             Set<Id> aleternateAccCaseIds = new Set<Id>();
//             Set<Id> accountIdSet = new Set<Id>();
//             Map<Id,set<Id>> newAccCaseMap = new Map<Id,set<Id>>();
//             Map<Id,set<Id>> oldAccCaseMap = new Map<Id,set<Id>>();
//             aleternateAccCaseIds.addAll(getMedAltCaseIds(newmedFormCases));        
//             SharingRecWrapper sharingRecWrapperObj = new SharingRecWrapper();
//             if(oldCaseMap.isEmpty()){
//                 for(Case caseRec:newmedFormCases){
//                     if(!aleternateAccCaseIds.contains(caseRec.Id)){
//                         newAccCaseMap.putAll(populateAccCaseMap(newAccCaseMap,caseRec.Entity__c,caseRec.Id));
//                         accountIdSet.add(caseRec.Entity__c);
//                     }
//                 }
//             }
//             else{
//                 PopulateAccCaseOld popAccCaseOld = new PopulateAccCaseOld();
//                 popAccCaseOld.aleternateAccCaseIds = aleternateAccCaseIds;
//                 popAccCaseOld.newCredVerCases = newmedFormCases;
//                 popAccCaseOld.oldCaseMap = oldCaseMap;
//                 AccCaseMapWrapper accCaseMapWrapperobj = populateAccCaseMapWOld(popAccCaseOld);
//                 newAccCaseMap.putAll(accCaseMapWrapperobj.newAccCaseMap);
//                 oldAccCaseMap.putAll(accCaseMapWrapperobj.oldAccCaseMap);
//                 accountIdSet.addAll(accCaseMapWrapperobj.accountIdSet);
//             }        
//             if(!newAccCaseMap.isEmpty()){
//                 sharingRecWrapperObj.insServiceAccCaseMap = new Map<string,Map<Id,Set<Id>>>{Constants.SERVICE_NAME_MEDICAL_EDU_FORM=>newAccCaseMap};
//                 sharingRecWrapperObj.delServiceAccCaseMap = new Map<string,Map<Id,Set<Id>>>{Constants.SERVICE_NAME_MEDICAL_EDU_FORM=>oldAccCaseMap};
//                 sharingRecWrapperObj.accountIdSet = accountIdSet;
//             }
//             return sharingRecWrapperObj;
//         }
//         catch(Exception ex){
//             throw ex;
//         }
//     }
//     // Populates Account, Case Map
//     public static map<Id,set<Id>> populateAccCaseMap(map<Id,set<Id>> accCaseMap,Id entityId,Id caseId){
//         if(accCaseMap.containsKey(entityId)){
//             accCaseMap.get(entityId).add(caseId);
//         }else{
//             accCaseMap.put(entityId,new set<Id>{caseId});
//         }
//         return accCaseMap;
//     }
//     // Populates Old Account, Case Map
//     public static AccCaseMapWrapper populateAccCaseMapWOld(PopulateAccCaseOld popAccCaseOld){
//         Set<Id> accountIdSet = new Set<Id>();
//         Map<Id,Set<Id>> newAccCaseMap = new Map<Id,Set<Id>>();
//         Map<Id,Set<Id>> oldAccCaseMap = new Map<Id,Set<Id>>();
//         PopulateParentCase popParentCase = new PopulateParentCase();
//         popParentCase.parentCaseEntity = popAccCaseOld.parentCaseEntity;
//         for(Case caseRec:popAccCaseOld.newCredVerCases){
//             if(popAccCaseOld.aleternateAccCaseIds.contains(caseRec.Id) && caseRec.Alternate_Entity__c!=popAccCaseOld.oldCaseMap.get(caseRec.Id).Alternate_Entity__c){
//                 populateAccCaseMap(newAccCaseMap,caseRec.Alternate_Entity__c,caseRec.Id);
//                 accountIdSet.add(caseRec.Alternate_Entity__c);
//                 popParentCase.accCaseMap = newAccCaseMap;
//                 includeParentCase(caseRec,popParentCase,caseRec.Alternate_Entity__c);
//                 populateAccCaseMap(oldAccCaseMap,popAccCaseOld.oldCaseMap.get(caseRec.Id).Alternate_Entity__c,caseRec.Id);
//                 accountIdSet.add(popAccCaseOld.oldCaseMap.get(caseRec.Id).Alternate_Entity__c);
//                 popParentCase.accCaseMap = oldAccCaseMap;
//                 includeParentCase(caseRec,popParentCase,popAccCaseOld.oldCaseMap.get(caseRec.Id).Alternate_Entity__c);
//             }
//             else if(!popAccCaseOld.aleternateAccCaseIds.contains(caseRec.Id) && caseRec.Entity__c!=popAccCaseOld.oldCaseMap.get(caseRec.Id).Entity__c){
//                 populateAccCaseMap(newAccCaseMap,caseRec.Entity__c,caseRec.Id);
//                 accountIdSet.add(caseRec.Entity__c);
//                 popParentCase.accCaseMap = newAccCaseMap;
//                 includeParentCase(caseRec,popParentCase,caseRec.Entity__c);
//                 populateAccCaseMap(oldAccCaseMap,popAccCaseOld.oldCaseMap.get(caseRec.Id).Entity__c,caseRec.Id);
//                 accountIdSet.add(popAccCaseOld.oldCaseMap.get(caseRec.Id).Entity__c);
//                 popParentCase.accCaseMap = oldAccCaseMap;
//                 includeParentCase(caseRec,popParentCase,popAccCaseOld.oldCaseMap.get(caseRec.Id).Entity__c);
//             }
//             else if(!popAccCaseOld.oldCaseMap.isEmpty() && caseRec.OwnerId != popAccCaseOld.oldCaseMap.get(caseRec.Id).OwnerId){
//                 if(!popAccCaseOld.aleternateAccCaseIds.contains(caseRec.Id)){
//                     newAccCaseMap.putAll(populateAccCaseMap(newAccCaseMap,caseRec.Entity__c,caseRec.Id));
//                     accountIdSet.add(caseRec.Entity__c);
//                     popParentCase.accCaseMap = newAccCaseMap;
//                     includeParentCase(caseRec,popParentCase,caseRec.Entity__c);
//                 }
//                 else{
//                     newAccCaseMap.putAll(populateAccCaseMap(newAccCaseMap,caseRec.Alternate_Entity__c,caseRec.Id));
//                     accountIdSet.add(caseRec.Alternate_Entity__c);
//                     popParentCase.accCaseMap = newAccCaseMap;
//                     includeParentCase(caseRec,popParentCase,caseRec.Alternate_Entity__c);
//                 }
//             }
//         }
//         AccCaseMapWrapper accCaseMapWrapperobj = new AccCaseMapWrapper();
//         accCaseMapWrapperobj.accountIdSet.addAll(accountIdSet);
//         accCaseMapWrapperobj.newAccCaseMap.putAll(newAccCaseMap);
//         accCaseMapWrapperobj.oldAccCaseMap.putAll(oldAccCaseMap);
//         return accCaseMapWrapperobj;
//     }
//     // Combines different record types cases and passes them to create caseshare records.
//     public static void updateCaseSharingRules(List<SharingRecWrapper> sharingRecWrapperList){
//         try{
//             Map<string,Map<Id,set<Id>>> insServiceAccCaseMap = new Map<string,Map<Id,set<Id>>>();
//             Map<string,Map<Id,set<Id>>> delServiceAccCaseMap = new Map<string,Map<Id,set<Id>>>();
//             set<Id> accountIdSet = new set<Id>();
//             for(SharingRecWrapper sharingRecWrapperObj:sharingRecWrapperList){
//                 insServiceAccCaseMap.putAll(populateServiceAccCaseShare(sharingRecWrapperObj.insServiceAccCaseMap,insServiceAccCaseMap));
//                 delServiceAccCaseMap.putAll(populateServiceAccCaseShare(sharingRecWrapperObj.delServiceAccCaseMap,delServiceAccCaseMap));
//                 accountIdSet.addAll(sharingRecWrapperObj.accountIdSet);            
//             }
//             if(!accountIdSet.isEmpty()){
//                 SharingRuleEntityUserRequestCase.updateSharingRulesEntityUserRequestCase(insServiceAccCaseMap,delServiceAccCaseMap,accountIdSet);
//             }
//         }
//         catch(Exception ex){
//             throw ex;
//         }
//     }
//     // Populates Service, Account, Case Map
//     public static Map<string,Map<Id,set<Id>>> populateServiceAccCaseShare(Map<string,Map<Id,set<Id>>> sharingRecServiceAccCaseMap,Map<string,Map<Id,set<Id>>> serviceAccCaseMap){
//         for(string serviceName:sharingRecServiceAccCaseMap.keyset()){
//             if(serviceAccCaseMap.containsKey(serviceName)){
//                 Map<Id,set<Id>> accConIds = new Map<Id,set<Id>>(sharingRecServiceAccCaseMap.get(serviceName));
//                 for(Id entityId:accConIds.keyset()){
//                     if(serviceAccCaseMap.get(serviceName).containskey(entityId)){
//                         serviceAccCaseMap.get(serviceName).get(entityId).addAll(accConIds.get(entityId));
//                     }else{
//                         serviceAccCaseMap.get(serviceName).put(entityId,accConIds.get(entityId));
//                     }
//                 }
//             }else{
//                 serviceAccCaseMap.put(serviceName,new map<Id,set<Id>>(sharingRecServiceAccCaseMap.get(serviceName)));
//             }
//         }
//         return serviceAccCaseMap;
//     }
//     // This method fetches corresponding entity of all child records (except the current case) of parent caseId.
//     public static Map<Id,Set<Id>> getParentCaseChildCaseEntity(Set<Id> shareCredVerCases,Set<Id> cvParentCaseIds){
//         List<Case> childCaseList = [SELECT Id,ParentId,Entity__c,Alternate_Entity__c FROM Case WHERE Id NOT IN:shareCredVerCases AND ParentId IN: cvParentCaseIds AND Parent.RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_APP_FOR_CERT AND RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION];
//         Set<Id> aleternateAccCaseIds = new Set<Id>(getAltCaseIds(childCaseList));
//         Map<Id,Set<Id>> parentCaseEntity = new Map<Id,Set<Id>>();
//         for(Case childCaseRecord:childCaseList){
//             Set<Id> entityIds = new Set<Id>();
//             if(parentCaseEntity.containsKey(childCaseRecord.ParentId)){
//                 entityIds.addAll(parentCaseEntity.get(childCaseRecord.ParentId));
//             }
//             if(aleternateAccCaseIds.contains(childCaseRecord.Id)){
//                 entityIds.add(childCaseRecord.Alternate_Entity__c);
//             }else{
//                 entityIds.add(childCaseRecord.Entity__c);
//             }
//             parentCaseEntity.put(childCaseRecord.ParentId,entityIds);
//         }
//         return parentCaseEntity;
//     }
//     // This method checks if the CV parent caseId has access to entity passed.
//     public static boolean checkParentCaseEntityAccess(Id parentCaseId, Id entityId,Map<Id,Set<Id>> parentCaseEntity){
//         if(parentCaseEntity.containsKey(parentCaseId) && parentCaseEntity.get(parentCaseId).contains(entityId)){
//             return true;
//         }
//         return false;
//     }
//     // This method includes parent case to the map to provide sharing access.
//     public static void includeParentCase(Case caseRec,PopulateParentCase popParentCase,Id accountId){
//         if(caseRec.RecordTypeId == Constants.CRED_VER_RDTYPEID && String.isNotBlank(caseRec.ParentId) && !checkParentCaseEntityAccess(caseRec.ParentId,accountId,popParentCase.parentCaseEntity)){
//             populateAccCaseMap(popParentCase.accCaseMap,accountId,caseRec.ParentId);
//         }
//     }
//     //Method to update the Verification Request Send date when the parent CV case status changes to Sent for verification
//     public static List<Case> updateEpicReportVerifReqSendDate(String cvCaseId){
//         List<Case> epicCaseList = new List<Case>();
//         for(Case epicCase :[SELECT Id, First_Verification_Request_Sent_Date__c, Verification_Request_Send_Date__c, Secondary_Parent_Case__c FROM Case WHERE Secondary_Parent_Case__c =:cvCaseId AND recordTypeId =: Constants.EPICVERREPORTREQRTID WITH SECURITY_ENFORCED]){
//             if(epicCase.First_Verification_Request_Sent_Date__c ==  null){
//                 epicCase.First_Verification_Request_Sent_Date__c = Date.today();    
//             }
//             epicCase.Verification_Request_Send_Date__c = Date.today();  
//             epicCaseList.add(epicCase);
//         }
//         return epicCaseList;
//     }
//     //US 20321 - Method to uncheck the Do_Not_Know_Orgs_to_send_EPIC_Reports__c if the cv case has epic case record
//     public static Void CredVerCasesToUpdate(String CaseId){
//         List<Case> CredVerCaseList = new List<Case>();
//         for(Case epicCase :[SELECT Id, Do_Not_Know_Orgs_to_send_EPIC_Reports__c, Secondary_Parent_Case__c FROM Case WHERE Id =: CaseId AND recordTypeId =: Constants.EPICVERREPORTREQRTID WITH SECURITY_ENFORCED]){
//             if(epicCase.Secondary_Parent_Case__c <>  null){
//             Case caseObj = new case(); 
//             caseObj.Id = epicCase.Secondary_Parent_Case__c;
//             caseObj.Do_Not_Know_Orgs_to_send_EPIC_Reports__c = false;               
//             CredVerCaseList.add(caseObj);
//             }
//         }
// 		if(!CredVerCaseList.isEmpty() && Schema.sObjectType.Case.isUpdateable()){
//             update CredVerCaseList;
//         }
//     }

//     public static void updateEpicCases(List<Case> epicCaseList){
//         try{
//             if(Case.SObjectType.getDescribe().isUpdateable()){
//                 Update epicCaseList;
//             }
//         }catch(Exception e){
//             throw new ControllerException(e.getMessage());
//         }
//     }
//     public class PopServiceAccCaseMapWrapper{
//         string serviceName{get;set;}
//         Map<string,Map<Id,set<Id>>> serviceAccCaseMap = new Map<string,Map<Id,set<Id>>>();
//         Id entityId {get;set;}
//         Id caseId {get;set;}
//     }
//     public class AccCaseMapWrapper{
//         set<Id> accountIdSet = new set<Id>();
//         map<Id,set<Id>> newAccCaseMap = new map<Id,set<Id>>();
//         map<Id,set<Id>> oldAccCaseMap = new map<Id,set<Id>>();
//     }
//     public class SharingRecWrapper{
//         Map<string,Map<Id,set<Id>>> insServiceAccCaseMap = new Map<string,Map<Id,set<Id>>>();
//         Map<string,Map<Id,set<Id>>> delServiceAccCaseMap = new Map<string,Map<Id,set<Id>>>();
//         set<Id> accountIdSet = new set<Id>();
        
//     }
//     public class SendMailWrapper{
//         public List<Case> caseList = new List<Case>();
//         public OrgWideEmailAddress addr = new OrgWideEmailAddress();
//         public EmailTemplate emailTemplate = new EmailTemplate();
//     }
//     public class PrepareHtmlWrapper{
//         public Case caseRecord = new Case();
//         public string htmlBody = '';
//         public Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
//         public Contact con = new Contact();
//     }
//     public class PopulateParentCase{
//         public Map<Id,Set<Id>> accCaseMap = new Map<Id,set<Id>>();
//         public Map<Id,Set<Id>> parentCaseEntity = new Map<Id,Set<Id>>();
//     }
//     public class PopulateAccCaseOld{
//         Set<Id> aleternateAccCaseIds = new Set<Id>();
//         List<Case> newCredVerCases = new List<Case>();
//         Map<Id,Case> oldCaseMap = new Map<Id,Case>();
//         Map<Id,Set<Id>> parentCaseEntity = new Map<Id,Set<Id>>();
//     }
}