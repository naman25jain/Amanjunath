@isTest(seeAllData=false)
public class EpicReportsControllerTest{
    //This method will cover the positive and negative scenario of the EpicReportsController class
    @isTest
    public static void testEVActive(){
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.BillingCountry = 'India';
        INSERT acc;
        
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        con.Email = 'test@test.com';
        INSERT con;
        
        List<Service__c> myServiceList = new List<Service__c>();
        Service__c serv = new Service__c(Name = 'Volume Report Recipients', Signature_Required__c = TRUE, Seal_Required__c = TRUE);
        myServiceList.add(serv);

        insert myServiceList;
        List<Account2Service__c> myAccServList = new List<Account2Service__c>();
        Account2Service__c acc2Service = new Account2Service__c(Account__c = acc.Id, Active__c = TRUE, Service__c = serv.Id);

        myAccServList.add(acc2Service);
        insert myAccServList;
        List<CONTACT2ACCTSERVICE__c> myCon2AccService = new List<CONTACT2ACCTSERVICE__c>();
        CONTACT2ACCTSERVICE__c conService = new CONTACT2ACCTSERVICE__c(Account_Service__c = acc2Service.Id, Role__c = 'Coordinator', Service_Contact__c=con.Id);
        myCon2AccService.add(conService);
        insert myCon2AccService;

        Id epicReportReqId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_VER_REPORT_REQUEST).getRecordTypeId();

        Case evCase = new Case();
            evCase.RecordTypeId = epicReportReqId;
            evCase.ContactId = con.Id;
            evCase.AccountId = acc.Id;
            evCase.Internal_Status__c = 'New';
            evCase.EPIC_Report_Archived_Status__c = false;
            evCase.Document_Type__c = 'Release';
            evCase.Reference_Number__c = '1234';
            evCase.Entity_External_Status__c = 'Not Reviewed';
            evCase.EPIC_Report_Received_Date__c = system.today();
            INSERT evCase;
        Test.startTest();
        List<Case> caseEpicList = EpicReportsController.getEpicCases(acc.Id, true);
        //Added assert condition to check the whether is method is returing the EPIC Cases or not
        System.assert(caseEpicList != null, 'Case List should not empty');
        Boolean isUpdateDone =  EpicReportsController.updateArchivedStatus(evCase.Id, true);
        //Added assert condition to check the whether is method is returing the boolean as true or not
        System.assert(isUpdateDone == true, 'Field should be udpated as true');
        Boolean isStatusUpdated =  EpicReportsController.updateEntityExternalStatus(evCase.Id);
        //Added assert condition to check the whether is method is returing the boolean as true or not
        System.assert(isStatusUpdated == true, 'Status should be udpated as true');

        EpicReportsController.getParentEnityName(acc.Id);
        Test.stopTest();   
    }
}