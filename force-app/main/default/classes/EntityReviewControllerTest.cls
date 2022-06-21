@isTest
public with sharing class EntityReviewControllerTest{
    public static final String CON_ACC_ROLE = 'User';
    public static final string AFF_STATUS = 'In Progress';
    @testSetup static void setup(){
        CurrentECFMGIDSequence__c curECFMGSetting = CurrentECFMGIDSequence__c.getOrgDefaults();
        curECFMGSetting.ECFMG_ID__c = '00000001';
        upsert curECFMGSetting;
        CurrentEntityIDSequence__c curEntitySetting = CurrentEntityIDSequence__c.getOrgDefaults();
        curEntitySetting.Entity_ID__c = '0000000';
        upsert curEntitySetting;
        WDOMS_ID_Sequence__c wdomsIdSeq = WDOMS_ID_Sequence__c.getOrgDefaults();
        wdomsIdSeq.AKA_ID__c = 1000;
        upsert wdomsIdSeq;
    }
    @IsTest
    public static void testGetEntityFields(){
        Id applRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_APPLICANT ).getRecordTypeId();
        Account newApplAcct = new Account();
        newApplAcct.Name = 'User abc';
        newApplAcct.BillingCountry='India';
        INSERT newApplAcct;
        System.assert(newApplAcct.Id!=null,'Applicant account not creted');
        Id entityRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account mainAcc = new Account();
        mainAcc.Name = 'UserAccount1';
        mainAcc.RecordTypeId = entityRecordType;
        mainAcc.BillingCountry='India';
        INSERT mainAcc;
        System.assert(mainAcc.Id!=null,'Parent account not found');
        Account acc = new Account();
        acc.Name = 'TestAccount1';
        acc.Internal_Instructions__c = 'This is Test account';
        acc.Parent_Entity__c = mainAcc.Id;
        acc.Alternative_Name__c = 'TA';
        acc.RecordTypeId = entityRecordType;
        acc.BillingCountry='India';
        INSERT acc;
        System.assert(acc.Id!=null,'Test account not found');
        Contact con = new Contact();
        con.AccountId = newApplAcct.Id;
        con.LastName = 'Test';
        con.Email = 'test21@test.com';
        con.RecordTypeId = applRecTypeId;
        INSERT con;
        Contact con1 = new Contact();
        con1.AccountId = newApplAcct.Id;
        con1.LastName = 'Test1';
        con1.Email = 'test211@test.com';
        con1.RecordTypeId = applRecTypeId;
        INSERT con1;
        System.assert(con.Id!=null,'Contact not found!');
        Id profId1 = [Select id from profile where name= '4-Customer Community Plus Login' LIMIT 1].id;
        User user2 = new User(alias = 'testUsr1',
                              email = 'test22@test.com',
                              emailencodingkey = 'UTF-8',
                              lastname = 'Test user',
                              languagelocalekey = 'en_US',
                              localesidkey = 'en_US',
                              profileid = profId1,
                              country = 'United States',
                              IsActive = true,
                              ContactId = con.Id,
                              timezonesidkey = 'America/Los_Angeles',
                              username = 'testUser1@test.com');
        INSERT user2;
        User user3 = new User(alias = 'testUsr2',
                              email = 'test221@test.com',
                              emailencodingkey = 'UTF-8',
                              lastname = 'Test user1',
                              languagelocalekey = 'en_US',
                              localesidkey = 'en_US',
                              profileid = profId1,
                              country = 'United States',
                              IsActive = true,
                              ContactId = con1.Id,
                              timezonesidkey = 'America/Los_Angeles',
                              username = 'testUser11@test.com');
        INSERT user3;      
        Id credVerRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION ).getRecordTypeId();
        Case newCase = new Case();
        newCase.RecordTypeId = credVerRecTypeId;
        newCase.ContactId = con.Id;
        newCase.AccountId = newApplAcct.Id;
        newCase.Service__c = Constants.CASE_SERVICE_EPIC;
        INSERT newCase;
        System.assert(newCase.Id!=null,'Case not created.');
        Case parentCase = new Case();
        parentCase.RecordTypeId = Constants.ECFMG_CERTIFICATE_RDTYPEID;
        parentCase.ContactId = con.Id;
        parentCase.AccountId = newApplAcct.Id;
        parentCase.Service__c = Constants.CASE_SERVICE_EPIC;
        parentCase.ParentId = newCase.Id;
        parentCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_REVIEW;
        INSERT parentCase;
        System.assert(parentCase.Id!=null,'Case not created.');
        Case newCase1 = new Case();
        newCase1.RecordTypeId = credVerRecTypeId;
        newCase1.ContactId = con.Id;
        newCase1.AccountId = newApplAcct.Id;
        newCase1.Service__c = Constants.CASE_SERVICE_EPIC;
        newCase1.ParentId = parentCase.Id;
        INSERT newCase1;
        System.assert(newCase1.Id!=null,'Case not created.');
        Asset assetRec = new Asset();
        assetRec.Name = 'test';
        assetRec.Case__c = newCase1.Id;
        assetRec.ContactId = newCase1.ContactId;
        assetRec.Type__c = Constants.CASE_DOC_TYPE_FINAL_MED_DIPLOMA;
        INSERT assetRec;
        System.assert(assetRec.Id!=null,'Asset not created.');
        Id catsCredRecTypeId =Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_CREDENTIAL_INTAKE).getRecordTypeId();
        Contact_Association_Type_Staging__c newCats = new Contact_Association_Type_Staging__c();
        newCats.Contact__c = con.Id;
        newCats.Account__c = acc.Id;
        newCats.Case__c = newCase.Id;
        newCats.RecordTypeId = catsCredRecTypeId;
        newCats.Credential_Type__c= 'Advanced Degree in the Medical Sciences';
        INSERT newCats;
        System.assert(newCats.Id!=null, 'CATS recs not found');
        Contact_Association_Type__c newCats1 = new Contact_Association_Type__c();
        newCats1.Contact__c = con.Id;
        newCats1.Account__c = acc.Id;
        newCats1.Case__c = newCase1.Id;
        newCats1.Credential_Type__c= Constants.CASE_DOC_TYPE_FINAL_MED_DIPLOMA;
        INSERT newCats1;
        System.assert(newCats1.Id!=null,'CATS recs not found');
        assetRec.Contact_Association_Type__c = newCats1.Id;
        UPDATE assetRec;
        Case parentCase2 = new Case();
        parentCase2.RecordTypeId = Constants.ENTITY_SERVICE_REQUEST_RDTYPEID;
        parentCase2.ContactId = con.Id;
        parentCase2.AccountId = newApplAcct.Id;
        INSERT parentCase2;
        System.assert(parentCase2.Id!=null,'Case not created.');
        Case newCase2 = new Case();
        newCase2.RecordTypeId = Constants.ENTITY_SERVICE_REQUEST_RDTYPEID;
        newCase2.ContactId = con.Id;
        newCase2.AccountId = newApplAcct.Id;
        newCase2.Service__c = Constants.CASE_SERVICE_EPIC;
        newCase2.ParentId = parentCase2.Id;
        INSERT newCase2;
        System.assert(newCase2.Id!=null,'Case not created.');
        Contact_Association_Type_Staging__c newCats2 = new Contact_Association_Type_Staging__c();
        newCats2.Contact__c = con.Id;
        newCats2.Account__c = acc.Id;
        newCats2.Case__c = newCase2.Id;
        newCats2.RecordTypeId = catsCredRecTypeId;
        newCats2.Credential_Type__c= 'Advanced Degree in the Medical Sciences';
        INSERT newCats2;
        System.assert(newCats2.Id!=null, 'CATS recs not found');
        Test.startTest();
        System.runAs(user2){
            EntityReviewController.EntityCatStagWrapper returnCats =EntityReviewController.getEntityFields(newCase.Id);
            System.assert(returnCats.key!=null,'Record not found');
            returnCats =EntityReviewController.getEntityFields(newCase1.Id);
            System.assert(returnCats.key!=null,'Record not found');
        }
        System.runAs(user3){
            EntityReviewController.EntityCatStagWrapper returnCats1 =EntityReviewController.getEntityFields(newCase2.Id);
            System.assert(returnCats1.key!=null,'Record not found');
        }
        Test.stopTest();
    }
    @IsTest
    public static void testGetEntityFieldsCase(){
        Contact contact = BaseTestFactory.getContact();
        Account newApplAcct = new Account();
        newApplAcct.Name = 'User abc Account';
        newApplAcct.BillingCountry = 'India';
        INSERT newApplAcct;
        System.assert(newApplAcct.Id!=null,'Applicant account not creted');
        Id entityRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account mainAcc = new Account();
        mainAcc.Name = 'UserAccount1';
        mainAcc.RecordTypeId = entityRecordType;
        mainAcc.BillingCountry = 'India';
        INSERT mainAcc;
        System.assert(mainAcc.Id!=null,'Parent account not found');
        Account acc = new Account();
        acc.Name = 'TestAccount1';
        acc.Internal_Instructions__c = 'This is Test account';
        acc.Parent_Entity__c = mainAcc.Id;
        acc.Alternative_Name__c = 'TA';
        acc.RecordTypeId = entityRecordType;
        acc.BillingCountry = 'India';
        INSERT acc;
        System.assert(acc.Id!=null,'Test account not found');
        Id medEducFormRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_MED_EDU_FORM).getRecordTypeId();
        Case newCase = new Case();
        newCase.RecordTypeId = medEducFormRecTypeId;
        newCase.ContactId = contact.Id;
        newCase.AccountId = newApplAcct.Id;
        newCase.Document_Type__c = Constants.CASE_DOCUMENT_TYPE_MED_EDU_FORM;
        newCase.Internal_Status__c = Constants.CASE_STATUS_NEW;
        INSERT newCase;
        System.assert(newCase.Id!=null,'Case not created.');
        Test.startTest();
        Case returnCase =EntityReviewController.getEntityFieldsCase(newCase.Id);
        System.assert(returnCase.Id!=null,'Record not found');
        Test.stopTest();
    }

    @IsTest
    public static void testGetAuthority(){
        Id applRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_APPLICANT ).getRecordTypeId();
        Account newApplAcct = new Account();
        newApplAcct.Name = 'UserX abc';
        newApplAcct.BillingCountry = 'India';
        INSERT newApplAcct;
        System.assert(newApplAcct.Id!=null,'Applicant account not creted');
        Id entityRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account mainAcc = new Account();
        mainAcc.Name = 'Main Account';
        mainAcc.RecordTypeId = entityRecordType;
        mainAcc.BillingCountry = 'India';
        INSERT mainAcc;
        System.assert(mainAcc.Id!=null,'Parent Account not found');
        Account acc = new Account();
        acc.Name = 'TestAccount2';
        acc.Internal_Instructions__c = 'This is test account';
        acc.Alternative_Name__c = 'TA';
        acc.RecordTypeId = entityRecordType;
        acc.BillingCountry = 'India';
        INSERT acc;
        System.assert(acc.Id!=null,'Test account not found');
        Contact con = new Contact();
        con.AccountId = newApplAcct.Id;
        con.LastName = 'Test';
        con.Email = 'test2@test.com';
        con.RecordTypeId = applRecTypeId;
        INSERT con;
        System.assert(con.Id!=null,'Contact not found');
        Id credVerRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION ).getRecordTypeId();
        Case newCase = new Case();
        newCase.RecordTypeId = credVerRecTypeId;
        newCase.ContactId = con.Id;
        newCase.AccountId = newApplAcct.Id;
        newCase.Service__c = Constants.CASE_SERVICE_EPIC;
        INSERT newCase;
        System.assert(newCase.Id!=null,'Case not created');
        Id catsCredRecTypeId =Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_CREDENTIAL_INTAKE).getRecordTypeId();
        Contact_Association_Type_Staging__c newCats = new Contact_Association_Type_Staging__c();
        newCats.Contact__c = con.Id;
        newCats.Account__c = acc.Id;
        newCats.Case__c = newCase.Id;
        newCats.RecordTypeId = catsCredRecTypeId;
        newCats.Credential_Type__c= 'Advanced Degree in the Medical Sciences';
        INSERT newCats;
        System.assert(newCats.Id!=null,'CATS record not found');
        Case epVer =  new Case();
        epVer.Secondary_Parent_Case__c = newCase.Id;
        epVer.Entity__c = mainAcc.Id;
        epVer.ContactId = con.Id;
        INSERT epVer;
        Test.startTest();
		Case retEpVer = EntityReviewController.getAuthority(newCase.Id);
        System.assert(retEpVer.Id!=null,'No authority');
     	Test.stopTest();
    }
    @IsTest
    public static void testgetSpecInst(){
        Id entityRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Internal_Instructions__c = 'This is test account';
        acc.Alternative_Name__c = 'TA';
        acc.RecordTypeId = entityRecordType;
        acc.EPIC_Client_Special_Instructions_Languag__c = 'Read these instructions..';
        acc.BillingCountry = 'India';
        INSERT acc;
        Test.startTest();
        String specInstructions =EntityReviewController.getSpecInstruction(acc.Id);
        System.assert(specInstructions!=null,'Special Instructions not mentioned');
        Test.stopTest();
    }
    @IsTest
    public static void testgetActiveEntities(){
        Id entityRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account mainAcc = new Account();
        mainAcc.Name = 'Main Account';
        mainAcc.RecordTypeId = entityRecordType;
        mainAcc.BillingCountry = 'India';
        INSERT mainAcc;
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.RecordTypeId = entityRecordType;
        acc.BillingCountry = 'India';
        INSERT acc;
        Test.startTest();
        List<Account> entities = EntityReviewController.getActiveEntities();
        System.assert(entities[0].Id!=null,'no active entities found');
        Test.stopTest();
    }
    @IsTest
    public static void testgetCaseDet(){
        Account newApplAcct = new Account();
        newApplAcct.Name = 'abc tester';
        newApplAcct.BillingCountry = 'India';
        INSERT newApplAcct;
        System.assert(newApplAcct.Id!=null,'Applicant account not created');
        Id applRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_APPLICANT ).getRecordTypeId();
        Contact con = new Contact();
        con.AccountId = newApplAcct.Id;
        con.LastName = 'Test';
        con.Email = 'test1@test.com';
        con.RecordTypeId = applRecTypeId;
        INSERT con;
        Id credVerRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION ).getRecordTypeId();
        Case newCase = new Case();
        newCase.RecordTypeId = credVerRecTypeId;
        newCase.ContactId = con.Id;
        newCase.AccountId = newApplAcct.Id;
        newCase.Service__c = Constants.CASE_SERVICE_EPIC;
        INSERT newCase;
        System.assert(newCase.Id!=null,'Case not found!');
        Test.startTest();
        Case case1 = EntityReviewController.getCaseDetails(newCase.Id);
        System.assert(case1.Id!=null,'Case1 is not found');
        Test.stopTest();
    }
    @IsTest
    public static void testgetAsset(){
        Id credIntakeCatRecTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_CREDENTIAL_INTAKE).getRecordTypeId();
        Id credVerRecTypId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        Id credRecTypId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_CREDENTIAL).getRecordTypeId();
        Account acc3 = new Account();
        acc3.Name = 'Test Account2';
        acc3.BillingCountry = 'India';
        INSERT acc3;
		Id applRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_APPLICANT ).getRecordTypeId();
        Contact con = new Contact();
        con.AccountId = acc3.Id;
        con.LastName = 'Test';
        con.Email = 'test1@test1.com';
        con.RecordTypeId = applRecTypeId;
        INSERT con;
        System.assert(acc3.Id != null, 'Account 3 creation failed');
        Case credVerCase = new Case();
        credVerCase.RecordTypeId = credVerRecTypId;
        credVerCase.ContactId = con.Id;
        credVerCase.Internal_Status__c = Constants.CASE_STATUS_NEW;
        INSERT credVerCase;
        System.assert(credVerCase.Id != null, 'credVerCase creation failed');
        Contact_Association_Type_Staging__c catStag3 = new Contact_Association_Type_Staging__c();
        catStag3.Contact__c = con.Id;
        catStag3.Case__c = credVerCase.Id;
        catStag3.Account__c = acc3.Id;
        catStag3.RecordTypeId = credIntakeCatRecTypeId;
        catStag3.Issue_Date__c = Date.newInstance(2020, 10, 20);
        catStag3.Title__c = 'MD';
        catStag3.Credential_Type__c = Constants.ASSET_TYPE_SPECIALIST_QUALIFICATION;
        INSERT catStag3;
        System.assert(catStag3.Id != null, 'catStag3 creation failed');
        Asset asst1 = new Asset();
        asst1.Name = Constants.ASSET_TYPE_SPECIALIST_QUALIFICATION;
        asst1.Status = Constants.ASSET_STATUS_IN_PROGRESS;
        asst1.contactId = con.Id;
        asst1.Case__c =credVerCase.Id;
        asst1.ParentId =NULL;
        asst1.Name_On_Document__c ='test';
        asst1.Type__c = Constants.ASSET_TYPE_SPECIALIST_QUALIFICATION;
        asst1.Contact_Association_Type_Staging__c = catStag3.Id;
        asst1.RecordTypeId = credRecTypId;
        insert asst1;
        System.assert(asst1.Id != null, 'asst1 creation failed');
        Test.startTest();
		asst1  = EntityReviewController.getAsset(credVerCase.Id);
	    System.assert(asst1.Id !=null,'asst1 is not found');
		Boolean upnod= EntityReviewController.updateAssetNOD(asst1.Id,credVerCase.Id);
        System.assert(upnod != false, 'asset is not updated');
		Test.stopTest();
    }
    @IsTest
    public static void testUpdateEntityValuesCaseRec(){
        Contact contact = BaseTestFactory.getContact();        
        Account newApplAcct = new Account();
        newApplAcct.Name = 'UserX abc';
        newApplAcct.BillingCountry = 'India';
        INSERT newApplAcct;
        System.assert(newApplAcct.Id!=null,'Applicant account not created');
        Id entityRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Account1';
        acc.BillingCountry = 'India';
        acc.RecordTypeId = entityRecordType;
        INSERT acc;
        System.assert(acc.Id!=null,'Test Account not found');
        Id credVerRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION ).getRecordTypeId();
        Id medEducFormRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_MED_EDU_FORM).getRecordTypeId();
        Case newCase = new Case();
        newCase.RecordTypeId = medEducFormRecTypeId;
        newCase.ContactId = contact.Id;
        newCase.AccountId = newApplAcct.Id;
        newCase.Document_Type__c = Constants.CASE_DOCUMENT_TYPE_MED_EDU_FORM;
        newCase.Internal_Status__c = Constants.CASE_STATUS_NEW;
        INSERT newCase;
        System.assert(newCase.Id!=null,'New Case not created');
        Account newEnt = new Account();
        newEnt.Name = 'Entity1';
        newEnt.BillingCountry = 'India';
        INSERT newEnt;
        Account altEnt = new Account();
        altEnt.Name = 'Entity2';
        altEnt.BillingCountry = 'India';
        INSERT altEnt;
        Test.startTest();
        Boolean upd = EntityReviewController.updateEntityValuesCaseRec(newCase.Id, newEnt.Id, altEnt.Id);
        System.assert(upd!=false,'Couldnot update the CASE record');
        Test.stopTest();
    }

    @IsTest
    public static void testUpdateEntityVal(){
        Id applRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_APPLICANT ).getRecordTypeId();
        Account newApplAcct = new Account();
        newApplAcct.Name = 'UserX abc';
        newApplAcct.BillingCountry = 'India';
        INSERT newApplAcct;
        System.assert(newApplAcct.Id!=null,'Applicant account not created');
        Id entityRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Account1';
        acc.RecordTypeId = entityRecordType;
        acc.BillingCountry = 'India';
        INSERT acc;
        System.assert(acc.Id!=null,'Test Account not found');
        Contact con = new Contact();
        con.AccountId = newApplAcct.Id;
        con.LastName = 'Test';
        con.Email = 'test1@test.com';
        con.RecordTypeId = applRecTypeId;
        INSERT con;
        System.assert(con.Id!=null,'Contact not found');
        Id profId1 = [Select id from profile where name= '4-Customer Community Plus Login' LIMIT 1].id;
        User user2 = new User(alias = 'testUsr1',
                              email = 'test2@test.com',
                              emailencodingkey = 'UTF-8',
                              lastname = 'test user',
                              languagelocalekey = 'en_US',
                              localesidkey = 'en_US',
                              profileid = profId1,
                              country = 'United States',
                              IsActive = true,
                              ContactId = con.Id,
                              timezonesidkey = 'America/Los_Angeles',
                              username = 'testUserapp@test.com');
        INSERT user2;     
        Id credVerRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION ).getRecordTypeId();
        Case newCase = new Case();
        newCase.RecordTypeId = credVerRecTypeId;
        newCase.ContactId = con.Id;
        newCase.AccountId = newApplAcct.Id;
        newCase.Service__c = Constants.CASE_SERVICE_EPIC;
        INSERT newCase;
        System.assert(newCase.Id!=null,'New Case not created');
        Id catsCredRecTypeId =Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_CREDENTIAL_INTAKE).getRecordTypeId();
        Contact_Association_Type_Staging__c newCats = new Contact_Association_Type_Staging__c();
        newCats.Contact__c = con.Id;
        newCats.Account__c = acc.Id;
        newCats.Case__c = newCase.Id;
        newCats.RecordTypeId = catsCredRecTypeId;
        newCats.Credential_Type__c= 'Certificate of Good Standing';
        INSERT newCats;
        System.assert(newCats.Id!=null,'CATS record not found');
        Account newEnt = new Account();
        newEnt.Name = 'Entity1';
        newEnt.BillingCountry = 'India';
        INSERT newEnt;
        Account altEnt = new Account();
        altEnt.Name = 'Entity2';
        altEnt.BillingCountry = 'India';
        INSERT altEnt;
        Test.startTest();
        System.runAs(user2){
            Boolean upd = EntityReviewController.updateEntityValues(newCats.Id, newEnt.Id, altEnt.Id);
            System.assert(upd!=false,'Couldnot update the CATS record');
        }
        Test.stopTest();
    }
    @IsTest
    public static void testGetCountryInst(){
        String countryName='United States';
        Test.startTest();
        String countryInst = EntityReviewController.getCountryInst(countryName);
        System.assert(countryInst != null,'Instructions are empty');
        Test.stopTest();
    }
    
    @IsTest
    public static void testGetAKANames(){
        Id entityRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_DEV_ENTITY).getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Account3';
        acc.RecordTypeId = entityRecordType;
        acc.BillingCountry = 'India';
        INSERT acc;
        System.assert(acc.Id!=null,'Account not found');
        aka_Names__c newAka = new aka_Names__c();
        newAka.Account__c = acc.Id;
        newAka.Name = 'TA3';
        INSERT newAka;

        aka_Names__c newAka1 = new aka_Names__c();
        newAka1.Account__c = acc.Id;
        newAka1.Name = 'TA4';
        newAka1.Year_From__c = '1997';
        newAka1.Year_From__c = '2022';
        INSERT newAka1;

        Test.startTest();
        List<String> akaNamelist = EntityReviewController.getAKANames(acc.Id);
        System.assert(!akaNamelist.isEmpty(),'List is empty');
        Test.stopTest();
    }
    @isTest static void getDefaultSendMethodPaperTest(){
        String email1 = 'testUser@gmail.com';
        String documentType = Constants.CREDENTIAL_TYPE_CGS;
        Id idAccountTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account acct = new Account(Name = 'Entity Account', RecordTypeId = idAccountTypeId, School__c = true, BillingCountry = 'India');
        insert acct;
        System.assert(acct.Id!=null, 'Entity not created');
        Account acct1 = new Account(Name = 'Alternate Entity Account', RecordTypeId = idAccountTypeId, School__c = true, BillingCountry = 'India');
        insert acct1;
        System.assert(acct1.Id!=null, 'Alternate Entity not created');
        Id idContactTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Entity_Contact').getRecordTypeId();
        Contact con = new Contact(FirstName = 'Entity', LastName = 'User', RecordTypeId = idContactTypeId, Email = email1, AccountId = acct.Id);
        insert con;
        System.assert(con.Id!=null, 'New Contact not created');
        Contact con1 = new Contact(FirstName = 'Entity 1', LastName = 'User 1', RecordTypeId = idContactTypeId, Email = email1, AccountId = acct1.Id);
        insert con1;
        System.assert(con1.Id!=null, 'Contact 1 not created');
        List<Service__c> myServiceList = new List<Service__c>();
        Service__c serv = new Service__c(Name = Constants.SERVICE_NAME_CREDENTIAL_VERIFICATION);
        myServiceList.add(serv);
        insert myServiceList;
        System.assert(myServiceList[0].Id!=null, 'Service not created');
        Id credVerRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION ).getRecordTypeId();
        Case newCase = new Case();
        newCase.RecordTypeId = credVerRecTypeId;
        newCase.ContactId = con.Id;
        newCase.AccountId = acct.Id;
        newCase.Entity__c = acct.Id;
        newCase.Alternate_Entity__c = acct1.Id;
        newCase.Document_Type__c = documentType;
        newCase.Service__c = Constants.CASE_SERVICE_EPIC;
        insert newCase;
        System.assert(newCase.Id!=null, 'NewCase not created.');
        String affirRecordTypeID = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get(Constants.AFFIRMATION_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();		
        Affirmation__c credVerfAffir = new Affirmation__c();
        credVerfAffir.Verify_with_Alternate_Entity__c = false;
        credVerfAffir.Status__c = AFF_STATUS;
        credVerfAffir.Case__c = newCase.Id;
        credVerfAffir.RecordTypeId = affirRecordTypeID;
        insert credVerfAffir;
        System.assert(credVerfAffir.Id!=null, 'Affirmation not created.');
        List<Account2Service__c> myAccServList = new List<Account2Service__c>();
        Account2Service__c acc2Service = new Account2Service__c(Account__c = acct.Id, Active__c = false, Service__c = serv.Id);
        myAccServList.add(acc2Service);
        insert myAccServList; 
        System.assert(myAccServList[0].Id!=null, 'Acc2Service is not created');
        test.startTest();
        CONTACT2ACCTSERVICE__c conAccServiceObj = new CONTACT2ACCTSERVICE__c();
        conAccServiceObj.Role__c = CON_ACC_ROLE;
        conAccServiceObj.Preferred_mode_of_communication__c = 'Paper';
        conAccServiceObj.Physical_Address__c = 'Test Address';
        conAccServiceObj.List_of_emails__c = '';
        conAccServiceObj.Verification_Website_URL__c = '';
        conAccServiceObj.Credential_Type__c = documentType;
        conAccServiceObj.Account_Service__c = acc2Service.Id;
        conAccServiceObj.Service_Contact__c = con.Id;
        conAccServiceObj.Active__c = true;
        conAccServiceObj.City__c = 'test city';
        conAccServiceObj.Street__c = 'test street';
        conAccServiceObj.Country__c = 'United States';
        conAccServiceObj.State__c = 'Alaska';
        conAccServiceObj.Postal_Code__c = 'test111';
        insert conAccServiceObj;
        System.assert(conAccServiceObj.Id!=null, 'Contact2Acc Service is not created');
        String defaultSendMethod = EntityReviewController.getDefaultSendMethod(newCase.Id);
        System.assert(defaultSendMethod == 'Paper', 'Default Send Method is not Paper');
        test.stopTest();
    }
    @isTest static void getDefaultSendMethodEntityPortalTest(){
        String email1 = 'testUser@gmail.com';
        String documentType = 'Certificate of Good Standing';
        Id idAccountTypeId = GenericUtilities.getRecordTypeIdByDevName('Account',Constants.ACCOUNT_RECORD_TYPE_DEV_ENTITY);
        Account acct = new Account(Name = 'Entity Account', RecordTypeId = idAccountTypeId, School__c = true, BillingCountry='India');
        insert acct;
        System.assert(acct.Id!=null, 'Entity not created');
        Account acct1 = new Account(Name = 'Alternate Entity Account', RecordTypeId = idAccountTypeId, School__c = true, BillingCountry='India');
        insert acct1;
        System.assert(acct1.Id!=null, 'Alternate Entity not created');
        Id idContactTypeId = GenericUtilities.getRecordTypeIdByDevName('Contact',Constants.CONTACT_RECORD_TYPE_ENTITY_CONTACT);
        Contact con = new Contact(FirstName = 'Entity Con', LastName = 'User Con', RecordTypeId = idContactTypeId, Email = email1, AccountId = acct.Id);
        insert con;
        System.assert(con.Id!=null, 'Contact not created');
        Contact con1 = new Contact(FirstName = 'Entity 1', LastName = 'User 1', RecordTypeId = idContactTypeId, Email = email1, AccountId = acct1.Id);
        insert con1;
        System.assert(con1.Id!=null, 'Contact not created');
        List<Service__c> myServiceList = new List<Service__c>();
        Service__c serv = new Service__c(Name = Constants.SERVICE_NAME_CREDENTIAL_VERIFICATION);
        Service__c serv1 = new Service__c(Name = Constants.SERVICE_NAME_MEDICAL_EDU_FORM);
        myServiceList.add(serv);
        myServiceList.add(serv1);
        insert myServiceList;
        System.assert(serv.Id!=null && serv1.Id!=null, 'Service not created');
        Id credVerRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION);
        Case newCase = new Case();
        newCase.RecordTypeId = credVerRecTypeId;
        newCase.ContactId = con.Id;
        newCase.AccountId = acct.Id;
        newCase.Entity__c = acct.Id;
        newCase.Alternate_Entity__c = acct1.Id;
        newCase.Document_Type__c = documentType;
        newCase.Service__c = Constants.CASE_SERVICE_EPIC;
        insert newCase;
        System.assert(newCase.Id!=null, 'NewCase 1 not created.');
        String affirRecordTypeID = GenericUtilities.getRecordTypeIdByDevName('Affirmation__c',Constants.AFFIRMATION_RECORD_TYPE_CREDENTIAL_VERIFICATION);
        Affirmation__c credVerfAffir = new Affirmation__c();
        credVerfAffir.Verify_with_Alternate_Entity__c = false;
        credVerfAffir.Status__c = AFF_STATUS;
        credVerfAffir.Case__c = newCase.Id;
        credVerfAffir.RecordTypeId = affirRecordTypeID;
        insert credVerfAffir;
        System.assert(credVerfAffir.Id!=null, 'Affirmation is not created.');
        Id medEduRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constants.CASE_RECORD_TYPE_MED_EDU_FORM);
        Case newCaseMed = new Case();
        newCaseMed.RecordTypeId = medEduRecTypeId;
        newCaseMed.ContactId = con.Id;
        newCaseMed.AccountId = acct.Id;
        newCaseMed.Entity__c = acct1.Id;
        newCaseMed.Alternate_Entity__c = acct.Id;
        newCaseMed.Document_Type__c = documentType;
        newCaseMed.Service__c = Constants.CASE_SERVICE_EPIC;
        insert newCaseMed;
        System.assert(newCaseMed.Id!=null, 'newCaseMed not created.');
        String affirMedRecordTypeID = GenericUtilities.getRecordTypeIdByDevName('Affirmation__c',Constants.AFFIRMATION_RECORD_TYPE_MED_EDU_FORM);		
        Affirmation__c medEduVerfAffir = new Affirmation__c();
        medEduVerfAffir.Verify_with_Alternate_Entity__c = true;
        medEduVerfAffir.Status__c = AFF_STATUS;
        medEduVerfAffir.Case__c = newCaseMed.Id;
        medEduVerfAffir.RecordTypeId = affirMedRecordTypeID;
        insert medEduVerfAffir;
        System.assert(medEduVerfAffir.Id!=null, 'Affirmation is not created.');
        List<Account2Service__c> myAccServList = new List<Account2Service__c>();
        Account2Service__c acc2Service = new Account2Service__c(Account__c = acct.Id, Active__c = true, Service__c = serv.Id);
        Account2Service__c acc2Service1 = new Account2Service__c(Account__c = acct.Id, Active__c = false, Service__c = serv1.Id);
        myAccServList.add(acc2Service);
        myAccServList.add(acc2Service1);
        insert myAccServList; 
        System.assert(acc2Service.Id!=null && acc2Service1.Id!=null, 'Acc2Service is not created');
        test.startTest();
        List<CONTACT2ACCTSERVICE__c> conAccSerList = new List<CONTACT2ACCTSERVICE__c>();
        CONTACT2ACCTSERVICE__c conAccServiceObj = new CONTACT2ACCTSERVICE__c();
        conAccServiceObj.Role__c = CON_ACC_ROLE;
        conAccServiceObj.Preferred_mode_of_communication__c = 'Paper';
        conAccServiceObj.Physical_Address__c = 'Test Address';
        conAccServiceObj.List_of_emails__c = '';
        conAccServiceObj.Verification_Website_URL__c = '';
        conAccServiceObj.Credential_Type__c = documentType;
        conAccServiceObj.Account_Service__c = acc2Service.Id;
        conAccServiceObj.Service_Contact__c = con.Id;
        conAccServiceObj.Active__c = true;
        conAccSerList.add(conAccServiceObj);
        CONTACT2ACCTSERVICE__c conAccServiceObj1 = new CONTACT2ACCTSERVICE__c();
        conAccServiceObj1.Role__c = CON_ACC_ROLE;
        conAccServiceObj1.Credential_Type__c = documentType;
        conAccServiceObj1.Account_Service__c = acc2Service1.Id;
        conAccServiceObj1.Service_Contact__c = con.Id;
        conAccServiceObj1.Active__c = true;
        conAccServiceObj.City__c = 'test city';
        conAccServiceObj.Street__c = 'test street';
        conAccServiceObj.Country__c = 'United States';
        conAccServiceObj.State__c = 'Alaska';
        conAccServiceObj.Postal_Code__c = 'test111';
        conAccSerList.add(conAccServiceObj1);
        insert conAccSerList;
        System.assert(conAccServiceObj.Id!=null && conAccServiceObj1!=null, 'Contact2Acc Service is not created');
        String defaultSendMethod = EntityReviewController.getDefaultSendMethod(newCase.Id);
        System.assert(defaultSendMethod == 'Entity Portal', 'Default Send Method is not Entity Portal');
        defaultSendMethod = EntityReviewController.getDefaultSendMethod(newCaseMed.Id);
        System.assert(defaultSendMethod == 'Paper','Default Send Method is not Paper');
        test.stopTest();
    }
}