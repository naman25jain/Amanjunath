@isTest
public class RunTestClassesJobTest {

    @isTest
    static void test() {
        Test.startTest();
        ApexClass obj = new ApexClass();
        obj.Id = '01p170000087CEjAAM';
        obj.Name = 'ExamRegistrationControllerTest';
        Test.setMock(HttpCalloutMock.class, new OrgRESTMock(200));
        CodeCoverageExportController.saveCSVtoFiles('Test Blob');
        CodeCoverageExportController.saveCSVtoFiles('Test Blob');
        RunTestClassesJob uca = new RunTestClassesJob();
        RunTestClassesJob.lstApexClasses = new list<ApexClass>{obj};
        Id batchId = Database.executeBatch(uca);
        Test.stopTest();
    }

    @isTest
    static void testSchedule() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OrgRESTMock(200));
        CodeCoverageExportController.saveCSVtoFiles('Test Blob');
        CodeCoverageExportController.saveCSVtoFiles('Test Blob');
        RunTestClassesJobScheduler schObj = new RunTestClassesJobScheduler(); 
        String sch ='0 48 * * * ?'; 
        System.schedule('Schedule Test class', sch,schObj);
        Test.stopTest();
    }
}