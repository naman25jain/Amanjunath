/*
CIBIS EPEX Schedule Limit Response handler
*/
public class CibisEpexScheduleLimitConRespHandler {
    //Variable Declaration
    Public Static Set<Id> sCaseIds = new Set<Id>();
    Public static map<Id,Case> caseMap;
    
    // Method to Handle Response Event from Platform Event Trigger routed from ResponseUtilityHandler
    public Static void handleResponse(List<String> lstPayloads){
        try{
            caseMap=new map<Id,Case>();
            if(lstPayloads != null && !lstPayloads.isEmpty()) {
                for(String str:lstPayloads){
                    System.debug('**str**'+str);
                    processPayload(str);
                }
                if(!sCaseIds.isEmpty() || !caseMap.isEmpty()){
                    processCaseRecds(sCaseIds); 
                }
            }
        }
        Catch(Exception e){
            System.debug('**CibisEpexConRespHandler**'+e.getMessage());
        }
        
    }
    
    //Process response event and split based on the response status
    public static void processPayload(String strPayload) {
        
        CibisEpexScheduleLimitResponseEventWrap responseEvent = (CibisEpexScheduleLimitResponseEventWrap)JSON.deserialize(strPayload,CibisEpexScheduleLimitResponseEventWrap.class);  
        System.debug('**responseEvent**'+responseEvent);      
        if( responseEvent.transactionId.split('-')[1]!=null){ 
            Id caseId=Id.ValueOf(responseEvent.transactionId.split('-')[1]);
            if(responseEvent != null && responseEvent.responseStatus == 'SUCCESS' && responseEvent.transactionId != null){                          
                sCaseIds.add(caseId);              
                caseMap.put(caseId,new Case(id=caseId,Internal_Status__c=Constants.CASE_STATUS_ACCEPTED,CIBIS_Integration__c=strPayload));  
                
            }
            
            else if(responseEvent != null && responseEvent.responseStatus == 'FAILED' && responseEvent.transactionId != null){
                System.debug('**FAILED**'+responseEvent);     
                caseMap.put(caseId,new Case(id=caseId,Internal_Status__c=Constants.CASE_STATUS_ERROR_CIBIS,CIBIS_Integration__c=strPayload));       
            }            
        }        
    }
    //Update Exam Registration Case
    public static void processCaseRecds(Set<Id> caseIds){
        list<Sobject> updList=new list<Sobject>();
        map<Id,Case> exregEpexMap=new map<Id,Case>();
        list<Exam_Registration__c> exRegList=new list<Exam_Registration__c>();
        for(case cs:[Select Id,ParentID,Eligibility_Period__c,EP_Start_Date__c,EP_End_Date__c,Parent.EP_Start_Date__c,Parent.EP_End_Date__c from Case where ID IN:sCaseIds AND RecordType.DeveloperName=:Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD and Internal_Status__c=:Constants.CASE_STATUS_PENDING_CIBIS]){
            Date stDate = cs.Parent.EP_Start_Date__c;
            Date edDate = cs.Parent.EP_End_Date__c;
            caseMap.put(cs.parentId,new Case(Id=cs.ParentId,Previous_EP_Start_Date__c=stDate,Previous_EP_End_Date__c=edDate,Eligibility_Period__c=cs.Eligibility_Period__c));   
            exregEpexMap.put(cs.parentId,cs);
        }
        For(Exam_Registration__c exReg:[Select id,EP_start_Date__c,EP_end_Date__c,Case__c from Exam_Registration__c where Case__c IN:caseMap.keySet() AND (Exam_Status__c='' OR Exam_Status__c=null)]){
            if(caseMap.containskey(exReg.Case__c)){
                exRegList.add(new Exam_Registration__c(Id=exReg.Id,EP_start_Date__c=exregEpexMap.get(exReg.Case__c).EP_Start_Date__c,EP_End_Date__c=exregEpexMap.get(exReg.Case__c).EP_End_Date__c)); 
            }
        }
        if(!exRegList.isEmpty()){
            updList.addAll(exRegList);
        }
        if(!caseMap.isEmpty()){
            updList.addAll(caseMap.Values());
        }
        if(!updList.isEmpty()){
            CibisUtility.updateSobjects(updList);
        }
        
    }
}