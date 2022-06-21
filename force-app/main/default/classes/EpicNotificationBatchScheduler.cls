/**
 * Scheduler class for EpicNotificationBatch
 * @author        Enable Consulting
 * @version       1.0
 * @createdDate   24-NOV-2021
 */
public class EpicNotificationBatchScheduler implements Schedulable{
    public void execute(SchedulableContext context){
		Integer batchSize = Integer.valueOf(System.Label.EpicNotificationBatch_Size);
        EpicNotificationBatch b = new EpicNotificationBatch();
		Database.executeBatch(b, batchSize);
	}
}