/*
 CIBIS EPEX Schedule Limit request handler
*/
public class CibisEpexScheduleLimitGenReqHandler {
    
    public static list<Cibis_Entity_Search_Request_Event__e> constructPayload(String strEntity, Set<Id> caseIds){ 
        // Variable Declaration
        list<Cibis_Entity_Search_Request_Event__e> cibisEpexList = new list<Cibis_Entity_Search_Request_Event__e>();    
        try{
            if(caseIds != null && !caseIds.isEmpty()) {                
                map<Id,Case> examEpexMap=new map<Id,Case>();
                For(Case cs:[Select id,ParentId,EP_Start_Date__c,EP_End_Date__c from Case where ID IN:caseIds AND RecordType.DeveloperName=:Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD And Internal_Status__c=:Constants.CASE_STATUS_PENDING_CIBIS]){
                    examEpexMap.put(cs.ParentId,cs); 
                }
                
                List<Exam_Registration__c> lstExamRegistrations = [Select Id, Application_Id__c,Exam__c,Case__c,Case__r.Contact.USMLE_ID__c, Case__r.Contact.RecordType.DeveloperName,
                                                                   Case__r.Internal_Status__c, Case__r.RecordType.DeveloperName,EP_start_Date__c,EP_end_Date__c 
                                                                   FROM Exam_Registration__c 
                                                                   WHERE Case__c IN:examEpexMap.keyset() 
                                                                   AND Case__r.Contact.USMLE_ID__c != null WITH SECURITY_ENFORCED];
                
                if(lstExamRegistrations != null && !lstExamRegistrations.isEmpty()) {
                    
                    for(Exam_Registration__c examIterator : lstExamRegistrations) {                 
                        CibisEpexScheduleLimitRequestEventWrap.SchedulingLimit epexEvalSchedule =  new CibisEpexScheduleLimitRequestEventWrap.SchedulingLimit();  
                        epexEvalSchedule.eligibilityStartDate =  String.valueOf(examEpexMap.get(examIterator.Case__c).EP_Start_Date__c);
                        epexEvalSchedule.eligibilityEndDate =  String.valueOf(examEpexMap.get(examIterator.Case__c).EP_End_Date__c);
                        CibisEpexScheduleLimitRequestEventWrap.Payload schedulePayload=new CibisEpexScheduleLimitRequestEventWrap.Payload(epexEvalSchedule);
                        CibisEpexScheduleLimitRequestEventWrap epexEvalObj =  new CibisEpexScheduleLimitRequestEventWrap();
                        
                        epexEvalObj.payload=schedulePayload;
                        epexEvalObj.USMLEId = (examIterator.Case__r.Contact.USMLE_ID__c != null && examIterator.Case__r.Contact.USMLE_ID__c != '') ? examIterator.Case__r.Contact.USMLE_ID__c : '';
                        epexEvalObj.ExamType = (examIterator.Exam__c != null && examIterator.Exam__c != '') ? examIterator.Exam__c : '';             
                        epexEvalObj.ApplicationId = integer.valueOf(examIterator.Application_Id__c);
                        epexEvalObj.transactionId = Constants.CIBIS_SCHEDULE_LIMIT_EVENT+'-'+ String.valueOf(examEpexMap.get(examIterator.Case__c).Id)+'-'+GenericUtilities.getUUID();                  
                        epexEvalObj.entity = Constants.CIBIS_REG_CHANGE_TYPE;
                        epexEvalObj.subEntity ='';
                        epexEvalObj.operation = 'PATCH';          
                        String payload = JSON.serialize(epexEvalObj); 
                        system.debug('===payload===> ' + payload);
                        Cibis_Entity_Search_Request_Event__e requestEvent = new Cibis_Entity_Search_Request_Event__e(Payload__c = payload);                    
                        cibisEpexList.add(requestEvent);
                    }
                    
                }
            }
            return cibisEpexList;
        }
        catch(Exception e)
        {
            system.debug('===CibisEpexEvaluationGenReqHandler===> ' + e.getMessage());
            throw e; 
        }
        
    }
}