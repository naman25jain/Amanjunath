/** @name: RecordTypeUtility
 *  @description: Define methods to pre-process the data and pass on to helper methods for processing business logic
**/
@isTest
public class VerReqRouteBatchTest {
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

    /*
        Creates test data for other tests.
     */

    @testSetup
   static void setup() {
        Account acct = new Account(
                Name = 'Test Entity Account',
                BillingCountry = 'India',
            	RecordTypeId = RecordTypeUtility.getRecordTypeIdByName('Account', Constants.ACCOUNT_RECORD_TYPE_ENTITY)
        );
        insert acct;
       
       Account acct1 = new Account(
                Name = 'FEDERATION OF STATE MEDICAL BOARDS',
                BillingCountry = 'India',
            	RecordTypeId = RecordTypeUtility.getRecordTypeIdByName('Account', Constants.ACCOUNT_RECORD_TYPE_ENTITY)
        );
        insert acct1;
       
       Account acct2 = new Account(
                Name = 'MEDICAL COUNCIL OF CANADA',
                BillingCountry = 'India',
            	RecordTypeId = RecordTypeUtility.getRecordTypeIdByName('Account', Constants.ACCOUNT_RECORD_TYPE_ENTITY)
        );
        insert acct2;
       
       Account acct3 = new Account(
                Name = 'NATIONAL BOARD OF MEDICAL EXAMINERS',
                BillingCountry = 'India',
            	RecordTypeId = RecordTypeUtility.getRecordTypeIdByName('Account', Constants.ACCOUNT_RECORD_TYPE_ENTITY)
        );
        insert acct3;
       
        Contact con = new Contact(
                AccountId = acct.Id,
                FirstName = 'Uniq',
                LastName = 'uniq',
                email = 'uniq@mail.com',
                MailingCountry = 'India');
        insert con;

        Id verReqCRRecordTypeId = Schema.SObjectType.Verification_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.VERIFICATION_REQUEST_RECORD_TYPE_CREDENTIAL_REVIEW).getRecordTypeId();
        Id verReqIFOMRecordTypeId = Schema.SObjectType.Verification_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.VERIFICATION_REQUEST_RECORD_TYPE_IFOM).getRecordTypeId();

        Verification_Request__c req1 = new Verification_Request__c(
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
                Exact_Match_Contact__c = null,
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
                Status__c = 'Scored',
                University_Code__c = 'ABC123',
                University_Name__c = 'Test School',
                Urgent__c = false,
                USMLE_ID__c = 'ABC123'
        );
        insert req1;

        Verification_Request__c req2 = new Verification_Request__c(
                RecordTypeId = verReqIFOMRecordTypeId,
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
        insert req2;        
    }
    
    @isTest
    static void testContactAssociationTypeCreation() {
        
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

        System.assert(reqs != null, 'reqs should not be null');
        System.assert(reqs.size() == 2, 'size of reqs should be 2');

        List<Account> accounts = [select Id, Name from Account];

        System.assert(accounts != null, 'accounts should not be null');
               
		Id accountId = reqs[0].Exact_Match_Account__c;
        
        // invoke the batch class
        test.startTest();
        	Database.executeBatch(new VerReqRouteBatch());
        test.stopTest();
        
        List<Case> cases = [SELECT Id, Verification_Request__c FROM Case WHERE Verification_Request__c=:reqs[0].Id];
        System.assert(cases != null, 'cases should not be null');
        System.assert(cases.size() == 1, 'size of cases should be 1');        
        List<Case_Attribute__c> caseAttrList = [SELECT Id, Name, Case__r.ContactId, Case__r.Verification_Request__r.Graduation_Date__c, Value__c	 
                                                    FROM Case_Attribute__c 
                                                    WHERE Case__c =: cases[0].Id 
                                                    AND Name =: Constants.REQUEST_VERIFICATION_LINKED_ENTITY_ID_ATTRIBUTE_NAME
                                               		ORDER BY Case__c]; 
        
        System.assert(caseAttrList != null, 'case attribute list should not be null');
                
        List<Contact> contacts = [select Id, Name from Contact];
       
        System.assert(contacts != null, 'contacts should not be null');   
        
        List<Contact_Association_Type__c> conAscList = [SELECT Account__c, Contact__c, RecordTypeId, Degree_Issue_Date__c, Type__c
                                                        	FROM Contact_Association_Type__c
                                                        	WHERE Account__c=:accountId
                                                        	AND Contact__c=:contacts[0].Id];
        
		System.assert(conAscList != null, 'contact association type should not be null');
    
    }
   
   
    @isTest
    static void testContactAssociationTypeCreation1() {
        
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
        
		Id accountId = reqs[0].Exact_Match_Account__c;
        VerReqRouteBatch b = new VerReqRouteBatch();
        b.testScenario = 1;
        // invoke the batch class
        test.startTest();
        	Database.executeBatch(b);
        	b.testScenario = 2;
        	Database.executeBatch(b);
        	b.testScenario = 3;
        	Database.executeBatch(b);
        	b.testScenario = 4;
        	Database.executeBatch(b);
        	b.testScenario = 5;
        	Database.executeBatch(b);
        	b.testScenario = 6;
        	Database.executeBatch(b);
        test.stopTest();
        List<Contact_Association_Type__c> conAscList = [SELECT Account__c, Contact__c, RecordTypeId, Degree_Issue_Date__c, Type__c
        FROM Contact_Association_Type__c
        WHERE Account__c=:accountId  ];

        System.assert(conAscList != null, 'contact association type should not be null');
        
    }


    
}