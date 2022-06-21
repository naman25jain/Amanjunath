/**
 * Sampath Karnati
 * * Test Class for Case Print Handler Scheduler
 * ? Private
 */
@isTest
private class CasePrintHandlerSchedulerTest { 
    
    static final String ASSET_NAME = 'USMLE Transcript';
    static final String OLD_CASE_STATUS = 'Sent for Printing';
    static final String NEW_CASE_STATUS = 'Sent';

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
       String caserecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Attestation').getRecordTypeId();

        Case caseWithWorkingStatus = new Case(ContactId = contact.Id,
                                                AccountId = contact.AccountId,
                                                RecordTypeId = caserecordTypeId,
                                                Internal_Status__c = OLD_CASE_STATUS );
                
        insert caseWithWorkingStatus;

        // Add a new transcript to this shipment
        Id caseId =  [SELECT Id
                      FROM Case
                      WHERE Internal_Status__c =: OLD_CASE_STATUS
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
    static void testPrintCaseAssetScheduleUpdatesCaseStatus() {
        //Arrange
          
            String cronExpression = '0 0 * * * ?';

            // Get Shipment
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
            // Schedule the job
            System.schedule('ScheduledPrintJobTest',cronExpression, new CasePrintHandlerScheduler());
            Test.stopTest();
        
        //Assert (Assume print email have been sent)
            case workingCase =  [SELECT Internal_Status__c
                                FROM Case
                                WHERE Id =: asset.Case__c
                                LIMIT 1];
            System.assertEquals(NEW_CASE_STATUS, workingCase.Internal_Status__c,'Scheduled Job did not update case status');
    }
     /////////////////////////////////////////////////////////////////////////////////////////////////////////
    
}