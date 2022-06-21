/*
Construct USMLE Transcript Eligibility Response Request Payload
*/
public inherited sharing class CibisTranscriptEligGenReqHandler {
    // Method to Construct payload
    public static List<Cibis_Entity_Search_Request_Event__e> constructPayload(String eventType,set<Id> contactIds){
        // Variable Declaration
        List<Cibis_Entity_Search_Request_Event__e> lstEventsToPublish = new List<Cibis_Entity_Search_Request_Event__e>();
        try {
            system.debug('====contactIds====> ' + contactIds);
            if(contactIds != null && !contactIds.isEmpty()) {
                for(Contact con : [SELECT Id, USMLE_ID__c,(Select id from Cases where Internal_Status__c=:Constants.CASE_STATUS_PENDING_CIBIS AND isCibisTranReqInit__C=TRUE AND RecordType.DeveloperName='USMLE_Transcript') FROM Contact WHERE Id IN:contactIds]) {
                    
                    CibisTranscriptEligRequestEventWrap transObj = new CibisTranscriptEligRequestEventWrap();                              
                    transObj.USMLEId = con.USMLE_ID__c; 
                    transObj.entity = Constants.CIBIS_CANDIDATE_TYPE;
                    transObj.subEntity = '';                  
                    transObj.operation = 'GET';
                    transObj.field = Constants.TRANSCRIPT_REQUEST_CHECK;
                    if(eventType==Constants.CIBIS_USMLE_TRANSCRIPT_REQUEST_PRE_CHECK_EVENT)
                    {
                       transObj.transactionId = eventType+'-'+con.Id+'-'+GenericUtilities.getUUID();  
                    }
                    else{
                         transObj.transactionId = eventType+'-'+con.Id+'-'+con.Cases[0]?.Id+'-'+GenericUtilities.getUUID();    
                    }                     
                    lstEventsToPublish.add(new Cibis_Entity_Search_Request_Event__e(Payload__c = JSON.serialize(transObj)));  
                }
            }
            if(lstEventsToPublish != null && !lstEventsToPublish.isEmpty()) {
                return lstEventsToPublish;
            }
            else {
                return null;
            }
        }
        catch(exception e) {
            System.debug('**CibisTranscriptEligibilityGenReqHandler**'+e.getMessage());
            System.debug('**CibisTranscriptEligibilityGenReqHandler** ==> '+e.getLineNumber());
            System.debug('**CibisTranscriptEligibilityGenReqHandler** ==> '+e.getStackTraceString());
            System.debug('**CibisTranscriptEligibilityGenReqHandler** ==> '+e.getCause());
            throw e;
        }
    }
}