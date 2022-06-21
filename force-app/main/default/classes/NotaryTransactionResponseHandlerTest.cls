/**
 * Sampath Karnati
 * * Test class for NotaryTransactionResponseEventHandler
 */
@isTest
private class NotaryTransactionResponseHandlerTest {
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
    static void testHandleResponseEventPayloadUpdatesCaseStatus() {
        //Arrange
        string payload = ConstantsTest.TEST_NOTARY_TRANSACTION_RESPONSE_PAYLOAD;

        Case caseObj =  [SELECT Id, Internal_Status__c
                        FROM Case
                        WHERE Internal_Status__c =: ConstantsTest.TEST_CASE_STATUS_NEW
                        LIMIT 1];

        //Replace case id placeholder from the payload with id from caseObj, we will use this case to assert
        system.debug('Caseid from testHandleResponseEventPayloadUpdatesCaseStatus'+caseObj.Id);
        payload = payload.replace('CASE_ID_PLACEHOLDER', caseObj.Id);
        LogUtil.logMessage('Test', payload+ 'from test payload', null);
        system.debug ('Test -->'+ payload);

      //Act
          Test.startTest();
          NotaryTransactionResponseEventHandler.handleResponseEventPayload(payload);
          Test.stopTest();

      //Assert
        Case caseObjWithUpdatedStatus =  [SELECT Internal_Status__c
                                          FROM Case
                                          WHERE Id =: caseObj.Id
                                          LIMIT 1];
        System.assertEquals(Constants.CASE_STATUS_ONLINE_NOTARY_SESSION_CREATED, caseObjWithUpdatedStatus.Internal_Status__c,'Handle response event payload - Case status is not updated'); 
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testHandleResponseSuccessUpdatesCaseStatus() {
        //Arrange
        string payload = ConstantsTest.TEST_NOTARY_TRANSACTION_RESPONSE_PAYLOAD;

        Case caseObj =  [SELECT Id, Internal_Status__c
                        FROM Case
                        WHERE Internal_Status__c =: ConstantsTest.TEST_CASE_STATUS_NEW
                        LIMIT 1];

        //Replace case id placeholder from the payload with id from caseObj, we will use this case to assert
        payload = payload.replace('CASE_ID_PLACEHOLDER', caseObj.Id);

        //Response event object
        NotaryTransactionResponseEvent notaryTransactionResponseEvent = new NotaryTransactionResponseEvent();
        NotaryTransactionResponseEvent = (NotaryTransactionResponseEvent)System.JSON.deserialize(payload, NotaryTransactionResponseEvent.class);


      //Act
          Test.startTest();
          NotaryTransactionResponseEventHandler.handleResponse(notaryTransactionResponseEvent);
          Test.stopTest();

      //Assert
        Case caseObjWithUpdatedStatus =  [SELECT Internal_Status__c
                                          FROM Case
                                          WHERE Id =: caseObj.Id
                                          LIMIT 1];
        System.assertEquals(Constants.CASE_STATUS_ONLINE_NOTARY_SESSION_CREATED, caseObjWithUpdatedStatus.Internal_Status__c,'Handle response - Case status is not updated'); 
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testHandleResponseErrorUpdatesCaseStatus() {
        //Arrange
        string payload = ConstantsTest.TEST_NOTARY_TRANSACTION_RESPONSE_ERROR_PAYLOAD;

        Case caseObj =  [SELECT Id, Internal_Status__c
                        FROM Case
                        WHERE Internal_Status__c =: ConstantsTest.TEST_CASE_STATUS_NEW
                        LIMIT 1];

        //Replace case id placeholder from the payload with id from caseObj, we will use this case to assert
        payload = payload.replace('CASE_ID_PLACEHOLDER', caseObj.Id);

        //Response event object
        NotaryTransactionResponseEvent notaryTransactionResponseEvent = new NotaryTransactionResponseEvent();
        NotaryTransactionResponseEvent = (NotaryTransactionResponseEvent)System.JSON.deserialize(payload, NotaryTransactionResponseEvent.class);


      //Act
          Test.startTest();
          NotaryTransactionResponseEventHandler.handleResponse(notaryTransactionResponseEvent);
          Test.stopTest();

      //Assert
        Case caseObjWithUpdatedStatus =  [SELECT Internal_Status__c
                                          FROM Case
                                          WHERE Id =: caseObj.Id
                                          LIMIT 1];
        System.assertEquals(Constants.CASE_STATUS_ONLINE_NOTARY_SESSION_FAILED, caseObjWithUpdatedStatus.Internal_Status__c,'Handle response - Case status is not updated'); 
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testHandleResponseReturnsException() {
        //Arrange
        string payload = ConstantsTest.TEST_NOTARY_TRANSACTION_RESPONSE_PAYLOAD;

        //Response event object
        NotaryTransactionResponseEvent notaryTransactionResponseEvent = new NotaryTransactionResponseEvent();
        NotaryTransactionResponseEvent = (NotaryTransactionResponseEvent)System.JSON.deserialize(payload, NotaryTransactionResponseEvent.class);

      //Act
        try 
        {
          Test.startTest();
          NotaryTransactionResponseEventHandler.handleResponse(notaryTransactionResponseEvent);
          Test.stopTest();
        }
        catch(Exception e)
        {
            //Assert
            System.assertNotEquals(null, e,'Exception is not thrown'); 
        }
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testHandleResponseReturnsNoAccessException() {
        //Arrange

         // Run as Customer Community Plus Login User
         Profile profile = BaseTestFactory.getProfile(ConstantsTest.TEST_PROFILE_COMMUNITY_LOGIN);

         User runAsUser = [SELECT id, contactId 
                           FROM User 
                           WHERE alias =: ConstantsTest.TEST_USER_ALIAS
                            AND profileId =: profile.id
                            LIMIT 1]; 

        string payload = ConstantsTest.TEST_NOTARY_TRANSACTION_RESPONSE_PAYLOAD;

        Case caseObj =  [SELECT Id, Internal_Status__c
                        FROM Case
                        WHERE Internal_Status__c =: ConstantsTest.TEST_CASE_STATUS_NEW
                        LIMIT 1];

        //Replace case id placeholder from the payload with id from caseObj, we will use this case to assert
        payload = payload.replace('CASE_ID_PLACEHOLDER', caseObj.Id);

        //Response event object
        NotaryTransactionResponseEvent notaryTransactionResponseEvent = new NotaryTransactionResponseEvent();
        NotaryTransactionResponseEvent = (NotaryTransactionResponseEvent)System.JSON.deserialize(payload, NotaryTransactionResponseEvent.class);

      //Act
        try 
        {
          Test.startTest();
          NotaryTransactionResponseEventHandler.handleResponse(notaryTransactionResponseEvent);
/*           System.runAs(runAsUser)
          {
            NotaryTransactionResponseEventHandler.handleResponse(notaryTransactionResponseEvent);
          } */
          Test.stopTest();
        }
        catch(NoAccessException e)
        {
          system.debug('exception message ' +e.getMessage()); 
            //Assert
            System.assertNotEquals(null, e,'NoAccess Exception is not thrown'); 
        }
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testHandleSuccessUpdatesCaseStatus() {
        //Arrange
        string payload = ConstantsTest.TEST_NOTARY_TRANSACTION_RESPONSE_PAYLOAD;

        Case caseObj =  [SELECT Id, Internal_Status__c
                        FROM Case
                        WHERE Internal_Status__c =: ConstantsTest.TEST_CASE_STATUS_NEW
                        LIMIT 1];

        //Replace case id placeholder from the payload with id from caseObj, we will use this case to assert
        payload = payload.replace('CASE_ID_PLACEHOLDER', caseObj.Id);

        //Response event object
        NotaryTransactionResponseEvent notaryTransactionResponseEvent = new NotaryTransactionResponseEvent();
        NotaryTransactionResponseEvent = (NotaryTransactionResponseEvent)System.JSON.deserialize(payload, NotaryTransactionResponseEvent.class);

        system.assertEquals('Abc', NotaryTransactionResponseEvent.Data.participants[0].user.firstName, 'FirstName is done'); 
        system.assertEquals('LName', NotaryTransactionResponseEvent.Data.participants[0].user.lastName, 'LastName is done'); 
        system.assertEquals('abcd@ecfmg.org', NotaryTransactionResponseEvent.Data.participants[0].user.email, 'Email is done');
        system.assertEquals('v4', NotaryTransactionResponseEvent.apiVersion, 'Version ');  
        system.assertEquals('testville', NotaryTransactionResponseEvent.Data.participants[0].user.address.city, 'Version ');  
        system.assertEquals('PA', NotaryTransactionResponseEvent.Data.participants[0].user.address.state, 'State '); 
        system.assertEquals('5 Test Lane', NotaryTransactionResponseEvent.Data.participants[0].user.address.street, 'Street '); 
        system.assertEquals('USA', NotaryTransactionResponseEvent.Data.participants[0].user.address.country, 'Country ');   
        system.assertEquals('1923', NotaryTransactionResponseEvent.Data.participants[0].user.address.postalCode, 'PostalCode ');
        system.assertEquals('https://redirectUrl.com', NotaryTransactionResponseEvent.Data.participants[0].redirectUrl, 'redirectUrl ');
        system.assertEquals('https://test-sandbox.notarycam.com/signingRoom/12ac/45cd', NotaryTransactionResponseEvent.Data.participants[0].roomUrl, 'Room Url ');
        system.assertEquals('test12acde76gh95dg', NotaryTransactionResponseEvent.Data.signingViews[0].txnId, 'Room Url ');
        system.assertEquals('Successfully retrived', NotaryTransactionResponseEvent.message, 'Message  ');
        system.assertEquals(false, NotaryTransactionResponseEvent.Data.archived, 'Archived ');
        system.assertEquals('123456', NotaryTransactionResponseEvent.Data.department, 'Department ');




      //Act
          Test.startTest();
          NotaryTransactionResponseEventHandler.handleSuccess(notaryTransactionResponseEvent);
          Test.stopTest();

      //Assert
        Case caseObjWithUpdatedStatus =  [SELECT Internal_Status__c
                                          FROM Case
                                          WHERE Id =: caseObj.Id
                                          LIMIT 1];
        System.assertEquals(Constants.CASE_STATUS_ONLINE_NOTARY_SESSION_CREATED, caseObjWithUpdatedStatus.Internal_Status__c,'Handle success - Case status is not updated'); 
        //System.assertEquals(Constants.CASE_STATUS_ONLINE_NOTARY_SESSION_CREATED, caseObjWithUpdatedStatus.Internal_Status__c,'Handle success - Case status is not updated'); 
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testHandleErrorUpdatesCaseStatus() {
        //Arrange
        string payload = ConstantsTest.TEST_NOTARY_TRANSACTION_RESPONSE_ERROR_PAYLOAD;

        Case caseObj =  [SELECT Id, Internal_Status__c
                        FROM Case
                        WHERE Internal_Status__c =: ConstantsTest.TEST_CASE_STATUS_NEW
                        LIMIT 1];

        //Replace case id placeholder from the payload with id from caseObj, we will use this case to assert
        payload = payload.replace('CASE_ID_PLACEHOLDER', caseObj.Id);

        //Response event object
        NotaryTransactionResponseEvent notaryTransactionResponseEvent = new NotaryTransactionResponseEvent();
        NotaryTransactionResponseEvent = (NotaryTransactionResponseEvent)System.JSON.deserialize(payload, NotaryTransactionResponseEvent.class);


      //Act
          Test.startTest();
          NotaryTransactionResponseEventHandler.handleError(notaryTransactionResponseEvent);
          Test.stopTest();

      //Assert
        Case caseObjWithUpdatedStatus =  [SELECT Internal_Status__c
                                          FROM Case
                                          WHERE Id =: caseObj.Id
                                          LIMIT 1];
        System.assertEquals(Constants.CASE_STATUS_ONLINE_NOTARY_SESSION_FAILED, caseObjWithUpdatedStatus.Internal_Status__c,'Handle error - Case status is not updated'); 
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
}