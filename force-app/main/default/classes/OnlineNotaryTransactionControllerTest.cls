@isTest
private class OnlineNotaryTransactionControllerTest {
     /**
     * *  Setup Data (AAA-Arrange)
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
    static void testGetOnlineNotaryTransactionReturnsNotNull() {
        //Arrange
        Online_Notary_Transaction__c onlineNotaryTransaction;

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

        Online_Notary_Transaction__c notaryRelatedToCase = new Online_Notary_Transaction__c(Signing_Session_Url__c = ConstantsTest.TEST_ONLINE_NOTARY_TRANSACTION_SIGNING_SESSION_URL,
                                                                                            Case__c = caseObj.Id,
                                                                                            Status__c = ConstantsTest.TEST_ONLINE_NOTARY_TRANSACTION_STATUS,
                                                                                            Transaction_ID__c = ConstantsTest.TEST_ONLINE_NOTARY_TRANSACTION_ID);
                  
        insert notaryRelatedToCase;

      //Act
          Test.startTest();
          System.runAs(runAsUser)
          {
            onlineNotaryTransaction = OnlineNotaryTransactionController.getOnlineNotaryTransaction(caseObj.Id, caseObj.Internal_Status__c);
          }
          Test.stopTest();

      //Assert
          System.assertNotEquals(null, onlineNotaryTransaction,'Online notary transaction is null'); 
    }
        /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testGetOnlineNotaryTransactionReturnsNull() {
        //Arrange
        Online_Notary_Transaction__c onlineNotaryTransaction;

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
            onlineNotaryTransaction = OnlineNotaryTransactionController.getOnlineNotaryTransaction(null, null);
          }
          Test.stopTest();

      //Assert
          System.assertEquals(null, onlineNotaryTransaction,'Online notary transaction is not null'); 
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testSaveOnlineNotaryTransactionThrowsNoAccessException() {
        //Arrange

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

        Online_Notary_Transaction__c onlineNotaryTransaction = new Online_Notary_Transaction__c(Signing_Session_Url__c = ConstantsTest.TEST_ONLINE_NOTARY_TRANSACTION_SIGNING_SESSION_URL,
                                                                                                Case__c = caseObj.Id,
                                                                                                Status__c = ConstantsTest.TEST_ONLINE_NOTARY_TRANSACTION_STATUS,
                                                                                                Transaction_ID__c = ConstantsTest.TEST_ONLINE_NOTARY_TRANSACTION_ID);

        List<Online_Notary_Transaction__c> onlineNotaryTransactions = new List<Online_Notary_Transaction__c>();
        onlineNotaryTransactions.add(onlineNotaryTransaction);

      //Act
        try 
        {
          Test.startTest();
          System.runAs(runAsUser)
          {
            OnlineNotaryTransactionController.saveOnlineNotaryTransaction(onlineNotaryTransactions);
          }
          Test.stopTest();
        }
          catch(NoAccessException e)
          {
              //Assert
              System.assertNotEquals(null, e,'Save online notary transaction-NoAccess Exception is not thrown'); 
          }
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testSaveOnlineNotaryTransactionReturnsTrue() {
        //Arrange
        boolean success;
                   
        Case caseObj =  [SELECT Id, contactId, accountId, Internal_Status__c 
                        FROM Case
                        WHERE Internal_Status__c =: ConstantsTest.TEST_CASE_STATUS_NEW
                        LIMIT 1];

        Online_Notary_Transaction__c onlineNotaryTransaction = new Online_Notary_Transaction__c(Signing_Session_Url__c = ConstantsTest.TEST_ONLINE_NOTARY_TRANSACTION_SIGNING_SESSION_URL,
                                                                                                Case__c = caseObj.Id,
                                                                                                Status__c = ConstantsTest.TEST_ONLINE_NOTARY_TRANSACTION_STATUS,
                                                                                                Transaction_ID__c = ConstantsTest.TEST_ONLINE_NOTARY_TRANSACTION_ID);

        List<Online_Notary_Transaction__c> onlineNotaryTransactions = new List<Online_Notary_Transaction__c>();
        onlineNotaryTransactions.add(onlineNotaryTransaction);

      //Act
          Test.startTest();
          success = OnlineNotaryTransactionController.saveOnlineNotaryTransaction(onlineNotaryTransactions);
          Test.stopTest();

      //Assert
        System.assertEquals(true, success,'Save Online notary transaction returns false'); 
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testUpdateOnlineNotaryTransactionStatusReturnsTrue() {
        //Arrange
        boolean success;
                   
        Case caseObj =  [SELECT Id, contactId, accountId, Internal_Status__c 
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

      //Act
          Test.startTest();
          success = OnlineNotaryTransactionController.updateOnlineNotaryTransactionStatus(transactionId, ConstantsTest.TEST_ONLINE_NOTARY_TRANSACTION_STATUS);
          Test.stopTest();

      //Assert
        System.assertEquals(true, success,'Update Online notary transaction status returns false'); 
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testUpdateOnlineNotaryTransactionStatusExceptionThrown() {
        //Arrange
        boolean success;
                  
        Case caseObj =  [SELECT Id, contactId, accountId, Internal_Status__c 
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

                                  Blob blobKey = crypto.generateAesKey(256);
                                  String key = EncodingUtil.convertToHex(blobKey);
                                  String tranStatus = key+key+key+key;                                     
      //Act
          Test.startTest();
          try {
            success = OnlineNotaryTransactionController.updateOnlineNotaryTransactionStatus(transactionId, tranStatus);            
          } catch (Exception ex) {
          success = false;
          }             
          Test.stopTest();

      //Assert
        System.assertEquals(false, success,'Update Online notary transaction status returns false'); 
    }
       /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testUpdateOnlineNotaryTransactionStatusReturnsFalse() {
        //Arrange
        boolean success;
                   
      //Act
          Test.startTest();
          success = OnlineNotaryTransactionController.updateOnlineNotaryTransactionStatus(null, ConstantsTest.TEST_ONLINE_NOTARY_TRANSACTION_STATUS);
          Test.stopTest();

      //Assert
        System.assertNotEquals(true, success,'Update Online notary transaction status returns true'); 
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testUpdateOnlineNotaryTransactionStatusThrowsNoAccessException() {
        //Arrange

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
   
        Online_Notary_Transaction__c onlineNotaryTransaction = new Online_Notary_Transaction__c(Signing_Session_Url__c = ConstantsTest.TEST_ONLINE_NOTARY_TRANSACTION_SIGNING_SESSION_URL,
                                                                                                   Case__c = caseObj.Id,
                                                                                                   Status__c = ConstantsTest.TEST_ONLINE_NOTARY_TRANSACTION_STATUS,
                                                                                                   Transaction_ID__c = ConstantsTest.TEST_ONLINE_NOTARY_TRANSACTION_ID);
   
        insert onlineNotaryTransaction;
   
        string transactionId =  [SELECT Transaction_Id__c
                                  FROM Online_Notary_Transaction__c
                                  WHERE Case__c =: caseObj.Id
                                  LIMIT 1].Transaction_Id__c;

      //Act
        try 
        {
          Test.startTest();
          System.runAs(runAsUser)
          {
            OnlineNotaryTransactionController.updateOnlineNotaryTransactionStatus(transactionId, ConstantsTest.TEST_ONLINE_NOTARY_TRANSACTION_STATUS);
          }
          Test.stopTest();
        }
          catch(NoAccessException e)
          {
              //Assert
              System.assertNotEquals(null, e,'Update online notary transaction-NoAccess Exception is not thrown'); 
          }
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testGetOnlineNotaryTransactionWithTransactionIdReturnsNotNull() {
        //Arrange

          Case caseObj =  [SELECT Id, contactId, accountId, Internal_Status__c 
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

        //Act
            
                Test.startTest();
                Online_Notary_Transaction__c notaryTransaction = OnlineNotaryTransactionController.getOnlineNotaryTransaction(transactionId);
                Test.stopTest();
           
        //Assert
                 System.assertNotEquals(null, notaryTransaction,'Get online notary transaction returns not null'); 
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
     @isTest
    static void testGetOnlineNotaryTransactionWithTransactionIdReturnsNull() {
        //Arrange

        //Act
        string transId; 
        Test.startTest();
          Online_Notary_Transaction__c notaryTransaction = OnlineNotaryTransactionController.getOnlineNotaryTransaction(transId);
        Test.stopTest();
    
        //Assert
        System.assertEquals(null, notaryTransaction,'Get online notary transaction returns  null'); 
    } 
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testGetOnlineNotaryTransactionWithCaseIdReturnsNotNull() {
        //Arrange

          Case caseObj =  [SELECT Id, contactId, accountId, Internal_Status__c 
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

           //Act
      
          Test.startTest();
          Online_Notary_Transaction__c notaryTransaction = OnlineNotaryTransactionController.getOnlineNotaryTransaction(caseObj.Id);
          Test.stopTest();
      
          //Assert
            System.assertNotEquals(null, notaryTransaction,'Get online notary transaction returns not null for CaseId'); 
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testGetOnlineNotaryTransactionWithTransactionIdthrowException() {
        //Arrange

          Case caseObj =  [SELECT Id, contactId, accountId, Internal_Status__c 
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
         
          string exMessage; 

        //Act
            
          Test.startTest();
            try {
              Online_Notary_Transaction__c notaryTransaction = OnlineNotaryTransactionController.getOnlineNotaryTransaction(transactionId, ConstantsTest.TEST_CASE_STATUS_NEW);
            } catch (Exception e) {
              exMessage =  e.getMessage(); 
            }
        
          Test.stopTest();
    //Assert
            System.assertNotEquals(null, exMessage,'Exception thrown'); 
    }

    @isTest
    static void testSaveOnlineNotaryTransactionDMLException() {
        //Arrange
        boolean success;
                   
        Case caseObj =  [SELECT Id, contactId, accountId, Internal_Status__c 
                        FROM Case
                        WHERE Internal_Status__c =: ConstantsTest.TEST_CASE_STATUS_NEW
                        LIMIT 1];

        Online_Notary_Transaction__c onlineNotaryTransaction = new Online_Notary_Transaction__c(); 
        List<Online_Notary_Transaction__c> onlineNotaryTransactions = new List<Online_Notary_Transaction__c>();
        onlineNotaryTransactions.add(onlineNotaryTransaction);

      //Act
          Test.startTest();
          try {
            success = OnlineNotaryTransactionController.saveOnlineNotaryTransaction(onlineNotaryTransactions);
          } catch (Exception ex) {
            success = false; 
          }
          Test.stopTest();

      //Assert
        System.assertEquals(false, success,'Save Online notary transaction returns false'); 
    }
       /////////////////////////////////////////////////////////////////////////////////////////////////////////
}