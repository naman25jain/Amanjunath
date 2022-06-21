public with sharing class ApplicantCaseRecord{
    @AuraEnabled
    public static Map<String, Map<String, String>> getApplicantRequestData(){
        try{
            Set<String> setStatus = new Set<String>();
            setStatus.add(Constants.CASE_STATUS_EXPIRED);
            setStatus.add(Constants.CASE_STATUS_PENDING_SUBMISSION);
            setStatus.add(Constants.CASE_STATUS_MARKED_FOR_DELETION);
            Set<String> setRecType = new Set<String>();
            setRecType.add(Constants.CASE_RECORD_TYPE_IDENTITY_VERIFICATION);
            setRecType.add(Constants.CASE_RECORD_TYPE_APP_FOR_CERT);
            setRecType.add(Constants.CASE_RECORD_TYPE_ERAS);
            setRecType.add(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION);
            setRecType.add(Constants.CASE_RECORD_TYPE_REGION_CHANGE);
            setRecType.add(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION);
            setRecType.add(Constants.CASE_RECORD_TYPE_EPIC_EXTRACTION);
            setRecType.add(Constants.CASE_RECORD_TYPE_EPIC_VER_REPORT_REQUEST);
            String scrRecheck = Constants.CASE_RECORD_TYPE_SCORE_RECHECK;
            Set<String> setRecTypeList = new Set<String>();
            setRecTypeList.add(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION);
            setRecTypeList.add(Constants.CASE_RECORD_TYPE_ECFMG_CERTIFICATION);
            setRecTypeList.add(Constants.CASE_RECORD_TYPE_EPIC_EXTRACTION);
            setRecTypeList.add(Constants.CASE_RECORD_TYPE_ATTESTATION);
            setRecTypeList.add(Constants.CASE_RECORD_TYPE_EPIC_VER_REPORT_REQUEST);
            Map<String, Map<String, String>> returnValuesMap = new Map<String, Map<String, String>> ();
            List<Case> valuesToReturn = new List<Case>([SELECT Id,CaseNumber,Case_Service__c,ContactId,
                External_Status__c, CreatedDate, LastModifiedDate, Action_Required_Icon__c, RecordType.Name, RecordType.DeveloperName 
                FROM Case WHERE (My_Community_Case__c = TRUE AND RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_APP_BIO_CHANGE AND Internal_Status__c !=: Constants.CASE_STATUS_PENDING_SUBMISSION) OR (RecordType.DeveloperName in:setRecType AND Internal_Status__c Not in: setStatus) 
                          OR (RecordType.DeveloperName in: setRecTypeList AND Case_Type__c != :Constants.CASE_TYPE_ATTESTATION_SUB_CASE AND Internal_Status__c Not in: setStatus) OR (RecordType.DeveloperName =: scrRecheck AND Internal_Status__c !=: Constants.CASE_STATUS_PENDING_SUBMISSION AND Internal_Status__c !=: Constants.CASE_STATUS_MARKED_FOR_DELETION) 
                          OR (RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_DUPLICATE_CERTIFICATE AND Internal_Status__c !=: Constants.CASE_STATUS_PENDING_SUBMISSION AND Internal_Status__c !=: Constants.CASE_STATUS_MARKED_FOR_DELETION)
                          OR (RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD AND Internal_Status__c !=: Constants.CASE_STATUS_PENDING_SUBMISSION AND Internal_Status__c !=: Constants.CASE_STATUS_MARKED_FOR_DELETION)
                          OR ((RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_USMLE_TRANSCRIPT OR RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_NON_USMLE_TRANSCRIPT) AND Internal_Status__c Not in: setStatus AND ParentId != NULL)                          
                          WITH SECURITY_ENFORCED ORDER BY Action_Required_Icon__c Desc NULLS LAST, CreatedDate Asc NULLS LAST]);           
                Map<String,String> conIds = new Map<String,String>();
                Map<String,Boolean> retMsgMap = new Map<String,Boolean>();            
                for(Case restCheck : valuesToReturn){                
                    conIds.put(restCheck.Id,restCheck.Case_Service__c+ ' - Internal and External');                                              
                }            
                retMsgMap = RestrictedMessage.checkRestrictionForCons(conIds); 
                for(Case cs : valuesToReturn){
                    String urlVal;
                    Map<String, String> tempMap = new Map<String, String> ();
                    tempMap.put('Id', cs.Id);
                    tempMap.put('caseId', cs.Id);
                    tempMap.put('nameUrl', '/s/case/'+cs.Id+'/detail');
                    tempMap.put('caseNumber', cs.CaseNumber);
                    tempMap.put('recType', cs.RecordType.Name);
                    tempMap.put('caseStatus', cs.External_Status__c);
                    tempMap.put('modifiedDate',  String.valueOf(date.newInstance(cs.LastModifiedDate.year(),cs.LastModifiedDate.month(), cs.LastModifiedDate.day())));
                    tempMap.put('createdDate',  String.valueOf(date.newInstance(cs.CreatedDate.year(),cs.CreatedDate.month(), cs.CreatedDate.day())));                
                    if(retMsgMap.containsKey(cs.Id) && retMsgMap.get(cs.Id)){
                        tempMap.put('restricted','Yes');
                    }else{
                        tempMap.put('restricted','No');
                    }
                    String actionReqdVal;
                    if(cs.Action_Required_Icon__c != NULL){
                        actionReqdVal = getActionReqd(cs.Action_Required_Icon__c);
                    }
                    tempMap.put('actionReqd', actionReqdVal);
                    String resubmitId = 'Resubmit ID Documents';
                    String onlineNotary = 'Online Notary Confirmation';
                    String notarizeId = 'Notarize ID Form';
                    String resubmitNotarize = 'Resubmit Notarized ID Form';
                    String onlineNotarySession = 'Online Notary Session Links';
                    if(cs.Action_Required_Icon__c == 'No'){
                        tempMap.put('iconUrl', 'javascript: void(0)');
                    }
                    else if(cs.Action_Required_Icon__c != NULL){
                        if(cs.Action_Required_Icon__c.contains('Yes') || cs.Action_Required_Icon__c.contains(resubmitId) || cs.Action_Required_Icon__c.contains(onlineNotary) || cs.Action_Required_Icon__c.contains(notarizeId) || cs.Action_Required_Icon__c.contains(resubmitNotarize) || cs.Action_Required_Icon__c.contains(onlineNotarySession)){
                            urlVal = cs.Action_Required_Icon__c.subStringAfter('\"').subStringBefore('\"');
                            tempMap.put('iconUrl', urlVal);
                        }
                    }
                    else{
                        tempMap.put('iconUrl', 'javascript: void(0)');
                    }
                    returnValuesMap.put(cs.Id, tempMap);
                }            
            return returnValuesMap;
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }   
    public static String getActionReqd(String actionVal){
        String resubmitId = 'Resubmit ID Documents';
        String onlineNotary = 'Online Notary Confirmation';
        String notarizeId = 'Notarize ID Form';
        String resubmitNotarize = 'Resubmit Notarized ID Form';
        String onlineNotarySession = 'Online Notary Session Links';
        String returnVal = '';
        if(actionVal.contains('Yes') || actionVal.contains(resubmitId) || actionVal.contains(onlineNotary) || actionVal.contains(notarizeId) || actionVal.contains(resubmitNotarize) || actionVal.contains(onlineNotarySession)){
            returnVal = 'Yes';
        }
        else{
            returnVal = actionVal;
        }
        return returnVal;
    }
    public class GetMessageWrapper{
        public string caseId;
        public string accountId;
        public string contactId;
        public string service;
    }
}