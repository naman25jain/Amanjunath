@isTest
private class NotaryTransactionRequestEventHandlerTest {
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

           Online_Notary_Transaction__c onlineNotaryTrans=  new Online_Notary_Transaction__c(
                                            Case__c = caseWithWorkingStatus.Id,                                            
                                            Status__c = ConstantsTest.API_STATUS_SUCCESS, 
                                            Transaction_ID__c = '1234567' ,
                                            Signing_Session_Url__c = ConstantsTest.TEST_ONLINE_NOTARY_TRANSACTION_SIGNING_SESSION_URL,
                                            Dev_Notary_Link__c = ConstantsTest.TEST_ONLINE_NOTARY_TRANSACTION_SIGNING_SESSION_URL); 
          insert onlineNotaryTrans;                                             
   }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testBuildRequestEventPayloadReturnsNotNull() {
        //Arrange
        string payload;

        // Run as Customer Community Plus Login User
        Profile profile = BaseTestFactory.getProfile(ConstantsTest.TEST_PROFILE_COMMUNITY_LOGIN);

        User runAsUser = [SELECT id, contactId 
                          FROM User 
                          WHERE alias =: ConstantsTest.TEST_USER_ALIAS
                           AND profileId =: profile.id
                           LIMIT 1]; 
                           
        Case caseObj =  [SELECT Id, contactId, accountId 
                        FROM Case
                        WHERE Internal_Status__c =: ConstantsTest.TEST_CASE_STATUS_NEW
                        LIMIT 1];

        Asset assetRelatedToCase = new Asset(Name = ConstantsTest.TEST_ASSET_NAME_ID_FORM_TEMPLATE,
                                            AccountId = caseObj.AccountId,
                                            ContactId = caseObj.ContactId,
                                            Case__c = caseObj.Id,
                                            Status = ConstantsTest.TEST_ASSET_STATUS_IN_PROGRESS,
                                            Azure_Storage_URL__c = ConstantsTest.TEST_ASSET_AZURE_STORAGE_URL);
                  
        insert assetRelatedToCase;

      //Act
          Test.startTest();
          System.runAs(runAsUser)
          {
            payload = NotaryTransactionRequestEventHandler.buildRequestEventPayload(caseObj.Id);
          }
          Test.stopTest();

      //Assert
          System.assertNotEquals(null, payload,'Request payload is null'); 
    }

 /////////////////////////////////////////////////////////////////////////////////////////////////////////

     
    @isTest
    static void testBuildPartiesReturnsNotNull() {
        //Arrange
        List<NotaryTransactionRequestEvent.Party> parties;

        // Run as Customer Community Plus Login User
        Profile profile = BaseTestFactory.getProfile(ConstantsTest.TEST_PROFILE_COMMUNITY_LOGIN);

        User runAsUser = [SELECT id, contactId 
                          FROM User 
                          WHERE alias =: ConstantsTest.TEST_USER_ALIAS
                           AND profileId =: profile.id
                           LIMIT 1]; 
                           
        Case caseObj =  [SELECT Id, contactId, accountId 
                        FROM Case
                        WHERE Internal_Status__c =: ConstantsTest.TEST_CASE_STATUS_NEW
                        LIMIT 1];

      //Act
          Test.startTest();
          System.runAs(runAsUser)
          {
            parties = NotaryTransactionRequestEventHandler.buildParties(caseObj.Id);
          }
          Test.stopTest();

      //Assert
          System.assertNotEquals(null, parties,'Parties is null'); 
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testBuildPartiesReturnsNull() {
        //Arrange
        List<NotaryTransactionRequestEvent.Party> parties;

        // Run as Customer Community Plus Login User
        Profile profile = BaseTestFactory.getProfile(ConstantsTest.TEST_PROFILE_COMMUNITY_LOGIN);

        User runAsUser = [SELECT id, contactId 
                          FROM User 
                          WHERE alias =: ConstantsTest.TEST_USER_ALIAS
                           AND profileId =: profile.id
                           LIMIT 1]; 

      //Act
          Test.startTest();
          System.runAs(runAsUser)
          {
            parties = NotaryTransactionRequestEventHandler.buildParties(null);
          }
          Test.stopTest();

      //Assert
          System.assertEquals(null, parties,'Parties is not null'); 
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testBuildPartiesNoFirstName() {
        //Arrange
        List<NotaryTransactionRequestEvent.Party> parties;

        // Run as Customer Community Plus Login User
        Profile profile = BaseTestFactory.getProfile(ConstantsTest.TEST_PROFILE_COMMUNITY_LOGIN);

        User runAsUser = [SELECT id, contactId 
                          FROM User 
                          WHERE alias =: ConstantsTest.TEST_USER_ALIAS
                           AND profileId =: profile.id
                           LIMIT 1]; 
       contact con = new contact(Id=runAsUser.contactId, FirstName=null); 
       update con;   
       
       Case caseObj =  [SELECT Id, contactId, accountId 
                        FROM Case
                        WHERE Internal_Status__c =: ConstantsTest.TEST_CASE_STATUS_NEW
                        LIMIT 1];

      //Act
          Test.startTest();
          System.runAs(runAsUser)
          {
            parties = NotaryTransactionRequestEventHandler.buildParties(caseObj.Id);
          }
          Test.stopTest();

      //Assert
      System.assertEquals('-', parties[0].firstName,'FirstName is null');  
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testBuildDocumentsReturnsNotNull() {
        //Arrange
        List<NotaryTransactionRequestEvent.Document> documents;

        // Run as Customer Community Plus Login User
        Profile profile = BaseTestFactory.getProfile(ConstantsTest.TEST_PROFILE_COMMUNITY_LOGIN);

        User runAsUser = [SELECT id, contactId 
                          FROM User 
                          WHERE alias =: ConstantsTest.TEST_USER_ALIAS
                           AND profileId =: profile.id
                           LIMIT 1]; 
                           
        Case caseObj =  [SELECT Id, contactId, accountId 
                        FROM Case
                        WHERE Internal_Status__c =: ConstantsTest.TEST_CASE_STATUS_NEW
                        LIMIT 1];

        Asset assetRelatedToCase = new Asset(Name = ConstantsTest.TEST_ASSET_NAME_ID_FORM_TEMPLATE,
                                            AccountId = caseObj.AccountId,
                                            ContactId = caseObj.ContactId,
                                            Case__c = caseObj.Id,
                                            Status = ConstantsTest.TEST_ASSET_STATUS_IN_PROGRESS,
                                            Azure_Storage_URL__c = ConstantsTest.TEST_ASSET_AZURE_STORAGE_URL);

        insert assetRelatedToCase;

      //Act
          Test.startTest();
          System.runAs(runAsUser)
          {
            documents = NotaryTransactionRequestEventHandler.buildDocuments(caseObj.Id);
          }
          Test.stopTest();

      //Assert
          System.assertNotEquals(null, documents,'Documents is null'); 
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testBuildDocumentsReturnsNull() {
        //Arrange
        List<NotaryTransactionRequestEvent.Document> documents;

      //Act
          Test.startTest();
          documents = NotaryTransactionRequestEventHandler.buildDocuments(null);
          Test.stopTest();

      //Assert
          System.assertEquals(null, documents,'Documents is not null'); 
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testPublishEventWithCaseIdReturnsTrue() {
        //Arrange
        boolean success;

        // Run as Customer Community Plus Login User
        Profile profile = BaseTestFactory.getProfile(ConstantsTest.TEST_PROFILE_COMMUNITY_LOGIN);

        User runAsUser = [SELECT id, contactId 
                          FROM User 
                          WHERE alias =: ConstantsTest.TEST_USER_ALIAS
                           AND profileId =: profile.id
                           LIMIT 1]; 
                           
        Case caseObj =  [SELECT Id, contactId, accountId 
                        FROM Case
                        WHERE Internal_Status__c =: ConstantsTest.TEST_CASE_STATUS_NEW
                        LIMIT 1];

        Asset assetRelatedToCase = new Asset(Name = ConstantsTest.TEST_ASSET_NAME_ID_FORM_TEMPLATE,
                                            AccountId = caseObj.AccountId,
                                            ContactId = caseObj.ContactId,
                                            Case__c = caseObj.Id,
                                            Status = ConstantsTest.TEST_ASSET_STATUS_IN_PROGRESS,
                                            Azure_Storage_URL__c = ConstantsTest.TEST_ASSET_AZURE_STORAGE_URL);
                  
        insert assetRelatedToCase;

      //Act
          Test.startTest();
          System.runAs(runAsUser)
          {
            success = NotaryTransactionRequestEventHandler.publishEvent(caseObj.Id);
          }
          Test.stopTest();

      //Assert
          System.assertEquals(true, success,'Publish event with case id returns false'); 
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testPublishEventWithPayloadReturnsOneEventPublished() {
        //Arrange

        // Run as Customer Community Plus Login User
        Profile profile = BaseTestFactory.getProfile(ConstantsTest.TEST_PROFILE_COMMUNITY_LOGIN);

        User runAsUser = [SELECT id, contactId 
                          FROM User 
                          WHERE alias =: ConstantsTest.TEST_USER_ALIAS
                           AND profileId =: profile.id
                           LIMIT 1]; 

      //Act
          Test.startTest();
          System.runAs(runAsUser)
          {
            NotaryTransactionRequestEventHandler.publishEvent(ConstantsTest.TEST_NOTARY_TRANSACTION_REQUEST_PAYLOAD);
          }
          Test.stopTest();

      //Assert
      System.assertEquals(1, EventBusWrapper.eventList.size(), 'More than one event is published' );
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testPublishEventWithCaseIdListReturnsOneEventPublished() {
        //Arrange
                    
        Case caseObj =  [SELECT Id, contactId, accountId 
                        FROM Case
                        WHERE Internal_Status__c =: ConstantsTest.TEST_CASE_STATUS_NEW
                        LIMIT 1];

        List<Id> caseIds = new List<Id>();
        caseIds.add(caseObj.Id);

        Asset assetRelatedToCase = new Asset(Name = ConstantsTest.TEST_ASSET_NAME_ID_FORM_TEMPLATE,
                                            AccountId = caseObj.AccountId,
                                            ContactId = caseObj.ContactId,
                                            Case__c = caseObj.Id,
                                            Status = ConstantsTest.TEST_ASSET_STATUS_IN_PROGRESS,
                                            Azure_Storage_URL__c = ConstantsTest.TEST_ASSET_AZURE_STORAGE_URL);
                  
        insert assetRelatedToCase;

      //Act
          Test.startTest();
          NotaryTransactionRequestEventHandler.publishEvent(caseIds);
          Test.stopTest();

      //Assert
      System.assertEquals(1, EventBusWrapper.eventList.size(), 'More than one event is published' );
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
}