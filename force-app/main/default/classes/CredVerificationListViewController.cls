public with sharing class CredVerificationListViewController{
    @AuraEnabled
    public static List<CredVerificationListViewController.CVCaseWrapper> getCaseRecords(String currentEntityId,String applicantId,String currCaseId){
        try{
            system.debug('currentEntityId--->'+currentEntityId);
            system.debug('applicantId--->'+applicantId);
            system.debug('currCaseId--->'+currCaseId);
            Id cID = AppForCertHelper.retrieveCurrentContactId();
            system.debug('cID--->'+cID);
            List<CONTACT2ACCTSERVICE__c> activeEntity = new List<CONTACT2ACCTSERVICE__c>([SELECT Id,Service__c,Role__c
                FROM CONTACT2ACCTSERVICE__c
                WHERE Account_Service__r.Account__c =: currentEntityId AND
                Service_Contact__c =: cID AND
                (Service__c =: Constants.SERVICE_NAME_CREDENTIAL_VERIFICATION OR Service__c =: Constants.SERVICE_NAME_MEDICAL_EDU_FORM) AND
                Active__c = true]);
            List<CredVerificationListViewController.CVCaseWrapper> retCaseList =  new List<CredVerificationListViewController.CVCaseWrapper>();
            List<Case> currentCvlist=  new List<Case>();
            system.debug('activeEntity--->'+activeEntity);
            if(!activeEntity.isEmpty()){
                Id credVerRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION);
                Id medEduFormId = GenericUtilities.getRecordTypeIdByDevName('Case',Constants.CASE_RECORD_TYPE_MED_EDU_FORM);
                Id affirmCredVerRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Affirmation__c',Constants.AFFIRMATION_RECORD_TYPE_CREDENTIAL_VERIFICATION);
                Id affirmMedFormRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Affirmation__c',Constants.AFFIRMATION_RECORD_TYPE_MED_EDU_FORM);
                Set<Id> caseIds = new Set<Id>();
                Set<String> internalStat = new Set<String>{Constants.CASE_STATUS_SENT_FOR_VERIFICATION,Constants.CASE_STATUS_RESENT_FOR_VERIFICATION,Constants.CASE_STATUS_IN_REVIEW_AT_ENTITY,Constants.CASE_STATUS_INCOMPLETE_RESENT_FOR_VERIFICATION};
                String affirmationQuery = 'SELECT Id, Case__c FROM Affirmation__c WHERE (Case__r.RecordTypeId =: credVerRecTypeId OR Case__r.RecordTypeId =: medEduFormId) AND (RecordTypeId =: affirmCredVerRecTypeId OR RecordTypeId =: affirmMedFormRecTypeId) AND Case__r.Internal_Status__c IN: internalStat AND ((Case__r.Entity__c =: currentEntityId AND Verify_with_Alternate_Entity__c = false) OR (Case__r.Alternate_Entity__c =:currentEntityId AND Verify_with_Alternate_Entity__c = true))';
                affirmationQuery = getAffQuery(applicantId,currCaseId,affirmationQuery);
                affirmationQuery = String.escapeSingleQuotes(affirmationQuery +  ' WITH SECURITY_ENFORCED');
                for(Affirmation__c affRec:database.query(affirmationQuery)){
                    caseIds.add(affRec.Case__c);
                }
                system.debug('caseIds--->'+caseIds);
                List<Verification_Packet__c> verPackt = [SELECT Id,Case__r.CaseNumber,(SELECT Id, Send_Method__c FROM Send_Requests__r 
                                                                                       WHERE Send_Method__c = 'Entity Portal' AND Current_Send_Date__c!=null  ORDER BY CreatedDate desc Limit 1) 
                                                         FROM Verification_Packet__c WHERE Case__c in: caseIds AND Is_Active__c = true WITH SECURITY_ENFORCED];
                List<String> caseNumbers = new List<String>();
                system.debug('verPackt--->'+verPackt);
                for(Verification_Packet__c ver: verPackt){
                    for(Send_Request__c send: ver.Send_Requests__r){
                        if(send.Id!=null){
                            caseNumbers.add(ver.Case__r.CaseNumber);
                        }
                    }
                }
                system.debug('caseNumbers--->'+caseNumbers);
                currentCvlist = [SELECT Id, Contact.FirstName,Case_Service__c, CaseNumber, Contact.LastName, Account.Unique_Medical_School_ID__c, Record_Available_Date__c, ECFMG_ID__c, Date_of_Birth__c, Entity_External_Status__c, Send_Method__c, RecordTypeId, Entity_Review_Step__c FROM Case WHERE CaseNumber IN: caseNumbers  WITH SECURITY_ENFORCED ORDER BY Record_Available_Date__c ASC];
                retCaseList = getCVcaseWrp(currentCvlist, cID);
                system.debug('retCaseList--->'+retCaseList);
                return retCaseList;
            }else{
                return null;
            }
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }  
    }
    public static List<CVCaseWrapper> getCVcaseWrp(List<Case> cvCaseList, ID entityConId){
        
        String EntityContactId = entityConId;
        List<CVCaseWrapper> returnValue = new List<CVCaseWrapper>();
        if(!cvCaseList.isEmpty()){
            for(Case ca : cvCaseList){
                string caseId = ca.Id;                      
                string caseNumber = ca.caseNumber;
                string caseService = ca.Case_Service__c;   
                string restOfName = ca.Contact.FirstName;
                string lastName = ca.Contact.LastName;
                string ecfmgID = ca.ECFMG_ID__c;
                string uniqueMedicalSchoolID = ca.Account.Unique_Medical_School_ID__c;
                string dateOfBirth = null;
                if(ca.Date_of_Birth__c != null){                
                    dateOfBirth = dateFormatting(ca.Date_of_Birth__c);
                }	
                string recordAvailableDate = null;
                if(ca.Record_Available_Date__c != null){
                    recordAvailableDate = dateFormatting(ca.Record_Available_Date__c);
                }
                string status = ca.Entity_External_Status__c;
                Decimal reviewStep = ca.Entity_Review_Step__c;
                Map<String,String> cData = new Map<String,String>();
                cData.put('caseIdVal', caseId);
                cData.put('caseNumberVal', caseNumber);
                cData.put('caseServiceVal',caseService);
                cData.put('restOfNameVal', restOfName);
                cData.put('lastNameVal', lastName);
                cData.put('uniqueMedicalSchoolIDVal', uniqueMedicalSchoolID);
                cData.put('ecfmgID', ecfmgID);
                cData.put('dateOfBirth', dateOfBirth);
                cData.put('recordAvailableDate', recordAvailableDate);
                cData.put('status', status);
                CVCaseWrapper cvWrp = new CVCaseWrapper(cData,reviewStep,EntityContactId);
                returnValue.add(cvWrp);
            }
        }
        return returnValue;
    }
    public class CVCaseWrapper{
        @auraenabled public string caseId {get;set;}       
        @auraenabled public string caseNumber {get;set;}
        @auraenabled public string restOfName {get;set;}
        @auraenabled public string lastName {get;set;}
        @auraenabled public string uniqueMedicalSchoolID {get;set;}
        @auraenabled public string dateOfBirth {get;set;} 
        @auraenabled public string ecfmgID {get;set;}       
        @auraenabled public string recordAvailableDate {get;set;}        
        @auraenabled public string status {get;set;}
        @auraenabled public Decimal reviewStep {get;set;}
        @auraenabled public string caseService { get; set; }
        @auraenabled public string entityConId { get; set; }
        public CVCaseWrapper(Map<String,String> cData, Decimal reviewStepNum,Id entityConIdVal){
            caseId = cData.get('caseIdVal');
            caseNumber = cData.get('caseNumberVal');
            caseService = cData.get('caseServiceVal');
            restOfName = cData.get('restOfNameVal');
            lastName = cData.get('lastNameVal');
            ecfmgID = cData.get('ecfmgID');
            uniqueMedicalSchoolID = cData.get('uniqueMedicalSchoolIDVal');
            dateOfBirth = cData.get('dateOfBirth');
            recordAvailableDate = cData.get('recordAvailableDate');
            status = cData.get('status');
            reviewStep = reviewStepNum;  
            entityConId = entityConIdVal;         
        }
    }
    @AuraEnabled
    public static string dateFormatting(Date dateValue){
        try{
            String dateForm = '';
            if(dateValue != null){
                Date relatedMonthDate = dateValue;
                Integer day2 = relatedMonthDate.day();
                Integer mon2= relatedMonthDate.month();
                Integer yr2 = relatedMonthDate.year();
                DateTime dt2 = DateTime.newInstance(yr2, mon2, day2);       
                dateForm = dt2.format('MMMM d, yyyy');        
            }
            return dateForm;
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    static String getAffQuery(String applicantId,String currCaseId,String affirmationQuery){
        if(String.isNotBlank(applicantId) && String.isNotBlank(currCaseId)){
            affirmationQuery = affirmationQuery + ' AND Case__r.Id !=: currCaseId AND Case__r.ContactId =: applicantId';
        }
        return affirmationQuery;
    }
}