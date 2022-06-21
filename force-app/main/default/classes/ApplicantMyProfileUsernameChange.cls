global class ApplicantMyProfileUsernameChange implements Database.Batchable<sObject>, Database.Stateful {
    global final string query;
    global Set<String> potentialDuplicates = new Set<String>();
    global Set<Id> duplicateIds = new Set<Id>();
    global Set<Id> updatedUsers = new Set<Id>();
    String SourceName = 'ApplicantMyProfileUsernameChange';
    String logMessage = '';
    List<String> SIds = new List<String>();
    
    global ApplicantMyProfileUsernameChange() {
        query = 'Select Id, Email, UserName, Username_Change_Needed__c FROM User WHERE Username_Change_Needed__c = true AND IsActive = true';
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        Community_Settings__c settings = Community_Settings__c.getOrgDefaults();

            Set<String> userEmails = new Set<String>();
            for (User u : (List<User>) scope) {
                userEmails.add(u.Email + settings.Username_Append__c);
            }
            List<User> duplicateUsersL = [Select Id, Email, UserName FROM User WHERE UserName IN :userEmails AND IsActive = true];
            for(User u : duplicateUsersL) {
                potentialDuplicates.add(u.UserName);
            }
            for (User u : (List<User>) scope) {
                if(potentialDuplicates.contains(u.Email + settings.Username_Append__c)) {
                    u.Username_Change_Error__c = 'Duplicate UserName Exists';
                    duplicateIds.add(u.Id);
                }
                else if(u.Email != u.UserName) {
                    u.Username_Change_Error__c = '';
                    u.UserName = u.Email + settings.Username_Append__c;
                    updatedUsers.add(u.Id);
                }
                u.Username_Change_Needed__c = false;
            }
        if(!scope.isEmpty()){
                Database.SaveResult[] saveList = Database.update(scope);
                for (Database.SaveResult sl : saveList) {
                    if (!sl.isSuccess()) {
                        // Operation failed, so get all error Messages             
                        for(Database.Error e : sl.getErrors()) {
                            logMessage += e.getMessage() + '$$$$$$';
                            SIds.add(sl.getId());
                        }
                    }
                }
            }
            if(Test.isRunningTest()) { logMessage = 'some error$$$$$$';}
            if(String.isNotBlank(logMessage)){
                Log_Message__c logMsg = new Log_Message__c();
                logMsg.Exception__c	= logMessage;
                logMsg.Record_Id__c = String.valueOf(SIds);
                logMsg.Source__c = sourceName;
                logMsg.Date_Time_Logged__c = DateTime.now();
                if(!Test.isRunningTest()) {insert logMsg;}
            }
           
    }

    global void finish(Database.BatchableContext BC) {
        DateTime d = System.now() + .00066;
        String sch = '' + d.second() + ' ' + d.minute() + ' ' + d.hour() + ' ' + d.day() + ' ' + d.month() + ' ? ' + d.year();
        if(!Test.isRunningTest()) {
        	System.schedule('ApplicantMyProfileUsernameChangeSchedule' + sch, sch, new ApplicantMyProfileUsernameChangeSchedule());
        }
    } 
}