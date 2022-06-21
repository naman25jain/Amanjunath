//CIBIS
public class CibisCandIrregularGenReqHandler {
    public static list<Cibis_Entity_Search_Request_Event__e> constructPayload(String strEntity, Set<Id> caseIds)
    {
        list<Cibis_Entity_Search_Request_Event__e> cibisNotesList; 
        try{
            if(!caseIds.isEmpty() && String.isNotBlank(strEntity) ) {
                cibisNotesList=new list<Cibis_Entity_Search_Request_Event__e>();
                for(case cs:[Select id,ContactID,contact.USMLE_ID__c from case where ID IN:caseIds]) {
                    
                    CibisCandIrregularRequestEventWrap obj=new CibisCandIrregularRequestEventWrap();
                    obj.entity=constants.CIBIS_CANDIDATE_TYPE;
                    obj.subEntity='';
                    obj.field=constants.TRANSCRIPT_EVALUATION_INFO;
                    obj.operation='GET';
                    obj.USMLEId=cs.contact.USMLE_ID__c<> null ? string.valueOf(cs.contact.USMLE_ID__c): null;
                    obj.transactionId=constants.CIBIS_APPLICANT_IRREGULAR_BEHAVIOR_EVENT+'-'+cs.ContactId+'-'+cs.Id+'-'+GenericUtilities.getUUID();
                    String payload = JSON.serialize(obj);
                    Cibis_Entity_Search_Request_Event__e requestEvent = new Cibis_Entity_Search_Request_Event__e(Payload__c = payload);
                    System.debug('CibisCandIrregularGenReqHandler'+requestEvent);
                    cibisNotesList.add(requestEvent);
                }
            }
            if(cibisNotesList != null && !cibisNotesList.isEmpty()) {
                return cibisNotesList;
            }
            else {
                return null;
            }  
        }
        catch(exception ex) {
            System.debug('**CibisCandIrregularGenReqHandler**'+ex.getMessage());
            throw ex;
        } 
    }
}