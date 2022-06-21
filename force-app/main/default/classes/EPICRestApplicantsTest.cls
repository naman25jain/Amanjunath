/*
    Createdby       : Pradeep Kumar
    CreatedDate     : 02/15/2022
    Story           : EPIC Applicant Test Class with code coverage
*/
@IsTest
public class EPICRestApplicantsTest extends ECFMGTestFactory {
 private static CurrentEntityIDSequence__c settingsInstance;
    private static CurrentECFMGIDSequence__c settingsECFMGInstance;
    static{
        CurrentECFMGIDSequence__c settingsECFMGInstance = CurrentECFMGIDSequence__c.getOrgDefaults();
        settingsECFMGInstance.ECFMG_ID__c = '00000001';
        upsert settingsECFMGInstance;
    }
    @TestSetup
    static void makeData(){
        setDefaultContext();

        //Create a System Admin user
        User setUpUser = (User) make(ECFMGTestFactoryUsers.UnitTestSetUpUser.class);
        run();
        
        //Get RecordType IDs of Account, Contact, Case, Asset
        Id entityRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_ENTITY).getRecordTypeId(); 
        Id applicantRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_APPLICANT).getRecordTypeId();
        Id caseEpicReportRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_VER_REPORT_REQUEST).getRecordTypeId(); 
        Id caseCVRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        
        List<Account> topLevelList = new List<Account>();
        integer totalParentAccounts = ECFMGTestFactory.BULKIFY_TESTS ? 100 : 2;
        integer totalCustomersPerTopAccount = 2;
        
        //Create Account, Contact, Case, CV Case, Asset, CAT 
        System.runAs(setUpUser){
        
            for(Integer i=0; i < totalParentAccounts; i++){
                Account accountRec = (Account) make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(RecordTypeId = entityRTId));
                Contact contactRec = (Contact) make( ECFMGDefaultTestData.DefaultContactData.class, new Contact(FirstName = 'EpicApi', LastName = 'TESTContact' + i, Birthdate = Date.today()-100, Account = accountRec, RecordTypeId = applicantRTId, EPIC_ID__c = 'C-12345'+i));
                topLevelList.add(accountRec);
            }
        }

        List<Account> updateAccountList = [select Id,Entity_ID__c from Account];
        Integer i=0;
        for(Account a : [select Id,Entity_ID__c from Account]){
            Account updAccount = new Account();
            updAccount.Id = a.Id;
            updAccount.Entity_ID__c = 'ENT-000000'+i;
            i++;
            updateAccountList.add(updAccount);
        }

        update updateAccountList;

        System.assertEquals(totalParentAccounts, topLevelList.size(), 'Top level group accounts not generated');
        run(); 

        List<Task> taskList = new List<Task>();
        List<Contact> contactList = [select Id, AccountId from Contact where AccountId IN: topLevelList];
        for (Contact contactRec : contactList) {
            for (Integer j=0; j < totalCustomersPerTopAccount; j++) {
                Case parentCVCase = (Case) make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Service__c = 'EPIC', RecordTypeId = caseCVRTId, Entity__c = contactRec.AccountId, Contact = contactRec, Internal_Status__c = 'CV Accepted'));
                Case caseRec = (Case) make(ECFMGDefaultTestData.DefaultCaseData.class, 
                    new Case(RecordTypeId = caseEpicReportRTId, Entity__c = contactRec.AccountId, Contact = contactRec, Secondary_Parent_Case__c = parentCVCase.Id,
                    Internal_Status__c = 'Sent',EPIC_Report_Status__c = 'Report Sent', EPIC_Report_Received_Date__c = Date.Today(), Document_Type__c = 'Specialist Qualification'));
                Asset assetRec = (Asset) make(ECFMGDefaultTestData.DefaultAssest.class, 
                    new Asset(Name='Final Medical Diploma', Azure_Storage_URL__c = 'https://Someurl.com', Status = 'Accepted',
                        Case__c = parentCVCase.Id, Contact = contactRec, Source_Document__c = true, Name_on_Document__c = 'TestDocument'));
            
                Task newRec = new Task(Application_ID__c = '987654321', Application_Status__c = 'TestStatus', Client_Name__c = topLevelList[0].Id);
                taskList.add(newRec);

                System.debug('Contact Record +++ ' + contactRec);
                System.debug('parentCVCase Record +++ ' + parentCVCase);
                System.debug('caseRec Record +++ ' + caseRec);
                System.debug('assetRec Record +++ ' + assetRec);
            }
        }
        run();
        
        if(taskList.size() > 0){
            Insert taskList;
        }
    }

    @IsTest
    static void testgetApplicantsPositive(){
        setDefaultContext();

        String strEntityId = null;
        String strEPICId = null;
        Date todayDate = System.Date.today()-100;
        Account account = [SELECT id, Entity_ID__c, Name FROM Account LIMIT 1];
        strEntityId = account.Entity_ID__c; 
        List<Contact> testContact = [SELECT EPIC_ID__c,ECFMG_ID__c,LastName,Name,Generational_Suffix__c,Birthdate,RecordType.Name,Account.Entity_ID__c FROM Contact WITH SECURITY_ENFORCED LIMIT 1];
        strEPICId = testContact[0].EPIC_ID__c;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/EPICApplicants?';//+'orgID='+strEntityId+'&statusDate='+strStatusDate;
        req.httpMethod = 'GET';
        req.params.put('orgID', strEntityId);
        req.params.put('ID', strEPICId);

        RestContext.request = req;
        RestContext.response= res; 
        Test.startTest();
        try{
            EPICRestApplicants.EPICApplicantWrap epicApplicantsWrap;// = new List<EPICRestApplicants.EPICApplicantWrap>();
            epicApplicantsWrap = EPICRestApplicants.getApplicants();
            System.debug('epicApplicantsWrap +++ ' + epicApplicantsWrap);

            System.assert(epicApplicantsWrap != null, 'epicApplicantsWrap is null');

        }catch(Exception e){
            System.debug('Error in testgetApplicantsPositive ++++ ' + e.getStackTraceString() + ', Message ++ ' + e.getMessage() + 
            ' ' + e.getCause());
        }   
        Test.stopTest();
    }

    @IsTest
    static void testgetApplicantsPositivewithECFMGID(){
        setDefaultContext();

        String strEntityId = null;
        String strECFMGId = null;
        Date todayDate = System.Date.today()-100;
        Account account = [SELECT id, Entity_ID__c, Name FROM Account LIMIT 1];
        strEntityId = account.Entity_ID__c; 
        List<Contact> testContact = [SELECT EPIC_ID__c,ECFMG_ID__c,LastName,Name,Generational_Suffix__c,Birthdate,RecordType.Name,Account.Entity_ID__c FROM Contact WITH SECURITY_ENFORCED LIMIT 1];
        strECFMGId = testContact[0].ECFMG_ID__c;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/EPICApplicants?';//+'orgID='+strEntityId+'&statusDate='+strStatusDate;
        req.httpMethod = 'GET';
        req.params.put('orgID', strEntityId);
        req.params.put('ID', strECFMGId);

        RestContext.request = req;
        RestContext.response= res; 
        Test.startTest();
        try{
            EPICRestApplicants.EPICApplicantWrap epicApplicantsWrap;// = new List<EPICRestApplicants.EPICApplicantWrap>();
            epicApplicantsWrap = EPICRestApplicants.getApplicants();
            System.debug('epicApplicantsWrap +++ ' + epicApplicantsWrap);

            System.assert(epicApplicantsWrap != null, 'epicApplicantsWrap is null');

        }catch(Exception e){
            System.debug('Error in testgetApplicantsPositive ++++ ' + e.getStackTraceString() + ', Message ++ ' + e.getMessage() + 
            ' ' + e.getCause());
        }   
        Test.stopTest();
    }

    @IsTest
    static void testgetApplicantsEPICisNull(){
        setDefaultContext();

        String strEntityId = null;
        String strEPICId = null;
        Date todayDate = System.Date.today();
        Account account = [SELECT id, Entity_ID__c, Name FROM Account LIMIT 1];
        strEntityId = account.Entity_ID__c; 
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/EPICApplicants?';//+'orgID='+strEntityId+'&statusDate='+strStatusDate;
        req.httpMethod = 'GET';
        req.params.put('orgID', strEntityId);
        req.params.put('ID', strEPICId);

        RestContext.request = req;
        RestContext.response= res; 
        Test.startTest();
        try{
            EPICRestApplicants.EPICApplicantWrap epicApplicantsWrap;// = new List<EPICRestApplicants.EPICApplicantWrap>();
            epicApplicantsWrap = EPICRestApplicants.getApplicants();
            System.debug('epicApplicantsWrap +++ ' + epicApplicantsWrap);

            System.assert(epicApplicantsWrap != null, 'epicApplicantsWrap is null');

        }catch(Exception e){
            System.debug('Error in testgetApplicantsEPICisNull ++++ ' + e.getStackTraceString() + ', Message ++ ' + e.getMessage() + 
            ' ' + e.getCause());
        }   
        Test.stopTest();
    }

    @IsTest
    static void testgetApplicantsEPICisInvalid(){
        setDefaultContext();

        String strEntityId = null;
        String strEPICId = '000000';//Dummy EPICID for Error
        Account account = [SELECT id, Entity_ID__c, Name FROM Account LIMIT 1];
        strEntityId = account.Entity_ID__c; 
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/EPICApplicants?';//+'orgID='+strEntityId+'&statusDate='+strStatusDate;
        req.httpMethod = 'GET';
        req.params.put('orgID', strEntityId);
        req.params.put('ID', strEPICId);

        RestContext.request = req;
        RestContext.response= res; 
        Test.startTest();
        try{
            EPICRestApplicants.EPICApplicantWrap epicApplicantsWrap;// = new List<EPICRestApplicants.EPICApplicantWrap>();
            epicApplicantsWrap = EPICRestApplicants.getApplicants();
            System.debug('epicApplicantsWrap +++ ' + epicApplicantsWrap);

            System.assert(epicApplicantsWrap != null, 'epicApplicantsWrap is null');

        }catch(Exception e){
            System.debug('Error in testgetApplicantsEPICisInvalid ++++ ' + e.getStackTraceString() + ', Message ++ ' + e.getMessage() + 
            ' ' + e.getCause());
        }   
        Test.stopTest();
    }


    @IsTest
    static void testPOSTApplicantStatusPositive(){
        setDefaultContext();

        String strEntityId = null;
        String strEPICId = null;
        Date todayDate = System.Date.today()-100;
        String applicationStatusDate = todayDate.month() + '/' + todayDate.day() + '/' + todayDate.year();
        Account account = [SELECT id, Entity_ID__c, Name FROM Account LIMIT 1];
        strEntityId = account.Entity_ID__c; 
        List<Contact> testContact = [SELECT EPIC_ID__c,ECFMG_ID__c,LastName,Name,Generational_Suffix__c,Birthdate,RecordType.Name,Account.Entity_ID__c FROM Contact WITH SECURITY_ENFORCED LIMIT 1];
        strEPICId = testContact[0].EPIC_ID__c;
        EPICRestApplicants.EPICPostRequestWrap reqWrap = new EPICRestApplicants.EPICPostRequestWrap();
        reqWrap.orgID = strEntityId;
        reqWrap.applicationID = '123456789';
        reqWrap.applicationStatus = 'TestStatus';
        reqWrap.applicationStatusDate = applicationStatusDate;
        reqWrap.applicationType = 'TestType';
        reqWrap.ID = strEPICId;
    
        String requestBodyStr = JSON.serialize(reqWrap);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/EPICApplicants?';//+'orgID='+strEntityId+'&statusDate='+strStatusDate;
        req.requestBody = Blob.valueOf(requestBodyStr);
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response= res; 
        Test.startTest();
        try{
            EPICRestApplicants.ResponseWrp epicApplicantsWrap;// = new List<EPICRestApplicants.EPICApplicantWrap>();
            epicApplicantsWrap = EPICRestApplicants.createActivity();
            System.debug('epicApplicantsWrap +++ ' + epicApplicantsWrap);

            System.assert(epicApplicantsWrap != null, 'epicApplicantsWrap is null');

        }catch(Exception e){
            System.debug('Error in testPOSTApplicantStatusPositive  ++++ ' + e.getStackTraceString() + ', Message ++ ' + e.getMessage() + 
            ' ' + e.getCause());
        }   
        Test.stopTest();
    }

    @IsTest
    static void testPOSTInvalidInput(){
        setDefaultContext();

        String strEntityId = null;
        String strEPICId = null;
        Date todayDate = System.Date.today()-100;
        String applicationStatusDate = todayDate.month() + '/' + todayDate.day() + '/' + todayDate.year();
        Account account = [SELECT id, Entity_ID__c, Name FROM Account LIMIT 1];
        strEntityId = account.Entity_ID__c; 
        List<Contact> testContact = [SELECT EPIC_ID__c,ECFMG_ID__c,LastName,Name,Generational_Suffix__c,Birthdate,RecordType.Name,Account.Entity_ID__c FROM Contact WITH SECURITY_ENFORCED LIMIT 1];
        strEPICId = testContact[0].EPIC_ID__c;
        EPICRestApplicants.EPICPostRequestWrap reqWrap = new EPICRestApplicants.EPICPostRequestWrap();
        String requestBodyStr = JSON.serialize(reqWrap);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/EPICApplicants?';//+'orgID='+strEntityId+'&statusDate='+strStatusDate;
        //req.requestBody = Blob.valueOf(requestBodyStr);
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response= res; 
        Test.startTest();
        try{
            EPICRestApplicants.ResponseWrp epicApplicantsWrap;// = new List<EPICRestApplicants.EPICApplicantWrap>();
            epicApplicantsWrap = EPICRestApplicants.createActivity();
            System.debug('epicApplicantsWrap +++ ' + epicApplicantsWrap);

            System.assert(epicApplicantsWrap != null, 'epicApplicantsWrap is null');

        }catch(Exception e){
            System.debug('Error in testPOSTInvalidInput ++++ ' + e.getStackTraceString() + ', Message ++ ' + e.getMessage() + 
            ' ' + e.getCause());
        }   
        Test.stopTest();
    }

    @IsTest
    static void testPOSTSameApplicationStatus(){
        setDefaultContext();

        String strEntityId = null;
        String strEPICId = null;
        Date todayDate = System.Date.today()-100;
        String applicationStatusDate = todayDate.month() + '/' + todayDate.day() + '/' + todayDate.year();
        List<Contact> testContact = [SELECT EPIC_ID__c,ECFMG_ID__c,LastName,Name,Generational_Suffix__c,Birthdate,RecordType.Name,Account.Entity_ID__c FROM Contact WITH SECURITY_ENFORCED LIMIT 1];
        strEPICId = testContact[0].EPIC_ID__c;
        EPICRestApplicants.EPICPostRequestWrap reqWrap = new EPICRestApplicants.EPICPostRequestWrap();
        reqWrap.orgID = strEntityId;
        reqWrap.applicationID = '987654321';
        reqWrap.applicationStatus = 'TestStatus';
        reqWrap.applicationStatusDate = applicationStatusDate;
        reqWrap.applicationType = 'TestType';
        reqWrap.ID = strEPICId;
    
        String requestBodyStr = JSON.serialize(reqWrap);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/EPICApplicants?';//+'orgID='+strEntityId+'&statusDate='+strStatusDate;
        req.requestBody = Blob.valueOf(requestBodyStr);
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response= res; 
        Test.startTest();
        try{
            EPICRestApplicants.ResponseWrp epicApplicantsWrap;// = new List<EPICRestApplicants.EPICApplicantWrap>();
            epicApplicantsWrap = EPICRestApplicants.createActivity();
            System.debug('epicApplicantsWrap +++ ' + epicApplicantsWrap);

            System.assert(epicApplicantsWrap != null, 'epicApplicantsWrap is null');

        }catch(Exception e){
            System.debug('Error in testPOSTSameApplicationStatus  ++++ ' + e.getStackTraceString() + ', Message ++ ' + e.getMessage() + 
            ' ' + e.getCause());
        }   
        Test.stopTest();
    }

    @IsTest
    static void testPOSTDifferentApplicationStatus(){
        setDefaultContext();

        String strEntityId = null;
        String strEPICId = null;
        Date todayDate = System.Date.today()-100;
        String applicationStatusDate = todayDate.month() + '/' + todayDate.day() + '/' + todayDate.year();
        Account account = [SELECT id, Entity_ID__c, Name FROM Account LIMIT 1];
        strEntityId = account.Entity_ID__c; 
        List<Contact> testContact = [SELECT EPIC_ID__c,ECFMG_ID__c,LastName,Name,Generational_Suffix__c,Birthdate,RecordType.Name,Account.Entity_ID__c FROM Contact WITH SECURITY_ENFORCED LIMIT 1];
        strEPICId = testContact[0].EPIC_ID__c;
        EPICRestApplicants.EPICPostRequestWrap reqWrap = new EPICRestApplicants.EPICPostRequestWrap();
        reqWrap.orgID = strEntityId;
        reqWrap.applicationID = '987654321';
        reqWrap.applicationStatus = 'TestStatusChanged';
        reqWrap.applicationStatusDate = applicationStatusDate;
        reqWrap.applicationType = 'TestType';
        reqWrap.ID = strEPICId;
    
        String requestBodyStr = JSON.serialize(reqWrap);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/EPICApplicants?';//+'orgID='+strEntityId+'&statusDate='+strStatusDate;
        req.requestBody = Blob.valueOf(requestBodyStr);
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response= res; 
        Test.startTest();
        try{
            EPICRestApplicants.ResponseWrp epicApplicantsWrap;// = new List<EPICRestApplicants.EPICApplicantWrap>();
            epicApplicantsWrap = EPICRestApplicants.createActivity();
            System.debug('epicApplicantsWrap +++ ' + epicApplicantsWrap);

            System.assert(epicApplicantsWrap != null, 'epicApplicantsWrap is null');

        }catch(Exception e){
            System.debug('Error in testPOSTDifferentApplicationStatus  ++++ ' + e.getStackTraceString() + ', Message ++ ' + e.getMessage() + 
            ' ' + e.getCause());
        }   
        Test.stopTest();
    }

    @IsTest
    static void testPOSTOrgIDisNull(){
        setDefaultContext();

        String strEntityId = null;
        String strEPICId = null;
        Date todayDate = System.Date.today()-100;
        String applicationStatusDate = todayDate.month() + '/' + todayDate.day() + '/' + todayDate.year();
        Account account = [SELECT id, Entity_ID__c, Name FROM Account LIMIT 1];
        strEntityId = account.Entity_ID__c; 
        List<Contact> testContact = [SELECT EPIC_ID__c,ECFMG_ID__c,LastName,Name,Generational_Suffix__c,Birthdate,RecordType.Name,Account.Entity_ID__c FROM Contact WITH SECURITY_ENFORCED LIMIT 1];
        strEPICId = testContact[0].EPIC_ID__c;
        EPICRestApplicants.EPICPostRequestWrap reqWrap = new EPICRestApplicants.EPICPostRequestWrap();
        reqWrap.orgID = '';
        reqWrap.applicationID = '987654321';
        reqWrap.applicationStatus = 'TestStatusChanged';
        reqWrap.applicationStatusDate = applicationStatusDate;
        reqWrap.applicationType = 'TestType';
        reqWrap.ID = strEPICId;
    
        String requestBodyStr = JSON.serialize(reqWrap);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/EPICApplicants?';//+'orgID='+strEntityId+'&statusDate='+strStatusDate;
        req.requestBody = Blob.valueOf(requestBodyStr);
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response= res; 
        Test.startTest();
        try{
            EPICRestApplicants.ResponseWrp epicApplicantsWrap;// = new List<EPICRestApplicants.EPICApplicantWrap>();
            epicApplicantsWrap = EPICRestApplicants.createActivity();
            System.debug('epicApplicantsWrap +++ ' + epicApplicantsWrap);

            System.assert(epicApplicantsWrap != null, 'epicApplicantsWrap is null');

        }catch(Exception e){
            System.debug('Error in testPOSTOrgIDisNull  ++++ ' + e.getStackTraceString() + ', Message ++ ' + e.getMessage() + 
            ' ' + e.getCause());
        }   
        Test.stopTest();
    }

}