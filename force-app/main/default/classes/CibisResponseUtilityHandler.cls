//CIBIS
public class CibisResponseUtilityHandler {
    Public static map<string,list<string>> cibisRespMap=new map<string,list<string>>();   
    //method to handle response
    public static void handleResponse(List<Cibis_Entity_Search_Response_Event__e> respList){
        Try{ 
            if(!respList.isEmpty()){ 
                
                for(Cibis_Entity_Search_Response_Event__e rsp : respList){
                    if(String.ValueOf(rsp.Payload__c).Contains(Constants.CIBIS_OVER_ALL_MATCH_EVENT)){                     
                        constructListMap(Constants.CIBIS_OVER_ALL_MATCH_EVENT,rsp.Payload__c);
                    }
                    else if(String.ValueOf(rsp.Payload__c).Contains(Constants.CIBIS_EXAM_REG_HISTORY_EVENT)){
                        system.debug('respList'+rsp.Payload__c);
                        constructListMap(Constants.CIBIS_EXAM_REG_HISTORY_EVENT,rsp.Payload__c);
                        system.debug('respList'+rsp.Payload__c);
                    }
                    else if(String.ValueOf(rsp.Payload__c).Contains(Constants.CIBIS_CANDIDATE_EVENT)){
                        constructListMap(Constants.CIBIS_CANDIDATE_EVENT,rsp.Payload__c);
                    }              
                    else if(String.ValueOf(rsp.Payload__c).Contains(Constants.CIBIS_REGISTRATION_EVENT)){
                        constructListMap(Constants.CIBIS_REGISTRATION_EVENT,rsp.Payload__c);
                    }
                    else if(String.ValueOf(rsp.Payload__c).Contains(Constants.CIBIS_EXAM_EVENT)){
                        constructListMap(Constants.CIBIS_EXAM_EVENT,rsp.Payload__c);
                    }
                    else if(String.ValueOf(rsp.Payload__c).Contains(Constants.CIBIS_ELIGIBILITY_EVALUATION_EVENT)){
                        constructListMap(Constants.CIBIS_ELIGIBILITY_EVALUATION_EVENT,rsp.Payload__c);
                    }
                     else if(String.ValueOf(rsp.Payload__c).Contains(Constants.CIBIS_ELIGIBILITY_REVISION_EVENT)){
                        constructListMap(Constants.CIBIS_ELIGIBILITY_REVISION_EVENT,rsp.Payload__c);
                    }
                     else if(String.ValueOf(rsp.Payload__c).Contains(Constants.CIBIS_SCHEDULE_LIMIT_EVENT)){
                        constructListMap(Constants.CIBIS_SCHEDULE_LIMIT_EVENT,rsp.Payload__c);
                    }
                    else if(String.ValueOf(rsp.Payload__c).Contains(Constants.CIBIS_USMLE_TRANSCRIPT_REQUEST_PRE_CHECK_EVENT)){
                        constructListMap(Constants.CIBIS_USMLE_TRANSCRIPT_REQUEST_PRE_CHECK_EVENT,rsp.Payload__c);
                    }
                      else if(String.ValueOf(rsp.Payload__c).Contains(Constants.CIBIS_USMLE_TRANSCRIPT_REQUEST_POST_CHECK_EVENT)){
                        constructListMap(Constants.CIBIS_USMLE_TRANSCRIPT_REQUEST_POST_CHECK_EVENT,rsp.Payload__c);
                    }
                      else if(String.ValueOf(rsp.Payload__c).Contains(Constants.CIBIS_SECR_DOCURL_EVENT)){
                        constructListMap(Constants.CIBIS_SECR_DOCURL_EVENT,rsp.Payload__c);
                    }
                    else if(String.ValueOf(rsp.Payload__c).Contains(Constants.CIBIS_NOTES_REQUEST_EVENT)){
                        constructListMap(Constants.CIBIS_NOTES_REQUEST_EVENT,rsp.Payload__c);
                    }
                    else if(String.ValueOf(rsp.Payload__c).Contains(Constants.CIBIS_APPLICANT_IRREGULAR_BEHAVIOR_EVENT)){
                        constructListMap(Constants.CIBIS_APPLICANT_IRREGULAR_BEHAVIOR_EVENT,rsp.Payload__c);
                    }
                    else if(String.ValueOf(rsp.Payload__c).Contains(constants.CIBIS_EXAM_HISTORY_IRREGULAR_BEHAVIOR_EVENT)){
                        System.debug('Building Map');
                        constructListMap(constants.CIBIS_EXAM_HISTORY_IRREGULAR_BEHAVIOR_EVENT,rsp.Payload__c);
                    }
                  
                    
                    else if(String.ValueOf(rsp.Payload__c).Contains(Constants.CIBIS_SECR_DOCINFO_EVENT)){
                        constructListMap(Constants.CIBIS_SECR_DOCINFO_EVENT,rsp.Payload__c);
                    }
                    else if(String.ValueOf(rsp.Payload__c).Contains(Constants.CIBIS_SCORE_REPORT_EVENT)){
                        constructListMap(Constants.CIBIS_SCORE_REPORT_EVENT,rsp.Payload__c);
                    }
                    system.debug('cibisRespMap'+cibisRespMap);
                }
                if(!respList.isEmpty()){
                    GenericUtilities.upsertErrorLogForEvents(respList, null, Constants.RESPONSE);
                }
                if(!cibisRespMap.isEmpty()){
                    processResponse(cibisRespMap);
                }
                
                
            }
        }
        
        Catch(Exception e){            
            CibisUtility.insertSobjects(new list<npsp__Error__c>{new npsp__Error__c(npsp__Full_Message__c=e.getMessage()+'--'+e.getTypeName(),npsp__Stack_Trace__c=e.getStackTraceString()+'--'+e.getLineNumber(),npsp__Error_Type__c='CibisResponseUtilityHandler')});
            System.debug('**CibisResponseUtilityHandler**'+e.getMessage());
            System.debug('**CibisResponseUtilityHandler**'+e.getStackTraceString());
            System.debug('**CibisResponseUtilityHandler**'+e.getLineNumber());
        }
    }
    Public static void processResponse(Map<String,list<String>> cibisRespMap){
        system.debug('cibisRespMap'+cibisRespMap);
        if(cibisRespMap.Containskey(Constants.CIBIS_OVER_ALL_MATCH_EVENT)){ 
            CibisDupCheckConResHandler.handleResponse(cibisRespMap.get(Constants.CIBIS_OVER_ALL_MATCH_EVENT));            
        }
        if(cibisRespMap.Containskey(Constants.CIBIS_EXAM_REG_HISTORY_EVENT)){            
            CibisExamHistoryConRespHandler.handleResponse(cibisRespMap.get(Constants.CIBIS_EXAM_REG_HISTORY_EVENT));            
        }
        if(cibisRespMap.Containskey(Constants.CIBIS_CANDIDATE_EVENT)){
            CibisCandidateConRespHandler.handleResponse(cibisRespMap.get(Constants.CIBIS_CANDIDATE_EVENT));
        }
        if(cibisRespMap.Containskey(Constants.CIBIS_EXAM_EVENT)){
            CibisRegChangeConRespHandler.handleResponse(cibisRespMap.get(Constants.CIBIS_EXAM_EVENT)); 
        }
        if(cibisRespMap.Containskey(Constants.CIBIS_REGISTRATION_EVENT)){
            CibisExamRegConRespHandler.handleResponse(cibisRespMap.get(Constants.CIBIS_REGISTRATION_EVENT));
        }
        if(cibisRespMap.Containskey(Constants.CIBIS_ELIGIBILITY_EVALUATION_EVENT)){
            CibisEpexEvaluationConRespHandler.handleResponse(cibisRespMap.get(Constants.CIBIS_ELIGIBILITY_EVALUATION_EVENT));
        }
         if(cibisRespMap.Containskey(Constants.CIBIS_ELIGIBILITY_REVISION_EVENT)){
            CibisEpexEligRevisionConRespHandler.handleResponse(cibisRespMap.get(Constants.CIBIS_ELIGIBILITY_REVISION_EVENT));
        }
         if(cibisRespMap.Containskey(Constants.CIBIS_SCHEDULE_LIMIT_EVENT)){
            CibisEpexScheduleLimitConRespHandler.handleResponse(cibisRespMap.get(Constants.CIBIS_SCHEDULE_LIMIT_EVENT));
        }
        if(cibisRespMap.Containskey(Constants.CIBIS_USMLE_TRANSCRIPT_REQUEST_PRE_CHECK_EVENT)){
            CibisTranscriptEligConRespHandler.handleResponse(cibisRespMap.get(Constants.CIBIS_USMLE_TRANSCRIPT_REQUEST_PRE_CHECK_EVENT));
        } 
         if(cibisRespMap.Containskey(Constants.CIBIS_USMLE_TRANSCRIPT_REQUEST_POST_CHECK_EVENT)){
            CibisTranscriptEligConRespHandler.handleResponse(cibisRespMap.get(Constants.CIBIS_USMLE_TRANSCRIPT_REQUEST_POST_CHECK_EVENT));
        } 
         if(cibisRespMap.containskey(Constants.CIBIS_SECR_DOCURL_EVENT)){
            CibisSecrDocURLConRespHandler.handleResponse(cibisRespMap.get(Constants.CIBIS_SECR_DOCURL_EVENT));
        }
        
      /*  if(cibisRespMap.containskey(Constants.CIBIS_NOTES_REQUEST_EVENT)){
            CibisTranscriptsNotesConRespHandler.handleResponse(cibisRespMap.get(Constants.CIBIS_NOTES_REQUEST_EVENT));
        }*/ 
        
        if(cibisRespMap.containskey(constants.CIBIS_EXAM_HISTORY_IRREGULAR_BEHAVIOR_EVENT)){
            System.debug('Invoking method');
            CibisExamIrregularConRespHandler.handleResponse(cibisRespMap.get(constants.CIBIS_EXAM_HISTORY_IRREGULAR_BEHAVIOR_EVENT));
        }     
                
        if(cibisRespMap.containskey(Constants.CIBIS_APPLICANT_IRREGULAR_BEHAVIOR_EVENT)){
            CibisCandIrregularConRespHandler.handleResponse(cibisRespMap.get(Constants.CIBIS_APPLICANT_IRREGULAR_BEHAVIOR_EVENT));
        } 
        if(cibisRespMap.containskey(Constants.CIBIS_SCORE_REPORT_EVENT)){
            CibisScoreReportConRespHandler.handleResponse(cibisRespMap.get(Constants.CIBIS_SCORE_REPORT_EVENT));
        }
        
    } 
    
    public static void constructListMap(string strKey,string strValue) {
        if(!cibisRespMap.containskey(strKey)){
            cibisRespMap.put(strKey,new list<String>{strValue});
        }   
        else{
            cibisRespMap.get(strKey).add(strValue); 
        }
    }
    
    
}