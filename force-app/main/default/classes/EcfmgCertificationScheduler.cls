//Scheduler class for EcfmgCertificationBatch
global with sharing class EcfmgCertificationScheduler implements Schedulable {    
    global void execute(SchedulableContext context) {
        Integer batchSize = Integer.valueOf(System.Label.EcfmgCertificationBatch_Size);
		EcfmgCertificationBatch b = new EcfmgCertificationBatch();
		Database.executeBatch(b, batchSize);
	}
}