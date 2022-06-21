@isTest
private class AccountTriggerHelperTest {
    
    private static CurrentEntityIDSequence__c settingsInstance;
    /**
* * Setup Data (AAA-Arrange)
*/ 
    @testSetup static void setup(){
        //Common Data Setup
        BaseTestFactory.getCustomerCommunityPlusUser();
        
        Profile profile = BaseTestFactory.getProfile(ConstantsTest.TEST_PROFILE_COMMUNITY_LOGIN);
        User user = [SELECT id, contactId 
                     FROM User 
                     WHERE alias =: ConstantsTest.TEST_USER_ALIAS
                     AND profileId =: profile.id
                     LIMIT 1];
        Contact contact = [SELECT id, AccountId 
                           FROM Contact 
                           WHERE Id =: user.contactId
                           LIMIT 1];
        
        
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest()
    static void testBeforeInsertHelperSuccess() {
        // Setup()
        Id entityRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_ENTITY).getRecordTypeId();                    // new Account 
        Account testAccount = new Account(Name =ConstantsTest.TEST_ENTITY_ACCOUNT_NAME, RecordTypeId = entityRTId,School__c=true, BillingCountry='United States', Phone='122354', BillingState = 'California', BillingPostalCode = '12345');
        insert testAccount;
        List<Account> tstNewAccounts = new List<Account>([SELECT Id, Name, RecordTypeId, Entity_ID__c,WDOMS_ID__c,School__c,BillingCountry
                                                          FROM Account
                                                          WHERE Name =: ConstantsTest.TEST_ENTITY_ACCOUNT_NAME]);
        /*WDOMS_ID_Sequence__c wdomsIdSeq = new WDOMS_ID_Sequence__c(); 
        wdomsIdSeq.School_ID__c=0; 
        insert wdomsIdSeq;*/
        Map<id,Account> oldmap = new Map<id,Account>();
        Map<id,Account> newmap = new Map<id,Account>();
        oldmap.put(testAccount.id, testAccount);
        //Act
        Test.startTest();
        AccountTriggerHelper.beforeInsertHelper(tstNewAccounts);
        Account acc=[SELECT Id, Name, RecordTypeId, Entity_ID__c,WDOMS_ID__c,School__c,BillingCountry
                                                          FROM Account
                                                          WHERE Id=:testAccount.Id];
        update acc; 
        newmap.put(acc.Id, acc);
        AccountTriggerHelper.raiseAdditionalWDOMSPlatformEvents(testAccount.Id);
        AccountTriggerHelper.afterUpdateHelper(tstNewAccounts,newmap);
        Test.stopTest();
        //Assert
        System.assert(tstNewAccounts.size() != 0, 'Account created successfully');
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest    
    static void testBeforeInsertHelperFailure() {
        // Setup()
        Id entityRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_ENTITY).getRecordTypeId();                    // new Account 
        Account testAccount = new Account(Name =ConstantsTest.TEST_ENTITY_ACCOUNT_NAME, RecordTypeId = entityRTId,School__c=true, BillingCountry='United States', BillingState = 'California', BillingPostalCode = '12345');
        insert testAccount;
        List<Account> tstNewAccounts = new List<Account>([SELECT Id, Name, RecordTypeId, Entity_ID__c,WDOMS_ID__c,School__c,BillingCountry
                                                          FROM Account
                                                          WHERE Name =: ConstantsTest.TEST_ENTITY_ACCOUNT_NAME]);
        Map<id,Account> oldmap = new Map<id,Account>();
        Map<id,Account> newmap = new Map<id,Account>();
        oldmap.put(testAccount.id, testAccount);
        //Act
        Test.startTest();
        AccountTriggerHelper.beforeInsertHelper(tstNewAccounts);
        Account acc=[SELECT Id, Name, RecordTypeId, Entity_ID__c,WDOMS_ID__c,School__c,BillingCountry
                                                          FROM Account
                                                          WHERE Id=:testAccount.Id];
        update acc; 
        newmap.put(acc.Id, acc);
        AccountTriggerHelper.raiseAdditionalWDOMSPlatformEvents(testAccount.Id);
        AccountTriggerHelper.afterUpdateHelper(tstNewAccounts,newmap);
        Test.stopTest();
        //Assert
        System.assertEquals(tstNewAccounts.size(),1, 'Account creation failed');
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}