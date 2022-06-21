//Created by Matthew on 2019-05-23.

public with sharing class DuplicateCheckController{
    @AuraEnabled
    public static Verification_Request__c getVerificationRequest(String caseId){
        // get the case
        Case cse = CaseService.getCase(caseId);
        // verify we got a case
        if(cse == null) throw new ServiceException('Could not find case with Id ' + caseId);
        // return req
        return VerificationRequestService.getVerificationRequest(cse.Verification_Request__c);
    }

    @AuraEnabled
    public static List<ApplicantDuplicateMatchModel> getApplicantMatches(String caseId){
        // declare the result
        List<ApplicantDuplicateMatchModel> result = new List<ApplicantDuplicateMatchModel>();
        // get the case
        Case cse = CaseService.getCase(caseId);
        // get applicant verification request data
        Verification_Request__c req = VerificationRequestService.getVerificationRequest(cse.Verification_Request__c);
        // make sure we have data
        if(req != null){
            // create an in-memory contact used for search criteria
            Contact criteria = new Contact(
                    LastName = req.Last_Name__c,
                    FirstName = req.Rest_of_Name__c,
                    Birthdate = req.Birth_Date__c,
                    Birth_Country__c = req.Birth_Country__c,
                    Gender__c = req.Gender__c
            );
            dupcheck.dc3Api dc = new dupcheck.dc3Api();
            // hold search result and build contact id score map
            Map<String, List<dupcheck.dc3SearchResult>> searchResult = dc.doSearch(criteria);
            Map<String, Integer> contactIdScoreMap = new Map<String, Integer>();
            // build up the contact id score map
            if(searchResult.containsKey(Constants.CONTACT_OBJECT_PREFIX)){
                for(dupcheck.dc3SearchResult r : searchResult.get(Constants.CONTACT_OBJECT_PREFIX)){
                    contactIdScoreMap.put(r.objectData.Id, r.score);
                }
            }
            // create a map of contacts using contact id keyset
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
            // finally build result
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
            result.sort();
        }
        return result;
    }
    @AuraEnabled
    public static List<EntityDuplicateMatchModel> getEntityMatches(String caseId){
        // declare the result
        List<EntityDuplicateMatchModel> result = new List<EntityDuplicateMatchModel>();
        // get the case
        Case cse = CaseService.getCase(caseId);
        // get entity verification request data
        Verification_Request__c load = VerificationRequestService.getVerificationRequest(cse.Verification_Request__c);
        // make sure we have data
        if(load != null){            
            // create an in-memory account used for search criteria
            Account criteria = new Account(
                    Name = load.Medschool_Name__c
            );
            //initialize the search api
            dupcheck.dc3Api dc = new dupcheck.dc3Api();
            // hold search result and build contact id score map
            Map<String, List<dupcheck.dc3SearchResult>> searchResult = null;
            if(test.isRunningTest()){
                searchResult = new Map<String, List<dupcheck.dc3SearchResult>>();
                searchResult.put(Constants.ACCOUNT_OBJECT_PREFIX, new List<dupcheck.dc3SearchResult>());
                dupcheck.dc3SearchResult item1 = new dupcheck.dc3SearchResult();
                Account cnt = [select Id,Name from Account limit 1];
                item1.score = 100;
                item1.objectData = cnt;
            }
            else{
                searchResult = dc.doSearch(criteria);
            }
            Map<String, Integer> accountIdScoreMap = new Map<String, Integer>();
            // build up the contact id score map
            if(searchResult.containsKey(Constants.ACCOUNT_OBJECT_PREFIX)){
                for(dupcheck.dc3SearchResult r : searchResult.get(Constants.ACCOUNT_OBJECT_PREFIX)){
                    accountIdScoreMap.put(r.objectData.Id, r.score);
                }
            }
            // create a map of accounts using contact id keyset
            Map<Id, Account> contactMap = new Map<Id, Account>([select Id, Name, BillingCountry from Account where Id in :accountIdScoreMap.keySet()]);
            // finally build result
            for(Account a : contactMap.values()){
                EntityDuplicateMatchModel model = new EntityDuplicateMatchModel();
                model.Id = a.Id;
                model.Score = accountIdScoreMap.get(a.Id);
                model.SchoolCode = 'TODO';
                model.SchoolName = a.Name;
                model.Country = a.BillingCountry;
                model.InstitutionId = 'TODO';
                model.InstitutionName = 'TODO';
                result.add(model);
            }
            // sort by score (via ApplicantDuplicateMatchComparable)
            result.sort();
        }
        return result;
    }
    @AuraEnabled
    public static void linkApplicant(String caseId, String contactId){
        // get the case
        Case cse = CaseService.getCase(caseId);
        // verify we got a case
        if(cse == null) throw new ServiceException('Could not find case with Id ' + caseId);
        // get the contact
        Contact cnt = ContactService.getContact(contactId);
        // verify we got a contact
        if(cnt == null) throw new ServiceException('Could not find contact with Id ' + contactId);
        // set the contact on the case
        cse.ContactId = contactId;
        // update the case
        CaseService.updateCase(cse);
        // get case again
        cse = CaseService.getCase(caseId);
        // clear the account
        cse.AccountId = null;
        // update the case again
        CaseService.updateCase(cse);
    }
    @AuraEnabled
    public static void unlinkApplicant(String caseId){
        // get the case
        Case cse = CaseService.getCase(caseId);
        // verify we got a case
        if(cse == null) throw new ServiceException('Could not find case with Id ' + caseId);
        // remove the contact and (household) account from case
        cse.ContactId = null;
        cse.AccountId = null;
        // update the case
        CaseService.updateCase(cse);
    }
    @AuraEnabled
    public static void linkEntity(String caseId, String accountId){
        // get the case
        Case cse = CaseService.getCase(caseId);
        // verify we got a case
        if(cse == null) throw new ServiceException('Could not find case with Id ' + caseId);
        // get the account
        Account acct = AccountService.getAccount(accountId);
        // verify we got an account
        if(acct == null) throw new ServiceException('Could not find account with Id ' + accountId);
        // set the account on the case attribute
        CaseService.setCaseAttribute(caseId, Constants.REQUEST_VERIFICATION_LINKED_ENTITY_ID_ATTRIBUTE_NAME, accountId);
    }
    @AuraEnabled
    public static void unlinkEntity(String caseId){
        // get the case
        Case cse = CaseService.getCase(caseId);
        // verify we got a case
        if(cse == null) throw new ServiceException('Could not find case with Id ' + caseId);
        // remove account from case attribute
        CaseService.removeCaseAttribute(caseId, Constants.REQUEST_VERIFICATION_LINKED_ENTITY_ID_ATTRIBUTE_NAME);
    }
    //   This method creates a new applicant (contact) and links it to the case using verification request data.     
    @AuraEnabled
    public static Contact createLinkApplicant(String caseId){
        // get the case
        Case cse = CaseService.getCase(caseId);
        // verify we got a case
        if(cse == null) throw new ServiceException('Could not find case with Id ' + caseId);
        // get the request data
        Verification_Request__c req = VerificationRequestService.getVerificationRequest(cse.Verification_Request__c);
        // verify we have the request
        if(req == null) throw new ServiceException('Could not find verification request with case id ' + caseId);
        // get the EICS Applicant record type
        List<RecordType> rts = [select Id from RecordType where SobjectType = 'Contact' and Name = :Constants.CONTACT_RECORD_TYPE_EICS_APPLICANT];
        // verify we have the record type
        if(rts.size() == 0) throw new ServiceException('Could not find contact record type named ' + Constants.CONTACT_RECORD_TYPE_EICS_APPLICANT);
        // create a contact
        Contact c = new Contact(
                RecordTypeId = rts[0].Id,
                Candidate_Code__c = req.Candidate_Code__c,
                LastName = req.Last_Name__c,
                FirstName = req.Rest_of_Name__c,
                Gender__c = req.Gender__c,
                Birthdate = req.Birth_Date__c,
                Birth_Country__c = req.Birth_Country__c,
                Medschool_Code__c = req.Medschool_Code__c,
                USMLE_ID__c = req.USMLE_ID__c,
                EICS_ID__c = req.EICS_ID__c,
                Previous_Last_Name__c = req.Previous_Last_Name__c,
                Previous_Rest_of_Name__c = req.Previous_Rest_of_Name__c,
                MailingCountryCode = req.Residence_Country__c
        );
        insert c;
        // associate with case
        cse.ContactId = c.Id;
        CaseService.updateCase(cse);
        // return contact
        return c;
    }
    @AuraEnabled
    public static Case createEntityRequest(String caseId){
        // get the case
        Case credentialReviewCase = CaseService.getCase(caseId);
        // verify we got a case
        if(credentialReviewCase == null) throw new ServiceException('Could not find case with Id ' + caseId);
        // get the request data
        Verification_Request__c req = VerificationRequestService.getVerificationRequest(credentialReviewCase.Verification_Request__c);
        // verify we have the request
        if(req == null) throw new ServiceException('Could not find verification request with case id ' + caseId);
        // get the Entity Service Request record type
        List<RecordType> rts = [select Id from RecordType where SobjectType = 'Case' and Name = :Constants.CASE_RECORD_TYPE_ENTITY_SERVICE_REQUEST];
        // verify we have the record type
        if(rts.size() == 0) throw new ServiceException('Could not find case record type named ' + Constants.CASE_RECORD_TYPE_ENTITY_SERVICE_REQUEST);
        // get the Entity Service Requests Queue
        List<Group> entityServiceRequestsQueue = [select Id from Group where Type = 'Queue' and Name = :Constants.CASE_QUEUE_ENTITY_SERVICE_REQUESTS];
        // verify we have the queue
        if(entityServiceRequestsQueue.size() == 0) throw new ServiceException('Could not find case queue named ' + Constants.CASE_QUEUE_ENTITY_SERVICE_REQUESTS);
        // create entity request case
        Case entityRequestCase = new Case(
                ParentId = credentialReviewCase.Id,
                Internal_Status__c = Constants.CASE_STATUS_NEW,
                OwnerId = entityServiceRequestsQueue[0].Id,
                Type = Constants.CASE_TYPE_NEW_ENTITY_REQUEST,
                RecordTypeId = rts[0].Id
        );
        insert entityRequestCase;
        // get the Entity Service Requests Queue
        List<Group> duplicateCheckQueue = [select Id from Group where Type = 'Queue' and Name = :Constants.CASE_QUEUE_DUPLICATE_CHECK];
        // verify we have the queue
        if(duplicateCheckQueue.size() == 0) throw new ServiceException('Could not find case queue named ' + Constants.CASE_QUEUE_DUPLICATE_CHECK);
        // update the case
        credentialReviewCase.Internal_Status__c = Constants.CASE_STATUS_ON_HOLD_PENDING_INSTITUTION_ADD;
        credentialReviewCase.Entity_Service_Request__c = entityRequestCase.Id;
        credentialReviewCase.OwnerId = duplicateCheckQueue[0].Id;
        update credentialReviewCase;
        // return the entity request case
        return entityRequestCase;
    }
    @AuraEnabled
    public static Case getCase(String caseId){
        return CaseService.getCase(caseId);
    }
    @AuraEnabled
    public static Contact getContact(String contactId){
        return ContactService.getContact(contactId);
    }
    @AuraEnabled
    public static Account getAccount(String accountId){
        return AccountService.getAccount(accountId);
    }
    @AuraEnabled
    public static String getLinkedEntityId(String caseId){
        return CaseService.getCaseAttribute(caseId, Constants.REQUEST_VERIFICATION_LINKED_ENTITY_ID_ATTRIBUTE_NAME);
    }
    //This method returns a single case, representing the entity service request child cases for the specific caseId.     
    @AuraEnabled
    public static Case getEntityServiceRequest(String caseId){
        List<Case> cases = CaseService.getChildCases(caseId);
        if(cases.size() == 0){
            // no child cases where found, so return null indicating no entity service request
            return null;
        }
        else if(cases.size() > 1){
            // raise error
            throw new ServiceException('Case should only have 0 or 1 child cases.');
        }
        else{
            List<RecordType> rts = [select Id from RecordType where SobjectType = 'Case' and Name = :Constants.CASE_RECORD_TYPE_ENTITY_SERVICE_REQUEST];
            // verify we have the record type
            if(rts.size() != 1) throw new ServiceException('Could not find case record type named ' + Constants.CASE_RECORD_TYPE_ENTITY_SERVICE_REQUEST);
            if(cases[0].RecordTypeId == rts[0].Id){
                // return the entity service request case
                return cases[0];
            }
            else{
                // just return null
                return null;
            }
        }
    }
}