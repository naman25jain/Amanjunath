/**
 * Sampath Karnati
 * * Test class for NotaryTransactionResponseEventTrigger
 */
@isTest
private class NotaryTransactionResponseTriggerTest {
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
                                                   Internal_Status__c = ConstantsTest.TEST_CASE_STATUS_NEW);

           insert caseWithWorkingStatus;
   }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testNotaryTransactionResponseEventReturnsOneEventPublished() {
        //Arrange
        string payload = ConstantsTest.TEST_NOTARY_TRANSACTION_RESPONSE_PAYLOAD;

        Case caseObj =  [SELECT Id, Internal_Status__c
                        FROM Case
                        WHERE Internal_Status__c =: ConstantsTest.TEST_CASE_STATUS_NEW
                        LIMIT 1];

        //Replace case id placeholder from the payload with id from caseObj, we will use this case to assert
          payload = payload.replace('CASE_ID_PLACEHOLDER', caseObj.Id);

      //Act
          Test.startTest();
          Notary_Transaction_Response_Event__e notaryTransactionResponseEvent = new Notary_Transaction_Response_Event__e(Payload__c = payload);
          // Publish test event
          EventBusWrapper.publish(notaryTransactionResponseEvent);
          Test.stopTest();

      //Assert
       System.assertEquals(1, EventBusWrapper.eventList.size(), 'More than one event is published' );
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testNotaryTransactionResponseEventUpdatesCaseStatus() {
        //Arrange
        string payload = ConstantsTest.TEST_NOTARY_TRANSACTION_RESPONSE_PAYLOAD;

        Case caseObj =  [SELECT Id, Internal_Status__c
                        FROM Case
                        WHERE Internal_Status__c =: ConstantsTest.TEST_CASE_STATUS_NEW
                        LIMIT 1];

        //Replace case id placeholder from the payload with id from caseObj, we will use this case to assert
        payload = payload.replace('CASE_ID_PLACEHOLDER', caseObj.Id);

      //Act
          Test.startTest();
          Notary_Transaction_Response_Event__e notaryTransactionResponseEvent = new Notary_Transaction_Response_Event__e(Payload__c = payload);
          // Publish test event
          EventBusWrapper.publish(notaryTransactionResponseEvent);
          Test.stopTest();

      //Assert
        Case caseObjWithUpdatedStatus =  [SELECT Internal_Status__c
                                          FROM Case
                                          WHERE Id =: caseObj.Id
                                          LIMIT 1];
        System.assertEquals(Constants.CASE_STATUS_ONLINE_NOTARY_SESSION_CREATED, caseObjWithUpdatedStatus.Internal_Status__c,'Notary transaction response event trigger - Case status is not updated'); 
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
}