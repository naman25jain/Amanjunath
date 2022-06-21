public with sharing class DeactivateServiceController {
    @AuraEnabled
    public static String deactivateService(String ac2ServId){
        List<Account2Service__c> recDetails = new List<Account2Service__c>([Select Id, Account__c, Service__r.Name, Active__c, End_Date__c from Account2Service__c where Id =: ac2ServId]);
        if(recDetails.size() > 0){
            String servName = recDetails[0].Service__r.Name;
            List<CONTACT2ACCTSERVICE__c> recsToDeactivate = new List<CONTACT2ACCTSERVICE__c>();
            recsToDeactivate = [Select Id, Active__c from Contact2AcctService__c where Account_Service__c =: ac2ServId AND Active__c = True];
            if(recsToDeactivate.size() > 0){
                for(integer count = 0; count < recsToDeactivate.size(); count++){
                    recsToDeactivate[count].Active__c = FALSE;
                }
                update recsToDeactivate;
            }
            recDetails[0].End_Date__c = System.today();
            recDetails[0].Active__c = false;
            update recDetails[0];
            if(servName == Constants.SERVICE_NAME_CREDENTIAL_VERIFICATION || servName == Constants.SERVICE_NAME_ENROLLMENT_VERIFICATION){
                sonarDeactivatePerfService(recDetails);    
            }
        }
        return 'true';
    }

    @AuraEnabled
    public static void sonarDeactivatePerfService(List<Account2Service__c> recDetails){
        String accId = recDetails[0].Account__c;
        List<Account2Service__c> perfDataList = new List<Account2Service__c>([Select Id, Active__c, End_Date__c from Account2Service__c where Account__c =: accId AND Service__r.Name =: Constants.SERVICE_NAME_PERFORMANCE_DATA AND Active__c = TRUE]);
        if(perfDataList.size() > 0){
            List<String> perfDataId = new List<String>();
            for(integer i = 0; i< perfDataList.size(); i++){
                perfDataId.add(perfDataList[i].Id);    
            }
            List<CONTACT2ACCTSERVICE__c> deactPerfData = new List<CONTACT2ACCTSERVICE__c>([Select Id, Active__c from Contact2AcctService__c where Active__c = True AND Account_Service__c =: perfDataId]);
            if(deactPerfData.size() > 0){
                for(integer countVar = 0; countVar < deactPerfData.size(); countVar++){
                    deactPerfData[countVar].Active__c = False;
                }
                update deactPerfData;
            }
            for(integer j = 0; j < perfDataList.size(); j++){
                perfDataList[j].Active__c = False;
                perfDataList[j].End_Date__c = System.today();
            }
            update perfDataList;
        }
    }

    @AuraEnabled(cacheable = true)
    public static boolean perfDataCheck(String ac2ServId){
        boolean returnVal;
        List<Account2Service__c> recList = new List<Account2Service__c>([Select Id, Account__c, Service__r.Name from Account2Service__c where Id =: ac2ServId]);
        if(recList[0].Service__r.Name != Constants.SERVICE_NAME_PERFORMANCE_DATA && (recList[0].Service__r.Name == Constants.SERVICE_NAME_CREDENTIAL_VERIFICATION || recList[0].Service__r.Name == Constants.SERVICE_NAME_ENROLLMENT_VERIFICATION)){
            String accId = recList[0].Account__c;
            List<Account2Service__c> perfDataList = new List<Account2Service__c>([Select Id, Active__c from Account2Service__c where Account__c =: accId AND Service__r.Name =: Constants.SERVICE_NAME_PERFORMANCE_DATA AND Active__c = TRUE]);
            if(perfDataList.size() > 0){
                    returnVal = false;            
            }
            else{
                returnVal = true;
            }
        }
        else{
            returnVal = true;
        }
        return returnVal;
    }
}