// Created by Matthew on 2019-06-18.
global with sharing  class VerReqContactDupeCheckBatch implements Database.Batchable<sObject>{
	public static final Integer MAX_BATCH_SIZE = 1;
	public static final Integer DEFAULT_EXACT_SCORE = 0;
	public static final Integer DEFAULT_NON_EXACT_SCORE = 0;
	//Query the Contact records that have Name change Flag checked to true
	global Database.QueryLocator start(Database.BatchableContext bc){
        String status = Constants.VERIFICATION_REQUEST_STATUS_PENDING;
		String query = 'SELECT Id, Last_Name__c, Rest_of_Name__c, Birth_Date__c, Previous_Last_Name__c, Previous_Rest_of_Name__c, Birth_Country__c, Gender__c, Medschool_Code__c, Contact_Exact_Scenario_Score__c, Account_Exact_Scenario_Score__c from Verification_Request__c where Status__c = :status';
		return Database.getQueryLocator(query);
	}
	global void execute(Database.BatchableContext bc, List<Verification_Request__c> scope){
		// get the applicant non-exact match scenario id
		List<Duplicate_Check_Setting__mdt> settings = [select Applicant_Create_Bucket_End_Range__c,
															Applicant_Create_Bucket_Start_Range__c,
															Applicant_Exact_Match_Score__c,
															Applicant_Match_Bucket_End_Range__c,
															Applicant_Match_Bucket_Start_Range__c,
															DeveloperName,
															Entity_Exact_Match_Score__c,
															Exact_Match_Applicant_Scenario_ID__c,
															Exact_Match_Entity_Scenario_ID__c,
															Id,
															Label,
															Language,
															MasterLabel,
															NamespacePrefix,
															Non_Exact_Match_Applicant_Scenario_ID__c,
															Non_Exact_Match_Entity_Scenario_ID__c,
															QualifiedApiName
													from
															Duplicate_Check_Setting__mdt
													where
															DeveloperName = 'Default_Settings'];
		if(settings.size()==0){
			throw new ControllerException('Could not find Duplicate Check Settings (custom metadata).');
		}
		String exactMatchScenarioId = settings[0].Exact_Match_Applicant_Scenario_ID__c;
		String nonExactMatchScenarioId = settings[0].Non_Exact_Match_Applicant_Scenario_ID__c;
		if(exactMatchScenarioId==null||nonExactMatchScenarioId==null){
			throw new ServiceException('Could not load Duplicate Check Settings.');
		}
		for(Verification_Request__c req : scope){
			// by default, set score to 0 in-case the are no matches found
			req.Contact_Exact_Scenario_Score__c = DEFAULT_EXACT_SCORE;
			req.Contact_Non_Exact_Scenario_Score__c = DEFAULT_NON_EXACT_SCORE;
			Contact criteria = new Contact(
					DC_Last_Name_Exact__c = req.Last_Name__c,
					DC_Last_Name_Partial__c = req.Last_Name__c,
					DC_Rest_of_Name_Exact__c = req.Rest_of_Name__c,
					DC_Rest_of_Name_Partial__c = req.Rest_of_Name__c,
					DC_Last_Rest_of_Name_Switch_Partial__c = req.Rest_of_Name__c,
					DC_Last_Rest_of_Name_Switch_Exact__c = req.Rest_of_Name__c,
					DC_Prev_Rest_of_Name_Exact__c = req.Previous_Rest_of_Name__c,
					DC_Prev_Rest_of_Name_Partial__c = req.Previous_Rest_of_Name__c,
					DC_Prev_Last_Name_Exact__c = req.Previous_Last_Name__c,
					DC_Prev_Last_Name_Partial__c = req.Previous_Last_Name__c,
					DC_Prev_Last_Prev_Rest_Switch_Exact__c = req.Previous_Rest_of_Name__c,
					DC_Prev_Last_Prev_Rest_Switch_Partial__c = req.Previous_Rest_of_Name__c,
					DC_DOB_Day_Exact__c = req.Birth_Date__c == null ? null : String.valueOf(req.Birth_Date__c.day()),
					DC_DOB_Month_Exact__c = req.Birth_Date__c == null ? null : String.valueOf(req.Birth_Date__c.month()),
					DC_DOB_Month_Day_Switch_Exact__c = req.Birth_Date__c == null ? null : String.valueOf(req.Birth_Date__c.day()),
					DC_DOB_Year_Exact__c = req.Birth_Date__c == null ? null : String.valueOf(req.Birth_Date__c.year()),
					BirthDate = req.Birth_Date__c,
					Gender__c = req.Gender__c
			);
			//initialize the search api
			dupcheck.dc3Api dc = new dupcheck.dc3Api();
			// hold search result and build contact id score map
			Map<String, List<dupcheck.dc3SearchResult>> searchResult = dc.doSearch(criteria);
			// build up the contact id score map
			if(searchResult.containsKey(Constants.CONTACT_OBJECT_PREFIX)){
				if(searchResult.get(Constants.CONTACT_OBJECT_PREFIX).size()>0){
					// get the first highest match result
					dupcheck.dc3SearchResult result = searchResult.get(Constants.CONTACT_OBJECT_PREFIX)[0];
					// get the individual scenario scores
					for(dupcheck.dc3SearchResult.ScenarioScore ss : result.ScenarioScores){
						if(ss.scenarioId==exactMatchScenarioId){
							req.Contact_Exact_Scenario_Score__c = ss.scenarioScore;
							// link the current contact if there's a 100% exact match
							if(ss.scenarioScore==100){
								req.Exact_Match_Contact__c = result.objectData.Id;
							}
						}
						if(ss.scenarioId==nonExactMatchScenarioId){
							req.Contact_Non_Exact_Scenario_Score__c = ss.scenarioScore;
						}
					}
				}
			}
		}
		update scope;
		List<String> ids = new List<String>();
		for(Verification_Request__c req : scope){
						ids.add(req.Id);
		} 
		// get the latest scored verification requests from database
		List<Verification_Request__c> reqs = [select Id, Status__c from Verification_Request__c where Id in :ids and Contact_Exact_Scenario_Score__c >= 0 and Account_Exact_Scenario_Score__c >= 0];
		for(Verification_Request__c req : reqs){
			req.Status__c = Constants.VERIFICATION_REQUEST_STATUS_SCORED;
		}
		update reqs;
	}
	global void finish(Database.BatchableContext info){
	}
}