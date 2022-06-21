//CIBIS
public inherited sharing class CibisExamIrregularGenReqHandler {

    public static list<Cibis_Entity_Search_Request_Event__e> constructPayload(String strEvent, Set<Id> caseIds){
        list<Cibis_Entity_Search_Request_Event__e> lstCmntsEvents = new list<Cibis_Entity_Search_Request_Event__e>();
        try{
        if(caseIds != null && !caseIds.isEmpty()) {
            for(case cs:[Select id,ContactID,contact.USMLE_ID__c from case where ID IN:caseIds]) {
                CibisExamIrregularRequestEventWrap obj = new CibisExamIrregularRequestEventWrap();
                obj.entity = Constants.CIBIS_REG_CHANGE_TYPE; 
                obj.subEntity = '';
                obj.transactionId = constants.CIBIS_EXAM_HISTORY_IRREGULAR_BEHAVIOR_EVENT +'-'+cs.ContactId+'-'+cs.Id+'-'+GenericUtilities.getUUID();
                obj.applicationId =String.valueOf(0);
                obj.USMLEId = cs.Contact.USMLE_ID__c;
                obj.examType = '';
                obj.field = constants.EXAM_HISTORY_IRREGULAR;
                obj.operation = 'GET';
                lstCmntsEvents.add(new Cibis_Entity_Search_Request_Event__e(Payload__c = JSON.serialize(obj)));
            }
        }   
        
        if(lstCmntsEvents != null && !lstCmntsEvents.isEmpty()) {
            return lstCmntsEvents;
        }
        else {
            return null;
        }
      }
        catch(exception ex) {
            System.debug('**CibisExamIrregularGenReqHandle**'+ex.getMessage());
            throw ex;
        } 
    }
}