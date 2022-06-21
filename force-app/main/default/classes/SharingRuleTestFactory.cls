/**
* Factory Class for Sharing Rule functionality
*
* @author        Enable Consulting
* @version       1.0
*/
@isTest
public class SharingRuleTestFactory extends ECFMGTestFactory{
    
	public static final String UNITED_STATES  = 'United States';
   	public static final String AMERICA_LA = 'America/Los_Angeles';
    
	public static testMethod void servicePageSetup() {
		Id conRecordTypeId = GenericUtilities.getRecordTypeIdByDevName('Contact',Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c);
        Id identityAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
		Account acc = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name='ADENUNIVERSITY',RecordTypeId=identityAccountRecordTypeId,School__c=true,BillingCountry='India'));
        Contact con = (Contact)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, new Contact(FirstName='Test', LastName='Contacts', USMLE_ID__c='1234', RecordTypeId=conRecordTypeId, Account = acc));
        run();
       	//create a new contact;
       	date birthdate1 = date.valueOf('1998-01-01');
       	string emailtest = 'tester@unknownmail.com';
       	String userName = 'tester@unknownmail.com_' + System.now();
       	userName=userName.replace(' ','').replace(':','-');
       	string lastname = 'Last';
       	string firstname = 'First';
       	string usmleId = '123';
		Contact c1 = (Contact)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, new Contact(AccountId = acc.Id, Firstname=firstname,Lastname=lastname,Birthdate=birthdate1,email=emailtest,MailingCountry='Mexico',USMLE_ID__c = usmleId));
       	Id profileId1=[Select id from profile where name='4-Customer Community Plus Login' LIMIT 1].id;       
      	//create a new User row
		ECFMGTestFactory.make(ECFMGDefaultTestData.SystemAdminUser.class, new User(alias='flastt', email=emailtest, emailencodingkey='UTF-8',lastname=lastname, languagelocalekey='en_US',localesidkey='en_US',profileid=profileId1,country=UNITED_STATES,IsActive=true,ContactId=con.Id, timezonesidkey=AMERICA_LA,username=userName));
      	run();
       	//create a new contact;
       	date birthdate2 = date.valueOf('1997-01-01');
       	string email2 = 'tester@unknownmail2.com';
       	String userName2 = 'tester@unknownmail2.com_' + System.now();
		userName2=userName2.replace(' ','').replace(':','-');	
       	string lastname2 = 'Last2';
       	string firstname2 = 'First2';
       	string usmleId2 = '123';
		Contact c2 = (Contact)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, new Contact(AccountId = acc.Id, Firstname=firstname2,Lastname=lastname2,Birthdate=birthdate2,email=email2,MailingCountry='Mexico', USMLE_ID__c = usmleId2));
		run();
		Id profileId2 = [SELECT id FROM profile WHERE name =: Constants.Entity_360_USER_PROFILE LIMIT 1].id;   
      	//create a new User row
		ECFMGTestFactory.make(ECFMGDefaultTestData.SystemAdminUser.class, new User(alias='flastt2', email=email2, emailencodingkey='UTF-8',lastname=lastname2, languagelocalekey='en_US',localesidkey='en_US',profileid=profileId2,country=UNITED_STATES,IsActive=true,ContactId=c2.Id, timezonesidkey=AMERICA_LA,username=userName2));
      	run();
        //create a new contact;
       	date birthdate3 = date.valueOf('2000-01-01');
       	string email3 = 'tester@unknownmail3.com';
       	String userName3 = 'tester@unknownmail3.com_' + System.now();
		userName3=userName3.replace(' ','').replace(':','-');	
       	string lastname3 = 'Last3';
       	string firstname3 = 'First3';
       	string usmleId3 = '123';
		Contact c3 = (Contact)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, new Contact(AccountId = acc.Id, Firstname=firstname3, Lastname=lastname3, Birthdate=birthdate3, email=email3, MailingCountry='Mexico', USMLE_ID__c = usmleId3));
		run();
		Id profileId3 = [SELECT id FROM profile WHERE name =: Constants.Entity_360_USER_PROFILE LIMIT 1].id;   
      	//create a new User row
		ECFMGTestFactory.make(ECFMGDefaultTestData.SystemAdminUser.class, new User(alias='flastt3', email=email3, emailencodingkey='UTF-8',lastname=lastname3, languagelocalekey='en_US', localesidkey='en_US', profileid=profileId3, country=UNITED_STATES, IsActive=true, ContactId=c3.Id, timezonesidkey=AMERICA_LA, username=userName3));
      	run();
		Service__c serv = (Service__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultServiceTestData.class, new Service__c(Name = 'Performance Data'));
        run();
        Account2Service__c acc2Service = (Account2Service__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccount2ServiceTestData.class, new Account2Service__c(Account__c = acc.Id, Active__c = TRUE, Service__c = serv.Id));
        run();
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContact2AccSerData.class, new CONTACT2ACCTSERVICE__c(Account_Service__c = acc2Service.Id, Role__c = 'User', Service_Contact__c=c2.Id));
        run();
        System.assertEquals(acc2Service.Id != NULL, TRUE);
    }
}