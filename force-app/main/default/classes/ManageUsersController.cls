public with sharing class ManageUsersController{
    static String hideClass = 'slds-hide';
    static String showClass = 'scaled-down';
    @AuraEnabled(cacheable = true)
    public static String revealButton(String currentEntityId){
        Id currentUser = AppForCertHelper.retrieveCurrentContactId();
        String loggedInAccountId = currentEntityId;
        List<CONTACT2ACCTSERVICE__c> fetchRole = new List<CONTACT2ACCTSERVICE__c>([Select Id, Role__c from CONTACT2ACCTSERVICE__c where Account_Service__r.Account__c =: loggedInAccountId AND Service_Contact__c =: currentUser AND Active__c = TRUE]);    
        List<String> roles = new List<String>();
        for(Integer i=0; i < fetchRole.size(); i++){
            roles.add(fetchRole[i].Role__c);
        }
        String returnVal;
        if(roles.contains('Coordinator')){
            returnVal = 'Coordinator';
        }
        else if(roles.contains('User')){
            returnVal = 'User';
        }
        return returnVal;
    }
    @AuraEnabled(cacheable = true)
    public static List<contact2AccServiceWrapper> getRecs(String currentEntityId){
        Id currentUser = AppForCertHelper.retrieveCurrentContactId();
        String loggedInAccountId = currentEntityId;
        List<CONTACT2ACCTSERVICE__c> fetchRole = new List<CONTACT2ACCTSERVICE__c>([Select Id, Role__c, Account_Service__r.Service__c from CONTACT2ACCTSERVICE__c where Account_Service__r.Account__c =: loggedInAccountId AND Service_Contact__c =: currentUser AND Active__c = TRUE]);    
        List<contact2AccServiceWrapper> returnList = new List<contact2AccServiceWrapper>();
        Set<Id> contactSet = new Set<Id>();
        contactSet.add(currentUser);
        Set<contact2AccServiceWrapper> mySet = new Set<contact2AccServiceWrapper>();
        for(CONTACT2ACCTSERVICE__c loopVar : [Select Id, Service_Contact__r.Name, Account_Service__r.Account__c, Account_Service__r.Service__c, Service_Contact__r.Title, Service__c, Role__c from CONTACT2ACCTSERVICE__c where Account_Service__r.Account__c =: loggedInAccountId AND Active__c = TRUE AND Service_Contact__c NOT IN: contactSet AND Service_Contact__c != NULL ORDER BY Service_Contact__r.Name ASC]){
            contact2AccServiceWrapper loopVar1 = new contact2AccServiceWrapper();
            loopVar1.userName = loopVar.Service_Contact__r.Name;
            loopVar1.role = loopVar.Role__c;
            loopVar1.jobTitle = loopVar.Service_Contact__r.Title;
            loopVar1.serviceName = loopVar.Service__c;
            loopVar1.idVal = loopVar.Id;
            loopVar1.isVisible = true;
            loopVar1.className = hideClass;
            for(integer count = 0; count < fetchRole.size(); count++){
                switch on fetchRole[count].Role__c{
                    when 'User'{    
                        loopVar1.isVisible = true;
                        loopVar1.className = hideClass;
                    }
                    when 'Coordinator'{
                        Boolean checkVariable = checkValues(loopVar.Role__c, loopVar.Account_Service__r.Service__c, fetchRole[count].Account_Service__r.Service__c);
                        if(checkVariable){
                            loopVar1.isVisible = false;
                            loopVar1.className = showClass;
                            break;
                        }
                    }
                    when else{
                        loopVar1.isVisible = false;
                        loopVar1.className = showClass;
                        break;
                    }
                }
            }
            mySet.add(loopVar1);    
        }    
        returnList.addAll(mySet);
        return returnList;
    }
    @AuraEnabled
    public static boolean deactivateUser(String contact2AddId){
        CONTACT2ACCTSERVICE__c selectedRec = [Select Id, Active__c from CONTACT2ACCTSERVICE__c where Id =: contact2AddId];
        selectedRec.Active__c = false;
        update selectedRec;
        return true;
    }   
    @AuraEnabled
    public static boolean checkValues(String role, String service1, String service2){
        if(role=='User' && service1 == service2){
            return TRUE;
        }
        else{
            return FALSE;
        }
    }
}