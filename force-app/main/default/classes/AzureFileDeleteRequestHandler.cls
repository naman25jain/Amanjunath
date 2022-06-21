public with sharing class AzureFileDeleteRequestHandler {

    static final string ENTITY = 'AzureDelete'; 
    static final string SUBENTITY = 'BlockBlob'; 
    static final string PLATEFORM_EVENT_OPERATION_DELETE  = 'DELETE'; 
    static final String LOG_SOURCE = 'Azure Batch file Delete'; 
    
    
    public static  AzureAssetDeleteRequestBatch buildAssetList (List<Asset> assetLists, string batchId ){        
        AzureAssetDeleteRequestBatch reqBatch = new AzureAssetDeleteRequestBatch(); 
        AzureAssetDeleteRequestBatch.Cls_payload batchPayload = new  AzureAssetDeleteRequestBatch.Cls_payload(); 
        List<String> listOfDocIds = new List<String>(); 
        string docId; 
        Cloud_Storage_Config__c cloudStorageCofig = Cloud_Storage_Config__c.getOrgDefaults();
        
        reqBatch.entity = ENTITY; 
        reqBatch.subEntity = SUBENTITY; 
        reqBatch.transactionId = batchId; 
        reqBatch.operation = PLATEFORM_EVENT_OPERATION_DELETE;               
        batchPayload.containerName = cloudStorageCofig.Container_Name__c;       

        for(Asset assetList :assetLists){
            docId = assetList.Azure_Storage_URL__c.subStringAfterLast('/');                    
            listOfDocIds.add(docId);                 
        }  

        batchPayload.document = listOfDocIds;        
        reqBatch.payload = batchPayload;        
        return reqBatch; 
    }

    public static boolean updateAssets(List<Asset> assets){
        Database.SaveResult[] savelist = Database.update(assets,false); 
        for (Database.SaveResult sl :saveList){
            if (!sl.isSuccess()){
                for(Database.Error err: sl.getErrors()){
                    CommonUtils.logMessage(new Log_Message__c(Exception__c = err.getMessage(), 
                    Source__c = LOG_SOURCE,
                    Date_Time_Logged__c = DateTime.now(),
                    Record_Id__c = sl.getId()));  
                }
                return false; 
            }
        }
        return true; 
    }
}