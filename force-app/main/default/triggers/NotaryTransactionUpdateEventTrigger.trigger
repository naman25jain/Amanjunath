/**
 * Sampath Karnati 
 * * Handle Online Notary  Transaction Update Platform Event
 * ? Exposed as Public
 */
trigger NotaryTransactionUpdateEventTrigger on Notary_Transaction_Update_Event__e (after insert) {
    for (Notary_Transaction_Update_Event__e event : Trigger.New) {
        NotaryTransactionUpdateEventHandler.handleUpdateEventPayload(event.Payload__c);
    }
}