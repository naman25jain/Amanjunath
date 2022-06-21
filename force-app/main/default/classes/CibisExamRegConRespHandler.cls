//CIBIS
public with sharing class CibisExamRegConRespHandler{   
    
    public static map<Id,Case> caseMap;
    public static map<String, string> mapKeyAndValue = new map<String, string>();
    Public static map<string,string> examTypeMap=new map<String,String>{'USMLE Step 1'=>'STEP1','USMLE Step 2 CK' => 'STEP2','STEP 3'=>'STEP3'};
    public Static void handleResponse(List<String> lstPayloads){
        try{
            if(lstPayloads != null && !lstPayloads.isEmpty()) {
                caseMap=new map<Id,Case>();
                for(String str:lstPayloads){
                    processPayload(str);
                }
             
                if(!caseMap.isEmpty()){
                     System.debug('**caseMap**'+caseMap);
                    CibisUtility.updateSobjects(caseMap.values());
                }                   
                if(mapKeyAndValue != null && !mapKeyAndValue.isEmpty()) {
                    CibisUtility.constructExamRegExternalId(mapKeyAndValue);
                }
            }
        }
        Catch(Exception e){
            System.debug('**CibisExamRegConRespHandler**'+e.getMessage()); 
            System.debug('**CibisExamRegConRespHandler** ===> '+e.getStackTraceString());
        }
        
    }
    
    public static void processPayload(String strPayloadResponse) {
     String strPayload= strPayloadResponse.replaceAll('\n','').replaceAll('\r','');
        CibisExamRegResponseEventWrap responseEvent = (CibisExamRegResponseEventWrap)JSON.deserialize(strPayload,CibisExamRegResponseEventWrap.class);  
          System.debug('**responseEvent**'+responseEvent);      
        if( responseEvent.transactionId.split('-')[1]!=null){ 
            Id caseId=Id.ValueOf(responseEvent.transactionId.split('-')[1]);
            CibisExamRegResponseEventWrap.Payload objPayload = responseEvent.payload;          
             System.debug('**objPayload**'+objPayload); 
            if(responseEvent != null && responseEvent.responseStatus == 'SUCCESS' && responseEvent.transactionId != null){
                system.debug('***responseEvent.transactionId.split***'+Id.ValueOf(responseEvent.transactionId.split('-')[1])); 
                             
                  mapKeyAndValue.put(String.valueOf(caseId), String.valueOf(objPayload.applicationId));
                caseMap.put(caseId,new Case(id=caseId,Date_Registered__c=Date.Today(),Internal_Status__c=Constants.CASE_STATUS_REGISTERED,CIBIS_Integration__c=strPayload));    
            }
            
            else if(responseEvent != null && responseEvent.responseStatus == 'FAILED' && responseEvent.transactionId != null){
                
                caseMap.put(caseId,new Case(id=caseId,Internal_Status__c=Constants.CASE_STATUS_ERROR_CIBIS,CIBIS_Integration__c=strPayload));       
            }
            
        }
    }
}