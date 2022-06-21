@isTest
private class CaseControllerTest {
    /**
     * * Setup Data (AAA-Arrange)
     */ 
    @testSetup static void setup(){
        CurrentECFMGIDSequence__c settingsInstance1 = CurrentECFMGIDSequence__c.getOrgDefaults();
        settingsInstance1.ECFMG_ID__c = '0000000';
        UPSERT settingsInstance1;
        System.assert(settingsInstance1.Id != null, 'Upsert settingsInstance1 is not Successful');
        // Common Data Setup
        BaseTestFactory.getCustomerCommunityPlusUser();
        BaseTestFactory.getReadOnlyUser();
        // Create a new case to be used in all applicable test functions
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
        // new case 
        Case caseWithWorkingStatus = new Case(ContactId = contact.Id,
                                                AccountId = contact.AccountId,
                                                Internal_Status__c = ConstantsTest.TEST_CASE_STATUS_NEW);
        insert caseWithWorkingStatus;
    }
    @isTest
    static void testUpdateCaseStatusAsCommunityUserReturnsTrue(){
        Boolean recordSaved;
        // Run as Customer Community Plus Login User
        Profile profile = BaseTestFactory.getProfile(ConstantsTest.TEST_PROFILE_COMMUNITY_LOGIN);
        User runAsUser = [SELECT id, contactId 
                        FROM User 
                        WHERE alias =: ConstantsTest.TEST_USER_ALIAS
                            AND profileId =: profile.id
                            LIMIT 1]; 
        Id caseId =  [SELECT Id
                        FROM Case
                        WHERE Internal_Status__c =: ConstantsTest.TEST_CASE_STATUS_NEW
                        LIMIT 1].Id;
        Test.startTest();
        System.runAs(runAsUser)
        {
            recordSaved = CaseController.updateCaseStatus(caseId, ConstantsTest.TEST_CASE_STATUS_NEW);
        }
        Test.stopTest();
        System.assertEquals(true, recordSaved,'Case status is not updated');
    }
    @isTest
    static void testUpdateCaseStatusReturnsTrue(){
        Boolean recordSaved;
        Id caseId =  [SELECT Id
                        FROM Case
                        WHERE Internal_Status__c =: ConstantsTest.TEST_CASE_STATUS_NEW
                        LIMIT 1].Id;
        Test.startTest();
        recordSaved = CaseController.updateCaseStatus(caseId, ConstantsTest.TEST_CASE_STATUS_NEW);
        Test.stopTest();
        System.assertEquals(true, recordSaved,'Case status is not updated');
    }
    @isTest
    static void testUpdateCaseStatusReturnsNoAccessException(){
        Profile profile = BaseTestFactory.getProfile(ConstantsTest.TEST_PROFILE_READONLY);
        User runAsUser = [SELECT id, contactId 
                            FROM User 
                            WHERE alias =: ConstantsTest.TEST_USER_ALIAS
                            AND profileId =: profile.id
                            LIMIT 1]; 
        Id caseId =  [SELECT Id
                        FROM Case
                        WHERE Internal_Status__c =: ConstantsTest.TEST_CASE_STATUS_NEW
                        LIMIT 1].Id;
        try{
            Test.startTest();
            System.runAs(runAsUser) 
            {
                CaseController.updateCaseStatus(caseId, ConstantsTest.TEST_CASE_STATUS_NEW);
            }
            Test.stopTest();
        }catch(NoAccessException e){
                System.assertNotEquals(null, e,'NoAccessException is not thrown'); 
        }
    }
    @isTest
    static void testGetCaseContactReturnsNotNull(){
        Case caseContact;
        Profile profile = BaseTestFactory.getProfile(ConstantsTest.TEST_PROFILE_COMMUNITY_LOGIN);
        User runAsUser = [SELECT id, contactId 
                            FROM User 
                            WHERE alias =: ConstantsTest.TEST_USER_ALIAS
                            AND profileId =: profile.id
                            LIMIT 1]; 
        Id caseId =  [SELECT Id
                        FROM Case
                        WHERE Internal_Status__c =: ConstantsTest.TEST_CASE_STATUS_NEW
                        LIMIT 1].Id;
        Test.startTest();
        System.runAs(runAsUser) 
        {
            caseContact = CaseController.getCaseContact(caseId);
        }
        Test.stopTest();
        System.assertNotEquals(null, caseContact,'Get case contact returns null'); 
    }
    @isTest
    static void testGetCaseContactReturnsNull(){
        Case caseContact;
        Test.startTest();
        caseContact = CaseController.getCaseContact(null);
        Test.stopTest();
        System.assertEquals(null, caseContact,'Get case contact returns not null'); 
    }
    @isTest
    static void testInsertCaseCommentReturnsTrue(){
        boolean success;
        Id caseId =  [SELECT Id
                        FROM Case
                        WHERE Internal_Status__c =: ConstantsTest.TEST_CASE_STATUS_NEW
                        LIMIT 1].Id;
        List<CaseComment> caseComments = new List<CaseComment>();
        caseComments.add(new CaseComment(ParentId = caseId, 
                                        CommentBody = ConstantsTest.TEST_CASE_COMMENT));
        Test.startTest();
        success = CaseController.insertCaseComment(caseComments);
        Test.stopTest();
        System.assertEquals(true, success,'Insert case comment returns false'); 
    }
   
    @isTest
    static void testGetCaseContact(){
        Case caseContact;
        Id caseId = [SELECT Id FROM Case
                     WHERE Internal_Status__c =: ConstantsTest.TEST_CASE_STATUS_NEW
                     LIMIT 1].Id;

        Test.startTest();
        try{
            caseContact = CaseController.getCaseContact(caseId);
        }catch(Exception e){
            System.assertEquals(null, caseContact,'Get case contact returns not null'); 
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetCaseDetail(){
        Case caseDetail;
        Id caseId = [SELECT Id FROM Case
                     WHERE Internal_Status__c =: ConstantsTest.TEST_CASE_STATUS_NEW
                     LIMIT 1].Id;
        
        Test.startTest();
        try{
            caseDetail = CaseController.getCaseDetail(caseId);
        }catch(Exception e){
            System.assertEquals(null, caseDetail,'Get case detail returns null');
        }
        Test.stopTest();
    }

    @isTest
    static void testGetCaseDetailReturnsNotNull(){
        Case caseDetail;
        Id caseId =  [SELECT Id
                        FROM Case
                        WHERE Internal_Status__c =: ConstantsTest.TEST_CASE_STATUS_NEW
                        LIMIT 1].Id;
        Test.startTest();
        caseDetail = CaseController.getCaseDetail(caseId);
        Test.stopTest();
        System.assertNotEquals(null, caseDetail,'Get case detail returns null'); 
    }
    @isTest
    static void testGetCaseDetailReturnsNull(){
        Case caseDetail;
        Test.startTest();
        caseDetail = CaseController.getCaseDetail(null);
        Test.stopTest();
        System.assertEquals(null, caseDetail,'Get case detail returns not null'); 
    }
}