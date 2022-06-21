/**
 * Sampath Karnati 
 * * Handle Online Notary Transaction Response  Platform Event
 * ? Exposed as Public
 */
trigger NotaryTransactionResponseEventTrigger on Notary_Transaction_Response_Event__e (after insert) {
    for (Notary_Transaction_Response_Event__e event : Trigger.New) {
        NotaryTransactionResponseEventHandler.handleResponseEventPayload(event.Payload__c);
    }
}