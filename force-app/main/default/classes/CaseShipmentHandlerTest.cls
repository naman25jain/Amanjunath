@isTest
//This class will give us the code coverage for CaseShipmentHandler
public class CaseShipmentHandlerTest{
	@testSetup static void setup(){
        BaseTestFactory.getCustomerCommunityPlusUser();
        zkmulti__MCShipment__c shipment = ShipmentTestFactory.getShipment();
        BaseTestFactory.getPDFAttachment(shipment.Id);
        Profile profile = BaseTestFactory.getProfile(ConstantsTest.TEST_PROFILE_COMMUNITY_LOGIN);
        User user = [SELECT id, contactId 
                     FROM User 
                     WHERE alias =:ConstantsTest.TEST_USER_ALIAS
                     AND profileId =:profile.id
                     LIMIT 1];
        Contact contact = [SELECT Id
                           FROM Contact 
                           WHERE Id =:user.contactId
                           LIMIT 1];
        Case caseRec = new Case();
        caseRec.ContactId = contact.Id;
        caseRec.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ECFMG_CERTIFICATION).getRecordTypeId();
        caseRec.Status='Working';
        caseRec.Origin='Phone';
        caseRec.Internal_Status__c='Complete';
        Insert caseRec;
        System.assert(caseRec.Id != null, 'Insert failed for case');
        shipment.Contact__c = contact.Id;
        shipment.Case__c = caseRec.Id;
        update shipment;
        System.assert(shipment.Case__c != null, 'Update failed for shipment');
        CloudDataTestFactory.createCloudConfig();
    }
    @isTest
    static void testSaveShippingLabel(){
        zkmulti__MCShipment__c shipment = [SELECT Id
                                           FROM zkmulti__MCShipment__c 
                                           WHERE zkmulti__Sender_Name__c =:ConstantsTest.TEST_NAME
                                           LIMIT 1];
        List<Id> shipments = new List<Id>{shipment.Id};
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator_UploadDocument());
        CaseShipmentHandler.saveShippingLabelToCloud(shipments);
        Test.stopTest();
        List<Attachment> attachments = [SELECT Id, Body, ContentType 
                                        FROM Attachment 
                                        WHERE ParentId =:shipment.Id];
        System.assertEquals(0, attachments.size(),'Shipping attachment is not deleted');
    }
}