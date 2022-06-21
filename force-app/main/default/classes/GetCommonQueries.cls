// This class will query common static org wide data
public with sharing class GetCommonQueries{
    // private static variable referencing the class
    private static GetCommonQueries instance = null;
    // private static variable referencing the CommonQueriesDataWrapper class
    private static CommonQueriesDataWrapper cqDataWrap = null;
    public static GetCommonQueries getInstance(){
        try{
            if(instance == null){
                instance = new GetCommonQueries();
                cqDataWrap = new CommonQueriesDataWrapper();
                getNetwork(cqDataWrap);
                getOrgEmailAddress(cqDataWrap);
                getEmailTemplate(cqDataWrap);
                getStaticResource(cqDataWrap);
            }
            return instance;
        }catch(Exception ex){
            throw ex;
        }
    }
    // Method queries Network details
    static void getNetwork(CommonQueriesDataWrapper cqDataWrap){
        // Stores name and network
        Map<String,Network> networkMap = new Map<String,Network>();
        for(Network myNetwork : [SELECT Id,Name FROM Network WHERE Name =: Constant_other__mdt.getInstance('COMMUNITY_NAME_APP_360').Value__c]){
            networkMap.put(myNetwork.Name,myNetwork);
        }
        if(!networkMap.isEmpty()){
            cqDataWrap.genericData.put(Constant_Data_Key__mdt.getInstance('NETWORK').Value__c,networkMap);
        }
    }
    // Method queries org wide email address 
    static void getOrgEmailAddress(CommonQueriesDataWrapper cqDataWrap){
        // Stores name and org wide email address
        Map<String,OrgWideEmailAddress> orgWideEmailAdd = new Map<String,OrgWideEmailAddress>();
        for(OrgWideEmailAddress orgWideEmailAddRec: [SELECT Id,displayName FROM OrgWideEmailAddress WHERE displayname =: Constants.ORG_WIDE_ADDRESS]){
            orgWideEmailAdd.put(orgWideEmailAddRec.displayName,orgWideEmailAddRec);
        }
        if(!orgWideEmailAdd.isEmpty()){
            cqDataWrap.genericData.put(Constant_Data_Key__mdt.getInstance('ORGWIDEEMAILADD').Value__c,orgWideEmailAdd);
        }
    }
    // Method queries email templates
    static void getEmailTemplate(CommonQueriesDataWrapper cqDataWrap){
        // Stores the email template names
        Set<String> emailTempNames = new Set<String>{Constant_Case__mdt.getInstance('EMAIL_TEMPLATE_STATUS_UPDATE').Value__c
        ,Constant_Case__mdt.getInstance('EMAIL_TEMPLATE_ECFMG_DUP_CERTIFICATE').Value__c,Constant_Case__mdt.getInstance('EMAIL_TEMPLATE_STATUS_UPDATE_ON_CV_ACCEP').Value__c
        ,Constant_Case__mdt.getInstance('EMAIL_TEMPLATE_STATUS_UPDATE_ATTEST').Value__c,Constant_Case__mdt.getInstance('EMAIL_TEMPLATE_ECFMG_CERTIFICATE').Value__c
        ,Constant_Case__mdt.getInstance('ENTITY_USER_REQUEST_REJECTED').Value__c
        ,Constant_Case__mdt.getInstance('CASE_EMAIL_DEFICIENCY_TEMPLATE').Value__c
        ,Constant_Case__mdt.getInstance('EMAIL_TEMPLATE_ERAS_STATUS_UPDATE').Value__c};
        // Stores name and email template
        Map<String,EmailTemplate> emailTempMap = new Map<String,EmailTemplate>();
        for(EmailTemplate emailTemp: [SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE DeveloperName in:emailTempNames]){
            emailTempMap.put(emailTemp.DeveloperName,emailTemp);
        }
        if(!emailTempMap.isEmpty()){
            cqDataWrap.genericData.put(Constant_Data_Key__mdt.getInstance('EMAIL_TEMPLATE').Value__c,emailTempMap);
        }
    }
    // Method queries static resource
    static void getStaticResource(CommonQueriesDataWrapper cqDataWrap){
        // collects the static resource
        Map<String,StaticResource> nameStaticResource = new Map<String,StaticResource>();
        for(StaticResource srRecord : [SELECT Name, Id, Body FROM StaticResource WHERE Name =: Constant_other__mdt.getInstance('STATIC_RESOURCE_EXAM_PERMIT').Value__c]){
            nameStaticResource.put(srRecord.Name,srRecord);
        }
        if(!nameStaticResource.isEmpty()){
            cqDataWrap.genericData.put(Constant_Data_Key__mdt.getInstance('STATICRESOURCE').Value__c,nameStaticResource);
        }
    }
    // Returns generic data related data with return type as Map<String,sObject>
    public static Map<String,sObject> fetchGenericDataSObject(String objKey){
        try{
            if(cqDataWrap.genericData.containsKey(objKey)){
                return cqDataWrap.genericData.get(objKey);
            }else{
                return new Map<String,sObject>();
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // This class stores the data that will be used in the CaseTriggerDataInitialize to store the common queries.
    public class CommonQueriesDataWrapper{
        // Stores object name, recordId, sObject
        public Map<String,Map<String,sObject>> genericData = new Map<String,Map<String,sObject>>();
    }
}