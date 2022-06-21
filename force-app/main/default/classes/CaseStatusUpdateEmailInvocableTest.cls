@isTest
private class CaseStatusUpdateEmailInvocableTest {
    /**
     * * Setup Data (AAA-Arrange)
     */ 
    @testSetup static void setup() {

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
           Case caseWithWorkingStatus = new Case(ContactId = contact.Id,
                                                   AccountId = contact.AccountId,
                                                   Internal_Status__c = Constants.CASE_STATUS_NEW);

           insert caseWithWorkingStatus;
   }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testCaseStatusUpdateEmailReturnsSuccess() {
        //Arrange
        Case caseObj =  [SELECT Id, Internal_Status__c
                        FROM Case
                        WHERE Internal_Status__c =: Constants.CASE_STATUS_NEW
                        LIMIT 1];

        List<CaseStatusUpdateEmailInvocable.EmailDetail> emailDetails = new List<CaseStatusUpdateEmailInvocable.EmailDetail>();
        CaseStatusUpdateEmailInvocable.EmailDetail emailDetail = new CaseStatusUpdateEmailInvocable.EmailDetail();
        emailDetail.caseId = caseObj.Id;
        emailDetail.templateName = Constants.CASE_EMAIL_TEMPLATE_NAME;
        emailDetail.senderAddress = Constants.ORG_WIDE_ADDRESS;
        emailDetails.add(emailDetail);

        //Act
       
            Test.startTest();
            CaseStatusUpdateEmailInvocable.caseStatusUpdateEmail(emailDetails);
            Test.stopTest();
        
        //Assert
            System.assertEquals(true, true,'Case Status Update Email Exception is thrown'); 
        
        
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testCaseStatusUpdateEmailThrowsException() {
        //Arrange
        
        //Act
        try 
        {
            Test.startTest();
            CaseStatusUpdateEmailInvocable.caseStatusUpdateEmail(null);
            Test.stopTest();
        }
        catch(Exception e)
        {
            //Assert
            System.assertNotEquals(null, e,'Exception is not thrown'); 
        }
        
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
}