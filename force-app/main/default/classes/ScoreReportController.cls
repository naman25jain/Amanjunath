/**
 * Class for ScoreReportController
 *
 * @author        Enable Consulting
 * @version       1.0
 * @createdDate   23-APRIL-2020
 */
public with sharing class ScoreReportController {
    /**
     * Created by Nayana S
     * Method Name: getScoreReportInfo
     * Purpose : Method to fetch Score Report Information
     * Return Type : List of Exam Registration
     */
    @AuraEnabled(Cacheable = false)
    public static List< ScoreReportHelper.ExamScoreWrapper > getScoreReportInfo(){
        Id contactId = AppForCertHelper.retrieveCurrentContactId();
        
        List< ScoreReportHelper.ExamScoreWrapper > returnValue = new List< ScoreReportHelper.ExamScoreWrapper >();

        for (Exam_Registration__c examReg : [SELECT Id, Name, Exam_Types__c,Withheld_Score__c, Exam_taken_date__c, Posted_Date__c,Pd_Optout_flag__c,Withheld_Reason__c
                                        FROM Exam_Registration__c                                        
                                        WHERE Applicant__c =: contactId
                                        AND (Exam_status__c =: Constants.EXAM_REGISTRATION_EXAM_STATUS_FAILED OR Exam_status__c =: Constants.EXAM_REGISTRATION_EXAM_STATUS_PASSED) AND ((Withheld_Score__c = false 
                                        AND Posted_Date__c != null) OR (Withheld_Score__c = true 
                                        AND Posted_Date__c = null AND Withheld_Reason__c includes (:Constants.SCORE_WITHHELD_REASON_ENROLLMENT_REVERIFICATION,:Constants.SCORE_WITHHELD_REASON_ID_VERIFICATION)))
                                        ORDER BY Posted_Date__c DESC] ) {

                                            String tempAvailableDate;
                                            String tempExamDate;
                                            Boolean tempIsAvailable = true;
                                            String optOutFlag = Constants.STATUS_NO;
                                            string withHeldReason = '';
                                            Date availableDate ;
                                            
                                            if(examReg.Posted_Date__c != null){
                                                availableDate = examReg.Posted_Date__c.addDays(365);
                                                tempAvailableDate = String.valueOf(DateTime.newInstance(availableDate.year(), availableDate.month(), availableDate.day()).format(Constants.DATE_FORMAT));
                                            }
                                            

                                            if(System.today() > availableDate) {
                                                tempIsAvailable = false;
                                            }

                                            if (examReg.Exam_taken_date__c != null) {
                                                tempExamDate = String.valueOf(DateTime.newInstance(examReg.Exam_taken_date__c.year(), examReg.Exam_taken_date__c.month(), examReg.Exam_taken_date__c.day()).format(Constants.DATE_FORMAT));
                                            } else {
                                                tempExamDate = '';
                                            }

                                            if(examReg.Pd_Optout_flag__c == True){
                                                optOutFlag = Constants.STATUS_YES;
                                            }

                                            withHeldReason = getWithHeldReason(examReg);
                                           
                                            String scoreReport = '';
                                            ScoreReportHelper.ExamScoreWrapper examScoreObj = new ScoreReportHelper.ExamScoreWrapper (examReg.Id, examReg.Exam_Types__c,tempExamDate,tempAvailableDate,scoreReport,tempIsAvailable,optOutFlag,withHeldReason,examReg.Withheld_Score__c);
                                            returnValue.add(examScoreObj);
                                        }
        return returnValue;        
    } 

       /**
     * Created by Jofrin    
     * Method Name: getWithHeldReason
     * Purpose : Method to get WithHeldReason.
     * Return Type : String
     */
    @AuraEnabled(Cacheable = false)
    public static String getWithHeldReason(Exam_Registration__c examReg){
        string withHeldReason = '';
        if(string.isnotblank(examReg.Withheld_Reason__c) && examReg.Withheld_Score__c == true && examReg.Posted_Date__c == null){
            if(examReg.Withheld_Reason__c.contains(Constants.SCORE_WITHHELD_REASON_ENROLLMENT_REVERIFICATION) && examReg.Withheld_Reason__c.contains(Constants.SCORE_WITHHELD_REASON_ID_VERIFICATION)){
                withHeldReason = Constants.SCORE_WITHHELD_REASON_ID_VERIFICATION_SCORE_RECHECK +'<br>' +Constants.SCORE_WITHHELD_REASON_ENROLLMENT_REVERIFICATION_SCORE_RECHECK;
            }
            else if(examReg.Withheld_Reason__c.contains(Constants.SCORE_WITHHELD_REASON_ENROLLMENT_REVERIFICATION)){
                withHeldReason = Constants.SCORE_WITHHELD_REASON_ENROLLMENT_REVERIFICATION_SCORE_RECHECK;
            }
            else if(examReg.Withheld_Reason__c.contains(Constants.SCORE_WITHHELD_REASON_ID_VERIFICATION)){
                withHeldReason = Constants.SCORE_WITHHELD_REASON_ID_VERIFICATION_SCORE_RECHECK;
            }
        }
        return withHeldReason;
    }


    /**
     * Created by Jofrin    
     * Method Name: conditionForScoreRecheck
     * Purpose : Method to display Score Recheck button.
     * Return Type : List of Exam Registration
     */
    @AuraEnabled(Cacheable = false)
    public static Boolean conditionForScoreRecheck(){
        Id contactId = AppForCertHelper.retrieveCurrentContactId();
        Boolean returnValT = false;
        Id scoreRecheckRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_SCORE_RECHECK).getRecordTypeId();
        List<Id> examRegIdList = new List<Id>();
        for(Case scoreReCase : [SELECT Id, Internal_Status__c, Exam_Registration__c,ContactId
                                FROM Case                                        
                                WHERE ContactId =: contactId
                                AND RecordTypeId =: scoreRecheckRecordTypeId AND (Internal_Status__c !=: Constants.CASE_STATUS_ACCEPTED AND Internal_Status__c !=: Constants.CASE_STATUS_PENDING_SUBMISSION)]){
                                    examRegIdList.add(scoreReCase.Exam_Registration__c);
                                }
        for(Exam_Registration__c examReg : [SELECT Id, Name, Exam_Types__c, Exam_taken_date__c, Posted_Date__c,Exam_Status__c
                                        FROM Exam_Registration__c                                        
                                        WHERE Applicant__c =: contactId
                                        AND Withheld_Score__c = false 
                                        AND Posted_Date__c != null AND Id !=: examRegIdList
                                        ORDER BY Posted_Date__c DESC]){
                                            Date dateVal = examReg.Posted_Date__c.addDays(90);
                                            if(System.today() < dateVal &&  (examReg.Exam_Status__c != Constants.EXAM_REGISTRATION_EXAM_STATUS_NOSHOW && examReg.Exam_Status__c != '' && examReg.Exam_Status__c != null)){
                                                returnValT = true;
                                            }
                                        }
        return returnValT;
    }
    /**
     * Created by Nayana S
     * Method Name: getScoreRecheckExams
     * Purpose : Method to fetch the exams eligible for score recheck
     * Return Type : List of Exams
     */
    @AuraEnabled(Cacheable = false)
    public static List< Exam_Registration__c > getScoreRecheckExams(){
        Id contactId = AppForCertHelper.retrieveCurrentContactId();
        List<Exam_Registration__c> eligibleExamRegList = new List<Exam_Registration__c>();
        Id scoreRecheckRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_SCORE_RECHECK).getRecordTypeId();
        List<Id> examRegIdList = new List<Id>();
        for(Case scoreReCase : [SELECT Id, Internal_Status__c, Exam_Registration__c,ContactId
                                FROM Case                                        
                                WHERE ContactId =: contactId
                                AND RecordTypeId =: scoreRecheckRecordTypeId AND Internal_Status__c !=: Constants.CASE_STATUS_ACCEPTED AND Internal_Status__c !=: Constants.CASE_STATUS_PENDING_SUBMISSION WITH SECURITY_ENFORCED]){
                                    examRegIdList.add(scoreReCase.Exam_Registration__c);
                                }
        for(Exam_Registration__c examReg : [SELECT Id, Name, Exam_Types__c, Exam_taken_date__c, Posted_Date__c, Exam_Status__c, Is_Score_Rechecked__c
                                        FROM Exam_Registration__c                                        
                                        WHERE Applicant__c =: contactId
                                        AND Withheld_Score__c = false 
                                        AND Posted_Date__c != null AND Id !=: examRegIdList WITH SECURITY_ENFORCED
                                        ORDER BY Posted_Date__c DESC, Exam_Types__c]){
                                            Date eligibleDate = examReg.Posted_Date__c.addDays(90);
                                            if(System.today() < eligibleDate && (examReg.Exam_Status__c != Constants.EXAM_REGISTRATION_EXAM_STATUS_NOSHOW 
                                                && examReg.Exam_Status__c != '' && examReg.Exam_Status__c != null)){              
                                                    eligibleExamRegList.add(examReg);
                                            }
                                        }
        return eligibleExamRegList;        
    }
    /**
     * Created by Nayana S
     * Method Name: manageScoreRecheck
     * Purpose : Method to fetch the exams eligible for score recheck
     * Return Type : String
     */ 
    @AuraEnabled(Cacheable = false)
    public static String manageScoreRecheck(List<String> examIdsList){
        Id contactId = AppForCertHelper.retrieveCurrentContactId();
        List<Exam_Registration__c> scoreRecheckExamRegList = new List<Exam_Registration__c>();
        List<Exam_Registration__c> updExamReg = new List<Exam_Registration__c>();
        List<Exam_Registration__c> examRegs = [SELECT Id, Is_Score_Rechecked__c FROM Exam_Registration__c WHERE Applicant__c =: contactId WITH SECURITY_ENFORCED];
        for(Exam_Registration__c examReg : examRegs){
            if(examIdsList.contains(examReg.Id)){
                examReg.Is_Score_Rechecked__c = true;
                scoreRecheckExamRegList.add(examReg);
            }
            else{
                examReg.Is_Score_Rechecked__c = false;
                updExamReg.add(examReg);
            }
        }
        if(!scoreRecheckExamRegList.isEmpty() && Exam_Registration__c.SObjectType.getDescribe().isUpdateable()){
            UPDATE scoreRecheckExamRegList;  
        }
        if(!updExamReg.isEmpty() && Exam_Registration__c.SObjectType.getDescribe().isUpdateable()){
            UPDATE updExamReg;
        }
        return 'true';      
    }
    // US 20731 - Create Score Recheck Case.
    @AuraEnabled
    public static String createSRCase(){        
        try{
            Id contactId = AppForCertHelper.retrieveCurrentContactId();
            Id scoreRecheckRecordTypeId =   Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_SCORE_RECHECK).getRecordTypeId();
            List<Case> scoreRecheckCaseList = new List<Case>();
            List<Case> scoreRecheckToDel = [SELECT Id, Internal_Status__c, Exam_Registration__c, ContactId FROM Case WHERE ContactId =: contactId AND RecordTypeId =: scoreRecheckRecordTypeId AND Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION AND Exam_Registration__r.Is_Score_Rechecked__c = false WITH SECURITY_ENFORCED];
            List<Exam_Registration__c> examRegList = [SELECT Id, Name, (SELECT Id, CaseNumber FROM Cases__r WHERE RecordTypeId =: scoreRecheckRecordTypeId AND Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION) FROM Exam_Registration__c WHERE Applicant__c =: contactId AND Is_Score_Rechecked__c = true WITH SECURITY_ENFORCED];
            for(Exam_Registration__c examReg : examRegList){
                if(examReg.Cases__r.isEmpty()){
                    Case srCase = new Case();
                    srCase.ContactId = contactId;
                    srCase.RecordTypeId = scoreRecheckRecordTypeId;
                    srCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_SUBMISSION;
                    srCase.Exam_Registration__c = examReg.Id;
                    scoreRecheckCaseList.add(srCase);  
                }
            }
            if(!scoreRecheckCaseList.isEmpty() && Case.SObjectType.getDescribe().isCreateable()){
                INSERT scoreRecheckCaseList;
            }  
            for(Case scoreRech : scoreRecheckToDel){
                scoreRech.Internal_Status__c = Constants.CASE_STATUS_MARKED_FOR_DELETION;
                scoreRech.Exam_Registration__c = null;
            } 
            if(!scoreRecheckToDel.isEmpty() && Case.SObjectType.getDescribe().isUpdateable()){
                UPDATE scoreRecheckToDel;
            }
            String srCaseIdString = '';
            List<String> srCaseIdList = new List<String>();
            List<Case> srCaseList = [SELECT Id, CaseNumber, Internal_Status__c FROM Case WHERE RecordTypeId =: scoreRecheckRecordTypeId AND ContactId =: contactId AND Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION WITH SECURITY_ENFORCED];
            for(Case srCaseObj : srCaseList){                
                srCaseIdList.add(srCaseObj.Id);
            }
            srCaseIdString = String.join(srCaseIdList,',');
            return srCaseIdString;  
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
     * @author: Ajoydhas
     * @methodname: getTermsandConditionsData
     * @description: Method to fetch Terms and conditions for Store Recheck Legal Signoff
     * @Parameters: no
     * @return type: List of wrapper with terms content
     */
    @AuraEnabled(Cacheable = true)
	public static List<AppForCertHelper.TermsObjWrapper> getTermsandConditionsData() {
		List<AppForCertHelper.TermsObjWrapper > fetchedValuesToReturn = new List<AppForCertHelper.TermsObjWrapper > ();
		List<Terms_and_Conditions__c > termsList = new List<Terms_and_Conditions__c > ();
		termsList = [Select Id, Copy__c, Name, Short_Copy__c From Terms_and_Conditions__c Where Product__r.Name =: Constants.PRODUCT_NAME_SCORE_RECHECK_LEGAL_TERMS
			and Status__c =: Constants.TERMS_AND_COND_STATUS_ACTIVE
			Order By CreatedDate ASC
		];
		if (!termsList.isEmpty()) {
			For(Terms_and_Conditions__c terms: termsList) {
				string termsId = terms.Id;
				string termsContent = terms.Copy__c;
				string termsCheckBox = terms.Short_Copy__c;

				AppForCertHelper.TermsObjWrapper tempTermsObj = new AppForCertHelper.TermsObjWrapper(termsId, termsContent, termsCheckBox);

				fetchedValuesToReturn.add(tempTermsObj);
			}
		}

		return fetchedValuesToReturn;
    }
    /**
     * @author: Ajoydhas
     * @methodname: paymentCompletion
     * @description: Method to create Score Recheck Case for each selected exams
     * @Parameters: no
     * @return type: Boolean
     */
    @AuraEnabled(Cacheable = false)
    public static List<String> paymentCompletion(){
        Id contactId = AppForCertHelper.retrieveCurrentContactId();
        Id scoreRecheckRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_SCORE_RECHECK).getRecordTypeId();
        Group scoreRecheckQueue =   [SELECT Id FROM Group WHERE Type = 'Queue' AND Group.DeveloperName =: Constants.CASE_QUEUE_SCORE_REPORTS WITH SECURITY_ENFORCED LIMIT 1];
        String scoreRecheckQueueId = scoreRecheckQueue.Id;
        List<Case> scoreRecheckCaseList = new List<Case>();
        Set<Id> examRegsId = new Set<Id>();
        List<String> srCaseNums = new List<String>();
        for(Exam_Registration__c examReg : [SELECT Id, Name FROM Exam_Registration__c WHERE Applicant__c =: contactId 
                                           AND Is_Score_Rechecked__c = true WITH SECURITY_ENFORCED]){
                                            examRegsId.add(examReg.Id);
        }
        List<Case> srCases = [SELECT Id, CaseNumber, Internal_Status__c, Exam_Registration__c, ContactId, ECFMG_Portal_Case_Url__c FROM Case WHERE ContactId =: contactId
                             AND RecordTypeId =: scoreRecheckRecordTypeId AND Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION AND Exam_Registration__c IN : examRegsId WITH SECURITY_ENFORCED];
        for(Case sr : srCases){
            sr.Internal_Status__c = Constants.CASE_STATUS_NEW;
            sr.OwnerId = scoreRecheckQueueId;
            scoreRecheckCaseList.add(sr);
            srCaseNums.add(sr.CaseNumber);
        }
        // Score Recheck Case is updated
        if(!scoreRecheckCaseList.isEmpty() && Case.SObjectType.getDescribe().isUpdateable()){
            UPDATE scoreRecheckCaseList;
            // Updating as Is_Score_Rechecked__c is false on Exam Registration Object
            List<Exam_Registration__c> examRegList = new List<Exam_Registration__c>();    
            for(Case caseItem : scoreRecheckCaseList) {
                Exam_Registration__c examReg = new Exam_Registration__c();
                examReg.Id = caseItem.Exam_Registration__c;
                examReg.Is_Score_Rechecked__c = false;
                examRegList.add(examReg);
            }
            if(!examRegList.isEmpty() && Case.SObjectType.getDescribe().isUpdateable()){
                UPDATE examRegList;
            }
            // Sending Mail to NBME
            sendMailToNBMEScoreRecheck(scoreRecheckCaseList);
        }
        return srCaseNums;
    }
    // Method to send mail to NBME (Score Rechecks: Inform NBME, Receive Results)
    public static void sendMailToNBMEScoreRecheck(List<Case> scoreRecheckCaseList){
        Id contactId = AppForCertHelper.retrieveCurrentContactId();
        List<Case> scoreRecheckCases = new List<Case>();
        List<OrgWideEmailAddress> addr = [select Id from OrgWideEmailAddress where displayname =: Constants.ORG_WIDE_ADDRESS];
        EmailTemplate emailTemplate = [Select Id, Subject, Description, HtmlValue, DeveloperName, Body from EmailTemplate where DeveloperName =: Constants.CASE_EMAIL_TEMPLATE_NAME];
        Contact contactEmail = [Select Id, Email, Name from Contact where Id =: contactId WITH SECURITY_ENFORCED];
        for(Case caseRecord : scoreRecheckCaseList){            
            if(contactEmail.Email != null){
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setTargetObjectId(caseRecord.ContactId);
                message.setTemplateID(emailTemplate.Id);
                message.setOrgWideEmailAddressId(addr[0].Id);
                String htmlBody = emailTemplate.HtmlValue;
                String ecfmgPortalCaseUrl = caseRecord.ECFMG_Portal_Case_Url__c;
                if(ecfmgPortalCaseUrl == null){
                    ecfmgPortalCaseUrl = getECFMGPortalCaseUrl(caseRecord.Id);
                }
                htmlBody = htmlBody.replace('{!Case.Internal_Status__c}', caseRecord.Internal_Status__c);
                htmlBody = htmlBody.replace('{!Case.Contact}', contactEmail.Name);
                htmlBody = htmlBody.replace('{!Case.ECFMG_Portal_Case_Url__c}', ecfmgPortalCaseUrl);
                htmlBody = htmlBody.replaceAll('<!\\[CDATA\\[', '');
                htmlBody = htmlBody.replaceAll('\\]\\]>', '');
                String toEmailAddress = contactEmail.Email;
                message.setHtmlBody(htmlBody);
                message.toAddresses = new String[]{toEmailAddress};
                try{
                    Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{message};
                    Messaging.sendEmail(messages);
                }catch(exception e){
                    throw new ControllerException(e.getMessage());
                }
            }
            Case caseObj = new Case();
            caseObj.Id = caseRecord.Id;
            caseObj.Internal_Status__c = Constants.CASE_STATUS_SENT;
            scoreRecheckCases.add(caseObj);
        }        
        try{
            if(!scoreRecheckCases.isEmpty() && Case.SObjectType.getDescribe().isUpdateable()){
                update scoreRecheckCases;  
            }
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    // Get ECFMG Portal Case URL
    public static String getECFMGPortalCaseUrl(String caseId){
        String caseUrl = '';
        try{
            Network myNetwork = [SELECT Id FROM Network WHERE Name =: Constants.COMMUNITY_NAME]; //Donot add WITH SECURITY_ENFORCED
            String portalUrl = Network.getLoginUrl(myNetwork.Id);
            portalUrl = portalUrl.substringBefore('login');
            caseUrl = portalUrl+'s/case/'+caseId;            
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
        return caseUrl;
    }
    /**
     * Created by Jofrin    
     * Method Name: checkValidationForWithholdExams
     * Purpose : Method to check for exam registration to withhold.
     * Return Type : List of Exam Registration
     */
    @AuraEnabled(Cacheable = false)
    public static List< ScoreReportHelper.ExamWithholdWrapper > checkValidationForWithholdExams(){
        List< ScoreReportHelper.ExamWithholdWrapper > returnValue = new List< ScoreReportHelper.ExamWithholdWrapper >();
        Id contactId = AppForCertHelper.retrieveCurrentContactId();
        string regionName = '';
        string examType = '';
        string testAccomod = '';
        string elRangeFormatted = '';
        Date checkDate;
        for(Exam_Registration__c examReg : [SELECT Id, Name,Exam__c, Exam_Types__c,Test_Accommodations_needed__c,EP_start_Date__c,Product_Detail__r.Exam_Region__r.Region_Name__c,Product_Detail__c,Pd_Optout_flag__c,Scheduled_Test_Date__c,EP_end_Date__c,Case__r.External_Status__c FROM Exam_Registration__c WHERE Applicant__c =: contactId AND Case__r.External_Status__c =:Constants.CASE_STATUS_REGISTERED AND (Exam_Status__c = '' OR Exam_Status__c = null)]){   
            if(examReg.Scheduled_Test_Date__c != null){
               checkDate = examReg.Scheduled_Test_Date__c - 10;
            }
            else{
                checkDate = examReg.EP_end_Date__c - 10;
            }
            if(examReg.Test_Accommodations_needed__c != null && examReg.Test_Accommodations_needed__c !=''){
                testAccomod = examReg.Test_Accommodations_needed__c;        
            }
            if(examReg.Pd_Optout_flag__c == false && system.Today() < checkDate){
                regionName = examReg.Product_Detail__r.Exam_Region__r.Region_Name__c;
                examType = examReg.Exam__c;
                Date epStartDate = examReg.EP_start_Date__c;
                Date epEndDate = examReg.EP_end_Date__c;
                
                Datetime epStartDateTime = Datetime.newInstance(epStartDate.year(), epStartDate.month(), epStartDate.day());
                Datetime epEndDateTime = Datetime.newInstance(epEndDate.year(), epEndDate.month(), epEndDate.day());
    
                elRangeFormatted = epStartDateTime.format(Constants.Eligibility_Date_Format) + ' - ' + epEndDateTime.format(Constants.Eligibility_Date_Format);     
                
                ScoreReportHelper.ExamWithholdWrapper examScoreObj = new ScoreReportHelper.ExamWithholdWrapper (examReg.Id, examType,elRangeFormatted,regionName,testAccomod); 

                returnValue.add(examScoreObj);
            }
        }
        return returnValue;
    }

    /**
     * Created by Jofrin    
     * Method Name: updateOptoutFlag
     * Purpose : Method to update OptOut flag in exam registration.
     * Return Type : String
     */
    @AuraEnabled(Cacheable = false)
    public static String updateOptoutFlag(List<String> examsSelected){
        List<Exam_Registration__c> examRegList = new List<Exam_Registration__c> ();
        for(Exam_Registration__c examReg : [SELECT Id, Name,Exam__c, Exam_Types__c,Pd_Optout_flag__c FROM Exam_Registration__c WHERE Id =: examsSelected]){
            examReg.Pd_Optout_flag__c = True;
            examRegList.add(examReg);
        }
        try{
            if(!examRegList.isEmpty()){
                Update examRegList;
            }
        }
        catch(exception e){
            system.debug('results: e' + e.getMessage());
        }
        return 'Success';
    }
    @AuraEnabled(cacheable = false)
    public static String getScoreRecheckCases(){
        Id contactId = AppForCertHelper.retrieveCurrentContactId();
        Id scoreRecheckRecordTypeId =   Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_SCORE_RECHECK).getRecordTypeId();
        String srCaseIdString = '';
        List<String> srCaseIdList = new List<String>();
        List<Case> srCaseList = [SELECT Id, CaseNumber, Internal_Status__c FROM Case WHERE RecordTypeId =: scoreRecheckRecordTypeId AND ContactId =: contactId AND Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION WITH SECURITY_ENFORCED];
        for(Case srCaseObj : srCaseList){                
            srCaseIdList.add(srCaseObj.Id);
        }
        srCaseIdString = String.join(srCaseIdList,',');
        return srCaseIdString;
    }
}