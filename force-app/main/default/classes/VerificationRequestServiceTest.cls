// Created by Matthew on 2019-07-29
@isTest
public class VerificationRequestServiceTest{
        // Creates test data for other tests.
        private static CurrentEntityIDSequence__c settingsInstance;                  
        static{
                CurrentEntityIDSequence__c settingsInstance = CurrentEntityIDSequence__c.getOrgDefaults(); 
                settingsInstance.Entity_ID__c = '0000000';         
                upsert settingsInstance;     
            }     

        @testSetup
        static void setup(){
                string verReqCredentialReviewRecordTypeId = Schema.SObjectType.Verification_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.VERIFICATION_REQUEST_RECORD_TYPE_CREDENTIAL_REVIEW).getRecordTypeId();
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
                Residence_Country__c = 'United States',
                Rest_of_Name__c = 'Test1',
                Sender__c = 'MCC',
                Status__c = Constants.VERIFICATION_REQUEST_STATUS_PENDING,
                University_Code__c = 'ABC123',
                University_Name__c = 'Test School 4',
                Urgent__c = false,
                USMLE_ID__c = 'ABC123',
                RecordTypeId = verReqCredentialReviewRecordTypeId
                );
                insert vr;
                // Verification_Request_File__c
                Verification_Request_File__c vrf = new Verification_Request_File__c(
                        Verification_Request__c = vr.Id,
                        Document_Type__c = 'PHOTO',
                        status__c= 'Pending'
                );                
                Verification_Request_File__c vrf2 = new Verification_Request_File__c(
                        Verification_Request__c = vr.Id,
                        Document_Type__c = 'TRANS',
                        status__c= 'Pending'
                );
                insert vrf2;

                // Contact
                Contact cnt = new Contact(
                        FirstName = 'Test',
                        LastName = 'User1'
                );
                insert cnt;
                // Case
                insert new Case(
                        Verification_Request__c = vr.Id,
                        ContactId = cnt.Id,
                        RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId()
                );
        }
        // This method tests the setup.
        @isTest
        static void testSetup(){
                List<Verification_Request__c> reqs = [
                        SELECT
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
                        FROM Verification_Request__c
                ];
                System.assert(reqs != null, 'reqs should not be null');
                System.assert(reqs.size() == 1, 'size of reqs should be 1');
                List<Case> cases = [select Id from Case];
                System.assert(cases != null, 'cases should not be null');
                System.assert(cases.size() == 1, 'size of cases should be equal to 1');
                List<ContentDocumentLink> cdls = [select Id, ContentDocumentId from ContentDocumentLink where LinkedEntityId = :cases[0].Id];
                System.assert(cdls != null, 'cdls should not be null');
                System.assert(cdls.size() == 0, 'size of cdls should be 0');
        }
        @isTest
        static void createAssetsFromVerificationRequestFilesShouldCreateAssetsAndFiles(){
                List<Verification_Request__c> reqs = [select Id from Verification_Request__c];
                System.assert(reqs != null, 'reqs should not be null');
                System.assert(reqs.size() == 1, 'size of reqs should be 1');
                List<Case> cases = [select Id from Case];
                System.assert(cases != null, 'cases should not be null');
                System.assert(cases.size() == 1, 'size of cases should be 1');
                List<Asset> assets = [select Id from Asset];
                System.assert(assets.size() == 0, 'size of cases should be 0');
                VerificationRequestService.getVerificationRequest(reqs[0].Id);
                VerificationRequestService.createAssetsFromVerificationRequestFiles(reqs[0].Id); 
                VerificationRequestService.getMonthAsText(2);	
                List<String> caseIdLists = new List<String>();
                for(Case caseObj : [select Id from Case]){
                        caseIdLists.add(caseObj.Id);
                }
                VerificationRequestService.createContactAssociationTypes(caseIdLists);        
                assets = [select Id, Name, Type__c from Asset];
                System.assert(assets.size() == 1, 'size of cases should be 1');
        }
        
        @isTest
        static void testGetCaseByVerificationRequestId(){                 
                CurrentECFMGIDSequence__c settingsECFMGInstance = CurrentECFMGIDSequence__c.getOrgDefaults();
                settingsECFMGInstance.ECFMG_ID__c = '00000001';         
                upsert settingsECFMGInstance;     
                //create a new contact;
                date birthdate1 = date.valueOf('2000-01-01');
                string emailtest = 'tester@unknownmail.com';
                String userName = 'tester@unknownmail.com_' + System.now();
                userName=userName.replace(' ','').replace(':','-');
                string lastname = 'Last';
                string firstname = 'First';                
                Contact c1 = new Contact(Firstname=firstname,School_Enrollment_Status__c=constants.CONASCTYPESTG_STATUS_STUDENT,Lastname=lastname,Birthdate=birthdate1,email=emailtest,MailingCountry='Mexico',Step_1_Attempt_Limit_Exception__c = true, Step_2_CK_Attempt_Limit_Exception__c= true,Step_2_CS_Attempt_Limit_Exception__c= true);
                insert c1;
                //create Entity record for Account                     
                Id identityAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
                Account ac = new Account(Name='EntityAcctName', RecordTypeId=identityAccountRecordTypeId, School__c=true, BillingCountry ='Italy');
                insert ac;
                // Case
                Case caseobj = new Case();
                caseobj.ContactId = c1.Id;
                caseobj.AccountId = ac.Id;
                caseobj.Internal_Status__c = 'New';
                insert caseObj;
                System.assert(caseObj != null, 'caseObj should not be null');
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
                        Medschool_Name__c = 'Test School',
                        Previous_Last_Name__c = 'Previous Last1',
                        Previous_Rest_of_Name__c = 'Previous First1',
                        Request_Id__c = 'ABC123',
                        Request_Type__c = 'Test Request',
                        Residence_Country__c = 'United States',
                        Rest_of_Name__c = 'Test1',
                        Sender__c = 'MCC',
                        Status__c = Constants.VERIFICATION_REQUEST_STATUS_PENDING,
                        University_Code__c = 'ABC123',
                        University_Name__c = 'Test School',
                        Urgent__c = false,
                        USMLE_ID__c = 'ABC123'
                );
                insert vr;
                VerificationRequestService.getVerificationRequest(vr.Id);
                System.assert(vr != null, 'Verification Request should not be null');                
        }

        @isTest
        static void testGetDocSelectedByApplicant_doctypePreGrad(){
            string cdoctype = Constants.CASE_DOC_TYPE_PREGRADUATE_INTERNSHIP_CREDENTIAL; 
            string returndoctype; 
            Test.startTest();
            returndoctype = VerificationRequestService.getDocSelectedByApplicant(cdoctype);         
            Test.stopTest();
            System.assertEquals(Constants.CASE_APP_SELECTED_DOC_TYPE_PREGRADUATE_INTERNSHIP_CERTIFICATE, returndoctype, 'Pre Grd doc type test!');
        }

        @isTest
        static void testGetDocSelectedByApplicant_doctypePostGrad(){
            string cdoctype = Constants.CASE_DOC_TYPE_POSTGRADUATE_MEDICAL_EDUCATION_CREDENTIAL; 
            string returndoctype; 
            Test.startTest();
            returndoctype = VerificationRequestService.getDocSelectedByApplicant(cdoctype);         
            Test.stopTest();
            System.assertEquals(Constants.CASE_APP_SELECTED_DOC_TYPE_POSTGRADUATE_TRAINING_CREDENTIAL, returndoctype, 'Post Grad doc type test!');
        }

        @isTest
        static void testIsSourceDocument(){
            string cdoctype = 'Photo'; 
            boolean returnboolean; 
            Test.startTest();
            returnboolean = VerificationRequestService.isSourceDocument(cdoctype);         
            Test.stopTest();
            System.assertEquals(returnboolean, false, 'Test is source doctype!');
        }

        @isTest
        static void testCreateAssetsFromVerificationRequestFiles_NegativeTest(){

                Verification_Request__c vr = new Verification_Request__c(
                        Batch_Id__c = '12378'); 
                insert vr; 

                Test.startTest();
                Boolean bExceptionThrown = false;
               try {
                VerificationRequestService.createAssetsFromVerificationRequestFiles(vr.Id);  
               } catch (Exception e) {
                 bExceptionThrown = true;
                 system.debug('excpetion is thrown'); 
               } 
               Test.stopTest();
               System.assertEquals(true,  bExceptionThrown,  'Exception thrown');
        }

        @isTest
        static void testCreateContactAssociationTypes_ForIfme(){
                Map<String, Map<String, String>> attributeMap = new Map<String, Map<String, String>>();
                List<Verification_Request__c> reqs = [select Id from Verification_Request__c];
                System.assert(reqs != null, 'reqs should not be null');
                System.assert(reqs.size() == 1, 'size of reqs should be 1');
                List<Account> accs = [select id from account]; 
                reqs[0].Exact_Match_Account__c = accs[0].Id;
                update reqs; 

                List<Case> cases; 
                
                Case aCase = [select Id, recordtypeId from Case limit 1];
                aCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_IFOM_REQUEST).getRecordTypeId();
                aCase.Verification_Request__c = reqs[0].Id; 
                update aCase; 
                attributeMap = CaseService.appendToAttributeMap(attributeMap, aCase.Id, Constants.REQUEST_VERIFICATION_LINKED_ENTITY_ID_ATTRIBUTE_NAME, reqs[0].Exact_Match_Account__c);
                CaseService.setCaseAttributes(attributeMap);
	
                List<String> caseIdLists = new List<String>();
               
                caseIdLists.add(aCase.Id);

                VerificationRequestService.createContactAssociationTypes(caseIdLists);        
                List<Contact_Association_Type__c> cats = [select Id, Name, Type__c from Contact_Association_Type__c];                
                System.assert(cats.size() == 1, 'size of cat should be 1');
        }

        @isTest
        static void testCreateContactAssociationTypes_ForMedEduForm(){
                Map<String, Map<String, String>> attributeMap = new Map<String, Map<String, String>>();
                List<Verification_Request__c> reqs = [select Id from Verification_Request__c];
                System.assert(reqs != null, 'reqs should not be null');
                System.assert(reqs.size() == 1, 'size of reqs should be 1');
                List<Account> accs = [select id from account]; 
                reqs[0].Exact_Match_Account__c = accs[0].Id;
                update reqs; 

                Case aCase = [select Id, recordtypeId from Case limit 1];
                aCase.RecordTypeId = Constants.MEDEDUFORMID; 
                aCase.Verification_Request__c = reqs[0].Id; 
                update aCase; 
                attributeMap = CaseService.appendToAttributeMap(attributeMap, aCase.Id, Constants.REQUEST_VERIFICATION_LINKED_ENTITY_ID_ATTRIBUTE_NAME, reqs[0].Exact_Match_Account__c);
                CaseService.setCaseAttributes(attributeMap);	
                List<String> caseIdLists = new List<String>();               
                caseIdLists.add(aCase.Id);

                VerificationRequestService.createContactAssociationTypes(caseIdLists);        
                List<Contact_Association_Type__c> cats = [select Id, Name, Type__c from Contact_Association_Type__c];                
                System.assert(cats.size() == 1, 'size of cat should be 1');
        }     
        
        @isTest
        static void testCreateContactAssociationStagingTypes(){
                Map<String, Map<String, String>> attributeMap = new Map<String, Map<String, String>>();
                List<Verification_Request__c> reqs = [select Id from Verification_Request__c];
                System.assert(reqs != null, 'reqs should not be null');
                System.assert(reqs.size() == 1, 'size of reqs should be 1');
                List<Account> accs = [select id from account]; 
                reqs[0].Exact_Match_Account__c = accs[0].Id;
                update reqs; 

                Case aCase = [select Id, recordtypeId from Case limit 1];
                aCase.RecordTypeId = Constants.MEDEDUFORMID; 
                aCase.Verification_Request__c = reqs[0].Id; 
                update aCase; 
                attributeMap = CaseService.appendToAttributeMap(attributeMap, aCase.Id, Constants.REQUEST_VERIFICATION_LINKED_ENTITY_ID_ATTRIBUTE_NAME, reqs[0].Exact_Match_Account__c);
                CaseService.setCaseAttributes(attributeMap);	
                List<String> caseIdLists = new List<String>();               
                caseIdLists.add(aCase.Id);

                VerificationRequestService.createCATS(caseIdLists);        
                List<Contact_Association_Type_Staging__c> cats = [select Id, Name, Type__c from Contact_Association_Type_Staging__c];                
                System.assert(cats.size() == 1, 'size of cat should be 1');
        }  
        @isTest
        static void testCreateContactAssociationStagingTypesForIFOM(){
                Map<String, Map<String, String>> attributeMap = new Map<String, Map<String, String>>();
                List<Verification_Request__c> reqs = [select Id from Verification_Request__c];
                System.assert(reqs != null, 'reqs should not be null');
                System.assert(reqs.size() == 1, 'size of reqs should be 1');
                List<Account> accs = [select id from account]; 
                reqs[0].Exact_Match_Account__c = accs[0].Id;
                update reqs; 

                Case aCase = [select Id, recordtypeId from Case limit 1];
                aCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_IFOM_REQUEST).getRecordTypeId();                
                aCase.Verification_Request__c = reqs[0].Id; 
                update aCase; 
                attributeMap = CaseService.appendToAttributeMap(attributeMap, aCase.Id, Constants.REQUEST_VERIFICATION_LINKED_ENTITY_ID_ATTRIBUTE_NAME, reqs[0].Exact_Match_Account__c);
                CaseService.setCaseAttributes(attributeMap);	
                List<String> caseIdLists = new List<String>();               
                caseIdLists.add(aCase.Id);

                VerificationRequestService.createCATS(caseIdLists);        
                List<Contact_Association_Type_Staging__c> cats = [select Id, Name, Type__c from Contact_Association_Type_Staging__c];                
                System.assert(cats.size() == 1, 'size of cats should be 1');
        } 
}