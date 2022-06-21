// Bug 6791 - Update sharing rules for users based on Case RecordType
public without sharing class SharingRuleEVCase{
    // @InvocableMethod(label='EVCase - UpdateSharingRules' description='EV Case - Update Sharing Rules for Case Users')
    // // Bug 6791 - Update sharing rules for users based on Case RecordType - EV Case related
    // public static void updateSharingRules(List<Id> caseIds){ 
    //     if(!caseIds.isEmpty()){
    //         // Exam Reg Case's Case Ids
    //         Id examRegRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
    //         List<Id> caseIdsList = new List<Id>();
    //         caseIdsList.addAll(caseIds);
    //         Set<Id> examRegCaseIdsSet = new SET<Id>();
    //         Map<Id, Case> caseMap = new Map<Id, Case>([SELECT Id FROM Case WHERE Enrollment_Verification_Parent__c IN :caseIds AND RecordTypeId =:examRegRecordTypeId]);
    //         caseIdsList.addAll(caseMap.keySet());
    //         examRegCaseIdsSet.addAll(caseMap.keySet());
    //         if(!examRegCaseIdsSet.isEmpty()){
    //             // Epex Case's Case Ids
    //             Id epexRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD).getRecordTypeId();
    //             Map<Id, Case> caseMap1 = new Map<Id, Case>([SELECT Id FROM Case WHERE ParentId IN :examRegCaseIdsSet AND RecordTypeId =:epexRecordTypeId]);
    //             caseIdsList.addAll(caseMap1.keySet());
    //         }
    //         // Get AccountId of all Case Ids .... mapping AccountId with CaseId
    //         Map<Id, Case> casesMap = new Map<Id, Case>([SELECT Id, AccountId FROM Case WHERE Id IN :caseIds]);
    //         Map<Id, Id> caseAccountIdsMap = new Map<Id, Id>();
    //         for(Case caseObj : casesMap.values()){                
    //             caseAccountIdsMap.put(caseObj.AccountId, caseObj.Id);
    //         }
    //         // Get Contact Ids from CONTACT2ACCTSERVICE__c based on AccountId
    //         Set<Id> contactIdsSet = new Set<Id>();
    //         for(CONTACT2ACCTSERVICE__c con2accserviceObj : [SELECT ID, Service_Contact__c, Account_Service__c, Account_Service__r.Account__c
    //                                                         FROM CONTACT2ACCTSERVICE__c
    //                                                         WHERE Active__c = true
    //                                                             AND Service_Contact__c != null
    //                                                             AND Account_Service__r.Account__c IN :caseAccountIdsMap.keySet()
    //                                                             AND Account_Service__r.Active__c = true]){
    //             contactIdsSet.add(con2accserviceObj.Service_Contact__c);
    //         }
    //         Id profileId = [SELECT id FROM profile WHERE name =: Constants.Entity_360_USER_PROFILE LIMIT 1].id;            
    //         // Get User Ids from User based on ContactId
    //         List<Id> userIdsList = new List<Id>();
    //         Map<Id, User> userMap = new Map<Id, User>([SELECT id, name, ContactId, ProfileId FROM User WHERE IsActive = true AND ProfileId =:profileId AND ContactId IN :contactIdsSet]);
    //         userIdsList.addAll(userMap.keySet());
    //         // Calling as seperate method tp resolve refactoring issue
    //         updateSharingRulesRefactor(caseIdsList, userIdsList);
    //     }       
    // }
    // /**
    // * @author: Ajoydhas
    // * @name: updateSharingRulesRefactor
    // * @description: Bug 6791 - Update sharing rules for users based on Case RecordType - EV Case related 
    // * @createdDate: 23-July-2020
    // **/
    // public static void updateSharingRulesRefactor(List<id> caseIdsList, List<id> userIdsList) {
    //     if(!userIdsList.isEmpty()) {
    //         List<CaseShare> caseList = new List<CaseShare>();

    //         for(Id caseId : caseIdsList) {

    //             for(Id userId : userIdsList) {

    //                 // Create new sharing object for the custom object Job.
    //                 CaseShare caseShr  = new CaseShare();
                
    //                 // Set the ID of record being shared.
    //                 caseShr.CaseId = caseId;
                        
    //                 // Set the ID of user or group being granted access.
    //                 //caseShr.UserOrGroupId = caseUserIdsMap.get(caseId); // Get User Id from MAP
    //                 caseShr.UserOrGroupId = userId; // Get User Id from MAP
                        
    //                 // Set the access level.
    //                 caseShr.CaseAccessLevel = 'Edit';
                        
    //                 // Set rowCause to 'manual' for manual sharing.
    //                 // This line can be omitted as 'manual' is the default value for sharing objects.
    //                 caseShr.RowCause = Schema.CaseShare.RowCause.Manual;

    //                 // Add the new share reords
    //                 caseList.add(caseShr);
    //             }
    //         }

    //         // Insert the sharing record and capture the save result. 
    //         // The false parameter allows for partial processing if multiple records passed 
    //         // into the operation.
    //         if(!caseList.isEmpty()) {
    //             Database.insert(caseList, false);
    //         }
    //     }
    // }
}