/**
 * Class for initiating all Scheduled Jobs in one go
 *
 * @author        Enable Consulting : Chinmay Menon
 * @version       1.0
 * @createdDate   7-May-2020
 */
public with sharing class ScheduledJobsClass {
    public ScheduledJobsClass() {

    }

    // static method for Admin to call for initiating all jobs
    public static void initiateJobs() {

        // nightly job to auto release scores that were marked withheld initially (goes at 1:00 AM)
        system.schedule(Test.isRunningTest()?'Score Release Job1':'Score Release Job', '0 0 1 * * ? *', new ScoreReleaseScheduler());

        // nightly job to check if an enrollment re-verification case is to be created (goes at 1:30 AM)
        system.schedule(Test.isRunningTest()?'Enrollment Reverification Case Creation Job1':'Enrollment Reverification Case Creation Job', '0 30 1 * * ? *', new EnrollmentReVerificationScheduler());

        // job to check seven year rule and update voided exams (goes at 2:00 AM)
        system.schedule(Test.isRunningTest()?'Seven Year Rule Check1':'Seven Year Rule Check', '0 0 2 * * ? *', new SevenYearRuleScheduler());

        // job to notify entities enrolled for Performance Data daily (goes at 5:00 PM)
        system.schedule(Test.isRunningTest()?'Performance Data Daily Notification to Entities Job1':'Performance Data Daily Notification to Entities Job', '0 0 17 ? * * *', new PerformanceDataNotificationScheduler());

        // daily job to notify entities for Not Reviewed Enrollment Verification (goes at 10:00 PM)
        system.schedule(Test.isRunningTest()?'Not Reviewed Enrollment Verification Daily Notification Job1':'Not Reviewed Enrollment Verification Daily Notification Job', '0 0 22 * * ? *', new EntityEnrollmentVerificationDailySched());

        // weekly job to notify entities for Not Reviewed Enrollment Verification (goes at 2:00 PM on Sundays)
        system.schedule(Test.isRunningTest()?'Not Reviewed Enrollment Verification Weekly Notification Job1':'Not Reviewed Enrollment Verification Weekly Notification Job', '0 0 14 ? * SUN *', new EntityEnrollmentVerificationWeeklySched());
    }
}