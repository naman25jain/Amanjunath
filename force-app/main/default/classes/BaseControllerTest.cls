@isTest
private class BaseControllerTest{
    /**
     * * Setup Data (AAA-Arrange)
     */ 
    @testSetup static void setup(){
        // Common Data Setup
        BaseTestFactory.getCustomerCommunityPlusUser();
        BaseTestFactory.getReadOnlyUser();
    }
    @isTest
    static void testGetAllConstantsReturnsNotNull(){
        Constants allConstants = BaseController.getAllConstants();
        System.assertNotEquals(null, allConstants,'Constants is null');
    }
    @isTest
    static void testGetCurrentUserContactIdReturnsNotNull(){
        Id contactId;
        // Get a user who has associated contact
        Profile profile = BaseTestFactory.getProfile(ConstantsTest.TEST_PROFILE_COMMUNITY_LOGIN);
        User runAsUser = [SELECT id, contactId 
                            FROM User 
                            WHERE alias =: ConstantsTest.TEST_USER_ALIAS
                            AND profileId =: profile.id
                            LIMIT 1]; 
        Test.startTest();
        System.runAs(runAsUser) 
        {
            contactId = BaseController.getCurrentUserContactId(runAsUser.Id);
        }
        Test.stopTest();
        System.assertNotEquals(null, contactId,'Contact Id is Null');
    }
    @isTest
    static void testGetCurrentUserContactIdReturnsNull() {
        Id contactId;
        // Fetch Test Community User
        User runAsUser = [SELECT Id FROM User 
                          WHERE Email like '%@unknownmail.com'
                          AND Profile.Name = :ConstantsTest.TEST_PROFILE_COMMUNITY_LOGIN
                          AND IsActive=true LIMIT 1];
        
        Test.startTest();
        System.runAs(runAsUser){
            try{
                contactId = BaseController.getCurrentUserContactId(runAsUser.Id);
            }catch(Exception e){
                System.assertEquals(null, contactId,'Contact Id is Not Null');
            }
        }
        Test.stopTest();
    }

    @isTest
    static void testGetUserIdReturnsNotNull(){
        Id id = BaseController.getUserId();
        System.assertNotEquals(null, id,'User Id is null');
    }
}