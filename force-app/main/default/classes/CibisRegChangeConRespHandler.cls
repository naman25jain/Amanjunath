//CIBIS
public class CibisRegChangeConRespHandler {
    Public Static Set<Id> sCaseIds = new Set<Id>();
    Public Static Set<Id> eCaseIds = new Set<Id>();
    Public Static Map<Id,String> pldMap = new Map<Id,String>();
    public Static void handleResponse(List<String> lstPayloads){
        try{
            if(lstPayloads != null && !lstPayloads.isEmpty()) {
                for(String str:lstPayloads){
                    processPayload(str);
                }
                
                if(!pldMap.keySet().isEmpty()){
                    processCaseRecds(pldMap.keySet());
                }
            }
        }
        Catch(Exception e){
            System.debug('**CibisCandidateConRespHandler**'+e.getMessage());
        }
        
    }
    
    public static void processPayload(String strPayload) {
        
        CibisRegChangeResponseEventWrap responseEvent = (CibisRegChangeResponseEventWrap)JSON.deserialize(strPayload,CibisRegChangeResponseEventWrap.class);
        if(responseEvent != null && responseEvent.responseStatus == 'SUCCESS' && responseEvent.transactionId != null){
            system.debug('***responseEvent.transactionId.split***'+Id.ValueOf(responseEvent.transactionId.split('-')[1]));
            pldMap.put(Id.ValueOf(responseEvent.transactionId.split('-')[1]),strPayload);
            if( responseEvent.transactionId.split('-')[1]!=null){ 
                sCaseIds.add(Id.ValueOf(responseEvent.transactionId.split('-')[1]));
            }
            
        }
        else if(responseEvent != null && responseEvent.responseStatus == 'ERROR' && responseEvent.transactionId != null){
            pldMap.put(Id.ValueOf(responseEvent.transactionId.split('-')[1]),strPayload);       
        }
        
    }
    //Select Id,CIBIS_Integration__c,Internal_Status__c
    public static void processCaseRecds(Set<Id> caseIds){
        List<Case> csUpdLst = new List<Case>();
        Map<String, Id> csCMap = new Map<String, Id>();
         map<Id,Case> regChangeCaseMap=new map<Id,Case>();
        Map<Id,Exam_Registration__c> newExam = new Map<Id,Exam_Registration__c>();
        system.debug('5001700000BvNdDAAV'+caseIds); 
          system.debug('regCase.ParentId'+[Select Id,Internal_Status__c,parentId from Case where RecordType.DeveloperName=:Constants.CASE_RECORD_TYPE_REGION_CHANGE and Internal_Status__c=:Constants.CASE_STATUS_PENDING_CIBIS]);
        for(Case regCase:[Select Id,Internal_Status__c,parentId,Product_Detail__c,Exam_Region__c,Surcharge__c,OwnerID from Case where RecordType.DeveloperName=:Constants.CASE_RECORD_TYPE_REGION_CHANGE and Internal_Status__c=:Constants.CASE_STATUS_PENDING_CIBIS and ParentID IN:caseIds AND ParentID <> null]){
            if(sCaseIds.contains(regCase.parentId)){
                /* Need to cancel the parent case from Trigger*/
                csUpdLst.add(new Case(Id=regCase.Id,CIBIS_Integration__c=pldMap.get(regCase.Id),Internal_Status__c=Constants.CASE_STATUS_ACCEPTED));
                regChangeCaseMap.put(regCase.ParentId,regCase);
                system.debug('regCase.ParentId'+regCase.ParentId);
            }
            else {
                csUpdLst.add(new Case(Id=regCase.Id,CIBIS_Integration__c=pldMap.get(regCase.Id),Internal_Status__c=Constants.CASE_STATUS_ERROR_CIBIS));
            }            
        }
        if(!csUpdLst.isEmpty()){
            CibisUtility.updateSobjects(csUpdLst);
        }
        if(!regChangeCaseMap.isEmpty()){
            CibisUtility.createExamRegCases(regChangeCaseMap);
        }
        
    }
    
}