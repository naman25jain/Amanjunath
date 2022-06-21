/**
 * Class for Entity Performance Data screen
 *
 * @author        Enable Consulting
 * @version       1.0
 * @createdDate   28-APRIL-2020
 */
public with sharing class EntityScoreReport {
	// Purpose : Method will get the Current User's Contact Id
	@AuraEnabled(Cacheable = false)
	public static Id getContact(String userId){
		User uId = [select id, contactId from User where id = : userId WITH SECURITY_ENFORCED];
		id getContactId = uId.contactId;
		return getContactId;
	}
	// Purpose : Method to check if the Entity has enrolled for Performance Data	
	@AuraEnabled(Cacheable = false)
	public static Boolean checkPerformanceDataEnrolled(String currentEntityId) {
		Boolean enrolledForPerformanceData = false;
		Id contactId = AppForCertHelper.retrieveCurrentContactId();
		List<Account2Service__c > activePerformanceDataServiceList = new List<Account2Service__c > ([SELECT Id
			FROM Account2Service__c
			WHERE Account__c =: currentEntityId AND
			Service__r.Name =: Constants.SERVICE_NAME_PERFORMANCE_DATA AND
			Active__c = true
		]);

		if (activePerformanceDataServiceList.size() > 0) {
			List<CONTACT2ACCTSERVICE__c > activeEntityContactEnrolledInPerformanceDataList = new List<CONTACT2ACCTSERVICE__c > ([SELECT Id,Service__c,Role__c
				FROM CONTACT2ACCTSERVICE__c
				WHERE Account_Service__c =: activePerformanceDataServiceList[0].Id AND
				Service_Contact__c =: contactId AND
				Service__c =: Constants.SERVICE_NAME_PERFORMANCE_DATA AND
				Active__c = true
			]);
			if (activeEntityContactEnrolledInPerformanceDataList.size() > 0) {
				enrolledForPerformanceData = true;
			}
		}

		return enrolledForPerformanceData;
	}

	// Purpose : Method to get the Performance Data of the contacts related to that Entity	 
	@AuraEnabled(Cacheable = false)
	public static Map<String, Map<String, String>> getPerformanceData(String currentEntityId) {
		Map<String, Map<String, String>> returnValuesMap = new Map<String, Map<String, String>> ();
		Map<String, Map<String, String>> returnValuesMapEmpty = new Map<String, Map<String, String>> ();
		List<Account2Service__c > activePerformanceDataServiceList = new List<Account2Service__c > ([SELECT Id, Start_Date__c
			FROM Account2Service__c
			WHERE Account__c =: currentEntityId AND
			Service__r.Name =: Constants.SERVICE_NAME_PERFORMANCE_DATA AND
			Active__c = true
		]);
		List<Exam_Registration__c > valuesToReturn = new List<Exam_Registration__c > ([SELECT Applicant__c, Applicant__r.FirstName, Applicant__r.LastName,
			Applicant__r.School_Enrollment_Status__c, Id, USMLE_ID_CIBIS__c,
			Exam_Types__c, Exam_taken_date__c, Pass_fail__c,
			Three_Digit_Score__c, Score_Available_Date__c,
			Remarks__c, Posted_Date__c, Unique_Medical_School_ID__c, Exam_Status__c, Pd_Optout_flag__c
			FROM Exam_Registration__c
			WHERE Degree_Medical_School__c =: currentEntityId AND (Exam_status__c =:Constants.EXAM_REGISTRATION_EXAM_STATUS_FAILED OR Exam_status__c =:Constants.EXAM_REGISTRATION_EXAM_STATUS_PASSED)
			ORDER BY Posted_Date__c asc
		]);
		for (Exam_Registration__c er: valuesToReturn) {
			if (er.Posted_Date__c != null && er.Posted_Date__c >= activePerformanceDataServiceList[0].Start_Date__c) {
				Date dateToCompare = er.Posted_Date__c;
				dateToCompare = dateToCompare.addYears(5); // the score should be shown till 5 years from score available until value and no more
				Integer daysBetween = date.today().daysBetween(dateToCompare);
				Boolean examOutcomeIndeterminate = er.Exam_Status__c == Constants.EXAM_REGISTRATION_EXAM_STATUS_INDETERMINATE;
				Boolean pdOptedOut = er.Pd_Optout_flag__c;
				if (daysBetween >= 0) {
					Map<String, String> tempMap = new Map<String, String> ();
					tempMap.put('Applicant__r.FirstName', er.Applicant__r.FirstName);
					tempMap.put('Applicant__r.LastName', er.Applicant__r.LastName);
					tempMap.put('USMLE_ID_CIBIS__c', er.USMLE_ID_CIBIS__c);
					tempMap.put('Remarks__c', er.Remarks__c);
					tempMap = setValuesAsPerConditions(er, tempMap, examOutcomeIndeterminate, pdOptedOut);
					String checkVarVal = tempMap.get('Posted_Date__c');
					Object returnMapVal;
					returnMapVal = (checkVarVal != '' && checkVarVal != null) ? returnValuesMap.put(er.id, tempMap) : returnValuesMapEmpty.put(er.id, tempMap);
				}
			}
		}
		if(returnValuesMapEmpty.size() > 0){
			returnValuesMap.putAll(returnValuesMapEmpty);
		}
		return returnValuesMap;
	}

	// Purpose : Method to set map values as per values of Exam outcome and PD opted out flag; created to reduce cognitive complexity
	public static Map<String, String> setValuesAsPerConditions(Exam_Registration__c er, Map<String, String> tempMap, Boolean examOutcomeIndeterminate, Boolean pdOptedOut){
		if(!pdOptedOut){
			tempMap.put('Applicant__r.School_Enrollment_Status__c', er.Applicant__r.School_Enrollment_Status__c);
			tempMap.put('id', er.Id);
			tempMap.put('Unique_Student_Id', er.Unique_Medical_School_ID__c);
			tempMap.put('Exam_Types__c', er.Exam_Types__c);
			tempMap.put('Exam_taken_date__c', String.valueOf(er.Exam_taken_date__c));
			tempMap.put('Posted_Date__c', String.valueOf(er.Posted_Date__c));
			if(!examOutcomeIndeterminate) {
				tempMap.put('Pass_fail__c', er.Pass_fail__c);
				tempMap.put('Three_Digit_Score__c', String.valueOf(er.Three_Digit_Score__c));
			} else {
				tempMap.put('Pass_fail__c', '');
				tempMap.put('Three_Digit_Score__c', '');
			}
		} else {
			tempMap.put('Applicant__r.School_Enrollment_Status__c', '');
			tempMap.put('id', '');
			tempMap.put('Unique_Student_Id', '');
			tempMap.put('Exam_Types__c', '');
			tempMap.put('Exam_taken_date__c', '');
			tempMap.put('Posted_Date__c', '');
			tempMap.put('Pass_fail__c', '');
			tempMap.put('Three_Digit_Score__c', '');
		}
		return tempMap;
	}
}