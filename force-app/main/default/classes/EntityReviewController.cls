public with sharing class EntityReviewController{
    //Method to get the fields from case related CATS record
    @AuraEnabled(Cacheable = false)
    public static EntityCatStagWrapper getEntityFields(Id caseId){
        Case currCase = [SELECT Id, ContactId, ParentId, Alternate_Entity__c,Alternate_Entity__r.Internal_Instructions__c, Alternate_Entity__r.External_Instructions__c,Alternate_Entity__r.Name, Document_Type__c FROM Case WHERE Id=:caseId WITH SECURITY_ENFORCED];
        EntityCatStagWrapper returnWrap = new EntityCatStagWrapper();
         if(currCase.ParentId!=null){
        Case checkRecord = [SELECT Id, ContactId, ParentId, RecordTypeId FROM Case WHERE Id=:currCase.ParentId WITH SECURITY_ENFORCED];
        if(checkRecord.RecordTypeId== Constants.ECFMG_CERTIFICATE_RDTYPEID){
        Set<String> statusId = new Set<String>{Constants.CASE_DOC_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT,Constants.CASE_DOC_TYPE_FINAL_MED_DIPLOMA, Constants.ASSET_TYPE_TCT};
        Asset assetList =[SELECT Id, Contact_Association_Type__c FROM Asset WHERE Case__c =: caseId AND ContactId =:currCase.ContactId AND Type__c IN:statusId WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1];
        List<Contact_Association_Type__c> catRec = new List<Contact_Association_Type__c>();
        catRec = [Select Id, Account__c, Account__r.Internal_Instructions__c, Account__r.Name, Account__r.RecordType.Name, Account__r.External_Instructions__c, Account__r.Parent_Entity__r.Name, Account__r.Parent_Entity__c, Account__r.Country__c, Credential_Type__c From Contact_Association_Type__c Where Contact__c =: currCase.ContactId AND Id=: assetList.Contact_Association_Type__c WITH SECURITY_ENFORCED];
            if(!catRec.isEmpty()){
            returnWrap.key= catRec[0].Id;
            returnWrap.accountId= catRec[0].Account__r.Id;
            returnWrap.accName= catRec[0].Account__r.Name;
            returnWrap.intInst = catRec[0].Account__r.Internal_Instructions__c;
            returnWrap.extInst = catRec[0].Account__r.External_Instructions__c;
            returnWrap.accCountry= catRec[0].Account__r.Country__c;
            returnWrap.accParentEnt= catRec[0].Account__r.Parent_Entity__c;
            returnWrap.accParentEntName= catRec[0].Account__r.Parent_Entity__r.Name;
            returnWrap.accRecordTypeName= catRec[0].Account__r.RecordType.Name;
            returnWrap.altEntity= currCase.Alternate_Entity__c;
            returnWrap.altEntityName= currCase.Alternate_Entity__r.Name;
            returnWrap.altIntInst= currCase.Alternate_Entity__r.Internal_Instructions__c;
            returnWrap.altExtInst= currCase.Alternate_Entity__r.External_Instructions__c;
            returnWrap.credType= catRec[0].Credential_Type__c; 
          }
        }
             else{
             Contact_Association_Type_Staging__c catsRec = new Contact_Association_Type_Staging__c();
             catsRec = [Select Id, Account__c, Alternate_Entity__c, Account__r.Internal_Instructions__c, Account__r.Name, Account__r.RecordType.Name,
             Account__r.External_Instructions__c, Alternate_Entity__r.Internal_Instructions__c, Alternate_Entity__r.External_Instructions__c,
             Account__r.Parent_Entity__r.Name, Account__r.Parent_Entity__c, Account__r.Country__c, Credential_Type__c, Alternate_Entity__r.Name From Contact_Association_Type_Staging__c Where Case__c=:caseId WITH SECURITY_ENFORCED];
             returnWrap.key= catsRec.Id;
             returnWrap.accountId= catsRec.Account__r.Id;
             returnWrap.accName= catsRec.Account__r.Name;
             returnWrap.intInst = catsRec.Account__r.Internal_Instructions__c;
             returnWrap.extInst = catsRec.Account__r.External_Instructions__c;
             returnWrap.accCountry= catsRec.Account__r.Country__c;
             returnWrap.accParentEnt= catsRec.Account__r.Parent_Entity__c;
             returnWrap.accParentEntName= catsRec.Account__r.Parent_Entity__r.Name;
             returnWrap.accRecordTypeName= catsRec.Account__r.RecordType.Name;
             returnWrap.altEntity= catsRec.Alternate_Entity__c;
             returnWrap.altEntityName= catsRec.Alternate_Entity__r.Name;
             returnWrap.altIntInst= catsRec.Alternate_Entity__r.Internal_Instructions__c;
             returnWrap.altExtInst= catsRec.Alternate_Entity__r.External_Instructions__c;
             returnWrap.credType= catsRec.Credential_Type__c;
             }
        }
        else{
        Contact_Association_Type_Staging__c catsRec = new Contact_Association_Type_Staging__c();
        catsRec = [Select Id, Account__c, Alternate_Entity__c, Account__r.Internal_Instructions__c, Account__r.Name, Account__r.RecordType.Name,
        Account__r.External_Instructions__c, Alternate_Entity__r.Internal_Instructions__c, Alternate_Entity__r.External_Instructions__c,
        Account__r.Parent_Entity__r.Name, Account__r.Parent_Entity__c, Account__r.Country__c, Credential_Type__c, Alternate_Entity__r.Name
        From Contact_Association_Type_Staging__c
        Where Case__c=:caseId WITH SECURITY_ENFORCED];
        returnWrap.key= catsRec.Id;
        returnWrap.accountId= catsRec.Account__r.Id;
        returnWrap.accName= catsRec.Account__r.Name;
        returnWrap.intInst = catsRec.Account__r.Internal_Instructions__c;
        returnWrap.extInst = catsRec.Account__r.External_Instructions__c;
        returnWrap.accCountry= catsRec.Account__r.Country__c;
        returnWrap.accParentEnt= catsRec.Account__r.Parent_Entity__c;
        returnWrap.accParentEntName= catsRec.Account__r.Parent_Entity__r.Name;
        returnWrap.accRecordTypeName= catsRec.Account__r.RecordType.Name;
        returnWrap.altEntity= catsRec.Alternate_Entity__c;
        returnWrap.altEntityName= catsRec.Alternate_Entity__r.Name;
        returnWrap.altIntInst= catsRec.Alternate_Entity__r.Internal_Instructions__c;
        returnWrap.altExtInst= catsRec.Alternate_Entity__r.External_Instructions__c;
        returnWrap.credType= catsRec.Credential_Type__c;
        }
        return returnWrap;
    }
    public class EntityCatStagWrapper{
        @AuraEnabled public Id key;
        @AuraEnabled public Id accountId;
        @AuraEnabled public String accName;
        @AuraEnabled public String intInst;
        @AuraEnabled public String extInst;
        @AuraEnabled public String accCountry;
        @AuraEnabled public String accParentEnt;
        @AuraEnabled public String accParentEntName;
        @AuraEnabled public String accRecordTypeName;
        @AuraEnabled public String altEntity;
        @AuraEnabled public String altEntityName;
        @AuraEnabled public String altIntInst;
        @AuraEnabled public String altExtInst;  
        @AuraEnabled public String credType;

    }
    //get entity details from the Case record for the given caseid.
    @AuraEnabled(Cacheable = false)
    public static Case getEntityFieldsCase(Id caseId){
        Case caseRec = new Case();
        caseRec = [Select Id, Entity__c, Alternate_Entity__c, Entity__r.Internal_Instructions__c, Entity__r.Name,
        Entity__r.External_Instructions__c, Alternate_Entity__r.Internal_Instructions__c, Alternate_Entity__r.External_Instructions__c,
        Entity__r.Parent_Entity__r.Name, Entity__r.Country__c, Document_Type__c, Alternate_Entity__r.Name
        From Case
        Where Id=:caseId WITH SECURITY_ENFORCED];
        return caseRec;
    }
    //Method to get authority 
    @AuraEnabled(Cacheable = true)
    public static Case getAuthority(Id caseId){
        Case epVer = new Case();
        epVer = [Select Id, Entity__c, Entity__r.Name, Entity__r.EPIC_Client_Special_Instructions_Languag__c from Case where Secondary_Parent_Case__c =: caseId WITH SECURITY_ENFORCED];
        return epVer;
    }
    //Method to get special instruction of the authority
    @AuraEnabled(Cacheable = true)
    public static String getSpecInstruction(Id accId){ 
        Account acc = new Account();
        acc = [Select Id, EPIC_Client_Special_Instructions_Languag__c from Account where Id=:accId WITH SECURITY_ENFORCED];
        String specInst = acc.EPIC_Client_Special_Instructions_Languag__c;
        return specInst;
    }
    //Method to get the country instructions based on country 
    @AuraEnabled(Cacheable = false)
    public static String getCountryInst(String countryName){
        String returnVal = '';
        List<Country_Instructions__mdt> countryInst = new List<Country_Instructions__mdt>();
        if(countryName != ''){
            countryInst = [SELECT Id, Instructions__c From Country_Instructions__mdt WHERE Country_Name__c=:countryName WITH SECURITY_ENFORCED];
            if(!countryInst.isEmpty()){
                returnVal = countryInst[0].Instructions__c;
            }            
        }        
        return returnVal;
    }
    //Method to get all the entities
    @AuraEnabled(Cacheable = true)
    public static List<Account> getActiveEntities(){
        List<Account> accts= new List<Account>();
        Id entityRecId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_ENTITY).getRecordTypeId();
        Id unapprovedEntityrecId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_UNAPPROVED_ENTITY).getRecordTypeId();
        accts = [Select Id, Name from Account where RecordTypeId=:entityRecId OR RecordTypeId=:unapprovedEntityrecId WITH SECURITY_ENFORCED];
        return accts;
    }
    //Method to get case fields
    @AuraEnabled(cacheable = false)
    public static Case getCaseDetails(Id caseId){
        Case newCase = new Case();
        newCase = [SELECT Id, ContactId, Service__c, Contact.Name, Send_Method__c, Entity__c, Alternate_Entity__c, Document_Type__c, recordType.DeveloperName FROM Case WHERE Id=:caseId WITH SECURITY_ENFORCED];
        return newCase;
    }
    //Method to get Asset fields
    @AuraEnabled(cacheable = false)
    public static Asset getAsset(Id caseId){
        Asset asst = new Asset();
        asst = [Select id,Name_on_Document__c from Asset where Case__c=:caseId AND Status=:Constants.ASSET_STATUS_IN_PROGRESS AND ParentId=Null WITH SECURITY_ENFORCED Limit 1];
        return asst;
    }
    //Method to update the entity fields on CATS and Case record
    @AuraEnabled(Cacheable = false)
    public static Boolean updateEntityValues(String catsId, String entId, String altentId){
        Contact_Association_Type_Staging__c catRec = new Contact_Association_Type_Staging__c();
        catRec = [Select Id, Account__c, Alternate_Entity__c, Case__c from Contact_Association_Type_Staging__c where Id=:catsId WITH SECURITY_ENFORCED Limit 1];
        catRec.Account__c = entId;
        catRec.Alternate_Entity__c = altentId;
        Id credCaseId = catRec.Case__c;
        Case credCase = new Case();
        credCase = [Select Id, Entity__c from Case where Id=:credCaseId WITH SECURITY_ENFORCED];
        credCase.Entity__c = entId;
        credCase.Alternate_Entity__c = altentId;
        if(Schema.sObjectType.Contact_Association_Type_Staging__c.isUpdateable() && catRec.Id!=null){
            update catRec;
        }
        if(Schema.sObjectType.Case.isUpdateable() && credCase.Id!=null){
            update credCase;
        }
        return true;  
    }
    //Method to update the entity fields on Case record
    @AuraEnabled(Cacheable = false)
    public static Boolean updateEntityValuesCaseRec(String caseId, String entId, String altentId){
        Case credCase = new Case();
        credCase = [Select Id, Entity__c from Case where Id=:caseId WITH SECURITY_ENFORCED];
        credCase.Entity__c = entId;
        credCase.Alternate_Entity__c = altentId;
        if(Schema.sObjectType.Case.isUpdateable() && credCase.Id!=null){
            update credCase;
        }
        return true;  
    }
     //method to update the Asset object NOD field 
    @AuraEnabled(Cacheable = false)
    public static Boolean updateAssetNOD(String asstId,String nameOnDoc){ 
        Asset upasst = new Asset();
        upasst.Id = asstId;
        upasst.Name_On_Document__c = nameOnDoc;
        Boolean updateasst = false;
        if(Schema.sObjectType.Asset.isUpdateable() && upasst.Id!=null){
            update upasst;
            updateasst = true;
        }
        return updateasst;
    }
    //Method to get the Default Send Method
    @AuraEnabled(Cacheable = true)
    public static String getDefaultSendMethod(Id caseId){
        Case caseRecord = getCaseDetails(caseId);        
        String entityId = caseRecord.Entity__c;
        String alternateEntityId = caseRecord.Alternate_Entity__c;
        String documentType = caseRecord.Document_Type__c;
        String caseRecordTypeDevName = caseRecord.recordType.DeveloperName;
        String actualEntityId = entityId;  
        String affirRecTypeDevName = '';
        String serviceName = '';
        if(caseRecordTypeDevName == Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION){
            serviceName = Constants.SERVICE_NAME_CREDENTIAL_VERIFICATION;
            affirRecTypeDevName = Constants.AFFIRMATION_RECORD_TYPE_CREDENTIAL_VERIFICATION;
        }else if(caseRecordTypeDevName == Constants.CASE_RECORD_TYPE_MED_EDU_FORM){
            serviceName = Constants.SERVICE_NAME_MEDICAL_EDU_FORM;
            affirRecTypeDevName = Constants.AFFIRMATION_RECORD_TYPE_MED_EDU_FORM;
        }
        LIST<Affirmation__c> credVerAffirmationsList = [SELECT Id, Verify_with_Alternate_Entity__c FROM Affirmation__c WHERE recordType.DeveloperName =: affirRecTypeDevName AND Case__c =: caseId AND Verify_with_Alternate_Entity__c = true WITH SECURITY_ENFORCED ORDER BY LastModifiedDate DESC];
        if(alternateEntityId != null && !credVerAffirmationsList.isEmpty()){
            actualEntityId = alternateEntityId;
        }
        return getDefSendMethod(documentType,actualEntityId,serviceName);
    }
    public static String getDefSendMethod(String documentType,Id actualEntityId,String serviceName){
        String defaultSendMethod = Constants.SEND_METHOD_PAPER;
        LIST<Account2Service__c> acc2serList = [SELECT Id, Account__c, Service__c, Active__c FROM Account2Service__c WHERE Account__c =: actualEntityId AND Service__r.Name =: serviceName WITH SECURITY_ENFORCED ORDER BY CreatedDate ASC];
        if(!acc2serList.isEmpty()){
            if(acc2serList[0].Active__c){
                defaultSendMethod = Constants.SEND_METHOD_ENTITY_PORTAL;
            }else{
                String accountServiceId = acc2serList[0].Id;
                LIST<CONTACT2ACCTSERVICE__c> cntct2serList = [SELECT Id, Preferred_mode_of_communication__c FROM CONTACT2ACCTSERVICE__c WHERE Account_Service__c =: accountServiceId AND Credential_Type__c =: documentType WITH SECURITY_ENFORCED ORDER BY CreatedDate ASC];
                if(!cntct2serList.isEmpty()){
                    defaultSendMethod = cntct2serList[0].Preferred_mode_of_communication__c;
                    if(defaultSendMethod == null){
                        defaultSendMethod = Constants.SEND_METHOD_PAPER;
                    }
                }
            }
        }
        return defaultSendMethod;
    }
    //Method to get the AKA Names of an Entity
    @AuraEnabled(Cacheable = true)
    public static List<string> getAKANames(Id entityId){
        List<String> akaNameList = new List<String>();
        List<aka_Names__c> akaNames = [Select Id, Name, Year_From__c, Year_To__c from aka_Names__c where Account__c=:entityId WITH SECURITY_ENFORCED];
        for(aka_Names__c aka:akaNames){
            if(aka.Year_From__c != null && aka.Year_To__c != null){
                akaNameList.add(aka.Name+'(From '+aka.Year_From__c+' to '+aka.Year_To__c+') ');
            }
            else{
                akaNameList.add(aka.Name +' ');
            }
        }
        return akaNameList;
    }
}