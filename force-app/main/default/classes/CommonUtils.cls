/**
 * Sampath Karnati
 * * Common  Utils 
 * ? Exposed as Public
 */
public with sharing class CommonUtils {

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public static HttpResponse getDocumentFromAzure(string url) {
        try 
        {
            string urlWithSasToken = CloudStorageUtils.getRequestUrl(DocumentEnums.DocumentAccessLevel.READ, getFileNameFromUrl(url));
            
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setMethod('GET');
            httpRequest.setEndpoint(urlWithSasToken);

            Http httpCall = new Http();
            HttpResponse response = httpCall.send(httpRequest);
            
            return response;
        } catch (Exception e) {
            throw e;
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public static Boolean logMessage(Log_Message__c logMessage){
        if(!Test.isRunningTest() && Log_Message__c.SObjectType.getDescribe().isCreateable()) 
        {
            insert logMessage;
        }
        return true;
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public static String getFileNameFromUrl(string url){
        List<String> parts = url.split('/');
        return parts[parts.size()-1];
    }
     //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}