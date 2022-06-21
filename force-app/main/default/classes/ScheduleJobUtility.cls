public with sharing class ScheduleJobUtility {
    public static Schedule_Job_Configuration__mdt getScheduleJobParameters(string apiName){
        Schedule_Job_Configuration__mdt schMdt = [SELECT Is_Active__c, Run_After_No_Of_Days__c
                                                    FROM Schedule_Job_Configuration__mdt
                                                    WHERE 	Job_API_Name__c =: apiName 
                                                    WITH SECURITY_ENFORCED
                                                    LIMIT 1]; 
        return schMdt;

    }    
}