public with sharing class TaskTriggerHelper{
    public static boolean firstRun = true;
    public static void afterInsertHelper(List<Task> newTasks){
        Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Task.getRecordTypeInfosById();                
        Set<Id> caseId = new Set<Id>();
        for(Task newTask : newTasks){ 
            if(newTask.RecordTypeId != null){
                string recType = rtMap.get(newTask.RecordTypeId).getName(); 
                if(recType == Constants.TASK_RECORD_TYPE_COMMENTS && newTask.whatid != null){
                    String sObjName = newTask.whatid.getSObjectType().getDescribe().getName();                   
                    handleRaiseplatformEventforWDOMS(sObjName, newTask);
                } 
                if(string.valueof(newTask.WhatId).startswith('500') && newTask.Subject.startswith('Reupload')){
                    caseId.add(newTask.WhatId);
            }   
        }
    }
        if(caseId.size() > 0){
            SendEmailOnTaskCreation.getToEmailAddress(caseId);
           }
    }
    public static void afterUpdateHelper(List<Task> newTasks, Map<Id, Task> oldTasksMap){         
        Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Task.getRecordTypeInfosById(); 
        Set<String> recipientsId= new Set<String>();
        for(Task newTask : newTasks){                                
            if(newTask.RecordTypeId != null){
                string recType = rtMap.get(newTask.RecordTypeId).getName(); 
                if(recType == Constants.TASK_RECORD_TYPE_COMMENTS && newTask.whatid != null){
                    String sObjName = newTask.whatid.getSObjectType().getDescribe().getName();                   
                    handleRaiseplatformEventforWDOMS(sObjName, newTask);
                }
            }
            if(newTask.Status == 'Restriction Release' || newTask.Status == 'Restriction Upheld'){
                Case caseOwner=[SELECT Id, OwnerId FROM case where Id=:newTask.WhatId WITH SECURITY_ENFORCED];
                recipientsId.add(caseOwner.OwnerId);
                CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='ERAS_Case_Owner_Notification'];
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                notification.setTitle('Task status has been changed to Restriction');
                if(newTask.Status == 'Restriction Release'){
                    notification.setBody('The Task status has been changed to Restriction Release');
                }
                else{
                    notification.setBody('The Task status has been changed to Restriction Upheld');
                }
                notification.setNotificationTypeId(notificationType.Id);
                notification.setTargetId(newTask.Id);
                try {
                    notification.send(recipientsId);
                }
                catch (Exception e) {
                    throw e;
                }
            }
        }
    }
    public static void handleRaiseplatformEventforWDOMS(String sObjName, Task newTask){
        String objectType; 
        String operationtype = Constants.WDOMS_PLATFORM_OPERATION_PATCH; 
        Id objectId;
        if(sObjName == Constants.SOBJECT_TYPE_ACCOUNT){
            string wdid = WDOMSService.getWDOMSIdByAccountId(newTask.whatid);                     
            if(!string.isBlank(wdid)){
                objectType = Constants.WDOMS_OBJ_SCHOOL;                            
                objectId = newTask.whatid;                
                WDOMSResponseService.raiseplatformEventforWDOMS(objectType, objectId, operationtype); 
            }
        }else if(sObjName == Constants.SOBJECT_TYPE_PROGRAM){
            objectType = Constants.WDOMS_OBJ_MDT_PROGRAM;                            
            objectId = newTask.whatid;                
            WDOMSResponseService.raiseplatformEventforWDOMS(objectType, objectId, operationtype); 
        }
    }
    public static void beforeInsert(List<Task> newtask){
        Map<Id, Task> idContactTaskMap = new Map<Id, Task>();
        for(Task taskRec : newtask){
            if(taskRec.WhoId != null)
                idContactTaskMap.put(taskRec.WhoId, taskRec);
        }
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT ECFMG_ID__c FROM Contact WHERE Id = :idContactTaskMap.keyset()]);
        
        for(Task taskRec : idContactTaskMap.values()) 
        {
            taskRec.ECFMGID__c = contactMap.get(taskRec.WhoId).ECFMG_ID__c;
        }
    }
}