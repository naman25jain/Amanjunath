/*
 CIBIS EPEX Evaluation request handler
*/
public class CibisEpexEvaluationGenReqHandler {
    
    public static list<Cibis_Entity_Search_Request_Event__e> constructPayload(String strEntity, Set<Id> caseIds){  
        // Variable Declaration
        list<Cibis_Entity_Search_Request_Event__e> cibisEpexList = new list<Cibis_Entity_Search_Request_Event__e>();    
        String strSubEntity = Constants.CIBIS_CANDIDATE_TYPE;
        try{
            if(caseIds != null && !caseIds.isEmpty()) {                
                map<Id,Case> examEpexMap=new map<Id,Case>();
                For(Case cs:[Select id,ParentId from Case where ID IN:caseIds AND RecordType.DeveloperName=:Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD And Internal_Status__c=:Constants.CASE_STATUS_PENDING_CIBIS]){
                    examEpexMap.put(cs.ParentId,cs); 
                }
                
                List<Exam_Registration__c> lstExamRegistrations = [Select Id, Application_Id__c,Exam__c,Case__c,Case__r.Contact.USMLE_ID__c, Case__r.Contact.RecordType.DeveloperName,
                                                                   Case__r.Internal_Status__c, Case__r.RecordType.DeveloperName 
                                                                   FROM Exam_Registration__c 
                                                                   WHERE Case__c IN:examEpexMap.keyset() 
                                                                   AND Case__r.Contact.USMLE_ID__c != null WITH SECURITY_ENFORCED];
                
                if(lstExamRegistrations != null && !lstExamRegistrations.isEmpty()) {
                    
                    for(Exam_Registration__c examIterator : lstExamRegistrations) {
                        CibisEpexEvaluationRequestEventWrap.Payload epexEvalPayloadObj =  new CibisEpexEvaluationRequestEventWrap.Payload();                    
                        epexEvalPayloadObj.USMLEId = (examIterator.Case__r.Contact.USMLE_ID__c != null && examIterator.Case__r.Contact.USMLE_ID__c != '') ? examIterator.Case__r.Contact.USMLE_ID__c : '';
                        epexEvalPayloadObj.ExamType = (examIterator.Exam__c != null && examIterator.Exam__c != '') ? examIterator.Exam__c : '';             
                        epexEvalPayloadObj.ApplicationId = string.valueOf(examIterator.Application_Id__c);
                        CibisEpexEvaluationRequestEventWrap epexEvalObj =  new CibisEpexEvaluationRequestEventWrap();
                        epexEvalObj.payload = epexEvalPayloadObj;
                        epexEvalObj.transactionId = Constants.CIBIS_ELIGIBILITY_EVALUATION_EVENT+'-'+ String.valueOf(examEpexMap.get(examIterator.Case__c).Id)+'-'+System.now();                  
                        epexEvalObj.entity = Constants.CIBIS_CANDIDATE_TYPE;
                        epexEvalObj.subEntity = Constants.ELIGIBILITY_EXTENSION_EVALUATION_INFO;
                        epexEvalObj.operation = 'GET';          
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