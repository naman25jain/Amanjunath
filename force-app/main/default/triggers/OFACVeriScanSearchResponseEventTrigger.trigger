/**
 * Alex Koz 
 * * Handle OFAC VeriScan Search Response Platform Event
 * ? Exposed as Public
 */
trigger OFACVeriScanSearchResponseEventTrigger on OFAC_VeriScan_Search_Response_Event__e (after insert) {
    for (OFAC_VeriScan_Search_Response_Event__e event : Trigger.New) {
        OFACSearchResponseHandler.handleResponseEventPayload(event.Payload__c);
    }
}