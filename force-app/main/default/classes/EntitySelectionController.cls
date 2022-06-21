// Helper class for EntitySelection Form
public with sharing class EntitySelectionController{
    // Purpose : Method to fetch Primary Entity in the Entity contact
    @AuraEnabled(Cacheable = true)
    public static List<EntityContactServiceHelper.EntityConWrapper> getEntity(){
        String conId = AppForCertHelper.retrieveCurrentContactId();
        List<Contact> contactList = new List<Contact>();
        contactList = [SELECT Id,AccountId,Account.Name,Name FROM Contact WHERE Id = :conId WITH SECURITY_ENFORCED];
        List<EntityContactServiceHelper.EntityConWrapper> evWrapList = new List<EntityContactServiceHelper.EntityConWrapper>();
        if(!contactList.isEmpty()){
            List<EntityContactServiceHelper.EntityOptionsWrapper> entityOptionList = new List<EntityContactServiceHelper.EntityOptionsWrapper>();
            Map<String, EntityContactServiceHelper.EntityOptionsWrapper> entityOptionUniqueVal = new Map<String, EntityContactServiceHelper.EntityOptionsWrapper>();
            for(CONTACT2ACCTSERVICE__c con2AccSer:[SELECT Id,Name,Service_Contact__c,Service_Contact__r.Name,Account_Service__c,Account_Service__r.Account__c,Account_Service__r.Account__r.Name,Account_Service__r.Service_Name__c,Role__c,Account_Service__r.Service__c,Active__c FROM CONTACT2ACCTSERVICE__c WHERE Service_Contact__c = :conId AND Active__c = :TRUE AND Account_Service__r.Account__c != null WITH SECURITY_ENFORCED ORDER BY CreatedDate ASC]){
                EntityContactServiceHelper.EntityOptionsWrapper entityOptionWrap = new EntityContactServiceHelper.EntityOptionsWrapper(con2AccSer.Account_Service__r.Account__c, con2AccSer.Account_Service__r.Account__r.Name);
                entityOptionUniqueVal.put(con2AccSer.Account_Service__r.Account__c, entityOptionWrap);
            }
            entityOptionList.addAll(entityOptionUniqueVal.values());
            EntityContactServiceHelper.EntityConWrapper evWrap = new EntityContactServiceHelper.EntityConWrapper(contactList[0].Id, contactList[0].Name, entityOptionList);
            evWrapList.add(evWrap);
        }
        return evWrapList;
    }
    /**
     * Created by Balashankar     
     * Method Name: getServices
     * Purpose : Method to fetch services for selected Account
     */
    @AuraEnabled(Cacheable = true)
    public static Boolean getServices(String accId) {

    String conId = AppForCertHelper.retrieveCurrentContactId();
    Boolean entSerCoordinatorCheck = False;               
    if(accId != ''){
        List<CONTACT2ACCTSERVICE__c> con2AccSer = new List<CONTACT2ACCTSERVICE__c>();
         con2AccSer = [Select Id,Name,Service_Contact__c,Service_Contact__r.Name,Account_Service__c,Account_Service__r.Account__c,
            Account_Service__r.Account__r.Name,Account_Service__r.Service_Name__c,Role__c,Account_Service__r.Service__c,
            Active__c from CONTACT2ACCTSERVICE__c where Service_Contact__c =:conId 
            And Account_Service__r.Account__c =:accId And Active__c =: TRUE And Role__c ='Coordinator'];
            if(!con2AccSer.isEmpty()){
                entSerCoordinatorCheck = True;
            } 
    }

        return entSerCoordinatorCheck;
    }
    //Method to check whether the selected entity is a volume recipient in the entity portal
    @AuraEnabled(Cacheable = true)
    public static boolean checkEntityIsVolumeReportRecpnt(String accId){
        String conId = AppForCertHelper.retrieveCurrentContactId();
        try{
            List<CONTACT2ACCTSERVICE__c > cont2AccServRcd = [SELECT Id,Name,Service_Contact__c,Active__c, Service__c FROM CONTACT2ACCTSERVICE__c WHERE Service_Contact__c = :conId AND Active__c = TRUE AND Account_Service__r.Account__c = :accId AND Service__c = :Constants.EPIC_SERVICENAME WITH SECURITY_ENFORCED];
            if(cont2AccServRcd.size()>0){
                return true;
            }else{
                return false;
            } 
        }catch(System.QueryException e){
            System.debug(LoggingLevel.ERROR,e.getMessage());
            return false;
        }
    }       
    @AuraEnabled(Cacheable = true)
    public static boolean checkEntityIsERAS(String accId){
        String conId = AppForCertHelper.retrieveCurrentContactId();
        try{
            List<CONTACT2ACCTSERVICE__c > cont2AccServRcd = [SELECT Id,Name,Service_Contact__c,Active__c, Service__c FROM CONTACT2ACCTSERVICE__c WHERE Service_Contact__c = :conId AND Active__c = TRUE AND Account_Service__r.Account__c = :accId AND Service__c = 'ERAS' WITH SECURITY_ENFORCED];
            if(!cont2AccServRcd.isEmpty()){
                return true;
            }else{
                return false;
            }
        }catch(System.QueryException e){
            return false;
        }
    }
}