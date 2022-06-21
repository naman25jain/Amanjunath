public with sharing class OFACContactRequestBatchScheduler implements Schedulable{
    // Execute at regular intervals
    public void execute(SchedulableContext ctx){
        String soql = 'SELECT Id, Name, Birthdate, Current_Citizenship__c, Gender__c, Passport_Number__c, Passport_Country__c, 	ECFMG_ID__c,'
        + ' Phone, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry,'
        + ' OFAC_Scan_BatchId__c, Generational_Suffix__c, National_Identification__c, National_ID_Country__c,  US_Social_Security__c'
        + ' FROM Contact'
        + ' WHERE Name != null'
        + ' AND OFAC_Scan_Required__c = true'
        + ' AND OFAC_Scan_BatchId__c = null'
        + ' WITH SECURITY_ENFORCED';
        
        OFACContactRequestBatch batch = new OFACContactRequestBatch(soql);
        Database.executeBatch(batch, 400); //assuming each applicant record is approx. 300 chars long, into 131,072 chars (max payload size), and you have 436 applicants per batch. Rounded down to 400.
    }
}