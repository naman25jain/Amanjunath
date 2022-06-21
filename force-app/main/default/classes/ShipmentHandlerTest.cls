/**
 * Sampath Karnati
 * * Test Class for Shipment Handling
 * ? Private
 */

@isTest
private class ShipmentHandlerTest {   
    /**
     * * Setup Data (AAA-Arrange)
     */ 
    @testSetup static void setup() {

          //Shipment Set up
          zkmulti__MCShipment__c shipment = ShipmentTestFactory.getShipment();

          //Shipment Label from Attachments
          BaseTestFactory.getPDFAttachment(shipment.Id);

          // Cloud test data
          CloudDataTestFactory.createCloudConfig();

    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testDeleteShipmentLabelAttachmentReturnsTrue() {
        //Arrange
          
            // Get Shipment
            zkmulti__MCShipment__c shipment = [SELECT Id
                                                FROM zkmulti__MCShipment__c 
                                                WHERE zkmulti__Sender_Name__c =: ConstantsTest.TEST_NAME
                                                LIMIT 1];
            
        //Act
            Test.startTest();
            Boolean success = ShipmentHandler.deleteShipmentLabelAttachment(shipment.Id);
            Test.stopTest();
        
        //Assert
            System.assertEquals(true, success,'Delete shipment label returned false');
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testSaveShipmentToAzureReturnsTrue() {
        //Arrange
          
            // Get Shipment
            zkmulti__MCShipment__c shipment = [SELECT Id
                                                FROM zkmulti__MCShipment__c 
                                                WHERE zkmulti__Sender_Name__c =: ConstantsTest.TEST_NAME
                                                LIMIT 1];

            Attachment attachment = ShipmentHandler.getShipmentLabel(shipment.Id);

            List<HttpHeader> httpHeaders = new List<HttpHeader>();

            CloudStorageParameters requestHeaders = new CloudStorageParameters(ConstantsTest.TEST_NAME, ConstantsTest.TEST_NAME, ConstantsTest.TEST_NAME, ConstantsTest.TEST_NAME, httpHeaders);
            
        //Act
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator_UploadDocument());
            HttpResponse response = ShipmentHandler.saveShipmentToAzure(attachment.Body, requestHeaders);
            Integer statusCode = response.getStatusCode();
            Test.stopTest();
        
        //Assert
            System.assertEquals(200, statusCode,'Status code is not 200');
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
     @isTest
     static void testSaveDocumentCallExecuteReturnsSuccess() {
         //Arrange
           
             // Get Shipment
             zkmulti__MCShipment__c shipment = [SELECT Id
                                                 FROM zkmulti__MCShipment__c 
                                                 WHERE zkmulti__Sender_Name__c =: ConstantsTest.TEST_NAME
                                                 LIMIT 1];
 
         //Act
             Test.startTest();
             Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator_UploadDocument());
             System.enqueueJob(new ShipmentHandler.SaveDocumentCall(shipment.Id, ConstantsTest.TEST_SHIPMENT_PAYLOAD));
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