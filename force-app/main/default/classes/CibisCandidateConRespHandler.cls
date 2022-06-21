/*
 CIBIS Candidate Process response handler
*/
public class CibisCandidateConRespHandler {
    
    // Variable declaration
    Public static Map<Id,Contact> conMap = new Map<Id,Contact>();
    Public static List<Case> casLst = new List<Case>();
    public Static void handleResponse(List<String> lstPayloads){
        try{
            if(lstPayloads != null && !lstPayloads.isEmpty()) {
                for(String str:lstPayloads){
                    processPayload(str);
                }
                
                //Utility method to Update Sobject - Update Contact records
                if(!conMap.Values().isEmpty()){
                    CibisUtility.updateSobjects(conMap.Values());
                }
                
                //Utility method to Update Sobject - Update Case data based on the response status
                if(!casLst.isEmpty()){
                    CibisUtility.updateSobjects(casLst);
                }
                
            }
        }
        Catch(Exception e){
            System.debug('**CibisCandidateConRespHandler**'+e.getMessage());
        }
    }
    
    //Process response event and split based on the response status
    public static void processPayload(String strPayload) {
        
        CibisCandidateResponseEventWrap responseEvent = (CibisCandidateResponseEventWrap)JSON.deserialize(strPayload,CibisCandidateResponseEventWrap.class);
        Id contactId= Id.ValueOf(responseEvent.transactionId.split('-')[2]);
        Id caseId= Id.ValueOf(responseEvent.transactionId.split('-')[1]);
        if(responseEvent != null && responseEvent.responseStatus == 'SUCCESS' && responseEvent.transactionId != null){
            
            system.debug('***contactId***'+contactId);  
            if( contactId!=null){
                conMap.put(contactId,new Contact(Id= contactId,is_CIBIS_Origin__c=TRUE)); 
            }  
            if(caseId!=null){
                casLst.Add(new case(Id=caseId,Internal_Status__c=Constants.CASE_STATUS_ACCEPTED,CIBIS_Integration__c = string.valueOf(strPayload)));    
            }
        }
        else if(responseEvent != null && responseEvent.responseStatus == 'FAILED' && responseEvent.transactionId != null){
            if(caseId!=null){
                casLst.Add(new case(Id=caseId,Internal_Status__c=Constants.CASE_STATUS_ERROR_CIBIS,CIBIS_Integration__c = string.valueOf(strPayload)));  
            }
            
        }        
    }
    
}