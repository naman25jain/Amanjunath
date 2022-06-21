// @description: Bug 10189 - Update sharing rules for users based on Case RecordType
public without sharing class SharingRuleEPEXCase{
    @InvocableMethod(label='EPEXCase - UpdateSharingRules' description='EPEX Case - Update Sharing Rules for Case Users')
    //  @description: Bug 10189 - Update sharing rules for users based on Case RecordType - EV Case related  @createdDate: 03-Nov-2020
    public static void updateSharingRules(List<Id> caseIds){
        if(!caseIds.isEmpty()){
            // Epex Case's Case Ids
            Id epexRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD).getRecordTypeId();                
            List<Id> caseIdsList = new List<Id>();
            caseIdsList.addAll(caseIds);
            SET<Id> evCaseIdsSet = new SET<Id>();
            // caseIds is ParentId passing from Process Builder
            for(Case epexCaseObj : [SELECT Id, ParentId, Enrollment_Verification_Parent__c FROM Case WHERE Id IN :caseIds AND  RecordTypeId =: epexRecordTypeId]){
                caseIdsList.add(epexCaseObj.ParentId);
                caseIdsList.add(epexCaseObj.Enrollment_Verification_Parent__c);
                evCaseIdsSet.add(epexCaseObj.Enrollment_Verification_Parent__c);
            }
            // Get AccountId of all Case Ids .... mapping AccountId with CaseId
            MAP<Id, Id> caseAccountIdsMap = new MAP<Id, Id>();
            for(Case caseObj : [SELECT Id, AccountId FROM Case WHERE Id IN :evCaseIdsSet]){                
                caseAccountIdsMap.put(caseObj.AccountId, caseObj.Id);
            }
            // Get Contact Ids from CONTACT2ACCTSERVICE__c based on AccountId
            SET<Id> contactIdsSet = new SET<Id>();
            for(CONTACT2ACCTSERVICE__c con2accserviceObj : [SELECT ID, Service_Contact__c, Account_Service__c, Account_Service__r.Account__c
                                                                    FROM CONTACT2ACCTSERVICE__c
                                                                WHERE Active__c = true
                                                                    AND Service_Contact__c != null
                                                                    AND Account_Service__r.Account__c IN: caseAccountIdsMap.keySet()
                                                                    AND Account_Service__r.Active__c = true]){
                contactIdsSet.add(con2accserviceObj.Service_Contact__c);
            }
            Id profileId = [SELECT id FROM profile WHERE name =: Constants.Entity_360_USER_PROFILE LIMIT 1].id;            
            // Get User Ids from User based on ContactId
            List<Id> userIdsList = new List<Id>();
            for(USER userObj : [SELECT id, name, ContactId, ProfileId
                                    FROM User
                                WHERE IsActive = true 
                                    AND ProfileId =: profileId
                                    AND ContactId IN: contactIdsSet]) {
                userIdsList.add(userObj.Id);
            }
            // Calling as seperate method tp resolve refactoring issue
            updateSharingRulesRefactor(caseIdsList, userIdsList);
        }       
    }
    public static void updateSharingRulesRefactor(List<id> caseIdsList, List<id> userIdsList){
        if(!userIdsList.isEmpty()){
            List<CaseShare> caseList = new List<CaseShare>();
            for(Id caseId : caseIdsList){
                for(Id userId : userIdsList){
                    // Create new sharing object for the custom object Job.
                    CaseShare caseShr  = new CaseShare();                
                    // Set the ID of record being shared.
                    caseShr.CaseId = caseId;                        
                    // Set the ID of user or group being granted access.
                    caseShr.UserOrGroupId = userId; // Get User Id from MAP                        
                    // Set the access level.
                    caseShr.CaseAccessLevel = 'Edit';                        
                    // Set rowCause to 'manual' for manual sharing.
                    // This line can be omitted as 'manual' is the default value for sharing objects.
                    caseShr.RowCause = Schema.CaseShare.RowCause.Manual;
                    // Add the new share reords
                    caseList.add(caseShr);
                }
            }
            // Insert the sharing record and capture the save result. 
            // The false parameter allows for partial processing if multiple records passed 
            // into the operation.
            if(!caseList.isEmpty()){
                Database.insert(caseList, false);
            }
        }
    }
}