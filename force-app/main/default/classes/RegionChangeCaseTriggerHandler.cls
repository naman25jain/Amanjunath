public class RegionChangeCaseTriggerHandler implements CaseTriggerHandlerInterface{
    
    public void beforeInsert(List<Case> newCases){
        for(Case newCase : newCases){
            // Updates Case Service
            CaseTriggerUtility.updateCaseService(newCase,Constant_Case__mdt.getInstance('REC_TYPE_DEV_REGION_CHANGE').Value__c);
            // Updates the Applicant_Last_Submission_Date__c field
            CaseTriggerUtility.updateCaseRecordDate(newCase);
            // Updates standard case status field to closed/not applicable based on internal status
            CaseTriggerUtility.updateCaseRecordStatusFlag(newCase);
            // Updates External Status
            CaseTriggerUtility.updateCaseExtStatus(newCase, null);
        }
    }
    public void beforeUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap){
        for(Case newCase : newCasesMap.values()){
            // Updates the Applicant_Last_Submission_Date__c field
            CaseTriggerUtility.updateCaseRecordDate(newCase);
            // Updates standard case status field to closed/not applicable based on internal status
            CaseTriggerUtility.updateCaseRecordStatusFlag(newCase);
            // Updates External Status
            CaseTriggerUtility.updateCaseExtStatus(newCase, oldCasesMap.get(newCase.Id));
        }
    }
    public void afterInsert(Map<Id,Case> newCasesMap){
        List<Case> newCibisCases = new List<Case>();
        try {
            for(Case newCase : newCasesMap.values()){
                if(newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_PENDING_CIBIS').Value__c){
                    newCibisCases.add(newCase);
                }
            }
            if(RecursiveTriggerHandler.isFirstTimeCibis && !newCibisCases.isEmpty()){ 
                CibisUtility.invokeCibisPlatformEventLogic(newCibisCases, null);
            }  
        } catch (Exception e){
            throw e;    
        }
    }
    public void afterUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap){
        try{
            // Getiing the instance of CaseTriggerDataInitialize
            CaseTriggerDataInitialize ctData = CaseTriggerDataInitialize.getInstance(new List<Case>(), false);
            // Fetches the stored wrapper data
            CaseTriggerDataInitialize.CaseTriggerDataWrapper ctDataWrap = ctData.fetchData();
            // Fetches the stored SOQL for Org wide email address
            Map<String,sObject> orgWideEmailAddRec = GetCommonQueries.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('ORGWIDEEMAILADD').Value__c);
            // Fetches the stored SOQL for Email Template
            Map<String,sObject> emailTemplate = GetCommonQueries.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('EMAIL_TEMPLATE').Value__c);
            // Fetches the stored SOQL for Contact
            Map<String,sObject> contactMap = CaseTriggerDataInitialize.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('CONTACT_REC').Value__c);
            // Fetches the static resource email permit for attaching file
            Map<String,sObject> staticResourceMap = GetCommonQueries.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('STATICRESOURCE').Value__c);
            // Fetches the Asset records
            Map<String,List<sObject>> assetRecList = CaseTriggerDataInitialize.fetchGenericDataSObjectList(Constant_Data_Key__mdt.getInstance('ASSET_REC_CASE').Value__c);
            // Obtains org wide email address
            OrgWideEmailAddress addr = (OrgWideEmailAddress)orgWideEmailAddRec.get(Constant_other__mdt.getInstance('ORG_WIDE_ADDRESS').Value__c);
            // Obtains email template
            EmailTemplate emailTempRec = (EmailTemplate)emailTemplate.get(Constant_Case__mdt.getInstance('EMAIL_TEMPLATE_STATUS_UPDATE').Value__c);
            // Obtains the Static resource record.
            StaticResource staticResc = ((StaticResource)staticResourceMap.get(Constant_other__mdt.getInstance('STATIC_RESOURCE_EXAM_PERMIT').Value__c));
            //to store asset records to be inserted
            List<Asset> assetRecsIn = new List<Asset>();
            //to store asset records to be updated
            List<Asset> assetsToUpdate = new List<Asset>();
            //Loop through each record
            for(Case newCase : newCasesMap.values()){
                if(newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_ACCEPTED').Value__c && oldCasesMap.get(newCase.Id).Internal_Status__c != newCase.Internal_Status__c){   
                    //for email sending
                    CaseTriggerUtility.SendMailWrapper sendMailWrap = new CaseTriggerUtility.SendMailWrapper();
                    sendMailWrap.caseRec = newCase;
                    sendMailWrap.addr = addr;
                    sendMailWrap.emailTemplate = emailTempRec;
                    sendMailWrap.con = (Contact)contactMap.get(newCase.contactId);
                    Messaging.SingleEmailMessage message = CaseTriggerUtility.sendCaseStatusMail(sendMailWrap);
                    CaseTriggerUtility.attachFiletoEmail(message,staticResc.Body,Constant_Asset__mdt.getInstance('TYPE_SCHEDULING_PERMIT').Value__c);
                    ctDataWrap.sendEmail.add(message);
                    //to create asset
                    //Content version and Content document link will be created in AssetTrigger
                    assetRecsIn.add(CaseTriggerUtility.createAsset(newCase, newCase.ParentId, Constant_Asset__mdt.getInstance('TYPE_SCHEDULING_PERMIT').Value__c));
                    if(assetRecList.containsKey(newCase.Id)){
                        //to mark the existing assets as outdated
                        assetsToUpdate.addAll(CaseTriggerUtility.updateAsset(assetRecList.get(newCase.Id)));
                    }
                }
            }
            if(!assetRecsIn.isEmpty() && GenericUtilities.checkIsCreatable('Asset')){
                CaseTriggerUtility.insertDML(assetRecsIn);
            }
            if(!assetsToUpdate.isEmpty() && GenericUtilities.checkIsUpdatable('Asset')){
                CaseTriggerUtility.updateDMLMap(assetsToUpdate);
            }
            if(RecursiveTriggerHandler.isFirstTimeCibis){
                //Invoke CIBIS platform event publish method from utility
                CibisUtility.invokeCibisPlatformEventLogic(newCasesMap.values(),oldCasesMap);
                //CibisRegChangeGenReqHandler.constructPayload method is called from invokeCibisPlatformEventLogic;
            }
        } catch(Exception ex){
            throw ex;
        }
    }
}