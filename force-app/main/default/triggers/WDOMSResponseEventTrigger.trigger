trigger WDOMSResponseEventTrigger on WDOMSResponse__e (after insert) {
    for (WDOMSResponse__e event : Trigger.New) {
        WDOMSResponseHandler.handleResponseEventPayload(event.Payload__c);
    }
}