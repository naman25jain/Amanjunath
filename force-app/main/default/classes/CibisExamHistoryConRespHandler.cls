/*
 CIBIS NBME Exam History Process response handler
*/
public with sharing class CibisExamHistoryConRespHandler{
    //Variable declaration
    public static list<Contact> examHistoryContacts;
    Public Static map<String, list<CibisExamHistoryResponseEventWrap.Payload>> responseMap;
    
    // Method to Handle Response Event from Platform Event Trigger routed from ResponseUtilityHandler
    public Static void handleResponse(List<String> lstPayloads){
        try{
            
            if(lstPayloads != null && !lstPayloads.isEmpty()) {
                examHistoryContacts =new list<Contact>();
                responseMap = new Map<String,list<CibisExamHistoryResponseEventWrap.Payload>>();
                
                // Iterate each payload and construct process payload 
                for(String str:lstPayloads){
                    processPayload(str);
                }
                // Utility method to Process Exam History
                if(!responseMap.isEmpty()){
                    CibisUtility.processExamHistory(responseMap); 
                }
                // Utility method to Update Sobject - Update Exam Histrory data based on the response status
                if(!examHistoryContacts.isEmpty()){
                    CibisUtility.updateSobjects(examHistoryContacts);
                }
                
            }
        }
        Catch(Exception e){
            System.debug('**CibisExamHistoryConRespHandler**'+e.getMessage());
             System.debug('**CibisExamHistoryConRespHandler**'+e.getLineNumber());
             System.debug('**CibisExamHistoryConRespHandler**'+e.getStackTraceString());
        }  
    }
    
   //Process response event and split based on the response status
    public static void processPayload(String responsePayLoad){
        CibisExamHistoryResponseEventWrap responseEvent = (CibisExamHistoryResponseEventWrap) JSON.deserialize(responsePayLoad,CibisExamHistoryResponseEventWrap.class); 
        if(responseEvent != null && responseEvent.transactionId != null){
            Id contactId =Id.valueOf(responseEvent.transactionId.split('-')[1]);
            if(responseEvent != null && responseEvent.responseStatus == 'SUCCESS' && responseEvent.transactionId != null){ 
                
                list<CibisExamHistoryResponseEventWrap.Payload>  payLoadObjList = responseEvent.payload;
                responseMap.put(contactId, payLoadObjList);
            }
            /*Need to evaluate to remove this logic*/
            else if(responseEvent != null && responseEvent.responseStatus == 'FAILED' && responseEvent.transactionId != null){
                examHistoryContacts.add(new Contact(Id=Id.valueOf(responseEvent.transactionId.split('-')[1]),CIBIS_Integration__c=responsePayLoad));
            }
            
            
        }        
        
    }
    
}