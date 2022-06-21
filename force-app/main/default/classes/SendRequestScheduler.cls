//Scheduler to create next send request based on current send count
global with sharing class SendRequestScheduler implements Schedulable{
    global void execute(SchedulableContext context){
        SendRequestBatch b = new SendRequestBatch();
		Database.executeBatch(b);
	}
}