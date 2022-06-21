/**
* Test Class for RegionChangeController class
*
* @author        Enable Consulting
* @version       1.0
* @createdDate   02-APR-2020
*/
@isTest
public with sharing class RegionChangeControllerTest {
    @testSetup static void setup() {
        RegionChangeTestFactory.servicePageSetup();
    }
    
    @isTest static void testRegionChange() {
        User testUser = [SELECT Id, contactId from User where alias='second'];
        System.runAs(testUser) {
            
            Test.startTest();
            RegionChangeController.getRegionChangeCaseforSummary();
            RegionChangeController.getTermsandConditionsDataRegionChange();
            RegionChangeController.regionChangePaymentCompletion();
            RegionChangeController.getCaseNumber();
            RegionChangeController.getConstantsClass();
            RegionChangeController.cancelRegionChangeRequest();
            Test.stopTest();
        }
    }
    @isTest static void testgetRegionChangeExams() {
        User testUser = [SELECT Id, contactId from User where alias='second'];
        System.runAs(testUser) {
            String valLabel = 'USMLE Step 1'+' ' + System.label.Region_Change_Validation_Eligibility_Period + 'USMLE Step 1'+' ' + System.label.Region_Change_Validation_Exam_Already_Taken;
            System.assert(valLabel != NULL);
            Test.startTest();
            List<RegionChangeHelper.ExamRegistrationObjWrapper> examRegValues = new List <RegionChangeHelper.ExamRegistrationObjWrapper>();
            examRegValues = RegionChangeController.getRegionChangeExams();
            
            List<String> examIdString = new List<String>();
            examIdString.add(examRegValues[0].recordIdVal);
            
            RegionChangeController.getRegionChangeCaseforSummary();
            
            String s = '[{"Id":"'+examRegValues[0].caseId+'","Exam_Region_Surcharge__c":"'+examRegValues[0].regionSurchargeId+'","Surcharge__c":"100","Is_Requested_Region_Change__c":true}]';
            RegionChangeController.manageRegionChangeRequest(s);
            Test.stopTest();
        }
    }
    @isTest public static void testcheckingExistingRegionChange(){
        User testUser = [SELECT Id, contactId from User where alias='second'];
        System.runAs(testUser) {
           String s1='000011A';
           RegionChangeController.checkingExistingRegionChange(s1);
            
        }
    }
    
    @isTest static void testGetExamRegistrationforSummaryData(){
        List<Exam_Registration__c> myList_ER = new List<Exam_Registration__c>([Select Id from Exam_Registration__c]);
        List<String> myList = new List<String>();
        for(Integer i=0; i< myList_ER.size(); i++){
            myList.add(myList_ER[i].Id);
        }
        //   RegionChangeController.getRegionChangeCaseforSummary();
    }
    @isTest static void testWrapCaseSummaryData(){
        RegionChangeController.WrapCaseSummaryData wrapper= new RegionChangeController.WrapCaseSummaryData ();
        wrapper.caseId='caseId123';
        wrapper.examType='type1';
        wrapper.oldRegionAndSurcharge='oldSurcharge';
        wrapper.newRegionAndSurcharge='new surcharge';
        
        
        
    }
    @isTest static void testgetConstantsClass(){
        RegionChangeController.getConstantsClass();
    }
    
    
}