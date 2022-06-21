//CIBIS
public class CibisRegChangeGenReqHandler {
    
    public static list<Cibis_Entity_Search_Request_Event__e> constructPayload(String entity, Set<Id> caseIds){
         
        list<Cibis_Entity_Search_Request_Event__e> cibisRegChgList;
        try 
        {   
            if(!caseIds.isEmpty()){  
                 System.debug('****CibisRegChangeGenReqHandler***'+caseIds);
                cibisRegChgList =  new list<Cibis_Entity_Search_Request_Event__e>();       
                For(Exam_Registration__c examReg:[Select Id,Exam__c,case__c,Applicant__c,Application_Id__c,Applicant__r.USMLE_ID__c from  Exam_Registration__c where case__c IN:caseIds WITH SECURITY_ENFORCED]){
                    CibisRegChangeRequestEventWrap.regChangePayloadStatus payloadObjStatus =  new CibisRegChangeRequestEventWrap.regChangePayloadStatus();                  
                    payloadObjStatus.registrationStatus='T';
                    CibisRegChangeRequestEventWrap.regChangePayload payloadObj =  new CibisRegChangeRequestEventWrap.regChangePayload();
                    payloadObj.registrationStatus=payloadObjStatus;
                    CibisRegChangeRequestEventWrap regChangObj = new CibisRegChangeRequestEventWrap();
                    regChangObj.payload = payloadObj;
                    regChangObj.transactionId =Constants.CIBIS_EXAM_EVENT+'-'+(examReg.case__c!=null ? examReg.case__c :'')+'-'+((examReg.Exam__c != null && examReg.Exam__c != '')?examReg.Exam__c:'')+'-'+GenericUtilities.getUUID();
                    regChangObj.USMLEId = (examReg.Applicant__r.USMLE_ID__c != null && examReg.Applicant__r.USMLE_ID__c != '')?examReg.Applicant__r.USMLE_ID__c:''; 
                    regChangObj.examType = (examReg.Exam__c != null && examReg.Exam__c != '')?examReg.Exam__c:'';
                    regChangObj.entity = Constants.CIBIS_REG_CHANGE_TYPE;
                    regChangObj.subEntity = '';
                    regChangObj.applicationId=(examReg.Application_Id__c != null) ? integer.valueOf(examReg.Application_Id__c):null;
                    regChangObj.operation = 'Patch';
                    String payload = JSON.serialize(regChangObj);  
                       System.debug('****CibisRegChangeGenReqHandler***'+payload);
                    cibisRegChgList.add(new Cibis_Entity_Search_Request_Event__e(Payload__c=payload));
                }   
                
            }
            return cibisRegChgList;
        }
        catch(Exception e)
        {
            System.debug('****CibisRegChangeGenReqHandler***'+e.getMessage());
            throw e; 
        }
    }
}