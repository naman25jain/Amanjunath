/*
Handle CIBIS Duplicate Applicant Response Payload
*/
public with sharing class CibisDupCheckConResHandler{
    
    // Variable Declaration
    Public static set<Id> caseIdsWDup;
    Public static set<Id> caseIdsWODup;
    Public static list <Case> updateCaseList;
    Public static Map<Id,Case> updateCaseMap;
    Public static set<Id> idVerCaseIds;
    Public static list<CIBIS_Duplicate_Check__c> cibisDupCheckList;
    Public static  list<npsp__Error__c> npspErrorLogs=new list<npsp__Error__c>();
    
    // Method to Handle Response Event from Platform Event Trigger routed from ResponseUtilityHandler
    public static void handleResponse(list<String> lstPayloads){
        
        if(lstPayloads != null && !lstPayloads.isEmpty()) {            
            updateCaseMap=new map<Id,Case>();
            idVerCaseIds=new set<Id>();
            cibisDupCheckList=new list<CIBIS_Duplicate_Check__c>();
            list<Case> lstFailureCaseToUpdate = new list<Case>();
            
            // Iterate each payload and construct process payload 
            for(String strPayload : lstPayloads) {
                processPayload(strPayload);
            }
            // Utility method to Insert Sobject - CIBIS Duplicate Applicants data
            if(!cibisDupCheckList.isEmpty()){
                CibisUtility.insertSobjects(cibisDupCheckList);
            }
            
            //Utility method to Update Sobject - Update Case data based on the response status
            if(!updateCaseMap.isEmpty()){
                CibisUtility.updateSobjects(updateCaseMap.Values());
            }
            
            // Utility method to create Case related data - Create Case related datat after event Published
            if(!idVerCaseIds.isEmpty()){
                CibisUtility.createCaseRelatedData(idVerCaseIds);
            }
            
            // Utility method to Upsert Error Log for the transaction - this will capture request and response events
            if(!npspErrorLogs.isEmpty()){
                GenericUtilities.createErrorLogs(npspErrorLogs);
            }
            
        }
    }
    
    //Process response event and split based on the response status
    public static void processPayload(String strPayload) {
        if(String.isNotBlank(strPayload)) {
            CibisDupCheckResponseEventWrap dupCheckResult = new CibisDupCheckResponseEventWrap();
            CibisDupCheckResponseEventWrap responseEvent = (CibisDupCheckResponseEventWrap) JSON.deserialize(strPayload, CibisDupCheckResponseEventWrap.class);
            System.debug('responseEvent '+responseEvent);
            Id csId=responseEvent.transactionId.split('-')[2]; 
            npspErrorLogs.add(new npsp__Error__c(Unique_Key__c=responseEvent.transactionId,Response__c=string.valueOf(strPayload),Case__c=csId));
            if(responseEvent != null && responseEvent.responseStatus == 'SUCCESS') {                            
                cibisDupCheckList.addAll(processCIBISDupCheckRecord(responseEvent));
            }
            else if(responseEvent != null && responseEvent.responseStatus == 'FAILED' && responseEvent.transactionId != null){          
                updateCaseMap.put(csId,new Case(Id=csId,Internal_Status__c=Constants.CASE_STATUS_ERROR_CIBIS,CIBIS_Integration__c=String.valueOf(responseEvent.ErrorDescription)));
                
            }
        }
    }
    
    // Method to construct CIBIS Duplicate Applican records and insert them into Salesforce
    public static List<CIBIS_Duplicate_Check__c> processCIBISDupCheckRecord(CibisDupCheckResponseEventWrap responseEvent) {
        List<CIBIS_Duplicate_Check__c> cibisList = new List<CIBIS_Duplicate_Check__c>();
        
        if(responseEvent.payload != null && !responseEvent.payload.isEmpty()) {
            List<CibisDupCheckResponseEventWrap.dupCheckPayload>  lstPayloadValues = responseEvent.payload; 
            if(lstPayloadValues != null && !lstPayloadValues.isEmpty()) {
                for(CibisDupCheckResponseEventWrap.dupCheckPayload  payLoadObj : lstPayloadValues){
                    CIBIS_Duplicate_Check__c objCIBISDup = new CIBIS_Duplicate_Check__c();
                    if((payLoadObj.birthYear != null && payLoadObj.birthYear != '' &&  payLoadObj.birthYear.containsNone('-'))  && (payLoadObj.birthMonth != null && payLoadObj.birthMonth != '' && payLoadObj.birthMonth.containsNone('-')) && (payLoadObj.birthDay != null &&payLoadObj.birthDay.containsNone('-'))){
                        String birthDate = payLoadObj.birthYear + '-' + payLoadObj.birthMonth + '-' + payLoadObj.birthDay;  
                        System.debug('birthDate'+birthDate);                 
                        objCIBISDup.CibisBirthDate__c = Date.valueOf(birthDate); 
                    }
                    
                    objCIBISDup.Contact__c = (responseEvent.transactionId != null) ? responseEvent.transactionId.split('-')[1] : '';
                    objCIBISDup.Case__c = (responseEvent.transactionId != null) ? responseEvent.transactionId.split('-')[2] : '';
                    objCIBISDup.CIBIS_USMLE_ID__c = payLoadObj.USMLEId;
                    objCIBISDup.Cibis_Generation_Suffix__c = payLoadObj.sourceGenerationSuffix;
                    objCIBISDup.CIBIS_GENDER_CODE__c = payLoadObj.gender;                        
                    objCIBISDup.Cibis_Last_Name__c = payLoadObj.lastName;
                    objCIBISDup.Cibis_Overall_Match__c = payLoadObj.overallMatch;
                    objCIBISDup.CIBIS_SSN__c = payLoadObj.SSN; 
                    objCIBISDup.CibisMedicalSchoolCode__c = payLoadObj.medicalSchoolCode;
                    objCIBISDup.Cibis_Request_Id__c = payLoadObj.requestId;   
                    objCIBISDup.Cibis_First_Name__c = payLoadObj.firstName;                 
                    if(!updateCaseMap.containsKey(objCIBISDup.Case__c)){
                        updateCaseMap.put(objCIBISDup.Case__c,new Case(Id=objCIBISDup.Case__c,Internal_Status__c=Constants.CASE_STATUS_CIBIS_SEARCH_RESULTS_RECEIVED,External_Status__c=Constants.CASE_EXTERNAL_STATUS_SUBMITTED_ID_REVIEW));
                    }
                    cibisList.add(objCIBISDup);
                }
            }            
        }
        else{
            if((responseEvent.transactionId != null)){
                // Capture the case Ids to create related records for the case
                idVerCaseIds.add(responseEvent.transactionId.split('-')[2]);
            }            
        }        
        return cibisList;
    }
}