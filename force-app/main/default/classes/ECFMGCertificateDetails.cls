public with sharing class ECFMGCertificateDetails{
    
    @AuraEnabled(cacheable = true)
    public static WrapCaseAssetData getECFMGCertificateInfo(){
        
        List<User> userList = new List<User>();
        List<Asset> assetList = new List<Asset>();
        List<Case> shippingAssetCaseList = new List<Case>();
        WrapCaseAssetData certificationData = new WrapCaseAssetData();
        String contactId = null;
        String sentDate;
        Id currentUser = UserInfo.getUserId();
        
        //Get Current loggedIn User's contact Info
        userList = [SELECT contactId FROM User WHERE Id=:currentUser WITH SECURITY_ENFORCED LIMIT 1];
        if (!userList.isEmpty()){
            contactId = userList[0].contactId;
        }
        
        //Get asset and case information from the contact's asset
        if(contactId != null){
            assetList = [SELECT Id, Name, CreatedDate, Case__c, Case__r.Id, Case__r.Tracking_Number__c, Case__r.Internal_Status__c, ContactId, 
                         Contact.MailingStreet, Contact.MailingCity, Contact.MailingState, Contact.MailingCountry, Contact.MailingPostalCode, 
                         Contact.Certificate_Issue_Date__c FROM Asset 
                         WHERE Name IN('ECFMG Certificate','Interim ECFMG Certificate','Duplicate ECFMG Certificate')
                         AND Status='Accepted' AND ContactId=:contactId WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1];
        }        
        
        //Pass details to wrapper
        if(assetList.size()>0){
            certificationdata.caseStatus = assetList[0].Case__r.Internal_Status__c;
            certificationdata.dateIssued = assetList[0].Contact.Certificate_Issue_Date__c;
            certificationdata.trackingNumber = assetList[0].Case__r.Tracking_Number__c;
            certificationdata.mailingStreet = assetList[0].Contact.MailingStreet;
            certificationdata.mailingCity = assetList[0].Contact.MailingCity;
            certificationdata.mailingState = assetList[0].Contact.MailingState;
            certificationdata.mailingCountry = assetList[0].Contact.MailingCountry;
            certificationdata.mailingPostalCode = assetList[0].Contact.MailingPostalCode;
            
            //Get Shipping Label Asset info from the related case
            if(assetList[0].Case__c != null){
                shippingAssetCaseList = [Select Id, (SELECT Id, Name, Status, CreatedDate from Assets__r 
                    			 WHERE Name IN('Shipping Label') AND Status='Accepted' LIMIT 1) FROM Case 
                    			 WHERE Recordtype.Name IN('ECFMG Certification','Duplicate Certificate')
                                 AND Id=:assetList[0].Case__c WITH SECURITY_ENFORCED LIMIT 1 ];
                if(shippingAssetCaseList.size() > 0 && shippingAssetCaseList[0].Assets__r.size() >0){
                    sentDate = String.valueOf(Date.valueOf(shippingAssetCaseList[0].Assets__r[0].CreatedDate)).removeEnd(' 00:00:00');
                }               
            }
            certificationdata.dateSent = sentDate;            
        }
        return certificationdata;
    } 
    
    public class WrapCaseAssetData{
        @AuraEnabled public String caseStatus {get; set;}
        @AuraEnabled public Date dateIssued {get; set;}
        @AuraEnabled public String dateSent {get; set;}        
        @AuraEnabled public String trackingNumber {get; set;}
        @AuraEnabled public Address sentAddress {get; set;}
        @AuraEnabled public String mailingStreet {get; set;}
        @AuraEnabled public String mailingCity {get; set;}
        @AuraEnabled public String mailingState {get; set;}
        @AuraEnabled public String mailingCountry {get; set;}
        @AuraEnabled public String mailingPostalCode {get; set;}
    }
}