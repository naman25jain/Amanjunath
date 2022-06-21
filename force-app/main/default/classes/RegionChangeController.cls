/**
 * @description RegionChangeController
 * Class for Region Change
 *
 * @author        Enable Consulting
 * @version       1.0
 * @createdDate   16-MARCH-2020
 */
public with sharing class RegionChangeController {
    /**
     * Created by Ajoydhas
     * Method Name: getExamRegistrations
     * @description : Method to get list of exam registrations with region surcharges based on examtype for Region Change Request
     * @return: List of registration records with region surcharges
     */
    @AuraEnabled(cacheable = false)
    public static List <RegionChangeHelper.ExamRegistrationObjWrapper> getRegionChangeExams() {
        Id contactId = AppForCertHelper.retrieveCurrentContactId();
        Id examRegRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        List <RegionChangeHelper.ExamRegistrationObjWrapper> fetchedValuesToReturn = new List <RegionChangeHelper.ExamRegistrationObjWrapper>();
        // Map of Region Surcharge based on Exam Type
        Map<String, List<Product_Detail__c>> erSurchargeMap = new Map<String, List<Product_Detail__c>>();
        String objectName   =   Constants.EXAM_REGISTRATION_OBJECT;
        String fieldName    =   Constants.EXAM_REGISTRATION_FIELD_EXAM_TYPES;

        //Map of examtype and region change case
        Map<String, Case> examRegionCaseMap = new Map<String, Case>();
        List<Case> existingRegionCases = new List<Case>();
        Case selectedRegion = new Case();
        Boolean isRequestedRegionChange;
        String caseRegionSurchargeId;
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult r = s.getDescribe();
        Map < String, Schema.SObjectField > fields = r.fields.getMap();
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();        
        for (Schema.PicklistEntry pickListVal: ple) {
            String examTypeVal = pickListVal.getLabel();
            List <Product_Detail__c> examRegionSurchargeLists = [SELECT ID, Exam_Types__c, Surcharge__c, Exam_Region__r.Name, Exam_Region__c,
                                                                    Exam_Region__r.Region_Short_Description__c, Service_Fee__c 
                                                                    FROM Product_Detail__c 
                                                                    WHERE Exam_Types__c =: examTypeVal AND Active_formula__c = true 
                                                                    ORDER BY Exam_Region__r.Name ASC];
            erSurchargeMap.put(examTypeVal, examRegionSurchargeLists);
        }
        //Get Selected Region Change cases if any        
        existingRegionCases = [SELECT Id, CaseNumber, Internal_Status__c, Is_Requested_Region_Change__c, ParentId,Surcharge__c,
							Product_Detail__r.Exam_Region__r.Region_Name__c, Product_Detail__r.Exam_Types__c, Product_Detail__c
							FROM Case WHERE recordType.DeveloperName =: Constants.CASE_RECORD_TYPE_REGION_CHANGE
                            AND ContactId =: contactId AND Internal_Status__c =:Constants.CASE_STATUS_PENDING_SUBMISSION
                            AND Product_Detail__c != null WITH SECURITY_ENFORCED];        
        //Create map of exam type and region change case
        if(existingRegionCases.size()>0){
            for(Case regionChangeCase:existingRegionCases){
                examRegionCaseMap.put(regionChangeCase.Product_Detail__r.Exam_Types__c,regionChangeCase);
            }
        }                         
        // Lists of Exam Registrations
        Date valCheckDate = System.today()+ 20;
		for (Exam_Registration__c examRegistrationRecord: [SELECT Id, Exam_Types__c, EP_start_Date__c, EP_end_Date__c, Case__r.Product_Detail__c, Product_Detail__c, Surcharge__c, Product_Detail__r.Exam_Region__r.Name, Product_Detail__r.Exam_Region__c, Case__r.Is_Requested_Region_Change__c, Test_Accommodations_needed__c
                                                                FROM Exam_Registration__c
                                                                WHERE Applicant__c =: contactId
                                                                AND Case__r.RecordTypeId =: examRegRecordTypeId
                                                                AND Case__r.Internal_Status__c =: Constants.CASE_STATUS_REGISTERED                                                                
                                                                AND Exam_Types__c !=: Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCS
                                                                AND EP_end_Date__c >=: valCheckDate
                                                                AND Exam_Status__c = null    
                                                                ORDER BY Exam_Types__c]) {
            if(examRegionCaseMap.size()>0 && !examRegionCaseMap.isEmpty() && examRegionCaseMap.containsKey(examRegistrationRecord.Exam_Types__c)){               
                selectedRegion = examRegionCaseMap.get(examRegistrationRecord.Exam_Types__c);
                isRequestedRegionChange =  selectedRegion.Is_Requested_Region_Change__c; 
                caseRegionSurchargeId = String.valueOf(selectedRegion.Product_Detail__c);    
            } else{
                isRequestedRegionChange = examRegistrationRecord.Case__r.Is_Requested_Region_Change__c;
                caseRegionSurchargeId = examRegistrationRecord.Case__r.Product_Detail__c;
            }            
            // Formatting EP Start Date & EP End Date
            String eligibilityPeriodDate    =   '';
            Date epStartDate1               =   examRegistrationRecord.EP_start_Date__c;
            Datetime epStartDateTime        =   Datetime.newInstance(epStartDate1.year(), epStartDate1.month(), epStartDate1.day());
            Date epEndDate1                 =   examRegistrationRecord.EP_end_Date__c;
            Datetime epEndDateTime          =   Datetime.newInstance(epEndDate1.year(), epEndDate1.month(), epEndDate1.day());
            eligibilityPeriodDate           =   epStartDateTime.format('MMMM d,  yyyy') +' - '+ epEndDateTime.format('MMMM d,  yyyy');

            String recordIdVal              =   examRegistrationRecord.Id;
            String examType                 =   examRegistrationRecord.Exam_Types__c;
            Date epStartDate                =   examRegistrationRecord.EP_start_Date__c;
            Date epEndDate                  =   examRegistrationRecord.EP_end_Date__c;
            String eligibilityPeriod        =   eligibilityPeriodDate;
            String caseId                   =   examRegistrationRecord.Case__r.Id;
            String regionSurchargeId        =   examRegistrationRecord.Product_Detail__c;
            String surcharge                =   String.valueof(examRegistrationRecord.Surcharge__c);
            String regionName               =   examRegistrationRecord.Product_Detail__r.Exam_Region__r.Name;
            String regionId                 =   examRegistrationRecord.Product_Detail__r.Exam_Region__c;
            String testAccommodNeeded       =   examRegistrationRecord.Test_Accommodations_needed__c;
            
            RegionChangeHelper.ExamRegistrationObjWrapper tempObj = new RegionChangeHelper.ExamRegistrationObjWrapper(
                recordIdVal, 
                examType, 
                epStartDate, 
                epEndDate, 
                eligibilityPeriod, 
                caseId,
                regionSurchargeId,
                surcharge,
                regionName,
                regionId,
                testAccommodNeeded,
                isRequestedRegionChange,
                getWrapExamRegSurchargeLists(erSurchargeMap, examType, regionSurchargeId, caseRegionSurchargeId)
            );
            fetchedValuesToReturn.add(tempObj);
        }
        return fetchedValuesToReturn;       
    }

    /**
     * Created by Ajoydhas
     * Method Name: validateRegionChangeRequest
     * @description : Method to validate during check on Exam Type
     * @return List of RegionSurchargeObjWrapper
     */
    @AuraEnabled
    public static List <RegionChangeHelper.RegionSurchargeObjWrapper> getWrapExamRegSurchargeLists(Map<String, List<Product_Detail__c>> erSurchargeMap, String examType, String regionSurchargeId, String caseRegionSurchargeId) {
        // Lists of Region Surcharge based on Exam Type
        List <RegionChangeHelper.RegionSurchargeObjWrapper> surchargeLists = new List <RegionChangeHelper.RegionSurchargeObjWrapper>();
        RegionChangeHelper.RegionSurchargeObjWrapper surchargeTemp; 
        if (!erSurchargeMap.isEmpty()) {                
            List<Product_Detail__c> regionSurchargeLists = erSurchargeMap.get(examType);
            for (Product_Detail__c regionSurchargeRec: regionSurchargeLists) {
                String regionSurchargeIdVal     =   regionSurchargeRec.Id;
                String regionNameVal            =   regionSurchargeRec.Exam_Region__r.Name;
                String regionIdVal            =   regionSurchargeRec.Exam_Region__c;
                String regionShortDescription   =   regionSurchargeRec.Exam_Region__r.Region_Short_Description__c;
                String regionSurchargeVal       =   string.valueof(regionSurchargeRec.Service_Fee__c);
                String selectedSurchargeId      =   '';

                if(caseRegionSurchargeId == regionSurchargeIdVal) {
                    selectedSurchargeId = regionSurchargeIdVal;
                }

                if(regionSurchargeId != regionSurchargeIdVal) {
                    surchargeTemp = new RegionChangeHelper.RegionSurchargeObjWrapper(
                                            regionSurchargeIdVal, 
                                            regionNameVal, 
                                            regionIdVal, 
                                            regionShortDescription, 
                                            regionSurchargeVal, 
                                            selectedSurchargeId);
                    surchargeLists.add(surchargeTemp);
                }                
            }
        }
        return surchargeLists;
    }
    /**
     * Created by Monica
     * Method Name : checkingExistingRegionChange
     * @description : Method to validate during check on Exam Type
     * @return String
     */
    @AuraEnabled(Cacheable = false)
    public static String checkingExistingRegionChange(String examId){
        String returnString;
        Set<Id> caseList = new Set<Id>();
        Id currentContactId = AppForCertHelper.retrieveCurrentContactId();
        List<Exam_Registration__c> caseId=[SELECT Id, case__r.Id FROM Exam_Registration__c WHERE Id=:examId WITH SECURITY_ENFORCED];
        for(Exam_Registration__c examCase:caseId){
            caseList.add(examCase.case__r.Id);
        }
        if(caseList != null){
            List<Case> existingRegionCases = [SELECT Id, CaseNumber, Internal_Status__c FROM Case WHERE ParentId IN: caseList 
                                                        AND ContactId=:currentContactId
                                                        AND RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_REGION_CHANGE AND 
                                                        Internal_Status__c !=: Constants.CASE_STATUS_ACCEPTED AND Internal_Status__c !=: Constants.CASE_STATUS_PENDING_SUBMISSION
                                                        AND Internal_Status__c !=: Constants.CASE_STATUS_EXPIRED
                                                        AND Product_Detail__c != null WITH SECURITY_ENFORCED];
            if(!existingRegionCases.isEmpty()){
                returnString = 'true';
            }
            else{
                returnString = 'false';
            }
        }
        return returnString;
    }
    /**
     * Created by Ajoydhas
     * Modified by Indu Prasad for US 18763 SP-53
     * Method Name: manageRegionChangeRequest
     * @description : Method to validate during check on Exam Type.Return Type is String containing validation error or true if no errors are hit
     * @return String
     */
    // Creating Region Change case with Status is Pending Submission
    @AuraEnabled(Cacheable = false)
    public static String manageRegionChangeRequest(String jsonString){
        Id currentContactId = AppForCertHelper.retrieveCurrentContactId();
        Id regionChangeRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_REGION_CHANGE).getRecordTypeId();
        List<Case> objectList = (List<Case>) JSON.deserialize(jsonString, List <Case>.class);
        List<Case> caseInsertList = new List<Case>(); 
        //List<Case> caseUpdateList = new List<Case>();
        //Map<Id,Case> caseUpdateMap = new Map<Id,Case>(); 
        Map<Id,Case> caseInsertMap = new Map<Id,Case>();           
        List<Case> existingRegionCases = new List<Case>();
        Set<Id> examCaseIds = new Set<Id>();
        List<String> regionChangeIdLsit = new List<String>();
        String regionChangeIdStr = '';
        //String returnString = 'true';
        Map<String, Case> regionExamMap = new Map<String, Case>();
        for(Case caseRec : objectList){
            examCaseIds.add(caseRec.Id);
        }
        existingRegionCases = [SELECT Id,ContactId,RecordType.DeveloperName,Internal_Status__c,ParentId, 
                                Product_Detail__c, Surcharge__c, Product_Detail__r.Exam_Types__c
                                FROM Case WHERE ParentId IN: examCaseIds 
                                AND ContactId=:currentContactId 
                                AND RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_REGION_CHANGE 
                                AND Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION
                                WITH SECURITY_ENFORCED];
        if(!existingRegionCases.isEmpty()){
            for(Case regCase:existingRegionCases){
                regionExamMap.put(regCase.ParentId,regCase); 
            }
        }
        for(Case caseRecord : objectList){            
            if(regionExamMap.containsKey(caseRecord.Id) && regionExamMap.get(caseRecord.Id) !=null){
                Case existingRegionCase = regionExamMap.get(caseRecord.Id);
                if(caseRecord.Product_Detail__c != null && !String.isBlank(caseRecord.Product_Detail__c)){
                    existingRegionCase.Product_Detail__c = caseRecord.Product_Detail__c;
                    existingRegionCase.Surcharge__c  =  Double.valueOf(caseRecord.Surcharge__c);                            
                } else{
                    existingRegionCase.Internal_Status__c = Constants.CASE_STATUS_EXPIRED;
                    existingRegionCase.Is_Requested_Region_Change__c = false;
                }
                caseInsertList.add(existingRegionCase);
            }else if((regionExamMap.isEmpty() || regionExamMap.get(caseRecord.Id) == null) && caseRecord.Is_Requested_Region_Change__c == true){
                Case newRegionChangeCase = new Case(
                    ParentId =  caseRecord.Id,
                    ContactId = currentContactId,
                    RecordTypeId = regionChangeRecordTypeId,
                    Service__c = Constants.CASE_SERVICE_ECFMG_CERT,
                    Internal_Status__c = Constants.CASE_STATUS_PENDING_SUBMISSION,
                    Product_Detail__c = caseRecord.Product_Detail__c,
                    Surcharge__c  =  Double.valueOf(caseRecord.Surcharge__c),
                    Is_Requested_Region_Change__c = true,
                    Exam_Region__c = caseRecord.Exam_Region__c
                );
                caseInsertList.add(newRegionChangeCase);
            }
        }         
        try{
            if(!caseInsertList.isEmpty() && Schema.sObjectType.Case.isCreateable() && Schema.sObjectType.Case.isUpdateable()){
                upsert caseInsertList;
                for(Case caseObj : caseInsertList){
                    regionChangeIdLsit.add(caseObj.Id);
                }
                regionChangeIdStr = String.join(regionChangeIdLsit,',');
            }          
        } catch(DmlException e){
            throw new ControllerException(e.getMessage());
        }
        return regionChangeIdStr;
    } 

    /**
     * Created by Ajoydhas
     * Method Name: cancelRegionChangeRequest
     * @description : Method to Cancel RegionChange Request. Return Type is String containing validation error or true if no errors are hit
     * @return String
     */
    @AuraEnabled(Cacheable = false)
    public static String cancelRegionChangeRequest() {
        String returnString = 'true';
        return returnString;
    }
	
	/**
     * Created by Balashankar
     * Modified by Indu Prasad
     * Method Name: getExamRegistrationforSummary
     * @description : Method to fetch case data to display for summary screen.Return Type : case record data
     * @return List of WrapCaseSummaryData
     */
    @AuraEnabled
    public static List<WrapCaseSummaryData> getRegionChangeCaseforSummary(){
        Id contactId = AppForCertHelper.retrieveCurrentContactId();
        List<Case> regionChangeCases = new List<Case>();
        List<WrapCaseSummaryData> caseData = new List<WrapCaseSummaryData>();
        String oldSurcharge;

        regionChangeCases = [SELECT Id, CaseNumber, Internal_Status__c, Surcharge__c,
							Product_Detail__r.Exam_Region__r.Region_Name__c, Product_Detail__r.Exam_Types__c,
							ParentId, Parent.Product_Detail__r.Exam_Region__r.Region_Name__c,  Parent.Surcharge__c,
                            Parent.Product_Detail__r.Service_Fee__c, Parent.Product_Detail__r.Processing_Fee__c
							FROM Case WHERE recordType.DeveloperName =: Constants.CASE_RECORD_TYPE_REGION_CHANGE
                            AND ContactId =: contactId AND Internal_Status__c =:Constants.CASE_STATUS_PENDING_SUBMISSION
                            AND Is_Requested_Region_Change__c = true AND Product_Detail__c != null 
                            WITH SECURITY_ENFORCED];

        if(regionChangeCases.size() > 0){
            for(Case caseRecord:regionChangeCases){
                if(caseRecord.ParentId !=null && caseRecord.Parent.Product_Detail__c !=null){
                    if(caseRecord.Parent.Product_Detail__r.Service_Fee__c !=null && caseRecord.Parent.Product_Detail__r.Processing_Fee__c !=null){
                        oldSurcharge = String.valueOf(caseRecord.Parent.Product_Detail__r.Service_Fee__c + caseRecord.Parent.Product_Detail__r.Processing_Fee__c);
                    } else if(caseRecord.Parent.Product_Detail__r.Processing_Fee__c ==null){
                        oldSurcharge = String.valueOf(caseRecord.Parent.Product_Detail__r.Service_Fee__c);
                    }                    
                    WrapCaseSummaryData caseRec = new WrapCaseSummaryData();
                    caseRec.caseId = caseRecord.Id;
                    caseRec.examType = caseRecord.Product_Detail__r.Exam_Types__c;
                    caseRec.oldRegionAndSurcharge = caseRecord.Parent.Product_Detail__r.Exam_Region__r.Region_Name__c + '(' + '$' + String.valueOf(oldSurcharge)  + ')';
                    caseRec.newRegionAndSurcharge = caseRecord.Product_Detail__r.Exam_Region__r.Region_Name__c + '(' + '$' + caseRecord.Surcharge__c  + ')';
                    caseData.add(caseRec);
                }                
            }            
        }
        return caseData;        
    }

    /**
     * Method Name: getTermsandConditionsDataRegionChange
     * @description : Method to fetch Terms and conditions for Region change legalsignoff. Return Type : List of wrapper with terms content
     * @return List of AppForCertHelper.TermsObjWrapper
     */
    @AuraEnabled(Cacheable = true)
    public static List < AppForCertHelper.TermsObjWrapper > getTermsandConditionsDataRegionChange() {
        List < AppForCertHelper.TermsObjWrapper > fetchedValuesToReturn = new List < AppForCertHelper.TermsObjWrapper > ();
        List < Terms_and_Conditions__c > termsList = new List < Terms_and_Conditions__c > ();
        termsList = [Select Id, Copy__c, Name, Short_Copy__c From Terms_and_Conditions__c Where Product__r.Name =: Constants.PRODUCT_NAME_REGION_CHANGE_LEGAL_TERMS
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
     * Author: Balashankar Bhaskar
     * Modified by: Indu Prasad for SP-53 US 18763
     * Method Name: regionChangePaymentCompletion
     * @description : Update existing most recent region change request Case's status and make previous region change requests false
     * @return Boolean
     */
    @AuraEnabled(Cacheable = false)
    public static Boolean regionChangePaymentCompletion(){        
       Id contactId = AppForCertHelper.retrieveCurrentContactId();
       List<Case> existingRegionChangeCases= new List<Case>();
       List<Case> existingCasesToUpdate = new List<Case>();
       List<Case> latestRegionChangeCasesToUpdate = new List<Case>();
       List<Case> latestRegionChangeCases= new List<Case>();
       
       Group g = [SELECT Id, name, Group.DeveloperName FROM Group WHERE Type = 'Queue'
           and Group.DeveloperName =: Constants.QUEUE_EXAM_REG WITH SECURITY_ENFORCED];	

       //Query existing region change request cases related to the contact with status Pending CIBIS and make Is_Requested_Region_Change__c false
       existingRegionChangeCases = [SELECT Id, CaseNumber, Internal_Status__c, Status FROM Case 
                                   WHERE recordType.DeveloperName =: Constants.CASE_RECORD_TYPE_REGION_CHANGE 
                                   AND ContactId =: contactId AND Internal_Status__c =: Constants.CASE_STATUS_PENDING_CIBIS 
                                   AND Is_Requested_Region_Change__c = true WITH SECURITY_ENFORCED];
                              
       if(existingRegionChangeCases.size() > 0){		
           for(Case existingRegionChangeRec: existingRegionChangeCases){
               existingRegionChangeRec.Is_Requested_Region_Change__c = false;
               existingCasesToUpdate.add(existingRegionChangeRec);
           }
       }
       
       if(!existingCasesToUpdate.isEmpty() && Schema.sObjectType.Case.isUpdateable()){
           update existingCasesToUpdate;
       }

       //Query region change request case with status pending submission and mark it true and update required fields
       latestRegionChangeCases = [SELECT Id, CaseNumber,Internal_Status__c, Status FROM Case 
                                   WHERE recordType.DeveloperName =: Constants.CASE_RECORD_TYPE_REGION_CHANGE
                                   AND ContactId =: contactId AND Internal_Status__c =:Constants.CASE_STATUS_PENDING_SUBMISSION
                                   AND Is_Requested_Region_Change__c = true WITH SECURITY_ENFORCED];
      
       //Update status and Is_Requested_Region_Change__c so that correct case number will be displayed in the summary screen
       if(latestRegionChangeCases.size() > 0){		
           for(Case regionChangeRec: latestRegionChangeCases){
               regionChangeRec.OwnerId = g.Id;
               regionChangeRec.Internal_Status__c =  Constants.CASE_STATUS_PENDING_CIBIS;
               regionChangeRec.External_Status__c = Constants.CASE_STATUS_SUBMITTED_IN_REVIEW;
               latestRegionChangeCasesToUpdate.add(regionChangeRec);
           }
       }
      
       if(!latestRegionChangeCasesToUpdate.isEmpty() && Schema.sObjectType.Case.isUpdateable()){
           update latestRegionChangeCasesToUpdate;
       }       
       return true;        
    }

    /**
     * Created by Balashankar
     * Method Name: getCaseNumber
     * @description : Method to get Region Change caseNumber
     * @return List<String>
     */
    @AuraEnabled(Cacheable = false)
    public static  String  getCaseNumber() {
        String returnStr ='';
        Id currentContactId = AppForCertHelper.retrieveCurrentContactId();
        if (currentContactId != null){
            for(Case c :[SELECT id, CaseNumber, Internal_Status__c 
                            FROM Case 
                        WHERE recordType.DeveloperName =: Constants.CASE_RECORD_TYPE_REGION_CHANGE
                            AND ContactId =: currentContactId 
                            AND Internal_Status__c =: Constants.CASE_STATUS_PENDING_CIBIS
                            AND Is_Requested_Region_Change__c = true]){                            
                if(returnStr == ''){
                    returnStr = String.valueof(c.caseNumber);
                } else{
                    returnStr = returnStr +',' +String.valueof(c.caseNumber);
                }                            
            }                  
        }
        return returnStr;
    }

    public class WrapCaseSummaryData{
        @AuraEnabled public String caseId {get; set;}
        @AuraEnabled public String examType {get; set;}
        @AuraEnabled public String oldRegionAndSurcharge {get; set;}
        @AuraEnabled public String newRegionAndSurcharge {get; set;}
    }

    @AuraEnabled(Cacheable = true)
    public static Constants getConstantsClass(){
        return new Constants();
    }
}