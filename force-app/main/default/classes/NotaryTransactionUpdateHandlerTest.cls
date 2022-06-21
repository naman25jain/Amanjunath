/**
 * Sampath Karnati
 * * Test class for  NotaryTransactionUpdateEventHandler
 */
@isTest
private class NotaryTransactionUpdateHandlerTest {
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
    static void testHandleUpdateEventPayloadUpdatesTransactionStatusToRejected() {
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
        NotaryTransactionUpdateEventHandler.handleUpdateEventPayload(payload);
        Test.stopTest();
         //Assert
        Online_Notary_Transaction__c transactionObjWithUpdatedStatus =  [SELECT Status__C
                                                                        FROM Online_Notary_Transaction__c
                                                                        WHERE Transaction_Id__c =: transactionId
                                                                        LIMIT 1];                                                                            
        System.assertEquals(ConstantsTest.TEST_ONLINE_NOTARY_TRANSACTION_STATUS_REJECTED, transactionObjWithUpdatedStatus.Status__C,'Handle update event payload - Transaction status is updated'); 
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testUpdateTransactionStatusToSuccess(){
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
        string payload = ConstantsTest.TEST_NOTARY_TRANSACTION_UPDATE_SUCCESS_PAYLOAD;
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
        payload = payload.replace('TRANSACTION_ID_PLACEHOLDER', transactionId);
        Product2 pdt1= new Product2();
        pdt1.Name='Id form';
        pdt1.ProductCode= Constants.PRODUCT_CODE_ID_FORM;
        insert pdt1;
       	Asset asst1 = new Asset(Name='newAsset',
            					ContactId= contact.Id,
                                AccountId=contact.AccountId,
                                Case__c=caseObj.Id,
                                Azure_Storage_URL__c=null);
        insert asst1;

        NotaryTransactionUpdateEvent notaryTransactionUpdateEvent = new NotaryTransactionUpdateEvent();
        notaryTransactionUpdateEvent = (NotaryTransactionUpdateEvent)System.JSON.deserialize(payload, NotaryTransactionUpdateEvent.class);

        system.assertEquals('Abc', notaryTransactionUpdateEvent.Data.participants[0].user.firstName, 'FirstName is done'); 
        system.assertEquals('LName', notaryTransactionUpdateEvent.Data.participants[0].user.lastName, 'LastName is done'); 
        system.assertEquals('abcd@ecfmg.org', notaryTransactionUpdateEvent.Data.participants[0].user.email, 'Email is done'); 
        system.assertEquals('test123.pdf', notaryTransactionUpdateEvent.Data.documents[0].name, 'Document name is done');        
        system.assertEquals('https://test-sandbox.notarycam.com/thumbnail/12ac45ce', notaryTransactionUpdateEvent.Data.documents[0].thumbnailURL, 'Document name is done');        
        system.assertEquals('https://redirectUrl.com', notaryTransactionUpdateEvent.Data.participants[0].redirectUrl, 'redirectUrl ');
        system.assertEquals('https://test-sandbox.notarycam.com/signingRoom/12ac/45cd', notaryTransactionUpdateEvent.Data.participants[0].roomUrl, 'Room Url ');  
        system.assertEquals('signer', notaryTransactionUpdateEvent.Data.participants[0].role, 'Room Url ');       
        system.assertEquals('', notaryTransactionUpdateEvent.errorDescription, 'Message  ');

        
        Test.startTest();


        NotaryTransactionUpdateEventHandler.handleUpdateEventPayload(payload);
        Test.stopTest();
        Online_Notary_Transaction__c transactionObjWithUpdatedStatus =  [SELECT Status__C
                                                                        FROM Online_Notary_Transaction__c
                                                                        WHERE Transaction_Id__c =: transactionId
                                                                        LIMIT 1];

        System.assertNotEquals(ConstantsTest.TEST_ONLINE_NOTARY_TRANSACTION_STATUS, transactionObjWithUpdatedStatus.Status__C,'Handle update event payload - Transaction status is not updated');


        
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testHandleRejectionThrowsException() {
        //Arrange
        NotaryTransactionUpdateEvent updateEvent = new NotaryTransactionUpdateEvent();
        //Act
        try 
        {
          Test.startTest();
          NotaryTransactionUpdateEventHandler.handleRejection(updateEvent);
          Test.stopTest();
        }
        catch(Exception e)
          {
              //Assert
              System.assertNotEquals(null, e,'Handle Rejection-Exception is not thrown'); 
          }
      }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testHandleCompleteSuccessThrowsException()
    { 
        NotaryTransactionUpdateEvent updateEvent = new NotaryTransactionUpdateEvent();
        try
        {
            Test.startTest();
            NotaryTransactionUpdateEventHandler.handleCompleteSuccess(updateEvent);
            Test.stopTest();
        }
        catch(Exception e)
        {
			System.assertNotEquals(null, e,'No complete success exception thrown');
        }
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testHandleEventsThrowsException() {
        //Arrange
        
        //Act
        try 
        {
          Test.startTest();
          NotaryTransactionUpdateEventHandler.handleUpdate(null);
          Test.stopTest();
        }
        catch(Exception e)
          {
              //Assert
              System.assertNotEquals(null, e,'Handle Events-Exception is not thrown'); 
          }
      }
    ///////////////////////////////////////////////////////////////////////////////////////////////////////// 
    @isTest
    static void testUpdateTransactionStatusToInProgress(){
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
        string payload = ConstantsTest.TEST_NOTARY_TRANSACTION_UPDATE_SUCCESS_PAYLOAD_IN_PROGRESS;
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
        payload = payload.replace('TRANSACTION_ID_PLACEHOLDER', transactionId);
        Product2 pdt1= new Product2();
        pdt1.Name='Id form';
        pdt1.ProductCode= Constants.PRODUCT_CODE_ID_FORM;
        insert pdt1;
       	Asset asst1 = new Asset(Name='newAsset',
            					ContactId= contact.Id,
                                AccountId=contact.AccountId,
                                Case__c=caseObj.Id,
                                Azure_Storage_URL__c=null);
        insert asst1;

        NotaryTransactionUpdateEvent notaryTransactionUpdateEvent = new NotaryTransactionUpdateEvent();
        notaryTransactionUpdateEvent = (NotaryTransactionUpdateEvent)System.JSON.deserialize(payload, NotaryTransactionUpdateEvent.class);
        
        Test.startTest();
        NotaryTransactionUpdateEventHandler.handleUpdateEventPayload(payload);
        Test.stopTest();
        Online_Notary_Transaction__c transactionObjWithUpdatedStatus =  [SELECT Status__C
                                                                        FROM Online_Notary_Transaction__c
                                                                        WHERE Transaction_Id__c =: transactionId
                                                                        LIMIT 1];

        System.assertEquals(ConstantsTest.API_STATUS_IN_PROGRESS, transactionObjWithUpdatedStatus.Status__C,'Handle update event payload - Transaction status is updated');        
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////    
}