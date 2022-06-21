@isTest
public with sharing class CaseTriggerHandlerTest{
    @isTest
    static void CaseTriggerHandlerTestMethod(){
        CaseTriggerHandler caseTrig = new CaseTriggerHandler();
    }
    /*@testSetup
    static void setup() { 
        List<Case> lstCase = new List<Case>(); 
        Id verReqCRRecordTypeId = Schema.SObjectType.Verification_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.VERIFICATION_REQUEST_RECORD_TYPE_CREDENTIAL_REVIEW).getRecordTypeId();
        Account acct = new Account(
                Name = 'Test Entity Account',
            	RecordTypeId = RecordTypeUtility.getRecordTypeIdByName('Account', Constants.ACCOUNT_RECORD_TYPE_ENTITY)
        );
        insert acct;

        Contact con = new Contact(
                AccountId = acct.Id,
                FirstName = 'Uniq',
                LastName = 'uniq',
                email = 'uniq@mail.com',
                MailingCountry = 'India');
        insert con;


    

        Verification_Request__c req = new Verification_Request__c(
                RecordTypeId = verReqCRRecordTypeId,
                Account_Exact_Scenario_Score__c = 100,
                Account_Non_Exact_Scenario_Score__c = 100,
                Batch_Id__c = '12345',
                Birth_Date__c = Date.parse('1/1/1970'),
                Candidate_Code__c = 'ABC123',
                Client_Batch_Create_Date__c = Date.today(),
                Client_Institution_ID__c = '12345',
                Client_Provided_Entity_ID__c = '12345',
                Client_Provided_Entity_Name__c = 'Test School',
                Comments__c = 'This is a comment',
                Contact_Exact_Scenario_Score__c = 35,
                Contact_Non_Exact_Scenario_Score__c = 35,
                Current_Citizenship__c = 'UK',
                EICS_ID__c = 'ABC123',
                EPIC_ID__c = 'ABC123',
                Exact_Match_Account__c = acct.Id,
                Exact_Match_Contact__c = con.Id,
                Gender__c = 'Male',
                Graduation_Date__c = Date.parse('1/1/2000'),
                Institution_Address__c = '123 Main Street',
                Institution_City__c = 'Dallas',
                Institution_Country_Code__c = 'US',
                Institution_ID__c = 'ABC123',
                Institution_Name__c = 'Test School',
                Institution_Postal_Code__c = '75001',
                Institution_State_Code__c = 'TX',
                Is_EICS__c = false,
                Is_EPIC__c = false,
                Is_USMLE__c = false,
                Last_Name__c = 'User2',
                Medschool_Code__c = 'ABC123',
                Medschool_Name__c = 'Test School',
                Previous_Last_Name__c = 'Previous Last1',
                Previous_Rest_of_Name__c = 'Previous First1',
                Request_Id__c = 'ABC123',
                Registration_ID__c = '1344',
                Eligibility_Case_ID__c = '10001',
                Rest_of_Name__c = 'Test1',
                Middle_Name__c = 'N',
                Email__c = 'verqcon@testmail.com',
                Status__c = 'Scored',
                University_Code__c = 'ABC123',
                University_Name__c = 'Test School',
                Urgent__c = false,
                USMLE_ID__c = 'ABC123',
                Sender__c = 'FSMB'
        );
        insert req;   
             


        string caseCredentialVerificationTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        string caseFCVSRequestId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_FCVS_REQUEST).getRecordTypeId();
        string caseMEFId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_MED_EDU_FORM).getRecordTypeId();
        Case parentCase = new Case(Internal_Status__c = Constants.CASE_STATUS_NEW,                                    
                                    RecordTypeId = caseFCVSRequestId,
                                    Verification_Request__c = req.Id,
                                    Verification_Request_Source__c = 'FCVS',
                                    ContactId = con.Id, 
                                    AccountId = acct.Id,
                                    Service__c = 'FCVS' );
        insert parentCase;
        //lstCase.Add(parentCase);

        Case childCaseCV1 = new Case(Internal_Status__c = Constants.CASE_STATUS_NEW,                                    
        RecordTypeId = caseCredentialVerificationTypeId,
        Verification_Request__c = req.Id,
        Verification_Request_Source__c = 'FCVS',
        //ParentId = parentCase.Id,
        Service__c = 'FCVS' );
        //insert childCaseCV1;
        lstCase.Add(childCaseCV1);

        Case childCaseCV2 = new Case(Internal_Status__c = Constants.CASE_STATUS_NEW,                                    
        RecordTypeId = caseCredentialVerificationTypeId,
        Verification_Request__c = req.Id,
        Verification_Request_Source__c = 'FCVS',
        //ParentId = parentCase.Id,
        Service__c = 'FCVS' );
        //insert childCaseCV2;
        lstCase.Add(childCaseCV2);
        
        

        Case childCaseME = new Case(Internal_Status__c = Constants.CASE_STATUS_NEW,                                    
        RecordTypeId = caseMEFId,
        Verification_Request__c = req.Id,
        //ParentId = parentCase.Id,
        Verification_Request_Source__c = 'FCVS',
        Service__c = 'FCVS' );
       // insert childCaseME;
        lstCase.Add(childCaseME);

        insert lstCase; 

        Id affCVRecordTypeId = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get(Constants.AFFIRMATION_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        Affirmation__c affirmation = new Affirmation__c();
        affirmation.RecordTypeId = affCVRecordTypeId;
        affirmation.Case__c = childCaseME.Id;
        affirmation.Verify_with_Alternate_Entity__c = true;
        insert affirmation;
        System.assert(affirmation.Id != null, 'Affirmation creation failed');

       /* Service__c newSer = new Service__c();
        newSer.Name = Constants.SERVICE_NAME_CREDENTIAL_VERIFICATION;
        Insert newSer;
        Account2Service__c acctServ = new Account2Service__c();
        acctServ.active__c = true;
        acctServ.Account__c = acct1.Id;
        acctServ.Service__c = newSer.Id;
        Insert acctServ;*/

        /*Service__c ser = new Service__c(
            name = 'Credential Verification');
		insert ser; 

        Account2Service__c a2s = new Account2Service__c(
                Account__c = acct.Id,
            	Service__c = ser.Id,
                active__c =true
        );
        insert a2s;    

        for(Case aCase : lstCase ){
            aCase.ParentId = parentCase.Id;
            aCase.Send_Method__c = Constants.CASE_SEND_METHOD_ENTITY_PORTAL;
            aCase.Send_Method_Override_Comments__c = 'test'; 
        }
        update lstCase; 

    }

    
    @isTest
    static void isParentFCVSCaseTypeTestPostive(){
        List<Account> accounts = [select Id, Name from Account];        
        List<Case> cases = [select Id from Case where AccountId =: accounts[0].Id]; 
        Boolean fcvsRecordTrue; 
        test.startTest();
            fcvsRecordTrue = CaseTriggerHandler.isParentFCVSCaseType(cases[0].Id);             
        test.stopTest(); 
        System.assertEquals(true, fcvsRecordTrue, 'ParentCase is FCVS');

    }

    @isTest
    static void updateParentCaseForFCVSInProgressTestPostive(){
        string parentCasesStatus; 
        test.startTest();
            List<Account> accounts = [select Id, Name from Account];            
            List<Case> parentCases = [select Id, Internal_Status__c from Case where AccountId =: accounts[0].Id]; 
            List<Case> childCases = [select Id,  Internal_Status__c from Case where AccountId !=: accounts[0].Id]; 
            string parentCaseStatus = parentCases[0].Internal_Status__c;
            string childCaseStatus; 
            childCases[0].Internal_Status__c = Constants.CASE_STATUS_SUBMITTED_IN_REVIEW; 
            update childCases;            
            List<Case> parentCasesStatusAfterUpdate = [select Id,Internal_Status__c  from Case where AccountId =: accounts[0].Id]; 
            parentCasesStatus = parentCasesStatusAfterUpdate[0].Internal_Status__c; 
        test.stopTest();
        System.assertEquals(Constants.CASE_STATUS_IN_PROGRESS, parentCasesStatus, 'ParentCase is status is in progress');

    }

    @isTest
    static void updateParentCaseForFCVSRejectedTestPostive(){
        string parentCasesStatus; 
        
            List<Account> accounts = [select Id, Name from Account];            
            List<Case> parentCases = [select Id, Internal_Status__c from Case where AccountId =: accounts[0].Id]; 
            List<Case> childCases = [select Id,  Internal_Status__c from Case where ParentId =: parentCases[0].Id]; 
            string parentCaseStatus = parentCases[0].Internal_Status__c;
            string childCaseStatus; 
            test.startTest();
                childCases[0].Internal_Status__c = Constants.CASE_STATUS_CV_REJECTED; 
                update childCases; 
            test.stopTest();
            List<Case> afterChildCasesUpdate = [select Id,  Internal_Status__c from Case where ParentId =: parentCases[0].Id and Internal_Status__c =: Constants.CASE_STATUS_CV_REJECTED ];                                
            System.assertEquals(3, afterChildCasesUpdate.size(), 'All 3 child cases are updated to cancel ');

    }

    @isTest
    static void updateParentCaseForFCVSSendForVerificationTestPostive(){
        string parentCasesStatus; 
        test.startTest();
            List<Account> accounts = [select Id, Name from Account];
            List<Case> parentCases = [select Id, Internal_Status__c from Case where AccountId =: accounts[0].Id]; 
            List<Case> childCases = [select Id,  Internal_Status__c from Case where AccountId !=: accounts[0].Id]; 
            Integer casesCount = childCases.size(); 

            parentCasesStatus = parentCases[0].Internal_Status__c;
            string childCaseStatus; 
            for(integer i=0; i<casesCount-1; i++){
                childCases[i].Internal_Status__c = Constants.CASE_STATUS_SENT_FOR_VERIFICATION; 
            }
            update childCases; 
        test.stopTest();              
        List<Case> parentCasesStatusAfterUpdate = [select Id,Internal_Status__c  from Case where AccountId =: accounts[0].Id]; 
        String strParentCasesStatusAfterUpdate = parentCasesStatusAfterUpdate[0].Internal_Status__c; 
        System.assertEquals('New', parentCasesStatus, 'ParentCase is status - No Change after 2 updates');                            
    }

    
    @isTest
    static void updateParentCaseForFCVSSendForVerification2TestPostive(){
        string parentCasesStatus; 
        test.startTest();
            List<Account> accounts = [select Id, Name from Account];            
            List<Case> parentCases = [select Id, Internal_Status__c from Case where AccountId =: accounts[0].Id]; 
            List<Case> childCases = [select Id,  Internal_Status__c from Case where AccountId !=: accounts[0].Id]; 
            Integer casesCount = childCases.size();
            parentCasesStatus = parentCases[0].Internal_Status__c;
            string childCaseStatus; 
            for( case a : childCases){
                a.Internal_Status__c = Constants.CASE_STATUS_SENT_FOR_VERIFICATION; 
            }
            update childCases; 
            test.stopTest(); 
        List<Case> parentCasesStatusAfterUpdate = [select Id,Internal_Status__c  from Case where AccountId =: accounts[0].Id]; 
        String strParentCasesStatusAfterUpdate = parentCasesStatusAfterUpdate[0].Internal_Status__c; 
        System.assertEquals(Constants.CASE_STATUS_SENT_FOR_VERIFICATION, strParentCasesStatusAfterUpdate, 'ParentCase is status change to Sent for Verification after 3 subcases update');                       
      
    }

    @isTest
    static void updateParentCaseForFCVSReSendForVerificationTestPostive(){
        string parentCasesStatus; 
        String strParentCasesStatusAfterUpdate; 
        test.startTest();
            List<Account> accounts = [select Id, Name from Account];            
            List<Case> parentCases = [select Id, Internal_Status__c from Case where AccountId =: accounts[0].Id]; 
            List<Case> childCases = [select Id,  Internal_Status__c from Case where AccountId !=: accounts[0].Id]; 
            Integer casesCount = childCases.size(); 

            parentCasesStatus = parentCases[0].Internal_Status__c;
            string childCaseStatus; 
            for( case a : childCases){
                a.Internal_Status__c = Constants.CASE_STATUS_RESENT_FOR_VERIFICATION; 
            }
            update childCases; 
        test.stopTest();                
        List<Case> parentCasesStatusAfterUpdate = [select Id,Internal_Status__c  from Case where AccountId =: accounts[0].Id]; 
        strParentCasesStatusAfterUpdate = parentCasesStatusAfterUpdate[0].Internal_Status__c; 
        System.assertEquals(Constants.CASE_STATUS_RESENT_FOR_VERIFICATION, strParentCasesStatusAfterUpdate, 'ParentCase is status change to ReSent for Verification after 3 subcases update');
                       
   
    }

    @isTest
    static void updateParentCaseForFCVSCancelledTestPostive(){
        string parentCasesStatus; 
        
            List<Account> accounts = [select Id, Name from Account];            
            List<Case> parentCases = [select Id, Internal_Status__c from Case where AccountId =: accounts[0].Id]; 
            List<Case> childCases = [select Id,  Internal_Status__c from Case where ParentId =: parentCases[0].Id]; 
            string parentCaseStatus = parentCases[0].Internal_Status__c;
            string childCaseStatus; 
            test.startTest();
                childCases[0].Internal_Status__c = Constants.CASE_STATUS_CANCELLED; 
                update childCases; 
            test.stopTest();
            List<Case> afterChildCasesUpdate = [select Id,  Internal_Status__c from Case where ParentId =: parentCases[0].Id and Internal_Status__c =: Constants.CASE_STATUS_CANCELLED ];                                
            System.assertEquals(3, afterChildCasesUpdate.size(), 'All 3 child cases are updated to cancel ');
    }

    @isTest
    static void updateParentCaseForFCVSAcceptedTestPostive(){
        string parentCasesStatus; 
        String strParentCasesStatusAfterUpdate; 
        test.startTest();
            List<Account> accounts = [select Id, Name from Account];            
            List<Case> parentCases = [select Id, Internal_Status__c from Case where AccountId =: accounts[0].Id]; 
            List<Case> childCases = [select Id,  Internal_Status__c from Case where AccountId !=: accounts[0].Id]; 
            Integer casesCount = childCases.size(); 

            parentCasesStatus = parentCases[0].Internal_Status__c;
            string childCaseStatus; 
            for( case a : childCases){
                a.Internal_Status__c = Constants.CASE_STATUS_CV_ACCEPTED ; 
            }
            update childCases; 
        test.stopTest();     
        List<Case> parentCasesStatusAfterUpdate = [select Id,Internal_Status__c  from Case where Id =: parentCases[0].Id]; 
        strParentCasesStatusAfterUpdate = parentCasesStatusAfterUpdate[0].Internal_Status__c; 
        System.assertEquals(Constants.CASE_STATUS_ENROLLMENT_COMPLETED, strParentCasesStatusAfterUpdate, 'ParentCase is status change to Complete');                       
                     
    }

    
    @isTest
    static void updateParentCaseForFCVSPrevVerfiedAcceptedTestPostive(){
        string parentCasesStatus; 
        String strParentCasesStatusAfterUpdate;
        List<Case> childCases = new  List<Case>(); 
        List<Case> parentCases = new List<Case>(); 
        List<Account> accounts = [select Id, Name from Account];    
        parentCases = [select Id, Internal_Status__c from Case where AccountId =: accounts[0].Id]; 
        childCases = [select Id,  Internal_Status__c from Case where AccountId !=: accounts[0].Id]; 
        Integer casesCount = childCases.size(); 
        test.startTest();
            parentCasesStatus = parentCases[0].Internal_Status__c;            
            string childCaseStatus; 
            for(integer i=0; i<casesCount; i++){
                childCases[i].Internal_Status__c = Constants.CASE_STATUS_PREV_VERIFIED_ACCEPTED; 
            }          
            update childCases; 
        test.stopTest();             
        List<Case> parentCasesStatusAfterUpdate = [select Id,Internal_Status__c  from Case where AccountId =: accounts[0].Id]; 
        strParentCasesStatusAfterUpdate = parentCasesStatusAfterUpdate[0].Internal_Status__c; 
        childCases = [select Id,  Internal_Status__c from Case where AccountId !=: accounts[0].Id];            
        System.assertEquals(strParentCasesStatusAfterUpdate, Constants.CASE_STATUS_PREV_VERIFIED_ACCEPTED, 'ParentCase is status - completed');                     
    }*/
}