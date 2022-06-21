public with sharing class LightningSearchController{
    @AuraEnabled(Cacheable = true)
    public static List<Account> getSchoolRecords(String recType, String inputText){
        try{  
            String searchStr = '%' + inputText + '%';
            List<Account> schoolRecords = [SELECT Id, Name,School__c,Certification_Agency__c,
                                           Accrediting_QA_Agency__c,Government_Agency__c,
                                           Health_Profession_Regulatory_Authority__c,
                                           BillingStreet, BillingCity, BillingState, BillingPostalCode, 
                                           BillingCountry  FROM Account 
                                           WHERE recordType.DeveloperName =: Constants.ACCOUNT_RECORD_TYPE_DEV_ENTITY AND Name LIKE :searchStr];
            List<Account> accRecords = new List<Account>();
            if(recType == 'Regulatory Organization'){
                accRecords.addAll(entityRecords(schoolRecords));
            }else{
                for(Account acc : schoolRecords){
                    if((recType == 'Medical Authority') && (acc.Certification_Agency__c == true 
                                                            || acc.Accrediting_QA_Agency__c == true 
                                                            || acc.Government_Agency__c == true 
                                                            || acc.Health_Profession_Regulatory_Authority__c == true)){                          
                                                                accRecords.add(acc);
                                                            }else if(recType == 'Medical School' && acc.School__c == true){
                                                                accRecords.add(acc);
                                                            }
                }
            }        
            return accRecords;
        }
        catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }
    // Returns only Volume Report Recipients Account.
    public static List<Account> entityRecords(List<Account> schoolRecords){
        List<Account> accRecords = new List<Account>();
        Set<Id> accountIdSet = new Set<Id>();
        List<Account2Service__c> acc2SerList =  new List<Account2Service__c>([SELECT Id, Account__c FROM Account2Service__c WHERE Active__c = True AND Service__r.Name = :Constants.EPIC_SERVICENAME AND Account__c in :schoolRecords]);
        for(Account2Service__c acct: acc2SerList){
            accountIdSet.add(acct.Account__c);
        }
        if(!accountIdSet.isEmpty()){
            for(Account acc : schoolRecords){
                if(accountIdSet.contains(acc.Id)){
                    accRecords.add(acc);
                }
            }
        }
        return accRecords;
    }
}