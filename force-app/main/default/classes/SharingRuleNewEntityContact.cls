/**
    * @author: Ajoydhas
    * @name: SharingRuleNewEntityContact
    * @description: Manual sharing of existing EV cases, Exam Reg cases, EPEx Cases, Entity User Request cases to new Entity Contact
**/
public without sharing class SharingRuleNewEntityContact {

    @InvocableMethod(label='New Entity Cntact - UpdateSharingRules' description='New Entity Cntact - UpdateSharingRules')
     /**
    * @author: Ajoydhas
    * @name: updateSharingRules
    * @description: Manual sharing of existing EV cases, Exam Reg cases, EPEx Cases, Entity User Request cases to new Contact
    **/
    public static void updateSharingRulesNewEntityContact(List<ContEntity> conEntityList){
        if(!conEntityList.isEmpty()){
            MAP<Id, Id> accountEntityContactMap = new MAP<Id, Id>();
            Set<Id> contactIds = new Set<Id>();
            Map<Id,Set<Id>> entityContact = new Map<Id,Set<Id>>();
            Set<Id> accountIdsSet = new Set<Id>();
            for(ContEntity conEnt:conEntityList){
                populateMap(entityContact,conEnt.entityId,conEnt.contactId);
                accountIdsSet.add(conEnt.entityId);
                accountEntityContactMap.put(conEnt.entityId,conEnt.contactId);
                contactIds.add(conEnt.contactId);
            }
                Map<Id, List<Id>> contactCaseIdListMap = getCaseIdsList(accountIdsSet, accountEntityContactMap); // Entity Contact Id, List of cases
                Id profileId = [SELECT id FROM profile WHERE name =: Constants.Entity_360_USER_PROFILE LIMIT 1].id;
                // Get User Ids from User based on ContactId
                List<Id> userIdsList = new List<Id>();
                Map<Id, List<Id>> userCaseIdsMap = new Map<Id, List<Id>>(); // User Id, List of Cases
                for(USER userObj : [SELECT id, name, ContactId, ProfileId
                                        FROM User
                                    WHERE IsActive = true
                                        AND ProfileId =: profileId
                                        AND ContactId IN: contactIds]) {
                    userIdsList.add(userObj.Id);
                    if(contactCaseIdListMap.containsKey(userObj.ContactId)){    
                        List<Id> caseIdsList = contactCaseIdListMap.get(userObj.ContactId);
                        userCaseIdsMap.put(userObj.Id, caseIdsList);
                    }
                }
                if(!userCaseIdsMap.isEmpty() && !userIdsList.isEmpty()) {
                    // Calling as seperate method tp resolve refactoring issue
                    updateSharingRulesRefactor(userIdsList, userCaseIdsMap);
                }
                getConCaseMap(entityContact);
            }
        }
    /**
    * @author: Ajoydhas
    * @name: getCaseIdsListRefactor
    * @description: Get Case Id Lists
    **/
    public static Map<Id, List<Id>> getCaseIdsList(Set<Id> accountIdsSet, MAP<Id, Id> accountEntityContactMap){
        Map<Id, List<Id>> contactCaseIdListMap  =   new Map<Id, List<Id>>(); // Contact Id , List of Case ids
        Map<Id, Id> caseContactIdMap            =   new Map<Id, Id>(); // Case Id, Contact Id
        Map<Id, Id> examRegCaseContactMap       =   new Map<Id, Id>(); // Case Id, Contact Id
        SET<Id> evCaseIdsSet        =   new SET<Id>();
        SET<Id> examRegCaseIdsSet   =   new SET<Id>();
        if(!accountIdsSet.isEmpty()) {
            // Get Case records for EV Cases
            Id evCaseRecordTypeId       =   Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION).getRecordTypeId();
            Id credVerRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
            Id medFormRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_MED_EDU_FORM).getRecordTypeId();
            List<Case> evCaseLists = [SELECT Id, AccountId FROM Case 
                                        WHERE AccountId IN :accountIdsSet
                                    AND(RecordTypeId =: evCaseRecordTypeId OR RecordTypeId =: medFormRecTypeId) WITH SECURITY_ENFORCED];
            // creating map with account id as key and case as list
            for(Case evCaseObj : evCaseLists) {
                // Mapping Entity Conatct with list of cases
                Id entityContactId = accountEntityContactMap.get(evCaseObj.AccountId);
                if(contactCaseIdListMap.containsKey(entityContactId)) {   
                    contactCaseIdListMap.get(entityContactId).add(evCaseObj.Id);                    
                } else {   
                    contactCaseIdListMap.put(entityContactId,new list<Id>{evCaseObj.Id}); 
                }
                evCaseIdsSet.add(evCaseObj.Id);
                caseContactIdMap.put(evCaseObj.Id, entityContactId);
            }
        }
        if(!evCaseIdsSet.isEmpty()) {
            // Exam Registration Case's Case Ids
            contactCaseIdListMap = getExamRegContactCaseListMapRefactor(evCaseIdsSet, caseContactIdMap, contactCaseIdListMap);
            examRegCaseContactMap = getExamRegCaseContactMapRefactor(evCaseIdsSet, caseContactIdMap);
            examRegCaseIdsSet = examRegCaseContactMap.keySet();
            caseContactIdMap.putAll(examRegCaseContactMap);
        }
        if(!examRegCaseIdsSet.isEmpty()) {
            // Epex Case's Case Ids
            contactCaseIdListMap = getEpexContactCaseListMapRefactor(examRegCaseIdsSet, caseContactIdMap, contactCaseIdListMap);
        }
        // Get Case records for Entity User Request cases
        Id enUsrReqRecordTypeId =   Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENTITY_USER_REQUEST).getRecordTypeId();
        List<Case> entityUserRequestCaseLists = [SELECT Id, Entity__c FROM Case 
                                                    WHERE Entity__c IN :accountIdsSet
                                                AND RecordTypeId =: enUsrReqRecordTypeId];
        
        // creating map with account id as key and case as list
        for(Case entityUserRequestCaseObj : entityUserRequestCaseLists) {
            // Mapping Entity Conatct with list of cases
            Id entityContactId = accountEntityContactMap.get(entityUserRequestCaseObj.Entity__c);
            if(contactCaseIdListMap.containsKey(entityContactId)) {   
                contactCaseIdListMap.get(entityContactId).add(entityUserRequestCaseObj.Id);                    
            } else {   
                contactCaseIdListMap.put(entityContactId,new list<Id>{entityUserRequestCaseObj.Id}); 
            }
        }
        return contactCaseIdListMap;
    }
    public static Map<Id, List<Id>> getExamRegContactCaseListMapRefactor(Set<Id> evCaseIdsSet, Map<Id, Id> caseContactIdMap, Map<Id, List<Id>> contactCaseIdListMap) {
        Map<Id, List<Id>> examregContactCaseIdListMap =   contactCaseIdListMap; // Contact Id , List of Case ids
        // Exam Registration Case's Case Ids
        Id examRegRecordTypeId      =   Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        for(Case examRegCaseObj : [SELECT Id, Enrollment_Verification_Parent__c FROM Case 
                                        WHERE Enrollment_Verification_Parent__c IN :evCaseIdsSet
                                            AND  RecordTypeId =: examRegRecordTypeId]) {
            // Mapping Entity Conatct with list of cases
            Id entityContactId = caseContactIdMap.get(examRegCaseObj.Enrollment_Verification_Parent__c);
            if(examregContactCaseIdListMap.containsKey(entityContactId)) {   
                examregContactCaseIdListMap.get(entityContactId).add(examRegCaseObj.Id);                    
            } else {   
                examregContactCaseIdListMap.put(entityContactId,new list<Id>{examRegCaseObj.Id}); 
            }
        }       
        
        return examregContactCaseIdListMap;
    }
    /**
    * @author: Ajoydhas
    * @name: updateSharingRulesRefactor
    * @description: Refactoring Purpose
    **/
    public static Map<Id, Id> getExamRegCaseContactMapRefactor(Set<Id> evCaseIdsSet, Map<Id, Id> caseContactIdMap) {
        Map<Id, Id> examRegCaseContactMap =   new Map<Id, Id>(); // Case Id, Contact Id
        // Exam Registration Case's Case Ids
        Id examRegRecordTypeId      =   Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        for(Case examRegCaseObj : [SELECT Id, Enrollment_Verification_Parent__c FROM Case 
                                        WHERE Enrollment_Verification_Parent__c IN :evCaseIdsSet
                                            AND  RecordTypeId =: examRegRecordTypeId]) {
            // Mapping Entity Conatct with list of cases
            Id entityContactId = caseContactIdMap.get(examRegCaseObj.Enrollment_Verification_Parent__c);
            examRegCaseContactMap.put(examRegCaseObj.Id, entityContactId);
        }
        return examRegCaseContactMap;
    }
    /**
    * @author: Ajoydhas
    * @name: getEpexContactCaseListMapRefactor
    * @description: Refactoring Purpose - Epex Case Map // Contact Id , List of Case ids
    **/
    public static Map<Id, List<Id>> getEpexContactCaseListMapRefactor(Set<Id> examRegCaseIdsSet, Map<Id, Id> caseContactIdMap, Map<Id, List<Id>> contactCaseIdListMap) {
        Map<Id, List<Id>> epexContactCaseIdListMap =   contactCaseIdListMap; // Contact Id , List of Case ids
        // Epex Case's Case Ids
        Id epexRecordTypeId         =   Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD).getRecordTypeId();
        for(Case epexCaseObj : [SELECT Id, ParentId FROM Case 
                                    WHERE ParentId IN :examRegCaseIdsSet
                                        AND RecordTypeId =: epexRecordTypeId]) {
            // Mapping Entity Conatct with list of cases
            Id entityContactId = CaseContactIdMap.get(epexCaseObj.ParentId);
            if(epexContactCaseIdListMap.containsKey(entityContactId)) {   
                epexContactCaseIdListMap.get(entityContactId).add(epexCaseObj.Id);                    
            } else {   
                epexContactCaseIdListMap.put(entityContactId,new list<Id>{epexCaseObj.Id}); 
            }
        }        
        return epexContactCaseIdListMap;
    }    
    /**
    * @author: Ajoydhas
    * @name: updateSharingRulesRefactor
    * @description: Update Sharing Rules
    **/
    public static void updateSharingRulesRefactor(List<id> userIdsList, Map<Id, List<Id>> userCaseIdsMap) {
        if(!userIdsList.isEmpty()) {
            List<CaseShare> caseList = new List<CaseShare>();           

            for(Id userId : userIdsList) {

                if(userCaseIdsMap.containsKey(userId)) {
                    List<Id> caseIdsList = userCaseIdsMap.get(userId);

                    for(Id caseId : caseIdsList) {

                        // Create new sharing object for the custom object Job.
                        CaseShare caseShr  = new CaseShare();
                    
                        // Set the ID of record being shared.
                        caseShr.CaseId = caseId;
                            
                        // Set the ID of user or group being granted access.
                        //caseShr.UserOrGroupId = caseUserIdsMap.get(caseId); // Get User Id from MAP
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
            }

            // Insert the sharing record and capture the save result. 
            // The false parameter allows for partial processing if multiple records passed 
            // into the operation.
            if(!caseList.isEmpty()) {
                Database.insert(caseList, false);
            }
        }
    }
    // This method creates caseshare records
    public static void updateSharingRules(Map<Id, set<Id>> conCase){
        map<Id,set<Id>> userCaseIdsMap = new map<Id,set<Id>>();
        List<User> usersList = [SELECT Id,ContactId FROM User WHERE ContactId in: conCase.keySet() AND Profile.Name =: Constants.Entity_360_USER_PROFILE AND IsActive = true];
        for(User userRec : usersList){
            userCaseIdsMap.put(userRec.Id,conCase.get(userRec.ContactId));
        }
        List<CaseShare> caseshrList = new List<CaseShare>();
        for(Id userId : userCaseIdsMap.keySet()){
            for(Id caseId : userCaseIdsMap.get(userId)){
                CaseShare caseShr  = new CaseShare();
                caseShr.CaseId = caseId;
                caseShr.UserOrGroupId = userId;
                caseShr.CaseAccessLevel = 'Edit';
                caseShr.RowCause = Schema.CaseShare.RowCause.Manual;
                caseshrList.add(caseShr);
            }
        }
        if(!caseshrList.isEmpty()){
            Insert caseshrList;
        }
    }
    // gets the open cases and provides access to the users.
    private static void getConCaseMap(Map<Id,Set<Id>> entityContact){
        Map<Id,Set<Id>> conCase = new Map<Id,Set<Id>>();
        Map<Id,Set<Id>> entityCaseMap = new Map<Id,Set<Id>>();
        List<Case> caseLists = [SELECT Id,parentId,Alternate_Entity__c,Entity__c,parent.recordType.DeveloperName,(SELECT Id,Verify_with_Alternate_Entity__c FROM Affirmations__r WHERE RecordType.DeveloperName =: Constants.AFFIRMATION_RECORD_TYPE_CREDENTIAL_VERIFICATION AND Verify_with_Alternate_Entity__c = true) FROM Case WHERE isClosed = false AND RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION AND (Entity__c IN: entityContact.keySet() OR Alternate_Entity__c IN: entityContact.keySet()) WITH SECURITY_ENFORCED];
        for(Case csRecord : caseLists){
            Id entityId;
            if(!(csRecord.affirmations__r).isEmpty() && (entityContact.keySet()).contains(csRecord.Alternate_Entity__c)){
                entityId = csRecord.Alternate_Entity__c;                
            }else if((entityContact.keySet()).contains(csRecord.Entity__c)){
                entityId = csRecord.Entity__c;
            }
            populateMap(entityCaseMap,csRecord.Alternate_Entity__c,csRecord.Id);
            if(csRecord.parent.recordType.DeveloperName == Constants.CASE_RECORD_TYPE_APP_FOR_CERT){
                populateMap(entityCaseMap,entityId,csRecord.parentId);
            }
        }
        conCase = populateConCase(entityContact,entityCaseMap);
        if(!conCase.isEmpty()){
            updateSharingRules(conCase);
        }        
    }
    private static void populateMap(Map<Id,Set<Id>> mapChildSet,Id key,Id value){
        if(mapChildSet.containsKey(key)){
            mapChildSet.get(key).add(value);
        }else{
            mapChildSet.put(key,new Set<Id>{value});
        }
    }
    private static Map<Id,Set<Id>> populateConCase(Map<Id,Set<Id>> entityContact,Map<Id,Set<Id>> entityCaseMap){
        Map<Id,Set<Id>> conCase = new Map<Id,Set<Id>>();
        for(Id entityId:entityContact.keySet()){
            if(entityCaseMap.containsKey(entityId)){
                for(Id conId:entityContact.get(entityId)){
                    if(conCase.containsKey(conId)){
                        conCase.get(conId).addAll(entityCaseMap.get(entityId));
                    }else{
                        conCase.put(conId,entityCaseMap.get(entityId));
                    }
                }
            }            
        }
        return conCase;
    }
    // Wrapper class for getting variables from Process Builder.
    public class ContEntity{
        @InvocableVariable(required=true)
        public Id contactId;
        @InvocableVariable(required=true)
        public Id entityId;
    }
}