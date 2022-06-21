public class CibisSecrDocURLConRespHandler {
    
    Public Static map<Id, Case> mapCases;
    Public static map<String,map<String,Object>> responseMap;
    
    public static void handleResponse(List<String> lstPayloads){
        System.debug('**lstPayloads ==>'+lstPayloads);
        try{
            if(lstPayloads != null && !lstPayloads.isEmpty()) {
                responseMap=new map<String,map<String,Object>>();
                mapCases = new map<Id, Case>();
                
                for(String str : lstPayloads){
                    processPayload(str);
                }
                if(!responseMap.isEmpty()){
                    CibisUtility.updateSecrDocData(responseMap);
                }
                
            }
        }catch(Exception e){
            System.debug('*** CibisSecrDocURLConRespHandler*** '+e.getMessage()+' at line '+e.getLineNumber());
        }
    }
    
    public static void processPayload(String responsePayLoad){
        System.debug('**responsePayLoad ==>'+responsePayLoad);
        CibisSecrDocURLResponseEventWrap responseEvent = (CibisSecrDocURLResponseEventWrap) JSON.deserialize(responsePayLoad,CibisSecrDocURLResponseEventWrap.class); 
        if(responseEvent != null && responseEvent.transactionId != null){
            Id contactId = Id.valueOf(responseEvent.transactionId.split('-')[2]);
            
            if(responseEvent != null && responseEvent.responseStatus == 'SUCCESS' && responseEvent.transactionId != null){        
                CibisSecrDocURLResponseEventWrap.Payload  payLoadObjList = responseEvent.Payload;
                
                Object secDocInfoWithUrls = JSON.deserializeUntyped(JSON.serialize(payLoadObjList.SecretariatDocumentInfoWithURL[0]));
                Map<String,Object> ObjMapData = (Map<String,Object>)secDocInfoWithUrls;
                System.debug('ObjMapData '+ObjMapData);
                System.debug('transactionId '+responseEvent.transactionId);
                responseMap.put(responseEvent.transactionId, ObjMapData);          
                
            } 
            else if(responseEvent != null && responseEvent.responseStatus == 'FAILED' && responseEvent.transactionId != null){
                mapCases.put(Id.valueOf(responseEvent.transactionId.split('-')[2]), new Case(Id=Id.valueOf(responseEvent.transactionId.split('-')[2]),Internal_Status__C=Constants.CASE_STATUS_ERROR_CIBIS,CIBIS_Integration__c=responsePayLoad));
            }
        }         
    }
}