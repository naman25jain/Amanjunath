/**
 * Batch class for Enrollment Verification daily email notification
 *
 * @author        Nayana Suresh
 * @version       1.0
 * @createdDate   09-JUN-2020
 */
global with sharing class EntityEnrollmentVerificationDailyBatch implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Id evCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION).getRecordTypeId();
        
        String query = 'SELECT Id, AccountId'
            +' FROM Case WHERE RecordTypeId = \''+ evCaseRecordTypeId +'\''
            +' AND Verification_Status__c =  \'' + Constants.CASE_VERIFICATION_STATUS_NOT_REVIEWED +'\''
            +' AND Status_Not_Reviewed_Date__c = TODAY'; 
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Case> caseList) {
        Set<Id> accountIdSet = new Set<Id>();
        List<Messaging.SingleEmailMessage> mailToSentList = new List<Messaging.SingleEmailMessage>();
        Id entityContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_ENTITY_CONTACT).getRecordTypeId();
        Set<Id> contactIdWithEntitySet = new Set<Id>();

        Id emailTemplateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: Constants.EV_NOT_REVIEWED_DAILY_TEMPLATE].Id;

        for(Case evcase : caseList) {
            accountIdSet.add(evcase.AccountId);
        }

        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, Email 
            FROM Contact 
            WHERE AccountId IN : accountIdSet AND RecordTypeId =: entityContactRecordTypeId]);

        for(Contact2AcctService__c ctas : [SELECT Id, Service_Contact__c
                                            FROM Contact2AcctService__c 
                                            WHERE Service_Contact__c =: contactMap.values() AND Active__c = true
                                            AND Service__c =: Constants.SERVICE_NAME_ENROLLMENT_VERIFICATION]) {
            contactIdWithEntitySet.add(ctas.Service_Contact__c);
        }    

        for(Id conId : contactIdWithEntitySet) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateId(emailTemplateId);
            mail.setToAddresses(new List<String>{contactMap.get(conId).Email});
            mail.setTargetObjectId(conId);
            mailToSentList.add(mail);
        }
        try {
            Messaging.sendEmail(mailToSentList);
        } 
        catch(Exception e){
            system.debug('Enrollment Verification Daily Mail sending exception ::'+ e.getMessage());
        }
    }
    global void finish(Database.BatchableContext bc) {
        // execute any post-processing operations
    }    
}