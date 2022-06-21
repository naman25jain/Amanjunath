/**
 * Batch class for Daily auto-notification to school informing that the new scores have been published
 *
 * @author        Enable Consulting
 * @version       1.0
 * @createdDate   30-APR-2020
 */
public with sharing class EntityPerformanceDataNotificationBatch implements Database.Batchable<sObject> {


    private String query;

    /**
	 * Created by Chinmay Menon
	 * Purpose : Constructor to pass the query from the Scheduler Class
	 */
    public EntityPerformanceDataNotificationBatch(String soql) {
        query = soql;
    }


    // The batch job starts
    public Database.Querylocator start(Database.BatchableContext bc){
        return Database.getQuerylocator(query);
    }

    // The batch job executes and operates on one batch of records
    public void execute(Database.BatchableContext bc, List<Contact> scope){

        List<Messaging.SingleEmailMessage> msgsToBeSent = new List<Messaging.SingleEmailMessage>();
        List<OrgWideEmailAddress> addr  = [select Id from OrgWideEmailAddress where displayname =: Constants.ORG_WIDE_ADDRESS];

        for(Contact con : scope){
            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
            msg.setTemplateId( [select id from EmailTemplate where DeveloperName='Entity_Performance_Data_Daily_Notification'].id );
            msg.setToAddresses(new List<String>{con.email});
            msg.setTargetObjectId(con.id);
            msg.setOrgWideEmailAddressId(addr[0].Id);
            msgsToBeSent.add(msg);
        }

        try {
            Messaging.sendEmail(msgsToBeSent);
        } catch(Exception e){
            system.debug('Data notification Mail sending exception>>>>'+ e);
        }
    }

    // The batch job finishes
    public void finish(Database.BatchableContext bc){
        AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        System.debug('>>>> finish ' + job.Status);
    }
}