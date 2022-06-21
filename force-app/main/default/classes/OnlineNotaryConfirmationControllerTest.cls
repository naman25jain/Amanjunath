@isTest
private class OnlineNotaryConfirmationControllerTest {
      /**
     * * Setup Data (AAA-Arrange)
     */ 
    @testSetup static void setup() {

        // Common Data Setup
           BaseTestFactory.getCustomerCommunityPlusUser();
           BaseTestFactory.getReadOnlyUser();
		       CloudDataTestFactory.createCloudConfig();  
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
    static void testGetConstantsReturnsNotNull(){
        //Arrange
            //N/A

        //Act
            Constants constants = OnlineNotaryConfirmationController.getConstants();
        
        //Assert
            System.assertNotEquals(null, constants,'Constants is null');
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testPublishNotaryTransactionRequestEventReturnsTrue() {
        //Arrange
        boolean success;
		    string url;
        // Run as Customer Community Plus Login User
        Profile profile = BaseTestFactory.getProfile(ConstantsTest.TEST_PROFILE_COMMUNITY_LOGIN);

        User runAsUser = [SELECT id, contactId 
                          FROM User 
                          WHERE alias =: ConstantsTest.TEST_USER_ALIAS
                           AND profileId =: profile.id
                           LIMIT 1]; 
                           
        Case caseObj =  [SELECT Id, contactId, accountId, Internal_Status__c 
                        FROM Case
                        WHERE Internal_Status__c =: ConstantsTest.TEST_CASE_STATUS_NEW
                        LIMIT 1];
        // Product
        Product2 product =  new Product2(Name = ConstantsTest.TEST_PRODUCT, 
                                        Family = ConstantsTest.TEST_STRING,
                                        isActive=true);

        insert product;

        // Get a Test Product (loaded from setup)
        Id productId =  [SELECT Id FROM PRODUCT2 
                        WHERE Name =: ConstantsTest.TEST_PRODUCT
                        LIMIT 1].Id ;

         // New Terms and Conditions
         Terms_and_Conditions__c termsAndCondition =  new Terms_and_Conditions__c(Name = ConstantsTest.TEST_TERMS_CONDITIONS_NAME_ACTIVE,
                                                                                    Copy__c = ConstantsTest.TEST_STRING,
                                                                                    Short_Copy__c = ConstantsTest.TEST_STRING,
                                                                                    Status__c = ConstantsTest.TEST_STATUS_ACTIVE,
                                                                                    Product__c = productId,
                                                                                    ExpirationDate__c = System.today()+20);

         insert termsAndCondition;

        Asset assetRelatedToCase = new Asset(Name = Constants.ASSET_NAME_ID_FORM_TEMPLATE,
                                               AccountId = caseObj.AccountId,
                                               ContactId = caseObj.ContactId,
                                               Case__c = caseObj.Id,
                                               Status = ConstantsTest.TEST_ASSET_STATUS_IN_PROGRESS,
                                               Azure_Storage_Url__c = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/00355000016C6jUAAS_02i55000004kcDbAAI.pdf'
                                            );
                                       
        insert assetRelatedToCase;
		    System.assert([SELECT Id FROM Asset WHERE Id=:assetRelatedToCase.Id] != null, 'Assert success');
        Asset assetObj =  [SELECT Id 
                              FROM Asset
                              WHERE Status =: ConstantsTest.TEST_ASSET_STATUS_IN_PROGRESS
                              LIMIT 1];

      //Act
          Test.startTest();
          System.runAs(runAsUser)
          {
            success = OnlineNotaryConfirmationController.publishNotaryTransactionRequestEvent(caseObj.Id, termsAndCondition, assetObj.Id);
          	url = OnlineNotaryConfirmationController.getAzureUrl(caseObj.Id);
          }
          Test.stopTest();

      //Assert
          System.assertEquals(true, success,'Publish notary transaction request event is not published'); 
          System.assert(url != null, 'Assert success');
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testPublishNotaryTransactionRequestEventThrowsNoAccessException() {
        //Arrange

        // Run as Customer Community Plus Login User
        Profile profile = BaseTestFactory.getProfile(ConstantsTest.TEST_PROFILE_READONLY);

        User runAsUser = [SELECT id, contactId 
                          FROM User 
                          WHERE alias =: ConstantsTest.TEST_USER_ALIAS
                           AND profileId =: profile.id
                           LIMIT 1]; 

        Case caseObj =  [SELECT Id, contactId, accountId, Internal_Status__c 
                        FROM Case
                        WHERE Internal_Status__c =: ConstantsTest.TEST_CASE_STATUS_NEW
                        LIMIT 1];

        // Product
        Product2 product =  new Product2(Name = ConstantsTest.TEST_PRODUCT, 
                                        Family = ConstantsTest.TEST_STRING,
                                        isActive=true);

        insert product;

        // Get a Test Product (loaded from setup)
        Id productId =  [SELECT Id FROM PRODUCT2 
                        WHERE Name =: ConstantsTest.TEST_PRODUCT
                        LIMIT 1].Id ;

        // New Terms and Conditions
        Terms_and_Conditions__c termsAndCondition =  new Terms_and_Conditions__c(Name = ConstantsTest.TEST_TERMS_CONDITIONS_NAME_ACTIVE,
                                                                                    Copy__c = ConstantsTest.TEST_STRING,
                                                                                    Short_Copy__c = ConstantsTest.TEST_STRING,
                                                                                    Status__c = ConstantsTest.TEST_STATUS_ACTIVE,
                                                                                    Product__c = productId,
                                                                                    ExpirationDate__c = System.today()+20);

        insert termsAndCondition;

        Asset assetRelatedToCase = new Asset(Name = ConstantsTest.TEST_ASSET_NAME_RELATED_TO_CASE,
                                                AccountId = caseObj.AccountId,
                                                ContactId = caseObj.ContactId,
                                                Case__c = caseObj.Id,
                                                Status = ConstantsTest.TEST_ASSET_STATUS_IN_PROGRESS);
                                        
        insert assetRelatedToCase;

        Asset assetObj =  [SELECT Id 
                                FROM Asset
                                WHERE Status =: ConstantsTest.TEST_ASSET_STATUS_IN_PROGRESS
                                LIMIT 1];
   

      //Act
        try 
        {
          Test.startTest();
          System.runAs(runAsUser)
          {
            OnlineNotaryConfirmationController.publishNotaryTransactionRequestEvent(caseObj.Id, 
                                                                                    termsAndCondition, 
                                                                                    assetObj.Id);
          }
          Test.stopTest();
        }
        catch(NoAccessException e)
        {
            //Assert
            System.assertNotEquals(null, e,'Publish notary transaction request event- NoAccessException is not thrown'); 
        }
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testPublishNotaryTransactionRequestEventThrowsDMLException() {
        //Arrange

        Case caseObj =  [SELECT Id, contactId, accountId, Internal_Status__c 
                        FROM Case
                        WHERE Internal_Status__c =: ConstantsTest.TEST_CASE_STATUS_NEW
                        LIMIT 1];

        // New Terms and Conditions
        Terms_and_Conditions__c termsAndCondition =  new Terms_and_Conditions__c(Name = ConstantsTest.TEST_TERMS_CONDITIONS_NAME_ACTIVE,
                                                                                    Copy__c = ConstantsTest.TEST_STRING,
                                                                                    Short_Copy__c = ConstantsTest.TEST_STRING,
                                                                                    Status__c = ConstantsTest.TEST_STATUS_ACTIVE,
                                                                                    ExpirationDate__c = System.today()+20);

      //Act
        try 
        {
          Test.startTest();
            OnlineNotaryConfirmationController.publishNotaryTransactionRequestEvent(caseObj.Id, 
                                                                                    termsAndCondition, 
                                                                                    caseObj.Id);
          Test.stopTest();
        }
        catch(DmlException e)
        {
            //Assert
            System.assertNotEquals(null, e,'Publish notary transaction request event- DMLException is not thrown'); 
        }
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
   
}