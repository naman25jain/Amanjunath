/*
  CIBIS Candidate Irregular Behavior Process response handler
*/
public class CibisCandIrregularConRespHandler {
    // Variable declaration
    Public static map<String,map<String,Object>> responseMap;     
    Public Static List<Case> caseRecs;
    // Method to Handle Response Event from Platform Event Trigger routed from ResponseUtilityHandler
    public static void handleResponse(List<String> lstPayloads){
        try{
            
            if(lstPayloads != null && !lstPayloads.isEmpty()) {
                // Collection Variable initialization
                caseRecs = new List<Case>();
                responseMap=new map<String,map<String,Object>>();
                // Iterate each payload and construct process payload 
                for(String str : lstPayloads){
                    processPayload(str);
                }
                // Method to Process USMLE Transcript Notes
                if(!responseMap.isEmpty()){
                    CibisUtility.processUSMLETranscriptNotes(responseMap); 
                }
                //Utility method to Update Sobject - Update Case data based on the response status
                if(!caseRecs.isEmpty()){
                    CibisUtility.updateSobjects(caseRecs);
                }
            }
        }catch(Exception e){
            System.debug('**CibisCandIrregularConRespHandler** ==> '+e.getMessage());
            System.debug('**CibisCandIrregularConRespHandler** ==> '+e.getLineNumber());
            System.debug('**CibisCandIrregularConRespHandler** ==> '+e.getStackTraceString());
            System.debug('**CibisCandIrregularConRespHandler** ==> '+e.getCause());
        }
    }
    
    //Process response event and split based on the response status 
    public static void processPayload(String responsePayLoad){
        CibisCandIrregularResponseEventWrap responseEvent = (CibisCandIrregularResponseEventWrap) JSON.deserialize(responsePayLoad,CibisCandIrregularResponseEventWrap.class); 
        if(responseEvent != null && responseEvent.transactionId != null){         
            System.debug('responseEvent '+responseEvent.payload);
            if(responseEvent != null && responseEvent.responseStatus == 'SUCCESS' && responseEvent.transactionId != null){        
                CibisCandIrregularResponseEventWrap.payload  payLoadObjList = responseEvent.payload; 
                 responseMap.put(responseEvent.transactionId,(Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(payLoadObjList)));    
  
            } 
            else if(responseEvent != null && responseEvent.responseStatus == 'FAILED' && responseEvent.transactionId != null){
                caseRecs.add(new Case(Id=Id.valueOf(responseEvent.transactionId.split('-')[2]),Internal_Status__C=Constants.CASE_STATUS_ERROR_CIBIS,CIBIS_Integration__c=responsePayLoad));
            } 
        }         
    }
}