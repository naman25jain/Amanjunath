@isTest
private class Entity_360_Base_ControllerTests {
    
   
    @testSetup static void setup() {
        
        Contact c1 = new Contact(Firstname='firstname',Lastname='lastname',email=CommunitiesTestFactory.emailtest);
        insert c1;
        
        Profile p = [ Select id from Profile where name = '4-Customer Community Entity 360' limit 1];
        
        User u = new User();
        u.FirstName = 'Test User - 1';
        u.LastName = 'Entity_360';
        u.Email = 'tester@unknownmail.com';
        u.ContactId = c1.Id;
        u.Username = 'tester@un.com';
        u.Alias = 'test';     
        u.TimeZoneSidKey = 'America/Denver';
        u.LocaleSidKey =  'en_US';
        u.EmailEncodingKey = 'UTF-8';       
        u.ProfileId = p.Id;       
        u.LanguageLocaleKey = 'en_US';     
        insert u;
        
        
            
       //String conId = CommunityIdentityVerificationController.getRunningContactId();
        //String contactId = CommunityIdentityVerificationController.getRunningContactId();
        Terms_and_Conditions__c tc1 = new Terms_and_Conditions__c(Name='A', Status__c = 'Active', ExpirationDate__c = Date.Today()+7);
        Terms_and_Conditions__c tc2 = new Terms_and_Conditions__c(Name='Certification by Applicant', Status__c = 'Active', ExpirationDate__c = Date.Today()+7);
        insert tc1;
        insert tc2;
        
          
        
    }
    
    
    @isTest
    public static void systemTests1() {
        
        Test.startTest();
        String conId = CommunityIdentityVerificationController.getRunningContactId();
        //[SELECT id, ContactId from User where email = :CommunitiesTestFactory.emailtest AND ContactId != null LIMIT 1].ContactId;
        //User u = [SELECT id, ContactId from User where email = :CommunitiesTestFactory.emailtest AND ContactId = :conId AND Profile.Name LIKE '%Community%' LIMIT 1 ];
		Account a = [Select Id FROM Account][0];
        
        Contact c1 = [SELECT Id FROM Contact WHERE email =: CommunitiesTestFactory.emailtest];
       
        Case cs = new Case ( Eligible_For_Online_Notary__c = 'yes', ContactId = c1.Id);
        insert cs;  
        
        String ContactId = c1.Id;
        
        Entity_360_Base_Controller.getInitContactInfo('A');
        Entity_360_Base_Controller.getContact();
        Contact c = Entity_360_Base_Controller.getContactById(conId);
        Entity_360_Base_Controller.getCountries();
        Entity_360_Base_Controller.addPrivacy('A');
        Entity_360_Base_Controller.updateContactInformation(c);
        c.Email = 'newteste@ecfmg.org';
        Entity_360_Base_Controller.updateContactInformationWithEmail(c);
        Entity_360_Base_Controller.createEntityInfoChangeCase(a.Id, 'Test');
        a = Entity_360_Base_Controller.getAccount(a.Id);
        Entity_360_Base_Controller.postChatter(cs.Id, 'Test');
        Entity_360_Base_Controller.getChatterPosts(a.Id);
        Entity_360_Base_Controller.getGenderPicklistEntries();
        Entity_360_Base_Controller.getGenerationalSuffixPicklistEntries();
        
        Map <String, Object> fieldMap = new Map <String, Object>();
        List <Map <String, Object>> fieldlist = new List <Map <String, Object>>();          
        fieldMap = new Map <String, Object>();
        fieldlist = new List <Map <String, Object>>();
        fieldMap.put('Id', conId);
        fieldMap.put('Previous_EPIC_Services__c', 'false');
        fieldMap.put('Applicant_Provided_USMLE_ID__c', 'true');
        fieldMap.put('Applicant_Provided_EPIC_ID__c', 'true');
        fieldMap.put('Passport_Expiration__c', '');
        fieldMap.put('USMLE_ID__c', '12312');
        fieldMap.put('Department', 'Salesforce');
        fieldlist.add(fieldMap);
        String fieldJSON = JSON.serialize(fieldlist);
        Entity_360_Base_Controller.updateContact(ContactId, fieldJSON.replace('[','').replace(']',''));
        Test.stopTest();
        
       
	}
    
    /*@isTest
    public static void systemTests2() {
        
        Test.startTest();
        String conId = CommunityIdentityVerificationController.getRunningContactId();
        //[SELECT id, ContactId from User where email = :CommunitiesTestFactory.emailtest AND ContactId != null LIMIT 1].ContactId;
        //User u = [SELECT id, ContactId from User where email = :CommunitiesTestFactory.emailtest AND ContactId = :conId AND Profile.Name LIKE '%Community%' LIMIT 1 ];
		Account a = [Select Id FROM Account][0];
       
        date birthdate1 = date.valueOf('2000-01-01');
        Contact c1 = new Contact(Firstname='firstname',Lastname='lastname', Birthdate = birthdate1 ,email=CommunitiesTestFactory.emailtest);
        insert c1;
        
        Case cs = new Case ( Eligible_For_Online_Notary__c = 'yes', ContactId = c1.Id);
        insert cs;  
        
        String ContactId = c1.Id;
        
        Entity_360_Base_Controller.getInitContactInfo('A');
        Entity_360_Base_Controller.getContact();
        Contact c = Entity_360_Base_Controller.getContactById(conId);
        Entity_360_Base_Controller.getCountries();
        Entity_360_Base_Controller.addPrivacy('A');
        Entity_360_Base_Controller.updateContactInformation(c);
        c.Email = 'newteste@ecfmg.org';
        Entity_360_Base_Controller.updateContactInformationWithEmail(c);
        Entity_360_Base_Controller.createEntityInfoChangeCase(a.Id, 'Test');
        a = Entity_360_Base_Controller.getAccount(a.Id);
        Entity_360_Base_Controller.postChatter(cs.Id, 'Test');
        Entity_360_Base_Controller.getChatterPosts(a.Id);
        Entity_360_Base_Controller.getGenderPicklistEntries();
        Entity_360_Base_Controller.getGenerationalSuffixPicklistEntries();
        
        Map <String, Object> fieldMap = new Map <String, Object>();
        List <Map <String, Object>> fieldlist = new List <Map <String, Object>>();          
        fieldMap = new Map <String, Object>();
        fieldlist = new List <Map <String, Object>>();
        fieldMap.put('Id', conId);
        fieldMap.put('Previous_EPIC_Services__c', 'false');
        fieldMap.put('Applicant_Provided_USMLE_ID__c', 'true');
        fieldMap.put('Applicant_Provided_EPIC_ID__c', 'true');
        fieldMap.put('Passport_Expiration__c', '');
        fieldMap.put('USMLE_ID__c', '12312');
        fieldMap.put('legal_name_consists_of_one_name_only__c', false);
        fieldlist.add(fieldMap);
        String fieldJSON = JSON.serialize(fieldlist);
        Entity_360_Base_Controller.updateContact(conId, fieldJSON.replace('[','').replace(']',''));
        Test.stopTest();
        
       
	}*/
}