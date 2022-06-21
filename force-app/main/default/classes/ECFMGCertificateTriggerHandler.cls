public with sharing class ECFMGCertificateTriggerHandler implements CaseTriggerHandlerInterface{
    final String REC_TYPE_ECFMG_CERT = Constant_Case__mdt.getInstance('REC_TYPE_ECFMG_CERTIFICATION').Value__c;
    public void beforeInsert(List<Case> newCases){
        for(Case newcase: newCases){
            // Updates the Applicant_Last_Submission_Date__c field
            CaseTriggerUtility.updateCaseRecordDate(newcase);
            // Updates standard case status field to closed/not applicable based on internal status
            CaseTriggerUtility.updateCaseRecordStatusFlag(newcase);
            // Updates Case Service
            CaseTriggerUtility.updateCaseService(newCase,REC_TYPE_ECFMG_CERT);
            //Updates External Status field for case record
            CaseTriggerUtility.updateCaseExtStatus(newcase, null);
        }
    }
    public void beforeUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap){
        system.debug('-------ECFMG CERT Before Update Handler-------');
        for(Case newcase: newCasesMap.values()){
            Case oldCase = oldCasesMap.get(newCase.Id);
            Boolean isIntStatusChanged = (newCase.Internal_Status__c != oldCase.Internal_Status__c);
            if(isIntStatusChanged){
                // Updates the Applicant_Last_Submission_Date__c field
                CaseTriggerUtility.updateCaseRecordDate(newcase);
                // Updates standard case status field to closed/not applicable based on internal status
                CaseTriggerUtility.updateCaseRecordStatusFlag(newcase);
                // Updates External Status field for case record
                CaseTriggerUtility.updateCaseExtStatus(newcase, oldCase);
            }
        }
    }
    public void afterInsert(Map<Id,Case> newCasesMap){}
    public void afterUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap){
        try{
            // Getiing the instance of CaseTriggerDataInitialize
            CaseTriggerDataInitialize ctData = CaseTriggerDataInitialize.getInstance(new List<Case>(),false);
            // Fetches the stored wrapper data
            CaseTriggerDataInitialize.CaseTriggerDataWrapper ctDataWrap = ctData.fetchData();
            // Fetches the stored SOQL for Org wide email address
            Map<String,sObject> orgWideEmailAddRec = GetCommonQueries.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('ORGWIDEEMAILADD').Value__c);
            // Obtains org wide email address
            OrgWideEmailAddress addr = (OrgWideEmailAddress)orgWideEmailAddRec.get(Constant_other__mdt.getInstance('ORG_WIDE_ADDRESS').Value__c);
            // Fetches the stored SOQL for Email Template
            Map<String,sObject> emailTemplate = GetCommonQueries.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('EMAIL_TEMPLATE').Value__c);
            // Obtains email template ECFMG Certificate
            EmailTemplate emailTempRec = (EmailTemplate)emailTemplate.get(Constant_Case__mdt.getInstance('EMAIL_TEMPLATE_ECFMG_CERTIFICATE').Value__c);
            // Fetches Contact Map
            Map<String,Contact> contactMap = (Map<String,Contact>)CaseTriggerDataInitialize.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('CONTACT_REC').Value__c);
            //Store the Medical Education QueueId
            Id medEduFormQueueId = Constants.QUEUE_DEV_ID_MAP.get(Constant_Case__mdt.getInstance('QUEUE_MED_EDU_FORM').Value__c);
            // Stores the contact Id and the corresponding list of CAT records.
            Map<String,List<Contact_Association_Type__c>> conCATMap = (Map<String,List<Contact_Association_Type__c>>)CaseTriggerDataInitialize.fetchGenericDataSObjectList(Constant_Data_Key__mdt.getInstance('CAT_CONTACT').Value__c);
            //Collect Medical education cases to insert
            List<case> recordsToInsert = new List<case>();
            //Map to fetch doc config data
            Map<String, cadmus_core__Doc_Config__c> docConfigMap = CaseTriggerUtility.populateDocConfig();
            // fetches the Id of DOC CONFIG ECFMG CERTIFICATE
            Id docConfigId = docConfigMap.get(Constant_PDF_Butler__mdt.getInstance('ECFMG_CERT').Value__c).Id;
            Id medEduFormId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_MED_EDU_FORM').Value__c);
            for(Case newCase: newCasesMap.values()){
                Case oldCase = oldCasesMap.get(newCase.Id);
                Boolean isIntStatusChanged = (newCase.Internal_Status__c != oldCase.Internal_Status__c);
                if(String.isNotBlank(newCase.ContactId)
                   && (isIntStatusChanged && newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_SENT').Value__c)){
                       CaseTriggerUtility.SendMailWrapper sendMailWrap = new CaseTriggerUtility.SendMailWrapper();
                       sendMailWrap.caseRec = newCase;
                       sendMailWrap.addr = addr;
                       sendMailWrap.emailTemplate = emailTempRec;
                       sendMailWrap.con = (Contact)contactMap.get(newCase.contactId);
                       Messaging.SingleEmailMessage message = CaseTriggerUtility.sendCaseStatusTextMail(sendMailWrap);
                       ctDataWrap.sendEmail.add(message);
                      
                 		Case medEduFormCase = new Case();
                        medEduFormCase.ParentId = newCase.Id;
                        medEduFormCase.RecordTypeId = medEduFormId;
                        medEduFormCase.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c;
                        medEduFormCase.OwnerId = medEduFormQueueId;
                        medEduFormCase.Document_Type__c = Constant_Case__mdt.getInstance('CASE_DOCUMENT_TYPE_MED_EDU_FORM').Value__c;   
                        medEduFormCase.Received_Date__c = Date.today();
                        medEduFormCase.ContactId = newCase.ContactId;
                        medEduFormCase.Service__c = Constant_Case__mdt.getInstance('SERVICE_ECFMG_CERT').Value__c;
                       if(conCATMap.containsKey(newCase.ContactId)){
                            medEduFormCase.Entity__c = CaseTriggerUtility.getAccount(conCATMap.get(newCase.ContactId));
                        }
                        recordsToInsert.add(medEduFormCase);
                    }
                
                    if(isIntStatusChanged && newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_PENDING_PRINT').Value__c){
                        if(String.isNotBlank(docConfigId)){
                            CaseTriggerUtility.generateDocHelper(docConfigId, newCase);
                        }
                    }
                }
                if(!recordsToInsert.isEmpty() && GenericUtilities.checkIsCreatable('Case') ){
                    CaseTriggerUtility.insertDML(recordsToInsert);
                }
            }catch(exception ex){
                throw ex;
            }
        }
    }