/*
    Createdby       : Pradeep Kumar
    CreatedDate     : 12/09/2021
    Story           : Restriction Request Process test class
*/
@isTest
public class RestrictionRequestProcessTest {
    
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

    @TestSetup
    static void makeData(){

        Profile p = [SELECT id, Name FROM Profile where name = 'System Administrator' ].get(0);  
        User usr = new User(firstname= 'Test',
                    lastname='ECFMG',
                    Alias='TestUsr',
                    email = 'testEcfmg@ecfmg.org',
                    username= 'testEcfmg@ecfmg.org.test', 
                    profileId= p.id, 
                    emailencodingkey='UTF-8',
                    languagelocalekey='en_US',
                    localesidkey='en_US',
                    timezonesidkey='America/Los_Angeles');
        insert usr;	 

        //Create Accounts
        Id entityRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_ENTITY).getRecordTypeId();
        List<Account> accountList = new List<Account>();
        List<Id> entityIDList = new List<Id>();
        for(Integer i = 1; i<= 50; i++){
            Account a = new Account(Name =ConstantsTest.TEST_ENTITY_ACCOUNT_NAME+i, RecordTypeId = entityRTId, BillingCountry = 'India');
            accountList.add(a);
        }
        insert accountList;
        System.debug('Account list size ++ ' + accountList.size());
        System.debug('Account ++++ ' + accountList);
        System.assert(accountList.size() > 0, 'Test account creation failed');
        for(Account a : accountList){
            entityIDList.add(a.Id);
        }
        System.debug('entityIDList ++ ' + System.JSON.serialize(entityIDList));

        //Create Applicants
        Id applRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_APPLICANT).getRecordTypeId();
        Account account = [SELECT id, Entity_ID__c, Name
                            FROM Account 
                            WHERE Name =: ConstantsTest.TEST_ENTITY_ACCOUNT_NAME+1
                            LIMIT 1];

        List<Contact> contactList = new List<Contact>();
        List<Id> applicantIDList = new List<Id>();
        for(Integer i = 1; i<= 10; i++){
            Contact con = new Contact();
            date birthdate1 = date.valueOf('2001-01-01');
            con.AccountId = account.Id;
            con.LastName = 'Test Last' + i;
            con.Email = 'test1@test.com'+i;
            con.RecordTypeId = applRecTypeId;
            con.EPIC_ID__c = 'E-12345'+i;
            con.Generational_Suffix__c = 'Jr';
            con.Birthdate = birthdate1;
            contactList.add(con);
        }
        insert contactList;
        List<Contact> testContact = [SELECT EPIC_ID__c,ECFMG_ID__c,LastName,Name,Generational_Suffix__c,Birthdate,RecordType.Name,Account.Entity_ID__c FROM Contact WHERE LastName ='Test Last1' WITH SECURITY_ENFORCED LIMIT 1];
        System.debug('testGetApplicantsSuccess::contactList2 '+testContact);
        String strEPICId = testContact[0].EPIC_ID__c;
        System.assert(contactList.size() > 0, 'Test Contact creation Success');
        for(Contact a : contactList){
            applicantIDList.add(a.Id);
        }
        System.debug('entityIDList ++ ' + System.JSON.serialize(applicantIDList));

        //Create Restriction Requests
        List<Restriction_Request__c> restrictionRequestList = new List<Restriction_Request__c>();
        for(Integer i=1;i<=100;i++){
            Restriction_Request__c rrReq = new Restriction_Request__c(Request_Type__c = 'New',
                            Services_Restricted__c = 'Region Change;Application for Certification;',
                            Restriction_End_Date__c = System.TODAY()+30, RestrictionStatus__c = 'Ready to Process', Restriction_Reason__c = 'Investigation');
                
            if(i < 50 ){
                rrReq.Restriction_Level__c = 'Entity';
                rrReq.Restriction_Type__c = 'Internal and External';
                rrReq.Entity_ID_List__c = System.JSON.serialize(entityIDList);
            }else{
                rrReq.Restriction_Level__c = 'Applicant';
                rrReq.Restriction_Type__c = 'Internal Only';
                rrReq.Applicant_ID_List__c = System.JSON.serialize(applicantIDList);
            }
            
            restrictionRequestList.add(rrReq);
        }

        insert restrictionRequestList;
        System.debug('restrictionRequestList++ ' + restrictionRequestList.size());

        //Create Restriction Records
        List<Restriction__c> restrictionRecordList = new List<Restriction__c>();
        Restriction_Request__c entityRRRecord = [select Id, Restriction_Start_Date__c, Restriction_End_Date__c, Assigned_SI_Case_Manager__c, Restriction_Level__c, Restriction_Reason__c, Request_Type__c, RestrictionStatus__c, Restriction_Type__c from Restriction_Request__c where Restriction_Level__c = 'Entity' limit 1];
        Restriction_Request__c applicantRRRecord = [select Id, Restriction_Start_Date__c, Restriction_End_Date__c, Assigned_SI_Case_Manager__c, Restriction_Level__c, Restriction_Reason__c, Request_Type__c, RestrictionStatus__c, Restriction_Type__c from Restriction_Request__c where Restriction_Level__c = 'Applicant' limit 1];
        for(Integer i=1; i <=100; i++){
            Restriction__c newRestrictionRec = new Restriction__c();
            newRestrictionRec.ServiceRestricted__c = 'Application for Certification';
            if(i < 50){
                newRestrictionRec.Restriction_Request__c = entityRRRecord.Id;
                newRestrictionRec.Entity__c = account.Id;
            }else{
                newRestrictionRec.Restriction_Request__c = applicantRRRecord.Id;
                newRestrictionRec.Applicant__c = testContact[0].Id;
            }

            newRestrictionRec.Assigned_SI_Case_Manager__c = entityRRRecord.Assigned_SI_Case_Manager__c;
            newRestrictionRec.Restriction_Start_Date__c = entityRRRecord.Restriction_Start_Date__c;
            newRestrictionRec.Restriction_End_Date__c = entityRRRecord.Restriction_End_Date__c;
            newRestrictionRec.Restriction_Reason__c = entityRRRecord.Restriction_Reason__c;
            newRestrictionRec.Restriction_Level__c = entityRRRecord.Restriction_Level__c;
            if(entityRRRecord.Request_Type__c == 'New'){
                newRestrictionRec.Restriction_Status__c = 'Active';
            }
            restrictionRecordList.add(newRestrictionRec);
        }//for
        insert restrictionRecordList;
        //System.assert(restrictionRecordList.size() > 0, 'Test Restriction Records creation are successful');
    }

    @IsTest
    static void testEntityRestrictionSuccess(){//Testing the entity restriction success
        
        User adminUsr = [select id from User where email = 'testEcfmg@ecfmg.org' limit 1];
        Map<Id, Restriction_Request__c> restrictionReqMap = new Map<Id, Restriction_Request__c>([select Id, Restriction_Level__c, RestrictionStatus__c, Restriction_Type__c, 
                        Restriction_Start_Date__c, Restriction_End_Date__c, Services_Restricted__c,Assigned_SI_Case_Manager__c,Restriction_Reason__c,Request_Type__c,
                        Entity_ID_List__c, Applicant_ID_List__c from Restriction_Request__c where Restriction_Level__c = 'Entity' limit 10]);
                        
        Test.startTest();
        System.runAs(adminUsr){
            RestrictionRequestProcess.processRestrictionRequests(restrictionReqMap);
        }
        Test.stopTest();
        
        List<Restriction__c> restrictionList = [select id from Restriction__c where Restriction_Request__c IN: restrictionReqMap.keySet() ];
        System.assert(restrictionList.size() > 0, 'Restriction Records are created');
    }

    @IsTest
    static void testApplicantRestrictionSuccess(){//Testing the Applicant restriction success
        
        User adminUsr = [select id from User where email = 'testEcfmg@ecfmg.org' limit 1];
        Map<Id, Restriction_Request__c> restrictionReqMap = new Map<Id, Restriction_Request__c>([select Id, Restriction_Level__c, RestrictionStatus__c, Restriction_Type__c, 
                        Restriction_Start_Date__c, Restriction_End_Date__c, Services_Restricted__c,Assigned_SI_Case_Manager__c,Restriction_Reason__c,Request_Type__c,
                        Entity_ID_List__c, Applicant_ID_List__c from Restriction_Request__c where Restriction_Level__c = 'Applicant'  limit 10]);
                        
        Test.startTest();
        System.runAs(adminUsr){
            RestrictionRequestProcess.processRestrictionRequests(restrictionReqMap);
        }
        Test.stopTest();
        
        List<Restriction__c> restrictionList = [select id from Restriction__c where Restriction_Request__c IN: restrictionReqMap.keySet() ];
        System.assert(restrictionList.size() > 0, 'Restriction Records are created');
    }

    @IsTest
    static void testprocessRestrictionRecords(){
        User adminUsr = [select id from User where email = 'testEcfmg@ecfmg.org' limit 1];
        List<Restriction__c> restrictionRecordList = [select id, Entity__c, Applicant__c, Restriction_Start_Date__c, Restriction_End_Date__c, Restriction_Level__c, Restriction_Reason__c, Restriction_Status__c, Restriction_Type__c from Restriction__c];
        Test.startTest();
        System.runAs(adminUsr){
            RestrictionRequestProcess.processRestrictionRecords(restrictionRecordList);
        }
        Test.stopTest();
    }

    @IsTest
    static void testErrorRestrictionRecords(){
        User adminUsr = [select id from User where email = 'testEcfmg@ecfmg.org' limit 1];
        Account account = [SELECT id, Entity_ID__c, Name FROM Account WHERE Name =: ConstantsTest.TEST_ENTITY_ACCOUNT_NAME+1 LIMIT 1];
        List<Restriction__c> restrictionList = new List<Restriction__c>();
        Restriction_Request__c entityRRRecord = [select Id, Restriction_Start_Date__c, Restriction_End_Date__c, Assigned_SI_Case_Manager__c, Restriction_Level__c, Restriction_Reason__c, Request_Type__c, RestrictionStatus__c, Restriction_Type__c from Restriction_Request__c where Restriction_Level__c = 'Entity' limit 1];
        Restriction_Request__c applicantRRRecord = [select Id, Restriction_Start_Date__c, Restriction_End_Date__c, Assigned_SI_Case_Manager__c, Restriction_Level__c, Restriction_Reason__c, Request_Type__c, RestrictionStatus__c, Restriction_Type__c from Restriction_Request__c where Restriction_Level__c = 'Applicant' limit 1];
        Restriction__c restrictionRecord = new Restriction__c(ServiceRestricted__c = 'Application for Certification', 
            Restriction_Request__c = entityRRRecord.Id, Entity__c = account.Id, Restriction_Start_Date__c = Date.TODAY()-10, 
            Restriction_End_Date__c = Date.Today()-1,Restriction_Status__c = 'Active');
        restrictionList.add(restrictionRecord);
        insert restrictionList;

        Test.startTest();
        System.runAs(adminUsr){
            RestrictionRequestProcess.processRestrictionRecords(restrictionList);
        }
        Test.stopTest();
        
    }
}