public with sharing class ERASController{
    static final String STATUS_PENDING_SUBMISSION = Constant_Case__mdt.getInstance('STATUS_PENDING_SUBMISSION').Value__c;
    static final String STATUS_PENDING_TOKEN_CALL = Constant_Case__mdt.getInstance('STATUS_PENDING_TOKEN_CALL').Value__c;
    static final String STATUS_PENDING_RESTRICTION_REVIEW = Constant_Case__mdt.getInstance('STATUS_PENDING_RESTRICTION_REVIEW').Value__c;
    static final String STATUS_TOKEN_GENERATED = Constant_Case__mdt.getInstance('STATUS_TOKEN_GENERATED').Value__c;
    static final String STATUS_TOKEN_REQUEST_SUBMITTED = Constant_Case__mdt.getInstance('STATUS_TOKEN_REQUEST_SUBMITTED').Value__c;
    static final String REC_TYPE_ECFMG = Constant_Case__mdt.getInstance('REC_TYPE_ECFMG_CERTIFICATION').Value__c;
    @AuraEnabled
    public static String checkApplicantDocUploadDisabled(){
        Id contactId = AppForCertHelper.retrieveCurrentContactId();
        return checkDocUploadDisabled(contactId);
    }
    @AuraEnabled
    public static String checkDocUploadDisabled(Id contactId){
        Id erasRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ERAS).getRecordTypeId();
        Set<String> deniedStatus = new Set<String> {STATUS_PENDING_SUBMISSION,STATUS_PENDING_TOKEN_CALL,STATUS_PENDING_RESTRICTION_REVIEW,STATUS_TOKEN_GENERATED,STATUS_TOKEN_REQUEST_SUBMITTED};
        //Change the soql query to use new formula field -ERAS_Active__c - #US22257
        //List<Case> erasCase = [SELECT Id,Internal_status__c FROM Case where ContactId=:contactId AND Eligibility_Period__r.Active__c = 'Y' and Internal_Status__c not in :deniedStatus AND RecordTypeId =: erasRecordTypeId WITH SECURITY_ENFORCED];
        List<Case> erasCase = [SELECT Id,Internal_status__c FROM Case where ContactId=:contactId AND Eligibility_Period__r.ERAS_Active__c = true AND Internal_Status__c not in :deniedStatus AND RecordTypeId =: erasRecordTypeId WITH SECURITY_ENFORCED];
        if(erasCase.isEmpty()){
            return null;
        }else{
            return erasCase[0].Id;
        }
    }
	@AuraEnabled(Cacheable = true)
	public static List<Account> getSchoolRecords() {
		return [SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry
			FROM Account
			WHERE recordType.DeveloperName =: Constants.ACCOUNT_RECORD_TYPE_DEV_ENTITY
			AND School__c = true WITH SECURITY_ENFORCED
		];
	}
    // Method to fetch Degree Medical School for Step 2 - Degree Medical School confirmation
	@AuraEnabled(Cacheable = true)
	public static Map<string, string> getSelectedValues(){
		Id contactId = AppforCertHelper.retrieveCurrentContactId();
		String contactStatus = [SELECT School_Enrollment_Status__c FROM Contact WHERE id =: contactId WITH SECURITY_ENFORCED].School_Enrollment_Status__c;
		Map<String, String> degreeMedicalSchool = new Map<String, String>();
		List<case> newCases = [SELECT Id FROM Case WHERE recordType.DeveloperName =: Constants.CASE_RECORD_TYPE_APP_FOR_CERT
				AND ContactId =: contactId
				AND Case_Status__c !=: Constants.CASE_STATUS_REJECTED
				AND Case_Status__c !=: Constants.CASE_STATUS_EXPIRED WITH SECURITY_ENFORCED];
		if(!newCases.isEmpty()){
			List<Contact_Association_Type_Staging__c> existingConAssoStagingObjList = [SELECT Id, Case__r.Internal_Status__c, Status__c, Number_of_Years_Attended__c, Account__c, Degree_Title__c, Account_Name__c,
				Start_Date__c, End_Date__c, Graduation_Year__c, Graduation_Month__c, Degree_Issue_Date__c, School_Program__c, Student_ID__c, Specialty__c,
				Start_Month__c, Start_Year__c, End_Year__c, End_Month__c, Degree_Issue_Month__c, Degree_Issue_Year__c
				FROM Contact_Association_Type_Staging__c
				WHERE recordType.DeveloperName =: Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL
				AND Parent_Case__c =: newCases[0].id 
				WITH SECURITY_ENFORCED];			
			degreeMedicalSchool.put('Account__c', String.valueOf(existingConAssoStagingObjList[0].Account__c));
			
			degreeMedicalSchool.put('Account_Name__c', String.valueOf(existingConAssoStagingObjList[0].Account_Name__c));			
		}
		return degreeMedicalSchool;
	} 
    //Method to display the current season month name and year dynamically in the ERAS Summary Screen
    @AuraEnabled
    public static string getActiveErasSeason(){
        string activeSeason;
        List<Eligibility_Period__c> activeEligibilityPeriod = new List<Eligibility_Period__c>();
        //Change the soql query to use new formula field - ERAS_Active__c - #US22257
        activeEligibilityPeriod = [SELECT Id, EP_Start_Date__c, EP_End_Date__c FROM Eligibility_Period__c 
                                                        WHERE RecordType.DeveloperName = :Constants.ELIGIBILITY_PERIOD_RECORD_TYPE_ERAS 
                                                        AND ERAS_Active__c = true 
                                                        WITH SECURITY_ENFORCED LIMIT 1];
        if(activeEligibilityPeriod.size()>0){
            if(activeEligibilityPeriod[0].EP_Start_Date__c <= date.today() && activeEligibilityPeriod[0].EP_End_Date__c >= date.today()){                
				activeSeason = String.valueOf(activeEligibilityPeriod[0].EP_Start_Date__c.year() + 1);
				//converting Date to dateTime to get the month name from Start Date
				Date startDate = activeEligibilityPeriod[0].EP_Start_Date__c;
				Integer y = startDate.year();
				Integer m = startDate.month();
				Integer d = startDate.day();
				DateTime seasonStartDateTime = DateTime.newInstance(y,m,d);
				activeSeason += '-' + String.valueOf( seasonStartDateTime.format('MMMM')) +' '+String.valueOf(activeEligibilityPeriod[0].EP_Start_Date__c.year()) ;				
            }
        }
        return activeSeason;        
    }
    @AuraEnabled
	public static String getContactAssociationOrStaging(){
		String valuesToReturn = '';
		Id contactId = AppForCertHelper.retrieveCurrentContactId();
		if (contactId != null) {
			List<case >newCases = [SELECT id, Internal_Status__c FROM Case
					WHERE recordType.DeveloperName =: Constants.CASE_RECORD_TYPE_APP_FOR_CERT
					AND ContactId =: contactId
					AND Case_Status__c !=: Constants.CASE_STATUS_REJECTED WITH SECURITY_ENFORCED
				];
			String caseStatus = '';
			if (!newCases.isEmpty()) {
				caseStatus = newCases[0].Internal_Status__c;
			}

			if (!newCases.isEmpty() && caseStatus != Constants.CASE_STATUS_ACCEPTED) {
				List<Contact_Association_Type_Staging__c > existingConAssoStagingObjList = [SELECT id FROM Contact_Association_Type_Staging__c 
																							WHERE recordType.DeveloperName =: Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL
																							AND Parent_Case__c =: newCases[0].id WITH SECURITY_ENFORCED
																							];
				if (!existingConAssoStagingObjList.isEmpty()){
					valuesToReturn = String.valueOf(existingConAssoStagingObjList[0].id) + ',Contact_Association_Type_Staging__c,' + caseStatus;
				}
			} else {
				List<Contact_Association_Type__c > existingConAssoObjList = [SELECT ID FROM Contact_Association_Type__c 
																			WHERE Contact__c =: contactId AND 
																			recordType.DeveloperName =: Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL
																			WITH SECURITY_ENFORCED];
				if (!existingConAssoObjList.isEmpty()){
					valuesToReturn = String.valueOf(existingConAssoObjList[0].id) + ',Contact_Association_Type__c,' + caseStatus;
				}
			}
		}
		return valuesToReturn;
	}
    @AuraEnabled
    public static Boolean createERASCase(){
    Id contactId = AppForCertHelper.retrieveCurrentContactId();
        Id erasRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ERAS).getRecordTypeId();
        Case csERAS = New Case();
        csERAS.RecordTypeId = erasRecordTypeId;
        csERAS.ContactId = contactId;
        csERAS.Internal_Status__c = Constants.CASE_STATUS_PENDING_SUBMISSION;
        csERAS.Case_Type__c = Constants.CASE_TYPE_ERAS;
        //Change the soql query to use new formula field - ERAS_Active__c - US#22257
        //List<Case> csERASQuery = [SELECT id FROM Case WHERE ContactId =: contactId AND RecordTypeId =:erasRecordTypeId AND Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION AND Eligibility_Period__r.Active__c='Y' WITH SECURITY_ENFORCED];
        List<Case> csERASQuery = [SELECT id FROM Case WHERE ContactId =: contactId AND RecordTypeId =:erasRecordTypeId AND Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION AND Eligibility_Period__r.ERAS_Active__c = true WITH SECURITY_ENFORCED];
        if(csERASQuery.isEmpty()){
            //Change the soql query to use new formula field - ERAS_Active__c - US#22257
            Eligibility_Period__c currntSeason = [SELECT Id FROM Eligibility_Period__c WHERE ERAS_Active__c = true AND EP_End_Date__c > TODAY AND RecordType.DeveloperName =:Constants.ELIGIBILITY_PERIOD_RECORD_TYPE_ERAS WITH SECURITY_ENFORCED LIMIT 1];
            csERAS.Eligibility_Period__c = currntSeason.Id;
            if(Schema.sObjectType.Case.isCreateable()){
                Insert csERAS;
            }
        }
        return true;
    }
    @AuraEnabled
    public static void checkERASInternalRestriction(){
        String currConId = AppForCertController.getContactId();
        Id qId = [Select Id from Group where type = 'Queue' and Name =: Constant_Case__mdt.getInstance('QUEUE_ERAS').Value__c limit 1].Id;
        Id erasRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constant_Case__mdt.getInstance('REC_TYPE_ERAS').Value__c).getRecordTypeId();
        List<Case> erasCases = new List<Case>();
        List<Case> erasCasesToUpdate = new List<Case>();
        erasCases = [SELECT Id, Internal_Status__c, CaseNumber FROM Case WHERE ContactId=:currConId and Internal_Status__c=:Constant_Case__mdt.getInstance('STATUS_PENDING_SUBMISSION').Value__c 
                    AND RecordTypeId=:erasRecTypeId WITH SECURITY_ENFORCED];
        if(!erasCases.isEmpty()){
            Case cs = new Case(Id =erasCases[0].Id); 
            cs.OwnerId = qId;
            Map<String,String> getDeg = getSelectedValues();
            if(getDeg.containsKey('Account__c')){
            cs.Entity__c = getDeg.get('Account__c');
            }
            cs.Token_Request_date__c = System.now();
            ApplicantCaseRecord.GetMessageWrapper rstMsg = new ApplicantCaseRecord.GetMessageWrapper();                
            rstMsg.caseId = null;
            rstMsg.accountId = null;
            rstMsg.contactId = currConId;
            rstMsg.service = 'ERAS - Internal Only';
            String inputJSONdtl = JSON.serialize(rstMsg);                
            String rstDtl = RestrictedMessage.getMessage(inputJSONdtl);             
            if(string.isNotBlank(rstDtl)){
                //No Restriction logic
                cs.Internal_status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_RESTRICTION_REVIEW').Value__c;
                cs.External_status__c = Constant_Case__mdt.getInstance('STATUS_TOKEN_REQUEST_IN_REVIEW').Value__c;            
                erasCasesToUpdate.add(cs);
            }
            else{            
                cs.Internal_status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_TOKEN_CALL').Value__c;
                cs.External_status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_TOKEN_CALL').Value__c;   
                erasCasesToUpdate.add(cs);         
            }        
            if(Schema.sObjectType.Case.isUpdateable() && !erasCasesToUpdate.isEmpty()){
                Update erasCasesToUpdate;
            }        
        }
    }
    //Method to check whether the applicant is eligible for requesting ERAS token
    @AuraEnabled
    public static boolean checkEligibilityForErasTokenReq(){
        Boolean usmleIdExists;
        Boolean isActiveErasSeason;
        String contactId = AppForCertHelper.retrieveCurrentContactId();
        usmleIdExists = checkApplicantUsmleID(contactId);
        isActiveErasSeason = checkActiveErasSeason();
        if(usmleIdExists == true && isActiveErasSeason == true){
            return true;
        }else{
            return false;
        }
    }
    @AuraEnabled
    public static boolean checkApplicantBiographic(){
        Boolean isBiographicPending ;
        String contactId = AppForCertHelper.retrieveCurrentContactId();
        List<Case> caseList = [SELECT Id,Internal_Status__c,RecordType.DeveloperName FROM Case
                WHERE ContactId =:contactId  AND RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_APP_BIO_CHANGE
                WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
        if(!caseList.isEmpty()){
            if(caseList[0].Internal_Status__c == Constants.CASE_STATUS_ACCEPTED || caseList[0].Internal_Status__c == Constants.CASE_STATUS_CANCELLED_BY_ECFMG || caseList[0].Internal_Status__c == Constants.CASE_STATUS_CANCELLED_BY_APPLICANT || caseList[0].Internal_Status__c == Constants.CASE_STATUS_REJECTED ){
            isBiographicPending = false;
            }
            else{
            isBiographicPending = true;
            }
        }else{
            isBiographicPending = false;
        }
        return isBiographicPending;      
    }
    //Method to check whether USMLE Id exists for Contact
    public static boolean checkApplicantUsmleID(String contactId){
        Boolean usmleIdExists;
        List<Contact> applicant = new List<Contact>();
        applicant = [SELECT Id, USMLE_ID__c FROM Contact 
                            WHERE Id =:contactId
                            WITH SECURITY_ENFORCED LIMIT 1];
        if(applicant.Size()>0){
            if(applicant[0].USMLE_ID__c != null){
                usmleIdExists = true;
            }else{
                usmleIdExists = false;
            }
        }
        return usmleIdExists;
    }
    //Method to check whether token request is already submitted for current season 
    @AuraEnabled
    public static List<Case> checkExistingErasTokenReq(){
        String contactId = AppForCertHelper.retrieveCurrentContactId();
        List<Case> erasTokenReqCase = new List<Case>();
        //Change the soql query to use new formula field
        erasTokenReqCase = [SELECT Id, Internal_Status__c, Eligibility_Period__c, Token__c, Token_Request_date__c, Date_Token_Issued__c, Eligibility_Period__r.Season__c 
                                FROM CASE 
                                WHERE ContactId =:contactId 
                                AND RecordType.DeveloperName = :Constants.CASE_RECORD_TYPE_ERAS 
                                AND Eligibility_Period__r.ERAS_Active__c = true 
                                AND Internal_Status__c != :Constants.CASE_STATUS_PENDING_SUBMISSION 
                                WITH SECURITY_ENFORCED LIMIT 1];
        return erasTokenReqCase;
    }
    //Method to check if request is initiated during the active ERAS season window 
    @AuraEnabled
    public static boolean checkActiveErasSeason(){
        Boolean activeSeason;
        List<Eligibility_Period__c> activeEligibilityPeriod = new List<Eligibility_Period__c>();
        //Change the soql query to use new formula field - US#22257
        activeEligibilityPeriod = [SELECT Id, EP_Start_Date__c, EP_End_Date__c FROM Eligibility_Period__c 
                                                        WHERE RecordType.DeveloperName = :Constants.ELIGIBILITY_PERIOD_RECORD_TYPE_ERAS 
                                                        AND ERAS_Active__c = true 
                                                        WITH SECURITY_ENFORCED LIMIT 1];
        if(activeEligibilityPeriod.size()>0){
            if(activeEligibilityPeriod[0].EP_Start_Date__c <= date.today() && activeEligibilityPeriod[0].EP_End_Date__c >= date.today()){
                activeSeason = true;
            }else{
                activeSeason = false;
            } 
        }
        return activeSeason;        
    }
    //Method to create ERAS Transcript request task creation.
    @AuraEnabled
    public static Boolean createERASTranscriptReqTask(Id caseId){
        Id contactId = AppforCertHelper.retrieveCurrentContactId();
        Id tskRectype = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Task').getRecordTypeId();
        Group g = [SELECT Id, name, Group.DeveloperName FROM Group WHERE Type = 'Queue' and Group.DeveloperName =: Constants.QUEUE_ERAS_TRANSCRIPT_REQ_TASK_QUEUE WITH SECURITY_ENFORCED];
        Contact thisContact = [SELECT Id, USMLE_ID__c from Contact where Id =: contactId WITH SECURITY_ENFORCED LIMIT 1];
        Task newTask = new Task();
        newTask.WhoId = contactId;
        newTask.RecordTypeId = tskRectype;
        newTask.Subject = 'ERAS Transcript Request';
        newTask.Status = 'New';
        newTask.OwnerId = g.Id;
        Date currentDate = Date.Today();
        newTask.USMLE_ID__c = thisContact.USMLE_ID__c;
        newTask.ActivityDate = currentDate.addDays(8);
        newTask.WhatId = caseId;
        newTask.IsVisibleInSelfService = true;
        if(Schema.SObjectType.Task.isCreateable() && Task.SObjectType.getDescribe().isCreateable()){
            INSERT newTask;
            return true;
        }
        return false;
    }
    // Method to check if the Mailing country is in the OFAC's Restricted by ECFMG category on profile page
    public static Boolean checkOFACRestriction(){
        try {
            Boolean isContactInOFAC = false;
		    Map<String,	OFAC__c > ofacCountriesMap = ServicesComponentController.getOFACCountryList();
            if (!ofacCountriesMap.isEmpty()) {
                Id contactId = AppforCertHelper.retrieveCurrentContactId();
                if (contactId != null) {
                    Contact thisContact = [Select id, MailingCountry from Contact where id =: contactId WITH SECURITY_ENFORCED LIMIT 1];
                    if (ofacCountriesMap.containsKey(thisContact.MailingCountry) && ofacCountriesMap.get(thisContact.MailingCountry).type__c == System.Label.OFAC_NOT_ALLOWED) {
                        isContactInOFAC = True;
                    }
                }
            }
		    return isContactInOFAC;
        } catch (Exception ex) {
            throw ex;
        }
        
	}
    @AuraEnabled
    public static string checkRestriction(){
        String separator = ';';
        String sobjectType = 'Contact';
        Id recordId = AppForCertHelper.retrieveCurrentContactId();
        String service = 'ERAS - Internal and External';
        String restrictedMsg = label.restrictedMsg;
        String query = String.escapeSingleQuotes('SELECT Id,ServicesRestricted__c FROM '+sobjectType+ ' WHERE Id=:recordId WITH SECURITY_ENFORCED');
        sObject rec = database.query(query);
        String serviceRestricted = string.valueof(rec.get('ServicesRestricted__c'));
        Boolean countryRestricted = checkOFACRestriction();
        if(countryRestricted){
            return label.OFAC_Not_Allowed_Error_Message;
        } 
        if(String.isNotBlank(serviceRestricted) && checkRestriction(serviceRestricted.split(separator),service)){
            return restrictedMsg;
        }
        return null;
    }

    private static boolean checkRestriction(List<string> serviceRestricted,string service){
        if((string.isBlank(service) && !serviceRestricted.isEmpty()) || serviceRestricted.contains(service)){
            return true;
        }
        return false;
    }
    @AuraEnabled
    public static String checkERASLockdownDate(){
       String contactId = AppForCertController.getContactId();
       List<Case> checkCase = [SELECT Id, ContactId, ParentId, Eligibility_period__c, End_of_Season_override_flag__c, RecordTypeId FROM Case WHERE RecordType.DeveloperName = :Constants.CASE_RECORD_TYPE_ERAS AND Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION AND contactId=: contactId WITH SECURITY_ENFORCED LIMIT 1];
       String result;
       if(checkCase.size() > 0){
       List<Eligibility_Period__c> checkEP= [SELECT Id, EP_Start_Date__c, Season__c, Lockdown_Start_Date__c FROM Eligibility_Period__c WHERE Id=:checkCase[0].Eligibility_period__c AND RecordType.DeveloperName = :Constants.ELIGIBILITY_PERIOD_RECORD_TYPE_ERAS WITH SECURITY_ENFORCED LIMIT 1];
           if(checkCase[0].End_of_Season_override_flag__c=='Yes' || checkEP[0].Lockdown_Start_Date__c > Date.today()){
           result= 'true';
            }
           else if(checkEP[0].Lockdown_Start_Date__c <= Date.today() && checkCase[0].End_of_Season_override_flag__c=='No'){
           result= 'false';
           }
           else{
           result= 'false';
           }
       }
       return result;
    }
    @AuraEnabled
    public static String getERASPSubmissionCase(){
        Id contactId = AppForCertHelper.retrieveCurrentContactId();
        Id erasRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ERAS).getRecordTypeId();        
        //Change the soql query to use new formula field -ERAS_Active__c - #US22257
        List<Case> erasCaseList = [SELECT Id FROM Case WHERE ContactId =: contactId AND RecordTypeId =: erasRecordTypeId AND Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION AND Eligibility_Period__r.ERAS_Active__c = true WITH SECURITY_ENFORCED];
        String erasCaseIds = '';            
        if(!erasCaseList.isEmpty()){
            List<String> erasCaseIdList = new List<String>();
            for(Case erasCaseRecord : erasCaseList){                
                erasCaseIdList.add(erasCaseRecord.Id);
            }
            erasCaseIds = String.join(erasCaseIdList,',');
        }
        return erasCaseIds;
    }
    @AuraEnabled
    public static boolean checkMedSchoolPortalAccess(){
        Id contactId = AppforCertHelper.retrieveCurrentContactId();
        List<CONTACT2ACCTSERVICE__c> con2AccSer = new List<CONTACT2ACCTSERVICE__c>();
        List<Account2Service__c> acc2Ser = new List<Account2Service__c>();
        List<Contact_Association_Type__c> catList = [SELECT Id, Account__c FROM Contact_Association_Type__c WHERE Contact__c =: contactId AND recordType.DeveloperName =: Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL WITH SECURITY_ENFORCED];
        if(!catList.isEmpty()){
            acc2Ser = [SELECT Id FROM Account2Service__c WHERE Account__c =: catList[0].Account__c AND Active__c = true AND Service__r.Name = 'ERAS' WITH SECURITY_ENFORCED];
        }
        if(!acc2Ser.isEmpty()){
            con2AccSer = [SELECT Id FROM CONTACT2ACCTSERVICE__c WHERE Account_Service__c IN : acc2Ser AND Active__c = true WITH SECURITY_ENFORCED];
        }
        if(!acc2Ser.isEmpty() && ! con2AccSer.isEmpty()){
            return true;
        }
        return false;        
    }
    @AuraEnabled
    public static List<Case> getErasTokenReq(){
        String contactId = AppForCertHelper.retrieveCurrentContactId();
        List<Case> erasTokenReqCase = new List<Case>();
        //Change the soql query to use new formula field -ERAS_Active__c - #US22257
        erasTokenReqCase = [SELECT Id, Internal_Status__c,MSPE__c,MS_Transcript__c,Repeat_Applicant__c,SG__c,AAMC_ID__c,USMLE_ID__c, Eligibility_Period__c, Token__c, Token_Request_date__c, Date_Token_Issued__c, Eligibility_Period__r.Season__c 
                                FROM CASE 
                                WHERE RecordType.DeveloperName = :Constants.CASE_RECORD_TYPE_ERAS 
                                AND Eligibility_Period__r.ERAS_Active__c = true
                                AND Internal_Status__c != :Constants.CASE_STATUS_PENDING_SUBMISSION 
                                WITH SECURITY_ENFORCED LIMIT 1];
        return erasTokenReqCase;
    }
    //To check if the applicant is eligible for Transcript Request from ECFMG
    @AuraEnabled
    public static String checkTranReqEligible(){
        try{
            Id contactId = AppForCertHelper.retrieveCurrentContactId();
            String retCaseId = checkDocUploadDisabled(contactId);
            Boolean accessOrNot = checkMedSchoolPortalAccess();
            List<Case> ecfmgCertCase = [SELECT Id, Internal_Status__c FROM Case WHERE ContactId =: contactId AND (RecordType.DeveloperName =: REC_TYPE_ECFMG OR Contact.Certificate_Issue_Date__c !=: null) WITH SECURITY_ENFORCED];
            List<Case> erasCase = [SELECT Id, Repeat_Applicant__c, CaseNumber FROM Case WHERE Id =: retCaseId WITH SECURITY_ENFORCED];
            List<Task> transReqTask = [SELECT Id FROM Task WHERE WhatId =: erasCase[0].Id WITH SECURITY_ENFORCED];
            if(retCaseId!=null && !accessOrNot && !ecfmgCertCase.isEmpty() && transReqTask.isEmpty() && !erasCase[0].Repeat_Applicant__c){
                return erasCase[0].CaseNumber;
            }
            return null;   
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    //To update the case on Transcript request
    @AuraEnabled
    public static Boolean updERASforTransReq(String copyOfTrans, String prevSubMSPE, Id caseId){
        try{
            List<Case> erasCase = [SELECT Id, Medical_school_transcript_obtained__c, MSPE_previously_submitted_to_ECFMG__c FROM Case WHERE Id =: caseId WITH SECURITY_ENFORCED LIMIT 1];
            erasCase[0].Medical_school_transcript_obtained__c = copyOfTrans;
            erasCase[0].MSPE_previously_submitted_to_ECFMG__c = prevSubMSPE;
            if(!erasCase.isEmpty() && Case.SObjectType.getDescribe().isUpdateable()){
                UPDATE erasCase[0];
            }
            return true;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    //To get the ERAS current case field values 
    @AuraEnabled
    public static Case getERASCase(Id caseId){
        try{
            List<Case> erasCase = [SELECT Id, Medical_school_transcript_obtained__c, MSPE_previously_submitted_to_ECFMG__c FROM Case WHERE Id =: caseId WITH SECURITY_ENFORCED LIMIT 1];
            return erasCase[0];
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Case> getCompletedErasTokenReq(String accountId){
        List<Case> erasTokenReqCase = new List<Case>();
        try{
        erasTokenReqCase = [SELECT Id,CaseNumber,Contact.lastName,Contact.firstName,SG__c,USMLE_ID__c,AAMC_ID__c,Repeat_Applicant__c,Date_Token_Issued__c,MS_Transcript__c,MSPE__c,Internal_Status__c
                            FROM CASE
                            WHERE RecordType.DeveloperName = :Constants.CASE_RECORD_TYPE_ERAS
                            AND Internal_Status__c =: Constant_Case__mdt.getInstance('STATUS_IN_REVIEW_WITH_AAMC').Value__c 
                            AND MSPE__c = true AND MS_Transcript__c = true
                            AND Entity__c =: accountId
                            AND Eligibility_Period__r.ERAS_Active__c = true
                            WITH SECURITY_ENFORCED ORDER BY CaseNumber ASC];
        return erasTokenReqCase;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Case> getPendingErasTokenReq(String accountId){
        List<Case> erasTokenReqCase = new List<Case>();
        try{
        erasTokenReqCase = [SELECT Id,CaseNumber,Contact.lastName,Contact.firstName,SG__c,USMLE_ID__c,AAMC_ID__c,Repeat_Applicant__c,Date_Token_Issued__c,MS_Transcript__c,MSPE__c,Internal_Status__c
                            FROM CASE
                            WHERE RecordType.DeveloperName = :Constants.CASE_RECORD_TYPE_ERAS
                            AND (Internal_Status__c =: Constant_Case__mdt.getInstance('STATUS_PENDING_DOCUMENT_UPLOAD').Value__c OR Internal_Status__c =: Constant_Case__mdt.getInstance('STATUS_IN_REVIEW_WITH_AAMC').Value__c OR Internal_Status__c =: Constant_Case__mdt.getInstance('STATUS_PENDING_AAMC_REVIEW').Value__c) 
                            AND (MSPE__c = false OR MS_Transcript__c = false)
                            AND Repeat_Applicant__c = false
                            AND Entity__c =: accountId
                            AND Eligibility_Period__r.ERAS_Active__c = true 
                            WITH SECURITY_ENFORCED ORDER BY CaseNumber ASC];
        return erasTokenReqCase;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
	public static List<CvWrapper> getFilesForMerge(String filename){
        try{
            List<CvWrapper> cvwList = new List<CvWrapper> ();
            //Define supported file extensions
            Set<String> fileFormats = new Set<String> {
                    'pdf', 
                    'xfdf',
                    'fdf',
                    'docx', 
                    'xlsx',
                    'pptx',
                    'jpg',
                    'jpeg',
                    'png',
                    'mov',
                    'tif',
                    'xlsx'
            };
            //Use links to get attachments
            List<ContentDocument>  contDoc = [SELECT Id FROM ContentDocument  where Title =: filename WITH SECURITY_ENFORCED];
            for(ContentVersion cv : [SELECT Title, FileExtension, VersionData, ContentDocumentId, LastModifiedDate, ContentSize, LastModifiedBy.Alias
                                        FROM ContentVersion 
                                        WHERE ContentDocumentId IN :contDoc 
                                        AND IsLatest = true 
                                        WITH SECURITY_ENFORCED ORDER BY Title]){
                if(fileFormats.contains(cv.FileExtension.toLowerCase())){
                    cvwList.add(new CvWrapper(cv));
                }
            }
            return cvwList;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
	}
    public class CvWrapper{
		@AuraEnabled
		public String id{get; set;}
		@AuraEnabled
		public String fileName{get; set;}
		@AuraEnabled
		public String base64{get; set;}
		@AuraEnabled
		public String fileExtension{get; set;}
		public CvWrapper(ContentVersion cv){
			this.id = cv.Id;
			this.fileName = cv.Title + '.' + cv.FileExtension;
			this.fileExtension = cv.FileExtension;
			this.base64 = EncodingUtil.base64Encode(cv.VersionData);
		}
	}
}