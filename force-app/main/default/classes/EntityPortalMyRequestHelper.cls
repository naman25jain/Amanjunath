/**
 * Helper class for EntityPortalMyRequestsController
 *
 * @author        Enable Consulting : Chinmay Menon
 * @version       1.0
 * @createdDate   21-JUL-2020
 */
public with sharing class EntityPortalMyRequestHelper {
	public EntityPortalMyRequestHelper() {

	}

	/**
	 * @author: Chinmay Menon
	 * @description: Wrapper class to pass list of active request cases and corrsponding services
	 */
	public class MyRequestCaseWrapper {

        @auraenabled public string caseId {get; set;}
        @auraenabled public string contactId {get; set;}
		@auraenabled public string caseNumber {get; set;}
		@auraenabled public string caseType {get; set;}
		@auraenabled public string restOfName {get; set;}
		@auraenabled public string lastName {get; set;}
		@auraenabled public string externalStatus {get; set;}
		@auraenabled public Boolean actionRequired {get; set;}
		@auraenabled public string createdDate {get; set;}
		@auraenabled public string lastModifiedDate {get; set;}
		@auraenabled public list<string> serviceNamesList {get; set;}

		public MyRequestCaseWrapper(String caseIdVal,String contactIdVal, String caseNumberVal, String caseTypeVal, String restOfNameVal, String lastNameVal, String externalStatusVal, Boolean actionRequiredVal, String createdDateVal, String lastModifiedDateVal, list<String> serviceNamesListVal) {

            caseId = caseIdVal;
            contactId = contactIdVal;
			caseNumber = caseNumberVal;
			caseType = caseTypeVal;
			restOfName = restOfNameVal;
			lastName = lastNameVal;
			externalStatus = externalStatusVal;
			actionRequired = actionRequiredVal;
			createdDate = createdDateVal;
			lastModifiedDate = lastModifiedDateVal;

			if (serviceNamesListVal != null && !serviceNamesListVal.isEmpty()) {
				serviceNamesList = new list<string> ();
				serviceNamesList.addAll(serviceNamesListVal);
			} else {
				serviceNamesList = null;
			}
		}

	}
}