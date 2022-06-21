global with sharing class Actionable_GenerateNameOnDocument implements cadmus_core.AbstractBeforeActionable{
    //Abstract method of cadmus_core.AbstractBeforeActionable interface
    global void execute(cadmus_core__Actionable__c actionable,Id docConfig,Id objectId,Map<String, Object> inputMap,cadmus_core.ConvertController.ConvertDataModel cdm){
        Map<String, cadmus_core__Data_Source__c> dsMap = new Map<String,cadmus_core__Data_Source__c>();
        set<string> setConfigId = new set<string>();
        try{
            for(cadmus_core__Data_Source__c ds : [SELECT Id,Name,cadmus_core__CustomerDataSourceId__c,cadmus_core__Image_Name__c FROM cadmus_core__Data_Source__c WITH SECURITY_ENFORCED]){
                dsMap.put(ds.cadmus_core__CustomerDataSourceId__c,ds);
            }
            for(CredentialLangConfigID__mdt credLangConfigId : [SELECT Id,Form_ConfigId__c FROM CredentialLangConfigID__mdt WHERE active__c = true WITH SECURITY_ENFORCED]){
                setConfigId.add(credLangConfigId.Form_ConfigId__c);
            }
            if((Test.isRunningTest() || setConfigId.contains([SELECT Id,cadmus_core__CustomerDocumentConfigId__c FROM cadmus_core__Doc_Config__c WHERE Id=:docConfig WITH SECURITY_ENFORCED].cadmus_core__CustomerDocumentConfigId__c))){
                getNameonDocument(inputMap,objectId,dsMap);
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }
// Bug 19911
    public static void getNameonDocument(Map<String,Object> inputMap,Id objectId,Map<String,cadmus_core__Data_Source__c> dsMap){     
        Map<String, String> keyValDataSource = new Map<String, String>();
        Case caseRec = [SELECT Id, Service__c FROM Case WHERE Id=:objectId WITH SECURITY_ENFORCED];
        if(caseRec.Service__c == Constants.CASE_SERVICE_EPIC){
            List<Contact_Association_Type_Staging__c> catsList = [SELECT Id, Alternate_Entity__r.Entity_ID__c, Name_on_Document__c FROM Contact_Association_Type_Staging__c WHERE Case__c =: objectId WITH SECURITY_ENFORCED];
            keyValDataSource.put('Name_On_Document',catsList[0].Name_on_Document__c);
        }else{
            List<Asset> assetList = [SELECT Id, Name_on_Document__c FROM Asset WHERE Case__c =: objectId AND Name_on_Document__c != null WITH SECURITY_ENFORCED];
            keyValDataSource.put('Name_On_Document',assetList[0].Name_on_Document__c);
        }
        if(!Test.isRunningTest()){
            inputMap.put(dsMap.get(Constants.NAME_ON_DOCUMENT_DATASOURCE_IDENTIFIER).Id, keyValDataSource); 
        }else{
            inputMap.put(dsMap.values()[0].Id, keyValDataSource); 
        }
    }
}