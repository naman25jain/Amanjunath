@isTest
private class ContactShipmentHandlerTest {   
    /**
     * * Setup Data (AAA-Arrange)
     */ 
    @testSetup static void setup() {
		CurrentECFMGIDSequence__c curECFMGSetting = CurrentECFMGIDSequence__c.getOrgDefaults();
        curECFMGSetting.ECFMG_ID__c = '00000';
        upsert curECFMGSetting CurrentECFMGIDSequence__c.Id;
         // Common Data Setup
        BaseTestFactory.getCustomerCommunityPlusUser();
          
        //Shipment Set up
        zkmulti__MCShipment__c shipment = ShipmentTestFactory.getShipment();

        //Shipment Label from Attachments
        BaseTestFactory.getPDFAttachment(shipment.Id);

        // Add an existing account to this shipment
        Profile profile = BaseTestFactory.getProfile(ConstantsTest.TEST_PROFILE_COMMUNITY_LOGIN);

        User user = [SELECT id, contactId 
                        FROM User 
                        WHERE alias =: ConstantsTest.TEST_USER_ALIAS
                        AND profileId =: profile.id
                        LIMIT 1];
                    
        Contact contact = [SELECT Id
                            FROM Contact 
                            WHERE Id =: user.contactId
                            LIMIT 1];

        shipment.Contact__c = contact.Id;
        update shipment;

        // Cloud test data
        CloudDataTestFactory.createCloudConfig();

    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testShippingLabelPayloadReturnsNotNull() {
        //Arrange
          
            // Get Shipment
            zkmulti__MCShipment__c shipment = [SELECT Id
                                                FROM zkmulti__MCShipment__c 
                                                WHERE zkmulti__Sender_Name__c =: ConstantsTest.TEST_NAME
                                                LIMIT 1];
            
        //Act
            Test.startTest();
            string payload = ContactShipmentHandler.shippingLabelPayload(shipment.Id);
            Test.stopTest();
        
        //Assert
            System.assertNotEquals(null, payload,'Shipping label payload is null');
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testSaveShippingLabelToCloudReturnsSuccess() {
        //Arrange
          
            // Get Shipment
            zkmulti__MCShipment__c shipment = [SELECT Id
                                                FROM zkmulti__MCShipment__c 
                                                WHERE zkmulti__Sender_Name__c =: ConstantsTest.TEST_NAME
                                                LIMIT 1];

            List<Id> shipments = new List<Id>();
            shipments.add(shipment.Id);
            
        //Act
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator_UploadDocument());
            ContactShipmentHandler.saveShippingLabelToCloud(shipments);
            Test.stopTest();
        
        //Assert
        List<Attachment> attachments =  [SELECT Id, Body, ContentType 
                                            FROM Attachment 
                                            WHERE ParentId =: shipment.Id
                                            WITH SECURITY_ENFORCED
                                            ];

        System.assertEquals(0, attachments.size(),'Shipping attachment is not deleted');
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
}