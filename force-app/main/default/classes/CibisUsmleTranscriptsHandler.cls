public with sharing class CibisUsmleTranscriptsHandler {
    public static Map<String,Set<Id>> cibisIdMap; 
    
    @InvocableMethod
    public static void processUSMLETranscriptCases(List<Id> caseIds){
        try{
            if(!caseIds.isEmpty() && caseIds.size()>0){
                cibisIdMap= new Map<String,Set<Id>>();
                list<Case> caseList=new list<Case>();
                set<Id> relatedCaseIds=new set<Id>();
                list<String> lstParentIds = new list<String>();
                map<Id, list<Case>> mapPrntIdAndCases = new map<Id, list<Case>>();
                set<String> setCaseStatuses = new set<String>{Constants.CASE_STATUS_APPROVED, Constants.CASE_STATUS_PENDING_PRINT};
                 
                map<Id, Case> mapCases = new map<Id, Case>([SELECT Id, ParentId, Parent.Internal_Status__c, Internal_Status__c, Parent.isCibisTranReqInit__c, isCibisTranReqInit__c, Parent.External_Status__c, External_Status__c, Cibis_Transcript_Status__c, ContactId FROM Case WHERE Id IN:caseIds]);

                for(Case cs : mapCases.values()){
                    if(cs.ParentId != null) lstParentIds.add(cs.ParentId);
                }
                
                for(Case cs : [SELECT Id, External_Status__c, Internal_Status__c, Cibis_Transcript_Status__c, ParentId, Parent.Internal_Status__c, Parent.External_Status__c, Parent.Cibis_Transcript_Status__c,isCibisTranReqInit__C, Parent.isCibisTranReqInit__c,ContactId FROM Case WHERE ParentId IN:lstParentIds]){
                    if(!mapPrntIdAndCases.containsKey(cs.ParentId) && cs.ParentId != null) {
                        mapPrntIdAndCases.put(cs.ParentId, new list<Case>{cs});
                    }
                    else {
                        mapPrntIdAndCases.get(cs.ParentId).add(cs);
                    }
                }
     
                for(String strId : caseIds) {
                    Case objCase = null;
                    if(mapCases.containsKey(strId)) {
                        objCase = mapCases.get(strId);
                    }
                    
                    if(objCase != null) {
                        if(!objCase.Parent.isCibisTranReqInit__c && !objCase.isCibisTranReqInit__C && objCase.contactID != null){
                            caseList.add(new Case(Id = objCase.Id, isCibisTranReqInit__C = TRUE, 
                                                  Internal_Status__c = constants.CASE_STATUS_PENDING_CIBIS,
                                                  External_Status__c=constants.CASE_STATUS_SUBMITTED_IN_REVIEW));
                            
                            caseList.add(new Case(Id = objCase.ParentId, isCibisTranReqInit__c = TRUE)); 
                            
                            createCibisIdMap(Constants.CIBIS_USMLE_TRANSCRIPT_REQUEST_POST_CHECK_EVENT, objCase.ContactId);    
                        }
                        else {
                            Case childCase = null;
                            if(mapPrntIdAndCases.containskey(objCase.ParentId)) {
                                list<Case> lstChildCases = mapPrntIdAndCases.get(objCase.ParentId);
                                if(lstChildCases != null && !lstChildCases.isEmpty()) {
                                    for(Case obj : lstChildCases) {
                                        if(obj.Id != objCase.Id) {
                                            childCase = obj; 
                                            break;
                                        }
                                    }
                                }
                            }

                            if(childCase != null) {
                                if(setCaseStatuses.contains(childCase.Internal_Status__c)) {  
                                    relatedCaseIds.add(childCase.Id);
                                }
                                else if(childCase.Internal_Status__c == Constants.CASE_STATUS_REJECTED){
                                    caseList.add(new Case(Id = objCase.Id, Internal_Status__c = Constants.CASE_STATUS_REJECTED,
                                                          External_Status__c = Constants.CASE_STATUS_REJECTED));  
                                }
                                else{                           
                                    caseList.add(new Case(Id = objCase.Id, Internal_Status__c = constants.CASE_STATUS_PENDING_CIBIS,
                                                          External_Status__c=constants.CASE_STATUS_SUBMITTED_IN_REVIEW));
                                }
                            }
                        }
                    }
                }

                if(!caseList.isEmpty()){
                    CibisUtility.updateSobjects(caseList);
                }
                if(cibisIdMap!=null && !cibisIdMap.isEmpty()){
                    CibisRequestUtilityHandler.cibisPlatformEventPublish(cibisIdMap);  
                }                
                if(!relatedCaseIds.isEmpty()){
                    CibisUtility.processRelatedCaseTranscriptAnnots(null,null,relatedCaseIds);
                }
                
            }
        }
        Catch(Exception e){
            System.debug('****CibisUsmleTranscriptsHandler getMessage****'+e.getMessage());
            System.debug('****CibisUsmleTranscriptsHandler getLineNumber****'+e.getLineNumber());
            System.debug('****CibisUsmleTranscriptsHandler getStackTraceString****'+e.getStackTraceString());
        }       
    }
    
    public static void createCibisIdMap(String key,Id caseId){
        if(cibisIdMap.containskey(key)){
            cibisIdMap.get(key).add(caseId);
        }
        else{
            cibisIdMap.put(key,new set<Id>{caseId});
        }
        
    }  
    
}