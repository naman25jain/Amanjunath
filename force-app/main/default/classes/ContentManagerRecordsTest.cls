@isTest
public class ContentManagerRecordsTest extends ECFMGTestFactory {
	@TestSetup
    public static void generateData(){
        Content_Manager__c cmRecords = (Content_Manager__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContentManagerTestData.class, new Content_Manager__c(Content__c = 'I am content', Unique_Name__c = 'IamUnique', Name = 'I am Title', Process_Flow__c = 'General'));
        run();
    }
    
    @isTest
    public static void invokeContentManagerRecords(){
        Content_Manager__c cmRecord = [SELECT Id, Unique_Name__c FROM Content_Manager__c LIMIT 1];
        List<String> uniqueNames = new List<String>();
        uniqueNames.add(cmRecord.Unique_Name__c);
        ContentManagerRecords.FetchContentManagerRecords(uniqueNames);
    }
}