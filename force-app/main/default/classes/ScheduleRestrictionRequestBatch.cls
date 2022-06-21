public without sharing class ScheduleRestrictionRequestBatch implements System.Schedulable {
    public void execute(SchedulableContext sc) {

        Database.executeBatch(new RestrictionProcessBatch(), 200);
    }
}