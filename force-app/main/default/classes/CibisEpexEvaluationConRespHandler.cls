/*
CIBIS EPEX Evaluation Response handler
*/
public class CibisEpexEvaluationConRespHandler {
    // Variable Declartion
    Public Static Set<Id> sCaseIds = new Set<Id>();      
    Public static list<npsp__Error__c> npspErrorLogs=new list<npsp__Error__c>();
    Public static map<Id,Case> caseMap;
    Public static Map<String,Set<Id>> cibisIdMap; 
    
    // Method to Handle Response Event from Platform Event Trigger routed from ResponseUtilityHandler
    public Static void handleResponse(List<String> lstPayloads){
        try{
            caseMap=new map<Id,Case>();
            cibisIdMap=new Map<String,Set<Id>>();
            if(lstPayloads != null && !lstPayloads.isEmpty()) {
                for(String str:lstPayloads){
                    System.debug('**str**'+str);
                    processPayload(str);
                }
                
                //Utility method to Update Sobject - Update Case data based on the response status
                if(!cibisIdMap.isEmpty() && cibisIdMap!=null){                  
                    CibisRequestUtilityHandler.cibisPlatformEventPublish(cibisIdMap);
                    
                }
                if(!caseMap.isEmpty()){
                   Cibisutility.updateSobjects(caseMap.values()); 
                }
                
            }
        }
        Catch(Exception e){
            System.debug('**CibisEpexEvaluationConRespHandler**'+e.getMessage());
        }
        
    }
    
    //Process response event and split based on the response status
    public static void processPayload(String strPayload) {
        
        CibisEpexEvaluationResponseEventWrap responseEvent = (CibisEpexEvaluationResponseEventWrap)JSON.deserialize(strPayload,CibisEpexEvaluationResponseEventWrap.class);  
        System.debug('**responseEvent**'+responseEvent);      
        if( responseEvent.transactionId.split('-')[1]!=null){ 
            Id caseId=Id.ValueOf(responseEvent.transactionId.split('-')[1]);
            if(responseEvent != null && responseEvent.responseStatus == 'SUCCESS' && responseEvent.transactionId != null){
                npspErrorLogs.add(new npsp__Error__c(Unique_Key__c=responseEvent.transactionId,Response__c=string.valueOf(strPayload),Case__c=caseId));
                CibisEpexEvaluationResponseEventWrap.payload payloadObj=responseEvent.payload;
                if((payloadObj.candidateExistInCIBIS=='N' || payloadObj.otherOpenRegistration=='Y' || payloadObj.currentExamHasOpenRegistration =='N') || (payloadObj.candidateExistInCIBIS=='Y' && payloadObj.otherOpenRegistration=='N' && payloadObj.covertValue=='Y' && payloadObj.outcomeRecievedValue=='Y' &&  payloadObj.currentExamHasOpenRegistration =='Y')){
                    caseMap.put(caseId,new Case(id=caseId,Internal_Status__c=Constants.CASE_STATUS_REJECTED,CIBIS_Integration__c=strPayload));       
                    System.debug('**caseMap**'+caseMap);     
                }
                else if(payloadObj.candidateExistInCIBIS=='Y' && payloadObj.otherOpenRegistration=='N' && payloadObj.covertValue=='Y' && payloadObj.outcomeRecievedValue=='N' && payloadObj.currentExamHasOpenRegistration =='Y'){
                    cibisIdMap.put(Constants.CIBIS_ELIGIBILITY_REVISION_EVENT,new set<Id>{caseId});
                }
                else if(payloadObj.candidateExistInCIBIS=='Y' && payloadObj.otherOpenRegistration=='N' && payloadObj.covertValue=='N' && payloadObj.currentExamHasOpenRegistration =='Y'){
                    cibisIdMap.put(Constants.CIBIS_SCHEDULE_LIMIT_EVENT,new set<Id>{caseId});
                }             
                
            }
            
            else if(responseEvent != null && responseEvent.responseStatus == 'FAILED' && responseEvent.transactionId != null){
                npspErrorLogs.add(new npsp__Error__c(Unique_Key__c=responseEvent.transactionId,Response__c=string.valueOf(strPayload),Case__c=caseId)); 
                caseMap.put(caseId,new Case(id=caseId,Internal_Status__c=Constants.CASE_STATUS_ERROR_CIBIS,CIBIS_Integration__c=strPayload));    
                System.debug('**FAILED**'+responseEvent);     
            }            
        }        
    }
    
    
}