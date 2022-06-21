/**
* Created by Mathew on 10/31/18
  Enhanced as per CIBIS Requirement.
*/
public with sharing class ApplicantCommunityController {
    
    @AuraEnabled
    public static Map< String, Id> GetAccountRecordTypes() {
        
        List<RecordType> recs = [SELECT Id, Name FROM RecordType WHERE sObjectType='Account'];
        
        Map<String, Id> mpRecordTypes = new Map<String, Id>();
        
        for(RecordType rec : recs) {
            RecordType  newRecList = new RecordType();
            newRecList.Id = rec.Id;
            newRecList.Name = rec.Name;
            mpRecordTypes.put(rec.Name,rec.Id);    
        }
        return mpRecordTypes;
    }
    
    @AuraEnabled
    public static Map<String, Id> getContactAssociationRecordTypes() {
        
        List<RecordType> recs = [SELECT Id, Name FROM RecordType WHERE sObjectType='Contact_Association_Type__c'];
        
        Map<String, Id> mpRecordTypes = new Map<String, Id>();
        
        for(RecordType rec : recs) {
            RecordType  newRecList = new RecordType();
            newRecList.Id = rec.Id;
            newRecList.Name = rec.Name;
            mpRecordTypes.put(rec.Name,rec.Id);    
        }
        return mpRecordTypes;
    }
    
    @AuraEnabled
    public static List<ContactAssociationTypeViewModel> getContactAssociationTypes(String contactId, String recordTypeName){
        //Added new fields for the select query - Shailaja - 8/25/2020, User story#7211
        List<Contact_Association_Type__c> schools = [SELECT
                                                     Id,
                                                     Account__r.Name,
                                                     Account__r.Alternative_Name__c,
                                                     Account__r.BillingStreet,
                                                     Account__r.BillingCity,
                                                     Account__r.BillingState,
                                                     Account__r.BillingPostalCode,
                                                     Account__r.BillingCountry,
                                                     Account__r.ParentId,
                                                     Account__r.Parent.Name,
                                                     Account__r.University_Name__c,
                                                     Degree_Title__c,
                                                     Degree_Issue_Date__c,
                                                     Degree_Issue_Month__c,
                                                     Degree_Issue_Year__c,
                                                     Start_Date__c,
                                                     Start_Month__c,
                                                     Start_Year__c,
                                                     End_Date__c,
                                                     End_Month__c,
                                                     End_Year__c,                
                                                     Student_ID__c,
                                                     RecordType.Name
                                                     FROM
                                                     Contact_Association_Type__c
                                                     WHERE
                                                     RecordType.Name = :recordTypeName
                                                     and Contact__c = :contactId];
        List<ContactAssociationTypeViewModel> viewModel = new List<ContactAssociationTypeViewModel>();     
        for(Contact_Association_Type__c school : schools){         
            ContactAssociationTypeViewModel model = new ContactAssociationTypeViewModel();         
            model.Id = school.Id;
            model.Name = school.Account__r.Name;
            model.AlternativeName = school.Account__r.Alternative_Name__c;
            model.Address1 = school.Account__r.BillingStreet;
            model.Address2 = school.Account__r.BillingCity;
            model.Address3 = school.Account__r.BillingState;
            model.Address4 = school.Account__r.BillingPostalCode;
            model.Country = school.Account__r.BillingCountry;
            model.DegreeTitle = school.Degree_Title__c;
            model.DegreeDate = school.Degree_Issue_Date__c;
            //New code
            model.DegreeMonth = school.Degree_Issue_Month__c;
            model.DegreeYear = school.Degree_Issue_Year__c;
            model.UniversityName = school.Account__r.University_Name__c;
            //Code commented as start date is removed. 9/24/2020. Shailaja
            //model.StartDate = school.Start_Date__c;          
            model.StartMonth = school.Start_Month__c;
            model.StartYear = school.Start_Year__c;
            model.EndMonth = school.End_Month__c;
            model.EndYear = school.End_Year__c;
            //Code commented as end date is removed. 9/24/2020. Shailaja
            //model.EndDate = school.End_Date__c;
            model.StudentId = school.Student_ID__c;
            model.Type = school.RecordType.Name;           
            viewModel.add(model);
        }  
        return viewModel;
    }
    
    
    @AuraEnabled
    public static void deleteContactAssociationType(String id) {
        Contact_Association_Type__c association = new Contact_Association_Type__c(Id = id);
        delete association;
    }
    
    @AuraEnabled
    public static void deleteContactAssociationTypes(String contactId, String recordTypeName) {
        List<Contact_Association_Type__c> associations = [select Id from Contact_Association_Type__c where Contact__c = :contactId and RecordType.Name = :recordTypeName];
        delete associations;
    }
    
    
    
    @AuraEnabled
    public static String getRunningUserId() {
        return (String)UserInfo.getUserId();
    }
    
    
    /*    *//*
Returns the contact id of the logged in user, such as a user who is a enabled for community access.
*//*
@AuraEnabled
public static String getRunningContactId() {
String userId = (String)UserInfo.getUserId();
User usr = [select ContactId from User where Id = :userId limit 1];
String contactId = usr.ContactId;
if(contactId == null || contactId == '') {
//return '0030U00000PGMbC'; // karl
//return '0050U000000zM7l'; // david
return '0030U00000PGMbC';
} else {
return contactId;
}
}*/
    
    /*
Returns the contact id of the logged in user, such as a user who is a enabled for community access.
If not found, tries to load the "test contact" from Community Settings.
*/
    @AuraEnabled
    public static String getRunningContactId() {
        String userId = (String)UserInfo.getUserId();
        User usr = [select ContactId from User where Id = :userId limit 1];
        String contactId = usr.ContactId;
        if(contactId == null || contactId == '') {
            Community_Settings__c settings = Community_Settings__c.getOrgDefaults();
            contactId = settings.Builder_Test_Contact__c;
            if(contactId != null) {
                // ensure the setting provided is a valid contact id and/or is valid for this org.
                List<Contact> contacts = [select Id from Contact where Id = :contactId];
                if(contacts.size() == 0) contactId = null;
            }
            if(contactId == null) throw new CommunityException('Unable to find Community User/Contact. If using a test contact, make sure it is valid for this org.');
        }
        return contactId;
    }
    
    
    /*
Returns a select option list for use with listboxes.
See: https://help.salesforce.com/articleView?id=000212327&type=1
*/
    @AuraEnabled
    public static List<SelectOption> getCountryPicklistEntries() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = User.CountryCode.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }
        return options;
    }
    //User Story#7211, Code added on Aug 26 2020, Shailaja
    @AuraEnabled
    public static List<SelectOption> getMonthPicklistEntries() {
        List<SelectOption> options = ComponentUtility.getMonthPicklistEntries();
        return options;
    }
    /*
Returns a select option list for use with listboxes.
See: https://help.salesforce.com/articleView?id=000212327&type=1
*/
    @AuraEnabled
    public static List<SelectOption> getCountryAndStatePicklistEntries() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = User.CountryCode.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            options.add(new SelectOption(f.getValue(), f.getLabel()));
        }
        return options;
    }
    
    
    @AuraEnabled
    public static Map<String, List<String>>  getGeoData() {
        
        String stateString = 'User.StateCode';
        
        List<String> splitStateString = stateString.split('\\.');
        
        Schema.SobjectField stateField = Schema.getGlobalDescribe().get(splitStateString[0]).getDescribe().fields.getMap().get(splitStateString[1]);
        
        //System.debug('State Field: ' + stateField);
        
        String countryString = 'User.CountryCode';
        
        List<String> splitCountryString = countryString.split('\\.');
        
        Schema.SobjectField countryField = Schema.getGlobalDescribe().get(splitCountryString[0]).getDescribe().fields.getMap().get(splitCountryString[1]);
        
        //System.debug('Country Field: ' + countryField);
        
        DependentPicklists dp = new DependentPicklists();
        
        Map<String, List<String>> result =  dp.controllingToDependentValues(countryField, stateField);
        
        return result;
        
    }
    
    
    @AuraEnabled
    public static List<CaseImageModel> getCaseImages(String caseId) {
        
        // find all in progress assets
        List<Asset> assets = [select Id,Key__c,Contact_Association_Type_Staging__r.Account_Name__c from Asset where Case__r.Id = :caseId AND ((Status = 'In Progress') OR 
                                                                                                                                              (Status = 'Accepted' AND Case__r.RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_APP_FOR_CERT AND (Case__r.Internal_Status__c =: Constants.CASE_STATUS_RESUBMITTED_IN_REVIEW
                                                                                                                                                                                                                                                        OR Case__r.Internal_Status__c =: Constants.CASE_STATUS_RESUBMITTED_PENDING_REVIEW))) ];
        
        if(assets.size() == 0) return null;
        
        // get the asset ids
        List<String> assetIds = new List<String>();
        
        Map<Id,Asset> assetMap = new Map<Id,Asset>();        
        for(Integer i = 0; i < assets.size(); i++) {
            assetIds.add(assets[i].Id);
            assetMap.put(assets[i].Id,assets[i]);
        } 
        
        // get content document links
        List<ContentDocumentLink> links = [select Id, ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId in :assetIds];
        
        if(links.size() == 0) return null;
        
        // get the doc ids
        List<String> docIds = new List<String>();
        Map<Id,Id> docAssetMap = new Map<Id,Id>();
        for(Integer i = 0; i < links.size(); i++) {
            docIds.add(links[i].ContentDocumentId);
            docAssetMap.put(links[i].ContentDocumentId,links[i].LinkedEntityId);
        } 
        
        // find all content documents
        List<ContentDocument> docs = [select Id, Title, CreatedDate, CreatedBy.Name, FileType from ContentDocument where Id in :docIds order by CreatedDate asc];
        
        if(docs.size() == 0) return null;
        
        // build a list of content document ids
        List<String> contentDocumentIds = new List<String>();
        for(ContentDocument doc : docs) contentDocumentIds.add(doc.Id);
        
        // get the content versions for the in scope content documents
        List<ContentVersion> versions = [select Id, ContentDocumentId, Document_Type__c from ContentVersion where ContentDocumentId in :contentDocumentIds];
        
        if(versions.size() == 0) return null;
        
        // build a map of document ids to document type
        Map<String, String> documentTypeMap = new Map<String, String>();
        for(ContentVersion version : versions) documentTypeMap.put(version.ContentDocumentId, version.Document_Type__c);
        
        // get the record type id from Case
        Case caseRec = [SELECT Id, RecordType.DeveloperName FROM Case WHERE Id = :caseId];
        
        StaticResource pdfLogo = [SELECT Id, SystemModStamp, Name
                                  FROM StaticResource 
                                  WHERE Name = :Constants.PDF_LOGO
                                  LIMIT 1];
        
        List<CaseImageModel> model = new List<CaseImageModel>();
        String imgURL;
        if(caseRec != null && caseRec.RecordType.DeveloperName == Constants.CASE_RECORD_TYPE_APP_FOR_CERT) {
            for(Integer i = 0; i < docs.size(); i++) {
                imgURL = '';
                if(docs[i].FileType == 'PDF') {
                    imgURL = '/resource/'
                        + String.valueOf(((DateTime)pdfLogo.get('SystemModStamp')).getTime())
                        + '/' 
                        + pdfLogo.get('Name');
                }
                else {
                    imgURL = '/sfc/servlet.shepherd/document/download/' + docs[i].Id + '?operationContext=S1';
                }
                model.add(
                    new CaseImageModel(
                        documentTypeMap.get(docs[i].Id),
                        '"' + assetMap.get(docAssetMap.get(docs[i].Id)).Key__c + '"' + ' of ' + assetMap.get(docAssetMap.get(docs[i].Id)).Contact_Association_Type_Staging__r.Account_Name__c  + ' uploaded by ' + docs[i].CreatedBy.Name + ' on ' + docs[i].CreatedDate + '.',
                        imgURL,
                        '/sfc/servlet.shepherd/document/download/' + docs[i].Id + '?operationContext=S1'
                    )
                );
            }
        }
        else {
            for(Integer i = 0; i < docs.size(); i++) {
                model.add(
                    new CaseImageModel(
                        documentTypeMap.get(docs[i].Id),
                        '"' + docs[i].Title + '"' + ' uploaded by ' + docs[i].CreatedBy.Name + ' on ' + docs[i].CreatedDate + '.',
                        '/sfc/servlet.shepherd/document/download/' + docs[i].Id + '?operationContext=S1',
                        '/sfc/servlet.shepherd/document/download/' + docs[i].Id + '?operationContext=S1'
                    )
                );
            }
        }
        
        if(model.size() == 0) return null;
        
        return model;
    }
    
    /*
This is so we can test that errors are being returned and handle by client code.
*/
    @AuraEnabled
    public static void errorTest() {
        throw new CommunityException('Test exception thrown by Apex');
    }
    
    
    /*
This method returns a contact using the contact id.
*/
    @AuraEnabled
    public static Contact getContact(String contactId) {
        return ContactService.getContact(contactId);
    }
    //Added for Cibis Duplicate Candidate Exam Registration Check Request Call by Rambabu Vadlamudi
    @AuraEnabled
    public static CIBIS_Duplicate_Check__c getCibisCandidate(String usmleId){
        CIBIS_Duplicate_Check__c cibisObj =[SELECT Id,Cibis_First_Name__c,CIBIS_GENDER_CODE__c,Cibis_Last_Name__c,Cibis_Overall_Match__c,Case__c,
                                            CibisBirthDate__c,CIBIS_USMLE_ID__c,CibisMedicalSchoolCode__c,Contact__c FROM CIBIS_Duplicate_Check__c WHERE CIBIS_USMLE_ID__c =: usmleId WITH SECURITY_ENFORCED LIMIT 1];
        return cibisObj;
    }
   
    @AuraEnabled
    public static String cibisCandRequestEvent(String caseId){
        return CibisDupCheckRequestEventHandler.buildDupCheckPayload(caseId);
    }
    @AuraEnabled
    Public static void updatecaseContactWithConfirm(CIBIS_Duplicate_Check__c cibisContact){
        try{
            System.debug('*****cibisContact'+cibisContact);
            if(cibisContact!=null){ 
                if(cibisContact.Contact__c <> null && cibiscontact.CIBIS_USMLE_ID__c <> null){
                    Contact con = new Contact(Id=cibisContact.Contact__c,USMLE_ID__c=cibiscontact.CIBIS_USMLE_ID__c,is_CIBIS_Origin__c=True); 
                    if(Schema.sObjectType.Contact.isUpdateable()){
                        System.debug('*****con'+con);
                        update con;
                    }
                    if(cibiscontact.Case__c <> null){
                        CibisExamHistoryGenReqHandler.constructPayload(string.valueOf(cibisContact.Contact__c),string.valueOf(cibiscontact.CIBIS_USMLE_ID__c));
                        createCaseRelatedData(cibiscontact.Case__c);
                    }
                }
            }
        }
        catch(Exception ex){
            system.debug('Line '+ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage());  
        }  
        
    }
    @AuraEnabled       
    Public static void updatecaseContactNotConfirm(string strCaseId){
        createCaseRelatedData(strCaseId);
    }
    Public static void createCaseRelatedData(string caseId){
        Case cse = CaseService.getCase(caseId);
        Id assetIdRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Identity').getRecordTypeId();
        Id prdIdenityRecTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Identity').getRecordTypeId();
        Id affriIDVerifyRecTypeId = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByName().get('ID_Verification').getRecordTypeId();        
        Product2 prd=[Select id from product2 where Name='ID Form' AND RecordTypeID=:prdIdenityRecTypeId]; 
        Id queueId = [SELECT Id FROM Group WHERE Type='Queue' AND DeveloperName=:Constants.CASE_QUEUE_ID_Verification_Queue].Id;
        List<case> cs = new List<case>{new case(Id=caseId,Internal_Status__c=Constants.CASE_STATUS_INTERNAL_PENDING_APPLICANT_ACTION_NOTARIZE_ID,OwnerId=queueId)};
            if(prd<> null){
                list<Asset> assetList=new list<Asset>{new Asset(Product2Id=prd.Id,recordTypeId=assetIdRecTypeId,Case__c=caseId,InstallDate=Date.today(),
                                                                Name='ID Form Template',status='In Progress',Type__c='ID Verification',contactId=cse.ContactId)};
                                                                    System.debug('*****assetList'+assetList);                                                    
                if(Schema.sObjectType.Asset.isCreateable()){
                    database.saveresult[] srlist= database.insert(assetList,false); 
                    
                    list<Affirmation__c> affirmationsList=new list<Affirmation__c>();
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
                        Insert affirmationsList;
                    }
                    if(!cs.isEmpty() && Schema.sObjectType.case.isUpdateable()){
                        System.debug('*****caseList'+cs);     
                        //Update cs;
                        Database.SaveResult [] updateResult = Database.update(cs, false);
                        for (Database.SaveResult res : updateResult){
                            if(!res.isSuccess()){
                                //Get Error
                                for (Database.Error e : res.getErrors()){
                                    System.debug('Error occured '+e.getMessage());
                                }
                            }
                        }
                    }
                }
            }
        SendEmailToContact(cse);
    }
    Public static void sendEmailToContact(case cse){
        Content_Manager__c contentMgr=getContentManagerInfo('CIBIS Contact Email');
        if(contentMgr!=null){
        OrgWideEmailAddress owea=[select id, Address from OrgWideEmailAddress where Address='salesforceadmin@ecfmg.org' limit 1];
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
        email.setTargetObjectId(cse.ContactId);
        email.setOrgWideEmailAddressId(owea.ID);
        string body='Dear '+cse.Contact.FirstName+' '+cse.Contact.LastName+'<br/><br/>';
        email.setSubject(contentMgr.Subject__c<> null ? contentMgr.Subject__c:'Status Update Available In ECFMG Portal');
        email.setHtmlBody(body+contentMgr.Content__c);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   
        }

    }
    public class CibisContact {
        
        public String BirthDate;
        public String contactId;
        public String Gender;
        public String LastName;
        public String MedschoolCode;
        public Integer overallMatch;
        public String RestOfName;
        public String ScorePercentage;
        public String usmleId;
    }
    
    @AuraEnabled
    public static List<CIBIS_Duplicate_Check__c> cibisCandResponse(String caseId){
        Case casObj = [SELECT ContactId FROM CASE WHERE Id =: caseId WITH SECURITY_ENFORCED];
        String contactId = casObj.ContactId;
        //List<ApplicantDuplicateMatchModel> modelList = new List<ApplicantDuplicateMatchModel>();
        List<CIBIS_Duplicate_Check__c> cibisList = [SELECT Id,Cibis_First_Name__c,Case__c,CIBIS_GENDER_CODE__c,Cibis_Last_Name__c,Cibis_Overall_Match__c,
                                                    CibisBirthDate__c,CIBIS_USMLE_ID__c,CibisMedicalSchoolCode__c,Contact__c FROM CIBIS_Duplicate_Check__c WHERE Contact__c =:contactId WITH SECURITY_ENFORCED ORDER BY Cibis_Overall_Match__c DESC];
        return cibisList;
    }
    
    /*
Returns a list of ApplicantDuplicateMatchModel representing contact (applicant) matches.

TODO: Refactor duplicate check logic into its own Service class for code reusability.
*/
    @AuraEnabled
    public static List<ApplicantDuplicateMatchModel> getApplicantMatches(String caseId){
        List<ApplicantDuplicateMatchModel> result = new List<ApplicantDuplicateMatchModel>();
        Case cse = CaseService.getCase(caseId);
        if(cse.ContactId == null){
            throw new ControllerException('Identity Verification case must have a contact.');
        }
        Contact cnt = ContactService.getContact(cse.ContactId);
        if(cnt != null){
            Duplicate_Check_Setting__mdt settings = getDuplicateCheckSettings();
            String scenarioId = settings.Non_Exact_Match_Applicant_Scenario_ID__c;
            if(scenarioId == null){
                throw new ServiceException('Could not load Duplicate Check Settings.');
            }
            Contact criteria = new Contact(
                DC_Last_Name_Exact__c = cnt.LastName,
                DC_Last_Name_Partial__c = cnt.LastName,
                DC_Rest_of_Name_Exact__c = cnt.FirstName,
                DC_Rest_of_Name_Partial__c = cnt.FirstName,
                DC_Last_Rest_of_Name_Switch_Partial__c = cnt.FirstName,
                DC_Last_Rest_of_Name_Switch_Exact__c = cnt.FirstName,
                DC_Prev_Rest_of_Name_Exact__c = cnt.Previous_Rest_of_Name__c,
                DC_Prev_Rest_of_Name_Partial__c = cnt.Previous_Rest_of_Name__c,
                DC_Prev_Last_Name_Exact__c = cnt.Previous_Last_Name__c,
                DC_Prev_Last_Name_Partial__c = cnt.Previous_Last_Name__c,
                DC_Prev_Last_Prev_Rest_Switch_Exact__c = cnt.Previous_Rest_of_Name__c,
                DC_Prev_Last_Prev_Rest_Switch_Partial__c = cnt.Previous_Rest_of_Name__c,
                DC_DOB_Day_Exact__c = cnt.Birthdate == null ? null : String.valueOf(cnt.Birthdate.day()),
                DC_DOB_Month_Exact__c = cnt.Birthdate == null ? null : String.valueOf(cnt.Birthdate.month()),
                DC_DOB_Month_Day_Switch_Exact__c = cnt.Birthdate == null ? null : String.valueOf(cnt.Birthdate.day()),
                DC_DOB_Year_Exact__c = cnt.Birthdate == null ? null : String.valueOf(cnt.Birthdate.year()),
                Gender__c = cnt.Gender__c
            );
            dupcheck.dc3Api dc = new dupcheck.dc3Api();
            Map<String, List<dupcheck.dc3SearchResult>> searchResult = null;
            Map<String, Integer> contactIdScoreMap = new Map<String, Integer>();
            if(test.isRunningTest()) {
                searchResult = new Map<String, List<dupcheck.dc3SearchResult>>();
                searchResult.put(Constants.CONTACT_OBJECT_PREFIX, new List<dupcheck.dc3SearchResult>());
                dupcheck.dc3SearchResult item1 = new dupcheck.dc3SearchResult();
                Contact c = [select Id, FirstName, LastName from Contact limit 1];
                item1.score = 100;
                item1.objectData = c;
                searchResult.get(Constants.CONTACT_OBJECT_PREFIX).add(item1);
            }
            else {
                searchResult = dc.doSearch(criteria);
            }
            //Code commented below to get only non exact match scenario results. - Dec 21/2020 - Shailaja Yerneni
            // build up the contact id score map
            /*if (searchResult.containsKey(Constants.CONTACT_OBJECT_PREFIX)) {
for (dupcheck.dc3SearchResult r : searchResult.get(Constants.CONTACT_OBJECT_PREFIX)) {
contactIdScoreMap.put(r.objectData.Id, r.score);
System.debug('contactIdScoreMap: ' + contactIdScoreMap);
}
}*/
            if (searchResult.containsKey(Constants.CONTACT_OBJECT_PREFIX)){
                for (dupcheck.dc3SearchResult r : searchResult.get(Constants.CONTACT_OBJECT_PREFIX)){
                    for(dupcheck.dc3SearchResult.ScenarioScore ss : r.ScenarioScores){
                        if(ss.scenarioId == scenarioId) {
                            if(settings.Non_Exact_Match_Applicant_Threshold__c != null && settings.Non_Exact_Match_Applicant_Threshold__c >= 0 && ss.scenarioScore >= settings.Non_Exact_Match_Applicant_Threshold__c) {
                                contactIdScoreMap.put(r.objectData.Id, ss.scenarioScore);
                            }
                        }
                    }
                }
            }
            Map<Id, Contact> contactMap = new Map<Id, Contact>(
                [
                    SELECT
                    Id,
                    LastName,
                    FirstName,
                    Birthdate,
                    Birth_Country__c,
                    Gender__c,
                    Medschool_Code__c,
                    Overall_Match__c,
                    US_Social_Security__c
                    FROM
                    Contact
                    WHERE
                    Id in :contactIdScoreMap.keySet()]);
            for(Contact c : contactMap.values()) {
                if(cse.ContactId == c.Id)
                    continue;
                ApplicantDuplicateMatchModel model = new ApplicantDuplicateMatchModel();
                model.Id = c.Id;
                model.LastName = c.LastName;
                model.RestOfName = c.FirstName;
                model.BirthDate = c.Birthdate;
                model.BirthCountry = c.Birth_Country__c;
                model.Gender = c.Gender__c;
                model.MedschoolCode = c.Medschool_Code__c;
                model.Score = contactIdScoreMap.get(c.Id);
                result.add(model);
            }
            result.sort();
        }
        return result;
    }
    /*
Returns the the duplicate check settings.
If not found, throws an exception.

TODO: This code is duplicated. Refactor into a Service or Utility class for reusability.
*/
    @testVisible
    private static Duplicate_Check_Setting__mdt getDuplicateCheckSettings() {
        List<Duplicate_Check_Setting__mdt> mdt = [
            select
            Applicant_Create_Bucket_End_Range__c,
            Applicant_Create_Bucket_Start_Range__c,
            Applicant_Exact_Match_Score__c,
            Applicant_Match_Bucket_End_Range__c,
            Applicant_Match_Bucket_Start_Range__c,
            DeveloperName,
            Entity_Exact_Match_Score__c,
            Exact_Match_Applicant_Scenario_ID__c,
            Exact_Match_Entity_Scenario_ID__c,
            Id,
            Label,
            Language,
            MasterLabel,
            NamespacePrefix,
            Non_Exact_Match_Applicant_Scenario_ID__c,
            Non_Exact_Match_Entity_Scenario_ID__c,
            Non_Exact_Match_Applicant_Threshold__c,
            QualifiedApiName
            from
            Duplicate_Check_Setting__mdt
            where
            DeveloperName = 'Default_Settings'
        ];
        if(mdt.size() == 0) {
            throw new ControllerException('Could not find Duplicate Check Settings (custom metadata).');
        }
        // return the only custom setting
        return mdt[0];
    }
    
    
    /*
This method returns a case using the case id.
*/
    @AuraEnabled
    public static Case getCase(String caseId) {
        return CaseService.getCase(caseId);
    }
    
    /**
* Created by Shailaja Yerneni 
* Method Name: getContactAssociationRecord
* Purpose : Method to get ContactAssociation Record
* Return Type : ContactAssociationType
* Date: 7/29/2020. User Story#843
*/
    @AuraEnabled
    public static Contact_Association_Type__c getContactAssociationRecord(String contactId) {
        Contact_Association_Type__c contactAssociation = new Contact_Association_Type__c();
        List<Contact_Association_Type__c> contAssnList = [SELECT id, Account__c, Account__r.Name, Graduation_Year__c FROM Contact_Association_Type__c WHERE Contact__c =: contactId AND recordtype.DeveloperName =: Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL];
        if(!contAssnList.isEmpty()){
            contactAssociation = contAssnList[0];
        }
        return contactAssociation;
    }
    
    
    @AuraEnabled
    public static Content_Manager__c getContentManagerInfo(String strConfirmType) {
        if(String.isNotBlank(strConfirmType)) {
            Content_Manager__c obj = [SELECT Id, Name, Content__c, Page_Name__c,Subject__c, Process_Flow__c, Unique_Name__c  From Content_Manager__c WHERE Name =:strConfirmType];
            if(obj != null) {
                return obj;
            }
            else {
                throw new AuraHandledException('Content Manger Record Not Found');
            }
        }
        else {
            throw new AuraHandledException('Please enter valid confirm type');
        }
    }

    @AuraEnabled
    public static Case getContactDetails(Id CaseId){
        try {
            Case conData = [SELECT Id, Contact.LastName, Contact.Name, Contact.USMLE_ID__c, Contact.Birthdate, Contact.Gender__c, Contact.Medschool_Code__c FROM Case WHERE Id=:CaseId LIMIT 1];
            return conData;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}