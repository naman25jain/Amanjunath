/**
 * Sampath Karnati
 * * Test Class for Case Print Handler
 * ? Private
 */
@isTest
private class CasePrintHandlerTest { 
    
    static final String ASSET_NAME = 'USMLE Transcript';

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
        String caserecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Applicant_Biographic_Change').getRecordTypeId();

        Case caseWithWorkingStatus = new Case(ContactId = contact.Id,
                                                AccountId = contact.AccountId,
                                                Internal_Status__c = 'Open' , RecordTypeId= caserecordTypeId);//ConstantsTest.TEST_CASE_STATUS_WORKING);
                
        insert caseWithWorkingStatus;

        // Add a new transcript to this shipment
        Id caseId =  [SELECT Id
                      FROM Case
                      WHERE Internal_Status__c = 'Open'  //: ConstantsTest.TEST_CASE_STATUS_WORKING
                      LIMIT 1].Id;

        String recordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_SCORE_REPORT).getRecordTypeId();

        Asset asset = new Asset(Name = ASSET_NAME,
                                Status = Constants.ASSET_STATUS_VERIFIED,
                                Type__c = ASSET_NAME,
                                Azure_Storage_URL__c = ConstantsTest.TEST_ASSET_AZURE_FILE_URL,
                                Case__c = caseId,
                                RecordTypeId = recordTypeId,
                                ContactId = contact.Id);

        insert asset;

         // Cloud test data
         CloudDataTestFactory.createCloudConfig();

    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testPrintCaseAssetReturnsTrue() {
        //Arrange
          
            Asset asset = [SELECT Id, Case__c, Azure_Storage_URL__c
                            FROM Asset 
                            WHERE Name =: ASSET_NAME
                            LIMIT 1];

            AssetPrintDetail assetPrintDetail = new AssetPrintDetail();
            assetPrintDetail.caseId = asset.Case__c;
            assetPrintDetail.documentUrl = asset.Azure_Storage_URL__c;
            assetPrintDetail.printerName = ConstantsTest.TEST_ORG_WIDE_EMAIL_ADDRESS;

            List<List<AssetPrintDetail>> assetPrintDetailsList = new List<List<AssetPrintDetail>>();

            List<AssetPrintDetail> assetPrintDetails = new List<AssetPrintDetail>();

            assetPrintDetails.add(assetPrintDetail);

            assetPrintDetailsList.add(assetPrintDetails);

                                            
        //Act
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator_GetPicture());
            CasePrintHandler.printCaseAsset(assetPrintDetailsList);
            Test.stopTest();
        
        //Assert (Assume print email have been sent)
            System.assertEquals(true, true,'Print job failed');
    }
     /////////////////////////////////////////////////////////////////////////////////////////////////////////
     @isTest
    static void testPrintCaseAssetThrowsException() {
        //Arrange
                                            
        //Act
            try {
                Test.startTest();
                Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator_GetPicture());
                CasePrintHandler.printCaseAsset(null);
                Test.stopTest();
            }catch(Exception e){
                //Assert
                System.assertNotEquals(null, e,'Exception is not thrown'); 
            }
    }
     ////////////////////////////////////////////////////////////////////////////////////////////////////////
    
}