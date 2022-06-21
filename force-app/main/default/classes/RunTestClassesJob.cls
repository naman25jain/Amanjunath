public class RunTestClassesJob implements Database.Batchable<sObject>,Database.AllowsCallouts {

    public static list<ApexClass> lstApexClasses = new list<ApexClass>();
    
    public static list<ApexClass> start(Database.BatchableContext bc) {
        CodeCoverageExportController.CoverageWrap lstData = CodeCoverageExportController.exportClassCoverage();
        list<CodeCoverageExportController.CSVData> lstCSVData = CodeCoverageExportController.processTestRecords(lstData);
        if(lstCSVData != null) {
            CodeCoverageExportController.createCSVFileFromBatch(lstCSVData, new list<String>{'ApexClassOrTrigger', 'PercentageCovered'});
        }

        List<List<ApexClass>> testClasses = [FIND '@istest or testmethod' 
                           IN ALL FIELDS 
                           RETURNING ApexClass(Id, Name WHERE NamespacePrefix = '')];
        
        if(!testClasses.isEmpty() && testClasses.size() > 0 && testClasses[0] != null) {
            if(!Test.isRunningTest()) {
                lstApexClasses = (list<ApexClass>)testClasses[0];
            }
            return lstApexClasses;
        }
        else {
            return null;
        }
    }
    
    
    public static void execute(Database.BatchableContext bc, list<ApexClass> lstSobjects) {
        if(lstSobjects != null && !lstSobjects.isEmpty()) {
            list<ApexTestQueueItem> lstTestItems = new list<ApexTestQueueItem>();
            for(ApexClass cls : lstSobjects) {
                lstTestItems.add(new ApexTestQueueItem(ApexClassId = cls.Id));
            }
            
            if(lstTestItems != null && !lstTestItems.isEmpty()) {
                try {
                    INSERT lstTestItems;
                }
                catch(Exception ex) {
                    System.debug('ex ==> '+ex.getMessage());
                }
            }
        }
    }
    
    public static void finish(Database.BatchableContext bc) {
        
    }
}