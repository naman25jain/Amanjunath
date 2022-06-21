/**
 * Sampath Karnati
 * * Handle new account shipment
 * ? Exposed as Public
 */
public with sharing class ContactShipmentHandler {

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    @InvocableMethod(label='Save Contact Shipping Label to Cloud' 
                     description='Create a new azure document from the shipment attachment.' 
                     category='Contact Shipment')
    public static void saveShippingLabelToCloud(List<Id> shipments) {
       
        // Generate Payload
        string payload = shippingLabelPayload(shipments[0]);

        System.enqueueJob(new ShipmentHandler.SaveDocumentCall(shipments[0], payload));
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public static string shippingLabelPayload(Id shipmentId) 
    {
        zkmulti__MCShipment__c shipment = ShipmentController.getShipment(shipmentId);

        // Get contact tied to this transcript request
        Contact contact = [SELECT Id, AccountId  
                            FROM Contact 
                            WHERE Id =: shipment.Contact__c
                            WITH SECURITY_ENFORCED
                            ];

        CloudStorageController.PayloadWrapper payload = new CloudStorageController.PayloadWrapper(contact.Id, 
                                                                                                    Constants.ASSET_TYPE_SHIPPING_LABEL,
                                                                                                    Constants.ASSET_RECORD_TYPE_SHIPMENT,
                                                                                                    'Create',
                                                                                                    null,
                                                                                                    contact.AccountId,
                                                                                                    'true',
                                                                                                    Constants.ASSET_STATUS_VERIFIED,
                                                                                                    null);
        payload.createFromPB = 'true';
        return JSON.serialize(payload);
    }

}