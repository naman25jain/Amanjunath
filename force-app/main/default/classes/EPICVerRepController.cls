public with sharing class EPICVerRepController{
    @AuraEnabled(cacheable = false)
    public static List<EpicVerRepWrap> getEpicCaseList(){
        String con = AppforCertController.getContactId();       
        List<EpicVerRepWrap> returnMap = new List<EpicVerRepWrap>();
        List<Case> caseList = new List<Case>();
        List<Asset> asstList = new List<Asset>();
        Set<String> statusId = new Set<String>{Constants.ASSET_STATUS_OUTDATED,Constants.ASSET_STATUS_MARKED_FOR_DELETION};
        asstList = [SELECT Id,Case__c,Type__c,Status,RecordType.DeveloperName FROM Asset WHERE Status NOT IN:statusId AND Case__c IN(SELECT Id FROM Case 
        WHERE Service__c=:Constants.CASE_SERVICE_EPIC AND contactID =:con AND Document_Type__c != ''AND ((recordType.DeveloperName =: Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION AND Internal_Status__c !=: Constants.CASE_STATUS_PENDING_SUBMISSION)
        OR (recordType.DeveloperName =: Constants.CASE_RECORD_TYPE_EXTRACTION_SUB_CASE AND Internal_Status__c =: Constants.CASE_STATUS_ACCEPTED))) WITH SECURITY_ENFORCED];
           Map<String,String> asstMap = new Map<String,String>();
           Map<String,String> asstDoc = new Map<String,String>();
           for(Asset a: asstList){
               if(a.recordType.DeveloperName == Constants.ASSET_RECORD_TYPE_CREDENTIAL && a.Type__c != Constants.ASSET_TYPE_TRANSLATION){
                    asstMap.put(a.Case__c,a.Id);
                    asstDoc.put(a.Case__c,a.Type__c);
                    if(a.Type__c == Constants.ASSET_TYPE_TCT){
                        asstDoc.put(a.Case__c,Constants.CASE_DOCUMENT_TYPE_TCT);
                    }
               }               
           }
        caseList = [SELECT Id,recordType.DeveloperName,CaseNumber,Document_Type__c,contactID,Internal_Status__c FROM Case 
            WHERE Service__c=:Constants.CASE_SERVICE_EPIC AND contactID =:con AND Document_Type__c != '' AND ((recordType.DeveloperName =: Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION AND Internal_Status__c !=: Constants.CASE_STATUS_PENDING_SUBMISSION)
            OR (recordType.DeveloperName =: Constants.CASE_RECORD_TYPE_EXTRACTION_SUB_CASE AND Internal_Status__c =: Constants.CASE_STATUS_ACCEPTED)) WITH SECURITY_ENFORCED];            
            Map<String,Case> existingCaseMap = new Map<String,Case>();
            Set<Id> cvCaseSet = new Set<Id>();
            for(Case cs:caseList){
                cvCaseSet.add(cs.Id);
            }
            existingCaseMap = getExistingEPICCase(cvCaseSet);
            for(Case cs:caseList){
                epicVerRepWrap evWrap = new epicVerRepWrap();
                evWrap.key = cs.Id;
                evWrap.docType = cs.Document_Type__c;
                evWrap.casNum = cs.CaseNumber;
                evWrap.selected = false;
                evWrap.status = cs.Internal_Status__c;
                evWrap.recType = cs.recordType.DeveloperName;                
                evWrap.asstExist = false;
                evWrap.reportType = '';
                evWrap.selectedAuthEntityId = '';
                evWrap.referenceNumber = '';
                evWrap.billName = '';
                if(asstMap.containsKey(cs.Id)){
                    evWrap.asst = asstMap.get(cs.Id);
                    evWrap.type = asstDoc.get(cs.Id);
                    evWrap.asstExist = true;
                }
                if(existingCaseMap.containsKey(cs.Id)){
                    evWrap.selected = true;
                    evWrap.reportType = existingCaseMap.get(cs.Id).Report_Type__c;
                    evWrap.selectedAuthEntityId = existingCaseMap.get(cs.Id).Entity__c;
                    evWrap.referenceNumber = existingCaseMap.get(cs.Id).Reference_Number__c;
                    evWrap.billName = existingCaseMap.get(cs.Id).Entity__r.Name;
                    evWrap.billStreet = existingCaseMap.get(cs.Id).Entity__r.BillingStreet;
                    evWrap.billCity = existingCaseMap.get(cs.Id).Entity__r.BillingCity;
                    evWrap.billState = existingCaseMap.get(cs.Id).Entity__r.BillingState;
                    evWrap.billCountry = existingCaseMap.get(cs.Id).Entity__r.BillingCountry;
                    evWrap.billPostal = existingCaseMap.get(cs.Id).Entity__r.BillingPostalCode;
                    evWrap.emailAddress = existingCaseMap.get(cs.Id).EPIC_Report_Entity_Email__c;
                    evWrap.verifyEmailAddress = existingCaseMap.get(cs.Id).EPIC_Report_Entity_Email__c;
                    evWrap.contactPersonName = existingCaseMap.get(cs.Id).EPIC_Report_Entity_Contact__c;
                    evWrap.nameOfEntity = existingCaseMap.get(cs.Id).EPIC_Report_Entity__c;
                    evWrap.entityAddress = existingCaseMap.get(cs.Id).EPIC_Report_Entity_Address__c;
                    evWrap.referenceNum = existingCaseMap.get(cs.Id).Reference_Number__c;
                    evWrap.country = existingCaseMap.get(cs.Id).EPIC_Report_Entity_Country__c;
                }
                returnMap.add(evWrap);                
            }                
            return returnMap;
    }
    @AuraEnabled(Cacheable = false)
    public static List<Account> searchRegOrg(String searchKey,String epicList){
       List<EpicVerRepWrap> objectList = (List<EpicVerRepWrap>) JSON.deserialize(epicList, List<EpicVerRepWrap>.class);
       Set<Id> caseSet = new Set<Id>();
       Set<Id> excludedAccSet = new Set<Id>();
       for(EpicVerRepWrap ev:objectList){
           if(ev.selected){
            caseSet.add(ev.key);
           }        
       }
       for(Case cs :[SELECT Id,Entity__c FROM Case WHERE Id IN: caseSet and Entity__c != null WITH SECURITY_ENFORCED]){
        excludedAccSet.add(cs.Entity__c);
       }       
        List<Id> accountIdList = new List<Id>();
        List<Account> accountListReturned = new List<Account>();
        if(String.isnotBlank(searchKey)){
            String keyValue = '%' + searchKey + '%';
            List<Account> accountList = new List<Account>([SELECT Id FROM Account WHERE Name LIKE :keyValue AND RecordType.DeveloperName = :Constants.ACCOUNT_RECORD_TYPE_DEV_ENTITY AND ID NOT IN:excludedAccSet WITH SECURITY_ENFORCED]);
            List<Account2Service__c> acc2SerList =  new List<Account2Service__c>([SELECT Id, Account__c FROM Account2Service__c WHERE Active__c = True AND Service__r.Name = :Constants.EPIC_SERVICENAME AND Account__c in :accountList WITH SECURITY_ENFORCED]);
            for(Account2Service__c acct: acc2SerList){
                accountIdList.add(acct.Account__c);
            }
            if(!accountIdList.isEmpty()){
                accountListReturned = [SELECT Id, RecordType.DeveloperName, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode,
                BillingCountry, Parent_Authority__c, EPIC_Client_Special_Instructions_Languag__c, Parent_Authority__r.EPIC_Client_Special_Instructions_Languag__c,Parent_Authority__r.Use_same_instruction_for_child_entities__c FROM Account WHERE Id IN :accountIdList WITH SECURITY_ENFORCED];
            }
        }
        return accountListReturned;
    }
    public static Set<Id> caseSetMerge(List<EpicVerRepWrap> objectList,Set<Id> caseSet){
        for(EpicVerRepWrap ev:objectList){
            if(ev.selected){
                caseSet.add(ev.key);
            }
        } 
        return caseSet;
    }

    public static String getAddressValue(Address inputAddress){
        String[] addr = new String[]{
            inputAddress.getStreet(), inputAddress.getCity(), inputAddress.getState(), inputAddress.getPostalCode(), inputAddress.getCountry()
          };                  
        for(Integer i = 4; i >= 0; i--){
           if(addr[i] == null) {
            addr.remove(i);
           }
        }                  
        String addressValue = String.join(addr, ', ');
        return addressValue;
    }

    @AuraEnabled
    public static EpicVerReturnWrap saveRecord(String action,String epicList,String epicVerFields){
        List<EpicVerRepWrap> objectList = (List<EpicVerRepWrap>) JSON.deserialize(epicList, List<EpicVerRepWrap>.class);
        EpicVerRepCreationWrap verRepWrap = (EpicVerRepCreationWrap) JSON.deserialize(epicVerFields, EpicVerRepCreationWrap.class);
        Set<Id> caseSet = new Set<Id>();
        Set<Id> altCaseIds = new Set<Id>();
        List<Case> epicReportCaseList = new List<Case>();
        Id recTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_VER_REPORT_REQUEST).getRecordTypeId();                 
        caseSet = caseSetMerge(objectList,caseSet);
        altCaseIds = caseTriggerHelper.formatGetAltCaseIds(caseSet);
        String con = AppforCertController.getContactId();
        String reportType = getReportType(action);
        ExistingCheckParamWrap existCheck = new ExistingCheckParamWrap();
        EpicVerReturnWrap returnWrap = new EpicVerReturnWrap();
        existCheck.reportType = reportType;
        existCheck.cont = con;
        Map<String,Case> getExistingPendingCases = new Map<String,Case>();
        Set<String> pendingCaseToRemoveSet = new Set<String>();
        getExistingPendingCases = getExistingEPICCase(caseSet);
        CaseDetWrap csDetail = getCaseDetWrap(caseSet,verRepWrap,existCheck);       
        List<String> returnVal = new List<String>(); 
        List<Contact> contactAccountInfo = new List<Contact>();
		List<Account> entityList = new List<Account>();
        
		if(con != null){
			contactAccountInfo = [SELECT Id, Name, MailingAddress, Email, Account.Name, Account.BillingAddress 
                                  FROM Contact WHERE Id=:con WITH SECURITY_ENFORCED];
            entityList = [SELECT Id, Name, BillingAddress FROM Account 
                            WHERE Id=:verRepWrap.selectedAuthEntityId WITH SECURITY_ENFORCED];                  
		}

        if((csDetail.existingCase).isEmpty()){       
                Map<String,String> acctMap = new Map<String,String>();
                acctMap=acctMap(acctMap,action,verRepWrap);
                for(EpicVerRepWrap ev:objectList){
                    if(ev.selected){
                        Case repCase = new Case();
                        getCaseId(repCase,getExistingPendingCases,ev.key);
                        repCase.contactId = con;
                        repCase.recordTypeId = recTypeId;
                        repCase.Internal_Status__c = constants.CASE_STATUS_PENDING_SUBMISSION;
                        repCase.External_Status__c = constants.CASE_STATUS_PENDING_SUBMISSION; 
                        repCase.Report_Type__c = '';
                        repCase.Secondary_Parent_Case__c =null;
                        repCase.EPIC_Report_Status__c = '';
                        repCase.EPIC_Report_Received_Date__c = null;
                        repCase.Document_Type__c = '';
                        repCase.Entity_External_Status__c = '';
                        repCase.Entity__c = null;
                        repCase.Reference_Number__c = '';
                        repCase.Service_Name__c = null;                                            
                        repCase.EPIC_Report_Entity_Email__c ='';                
                        repCase.EPIC_Report_Entity_Contact__c ='';
                        repCase.EPIC_Report_Entity__c ='';
                        repCase.EPIC_Report_Entity_Address__c ='';
                        repCase.Reference_Number__c ='';
                        repCase.EPIC_Report_Entity_Country__c ='';  
                        repCase.Issuing_Entity__c = null;   
                        repCase.Report_Type__c = reportType;                                       
                        repCase = actionTypeOne(repCase,action,ev);
                        repCase = actionTypeTwo(repCase,ev,verRepWrap);
                        repCase = acctMapForService(repCase,acctMap,verRepWrap);
                        if(action == System.Label.Applicant_select_option_to_send_report_to_an_Entity_that_is_not_found_in_search){                                                   
                            repCase.EPIC_Report_Entity_Email__c = verRepWrap.emailAddress;                
                            repCase.EPIC_Report_Entity_Contact__c = verRepWrap.contactPersonName;
                            repCase.EPIC_Report_Entity__c = verRepWrap.nameOfEntity;
                            repCase.EPIC_Report_Entity_Address__c = verRepWrap.entityAddress;
                            repCase.Reference_Number__c = verRepWrap.referenceNum;
                            repCase.EPIC_Report_Entity_Country__c = verRepWrap.country;
                            repCase.Secondary_Parent_Case__c = ev.key;                        
                            repCase = updateEntityDocType(repCase,csDetail.parentCase,altCaseIds);
                        } else if(action == System.Label.Applicants_receive_a_report_for_themselves && contactAccountInfo.size() > 0 ){                                                   
                            repCase.EPIC_Report_Entity_Email__c = contactAccountInfo[0].Email;
                            repCase.EPIC_Report_Entity__c = contactAccountInfo[0].Name;
                            if(contactAccountInfo[0].MailingAddress != null){
                                repCase.EPIC_Report_Entity_Address__c = getAddressValue(contactAccountInfo[0].MailingAddress);   
                            }                         
                            repCase = updateEntityDocType(repCase,csDetail.parentCase,altCaseIds);                            
                        } else if(action == System.Label.Applicant_can_search_for_an_Entity_which_will_receive_the_report && entityList.size() > 0 && contactAccountInfo.size() > 0){    
						    repCase.EPIC_Report_Entity__c = entityList[0].Name;
                            if(entityList[0].BillingAddress != null){
                                repCase.EPIC_Report_Entity_Address__c = getAddressValue(entityList[0].BillingAddress);   
                            }                                                     
                            repCase = updateEntityDocType(repCase,csDetail.parentCase,altCaseIds);
						}                  
                        epicReportCaseList.add(repCase);                    
                    }
                    else{
                        pendingCaseToRemoveSet.add(ev.key);
                    }    
                }
                createEPICReport(epicReportCaseList,pendingCaseToRemoveSet);
                CaseDetWrap csDetailAfter = getCaseDetWrap(caseSet,verRepWrap,existCheck);               
                returnVal = getCreatedEPICCases(caseSet,returnVal,reportType);
                returnWrap.epicCase = TRUE;
                returnWrap.existingcase = returnVal;
            }
            else{                
                returnWrap.epicCase = FALSE;
                returnWrap.existingcase =new List<String>(csDetail.existingCase);
            }
        return returnWrap;
    }

    public static Case actionTypeOne(Case repCase,String action,EpicVerRepWrap ev){        
        if(action == System.Label.Applicants_receive_a_report_for_themselves){                                    
            repCase.Secondary_Parent_Case__c = ev.key;
        }
        return repCase;
    }

    public static Case acctMapForService(Case repCase,Map<String,String> acctMap,EpicVerRepCreationWrap verRepWrap){        
        if(acctMap.containsKey(verRepWrap.selectedAuthEntityId)){
            repCase.Service_Name__c = acctMap.get(verRepWrap.selectedAuthEntityId);
        } 
        return repCase;
    } 

    public static Case actionTypeTwo(Case repCase,EpicVerRepWrap ev,EpicVerRepCreationWrap verRepWrap){
        if(repCase.Report_Type__c == System.Label.Report_Type_Volume_Entity){                         
            String action = System.Label.Applicant_can_search_for_an_Entity_which_will_receive_the_report;            
            repCase.Document_Type__c = ev.docType;
            repCase.Entity_External_Status__c = 'Not Reviewed';
            repCase.Entity__c = verRepWrap.selectedAuthEntityId;
            repCase.Reference_Number__c = verRepWrap.referenceNumber;
            repCase.Secondary_Parent_Case__c = ev.key;                  
        }
        return repCase;
    }

    public static Case getCaseId(Case repCase,Map<String,Case> getExistingPendingCases,String key){
        if(getExistingPendingCases.containsKey(key)){
            repCase.Id = getExistingPendingCases.get(key).Id;
        }
        return repCase;
    }
    public static List<String> getCreatedEPICCases(Set<Id> cvCaseSet,List<String> returnVal,String reportType){
        for(Case cas: [SELECT Id,Secondary_Parent_Case__r.CaseNumber FROM Case 
            WHERE Secondary_Parent_Case__c IN: cvCaseSet AND Report_Type__c =: reportType AND Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION WITH SECURITY_ENFORCED]){      
                returnVal.add(cas.Id);
            }
        return returnVal;
    }
    public static void createEPICReport(List<Case> epicReportCaseList,Set<String> pendingCaseToRemoveSet){ 
        List<Case> epicCaseToDel = new List<Case>();               
        for(Case c:[SELECT Id FROM Case WHERE Secondary_Parent_Case__c IN: pendingCaseToRemoveSet AND 
                Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION WITH SECURITY_ENFORCED]){
            Case cs = new Case(Id = c.Id);
            cs.Secondary_Parent_Case__c = null;
            cs.contactId = null;
            cs.Internal_Status__c = Constants.CASE_STATUS_EXPIRED;
            cs.External_Status__c = Constants.CASE_STATUS_EXPIRED;
            epicCaseToDel.add(cs);
        } 
        if(!epicCaseToDel.isEmpty()){ 
            epicReportCaseList.addAll(epicCaseToDel);
        }        
        if(Schema.sObjectType.Case.isCreateable() && Schema.sObjectType.Case.isUpdateable() && !epicReportCaseList.isEmpty()){
            UPSERT epicReportCaseList;
        }                   
    }
    // Gets report type based
    static String getReportType(String action){
        String reportType = '';
        if(action == System.Label.Applicants_receive_a_report_for_themselves){
            reportType = System.Label.Report_Type_Self;
        }else if(action == System.Label.Applicant_can_search_for_an_Entity_which_will_receive_the_report){
            reportType = System.Label.Report_Type_Volume_Entity;
        }else if(action == System.Label.Applicant_select_option_to_send_report_to_an_Entity_that_is_not_found_in_search){
            reportType = System.Label.Report_Type_Other_Entity;
        }
        return reportType;
    }
    // Sets document type and Issuing Entity
    private static Case updateEntityDocType(Case repCase,Map<Id,Case> parentCase,Set<Id> altCaseIds){
        if(!parentCase.isEmpty() && parentCase.containsKey(repCase.Secondary_Parent_Case__c)){            
            Case cs = parentCase.get(repCase.Secondary_Parent_Case__c);
            repCase.Document_Type__c = cs.Document_Type__c;
            repCase.Issuing_Entity__c = altCaseIds.contains(repCase.Secondary_Parent_Case__c)?cs.Alternate_Entity__c:cs.Entity__c;        
        }
        return repCase;
    }    
    private static CaseDetWrap getCaseDetWrap(Set<Id> caseSet,EpicVerRepCreationWrap verRepWrap,ExistingCheckParamWrap existCheck){
        CaseDetWrap csDetail = new CaseDetWrap();
        Set<String> reportStatus = new Set<String>{'Report Rejected','Report Expired'};
        for(Case cas: [SELECT Id,Secondary_Parent_Case__r.CaseNumber,EPIC_Report_Status__c,Do_Not_Know_Orgs_to_send_EPIC_Reports__c,Secondary_Parent_Case__c,Secondary_Parent_Case__r.Document_Type__c,Secondary_Parent_Case__r.Entity__c,Secondary_Parent_Case__r.Alternate_Entity__c,Entity__c,ContactId,EPIC_Report_Entity_Email__c,Report_Type__c FROM Case 
                        WHERE Secondary_Parent_Case__c IN: caseSet AND Internal_Status__c !=: Constants.CASE_STATUS_EXPIRED AND Internal_Status__c !=: Constants.CASE_STATUS_PENDING_SUBMISSION WITH SECURITY_ENFORCED]){      
                            csDetail.parentCase.put(cas.Secondary_Parent_Case__c,new Case(Id=cas.Secondary_Parent_Case__c,Entity__c=cas.Secondary_Parent_Case__r.Entity__c,Alternate_Entity__c=cas.Secondary_Parent_Case__r.Alternate_Entity__c,Document_Type__c=cas.Secondary_Parent_Case__r.Document_Type__c));
                            if(!reportStatus.contains(cas.EPIC_Report_Status__c) && cas.Report_Type__c == existCheck.reportType && ((cas.Report_Type__c == System.Label.Report_Type_Self && cas.contactId == existCheck.cont) || (cas.Report_Type__c == System.Label.Report_Type_Volume_Entity && cas.Entity__c == verRepWrap.selectedAuthEntityId) || (cas.Report_Type__c == System.Label.Report_Type_Other_Entity && cas.EPIC_Report_Entity_Email__c == verRepWrap.emailAddress))){
                                (csDetail.existingCase).add(cas.Secondary_Parent_Case__r.CaseNumber);
                                csDetail.existingEpicCase.put(cas.Secondary_Parent_Case__c,cas.Id);                                
                            }
                        }
        return csDetail;
    }
    public static Map<String,String> acctMap(Map<String,String> acctMap,String action,EpicVerRepCreationWrap verRepWrap){
        if(action == System.Label.Applicant_can_search_for_an_Entity_which_will_receive_the_report){
            for(Account2Service__c act:[SELECT Id, Account__c,Service__c FROM Account2Service__c WHERE 
            Active__c = True AND Service__r.Name = :Constants.EPIC_SERVICENAME AND 
            Account__c =:verRepWrap.selectedAuthEntityId WITH SECURITY_ENFORCED]){
                acctMap.put(act.Account__c,act.Service__c);
            } 
        }
        return acctMap;
    }
    @AuraEnabled
    public static List<Case> getExtractionSubCase(List<String> epicList){
        Id contactId = AppforCertHelper.retrieveCurrentContactId();
        Map<Id,Case> scIds = new Map<Id,Case>();
        for(Case cas:[SELECT Id,Secondary_Parent_Case__c,Secondary_Parent_Case__r.CaseNumber FROM Case WHERE Id IN: epicList]){
            scIds.put(cas.Secondary_Parent_Case__c,cas);
        }
        Set<String> statusId = new Set<String>{Constants.ASSET_STATUS_OUTDATED,Constants.ASSET_STATUS_MARKED_FOR_DELETION};             
        Id casRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXTRACTION_SUB_CASE).getRecordTypeId();
        List<Case> casList = [Select Id,CaseNumber,Internal_Status__c,Document_Type__c,(SELECT Id,RecordType.DeveloperName,Azure_Storage_URL__c, Document_is_not_in_English__c, Name_on_Document__c, Name_on_Document_is_Different__c, Type__c, Key__c, Parent_Key__c, ParentId FROM Assets__r WHERE Asset.status NOT IN:statusId ORDER BY CreatedDate ASC, Type__c ASC)
                                                                 FROM Case WHERE Id IN:scIds.keyset() AND RecordTypeId = :casRecTypeId 
                                                                 WITH SECURITY_ENFORCED];                                                                
        return casList;
    }
    @AuraEnabled
    public static List<Case> getEPICCaseList(List<String> epicList){        
        Map<Id,Case> scIds = new Map<Id,Case>();
        List<Case> cas = new List<Case>();
        cas = [SELECT Id,Report_Type__c,Entity__c,Entity__r.Name,Reference_Number__c,EPIC_Report_Entity_Email__c,EPIC_Report_Entity_Contact__c,
            EPIC_Report_Entity__c,EPIC_Report_Entity_Address__c,EPIC_Report_Entity_Country__c FROM 
            Case WHERE Id IN: epicList LIMIT 1];
        return cas;
    }
    @AuraEnabled
    public static List<Contact_Association_Type__c> getCredDocumentTypesCAT(List<String> epicList){       
        Map<Id,Case> scIds = new Map<Id,Case>();
        for(Case cas:[SELECT Id,Secondary_Parent_Case__c,Secondary_Parent_Case__r.CaseNumber FROM Case WHERE Id IN: epicList]){
            scIds.put(cas.Secondary_Parent_Case__c,cas);
        } 
        Set<String> statusId = new Set<String>{Constants.ASSET_STATUS_OUTDATED,Constants.ASSET_STATUS_MARKED_FOR_DELETION};      
        Id catRecTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_CREDENTIAL_INTAKE).getRecordTypeId();
        List<Contact_Association_Type__c> catStagList = [Select Id, Case__c,Name_on_Document__c,DOB_on_Document__c,Case__r.CaseNumber,Case__r.Internal_Status__c, Credential_Type__c, Account_Name__c, Account__r.name, Degree_Issue_Date__c, Issue_Date__c, Degree_Title__c,Requested_to_be_sent_to_ECFMG__c,Issued_in_the_last_90_days__c,
                                                                 Title__c,(SELECT Id,RecordType.DeveloperName,Azure_Storage_URL__c, Document_is_not_in_English__c, Name_on_Document__c, Name_on_Document_is_Different__c, Type__c, Key__c, Parent_Key__c, ParentId FROM Assets__r WHERE Asset.status NOT IN:statusId ORDER BY CreatedDate ASC, Type__c ASC)                                                                 
                                                                 FROM Contact_Association_Type__c WHERE Case__c IN:scIds.keyset() WITH SECURITY_ENFORCED];                                                                
        return catStagList;
    }
    @AuraEnabled
    public static List<Contact_Association_Type_Staging__c> getCredDocumentTypes(List<String> epicList){
        Id contactId = AppforCertHelper.retrieveCurrentContactId();
        Map<Id,Case> scIds = new Map<Id,Case>();
        for(Case cas:[SELECT Id,Secondary_Parent_Case__c,Secondary_Parent_Case__r.CaseNumber FROM Case WHERE Id IN: epicList]){
            scIds.put(cas.Secondary_Parent_Case__c,cas);
        }       
        Set<String> statusId = new Set<String>{Constants.ASSET_STATUS_OUTDATED,Constants.ASSET_STATUS_MARKED_FOR_DELETION};      
        Id catRecTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_CREDENTIAL_INTAKE).getRecordTypeId();
        List<Contact_Association_Type_Staging__c> catStagList = [Select Id, Case__c,Case__r.CaseNumber,Case__r.Internal_Status__c, Credential_Type__c, Account_Name__c, Account__r.name, Degree_Issue_Date__c, Issue_Date__c, Degree_Title__c,Requested_to_be_sent_to_ECFMG__c,Issued_in_the_last_90_days__c,
                                                                 Title__c,(SELECT Id,RecordType.DeveloperName,Azure_Storage_URL__c, Document_is_not_in_English__c, Name_on_Document__c, Name_on_Document_is_Different__c, Type__c, Key__c, Parent_Key__c, ParentId FROM Assets__r WHERE Asset.status NOT IN:statusId ORDER BY CreatedDate ASC, Type__c ASC),
                                                                 (SELECT Authority__c,Authority__r.Name,Regulatory_Org_Do_Not_Know__c FROM EPIC_Verification_Reports__r)
                                                                 FROM Contact_Association_Type_Staging__c WHERE Case__c IN:scIds.keyset() AND RecordTypeId = :catRecTypeId 
                                                                 WITH SECURITY_ENFORCED];                                                                
        return catStagList;
    }
    @AuraEnabled(cacheable = false)
    public static Map<String,Map<String,String>> getCredProgDocTypeMap(List<String> docName,String programName){
        Map<String,Map<String,String>> retValFinal = new Map<String,Map<String,String>>();
        Map<String,String> returnVal = new Map<String,String>();
        List<Program_Document_type_Mapping__mdt> docList = [SELECT Id,DeveloperName,Program__c,Credential_Type__c,Label,MasterLabel 
                        FROM Program_Document_type_Mapping__mdt WHERE Credential_Type__c =: docName AND Program__c =: programName WITH SECURITY_ENFORCED];
        if(!docList.isEmpty()){
            List<Document_Type_Field_Mapping__mdt> proDocMapList = [SELECT Id,DeveloperName,Field_API_Name__c,Field_Label__c,Field_Order__c,Program_Document_Type_Mapping__c,Label,MasterLabel,Program_Document_Type_Mapping__r.Credential_Type__c 
                        FROM Document_Type_Field_Mapping__mdt WHERE Program_Document_Type_Mapping__c =: docList WITH SECURITY_ENFORCED ORDER BY Field_Order__c ASC];
            if(!proDocMapList.isEmpty()){
                for(Document_Type_Field_Mapping__mdt proDoc : proDocMapList){
                    if(retValFinal.containsKey(proDoc.Program_Document_Type_Mapping__r.Credential_Type__c)){
                        retValFinal.get(proDoc.Program_Document_Type_Mapping__r.Credential_Type__c).put(proDoc.Field_API_Name__c,proDoc.Field_Label__c);
                    }
                    else{
                        returnVal = new Map<String,String>();
                        returnVal.put(proDoc.Field_API_Name__c,proDoc.Field_Label__c);
                        retValFinal.put(proDoc.Program_Document_Type_Mapping__r.Credential_Type__c,returnVal);
                    }
                }
            }
        }
        return retValFinal;
    }   
     // get existingCase
     public static Map<String,Case> getExistingEPICCase(Set<Id> cvCaseSet){
        Map<String,Case> csDetail = new Map<String,Case>();
        for(Case cas: [SELECT Id,Secondary_Parent_Case__r.CaseNumber,EPIC_Report_Status__c,Do_Not_Know_Orgs_to_send_EPIC_Reports__c,Secondary_Parent_Case__c,Secondary_Parent_Case__r.Document_Type__c,Secondary_Parent_Case__r.Entity__c,Secondary_Parent_Case__r.Alternate_Entity__c,ContactId,
                        Report_Type__c,Document_Type__c,Entity__c,Entity__r.Name,Entity__r.BillingStreet,Entity__r.BillingCity,Entity__r.BillingState,Entity__r.BillingCountry,Entity__r.BillingPostalCode,
                        Reference_Number__c,EPIC_Report_Entity_Email__c,EPIC_Report_Entity_Contact__c,EPIC_Report_Entity__c,EPIC_Report_Entity_Address__c,EPIC_Report_Entity_Country__c FROM Case 
                        WHERE Secondary_Parent_Case__c IN: cvCaseSet AND Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION WITH SECURITY_ENFORCED]){      
            csDetail.put(cas.Secondary_Parent_Case__c,cas);
        }
        return csDetail;
    } 
    public class EpicVerReturnWrap{
        @AuraEnabled public Boolean epicCase;
        @AuraEnabled public List<String> existingcase;
    }    
    public class EpicVerRepWrap{
        @AuraEnabled public String key;
        @AuraEnabled public String casNum;
        @AuraEnabled public String docType;
        @AuraEnabled public Boolean selected;
        @AuraEnabled public String status;
        @AuraEnabled public String recType;
        @AuraEnabled public String asst;
        @AuraEnabled public Boolean asstExist;
        @AuraEnabled public String type;
        @AuraEnabled public String reportType;
        @AuraEnabled public String selectedAuthEntityId;  
        @AuraEnabled public String referenceNumber;
        @AuraEnabled public String emailAddress;
        @AuraEnabled public String verifyEmailAddress;
        @AuraEnabled public String contactPersonName;
        @AuraEnabled public String nameOfEntity;
        @AuraEnabled public String entityAddress;
        @AuraEnabled public String referenceNum;
        @AuraEnabled public String country; 
        @AuraEnabled public String billName;
        @AuraEnabled public String billStreet;
        @AuraEnabled public String billCity;
        @AuraEnabled public String billState;
        @AuraEnabled public String billCountry;
        @AuraEnabled public String billPostal;
    }
    public class EpicVerRepCreationWrap{
        @AuraEnabled public String selectedAuthEntityId;  
        @AuraEnabled public String referenceNumber;
        @AuraEnabled public String emailAddress;
        @AuraEnabled public String verifyEmailAddress;
        @AuraEnabled public String contactPersonName;
        @AuraEnabled public String nameOfEntity;
        @AuraEnabled public String entityAddress;
        @AuraEnabled public String referenceNum;
        @AuraEnabled public String country;              
    }
    // Wrapper for storing case details
    public class CaseDetWrap{
        public Map<Id,Case> parentCase = new Map<Id,Case>();
        public Set<String> existingCase = new Set<String>();
        public Map<String,String> existingEpicCase = new Map<String,String>();
    }
    // Wrapper for passing reportType,contact
    public class ExistingCheckParamWrap{
        public String reportType;
        public String cont;
    }
    //Update EPIC Report Request case on payment completion.
    @AuraEnabled
    public static List<String> epicReportStatusUpdate(List<String> parentCVCases){
        try{
            String currConId = AppForCertController.getContactId();
            Id epicRepReqTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_VER_REPORT_REQUEST).getRecordTypeId();
            List<Case> epicReportReq = new List<Case>();
            epicReportReq = [SELECT Id, Internal_Status__c, EPIC_Report_Status__c, Report_Type__c, CaseNumber, Secondary_Parent_Case__c, EPIC_Report_Received_Date__c, Secondary_Parent_Case__r.Internal_Status__c, Irregular_Behavior_Annotated__c
                            FROM Case 
                            WHERE ContactId =:currConId 
                                AND Secondary_Parent_Case__c IN:parentCVCases 
                                AND RecordTypeId =:epicRepReqTypeId 
                                AND Internal_Status__c =:Constants.CASE_STATUS_PENDING_SUBMISSION 
                            WITH SECURITY_ENFORCED];
            List<String> epicRepCaseNum = new List<String>();
            List<Case> updRepCase = new List<Case>();
            List<Case> invCases = new List<Case>();
            invCases = [SELECT Id,Annotation__c FROM Case WHERE ContactId =:currConId AND RecordTypeId =:Constants.INVESTIGATIONRTID AND Annotation__c != null WITH SECURITY_ENFORCED];
            for(Case epicReq: epicReportReq){
                epicRepCaseNum.add(epicReq.CaseNumber);
                epicReq = updateBasedRepType(epicReq);
                if(!invCases.isEmpty()){
                    epicReq.Irregular_Behavior_Annotated__c = TRUE;
                }
                updRepCase.add(epicReq);
            }
            for(Case epicReq: updRepCase){
                epicReq = updatePaymentType(epicReq);
            }
            if(!updRepCase.isEmpty() && Schema.sObjectType.Case.isUpdateable()){
                UPDATE updRepCase;
            }   
            return epicRepCaseNum;            
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    public static Case updateBasedRepType(Case epicReq){
        Id qId = [SELECT Id FROM Group WHERE Type =: Constants.GROUP_TYPE_QUEUE AND Name =: Constants.CASE_QUEUE_EPIC_REP_REQ LIMIT 1].Id;
        if(epicReq.Report_Type__c == System.Label.Report_Type_Other_Entity){
            epicReq.OwnerId = qId;
            epicReq.EPIC_Report_Status__c = Constants.CASE_EPIC_REPORT_STATUS_REPORT_REQUESTED;
            epicReq.Internal_Status__c = Constants.CASE_EPIC_REPORT_STATUS_REQUESTED;
        }
        else if(epicReq.Report_Type__c == System.Label.Report_Type_Volume_Entity){
            epicReq = updateRepVolEntity(epicReq);
        }
        else if(epicReq.Report_Type__c == System.Label.Report_Type_Self){
            epicReq = updateRepForSelf(epicReq);
        }   
        return epicReq;
    }
    public static Case updateRepVolEntity(Case epicReq){
        if(epicReq.Secondary_Parent_Case__r.Internal_Status__c == Constants.CASE_STATUS_CV_ACCEPTED){
            epicReq.EPIC_Report_Status__c = Constants.CASE_EPIC_REPORT_STATUS_REPORT_SENT;
            epicReq.EPIC_Report_Received_Date__c = System.today();
            epicReq.Internal_Status__c = Constants.CASE_EPIC_REPORT_STATUS_REQUESTED;
            UPDATE epicReq;
            epicReq.Internal_Status__c = Constants.CASE_STATUS_SENT;
            UPDATE epicReq;
        }
        else if(epicReq.Secondary_Parent_Case__r.Internal_Status__c != Constants.CASE_STATUS_CV_ACCEPTED){
            epicReq.EPIC_Report_Status__c = Constants.CASE_EPIC_REPORT_STATUS_REPORT_REQUESTED;
            epicReq.Internal_Status__c = Constants.CASE_EPIC_REPORT_STATUS_REQUESTED;
            UPDATE epicReq;
        }
        return epicReq;
    }
    public static Case updateRepForSelf(Case epicReq){
        epicReq.EPIC_Report_Status__c = Constants.CASE_EPIC_REPORT_STATUS_REPORT_SENT;
        epicReq.EPIC_Report_Received_Date__c = System.today();
        epicReq.Internal_Status__c = Constants.CASE_EPIC_REPORT_STATUS_REQUESTED;
        UPDATE epicReq;
        epicReq.Internal_Status__c = Constants.CASE_STATUS_SENT;
        UPDATE epicReq;
        return epicReq;
    }
    public static Case updatePaymentType(Case epicReq){
        String parentCaseId = epicReq.Secondary_Parent_Case__c;
        List<Case> epicRepCases = [SELECT Id, Secondary_Parent_Case__r.CaseNumber, Payment_History__c, EPIC_Report_Status__c, Do_Not_Know_Orgs_to_send_EPIC_Reports__c
                                     FROM Case WHERE Secondary_Parent_Case__c =: parentCaseId WITH SECURITY_ENFORCED];
        if(epicRepCases.size() == 1){            
            epicReq.Payment_History__c = 'Free Report';
        }else{
            epicReq.Payment_History__c = 'Paid Report';
        }
        return epicReq;
    }
}