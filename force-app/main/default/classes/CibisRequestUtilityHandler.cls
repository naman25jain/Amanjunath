//CIBIS
public class CibisRequestUtilityHandler {
    
    // Method is used to Construct different Cibis Platform Request Events and publsih 
    public static void cibisPlatformEventPublish(Map<String,Set<Id>> cibisIdMap){
        try{
            //Variable declaration
            List<Cibis_Entity_Search_Request_Event__e> reqInsLst = new List<Cibis_Entity_Search_Request_Event__e>();
            System.debug('******CibisRequestUtilityHandler'+cibisIdMap);
            //Constructing payload from different handlers - Inorder to support bulfication- using if instead of else if block
            if(cibisIdMap.containsKey(Constants.CIBIS_EXAM_EVENT) && !cibisIdMap.get(Constants.CIBIS_EXAM_EVENT).isEmpty()){  
                reqInsLst.addAll(CibisRegChangeGenReqHandler.constructPayload(Constants.CIBIS_EXAM_EVENT,cibisIdMap.get(Constants.CIBIS_EXAM_EVENT)));
            }
            if(cibisIdMap.containsKey(Constants.CIBIS_REGISTRATION_EVENT) && !cibisIdMap.get(Constants.CIBIS_REGISTRATION_EVENT).isEmpty()){
                reqInsLst.addAll(CibisExamRegGenReqHandler.constructPayload(Constants.CIBIS_REGISTRATION_EVENT,cibisIdMap.get(Constants.CIBIS_REGISTRATION_EVENT)));
            }
            if(cibisIdMap.containsKey(Constants.CIBIS_CANDIDATE_EVENT) && !cibisIdMap.get(Constants.CIBIS_CANDIDATE_EVENT).isEmpty()){
                reqInsLst.addAll(CibisCandidateGenReqHandler.constructPayload(Constants.CIBIS_CANDIDATE_EVENT,cibisIdMap.get(Constants.CIBIS_CANDIDATE_EVENT)));  
            }
            if(cibisIdMap.containsKey(Constants.CIBIS_ELIGIBILITY_EVALUATION_EVENT) && !cibisIdMap.get(Constants.CIBIS_ELIGIBILITY_EVALUATION_EVENT).isEmpty()){
                reqInsLst.addAll(CibisEpexEvaluationGenReqHandler.constructPayload(Constants.CIBIS_ELIGIBILITY_EVALUATION_EVENT,cibisIdMap.get(Constants.CIBIS_ELIGIBILITY_EVALUATION_EVENT))); 
            }
            if(cibisIdMap.containsKey(Constants.CIBIS_ELIGIBILITY_REVISION_EVENT) && !cibisIdMap.get(Constants.CIBIS_ELIGIBILITY_REVISION_EVENT).isEmpty()){
                reqInsLst.addAll(CibisEpexEligRevisionGenReqHandler.constructPayload(Constants.CIBIS_ELIGIBILITY_REVISION_EVENT,cibisIdMap.get(Constants.CIBIS_ELIGIBILITY_REVISION_EVENT))); 
            }
            if(cibisIdMap.containsKey(Constants.CIBIS_SCHEDULE_LIMIT_EVENT) && !cibisIdMap.get(Constants.CIBIS_SCHEDULE_LIMIT_EVENT).isEmpty()){
                reqInsLst.addAll(CibisEpexScheduleLimitGenReqHandler.constructPayload(Constants.CIBIS_SCHEDULE_LIMIT_EVENT,cibisIdMap.get(Constants.CIBIS_SCHEDULE_LIMIT_EVENT))); 
            }
            
            if(cibisIdMap.containsKey(Constants.CIBIS_USMLE_TRANSCRIPT_REQUEST_PRE_CHECK_EVENT) && !cibisIdMap.get(Constants.CIBIS_USMLE_TRANSCRIPT_REQUEST_PRE_CHECK_EVENT).isEmpty()) {
                reqInsLst.addAll(CibisTranscriptEligGenReqHandler.constructPayload(Constants.CIBIS_USMLE_TRANSCRIPT_REQUEST_PRE_CHECK_EVENT,cibisIdMap.get(Constants.CIBIS_USMLE_TRANSCRIPT_REQUEST_PRE_CHECK_EVENT))); 
            }
            if(cibisIdMap.containsKey(Constants.CIBIS_USMLE_TRANSCRIPT_REQUEST_POST_CHECK_EVENT) && !cibisIdMap.get(Constants.CIBIS_USMLE_TRANSCRIPT_REQUEST_POST_CHECK_EVENT).isEmpty()) {
                reqInsLst.addAll(CibisTranscriptEligGenReqHandler.constructPayload(Constants.CIBIS_USMLE_TRANSCRIPT_REQUEST_POST_CHECK_EVENT,cibisIdMap.get(Constants.CIBIS_USMLE_TRANSCRIPT_REQUEST_POST_CHECK_EVENT))); 
            }
            if(cibisIdMap.containsKey(Constants.CIBIS_SECR_DOCURL_EVENT) && !cibisIdMap.get(Constants.CIBIS_SECR_DOCURL_EVENT).isEmpty()) {
                reqInsLst.addAll(CibisSecrDocGenReqHandler.constructPayload(Constants.CIBIS_SECR_DOCURL_EVENT,cibisIdMap.get(Constants.CIBIS_SECR_DOCURL_EVENT))); 
            }
            if(cibisIdMap.containsKey(Constants.CIBIS_APPLICANT_IRREGULAR_BEHAVIOR_EVENT) && !cibisIdMap.get(Constants.CIBIS_APPLICANT_IRREGULAR_BEHAVIOR_EVENT).isEmpty()) {
                reqInsLst.addAll(CibisCandIrregularGenReqHandler.constructPayload(Constants.CIBIS_APPLICANT_IRREGULAR_BEHAVIOR_EVENT,cibisIdMap.get(Constants.CIBIS_APPLICANT_IRREGULAR_BEHAVIOR_EVENT))); 
            }                  
            
            if(cibisIdMap.containsKey(Constants.CIBIS_EXAM_HISTORY_IRREGULAR_BEHAVIOR_EVENT) && !cibisIdMap.get(Constants.CIBIS_EXAM_HISTORY_IRREGULAR_BEHAVIOR_EVENT).isEmpty()) {
                reqInsLst.addAll(CibisExamIrregularGenReqHandler.constructPayload(Constants.CIBIS_EXAM_HISTORY_IRREGULAR_BEHAVIOR_EVENT,cibisIdMap.get(Constants.CIBIS_EXAM_HISTORY_IRREGULAR_BEHAVIOR_EVENT))); 
            }                  
            
            
            
            if(!reqInsLst.isEmpty()){
                publishCibisEvents(reqInsLst);
            }
        } 
        catch(Exception e)
        {
            system.debug('===CandidateCreationError===> ' + e.getMessage());
            throw e; 
        } 
        
    }
    /*  @InvocableMethod
public static void processExamRegisrationManualReview(List<Id> caseIds)
{
System.debug('***caseIds'+caseIds);
Map<String,Set<Id>> cibisIdMap=new map<String,Set<Id>>();
if(!caseIds.isEmpty() && caseIds!=null){
For(Id caseId:caseIds){
if(!cibisIdMap.containskey(Constants.CIBIS_REGISTRATION_EVENT)){
cibisIdMap.put(Constants.CIBIS_REGISTRATION_EVENT,new set<Id>{caseId});
}else{
cibisIdMap.get(Constants.CIBIS_REGISTRATION_EVENT).add(caseId); 
}   
}  
}
if(!cibisIdMap.isEmpty() && cibisIdMap!=null){
cibisPlatformEventPublish(cibisIdMap);
}

}*/
    @InvocableMethod
    public static void processEnrollementVerificationCase(List<Case> lstCases)
    {
        Id recTypeId=GenericUtilities.getRecordTypeIdByDevName('Case',Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION);
        Map<String,Set<Id>> cibisIdMap=new map<String,Set<Id>>();
        if(!lstCases.isEmpty() && lstCases!=null){
            For(case cs:lstCases){
                if(cs.RecordTypeId==recTypeId){
                    if(!cibisIdMap.containskey(Constants.CIBIS_REGISTRATION_EVENT)){
                        cibisIdMap.put(Constants.CIBIS_REGISTRATION_EVENT,new set<Id>{cs.Id});
                    }else{
                        cibisIdMap.get(Constants.CIBIS_REGISTRATION_EVENT).add(cs.Id); 
                    }   
                }
                else{
                    if(!cibisIdMap.containskey(Constants.CIBIS_ELIGIBILITY_EVALUATION_EVENT)){
                        cibisIdMap.put(Constants.CIBIS_ELIGIBILITY_EVALUATION_EVENT,new set<Id>{cs.Id});
                    }else{
                        cibisIdMap.get(Constants.CIBIS_ELIGIBILITY_EVALUATION_EVENT).add(cs.Id); 
                    }     
                }
            }
            
        }
        if(!cibisIdMap.isEmpty() && cibisIdMap!=null){
            cibisPlatformEventPublish(cibisIdMap);
        }
        
    }
    
    // Method is used to Publish Platform Events
    public static void publishCibisEvents(List<Cibis_Entity_Search_Request_Event__e> requestEvents){
        system.debug('===requestEvents===> ' + requestEvents);
        Database.SaveResult[] srList = EventBus.publish(requestEvents); 
        
        if(srList != null && !srList.isEmpty()) {
            GenericUtilities.upsertErrorLogForEvents(requestEvents, srList, Constants.REQUEST);
        }
    }
}