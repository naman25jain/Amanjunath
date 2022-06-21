global with sharing  class EPICVerReportBatch implements Database.Batchable<sObject>{
    public static final Integer MAX_BATCH_SIZE = 200;
    global Database.QueryLocator start(Database.BatchableContext bc){
        String vrStatus = Constants.CASE_STATUS_PENDING_SUBMISSION;
        Id recTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_VER_REPORT_REQUEST).getRecordTypeId();                 
        String query = 'select Id from Case where Internal_Status__c =:vrStatus and RecordTypeId =:recTypeId and CreatedDate >= LAST_N_DAYS:60';        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Case> scope){
        List<Case> csToUPD = new List<Case>();
        for(Case cs:scope){
            Case c = new Case(Id = cs.Id);
            c.Internal_Status__c = Constants.CASE_STATUS_EXPIRED;
            c.External_Status__c = Constants.CASE_STATUS_EXPIRED;
            csToUPD.add(c);
        }
        if(!csToUPD.isEmpty()){
            UPDATE csToUPD;
        }
    }
    global void finish(Database.BatchableContext info){}    
}