/**
 * Sampath Karnati
 * * Handle new account shipment
 * ? Exposed as Public
 */
public with sharing class AccountShipmentHandler {
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    @InvocableMethod(label='Save Account Shipping Label to Cloud' 
                     description='Create a new azure document from the shipment attachment.' 
                     category='Account Shipment')
    public static void saveShippingLabelToCloud(List<Id> shipments) {
        
            // Generate Payload
            string payload = shippingLabelPayload(shipments[0]);

            System.enqueueJob(new ShipmentHandler.SaveDocumentCall(shipments[0], payload));
       
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public static string shippingLabelPayload(Id shipmentId) 
    {
        zkmulti__MCShipment__c shipment = ShipmentController.getShipment(shipmentId);

        // Get account tied to this transcript request
        Account account = [SELECT Id 
                            FROM Account 
                            WHERE Id =: shipment.Account__c
                            WITH SECURITY_ENFORCED
                            ];

        CloudStorageController.PayloadWrapper payload = new CloudStorageController.PayloadWrapper(null, 
                                                                                                    Constants.ASSET_TYPE_SHIPPING_LABEL,
                                                                                                    Constants.ASSET_RECORD_TYPE_SHIPMENT,
                                                                                                    'Create',
                                                                                                    null,
                                                                                                    account.Id,
                                                                                                    'true',
                                                                                                    Constants.ASSET_STATUS_VERIFIED,
                                                                                                    null);
        payload.createFromPB = 'true';
        return JSON.serialize(payload);
    }

}