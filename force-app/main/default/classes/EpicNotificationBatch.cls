/*Batch class for Epic Notifications */
public class EpicNotificationBatch implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext bc){
        Id epicVerfRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_VER_REPORT_REQUEST).getRecordTypeId();
        Id credVerfRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        String query = 'SELECT Id,  RecordTypeId, Secondary_Parent_Case__r.Id, Secondary_Parent_Case__r.RecordTypeId, Entity__r.Id,'
            + ' Entity__r.Epic_Notifications__c, CreatedDate, Internal_Status__c, ContactId ' 
            + 'FROM Case WHERE Entity__r.Id != null AND Secondary_Parent_Case__r.Id != null AND RecordTypeId = \''+ epicVerfRecordTypeId +'\'' 
			+ ' AND Secondary_Parent_Case__r.RecordTypeId = \''+ credVerfRecordTypeId +'\''
            + ' AND Internal_Status__c != \''+ Constants.CASE_STATUS_CV_ACCEPTED +'\''
			+ ' AND Entity__r.Epic_Notifications__c = true AND CreatedDate = YESTERDAY';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Case> scope){
        List<Messaging.SingleEmailMessage> mailToList = new List<Messaging.SingleEmailMessage>();
        List<OrgWideEmailAddress> addr = [SELECT Id FROM OrgWideEmailAddress WHERE displayname =: Constants.ORG_WIDE_ADDRESS];
        Set<Id> entityCaseSet = new Set<Id>();
        for(Case cs : scope){
            entityCaseSet.add(cs.Entity__r.Id);
        }
        List<CONTACT2ACCTSERVICE__c> cont2AccServListAll = [SELECT Id, Account_Service__c, Account_Service__r.Account__c, 
                                 Account_Service__r.Service__r.Name, Service__c, Active__c, Account_Service__r.Active__c,
                                 Service_Contact__c, Service_Contact__r.Email, Service_Contact__r.Active_Entity_Portal_User__c 
                                 FROM CONTACT2ACCTSERVICE__c 
                                 WHERE Account_Service__r.Account__c IN: entityCaseSet
                                 AND Account_Service__r.Service__r.Name =: Constants.EPIC_SERVICENAME
                                 AND Account_Service__r.Active__c = TRUE
                                 AND Active__c = TRUE
                                 AND Service_Contact__c != NULL];
        Map<Id,List<String>> emailEntityList = new Map<Id,List<String>>();
        Set<String> toEmails = new Set<String>();
        for(CONTACT2ACCTSERVICE__c c2a : cont2AccServListAll){
            toEmails.add(c2a.Service_Contact__r.Email);
        }
        Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
        String[] toAddresses1 = new String[]{};
        for(String toEml : toEmails){
            toAddresses1.add(toEml);
        }
        mail1.setToAddresses(toAddresses1);
        mail1.setSubject('Epic Notifications');
        mail1.setHtmlBody('Please check your portal for EPIC Notifications.');
        mail1.setOrgWideEmailAddressId(addr[0].Id);
        mailToList.add(mail1); 
        if(mailToList.size() > 0 && !toAddresses1.isEmpty()){
        	try{
            	Messaging.sendEmail(mailToList);
            }
            catch(exception e){
            }
        }
    }
    public void finish(Database.BatchableContext bc){
    }
}