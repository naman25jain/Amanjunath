public with sharing class AzureFileViewerController {
    //Method to get azure url with sas token
    @AuraEnabled
    public static String getAzureUrl(Id recId){
        String url = '';
        Asset assetRec = [SELECT Id, Azure_Storage_URL__c FROM Asset WHERE Id =: recId WITH SECURITY_ENFORCED];
        if(String.isNotBlank(assetRec.Azure_Storage_URL__c)){
            String fileName = assetRec.Azure_Storage_URL__c.split('/')[4];
            url = CloudStorageUtils.getFileUrlWithSAS(fileName);
        }
        return url;
    }
    //Method to get Document URL from Case Object with sas token
    @AuraEnabled
    public static String getDocumentUrl(Id recId){
        String url = '';
        Case caseRec = [SELECT Id, Document_URL__c FROM Case WHERE Id =: recId WITH SECURITY_ENFORCED];
        if(String.isNotBlank(caseRec.Document_URL__c)){
            String fileName = caseRec.Document_URL__c.split('/')[4];
            url = CloudStorageUtils.getFileUrlWithSAS(fileName);
        }
        return url;
    } 
}