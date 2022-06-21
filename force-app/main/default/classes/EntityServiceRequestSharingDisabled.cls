public without sharing class EntityServiceRequestSharingDisabled{
    @AuraEnabled
    public static string insertContactandCaseEntityRqeuestWithoutShar(string jsonString){
        EntityServiceRequestControllerHelper.InsertContactandCaseEntityRqeuestWrapper objectList = (EntityServiceRequestControllerHelper.InsertContactandCaseEntityRqeuestWrapper) JSON.deserialize(jsonString, EntityServiceRequestControllerHelper.InsertContactandCaseEntityRqeuestWrapper.class);
        string caseNum='';
        Account entityAccount = new Account();
        entityAccount = [Select Name,id,Account_Type__c from Account where Id =:objectList.finalSelectedRecordId limit 1];
        Contact conToInsert = new Contact();
        conToInsert.FirstName = objectList.restOfName;
        conToInsert.LastName = objectList.entityLastName;
        if(objectList.onlyOneName){
            conToInsert.legal_name_consists_of_one_name_only__c = True;
        }
        else{
            conToInsert.legal_name_consists_of_one_name_only__c = false;
        }
        conToInsert.Generational_Suffix__c  = objectList.generationalSuffix;
        conToInsert.Birthdate = objectList.dateOfBirth;
        conToInsert.Email = objectList.emailAddress;
        conToInsert.Phone = objectList.phoneNumber;
        conToInsert.Department = objectList.department;
        conToInsert.Title = objectList.jobTitle;
        conToInsert.Passport_Country__c = objectList.countryVal;
        conToInsert.AccountId = objectList.finalSelectedRecordId;
        conToInsert.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_ENTITYUSER).getRecordTypeId();
        try{
            dupcheck.dc3TriggerProcessGlobal.setTriggerSource('DISABLE');
            insert conToInsert;
        }
        catch(exception e){
            logMessage(e.getMessage(), '');
        }
        Contact createdContact = new Contact();
        if(conToInsert.Id != null){
            createdContact = [Select id,FirstName,LastName,email,legal_name_consists_of_one_name_only__c,AccountId from Contact where Id =:conToInsert.Id Limit 1];
        }
        Group grp = [SELECT Id, name, Group.DeveloperName FROM Group WHERE Type = 'Queue' and Group.name =:Constants.CASE_QUEUE_ENTITY_USER_REQUESTS];
        if(createdContact.Id != null){
            string serviceName = objectList.serviceValue;
            Case newCase = new Case();
            newCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENTITY_USER_REQUEST).getRecordTypeId();
            newCase.Source__c = Constants.CASE_SOURCE_PORTAL_USER;
            newCase.Request_Type_Value__c = Constants.CASE_REQUEST_TYPE_ADD_USER;
            newCase.Share_Information_with_Coordinator__c = Constants.STATUS_YES;  
            newCase.Entity__c =  objectList.finalSelectedRecordId;
            newCase.Internal_Status__c = Constants.CASE_STATUS_NEW;
            newCase.ContactId = createdContact.Id;
            newCase.Service_Name__c = serviceName;
            //newCase.OwnerId = grp.Id;
            try{
                insert newCase;
            }
            catch(exception e){
                logMessage(e.getMessage(), '');
            }
            List<Case> createdCase = new List<Case>();
            if(newCase.Id != null){
                createdCase = [Select id,CaseNumber,OwnerId,ContactId from Case where id =: newCase.Id];
                caseNum = createdCase[0].CaseNumber;
            }
            if(!createdCase.isEmpty()){
                Case2Service__c newCreated2Service = new Case2Service__c();
                newCreated2Service.Case__c = createdCase[0].Id;
                newCreated2Service.Service__c = objectList.serviceValue;
                createdCase[0].OwnerId = grp.Id;
                createdCase[0].ContactId = createdContact.Id;
                createdCase[0].AccountId = createdContact.AccountId;
                try{
                    update createdCase;
                    insert newCreated2Service;                    
                }
                catch(exception e){
                    logMessage(e.getMessage(), createdCase[0].Id);
                }
            }
        }   
        return caseNum;
    }
    public static Id getPiaTemplateID(){
        List<cadmus_core__Doc_Config__c> docConfiList = new List<cadmus_core__Doc_Config__c>();
        docConfiList = [Select id,cadmus_core__View_Customer_DocConfig_Id__c from cadmus_core__Doc_Config__c where Name =:Constants.ASSET_TYPE_PIA_TEMPLATE Limit 1];
        if(!docConfiList.isEmpty()){
            Id docConfigIdPIATemplate = docConfiList[0].Id;    
            return docConfigIdPIATemplate;    
        }
        return null;
    }
    public static Id getNewServiceTemplateID(String templateName){         
        List<cadmus_core__Doc_Config__c> docConfiList = new List<cadmus_core__Doc_Config__c>();
        docConfiList = [Select id,cadmus_core__View_Customer_DocConfig_Id__c from cadmus_core__Doc_Config__c where Name =:templateName Limit 1];//Donot add WITH SECURITY_ENFORCED
        if(!docConfiList.isEmpty()){
            Id docConfigIdNewServiceTemplate = docConfiList[0].Id;    
            return docConfigIdNewServiceTemplate;    
        }
        return null;
    }
    public static Id getEnrollReverificationCoverLetter(){         
        List<cadmus_core__Doc_Config__c> docConfiList = new List<cadmus_core__Doc_Config__c>();
        docConfiList = [Select id,cadmus_core__View_Customer_DocConfig_Id__c from cadmus_core__Doc_Config__c where Name =:Constants.ASSET_NAME_ENROLLREV_COVER_LETTER Limit 1];
        if(!docConfiList.isEmpty()){
            Id docConfigIdEnrollReverCL = docConfiList[0].Id;    
            return docConfigIdEnrollReverCL;    
        }
        return null;
    }
    public static String getTemplateDocConfigId(Id docConfigId){         
        List<cadmus_core__Doc_Config__c> docConfiList = new List<cadmus_core__Doc_Config__c>();
        docConfiList = [SELECT cadmus_core__View_Customer_DocConfig_Id__c FROM cadmus_core__Doc_Config__c WHERE id =:docConfigId WITH SECURITY_ENFORCED];
        if(!docConfiList.isEmpty()){
            String templateDocConfigId = docConfiList[0].cadmus_core__View_Customer_DocConfig_Id__c;    
            return templateDocConfigId;    
        }
        return null;
    }
    public static Id getDocConfigRecordId(String customerDocConfigId){         
        List<cadmus_core__Doc_Config__c> docConfiList = new List<cadmus_core__Doc_Config__c>();
        docConfiList = [Select id,cadmus_core__View_Customer_DocConfig_Id__c from cadmus_core__Doc_Config__c where cadmus_core__View_Customer_DocConfig_Id__c =:customerDocConfigId WITH SECURITY_ENFORCED Limit 1];
        if(!docConfiList.isEmpty()){
            Id docConfigRecordId = docConfiList[0].Id;    
            return docConfigRecordId;    
        }
        return null;
    }
    public static void logMessage(String message, String recordId){
        Log_Message__c logMsg = new Log_Message__c();
        logMsg.Exception__c = message;
        logMsg.Record_Id__c = String.valueOf(recordId);
        logMsg.Source__c = 'EntityServiceRequestSharingDisabled';
        logMsg.Date_Time_Logged__c = DateTime.now();
        if(!Test.isRunningTest() && Log_Message__c.SObjectType.getDescribe().isCreateable()){
            insert logMsg;
        }
    }
}