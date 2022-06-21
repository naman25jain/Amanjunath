/**
    * @author: Reshma Ravi
    * @name: ExamRegistrationTrigger
    * @description: User story 3965 EV29: Scenarios for taking a child case(Exam Reg/EPEx) off the enrollment verification case.
    * @createdDate: 27-Apr-2020
**/
trigger ExamRegistrationTrigger on Exam_Registration__c (after insert, after update){
    Disable_Processes_for_Data_Migration__c dProcessSettings = Disable_Processes_for_Data_Migration__c.getInstance(UserInfo.getProfileId());
    if(Null != dProcessSettings){
        //check disable triggers
        boolean disableTriggers = dProcessSettings.Disable_Triggers__c; 
        if(disableTriggers == false){
            if(trigger.isAfter && trigger.isUpdate){
                ExamRegistrationTriggerHepler.sendWithheldNotification(Trigger.new,Trigger.oldMap);
                ExamRegistrationTriggerHepler.createScoreReportCase(Trigger.new,Trigger.oldMap);
                ExamRegistrationTriggerHepler.updateScoreReportCase(Trigger.new,Trigger.oldMap);
                ExamRegistrationTriggerHepler.caseCompletion(Trigger.new,Trigger.oldMap);
                ExamRegistrationTriggerHepler.updateDegreeSchool(Trigger.oldMap, Trigger.new);
            }
            ExamRegistrationTriggerHepler.updateCaseRecs(Trigger.new, Trigger.oldMap, trigger.isInsert, trigger.isUpdate);
        }
    }
}