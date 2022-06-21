/*
Author: Pradeep Kumar
Draft verion of Restriction Request batch 
*/
global without sharing class RestrictionRequestProcessBatch implements Database.Batchable<sObject>, Database.Stateful{

    //Default Constructor
    global RestrictionRequestProcessBatch (){

    }
    //Start
    global Database.queryLocator start (Database.BatchableContext bc){
        return Database.getQueryLocator([select ID, Name, Applicant_ID_List__c, Assigned_SI_Case_Manager__c, Entity_ID_List__c,
                                Request_Type__c,Restriction_Applied_Date__c,Restriction_End_Date__c,Restriction_Level__c,Services_Restricted__c,
                                Restriction_Reason__c,Restriction_Start_Date__c,Restriction_Type__c,RestrictionUniqueID__c
                                from Restriction_Request__c where (Restriction_Applied_Date__c = NULL OR RestrictionRollbackDate__c = NULL) 
                                         AND RestrictionStatus__c = 'Ready to Process'
                                ]);
    }
    //Execute
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        if(!scope.isEmpty()){
            Map<Id, Restriction_Request__c> restrictionReqMap = new Map<Id, Restriction_Request__c>();
            for(Restriction_Request__c rrRec : (List<Restriction_Request__c>)scope){
                restrictionReqMap.put(rrRec.Id, rrRec);
            }

            RestrictionRequestProcess.processRestrictionRequests(restrictionReqMap);
        }
    }
    //Finish
    global void finish(Database.BatchableContext bc){

    }
}