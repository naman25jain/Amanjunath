//Test class for ContactHandler
@isTest
public class ContactHandlerTest{
    private static CurrentEntityIDSequence__c settingsInstance;
    static{
        CurrentEntityIDSequence__c settingsInstance = CurrentEntityIDSequence__c.getOrgDefaults();
        settingsInstance.Entity_ID__c = '0000000';
        upsert settingsInstance;
    }
    @isTest(SeeAllData=true)
    static void testContactHandler(){
        CurrentECFMGIDSequence__c settingsECFMGInstance = CurrentECFMGIDSequence__c.getOrgDefaults();
        settingsECFMGInstance.ECFMG_ID__c = '10000001';
        upsert settingsECFMGInstance;
      List<RecordType> regUserRectTypeId = [select Id from RecordType where SobjectType = 'Contact' and Name = :Constants.CONTACT_RECORD_TYPE_REG_USR];        
      List<Account> act = new List<Account>();
        act = [Select Id from Account where Id =: Label.Default_Portal_Account];
        if(!act.isEmpty()){
        	Contact con2 = new Contact(
                FirstName = 'Test2Bless',
                LastName = 'UserBless',
                Birthdate = System.today().addYears(-10),
                Gender__c = 'Male',
    			AccountId = Label.Default_Portal_Account,
                ServicesRestricted__c = NULL,
                RecordTypeId = regUserRectTypeId[0].Id
            );
            insert con2;  
            System.assertEquals([SELECT FirstName FROM Contact WHERE Id =: con2.Id].FirstName, 'Test2Bless','Assetion Passed: Account Check');  
        }
    }
   	@isTest
    static void testContactHandler1(){
        CurrentECFMGIDSequence__c settingsECFMGInstance = CurrentECFMGIDSequence__c.getOrgDefaults();
        settingsECFMGInstance.ECFMG_ID__c = '20000001';
        upsert settingsECFMGInstance;
        Individual ind = new Individual(lastName = 'Ind 1');
        insert ind;
        Id aplRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_APPLICANT).getRecordTypeId();
        List<RecordType> ExmRegRectTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Exam_Registration__c'];
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.BillingCountry = 'India';
        acc.Epic_Notifications__c = true;
        insert acc;
        Contact con2 = new Contact(
                FirstName = 'Test2',
                LastName = 'User2',
                Birthdate = System.today().addYears(-10),
                Gender__c = 'Male',
    			AccountId = acc.Id,
                ServicesRestricted__c = NULL,
                IndividualId = ind.Id,
                RecordTypeId = aplRecTypeId
            );
            insert con2;
            Contact con3 = new Contact(
                FirstName = 'TestRaj3',
                LastName = 'UserRaj3',
                Birthdate = System.today().addYears(-10),
                Gender__c = 'Male',
    			AccountId = acc.Id,
                ServicesRestricted__c = NULL,
                IndividualId = ind.Id,
                RecordTypeId = aplRecTypeId
            );
            insert con3; 
        	Exam_Registration__c exmReg1 = new Exam_Registration__c(
                RecordTypeId = ExmRegRectTypeId[0].Id,
                Applicant__c = con2.Id,
                Exam_Types__c = 'USMLE Step 1',
                Exam_Status__c = NULL
            );
        	insert exmReg1;
        	Exam_Registration__c exmReg2 = new Exam_Registration__c(
                RecordTypeId = ExmRegRectTypeId[0].Id,
                Applicant__c = con2.Id,
                Exam_Types__c = 'USMLE Step 2 CK',
                Exam_Status__c = NULL
            );
        	insert exmReg2;
        	Exam_Registration__c exmReg3 = new Exam_Registration__c(
                RecordTypeId = ExmRegRectTypeId[0].Id,
                Applicant__c = con3.Id,
                Exam_Types__c = 'USMLE Step 1',
                Exam_Status__c = NULL
            );
        	insert exmReg3;
            con2.ServicesRestricted__c = 'Score Reporting - Internal and External';
            con2.lastName = 'test user';
            update con2;
            con3.ServicesRestricted__c = 'Score Rechecks - Internal Only';
            con3.lastName = 'test user';
            update con3;
            con3.ServicesRestricted__c = 'Score Reporting - Internal and External';
            update con3;
            Set<Id> conIds = new Set<Id>();
            conIds.add(con2.Id);
        	conIds.add(con3.Id);
            ContactHandler ch = new ContactHandler();
            ch.updateExamRegForScoreReporting(conIds);
            System.assertEquals([SELECT ServicesRestricted__c FROM Contact WHERE Id =: con2.Id].ServicesRestricted__c, 'Score Reporting - Internal and External','Assetion Passed: Account Check');
    }
     @isTest
    static void testContactHandler3(){
        List<Account> myList = new List<Account>(); // Define a new list
        Account a = new Account(Name='Acme'); // Create the account first
        myList.add(a);
        ContactHandler ch=new ContactHandler();
        ch.beforeDelete(myList); 
        ch.afterDelete(myList);
        ch.afterUndelete(myList);        
    }    
   // @isTest
   // static void testContactHandler3(){
    //    ContactHandler ch=new ContactHandler();
    //    ch.IsDisabled();
  //  }
    
}