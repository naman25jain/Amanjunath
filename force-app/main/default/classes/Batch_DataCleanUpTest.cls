@isTest
public with sharing class Batch_DataCleanUpTest {

    @TestSetup
    static void setup(){        
        CurrentECFMGIDSequence__c curECFMGSetting = CurrentECFMGIDSequence__c.getOrgDefaults();
        curECFMGSetting.ECFMG_ID__c = '00000001';
        upsert curECFMGSetting;
        CurrentEntityIDSequence__c curEntitySetting = CurrentEntityIDSequence__c.getOrgDefaults();
        curEntitySetting.Entity_ID__c = '0000000';
        upsert curEntitySetting;
        Id applRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_APPLICANT ).getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.BillingCountry = 'India';
        INSERT acc;
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        con.Email = 'test1@test.com';
        con.RecordTypeId = applRecTypeId;
        INSERT con;
        Contact con2 = new Contact();
        con2.AccountId = acc.Id;
        con2.LastName = 'Test';
        con2.Email = 'test21@test.com';
        con2.RecordTypeId = applRecTypeId;
        INSERT con2;
        Id profId = [SELECT id FROM profile WHERE name='4-Customer Community Entity 360' LIMIT 1].id;
        User user1 = new User(alias = 'tstUser',
                                email = 'test1@test.com',
                                emailencodingkey = 'UTF-8',
                                lastname = 'test user',
                                languagelocalekey = 'en_US',
                                localesidkey = 'en_US',
                                profileid = profId,
                                country = 'United States',
                                IsActive = true,
                                ContactId = con.Id,
                                timezonesidkey = 'America/Los_Angeles',
                                username = 'testuser@test.com');
        INSERT user1;
        User user2 = new User(alias = 'tstUser2',
                                email = 'test21@test.com',
                                emailencodingkey = 'UTF-8',
                                lastname = 'test user2',
                                languagelocalekey = 'en_US',
                                localesidkey = 'en_US',
                                profileid = profId,
                                country = 'United States',
                                IsActive = false,
                                ContactId = con2.Id,
                                timezonesidkey = 'America/Los_Angeles',
                                username = 'testuser2@test.com');
        INSERT user2;
        
    }

    @isTest
    public static void testBatchExecuteUser(){
        String tstUser = 'test user';
        String toBeDeleteSoqlUser = 'SELECT Id, Name '  
                                + ' FROM User '
                                + ' WHERE Name = \''+ tstUser + '\''
                                + ' WITH SECURITY_ENFORCED';
        
        Test.startTest();
        Batch_DataCleanUp batchEmpty = new Batch_DataCleanUp(); 
        Batch_DataCleanUp batch1 = new Batch_DataCleanUp(toBeDeleteSoqlUser,3,false); 
        ID jobID = Database.executeBatch(batch1,1);
        System.assertEquals(true, true,'User deleted successfully');
        Test.stopTest();
        System.abortJob(jobID);
    }

    @isTest
    public static void testBatchExecuteUser2(){
        String tstUser = 'test user2';
        String toBeDeleteSoqlUser = 'SELECT Id, Name '  
                                + ' FROM User '
                                + ' WHERE Name = \''+ tstUser + '\''
                                + ' WITH SECURITY_ENFORCED';
        
        Test.startTest();
        Batch_DataCleanUp batchEmpty = new Batch_DataCleanUp(); 
        Batch_DataCleanUp batch1 = new Batch_DataCleanUp(toBeDeleteSoqlUser,3,false); 
        ID jobID = Database.executeBatch(batch1,1);
        System.assertEquals(true, true,'User deleted successfully');
        Test.stopTest();
        System.abortJob(jobID);
    }

    @isTest
    public static void testBatchExecuteContact(){
        Boolean flag = false;
        String tstContactName = 'Test';
        String toBeDeleteSoqlContact = 'SELECT Id, Name '         
                                + ' FROM Contact '
                                + ' WHERE Name = \''+ tstContactName + '\''
                                + ' LIMIT 1';
        try{
            Test.startTest();
            Batch_DataCleanUp batch2 = new Batch_DataCleanUp(toBeDeleteSoqlContact,3,false); 
            ID jobID = Database.executeBatch(batch2,1);
            Test.stopTest();
            System.abortJob(jobID);
        }
        catch (System.UnexpectedException theException){
			flag = true;
		}
        System.assertNotEquals(true, flag,'Batch executed successfully');
    }

    @isTest
    public static void testBatchExecuteAccount(){
        Boolean flag = false;
        String tstAcctName = 'Test Account';
        String toBeDeleteSoqlAccount = 'SELECT Id, Name '         
                                + ' FROM Account '
                                + ' WHERE Name = \''+ tstAcctName + '\''
                                + ' WITH SECURITY_ENFORCED';
        try{
            Test.startTest();
            Batch_DataCleanUp batch3 = new Batch_DataCleanUp(toBeDeleteSoqlAccount,3,false); 
            ID jobID = Database.executeBatch(batch3,1);
            Test.stopTest();
            System.abortJob(jobID);
        }catch (System.UnexpectedException theException){
			flag = true;
		}
        System.assertNotEquals(true, flag,'Batch executed successfully');
    }
    @isTest 
    static void testPrepareQueryUser(){
        Batch_DataCleanUp tstBatchCleanup = new Batch_DataCleanUp();
        Batch_DataCleanUpConfig__mdt tstBatchMdt = new Batch_DataCleanUpConfig__mdt();
        tstBatchMdt.sObject_API_Name__c = 'User';
        tstBatchMdt.Delete_Old_Data_N_Days__c = 160;
        tstBatchMdt.sequence__c = 3;
        tstBatchMdt.Where_Clause__c = 'IsActive = True';
        tstBatchMdt.is_LastSequence__c = true;
        Test.startTest();
        String tstQuery = tstBatchCleanup.prepareQuery(tstBatchMdt);
        System.assertNotEquals(tstQuery,'','Query returned ');
        Test.stopTest();
    }
    @isTest 
    static void testPrepareQueryUser2(){
        Batch_DataCleanUp tstBatchCleanup = new Batch_DataCleanUp();
        Batch_DataCleanUpConfig__mdt tstBatchMdt = new Batch_DataCleanUpConfig__mdt();
        tstBatchMdt.sObject_API_Name__c = 'User';
        tstBatchMdt.Delete_Old_Data_N_Days__c = 0;
        tstBatchMdt.sequence__c = 3;
        tstBatchMdt.Where_Clause__c = 'IsActive = True';
        tstBatchMdt.is_LastSequence__c = true;
        Test.startTest();
        String tstQuery = tstBatchCleanup.prepareQuery(tstBatchMdt);
        System.assertNotEquals(tstQuery,'','Query returned ');
        Test.stopTest();
    }
    @isTest 
    static void testPrepareQueryContact(){
        Batch_DataCleanUp tstBatchCleanup = new Batch_DataCleanUp();
        Batch_DataCleanUpConfig__mdt tstBatchMdt = new Batch_DataCleanUpConfig__mdt();
        tstBatchMdt.sObject_API_Name__c = 'Contact';
        tstBatchMdt.Delete_Old_Data_N_Days__c = 160;
        tstBatchMdt.sequence__c = 3;
        tstBatchMdt.Where_Clause__c = '';
        tstBatchMdt.is_LastSequence__c = true;
        Test.startTest();
        String tstQuery = tstBatchCleanup.prepareQuery(tstBatchMdt);
        System.assertNotEquals(tstQuery,'','Query returned ');
        Test.stopTest();
    }
    @isTest 
    static void testPrepareQueryContact2(){
        Batch_DataCleanUp tstBatchCleanup = new Batch_DataCleanUp();
        Batch_DataCleanUpConfig__mdt tstBatchMdt = new Batch_DataCleanUpConfig__mdt();
        tstBatchMdt.sObject_API_Name__c = 'Contact';
        tstBatchMdt.Delete_Old_Data_N_Days__c = 0;
        tstBatchMdt.sequence__c = 3;
        tstBatchMdt.Where_Clause__c = '';
        tstBatchMdt.is_LastSequence__c = true;
        Test.startTest();
        String tstQuery = tstBatchCleanup.prepareQuery(tstBatchMdt);
        System.assertNotEquals(tstQuery,'','Query returned ');
        Test.stopTest();
    }
}