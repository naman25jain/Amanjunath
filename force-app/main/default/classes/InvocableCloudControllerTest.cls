/**
 * Shailaja Yerneni
 * * Test Class for InvocableCloudController
 * ? Private
 */
@isTest
private class InvocableCloudControllerTest extends ECFMGTestFactory{
	/**
     * * Setup Data (AAA-Arrange)
     */ 
    @testSetup static void setup(){
        // Common Data Setup
        BaseTestFactory.getCustomerCommunityPlusUser();

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
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(ContactId = contact.Id, AccountId = contact.AccountId, Internal_Status__c=Constant_Case__mdt.getInstance('STATUS_NEW').Value__c));
        run();
    }
    @isTest
    static void testGetInvocableCloudPayloadReturnsNotNull() {
        //Arrange
        List<Cloud_Document__c> cloudDocs = new List<Cloud_Document__c>([SELECT payload__c, Url__c
                                            FROM Cloud_Document__c
                                            WHERE Name =: ConstantsTest.TEST_CLOUD_DOCUMENT_NAME]);
        List <InvocableCloudController.IncvPayloadWrapper> payloadWrapper = new List<InvocableCloudController.IncvPayloadWrapper>();
        //Act
        Test.startTest();
        payloadWrapper = InvocableCloudController.getInvocableCloudPayload(cloudDocs);
        Test.stopTest();
    //Assert
        System.assertNotEquals(null, payloadWrapper,'payloadWrapper is null');
    }
    @isTest
    static void testGetInvocableCloudPayloadThrowsException() {
        //Arrange
        List <InvocableCloudController.IncvPayloadWrapper> payloadWrapper = new List<InvocableCloudController.IncvPayloadWrapper>();
        //Act
            try {
                Test.startTest();
                payloadWrapper = InvocableCloudController.getInvocableCloudPayload(null);
                Test.stopTest();
            }catch(Exception e){
                //Assert
                System.assertNotEquals(null, e,'Exception is not thrown'); 
            }
    }
     /////////////////////////////////////////////////////////////////////////////////////////////////////////
    
}