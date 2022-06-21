/*
Author: Pradeep Kumar
Draft verion of Restriction Request batch 
*/
global without sharing class RestrictionProcessBatch implements Database.Batchable<sObject>, Database.Stateful{

    //Default Constructor
    global RestrictionProcessBatch (){

    }
    //Start
    global Database.queryLocator start (Database.BatchableContext bc){
        return Database.getQueryLocator([select ID, Name, Applicant__c, Assigned_SI_Case_Manager__c, Entity__c,Restriction_Status__c,
                                Restriction_Applied_Date__c,Restriction_End_Date__c,Restriction_Level__c,ServiceRestricted__c,
                                Restriction_Reason__c,Restriction_Start_Date__c,Restriction_Type__c,RestrictionUniqueID__c
                                from Restriction__c where Restriction_End_Date__c <= TODAY  AND Restriction_End_Date__c != NULL
                                ]);
    }
    //Execute
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        
        if(!scope.isEmpty()){
            RestrictionRequestProcess.processRestrictionRecords((List<Restriction__c>)scope);
        }
    }
    //Finish
    global void finish(Database.BatchableContext bc){

    }
}