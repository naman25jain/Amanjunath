public with sharing class LogUtil {
    
    public static Boolean logMessage(String source, String message, List<Id> sIds){
        if(String.isNotBlank(message)){
            Log_Message__c logMsg = new Log_Message__c();
            logMsg.Exception__c	= message;
            logMsg.Record_Id__c = String.valueOf(sIds);
            logMsg.Source__c = source;
            logMsg.Date_Time_Logged__c = DateTime.now();            
            if(Log_Message__c.SObjectType.getDescribe().isCreateable()) {
                insert logMsg;
            }
            return true;
        }
        return false;
    } 
}