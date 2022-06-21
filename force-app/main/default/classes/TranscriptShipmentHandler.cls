/**
 * Sampath Karnati
 * * Handle new transcript shipment
 * ? Exposed as Public
 */
public with sharing class TranscriptShipmentHandler {

    static final String ASSET_ACTION = 'Create';
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    @InvocableMethod(label='Save Transcript Shipping Label to Cloud' 
                     description='Create a new azure document from the shipment attachment.' 
                     category='Transcript Shipment')
    public static void saveShippingLabelToCloud(List<Id> shipments) {
        
            // Generate Payload
            string payload = shippingLabelPayload(shipments[0]);

            System.enqueueJob(new ShipmentHandler.SaveDocumentCall(shipments[0], payload));
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public static string shippingLabelPayload(Id shipmentId) 
    {
        zkmulti__MCShipment__c shipment = ShipmentController.getShipment(shipmentId);

        // Get case tied to this transcript request
        Transcript_Request__C transcriptRequest = [SELECT Id, Case__c 
                                                    FROM Transcript_Request__C 
                                                    WHERE Id =: shipment.Transcript_Request__c
                                                    WITH SECURITY_ENFORCED
                                                    ];

        Case caseRecord =  [SELECT Id, ContactId, AccountId 
                            FROM Case 
                            WHERE Id =: transcriptRequest.Case__c
                            WITH SECURITY_ENFORCED
                            ];

        CloudStorageController.PayloadWrapper payload = new CloudStorageController.PayloadWrapper(caseRecord.ContactId, 
                                                                                                    Constants.ASSET_TYPE_SHIPPING_LABEL,
                                                                                                    Constants.ASSET_RECORD_TYPE_SHIPMENT,
                                                                                                    ASSET_ACTION,
                                                                                                    caseRecord.Id,
                                                                                                    null,
                                                                                                    'true',
                                                                                                    Constants.ASSET_STATUS_VERIFIED,
                                                                                                    null);
		payload.createFromPB = 'true';
        return JSON.serialize(payload);
    }

}