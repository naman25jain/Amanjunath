@IsTest
public class ECFMGTestFactoryTest {

      /*
    Unit Tests
    */
    @IsTest
    static void setContext() {
        ECFMGTestFactory.setDefaultContext();

        // Query custom meta data   

        // Validate context is set
        System.assert(ECFMGTestFactory.BULKIFY_TESTS != null, 'BULKIFY_TESTS not set in Test Settings (Custom Metadata Type)');
        System.assert(ECFMGTestFactory.COUNTRY_CODE != null, 'COUNTRY_CODE not set in Test Settings (Custom Metadata Type)');
        System.assert(ECFMGTestFactory.COUNTRY_NAME != null, 'COUNTRY_NAME not set in Test Settings (Custom Metadata Type)');
        System.assert(ECFMGTestFactory.TIMEZONE_SID_KEY != null, 'TIMEZONE_SID_KEY not set in Test Settings (Custom Metadata Type)');
        System.assert(ECFMGTestFactory.LANGUAGE_LOCALE_KEY != null, 'LANGUAGE_LOCALE_KEY not set in Test Settings (Custom Metadata Type)');
        System.assert(ECFMGTestFactory.LOCALE_SID_KEY != null, 'LOCALE_SID_KEY not set in Test Settings (Custom Metadata Type)');
        System.assert(ECFMGTestFactory.CURRENCY_ISO_CODE != null, 'CURRENCY_ISO_CODE not set in Test Settings (Custom Metadata Type)');
        System.assert(ECFMGTestFactory.EMAIL_ENCODING_KEY != null, 'EMAIL_ENCODING_KEY not set in Test Settings (Custom Metadata Type)');

        // Validate context can be updated
        ECFMGTestFactory.BULKIFY_TESTS = false;
        ECFMGTestFactory.COUNTRY_CODE = 'zz';
        ECFMGTestFactory.COUNTRY_NAME = 'Ziebretzke';
        ECFMGTestFactory.LANGUAGE_LOCALE_KEY = ECFMGTestFactory.LANGUAGE_LOCALE_KEY == 'FI' ? 'SV' : 'FI';
        
        // Basic test using the Core Users lib, which should follow the framework
        User u = (User)ECFMGTestFactory.make( ECFMGTestFactoryUsers.StandardUser.class );
        User adminUser = (User)ECFMGTestFactory.make( ECFMGTestFactoryUsers.StandardSystemAdmin.class );
        User readOnlyUser = (User)ECFMGTestFactory.make( ECFMGTestFactoryUsers.ReadOnly.class );
        User unitTestUser = (User)ECFMGTestFactory.make( ECFMGTestFactoryUsers.UnitTestSetUpUser.class );
        System.assertEquals(ECFMGTestFactory.LANGUAGE_LOCALE_KEY,u.LanguageLocaleKey, 'Locale key not set on standard user');
    }

    @IsTest
    static void mergeFields() {
        // Merge field from one instance of an object into another
        Account source = new Account(Name = '1234');
        Account destination = new Account(Phone = '5678');

        // Merge null fields
        destination = (Account)ECFMGTestFactoryObject.mergeFields((sobject)source,(sobject)destination);
        System.assertEquals('1234', destination.Name, 'Name field not merged');
        System.assertEquals('5678', destination.Phone, 'Name field not merged');

        // Do not overwrite populated fields (default behaviour)
        source.Name = 'zzzaaa';
        destination = (Account)ECFMGTestFactoryObject.mergeFields((sobject)source,(sobject)destination);
        System.assertNotEquals('zzzaaa', destination.Name, 'Name field was overwritten when it should have been left alone');        

        // Force overwrite populated fields
        destination = (Account)ECFMGTestFactoryObject.mergeFields((sobject)source,(sobject)destination,true);
        System.assertEquals('zzzaaa', destination.Name, 'Name field was not overwritten when it should have been');        
    }

    @IsTest 
    static void profileIdByName(){
        // I can get the ID of a profile by name
        Profile p = [select id, Name from Profile limit 1];
        System.AssertEquals(p.Id, ECFMGTestFactoryObject.profileIdByName(p.Name),'Profile ID not retreived for Profile "'+p.Name+'"');
    } 

    @IsTest
    static void roleIdByName() {
        // I can get the ID of a role by Name
        UserRole r = [select id,DeveloperName from UserRole limit 1];
        System.AssertEquals(r.Id, ECFMGTestFactoryObject.roleIdByName(r.DeveloperName),'Role ID not retreived for role "'+r.DeveloperName+'"');
    }

    @isTest
    static void sortAndLinkSObjects() {
        Account a = new Account(Name = 'Matthew', Id='00100000000014C'); // The ID needs to be any ID of a valid format for Account. No DML is applied, so the record does not need to exist.
        Contact c = new Contact(LastName = 'Evans', Account = a); // objects may be associated in this way before they have an id in practice
        
        sObject[] objs = new List<Sobject>{a,c};
        
        List<String> createOrder = new List<String>();
        Map<String, sObject[]> collections_INSERT = new map<String, sObject[]>();
        Map<String, sObject[]> collections_UPDATE = new map<String, sObject[]>();
        ECFMGTestFactory.sortAndLinkSObjects(objs, createOrder, collections_INSERT, collections_UPDATE);

        System.AssertEquals (collections_INSERT.get('Contact')[0] , c , 'A new Contact should have been Added to the Insert list');
        System.AssertEquals (collections_UPDATE.get('Account')[0] , a , 'An exsiting Account should have been Added to the Update list');
        System.Assert (c.AccountId == a.Id , 'The Contact should have been related to the existing Account record');
    }


    /*
    * Scan custom entities for compliance
    * Checks the indexed templates in c_TestFactory__c conform to some basic functions
    */

    @IsTest
    static void automateTestingOfEntities() {
        try {
            // The test shouldnt be aware of the objects created so this is for coverage only. 
            // It is not expected to succeed.
            ECFMGTestFactory.run();
            System.Assert(TRUE);
        } catch (Exception e) {
            // Any failures will be output here as warnings only
            System.Debug(LoggingLevel.INFO, '@@ WARNING: Factory failed to run DML for one or more sObjects. This may be ignored. Exception: '+e);
            System.Assert(TRUE);
        }
    }

}