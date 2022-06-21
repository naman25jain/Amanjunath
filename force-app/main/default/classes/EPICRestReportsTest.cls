/*
    Createdby       : Pradeep Kumar
    CreatedDate     : 12/09/2021
    Story           : EPIC Reports test Class with code coverage 
*/
@isTest
public class EPICRestReportsTest extends ECFMGTestFactory {

    private static CurrentEntityIDSequence__c settingsInstance;
    EPICRestReports.EpicReportWrap epic = new EPICRestReports.EpicReportWrap();
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
                Contact contactRec = (Contact) make( ECFMGDefaultTestData.DefaultContactData.class, new Contact(FirstName = 'EpicApi', LastName = 'TESTContact' + i, Birthdate = Date.today()-365, Account = accountRec, RecordTypeId = applicantRTId, EPIC_ID__c = 'C-12345'+i));
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

        List<Contact> contactList = [select Id, AccountId from Contact where AccountId IN: topLevelList];
        /* cadmus_core__Doc_Config__c cad= new cadmus_core__Doc_Config__c();
        cad.recordTypeId= Constants.EPICVERREPORTREQRTID;
           cad.Name='ABC';
        cad.cadmus_core__CustomerDocumentConfigId__c=Constants.DOCCONFIG_EPIC_VERIFICATION_REPORT;
        //insert cad;
        run();*/
        for (Contact contactRec : contactList) {
            for (Integer j=0; j < totalCustomersPerTopAccount; j++) {
                Case parentCVCase = (Case) make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Service__c = 'EPIC', RecordTypeId = caseCVRTId, Entity__c = contactRec.AccountId, Contact = contactRec, Internal_Status__c = 'CV Accepted'));
              // run(); 
                Case caseRec = (Case) make(ECFMGDefaultTestData.DefaultCaseData.class, 
                    new Case(RecordTypeId = caseEpicReportRTId, Entity__c = contactRec.AccountId, Contact = contactRec, Secondary_Parent_Case__c = parentCVCase.Id, EPIC_Report_Archived_Status__c = true,
                    Internal_Status__c = 'Sent',EPIC_Report_Status__c = 'Report Sent', EPIC_Report_Received_Date__c = Date.Today(), Document_Type__c = 'Specialist Qualification'));
         
                Case caseRec2 = (Case) make(ECFMGDefaultTestData.DefaultCaseData.class, 
                    new Case(RecordTypeId = caseEpicReportRTId, Entity__c = contactRec.AccountId, Contact = contactRec, Secondary_Parent_Case__c = parentCVCase.Id, EPIC_Report_Archived_Status__c = true,
                    Internal_Status__c = 'Sent',EPIC_Report_Status__c = 'Report Sent', EPIC_Report_Received_Date__c = Date.Today(), Document_Type__c = 'Specialist Qualification'));
                
                               Asset assetRec = (Asset) make(ECFMGDefaultTestData.DefaultAssest.class, 
                    new Asset(Name='Final Medical Diploma', Azure_Storage_URL__c = 'https://Someurl.com', Status = 'Accepted',
                        Case__c = parentCVCase.Id, Contact = contactRec, Source_Document__c = true, Name_on_Document__c = 'TestDocument'));
               
                   Asset assetRec2 = (Asset) make(ECFMGDefaultTestData.DefaultAssest.class, 
                    new Asset(Name='Alternate Graduation Document', Azure_Storage_URL__c = 'https://Someurl.com', Status = 'Accepted',
                        Case__c = parentCVCase.Id, Contact = contactRec, Source_Document__c = true, Name_on_Document__c = 'TestDocument'));                         
                
                Asset assetRec3 = (Asset) make(ECFMGDefaultTestData.DefaultAssest.class, 
                    new Asset(Name='Final Medical School Transcript', Azure_Storage_URL__c = 'https://Someurl.com', Status = 'Accepted',
                        Case__c = parentCVCase.Id, Contact = contactRec, Source_Document__c = true, Name_on_Document__c = 'TestDocument'));                         
                
                
                Contact_Association_Type__c catRec = (Contact_Association_Type__c) make(ECFMGDefaultTestData.DefaultContactAssociationTestData.class,
                    new Contact_Association_Type__c(Account__c = contactRec.AccountId, Contact__c = contactRec.Id, Case__c = parentCVCase.Id, Credential_Type__c = 'Final Medical Diploma'));
                Contact_Association_Type_Staging__c catsRec = (Contact_Association_Type_Staging__c) make(ECFMGDefaultTestData.DefaultContactAssociationStagingTestData.class,
                    new Contact_Association_Type_Staging__c(Account__c = contactRec.AccountId, Contact__c = contactRec.Id, Case__c = parentCVCase.Id, Credential_Type__c = 'Final Medical Diploma'));
                
                 Contact_Association_Type_Staging__c catsRec1 = (Contact_Association_Type_Staging__c) make(ECFMGDefaultTestData.DefaultContactAssociationStagingTestData.class,
                    new Contact_Association_Type_Staging__c(Account__c = contactRec.AccountId, Contact__c = contactRec.Id, Case__c = parentCVCase.Id, Credential_Type__c = 'Alternate Graduation Document'));
                
                 Contact_Association_Type_Staging__c catsRec2 = (Contact_Association_Type_Staging__c) make(ECFMGDefaultTestData.DefaultContactAssociationStagingTestData.class,
                    new Contact_Association_Type_Staging__c(Account__c = contactRec.AccountId, Contact__c = contactRec.Id, Case__c = parentCVCase.Id, Credential_Type__c = 'Final Medical School Transcript'));
                
                 Contact_Association_Type_Staging__c catsRec3 = (Contact_Association_Type_Staging__c) make(ECFMGDefaultTestData.DefaultContactAssociationStagingTestData.class,
                    new Contact_Association_Type_Staging__c(Account__c = contactRec.AccountId, Contact__c = contactRec.Id, Case__c = parentCVCase.Id, Credential_Type__c = 'Student Medical School Transcript'));
                
                 Contact_Association_Type_Staging__c catsRec4 = (Contact_Association_Type_Staging__c) make(ECFMGDefaultTestData.DefaultContactAssociationStagingTestData.class,
                    new Contact_Association_Type_Staging__c(Account__c = contactRec.AccountId, Contact__c = contactRec.Id, Case__c = parentCVCase.Id, Credential_Type__c = 'Postgraduate Training Credential'));
                
                 Contact_Association_Type_Staging__c catsRec5 = (Contact_Association_Type_Staging__c) make(ECFMGDefaultTestData.DefaultContactAssociationStagingTestData.class,
                    new Contact_Association_Type_Staging__c(Account__c = contactRec.AccountId, Contact__c = contactRec.Id, Case__c = parentCVCase.Id, Credential_Type__c = 'Specialist Qualification'));
                
                
                System.debug('Contact Record +++ ' + contactRec);
                System.debug('parentCVCase Record +++ ' + parentCVCase);
                System.debug('caseRec Record +++ ' + caseRec);
                System.debug('assetRec Record +++ ' + assetRec);
                System.debug('catRec +++ ' + catRec);
            }
        }
        run(); 
    }

    @IsTest
    static void testgetReportsPositive(){
        setDefaultContext();
         
         List<Contact_Association_Type__c> catList = [select Id,Case__c,Parent_Case__c,Attendance_Start_Date__c,Attendance_End_Date__c,Expiration_Date__c,
        Degree_Issue_Year__c,Degree_Title__c,Name_on_Document__c,Credential_Type__c,Case__r.Contact.EPIC_ID__c,Case__r.Document_Type__c,Issue_Date__c,Title__c,
        Degree_expected_to_be_issued_Month__c,Degree_expected_to_be_issued_Year__c,Program_Start_Date__c,Program_End_Date__c,School_Program__c
        from Contact_Association_Type__c];
        Map<Id, Id> M1= New Map<Id, Id>();
        For(Contact_Association_Type__c cList:catList){
            M1.Put(cList.case__c,cList.case__c);
            
        }
        
      
        EPICRestReports.getDocumentDetails(M1);
        
        List<String> documentNames = new List<String>();
        documentNames = EPICRestReports.fetchDocumentDetailsNames('Final Medical Diploma');
        System.assert(documentNames.size() > 0, 'DocumentNames is null');
        documentNames = EPICRestReports.fetchDocumentDetailsNames('Alternate Graduation Document');
        System.assert(documentNames.size() > 0, 'DocumentNames is null');
        documentNames = EPICRestReports.fetchDocumentDetailsNames('Final Medical School Transcript');
        System.assert(documentNames.size() > 0, 'DocumentNames is null');
        documentNames = EPICRestReports.fetchDocumentDetailsNames('Student Medical School Transcript');
        System.assert(documentNames.size() > 0, 'DocumentNames is null');
        documentNames = EPICRestReports.fetchDocumentDetailsNames('Postgraduate Training Credential');
        System.assert(documentNames.size() > 0, 'DocumentNames is null');
        documentNames = EPICRestReports.fetchDocumentDetailsNames('Specialist Qualification');
        System.assert(documentNames.size() > 0, 'DocumentNames is null');
        documentNames = EPICRestReports.fetchDocumentDetailsNames('Medical Registration Certificate/License to Practice Medicine');
        System.assert(documentNames.size() > 0, 'DocumentNames is null');
        documentNames = EPICRestReports.fetchDocumentDetailsNames('No Credential Name');
        System.assert(documentNames.size() > 0, 'DocumentNames is null');
        
        List <String> docname = new List<String>{'Degree expected to be issued Year','Expiration Date','Program Start Date','Program End Date','Program Name', 'Issue Date'};
        documentNames =  docname;

        Account account = [SELECT id, Entity_ID__c, Name FROM Account LIMIT 1];
        String strEntityId = account.Entity_ID__c;   
        List<Contact> testContact = [SELECT EPIC_ID__c,ECFMG_ID__c,LastName,Name,Generational_Suffix__c,Birthdate,RecordType.Name,Account.Entity_ID__c FROM Contact WITH SECURITY_ENFORCED LIMIT 1];
        String strEPICId = testContact[0].EPIC_ID__c;
        
        List<Case> caseRecList = [select id, Secondary_Parent_Case__c, Entity__r.Entity_ID__c from Case];
        
        
        System.assert(caseRecList.size() > 0, 'No records returned');
        System.debug('Case REcord List +++ ' + caseRecList);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/EPICReports?';//+'orgID='+strEntityId+'&epicID='+strEPICId;
        req.httpMethod = 'GET';
        req.params.put('orgID', strEntityId);
        req.params.put('ID', strEPICId);
        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        try {
            List<EPICRestReports.EpicReportWrap> epicReportWrapList;// = new List<EPICRestCredentials.EPICCredentialsWrap>();
            epicReportWrapList = EPICRestReports.getEPICReports();
            System.debug('epicReportWrapList +++ ' + epicReportWrapList);
            System.assert(epicReportWrapList.size() > 0, 'ResponseBody is null');
        } catch (Exception e) {
            System.debug('Error in testgetReportsPositive ++++ ' + e.getStackTraceString() + ', Message ++ ' + e.getMessage());
        }
        Test.stopTest(); 
    }

     @IsTest
    static void testCopy(){
        setDefaultContext();
         
         List<Contact_Association_Type__c> catList = [select Id,Case__c,Parent_Case__c,Attendance_Start_Date__c,Attendance_End_Date__c,Expiration_Date__c,
        Degree_Issue_Year__c,Degree_Title__c,Name_on_Document__c,Credential_Type__c,Case__r.Contact.EPIC_ID__c,Case__r.Document_Type__c,Issue_Date__c,Title__c,
        Degree_expected_to_be_issued_Month__c,Degree_expected_to_be_issued_Year__c,Program_Start_Date__c,Program_End_Date__c,School_Program__c
        from Contact_Association_Type__c];
       
        Map<Id, Id> M1= New Map<Id, Id>();
        For(Contact_Association_Type__c cList:catList){
            system.debug('cList.case__c :'+ cList.case__c);
            
            M1.Put(cList.case__c,cList.case__c);
            
        }
        
      
        EPICRestReports.getDocumentDetails(M1);
        
       
    }

    
    @IsTest
    static void testgetReportsPositiveWithCATS(){
        setDefaultContext();
        
        List<String> documentNames = new List<String>();
        documentNames = EPICRestReports.fetchDocumentDetailsNames('Final Medical Diploma');
        System.assert(documentNames.size() > 0, 'DocumentNames is null');
        documentNames = EPICRestReports.fetchDocumentDetailsNames('Alternate Graduation Document');
        System.assert(documentNames.size() > 0, 'DocumentNames is null');
        documentNames = EPICRestReports.fetchDocumentDetailsNames('Final Medical School Transcript');
        System.assert(documentNames.size() > 0, 'DocumentNames is null');
        documentNames = EPICRestReports.fetchDocumentDetailsNames('Student Medical School Transcript');
        System.assert(documentNames.size() > 0, 'DocumentNames is null');
        documentNames = EPICRestReports.fetchDocumentDetailsNames('Postgraduate Training Credential');
        System.assert(documentNames.size() > 0, 'DocumentNames is null');
        documentNames = EPICRestReports.fetchDocumentDetailsNames('Specialist Qualification');
        System.assert(documentNames.size() > 0, 'DocumentNames is null');
        documentNames = EPICRestReports.fetchDocumentDetailsNames('Medical Registration Certificate/License to Practice Medicine');
        System.assert(documentNames.size() > 0, 'DocumentNames is null');
        documentNames = EPICRestReports.fetchDocumentDetailsNames('No Credential Name');
        System.assert(documentNames.size() > 0, 'DocumentNames is null');

        Account account = [SELECT id, Entity_ID__c, Name FROM Account LIMIT 1];
        String strEntityId = account.Entity_ID__c;   
        List<Contact> testContact = [SELECT EPIC_ID__c,ECFMG_ID__c,LastName,Name,Generational_Suffix__c,Birthdate,RecordType.Name,Account.Entity_ID__c FROM Contact WITH SECURITY_ENFORCED LIMIT 1];
        String strEPICId = testContact[0].EPIC_ID__c;
        List<Case> caseRecList = [select  Entity__r.Entity_ID__c from Case];
        System.assert(caseRecList.size() > 0, 'No records returned');
        List<Contact_Association_Type__c> catList = [select Id from Contact_Association_Type__c];
        delete catList;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/EPICReports?';//+'orgID='+strEntityId+'&epicID='+strEPICId;
        req.httpMethod = 'GET';
        req.params.put('orgID', strEntityId);
        req.params.put('ID', strEPICId);
        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        try {
            List<EPICRestReports.EpicReportWrap> epicReportWrapList;// = new List<EPICRestCredentials.EPICCredentialsWrap>();
            epicReportWrapList = EPICRestReports.getEPICReports();
            System.debug('epicReportWrapList +++ ' + epicReportWrapList);
            System.assert(epicReportWrapList.size() > 0, 'ResponseBody is null');
        } catch (Exception e) {
            System.debug('Error in testgetReportsPositive ++++ ' + e.getStackTraceString() + ', Message ++ ' + e.getMessage());
        }
        Test.stopTest(); 
    }

    @IsTest
    static void testEntityIDNull(){
        setDefaultContext();

        String strEntityId = null;
        String strEPICId = null;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/EPICReports?';//+'orgID='+strEntityId+'&epicID='+strEPICId;
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response= res; 
        Test.startTest();
        try {
            List<EPICRestReports.EpicReportWrap> epicReportWrapList;// = new List<EPICRestCredentials.EPICCredentialsWrap>();
            epicReportWrapList = EPICRestReports.getEPICReports();
            System.debug('epicReportWrapList +++ ' + epicReportWrapList);
            System.assert(epicReportWrapList.size() > 0, 'ResponseBody is null');
        }catch(Exception e){
            System.debug('Error in testEntityIDNull ++++ ' + e.getStackTraceString() + ', Message ++ ' + e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void testEpicIDisNull(){
        setDefaultContext();

        String strEntityId = null;
        String strEPICId = '00000';//Dummy EPIC ID to test ContactList.size() == 0
        String strStatusDate = null;
        Account account = [SELECT id, Entity_ID__c, Name FROM Account LIMIT 1];
        strEntityId = account.Entity_ID__c; 
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/EPICReports?';//+'orgID='+strEntityId+'&epicID='+strEPICId;
        req.httpMethod = 'GET';
        req.params.put('orgID', strEntityId);
        req.params.put('ID', strEPICId);

        RestContext.request = req;
        RestContext.response= res; 
        Test.startTest();
        try {
            List<EPICRestReports.EpicReportWrap> epicReportWrapList;// = new List<EPICRestCredentials.EPICCredentialsWrap>();
            epicReportWrapList = EPICRestReports.getEPICReports();
            System.debug('epicReportWrapList +++ ' + epicReportWrapList);
            System.assert(epicReportWrapList.size() > 0, 'ResponseBody is null');
        }catch(Exception e){
            System.debug('Error in testEntityIDNull ++++ ' + e.getStackTraceString() + ', Message ++ ' + e.getMessage());
        } 
        Test.stopTest();
    }

    @IsTest
    static void testgetReportsByReportIDPositive(){
        setDefaultContext();
        
        Account account = [SELECT id, Entity_ID__c, Name FROM Account LIMIT 1];
        String strEntityId = account.Entity_ID__c;   
        List<Contact> testContact = [SELECT EPIC_ID__c,ECFMG_ID__c,LastName,Name,Generational_Suffix__c,Birthdate,RecordType.Name,Account.Entity_ID__c FROM Contact WITH SECURITY_ENFORCED LIMIT 1];
        String strEPICId = testContact[0].EPIC_ID__c;
        List<Case> caseRecList = [select  Id, CaseNumber, Entity__r.Entity_ID__c from Case where RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_EPIC_VER_REPORT_REQUEST];
        String strReportId = caseRecList[0].CaseNumber;
        System.debug('CaseNumber ++++ ' + strReportId);
        System.assert(caseRecList.size() > 0, 'No records returned');
        System.debug('Case REcord List +++ ' + caseRecList);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/EPICReports?';//+'orgID='+strEntityId+'&epicID='+strEPICId;
        req.httpMethod = 'GET';
        req.params.put('orgID', strEntityId);
        req.params.put('ID', strEPICId);
        req.params.put('reportID', strReportId);
        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        try {
            List<EPICRestReports.EpicReportWrap> epicReportWrapList;// = new List<EPICRestCredentials.EPICCredentialsWrap>();
            epicReportWrapList = EPICRestReports.getEPICReports();
            System.debug('epicReportWrapList +++ ' + epicReportWrapList);
            System.assert(epicReportWrapList.size() > 0, 'ResponseBody is null');
        } catch (Exception e) {
            System.debug('Error in testgetReportsByReportIDPositive ++++ ' + e.getStackTraceString() + ', Message ++ ' + e.getMessage());
        }
        Test.stopTest(); 
    }

    @IsTest
    static void testisArchivedisNotNull(){
        setDefaultContext();
        
        Account account = [SELECT id, Entity_ID__c, Name FROM Account LIMIT 1];
        String strEntityId = account.Entity_ID__c;   
        List<Contact> testContact = [SELECT EPIC_ID__c,ECFMG_ID__c,LastName,Name,Generational_Suffix__c,Birthdate,RecordType.Name,Account.Entity_ID__c FROM Contact WITH SECURITY_ENFORCED LIMIT 1];
        String strEPICId = testContact[0].EPIC_ID__c;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/EPICReports?';//+'orgID='+strEntityId+'&epicID='+strEPICId;
        req.httpMethod = 'GET';
        req.params.put('orgID', strEntityId);
        req.params.put('ID', strEPICId);
        req.params.put('isArchived', 'true');
        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        try {
            List<EPICRestReports.EpicReportWrap> epicReportWrapList;// = new List<EPICRestCredentials.EPICCredentialsWrap>();
            epicReportWrapList = EPICRestReports.getEPICReports();
            System.debug('epicReportWrapList +++ ' + epicReportWrapList);
            System.assert(epicReportWrapList.size() > 0, 'ResponseBody is null');
        } catch (Exception e) {
            System.debug('Error in testisArchivedisNotNull ++++ ' + e.getStackTraceString() + ', Message ++ ' + e.getMessage());
        }
        Test.stopTest(); 
    }

    @IsTest
    static void teststartandEndDateAreNotNull(){
        setDefaultContext();
        
        Account account = [SELECT id, Entity_ID__c, Name FROM Account LIMIT 1];
        String strEntityId = account.Entity_ID__c;   
        List<Contact> testContact = [SELECT EPIC_ID__c,ECFMG_ID__c,LastName,Name,Generational_Suffix__c,Birthdate,RecordType.Name,Account.Entity_ID__c FROM Contact WITH SECURITY_ENFORCED LIMIT 1];
        String strEPICId = testContact[0].EPIC_ID__c;
        Date todayDate = Date.today();
        String strStartDate = todayDate.month() + '/' + todayDate.day() + '/' + todayDate.year();
        String strEndDate = todayDate.month() + '/' + todayDate.day() + '/' + todayDate.year();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/EPICReports?';//+'orgID='+strEntityId+'&epicID='+strEPICId;
        req.httpMethod = 'GET';
        req.params.put('orgID', strEntityId);
        req.params.put('ID', strEPICId);
        req.params.put('startDate', strStartDate);
        req.params.put('endDate', strEndDate);
        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        try {
            List<EPICRestReports.EpicReportWrap> epicReportWrapList;// = new List<EPICRestCredentials.EPICCredentialsWrap>();
            epicReportWrapList = EPICRestReports.getEPICReports();
            System.debug('epicReportWrapList +++ ' + epicReportWrapList);
            System.assert(epicReportWrapList.size() > 0, 'ResponseBody is null');
        } catch (Exception e) {
            System.debug('Error in teststartandEndDateAreNotNull ++++ ' + e.getStackTraceString() + ', Message ++ ' + e.getMessage());
        }
        Test.stopTest(); 
    }

    @IsTest
    static void testUpdateArchivePositive(){
        setDefaultContext();
        
        Account account = [SELECT id, Entity_ID__c, Name FROM Account LIMIT 1];
        String strEntityId = account.Entity_ID__c;   
        List<Contact> testContact = [SELECT EPIC_ID__c,ECFMG_ID__c,LastName,Name,Generational_Suffix__c,Birthdate,RecordType.Name,Account.Entity_ID__c FROM Contact WITH SECURITY_ENFORCED LIMIT 1];
        String strEPICId = testContact[0].EPIC_ID__c;
        List<Case> caseRecList = [select  Id, CaseNumber, Entity__r.Entity_ID__c from Case where RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_EPIC_VER_REPORT_REQUEST];
        String strReportId = caseRecList[0].CaseNumber;
        Boolean isArchived = false;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/EPICReports?';//+'orgID='+strEntityId+'&epicID='+strEPICId;
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        try {
            EPICRestReports.PostResponse epicReportPostWrap;// = new List<EPICRestCredentials.EPICCredentialsWrap>();
            epicReportPostWrap = EPICRestReports.updateArchive(strEntityId, strReportId, isArchived);
            System.debug('epicReportPostWrap +++ ' + epicReportPostWrap);
            System.assert(epicReportPostWrap != null, 'ResponseBody is null');
        } catch (Exception e) {
            System.debug('Error in testUpdateArchive ++++ ' + e.getStackTraceString() + ', Message ++ ' + e.getMessage());
        }
        Test.stopTest(); 
    }

    @IsTest
    static void testUpdateArchiveNoRecordsFound(){
        setDefaultContext();
        
        Account account = [SELECT id, Entity_ID__c, Name FROM Account LIMIT 1];
        String strEntityId = 'ENT-9999';   
        List<Contact> testContact = [SELECT EPIC_ID__c,ECFMG_ID__c,LastName,Name,Generational_Suffix__c,Birthdate,RecordType.Name,Account.Entity_ID__c FROM Contact WITH SECURITY_ENFORCED LIMIT 1];
        String strEPICId = testContact[0].EPIC_ID__c;
        List<Case> caseRecList = [select  Id, CaseNumber, Entity__r.Entity_ID__c from Case];
        String strReportId = caseRecList[0].CaseNumber;
        Boolean isArchived = false;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/EPICReports?';//+'orgID='+strEntityId+'&epicID='+strEPICId;
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        try {
            EPICRestReports.PostResponse epicReportPostWrap;// = new List<EPICRestCredentials.EPICCredentialsWrap>();
            epicReportPostWrap = EPICRestReports.updateArchive(strEntityId, strReportId, isArchived);
            System.debug('epicReportPostWrap +++ ' + epicReportPostWrap);
            System.assert(epicReportPostWrap != null, 'ResponseBody is null');
        } catch (Exception e) {
            System.debug('Error in testUpdateArchive ++++ ' + e.getStackTraceString() + ', Message ++ ' + e.getMessage() + ' , Cause ++ ' + e.getCause());
        }
        Test.stopTest(); 
    }
 @IsTest
    static void testgetEPICReportsfalse(){
        setDefaultContext();
        
        Account account = [SELECT id, Entity_ID__c, Name FROM Account LIMIT 1];
        String strEntityId = 'ENT-9999';   
        List<Contact> testContact = [SELECT EPIC_ID__c,ECFMG_ID__c,LastName,Name,Generational_Suffix__c,Birthdate,RecordType.Name,Account.Entity_ID__c FROM Contact WITH SECURITY_ENFORCED LIMIT 1];
        String strEPICId = testContact[0].EPIC_ID__c;
        List<Case> caseRecList = [select  Id, CaseNumber, Entity__r.Entity_ID__c from Case];
        String strReportId = caseRecList[0].CaseNumber;
        Boolean isArchived = false;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/EPICReports?';//+'orgID='+strEntityId+'&epicID='+strEPICId;
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        
        List<Case> caseList = new List<Case>();
        
        Test.startTest();
        EPICRestReports.getEPICReports(caseList);
        Test.stopTest(); 
    }

}