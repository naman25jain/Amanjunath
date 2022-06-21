//Handle Case shipment
public with sharing class CaseShipmentHandler{
    @InvocableMethod(label='Save Case Shipping Label to Cloud' 
                     description='Create a new azure document from the shipment attachment.' 
                     category='Case Shipment')
    public static void saveShippingLabelToCloud(List<Id> shipments){
        string payload = shippingLabelPayload(shipments[0]);
        System.enqueueJob(new ShipmentHandler.SaveDocumentCall(shipments[0], payload));
    }
    public static string shippingLabelPayload(Id shipmentId){
        zkmulti__MCShipment__c shipment = ShipmentController.getShipment(shipmentId);
        Case caseRec = [SELECT Id, ContactId, AccountId FROM Case WHERE Id =:shipment.Case__c WITH SECURITY_ENFORCED];
        CloudStorageController.PayloadWrapper payload = new CloudStorageController.PayloadWrapper(caseRec.ContactId, 
                                                                                                    Constants.ASSET_TYPE_SHIPPING_LABEL,
                                                                                                    Constants.ASSET_RECORD_TYPE_SHIPMENT,
                                                                                                    'Create',
                                                                                                    caseRec.Id,
                                                                                                    caseRec.AccountId,
                                                                                                    'true',
                                                                                                    Constants.Asset_STATUS_ACCEPTED,
                                                                                                    null);
        payload.createFromPB = 'true';
        return JSON.serialize(payload);
    }
}