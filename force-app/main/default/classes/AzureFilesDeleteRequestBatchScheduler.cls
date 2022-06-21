public with sharing class AzureFilesDeleteRequestBatchScheduler implements Schedulable {
    static final String LOG_SOURCE = 'Azure Batch file Delete'; 
    public void execute (SchedulableContext sc){

        string jobAPI =  Constants.SCH_JOB_AZURE_FILE_DELETE; 
        Integer noOfDaysOut; 
        Schedule_Job_Configuration__mdt mdt= ScheduleJobUtility.getScheduleJobParameters(jobAPI); 

        if (mdt !=null && mdt.Is_Active__c ){
            noOfDaysOut = Integer.valueOf(mdt.Run_After_No_Of_Days__c); 
            string assetStatus = Constants.ASSET_STATUS_MARKED_FOR_DELETION;

            string toBeDeleteSoql = 'SELECT Id '         
                                + ' FROM Asset'
                                + ' WHERE Status = \''+ assetStatus + '\''
                                + ' AND LastModifiedDate <=LAST_N_DAYS:'+ noOfDaysOut  
                                + ' AND Azure_Storage_URL__c = null'    
                                + ' WITH SECURITY_ENFORCED';
            deleteAsset(toBeDeleteSoql);   

            string soql = 'SELECT Id, Name, Azure_Storage_URL__c, Case__c, Filename__c, Azure_Delete_Batch_Id__c,'
                        + ' Name_on_Document__c, ParentId, Parent_Azure_Storage_URL__c' 
                        + ' FROM Asset'
                        + ' WHERE Status = \''+ assetStatus + '\''
                        + ' AND LastModifiedDate <=LAST_N_DAYS:'+ noOfDaysOut         
                        + ' WITH SECURITY_ENFORCED';
            AzureFilesDeleteRequestBatch batch = new AzureFilesDeleteRequestBatch(soql); 
            Database.executeBatch(batch,2);
        }
    }
    
    public static void deleteAsset(string  soqlForDeleteAsset){
        List<Asset> tobeDeletedAssets = Database.query(soqlForDeleteAsset); 
        if (tobeDeletedAssets.size() > 0 && Asset.SObjectType.getDescribe().isDeletable()){         
            CommonUtils.logMessage(new Log_Message__c(Exception__c = 'Deleting following asset'+ tobeDeletedAssets,
                                    Source__c = LOG_SOURCE,
                                    Date_Time_Logged__c = DateTime.now()
                                    ));   
            deleteAffirmation(tobeDeletedAssets);                                            
            delete tobeDeletedAssets;                    
        }
    }

    public static void deleteAffirmation(List<Asset> assetList ){
        if (assetList.size() >0 ) {
            List<Affirmation__c> tobeDeltedAffiramtions = [SELECT Id FROM Affirmation__c where asset__c IN :assetList]; 
            if(tobeDeltedAffiramtions.size() > 0 && Affirmation__c.SObjectType.getDescribe().isDeletable() ){
                delete tobeDeltedAffiramtions; 
            }
        }
    }

}