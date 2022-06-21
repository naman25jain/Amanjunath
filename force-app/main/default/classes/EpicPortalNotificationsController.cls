public with sharing class EpicPortalNotificationsController{
    //Method to get the notifications
    @Auraenabled(cacheable=false)
    public static List<EpicPortalNotificationControllerHelper.EpicPortalNotificationWrapper> getNotifications(String entityId, Boolean archivedStatus){
        List<Id> cvCaseIds = new List<Id>();  
        List<EpicPortalNotificationControllerHelper.EpicPortalNotificationWrapper> notificationsWrapper = new List<EpicPortalNotificationControllerHelper.EpicPortalNotificationWrapper>();
        Map<Id,case> epicReportCaseMap = new Map<Id,case>();
        Map<Id, Contact_Association_Type_Staging__c> caseIdCATSMap = new Map<Id, Contact_Association_Type_Staging__c>();
        List<Asset> asstList = new List<Asset>();
        Set<String> statusId = new Set<String>{Constants.ASSET_STATUS_OUTDATED,Constants.ASSET_STATUS_MARKED_FOR_DELETION};
        Map<String,Asset> asstCredMap = new Map<String,Asset>();
        Map<String,Asset> asstTransMap = new Map<String,Asset>();
        for(Case cse : [SELECT Id, Secondary_Parent_Case__c, Document_Type__c, Parent_Case_Internal_Status__c, Contact.Name, Account.Name, ECFMG_ID__c, Recordtype.Name, RecordtypeId, Contactid, EPIC_Report_Received_Date__c, EPIC_Report_Available_Date__c, AccountId, First_Verification_Request_Sent_Date__c, Entity_Name__c, Country_of_Entity__c, Notification_Available_Date__c 
                        FROM Case
                        WHERE Notification_Archived_Status__c =: archivedStatus 
                        AND Entity__c =: entityId 
                        AND RecordTypeId =: Constants.EPICVERREPORTREQRTID 
                        AND Parent_Case_Internal_Status__c = :Constants.CASE_STATUS_SENT_FOR_VERIFICATION
                        WITH SECURITY_ENFORCED ORDER BY Createddate ASC]){
            epicReportCaseMap.put(cse.Id, cse);
            cvCaseIds.add(cse.Secondary_Parent_Case__c);
        }
        asstList = [SELECT Id, Name, Case__c,Type__c,Status,RecordType.DeveloperName, Azure_Storage_URL__c FROM Asset WHERE Status NOT IN:statusId AND Case__c IN : cvCaseIds AND (Type__c = 'Translation' or Name='Credential Request')  WITH SECURITY_ENFORCED];
        for(Asset a: asstList){
            if(a.recordType.DeveloperName == Constants.ASSET_RECORD_TYPE_CREDENTIAL){
             if(a.Name == Constants.ASSET_TYPE_CREDENTIAL_REQUEST){
                 asstCredMap.put(a.Case__c,a);
             }  
             if(a.Type__c == Constants.ASSET_TYPE_TRANSLATION){
                 asstTransMap.put(a.Case__c,a);
                 }
                }               
            }
        If(epicReportCaseMap.size() >0){
            for(Contact_Association_Type_Staging__c catsRcd : [SELECT Id, Attendance_Start_Date__c, Attendance_End_Date__c, Degree_Issue_Date__c, Degree_Title__c, Name_on_Document__c, Case__c 
                                                               FROM Contact_Association_Type_Staging__c WHERE Case__c IN : cvCaseIds
                                                               WITH SECURITY_ENFORCED]){
                caseIdCATSMap.put(catsRcd.Case__c,catsRcd);
            }
            for(Id caseId : epicReportCaseMap.keyset()){
               Asset asstCred=null;
               Asset asstTrans=null;
               if(asstCredMap.containsKey(epicReportCaseMap.get(caseId).Secondary_Parent_Case__c)){
                     asstCred = asstCredMap.get(epicReportCaseMap.get(caseId).Secondary_Parent_Case__c);
                }
                if(asstTransMap.containsKey(epicReportCaseMap.get(caseId).Secondary_Parent_Case__c)){
                    asstTrans = asstTransMap.get(epicReportCaseMap.get(caseId).Secondary_Parent_Case__c);
                }

            
                  notificationsWrapper.add(new EpicPortalNotificationControllerHelper.EpicPortalNotificationWrapper(epicReportCaseMap.get(caseId), caseIdCATSMap.get(epicReportCaseMap.get(caseId).Secondary_Parent_Case__c), asstCred, asstTrans));
            }
        }
        return notificationsWrapper;
    }
    //Method to update the notification field based on Archive and Unarchive action
    @AuraEnabled(cacheable=false)
    public static Boolean updateArchivedStatus(Id caseId, Boolean archivedStatus){
        List<Case> epicCases = new List<Case>();
        if(caseId != null){
            epicCases = [SELECT ID FROM Case WHERE Id=:caseId WITH SECURITY_ENFORCED];
        }        
        if(epicCases.size() > 0){
            Case caseIns = new Case();
            caseIns.Id = epicCases[0].Id;
            caseIns.Notification_Archived_Status__c = archivedStatus;
            if(Schema.sObjectType.Case.isUpdateable()){
                UPDATE caseIns;
            }
            return caseIns.Notification_Archived_Status__c;
        } else{
            return null;
        }        
    }
}