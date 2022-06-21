@IsTest
public class DuplicateCheckControllerTest{
    private static CurrentEntityIDSequence__c settingsInstance;
    static{
        CurrentEntityIDSequence__c settingsInstance = CurrentEntityIDSequence__c.getOrgDefaults();
        settingsInstance.Entity_ID__c = '0000000';
        upsert settingsInstance;
    }
    private static CurrentECFMGIDSequence__c settingsECFMGInstance;
    static{
        CurrentECFMGIDSequence__c settingsECFMGInstance = CurrentECFMGIDSequence__c.getOrgDefaults();
        settingsECFMGInstance.ECFMG_ID__c = '00000001';
        upsert settingsECFMGInstance;
    }
    @IsTest
    public static void testEnableDuplicateRequest(){
 		Account acc = new Account(Name = 'Test Account 123', BillingCountry = 'United States', BillingState = 'California', BillingCity = 'TEst', BillingPostalCode = '123456');
		//acc.Name = 'Test School 3';
		INSERT acc;
		Contact con = new Contact();
		con.AccountId = acc.Id;
		con.LastName = 'Test';
		con.Email = 'test@test.com';
		INSERT con;
        Verification_Request__c vr = new Verification_Request__c(
                Account_Exact_Scenario_Score__c = null,
                Account_Non_Exact_Scenario_Score__c = null,
                Account_Type__c = '',
                Phone__c = '',
                Parent_Affiliation__c = '',
                Batch_Id__c = '12345',
                // TODO: Revisit once the country list issue as been addressed //Birth_Country__c = 'UK',
                Birth_Date__c = Date.parse('1/1/1970'),
                Candidate_Code__c = 'ABC123',
                Client_Batch_Create_Date__c = Date.today(),
                Client_Institution_ID__c = '12345',
                Client_Provided_Entity_ID__c = '12345',
                Client_Provided_Entity_Name__c = 'Test School 1',
                Comments__c = 'This is a comment',
                Contact_Exact_Scenario_Score__c = null,
                Contact_Non_Exact_Scenario_Score__c = null,
                Current_Citizenship__c = 'UK',
                EICS_ID__c = 'ABC123',
                EPIC_ID__c = 'ABC123',
                Exact_Match_Account__c = null,
                Exact_Match_Contact__c = null,
                Gender__c = 'Male',
                Graduation_Date__c = Date.parse('1/1/2000'),
                Institution_Address__c = '123 Main Street',
                Institution_City__c = 'Dallas',
                Institution_Country_Code__c = 'US',
                Institution_ID__c = 'ABC123',
                Institution_Name__c = 'Test School 2',
                Institution_Postal_Code__c = '75001',
                Institution_State_Code__c = 'TX',
                Is_EICS__c = false,
                Is_EPIC__c = false,
                Is_USMLE__c = false,
                Last_Name__c = 'User1',
                Medschool_Code__c = 'ABC123',
                Medschool_Name__c = 'Test School 3',
                Previous_Last_Name__c = 'Previous Last1',
                Previous_Rest_of_Name__c = 'Previous First1',
                Request_Id__c = 'ABC123',
                Request_Type__c = 'Test Request',
                Rest_of_Name__c = 'Test1',
                Sender__c = 'MCC',
                Status__c = Constants.VERIFICATION_REQUEST_STATUS_PENDING,
                University_Code__c = 'ABC123',
                University_Name__c = 'Test School 4',
                Urgent__c = false,
                USMLE_ID__c = 'ABC123'
                );
                insert vr;
		Case caseVar = new Case();
        caseVar.Verification_Request__c = vr.Id;
		caseVar.ContactId = con.Id;
        caseVar.AccountId = acc.Id;
		INSERT caseVar;
        Id entSerRegRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_DEV_ENTITY_SERVICE_REQUEST).getRecordTypeId();
        Case parentcaseVar = new Case();
        parentcaseVar.RecordTypeId=entSerRegRTId;
		parentcaseVar.ContactId = con.Id;
        parentcaseVar.ParentId=caseVar.Id;
		INSERT parentcaseVar;  
        Test.startTest();      
        Case cs = DuplicateCheckController.getCase(caseVar.Id);
        System.assert(cs != null, 'Case does not exist');
        Contact cont = DuplicateCheckController.getContact(con.Id);
        System.assert(cont != null, 'Contact does not exist');
        Account acct = DuplicateCheckController.getAccount(acc.Id);
        System.assert(acct != null, 'Account does not exist');
        String linkeEnt = DuplicateCheckController.getLinkedEntityId(caseVar.Id);
        Case entSerReq = DuplicateCheckController.getEntityServiceRequest(caseVar.Id); 
        System.assert(linkeEnt != '', 'Verification Request is not Linked');
        System.assert(entSerReq != null, 'Case Request does not exist');              
        DuplicateCheckController.linkApplicant(caseVar.Id,con.Id);        
        List<Case> cases = [select Id, ContactId, AccountId from Case where Id = :caseVar.Id];
        System.assert(cases[0].ContactId == con.Id, 'case contactId should not be ' +  con.Id);
        DuplicateCheckController.unlinkApplicant(caseVar.Id);
        DuplicateCheckController.linkEntity(caseVar.Id,acc.Id);
        DuplicateCheckController.unlinkEntity(caseVar.Id);
        List<Case> cases1 = [select Id, ContactId, AccountId from Case where Id = :caseVar.Id];
        System.assert(cases1[0].ContactId == null, 'case contactId should not be null');
        Contact contactLinkApp = DuplicateCheckController.createLinkApplicant(caseVar.Id);
        System.assert(contactLinkApp != null, 'Contact should not be null');
        Case csEntReq = DuplicateCheckController.createEntityRequest(caseVar.Id);
        System.assert(csEntReq != null, 'case should be null');
        Verification_Request__c verRequest = DuplicateCheckController.getVerificationRequest(caseVar.Id);    
        System.assert(verRequest != null, 'Verification Request should be null');
        List<ApplicantDuplicateMatchModel> appDupMatchModel = DuplicateCheckController.getApplicantMatches(caseVar.Id);
        List<EntityDuplicateMatchModel> entDupMatchModel = DuplicateCheckController.getEntityMatches(caseVar.Id);
        System.assert(appDupMatchModel.size() == 0, 'Match found');
        System.assert(entDupMatchModel.size() == 0, 'Match found');
        Test.stopTest();
    }
}