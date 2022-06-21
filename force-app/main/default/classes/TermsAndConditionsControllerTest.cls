@isTest
private class TermsAndConditionsControllerTest extends ECFMGTestFactory{   
    /**
     * * Setup Data (AAA-Arrange)
     */ 
    @testSetup static void setup() {

         // Common Data Setup
        BaseTestFactory.getCustomerCommunityPlusUser();
        BaseTestFactory.getReadOnlyUser();

         // Product
         Product2 product =  new Product2(Name = ConstantsTest.TEST_PRODUCT, 
                                            Family = ConstantsTest.TEST_STRING,
                                            isActive=true);

         insert product;

         // Terms and Conditions - Active
         List<Terms_and_Conditions__c> termsAndConditions = new List<Terms_and_Conditions__c>();

         termsAndConditions.add(new Terms_and_Conditions__c(Name = ConstantsTest.TEST_TERMS_CONDITIONS_NAME_ACTIVE,
                                                            Copy__c = ConstantsTest.TEST_STRING,
                                                            Short_Copy__c = ConstantsTest.TEST_STRING,
                                                            Status__c = ConstantsTest.TEST_STATUS_ACTIVE,
                                                            Product__c = product.Id,
                                                            ExpirationDate__c = System.today()+20));

        // Terms and Conditions - Inactive
        termsAndConditions.add(new Terms_and_Conditions__c(Name = ConstantsTest.TEST_TERMS_CONDITIONS_NAME_INACTIVE,
                                                            Copy__c = ConstantsTest.TEST_STRING,
                                                            Short_Copy__c = ConstantsTest.TEST_STRING,
                                                            Status__c = ConstantsTest.TEST_STATUS_INACTIVE,
                                                            Product__c = product.Id,
                                                            ExpirationDate__c = System.today()+20));

        insert termsAndConditions;
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testGetTermsAndConditionsReturnsNotNull() {
        //Arrange
         // Setup()

        //Act
            Test.startTest();
            Terms_and_Conditions__c termsAndCondition = TermsAndConditionsController.getTermsAndConditions(ConstantsTest.TEST_TERMS_CONDITIONS_NAME_ACTIVE, ConstantsTest.TEST_PRODUCT);
            Test.stopTest();
        
        //Assert
            System.assertNotEquals(null, termsAndCondition,'Terms and Conditions is Null');
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testGetTermsAndConditionsReturnsNull() {
        //Arrange
            // Setup()

        //Act
            Test.startTest();
            Terms_and_Conditions__c termsAndCondition = TermsAndConditionsController.getTermsAndConditions(ConstantsTest.TEST_TERMS_CONDITIONS_NAME_INACTIVE, ConstantsTest.TEST_PRODUCT);
            Test.stopTest();
        
        //Assert
            System.assertEquals(null, termsAndCondition,'Terms and Conditions is Not Null');
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testGetTermsAndConditionsReturnsQueryException() {
        
        //Arrange
            // Run as Read only User
            Profile profile = BaseTestFactory.getProfile(ConstantsTest.TEST_PROFILE_READONLY);

            User runAsUser = [SELECT id, contactId 
                                FROM User 
                                WHERE alias =: ConstantsTest.TEST_USER_ALIAS
                                AND profileId =: profile.id
                                LIMIT 1]; 

        //Act
            try 
            {
                Test.startTest();
                System.runAs(runAsUser) 
                {
                    TermsAndConditionsController.getTermsAndConditions(ConstantsTest.TEST_TERMS_CONDITIONS_NAME_INACTIVE, ConstantsTest.TEST_PRODUCT);
                }
                Test.stopTest();
            }
            catch(QueryException e)
            {
                //Assert
                System.assertNotEquals(null, e,'Query Exception is not thrown'); 
            }
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testsaveTermsAndConditionsAgreementReturnsDMLException() {
        //Arrange
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
        try {
            //Act
            Test.startTest();
            TermsAndConditionsController.saveTermsAndConditionsAgreement(termsAndCondition);
            Test.stopTest();
        }
        catch(DmlException e)
        {
            //Assert
           // Contact Id is a required field for saving terms and conditions agreement, NULL Contact Id should throw exception
           System.assertNotEquals(null, e,'DML Exception is not thrown'); 
        }
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testsaveTermsAndConditionsAgreementReturnsNoAccessException() {
        //Arrange
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

             // Run as Read only User
             Profile profile = BaseTestFactory.getProfile(ConstantsTest.TEST_PROFILE_READONLY);

             User runAsUser = [SELECT id, contactId 
                                 FROM User 
                                 WHERE alias =: ConstantsTest.TEST_USER_ALIAS
                                 AND profileId =: profile.id
                                 LIMIT 1]; 

            try 
            {
                Test.startTest();
                System.runAs(runAsUser) 
                {
                    TermsAndConditionsController.saveTermsAndConditionsAgreement(termsAndCondition);
                }
                Test.stopTest();
            }
            catch(NoAccessException e)
            {
                //Assert
                System.assertNotEquals(null, e,'No Access Exception is not thrown'); 
            }
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testsaveTermsAndConditionsAgreementReturnsTrue() {
        
        //Arrange
            Boolean recordSaved;

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
                recordSaved = TermsAndConditionsController.saveTermsAndConditionsAgreement(termsAndCondition);
            }
            Test.stopTest();

        //Assert
            System.assertEquals(true, recordSaved,'Terms and Conditions Agreement not saved');
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testsaveTermsAndConditionsAgreementWithAssetReturnsTrue() {
        
        //Arrange
            Boolean recordSaved;

            // Run as Customer Community Plus Login User
            Profile profile = BaseTestFactory.getProfile(ConstantsTest.TEST_PROFILE_COMMUNITY_LOGIN);

            User runAsUser = [SELECT id, contactId 
                             FROM User 
                             WHERE alias =: ConstantsTest.TEST_USER_ALIAS
                             AND profileId =: profile.id
                             LIMIT 1]; 

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

                           
           Contact contact = [SELECT id, AccountId 
                               FROM Contact 
                               WHERE Id =: runAsUser.contactId
                               LIMIT 1];
           // new case 
           Case caseWithWorkingStatus = new Case(ContactId = contact.Id,
                                                 AccountId = contact.AccountId,
                                                Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c);

           ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, caseWithWorkingStatus);
           run();
           Case caseObj =  [SELECT Id, contactId, accountId 
                            FROM Case
                            WHERE Internal_Status__c =: Constant_Case__mdt.getInstance('STATUS_NEW').Value__c
                            LIMIT 1];

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
            Test.startTest();
            System.runAs(runAsUser)
            {
                recordSaved = TermsAndConditionsController.saveTermsAndConditionsAgreement(termsAndCondition, assetObj.Id);
            }
            Test.stopTest();

        //Assert
            System.assertEquals(true, recordSaved,'Terms and Conditions Agreement with Asset not saved');
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
}