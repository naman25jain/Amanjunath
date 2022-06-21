public with sharing  class VerReqAssetBatch implements Database.Batchable<sObject>{
    public static final Integer MAX_BATCH_SIZE = 200;
    public static final string LOG_SOURCE = 'VerReqAssetBatch';     
    public Database.QueryLocator start(Database.BatchableContext bc){
        String vrStatus = Constants.VERIFICATION_REQUEST_STATUS_PROCESSED;
        String vrfStatus = Constants.VERIFICATION_REQUEST_FILE_STATUS_PENDING;
        List<Verification_Request_File__c> vrfs = [select Verification_Request__c from Verification_Request_File__c where Status__c = :vrfStatus];
        Set<string> vrList = new Set<string>(); 
        for (Verification_Request_File__c vrf : vrfs){
            vrList.add(vrf.Verification_Request__c); 
        }

        String query  = 'SELECT Id, Last_Name__c, Rest_of_Name__c, Birth_Date__c, Birth_Country__c, Gender__c, Medschool_Code__c, ' +
                        'Sender__c, Candidate_Code__c, USMLE_ID__c, EICS_ID__c, Previous_Last_Name__c, Previous_Rest_of_Name__c, Residence_Country__c, ' +
                        'Contact_Exact_Scenario_Score__c, Account_Exact_Scenario_Score__c, Contact_Non_Exact_Scenario_Score__c, Account_Non_Exact_Scenario_Score__c, Exact_Match_Contact__c, Exact_Match_Account__c, ' +
                        'RecordTypeId '+
                        'FROM Verification_Request__c ' +
                        'WHERE Id in :vrList ';
        return Database.getQueryLocator(query);
    }
     
    public void execute(Database.BatchableContext bc, List<Verification_Request__c> scope){                      
        system.debug('Scope is '+scope); 
        Map<String, String> fileToReqMap = new Map<String, String>();
        Map<String, Set<String>> reqToFilesMap = new Map<String, Set<String>>();
        Map<String, Set<String>> verificationRequestIdToAssetIdsMap = new Map<String, Set<String>>();
        List<String> lstAssets; 
        Set<Id> vrIdsSet= new Set<Id>(); 
        List<Id> vrIdLst = new List<Id>(); 
        List<Case> lstCase = new List<Case>(); 
        List<Verification_Request_File__c> lstUpdateVrfList = new List<Verification_Request_File__c>();  

        for(Verification_Request__c vr : scope ){
            if (!string.isBlank(vr.Sender__c)){
                List<Case> lstCases = getCasebyVerificationId(vr.Id);                
                if (lstCases[0].Internal_Status__c != Constants.CASE_STATUS_DUPLICATE_CHECK){                
                List<Group> lstGroups = getGroupIdByName(Constants.CASE_QUEUE_CREDENTIAL_REVIEW);
                        VerificationRequestService.createAssetsFromVerificationRequestFiles(vr.Id); 
                }
            }
        }     
    }

    

    public static List<Group> getGroupIdByName(string queueName){        
        List<Group> groups = [select Id from Group where Type = 'Queue' and Name =: queueName];
        return groups; 
    }

    public static List<Case> getCasebyVerificationId(Id verifId ){
        List<Case> lstCase; 
        if (Case.SObjectType.getDescribe().isSearchable()){
            lstCase = [SELECT Id, Internal_Status__c FROM Case WHERE Verification_Request__c =: verifId ];
        }
        return lstCase; 
    }

    public void finish(Database.BatchableContext info){
            // Check batch status - IF COMPLETED then 
                AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email, ExtendedStatus FROM AsyncApexJob where Id = :info.getJobId()];                 

    }
}