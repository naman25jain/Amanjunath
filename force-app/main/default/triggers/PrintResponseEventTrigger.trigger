trigger PrintResponseEventTrigger on Print_Response_Event__e (after insert) {
    System.debug('response payload ==> '+trigger.new);
    PrintResponseEventTriggerHelper.handlePrintResponses(trigger.new);
}