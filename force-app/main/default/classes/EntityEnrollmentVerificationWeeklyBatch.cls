/**
 * Batch class for Enrollment Verification weekly email notification
 *
 * @author        Nayana Suresh
 * @version       1.0
 * @createdDate   10-JUN-2020
 */
global with sharing class EntityEnrollmentVerificationWeeklyBatch implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Id evCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION).getRecordTypeId();
        
        String query = 'SELECT Id, AccountId'
            +' FROM Case WHERE RecordTypeId = \''+ evCaseRecordTypeId +'\''
            +' AND Verification_Status__c =  \'' + Constants.CASE_VERIFICATION_STATUS_NOT_REVIEWED +'\''; 
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Case> caseList) {
        List<Messaging.SingleEmailMessage> mailToSentList = new List<Messaging.SingleEmailMessage>();
        Map<Id, Integer> accountNotReviewedCount = new Map<Id, Integer>();
        Set<Id> contactIdWithEntitySet = new Set<Id>();

        Id entityContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_ENTITY_CONTACT).getRecordTypeId();
        
        EmailTemplate weeklyEmailTemplate = [SELECT Id, HtmlValue, Subject FROM EmailTemplate WHERE DeveloperName =: Constants.EV_NOT_REVIEWED_WEEKLY_TEMPLATE];

        for(Case evcase : caseList) {
            if(accountNotReviewedCount.containsKey(evcase.AccountId)) {
                Integer evCount = accountNotReviewedCount.get(evcase.AccountId) + 1;
                accountNotReviewedCount.put(evcase.AccountId, evCount);
            }
            else {
                accountNotReviewedCount.put(evcase.AccountId,1);
            }
        }

        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, Email, AccountId 
            FROM Contact 
            WHERE AccountId IN : accountNotReviewedCount.keySet() AND RecordTypeId =: entityContactRecordTypeId]);

        for(Contact2AcctService__c ctas : [SELECT Id, Service_Contact__c
                                            FROM Contact2AcctService__c 
                                            WHERE Service_Contact__c =: contactMap.values() AND Active__c = true
                                            AND Service__c =: Constants.SERVICE_NAME_ENROLLMENT_VERIFICATION]) {
            contactIdWithEntitySet.add(ctas.Service_Contact__c);
        }    
        
        List<OrgWideEmailAddress> addr  = [select Id from OrgWideEmailAddress where displayname =: Constants.ORG_WIDE_ADDRESS];
        for(Id conId : contactIdWithEntitySet) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateId(weeklyEmailTemplate.Id);
            mail.setToAddresses(new List<String>{contactMap.get(conId).Email});
            mail.setTargetObjectId(conId);
            mail.setOrgWideEmailAddressId(addr[0].Id);

            String htmlBody = weeklyEmailTemplate.HtmlValue;
            htmlBody = htmlBody.replace('[!NUMBER_OF_REQUESTS]', String.valueOf(accountNotReviewedCount.get(contactMap.get(conId).AccountId)));
            htmlBody = htmlBody.replaceAll('<!\\[CDATA\\[', '');
            htmlBody = htmlBody.replaceAll('\\]\\]>', '');

            mail.setHtmlBody(htmlBody);
            mail.setSubject(weeklyEmailTemplate.Subject);

            mailToSentList.add(mail);
        }
        try {
            Messaging.sendEmail(mailToSentList);
        } 
        catch(Exception e){
            system.debug('Enrollment Verification Weekly Mail sending exception ::'+ e.getMessage());
        }
    }
    global void finish(Database.BatchableContext bc) {
        // execute any post-processing operations
    }    
}