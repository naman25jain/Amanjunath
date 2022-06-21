/*
Construct CIBIS EPEX Eligibility Revision Request Payload
*/
public with sharing class CibisEpexEligRevisionGenReqHandler {
    
    public static list<Cibis_Entity_Search_Request_Event__e> constructPayload(String strEntity, Set<Id> caseIds){
        // return variable declartion
        list<Cibis_Entity_Search_Request_Event__e> cibisEpexList = new list<Cibis_Entity_Search_Request_Event__e>();
        String strSubEntity = Constants.CIBIS_CANDIDATE_TYPE;
        try{
            if(caseIds != null && !caseIds.isEmpty()) {
                map<String,String> stateCodeMap=new map<String,String>();                
                For(Countries_and_States__c cs:Countries_and_States__c.getall().values()){
                    stateCodeMap.put(cs.State_Name__c,cs.State_Code__c);  
                    system.debug('stateCodeMap'+stateCodeMap);
                }
                map<Id,Case> examEpexMap=new map<Id,Case>();
                For(Case cs:[Select id,ParentId,EP_Start_Date__c,EP_End_Date__c from Case where ID IN:caseIds AND RecordType.DeveloperName=:Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD And Internal_Status__c=:Constants.CASE_STATUS_PENDING_CIBIS]){
                    examEpexMap.put(cs.ParentId,cs); 
                }
                
                List<Exam_Registration__c> lstExamRegistrations = [Select Id, Application_Id__c, EP_end_Date__c, EP_start_Date__c,Exam__c, Case__c,
                                                                   Case__r.ContactId, Case__r.Contact.FirstName, Case__r.Contact.MiddleName, Case__r.Contact.LastName, Case__r.Contact.MailingStreet, 
                                                                   Case__r.Contact.MailingCity,Case__r.Contact.MailingCountry, Case__r.Contact.MailingCountryCode, Case__r.Contact.MailingState, 
                                                                   Case__r.Contact.MailingPostalCode, Case__r.Contact.Generational_Suffix__c, Case__r.Contact.USMLE_ID__c, Case__r.Contact.RecordType.DeveloperName,
                                                                   Case__r.Internal_Status__c, Case__r.RecordType.DeveloperName 
                                                                   FROM Exam_Registration__c 
                                                                   WHERE Case__c IN:examEpexMap.keyset() 
                                                                   AND Case__r.Contact.USMLE_ID__c != null WITH SECURITY_ENFORCED];
                
                if(lstExamRegistrations != null && !lstExamRegistrations.isEmpty()) {
                    
                    for(Exam_Registration__c examIterator : lstExamRegistrations) {
                        CibisEpexEligRevisionRequestEventWrap.epexPayload epexPayloadObj =  new CibisEpexEligRevisionRequestEventWrap.epexPayload();
                        epexPayloadObj.USMLEId = (examIterator.Case__r.Contact.USMLE_ID__c != null && examIterator.Case__r.Contact.USMLE_ID__c != '') ? examIterator.Case__r.Contact.USMLE_ID__c : '';
                        epexPayloadObj.exam = (examIterator.Exam__c != null && examIterator.Exam__c != '') ? examIterator.Exam__c : '';             
                        epexPayloadObj.applicationId = Integer.valueOf(examIterator.Application_Id__c);
                        epexPayloadObj.address1 =(examIterator?.Case__r?.Contact?.MailingStreet != null && examIterator?.Case__r?.Contact?.MailingStreet != '') ? examIterator?.Case__r?.Contact?.MailingStreet : '';                  
                        epexPayloadObj.city = (examIterator.Case__r.Contact.MailingCity != null && examIterator.Case__r.Contact.MailingCity != '') ? examIterator.Case__r.Contact.MailingCity : '';
                        epexPayloadObj.state = stateCodeMap.containskey(examIterator.Case__r.Contact.MailingState) ? stateCodeMap.get(examIterator.Case__r.Contact.MailingState) : '';                   
                        epexPayloadObj.zip = (examIterator?.Case__r?.Contact?.MailingPostalCode != null && examIterator?.Case__r?.Contact?.MailingPostalCode != '') ? examIterator?.Case__r?.Contact?.MailingPostalCode : '';
                        epexPayloadObj.address4 = epexPayloadObj.city+', '+ epexPayloadObj.state+' '+ epexPayloadObj.zip;
                        epexPayloadObj.lastName = (examIterator?.Case__r?.Contact?.LastName != null && examIterator?.Case__r?.Contact?.LastName !='') ? examIterator?.Case__r?.Contact?.LastName : '';
                        epexPayloadObj.firstName = '';
                        epexPayloadObj.middleName = '';                       
                        epexPayloadObj.restOfName = (examIterator.Case__r.Contact.firstName != null && examIterator.Case__r.Contact.firstName != '') ? examIterator.Case__r.Contact.firstName : '';
                        epexPayloadObj.reportName=epexPayloadObj.lastName+','+ epexPayloadObj.restOfName;
                        epexPayloadObj.generationSuffix = examIterator.Case__r.Contact.Generational_Suffix__c!=null? examIterator.Case__r.Contact.Generational_Suffix__c :'';  
                        epexPayloadObj.eligibilityStartDate = String.valueOf(examEpexMap.get(examIterator.Case__c).EP_Start_Date__c);
                        epexPayloadObj.eligibilityEndDate =String.valueOf(examEpexMap.get(examIterator.Case__c).EP_End_Date__c);
                        
                        CibisEpexEligRevisionRequestEventWrap epexRequestObj = new CibisEpexEligRevisionRequestEventWrap();
                        epexRequestObj.payload = epexPayloadObj;
                        epexRequestObj.transactionId = Constants.CIBIS_ELIGIBILITY_REVISION_EVENT+'-'+ String.valueOf(examEpexMap.get(examIterator.Case__c).Id)+'-'+GenericUtilities.getUUID();
                        epexRequestObj.USMLEId = examIterator.Case__r.Contact.USMLE_ID__c;
                        epexRequestObj.entity = Constants.CIBIS_CANDIDATE_TYPE;
                        epexRequestObj.subEntity = Constants.CIBIS_EPEX_TYPE;
                        epexRequestObj.operation = 'POST';
                        epexRequestObj.field = '';
                        
                        String payload = JSON.serialize(epexRequestObj);
                        Cibis_Entity_Search_Request_Event__e requestEvent = new Cibis_Entity_Search_Request_Event__e(Payload__c = payload);
                        
                        cibisEpexList.add(requestEvent);
                    }
                    
                }
            }
            return cibisEpexList;
        }
        catch(Exception e)
        {
            system.debug('===CibisEpexError===> ' + e.getMessage());
            throw e; 
        } 
    }
    
}