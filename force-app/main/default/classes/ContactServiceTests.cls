@isTest
private class ContactServiceTests {

    static testMethod void contactTests() {
        Map<String, Schema.SObjectType> mContact = Schema.getGlobalDescribe();
        Schema.SObjectType sContact = mContact.get('Contact') ;
        Schema.DescribeSObjectResult schemaContactDescribe = sContact.getDescribe();
        Map<String,Schema.RecordTypeInfo> contactRecordTypeInfo = schemaContactDescribe.getRecordTypeInfosByName();
        Id contactRecordId = contactRecordTypeInfo.get('Registered User').getRecordTypeId();
        List<Contact> cL = new List<Contact>();
        List<Id> idL = new List<Id>();
        Contact c = new Contact(LastName = 'Doe', FirstName = 'Jane', Email = 'test@ecfmg.org', RecordTypeId = contactRecordId, Birthdate = Date.Today()-900);
        cL.add(c);
        insert c;
        idL.add(c.Id);
        
        c = ContactService.getContact(c.Id);
        ContactService.createIndividuals(cL);
        cL = new List<Contact>();
        cL.add(c);
        ContactService.updateIndividuals(cL);
        ContactService.createUpdateHouseholdAccount(idL);
        ContactService.setDuplicateCheckFields(c);
        ContactService.deactivateUser(idL);
    }
}