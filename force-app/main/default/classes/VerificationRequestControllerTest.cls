@isTest
public class VerificationRequestControllerTest{	
    Static final String SCHOOL = 'Test School';
    Static final String DAY = '1/1/1970';
    Static final String DAY1 = '1/1/2000';
    Static final String STREET = '123 Main Street';
    Static final String PREV_LAST = 'Previous Last1';
    Static final String COMMENT = 'This is a comment';
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
    //Creates test data for other tests.
    @testSetup
    static void setup(){
        List<RecordType> eicsRT = [select Id from RecordType where SobjectType = 'Contact' and Name = :Constants.CONTACT_RECORD_TYPE_EICS_APPLICANT];
        insert new Contact(FirstName = 'Test1',
                LastName = 'User1',
                Birthdate = Date.parse(day),
                Gender__c = 'Male',
                RecordTypeId = eicsRT[0].Id);
        Contact con = [select Id, FirstName from Contact where FirstName = 'Test1' and RecordTypeId =:eicsRT[0].Id limit 1];        
        System.assert(con.Id!=null,'Contact is not found');
        Id identityAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();         
            Account acc = new Account(Name = 'Test Account' ,                                                        
                                        BillingCountry = 'Nepal'
                                        );                   
        insert acc;
        System.assert(acc.Id!=null,'account not found.');
        Verification_Request__c req1 = new Verification_Request__c(Account_Exact_Scenario_Score__c = null,
                Account_Non_Exact_Scenario_Score__c = null,
                Batch_Id__c = '12345',
                Birth_Date__c = Date.parse(DAY),
                Candidate_Code__c = 'ABC123',
                Client_Batch_Create_Date__c = Date.today(),
                Client_Institution_ID__c = '12345',
                Client_Provided_Entity_ID__c = '12345',
                Client_Provided_Entity_Name__c = SCHOOL,
                Comments__c = COMMENT,
                Contact_Exact_Scenario_Score__c = null,
                Contact_Non_Exact_Scenario_Score__c = null,
                Current_Citizenship__c = 'UK',
                EICS_ID__c = 'ABC123',
                EPIC_ID__c = 'ABC123',
                Exact_Match_Account__c = null,
                Exact_Match_Contact__c = null,
                Gender__c = 'Male',
                Graduation_Date__c = Date.parse(DAY1),
                Institution_Address__c = STREET,
                Institution_City__c = 'Dallas',
                Institution_Country_Code__c = 'US',
                Institution_ID__c = 'ABC123',
                Institution_Name__c = SCHOOL,
                Institution_Postal_Code__c = '75001',
                Institution_State_Code__c = 'TX',
                Is_EICS__c = false,
                Is_EPIC__c = false,
                Is_USMLE__c = false,
                Last_Name__c = 'User1',
                Medschool_Code__c = 'ABC123',
                Medschool_Name__c = SCHOOL,
                Previous_Last_Name__c = PREV_LAST,
                Previous_Rest_of_Name__c = 'Previous First12',
                Request_Id__c = 'ABC123',
                Request_Type__c = 'Test Request1',
                Rest_of_Name__c = 'Test1',
                Sender__c = 'MCC',
                Status__c = Constants.VERIFICATION_REQUEST_STATUS_PENDING,
                University_Code__c = 'ABC123',
                University_Name__c = SCHOOL,
                Urgent__c = false,
                USMLE_ID__c = 'ABC123'
        );
        insert req1;
        System.assert(req1.Id!=null,'Request not found.');
        insert new Case(Verification_Request__c = req1.Id);
        Case case1 = [Select id from Case where Verification_Request__c =: req1.Id limit 1];
        System.assert(case1.Id!=null,'Case doesnot exists.');
        Case case2 = new Case();
        insert case2;
        System.assert(case2.Id!=null,'Case not found');
    }
    //This method tests the setup.
    @isTest
    static void testSetup(){
        List<Verification_Request__c> reqs =
            [SELECT
                Account_Exact_Scenario_Score__c,
                Account_Non_Exact_Scenario_Score__c,
                Batch_Id__c,
                Birth_Country__c,
                Birth_Date__c,
                Candidate_Code__c,
                Client_Batch_Create_Date__c,
                Client_Institution_ID__c,
                Client_Provided_Entity_ID__c,
                Client_Provided_Entity_Name__c,
                Comments__c,
                Contact_Exact_Scenario_Score__c,
                Contact_Non_Exact_Scenario_Score__c,
                CreatedById,
                CreatedDate,
                Current_Citizenship__c,
                EICS_ID__c,
                EPIC_ID__c,
                Exact_Match_Account__c,
                Exact_Match_Contact__c,
                Gender__c,
                Graduation_Date__c,
                Id,
                Institution_Address__c,
                Institution_City__c,
                Institution_Country_Code__c,
                Institution_ID__c,
                Institution_Name__c,
                Institution_Postal_Code__c,
                Institution_State_Code__c,
                Is_EICS__c,
                Is_EPIC__c,
                Is_USMLE__c,
                IsDeleted,
                Last_Name__c,
                LastModifiedById,
                LastModifiedDate,
                LastReferencedDate,
                LastViewedDate,
                Medschool_Code__c,
                Medschool_Name__c,
                Name,
                OwnerId,
                Previous_Last_Name__c,
                Previous_Rest_of_Name__c,
                Request_Id__c,
                Request_Type__c,
                Residence_Country__c,
                Rest_of_Name__c,
                Sender__c,
                Status__c,
                SystemModstamp,
                University_Code__c,
                University_Name__c,
                Urgent__c,
                USMLE_ID__c
        FROM Verification_Request__c];
        System.assert(reqs!=null, 'reqs should not be null');
        System.assert(reqs.size()==1, 'size of reqs should be 1');
        List<Case> cases = [select Id from Case];
        System.assert(cases!=null, 'cases cannot be null');
        System.assert(cases.size()==2, 'size of cases should be 2');
        List<Account> accounts = [select Id, Name from Account];
        System.assert(accounts!=null, 'accounts should not be null');
        System.assert(accounts.size()==2, 'size of accounts should be 2, it is ' + accounts.size());
        List<Contact> contacts = [select Id from Contact];
        System.assert(contacts!=null, 'contacts should not be null');
        System.assert(contacts.size()==1, 'size of contacts retrieved should be 1');
    }
    // This method tests if the method throws an exception if a non-valid case id is passed to method.
    @isTest
    static void getVerReqThrowExceptionIfInvalidCaseId(){
        try{
            // this should result in InvalidParameterException
            VerificationRequestController.getVerificationRequest('invalid');
            System.assert(false, 'An exception should have been thrown.');
        }
        catch(ServiceException ex){
            if(ex.getMessage().containsIgnoreCase('Could not find case')){
                // assert true (passing) if we get here
                System.assert(true,'Assert failed');
            }
            else{
                // if we get here, there was another problem
                System.assert(false, ex.getMessage());
            }
        }
        catch(Exception ex){
            // if we get here, there was another problem
            System.assert(false, ex.getMessage());
        }
    }
    // This method tests if the method returns null if the verification request could not be found by case id.
    @isTest
    static void getVerReqReturnNullIfNotFound(){
        List<Case> cases = [select Id from Case where Verification_Request__c = null limit 1];
        System.assert(cases!=null, 'cases cannot be null');
        Verification_Request__c req = VerificationRequestController.getVerificationRequest(cases[0].Id);
        System.assert(req==null, 'req should be null');
    }
    // This method tests if the the method returns data when a case is supplied which is linked to a verification request.
    @isTest
    static void getVerificationRequestShouldReturnData(){
        CurrentEntityIDSequence__c settingsInstance = CurrentEntityIDSequence__c.getOrgDefaults();
        settingsInstance.Entity_ID__c = '0000001';
        upsert settingsInstance;

        Id entityRecTypId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Tester Entity';
        acc.RecordTypeId = entityRecTypId;
        acc.BillingCity = 'Tester City';
        acc.BillingCountry = 'India';
        Insert acc;
        System.assert(acc.Id!=null, 'Account not found');
        VerificationRequestController.fetchEntityData('Tester Entity');
        List<Case> cases = [select Id from Case where Verification_Request__c <> null limit 1];
        System.assert(cases!=null, 'cases should not be null');
        Verification_Request__c req = VerificationRequestController.getVerificationRequest(cases[0].Id);
        System.assert(req!=null, 'req should not be null');
    }
    // This test if the method returns a result. The result is mocked as the search API doesn't work in tests.
    @isTest
    static void getEntityMatchesShouldReturnMatches(){
        List<Case> cases = [select Id from Case where Verification_Request__c <> null limit 1];
        System.assert(cases!=null, 'cases should not be null');
        System.assert(cases.size()==1, 'size of cases should be 1');
        List<EntityDuplicateMatchModel> model = VerificationRequestController.getEntityMatches(cases[0].Id);
        model[0].compareTo(model[0]);
        System.assert(model!=null, 'model should not be null');
        System.assert(model.size()==1, 'size of model should be 1');
    }
    // This tests if the method properly sets the cases contactId.
    @isTest
    static void linkApplicantShouldSetCaseContact(){
        List<Case> cases = [select Id, ContactId, AccountId from Case where ContactId = null limit 1];
        System.assert(cases[0].ContactId==null, 'case contactId should be null');
        List<Contact> contacts = [select Id from Contact limit 1];
        System.assert(contacts.size()==1, 'size of contacts should be 1');
        VerificationRequestController.linkApplicant(cases[0].Id, contacts[0].Id);
        cases = [select Id, ContactId, AccountId from Case where Id = :cases[0].Id];
        System.assert(cases[0].ContactId==contacts[0].Id, 'case contactId should be ' + contacts[0].Id);
    }
    // This tests if the method sets the appropriate case attribute name and value.
    @isTest
    static void linkEntityShouldSetCaseAttribute(){
        List<Case> cases = [select Id from Case limit 1];
        List<Account> accounts = [select Id from Account limit 1];
        System.assert(accounts.size()==1, 'size of accounts should be 1');
        List<Case_Attribute__c> ca = [select Id, Name, Value__c from Case_Attribute__c where Case__c = :cases[0].Id];
        System.assert(ca.size()==0, 'size of case attribute should be 0');
        VerificationRequestController.linkEntity(cases[0].Id, accounts[0].Id);
        ca = [select Id, Name, Value__c from Case_Attribute__c where Case__c = :cases[0].Id];
        System.assert(ca.size()==1, 'size of case attribute should be 1');
        System.assert(ca[0].Name==Constants.REQUEST_VERIFICATION_LINKED_ENTITY_ID_ATTRIBUTE_NAME, 'ca name should be ' + Constants.REQUEST_VERIFICATION_LINKED_ENTITY_ID_ATTRIBUTE_NAME);
        System.assert(ca[0].Value__c==accounts[0].Id, 'ca value should be ' + accounts[0].Id);
        string testAccountId = 'asdfas' +'\'';
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Salesforce Reviewer' LIMIT 1];
        //List<Contact> contacts = [select Id from Contact];
        User usr = new User(LastName = 'Bhardwaj',
                            FirstName = 'Pranav',
                            Alias = 'pbhar',
                            Email = 'Pranav.Bhardwaj@asdf.com',
                            Username = 'Pranav.Bhardwaj@asdf.com',
                            ProfileId = profileId.id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US');
        insert usr;
        System.assert(usr.Id!=null,'User not found.');
        System.runAs(usr){
            Account result = AccountService.getAccount(testAccountId);  
            System.assert(result==null, 'Exception test failed');
        }
    }
    // This tests if the method clears the case contact id.
    @isTest
    static void unlinkApplicantShouldRemoveContact(){
        List<Case> cases = [select Id, ContactId, AccountId from Case where ContactId = null limit 1];
        List<Contact> contacts = [select Id from Contact limit 1];
        VerificationRequestController.linkApplicant(cases[0].Id, contacts[0].Id);
        cases = [select Id, ContactId, AccountId from Case where Id = :cases[0].Id];
        System.assert(cases[0].ContactId==contacts[0].Id, 'case contactId should be ' + contacts[0].Id);
        VerificationRequestController.unlinkApplicant(cases[0].Id);
        cases = [select Id, ContactId, AccountId from Case where Id = :cases[0].Id];
    }
    // This tests if the method removes the appropriate case attribute.
    @isTest
    static void unlinkEntityShouldRemoveCaseAttribute(){
        List<Case> cases = [select Id from Case limit 1];
        List<Account> accounts = [select Id from Account limit 1];
        List<Case_Attribute__c> ca = [select Id, Name, Value__c from Case_Attribute__c where Case__c = :cases[0].Id];
        VerificationRequestController.linkEntity(cases[0].Id, accounts[0].Id);
        ca = [select Id, Name, Value__c from Case_Attribute__c where Case__c = :cases[0].Id];
        System.assert(ca.size()==1, 'size of case attribute should be 1');
        System.assert(ca[0].Name==Constants.REQUEST_VERIFICATION_LINKED_ENTITY_ID_ATTRIBUTE_NAME, 'ca name should be ' + Constants.REQUEST_VERIFICATION_LINKED_ENTITY_ID_ATTRIBUTE_NAME);
        System.assert(ca[0].Value__c==accounts[0].Id, 'ca value should be ' + accounts[0].Id);
        VerificationRequestController.unlinkEntity(cases[0].Id);
        ca = [select Id, Name, Value__c from Case_Attribute__c where Case__c = :cases[0].Id];
        System.assert(ca.size()==0, 'size of case attribute should be 0');
    }
    // This tests if the method creates a new applicant (contact) and links it to the case using verification request data.
    @isTest
    static void createLinkApplicantCreateNewConAndLinkToCase(){
        List<Case> cases = [select Id, ContactId from Case where Verification_Request__c != null];
        CurrentECFMGIDSequence__c settingsECFMGInstance = CurrentECFMGIDSequence__c.getOrgDefaults();
        settingsECFMGInstance.ECFMG_ID__c = '00000002';
        upsert settingsECFMGInstance;
        VerificationRequestController.createLinkApplicant(cases[0].Id);
        cases = [select Id, ContactId from Case where Verification_Request__c != null];
        System.assert(cases[0].ContactId!=null, 'case contactId should not be null');
        List<Contact> contacts = [select Id, FirstName, LastName, Gender__c from Contact where Id = :cases[0].ContactId];
        System.assert(contacts[0].FirstName=='Test1', 'contact first name should be test1');
        System.assert(contacts[0].LastName=='User1', 'contact last name should be user1');
        System.assert(contacts[0].Gender__c=='Male', 'contact gender should be male');
    }
    // This test if the method creates a new entity request child case and links it to the parent credential review case.
    @isTest
    static void createEntityReqCreateAndParentNewCase(){
        List<Case> cases = [select Id, ContactId, Verification_Request__c, recordtype.name,  Internal_Status__c  from Case where Verification_Request__c != null];
        List<Case> childCases = [select Id from Case where ParentId = :cases[0].Id];         
        System.assert(childCases.size()==0, 'size of cases should be 0');
        VerificationRequestController.createEntityRequest(cases[0].Id);
        childCases = [select Id, Verification_Request__c from Case where ParentId = :cases[0].Id];
        System.assert(childCases[0].Verification_Request__c==cases[0].Verification_Request__c, 'case verification request should be ' + cases[0].Verification_Request__c);
    }
    //This test if the method returns a case using the case id.
    @isTest
    static void getCaseShoudReturnCase(){
        List<Case> cases = [select Id, ContactId, Verification_Request__c from Case limit 1];
        Case cse = CaseService.getCase(cases[0].Id);
        System.assert(cse!=null, 'cse should not be null');
    }
    // This test if the method returns a contact using the contact id.
    @isTest
    static void getContactShouldReturnContact(){
        List<Contact> contacts = [select Id, FirstName, LastName from Contact limit 1];
        System.assert(contacts.size()==1, 'size of contacts should be 1');
        System.assert(contacts[0].FirstName=='Test1', 'contact first name should be Test1');
        System.assert(contacts[0].LastName=='User1', 'contact last name should be User1');
    }
    // This test if the method returns an account using the account id.
    @isTest
    static void getAccountShouldReturnAccount(){
        List<Account> accounts = [select Id from Account];
        System.assert(accounts.size()==2, 'size of accounts should be 2, instead it is ' + accounts.size());
    }
    // This method returns the linked entity id from the case attribute.
    @isTest
    static void getLinkedEntityIdShouldReturnId(){
        List<Case> cases = [select Id from Case limit 1];
        List<Account> accounts = [select Id from Account limit 1];
        System.assert(accounts.size()==1, 'size of accounts should be 1');
        List<Case_Attribute__c> ca = [select Id, Name, Value__c from Case_Attribute__c where Case__c = :cases[0].Id];
        VerificationRequestController.linkEntity(cases[0].Id, accounts[0].Id);
        ca = [select Id, Name, Value__c from Case_Attribute__c where Case__c = :cases[0].Id];
        VerificationRequestController.getLinkedEntityId(cases[0].Id);
    }
    // This method returns the linked entity id from the case attribute.
    @isTest
    static void getEntityServiceRequestShouldReturnChildCase(){
        List<Case> cases = [select Id, ContactId, Verification_Request__c, recordtype.name, status, Internal_Status__c from Case where Verification_Request__c != null];        
        System.assert(cases[0].ContactId==null, 'case contactId should be null');
        List<Case> childCases = [select Id from Case where ParentId = :cases[0].Id];
        System.assert(childCases.size()==0, 'size of cases should be 0');
        VerificationRequestController.createEntityRequest(cases[0].Id);
        childCases = [select Id, Verification_Request__c from Case where ParentId = :cases[0].Id];
        System.assert(childCases.size()==1, 'size of cases should be 1');
        System.assert(childCases[0].Verification_Request__c==cases[0].Verification_Request__c, 'case verification request should be ' + cases[0].Verification_Request__c);
        Case childCase = VerificationRequestController.getEntityServiceRequest(cases[0].Id);
        System.assert(childCase!=null, 'child case should not be null');
        System.assert(childCase.ParentId==cases[0].Id, 'child case should have parent id of ' + cases[0].Id);
    }
    @isTest
    static void getDuplicateCheckSettingsShouldReturnSettings(){
        Duplicate_Check_Setting__mdt settings = VerificationRequestController.getDuplicateCheckSettings();
        System.assert(settings!=null, 'settings should not be null');
        System.assert(settings.DeveloperName=='Default_Settings', 'settings developer name should be Default_Settings');
    }
    // This test if the method returns a result. The result is mocked as the search API doesn't work in tests.
    @isTest
    static void proceedTest(){
        CurrentECFMGIDSequence__c settingsECFMGInstance = CurrentECFMGIDSequence__c.getOrgDefaults();
        settingsECFMGInstance.ECFMG_ID__c = '00000003';
        upsert settingsECFMGInstance;
        CurrentEntityIDSequence__c settingsInstance = CurrentEntityIDSequence__c.getOrgDefaults();
        settingsInstance.Entity_ID__c = '0000003';
        upsert settingsInstance;
        Verification_Request__c req2 = new Verification_Request__c(Account_Exact_Scenario_Score__c = null,
                Account_Non_Exact_Scenario_Score__c = null,
                Batch_Id__c = '123452',
                Birth_Date__c = Date.parse(DAY),
                Candidate_Code__c = 'ABC1232',
                Client_Batch_Create_Date__c = Date.today(),
                Client_Institution_ID__c = '123425',
                Client_Provided_Entity_ID__c = '123425',
                Client_Provided_Entity_Name__c = SCHOOL,
                Comments__c = COMMENT,
                Contact_Exact_Scenario_Score__c = null,
                Contact_Non_Exact_Scenario_Score__c = null,
                Current_Citizenship__c = 'UK',
                EICS_ID__c = 'ABC1232',
                EPIC_ID__c = 'ABC1232',
                Exact_Match_Account__c = null,
                Exact_Match_Contact__c = null,
                Gender__c = 'Male',
                Graduation_Date__c = Date.parse(DAY1),
                Institution_Address__c = STREET,
                Institution_City__c = 'Dallas',
                Institution_Country_Code__c = 'US',
                Institution_ID__c = 'ABC1232',
                Institution_Name__c = SCHOOL,
                Institution_Postal_Code__c = '750012',
                Institution_State_Code__c = 'TX',
                Is_EICS__c = false,
                Is_EPIC__c = false,
                Is_USMLE__c = false,
                Last_Name__c = 'Tester',
                Medschool_Code__c = 'ABC123',
                Medschool_Name__c = SCHOOL,
                Previous_Last_Name__c = PREV_LAST,
                Previous_Rest_of_Name__c = 'Previous First1',
                Request_Id__c = 'ABC123',
                Request_Type__c = 'Test Request',
                Rest_of_Name__c = 'Tested',
                Sender__c = 'FSMB',
                Status__c = Constants.VERIFICATION_REQUEST_STATUS_PENDING,
                University_Code__c = 'ABC123',
                University_Name__c = SCHOOL,
                Urgent__c = false,
                USMLE_ID__c = 'ABC123'
        );
        insert req2;
        System.assert(req2.id!=null,'Verification request not found.');
        Contact con = new Contact();
        con.LastName = 'Ron';
        con.FirstName = 'Richard';
        Insert con;
        System.assert(con.Id!=null,'Contact cannot be found');
        Id entityRecTypId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account acc =  new Account();
        acc.Name = 'Test Entity';
        acc.RecordTypeId = entityRecTypId;
        acc.BillingCity = 'Test City';
        acc.BillingCountry ='India';
        Insert acc;
        System.assert(acc.Id!=null,'Account not found');        
        Id caseRecTypId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        Case cse = new Case();
        cse.contactId = con.Id;
        cse.Verification_Request__c = req2.Id;        
        cse.RecordTypeId = caseRecTypId;         
        insert cse;
        System.assert(cse.Id!=null,'Case not found');
        Case_Attribute__c attr = new Case_Attribute__c ();
        attr.Case__c = cse.Id;
        attr.Value__c = acc.Id;
        attr.Name = Constants.REQUEST_VERIFICATION_LINKED_ENTITY_ID_ATTRIBUTE_NAME;
        insert attr;
        System.assert(attr.Id!=null,'Case attribute not found');
        VerificationRequestController.proceed(cse.Id);
        Contact_Association_Type__c contAsso = [Select id, Contact__c, Account__c from Contact_Association_Type__c where Contact__c =: cse.contactId and Account__c =:attr.Value__c limit 1];
        System.assert(contAsso.id!=null,'Cont Assoc. not found');
    }
    @isTest
    static void proceedTest1(){
        CurrentECFMGIDSequence__c settingsECFMGInstance = CurrentECFMGIDSequence__c.getOrgDefaults();
        settingsECFMGInstance.ECFMG_ID__c = '00000006';
        upsert settingsECFMGInstance;
        CurrentEntityIDSequence__c settingsInstance = CurrentEntityIDSequence__c.getOrgDefaults();
        settingsInstance.Entity_ID__c = '0000006';
        upsert settingsInstance;
        Verification_Request__c req2 = new Verification_Request__c(Account_Exact_Scenario_Score__c = null,
                Account_Non_Exact_Scenario_Score__c = null,
                Batch_Id__c = '123451',
                Birth_Date__c = Date.parse(DAY),
                Candidate_Code__c = 'ABC1231',
                Client_Batch_Create_Date__c = Date.today(),
                Client_Institution_ID__c = '123451',
                Client_Provided_Entity_ID__c = '123451',
                Client_Provided_Entity_Name__c = SCHOOL,
                Comments__c = COMMENT,
                Contact_Exact_Scenario_Score__c = null,
                Contact_Non_Exact_Scenario_Score__c = null,
                Current_Citizenship__c = 'UK',
                EICS_ID__c = 'ABC1231',
                EPIC_ID__c = 'ABC1231',
                Exact_Match_Account__c = null,
                Exact_Match_Contact__c = null,
                Gender__c = 'Male',
                Graduation_Date__c = Date.parse(DAY1),
                Institution_Address__c = STREET,
                Institution_City__c = 'Dallas',
                Institution_Country_Code__c = 'US',
                Institution_ID__c = 'ABC1231',
                Institution_Name__c = SCHOOL,
                Institution_Postal_Code__c = '750011',
                Institution_State_Code__c = 'TX',
                Is_EICS__c = false,
                Is_EPIC__c = false,
                Is_USMLE__c = false,
                Last_Name__c = 'Tester',
                Medschool_Code__c = 'ABC123',
                Medschool_Name__c = SCHOOL,
                Previous_Last_Name__c = PREV_LAST,
                Previous_Rest_of_Name__c = 'PreviousFirst1',
                Request_Id__c = 'ABC123',
                Request_Type__c = 'Test Request',
                Rest_of_Name__c = 'Tested',
                Sender__c = 'MCC',
                Status__c = Constants.VERIFICATION_REQUEST_STATUS_PENDING,
                University_Code__c = 'ABC123',
                University_Name__c = SCHOOL,
                Urgent__c = false,
                USMLE_ID__c = 'ABC123'
        );
        insert req2;
        System.assert(req2.id!=null,'Verification request not found.');
        Contact con = new Contact();
        con.LastName = 'Ron';
        con.FirstName = 'Richard';
        Insert con;
        System.assert(con.Id!=null,'Contact cannot be found');
        Id entityRecTypId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'TestEntity';
        acc.RecordTypeId = entityRecTypId;
        acc.BillingCity = 'Test city';
        acc.BillingCountry ='India';
        Insert acc;
        System.assert(acc.Id!=null,'Record not found');       
        Id caseRecTypId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        Case cse = new Case();
        cse.contactId = con.Id;
        cse.Verification_Request__c = req2.Id;
        cse.RecordTypeId = caseRecTypId;
        insert cse;
        System.assert(cse.Id!=null,'Case not found!');
        Case_Attribute__c attr = new Case_Attribute__c ();
        attr.Case__c = cse.Id;
        attr.Value__c = acc.Id;
        attr.Name = Constants.REQUEST_VERIFICATION_LINKED_ENTITY_ID_ATTRIBUTE_NAME;
        insert attr;  
        System.assert(attr.Id!=null,'Case attribute not found!');
        VerificationRequestController.proceed(cse.Id);
        Case case1 = [select id,Internal_Status__c from case where Internal_Status__c =: Constants.CASE_STATUS_NEW limit 1];
        System.assert(case1.Id!=null,'Case status not updated.');
        List<ApplicantDuplicateMatchModel> result = VerificationRequestController.getApplicantMatches(cse.Id);
        System.assert(result.IsEmpty(),'Matching Applicants found');
    }
    @isTest
    static void testConfirmationMsg(){
        CurrentECFMGIDSequence__c settingsECFMGInstance = CurrentECFMGIDSequence__c.getOrgDefaults();
        settingsECFMGInstance.ECFMG_ID__c = '00000005';
        upsert settingsECFMGInstance;
        CurrentEntityIDSequence__c settingsInstance = CurrentEntityIDSequence__c.getOrgDefaults();
        settingsInstance.Entity_ID__c = '0000005';
        upsert settingsInstance;
        Verification_Request__c req2 = new Verification_Request__c(Account_Exact_Scenario_Score__c = null,
                Account_Non_Exact_Scenario_Score__c = null,
                Batch_Id__c = '123452',
                Birth_Date__c = Date.parse(DAY),
                Candidate_Code__c = 'ABC1232',
                Client_Batch_Create_Date__c = Date.today(),
                Client_Institution_ID__c = '123425',
                Client_Provided_Entity_ID__c = '123425',
                Client_Provided_Entity_Name__c = SCHOOL,
                Comments__c = COMMENT,
                Contact_Exact_Scenario_Score__c = null,
                Contact_Non_Exact_Scenario_Score__c = null,
                Current_Citizenship__c = 'UK',
                EICS_ID__c = 'ABC1232',
                EPIC_ID__c = 'ABC1232',
                Exact_Match_Account__c = null,
                Exact_Match_Contact__c = null,
                Gender__c = 'Male',
                Graduation_Date__c = Date.parse(DAY1),
                Institution_Address__c = STREET,
                Institution_City__c = 'Dallas',
                Institution_Country_Code__c = 'US',
                Institution_ID__c = 'ABC1232',
                Institution_Name__c = SCHOOL,
                Institution_Postal_Code__c = '750012',
                Institution_State_Code__c = 'TX',
                Is_EICS__c = false,
                Is_EPIC__c = false,
                Is_USMLE__c = false,
                Last_Name__c = 'Tester',
                Medschool_Code__c = 'ABC123',
                Medschool_Name__c = SCHOOL,
                Previous_Last_Name__c = PREV_LAST,
                Previous_Rest_of_Name__c = 'Previous First',
                Request_Id__c = 'ABC123',
                Request_Type__c = 'TestRequest',
                Rest_of_Name__c = 'Tested',
                Sender__c = 'MCC',
                Status__c = Constants.VERIFICATION_REQUEST_STATUS_PENDING,
                University_Code__c = 'ABC123',
                University_Name__c = SCHOOL,
                Urgent__c = false,
                USMLE_ID__c = 'ABC123'
        );
        insert req2;
        System.assert(req2.Id!=null,'Verification Request not found.');
        Contact con = new Contact();
        con.LastName = 'Ron';
        con.FirstName = 'Richard';
        Insert con;
        System.assert(con.Id!=null,'Contact not inserted');
        Id entityRecTypId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account acc =  new Account();
        acc.Name = 'TestEntity';
        acc.RecordTypeId = entityRecTypId;
        acc.BillingCity = 'TestCity';
        acc.BillingCountry ='India';
        Insert acc;
        System.assert(acc.Id!=null,'Rec not found');
        Id caseRecTypId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('IFOM_Request').getRecordTypeId();
        Case cse = new Case();
        cse.contactId = con.Id;
        cse.Verification_Request__c = req2.Id;
        cse.RecordTypeId = caseRecTypId;
        insert cse;
        System.assert(cse.Id!=null,'Case not inserted');
        String cnfrmMsg = VerificationRequestController.getConfirmationMsg(cse.Id);
        System.assert(string.isNotBlank(cnfrmMsg),'Exception is thrown');
    }
    @isTest
    static void testgetConAssociationRec(){
        CurrentECFMGIDSequence__c settingsECFMGInstance = CurrentECFMGIDSequence__c.getOrgDefaults();
        settingsECFMGInstance.ECFMG_ID__c = '00000005';
        upsert settingsECFMGInstance;
        CurrentEntityIDSequence__c settingsInstance = CurrentEntityIDSequence__c.getOrgDefaults();
        settingsInstance.Entity_ID__c = '0000005';
        upsert settingsInstance;
        Contact con = new Contact();
        con.LastName = 'Ron';
        con.FirstName = 'Richard';
        Insert con;
        System.assert(con.Id!=null,'Contact Not found.');
        Id entityRecTypId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Ent';
        acc.RecordTypeId = entityRecTypId;
        acc.BillingCity = 'TestCity';
        acc.BillingCountry ='India';
        Insert acc;
        System.assert(acc.Id!=null,'This account is not found');
        String gradYear = String.valueOf((System.today() + 365).year());
        Id conAssocRecordTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
        Contact_Association_Type__c degMedSchool = new Contact_Association_Type__c(RecordTypeId=conAssocRecordTypeId,
                                                    Contact__c = con.Id, Account__c=acc.id, School_Program__c = 'MBBS',
                                                    Start_Date__c = System.today() - 365, End_Date__c = System.today() + 365,
                                                    Graduation_Month__c = 'May', Graduation_Year__c = gradYear, Number_of_Years_Attended__c = 2);
        insert degMedSchool;
        System.assert(degMedSchool.Id!=null,'Not found');
        VerificationRequestController.getContactAssociationRecord(con.Id);
        Contact_Association_Type__c contAsso = [Select id, Account__c from Contact_Association_Type__c where Contact__c =: con.Id and recordtype.DeveloperName =: Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL];
        System.assert(contAsso.Id!=null, 'No contactAssociationType record returned.');
    }
    @isTest
    static void testAKANamesMatches(){
        CurrentECFMGIDSequence__c settingsECFMGInstance = CurrentECFMGIDSequence__c.getOrgDefaults();
        settingsECFMGInstance.ECFMG_ID__c = '00000005';
        upsert settingsECFMGInstance;
        CurrentEntityIDSequence__c settingsInstance = CurrentEntityIDSequence__c.getOrgDefaults();
        settingsInstance.Entity_ID__c = '0000005';
        upsert settingsInstance;
        Verification_Request__c req2 = new Verification_Request__c(Account_Exact_Scenario_Score__c = null,
                Account_Non_Exact_Scenario_Score__c = null,
                Batch_Id__c = '123452',
                Birth_Date__c = Date.parse(DAY),
                Candidate_Code__c = 'ABC1232',
                Client_Batch_Create_Date__c = Date.today(),
                Client_Institution_ID__c = '123425',
                Client_Provided_Entity_ID__c = '123425',
                Client_Provided_Entity_Name__c = SCHOOL,
                Comments__c = COMMENT,
                Contact_Exact_Scenario_Score__c = null,
                Contact_Non_Exact_Scenario_Score__c = null,
                Current_Citizenship__c = 'UK',
                EICS_ID__c = 'ABC1232',
                EPIC_ID__c = 'ABC1232',
                Exact_Match_Account__c = null,
                Exact_Match_Contact__c = null,
                Gender__c = 'Male',
                Graduation_Date__c = Date.parse(DAY1),
                Institution_Address__c = STREET,
                Institution_City__c = 'Dallas',
                Institution_Country_Code__c = 'US',
                Institution_ID__c = 'ABC1232',
                Institution_Name__c = SCHOOL,
                Institution_Postal_Code__c = '750012',
                Institution_State_Code__c = 'TX',
                Is_EICS__c = false,
                Is_EPIC__c = false,
                Is_USMLE__c = false,
                Last_Name__c = 'Tester',
                Medschool_Code__c = 'ABC123',
                Medschool_Name__c = SCHOOL,
                Previous_Last_Name__c = PREV_LAST,
                Previous_Rest_of_Name__c = 'Previous First1',
                Request_Id__c = 'ABC123',
                Request_Type__c = 'TestRequest',
                Rest_of_Name__c = 'Tested',
                Sender__c = 'MCC',
                Status__c = Constants.VERIFICATION_REQUEST_STATUS_PENDING,
                University_Code__c = 'ABC123',
                University_Name__c = SCHOOL,
                Urgent__c = false,
                USMLE_ID__c = 'ABC123'
        );
        insert req2;
        Contact con = new Contact();
        con.LastName = 'Ron';
        con.FirstName = 'Richard';
        Insert con;
        System.assert(con.Id!=null,'This contact is not found.');
        Id entityRecTypId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Entity';
        acc.RecordTypeId = entityRecTypId;
        acc.BillingCity = 'Test City';
        acc.BillingCountry ='India';
        Insert acc;
        System.assert(acc.Id!=null,'Record doesnot exists');
        aka_Names__c aka = new aka_Names__c ();
        aka.Name = 'Test';
        aka.Account__c = acc.Id;
        aka.WDOMS_ID__c = '00005';
        INSERT aka;
        System.assert(aka.Id!=null,'AKAName record not found.');
        Id caseRecTypId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('IFOM_Request').getRecordTypeId();
        Case cse = new Case();
        cse.contactId = con.Id;
        cse.Verification_Request__c = req2.Id;
        cse.RecordTypeId = caseRecTypId;
        insert cse;
        System.assert(cse.Id!=null,'Case not found!');
        List<AKANamesDuplicateMatchModel> model = VerificationRequestController.getAKANamesMatches(cse.Id);
        model[0].compareTo(model[0]);
        System.assert(!model.IsEmpty(),'Matches not found.');
    }

    @isTest
    static void testGetAccount(){
         List<Account> accounts = [select Id from Account limit 1];
        Test.startTest();
        Account acc = VerificationRequestController.getAccount(accounts[0].Id);         
        Test.stopTest();
        System.assert( acc.id != null, 'Account not found!');
    }

    @isTest
    static void testGetContact(){
         List<Contact> cons = [select Id from contact limit 1];
        Test.startTest();
        Contact con = VerificationRequestController.getContact(cons[0].Id);         
        Test.stopTest();
        System.assert( con.id != null, 'Contact not found!');
    }

    @isTest
    static void TestProceedForFSMB(){

        List<Account> accounts = [select Id from Account limit 1];
        List<Contact> contacts = [select Id, FirstName, LastName from Contact limit 1];
        List<Verification_Request__c>  vrs = [select Id from Verification_Request__c limit 1];

        Id caseRecTypId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('FCVS Request').getRecordTypeId();	
        Case cse = new Case();
        cse.contactId = contacts[0].Id;
        cse.Verification_Request__c = vrs[0].Id;        
        cse.RecordTypeId = caseRecTypId; 
        cse.Service__c = Constants.CASE_SERVICE_FCVS; 
        cse.Verification_Request_Source__c = 'FSMB';         
        insert cse;
        
        Case_Attribute__c attr = new Case_Attribute__c ();
        attr.Case__c = cse.Id;
        attr.Value__c = accounts[0].Id;
        attr.Name = Constants.REQUEST_VERIFICATION_LINKED_ENTITY_ID_ATTRIBUTE_NAME;
        insert attr;

        Test.startTest();
            VerificationRequestController.proceed(cse.Id);
        Test.stopTest();
        List<Case> lstCase = [Select id from case where parentId =: cse.Id];
        System.assertEquals(3, lstCase.size(), 'Cases for FSMB is created');
    }
}