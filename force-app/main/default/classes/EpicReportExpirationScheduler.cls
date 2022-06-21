global with sharing class EpicReportExpirationScheduler implements Schedulable{
	public void execute(SchedulableContext sc){
      EpicReportExpirationBatchClass b = new EpicReportExpirationBatchClass(); 
      Database.executeBatch(b,100);
    }
}