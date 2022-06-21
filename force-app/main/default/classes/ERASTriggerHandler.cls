public class ERASTriggerHandler implements CaseTriggerHandlerInterface{
    static final String STATUS_PENDING_DOCUMENT_UPLOAD = Constant_Case__mdt.getInstance('STATUS_PENDING_DOCUMENT_UPLOAD').Value__c;
    public void beforeInsert(List<Case> newCases){
        for(Case newCase: newCases){
            CaseTriggerUtility.updateCaseService(newCase,Constant_Case__mdt.getInstance('REC_TYPE_ERAS').Value__c);            
            updateRepeatApplicantonERASCase(newCase);
        }
    }
    public void beforeUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap){
        for(Case newCase: newCasesMap.values()){
            // Updates standard case status field to closed/not applicable based on internal status
            CaseTriggerUtility.updateCaseRecordStatusFlag(newCase);
        }
    }
    public void afterInsert(Map<Id,Case> newCasesMap){}
    public void afterUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap){
        try{
            // Gets the instance of CaseTriggerDataInitialize
            CaseTriggerDataInitialize ctData = CaseTriggerDataInitialize.getInstance(new List<Case>(),false);
            // Fetches the stored wrapper data
            CaseTriggerDataInitialize.CaseTriggerDataWrapper ctDataWrap = ctData.fetchData();
            // Obtains the contact records
            Map<String,sObject> contactMap = CaseTriggerDataInitialize.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('CONTACT_REC').Value__c);
            // fetching prior ERAS cases from CaseTriggerDataInitialize
            Map<String,Map<String,sObject>> erasCasesMap = new Map<String,Map<String,sObject>>();
            if(ctDataWrap.rtKeyrelatedRec.containsKey(Constant_Case__mdt.getInstance('REC_TYPE_ERAS').Value__c)){
                erasCasesMap = ctDataWrap.rtKeyrelatedRec.get(Constant_Case__mdt.getInstance('REC_TYPE_ERAS').Value__c);
            }
            Map<String,sObject> erasCaseMap = new Map<String,sObject>(); 
            if(erasCasesMap.containsKey(Constant_Data_Key__mdt.getInstance('ERAS').Value__c)){
                erasCaseMap = erasCasesMap.get(Constant_Data_Key__mdt.getInstance('ERAS').Value__c);
            }
            Case priorSeasonErasCase = new Case();
            if(!erasCaseMap.isEmpty()){
                for(sObject priorSeasonErasCaseRecord : erasCaseMap.values()){
                    priorSeasonErasCase = (case)priorSeasonErasCaseRecord;
                }
            }
            // Obtains the asset records
            Map<String,List<Asset>> assetMap = new Map<String,List<Asset>>();
            assetMap = CaseTriggerDataInitialize.fetchGenericDataSObjectList(Constant_Data_Key__mdt.getInstance('ASSET_REC_CASE').Value__c);
            // Fetches the stored SOQL for Email Template
            Map<String,sObject> emailTemplate = GetCommonQueries.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('EMAIL_TEMPLATE').Value__c);
            // Fetches the stored SOQL for Org wide email address
            Map<String,sObject> orgWideEmailAddRec = GetCommonQueries.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('ORGWIDEEMAILADD').Value__c);
            // Obtains org wide email address
            OrgWideEmailAddress addr = (OrgWideEmailAddress)orgWideEmailAddRec.get(Constant_other__mdt.getInstance('ORG_WIDE_ADDRESS').Value__c);
            // Obtains email template 
            EmailTemplate emailTempRec = (EmailTemplate)emailTemplate.get(Constant_Case__mdt.getInstance('EMAIL_TEMPLATE_ERAS_STATUS_UPDATE').Value__c);
            List<Asset> newAssetsList = new List<Asset>();
            Set<String> restrictedStatus = new Set<String>{Constant_Asset__mdt.getInstance('STATUS_EXPIRED').Value__c, 
                                                            Constant_Asset__mdt.getInstance('STATUS_REJECTED').Value__c, 
                                                            Constant_Asset__mdt.getInstance('STATUS_CANCELLED').Value__c, 
                                                            Constant_Asset__mdt.getInstance('STATUS_INVALIDATED').Value__c, 
                                                            Constant_Asset__mdt.getInstance('STATUS_OUTDATED').Value__c,
                                                            Constant_Asset__mdt.getInstance('STATUS_NOT_AUTHENTIC').Value__c, 
                                                            Constant_Asset__mdt.getInstance('STATUS_INACTIVE').Value__c, 
                                                            Constant_Asset__mdt.getInstance('ASSET_STATUS_INCOMPLETE').Value__c}; 
            for(Case newCase: newCasesMap.values()){
                // Gets the old case               
                Case oldCase = oldCasesMap.get(newCase.Id);
                if(newCase.OwnerId != oldCase.OwnerId){
                    CaseTriggerUtility.collectCaseShareAcc(new Map<Id,Set<Id>>{newCase.Entity__c=>new Set<Id>{newCase.Id}}, new Map<Id,Set<Id>>(), Constant_other__mdt.getInstance('SERVICE_NAME_ERAS').Value__c);
                }
                if(String.isNotBlank(newCase.ContactId) && newCase.Internal_Status__c != oldCase.Internal_Status__c && oldCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_TOKEN_REQUEST_SUBMITTED').Value__c && newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_TOKEN_GENERATED').Value__c){
                    // Sends email based on internal status change
                    CaseTriggerUtility.SendMailWrapper sendMailWrap = new CaseTriggerUtility.SendMailWrapper();
                    sendMailWrap.caseRec = newCase;
                    sendMailWrap.addr = addr;
                    sendMailWrap.emailTemplate = emailTempRec;
                    sendMailWrap.con = (Contact)contactMap.get(newCase.contactId);
                    Messaging.SingleEmailMessage message = CaseTriggerUtility.sendCaseStatusMail(sendMailWrap);
                    ctDataWrap.sendEmail.add(message);
                }
                if(newCase.Internal_Status__c == STATUS_PENDING_DOCUMENT_UPLOAD && newCase.Internal_Status__c != oldCase.Internal_Status__c && newCase.Repeat_Applicant__c){                                            
                    if(!assetMap.isEmpty()){
                        for(asset asst : assetMap.get(priorSeasonErasCase.Id)){
                            if(((asst.ParentId != NULL && asst.Name != Constant_Asset__mdt.getInstance('NAME_ERAS_PHOTO').Value__c) || (asst.Name == Constant_Asset__mdt.getInstance('NAME_ERAS_PHOTO').Value__c)) && 
                            asst.Case__c == priorSeasonErasCase.Id && !restrictedStatus.contains(asst.Status)){
                                Asset newAsset = new Asset();
                                newAsset.Name = asst.Name;
                                newAsset.Type__c = asst.Type__c;
                                newAsset.Status = Constant_Asset__mdt.getInstance('STATUS_NEW').Value__c;
                                newAsset.RecordTypeId = asst.RecordTypeId;
                                newAsset.ContactId = asst.ContactId;
                                newAsset.Azure_Storage_URL__c = asst.Azure_Storage_URL__c;
                                newAsset.Parent_Case__c = null;
                                newAsset.case__c = newCase.Id;
                                newAssetsList.add(newAsset);	
                            }
                        }
                    }
                }
            }            
            if(!newAssetsList.isEmpty() && GenericUtilities.checkIsUpdatable('Asset')){
                CaseTriggerUtility.insertDML(newAssetsList);
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }
    //Method to update Repeat Applicant field on ERAS Case
    private static void updateRepeatApplicantonERASCase(Case newSeasonErasCase){
        try{       
            // Gets the instance of CaseTriggerDataInitialize
            CaseTriggerDataInitialize ctData = CaseTriggerDataInitialize.getInstance(new List<Case>(),false);
            // Fetches the stored wrapper data
            CaseTriggerDataInitialize.CaseTriggerDataWrapper ctDataWrap = ctData.fetchData();
            // fetching prior ERAS cases from CaseTriggerDataInitialize
            Map<String,Map<String,sObject>> previousCaseMap = new Map<String,Map<String,sObject>>();
            if(ctDataWrap.rtKeyrelatedRec.containsKey(Constant_Case__mdt.getInstance('REC_TYPE_ERAS').Value__c)){
                previousCaseMap = ctDataWrap.rtKeyrelatedRec.get(Constant_Case__mdt.getInstance('REC_TYPE_ERAS').Value__c);
            }
            // retrieving the active ERAS eligibility period
            Map<String,List<Eligibility_Period__c>> erasEligibilityPeriodMap = CaseTriggerDataInitialize.fetchGenericDataSObjectList(Constant_Data_Key__mdt.getInstance('ERAS_ELIGIBILITY_PERIOD').Value__c);                        
            String earlierSeasonId;
            Date todayDate = Date.Today();
            String yr = String.valueOf(todayDate.year()+1);
            String seasonName = 'ERAS '+ yr;
            List<Eligibility_Period__c> epList = new List<Eligibility_Period__c>();
            if(!erasEligibilityPeriodMap.isEmpty()){
                epList = erasEligibilityPeriodMap.get(seasonName);
            }
            if(!epList.isEmpty()){
                earlierSeasonId = epList[0].Earlier_Season_Id__c;
            }
            Map<String,sObject> priorSeasonErasCaseMap = new Map<String,sObject>();
            if(!previousCaseMap.isEmpty()){
                priorSeasonErasCaseMap = previousCaseMap.get(Constant_Data_Key__mdt.getInstance('ERAS').Value__c);
            }
            if(!priorSeasonErasCaseMap.isEmpty()){
                for(sObject priorSeasonErasCaseRecord : priorSeasonErasCaseMap.values()){
                    Case priorSeasonErasCase = (case)priorSeasonErasCaseRecord;
                    if(earlierSeasonId != '' && earlierSeasonId != NULL){
                        if(priorSeasonErasCase.Eligibility_Period__c == earlierSeasonId){
                            newSeasonErasCase.Repeat_Applicant__c = true;
                        }
                    }   
                } 
            }                                                  
        }catch(Exception ex){
            throw ex;
        }
    }
}