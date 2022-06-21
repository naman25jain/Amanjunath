/*
    Createdby       : Pradeep Kumar
    CreatedDate     : 12/09/2021
    Story           : EPIC Credentials Test Class with code coverage
*/
@isTest
public class EPICRestCredentialsTest extends ECFMGTestFactory {
    private static CurrentEntityIDSequence__c settingsInstance;
    static{
        CurrentEntityIDSequence__c settingsInstance = CurrentEntityIDSequence__c.getOrgDefaults();
        settingsInstance.Entity_ID__c = '0000000';
        upsert settingsInstance;
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
        for (Contact contactRec : contactList) {
            for (Integer j=0; j < totalCustomersPerTopAccount; j++) {
                Case parentCVCase = (Case) make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Service__c = 'EPIC', RecordTypeId = caseCVRTId, Entity__c = contactRec.AccountId, Contact = contactRec, Internal_Status__c = 'CV Accepted'));
                Case caseRec = (Case) make(ECFMGDefaultTestData.DefaultCaseData.class, 
                    new Case(RecordTypeId = caseEpicReportRTId, Entity__c = contactRec.AccountId, Contact = contactRec, Secondary_Parent_Case__c = parentCVCase.Id,
                    Internal_Status__c = 'Sent',EPIC_Report_Status__c = 'Report Sent', EPIC_Report_Received_Date__c = Date.Today(), Document_Type__c = 'Specialist Qualification'));
                Asset assetRec = (Asset) make(ECFMGDefaultTestData.DefaultAssest.class, 
                    new Asset(Name='Final Medical Diploma', Azure_Storage_URL__c = 'https://Someurl.com', Status = 'Accepted',
                        Case__c = parentCVCase.Id, Contact = contactRec, Source_Document__c = true, Name_on_Document__c = 'TestDocument'));
            
                System.debug('Contact Record +++ ' + contactRec);
                System.debug('parentCVCase Record +++ ' + parentCVCase);
                System.debug('caseRec Record +++ ' + caseRec);
                System.debug('assetRec Record +++ ' + assetRec);
            }
        }
        run(); 
    }

    @IsTest
    static void testEpicIDAndStatusDateNull(){
        setDefaultContext();

        String strEntityId = null;
        String strEPICId = null;
        String strStatusDate = null;
        Account account = [SELECT id, Entity_ID__c, Name FROM Account LIMIT 1];
        strEntityId = account.Entity_ID__c; 
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/EPICCredentials?';//+'orgID='+strEntityId+'&epicID='+strEPICId;
        req.httpMethod = 'GET';
        req.params.put('orgID', strEntityId);
        //req.params.put('ID', strEPICId);
        //req.params.put('statusDate', strStatusDate);

        RestContext.request = req;
        RestContext.response= res; 
        Test.startTest();
        try{
            List<EPICRestCredentials.EPICCredentialsWrap> epicCredentialsWrapList;// = new List<EPICRestCredentials.EPICCredentialsWrap>();
            epicCredentialsWrapList = EPICRestCredentials.getCredentialStatus();
            System.debug('epicCredentialsWrapList +++ ' + epicCredentialsWrapList);
            for(EPICRestCredentials.EPICCredentialsWrap respWrap : epicCredentialsWrapList){
                System.assertEquals(respWrap.errorCode, 'ERR-002', 'OrgID was passed so No Error');
            }

        }catch(Exception e){
            System.debug('Error in testEpicIDAndStatusDateNull ++++ ' + e.getStackTraceString() + ', Message ++ ' + e.getMessage());
        }   
        Test.stopTest();
    }
    
    @IsTest
    static void testStatusDateisNotNull(){
        setDefaultContext();

        String strEntityId = null;
        String strEPICId = null;
        Date todayDate = System.Date.today();
        String strStatusDate = todayDate.month() + '/' + todayDate.day() + '/' + todayDate.year();
        Account account = [SELECT id, Entity_ID__c, Name FROM Account LIMIT 1];
        strEntityId = account.Entity_ID__c; 
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/EPICCredentials?'+'orgID='+strEntityId+'&statusDate='+strStatusDate;
        req.httpMethod = 'GET';
        req.params.put('orgID', strEntityId);
        req.params.put('ID', strEPICId);
        req.params.put('statusDate', strStatusDate);

        RestContext.request = req;
        RestContext.response= res; 
        Test.startTest();
        try{
            List<EPICRestCredentials.EPICCredentialsWrap> epicCredentialsWrapList;// = new List<EPICRestCredentials.EPICCredentialsWrap>();
            epicCredentialsWrapList = EPICRestCredentials.getCredentialStatus();
            System.debug('epicCredentialsWrapList +++ ' + epicCredentialsWrapList);
            
            for(EPICRestCredentials.EPICCredentialsWrap respWrap : epicCredentialsWrapList){
                if(String.isNotBlank(respWrap.errorCode)){
                    System.assertEquals(respWrap.errorCode, '204', 'OrgID was passed so No Error');
                }else{
                    System.assertEquals(respWrap.errorCode, null, 'OrgID was passed so No Error');
                }
            }
        }catch(Exception e){
            System.debug('Error in StatusDate is not null ++++ ' + e.getStackTraceString() + ', Message ++ ' + e.getMessage() + 
                         ' ' + e.getCause());
        }   
        Test.stopTest();
    }

    @IsTest
    static void testgetCredentialStatusPositive(){
        setDefaultContext();
        
        Account account = [SELECT id, Entity_ID__c, Name FROM Account LIMIT 1];
        String strEntityId = account.Entity_ID__c;   
        List<Contact> testContact = [SELECT EPIC_ID__c,ECFMG_ID__c,LastName,Name,Generational_Suffix__c,Birthdate,RecordType.Name,Account.Entity_ID__c FROM Contact WITH SECURITY_ENFORCED LIMIT 1];
        String strECFMGId = testContact[0].ECFMG_ID__c;
        List<Case> caseRecList = [select  Entity__r.Entity_ID__c from Case];
        System.assert(caseRecList.size() > 0, 'No records returned');
        System.debug('Case REcord List +++ ' + caseRecList);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/EPICCredentials?';//+'orgID='+strEntityId+'&epicID='+strEPICId;
        req.httpMethod = 'GET';
        req.params.put('orgID', strEntityId);
        req.params.put('ID', strECFMGId);
        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
        try {
            List<EPICRestCredentials.EPICCredentialsWrap> epicCredentialsWrapList;// = new List<EPICRestCredentials.EPICCredentialsWrap>();
            epicCredentialsWrapList = EPICRestCredentials.getCredentialStatus();
            System.debug('epicCredentialsWrapList +++ ' + epicCredentialsWrapList);
            System.assert(epicCredentialsWrapList.size() > 0, 'ResponseBody is null');
        } catch (Exception e) {
            System.debug('Error in testgetCredentialStatusPositive ++++ ' + e.getStackTraceString() + ', Message ++ ' + e.getMessage());
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
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/EPICCredentials?';//+'orgID='+strEntityId+'&epicID='+strEPICId;
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response= res; 
        Test.startTest();
        try{
            List<EPICRestCredentials.EPICCredentialsWrap> epicCredentialsWrapList;// = new List<EPICRestCredentials.EPICCredentialsWrap>();
            epicCredentialsWrapList = EPICRestCredentials.getCredentials(null, null, null, null);
            System.debug('epicCredentialsWrapList +++ ' + epicCredentialsWrapList);
            for(EPICRestCredentials.EPICCredentialsWrap respWrap : epicCredentialsWrapList){
                System.assertEquals(respWrap.errorCode, 'ERR-001', 'OrgID was passed so No Error');
            }
        }catch(Exception e){
            System.debug('Error in testEntityIDNull ++++ ' + e.getStackTraceString() + ', Message ++ ' + e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void testInputDOB(){
        setDefaultContext();

        Date todayDate = Date.today();
        String strDOB = todayDate.month() + '/' + todayDate.day() + '/' + todayDate.year();
        Account account = [SELECT id, Entity_ID__c, Name FROM Account LIMIT 1];
        String strEntityId = account.Entity_ID__c;   
        List<Contact> testContact = [SELECT EPIC_ID__c,ECFMG_ID__c,LastName,Name,Generational_Suffix__c,Birthdate,RecordType.Name,Account.Entity_ID__c FROM Contact WITH SECURITY_ENFORCED LIMIT 1];
        String strEPICId = testContact[0].EPIC_ID__c;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/EPICCredentials?';//+'orgID='+strEntityId+'&epicID='+strEPICId;
        req.httpMethod = 'GET';
        req.params.put('orgID', strEntityId);
        req.params.put('ID', strEPICId);
        req.params.put('DOB', strDOB);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        try {
            List<EPICRestCredentials.EPICCredentialsWrap> epicCredentialsWrapList;// = new List<EPICRestCredentials.EPICCredentialsWrap>();
            epicCredentialsWrapList = EPICRestCredentials.getCredentialStatus();
            System.debug('epicCredentialsWrapList +++ ' + epicCredentialsWrapList);
            System.assert(epicCredentialsWrapList.size() > 0, 'ResponseBody is null');

        } catch (Exception e) {
            System.debug('Error in testInputDOB ++++ ' + e.getStackTraceString() + ', Message ++ ' + e.getMessage());
        } 
        Test.stopTest();
    }

    @IsTest
    static void testInputWrongDOB(){
        setDefaultContext();

        String strDOB = String.valueOf(Date.today()+30);
        Account account = [SELECT id, Entity_ID__c, Name FROM Account LIMIT 1];
        String strEntityId = account.Entity_ID__c;   
        List<Contact> testContact = [SELECT EPIC_ID__c,ECFMG_ID__c,LastName,Name,Generational_Suffix__c,Birthdate,RecordType.Name,Account.Entity_ID__c FROM Contact WITH SECURITY_ENFORCED LIMIT 1];
        String strEPICId = testContact[0].EPIC_ID__c;
        List<Asset> astRecList = [Select Id, Name from Asset ];
        List<Asset> updateAssetList = new List<Asset>();
        for(Asset ast : astRecList){
            Asset a = new Asset();
            a.Id = ast.Id;
            a.Name = 'Credential Verification';
            updateAssetList.add(a);
        }
        update updateAssetList;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/EPICCredentials?';//+'orgID='+strEntityId+'&epicID='+strEPICId;
        req.httpMethod = 'GET';
        req.params.put('orgID', strEntityId);
        req.params.put('ID', strEPICId);
        req.params.put('DOB', strDOB);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        try {
            List<EPICRestCredentials.EPICCredentialsWrap> epicCredentialsWrapList;// = new List<EPICRestCredentials.EPICCredentialsWrap>();
            epicCredentialsWrapList = EPICRestCredentials.getCredentialStatus();
            System.debug('epicCredentialsWrapList +++ ' + epicCredentialsWrapList);
            System.assert(epicCredentialsWrapList.size() > 0, 'ResponseBody is null');

        } catch (Exception e) {
            System.debug('Error in testInputDOB ++++ ' + e.getStackTraceString() + ', Message ++ ' + e.getMessage());
        } 
        Test.stopTest();
    }

    @IsTest
    static void testAssetNull(){
        setDefaultContext();

        String strDOB = String.valueOf(Date.today());
        Account account = [SELECT id, Entity_ID__c, Name FROM Account LIMIT 1];
        String strEntityId = account.Entity_ID__c;   
        List<Contact> testContact = [SELECT EPIC_ID__c,ECFMG_ID__c,LastName,Name,Generational_Suffix__c,Birthdate,RecordType.Name,Account.Entity_ID__c FROM Contact WITH SECURITY_ENFORCED LIMIT 1];
        String strEPICId = testContact[0].EPIC_ID__c;
        Asset astRec = [Select Id, Name from Asset limit 1];
        astRec.Name = 'Credential Request'; // Class looks for 'Final Medical Diploma'
        update astRec;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/EPICCredentials?';//+'orgID='+strEntityId+'&epicID='+strEPICId;
        req.httpMethod = 'GET';
        req.params.put('orgID', strEntityId);
        req.params.put('ID', strEPICId);
        req.params.put('DOB', strDOB);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        try {
            List<EPICRestCredentials.EPICCredentialsWrap> epicCredentialsWrapList;// = new List<EPICRestCredentials.EPICCredentialsWrap>();
            epicCredentialsWrapList = EPICRestCredentials.getCredentialStatus();
            System.debug('epicCredentialsWrapList +++ ' + epicCredentialsWrapList);
            System.assert(epicCredentialsWrapList.size() > 0, 'ResponseBody is null');

        } catch (Exception e) {
            System.debug('Error in testAssetNull ++++ ' + e.getStackTraceString() + ', Message ++ ' + e.getMessage());
        } 
        Test.stopTest();
    }

    @IsTest
    static void testCaseListisNull(){
        setDefaultContext();

        String strEntityId = 'E-00001'; //dummy ID for testing CaseList.size() == 0 
        String strEPICId = '00000';//Dummy EPICID for testing caselist.size() == 0
        String strStatusDate = null;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/EPICCredentials?';//+'orgID='+strEntityId+'&epicID='+strEPICId;
        req.httpMethod = 'GET';
        req.params.put('orgID', strEntityId);
        req.params.put('ID', strEPICId);
        req.params.put('statusDate', strStatusDate);

        RestContext.request = req;
        RestContext.response= res; 
        Test.startTest();
        try{
            List<EPICRestCredentials.EPICCredentialsWrap> epicCredentialsWrapList;// = new List<EPICRestCredentials.EPICCredentialsWrap>();
            epicCredentialsWrapList = EPICRestCredentials.getCredentialStatus();
            System.debug('epicCredentialsWrapList +++ ' + epicCredentialsWrapList);
            for(EPICRestCredentials.EPICCredentialsWrap respWrap : epicCredentialsWrapList){
                if(String.isNotBlank(respWrap.errorCode)){
                    System.assertEquals(respWrap.errorCode, '204', 'OrgID was passed so No Error');
                }else{
                    System.assertEquals(respWrap.errorCode, null, 'OrgID was passed so No Error');
                }
            }
            
        }catch(Exception e){
            System.debug('Error in testCaseListisNull ++++ ' + e.getStackTraceString() + ', Message ++ ' + e.getMessage());
        } 
        Test.stopTest();
    }

    @IsTest
    static void testGetEPICAPIStatus(){
        
        String cvStatus = 'Resent for Verification';
        String resultStr = EPICRestCredentials.getEPICAPIStatus(cvStatus);
        System.assertEquals(resultStr, 'Sent for Verification');

        cvStatus = 'Pending Verification Review';
        resultStr = EPICRestCredentials.getEPICAPIStatus(cvStatus);
        System.assertEquals(resultStr, 'Verification received; in review at ECFMG');
        
        cvStatus = 'Closed - Not Authentic';
        resultStr = EPICRestCredentials.getEPICAPIStatus(cvStatus);
        System.assertEquals(resultStr, 'Verification closed as not authentic');
        
        cvStatus = 'CV Accepted';
        resultStr = EPICRestCredentials.getEPICAPIStatus(cvStatus);
        System.assertEquals(resultStr, 'CV Accepted');

        cvStatus = 'Unable to Verify Credential';
        resultStr = EPICRestCredentials.getEPICAPIStatus(cvStatus);
        System.assertEquals(resultStr, 'Verification closed as not verifiable');
        
        cvStatus = 'Cancelled';
        resultStr = EPICRestCredentials.getEPICAPIStatus(cvStatus);
        System.assertEquals(resultStr, 'Request Cancelled');

        cvStatus = 'Incomplete';
        resultStr = EPICRestCredentials.getEPICAPIStatus(cvStatus);
        System.assertEquals(resultStr, 'Verification not acceptable; resending for verification');

        cvStatus = 'Dummy';
        resultStr = EPICRestCredentials.getEPICAPIStatus(cvStatus);
        System.assertEquals(resultStr, '');
    }
    
    //We passed EPIC Id and Date of Birth of Contact, If Contact Date of Birth is mathcing with any associated Asset,
    //DOBMatch and EPICIDValid should be true.
    @isTest
    public static void verifyGetCredentialByDOB(){
        CurrentEntityIDSequence__c settingsInstance = CurrentEntityIDSequence__c.getOrgDefaults();
        settingsInstance.Entity_ID__c = '1000000';
        upsert settingsInstance;
        Id applRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_APPLICANT ).getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Unique_Medical_School_ID__c = 'TA123';
        acc.BillingCountry = 'India';
        INSERT acc;
        System.assert(acc.Id!=null,'Account not created');
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        con.Email = 'test1@test.com';
        con.Birthdate = Date.newInstance(2022,4,11).addDays(-33333);
        con.RecordTypeId = applRecTypeId;
        con.EPIC_ID__c  = 'test123';
        INSERT con; 
        
        Id credVerRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        //Create and insert case
        Case caseRecord = new Case();
        caseRecord.Internal_Status__c = 'Expired';
        caseRecord.RecordTypeId = credVerRTId;
        caseRecord.Service__c = Constants.CASE_SERVICE_EPIC;
        INSERT caseRecord;
        
        Asset asst1 = new Asset(
            Name = Constants.ASSET_TYPE_TCT,
            Status = Constants.ASSET_STATUS_ACCEPTED,
            ContactId = con.Id,
            InstallDate = System.Today(),
            key__c	=	Constants.ASSET_TYPE_TCT,
            Type__c	=	'Final Medical Diploma',
            case__c =   caseRecord.Id
        );
        
        insert asst1;
        
        List<EPICRestCredentials.EPICCredentialsWrap> results = EPICRestCredentials.getCredentialByDOB(con.ECFMG_ID__c, con.EPIC_ID__c, '01/06/1931');
        System.debug('results ==>'+results);
        System.assert(results != null);
        EPICRestCredentials.EPICCredentialsWrap objResult = results[0];
        System.assert(objResult.DOBMatch == true);
        System.assert(objResult.EPICIDValid == true);
    }

    //We have verified 2 Scenarios:
    //1. If ORG ID is null then system should return error code and error mesaage as 'ERR-001', 'Missing Required parameter: orgID'.
    //2. If any Child cases are present then response wrapper.EPICID == child case Contact.EPIC_ID__c
    @isTest
    public static void verifyGetCredentials(){ 
        List<EPICRestCredentials.EPICCredentialsWrap> results = EPICRestCredentials.getCredentials(null, null, null, null);
        System.debug('results ==>'+results);
        System.assert(results != null);
        EPICRestCredentials.EPICCredentialsWrap objResult = results[0];
        System.assert(objResult.errorCode == 'ERR-001');
        System.assert(objResult.errorMessage == 'Missing Required parameter: orgID');
        CurrentEntityIDSequence__c settingsInstance = CurrentEntityIDSequence__c.getOrgDefaults();
        settingsInstance.Entity_ID__c = '2000000';
        upsert settingsInstance;        
        Id applRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_APPLICANT ).getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Unique_Medical_School_ID__c = 'TA123';
        acc.BillingCountry = 'India';
        INSERT acc;
        System.assert(acc.Id!=null,'Account not created');
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        con.Email = 'test1@test.com';
        con.Birthdate = System.today().addDays(-33333);
        con.RecordTypeId = applRecTypeId;
        con.EPIC_ID__c  = 'test123';
        INSERT con; 
        //Parent Case
        Id credVerRecTypId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        Case credVerCase = new Case();
        credVerCase.RecordTypeId = credVerRecTypId;
         //Case.RecordType.DeveloperName = 'Credential_Verification'
        credVerCase.ContactId = con.Id;
        //credVerCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_SUBMISSION;
        
        
        credVerCase.Internal_Status__c = 'Accepted';
        INSERT credVerCase;
        //Update credVerCase;
        
        System.assert(credVerCase.Id != null, 'Credential verification Case creation failed');
        
        Id evCaseRecTypId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_VER_REPORT_REQUEST).getRecordTypeId();
        //Child Case
        Case epicVerRep = new Case();
        epicVerRep.Secondary_Parent_Case__c = credVerCase.Id;
        //epicVerRep.Secondary_Child_Cases__c
        epicVerRep.contactId = con.Id;
        epicVerRep.Entity__c = acc.Id;
        epicVerRep.RecordTypeId = evCaseRecTypId;
        epicVerRep.Internal_Status__c = Constants.CASE_STATUS_NEW;
        epicVerRep.Do_Not_Know_Orgs_to_send_EPIC_Reports__c = true;
        INSERT epicVerRep;
        results = EPICRestCredentials.getCredentials(acc.Id, null, con.EPIC_ID__c, con.Birthdate);
        System.assert(results != null);        
    }
    @isTest
    public static void verifyGetCredentials1(){ 
        List<EPICRestCredentials.EPICCredentialsWrap> results = EPICRestCredentials.getCredentials(null, null, null, null);
        System.debug('results ==>'+results);
        System.assert(results != null);
        EPICRestCredentials.EPICCredentialsWrap objResult = results[0];
        System.assert(objResult.errorCode == 'ERR-001');
        System.assert(objResult.errorMessage == 'Missing Required parameter: orgID');
        CurrentEntityIDSequence__c settingsInstance = CurrentEntityIDSequence__c.getOrgDefaults();
        settingsInstance.Entity_ID__c = '2000000';
        upsert settingsInstance;        
        Id applRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_APPLICANT ).getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Unique_Medical_School_ID__c = 'TA123';
        acc.BillingCountry = 'India';
        INSERT acc;
        System.assert(acc.Id!=null,'Account not created');
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        con.Email = 'test1@test.com';
        con.Birthdate = System.today().addDays(-33333);
        con.RecordTypeId = applRecTypeId;
        con.EPIC_ID__c  = 'test123';
        INSERT con; 
        //Parent Case
        Id credVerRecTypId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        Case credVerCase = new Case();
        credVerCase.RecordTypeId = credVerRecTypId;
         //Case.RecordType.DeveloperName = 'Credential_Verification'
        credVerCase.ContactId = con.Id;
        //credVerCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_SUBMISSION;
        credVerCase.Internal_Status__c = 'Accepted';
        INSERT credVerCase;
        //Update credVerCase;        
        System.assert(credVerCase.Id != null, 'Credential verification Case creation failed');        
        Id evCaseRecTypId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_VER_REPORT_REQUEST).getRecordTypeId();
        //Child Case
        Case epicVerRep = new Case();
        epicVerRep.Secondary_Parent_Case__c = null;
        //epicVerRep.Secondary_Child_Cases__c
        epicVerRep.contactId = con.Id;
        epicVerRep.Entity__c = acc.Id;
        epicVerRep.RecordTypeId = evCaseRecTypId;
        epicVerRep.Internal_Status__c = Constants.CASE_STATUS_NEW;
        epicVerRep.Do_Not_Know_Orgs_to_send_EPIC_Reports__c = true;
        INSERT epicVerRep;
        results = EPICRestCredentials.getCredentials(null, con.ECFMG_ID__c, con.EPIC_ID__c, con.Birthdate);
        System.assert(results != null);        
    }
    @isTest
    public static void verifyGetCredentialByDOB1(){
        CurrentEntityIDSequence__c settingsInstance = CurrentEntityIDSequence__c.getOrgDefaults();
        settingsInstance.Entity_ID__c = '4000000';
        upsert settingsInstance;
        Id applRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_APPLICANT ).getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Unique_Medical_School_ID__c = 'TA123';
        acc.BillingCountry = 'India';
        INSERT acc;
        System.assert(acc.Id!=null,'Account not created');
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        con.Email = 'test1@test.com';
        con.Birthdate = Date.newInstance(2022,4,11).addDays(-33333);
        con.RecordTypeId = applRecTypeId;
        con.EPIC_ID__c  = 'test123';
        INSERT con; 
        
        Id credVerRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        //Create and insert case
        Case caseRecord = new Case();
        caseRecord.Internal_Status__c = 'Resent for Verification';
        caseRecord.RecordTypeId = credVerRTId;
        caseRecord.Service__c = Constants.CASE_SERVICE_FCVS;
        INSERT caseRecord;
        
        Asset asst1 = new Asset(
            Name = Constants.ASSET_TYPE_TCT,
            Status = Constants.ASSET_STATUS_ACCEPTED,
            ContactId = con.Id,
            InstallDate = System.Today(),
            key__c	=	Constants.ASSET_TYPE_TCT,
            Type__c	=	'Final Medical Diploma',
            case__c =   caseRecord.Id
        );
        
        insert asst1;
        
        List<EPICRestCredentials.EPICCredentialsWrap> results = EPICRestCredentials.getCredentialByDOB(con.ECFMG_ID__c, con.EPIC_ID__c, '01/06/1931');
        System.debug('results ==>'+results);
        System.assert(results != null);
        EPICRestCredentials.EPICCredentialsWrap objResult = results[0];
        System.assert(objResult.DOBMatch == true);
        System.assert(objResult.EPICIDValid == true);
    }

        /*@isTest
    public static void verifyGetCredentialByDOB3(){
        Id applRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_APPLICANT ).getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Unique_Medical_School_ID__c = 'TA123';
        acc.BillingCountry = 'India';
        INSERT acc;
        System.assert(acc.Id!=null,'Account not created');
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        con.Email = 'test1@test.com';
        con.Birthdate = Date.newInstance(2022,4,11).addDays(-33333);
        con.RecordTypeId = applRecTypeId;
        con.EPIC_ID__c  = 'test123';
        INSERT con; 
        
        Id credVerRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        //Create and insert case
        Case caseRecord = new Case();
        caseRecord.Internal_Status__c = 'Unable to Verify Credential';
        caseRecord.RecordTypeId = credVerRTId;
        caseRecord.Service__c = Constants.CASE_SERVICE_EPIC;
        INSERT caseRecord;
        
        Asset asst1 = new Asset(
            Name = Constants.ASSET_TYPE_TCT,
            Status = Constants.ASSET_STATUS_ACCEPTED,
            ContactId = con.Id,
            InstallDate = System.Today(),
            key__c	=	Constants.ASSET_TYPE_TCT,
            Type__c	=	'Final Medical Diploma',
            case__c =   caseRecord.Id
        );
        
        insert asst1;
        
        List<EPICRestCredentials.EPICCredentialsWrap> results = EPICRestCredentials.getCredentialByDOB(con.EPIC_ID__c, '01/06/1931');
        System.debug('results ==>'+results);
        System.assert(results != null);
        EPICRestCredentials.EPICCredentialsWrap objResult = results[0];
        System.assert(objResult.DOBMatch == true);
        System.assert(objResult.EPICIDValid == true);
    } 
            @isTest
    public static void verifyGetCredentialByDOB2(){
        CurrentEntityIDSequence__c settingsInstance = CurrentEntityIDSequence__c.getOrgDefaults();
        settingsInstance.Entity_ID__c = '3000000';
        upsert settingsInstance;
        Id applRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_APPLICANT ).getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Unique_Medical_School_ID__c = 'TA123';
        acc.BillingCountry = 'India';
        INSERT acc;
        System.assert(acc.Id!=null,'Account not created');
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        con.Email = 'test1@test.com';
        con.Birthdate = Date.newInstance(2022,4,11).addDays(-33333);
        con.RecordTypeId = applRecTypeId;
        con.EPIC_ID__c  = 'test123';
        INSERT con; 
        
        Id credVerRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        //Create and insert case
        Case caseRecord = new Case();
        caseRecord.Internal_Status__c = 'CV Rejected';
        caseRecord.RecordTypeId = credVerRTId;
        caseRecord.Service__c = Constants.CASE_SERVICE_EICS;
        INSERT caseRecord;
        
        Asset asst1 = new Asset(
            Name = Constants.ASSET_TYPE_TCT,
            Status = Constants.ASSET_STATUS_ACCEPTED,
            ContactId = con.Id,
            InstallDate = System.Today(),
            key__c	=	Constants.ASSET_TYPE_TCT,
            Type__c	=	'Final Medical Diploma',
            case__c =   caseRecord.Id
        );
        
        insert asst1;
        
        List<EPICRestCredentials.EPICCredentialsWrap> results = EPICRestCredentials.getCredentialByDOB(con.EPIC_ID__c, '01/06/1931');
        System.debug('results ==>'+results);
        System.assert(results != null);
        EPICRestCredentials.EPICCredentialsWrap objResult = results[0];
        System.assert(objResult.DOBMatch == true);
        System.assert(objResult.EPICIDValid == true);
    } 
    */
}