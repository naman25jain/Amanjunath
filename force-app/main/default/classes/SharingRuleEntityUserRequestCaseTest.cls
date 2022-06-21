@isTest
public class SharingRuleEntityUserRequestCaseTest {
    
    @testSetup 
    public static void setup(){
        CurrentECFMGIDSequence__c curECFMGSetting = CurrentECFMGIDSequence__c.getOrgDefaults();
        curECFMGSetting.ECFMG_ID__c = '00000001';
        upsert curECFMGSetting;
        CurrentEntityIDSequence__c curEntitySetting = CurrentEntityIDSequence__c.getOrgDefaults();
        curEntitySetting.Entity_ID__c = '0000000';
        UPSERT curEntitySetting;
    }
    
    //This method will verify the functionality of Case share, We are checking 2 scenarios here,
    //1. If we call this method with proper data and provided case already is not shared wih that particular user. Then, this logic will share the record with that particluar user.
    //2. If we call this method with proper data and provided case already shared wih that particular user. Then, this logic will delet the exisiting share record and update share the sharing with that particluar user.
    @isTest
    public static void verifyUpdateSharingRulesEntityUserRequestCase(){
        Profile p = [SELECT Id, Name FROM Profile WHERE Name =: Constants.Entity_360_USER_PROFILE];
        
        Id entityAccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_ENTITY).getRecordTypeId();
        Id entityConRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_ENTITY_CONTACT).getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.BillingCountry = 'India';
        acc.RecordTypeId = entityAccountRecTypeId;
        INSERT acc;
        
        Contact entityCon = new Contact();
        entityCon.AccountId = acc.Id;
        entityCon.LastName = 'Entity Test';
        entityCon.Email = 'entitytest1@test.com';
        entityCon.RecordTypeId = entityConRecTypeId;
        INSERT entityCon;
        
        Service__c volService = new Service__c(Name='Volume Report Recipients');
        INSERT volService;
        
        Account2Service__c accServ1 = new Account2Service__c(Account__c = acc.Id, Active__c=true, Service__c = volService.Id);
        INSERT accServ1; 
        
        Contact2AcctService__c conAcct1 = new Contact2AcctService__c(Account_Service__c = accServ1.Id, Active__c=true, Service_Contact__c = entityCon.Id, Role__c = 'User', Credential_Type__c = 'Final Medical Diploma');
        INSERT conAcct1;
        
        Id entityUserRequestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENTITY_USER_REQUEST).getRecordTypeId();        
        
        Case objCase = new Case();
        objCase.RecordTypeId = entityUserRequestRecordTypeId;
        objCase.ContactId = entityCon.Id;
        objCase.Source__c = Constants.CASE_SOURCE_COORDINATOR;
        objCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_NEW_SERVICE;
        insert objCase;
        
        
        User u = new User(ContactId = entityCon.Id, Alias = 'standt', Email='standarduser1212@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1211@testorg.com');
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert u;
        }  
        
        Set<Id> caseIdSet = new Set<Id>();
        caseIdSet.add(objCase.Id);
        
        Set<Id> accountIdSet = new Set<Id>();
        accountIdSet.add(acc.Id);
        
        Map<String, Map<Id, Set<Id>>> insServiceAccCaseMap = new Map<String, Map<Id, Set<Id>>>();
        Map<Id, Set<Id>> mapAccCaseMap = new Map<Id, Set<Id>>();
        mapAccCaseMap.put(acc.Id, caseIdSet);
        insServiceAccCaseMap.put(volService.Name, mapAccCaseMap);
        insServiceAccCaseMap.put(volService.Name+'1', mapAccCaseMap);
        
        Map<String, Map<Id, Set<Id>>> delServiceAccCaseMap = new Map<String, Map<Id, Set<Id>>>();
        delServiceAccCaseMap.put(volService.Name, mapAccCaseMap);
        
        //Here, Checking Case should not be shared with the user:Username = 'standarduser1211@testorg.com' with Edit Access.
        List<CaseShare> caseShres  = [SELECT Id FROM CaseShare WHERE CaseId =: objCase.Id AND UserOrGroupId =: u.Id AND CaseAccessLevel = 'Edit'];
        System.assertEquals(caseShres.isEmpty(), true);
        
        //Record will be shared with the user:Username = 'standarduser1211@testorg.com' with Edit Access, Record will not be deleted, becuase there is no share record available
        Test.startTest();
        SharingRuleEntityUserRequestCase.updateSharingRulesEntityUserRequestCase(insServiceAccCaseMap, delServiceAccCaseMap, accountIdSet);
        Test.stopTest();
        
        caseShres  = [SELECT Id FROM CaseShare WHERE CaseId =: objCase.Id AND UserOrGroupId =: u.Id AND CaseAccessLevel = 'Edit'];
        System.assertEquals(caseShres.isEmpty(), false);
        
        //Here, Existing Case share record will be deleted and new Case share record will be inserted in the system.
        SharingRuleEntityUserRequestCase.updateSharingRulesEntityUserRequestCase(insServiceAccCaseMap, delServiceAccCaseMap, accountIdSet);
        caseShres  = [SELECT Id FROM CaseShare WHERE CaseId =: objCase.Id AND UserOrGroupId =: u.Id AND CaseAccessLevel = 'Edit'];
        System.assertEquals(caseShres.isEmpty(), false);

    }
    
}