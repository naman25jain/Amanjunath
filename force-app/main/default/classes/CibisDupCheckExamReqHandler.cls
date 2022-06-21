public with sharing class CibisDupCheckExamReqHandler{
    /*@InvocableMethod
    public static void buildDupExamPayload(List<String> caseIds){
        String caseId='';
        if(!caseIds.isEmpty()){
            caseId = caseIds[0];
        }
        try 
        {   
            String conId='';
            if(!String.isBlank(caseId)){
                CibisDupCheckExamRequest examPayload = new CibisDupCheckExamRequest();                              
                examPayload.USMLEId = caseId; 
                examPayload.entity = 'registrations';
                examPayload.subEntity = '';
                examPayload.transactionId = '';
                examPayload.operation = 'GET';
                examPayload.field = '';
            // Create an instance of the event with field values
            String payload = JSON.serialize(examPayload);
            Cibis_Entity_Search_Request_Event__e requestEvent = new Cibis_Entity_Search_Request_Event__e(Payload__c=payload);
            // Call method to publish events
            Database.SaveResult sr = EventBus.publish(requestEvent);
            // Inspect publishing result
            if (sr.isSuccess()) 
            {  
                System.debug('===CibisDupCheckResponseEvent==> '  + sr.isSuccess());
            } 
            else 
            {
                for(Database.Error err : sr.getErrors()) 
                {
                    system.debug('===errorMessage===> '+ err.getMessage());
                }
            }   
            }else{
                system.debug('===contactIdIsEmpty===> ');
            }
        }
        catch(Exception e)
        {
            throw e; 
        }
    }*/
}