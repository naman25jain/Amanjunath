public with sharing class ApplicantMyProfileUsernameChangeSchedule implements Schedulable{
    public void execute(SchedulableContext sc){
        ApplicantMyProfileUsernameChange b1 = new ApplicantMyProfileUsernameChange();
        Database.executeBatch(b1,10);
    }
}