/**
 * Scheduler class for EntityPerformanceDataNotificationBatch
 *
 * @author        Enable Consulting
 * @version       1.0
 * @createdDate   04-MAY-2020
 */
public with sharing class PerformanceDataNotificationScheduler implements Schedulable{
    // Execute at regular intervals
    public void execute(SchedulableContext ctx){
        // get list of all exam reg records which have scores posted today
        List<Exam_Registration__c> examRegsPostedToday = new List<Exam_Registration__c>([SELECT Id, Applicant__c
                                                                                         FROM Exam_Registration__c
                                                                                         WHERE Posted_Date__c = TODAY ]);
        if(examRegsPostedToday.size() > 0){
            Set<Id> applicantContacts = new Set<Id>();

            // loop to get contact ids of all applicants whose scores were posted today
            for(Exam_Registration__c er : examRegsPostedToday){
                applicantContacts.add(er.Applicant__c);
            }
            // get list of all contact association types to get the corresponding Degree Medical School for above applicants
            List<Contact_Association_Type__c> relatedCats = new List<Contact_Association_Type__c>([SELECT Id, Account__c
                                                                                                FROM Contact_Association_Type__c
                                                                                                WHERE recordType.DeveloperName =: Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL AND 
                                                                                                      Contact__c IN :applicantContacts]);

            Set<Id> entitiesToBeInformed = new Set<Id>();

            // loop to get entity ids of all applicants whose scores were posted today
            for(Contact_Association_Type__c cat : relatedCats){
                entitiesToBeInformed.add(cat.Account__c);
            }
            // get all entity contacts to whom the mails are to be sent
            List<CONTACT2ACCTSERVICE__c> contact2AccService = [SELECT id, Account_Service__c, Service_Contact__c FROM CONTACT2ACCTSERVICE__c WHERE Active__c = true AND Account_Service__r.Active__c = true AND Account_Service__r.Service__r.Name =:Constants.SERVICE_NAME_PERFORMANCE_DATA AND Account_Service__r.Account__c IN:entitiesToBeInformed AND Service_Contact__c != null WITH SECURITY_ENFORCED];
            Set<Id> entityContactIds = new Set<Id>();
            // loop to get entity contact ids to whom the mails are to be sent
            for(CONTACT2ACCTSERVICE__c cont : contact2AccService){
                entityContactIds.add(cont.Service_Contact__c);
            }
            // convert ids to set of string
            Set<String> setIdSet = new Set<String>(String.join(new List<id>(entityContactIds), ',').split(','));
            String soql = 'SELECT Id, Email FROM Contact WHERE Id IN (';
            // loop to complete query string with ids obtained from above logic
            for(string s : setIdSet) {
                soql += '\'' + s + '\',';
            }
            soql = soql.removeEnd(',');
            soql += ')';
            EntityPerformanceDataNotificationBatch batch = new EntityPerformanceDataNotificationBatch(soql);
            Database.executebatch(batch, 200);
        }
    }
}