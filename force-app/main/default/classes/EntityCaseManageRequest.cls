/**
 * Helper class for EntityCaseManageRequest 
 *
 * @author        Enable Consulting
 * @version       1.0
 * @createdDate   08-AUG-2020
 */
public with sharing class EntityCaseManageRequest {
    /**
	 * Created by Balashankar
	 * Method Name: getEntityRequestData
	 * Purpose : Method to get the Case Data(Active) related to that Entity
	 * Return Type : Map<String, Map<String,String>>
	 */
	@AuraEnabled(Cacheable = false)
	public static Map<String, Map<String, String>> getEntityRequestData(String currentEntityId) {
        
        Id entityUserRecordTypeId     =   Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENTITY_USER_REQUEST).getRecordTypeId();
            
		Map<String, Map<String, String>> returnValuesMap = new Map<String, Map<String, String>> ();
        Set<String> caseStatus = new Set<String>{Constants.CASE_STATUS_PENDING_COORDINATOR_APPROVAL,Constants.CASE_STATUS_INCOMPLETE};
        List<Case> valuesToReturn = new List<Case>([Select Id,CaseNumber,ContactId,
            Contact.Name,Subject,Internal_Status__c,Priority,CreatedDate,OwnerId,Owner.Name 
            From Case where Entity__c = : currentEntityId And RecordTypeId =: entityUserRecordTypeId And Internal_Status__c IN:caseStatus ]);
            for(Case cs : valuesToReturn){
                Map<String, String> tempMap = new Map<String, String> ();
                
                    tempMap.put('Id', cs.Id);
                    tempMap.put('nameUrl', '/entity360/s/case/'+cs.Id+'/');
                    tempMap.put('name', cs.CaseNumber);
                    tempMap.put('caseId', cs.Id);
                    tempMap.put('conId', cs.ContactId);
                    tempMap.put('CaseNumber', cs.CaseNumber);
                    tempMap.put('Contact.Name', cs.Contact.Name);
                    tempMap.put('Subject', cs.Subject);
                    tempMap.put('Status', cs.Internal_Status__c);
                    tempMap.put('Priority', cs.Priority);
                    tempMap.put('CreatedDate',  String.valueOf(cs.CreatedDate));
                    tempMap.put('Owner.Name', cs.Owner.Name);
                    returnValuesMap.put(cs.Id, tempMap);
            }

		return returnValuesMap;
    }
    
        	/**
	 * Created by Balashankar
	 * Method Name: getEntityCompletedRequestData
	 * Purpose : Method to get the Case Data(Completed) related to that Entity
	 * Return Type : Map<String, Map<String,String>>
	 */
	@AuraEnabled(Cacheable = false)
	public static Map<String, Map<String, String>> getEntityCompletedRequestData(String currentEntityId) {
        
        Id entityUserRecordTypeId     =   Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENTITY_USER_REQUEST).getRecordTypeId();
            
		Map<String, Map<String, String>> returnValuesMap = new Map<String, Map<String, String>> ();
        Set<String> caseStatus = new Set<String>{Constants.CASE_STATUS_PENDING_COORDINATOR_APPROVAL,Constants.CASE_STATUS_INCOMPLETE};
        List<Case> valuesToReturn = new List<Case>([Select Id,CaseNumber,ContactId,
            Contact.Name,Subject,Internal_Status__c,Priority,CreatedDate,OwnerId,Owner.Name 
            From Case where Entity__c = : currentEntityId And RecordTypeId =: entityUserRecordTypeId And Internal_Status__c Not IN:caseStatus ]);
            for(Case cs : valuesToReturn){
                Map<String, String> tempMap = new Map<String, String> ();
                    tempMap.put('caseId', cs.Id);
                    tempMap.put('conId', cs.ContactId);
                    tempMap.put('CaseNumber', cs.CaseNumber);
                    tempMap.put('Contact.Name', cs.Contact.Name);
                    tempMap.put('Subject', cs.Subject);
                    tempMap.put('Status', cs.Internal_Status__c);
                    tempMap.put('Priority', cs.Priority);
                    tempMap.put('CreatedDate',  String.valueOf(cs.CreatedDate));
                    tempMap.put('Owner.Name', cs.Owner.Name);
                    returnValuesMap.put(cs.Id, tempMap);
            }

		return returnValuesMap;
	}
}