public with sharing class EpicReportsController{
    
    @AuraEnabled(cacheable=false)
    public static List<Case> getEpicCases(Id parentEntityId, Boolean archivedStatus){
        Set<Id> entityIds = new Set<Id>();
        List<Account> accountList = new List<Account>();
        List<Case> epicCases = new List<Case>();
        Id epicVeriReportReq = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_VER_REPORT_REQUEST).getRecordTypeId();
        
        if(parentEntityId != null){
            entityIds.add(parentEntityId);
            accountList = [SELECT Id FROM Account WHERE Parent_Authority__c =:parentEntityId WITH SECURITY_ENFORCED];
        }    
        if(accountList.size() > 0){
            for(Account acc: accountList){
                entityIds.add(acc.Id);
            }
        }        
        if(entityIds.size() > 0){
            epicCases = [SELECT Id,Entity__c,Entity__r.Name,Document_Type__c,Contact.Name,Account.Name,
                                ECFMG_ID__c,Recordtype.Name,RecordtypeId,Contactid,EPIC_Report_Received_Date__c,
                                Reference_Number__c,Entity_External_Status__c,EPIC_Report_Available_Date__c,Createddate, Service__c
                                FROM Case 
                                WHERE EPIC_Report_Archived_Status__c =: archivedStatus 
                                AND Entity__c IN:entityIds AND Recordtypeid =:epicVeriReportReq  
                                AND Internal_Status__c =: Constants.CASE_STATUS_SENT 
                                WITH SECURITY_ENFORCED
                                ORDER BY Entity__r.Name ASC,Createddate ASC];
        }
        return epicCases;
    }
    
    @AuraEnabled(cacheable=false)
    public static Boolean updateEntityExternalStatus(Id caseId){
        List<Case> epicCases = new List<Case>();
        if(caseId != null){
            epicCases = [SELECT ID, Document_Type__c, Contact.Name,Account.Name, ECFMG_ID__c, 
                        Recordtype.Name,Recordtypeid, Reference_Number__c, Entity_External_Status__c, 
                        EPIC_Report_Received_Date__c, EPIC_Report_Available_Date__c, AccountId, Createddate 
                        FROM Case WHERE Id=:caseId WITH SECURITY_ENFORCED];
        }
        if(epicCases.size() > 0){
            if(epicCases[0].Entity_External_Status__c == Constants.CASE_ENTITY_EXTERNAL_STATUS_NOT_REVIWED){
                //UPDATE THE STATUS Reviewed
                epicCases[0].Entity_External_Status__c = Constants.CASE_ENTITY_EXTERNAL_STATUS_REVIWED;
            }
            if(Schema.sObjectType.Case.isUpdateable()){
                UPDATE epicCases;
            }
            return true;
        } else{
            return null;
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static Boolean updateArchivedStatus(Id caseId, Boolean archivedStatus){
        List<Case> epicCases = new List<Case>();
        if(caseId != null){
            epicCases = [SELECT ID, Document_Type__c, Contact.Name,Account.Name, ECFMG_ID__c, 
                        Recordtype.Name,Recordtypeid, Reference_Number__c, Entity_External_Status__c, 
                        EPIC_Report_Received_Date__c, EPIC_Report_Available_Date__c, AccountId, Createddate 
                        FROM Case WHERE Id=:caseId WITH SECURITY_ENFORCED];
        }        
        if(epicCases.size() > 0){
            Case caseIns = new Case();
            caseIns.Id = epicCases[0].Id;
            caseIns.EPIC_Report_Archived_Status__c = archivedStatus;
            if(Schema.sObjectType.Case.isUpdateable()){
                UPDATE caseIns;
            }
            return caseIns.EPIC_Report_Archived_Status__c;
        } else{
            return null;
        }        
    }

    @AuraEnabled(cacheable=false)
    public static String getParentEnityName(Id parentEntityId){
        String entityName = [SELECT Id, Name FROM Account WHERE Id =: parentEntityId WITH SECURITY_ENFORCED].Name;
        return entityName;
    }

    @AuraEnabled(Cacheable = false)
    // Purpose : Method will get the Current User's Contact Id
    public static Id getContact(String userId){
        User uId = [SELECT id, contactId FROM User WHERE id =: userId WITH SECURITY_ENFORCED];
		id getContactId = uId.contactId;
		return getContactId;
    }
}