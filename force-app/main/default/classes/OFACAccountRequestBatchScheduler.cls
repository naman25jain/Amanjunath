public with sharing class OFACAccountRequestBatchScheduler implements Schedulable {
    // Execute at regular intervals
    public void execute(SchedulableContext sc){
        String accRecType = Constants.ACCOUNT_RECORD_TYPE_ENTITY;
        String soql = 'SELECT Id, Name, OFAC_Scan_BatchId__c, Phone,'
        + ' Medschool_Code__c, Institution_ID__c, Account_Type__c, Entity_ID__c,'
        + ' BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry'
        + ' FROM Account'
        + ' WHERE Name != null'
        + ' AND OFAC_Scan_Required__c = true'
        + ' AND OFAC_Scan_BatchId__c = null'
        + ' AND BillingCountry != null'
        + ' AND recordtype.Name = \'' +  accRecType +  '\''
        + ' WITH SECURITY_ENFORCED';
        OFACAccountRequestBatch batch = new OFACAccountRequestBatch(soql);
        Database.executeBatch(batch, 400); //assuming each applicant record is approx. 300 chars long, into 131,072 chars (max payload size), and you have 436 applicants per batch. Rounded down to 400.
    }
}