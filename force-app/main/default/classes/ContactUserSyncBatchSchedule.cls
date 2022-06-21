//Description: This is the Schedule Class for the Batch Class ContactUserSyncBatch
global with sharing class ContactUserSyncBatchSchedule Implements Schedulable{
      global void execute(SchedulableContext sc){
         ContactUserSyncBatch instance = new ContactUserSyncBatch();
         Database.Executebatch(instance,200);
      }
}