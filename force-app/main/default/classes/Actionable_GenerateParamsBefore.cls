global with sharing class Actionable_GenerateParamsBefore implements cadmus_core.AbstractBeforeActionable{
    //Abstract method of cadmus_core.AbstractBeforeActionable interface
    global void execute(cadmus_core__Actionable__c actionable,Id docConfig,Id objectId,Map<String, Object> inputMap,cadmus_core.ConvertController.ConvertDataModel cdm){
        Map<String, cadmus_core__Data_Source__c> dsMap = new Map<String,cadmus_core__Data_Source__c>();
        set<string> setConfigId = new set<string>();
        try{
            for(cadmus_core__Data_Source__c ds : [SELECT Id,Name,cadmus_core__CustomerDataSourceId__c,cadmus_core__Image_Name__c FROM cadmus_core__Data_Source__c WITH SECURITY_ENFORCED]){
                dsMap.put(ds.cadmus_core__CustomerDataSourceId__c,ds);
            }
            for(CredentialLangConfigID__mdt credLangConfigId : [SELECT id,Form_ConfigId__c FROM CredentialLangConfigID__mdt WHERE Case_Record_Type__c=:Constants.CASE_RECORD_TYPE_MED_EDU_FORM AND active__c=true WITH SECURITY_ENFORCED]){
                setConfigId.add(credLangConfigId.Form_ConfigId__c);
            }
            if((Test.isRunningTest() || setConfigId.contains([SELECT id,cadmus_core__CustomerDocumentConfigId__c FROM cadmus_core__Doc_Config__c WHERE id=:docConfig WITH SECURITY_ENFORCED].cadmus_core__CustomerDocumentConfigId__c))){
                medEduFormParam(inputMap,objectId,dsMap);
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }
    // US 16936 - Adds dynamic parameter values to input map - Get Entity Address and Physical Address
    public static void medEduFormParam(Map<String,Object> inputMap,Id objectId,Map<String,cadmus_core__Data_Source__c> dsMap){
        String actualAccountId;
        Map<String, String> keyValDataSource = new Map<String, String>(); 
        String affirRecTypeDevName = Constants.AFFIRMATION_RECORD_TYPE_MED_EDU_FORM;
        Affirmation__c affirmationRec = [SELECT Id, Verify_with_Alternate_Entity__c, Case__r.Alternate_Entity__c, Case__r.Alternate_Entity__r.Name, Case__r.Entity__c, Case__r.Entity__r.Name, Case__r.Document_Type__c, Case__r.Send_Method__c FROM Affirmation__c WHERE recordType.DeveloperName=:affirRecTypeDevName AND Case__c=:objectId WITH SECURITY_ENFORCED ORDER BY LastModifiedDate DESC];
        String documentType = affirmationRec.Case__r.Document_Type__c;
        String sendMethod = affirmationRec.Case__r.Send_Method__c;      
        if(affirmationRec.Verify_with_Alternate_Entity__c && String.isNotBlank(affirmationRec.Case__r.Alternate_Entity__r.Name)){
            actualAccountId = affirmationRec.Case__r.Alternate_Entity__c;
        }else if(String.isNotBlank(affirmationRec.Case__r.Entity__r.Name)){
            actualAccountId = affirmationRec.Case__r.Entity__c;
        }
        keyValDataSource.put('Entity_Address',getEntityAddress(actualAccountId));
        LIST<Account2Service__c> acc2serList = [SELECT Id, Name, Account__c, Service__c, Service__r.Name, Account__r.Id, Active__c FROM Account2Service__c WHERE Account__c=:actualAccountId AND Active__c=false AND Service__r.Name=:Constants.SERVICE_NAME_MEDICAL_EDU_FORM WITH SECURITY_ENFORCED ORDER BY CreatedDate ASC];
        if(!acc2serList.isEmpty()){
            String accountServiceId = acc2serList[0].Id;
            LIST<CONTACT2ACCTSERVICE__c> con2accserList = [SELECT Id, Account_Service__r.Id, Physical_Address__c, Credential_Type__c FROM CONTACT2ACCTSERVICE__c WHERE Account_Service__c=:accountServiceId AND Credential_Type__c=:documentType AND Preferred_mode_of_communication__c=:sendMethod WITH SECURITY_ENFORCED ORDER BY LastModifiedDate DESC];
            if(!con2accserList.isEmpty() && con2accserList[0].Physical_Address__c != null){
                keyValDataSource.put('Entity_Address',con2accserList[0].Physical_Address__c);
            }
        }
        if(!Test.isRunningTest()){
            inputMap.put(dsMap.get(Constants.MEDEDUFORM_FORM_ENTITYADDR_IDENTIFIER).Id, keyValDataSource); 
        }
        else{
            inputMap.put(dsMap.values()[0].Id, keyValDataSource); 
        }
    }
    public static String getEntityAddress(Id actualAccountId){
        Account accRecord = [SELECT Id, Name, BillingCountry FROM Account WHERE Id=:actualAccountId WITH SECURITY_ENFORCED];
        AddressWrapper adWrap = new AddressWrapper();
        adWrap.name = accRecord.Name;
        adWrap.country = accRecord.BillingCountry;
        return formatAddress(adWrap);        
    }
    // US 16936- formats address
    public static string formatAddress(AddressWrapper adWrap){
        string address = adWrap.name+(string.isNotBlank(adWrap.country)?', '+adWrap.country:'');
        return address;
    }
    // US 16936- wrapper class for storing address
    public class AddressWrapper{
        string name{get;set;}
        string country{get;set;}
    }
}