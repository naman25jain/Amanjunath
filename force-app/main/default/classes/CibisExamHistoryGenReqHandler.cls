/*
CIBIS Exam History for NBME Response Payload Handler
*/ 
public with sharing class CibisExamHistoryGenReqHandler{
    
    public static void constructPayload(String contactId, String usmleId){
        list<npsp__Error__c> npspErrorLogs=new list<npsp__Error__c>();
        try 
        { 
            if(!String.isBlank(usmleId)){
                CibisExamHistoryRequestEventWrap examPayload = new CibisExamHistoryRequestEventWrap();                              
                examPayload.USMLEId = usmleId; 
                examPayload.entity = Constants.CIBIS_REG_CHANGE_TYPE;
                examPayload.subEntity = '';
                examPayload.transactionId =Constants.CIBIS_EXAM_REG_HISTORY_EVENT+'-'+contactId+'-'+GenericUtilities.getUUID();
                examPayload.operation = 'GET';
                examPayload.field = Constants.EXAM_HISTORY;
                
                // Create an instance of the event with field values
                String payload = JSON.serialize(examPayload);
                System.debug('CibisExamHistoryGenReqHandler-payload'  + payload);
                Cibis_Entity_Search_Request_Event__e requestEvent = new Cibis_Entity_Search_Request_Event__e(Payload__c=payload);
                // Call method to publish events
                System.debug('CibisExamHistoryGenReqHandler'  + requestEvent);
                Database.SaveResult sr = EventBus.publish(requestEvent);
                // Inspect publishing result
                if (sr.isSuccess()) 
                {  
                    System.debug('===CibisDupCheckResponseEvent==> '  + sr.isSuccess());
                    npspErrorLogs.add(new npsp__Error__c(Unique_Key__c=examPayload.transactionId,Request__c=payload,Contact__c=contactId));
                } 
                else 
                {
                    for(Database.Error err : sr.getErrors()) 
                    {
                        system.debug('===errorMessage===> '+ err.getMessage());
                        npspErrorLogs.add(new npsp__Error__c(Unique_Key__c=examPayload.transactionId,npsp__Full_Message__c=err.getMessage(),Request__c=payload,Contact__c=contactId));
                    }
                }   
            }
            else{
                system.debug('===contactIdIsEmpty===> ');
            }
        }
        catch(Exception e)
        {
            CibisUtility.insertSobjects(new list<npsp__Error__c>{new npsp__Error__c(npsp__Full_Message__c=e.getMessage()+'--'+e.getTypeName(),npsp__Stack_Trace__c=e.getStackTraceString()+'--'+e.getLineNumber(),npsp__Error_Type__c='CibisExamHistoryGenReqHandler',Contact__c=contactId)});
            throw e;
        }
        
        // Generic utilities log method to insert/ Upsert logs in Error log object  
        if(!npspErrorLogs.isEmpty() && npspErrorLogs!=null){
            GenericUtilities.createErrorLogs(npspErrorLogs);  
        }
        
    }
}