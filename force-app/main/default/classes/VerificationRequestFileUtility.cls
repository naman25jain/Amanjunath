public with sharing class VerificationRequestFileUtility {
    public static List<Verification_Request_File__c> getVerificationRequestFiles(String verificationRequestId, string vrfSatus){
        if(String.isBlank(verificationRequestId)){
             throw new InvalidParameterException('verificationRequestId cannot be empty');
        }
        List<Verification_Request_File__c> req =
                [SELECT
                        Comment__c,
                        CreatedById,
                        CreatedDate,
                        Document_Issue_Date__c,
                        Document_Name__c,
                        Document_Number__c,
                        Document_Type__c,
                        Embedded__c,
                        File_Name__c,
                        Id,
                        IsDeleted,
                        LastModifiedById,
                        LastModifiedDate,
                        LastReferencedDate,
                        LastViewedDate,
                        Name,
                        Name_On_Document__c,
                        Page_Count__c,
                        Status__c,
                        SystemModstamp,
                        Verification_Request__c,
                        Verification_Request_Status__c,
                        Azure_Storage_URL__c

                FROM
                        Verification_Request_File__c
                WHERE
                        Verification_Request__c = :verificationRequestId
                AND     Status__c = :vrfSatus];
        return req;
    }
}