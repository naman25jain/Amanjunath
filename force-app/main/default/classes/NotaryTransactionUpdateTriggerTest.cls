/**
 * Sampath Karnati
 * * Test class for  NotaryTransactionUpdateEventTrigger
 */
@isTest
private class NotaryTransactionUpdateTriggerTest {
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
    static void testNotaryTransactionUpdateEventReturnsOneEventPublished() {
        //Arrange
        string payload = ConstantsTest.TEST_NOTARY_TRANSACTION_UPDATE_REJECT_PAYLOAD;

        Case caseObj =  [SELECT Id, Internal_Status__c
                        FROM Case
                        WHERE Internal_Status__c =: ConstantsTest.TEST_CASE_STATUS_NEW
                        LIMIT 1];

        Online_Notary_Transaction__c onlineNotaryTransaction = new Online_Notary_Transaction__c(Signing_Session_Url__c = ConstantsTest.TEST_ONLINE_NOTARY_TRANSACTION_SIGNING_SESSION_URL,
                                                                                                Case__c = caseObj.Id,
                                                                                                Status__c = ConstantsTest.TEST_ONLINE_NOTARY_TRANSACTION_STATUS,
                                                                                                Transaction_ID__c = ConstantsTest.TEST_ONLINE_NOTARY_TRANSACTION_ID);

        insert onlineNotaryTransaction;

        string transactionId =  [SELECT Transaction_Id__c
                                  FROM Online_Notary_Transaction__c
                                  WHERE Case__c =: caseObj.Id
                                  LIMIT 1].Transaction_Id__c;

        //Replace case id placeholder from the payload with id from notaryRelatedToCase, we will use this transaction to assert
        payload = payload.replace('TRANSACTION_ID_PLACEHOLDER', transactionId);

      //Act
          Test.startTest();
          Notary_Transaction_Update_Event__e notaryTransactionUpdateEvent = new Notary_Transaction_Update_Event__e(Payload__c = payload);
          // Publish test event
          EventBusWrapper.publish(notaryTransactionUpdateEvent);
          Test.stopTest();

      //Assert
       System.assertEquals(1, EventBusWrapper.eventList.size(), 'More than one event is published' );
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testNotaryTransactionResponseEventUpdatesTransactionStatus() {
        //Arrange
        string payload = ConstantsTest.TEST_NOTARY_TRANSACTION_UPDATE_REJECT_PAYLOAD;

        Case caseObj =  [SELECT Id, Internal_Status__c
                        FROM Case
                        WHERE Internal_Status__c =: ConstantsTest.TEST_CASE_STATUS_NEW
                        LIMIT 1];

        Online_Notary_Transaction__c onlineNotaryTransaction = new Online_Notary_Transaction__c(Signing_Session_Url__c = ConstantsTest.TEST_ONLINE_NOTARY_TRANSACTION_SIGNING_SESSION_URL,
                                                                                                Case__c = caseObj.Id,
                                                                                                Status__c = ConstantsTest.TEST_ONLINE_NOTARY_TRANSACTION_STATUS,
                                                                                                Transaction_ID__c = ConstantsTest.TEST_ONLINE_NOTARY_TRANSACTION_ID);

        insert onlineNotaryTransaction;

        string transactionId =  [SELECT Transaction_Id__c
                                  FROM Online_Notary_Transaction__c
                                  WHERE Case__c =: caseObj.Id
                                  LIMIT 1].Transaction_Id__c;

        //Replace case id placeholder from the payload with id from notaryRelatedToCase, we will use this transaction to assert
        payload = payload.replace('TRANSACTION_ID_PLACEHOLDER', transactionId);

      //Act
        Test.startTest();
        Notary_Transaction_Update_Event__e notaryTransactionUpdateEvent = new Notary_Transaction_Update_Event__e(Payload__c = payload);
        // Publish test event
        EventBusWrapper.publish(notaryTransactionUpdateEvent);
        Test.stopTest();

      //Assert
      Online_Notary_Transaction__c transactionObjWithUpdatedStatus =  [SELECT Status__C
                                                                        FROM Online_Notary_Transaction__c
                                                                        WHERE Transaction_Id__c =: transactionId
                                                                        LIMIT 1];

      System.assertEquals(ConstantsTest.TEST_ONLINE_NOTARY_TRANSACTION_STATUS_REJECTED, transactionObjWithUpdatedStatus.Status__C,'Publish Notary Transaction Update Event - Transaction status is updated'); 
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
}