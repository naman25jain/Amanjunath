public with sharing class AggregatePerformanceReport {
    //Purpose : Method to get year from aggregrate performance data based on Report Type.
    @AuraEnabled(cacheable=false)
    public static List<String> getReportYear(String selectedReportValue,String entityId) {
        List<String> returnVal = new List<String>();
        Set<String> dataYearSet = new Set<String>();
        ID countryRecordTypeId = Schema.SObjectType.Aggregate_Performance_Data__c.getRecordTypeInfosByDeveloperName().get(Constants.APD_RECORD_TYPE_AGGREGAETPD_COUNTRY).getRecordTypeId();
        ID allRecordTypeId = Schema.SObjectType.Aggregate_Performance_Data__c.getRecordTypeInfosByDeveloperName().get(Constants.APD_RECORD_TYPE_AGGREGAETPD_ALL).getRecordTypeId();
        ID schoolRecordTypeId = Schema.SObjectType.Aggregate_Performance_Data__c.getRecordTypeInfosByDeveloperName().get(Constants.APD_RECORD_TYPE_AGGREGAETPD_SCHOOL).getRecordTypeId();
        ID specialRecordTypeId = Schema.SObjectType.Aggregate_Performance_Data__c.getRecordTypeInfosByDeveloperName().get(Constants.APD_RECORD_TYPE_SPECIALREPORTPD).getRecordTypeId();
        if(selectedReportValue == Constants.APD_FAIMERREPORT_AGGREGATE){
            List<Aggregate_Performance_Data__c> apdAggregateReport  = new List<Aggregate_Performance_Data__c>([Select id,Name,RecordTypeId,Data_agg_year__c from Aggregate_Performance_Data__c where (RecordTypeId = :countryRecordTypeId OR RecordTypeId = :allRecordTypeId OR RecordTypeId =:schoolRecordTypeId) AND School_Name__c=:entityId WITH SECURITY_ENFORCED order by Data_agg_year__c ASC]);
            if(!apdAggregateReport.isEmpty()){
                for(Aggregate_Performance_Data__c aggregateReport: apdAggregateReport){
                    String datayear = aggregateReport.Data_agg_year__c;
                    dataYearSet.add(datayear);
                } 
                returnVal.addAll(dataYearSet);
            }
        }
        if(selectedReportValue == Constants.APD_FAIMERREPORT_SPECIAL){
            List<Aggregate_Performance_Data__c> apdSpecialReport  = new List<Aggregate_Performance_Data__c>([Select id,Name,RecordTypeId,Data_agg_year__c from Aggregate_Performance_Data__c where (RecordTypeId = :specialRecordTypeId AND School_Name__c=:entityId) WITH SECURITY_ENFORCED order by Data_agg_year__c ASC]);
            if(!apdSpecialReport.isEmpty()){
                for(Aggregate_Performance_Data__c specialReport: apdSpecialReport){
                    String datayear = specialReport.Data_agg_year__c;
                    dataYearSet.add(datayear);
                } 
                returnVal.addAll(dataYearSet);
            }
        }
        return returnVal;
    }

    //Method to generate aggregate report of Step1 exam for selected year
    @AuraEnabled
    public static String generateAggregateReport(String yearValue, String entityId){
        String fileUrl = '';
        String step1Id = generateAggregateReportStep1(yearValue, entityId);
        String step2CKId = generateAggregateReportStep2CK(yearValue, entityId);
        String step2CSId = generateAggregateReportStep2CS(yearValue, entityId);
        if(String.isBlank(step1Id) && String.isBlank(step2CKId) && String.isBlank(step2CSId)){
            return 'No document created';
        }
        else{
            List<Id> docConfigIds = new List<Id>();
            List<cadmus_core__Doc_Config__c> docConfiList = [SELECT Id,cadmus_core__View_Customer_DocConfig_Id__c FROM cadmus_core__Doc_Config__c WHERE cadmus_core__View_Customer_DocConfig_Id__c = :Constants.DOCCONFIG_APD_COVER_LETTER WITH SECURITY_ENFORCED LIMIT 1];
            if(!docConfiList.isEmpty()){
                docConfigIds.add(docConfiList[0].Id);    
            }
            if(String.isNotBlank(step1Id)){
                docConfigIds.add(step1Id);
            }
            if(String.isNotBlank(step2CKId)){
                docConfigIds.add(step2CKId);
            }
            if(String.isNotBlank(step2CSId)){
                docConfigIds.add(step2CSId);
            }
            fileUrl = generateDocument(yearValue, entityId, docConfigIds);
            return fileUrl;
        }
    }

    //Method to generate aggregate report of Step1 exam for selected year
    public static String generateAggregateReportStep1(String yearValue, String entityId){
        Id aggPDSchool = Schema.SObjectType.Aggregate_Performance_Data__c.getRecordTypeInfosByDeveloperName().get(Constants.APD_RECORD_TYPE_AGGREGAETPD_SCHOOL).getRecordTypeId();
        String docConfigId = '';
        List<Aggregate_Performance_Data__c> apdSchool = new List<Aggregate_Performance_Data__c>([SELECT Id,Name,RecordTypeId,Data_agg_year__c,Bs_1f_take_count__c,Bs_1r_take_count__c,Bs_5f_take_count__c,Bs_5r_take_count__c FROM Aggregate_Performance_Data__c WHERE RecordTypeId =:aggPDSchool AND School_Name__c =:entityId AND Data_agg_year__c =:yearValue WITH SECURITY_ENFORCED]);
        if(!apdSchool.isEmpty()){
            docConfigId = generateReportForSchoolStep1(apdSchool, yearValue, entityId);
            if(String.isBlank(docConfigId)){
                docConfigId = generateReportForCountryStep1(yearValue, entityId);
            }
        }
        else{
            docConfigId = generateReportForCountryStep1(yearValue, entityId);
        }
        return docConfigId;
    }

    public static String generateReportForSchoolStep1(List<Aggregate_Performance_Data__c> apdSchool, String yearValue, String entityId){
        String docConfigId = '';
        if(apdSchool[0].Bs_1f_take_count__c >= Integer.valueOf(System.Label.Number_of_Test_Takers) || apdSchool[0].Bs_1r_take_count__c >= Integer.valueOf(System.Label.Number_of_Test_Takers)){
            List<cadmus_core__Doc_Config__c> docConfiList = [SELECT Id,cadmus_core__View_Customer_DocConfig_Id__c FROM cadmus_core__Doc_Config__c WHERE cadmus_core__View_Customer_DocConfig_Id__c = :Constants.DOCCONFIG_APD_SCHOOL_STEP1_1_YEAR WITH SECURITY_ENFORCED LIMIT 1];
            if(!docConfiList.isEmpty()){
                docConfigId = docConfiList[0].Id;    
            }
        }
        else if(apdSchool[0].Bs_5f_take_count__c >= Integer.valueOf(System.Label.Number_of_Test_Takers) || apdSchool[0].Bs_5r_take_count__c >= Integer.valueOf(System.Label.Number_of_Test_Takers)){
            List<cadmus_core__Doc_Config__c> docConfiList = [SELECT Id,cadmus_core__View_Customer_DocConfig_Id__c FROM cadmus_core__Doc_Config__c WHERE cadmus_core__View_Customer_DocConfig_Id__c = :Constants.DOCCONFIG_APD_SCHOOL_STEP1_5_YEAR WITH SECURITY_ENFORCED LIMIT 1];
            if(!docConfiList.isEmpty()){
                docConfigId = docConfiList[0].Id;    
            }
        }
        return docConfigId;
    }

    public static String generateReportForCountryStep1(String yearValue, String entityId){
        String docConfigId = '';
        Id aggPDCountry = Schema.SObjectType.Aggregate_Performance_Data__c.getRecordTypeInfosByDeveloperName().get(Constants.APD_RECORD_TYPE_AGGREGAETPD_COUNTRY).getRecordTypeId();
        Account entity = [SELECT Id, BillingCountry FROM Account WHERE Id =:entityId WITH SECURITY_ENFORCED];
        List<Aggregate_Performance_Data__c> apdCountry = new List<Aggregate_Performance_Data__c>([SELECT Id,Name,RecordTypeId,Data_agg_year__c,Bs_1f_take_count__c,Bs_1r_take_count__c,Bs_5f_take_count__c,Bs_5r_take_count__c,Country_Name__c FROM Aggregate_Performance_Data__c WHERE RecordTypeId =:aggPDCountry AND Data_agg_year__c =:yearValue AND Country_Name__c =:entity.BillingCountry WITH SECURITY_ENFORCED]);
        if(!apdCountry.isEmpty()){
            if(apdCountry[0].Bs_1f_take_count__c >= Integer.valueOf(System.Label.Number_of_Test_Takers) || apdCountry[0].Bs_1r_take_count__c >= Integer.valueOf(System.Label.Number_of_Test_Takers)){
                List<cadmus_core__Doc_Config__c> docConfiList = [SELECT Id,cadmus_core__View_Customer_DocConfig_Id__c FROM cadmus_core__Doc_Config__c WHERE cadmus_core__View_Customer_DocConfig_Id__c = :Constants.DOCCONFIG_APD_COUNTRY_STEP1_1_YEAR WITH SECURITY_ENFORCED LIMIT 1];
                if(!docConfiList.isEmpty()){
                    docConfigId = docConfiList[0].Id;    
                }
            }
            else if(apdCountry[0].Bs_5f_take_count__c >= Integer.valueOf(System.Label.Number_of_Test_Takers) || apdCountry[0].Bs_5r_take_count__c >= Integer.valueOf(System.Label.Number_of_Test_Takers)){
                List<cadmus_core__Doc_Config__c> docConfiList = [SELECT Id,cadmus_core__View_Customer_DocConfig_Id__c FROM cadmus_core__Doc_Config__c WHERE cadmus_core__View_Customer_DocConfig_Id__c = :Constants.DOCCONFIG_APD_COUNTRY_STEP1_5_YEAR WITH SECURITY_ENFORCED LIMIT 1];
                if(!docConfiList.isEmpty()){
                    docConfigId = docConfiList[0].Id;    
                }
            }
        }
        return docConfigId;
    }

    //Method to generate aggregate report of Step2 CK exam for selected year
    @AuraEnabled
    public static String generateAggregateReportStep2CK(String yearValue, String entityId){
        Id aggPDSchool = Schema.SObjectType.Aggregate_Performance_Data__c.getRecordTypeInfosByDeveloperName().get(Constants.APD_RECORD_TYPE_AGGREGAETPD_SCHOOL).getRecordTypeId();
        String docConfigId = '';
        List<Aggregate_Performance_Data__c> apdSchool = new List<Aggregate_Performance_Data__c>([SELECT Id,Name,RecordTypeId,Data_agg_year__c,Ck_1f_take_count__c, Ck_1r_take_count__c, Ck_5f_take_count__c, Ck_5r_take_count__c FROM Aggregate_Performance_Data__c WHERE RecordTypeId =:aggPDSchool AND School_Name__c =:entityId AND Data_agg_year__c =:yearValue WITH SECURITY_ENFORCED]);
        if(!apdSchool.isEmpty()){
            docConfigId = generateReportForSchoolStep2CK(apdSchool, yearValue, entityId);
            if(String.isBlank(docConfigId)){
                docConfigId = generateReportForCountryStep2CK(yearValue, entityId);
            }
        }
        else{
            docConfigId = generateReportForCountryStep2CK(yearValue, entityId);
        }
        return docConfigId;
    }

    public static String generateReportForSchoolStep2CK(List<Aggregate_Performance_Data__c> apdSchool, String yearValue, String entityId){
        String docConfigId = '';
        if(apdSchool[0].Ck_1f_take_count__c >= Integer.valueOf(System.Label.Number_of_Test_Takers) || apdSchool[0].Ck_1r_take_count__c >= Integer.valueOf(System.Label.Number_of_Test_Takers)){
            List<cadmus_core__Doc_Config__c> docConfiList = [SELECT Id,cadmus_core__View_Customer_DocConfig_Id__c FROM cadmus_core__Doc_Config__c WHERE cadmus_core__View_Customer_DocConfig_Id__c = :Constants.DOCCONFIG_APD_SCHOOL_STEP2CK_1_YEAR WITH SECURITY_ENFORCED LIMIT 1];
            if(!docConfiList.isEmpty()){
                docConfigId = docConfiList[0].Id;    
            }
        }
        else if(apdSchool[0].Ck_5f_take_count__c >= Integer.valueOf(System.Label.Number_of_Test_Takers) || apdSchool[0].Ck_5r_take_count__c >= Integer.valueOf(System.Label.Number_of_Test_Takers)){
            List<cadmus_core__Doc_Config__c> docConfiList = [SELECT Id,cadmus_core__View_Customer_DocConfig_Id__c FROM cadmus_core__Doc_Config__c WHERE cadmus_core__View_Customer_DocConfig_Id__c = :Constants.DOCCONFIG_APD_SCHOOL_STEP2CK_5_YEAR WITH SECURITY_ENFORCED LIMIT 1];
            if(!docConfiList.isEmpty()){
                docConfigId = docConfiList[0].Id;    
            }
        }
        return docConfigId;
    }

    public static String generateReportForCountryStep2CK(String yearValue, String entityId){
        String docConfigId = '';
        Id aggPDCountry = Schema.SObjectType.Aggregate_Performance_Data__c.getRecordTypeInfosByDeveloperName().get(Constants.APD_RECORD_TYPE_AGGREGAETPD_COUNTRY).getRecordTypeId();
        Account entity = [SELECT Id, BillingCountry FROM Account WHERE Id =:entityId WITH SECURITY_ENFORCED];
        List<Aggregate_Performance_Data__c> apdCountry = new List<Aggregate_Performance_Data__c>([SELECT Id,Name,RecordTypeId,Data_agg_year__c,Ck_1f_take_count__c, Ck_1r_take_count__c, Ck_5f_take_count__c, Ck_5r_take_count__c,Country_Name__c FROM Aggregate_Performance_Data__c WHERE RecordTypeId =:aggPDCountry AND Data_agg_year__c =:yearValue AND Country_Name__c =:entity.BillingCountry WITH SECURITY_ENFORCED]);
        if(!apdCountry.isEmpty()){
            if(apdCountry[0].Ck_1f_take_count__c >= Integer.valueOf(System.Label.Number_of_Test_Takers) || apdCountry[0].Ck_1r_take_count__c >= Integer.valueOf(System.Label.Number_of_Test_Takers)){
                List<cadmus_core__Doc_Config__c> docConfiList = [SELECT Id,cadmus_core__View_Customer_DocConfig_Id__c FROM cadmus_core__Doc_Config__c WHERE cadmus_core__View_Customer_DocConfig_Id__c = :Constants.DOCCONFIG_APD_COUNTRY_STEP2CK_1_YEAR WITH SECURITY_ENFORCED LIMIT 1];
                if(!docConfiList.isEmpty()){
                    docConfigId = docConfiList[0].Id;    
                }
            }
            else if(apdCountry[0].Ck_5f_take_count__c >= Integer.valueOf(System.Label.Number_of_Test_Takers) || apdCountry[0].Ck_5r_take_count__c >= Integer.valueOf(System.Label.Number_of_Test_Takers)){
                List<cadmus_core__Doc_Config__c> docConfiList = [SELECT Id,cadmus_core__View_Customer_DocConfig_Id__c FROM cadmus_core__Doc_Config__c WHERE cadmus_core__View_Customer_DocConfig_Id__c = :Constants.DOCCONFIG_APD_COUNTRY_STEP2CK_5_YEAR WITH SECURITY_ENFORCED LIMIT 1];
                if(!docConfiList.isEmpty()){
                    docConfigId = docConfiList[0].Id;    
                }
            }
        }
        return docConfigId;
    }

    //Method to generate aggregate report of Step2 CS exam for selected year
    @AuraEnabled
    public static String generateAggregateReportStep2CS(String yearValue, String entityId){
        Id aggPDSchool = Schema.SObjectType.Aggregate_Performance_Data__c.getRecordTypeInfosByDeveloperName().get(Constants.APD_RECORD_TYPE_AGGREGAETPD_SCHOOL).getRecordTypeId();
        String docConfigId = '';
        List<Aggregate_Performance_Data__c> apdSchool = new List<Aggregate_Performance_Data__c>([SELECT Id,Name,RecordTypeId,Data_agg_year__c,Cs_1f_take_count__c, Cs_1r_take_count__c, Cs_5f_take_count__c, Cs_5r_take_count__c FROM Aggregate_Performance_Data__c WHERE RecordTypeId =:aggPDSchool AND School_Name__c =:entityId AND Data_agg_year__c =:yearValue WITH SECURITY_ENFORCED]);
        if(!apdSchool.isEmpty()){
            docConfigId = generateReportForSchoolStep2CS(apdSchool, yearValue, entityId);
            if(String.isBlank(docConfigId)){
                docConfigId = generateReportForCountryStep2CS(yearValue, entityId);
            }
        }
        else{
            docConfigId = generateReportForCountryStep2CS(yearValue, entityId);
        }
        return docConfigId;
    }

    public static String generateReportForSchoolStep2CS(List<Aggregate_Performance_Data__c> apdSchool, String yearValue, String entityId){
        String docConfigId = '';
        if(apdSchool[0].Cs_1f_take_count__c >= Integer.valueOf(System.Label.Number_of_Test_Takers) || apdSchool[0].Cs_1r_take_count__c >= Integer.valueOf(System.Label.Number_of_Test_Takers)){
            List<cadmus_core__Doc_Config__c> docConfiList = [SELECT Id,cadmus_core__View_Customer_DocConfig_Id__c FROM cadmus_core__Doc_Config__c WHERE cadmus_core__View_Customer_DocConfig_Id__c = :Constants.DOCCONFIG_APD_SCHOOL_STEP2CS_1_YEAR WITH SECURITY_ENFORCED LIMIT 1];
            if(!docConfiList.isEmpty()){
                docConfigId = docConfiList[0].Id;    
            }
        }
        else if(apdSchool[0].Cs_5f_take_count__c >= Integer.valueOf(System.Label.Number_of_Test_Takers) || apdSchool[0].Cs_5r_take_count__c >= Integer.valueOf(System.Label.Number_of_Test_Takers)){
            List<cadmus_core__Doc_Config__c> docConfiList = [SELECT Id,cadmus_core__View_Customer_DocConfig_Id__c FROM cadmus_core__Doc_Config__c WHERE cadmus_core__View_Customer_DocConfig_Id__c = :Constants.DOCCONFIG_APD_SCHOOL_STEP2CS_5_YEAR WITH SECURITY_ENFORCED LIMIT 1];
            if(!docConfiList.isEmpty()){
                docConfigId = docConfiList[0].Id;    
            }
        }
        return docConfigId;
    }

    public static String generateReportForCountryStep2CS(String yearValue, String entityId){
        String docConfigId = '';
        Id aggPDCountry = Schema.SObjectType.Aggregate_Performance_Data__c.getRecordTypeInfosByDeveloperName().get(Constants.APD_RECORD_TYPE_AGGREGAETPD_COUNTRY).getRecordTypeId();
        Account entity = [SELECT Id, BillingCountry FROM Account WHERE Id =:entityId WITH SECURITY_ENFORCED];
        List<Aggregate_Performance_Data__c> apdCountry = new List<Aggregate_Performance_Data__c>([SELECT Id,Name,RecordTypeId,Data_agg_year__c,Cs_1f_take_count__c, Cs_1r_take_count__c, Cs_5f_take_count__c, Cs_5r_take_count__c,Country_Name__c FROM Aggregate_Performance_Data__c WHERE RecordTypeId =:aggPDCountry AND Data_agg_year__c =:yearValue AND Country_Name__c =:entity.BillingCountry WITH SECURITY_ENFORCED]);
        if(!apdCountry.isEmpty()){
            if(apdCountry[0].Cs_1f_take_count__c >= Integer.valueOf(System.Label.Number_of_Test_Takers) || apdCountry[0].Cs_1r_take_count__c >= Integer.valueOf(System.Label.Number_of_Test_Takers)){
                List<cadmus_core__Doc_Config__c> docConfiList = [SELECT Id,cadmus_core__View_Customer_DocConfig_Id__c FROM cadmus_core__Doc_Config__c WHERE cadmus_core__View_Customer_DocConfig_Id__c = :Constants.DOCCONFIG_APD_COUNTRY_STEP2CS_1_YEAR WITH SECURITY_ENFORCED LIMIT 1];
                if(!docConfiList.isEmpty()){
                    docConfigId = docConfiList[0].Id;    
                }
            }
            else if(apdCountry[0].Cs_5f_take_count__c >= Integer.valueOf(System.Label.Number_of_Test_Takers) || apdCountry[0].Cs_5r_take_count__c >= Integer.valueOf(System.Label.Number_of_Test_Takers)){
                List<cadmus_core__Doc_Config__c> docConfiList = [SELECT Id,cadmus_core__View_Customer_DocConfig_Id__c FROM cadmus_core__Doc_Config__c WHERE cadmus_core__View_Customer_DocConfig_Id__c = :Constants.DOCCONFIG_APD_COUNTRY_STEP2CS_5_YEAR WITH SECURITY_ENFORCED LIMIT 1];
                if(!docConfiList.isEmpty()){
                    docConfigId = docConfiList[0].Id;    
                }
            }
        }
        return docConfigId;
    }

    public static String generateDocument(String yearValue, String entityId, List<Id> docConfigIds){
        cadmus_core.ConvertController.ConvertDataModel cdm = new cadmus_core.ConvertController.ConvertDataModel();
        cdm.docConfigIds = docConfigIds;
        cdm.objectId = entityId;
        cdm.pdfActionType = 'MERGE';
        cdm.parameters = new cadmus_core.CadmusParameters();
        cadmus_core.CadmusKeyValue cadmusKeyValue = new cadmus_core.CadmusKeyValue();
        cadmusKeyValue.key = 'year';
        cadmusKeyValue.valueString = yearValue;
        cdm.parameters.values.add(cadmusKeyValue);
        Account entity = [SELECT Id, BillingCountry FROM Account WHERE Id =:entityId WITH SECURITY_ENFORCED];
        cadmus_core.CadmusKeyValue cadmusKeyValue1 = new cadmus_core.CadmusKeyValue();
        cadmusKeyValue1.key = 'country';
        cadmusKeyValue1.valueString = entity.BillingCountry;
        cdm.parameters.values.add(cadmusKeyValue1);
        if(!test.isRunningTest()){
            cadmus_core.DocGenerationWrapper result = cadmus_core.ConvertController.convertWithWrapper(cdm);
            ContentVersion report = [SELECT Id, ContentDocumentId, Title FROM ContentVersion WHERE Title = :result.response.metadata.targetName WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1];
            return Constants.FILE_VERSION_DOWNLOAD_URL+report.Id;
        }
        else{
            return 'No document created';
        }
    }

    @AuraEnabled
    public static String deleteAggregateReport(String cvId){
        try{
            if(ContentDocument.SObjectType.getDescribe().isDeletable()) {
				DELETE [SELECT Id FROM ContentDocument WHERE Id IN (SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cvId)];
			}
        }
        catch(Exception e){
            return e.getMessage();
        }
        return 'success';
    }

    @AuraEnabled(cacheable=false)
    public static String getApdRecord(String yearValue,String entityId){
        String retVal = '';
        String custDocConfigId = '';
        Id docConfigIdTemplate;
        List<cadmus_core__Doc_Config__c> docConfiList = new List<cadmus_core__Doc_Config__c>();
        ID specialRecordTypeId = Schema.SObjectType.Aggregate_Performance_Data__c.getRecordTypeInfosByDeveloperName().get(Constants.APD_RECORD_TYPE_SPECIALREPORTPD).getRecordTypeId();
        List<Aggregate_Performance_Data__c> apdSpecialReport  = new List<Aggregate_Performance_Data__c>([Select id,Name,RecordTypeId,Data_agg_year__c,Bs_1f_take_count__c,Bs_3f_take_count__c,Ck_1f_take_count__c,Ck_3f_take_count__c,Cs_1f_take_count__c,Cs_3f_take_count__c from Aggregate_Performance_Data__c where (RecordTypeId = :specialRecordTypeId AND School_Name__c=:entityId AND Data_agg_year__c=:yearValue) WITH SECURITY_ENFORCED order by Data_agg_year__c ASC]);
        if(!apdSpecialReport.isEmpty()){
            if(apdSpecialReport[0].Bs_1f_take_count__c >= 5 && apdSpecialReport[0].Ck_1f_take_count__c>= 5 && apdSpecialReport[0].Cs_1f_take_count__c>= 5){
                custDocConfigId = Constants.DOCCONFIG_APD_FAIMERREPORT_5_YEARS;
            }
            else{
                custDocConfigId = Constants.DOCCONFIG_APD_FAIMERREPORT_3_YEARS;
            }
            docConfiList = [Select id,cadmus_core__View_Customer_DocConfig_Id__c from cadmus_core__Doc_Config__c where cadmus_core__View_Customer_DocConfig_Id__c =:custDocConfigId WITH SECURITY_ENFORCED Limit 1 ];
            if(!docConfiList.isEmpty()){
                docConfigIdTemplate = docConfiList[0].Id;    
            }
            cadmus_core.ConvertController.ConvertDataModel cdm = new cadmus_core.ConvertController.ConvertDataModel();
            cdm.docConfigId = docConfigIdTemplate;
            cdm.objectId = apdSpecialReport[0].Id;
            if(!test.isRunningTest()){
                cadmus_core.DocGenerationWrapper result = cadmus_core.ConvertController.convertWithWrapper(cdm);
                ContentVersion report = [SELECT Id, ContentDocumentId, Title FROM ContentVersion WHERE Title = :result.response.metadata.targetName WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1];
                return Constants.FILE_VERSION_DOWNLOAD_URL+report.Id;
            }
        }
        return retVal;
    }
}