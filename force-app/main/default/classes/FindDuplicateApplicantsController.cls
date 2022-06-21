public with sharing class FindDuplicateApplicantsController {
    public static string degreeSchoolvalue = System.Label.Contact_Medical_School_Record_Type; /**  'Degree School'; **/
        
    @AuraEnabled 
    public static list<Contact> getDuplicateMatchesById(Id contactId, Id caseId) {

        system.debug(contactId);
        Contact c = [SELECT name, firstname, lastname, BirthDate, Email, accountId from Contact where Id = :contactId];
        String cID = caseId;
        list<Contact> matchlist = FindDuplicateApplicantsController.getDuplicateMatchesByObject(c, cID);
        return matchlist;
        
    }
    
    @AuraEnabled
    public static list<Contact> getDuplicateMatchesByObject(Contact contactobject, Id caseId) {
        string Firstname = contactobject.firstname;
        string Lastname = contactobject.lastname;
        Date dob = contactobject.Birthdate;
        string degreetitlevalue = FindDuplicateApplicantsController.degreeSchoolvalue;
        Id duplicateRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Deactivated-Duplicated').getRecordTypeId();
        list<contact> duplicateslist = [SELECT CreatedDate, name, Email,firstname, accountId, RecordType.Developername, Birthdate, Generational_Suffix__c, Gender__c, EPIC_ID__c, USMLE_ID__c, EICS_ID__c, recordTypeId, npo02__Household__c, isDuplicate__c,(SELECT id, Account__r.Name, Student_ID__c from Contact_Medical_Schools__r WHERE type__c = :degreetitlevalue) from Contact where (firstname LIKE :Firstname AND lastname LIKE :Lastname and Birthdate = :dob and recordTypeId != :duplicateRecordTypeId and isDuplicate__c =: false)];

        System.debug(duplicateslist);
        return duplicateslist;
    }


    @AuraEnabled
    @future
    public static void selectDuplicates(String contactRecord){
        Integer hasUser = [Select Count() From User WHERE ContactId =: contactRecord];
        if (hasUser > 0){
            User u = [Select id, IsActive, ContactId, IsPortalEnabled FROM User WHERE ContactId =: contactRecord];
            u.IsActive = false;
            u.IsPortalEnabled = false;
            System.debug(u);
            update u;
        } else {
            System.debug('nothing');
        }

    }

}