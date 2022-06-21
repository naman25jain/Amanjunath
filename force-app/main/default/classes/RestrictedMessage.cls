// Checks if record(Contact, Case, Account) has any restriction applied
public with sharing class RestrictedMessage{
    private static final string SEPARATOR = ';';
    // checks if the record is restricted.
    @AuraEnabled(cacheable = true)
    public static string getMessage(string jsonInput){
        try{
            string errorMsg = '';
            GetMessageWrapper getMessageWrap = (GetMessageWrapper)JSON.deserialize(jsonInput,GetMessageWrapper.class);
            if(string.isNotBlank(getMessageWrap.caseId) && checkCaseRestriction(getMessageWrap.caseId)){
                errorMsg = label.caseRestrictedMsg;
            }if(string.isBlank(errorMsg) && string.isNotBlank(getMessageWrap.accountId)){
                errorMsg = checkRestriction('Account',getMessageWrap.accountId,getMessageWrap.service);
            }if(string.isBlank(errorMsg) && string.isNotBlank(getMessageWrap.contactId)){
                errorMsg = checkRestriction('Contact',getMessageWrap.contactId,getMessageWrap.service);
            }if(string.isBlank(errorMsg) && string.isNotBlank(getMessageWrap.restrictionRequestId)){
                errorMsg = checkRestrictionRequestStatus('Restriction_Request__c', getMessageWrap.restrictionRequestId);
            }
            return errorMsg;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    // checks if Account/Contact has any restriction
    private static string checkRestriction(string sobjectType, Id recordId,string service){
        string restrictedMsg = label.restrictedMsg;
        string query = String.escapeSingleQuotes('SELECT Id,ServicesRestricted__c FROM '+sobjectType+ ' WHERE Id=:recordId WITH SECURITY_ENFORCED');
        sObject rec = database.query(query);
        string serviceRestricted = string.valueof(rec.get('ServicesRestricted__c'));
        if(string.isNotBlank(serviceRestricted) && checkRestriction(serviceRestricted.split(SEPARATOR),service)){
            return restrictedMsg;
        }
        return null;
    }
    // checks if Case has any restriction
    private static boolean checkCaseRestriction(Id caseId){
        try{
            boolean restricted = false;
            set<string> affirmRecType = new set<string>{Constants.AFFIRMATION_RECORD_TYPE_MED_EDU_FORM
                ,Constants.AFFIRMATION_RECORD_TYPE_CREDENTIAL_VERIFICATION};
                    Case caseRecord = [SELECT Id,Account.ServicesRestricted__c,Case_Service__c,Contact.ServicesRestricted__c
                                       ,recordtype.DeveloperName,Entity__r.ServicesRestricted__c,Alternate_Entity__r.ServicesRestricted__c
                                       ,(SELECT Id FROM Affirmations__r WHERE recordType.DeveloperName IN: affirmRecType AND Verify_with_Alternate_Entity__c = true)
                                       FROM Case WHERE Id =: caseId WITH SECURITY_ENFORCED];
            string caseServiceInt = caseRecord.Case_Service__c + ' - ' + label.Internal_Only;
            string caseServiceExt = caseRecord.Case_Service__c + ' - ' + label.Internal_External;
            List<string> restrictionServices = new List<string>();
            if(string.isNotBlank(caseRecord.Contact.ServicesRestricted__c) && (label.ContactCaseRestrictionRecordType.split(SEPARATOR)).contains(caseRecord.recordType.DeveloperName)){
                restrictionServices = caseRecord.Contact.ServicesRestricted__c.split(SEPARATOR);
                if(checkRestriction(restrictionServices,caseServiceInt) || checkRestriction(restrictionServices,caseServiceExt)){
                    restricted = true;
                }
            }
            else if((label.AccountCaseRestrictionRecordType.split(SEPARATOR)).contains(caseRecord.recordType.DeveloperName) || (label.EntityCaseRestrictionRecordType.split(SEPARATOR)).contains(caseRecord.recordType.DeveloperName)){
                restricted = checkCaseAccRestriction(caseRecord,caseServiceInt,caseServiceExt);
            }
            return restricted;
        }
        catch(Exception ex){
            throw ex;
        }
    }
    //checks if case's account has restriction
    private static boolean checkCaseAccRestriction(Case caseRecord,string caseServiceInt,string caseServiceExt){
        try{
            List<string> restrictionServices = new List<string>();
            if(label.EntityCaseRestrictionRecordType.split(SEPARATOR).contains(caseRecord.recordType.DeveloperName)){
                restrictionServices = checkCaseEntityRestriction(caseRecord);
            }else if(label.AccountCaseRestrictionRecordType.split(SEPARATOR).contains(caseRecord.recordType.DeveloperName)){
                restrictionServices = splitRestriction(caseRecord.Account.ServicesRestricted__c);
            }
            if(checkRestriction(restrictionServices,caseServiceInt) || checkRestriction(restrictionServices,caseServiceExt)){
                return true;
            }
            return false;
        }catch(Exception ex){
            throw ex;
        }
    }
    //fetches entity/alternate entity services
    private static List<string> checkCaseEntityRestriction(Case caseRecord){
        if((caseRecord.recordType.DeveloperName == Constants.CASE_RECORD_TYPE_MED_EDU_FORM 
            || caseRecord.recordType.DeveloperName == Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION)
           && (!(caseRecord.Affirmations__r).isEmpty())){
               return splitRestriction(caseRecord.Alternate_Entity__r.ServicesRestricted__c);
           }else{
               return splitRestriction(caseRecord.Entity__r.ServicesRestricted__c);
           }
    }
    // checks if service restricted field is not blank and splits the picklist value into a list
    private static List<string> splitRestriction(string servicesRestricted){
        List<string> restrictionServices = new List<string>();
        if(string.isNotBlank(servicesRestricted)){
            restrictionServices = servicesRestricted.split(SEPARATOR);
        }
        return restrictionServices;
    }
    // checks if service is present in the list of restrictions
    private static boolean checkRestriction(List<string> serviceRestricted,string service){
        if((string.isBlank(service) && !serviceRestricted.isEmpty()) || serviceRestricted.contains(service)){
            return true;
        }
        return false;
    }
    //check restricted message for list of Contacts
    public static Map<String,Boolean> checkRestrictionForCons(Map<String,String> recordIds){       
		Map<String,Boolean> retMap = new Map<String,Boolean>();
		for(Case con : [SELECT Id,Contact.ServicesRestricted__c,ContactId FROM Case WHERE Id IN: recordIds.keySet() WITH SECURITY_ENFORCED]){
			Boolean resApplied = false;            
			if(string.isNotBlank(con.Contact.ServicesRestricted__c) && checkRestriction(con.Contact.ServicesRestricted__c.split(SEPARATOR),recordIds.get(con.Id))){
				resApplied = true;
			}
			retMap.put(con.Id,resApplied);
		}
        return retMap;
    }

    public static string checkRestrictionRequestStatus(string SObjectType, string recordId){
        string restrictedRequestMsg = label.restrictedRequestMsg;
        string query = String.escapeSingleQuotes('SELECT Id,RestrictionStatus__c FROM '+sobjectType+ ' WHERE Id=:recordId WITH SECURITY_ENFORCED');
        sObject rec = database.query(query);
        string rrStatus = string.valueof(rec.get('RestrictionStatus__c'));
        if(string.isNotBlank(rrStatus) && rrStatus == 'Processing Error'){
            return restrictedRequestMsg;
        }
        return null; 
    }

    // wrapper for input
    private class GetMessageWrapper{
        string caseId;
        string accountId;
        string contactId;
        string service;
        string restrictionRequestId;
    }
}