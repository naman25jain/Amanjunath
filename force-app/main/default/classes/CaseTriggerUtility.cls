/**
    * @author: Reshma Ravi
    * @name: CaseTriggerUtility 
    * @description: Utility class for CaseTrigger
    * @createdDate: 15-Jun-2020
**/
public with sharing class CaseTriggerUtility {
    /**
     * @author: Reshma
     * @name: groupList
     * @description: Variable to query all the group records
     */
    public static List<Group> groupList {
        get {
           if (groupList == null) {
                groupList = [SELECT Id, Name FROM Group WHERE Type = 'Queue'];
           }
           return groupList;
        }
        set;
    }

    /**
     * @author: Reshma
     * @name: groupMap
     * @description: Storing group record as value and group id as key
     */
    public static Map<String, Group> groupMap {
        get {
           if (groupMap == null) {
                groupMap = new Map<String, Group>();
                for (Group grp: groupList) {
                     groupMap.put(grp.Name, grp);
                }
           }
           return groupMap;
        }
        set;
    }

    /**
     * @author: Reshma
     * @name: catList
     * @description: Variable to query all the Contact Association Type record with record type as degree medical school
     */
    public static List<Contact_Association_Type__c> catList {
        get {
           if (catList == null) {
               Id degMedSchRecordTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL).getRecordTypeId();        
               catList = [SELECT School_Program__c,
                             Graduation_Month__c,
                             Graduation_Year__c,
                             Start_Date__c,
                             End_Date__c,
                             Graduation_Date__c,
                             Degree_Issue_Date__c,
                             Degree_Issue_Month__c,
                             Degree_Issue_Year__c,
                             Status__c,
                             Contact__c,
                             Account__c,
                             Account__r.IsCustomerPortal,
                             Number_of_Years_Attended__c,
                             Student_ID__c,
                             Start_Month__c,
                             Start_Year__c,
                             End_Month__c,
                             End_Year__c
                             FROM Contact_Association_Type__c
                             WHERE RecordTypeId =: degMedSchRecordTypeId];
           }
           return catList;
        }
        set;
    }

    /**
     * @author: Reshma
     * @name: groupMap
     * @description: Storing CAT record as value and contact id as key
     */
    public static Map<String, Contact_Association_Type__c> catMap {
        get {
           if (catMap == null) {
                catMap = new Map<String, Contact_Association_Type__c>();
                for (Contact_Association_Type__c cat: catList) {
                     catMap.put(cat.Contact__c, cat);
                }
           }
           return catMap;
        }
        set;
    }
    // updates the updateDML member in CaseTriggerDataWrapper with latest record to update
    public static void updateDMLMap(List<sObject> records){
        try{
            CaseTriggerDataInitialize ctData = CaseTriggerDataInitialize.getInstance(new List<Case>(),false);
            CaseTriggerDataInitialize.CaseTriggerDataWrapper ctDataWrap = ctData.fetchData();
            for(sObject record: records){
                updateRec(ctDataWrap.updateDML,record);
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // Updates Record with latest data
    public static void updateRec(Map<Id,sObject> updateRecMap,sObject newRec){
        try{
            if((updateRecMap).containsKey(newRec.Id)){
                sObject rec = (updateRecMap).get(newRec.Id);
                Map<string,Object> fieldsToValue = (newRec).getPopulatedFieldsAsMap();
                for(String key:fieldsToValue.keySet()){
                    rec.put(key,fieldsToValue.get(key));
                }
            }else{
                (updateRecMap).put(newRec.id,newRec);
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // Updates the insertDML member in CaseTriggerDataWrapper with latest record to insert
    public static void insertDML(List<sObject> records){
        try{
            CaseTriggerDataInitialize ctData = CaseTriggerDataInitialize.getInstance(new List<Case>(),false);
            CaseTriggerDataInitialize.CaseTriggerDataWrapper ctDataWrap = ctData.fetchData();
            (ctDataWrap.insertDML).addAll(records);
        }catch(Exception ex){
            throw ex;
        }
    }
    // Updates the deleteDML member in CaseTriggerDataWrapper with latest record to delete
    public static void deleteDML(Set<Id> recordIds){
        try{
            CaseTriggerDataInitialize ctData = CaseTriggerDataInitialize.getInstance(new List<Case>(),false);
            CaseTriggerDataInitialize.CaseTriggerDataWrapper ctDataWrap = ctData.fetchData();
            (ctDataWrap.deleteDML).addAll(recordIds);
        }catch(Exception ex){
            throw ex;
        }
    }
    // Updates the Case Service for each record based on record type
    // serviceRecName is record type developer name and for credential verification 
    // and Medical Education Form, the value will be a combination of Service and Record type developer name.
    public static void updateCaseService(Case newCase,String serviceRecName){
        try{
            // Queries service related details from Custom metadata
            for(Case_Service_Mapping__mdt serviceRec : [SELECT Id,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c FROM Case_Service_Mapping__mdt WHERE Service_RecordType__c =:serviceRecName LIMIT 1]){
                newCase.Case_Service__c = serviceRec.Case_Service__c;
                newCase.Case_Service_Family__c = serviceRec.Case_Service_Family__c;
                newCase.Case_Service_Line__c = serviceRec.Case_Service_Line__c;
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // Updates date in case record
    public static void updateCaseRecordDate(Case newCase){
        try{
            Set<String> statusSet = new Set<String>{Constant_Case__mdt.getInstance('STATUS_PENDING_ID_REVIEW').Value__c,Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c,Constant_Case__mdt.getInstance('STATUS_RESUBMITTED_PENDING_ID_REVIEW').Value__c,Constant_Case__mdt.getInstance('STATUS_PENDING_ID_VERIFICATION_REVIEW').Value__c,Constant_Case__mdt.getInstance('STATUS_RESUBMITTED_PENDING_ID_VERIFICATI').Value__c};
            if(statusSet.contains(newCase.Internal_Status__c)){
                newCase.Applicant_Last_Submission_Date__c = Date.today();
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }
    // Update case status to closed/Not Applicable
    public static void updateCaseRecordStatusFlag(Case newCase){
        try{
            Set<String> statusSet = new Set<String>{Constant_Case__mdt.getInstance('STATUS_ACCEPTED').Value__c,Constant_Case__mdt.getInstance('STATUS_ADDED').Value__c,Constant_Case__mdt.getInstance('STATUS_CANCELLED_BY_APPLICANT').Value__c
            ,Constant_Case__mdt.getInstance('STATUS_CANCELLED_BY_ECFMG').Value__c,Constant_Case__mdt.getInstance('STATUS_CLOSED_SCHOOL_CHANGED').Value__c,Constant_Case__mdt.getInstance('STATUS_ENROLLMENT_COMPLETED').Value__c,Constant_Case__mdt.getInstance('STATUS_CV_ACCEPTED').Value__c
            ,Constant_Case__mdt.getInstance('STATUS_CV_REJECTED').Value__c,Constant_Case__mdt.getInstance('STATUS_DUPLICATE_RECORD').Value__c,Constant_Case__mdt.getInstance('STATUS_ENROLLMENT_VERIFICATION_COMPLETE').Value__c
            ,Constant_Case__mdt.getInstance('STATUS_ENROLLMENT_VERIFIED').Value__c,Constant_Case__mdt.getInstance('STATUS_EXPIRED').Value__c,Constant_Case__mdt.getInstance('STATUS_FINAL_QA_COMPLETE').Value__c,Constant_Case__mdt.getInstance('STATUS_REJECTED').Value__c
            };
            if(statusSet.contains(newCase.Internal_Status__c) && newCase.Status != Constant_Case__mdt.getInstance('STATUS_CLOSED').Value__c){
                newCase.Status = Constant_Case__mdt.getInstance('STATUS_CLOSED').Value__c;
            }
            else if(!statusSet.contains(newCase.Internal_Status__c) && newCase.Status != Constant_Case__mdt.getInstance('STATUS_NOT_APPLICABLE').Value__c){
                newCase.Status = Constant_Case__mdt.getInstance('STATUS_NOT_APPLICABLE').Value__c;
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // Updates External Status field for case record
    public static void updateCaseExtStatus(Case newCase,Case oldCase){
        try{
            GetCaseInternalStatus getInternalStatusObj = GetCaseInternalStatus.getInstance();
            Map<String,map<String,Internal_Status_External_Status_Mapping__mdt>> recIdIntExtStatus = getInternalStatusObj.getIntExtStatus();
            if(recIdIntExtStatus.containsKey(newCase.recordTypeId)){
                Internal_Status_External_Status_Mapping__mdt intExtStatusItem = null;
                Map<String,Internal_Status_External_Status_Mapping__mdt> intExtStatus = recIdIntExtStatus.get(newCase.recordTypeId);
                if(oldCase != null && intExtStatus.containsKey(newCase.Internal_Status__c+Constants.STATUS_SEPARATOR+oldCase.Internal_Status__c)){
                    intExtStatusItem = intExtStatus.get(newCase.Internal_Status__c+Constants.STATUS_SEPARATOR+oldCase.Internal_Status__c);
                }else if(intExtStatus.containsKey(newCase.Internal_Status__c)){
                    intExtStatusItem = intExtStatus.get(newCase.Internal_Status__c);
                }
                if(intExtStatusItem != null){
                    newCase.External_Status__c = intExtStatusItem.External_Status__c;
                    updateEntityExtStatus(newCase,intExtStatusItem);
                }
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // Updates Entity External Status
    public static void updateEntityExtStatus(Case newCase,Internal_Status_External_Status_Mapping__mdt intExtStatusItem){
        try{
            Set<String> noExtEntStatusRecType = new Set<String>{Constant_Case__mdt.getInstance('REC_TYPE_MED_EDU_FORM').Value__c,Constant_Case__mdt.getInstance('REC_TYPE_CREDENTIAL_VERIFICATION').Value__c};
            if(intExtStatusItem.Entity_External_Status__c!=null && (!noExtEntStatusRecType.contains(intExtStatusItem.Record_Type_Developer_Name__c) 
            || (noExtEntStatusRecType.contains(intExtStatusItem.Record_Type_Developer_Name__c) && newCase.Service__c != Constant_Case__mdt.getInstance('SERVICE_FCVS').Value__c))){
                newCase.Entity_External_Status__c = intExtStatusItem.Entity_External_Status__c;
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // collects the service, account, case ids for processing case share
    public static void collectCaseShareAcc(Map<Id,set<Id>> insAccCaseMap,Map<Id,set<Id>> delAccCaseMap,String service){
        try{
            CaseTriggerDataInitialize ctData = CaseTriggerDataInitialize.getInstance(new List<Case>(),false);
            CaseTriggerDataInitialize.CaseTriggerDataWrapper ctDataWrap = ctData.fetchData();
            ctDataWrap.accountIdSet.addAll(insAccCaseMap.keySet());
            ctDataWrap.accountIdSet.addAll(delAccCaseMap.keySet());
            populateAccCaseMap(insAccCaseMap,service,ctDataWrap.insServiceAccCaseMap);
            populateAccCaseMap(delAccCaseMap,service,ctDataWrap.delServiceAccCaseMap);
        }catch(Exception ex){
            throw ex;
        }
    }
    // populates account, case Id map for processing case share
    public static void populateAccCaseMap(Map<Id,Set<Id>> accCaseMap,String service,Map<String,Map<Id,Set<Id>>> serviceAccCaseMap){
        try{
            if(!accCaseMap.isEmpty()){
                if(serviceAccCaseMap.containsKey(service)){
                    Map<Id,Set<Id>> existingAccCaseMap = serviceAccCaseMap.get(service);
                    for(Id accId:accCaseMap.keySet()){
                        if(existingAccCaseMap.containsKey(accId)){
                            existingAccCaseMap.get(accId).addAll(accCaseMap.get(accId));
                        }else{
                            existingAccCaseMap.put(accId,new Set<Id>(accCaseMap.get(accId)));
                        }
                    }
                }else{
                    serviceAccCaseMap.put(service,new Map<Id,Set<Id>>(accCaseMap));
                }
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // Method to send mail when the Case Status is Accepted or Rejected or 
    public static Messaging.SingleEmailMessage sendCaseStatusMail(SendMailWrapper sendMailWrap){
        try{
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message = CaseTriggerHelper.prepareEmail(sendMailWrap.caseRec,sendMailWrap.addr,sendMailWrap.emailTemplate);
            PrepareHtmlWrapper prepHtmlWrap = new PrepareHtmlWrapper();
            prepHtmlWrap.caseRecord = sendMailWrap.caseRec;
            prepHtmlWrap.htmlBody = sendMailWrap.emailTemplate.HtmlValue;
            prepHtmlWrap.con = sendMailWrap.con;
            prepHtmlWrap.message = message;
            message = htmlContent(prepHtmlWrap);
            return message;
        }catch(Exception ex){
            throw ex;
        }
    }
    // Method to build html content
    public static Messaging.SingleEmailMessage htmlContent(PrepareHtmlWrapper prepHtmlWrap){
        string htmlBody = prepHtmlWrap.htmlBody;
        htmlBody = htmlBody.replace('{!Case.Internal_Status__c}',prepHtmlWrap.caseRecord.Internal_Status__c);
        htmlBody = htmlBody.replace('{!Case.Contact}', prepHtmlWrap.con.Name);
        if(prepHtmlWrap.caseRecord.Deficiency_Reason_RTF__c != null){
            htmlBody = htmlBody.replace('{!Case.Deficiency_Reason_RTF__c}', prepHtmlWrap.caseRecord.Deficiency_Reason_RTF__c);
        }
        htmlBody = htmlBody.replace('{!Case.CaseNumber}', prepHtmlWrap.caseRecord.CaseNumber);
        htmlBody = htmlBody.replace('[Link]', '<a href="' + prepHtmlWrap.caseRecord.ECFMG_Portal_Case_Url__c + '">Case Status</a>');        
        htmlBody = htmlBody.replaceAll('<!\\[CDATA\\[', '');
        htmlBody = htmlBody.replaceAll('\\]\\]>', '');
        prepHtmlWrap.message.setHtmlBody(htmlBody);
        return prepHtmlWrap.message;
    }
    public static Messaging.EmailFileAttachment getAttachment(String fileName){
        try{
            String url = CloudStorageUtils.getFileUrlWithSAS(fileName);
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setHeader('Content-Length', '0');
            req.setHeader('x-ms-blob-type', 'BlockBlob');
            req.setHeader('Content-Type', 'application/pdf');
            req.setHeader('x-ms-version', '2019-02-02');
            req.setEndpoint(url);
            HttpResponse res = h.send(req);
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(fileName);
            efa.setBody(res.getBodyAsBlob());
            return efa;
        }
        catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    // Method to send mail when the template is simple text
    public static Messaging.SingleEmailMessage sendCaseStatusTextMail(SendMailWrapper sendMailWrap){
        try{
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message = CaseTriggerHelper.prepareEmail(sendMailWrap.caseRec,sendMailWrap.addr,sendMailWrap.emailTemplate);
            String body = sendMailWrap.emailTemplate.Body;
            message.setPlainTextBody(body);
            return message;
        }catch(Exception ex){
            throw ex;
        }
    }
    // Method to attach file
    public static void attachFiletoEmail(Messaging.SingleEmailMessage message,Blob body,String fileName){
        try{
            Messaging.EmailFileAttachment emailAttach = new Messaging.EmailFileAttachment();
            emailAttach.setBody(body);
            emailAttach.setFileName(fileName + '.pdf');
            message.setFileAttachments(new Messaging.EmailFileAttachment[] {emailAttach});
        }catch(Exception ex){
            throw ex;
        }
    }
    // Method to generate documents by enqueing them
    public static void generateDocHelper(String docConfigId,Case newCase){
        try{
            if(String.isNotBlank(docConfigId)){
                PDFButlerCallout calloutClass = new PDFButlerCallout(docConfigId, newCase.Id);
                System.enqueueJob(calloutClass);
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // Method to populate doc config map
    public static Map<String, cadmus_core__Doc_Config__c> populateDocConfig(){
        try{
            Map<String, cadmus_core__Doc_Config__c> docConfigMap = new Map<String, cadmus_core__Doc_Config__c>();
            for(cadmus_core__Doc_Config__c config :[SELECT Id,Name,cadmus_core__View_Customer_DocConfig_Id__c FROM cadmus_core__Doc_Config__c WITH SECURITY_ENFORCED]){
                docConfigMap.put(config.cadmus_core__View_Customer_DocConfig_Id__c, config);
            }
            return docConfigMap;
        }catch(Exception ex){
            throw ex;
        }
    }
    // Method to create Asset for Exam registration/Eligibility period/Region change.
    // Based on the passed case record, caseId (could be parent Id for Eligibility period/Region change or case Id for Exam Registration) asset is created.
    public static Asset createAsset(Case caseRecord,Id caseId,String type){
        try{
            Asset assetRecord = new Asset();
            assetRecord.Name = type;
            assetRecord.ContactId = caseRecord.contactId;
            assetRecord.Case__c = caseId;
            assetRecord.Status = Constant_Asset__mdt.getInstance('STATUS_IN_PROGRESS').Value__c;
            assetRecord.type__c = type;
            assetRecord.recordTypeId = GenericUtilities.getRecordTypeIdByDevName('Asset',Constant_Asset__mdt.getInstance('RECORD_TYPE_EXAM_REG').Value__c);
            return assetRecord;
        }catch(Exception ex){
            throw ex;
        }
    }
    // Method to update update Asset to outdated for Exam registration/Eligibility period/Region change.
    public static List<Asset> updateAsset(List<sObject> assetRecList){
        try{
            List<Asset> assetsUpd = new List<Asset>();
            for(sObject assetRecSObject:assetRecList){
                Asset assetRec = (Asset)assetRecSObject;
                if(assetRec.Type__c == Constant_Asset__mdt.getInstance('TYPE_SCHEDULING_PERMIT').Value__c
                && assetRec.Status != Constant_Asset__mdt.getInstance('STATUS_OUTDATED').Value__c
                && assetRec.Status != Constant_Asset__mdt.getInstance('STATUS_MARKED_FOR_DELETION').Value__c){
                    assetRec.Status = Constant_Asset__mdt.getInstance('STATUS_OUTDATED').Value__c;
                    assetsUpd.add(assetRec);
                }
            }
            return assetsUpd;
        }catch(Exception ex){
            throw ex;
        }
    }
    // Method to get the service record name. This will be used only for Credential Verification/Medical Education Form.
    public static String getServRecName(String service,String recType){
        return service + '_' + recType;
    }
    // Method to update parent record if the all child cases status is Accepted
    public static Case updParCaseIntStat(Case newCase, Case parent){
        try{
            Set<String> childRecTypes = new Set<String>{Constant_Case__mdt.getInstance('REC_TYPE_CREDENTIAL_VERIFICATION').Value__c,Constant_Case__mdt.getInstance('REC_TYPE_DEV_NAME_REVIEW').Value__c,Constant_Case__mdt.getInstance('REC_TYPE_DEV_BIOGRAPHIC_REVIEW').Value__c};
            Boolean updParent = false;
            if(parent.RecordType.DeveloperName == Constant_Case__mdt.getInstance('REC_TYPE_ECFMG_CERTIFICATION').Value__c
            && (parent.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_INCOMPLETE').Value__c
            || parent.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_RECEIVED_IN_REVIEW').Value__c)
            && !(parent.Cases).isEmpty()){
                for(Case childCase:parent.Cases){
                    if(childRecTypes.contains(childCase.recordType.DeveloperName)){
                        if(childCase.Internal_Status__c != Constant_Case__mdt.getInstance('STATUS_ACCEPTED').Value__c){
                            updParent = false;
                            break;
                        }
                        else if(childCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_ACCEPTED').Value__c){
                            updParent = true;
                        }
                    }
                }
            }
            if(updParent){
                return new Case(Id = newCase.ParentId,Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c,OwnerId = Constants.QUEUE_DEV_ID_MAP.get(Constant_Case__mdt.getInstance('QUEUE_ECFMG_CERTIFICATION').Value__c));
            }
            return null;
        }catch(Exception ex){
            throw ex;
        }
    }
    // Method to update parent record if the child case status is sent or rejected
    public static Case upTransReqdParCase(Case parent){
        try{
            String caseStatusSent = Constant_Case__mdt.getInstance('STATUS_SENT').Value__c;
            String caseStatusRejected = Constant_Case__mdt.getInstance('STATUS_REJECTED').Value__c;
            Boolean updParent = false;
            String internalStatus;
            if(!(parent.Cases).isEmpty()){
                Integer rejCount = 0;
                for(Case childCase : parent.Cases){
                    if(childCase.Internal_Status__c == caseStatusSent){
                        if(parent.Internal_Status__c != caseStatusSent){
                            internalStatus = caseStatusSent;
                            updParent = true;
                            break;
                        }
                    }else if(childCase.Internal_Status__c == caseStatusRejected){
                        rejCount += 1;
                    }
                }
                if(rejCount > 0 && rejCount == parent.Cases.size()){
                    internalStatus = caseStatusRejected;
                    updParent = true;
                }
            }
            if(updParent){
                return new Case(Id = parent.Id, Internal_Status__c = internalStatus);
            }
            return null;
        }catch(Exception ex){
            throw ex;
        }
    }
    // Method to get the account Id from CAT record whose record type is Degree Medical School
    public static Id getAccount(List<Contact_Association_Type__c> catRecs){
        try{
            for(Contact_Association_Type__c catRec : catRecs){
                if(catRec.RecordType.DeveloperName == Constant_CAT__mdt.getInstance('REC_TYPE_DEGREE_MEDICAL_SCHOOL').Value__c && String.isNotBlank(catRec.Account__c)){
                    return catRec.Account__c;
                }
            }
            return null;
        }catch(Exception ex){
            throw ex;
        }
    }
    // fetches network APP 360 URL
    public static String getNetworkApp360(){
        Map<String,Network> networkMap = (Map<String,Network>)GetCommonQueries.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('NETWORK').Value__c);
        String portalUrl = Network.getLoginUrl(networkMap.get(Constant_other__mdt.getInstance('COMMUNITY_NAME_APP_360').Value__c).Id);
        portalUrl = portalUrl.substringBefore('login');
        return portalUrl+'s/case/';
    }
    // Updates OFAC Scan on Contact object
    public static void updateConOFAC(Case newCase,Map<Id,Contact> updateConRecMap,Map<String,sObject> contactMap){
        // checks if contact is not empty
        if(String.isNotBlank(newCase.ContactId) && contactMap.containsKey(newCase.ContactId)){
            Contact conRec = (Contact)(contactMap.get(newCase.ContactId));
            if(!conRec.OFAC_Scan_Required__c){
                conRec.OFAC_Scan_Required__c = true;
                CaseTriggerUtility.updateRec(updateConRecMap,new Contact(Id = conRec.Id,OFAC_Scan_Required__c = true));
            }
        }
    }
    // updates the child's internal status based on the current record's internal status for FCVS service
    // This logic requires relook as per US 18427
    public static void updChildCaseFCVS(Case newCase,Case parentRec,Map<Id,Case> updateCaseRecMap){
        try{
            final String STATUS_PARTIAL_PREVIOUSLY_VERIFIED = Constant_Case__mdt.getInstance('STATUS_PARTIAL_PREVIOUSLY_VERIFIED').Value__c;
            final String STATUS_CV_ACCEPTED = Constant_Case__mdt.getInstance('STATUS_CV_ACCEPTED').Value__c;
            final String STATUS_CV_REJECTED = Constant_Case__mdt.getInstance('STATUS_CV_REJECTED').Value__c;
            final String STATUS_CANCELLED = Constant_Case__mdt.getInstance('STATUS_CANCELLED').Value__c;
            final String STATUS_PREV_VERIFIED_ACCEPTED = Constant_Case__mdt.getInstance('STATUS_PREV_VERIFIED_ACCEPTED').Value__c;
            final String STATUS_SENT_FOR_VERIFICATION = Constant_Case__mdt.getInstance('STATUS_SENT_FOR_VERIFICATION').Value__c;
            final String STATUS_RESENT_FOR_VERIFICATION = Constant_Case__mdt.getInstance('STATUS_RESENT_FOR_VERIFICATION').Value__c;
            final String STATUS_ENROLLMENT_COMPLETED = Constant_Case__mdt.getInstance('STATUS_ENROLLMENT_COMPLETED').Value__c;
            final Integer PREV_VER_ACCEPTED = 2;
            List<Case> childCases = parentRec.Cases;
            if(newCase.Internal_Status__c == STATUS_CV_REJECTED){
                updateCaseChildRejCan(STATUS_CV_REJECTED,childCases,updateCaseRecMap);
            }else if(newCase.Internal_Status__c == STATUS_CANCELLED){
                updateCaseChildRejCan(STATUS_CANCELLED,childCases,updateCaseRecMap);
            }else if(parentRec.Internal_Status__c != STATUS_PREV_VERIFIED_ACCEPTED && (newCase.Internal_Status__c == STATUS_PREV_VERIFIED_ACCEPTED || newCase.Internal_Status__c == STATUS_PARTIAL_PREVIOUSLY_VERIFIED)){
                updateParStatus(STATUS_PREV_VERIFIED_ACCEPTED,parentRec,updateCaseRecMap);
            }else if(newCase.Internal_Status__c == STATUS_SENT_FOR_VERIFICATION){
                updateParStatus(STATUS_SENT_FOR_VERIFICATION,parentRec,updateCaseRecMap);
            }else if(newCase.Internal_Status__c == STATUS_RESENT_FOR_VERIFICATION){
                updateParStatus(STATUS_RESENT_FOR_VERIFICATION,parentRec,updateCaseRecMap);
            }else if(newCase.Internal_Status__c == STATUS_CV_ACCEPTED){
                Integer prvAccepted = 0;
                Integer statusCount = 0;
                for(Case caseRec:childCases){
                    if(caseRec.Internal_Status__c == STATUS_PREV_VERIFIED_ACCEPTED){
                        prvAccepted++;
                    }else if(caseRec.Internal_Status__c == STATUS_CV_ACCEPTED){
                        statusCount++;
                    }
                }
                if(statusCount == childCases.size() || prvAccepted == PREV_VER_ACCEPTED){
                    updateRec(updateCaseRecMap,new Case(Id = parentRec.Id,Internal_Status__c = STATUS_ENROLLMENT_COMPLETED));
                }
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // updates the child record's status if the internal status is either Cv rejected or Cancelled
    // This is for FCVS Case
    public static void updateCaseChildRejCan(String status,List<Case> childCases,Map<Id,Case> updateCaseRecMap){
        try{
            final String STATUS_CANCELLED = Constant_Case__mdt.getInstance('STATUS_CANCELLED').Value__c;
            final String STATUS_CV_ACCEPTED = Constant_Case__mdt.getInstance('STATUS_CV_ACCEPTED').Value__c;
            final String STATUS_CV_REJECTED = Constant_Case__mdt.getInstance('STATUS_CV_REJECTED').Value__c;
            for(Case caseRec:childCases){
                if(caseRec.Internal_Status__c != status && (!(caseRec.Internal_Status__c == STATUS_CV_ACCEPTED) || (caseRec.Internal_Status__c != STATUS_CV_REJECTED) || (caseRec.Internal_Status__c == STATUS_CANCELLED))){
                    caseRec.Internal_Status__c = status;
                    updateRec(updateCaseRecMap,new Case(Id = caseRec.Id,Internal_Status__c = status));
                }
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // Sent for verification/resent for verification update's the status of parent case to the corresponding case.
    // This is for FCVS Case
    public static void updateParStatus(String status,Case parentRec,Map<Id,Case> updateCaseRecMap){
        try{
            List<Case> childCases = parentRec.Cases;
            Boolean updStatus = true;
            for(Case caseRec:childCases){
                if(caseRec.Internal_Status__c != status){
                    updStatus = false;
                }
            }
            if(updStatus && parentRec.Internal_Status__c != status){
                parentRec.Internal_Status__c = status;
                CaseTriggerUtility.updateRec(updateCaseRecMap,new Case(Id = parentRec.Id,Internal_Status__c = status));
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // populates Account Id and Case Ids to be used for Case sharing
    public static void populatesAccCaseMap(Map<Id,Set<Id>> accCaseIdMap, List<Case> caseList, String caseType){
        try{
            for(Case cse : caseList){
                Id accId;
                if(caseType == Constant_Case__mdt.getInstance('REC_TYPE_DEV_ENROLLMENT_VERIFICATION').Value__c && String.isNotBlank(cse.AccountId)){
                    accId = cse.AccountId;
                }else if(caseType == Constant_Data_Key__mdt.getInstance('EV_CHILD_CASES').Value__c && String.isNotBlank(cse.Enrollment_Verification_Parent__r.AccountId)){
                    accId = cse.Enrollment_Verification_Parent__r.AccountId;
                }else if(caseType == Constant_Case__mdt.getInstance('REC_TYPE_ELIGIBILITY_PERIOD').Value__c && String.isNotBlank(cse.Parent.Enrollment_Verification_Parent__r.AccountId)){
                    accId = cse.Parent.Enrollment_Verification_Parent__r.AccountId;
                }
                if(accCaseIdMap.containsKey(accId)){
                    accCaseIdMap.get(accId).add(cse.Id);
                }else{
                    accCaseIdMap.put(accId, new Set<Id>{cse.Id});
                }
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    //Method to update the EV Case Status as Enrollment Verification Complete
    public static void updateEVCaseStatus(Case evNewCase, String evManualRejectedReason){
        try{
            final String data_key_ev_child_exam_reg_cases = Constant_Data_Key__mdt.getInstance('EV_CHILD_EXAM_REG_CASES').Value__c;
            final String case_status_enrollment_verification_complete = Constant_Case__mdt.getInstance('STATUS_ENROLLMENT_VERIFICATION_COMPLETE').Value__c;
            final String case_status_pending_cibis = Constant_Case__mdt.getInstance('STATUS_PENDING_CIBIS').Value__c;
            final String case_status_registered = Constant_Case__mdt.getInstance('STATUS_REGISTERED').Value__c;
            final String case_status_enrollment_not_verified_medscl = Constant_Case__mdt.getInstance('STATUS_ENROLLMENT_NOT_VERIFIED_MEDS').Value__c;
            Map<String,List<sObject>> evExamRegCaseMap = CaseTriggerDataInitialize.fetchGenericDataSObjectList(data_key_ev_child_exam_reg_cases);
            Map<String,sObject> examRegCaseMap = CaseTriggerDataInitialize.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('CHILD_CASE_RECORDS').Value__c);
            List<Case> casesToUpdate =   new List<Case>();
            MAP<ID, Case> examRegCaseEnrollMap = new MAP<ID, Case>();
            MAP<ID, Case> epexCaseMap = new MAP<ID, Case>();
            List<Case> examRegCases = evExamRegCaseMap.containsKey(evNewCase.Id) ? (List<Case>)evExamRegCaseMap.get(evNewCase.Id) : new List<Case>();
            List<String> statusList = new List<String>();
            statusList.add(case_status_pending_cibis);
            statusList.add(case_status_registered);
            statusList.add(case_status_enrollment_not_verified_medscl);
            for(Case examRegCaseRecord : examRegCases){
                // Exam Reg Case based on without any condition                                    
                if(String.isNotBlank(evManualRejectedReason)){
                    Case exCase = new Case(Id = examRegCaseRecord.Id);
                    exCase.Manual_Review_Reasons__c = evManualRejectedReason;
                    casesToUpdate.add(exCase);
                    examRegCaseRecord.Manual_Review_Reasons__c = evManualRejectedReason;
                }
                // Exam Reg Case based on  "Pending CIBIS" or "Registered" or "Enrollment Not Verified At Medical School";
                if(!statusList.contains(examRegCaseRecord.Internal_Status__c)){
                    examRegCaseEnrollMap.put(examRegCaseRecord.Enrollment_Verification_Parent__c, examRegCaseRecord);
                }
                updateEVCaseStatusRefactor(examRegCaseRecord, examRegCaseMap, epexCaseMap);   
            }
            // Exam Reg Case based on  "Pending CIBIS" or "Registered" or "Enrollment Not Verified At Medical School";  
            Case examRegCase = examRegCaseEnrollMap.get(evNewCase.Id);
            // EPEx Cases (EPEx Applications)
            Case epexCase = epexCaseMap.get(evNewCase.Id); 
            if(examRegCase == null && epexCase == null){
                Case evCaseOBj = new Case(Id = evNewCase.Id, Internal_Status__c = case_status_enrollment_verification_complete);
                evNewCase.Internal_Status__c = case_status_enrollment_verification_complete;
                casesToUpdate.add(evCaseOBj);
            }
            if(!casesToUpdate.isEmpty() && GenericUtilities.checkIsUpdatable('Case')){
                CaseTriggerUtility.updateDMLMap(casesToUpdate);
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }
    public static void updateEVCaseStatusRefactor(Case examRegCaseRecord, Map<String,sObject> examRegCaseMap, MAP<ID, Case> epexCaseMap){
        try{
            final String case_status_pending_cibis = Constant_Case__mdt.getInstance('STATUS_PENDING_CIBIS').Value__c;
            final String case_status_rejected = Constant_Case__mdt.getInstance('STATUS_REJECTED').Value__c;
            final String case_status_accepted = Constant_Case__mdt.getInstance('STATUS_ACCEPTED').Value__c;
            Case erCase = examRegCaseMap.containsKey(examRegCaseRecord.Id) ? (Case)examRegCaseMap.get(examRegCaseRecord.Id) : new Case();
            List<Case> epexCases = !(erCase.Cases.isEmpty()) ? erCase.Cases : new List<Case>();
            List<String> statusListEpex = new List<String>();
            statusListEpex.add(case_status_pending_cibis);
            statusListEpex.add(case_status_rejected);
            statusListEpex.add(case_status_accepted);
            for(Case epexCase : epexCases){
                if(!statusListEpex.contains(epexCase.Internal_Status__c)){
                    epexCaseMap.put(epexCase.Enrollment_Verification_Parent__c, epexCase);  
                }                    
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    //Method to calculate SLA date on exam registration
    public static Exam_Registration__c calculateSLADate(Case examRegCase, Exam_Registration__c examReg){
        try{
            if(examRegCase.Enrollment_Verification_Parent__r.Enrolled_in_Entity_Portal__c == true){
                if(!examRegCase.Cases.isEmpty()){
                    examReg.SLA_Date__c = examReg.EP_end_Date__c.addMonths(2).toStartOfMonth();
                }
                else{
                    examReg.SLA_Date__c = examRegCase.CreatedDate.date().addMonths(12);
                }
            }
            else{
                if(!examRegCase.Cases.isEmpty()){
                    examReg.SLA_Date__c = examReg.EP_end_Date__c.addMonths(2).toStartOfMonth().addDays(7);
                }
                else{
                    examReg.SLA_Date__c = examRegCase.CreatedDate.date().addMonths(12).addDays(7);
                }
            }
            return examReg;
        }catch(Exception ex){
            throw ex;
        }
    }
    // Wrapper class to send email
    public class SendMailWrapper{
        public Case caseRec;
        public OrgWideEmailAddress addr;
        public EmailTemplate emailTemplate;
        public Contact con;
    }
    public class PrepareHtmlWrapper{
        public Case caseRecord = new Case();
        public string htmlBody = '';
        public Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        public Contact con = new Contact();
    }
}