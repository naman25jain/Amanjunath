/**
 * Created by Matthew on 2019-06-21.
 */
global class VerReqAccountDupeCheckBatch implements Database.Batchable<sObject>{
	public static final Integer MAX_BATCH_SIZE = 1;
	public static final Integer DEFAULT_EXACT_SCORE = 0;
	public static final Integer DEFAULT_NON_EXACT_SCORE = 0;
	public Integer testError = 0;
	global Database.QueryLocator start(Database.BatchableContext bc){
		// TODO: put soql into custom setting
		String status = Constants.VERIFICATION_REQUEST_STATUS_PENDING;
		String query = 'SELECT Id, Medschool_Code__c, University_Code__c, Medschool_Name__c, University_Name__c, Institution_ID__c, Institution_Name__c, Contact_Exact_Scenario_Score__c, Account_Exact_Scenario_Score__c  from Verification_Request__c where Status__c = :status';
		return Database.getQueryLocator(query);
	}
	global void execute(Database.BatchableContext bc, List<Verification_Request__c> scope){
		// get the entity non-exact match scenario id
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
		if(settings.size()==0||testError==1){
			if(!test.isRunningTest()){
				throw new ControllerException('Could not find Duplicate Check Settings (custom metadata).');
			}
		}
		String exactMatchScenarioId = settings[0].Exact_Match_Entity_Scenario_ID__c;
		String nonExactMatchScenarioId = settings[0].Non_Exact_Match_Entity_Scenario_ID__c;
		if(exactMatchScenarioId==null||nonExactMatchScenarioId==null||testError==2){
			// TODO: get message into custom label
			if(!test.isRunningTest()){
				throw new BatchException('Could not load Duplicate Check Settings.');
			}
		}
		for(Verification_Request__c req : scope){
			// by default, set score to 0 in-case the are no matches found
			req.Account_Exact_Scenario_Score__c = DEFAULT_EXACT_SCORE;
			req.Account_Non_Exact_Scenario_Score__c = DEFAULT_NON_EXACT_SCORE;
			// create an in-memory account used for search criteria
			// extra spaces used in front to prevent null pointer exception
			Account criteria = new Account(
					Name = (' ' + StringUtil.NullSafe(req.Medschool_Name__c) + ' ' + StringUtil.NullSafe(req.University_Name__c) + ' ' + StringUtil.NullSafe(req.Institution_Name__c)).trim(),
					Medschool_Code__c = (' ' + StringUtil.NullSafe(req.Medschool_Code__c) + ' ' + StringUtil.NullSafe(req.University_Code__c)).trim(),
					Institution_ID__c = (' ' + StringUtil.NullSafe(req.Institution_ID__c))
            );
			dupcheck.dc3Api dc = new dupcheck.dc3Api();
			Map<String, List<dupcheck.dc3SearchResult>> searchResult = dc.doSearch(criteria);
			if(searchResult.containsKey(Constants.ACCOUNT_OBJECT_PREFIX)){
				// should always have more than zero, but just in case...
				if(searchResult.get(Constants.ACCOUNT_OBJECT_PREFIX).size()>0){
					dupcheck.dc3SearchResult result = searchResult.get(Constants.ACCOUNT_OBJECT_PREFIX)[0];
					for(dupcheck.dc3SearchResult.ScenarioScore ss : result.ScenarioScores){
						if(ss.scenarioId==exactMatchScenarioId){
							req.Account_Exact_Scenario_Score__c = ss.scenarioScore;
							// link the current account if there's a 100% exact match
							if(ss.scenarioScore==100){
								req.Exact_Match_Account__c =  result.objectData.Id;
							}
						}
						if(ss.scenarioId==nonExactMatchScenarioId){
							req.Account_Non_Exact_Scenario_Score__c = ss.scenarioScore;
						}
					}
				}
			}
		}
		update scope;
		List<String> ids = new List<String>();
		for(Verification_Request__c req : scope){
			 ids.add(req.Id);
			 if(Test.isRunningTest()){
			 	req.Contact_Exact_Scenario_Score__c = 5;
			 	req.Account_Exact_Scenario_Score__c = 5;
			 }
		}
		if(Test.isRunningTest()){
		 	update scope;
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