/**
 @Name: Shaik Nagajani
 @Description: 
 - This batch class updates the USML Transcript Eligibility flags to defaults.

 @History
  VERSION     AUTHOR             DATE            DETAIL
  1.0         Shaik Nagajani     13/Sep/2021     Created the Batch class.
*/
public inherited sharing class CibisEligbilityCheckflagDisableBatch implements Database.Batchable<sObject>,Schedulable  {
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id, USMLE_Transcript_Eligibility_Msg__c, USMLE_Transcript_Eligible__c 
                                         FROM Contact 
                                         WHERE (USMLE_Transcript_Eligibility_Msg__c = '' AND USMLE_Transcript_Eligible__c = TRUE)
                                         OR (USMLE_Transcript_Eligibility_Msg__c != NULL AND USMLE_Transcript_Eligible__c = FALSE)]);
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope){
        if(scope != null && !scope.isEmpty()){
            for(Contact conIterator : (List<Contact>)scope) {
                conIterator.USMLE_Transcript_Eligibility_Msg__c = null;
                conIterator.USMLE_Transcript_Eligible__c = false;
            }
            
            update scope;
        }
        
    }
    
    public void finish(Database.BatchableContext bc){
    }
    Public void execute(SchedulableContext SC) {
        CibisEligbilityCheckflagDisableBatch sch = new CibisEligbilityCheckflagDisableBatch(); 
    }
}