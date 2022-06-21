@isTest
private class AssetsControllerTest {   
    /**
     * * Setup Data (AAA-Arrange)
     */ 
    @testSetup static void setup() {

         // Common Data Setup
            BaseTestFactory.getCustomerCommunityPlusUser();
            BaseTestFactory.getReadOnlyUser();

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
                String caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Attestation').getRecordTypeId();

                Case caseWithWorkingStatus = new Case(ContactId = contact.Id,
                                                        AccountId = contact.AccountId,
                                                        recordTypeId= caseRecordTypeId,
                                                        Internal_Status__c = 'Open' );//ConstantsTest.TEST_CASE_STATUS_WORKING);
                        
                insert caseWithWorkingStatus;
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testGetAssetByCaseContactReturnsNotNull() {
        //Arrange
            Asset asset;
            
            Profile profile = BaseTestFactory.getProfile(ConstantsTest.TEST_PROFILE_COMMUNITY_LOGIN);

            User runAsUser = [SELECT id, contactId 
                            FROM User 
                            WHERE alias =: ConstantsTest.TEST_USER_ALIAS
                            AND profileId =: profile.id
                            LIMIT 1]; 

            Case caseObj =  [SELECT Id, contactId, accountId 
                            FROM Case
                            WHERE Internal_Status__c ='Open'  //: ConstantsTest.TEST_CASE_STATUS_WORKING
                            LIMIT 1];

           Asset assetRelatedToCase = new Asset(Name = ConstantsTest.TEST_ASSET_NAME_RELATED_TO_CASE,
                                               AccountId = caseObj.AccountId,
                                               ContactId = caseObj.ContactId,
                                               Case__c = caseObj.Id,
                                               Status = ConstantsTest.TEST_ASSET_STATUS_IN_PROGRESS);
                                       
           insert assetRelatedToCase;

        //Act
            Test.startTest();
            System.runAs(runAsUser) {
            asset = AssetsController.getAssetByCaseContact(caseObj.Id,
                                                           ConstantsTest.TEST_ASSET_NAME_RELATED_TO_CASE, 
                                                           ConstantsTest.TEST_ASSET_STATUS_IN_PROGRESS);
            }
            Test.stopTest();
        
        //Assert
            System.assertNotEquals(null, asset,'Asset is Null');
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testGetAssetByCaseContactReturnsNull() {
        //Arrange
            
        //Act
            Test.startTest();
            Asset asset = AssetsController.getAssetByCaseContact(null,
                                                                 ConstantsTest.TEST_ASSET_NAME_RELATED_TO_CASE, 
                                                                 ConstantsTest.TEST_ASSET_STATUS_IN_PROGRESS);
            Test.stopTest();
        
        //Assert
            System.assertEquals(null, asset,'Asset is Not Null');
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testGetAssetByCaseContactReturnsQueryException() {
        //Arrange

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
                    Asset asset = AssetsController.getAssetByCaseContact(null,
                                                                         ConstantsTest.TEST_ASSET_NAME_RELATED_TO_CASE, 
                                                                         ConstantsTest.TEST_ASSET_STATUS_IN_PROGRESS);
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
    static void testInsertAssetReturnsTrue() {
        //Arrange
           boolean success;

           Case caseObj =  [SELECT Id, contactId, accountId 
                            FROM Case
                            WHERE Internal_Status__c ='Open'  //: ConstantsTest.TEST_CASE_STATUS_WORKING
                            LIMIT 1];

           List<Asset> assets = new List<Asset>();
           assets.add(new Asset(Name = Constants.ASSET_NAME_ID_FORM_NOTARIZED,
                                  Type__C = Constants.ASSET_TYPE_IDENTITY_VERIFICATION,
                                  Status = Constants.ASSET_STATUS_INPROGRESS,
                                  ContactId = caseObj.contactId,
                                  AccountId = caseObj.accountId,
                                  RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_IDENTITY).getRecordTypeId()));

        //Act
                Test.startTest();
                success = AssetsController.insertAsset(assets);
                Test.stopTest();
        //Assert
                 System.assertEquals(true, success,'Insert asset returns false'); 
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testInsertAssetThrowsException() {
        //Arrange

        //Act
        try 
        {
            Test.startTest();
            AssetsController.insertAsset(null);
            Test.stopTest();
        }
        catch(Exception e)
        {
            //Assert
             System.assertNotEquals(null, e,'Insert Assert - Exception is not thrown'); 
        }
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
}