public with sharing class AzureFilesDeleteResponseHandler {
    static final integer SUCCESS = 200;
    static final string LOG_SOURCE = 'Azure Batch file Delete'; 
    static string batchId; 
    static final string  FILE_STATUS_DELETED ='Deleted';  

    public static void handleResponseEventPayload(string payload) {
        AzureFilesDeleteResponse res = new AzureFilesDeleteResponse();            
        try {
            res =  (AzureFilesDeleteResponse)System.JSON.deserialize(payload, AzureFilesDeleteResponse.class);  
            batchId = res.correlationId;
            
            CommonUtils.logMessage(new Log_Message__c(Exception__c = 'Azure delete response payload' +JSON.serialize(payload),
            Source__c = LOG_SOURCE,
            Date_Time_Logged__c = DateTime.now(),
            Record_Id__c = batchId));

            CommonUtils.logMessage(new Log_Message__c(Exception__c = 'Azure delete response payload as object' +res,
                                    Source__c = LOG_SOURCE,
                                    Date_Time_Logged__c = DateTime.now(),
                                    Record_Id__c = batchId));                                    
                                             
            handleEvent(res);                
            
        } catch (Exception e) {
            CommonUtils.logMessage(new Log_Message__c(Exception__c = 'Azure delete batch id ' +batchId+ 'Failed with error' + e,
                                                        Source__c = LOG_SOURCE,
                                                        Date_Time_Logged__c = DateTime.now(),
                                                        Record_Id__c = batchId));              
        }
    }

    @TestVisible
    private static void handleEvent(AzureFilesDeleteResponse response){
        try {
            string tempFileName; 

            List<AzureFilesDeleteResponse.Cls_transactionDetails> tds = response.transactionDetails;

            List<Asset> toBeDeleteAssestList = new List<Asset>();  
            if (response.transactionStatus == Constants.API_TRANSACTION_STATUS_PARTIAL_SUCCESS){
                toBeDeleteAssestList = handleParticalSuccess(tds, response.correlationId); 
                if (toBeDeleteAssestList.size() >0 ){                     
                    deleteAsset(toBeDeleteAssestList,response.transactionStatus ); 
                }                
            }
            else if (response.transactionStatus == Constants.API_TRANSACTION_STATUS_SUCCESS){
                List<Asset> listAssets = getAssetIdbycoorelationid(response.correlationId);
                for (Asset listAsset: listAssets){
                    toBeDeleteAssestList.add(listAsset); 
                }
                deleteAsset(toBeDeleteAssestList,response.transactionStatus ); 
            }
            else if (response.transactionStatus == Constants.API_TRANSACTION_STATUS_FAILURE){
                CommonUtils.logMessage(new Log_Message__c(Exception__c = 'Asset deleted - Failure :'+ response,
                                        Source__c = LOG_SOURCE,
                                        Date_Time_Logged__c = DateTime.now(),
                                        Record_Id__c = batchId)); 

            }

        } catch (Exception e) {
            CommonUtils.logMessage(new Log_Message__c(Exception__c = 'Unable to get response '+e,
                                    Source__c = LOG_SOURCE,
                                    Date_Time_Logged__c = DateTime.now())); 
            
        }
    }

    @TestVisible
    private static void deleteAsset(List<Asset> deleteAssets, string transactionStatus){
        if (deleteAssets.size() > 0 && Asset.SObjectType.getDescribe().isDeletable()){ 
            deleteAffirmation(deleteAssets);          
            delete deleteAssets;                    
        }
    }

    @TestVisible
    private static void deleteAffirmation(List<Asset> assetList ){
        if (assetList.size() >0 ) {
            if (Affirmation__c.SObjectType.getDescribe().isQueryable() && Affirmation__c.SObjectType.getDescribe().isDeletable() ){
                List<Affirmation__c> tobeDeltedAffiramtions = [SELECT Id FROM Affirmation__c where asset__c IN :assetList]; 
                if(tobeDeltedAffiramtions.size() > 0 && Affirmation__c.SObjectType.getDescribe().isDeletable() ){
                    delete tobeDeltedAffiramtions; 
                }
            }
        }
    }

    @TestVisible
    private static List<asset> getAssetIdbycoorelationid(string coorelationid){
        string tempFileName;       
        List<Asset> aList = ([SELECT Id, Name, Azure_Delete_Batch_Id__c, Azure_Storage_URL__c
                             FROM Asset 
                             WHERE Azure_Delete_Batch_Id__c =: coorelationid
                             WITH SECURITY_ENFORCED]);        
        return aList; 
    }

    @TestVisible
    private static List<Asset> handleParticalSuccess(List<AzureFilesDeleteResponse.Cls_transactionDetails> transDetails, string corId){
        string tempFileName; 
        List<Asset>  toBeDeleteAssestList = new List<Asset>();
        for(AzureFilesDeleteResponse.Cls_transactionDetails td :  transDetails){ 
            if (td.fileStatus == FILE_STATUS_DELETED){
                List<Asset> listAssets = getAssetIdbycoorelationid(corId); 
                    for (Asset listAsset: listAssets){
                    tempFileName = listAsset.Azure_Storage_URL__c.subStringAfterLast('/'); 
                    if (tempFileName == td.fileName){
                        toBeDeleteAssestList.add(listAsset); 
                    }
                }
            }
        } 
        return   toBeDeleteAssestList;           
    }
            
}