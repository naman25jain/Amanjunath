@isTest
private class OFACContactRequestBatchTest {

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

    @testSetup static void setup() {
        List<Contact> contacts = new List<Contact>();
        for(Integer i=0; i<10; i++){
            Contact con = new Contact(FirstName = 'FirstName' + i, 
                                      LastName = 'LastName' + i, 
                                      Gender__c = 'Male',
                                      OFAC_Scan_BatchId__c = null,
                                      OFAC_Scan_Required__c = true, 
                                      Phone ='666777888'+i,
                                      Birthdate = date.parse('12/30/2001'),
                                      Generational_Suffix__c = 'Sr',
                                      National_Identification__c = '123456'+i,
                                      National_ID_Country__c = 'India',
                                      Current_Citizenship__c= 'India',
                                      US_Social_Security__c = '123-45-6789',
                                      Passport_Number__c = '987654'+ i,
                                      Passport_Country__c = 'India',
                                      mailingStreet = '5 Delhi Rd',
                                      mailingCity = 'New Delhi',
                                      mailingCountry = 'India',
                                      mailingPostalCode= '00012');
            contacts.add(con);
        }
        insert contacts;
    }

    @isTest
    static void testBatchExecute(){
        String soql = 'SELECT Id, Name, Birthdate, Current_Citizenship__c, Gender__c, Passport_Number__c, Passport_Country__c, 	ECFMG_ID__c,'
        + ' Phone, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry,'
        + ' OFAC_Scan_BatchId__c, Generational_Suffix__c, National_Identification__c, National_ID_Country__c,  US_Social_Security__c'
        + ' FROM Contact'
        + ' WHERE Name != null'
        + ' AND OFAC_Scan_Required__c = true'
        + ' AND OFAC_Scan_BatchId__c = null'
        + ' WITH SECURITY_ENFORCED';

        Test.startTest();
        Database.executeBatch(new OFACContactRequestBatch(soql), 10);
        Test.stopTest();

        List<Contact> contactsWithBatchId = [SELECT OFAC_Scan_BatchId__c FROM Contact WHERE OFAC_Scan_BatchId__c != null];
        System.AssertEquals(10,contactsWithBatchId.size(),'Returned number of records does not match expected value');
    }

    @isTest
    static void testUpdateContactsError(){
        List<Contact> contacts = [SELECT OFAC_Scan_BatchId__c FROM Contact WHERE OFAC_Scan_Required__c = true];

        for(Contact con : contacts){
            con.OFAC_Scan_BatchId__c = 'CON12345678901234567890X'; //batch id too large
        }

        Test.startTest();
        Boolean result = OFACSearchHandler.updateContacts(contacts);
        Test.stopTest();

        System.AssertEquals(false,result,'Returned invalid boolean value');
    }
}