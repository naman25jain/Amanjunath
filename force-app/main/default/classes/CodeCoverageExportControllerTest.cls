@isTest
public class CodeCoverageExportControllerTest {
    public static List<CodeCoverageExportController.ParseCSVInfo> selectedRecords = new List<CodeCoverageExportController.ParseCSVInfo>();
    
    @isTest
    static void invokeTestMethods(){
        Test.startTest();
        buildListOfRecordsForEmail();
        Test.setMock(HttpCalloutMock.class, new OrgRESTMock(200));
        CodeCoverageExportController.exportClassCoverage();
        CodeCoverageExportController.saveCSVtoFiles('Code Coverage.csv');
        CodeCoverageExportController.saveCSVtoFiles('Code Coverage.csv\nTest\nCoverage');
        CodeCoverageExportController.getTestQueueData();
        CodeCoverageExportController.sentEmails(selectedRecords, 'test@gmail.com', 'CompareBtn');
        CodeCoverageExportController.sentEmails(selectedRecords, 'test@gmail.com', 'TestResBtn');
        CodeCoverageExportController.sentEmails(selectedRecords, 'test@gmail.com,ssp@gmail.con', 'seealldata');
        CodeCoverageExportController.getApexTestResults();
        CodeCoverageExportController.getSeeAllDataTestClasses();
        CodeCoverageExportController.runAllTestClasses();
        CodeCoverageExportController.CSVData objCSVData = new CodeCoverageExportController.CSVData();
        objCSVData.ApexClassOrTrigger = 'CodeCoverageExportController';
        objCSVData.PercentageCovered = '80%';
        
        CodeCoverageExportController.createCSVFileFromBatch(new list<CodeCoverageExportController.CSVData>{objCSVData}, new list<String>{'ApexClassOrTrigger', 'PercentageCovered'});
        try{
            CodeCoverageExportController.readCsvDataFromFile();
            CodeCoverageExportController.saveCSVtoFiles('Code Coverage.csv\nTest');
        } Catch(Exception e){
            System.assertEquals(true, e.getMessage().contains('Script-thrown exception'));
        }
        
        Test.stopTest();
    }
    
    @isTest
    static void orgRestError(){
        Test.startTest();
        buildListOfRecordsForEmail();
        Test.setMock(HttpCalloutMock.class, new OrgRESTMock(302));
        try{                        
            CodeCoverageExportController.exportClassCoverage();
            CodeCoverageExportController.saveCSVtoFiles('Code Coverage.csv');
            CodeCoverageExportController.saveCSVtoFiles('Code Coverage.csv\nTest\nCoverage');
            CodeCoverageExportController.getTestQueueData();
            CodeCoverageExportController.sentEmails(selectedRecords, 'test@gmail.com', 'CompareBtn');
            CodeCoverageExportController.sentEmails(selectedRecords, 'test@gmail.com', 'TestResBtn');
            CodeCoverageExportController.sentEmails(selectedRecords, 'test@gmail.com,ssp@gmail.con', 'seealldata');
            CodeCoverageExportController.getApexTestResults();
            CodeCoverageExportController.getSeeAllDataTestClasses();
            
            try{
                CodeCoverageExportController.readCsvDataFromFile();
                CodeCoverageExportController.saveCSVtoFiles('Code Coverage.csv\nTest');
            } Catch(Exception e){
                System.assertEquals(true, e.getMessage().contains('Script-thrown exception'));
            }
        } catch(Exception e){
            System.assertEquals(true, e.getMessage().contains('Argument 1 cannot be null'));
        }
        
        Test.stopTest();
    }
    
    @isTest
    static void orgRestWithBody(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OrgRESTMock(200));
        OrgREST.retriveResult('tooling/query/?q=Select+id,ApexClassorTriggerId,ApexClassorTrigger.Name,NumLinesCovered,NumLinesUncovered+from+ApexCodeCoverageAggregate', 'GET', 'Test Body');
        Test.stopTest();
    }
    
    
    static void buildListOfRecordsForEmail(){
        String classNames = 'PrintResponseEventTrigger;VerificationRevIncomController';
        for(Integer i=0; i<classNames.split(';').size(); i++){
            CodeCoverageExportController.ParseCSVInfo eachRecord = new CodeCoverageExportController.ParseCSVInfo();
            eachRecord.ApexClassOrTrigger = classNames.split(';')[i];
            eachRecord.NewPercentage = '0%';
            eachRecord.oldPercentage = '0%';
            eachRecord.PercentageChange = '0%';
            selectedRecords.add(eachRecord);
        }
        
    }
}