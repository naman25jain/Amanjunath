trigger AzureFilesDeleteResponseEventTrigger on Azure_Files_Delete_Response_Event__e (after insert) {    
    for (Azure_Files_Delete_Response_Event__e event : Trigger.New) {       
        AzureFilesDeleteResponseHandler.handleResponseEventPayload(event.payload__c);
    }
}