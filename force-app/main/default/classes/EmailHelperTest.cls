/**
 * Sampath Karnati
 * * Test Helper class to send email from apex
 * ? Exposed as Public
 */
@isTest
private class EmailHelperTest {
//     /**
//      * * Setup Data (AAA-Arrange)
//      */ 
//     @testSetup static void setup() {

//         // Common Data Setup
//            BaseTestFactory.getCustomerCommunityPlusUser();

//            // Create a new case to be used in all applicable test functions
//            Profile profile = BaseTestFactory.getProfile(ConstantsTest.TEST_PROFILE_COMMUNITY_LOGIN);

//            User user = [SELECT id, contactId 
//                            FROM User 
//                            WHERE alias =: ConstantsTest.TEST_USER_ALIAS
//                            AND profileId =: profile.id
//                            LIMIT 1];
                           
//            Contact contact = [SELECT id, AccountId 
//                                FROM Contact 
//                                WHERE Id =: user.contactId
//                                LIMIT 1];
//            // new case 
//            Case caseForEmail = new Case(ContactId = contact.Id,
//                                         AccountId = contact.AccountId,
//                                         Status = ConstantsTest.TEST_CASE_STATUS_WORKING,
//                                         ECFMG_Portal_Case_Url__c = ConstantsTest.TEST_ECFMG_PORTAL_CASE_URL);
                   
//            insert caseForEmail;

//            //Email Template
//            EmailTemplate emailTemplate = new EmailTemplate(DeveloperName = ConstantsTest.TEST_EMAIL_TEMPLATE_NAME,
//                                                             HtmlValue = ConstantsTest.TEST_EMAIL_TEMPLATE_HTML);

//            insert emailTemplate;

//            //Org Wide address to send emails
//            OrgWideEmailAddress orgWideEmailAddress = new OrgWideEmailAddress(Address = ConstantsTest.TEST_ORG_WIDE_EMAIL_ADDRESS,
//                                                                              DisplayName = ConstantsTest.TEST_ORG_WIDE_EMAIL_DISPLAY_NAME);
//    }
//    /////////////////////////////////////////////////////////////////////////////////////////////////////////
//    @isTest
//    static void testcaseStatusUpdateEmailReturnsTrue() {
//        //Arrange
//            Integer invocations;
           
//            Profile profile = BaseTestFactory.getProfile(ConstantsTest.TEST_PROFILE_COMMUNITY_LOGIN);

//            User runAsUser = [SELECT id, contactId 
//                            FROM User 
//                            WHERE alias =: ConstantsTest.TEST_USER_ALIAS
//                            AND profileId =: profile.id
//                            LIMIT 1]; 

//             Case caseObj =  [SELECT Id 
//                              FROM Case
//                             WHERE Status =: ConstantsTest.TEST_CASE_STATUS_WORKING
//                             LIMIT 1];

//        //Act
//            Test.startTest();
//            System.runAs(runAsUser) {
//            EmailHelper.caseStatusUpdateEmail(caseObj.Id, 
//                                              ConstantsTest.TEST_EMAIL_TEMPLATE_NAME,
//                                              ConstantsTest.TEST_ORG_WIDE_EMAIL_DISPLAY_NAME);

//            invocations = Limits.getEmailInvocations();
//            }
//            Test.stopTest();
       
//        //Assert
//            System.assertEquals(1, invocations, 'Case status update email has not been sent');
//    }
   /////////////////////////////////////////////////////////////////////////////////////////////////////////
}