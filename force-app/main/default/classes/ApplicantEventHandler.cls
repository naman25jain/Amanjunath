// Handler class for Applicant Batch Event when the Platform event is created then log to the Batch Error Log Custom Object
public class ApplicantEventHandler{    
    //After insert Methods
    public void onAfterInsert(List<Applicant_Batch_Event__e> newList, Map<Id,Applicant_Batch_Event__e> newMap){
        createPlatformEventLogsForProject(newList);
    }
    //This method creates a log record for Platform Events created during Applicant Event Insert
    public void createPlatformEventLogsForProject(List<Applicant_Batch_Event__e> EventList){
        List<Batch_Error_Log__c> platformEventLogs = new List<Batch_Error_Log__c>();       
        for (Applicant_Batch_Event__e event : EventList){  
           Batch_Error_Log__c newEvent = new Batch_Error_Log__c();
           newEvent.Batch_Request_Log__c = event.Batch_Request_log_Id__c;
           newEvent.Request_Id__c = event.Request_Id__c;
           newEvent.Sender__c = event.Client_Name__c;
           newEvent.Error_Code__c = event.Error_Code__c;  
           newEvent.Error_Description__c = event.Error_Description__c;
           platformEventLogs.add(newEvent);
        }
        try{
          insert platformEventLogs;
        }
        catch(Exception e){
          saveLogMessage(e.getMessage());
        }
    }
    // To avoiding cognitive complexity issues  - calling as seperate method
    public static void saveLogMessage(String getMessage){
      if(Schema.sObjectType.Log_Message__c.isCreateable()){
          Log_Message__c logMsg = new Log_Message__c();
          logMsg.Source__c = 'ApplicantEventHandler';
          logMsg.Exception__c	= 'Unhandled Exception while the Platform event is created:'+getMessage;
          logMsg.Date_Time_Logged__c = DateTime.now();
          INSERT logMsg;
      }
    } 
}