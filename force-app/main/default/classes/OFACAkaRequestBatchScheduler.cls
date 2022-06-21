public with sharing class OFACAkaRequestBatchScheduler implements Schedulable{
    // Execute at regular intervals
    public void execute(SchedulableContext sc){
        String soql = 'SELECT Id, Name, WDOMS_ID__c, OFAC_Scan_BatchId__c'
        + ' FROM aka_Names__c'
        + ' WHERE Name != null'
        + ' AND OFAC_Scan_Required__c = true'
        + ' AND OFAC_Scan_BatchId__c= null'
        + ' WITH SECURITY_ENFORCED';
        OFACAkaRequestBatch batch = new OFACAkaRequestBatch(soql);
        Database.executeBatch(batch, 400); //assuming each applicant record is approx. 300 chars long, into 131,072 chars (max payload size), and you have 436 applicants per batch. Rounded down to 400.
    }
}