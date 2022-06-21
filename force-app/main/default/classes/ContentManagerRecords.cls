public with sharing class ContentManagerRecords {
    @AuraEnabled
    public static Map<String, String> FetchContentManagerRecords(List<String> cmUniqueNames) {
        Map<String, String> contentManagerRecords = new Map<String, String>();
        List<Content_Manager__c> cmRecords = [SELECT Id, Content__c, Unique_Name__c	FROM Content_Manager__c WHERE Unique_Name__c IN: cmUniqueNames];
        for(Content_Manager__c eachCMRecord: cmRecords){
            if(eachCMRecord.Content__c != null){
                contentManagerRecords.put(eachCMRecord.Unique_Name__c, eachCMRecord.Content__c);
            }
        }
        return contentManagerRecords;
    }
}