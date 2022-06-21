// Helper class for EntityManageAccountServiceForm
public with sharing class EntityManageAccountServiceController{
    @AuraEnabled(cacheable = true)
    public static List<Account2Service__c> getServicesOfEntity(string accId){
        List<Account2Service__c> ac2servRec = new List<Account2Service__c>();
        ac2servRec = [Select Id,Service__r.Name,Service__r.Id,Name,Service_Name__c,Account__c,Service__c,isActiveEntity__c,List_of_emails__c,Mode_of_communication__c,Physical_Address__c
                        from Account2Service__c where Account__c=:accId And isActiveEntity__c=:TRUE WITH SECURITY_ENFORCED];
        return ac2servRec;
    }
    @AuraEnabled
    public static Boolean deleteActiveAccount(String accToSerId){
        List<Account2Service__c> ac2servRec = new List<Account2Service__c>();
        ac2servRec = [Select Id,Name,Service_Name__c,Account__c,Service__c,isActiveEntity__c,List_of_emails__c,Mode_of_communication__c,Physical_Address__c
                        from Account2Service__c where Id = :accToSerId WITH SECURITY_ENFORCED];
        Boolean retVal = false;
        if(!ac2servRec.isEmpty()){
            Account2Service__c upAcc = new Account2Service__c(Id = ac2servRec[0].Id);
            upAcc.isActiveEntity__c = False;
            if(Schema.sObjectType.Account2Service__c.isUpdateable()){
                update upAcc;
                retVal = True;
            }
        }       
        return retVal;
    }
    @AuraEnabled
    public static Boolean createAccountService(String acc,String emailList,String physicalAddress,String serviceVal,String selectedMode){
        Account2Service__c ac2servRec = new Account2Service__c();
        Boolean retVal = false;
        List<Account2Service__c> ac2servRecList = new List<Account2Service__c>();
        ac2servRecList = [Select Id,Name,Service_Name__c,Account__c,Service__c,isActiveEntity__c,List_of_emails__c,Mode_of_communication__c,Physical_Address__c
                        from Account2Service__c where Account__c = :acc And Service__c=:serviceVal WITH SECURITY_ENFORCED];        
        if(!ac2servRecList.isEmpty()){
            ac2servRec.Id = ac2servRecList[0].Id;                
            ac2servRec.Account__c = acc;
            ac2servRec.Service__c = serviceVal;
            ac2servRec.Mode_of_communication__c = selectedMode;
            ac2servRec.List_of_emails__c = emailList;
            ac2servRec.Physical_Address__c = physicalAddress;
            ac2servRec.isActiveEntity__c = TRUE;
            if(Schema.sObjectType.Account2Service__c.isUpdateable()){
                update ac2servRec;
                retVal = True;
            }
        }else{                
            ac2servRec.Account__c = acc;
            ac2servRec.Service__c = serviceVal;
            ac2servRec.Mode_of_communication__c = selectedMode;
            ac2servRec.List_of_emails__c = emailList;
            ac2servRec.Physical_Address__c = physicalAddress;
            ac2servRec.isActiveEntity__c = TRUE;
            if(Schema.sObjectType.Account2Service__c.isCreateable()){
                insert ac2servRec;
                retVal = True;
            }
        }                
        return retVal;    
    }
    @AuraEnabled
    public static Boolean updateAccountService(String accToSerId,String acc,String emailList,String physicalAddress,String serviceVal,String selectedMode){
        Account2Service__c ac2servRec = new Account2Service__c();
        Boolean retVal = false;
        List<Account2Service__c> ac2servRecList = new List<Account2Service__c>();
        ac2servRecList = [Select Id,Name,Service_Name__c,Account__c,Service__c,isActiveEntity__c,List_of_emails__c,Mode_of_communication__c,Physical_Address__c
                        from Account2Service__c where Id = :accToSerId WITH SECURITY_ENFORCED];        
        if(!ac2servRecList.isEmpty()){
            ac2servRec.Id = ac2servRecList[0].Id;                
            ac2servRec.Account__c = acc;
            ac2servRec.Service__c = serviceVal;
            ac2servRec.Mode_of_communication__c = selectedMode;
            ac2servRec.List_of_emails__c = emailList;
            ac2servRec.Physical_Address__c = physicalAddress;       
            ac2servRec.isActiveEntity__c = TRUE;
            if(Schema.sObjectType.Account2Service__c.isUpdateable()){           
                update ac2servRec;
                retVal = True;
            }
        }
        return retVal;
    }
}