/*
    Createdby       : Pradeep Kumar
    CreatedDate     : 12/09/2021
    Story           : Restriction Request Queue Test Class
*/
@isTest
public class RestrictionRequestQueueClassTest {
    
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
        Account accnt = new Account(Name = 'DummyAccount', RecordTypeId = entityRTId, BillingCountry = 'India');
        insert accnt;
        System.assert(accnt != null, 'Test account creation failed');
        entityIDList.add(accnt.Id);
        System.debug('entityIDList ++ ' + System.JSON.serialize(entityIDList));
        
        //Create Applicants
        Id applRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_APPLICANT).getRecordTypeId();

        List<Contact> contactList = new List<Contact>();
        List<Id> applicantIDList = new List<Id>();
        for(Integer i = 1; i<= 10; i++){
            Contact con = new Contact();
            date birthdate1 = date.valueOf('2001-01-01');
            con.AccountId = accnt.Id;
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
    }

    @isTest 
    static void testQueuebleClass()
    {
    
        User adminUsr = [select id from User where email = 'testEcfmg@ecfmg.org' limit 1];
        Map<Id, Restriction_Request__c> restrictionReqMap = new Map<Id, Restriction_Request__c>([select Id, Restriction_Level__c, RestrictionStatus__c, Restriction_Type__c, 
                        Restriction_Start_Date__c, Restriction_End_Date__c, Services_Restricted__c,Assigned_SI_Case_Manager__c,Restriction_Reason__c,Request_Type__c,
                        Entity_ID_List__c, Applicant_ID_List__c from Restriction_Request__c where Restriction_Level__c = 'Entity' limit 10]);
          
        Test.startTest();
           System.enqueueJob(new RestrictionRequestQueueClass(restrictionReqMap));
        Test.stopTest();
    }

    @IsTest
    static void testRestrictionRequestProcessBatch(){
        
        Test.startTest();
            Database.executeBatch(new RestrictionRequestProcessBatch(), 200);
        Test.stopTest();
        
    }
}