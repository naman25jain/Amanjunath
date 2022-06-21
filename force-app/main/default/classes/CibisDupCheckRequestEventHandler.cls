/*
Constructing Platform event Payload for CIBIS Duplicate Applicant Data Request: Request Payload for Cibis Duplicate Records
*/
public with sharing class CibisDupCheckRequestEventHandler{
    
    // This method invoke from flow to publish Platform event to get Cibis Duplicate Records
    @InvocableMethod
    Public static void buildDupCheck(list<Id> caseIds){
        if(!caseIds.isEmpty()){
            buildDupCheckPayload(string.valueOf(caseIds[0]));
        }
    }
    
    // Request Construction payload method
    public static String buildDupCheckPayload(String caseId){
        list<npsp__Error__c> npspErrorLogs=new list<npsp__Error__c>();
        try
        {            
            String conId='';
            if(!String.isBlank(caseId)){
                
                // Variable declaration and assignment
                map<String,string> genderMap=new map<String,String>{'Male'=>'M','Female'=>'F','X'=>'X'};
                    Contact_Association_Type__c catRecord;
                List<Case> caseList = [SELECT Id,Internal_Status__c,ContactId,Contact.Account.Medschool_Code__c,Contact.Birthdate,Contact.FirstName,Contact.LastName,
                                       Contact.Generational_Suffix__c,Contact.USMLE_ID__c,Contact.Gender__c,Contact.US_Social_Security__c FROM Case WHERE Id=:caseId WITH SECURITY_ENFORCED];
                
                if(caseList != null && !caseList.isEmpty()){              
                    conId = caseList[0].ContactId;
                    if(conId!=null && conId!=''){
                        catRecord=[Select id,Account__c,Account__r.Medschool_Code__c from Contact_Association_Type__c where Contact__c=:conId limit 1];
                    }
                    CibisDupCheckRequestEvent.dupCheckPayload payloadObj = new CibisDupCheckRequestEvent.dupCheckPayload();
                    payloadObj.gender=genderMap?.get(caseList[0].Contact.Gender__c);
                    payloadObj.USMLEId = (caseList[0].Contact.USMLE_ID__c != null && caseList[0].Contact.USMLE_ID__c != '')?caseList[0].Contact.USMLE_ID__c:'';
                    payloadObj.lastName = (caseList[0].Contact.LastName != null && caseList[0].Contact.LastName != '')?caseList[0].Contact.LastName:'';
                    payloadObj.restOfName = (caseList[0].Contact.FirstName != null && caseList[0].Contact.FirstName != '')?caseList[0].Contact.FirstName:'';
                    payloadObj.generationSuffix = (caseList[0].Contact.Generational_Suffix__c != null && caseList[0].Contact.Generational_Suffix__c != '')?caseList[0].Contact.Generational_Suffix__c:'';
                    payloadObj.SSN = (caseList[0].Contact.US_Social_Security__c != null && caseList[0].Contact.US_Social_Security__c != '')?caseList[0].Contact.US_Social_Security__c:'';
                    payloadObj.medicalSchoolCode = (catRecord.Account__r.Medschool_Code__c != null &&  catRecord.Account__r.Medschool_Code__c !='') ? catRecord.Account__r.Medschool_Code__c:'';
                    payloadObj.dateOfBirth = String.valueOf(caseList[0].Contact.Birthdate);
                    payloadObj.matchThresholdPercentage = 40;
                    payloadObj.maxResultRows = 60;
                    CibisDupCheckRequestEvent changeRequestObj = new CibisDupCheckRequestEvent();
                    changeRequestObj.payload = payloadObj;
                    changeRequestObj.entity = Constants.CIBIS_CANDIDATE_TYPE;
                    changeRequestObj.subEntity = 'searchCandidate';
                    changeRequestObj.transactionId =Constants.CIBIS_OVER_ALL_MATCH_EVENT+'-'+conId +'-'+caseList[0].Id+'-'+GenericUtilities.getUUID();
                    changeRequestObj.operation = 'POST';
                    
                    // Create an instance of the event with field values
                    String payload = JSON.serialize(changeRequestObj);
                    system.debug('===payload===> '+payload);
                    Cibis_Entity_Search_Request_Event__e requestEvent = new Cibis_Entity_Search_Request_Event__e(Payload__c=payload);
                    
                    // Call method to publish events
                    Database.SaveResult sr = EventBus.publish(requestEvent);
                    
                    // Inspect publishing result
                    if (sr.isSuccess()) {
                        Id queueId = [SELECT Id FROM Group WHERE Type='Queue' AND DeveloperName=:Constants.CASE_QUEUE_ID_Review_Queue].Id;
                        caseList[0].Internal_Status__c = Constants.CASE_STATUS_PENDING_CIBIS;
                        caseList[0].External_Status__c = Constants.CASE_EXTERNAL_STATUS_SUBMITTED_ID_REVIEW;
                        caseList[0].OwnerId = queueId;
                        
                        // Capture the Error logs from Request payload when publishing get sucsess
                        npspErrorLogs.add(new npsp__Error__c(Unique_Key__c=changeRequestObj.transactionId,Request__c=payload,Case__c=caseList[0].Id));
                    } else {
                        for(Database.Error err : sr.getErrors()) {
                            caseList[0].Internal_Status__c = Constants.CASE_STATUS_ERROR_CIBIS;
                            system.debug('===errorMessage===> '+ err.getMessage());
                            
                            // Capture the Error logs from Request payload when publishing get failed
                            npspErrorLogs.add(new npsp__Error__c(Unique_Key__c=changeRequestObj.transactionId,npsp__Full_Message__c=err.getMessage(),Request__c=payload,Case__c=caseList[0].Id));
                        }
                    }
                    // Call Generic utilities log method to insert/ Upsert logs in Error log object
                    if(!npspErrorLogs.isEmpty()){
                        GenericUtilities.createErrorLogs(npspErrorLogs);
                    }
                    
                     // Update Case Internal & External Status based on event publishing results
                    if(Case.SObjectType.getDescribe().isUpdateable()){
                        update caseList;
                    }
                    return 'Success';
                }
            } else{
                return null;
            }
        }
        catch(Exception e)
        {
            // Capture the Error logs when Exception occurs
            CibisUtility.insertSobjects(new list<npsp__Error__c>{new npsp__Error__c(npsp__Full_Message__c=e.getMessage()+'--'+e.getTypeName(),npsp__Stack_Trace__c=e.getStackTraceString()+'--'+e.getLineNumber(),npsp__Error_Type__c='CibisDupCheckRequestEventHandler',Case__c=caseId)});
            throw e;
        }
        return null;
    }
}