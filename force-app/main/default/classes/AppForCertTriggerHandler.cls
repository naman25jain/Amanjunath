public with sharing class AppForCertTriggerHandler implements CaseTriggerHandlerInterface{
    final String REC_TYPE_APPFORCERT = Constant_Case__mdt.getInstance('REC_TYPE_DEV_APPFORCERT').Value__c;
    final String ASSET_STATUS_REJECTED = Constant_Asset__mdt.getInstance('STATUS_REJECTED').Value__c;
    public void beforeInsert(List<Case> newCases){
        try{
            system.debug('-------APP FOR CERT Before Insert Handler-------');
            for(Case caseIns: newCases){
                //Updates the Case service, Service Line, Service Family fields on case object
                CaseTriggerUtility.updateCaseService(caseIns, REC_TYPE_APPFORCERT);
                 // Updates the Applicant_Last_Submission_Date__c field
                 CaseTriggerUtility.updateCaseRecordDate(caseIns);
                 if(caseIns.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_INCOMPLETE').Value__c){
                    caseIns.Incomplete_Status_Date__c = Date.today();
                 }
                 // Updates standard case status field to closed/not applicable based on internal status
                 CaseTriggerUtility.updateCaseRecordStatusFlag(caseIns);
                 // Updates External Status field for case record
                 CaseTriggerUtility.updateCaseExtStatus(caseIns, new Case());
             }
        }
        catch(Exception ex){
            throw ex;
        }
    }
    public void beforeUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap){
        try{
            system.debug('-------APP FOR CERT Before Update Handler-------');
            for(Case caseIns: newCasesMap.values()){
                Case oldCase = oldCasesMap.get(caseIns.Id);
                if(caseIns.Internal_Status__c != oldCase.Internal_Status__c){
                    // Updates the Applicant_Last_Submission_Date__c field
                    CaseTriggerUtility.updateCaseRecordDate(caseIns);
                    // Updates standard case status field to closed/not applicable based on internal status
                    CaseTriggerUtility.updateCaseRecordStatusFlag(caseIns);
                    // Updates External Status field for case record
                    CaseTriggerUtility.updateCaseExtStatus(caseIns, oldCase);
                }
                if(caseIns.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_INCOMPLETE').Value__c){
                    caseIns.Incomplete_Status_Date__c = Date.today();
                }
                if(caseIns.Internal_Status__c != oldCasesMap.get(caseIns.Id).Internal_Status__c && (caseIns.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_ACCEPTED').Value__c ||
                caseIns.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_REJECTED').Value__c ||
                                caseIns.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_INCOMPLETE').Value__c ||
                                caseIns.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_PENDING_CRED_VER').Value__c)){
                        caseIns.OwnerId = Constants.QUEUE_DEV_ID_MAP.get(Constant_Case__mdt.getInstance('QUEUE_APP_FOR_CERT').Value__c);
                }
            }            
        }
        catch(Exception ex){
            throw ex;
        }
    }
    public void afterInsert(Map<Id,Case> newCasesMap){
        try{
            system.debug('-------APP FOR CERT After Insert Handler-------');
            List<Case> pendingCibisList = new List<Case>();
            for(Case newCase : newCasesMap.values()){
                if(newCase.internal_status__c == Constant_Case__mdt.getInstance('STATUS_PENDING_CIBIS').Value__c){
                    pendingCibisList.add(newCase);
                }
            }
            if(RecursiveTriggerHandler.isFirstTimeCibis && !pendingCibisList.isEmpty()){
                System.debug('calling from after insert app for cert');
                // Invoke CIBIS platform event publish method from utility
                CibisUtility.invokeCibisPlatformEventLogic(pendingCibisList, null);
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }
    public void afterUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap){
        try{
            system.debug('-------APP FOR CERT After Update Handler-------');
            List<Asset> assetListToReject = new List<Asset>();
            // Getiing the instance of CaseTriggerDataInitialize
            CaseTriggerDataInitialize ctData = CaseTriggerDataInitialize.getInstance(new List<Case>(),false);
            // Fetches the stored wrapper data
            CaseTriggerDataInitialize.CaseTriggerDataWrapper ctDataWrap = ctData.fetchData();
            // Fetches Contact Map
            Map<String,Contact> contactMap = (Map<String,Contact>)CaseTriggerDataInitialize.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('CONTACT_REC').Value__c);
            // Fetches the stored SOQL for Org wide email address
            Map<String,sObject> orgWideEmailAddRec = GetCommonQueries.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('ORGWIDEEMAILADD').Value__c);
            // Obtains org wide email address
            OrgWideEmailAddress addr = (OrgWideEmailAddress)orgWideEmailAddRec.get(Constant_other__mdt.getInstance('ORG_WIDE_ADDRESS').Value__c);
            // Fetches the stored SOQL for Email Template
            Map<String,sObject> emailTemplate = GetCommonQueries.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('EMAIL_TEMPLATE').Value__c);
            // Obtains email template for AppforCert
            EmailTemplate emailTempRec = (EmailTemplate)emailTemplate.get(Constant_Case__mdt.getInstance('EMAIL_TEMPLATE_STATUS_UPDATE').Value__c);
            // Fetches the asset records
            Map<String,List<sObject>> caseAssetMap = CaseTriggerDataInitialize.fetchGenericDataSObjectList(Constant_Data_Key__mdt.getInstance('ASSET_REC_CASE').Value__c);
            // List of assets to be updated
            List<Asset> updAssetList = new List<Asset>();
            if(RecursiveTriggerHandler.isFirstTimeCibis){
                System.debug('calling from after update app for cert');
                // Invoke CIBIS platform event publish method from utility
                CibisUtility.invokeCibisPlatformEventLogic(newCasesMap.values(),oldCasesMap);
            }
            for(Case newCase : newCasesMap.values()){
                if(newCase.internal_status__c != (oldCasesMap.get(newCase.Id)).internal_status__c
                && String.isNotBlank(newCase.ContactEmail)
                && (newCase.internal_status__c == Constant_Case__mdt.getInstance('STATUS_ACCEPTED').Value__c
                || newCase.internal_status__c == Constant_Case__mdt.getInstance('STATUS_REJECTED').Value__c)){
                    CaseTriggerUtility.SendMailWrapper sendMailWrap = new CaseTriggerUtility.SendMailWrapper();
                    sendMailWrap.caseRec = newCase;
                    sendMailWrap.addr = addr;
                    sendMailWrap.emailTemplate = emailTempRec;
                    sendMailWrap.con = (Contact)contactMap.get(newCase.contactId);
                    Messaging.SingleEmailMessage message = CaseTriggerUtility.sendCaseStatusMail(sendMailWrap);
                    ctDataWrap.sendEmail.add(message);
                }
                if(newCase.internal_status__c != (oldCasesMap.get(newCase.Id)).internal_status__c && newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_REJECTED').Value__c && caseAssetMap.containsKey(newCase.Id)){
                    assetListToReject   = caseAssetMap.get(newCase.Id);
                    updAssetList.addAll(updateAppforcertAssets(assetListToReject));
                }
                if(contactMap.containsKey(newCase.ContactId) && contactMap.get(newCase.ContactId).USMLE_ID__c == null){
                    CaseTriggerHelper.generateUsmleId(newCase, oldCasesMap.get(newCase.Id));
                }
            }
            if(!updAssetList.isEmpty() && GenericUtilities.checkIsUpdatable('Asset')){
                CaseTriggerUtility.updateDMLMap(updAssetList);
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }
    //to update all related assets of appforcert case to rejected when the case is rejected
    public List<Asset> updateAppforcertAssets(List<Asset> assetListToReject){
        try{
            List<Asset> assetList = new List<Asset>();
            if(!assetListToReject.isEmpty()){            
                for(Asset assetIns:assetListToReject){
                    if(assetIns.Status != ASSET_STATUS_REJECTED || assetIns.Status != Constant_Asset__mdt.getInstance('STATUS_CANCELLED').Value__c){
                        assetIns.status = ASSET_STATUS_REJECTED;
                        assetList.add(new Asset(Id = assetIns.Id, status = ASSET_STATUS_REJECTED));
                    }                
                }            
            }
            return assetList;
        }
        catch(Exception ex){
            throw ex;
        }
    }
}