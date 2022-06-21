//CIBIS
public class CibisExamIrregularConRespHandler {
    Public Static map<String, list<CibisExamHistoryResponseEventWrap.Payload>> responseMap;
    Public Static List<Case> caseRecs;
    public static void handleResponse(List<String> lstPayloads){
        try{    
            if(lstPayloads != null && !lstPayloads.isEmpty()) {
                responseMap = new map<String, list<CibisExamHistoryResponseEventWrap.Payload>>();
                caseRecs = new List<Case>();
                
                for(String str : lstPayloads){
                    processPayload(str);
                }
                if(!responseMap.isEmpty()){
                    System.debug('Final step to process');
                    CibisUtility.processExamIrrBehData(responseMap); 
                }
                if(!caseRecs.isEmpty()){
                    CibisUtility.updateSobjects(caseRecs);
                }
                
            }
        }catch(Exception e){
            System.debug('**CibisExamIrregularConRespHandler** ==> '+e.getMessage());
            System.debug('**CibisExamIrregularConRespHandler** ==> '+e.getLineNumber());
            System.debug('**CibisExamIrregularConRespHandler** ==> '+e.getStackTraceString());
        }
    }
    
    public static void processPayload(String responsePayLoad){
        CibisExamHistoryResponseEventWrap responseEvent = (CibisExamHistoryResponseEventWrap) System.JSON.deserialize(responsePayLoad, CibisExamHistoryResponseEventWrap.class); 
        System.debug('responseEvent '+responseEvent);
        if(responseEvent != null && responseEvent.transactionId != null){
            
            if(responseEvent != null && responseEvent.responseStatus == 'SUCCESS' && responseEvent.transactionId != null){        
                  list<CibisExamHistoryResponseEventWrap.Payload> examsIrrBeh =  responseEvent.payload;
                System.debug('examsIrrBeh '+examsIrrBeh);
                responseMap.put(responseEvent.transactionId,examsIrrBeh);   
            } 
            else if(responseEvent != null && responseEvent.responseStatus == 'FAILED' && responseEvent.transactionId != null){
                caseRecs.add(new Case(Id=Id.valueOf(responseEvent.transactionId.split('-')[1]),Internal_Status__C=Constants.CASE_STATUS_ERROR_CIBIS,CIBIS_Integration__c=responsePayLoad));
            }
        }         
    }
    
}