global with sharing class Actionalbe_EpicReceipientsAddress implements cadmus_core.AbstractBeforeActionable{
    //Abstract method of cadmus_core.AbstractBeforeActionable interface
    global void execute(cadmus_core__Actionable__c actionable, Id docConfig, Id objectId,Map<String, Object> inputMap,cadmus_core.ConvertController.ConvertDataModel cdm){
        Map<String, cadmus_core__Data_Source__c> dsMap = new Map<String,cadmus_core__Data_Source__c>();
        try{
            for(cadmus_core__Data_Source__c ds : [SELECT Id, Name, cadmus_core__CustomerDataSourceId__c,cadmus_core__Image_Name__c FROM cadmus_core__Data_Source__c WITH SECURITY_ENFORCED]){
                dsMap.put(ds.cadmus_core__CustomerDataSourceId__c,ds);
            }
            epicReportReceipientsParam(inputMap,objectId,dsMap);
            epicReportAnnotationParam(inputMap,objectId,dsMap);
        }
        catch(Exception ex){
            throw ex;
        }
    }
    // US 12708 - Adds dynamic parameter values to input map - Get Receipients Address based on the selection of Report TYpe(Self, Volume Entity, Other Entity)
    public static void epicReportReceipientsParam(Map<String,Object> inputMap, Id objectId, Map<String,cadmus_core__Data_Source__c> dsMap){
        Map<String, String> keyValDataSource = new Map<String, String>(); 
        List<Case> epicReportCase = [SELECT Id,Secondary_Parent_Case__r.Entity__c,Report_Type__c,EPIC_Report_Entity__c,EPIC_Report_Entity_Country__c,EPIC_Report_Entity_Address__c,Contact.Name,Contact.MailingCity,
        Contact.MailingCountry,Entity__r.Name, Entity__r.BillingCity, Entity__r.BillingCountry FROM Case WHERE Id =: objectId];
        List<Account> accList = [SELECT Id, Name, BillingCity, BillingCountry FROM Account WHERE Id =: epicReportCase[0].Secondary_Parent_Case__r.Entity__c];
        if(!epicReportCase.isEmpty()){
            if(epicReportCase[0].Report_Type__c == 'Volume Entity'){
                keyValDataSource.put('Receipients_Name_Address',getEntityAddress(epicReportCase));
            }else if(epicReportCase[0].Report_Type__c == 'Self'){
                keyValDataSource.put('Receipients_Name_Address',getContactAddress(epicReportCase));
            }else if(epicReportCase[0].Report_Type__c == 'Other Entity'){
                keyValDataSource.put('Receipients_Name_Address',getEpicEntityAddress(epicReportCase));
            }
        }
        if(!accList.isEmpty()){
            keyValDataSource.put('CVCaseEntity_Name_Address',getCVCaseEntityAddress(accList));
        }                
        if(!Test.isRunningTest()){
            inputMap.put(dsMap.get(Constants.EPIC_REPORT_DATASOURCE_IDENTIFIER).Id, keyValDataSource); 
        }else{
            inputMap.put(dsMap.values()[0].Id, keyValDataSource); 
        }
    }
    public static String getEntityAddress(List<Case> epicReportCase){
        AddressWrapper adWrap = new AddressWrapper();
        adWrap.name = epicReportCase[0].Entity__r.Name;
        adWrap.city = epicReportCase[0].Entity__r.BillingCity;
        adWrap.country = epicReportCase[0].Entity__r.BillingCountry;
        return formatAddress(adWrap);        
    }
    public static String getContactAddress(List<Case> epicReportCase){
        AddressWrapper adWrap = new AddressWrapper();
        adWrap.name = epicReportCase[0].Contact.Name;
        adWrap.city = epicReportCase[0].Contact.MailingCity;
        adWrap.country = epicReportCase[0].Contact.MailingCountry;
        return formatAddress(adWrap);        
    }
    public static String getEpicEntityAddress(List<Case> epicReportCase){
        AddressWrapper adWrap = new AddressWrapper();
        adWrap.name = epicReportCase[0].EPIC_Report_Entity__c;
        adWrap.city = epicReportCase[0].EPIC_Report_Entity_Address__c;
        adWrap.country = epicReportCase[0].EPIC_Report_Entity_Country__c;
        return formatAddress(adWrap);        
    }
    public static String getCVCaseEntityAddress(List<Account> accRecord){
        AddressWrapper adWrap = new AddressWrapper();
        adWrap.name = accRecord[0].Name;
        adWrap.city = accRecord[0].BillingCity;
        adWrap.country = accRecord[0].BillingCountry;
        return formatAddress(adWrap);        
    }
    // US 12708 - formats address
    public static String formatAddress(AddressWrapper adWrap){
        String address = adWrap.name+(string.isNotBlank(adWrap.city)?Constants.LINE_BREAK+adWrap.city+',':'')+(string.isNotBlank(adWrap.country)?Constants.LINE_BREAK+adWrap.country:'');
        return address;
    }
    
    // US 12708 - wrapper class for storing address
    public class AddressWrapper{
        String name{get;set;}
        String city{get;set;}
        String country{get;set;}
    }
    //US 18636 - This method is used to pass the Annotation Text field value to the EPIC Report Recepients Data Source  
    public static void epicReportAnnotationParam(Map<String,Object> inputMap, Id objectId, Map<String,cadmus_core__Data_Source__c> dsMap){
        Map<String, String> keyValDataSource = new Map<String, String>();
        List<Case> epicReportCase = [SELECT Id, ContactId FROM Case WHERE Id =: objectId];
        Id epicReportConId = epicReportCase[0].ContactId;        
        List<Transcript_Anotation__c> transAnRecords = [SELECT Cibis_Transcript_Status__c, ANNOTATION_TEXT__c, Contact__c FROM Transcript_Anotation__c WHERE Contact__c =: epicReportConId WITH SECURITY_ENFORCED];
        if(transAnRecords.size() >0 && !transAnRecords.isEmpty()){
            keyValDataSource.put('Annotation_Text',getannotation(transAnRecords, epicReportConId));
        }
        if(!Test.isRunningTest()){
            inputMap.put(dsMap.get(Constants.EPIC_REPORT_DATASOURCE_IDENTIFIER).Id, keyValDataSource); 
        }else{
            inputMap.put(dsMap.values()[0].Id, keyValDataSource); 
        }
    }
    //This method is to pass the annotation Text values based on the combination values of Cibis_Transcript_Status__c
    public static String getannotation(List<Transcript_Anotation__c> annList, String contactId){
        Map<String, String> transAnnoStatusWithTextMap = new Map<String, String>();
        for(Transcript_Anotation__c trans: annList){
            transAnnoStatusWithTextMap.put(trans.Cibis_Transcript_Status__c, trans.ANNOTATION_TEXT__c);
        }        
        String annotation = '';
        if(transAnnoStatusWithTextMap.containsKey(Constants.TRANSCRIPT_STATUS_STANDARD) && !transAnnoStatusWithTextMap.containsKey(Constants.TRANSCRIPT_STATUS_STANDARDPROACTIVE) && !transAnnoStatusWithTextMap.containsKey(Constants.TRANSCRIPT_STATUS_SPECIALIZED)){
            annotation = transAnnoStatusWithTextMap.get(Constants.TRANSCRIPT_STATUS_STANDARD);
            return removeHtmlTagsOfAnnotation(annotation);
        }else if(transAnnoStatusWithTextMap.containsKey(Constants.TRANSCRIPT_STATUS_STANDARDPROACTIVE) && !transAnnoStatusWithTextMap.containsKey(Constants.TRANSCRIPT_STATUS_STANDARD) && !transAnnoStatusWithTextMap.containsKey(Constants.TRANSCRIPT_STATUS_SPECIALIZED)){
            annotation =transAnnoStatusWithTextMap.get(Constants.TRANSCRIPT_STATUS_STANDARDPROACTIVE);
            return removeHtmlTagsOfAnnotation(annotation);
        }else if(transAnnoStatusWithTextMap.containsKey(Constants.TRANSCRIPT_STATUS_SPECIALIZED) && !transAnnoStatusWithTextMap.containsKey(Constants.TRANSCRIPT_STATUS_STANDARD) && !transAnnoStatusWithTextMap.containsKey(Constants.TRANSCRIPT_STATUS_STANDARDPROACTIVE)){
            annotation = getAllSpecializedAnnotations(Constants.TRANSCRIPT_STATUS_SPECIALIZED, contactId);
            return annotation;
        }else if(transAnnoStatusWithTextMap.containsKey(Constants.TRANSCRIPT_STATUS_STANDARD) && transAnnoStatusWithTextMap.containsKey(Constants.TRANSCRIPT_STATUS_SPECIALIZED) && transAnnoStatusWithTextMap.containsKey(Constants.TRANSCRIPT_STATUS_STANDARDPROACTIVE)){
            String stdPro = transAnnoStatusWithTextMap.get(Constants.TRANSCRIPT_STATUS_STANDARDPROACTIVE);
            String stdProWithoutTags = removeHtmlTagsOfAnnotation(stdPro);
            String specializedWithoutTags = getAllSpecializedAnnotations(Constants.TRANSCRIPT_STATUS_SPECIALIZED, contactId);
            return annotation = stdProWithoutTags+Constants.LINE_BREAK+specializedWithoutTags;
        }
        else if(transAnnoStatusWithTextMap.containsKey(Constants.TRANSCRIPT_STATUS_STANDARD) && transAnnoStatusWithTextMap.containsKey(Constants.TRANSCRIPT_STATUS_SPECIALIZED) && !transAnnoStatusWithTextMap.containsKey(Constants.TRANSCRIPT_STATUS_STANDARDPROACTIVE)){
            String std = transAnnoStatusWithTextMap.get(Constants.TRANSCRIPT_STATUS_STANDARD);
            String stdWithoutTags = removeHtmlTagsOfAnnotation(std);
            String specializedWithoutTags = getAllSpecializedAnnotations(Constants.TRANSCRIPT_STATUS_SPECIALIZED, contactId);
            return annotation = stdWithoutTags+Constants.LINE_BREAK+specializedWithoutTags;
        }
        else if(transAnnoStatusWithTextMap.containsKey(Constants.TRANSCRIPT_STATUS_STANDARDPROACTIVE) && transAnnoStatusWithTextMap.containsKey(Constants.TRANSCRIPT_STATUS_SPECIALIZED) && !transAnnoStatusWithTextMap.containsKey(Constants.TRANSCRIPT_STATUS_STANDARD)){			
            String stdPro = transAnnoStatusWithTextMap.get(Constants.TRANSCRIPT_STATUS_STANDARDPROACTIVE);
            String stdProWithoutTags = removeHtmlTagsOfAnnotation(stdPro);
            String specializedWithoutTags = getAllSpecializedAnnotations(Constants.TRANSCRIPT_STATUS_SPECIALIZED, contactId);
            return annotation = stdProWithoutTags+Constants.LINE_BREAK+specializedWithoutTags;				
        }
        else if(transAnnoStatusWithTextMap.containsKey(Constants.TRANSCRIPT_STATUS_STANDARDPROACTIVE) && transAnnoStatusWithTextMap.containsKey(Constants.TRANSCRIPT_STATUS_STANDARD) && !transAnnoStatusWithTextMap.containsKey(Constants.TRANSCRIPT_STATUS_SPECIALIZED)){
            annotation = transAnnoStatusWithTextMap.get(Constants.TRANSCRIPT_STATUS_STANDARDPROACTIVE);
            return removeHtmlTagsOfAnnotation(annotation);            
        }
        return null;
    }
    public static String removeHtmlTagsOfAnnotation(String annotationStr){
        String annoValue = annotationStr.stripHtmlTags();
        return annoValue;
    }    
    // get all Specialized Annotations
    public static String getAllSpecializedAnnotations(String annotationType, String contactId){
        List<Transcript_Anotation__c> transAnRecords = [SELECT Cibis_Transcript_Status__c, ANNOTATION_TEXT__c, Contact__c 
                                                            FROM Transcript_Anotation__c 
                                                        WHERE Contact__c =: contactId 
                                                            AND Cibis_Transcript_Status__c =: annotationType WITH SECURITY_ENFORCED];
        String allSpecialized = '';
        if(!transAnRecords.isEmpty()){
            List<String> specializedAnnsList = new List<String>();
            for(Transcript_Anotation__c trans : transAnRecords){
                specializedAnnsList.add(removeHtmlTagsOfAnnotation(trans.ANNOTATION_TEXT__c));                
            }
            allSpecialized = String.join(specializedAnnsList,Constants.LINE_BREAK);
        }
        return allSpecialized;
    }
}