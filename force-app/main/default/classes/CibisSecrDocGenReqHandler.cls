public class CibisSecrDocGenReqHandler {
    
    public static list<Cibis_Entity_Search_Request_Event__e> constructPayload(String strEvent, Set<Id> caseIds){
        
        // return variable declaration
        list<Cibis_Entity_Search_Request_Event__e>  cibisSecrDocReqList=new list<Cibis_Entity_Search_Request_Event__e>();
        try 
        {
            if(!caseIds.isEmpty()){
                if(caseIds != null && caseIds.size() > 0){
                    for(case cs:[Select Id,ContactId,contact.USMLE_ID__c From Case where Id IN:caseIds]){
                        CibisSecrDocRequestEventWrap payloadObj =  new CibisSecrDocRequestEventWrap();
                        if(cs.Contact.USMLE_ID__c != null && cs.Contact.USMLE_ID__c != ''){                
                            
                            payloadObj.entity = Constants.CIBIS_CANDIDATE_TYPE;
                            payloadObj.subEntity = '';
                            payloadObj.transactionId = strEvent+'-'+cs.ContactId+'-'+cs.Id+'-'+GenericUtilities.getUUID();
                            payloadObj.operation = 'GET';
                            payloadObj.USMLEId = cs.Contact.USMLE_ID__c; 
                            payloadObj.field = 'secretariatDocumentInfoWithURL';          
                            // JSON Payload
                            String payload = JSON.serialize(payloadObj);
                            system.debug('payload'+payload);
                            cibisSecrDocReqList.add(new Cibis_Entity_Search_Request_Event__e(Payload__c=payload));
                        }
                    }
                }
            }
            return cibisSecrDocReqList;
        }
        catch(Exception e)
        {
            system.debug('====CibisSecrDocGenReqHandlerError====> ' + e.getMessage());
            throw e; 
        }
    }
    
}