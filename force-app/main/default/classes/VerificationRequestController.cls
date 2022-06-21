/**
 * Created by Matthew on 2019-07-05.
 *
 * Handles operations specific to verification request process and duplicate applicant/entity matching/linking.
 *
 */
public with sharing class VerificationRequestController{
    Static final String verReqMsg = 'Could not find verification request with case id ';
    /*
        This method will find the the verification request by case Id.
        The case has a Verification Request field, pointing to the Verification Request record.
         - If the case id passed in cannot be find, throws exception.
         - If the Verification Request cannot be found, returns null;
         - Else returns the Verification Request record.
     */
    @AuraEnabled
    public static Verification_Request__c getVerificationRequest(String caseId){
        Case cse = CaseService.getCase(caseId);
        if(cse == null){
            throw new ServiceException('Could not find case with Id ' + caseId);
        }
        if(cse.Verification_Request__c  == null){
            return null;
        }
        return VerificationRequestService.getVerificationRequest(cse.Verification_Request__c);
    }
    /*
        Returns a list of ApplicantDuplicateMatchModel representing contact (applicant) matches.
     */
    @AuraEnabled
    public static List<ApplicantDuplicateMatchModel> getApplicantMatches(String caseId){
        List<ApplicantDuplicateMatchModel> result = new List<ApplicantDuplicateMatchModel>();
        Case cse = CaseService.getCase(caseId);
        Verification_Request__c req = VerificationRequestService.getVerificationRequest(cse.Verification_Request__c);
        if(req!=null){
            Duplicate_Check_Setting__mdt settings = getDuplicateCheckSettings();
            String scenarioId = settings.Non_Exact_Match_Applicant_Scenario_ID__c;
            if(scenarioId == null){
                throw new ServiceException('Could not load Duplicate Check Settings.');
            }
            // create an in-memory contact used for search criteria
            Contact criteria = new Contact(
                    DC_Last_Name_Exact__c = req.Last_Name__c,
                    DC_Last_Name_Partial__c = req.Last_Name__c,
                    DC_Rest_of_Name_Exact__c = req.Rest_of_Name__c,
                    DC_Rest_of_Name_Partial__c = req.Rest_of_Name__c,
                    DC_Last_Rest_of_Name_Switch_Partial__c = req.Rest_of_Name__c,
                    DC_Last_Rest_of_Name_Switch_Exact__c = req.Rest_of_Name__c,
                    DC_Prev_Rest_of_Name_Exact__c = req.Previous_Rest_of_Name__c,
                    DC_Prev_Rest_of_Name_Partial__c = req.Previous_Rest_of_Name__c,
                    DC_Prev_Last_Name_Exact__c = req.Previous_Last_Name__c,
                    DC_Prev_Last_Name_Partial__c = req.Previous_Last_Name__c,
                    DC_Prev_Last_Prev_Rest_Switch_Exact__c = req.Previous_Rest_of_Name__c,
                    DC_Prev_Last_Prev_Rest_Switch_Partial__c = req.Previous_Rest_of_Name__c,
                    DC_DOB_Day_Exact__c = req.Birth_Date__c == null ? null : String.valueOf(req.Birth_Date__c.day()),
                    DC_DOB_Month_Exact__c = req.Birth_Date__c == null ? null : String.valueOf(req.Birth_Date__c.month()),
                    DC_DOB_Month_Day_Switch_Exact__c = req.Birth_Date__c == null ? null : String.valueOf(req.Birth_Date__c.day()),
                    DC_DOB_Year_Exact__c = req.Birth_Date__c == null ? null : String.valueOf(req.Birth_Date__c.year()),
					BirthDate = req.Birth_Date__c,
                    Gender__c = req.Gender__c
            );
            dupcheck.dc3Api dc = new dupcheck.dc3Api();
            Map<String, List<dupcheck.dc3SearchResult>> searchResult = null;
            Map<String, Integer> contactIdScoreMap = new Map<String, Integer>();
            if(test.isRunningTest()){
                searchResult = new Map<String, List<dupcheck.dc3SearchResult>>();
                searchResult.put(Constants.CONTACT_OBJECT_PREFIX, new List<dupcheck.dc3SearchResult>());
                dupcheck.dc3SearchResult item1 = new dupcheck.dc3SearchResult();
                Contact cnt = [select Id, FirstName, LastName from Contact WITH SECURITY_ENFORCED limit 1  ];
                item1.score = 100;
                item1.objectData = cnt;
            }
            else{
                searchResult = dc.doSearch(criteria);
            }
            // build up the contact id score map
            if(searchResult.containsKey(Constants.CONTACT_OBJECT_PREFIX)){
                for(dupcheck.dc3SearchResult r : searchResult.get(Constants.CONTACT_OBJECT_PREFIX)){
					for(dupcheck.dc3SearchResult.ScenarioScore ss : r.ScenarioScores){
						if(ss.scenarioId == scenarioId){
							if(settings.Non_Exact_Match_Applicant_Threshold__c != null && settings.Non_Exact_Match_Applicant_Threshold__c >= 0 && ss.scenarioScore >= settings.Non_Exact_Match_Applicant_Threshold__c){
                   				contactIdScoreMap.put(r.objectData.Id, ss.scenarioScore);
							}
                        }
                    }
                }
            }
            Map<Id, Contact> contactMap = new Map<Id, Contact>(
            [
                    select
                            Id,
                            LastName,
                            FirstName,
                            Birthdate,
                            Birth_Country__c,
                            Gender__c,
                            Medschool_Code__c
                    from
                            Contact
                    where
                            Id in :contactIdScoreMap.keySet()]);
            for(Contact c : contactMap.values()){
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
            // sort by score (via ApplicantDuplicateMatchComparable)
            result.sort();
        }
        return result;
    }
    public class AccountWrapper{
        public Boolean isSelected;
        public String id;
        public String name;
        public String address;
        public String parentAcc;
        public AccountWrapper(){
            this.isSelected = false;
        }
    }
    @AuraEnabled
    public static String fetchEntityData(String searchKey){
        String keyWord = '%'+searchKey+'%';
        Id entityRecTypId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Entity').getRecordTypeId();
        List<AccountWrapper> accData =new List<AccountWrapper>();
        for(Account acc : [SELECT Id,BillingAddress,BillingCity,BillingCountry,BillingPostalCode,
                           BillingState,BillingStreet,Name,Parent.Name 
                           FROM Account WHERE Name LIKE :keyWord AND RecordTypeId = :entityRecTypId WITH SECURITY_ENFORCED ]){
            AccountWrapper aw = new AccountWrapper();
            aw.id = acc.Id;
            aw.name = acc.Name;
            aw.parentAcc = acc.Parent.Name;
            String addrs =  '';
            if(acc.BillingCity != null){
               addrs += acc.BillingCity + ' ';
            }
            if(acc.BillingCountry != null){
               addrs += acc.BillingCountry;
            }
            aw.address = addrs;
            accData.add(aw);
        }
        return JSON.serialize(accData);
    }
    /*
        Returns a list of EntityDuplicateMatchModel representing account (entity) matches.
     */
    @AuraEnabled
    public static List<EntityDuplicateMatchModel> getEntityMatches(String caseId){
        List<EntityDuplicateMatchModel> result = new List<EntityDuplicateMatchModel>();
        Case cse = CaseService.getCase(caseId);
        Verification_Request__c req = VerificationRequestService.getVerificationRequest(cse.Verification_Request__c);
        if(req != null){
            Duplicate_Check_Setting__mdt settings = getDuplicateCheckSettings();
            String scenarioId = settings.Non_Exact_Match_Entity_Scenario_ID__c;
            if(scenarioId == null){
                throw new ServiceException('Could not load Duplicate Check Settings.');
            }
            // create an in-memory account used for search criteria
            // extra spaces used in front to prevent null pointer exception
            Account criteria = new Account(
                    Name = (' ' + StringUtil.NullSafe(req.Medschool_Name__c) + ' ' + StringUtil.NullSafe(req.University_Name__c) + ' ' + StringUtil.NullSafe(req.Institution_Name__c)).trim(),
                    Medschool_Code__c = (' ' + StringUtil.NullSafe(req.Medschool_Code__c) + ' ' + StringUtil.NullSafe(req.University_Code__c)).trim(),
                	Institution_ID__c = (' ' + StringUtil.NullSafe(req.Institution_ID__c))
            );
            dupcheck.dc3Api dc = new dupcheck.dc3Api();
            Map<String, List<dupcheck.dc3SearchResult>> searchResult = null;
            Map<String, Integer> accountIdScoreMap = new Map<String, Integer>();
            if(test.isRunningTest()){
                searchResult = new Map<String, List<dupcheck.dc3SearchResult>>();
                searchResult.put(Constants.ACCOUNT_OBJECT_PREFIX, new List<dupcheck.dc3SearchResult>());
                dupcheck.dc3SearchResult item1 = new dupcheck.dc3SearchResult();
                Account acct = [select Id, Name from Account WITH SECURITY_ENFORCED limit 1];
                item1.score = 100;
                item1.objectData = acct;
                searchResult.get(Constants.ACCOUNT_OBJECT_PREFIX).add(item1);
            }
            else{
                searchResult = dc.doSearch(criteria);
            }
            if(searchResult.containsKey(Constants.ACCOUNT_OBJECT_PREFIX)){
                for(dupcheck.dc3SearchResult r : searchResult.get(Constants.ACCOUNT_OBJECT_PREFIX)){
                    accountIdScoreMap.put(r.objectData.Id, r.score);
                }
            }
            Map<Id, Account> accountMap = new Map<Id, Account>([select Id, Name, BillingCity, BillingCountry, Medschool_Code__c, Institution_ID__c from Account where Id in :accountIdScoreMap.keySet()]);
            // finally build result
            // TODO: Reviewed to do's
            for(Account a : accountMap.values()){
                EntityDuplicateMatchModel model = new EntityDuplicateMatchModel();
                model.Id = a.Id;
                model.Score = accountIdScoreMap.get(a.Id);
                model.SchoolCode = a.Medschool_Code__c;
                model.SchoolName = a.Name;
                model.City = a.BillingCity;
                model.Country = a.BillingCountry;
                model.InstitutionId = a.Institution_ID__c;
                model.InstitutionName = a.Name;
                result.add(model);
            }
            // sort by score (via ApplicantDuplicateMatchComparable)
            result.sort();
        }
        return result;
    }
    /*
        Returns a list of AKANamesDuplicateMatchModel representing Also Known as names matches.
     */
    @AuraEnabled
    public static List<AKANamesDuplicateMatchModel> getAKANamesMatches(String caseId){
        List<AKANamesDuplicateMatchModel> result = new List<AKANamesDuplicateMatchModel>();
        Case cse = CaseService.getCase(caseId);
        Verification_Request__c req = VerificationRequestService.getVerificationRequest(cse.Verification_Request__c);
        if(req != null){
            aka_Names__c akaCriteria = new aka_Names__c(
                Name = (' ' + StringUtil.NullSafe(req.Medschool_Name__c) + ' ' + StringUtil.NullSafe(req.University_Name__c) + ' ' + StringUtil.NullSafe(req.Institution_Name__c)).trim()
            );
            dupcheck.dc3Api dc = new dupcheck.dc3Api();
            Map<String, List<dupcheck.dc3SearchResult>> akaNamesSearchResult = null;
            Map<String, Integer> akaNamesIdScoreMap = new Map<String, Integer>();
            if(test.isRunningTest()){
                akaNamesSearchResult = new Map<String, List<dupcheck.dc3SearchResult>>();
                akaNamesSearchResult.put(Constants.AKANAMES_OBJECT_PREFIX, new List<dupcheck.dc3SearchResult>());
                dupcheck.dc3SearchResult item1 = new dupcheck.dc3SearchResult();
                aka_Names__c aka = [select Id, Name from aka_Names__c WITH SECURITY_ENFORCED limit 1];
                item1.score = 100;
                item1.objectData = aka;
                akaNamesSearchResult.get(Constants.AKANAMES_OBJECT_PREFIX).add(item1);
            }
            else{
                akaNamesSearchResult = dc.doSearch(akaCriteria);
            }
            if (akaNamesSearchResult.containsKey(Constants.AKANAMES_OBJECT_PREFIX)) {
                for (dupcheck.dc3SearchResult r : akaNamesSearchResult.get(Constants.AKANAMES_OBJECT_PREFIX)) {
                    akaNamesIdScoreMap.put(r.objectData.Id, r.score);
                }
            }
            Map<Id, aka_Names__c> akaNamesMap = new Map<Id, aka_Names__c>([select Id, Name, Account__r.Name from aka_Names__c where Id in :akaNamesIdScoreMap.keySet()]);
            for(aka_Names__c a : akaNamesMap.values()){
                AKANamesDuplicateMatchModel model = new AKANamesDuplicateMatchModel();
                model.Id = a.Id;
                model.Score = akaNamesIdScoreMap.get(a.Id);
                model.Name = a.Name;
                model.AccountName = a.Account__r.Name;
                result.add(model);
            }
            result.sort();
        }
        return result;
    }
    /*
        Links the applicant by setting the case's contactId.
     */
    @AuraEnabled
    public static void linkApplicant(String caseId, String contactId){
        // TODO: Check args
        // get the case
        Case cse = CaseService.getCase(caseId);
        if(cse == null){
            throw new ServiceException('Could not find case with Id ' + caseId);
        }
        Contact cnt = ContactService.getContact(contactId);
        if(cnt == null){
            throw new ServiceException('Could not find contact with Id ' + contactId);
        }
        cse.ContactId = contactId;
        CaseService.updateCase(cse);
    }
    /*
        Unlinks the applicant from the case.
     */
    @AuraEnabled
    public static void unlinkApplicant(String caseId){
        Case cse = CaseService.getCase(caseId);
        if(cse == null){
            throw new ServiceException('Could not find case with Id ' + caseId);
        }
        cse.ContactId = null;
        cse.AccountId = null;
        CaseService.updateCase(cse);
    }
    /*
        Links to entity to the case by setting case attribute.
     */
    @AuraEnabled
    public static void linkEntity(String caseId, String accountId){
        Case cse = CaseService.getCase(caseId);
        if(cse == null){
            throw new ServiceException('Could not find case with Id ' + caseId);
        }
        Account acct = AccountService.getAccount(accountId);
        if(acct == null){
            throw new ServiceException('Could not find account with Id ' + accountId);
        }
        CaseService.setCaseAttribute(caseId, Constants.REQUEST_VERIFICATION_LINKED_ENTITY_ID_ATTRIBUTE_NAME, accountId);
    }
    @AuraEnabled
    public static void unlinkEntity(String caseId){
        Case cse = CaseService.getCase(caseId);
        if(cse == null){
            throw new ServiceException('Could not find case with Id ' + caseId);
        }
        CaseService.removeCaseAttribute(caseId, Constants.REQUEST_VERIFICATION_LINKED_ENTITY_ID_ATTRIBUTE_NAME);
    }
    /*
        This method creates a new applicant (contact) and links it to the case using verification request data.
     */
    @AuraEnabled
    public static Contact createLinkApplicant(String caseId){
        Case cse = CaseService.getCase(caseId);
        if(cse == null){
            throw new ServiceException('Could not find case with Id ' + caseId);
        }
        Verification_Request__c req = VerificationRequestService.getVerificationRequest(cse.Verification_Request__c);
        if(req == null){
            throw new ServiceException(verReqMsg + caseId);
        }
        List<RecordType> rts = new List<RecordType>();
        if(cse.recordType.DeveloperName == Constants.CASE_RECORD_TYPE_IFOM_REQUEST){
            rts = [select Id from RecordType where SobjectType = 'Contact' and DeveloperName = :Constants.CONTACT_RECORD_TYPE_IFOM_APPLICANT WITH SECURITY_ENFORCED];
            if(rts.size() == 0) {
                throw new ServiceException('Could not find contact record type named ' + Constants.CONTACT_RECORD_TYPE_IFOM_APPLICANT);
            }

        }else{
            rts = [select Id from RecordType where SobjectType = 'Contact' and Name = :Constants.CONTACT_RECORD_TYPE_EICS_APPLICANT WITH SECURITY_ENFORCED];
            if(rts.size() == 0){
                throw new ServiceException('Could not find contact record type named ' + Constants.CONTACT_RECORD_TYPE_EICS_APPLICANT);
            }
        }
        Contact c = new Contact (
                RecordTypeId = rts[0].Id,
                Candidate_Code__c = req.Candidate_Code__c,
                LastName = req.Last_Name__c,
                FirstName = req.Rest_of_Name__c,
                MiddleName = req.Middle_Name__c,
                Gender__c = req.Gender__c,
                Birthdate = req.Birth_Date__c,
                Email = req.Email__c,
                Birth_Country__c = req.Birth_Country__c,
                Medschool_Code__c = req.Medschool_Code__c,
                USMLE_ID__c = req.USMLE_ID__c,
                EICS_ID__c = req.EICS_ID__c,
                Previous_Last_Name__c = req.Previous_Last_Name__c,
                Previous_Rest_of_Name__c = req.Previous_Rest_of_Name__c,
                MailingCountry = req.Residence_Country__c,
                dupcheck__dc3DisableDuplicateCheck__c = True
        );
        if (Schema.sObjectType.Contact.isCreateable()){
            insert c;
        }
        cse.ContactId = c.Id;
        CaseService.updateCase(cse);
        return c;
    }
    /*
        This method creates a new entity request child case and links it to the parent credential review case.
     */
    @AuraEnabled
    public static Case createEntityRequest(String caseId){
        Case credentialReviewCase = CaseService.getCase(caseId);
        if(credentialReviewCase == null){
             throw new ServiceException('Could not find case with Id ' + caseId);
        }
        Verification_Request__c req = VerificationRequestService.getVerificationRequest(credentialReviewCase.Verification_Request__c);
        if(req == null){
             throw new ServiceException(verReqMsg + caseId);
        }
        List<RecordType> rts = [select Id from RecordType where SobjectType = 'Case' and Name = :Constants.CASE_RECORD_TYPE_NEW_ENTITY_REQUEST  WITH SECURITY_ENFORCED];
        if(rts.size() == 0){
             throw new ServiceException('Could not find case record type named ' + Constants.CASE_RECORD_TYPE_ENTITY_SERVICE_REQUEST);
        }
        List<Group> entityServiceRequestsQueue = [select Id from Group where Type = 'Queue' and Name = :Constants.CASE_QUEUE_ENTITY_SERVICE_REQUESTS  WITH SECURITY_ENFORCED];
        if(entityServiceRequestsQueue.size() == 0) {
             throw new ServiceException('Could not find case queue named ' + Constants.CASE_QUEUE_ENTITY_SERVICE_REQUESTS);
        }
        Case entityRequestCase = new Case(
                ParentId = credentialReviewCase.Id,
                Internal_Status__c = Constants.CASE_STATUS_NEW,
                OwnerId = entityServiceRequestsQueue[0].Id,
                Type = Constants.CASE_TYPE_NEW_ENTITY_REQUEST,
                Verification_Request__c = req.Id,
                RecordTypeId = rts[0].Id
        );
        if (Schema.sObjectType.Case.isCreateable()){
            insert entityRequestCase;
        }
        List<Group> duplicateCheckQueue = [select Id from Group where Type = 'Queue' and Name = :Constants.CASE_QUEUE_DUPLICATE_CHECK  WITH SECURITY_ENFORCED];
        if(duplicateCheckQueue.size() == 0){ 
            throw new ServiceException('Could not find case queue named ' + Constants.CASE_QUEUE_DUPLICATE_CHECK);
        }
            credentialReviewCase.Internal_Status__c = Constants.CASE_STATUS_ON_HOLD_PENDING_INSTITUTION_ADD;
            credentialReviewCase.Entity_Service_Request__c = entityRequestCase.Id;
            credentialReviewCase.OwnerId = duplicateCheckQueue[0].Id;
            if (Schema.sObjectType.Case.isUpdateable()){
                update credentialReviewCase;
            }
        return entityRequestCase;
    }
    /*
        This method returns a case using the case id.
     */
    @AuraEnabled
    public static Case getCase(String caseId){
        return CaseService.getCase(caseId);
    }
    /*
        This method returns a contact using the contact id.
     */
    @AuraEnabled
    public static Contact getContact(String contactId){
        return ContactService.getContact(contactId);
    }
    /*
        This method returns an account using the account id.
    */
    @AuraEnabled
    public static Account getAccount(String accountId){
        return AccountService.getAccount(accountId);
    }
    /*
        This method returns the linked entity id from the case attribute.
    */
    @AuraEnabled
    public static String getLinkedEntityId(String caseId){
        return CaseService.getCaseAttribute(caseId, Constants.REQUEST_VERIFICATION_LINKED_ENTITY_ID_ATTRIBUTE_NAME);
    }
    /*
        This method returns a single case, representing the entity service request child cases for the specific caseId.
        If not case is found, returns null;
        If more than one child case is found, throws exception.
     */
    @AuraEnabled
    public static Case getEntityServiceRequest(String caseId){
        List<Case> cases = CaseService.getChildCases(caseId);
        if(cases.size() == 0){
            return null;
        }
        else if(cases.size() > 1){
            throw new ServiceException('Case should only have 0 or 1 child cases.');
        }
        else{
            List<RecordType> rts = [select Id from RecordType where SobjectType = 'Case' and Name = :Constants.CASE_RECORD_TYPE_NEW_ENTITY_REQUEST WITH SECURITY_ENFORCED];
            if(rts.size()!=1){
                throw new ServiceException('Could not find case record type named ' + Constants.CASE_RECORD_TYPE_NEW_ENTITY_REQUEST);
            }
            if(cases[0].RecordTypeId == rts[0].Id){
                return cases[0];
            }
            else{
                return null;
            }
        }
    }
    /*
        This method handles all of the various actions/tasks necessary to take the case to the next step of credential review.
     */
    @AuraEnabled
    public static void proceed(String caseId){
        Map<String, Map<String, String>> attributeMap = new Map<String, Map<String, String>>();
        Case cse = CaseService.getCase(caseId);
        if(cse == null){
            throw new ControllerException('Could not find a case with the id ' + caseId);
        }
        List<Case_Attribute__c> caseAttrList = [SELECT Id,Value__c
            FROM Case_Attribute__c
            WHERE Case__c =: caseId
            AND Name =: Constants.REQUEST_VERIFICATION_LINKED_ENTITY_ID_ATTRIBUTE_NAME WITH SECURITY_ENFORCED];
        Verification_Request__c req = VerificationRequestService.getVerificationRequest(cse.Verification_Request__c);
        if(req == null){
            throw new ServiceException(verReqMsg + caseId);
        }
        if(cse.recordType.DeveloperName == Constants.CASE_RECORD_TYPE_IFOM_REQUEST){
            List<Contact_Association_Type__c> contAssnList = [SELECT id FROM Contact_Association_Type__c WHERE Contact__c =: cse.contactId AND recordtype.DeveloperName =: Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL WITH SECURITY_ENFORCED];
            if(contAssnList.isEmpty()){
                Contact_Association_Type__c contactAssociation = new Contact_Association_Type__c(
                    Contact__c = cse.contactId,
                    Account__c = caseAttrList[0].Value__c,
                    RecordTypeId=RecordTypeUtility.getRecordTypeIdByName('Contact_Association_Type__c', Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MED_SCHOOL),
                    Graduation_Month__c = VerificationRequestService.getMonthAsText(req.Graduation_Month__c),
                    Graduation_Year__c =  req.Graduation_Year__c,
                    Degree_Title__c = req.Medical_School_Degree__c,
                    Type__c=Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL,
                    Student_ID__c = req.Medical_School_Student_ID__c
                );
                if (Schema.sObjectType.Contact_Association_Type__c.isCreateable()){
                    insert contactAssociation;
                }
            }
            List<Group> groups = [select Id from Group where Type = 'Queue' and Name = :Constants.CASE_QUEUE_ENROLLMENT_VERIFICATION WITH SECURITY_ENFORCED];
            if(groups.size() != 1){
                throw new ControllerException('Could not find a case queue with the name ' + Constants.CASE_QUEUE_ENROLLMENT_VERIFICATION);
            }
            // update case owner, status and set entity (redundant now with case attribute linked entity id, needs to be refactored)
            cse.OwnerId = groups[0].Id;
            cse.Internal_Status__c = Constants.CASE_STATUS_PENDING_INITIAL_REVIEW;
            cse.Verification_Status__c = Constants.CASE_VERIFICATION_STATUS_NOT_REVIEWED;
            cse.Eligibility_Case_ID__c = req.Eligibility_Case_ID__c;
            cse.Registration_ID__c = req.Registration_ID__c;
            cse.Entity__c = CaseService.getCaseAttribute(cse.Id, Constants.REQUEST_VERIFICATION_LINKED_ENTITY_ID_ATTRIBUTE_NAME);
            CaseService.updateCase(cse);
        }
        else{
            List<Group> groups = [select Id from Group where Type = 'Queue' and Name = :Constants.CASE_QUEUE_CREDENTIAL_REVIEW WITH SECURITY_ENFORCED];
            if(groups.size() != 1){
                throw new ControllerException('Could not find a case queue with the name ' + Constants.CASE_QUEUE_CREDENTIAL_REVIEW);
            }
            // update case owner, status and set entity (redundant now with case attribute linked entity id, needs to be refactored)
            cse.OwnerId = groups[0].Id;
            cse.Internal_Status__c = Constants.CASE_STATUS_NEW;
            cse.Entity__c = CaseService.getCaseAttribute(cse.Id, Constants.REQUEST_VERIFICATION_LINKED_ENTITY_ID_ATTRIBUTE_NAME);
            CaseService.updateCase(cse);
            // setup contact association types if needed (this checks to see if types already exist before creating them)
            VerificationRequestService.createContactAssociationTypes(new String[] { caseId });
            VerificationRequestService.createCATS(new String[] { caseId });            
        }
        if(cse.recordType.DeveloperName == Constants.CASE_RECORD_TYPE_IFOM_REQUEST){
            VerificationRequestService.createAssetsFromVerificationRequestFiles(cse.Id);
        }else{
            VerificationRequestService.createAssetsFromVerificationRequestFiles(cse.Verification_Request__c);
        }           
        if (cse.Service__c == Constants.CASE_SERVICE_FCVS && Case.SObjectType.getDescribe().isCreateable()){
            List<Case> lstCase  =  VerReqRouteBatch.createCasesForSourceFSMB(cse.Id); 
            insert lstCase;
            List<String> newCaseList = new List<String>();
            for(case a:lstCase){
                newCaseList.add(a.id);
                attributeMap = CaseService.appendToAttributeMap(attributeMap, a.Id, Constants.REQUEST_VERIFICATION_LINKED_ENTITY_ID_ATTRIBUTE_NAME, cse.Entity__c);
                CaseService.setCaseAttributes(attributeMap);
            }
            VerificationRequestService.createContactAssociationTypes(newCaseList);
            VerificationRequestService.createCATS(newCaseList);
            //after FSMB cases are created. Create verification packet for the medical education form case
            //User story#17402 - As part of creating med edu case create a verification packet and assign the case, contact and isactive flag.
            List<Case> lstNewMefCases = [SELECT Id, Parentid,ContactId, Recordtype.DeveloperName FROM Case WHERE Parentid =:cse.Id AND Recordtype.DeveloperName =:Constants.CASE_RECORD_TYPE_MED_EDU_FORM];
            if(Verification_Packet__c.SObjectType.getDescribe().isCreateable()){
                Verification_Packet__c verPack = new Verification_Packet__c();
                verPack.Is_Active__c = true;
                verPack.Case__c = lstNewMefCases[0].Id;
                verPack.Contact__c = lstNewMefCases[0].ContactId;
                insert verPack;
            }
        }
    }
    /*
        Returns the the duplicate check settings.
        If not found, throws an exception.
     */
    @testVisible
    private static Duplicate_Check_Setting__mdt getDuplicateCheckSettings(){
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
                WITH SECURITY_ENFORCED                        
        ];
        if(mdt.size() == 0){
            throw new ControllerException('Could not find Duplicate Check Settings (custom metadata).');
        }
        return mdt[0];
    }
    /**
	 * Created by Femi 
	 * Method Name: getConfirmationMsg
	 * Purpose : Method to get confirmation message
	 * Return Type : String
	 */
	@AuraEnabled
	public static String getConfirmationMsg(String caseId){
        Case cse = CaseService.getCase(caseId);
        if(cse == null){
            throw new ControllerException('Could not find a case with the id ' + caseId);
        }
        if(cse.recordType.DeveloperName == Constants.CASE_RECORD_TYPE_IFOM_REQUEST){
            return 'You are about to complete this process and proceed to IFOM request. Do you wish to continue?';
        }
        return 'You are about to complete this process and proceed to credential review. Do you wish to continue?';
    }
    /**
	 * Created by Femi 
	 * Method Name: getContactAssociationRecord
	 * Purpose : Method to get ContactAssociation Record
	 * Return Type : ContactAssociationType
	 */
	@AuraEnabled
	public static Contact_Association_Type__c getContactAssociationRecord(String contactId){
        Contact_Association_Type__c contactAssociation = new Contact_Association_Type__c();
        List<Contact_Association_Type__c> contAssnList = [SELECT id, Account__c, Account__r.Name, Graduation_Year__c FROM Contact_Association_Type__c WHERE Contact__c =: contactId AND recordtype.DeveloperName =: Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL];
        if(!contAssnList.isEmpty()){
            contactAssociation = contAssnList[0];
        }
        return contactAssociation;
    }
}