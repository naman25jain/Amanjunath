public class CibisUtility {
    // Variable Declaration
    public static map<String,set<String>> flagInfoMap=new map<String,set<String>>();
    public static map<String, String> cibisStatusMap = new map<String, String>{Constants.CIBIS_NOTES_REQUEST_EVENT =>'USMLE;NBME;FSMB;ECFMG;',
        Constants.CIBIS_USMLE_TRANSCRIPT_NOTES_EVENT => 'USMLE', 
        Constants.CIBIS_NBME_TRANSCRIPT_NOTES_EVENT => 'NBME',
        Constants.CIBIS_FSMB_TRANSCRIPT_NOTES_EVENT => 'FSMB', 
        Constants.CIBIS_ECFMG_TRANSCRIPT_NOTES_EVENT => 'ECFMG',
        Constants.CIBIS_APPLICANT_IRREGULAR_BEHAVIOR_EVENT => 'APP IRREGULAR', 
        constants.CIBIS_EXAM_HISTORY_IRREGULAR_BEHAVIOR_EVENT => 'EXAM IRREGULAR', 
        Constants.CIBIS_SECR_DOCURL_EVENT => 'SECR DOC',
        Constants.CIBIS_SECR_DOCINFO_EVENT => 'SECR DOC',
        Constants.CIBIS_SECR_DOCINFO_EVENT_NA => 'USMLE;NBME;FSMB;ECFMG;SECR DOC;'}; 
            Public static map<string,string> examTypeMap=new map<String,String>{'STEP1'=>'USMLE Step 1','STEP2'=>'USMLE Step 2 CK','STEP3'=>'STEP 3','STEP2CS'=>'USMLE Step 2 CS'};
                public Static Map<String, Id> rectypeIdSet = GenericUtilities.getRecordTypeDevNameIdMapByDevNames('Exam_Registration__c', new set<String>{'NON_USMLE','USMLE'});
    
    public static map<String,Cibis_Annoatation__mdt> cibisAnnotationsMap=new map<String,Cibis_Annoatation__mdt>();
    public static list<Case> caseList=new list<Case>();
    
    /**
* 14 Oct 2021
* Method Name: Handle Cibis Platform Event Trigger Logic
* Purpose:Cibis logic is trimmed as part of recursion to avoid that adding cibis mothod after update logic
*/
    
    public static void invokeCibisPlatformEventLogic(List<Case> nCases, Map<Id, Case> oCaseMap){
        try{
            System.debug('Inisde invokeCibisPlatformEventLogic method'+nCases);
            System.debug('Inisde invokeCibisPlatformEventLogic'+oCaseMap);
            
            map < String, Set < Id >> cibisIdMap = new map < String, Set < Id >> { 
                Constants.CIBIS_CANDIDATE_EVENT => new set < Id > (),
                    Constants.CIBIS_REGISTRATION_EVENT => new set < Id > (),
                    Constants.CIBIS_EXAM_EVENT => new set < Id > (),
                    Constants.CIBIS_ELIGIBILITY_EVALUATION_EVENT => new set < Id > ()
                    };
                        
                        for(Case newCase: nCases){
                            if(oCaseMap!=null){
                                System.debug('Inisde invokeCibisPlatformEventLogic=> newCase.Internal_Status__c'+newCase.Internal_Status__c);
                                System.debug('Inisde invokeCibisPlatformEventLogic => CaseMap.get(newCase.Id).Internal_Status__c'+ oCaseMap.get(newCase.Id).Internal_Status__c);
                                if(newCase.Internal_Status__c!=oCaseMap.get(newCase.Id).Internal_Status__c  && newCase.Internal_Status__c == Constants.CASE_STATUS_PENDING_CIBIS ){
                                    
                                    if(newCase.Internal_Status__c == Constants.CASE_STATUS_PENDING_CIBIS && newCase.RecordTypeId == GenericUtilities.getRecordTypeIdByDevName('Case',Constants.CASE_RECORD_TYPE_REGION_CHANGE)) {
                                        // Capturing region change Case Ids for Cibis  
                                        cibisIdMap.get(Constants.CIBIS_EXAM_EVENT).add(newCase.ParentId);
                                    }    
                                    if(newCase.Internal_Status__c == Constants.CASE_STATUS_PENDING_CIBIS && newCase.RecordTypeId == GenericUtilities.getRecordTypeIdByDevName('Case',Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION)) {
                                        // Capturing Exam registration Case Ids for Cibis  
                                        cibisIdMap.get(Constants.CIBIS_REGISTRATION_EVENT).add(newCase.Id);
                                    }  
                                    if(newCase.Internal_Status__c == Constants.CASE_STATUS_PENDING_CIBIS && newCase.RecordTypeId == GenericUtilities.getRecordTypeIdByDevName('Case',Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD)) {
                                        // Capturing Eligiblity registration Case Ids for Cibis
                                        cibisIdMap.get(Constants.CIBIS_ELIGIBILITY_EVALUATION_EVENT).add(newCase.Id);  
                                    }  
                                    if(newCase.Internal_Status__c == Constants.CASE_STATUS_PENDING_CIBIS && newCase.RecordTypeId == GenericUtilities.getRecordTypeIdByDevName('Case',Constants.CASE_RECORD_TYPE_APP_FOR_CERT)) {
                                        // Capturing App for Cert registration Case Ids for Cibis
                                        cibisIdMap.get(Constants.CIBIS_CANDIDATE_EVENT).add(newCase.Id);  
                                    }
                                    
                                }
                            }
                            else if(newCase.Internal_Status__c == Constants.CASE_STATUS_PENDING_CIBIS){
                                
                                System.debug('Inisde invokeCibisPlatformEventLogic=> newCase.Internal_Status__c'+newCase.Internal_Status__c);
                                if(newCase.Internal_Status__c == Constants.CASE_STATUS_PENDING_CIBIS && newCase.RecordTypeId == GenericUtilities.getRecordTypeIdByDevName('Case',Constants.CASE_RECORD_TYPE_REGION_CHANGE)) {
                                    // Capturing region change Case Ids for Cibis  
                                    cibisIdMap.get(Constants.CIBIS_EXAM_EVENT).add(newCase.ParentId);
                                }    
                                if(newCase.Internal_Status__c == Constants.CASE_STATUS_PENDING_CIBIS && newCase.RecordTypeId == GenericUtilities.getRecordTypeIdByDevName('Case',Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION)) {
                                    // Capturing Exam registration Case Ids for Cibis  
                                    // removed due to exam registration cloning issue cibisIdMap.get(Constants.CIBIS_REGISTRATION_EVENT).add(newCase.Id);
                                }  
                                if(newCase.Internal_Status__c == Constants.CASE_STATUS_PENDING_CIBIS && newCase.RecordTypeId == GenericUtilities.getRecordTypeIdByDevName('Case',Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD)) {
                                    // Capturing Eligiblity registration Case Ids for Cibis
                                    cibisIdMap.get(Constants.CIBIS_ELIGIBILITY_EVALUATION_EVENT).add(newCase.Id);  
                                }
                                if(newCase.Internal_Status__c == Constants.CASE_STATUS_PENDING_CIBIS && newCase.RecordTypeId == GenericUtilities.getRecordTypeIdByDevName('Case',Constants.CASE_RECORD_TYPE_APP_FOR_CERT)) {
                                    // Capturing App for Cert registration Case Ids for Cibis
                                    cibisIdMap.get(Constants.CIBIS_CANDIDATE_EVENT).add(newCase.Id);  
                                }  
                            }          
                        }
            set<Id> caseIds=new set<ID>();
            For(string str:cibisIdMap.keyset()){
                if(cibisIdMap.containskey(str) && cibisIdMap.get(str)!=null){
                    caseIds.addAll(cibisIdMap.get(str));  
                }
            }

            System.debug('*****isFirstTimeCibis'+RecursiveTriggerHandler.isFirstTimeCibis);
            /*Publish Platform events-Exam Registrations,Region Changes,Eligibility Period Extension*/
            if (!caseIds.isEmpty() && caseIds!=null) { 
                System.debug('*****isFirstTimeCibis'+RecursiveTriggerHandler.isFirstTimeCibis);
                 RecursiveTriggerHandler.isFirstTimeCibis = false;    
                CibisRequestUtilityHandler.cibisPlatformEventPublish(cibisIdMap);
            }
        }
        catch(Exception e){
            System.debug('**CibisUtility + invokeCibisPlatformEventLogic Method ==> '+e.getMessage());
            System.debug('**CibisUtility + invokeCibisPlatformEventLogic Method ==> '+e.getStackTraceString());
            System.debug('**CibisUtility + invokeCibisPlatformEventLogic Method ==> '+e.getLineNumber());
            System.debug('**CibisUtility + invokeCibisPlatformEventLogic Method ==> '+e.getCause());
        }
        
        
    }
    
    // Method to create Case Related data
    Public static void createCaseRelatedData(set<Id> caseIds){
        try{
            if(!caseIds.isEmpty() && caseIds!=null){
                //OrgWideEmailAddress owea=[select id, Address from OrgWideEmailAddress where Address='salesforceadmin@ecfmg.org' limit 1];
                Id assetIdRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Identity').getRecordTypeId();
                Id prdIdenityRecTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Identity').getRecordTypeId();
                Id affriIDVerifyRecTypeId = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByName().get('ID_Verification').getRecordTypeId(); 
                Id queueId = [SELECT Id FROM Group WHERE Type='Queue' AND DeveloperName=:Constants.CASE_QUEUE_ID_Verification_Queue].Id;    
                Id prdId=[Select id from product2 where Name='ID Form' AND RecordTypeID=:prdIdenityRecTypeId limit 1].Id; 
                list<Asset> assetList=new list<Asset>();
                list<Case> caseUpdateLst=new list<Case>();
                For(Case cs:[Select id,ContactId,Contact.Email,Contact.LastName,Contact.Firstname from Case where Id IN:caseIds AND ContactID!=null]){
                    assetList.add(new Asset(Product2Id=prdId,recordTypeId=assetIdRecTypeId,Case__c=cs.Id,InstallDate=Date.today(),
                                            Name='ID Form Template',status='In Progress',Type__c='ID Verification',contactId=cs.ContactId));
                    caseUpdateLst.add(new Case(Id=cs.Id,Internal_Status__c=Constants.CASE_STATUS_INTERNAL_PENDING_APPLICANT_ACTION_NOTARIZE_ID,OwnerId=queueId,contactId=cs.ContactId));
                }
                if(!assetList.isEmpty() && Schema.sObjectType.Asset.isCreateable()){
                    list<Affirmation__c> affirmationsList=new list<Affirmation__c>();
                    database.saveresult[] srlist= database.insert(assetList,false); 
                    for (Database.SaveResult sr : srList) {
                        if (sr.isSuccess()) {                    
                            affirmationsList.add(new Affirmation__c(Asset__c=sr.getId(),RecordTypeId=affriIDVerifyRecTypeId,status__c='In Progress'));                    
                        }
                        else {                    
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('Asset fields that affected this error: ' + err.getFields());
                            }
                        }                
                    }
                    if(!affirmationsList.isEmpty() && Schema.sObjectType.Affirmation__c.isCreateable()){
                        System.debug('*****assetList'+assetList);     
                        insertSobjects(affirmationsList);
                    }
                    if(!caseUpdateLst.isEmpty() && Schema.sObjectType.Case.isUpdateable()){
                        System.debug('*****caseUpdateLst'+caseUpdateLst);     
                        updateSobjects(caseUpdateLst);
                        sendEmailToContacts(caseUpdateLst);
                    }
                }
                
            }
        }catch(Exception e){
            System.debug('**CibisUtility ==> '+e.getMessage());
        }
    }
    // Method to Insert Sobjects
    Public static void insertSobjects(list<Sobject> lstObjects){
        database.saveresult[] srlist= database.insert(lstObjects,false); 
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {                    
                System.debug('Sobject Inserted ' + sr.getId());
            }
            else {                    
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Sobject fields that affected this error: ' + err.getFields());
                    System.debug('Inserted erro message ' + err.getMessage());
                }
            }                
        }
    }
    // Method to Upsert Exam Registration Records
    Public static void upsertExamRegRecords(list<Sobject> lstObjects){
        Database.UpsertResult[]  srList=Database.upsert(lstObjects, Exam_Registration__c.Exam_Reg_External_Id__c,false);
        for (Database.UpsertResult sr : srList) {
            if (sr.isSuccess()) {                    
                System.debug('Sobject Inserted ' + sr.getId());
            }
            else {                    
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Sobject fields that affected this error: ' + err.getFields());
                    System.debug('Inserted erro message ' + err.getMessage());
                }
            }                
        }
    }
    // Method to Update Sobject Records
    Public static void updateSobjects(list<Sobject> lstObjects){
        System.debug('****lstObjects'+lstObjects);
        database.saveresult[] srlist= database.update(lstObjects,false); 
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {                    
                System.debug('Sobject updated ' + sr.getId());
            }
            else {                    
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Sobject fields that affected this error: ' + err.getFields());
                    System.debug('errorMessage'+err.getMessage());
                }
            }                
        }  
    }
    
    // Method to send Email to Contacts
    Public static void sendEmailToContacts(list<Case> caseList)
    {
        Content_Manager__c contentMgr=getContentManagerInfo('CIBIS Contact Email');
        if(contentMgr!=null){
            OrgWideEmailAddress owea=[select id, Address from OrgWideEmailAddress where Address='salesforceadmin@ecfmg.org' limit 1];
            list<Messaging.SingleEmailMessage> sendEmails=new list<Messaging.SingleEmailMessage>();
            For(Case cse:caseList){            
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
                email.setTargetObjectId(cse.ContactId);
                email.setOrgWideEmailAddressId(owea.ID);
                string body='Dear '+cse.Contact.FirstName+' '+cse.Contact.LastName+'<br/><br/>';
                email.setSubject(contentMgr.Subject__c<> null ? contentMgr.Subject__c:'Status Update Available In ECFMG Portal');
                email.setHtmlBody(body+contentMgr.Content__c);     
                sendEmails.add(email);
                System.debug('cse.ContactId'+cse.ContactId);
                System.debug('sendEmailToContacts'+email);
            }
            Messaging.sendEmail(sendEmails);   
        }
    }
    // Method to retrieve Content Manager record
    public static Content_Manager__c getContentManagerInfo(String strConfirmType) {
        if(String.isNotBlank(strConfirmType)) {            
            return [SELECT Id, Name, Content__c, Page_Name__c,Subject__c, Process_Flow__c, Unique_Name__c  From Content_Manager__c WHERE Name =:strConfirmType limit 1];
        }
        else{
            return null;
        }
        
    }
    // Method to create Exam Registration case
    Public static void createExamRegCases(map<Id,Case> regChangeCaseMap){ 
        Try{
            if(!regChangeCaseMap.isEmpty()){
                list<Case> caseLst=new list<Case>();  
                //Map<String,Id> ccsId = new Map<String, Id>();
                For(Id cid:regChangeCaseMap.keyset()){
                    caseLst.add(new case(Id=cid,internal_status__c=Constants.CASE_STATUS_CANCELLED,Region_Change_Cancellation__c=TRUE,Reason_for_Cancellation__c='Cancelled due to region change',External_Status__c=Constants.CASE_STATUS_CANCELLED));
                }                
                updateSobjects(caseLst);
                SET<ID> examRegCaseIds = regChangeCaseMap.keyset();
                string query=returnQueryByFieldSet('CASE',Constants.CASE_EXAM_REGISTRATION_FIELD_SET);
                query+=' Where ID IN:examRegCaseIds AND internal_status__c=\''+Constants.CASE_STATUS_CANCELLED+'\'';
                
                caseLst=new list<Case>();
                For(Case cs:Database.query(query)){
                    Case regChangeCase=regChangeCaseMap.containskey(cs.Id) ? regChangeCaseMap.get(cs.Id) : null;
                    System.debug('***regChangeCase***'+regChangeCase); 
                    Case c=cs.clone(false,TRUE);
                    c.Internal_Status__c=Constants.CASE_STATUS_PENDING_CIBIS;
                    c.Exam_Region__c=regChangeCase!=null ? regChangeCase.Exam_Region__c : null;
                    System.debug('parentId'+ regChangeCase.Id); 
                    c.parentId=regChangeCase.Id;
                    c.OwnerId=regChangeCase.OwnerID;
                    c.Product_Detail__c=regChangeCase!=null ? regChangeCase.Product_Detail__c : null;
                    System.debug('***Exam Registration Case***'+c); 
                    System.debug('parentId'+ c.parentId); 
                    //ccsId.put(cs.ContactId,cs.)
                    caseLst.add(c);
                }
                if(!caseLst.isEmpty()){
                    Insert caseLst;
                    createExamRegistrations(regChangeCaseMap,caseLst);
                    publishExamRegClonedCase(caseLst);
                }
                
            }  
        }
        Catch(Exception e){
            System.debug('***CibisUtilitycaseUpdate***'+e.getMessage()); 
        }
        
    }
    // Method to clone Exam Registration case 
    Public static void publishExamRegClonedCase(list<Case> caseLst){
        map < String, Set < Id >> cibisIdMap = new map < String, Set < Id >> {Constants.CIBIS_REGISTRATION_EVENT => new set < Id > ()};
            For(Case newCase:caseLst){
                if(newCase.Internal_Status__c == Constants.CASE_STATUS_PENDING_CIBIS && newCase.RecordTypeId == GenericUtilities.getRecordTypeIdByDevName('Case',Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION)) {
                    // Capturing Exam registration cloned Case Ids for Cibis  
                    cibisIdMap.get(Constants.CIBIS_REGISTRATION_EVENT).add(newCase.Id);
                } 
            }     
        /*Publish Platform events-Exam Registrations*/
        if (!cibisIdMap.values().isEmpty()) { 
            CibisRequestUtilityHandler.cibisPlatformEventPublish(cibisIdMap);
        }
    }
    // Method to create Exam Regustration
    Public static void createExamRegistrations(map<Id,Case> regChangeCaseMap,list<Case> clonedCases){
        Map<String,Id> cIds = new Map<String,Id>();
        
        for(Case cs: clonedCases){
            cIds.put(cs.ContactId+cs.Exam_Type__c,cs.Id);
        }
        SET<ID> examRegCaseIds = regChangeCaseMap.keyset();
        string erQuery=returnQueryByFieldSet('Exam_Registration__c',Constants.EXAM_REGISTRATION_FIELD_SET);
        erQuery+=' where Case__c IN:examRegCaseIds';
        System.debug('***query***'+erQuery); 
        List<Exam_Registration__c> eRLst=new list<Exam_Registration__c>();
        For(Exam_Registration__c er:Database.query(erQuery)){
            if(er.Applicant__c!=null && er.Exam_Types__c!=null){
                Case regChangeCase=regChangeCaseMap.containskey(er.Case__c) ? regChangeCaseMap.get(er.Case__c) : null;
                System.debug('***regChangeCase***'+regChangeCase);
                Exam_Registration__c erObj=er.clone(false,TRUE);
                erObj.Case__c = cIds.get(er.Applicant__c+er.Exam_Types__c); 
                erObj.OwnerId=er.OwnerId;
                erObj.Product_Detail__c=regChangeCase!=null ? regChangeCase.Product_Detail__c : null;
                erObj.Surcharge__c=regChangeCase!=null ? regChangeCase.Surcharge__c : null;
                eRLst.add(erObj);
            }
            
        }
        if(!eRLst.isEmpty()){
            insertSobjects(eRLst);
        }
        
        
    }
    
    // Method to Construct SOQL query
    Public static string returnSOQL(string ObjectName){   
        String soqlQuery='';
        Map<String, Schema.SObjectField> fieldmap = Schema.getGlobalDescribe().get(ObjectName).getDescribe().fields.getMap();
        
        For(string key:fieldmap.keyset())  {
            Schema.DescribeFieldResult field= fieldMap.get(key).getDescribe();
            if(field.isCreateable()){
                if(soqlQuery=='' || soqlQuery==null){
                    soqlQuery='Select '+ field.name;  
                }
                else{
                    soqlQuery +=','+field.name;  
                }
            }  
            
        }  
        
        return soqlQuery;
    }
    
    // Method to return Query By Field Set
    Public static string returnQueryByFieldSet(string ObjectName,String fieldSetName){
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        list<Schema.FieldSetMember> fieldSetFields=DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName).getFields();   
        string soqlQuery='';
        For(Schema.FieldSetMember field:fieldSetFields){        
            if(soqlQuery=='' || soqlQuery==null){
                soqlQuery='SELECT '+ field.getFieldPath(); 
            }
            else{
                soqlQuery +=','+field.getFieldPath();  
            }
        }
        soqlQuery+= ' From '+ ObjectName;
        return soqlQuery;
        
    }
    //Method to retrieve Cibis Annotations
    Public static map<String,Cibis_Annoatation__mdt> getCibisAnnoations(){
        map<String,Cibis_Annoatation__mdt> cibisAnnotationMap=new map<String,Cibis_Annoatation__mdt>();
        if(cibisAnnotationMap.isEmpty()){
            for(Cibis_Annoatation__mdt mdtObj:[Select ANNOTATION_CODE__c,SHORT_TEXT__c,Cibis_Transcript_Status__c,MasterLabel,ACTIVE__c,ANNOTATION_TEXT__c,Response__c,Sort_Order__c from Cibis_Annoatation__mdt]){
                cibisAnnotationMap.put(mdtObj.MasterLabel,mdtObj);         
            }     
        }        
        return cibisAnnotationMap;
    } 
    
    // Process USMLE Transcript Notes
    Public static void processUSMLETranscriptNotes(map<String, map<String,Object>> responseMap){      
        Map<String,Set<Id>> cibisIdMap=new Map<String,Set<Id>>();
        list<Transcript_Anotation__c> transAnnotsList=new list<Transcript_Anotation__c>();
        if(cibisAnnotationsMap.isEmpty())
        {
            cibisAnnotationsMap = getCibisAnnoations();      
        }      
        For(String transId:responseMap.keyset())
        {
            
            String [] tkeys=transId?.split('-');  
            Map<String,Object> notesMap=responseMap.get(transId);          
            cibisIdMap.put(constants.CIBIS_EXAM_HISTORY_IRREGULAR_BEHAVIOR_EVENT,new set<Id>{tkeys[2]}); 
            For(String myStr:notesMap?.keyset()){  
                
                if(cibisAnnotationsMap?.containskey(myStr+notesMap.get(myStr)))
                {
                    Cibis_Annoatation__mdt mdtAnnotObj=cibisAnnotationsMap.get(myStr+notesMap.get(myStr));
                    if(myStr=='nonAdminIrregularityStatus' && notesMap.get(myStr)=='P'){ 
                        list<String> lstdescriptors=new list<String>();
                        For(Object obj:(list<Object>)notesMap?.get('irregularBehavior')){
                            Map<String, Object> irreObj= (Map<String, Object>)obj;   
                            lstdescriptors.add(string.valueOf(irreObj.get('Description'))); 
                            
                            String annotationText=(lstdescriptors!=null && !lstdescriptors.isEmpty()) ? mdtAnnotObj.ANNOTATION_TEXT__c.replace('[!DESCRIPTORS]','<b>'+lstdescriptors+'</b>') :'';
                            
                            transAnnotsList.add(new Transcript_Anotation__c(Transcript_Case__c=tkeys[2],Contact__c=tkeys[1],ACTIVE__c=mdtAnnotObj.ACTIVE__c,SORT_ORDER__c=Integer.valueOf(mdtAnnotObj.Sort_Order__c),
                                                                            ANNOTATION_TEXT__c=annotationText,ANNOTATION_CODE__c=string.valueOf(mdtAnnotObj.ANNOTATION_CODE__c),
                                                                            SHORT_TEXT__c=mdtAnnotObj.SHORT_TEXT__c,Cibis_Transcript_Status__c=mdtAnnotObj.Cibis_Transcript_Status__c));  
                        } 
                        
                    }
                    else {
                        transAnnotsList.add(new Transcript_Anotation__c(Transcript_Case__c=tkeys[2],Contact__c=tkeys[1],ACTIVE__c=mdtAnnotObj.ACTIVE__c,SORT_ORDER__c=Integer.valueOf(mdtAnnotObj.Sort_Order__c),
                                                                        ANNOTATION_TEXT__c=mdtAnnotObj.ANNOTATION_TEXT__c,ANNOTATION_CODE__c=string.valueOf(mdtAnnotObj.ANNOTATION_CODE__c),
                                                                        SHORT_TEXT__c=mdtAnnotObj.SHORT_TEXT__c,Cibis_Transcript_Status__c=mdtAnnotObj.Cibis_Transcript_Status__c)); 
                    }         
                    
                }
                
                else if(myStr=='irregularBehavior'){             
                    For(Object obj:(list<Object>)notesMap?.get('irregularBehavior')){
                        Map<String, Object> irreObj= (Map<String, Object>)obj;
                        transAnnotsList.add(new Transcript_Anotation__c(Transcript_Case__c = tkeys[1],Contact__c = tkeys[2],
                                                                        SHORT_TEXT__c=String.valueOf(irreObj.get('Description')),ANNOTATION_TEXT__c=String.valueOf(irreObj.get('Explanation')), Cibis_Transcript_Status__c = Constants.APP_IRREGULAR));   
                    }
                }                  
            }             
        }
        
        if(!transAnnotsList.isEmpty()){
            insertSobjects(transAnnotsList);  
        }
        if(cibisIdMap != null && !cibisIdMap.isEmpty()) {
            CibisRequestUtilityHandler.cibisPlatformEventPublish(cibisIdMap);  
        }          
    }
    
    public static Boolean isNewValue(String newValue, String[] selectedValues){
        for(String eachValue : selectedValues){
            if(eachValue.equalsIgnoreCase(newValue)){
                return false;
            }
        }
        return true;
    }
    
    // Method to Construct Unique Key for Exam Registration Record
    public static void constructExamRegExternalId(Map<String, String> mapKeyAndValue) {
        list<Exam_Registration__c> lstExitsExams = [SELECT Id, USMLE_ID_CIBIS__c,Applicant__r.USMLE_ID__c , Exam__c, Case__c, Application_Id__c , Exam_Reg_External_Id__c FROM Exam_Registration__c WHERE Case__c IN:mapKeyAndValue.keySet()];
        
        if(lstExitsExams != null && !lstExitsExams.isEmpty()) {
            for(Exam_Registration__c iterator : lstExitsExams) {
                String strKey = iterator?.Applicant__r?.USMLE_ID__c+'-'+mapKeyAndValue?.get(iterator.Case__c)+'-'+iterator?.Exam__c;
                iterator.Application_Id__c = Decimal.valueOf(mapKeyAndValue?.get(iterator.Case__c));
                iterator.Exam_Reg_External_Id__c = strKey;
            } 
            updateSobjects(lstExitsExams);
        }
    }
    
    
    // Method to update Secratary Document Data
    public static void updateSecrDocData(map<String,map<String,Object>> responseMap)
    {
        if(responseMap != null && !responseMap.isEmpty()) {
            map<Id, Case> mapCases = new map<Id, Case>();
            list<Contact> lstConsToUpdate = new list<Contact>();
            Map<String,Set<Id>> cibisIdMap=new Map<String,Set<Id>>();
            For(string transId:responseMap.keyset()) {
                String [] tkeys=transId?.split('-');  
                cibisIdMap.put(Constants.CIBIS_APPLICANT_IRREGULAR_BEHAVIOR_EVENT,new set<Id>{tkeys[2]});
                Map<String,Object> objData=responseMap.get(transId);
                list<string> mydate=string.valueOf(objData.get('updatedAt')).split('T');
                lstConsToUpdate.add(new Contact(Id=tkeys[1],SecrDoc_Updated_Dtime__c=Date.valueOf(mydate[0]), Secr_Doc_Azure_Blob_URL__c = String.valueOf(objData.get('secretariatDocumentImageBLOB'))));
            } 
            if(lstConsToUpdate != null && !lstConsToUpdate.isEmpty()) {
                updateSobjects(lstConsToUpdate);
            }
            if(cibisIdMap!=null && !cibisIdMap.isEmpty()){
                CibisRequestUtilityHandler.cibisPlatformEventPublish(cibisIdMap);  
            } 
        }
    }
    
    //Method to Process Exam Registration History data
    Public Static void processExamHistory(map<String, list<CibisExamHistoryResponseEventWrap.payload>> responseMap){
        List<Exam_Registration__c> examList = new List<Exam_Registration__c>();
        
        for(String conId:responseMap.keySet()){            
            for(CibisExamHistoryResponseEventWrap.payload eHistory:responseMap.get(conId)){
                examList.add(getExamRegMapping(eHistory,conId));
            }
        }
        if(examList!=null && examList.size()>0 ){
            upsertExamRegRecords(examList);
        }
        
    }
    
    // Method to Process Exam Registration data
    Public static Exam_Registration__c getExamRegMapping(CibisExamHistoryResponseEventWrap.payload examRegObj,Id contactId ){   
        Exam_Registration__c exg=new Exam_Registration__c();
        exg.USMLE_ID_CIBIS__c=isNotEmpty(examRegObj.USMLEId) ? examRegObj.USMLEId :'';
        exg.Applicant__c=contactId;
        exg.Exam_Types__c=isNotEmpty(examRegObj.Exam)  ? examRegObj.Exam:''; 
        if(Exam_Registration_Config_Data__mdt.getInstance(examRegObj.exam.replace(' ','_').replace('-','_'))!=null){
            system.debug('recordTypeId'+GenericUtilities.getRecordTypeIdByDevName(Exam_Registration_Config_Data__mdt.getInstance(examRegObj.exam.replace(' ','_').replace('-','_')).Obj_Name__c,Exam_Registration_Config_Data__mdt.getInstance(examRegObj.exam.replace(' ','_').replace('-','_')).Record_Type_Developer_Name__c));
            exg.RecordTypeID = GenericUtilities.getRecordTypeIdByDevName(Exam_Registration_Config_Data__mdt.getInstance(examRegObj.exam.replace(' ','_').replace('-','_')).Obj_Name__c,Exam_Registration_Config_Data__mdt.getInstance(examRegObj.exam.replace(' ','_').replace('-','_')).Record_Type_Developer_Name__c);   
        }
        
        else
            exg.RecordTypeID = GenericUtilities.getRecordTypeIdByDevName('Exam_Registration__c','USMLE');
        system.debug('exg.RecordTypeID'+exg.RecordTypeID);
        exg.Exam_Reg_External_Id__c=isNotEmpty(examRegObj.SFExamRegExternalId) ? examRegObj.SFExamRegExternalId :'';  
        exg.Test_Accommodations__c=isNotEmpty(examRegObj.TAFlag) ? examRegObj.TAFlag :'';        
        exg.Application_Id__c=isNotEmpty(examRegObj.applicationId)  ? getintegerval(examRegObj.applicationId):null;
        exg.Two_Digit_Passing_Score__c=isNotEmpty(examRegObj.twoDigitPassingScore) ? examRegObj.twoDigitPassingScore :null;
        exg.Two_Digit_Score__c=isNotEmpty(examRegObj.twoDigitScore) ? examRegObj.twoDigitScore :null;
        exg.Three_Digit_Score__c=isNotEmpty(examRegObj.threeDigitScore) ? examRegObj.threeDigitScore :null;
        exg.Three_Digit_Passing_Score__c=isNotEmpty(examRegObj.threeDigitPassingScore) ? examRegObj.threeDigitPassingScore :null;
        exg.Exam_Status__c=isNotEmpty(examRegObj.examStatusCode) ?examRegObj.examStatusCode :null;
        exg.Actual_Exam_Start_Date__c=isNotEmpty(examRegObj.actualStartDate) ? Date.valueOf(examRegObj.actualStartDate):null;
        exg.Exam_taken_date__c=isNotEmpty(examRegObj.actualStartDate) ? Date.valueOf(examRegObj.actualStartDate):null;
        exg.Score_Available_Date__c=isNotEmpty(examRegObj.scoreAvailableDate) ? Date.valueOf(examRegObj.scoreAvailableDate):null;
        exg.Last_Update_Date__c=isNotEmpty(examRegObj.lastUpdateDate) ? getDateTimeformat(examRegObj.lastUpdateDate):null;
        exg.Score_Report_Date__c=isNotEmpty(examRegObj.ScoreReportDate) && examRegObj.ScoreReportDate!='' ? Date.valueOf(examRegObj.ScoreReportDate):null;
        exg.Ta_Code__c=isNotEmpty(examRegObj.TAFlag)? examRegObj.TAFlag :''; 
        exg.Admin_Org__c=isNotEmpty(examRegObj.adminOrg) ? examRegObj.adminOrg :''; 
        exg.Irregularity_Status__c=isNotEmpty(examRegObj.adminIrregularityStatus)? examRegObj.adminIrregularityStatus :''; 
        return exg;
    }
    
    // Method to Process Exam Irregular Behavior Data
    Public Static void processExamIrrBehData(map<String, list<CibisExamHistoryResponseEventWrap.payload>> responseMap){
        
        List<Exam_Registration__c> examList = new List<Exam_Registration__c>();
        Map<String, String> examCaseIdMap = new Map<String,String>();
        Map<String,Exam_Registration__c> examsMap = new Map<String,Exam_Registration__c>();
        map<Id, String> caseTransactionMap = new map<Id, String>();
        Map<Id,Id> IrregCaseConMap = new Map<Id,Id>();
        Map<String, List<CibisExamHistoryResponseEventWrap.IrregularBehavior>> examIrrBeh = new Map<String, List<CibisExamHistoryResponseEventWrap.IrregularBehavior>>();
        list<Transcript_Anotation__c> transAnnotsList=new list<Transcript_Anotation__c>(); 
        
        // Construct Map of Exam Reg external Id & List of Irregular behaviors with respect to Exam
        for(String trId:responseMap.keySet()){
            String conID = trId.split('-')[1];
            String caseId = trId.split('-')[2];             
            caseTransactionMap.put(caseId,constants.CIBIS_EXAM_HISTORY_IRREGULAR_BEHAVIOR_EVENT);
            
            for(CibisExamHistoryResponseEventWrap.payload exam:responseMap.get(trId)){
                examList.add(getExamRegMapping(exam,conID));  
                if(isNotEmpty(exam.SFExamRegExternalId)){
                    examCaseIdMap.put(exam.SFExamRegExternalId,caseId);
                    If(!exam.IrregularBehavior.IsEmpty()){
                        For(CibisExamHistoryResponseEventWrap.IrregularBehavior ir:exam.IrregularBehavior){
                            if(!examIrrBeh.containskey(exam.SFExamRegExternalId))
                            {
                                examIrrBeh.put(exam.SFExamRegExternalId,new list<CibisExamHistoryResponseEventWrap.IrregularBehavior>{ir});    
                            }
                            else{
                                examIrrBeh.get(exam.SFExamRegExternalId).add(ir);    
                            }
                        }  
                    }
                }
                
                
            }
            
        }
        if(examList!=null && examList.size()>0){
            upsertExamRegRecords(examList);
        }
        if(cibisAnnotationsMap.isEmpty())
        {
            cibisAnnotationsMap = getCibisAnnoations();
            System.debug('****cibisAnnotationsMap'+cibisAnnotationsMap);      
        }
        
        if(examIrrBeh!=null && !examIrrBeh.isEmpty()){
            System.debug('****examIrrBeh'+examIrrBeh);      
            // retreive Exam Registration record Id based on External Ids
            for(Exam_Registration__c exr:[SELECT Id, Exam_Reg_External_Id__c,Applicant__c FROM Exam_Registration__c WHERE Exam_Reg_External_Id__c IN:examIrrBeh.keySet()]){
                examsMap.put(exr.Exam_Reg_External_Id__c, exr); 
                IrregCaseConMap.put(Id.ValueOf(examCaseIdMap.get(exr.Exam_Reg_External_Id__c)),exr.Applicant__c);  
                
            }
            
            // Construct Transcrip Annotations for Exam Registration Irregular Behaviors
            for(String itr:examIrrBeh.keySet()){
                
                if(examsMap.containsKey(itr) && examIrrBeh?.get(itr) != null && !examIrrBeh?.get(itr).isEmpty()){
                    for(CibisExamHistoryResponseEventWrap.IrregularBehavior iterator : examIrrBeh.get(itr)){
                        System.debug('****examsMap'+examsMap.get(itr));      
                        transAnnotsList.add(new Transcript_Anotation__c(Transcript_Case__c = (examCaseIdMap.ContainsKey(itr)?examCaseIdMap.get(itr):null) ,USMLE_Transcripts_Notes__c = (examsMap.ContainsKey(itr)?examsMap.get(itr).Id:null),
                                                                        SHORT_TEXT__c=iterator.description,ANNOTATION_TEXT__c=iterator.explanation, Cibis_Transcript_Status__c = Constants.EXAM_IRREGULAR,Contact__c=(examsMap.ContainsKey(itr)?examsMap.get(itr).Applicant__c:null))); 
                    }
                    System.debug('****transAnnotsList'+transAnnotsList.size());      
                }
                
            }
            
            
            
        }
        
        if(IrregCaseConMap!=null && !IrregCaseConMap.isEmpty()){         
            Cibis_Annoatation__mdt mdtAnnotObj=cibisAnnotationsMap.get(Constants.Exam_IRREGULAR_Notes);          
            for(Id cid : IrregCaseConMap.keyset()){
                transAnnotsList.add(new Transcript_Anotation__c(Transcript_Case__c = cid,ACTIVE__c=mdtAnnotObj.ACTIVE__c,SORT_ORDER__c=Integer.valueOf(mdtAnnotObj.Sort_Order__c),
                                                                ANNOTATION_TEXT__c=mdtAnnotObj.ANNOTATION_TEXT__c,ANNOTATION_CODE__c=string.valueOf(mdtAnnotObj.ANNOTATION_CODE__c),
                                                                SHORT_TEXT__c=mdtAnnotObj.SHORT_TEXT__c,Cibis_Transcript_Status__c=mdtAnnotObj.Cibis_Transcript_Status__c,Contact__c=IrregCaseConMap.get(cId))); 
                
            }
        }
        
        
        if(!transAnnotsList.isEmpty()){
            insertSobjects(transAnnotsList);
        }
        
        if(!caseTransactionMap.isEmpty()){
            updateCaseStatus(caseTransactionMap.keyset());   
        }
        
        
    }
    
    // Method to create related Case transcript Annotation
    Public static void processRelatedCaseTranscriptAnnots(map<Id,Case> newCaseMap,map<Id,Case> oldCaseMap,set<Id> relatedCaseIds){
        set<Id> caseIds=new set<Id>();
        if(RecursiveTriggerHandler.isFirstTimeRelatedTranscript){            
            Id caseUSMLERecordTypeId = GenericUtilities.getRecordTypeIdByDevName('Case', 'USMLE_Transcript');
            if(newCaseMap!=null && oldCaseMap!=null && !newCaseMap.isEmpty() && !oldCaseMap.isEmpty()){    
                For(Case cs:newCaseMap.values()){
                    Case oldcs=oldCaseMap.get(cs.Id);
                    if(cs.RecordTypeId == caseUSMLERecordTypeId && cs.ParentId != null && cs.Internal_Status__c <> oldcs.Internal_Status__c && cs.Internal_Status__c==Constants.CASE_STATUS_APPROVED){
                        caseIds.add(cs.Id);
                    }
                }
            }
            else {
                
                caseIds=relatedCaseIds;
                System.debug('**caseIds**'+caseIds);
            }
            if(caseIds!=null && !caseIds.isEmpty()){
               	list<String> lstParentIds = new list<String>();
                map<Id, list<Case>> mapPrntIdAndCases = new map<Id, list<Case>>();
                map<Id, Case> mapCases = new map<Id, Case>([SELECT Id, ParentId FROM Case WHERE Id IN:caseIds]);
                //[SELECT Id, Related_Transcript_Case__c,ParentId, Related_Transcript_Case__r.Internal_Status__c,Related_Transcript_Case__r.External_Status__c,Related_Transcript_Case__r.Cibis_Transcript_Status__c,isCibisTranReqInit__C, Related_Transcript_Case__r.isCibisTranReqInit__c,ContactId FROM Case WHERE Id IN:caseIds]
                for(Case cs : mapCases.values()){
                    lstParentIds.add(cs.ParentId);
                }
                for(Case cs : [SELECT Id, External_Status__c, Internal_Status__c, Cibis_Transcript_Status__c, ParentId, Parent.Internal_Status__c, Parent.External_Status__c, Parent.Cibis_Transcript_Status__c,isCibisTranReqInit__C, Parent.isCibisTranReqInit__c,ContactId FROM Case WHERE ParentId IN:lstParentIds]){
                    if(!mapPrntIdAndCases.containsKey(cs.ParentId) && cs.ParentId != null) {
                        mapPrntIdAndCases.put(cs.ParentId, new list<Case>{cs});
                    }
                    else {
                        mapPrntIdAndCases.get(cs.ParentId).add(cs);
                    }
                }
                map<Id,Case> relatedCaseMap=new map<Id,Case>();
                list<Transcript_Anotation__c> transcriptAnnots=new list<Transcript_Anotation__c>();
                For(Transcript_Anotation__c transA:[Select Transcript_Case__c,Transcript_Case__r.ParentId, Transcript_Case__r.Cibis_Transcript_Status__c,Transcript_Case__r.Related_Transcript_Case__r.Internal_Status__c,Transcript_Case__r.Related_Transcript_Case__c,ACTIVE__c,Transcript_Case__r.Internal_Status__c,SORT_ORDER__c,ANNOTATION_TEXT__c,ANNOTATION_CODE__c,SHORT_TEXT__c,USMLE_Transcripts_Notes__c,Cibis_Transcript_Status__c,Contact__c from Transcript_Anotation__c where 
                                                    Transcript_Case__c IN:caseIds])
                {
                    Case objChildCase = null;
                    if(mapPrntIdAndCases.containsKey(transA.Transcript_Case__r.ParentId)) {
                        list<Case> lstCases = mapPrntIdAndCases.get(transA.Transcript_Case__r.ParentId);
                        if(lstCases != null && !lstCases.isEmpty()) {
                            for(Case obj : lstCases) {
                                if(obj.Id != transA.Transcript_Case__c) {
                                    objChildCase = obj; 
                                    break;
                                }
                            }
                        }
                    }
                    if(objChildCase != null && objChildCase.Internal_Status__c==constants.CASE_STATUS_PENDING_CIBIS || relatedCaseIds!=null){                              
                        if(!relatedCaseMap.containskey(objChildCase.Id)){
                            relatedCaseMap.put(objChildCase.Id,new Case(Id=objChildCase.Id,Cibis_Transcript_Status__c=objChildCase.Cibis_Transcript_Status__c,Internal_Status__c=objChildCase.Internal_Status__c));
                        }
                        
                        Transcript_Anotation__c objTransAnt = transA.clone(false, false, false, false);
                        System.debug('**objTransAnt**'+objTransAnt);
                        objTransAnt.Transcript_Case__c = objChildCase.Id;
                        System.debug('**objTransAnt.Transcript_Case__c**'+objTransAnt);
                        transcriptAnnots.add(objTransAnt);
                    }
                }
                
                if(relatedCaseMap.keySet() == null || relatedCaseMap.keySet().isEmpty()) {
                    Case objCase = null;
                    Case objChild = null;
                    for(String strId : caseIds) {
                        if(mapCases.containsKey(strId)) {
                        	objCase = mapCases.get(strId);
                    	}

                        if(objCase != null && objCase.ParentId != null && mapPrntIdAndCases.containsKey(objCase.ParentId)) {
                            list<Case> lstCases = mapPrntIdAndCases.get(objCase.ParentId);
                            if(lstCases != null && !lstCases.isEmpty()) {
                                for(Case obj : lstCases) {
                                    if(obj.Id != strId)  {
                                        objChild = obj; 
                                        break;
                                    }
                                }

                                if(objChild != null && !relatedCaseMap.containskey(objChild.Id)){
                                    relatedCaseMap.put(objChild.Id, new Case(Id=objChild.Id,Cibis_Transcript_Status__c=objChild.Cibis_Transcript_Status__c,Internal_Status__c=objChild.Internal_Status__c));
                                }
                            }
                        }
                    }
                }

                if(!transcriptAnnots.isEmpty()){
                    insertSobjects(transcriptAnnots);
                }
                if(!relatedCaseMap.isEmpty()){
                    updateCaseStatus(relatedCaseMap.keySet());
                    //updateSobjects(relatedCaseMap.values());
                }
                
            }
            RecursiveTriggerHandler.isFirstTimeRelatedTranscript = false;    
        }
    }
    
    // Method to create Score report details
    Public static void createScoreReportdetails(list<CibisScoreReportResponseEventWrap.cibisScoringInfo> scoreList){
        list<Exam_Registration__c> examRegList=new list<Exam_Registration__c>();
        
        For(CibisScoreReportResponseEventWrap.cibisScoringInfo scrObj:scoreList){ 
            System.debug('*****scrObj'+scrObj);
            
            if(isNotEmpty(scrObj.SFExamRegExternalId)){ 
                Exam_Registration__c exg=new Exam_Registration__c();   
                
                exg.Exam_Reg_External_Id__c=isNotEmpty(scrObj.SFExamRegExternalId) ? scrObj.SFExamRegExternalId :'';
                exg.USMLE_ID_CIBIS__c=isNotEmpty(scrObj.USMLEId) ? scrObj.USMLEId :'';
                exg.Exam_Types__c=isNotEmpty(scrObj.USMLEId) ? scrObj.exam:'';
                exg.Exam_Status__c=isNotEmpty(scrObj.passFail) ? scrObj.passFail:'';
                if(Exam_Registration_Config_Data__mdt.getInstance(scrObj.exam.replace(' ','_').replace('-','_'))!=null)
                    exg.RecordTypeID = GenericUtilities.getRecordTypeIdByDevName(Exam_Registration_Config_Data__mdt.getInstance(scrObj.exam.replace(' ','_').replace('-','_')).Obj_Name__c,Exam_Registration_Config_Data__mdt.getInstance(scrObj.exam.replace(' ','_').replace('-','_')).Record_Type_Developer_Name__c);  
                else
                    exg.RecordTypeID = GenericUtilities.getRecordTypeIdByDevName('Exam_Registration__c','USMLE');
                exg.Application_Id__c=isNotEmpty(scrObj.applicationId)  ? getintegerval(scrObj.applicationId):null;
                exg.Two_Digit_Passing_Score__c=isNotEmpty(scrObj.twoDigitPassingScore) ? getintegerval(scrObj.twoDigitPassingScore) :null;
                exg.Two_Digit_Score__c=isNotEmpty(scrObj.twoDigitScore) ? getintegerval(scrObj.twoDigitScore) :null;
                exg.Three_Digit_Score__c=isNotEmpty(scrObj.threeDigitScore) ? getintegerval(scrObj.threeDigitScore) :null;
                exg.Three_Digit_Passing_Score__c=isNotEmpty(scrObj.threeDigitPassingScore) ? getintegerval(scrObj.threeDigitPassingScore) :null;
                exg.Exam_Completion_Status__c=isNotEmpty(scrObj.examCompletionStatus) ?scrObj.examCompletionStatus :null;
                exg.Score_Report_Date__c=isNotEmpty(scrObj.scoreReportDate) ? Date.valueOf(scrObj.scoreReportDate):null;
                exg.Actual_Exam_Start_Date__c=isNotEmpty(scrObj.actualStartDateExamDate)!=null ? Date.valueOf(scrObj.actualStartDateExamDate):null;
                exg.Indeterminate_Flag__c=isNotEmpty(scrObj.indeterminateFlag)? scrObj.indeterminateFlag :'';
                exg.Score_Status__c=isNotEmpty(scrObj.scoreStatus) ?scrObj.scoreStatus :'';
                exg.Score_Available_Date__c=isNotEmpty(scrObj.scoreAvailableDate) ?date.valueOf(scrObj.scoreAvailableDate) :null;
                exg.Irregularity_Status__c=isNotEmpty(scrObj.irregularityStatus) ?scrObj.irregularityStatus :'';
                exg.Last_Update_Date__c=scrObj.lastUpdateDate!=null ?getDateTimeformat(scrObj.lastUpdateDate):null;
                exg.ice_pass_fail__c=isNotEmpty(scrObj.icePassFail) ?scrObj.icePassFail:'';
                exg.cis_pass_fail__c=isNotEmpty(scrObj.cisPassFail) ?scrObj.cisPassFail:'';
                exg.Sep_pass_fail__c=isNotEmpty(scrObj.sepPassFail) ?scrObj.sepPassFail:'';
                exg.Examination_repeat_flag__c=isNotEmpty(scrObj.examinationRepeatFlag) ?scrObj.examinationRepeatFlag:'';
                examRegList.add(exg);
            }
            
        }
        if(!examRegList.isEmpty()){
            
            upsertExamRegRecords(examRegList);
        }
    }
    
    Public static boolean isNotEmpty(String myStr){
        return (mystr!=null && mystr!='');
    }
    Public static boolean isNotEmpty(integer myIntVal){
        return myIntVal!=null;
    }
    Public static integer getintegerval(string myStr){
        return integer.valueOf(myStr);
    }
    // Method to get date Time Format
    Public static dateTime getDateTimeformat(string dtTime){ 
        Datetime myDateTime;
        if(dtTime!=null && String.isNotBlank(dtTime)){   
            String myDate=dtTime.replace('T',' ');
            myDateTime = Datetime.valueOf(myDate); 
        }
        return myDateTime;
    }
    
    // Method to update Case status based on Enable Shipment
    public static void updateCaseStatus(set <Id> caseIds) {
        if (caseIds != null && !caseIds.isEmpty()) {
            Id idExamTransQueue = GenericUtilities.getQueueIdByDevName('Exam_Transcripts');
            list<Case> casesToUpdate=new list<Case>();
            Org_Wide_Shipment_Setting__mdt objMdt = [SELECT DeveloperName, Enable_Shipment__c, Id, Label, MasterLabel, QualifiedApiName FROM Org_Wide_Shipment_Setting__mdt where DeveloperName = 'Enable_Shipment'
                                                     limit 1];
            for (Id csId:caseIds ) {              
                Case caseIterator=new Case(Id=csId);
                
                if (objMdt != null) {
                    if (!objMdt.Enable_Shipment__c) {                      
                        caseIterator.Internal_Status__c =Constants.CASE_STATUS_PENDING_PRINT;
                        if (idExamTransQueue != null)
                            caseIterator.OwnerId = idExamTransQueue;
                        caseIterator.External_Status__c = Constants.CASE_STATUS_SUBMITTED_IN_REVIEW;
                    } else if (objMdt.Enable_Shipment__c) {                     
                        caseIterator.Internal_Status__c = Constants.CASE_STATUS_APPROVED;
                        if (idExamTransQueue != null)
                            caseIterator.OwnerId = idExamTransQueue;
                        caseIterator.External_Status__c = Constants.CASE_STATUS_SUBMITTED_IN_REVIEW;
                    }
                }
                casesToUpdate.add(caseIterator);
            }
            if(!casesToUpdate.isEmpty() &&  casesToUpdate!=null){
                updateSobjects(casesToUpdate);
            }
            
        }
    }
    
}