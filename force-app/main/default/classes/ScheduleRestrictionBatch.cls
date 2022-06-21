public without sharing class ScheduleRestrictionBatch implements System.Schedulable {
    public void execute(SchedulableContext sc) {

        Database.executeBatch(new RestrictionProcessBatch(), 200);
    }
}