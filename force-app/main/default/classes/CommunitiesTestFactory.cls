@isTest
public class CommunitiesTestFactory {

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
    
    public static string emailtest { 
    	get {
        	return 'tester@unknownmail.com';
    	}
    }
    
    public static string contentdocForContact(string Labeldata, string ContactId) {
        Id networkId = [SELECT Id, name from Network WHERE Name = 'Applicant 360'].Id;
        System.assert(networkId <> null , 'Netword Id is Empty');
        ContentVersion cv = new ContentVersion(Title=Labeldata, PathOnClient=Labeldata + '.jpg',VersionData=Blob.valueOf('Test Content'),IsMajorVersion=true, networkId= networkId);
        insert cv;
        return cv.Id;
        
    } 
    @isTest 
	public static void setup() {


        //create a new contact;
        list<contact> lc = new list<contact>();
        list<sObject> insertlist = new list<sObject>();
        date birthdate1 = date.valueOf('2000-01-01');
        string emailtest = 'tester@unknownmail.com';
        String userName = 'tester@unknownmail.com_' + System.now();
        userName=userName.replace(' ','').replace(':','-');
        string lastname = 'Last';
        string firstname = 'First';
        Contact c1 = new Contact(Firstname=firstname,Lastname=lastname,Birthdate=birthdate1,email=CommunitiesTestFactory.emailtest);
        insert c1;
       
        //get the Household Account
        string accountname = lastname + ' Household';
        Account a = [Select Id from Account where name= :accountname LIMIT 1];
        system.debug(a);
        
        Id p=[Select id from profile where name='4-Customer Community Plus Login' LIMIT 1].id;
        //create a new User row
        User user = new User(alias='flastt',email=emailtest,emailencodingkey='UTF-8',lastname=lastname, languagelocalekey='en_US',localesidkey='en_US',profileid=p,country='United States',IsActive=true,ContactId=c1.Id, timezonesidkey='America/Los_Angeles',username=userName);
        insert user;
        
         birthdate1 = date.valueOf('2000-01-01');
         emailtest = 'tester@unknownmail.com';
         lastname = 'User';
         firstname = 'Test';
        id contrecordtypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Registered_User').getRecordTypeId();
        Contact c2 = new Contact(Firstname=firstname,Lastname=lastname,Birthdate=birthdate1,email=CommunitiesTestFactory.emailtest, recordtypeId = contrecordtypeId );
        insert c2;
        
        
    }
    
}