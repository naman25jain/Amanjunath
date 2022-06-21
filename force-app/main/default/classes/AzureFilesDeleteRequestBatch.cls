public with sharing class AzureFilesDeleteRequestBatch  implements Database.Batchable<sObject>, Database.Stateful{
    public Integer recordsProcessed = 0;
    static final String FILE_DELETE_BATCH_ID_MSG = 'Azure File Delete Batch Id ';
    static final String LOG_SOURCE = 'Azure Batch file Delete'; 
    public Integer batchSeq = 0;
    private String query;
    private String soql;

    public AzureFilesDeleteRequestBatch(String soql) {
        query = soql;
    }

    public Database.Querylocator start(Database.BatchableContext bc){
        return Database.getQuerylocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Asset> assetLists){

        String batchId =  bc.getJobId();
        batchId =  batchId + '.' + batchSeq;
        batchSeq += 1;
        for(Asset a: assetLists){
            a.Azure_Delete_Batch_Id__c = batchId;  //update asset with batch id 
        }
        AzureAssetDeleteRequestBatch batchPrepforPE =   AzureFileDeleteRequestHandler.buildAssetList(assetLists, batchId);         
        CommonUtils.logMessage(new Log_Message__c(Exception__c = 'JSON for Asset Delete'+JSON.serialize(batchPrepforPE),
                                Source__c = LOG_SOURCE,
                                Date_Time_Logged__c = DateTime.now(),
                                Record_Id__c = batchId));   
        string jsonPayload =  JSON.serialize(batchPrepforPE);                            
        try {
            Azure_Files_Delete_Request_Event__e reqEvent = new Azure_Files_Delete_Request_Event__e(payload__c = jsonPayload); 
            Database.SaveResult sr = EventBusWrapper.publish(reqEvent);
            if (sr.isSuccess()){                
                AzureFileDeleteRequestHandler.updateAssets(assetLists); 
                CommonUtils.logMessage(new Log_Message__c(Exception__c = 'Publish successfully'+JSON.serialize(reqEvent), 
                                        Source__c = LOG_SOURCE,
                                        Date_Time_Logged__c = DateTime.now(),
                                        Record_Id__c = batchId));  

            }
        } catch (Exception e) {
            CommonUtils.logMessage(new Log_Message__c(Exception__c = e.getMessage(), 
                                    Source__c = LOG_SOURCE,
                                    Date_Time_Logged__c = DateTime.now(),
                                    Record_Id__c = batchId));             
        }
    }

    public void finish(Database.BatchableContext bc){        
    }
}