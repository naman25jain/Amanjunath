global with sharing class Actionable_GenerateParametersBefore implements cadmus_core.AbstractBeforeActionable{
    //Abstract method of cadmus_core.AbstractBeforeActionable interface
    global void execute(cadmus_core__Actionable__c actionable,Id docConfig,Id objectId,Map<String, Object> inputMap,cadmus_core.ConvertController.ConvertDataModel cdm){
        Map<String, cadmus_core__Data_Source__c> dsMap = new Map<String,cadmus_core__Data_Source__c>();
        set<string> setConfigId = new set<string>();
        try{
            for(cadmus_core__Data_Source__c ds : [SELECT Id,Name,cadmus_core__CustomerDataSourceId__c,cadmus_core__Image_Name__c From cadmus_core__Data_Source__c WITH SECURITY_ENFORCED]){
                dsMap.put(ds.cadmus_core__CustomerDataSourceId__c,ds);
            }
            for(CredentialLangConfigID__mdt credLangConfigId : [Select id,CV_ConfigId__c from CredentialLangConfigID__mdt where active__c = true  WITH SECURITY_ENFORCED]){
                setConfigId.add(credLangConfigId.CV_ConfigId__c);
            }
            if((Test.isRunningTest() || setConfigId.contains([Select id,cadmus_core__CustomerDocumentConfigId__c from cadmus_core__Doc_Config__c where id=:docConfig WITH SECURITY_ENFORCED].cadmus_core__CustomerDocumentConfigId__c))){
                credentialCoverLetterParam(inputMap,objectId,dsMap);
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }
    // US 15508- Adds dynamic parameter values to input map
    public static void credentialCoverLetterParam(Map<String,Object> inputMap,Id objectId,Map<String,cadmus_core__Data_Source__c> dsMap){     
        Map<String, String> keyValDataSource = new Map<String, String>(); 
        for(Case cs : [select id,Document_Type__c,Entity__r.Name,Entity__r.BillingCity,Entity__r.BillingCountry,Entity__r.BillingPostalCode,Entity__r.BillingState,Entity__r.BillingStreet from Case where Id=:objectId WITH SECURITY_ENFORCED]){
            inputMap.put('DocumentType',cs.Document_Type__c);
            AddressWrapper adWrap = new AddressWrapper();
            adWrap.name = cs.Entity__r.Name;
            adWrap.city = cs.Entity__r.BillingCity;
            adWrap.country = cs.Entity__r.BillingCountry;
            adWrap.postalcode = cs.Entity__r.BillingPostalCode;
            adWrap.state = cs.Entity__r.BillingState;
            adWrap.street = cs.Entity__r.BillingStreet;
            keyValDataSource.put('Entity_Address',formatAddress(adWrap));
        }
        for(Contact_Association_Type_Staging__c cats: [Select id,Alternate_Entity__r.Name,Alternate_Entity__r.BillingCity,Alternate_Entity__r.BillingCountry,Alternate_Entity__r.BillingPostalCode,Alternate_Entity__r.BillingState,Alternate_Entity__r.BillingStreet from Contact_Association_Type_Staging__c where Case__r.Id=:objectId WITH SECURITY_ENFORCED order by lastmodifieddate desc limit 1]){
            if(string.isNotBlank(cats.Alternate_Entity__c)){
                AddressWrapper adWrap = new AddressWrapper();
                adWrap.name = cats.Alternate_Entity__r.Name;
                adWrap.city = cats.Alternate_Entity__r.BillingCity;
                adWrap.country = cats.Alternate_Entity__r.BillingCountry;
                adWrap.postalcode = cats.Alternate_Entity__r.BillingPostalCode;
                adWrap.state = cats.Alternate_Entity__r.BillingState;
                adWrap.street = cats.Alternate_Entity__r.BillingStreet;
                keyValDataSource.put('Alternate_Entity_Address',formatAddress(adWrap));
            }
        }
        if(!Test.isRunningTest()){
            inputMap.put(dsMap.get(label.EntityAddressDataSourceId).Id, keyValDataSource); 
        }
        else{
            inputMap.put(dsMap.values()[0].Id, keyValDataSource); 
        }
    }
    // US 15508- formats address
    public static string formatAddress(AddressWrapper adWrap){
        string address = adWrap.name+(string.isNotBlank(adWrap.street)?'<br>'+adWrap.street:'')+(string.isNotBlank(adWrap.city)?'<br>'+adWrap.city+',':'')+(string.isNotBlank(adWrap.state)?'<br>'+adWrap.state:'')+(string.isNotBlank(adWrap.postalcode)?string.isNotBlank(adWrap.state)?' '+adWrap.postalcode:'<br>'+adWrap.postalcode:'')+(string.isNotBlank(adWrap.country)?'<br>'+adWrap.country:'');
        return address;
    }
    // US 15508- wrapper class for storing address
    public class AddressWrapper{
        string name{get;set;}
        string city{get;set;}
        string country{get;set;}
        string postalcode{get;set;}
        string state{get;set;}
        string street{get;set;}
    }
}