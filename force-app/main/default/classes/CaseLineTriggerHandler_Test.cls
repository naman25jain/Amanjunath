@isTest
public class CaseLineTriggerHandler_Test {

    @TestSetup
    static void makeData(){

        BillingTestFactory.createEpicCase();

    }
    
    @IsTest
    static void testCreateBillings(){

        Test.startTest();

        Case case1 = [SELECT Id, Internal_Status__c FROM Case WHERE Subject = 'Test 1' LIMIT 1];
        case1.Internal_Status__c = 'Accepted';
        update case1;
        
        Test.stopTest();

        System.assertEquals('Billed', [SELECT Id, Accounting_Status__c FROM Case_Line__c WHERE Case__c = :case1.Id LIMIT 1].Accounting_Status__c, 'The case lines were not billed correctly');
        
    }

    @IsTest
    static void testFulfillment(){

        Test.startTest();

        Case case1 = [SELECT Id, Internal_Status__c FROM Case WHERE Subject = 'Test 1' LIMIT 1];

        List<Case_Line__c> caseLines = [SELECT Id, Accounting_Status__c FROM Case_Line__c WHERE Case__c = :case1.Id];
        List<String> caseLineIds = new List<String>();
        for (Case_Line__c caseLine : caseLines) {
            caseLineIds.add(caseLine.Id);
        }
        CaseLineTriggerHandler.createBillings(caseLineIds);

        case1.Internal_Status__c = 'Complete';
        update case1;

        Test.stopTest();

        System.assertEquals('Fulfilled', [SELECT Id, Accounting_Status__c FROM Case_Line__c WHERE Case__c = :case1.Id LIMIT 1].Accounting_Status__c, 'The case lines were not fulfilled correctly.');
    }
 
    @IsTest
    static void testRejection(){

        Test.startTest();

        Case case1 = [SELECT Id, Internal_Status__c FROM Case WHERE Subject = 'Test 1' LIMIT 1];

        List<Case_Line__c> caseLines = [SELECT Id, Accounting_Status__c FROM Case_Line__c WHERE Case__c = :case1.Id];
        List<String> caseLineIds = new List<String>();
        for (Case_Line__c caseLine : caseLines) {
            caseLineIds.add(caseLine.Id);
        }
        CaseLineTriggerHandler.createBillings(caseLineIds);

        case1.Internal_Status__c = 'Rejected';
        update case1;

        Test.stopTest();

        System.assertEquals('Rejected', [SELECT Id, Accounting_Status__c FROM Case_Line__c WHERE Case__c = :case1.Id LIMIT 1].Accounting_Status__c, 'The case line was not rejected correctly.');
    }

    @IsTest
    static void testCancellation(){

        Test.startTest();

        Case case1 = [SELECT Id, Internal_Status__c FROM Case WHERE Subject = 'Test 1' LIMIT 1];

        List<Case_Line__c> caseLines = [SELECT Id, Accounting_Status__c, Fulfilled_Date__c, EP_End_Date__c, Billed_Date__c, Product2Service__r.Fulfilled_Price_Date_Field__c FROM Case_Line__c WHERE Case__c = :case1.Id];
        List<String> caseLineIds = new List<String>();
        for (Case_Line__c caseLine : caseLines) {
            caseLineIds.add(caseLine.Id);
        }
        CaseLineTriggerHandler.createBillings(caseLineIds);
        CaseLineTriggerHandler.createJournalEntries(caseLineIds);

        case1.Internal_Status__c = 'Closed - No Longer Eligible';
        update case1;

        Test.stopTest();

        System.assertEquals('Cancelled', [SELECT Id, Accounting_Status__c FROM Case_Line__c WHERE Case__c = :case1.Id LIMIT 1].Accounting_Status__c, 'The case line was not cancelled correctly.');
    }
}