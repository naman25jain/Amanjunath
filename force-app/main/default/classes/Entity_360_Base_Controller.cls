public with sharing class Entity_360_Base_Controller {

    @AuraEnabled
    public static Terms_and_Conditions__c getInitContactInfo(String privacyName) {
        String contactId = CommunityIdentityVerificationController.getRunningContactId();
        List<Terms_and_Conditions_Agreement__c> aL = [SELECT Id FROM Terms_and_Conditions_Agreement__c WHERE Contact__c = :contactId AND TermsandConditions__r.Name = :privacyName AND TermsandConditions__r.Status__c = 'Active'];
        if (aL.size() > 0) {
        System.debug('!!!!!!HERE');
        return null;
    } else {
    List<Terms_and_Conditions__c> cL = [SELECT Id, Copy__c, Short_Copy__c FROM Terms_and_Conditions__c WHERE Name = :privacyName AND Status__c = 'Active'];
    for(Terms_and_Conditions__c c : cL) {
        System.debug('!!!!!!');
        System.debug(c.Id);
    }
    if (cL.size() > 0)
    return cL[0];
    }
    return null;
    }

    @AuraEnabled
    public static Contact getContact() {
        String contactId = CommunityIdentityVerificationController.getRunningContactId();
        Contact currentContact = [Select Id, name, FirstName, LastName, Birthdate, Birth_Country__c, Email, Generational_Suffix__c, legal_name_consists_of_one_name_only__c, Phone, Department, Title, Gender__c, Entity_Contact_Initial_Fields_Complete__C, ECFMG_ID__c From Contact Where id = :contactId];
        return currentContact;
    }

    @AuraEnabled
    public static Contact getContactById(String contactId) {
        Contact currentContact = [Select Id, name, FirstName, LastName, Birthdate, Birth_Country__c, Email, Generational_Suffix__c, legal_name_consists_of_one_name_only__c, Phone, Department, Title, Gender__c, Entity_Contact_Initial_Fields_Complete__C From Contact Where id = :contactId];
        return currentContact;
    }

    @AuraEnabled
    public static List <String> getCountries() {
        List <String>birthCountryMetaData = new List <String>();
        for (CitizenBirthCountries__mdt bc : [Select id, label From CitizenBirthCountries__mdt]) {
            birthCountryMetaData.add(bc.label);
        }
        return birthCountryMetaData;
    }

    @AuraEnabled
    public static String updateContact(String contactId, String contactJSON) {
        JSONParser parser = JSON.createParser(contactJSON);
        Contact c = [Select id from Contact where id =: contactId];
        System.debug(contactJSON);
        while (parser.nextToken() != null) {
            String fieldName = parser.getText();
            if (fieldName.contains('{') || fieldName.contains('}')) {
                parser.nextToken();
                fieldName = parser.getText();
            }
            parser.nextToken();
            System.debug(fieldName);
            if (fieldName == 'Phone' || fieldName == 'Title' || fieldName == 'Department' || fieldName == 'Birth_Country__c' || fieldName == 'Gender__c' || fieldName == 'Generational_Suffix__c' || fieldName == 'Lastname' || fieldName == 'FirstName'){
                String fieldValue = parser.getText();
                System.debug(fieldValue);
                if(fieldValue != '') {
                    c.put(fieldName, fieldValue);
                }
            } else if (fieldName == 'Birthdate'){
               Date fieldValue = parser.getDateValue();
               c.put(fieldName, fieldValue);
            }
            else if (fieldName == 'legal_name_consists_of_one_name_only__c'){
                Boolean fieldValue = parser.getBooleanValue();
                c.put(fieldName, fieldValue);
                }
        }
        c.Entity_Contact_Initial_Fields_Complete__C = true;
        update c;
        return contactJSON;
    }

    /*@AuraEnabled
    public static String updateContactandCreateCase(String contactId, String contactJSON) {
        String currentUserId = CommunityIdentityVerificationController.getRunningContactId();
        Case c = new Case();
        /////// case should not be displayed externally
        /////add desctription with changes
        c.Subject = 'Mike Test';
        c.ContactId = currentUserId;
        insert c;
        return null;
    }*/

    @AuraEnabled
    public static Boolean addPrivacy(String privacyAgreement) {
        Boolean privacyCreated = CommunityIdentityVerificationController.addPrivacy(privacyAgreement);
        return privacyCreated;
    }

    @AuraEnabled
    public static String updateContactInformation(Contact c) {
        try {
            createNotificationCase(c);
            update c;
        } catch(Exception e) {
            System.debug('Error: ' + e.getMessage());
            return 'Error: ' + e.getMessage();
        }
        return 'Success';
    }

    @AuraEnabled
    public static String updateContactInformationWithEmail(Contact c) {
        String conError = '';
        String userError = '';
        Community_Settings__c settings = Community_Settings__c.getOrgDefaults();

        String dupeCheck = c.Email + settings.Username_Append__c;
        List<User> dupe = [Select Id FROM User WHERE isActive=true AND (UserName = :c.Email OR UserName = :dupeCheck)];
        if(dupe.size() > 0) {
            return 'Duplicate';
        }

        User u = new User(Id = UserInfo.getUserId(), Email = c.Email,   Username_Change_Needed__c = true);
        try {
            update u;
        } catch(Exception e) {
            System.debug('Error: ' + e.getMessage());
            userError =  e.getMessage();
        }

        if (userError == '') {
            try {
                createNotificationCase(c);
                update c;
            } catch(Exception e) {
                System.debug('Error: ' + e.getMessage());
                conError =  e.getMessage();
            }
        }

        if (ConError == '' && userError == '')
            return 'Success';
        else
            return 'Error:' + conError + userError;
    }

    public static Case createNotificationCase(Contact newContact) {
        String caseRecordTypeId = null;
        if(Schema.SObjectType.Case.getRecordTypeInfosByName().get('Notification') == null) {
            throw new CommunityException('Could not find Case Record Type named Notification.');
        }
        else {
            caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Notification').getRecordTypeId();
        }

        String caseQueueGroupId = null;
        List<Group> groups = [select Id from Group where Type = 'Queue' and Name = 'Notifications Queue'];
        if(groups.size() == 0) throw new CommunityException('Could not find Notifications Queue for Case.');
        caseQueueGroupId = groups[0].Id;

        Contact oldContact = getContact();
        String description = '';
        if (nullSafe(oldContact.LastName) != nullSafe(newContact.LastName)) {
            description += 'Last Name changed from ' + nullSafe(oldContact.LastName) + ' to ' + nullSafe(newContact.LastName) + '\n';
        }
        if (nullSafe(oldContact.FirstName) != nullSafe(newContact.FirstName)) {
            description += 'First Name changed from ' + nullSafe(oldContact.FirstName) + ' to ' + nullSafe(newContact.FirstName) + '\n';
        }
        if (oldContact.legal_name_consists_of_one_name_only__c != newContact.legal_name_consists_of_one_name_only__c) {
            description += 'Legal Name Consists of One Name Only changed from ' + oldContact.legal_name_consists_of_one_name_only__c + ' to ' + newContact.legal_name_consists_of_one_name_only__c + '\n';
        }
        if (oldContact.Generational_Suffix__c != newContact.Generational_Suffix__c) {
            description += 'Generational Suffix changed from ' + oldContact.Generational_Suffix__c + ' to ' + newContact.Generational_Suffix__c + '\n';
        }
        if (oldContact.Gender__c != newContact.Gender__c) {
            description += 'Gender changed from ' + oldContact.Gender__c + ' to ' + newContact.Gender__c + '\n';
        }
        if (oldContact.Birthdate != newContact.Birthdate) {
            description += 'Date of Birth changed from ' + oldContact.Birthdate + ' to ' + newContact.Birthdate + '\n';
        }
        if (oldContact.Birth_Country__c != newContact.Birth_Country__c) {
            description += 'Birth Country changed from ' + oldContact.Birth_Country__c + ' to ' + newContact.Birth_Country__c + '\n';
        }
        if (nullSafe(oldContact.Phone) != nullSafe(newContact.Phone)) {
            description += 'Phone Number changed from ' + nullSafe(oldContact.Phone) + ' to ' + nullSafe(newContact.Phone) + '\n';
        }
        if (nullSafe(oldContact.Department) != nullSafe(newContact.Department)) {
            description += 'Department changed from ' + nullSafe(oldContact.Department) + ' to ' + nullSafe(newContact.Department) + '\n';
        }
        if (nullSafe(oldContact.Title) != nullSafe(newContact.Title)) {
            description += 'Job Title changed from ' + nullSafe(oldContact.Title) + ' to ' + nullSafe(newContact.Title) + '\n';
        }
        if (oldContact.Email != newContact.Email) {
            description += 'Email changed from ' + oldContact.Email + ' to ' + newContact.Email + '\n';
        }

        Case cse = new Case();
        cse.ContactId = newContact.Id;
        cse.RecordTypeId = caseRecordTypeId;
        cse.Internal_Status__c = 'New';
        if (oldContact.Email != newContact.Email) {
        	cse.Type = 'Email Address Change';
        } else {
        	cse.Type = 'Entity Contact Change';
        }
        cse.OwnerId = caseQueueGroupId;
        cse.Subject = 'Entity Contact Information Change - ' + newContact.FirstName + ' ' + newContact.LastName;
        cse.Description = description.replace(' 00:00:00', '');
        insert cse;
        return cse;
    }

    @AuraEnabled
    public static Case createEntityInfoChangeCase(String entityId, String description) {
        String caseRecordTypeId = null;
        if(Schema.SObjectType.Case.getRecordTypeInfosByName().get('Entity Service Request') == null) {
            throw new CommunityException('Could not find Case Record Type named Entity Service Request.');
        } else {
            caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Entity Service Request').getRecordTypeId();
        }

        String caseQueueGroupId = null;
        List<Group> groups = [select Id from Group where Type = 'Queue' and Name = 'Entity Update Requests Queue'];
        if(groups.size() == 0) throw new CommunityException('Could not find Entity Update Requests Queue for Case.');
        caseQueueGroupId = groups[0].Id;

        Account a = [Select Name, ShippingCountry FROM Account WHERE Id = :entityId];
        String cseSubject = 'Entity Details Change for - ' + a.Name + ' ' + a.ShippingCountry;
        cseSubject = cseSubject.replace('null', '');
        Case cse = new Case();
        cse.ContactId = getContact().Id;
        cse.AccountId = entityId;
        cse.RecordTypeId = caseRecordTypeId;
        cse.Internal_Status__c = 'New';
        cse.Type = 'Entity Details Change';
        cse.OwnerId = caseQueueGroupId;
        cse.Subject = cseSubject;
        cse.Description = description;
        insert cse;
        return cse;
    }

    @AuraEnabled
    public static Account getAccount(String recordId) {
        return [SELECT Id, Name, Website, ShippingCity, ShippingCountry, ShippingCountryCode, ShippingPostalCode, ShippingState, ShippingStateCode, ShippingStreet, BillingCity, BillingCountry, BillingCountryCode, BillingPostalCode, BillingState, BillingStateCode, BillingStreet FROM Account WHERE Id = :recordId];
    }

    @AuraEnabled
    public static List<CaseFeed>  getChatterPosts(String recordId) {
        return [SELECT CreatedBy.FirstName, CreatedBy.LastName, CreatedBy.Email, Body, CreatedDate, Type, Visibility FROM CaseFeed WHERE ParentId = :recordId];
    }

    @AuraEnabled
    public static String postChatter(String parentId, String msg) {
        FeedItem fi = new FeedItem(
            Body = msg,
            IsRichText = true,
            ParentId = parentId,
            Status = 'Published',
            Type = 'TextPost',
            Visibility = 'AllUsers'
        );
        try {
            insert fi;
            Case c = [SELECT Id, CaseNumber, CreatedDate, OwnerId, Owner.FirstName, Owner.LastName, Owner.Email, ContactId, Contact.FirstName, Contact.LastName, Contact.Email  FROM Case WHERE Id = :parentId];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSaveAsActivity(false);
            mail.setSubject('Comment posted to Case Number# ' + c.CaseNumber);
            mail.setHTMLBody(c.Contact.FirstName + ' ' + c.Contact.LastName + ' posted on ' +  c.CreatedDate.format() + '\r\n' + msg );
            Profile p = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
            if(p.Name.contains('Community')) {
                if(((String)c.OwnerId).startsWith('005')) {
					mail.setTargetObjectId(c.OwnerId);
					Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
                }
            } else {
                mail.setTargetObjectId(c.ContactId);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
            }
        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
        return 'Success';
    }

    /*
        Returns a select option list of Gender for use with lightning:combobox.
        See: https://help.salesforce.com/articleView?id=000212327&type=1
     */
    @AuraEnabled
    public static List<SelectOption> getGenderPicklistEntries() {
        List<SelectOption> options = ComponentUtility.getGenderPicklistEntries();
        options.remove(0);
        return options;
    }


    /*
        Returns a select option list of Gender for use with lightning:combobox.
        See: https://help.salesforce.com/articleView?id=000212327&type=1
     */
    @AuraEnabled
    public static List<SelectOption> getGenerationalSuffixPicklistEntries() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', ''));
        options.addAll(ComponentUtility.getGenerationalSuffixPicklistEntries());
        return options;
        //return ComponentUtility.getGenerationalSuffixPicklistEntries();
    }


    private static String nullSafe(String input) {
        if(input == null) return '';
        return input;
    }


}