public with sharing class ApplicantMyProfileController{
    Static final String RECORD_TYPE_EXCEPTION = 'Could not find record type named Marked for Deletion for Asset.';
    Static final String STATUS_IN_PROGRESS = Constants.ASSET_STATUS_IN_PROGRESS;
    @AuraEnabled
    public static Contact getContact(){
        return CommunityIdentityVerificationController.getContact();
    }
    @AuraEnabled
    public static void updateContact(Contact c){
        update c;
    }
    @AuraEnabled
    public static String updateContactInformation(String contactId, String country, String street, String city, String state, String zip, String phoneNumber, String phoneType){
        Boolean restricted = false;
        Contact oldC = getContact();
        Contact c = new Contact(Id = oldC.Id,
                MailingStreet = street,
                MailingCity = city,
                MailingStateCode = state,
                MailingPostalCode = zip,
                MailingCountryCode = country,
                Phone = phoneNumber,
                Phone_Type__c = phoneType
        );
        try{
            update c;
            Contact newC = [SELECT MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry FROM Contact WHERE Id = :c.Id];
            if(oldC.MailingCountry != newC.MailingCountry){
                restricted = checkRestrictedCountry(country);
            }
            if(restricted){
                Case cse = createNotificationCase();
                cse.description = '\n Old Address \n Street: ' + (oldC.MailingStreet == null ? '' : oldC.MailingStreet) + '\n City: ' + (oldC.MailingCity == null ? '' : oldC.MailingCity) + '\n State:' + (oldC.MailingState == null ? '' : oldC.MailingState) + '\n Country: ' + (oldC.MailingCountry == null ? '' : oldC.MailingCountry) + '\n Postal Code: ' + (oldC.MailingPostalCode == null ? '' : oldC.MailingPostalCode) + '\n';
                cse.description = cse.description + '\n New Address \n Street: ' + (newC.MailingStreet == null ? '' : newC.MailingStreet) + '\n City: ' + (newC.MailingCity == null ? '' : newC.MailingCity) + '\n State:' + (newC.MailingState == null ? '' : newC.MailingState) + '\n Country: ' + (newC.MailingCountry == null ? '' : newC.MailingCountry) + '\n Postal Code: ' + (newC.MailingPostalCode == null ? '' : newC.MailingPostalCode) + '\n';
                cse.Type = 'Applicant Address Change';
                insert cse;
            }
        }catch(Exception e){
            System.debug('Error: ' + e.getMessage());
            return 'Error: ' + e.getMessage();
        }
        return 'Success';
    }
    // Purpose To create payload for passport upload
    @AuraEnabled
    public static CloudStorageController.PayloadWrapper createPassportPayload(String contactId){
        String assetId = null;
        String accountId = null;
        String caseId = null;  
        List<Asset> assetList = [SELECT Id, Azure_Storage_URL__c FROM Asset WHERE ContactId =: contactId AND Name =: Constants.ASSET_NAME_PASSPORT AND Status =: STATUS_IN_PROGRESS WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
        if(!assetList.isEmpty()){
            assetId = assetList[0].id;
            CloudStorageController.PayloadWrapper payload = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_NAME_PASSPORT, 'Identity', '', caseId, accountId, '', STATUS_IN_PROGRESS, assetId, '', '', '', 'true', assetList[0].Azure_Storage_URL__c);
            return payload;
        }else{      
        CloudStorageController.PayloadWrapper payload = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_NAME_PASSPORT, 'Identity', 'Replace', caseId, accountId, 'true', STATUS_IN_PROGRESS, assetId);
        return payload;
        }
    }

    @AuraEnabled
    public static CloudStorageController.PayloadWrapper updatePassportPayload(String contactId, String azureDocUrl){
        List<Asset> assetList = [SELECT Id, Azure_Storage_URL__c FROM Asset WHERE ContactId =: contactId AND Name =: Constants.ASSET_NAME_PASSPORT AND Status =: STATUS_IN_PROGRESS WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
        String assetId = null;
        if(!assetList.isEmpty()){
            assetId = assetList[0].id;
        }
        String accountId = null;
        String caseId = null;
        CloudStorageController.PayloadWrapper payload = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_NAME_PASSPORT, 'Identity', 'Replace', caseId, accountId, 'true', STATUS_IN_PROGRESS, assetId, '', '', '', 'true', assetList[0].Azure_Storage_URL__c);
        return payload;
    }

    @AuraEnabled
    public static CloudStorageController.PayloadWrapper updatePassportTranslationPayload(String contactId){
        List<Asset> assetList = [SELECT Id, Azure_Storage_URL__c FROM Asset WHERE ContactId =: contactId AND Name =: Constants.ASSET_NAME_PASSPORT_TRANSLATION AND Status =: STATUS_IN_PROGRESS WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
        String assetId = null;
        if(!assetList.isEmpty()){
            assetId = assetList[0].id;
        }
        String accountId = null;
        String caseId = null;
        CloudStorageController.PayloadWrapper payload = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_NAME_PASSPORT_TRANSLATION, 'Identity', 'Replace', caseId, accountId, 'true', STATUS_IN_PROGRESS, assetId, '', '', '', 'true', assetList[0].Azure_Storage_URL__c);
        return payload;
    }

    @AuraEnabled
    public static CloudStorageController.PayloadWrapper updatePassportExnPayload(String contactId){
        List<Asset> assetList = [SELECT Id, Azure_Storage_URL__c FROM Asset WHERE ContactId =: contactId AND Name =: Constants.ASSET_NAME_PASSPORT_EXPIRATION AND Status =: STATUS_IN_PROGRESS WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
        String assetId = null;
        if(!assetList.isEmpty()){
            assetId = assetList[0].id;
        }
        String accountId = null;
        String caseId = null;
        CloudStorageController.PayloadWrapper payload = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_NAME_PASSPORT_EXPIRATION, 'Identity', 'Replace', caseId, accountId, 'true', STATUS_IN_PROGRESS, assetId, '', '', '', 'true', assetList[0].Azure_Storage_URL__c);
        return payload;
    }

    // Purpose To create payload for photo upload
    @AuraEnabled
    public static CloudStorageController.PayloadWrapper createPhotoPayload(String contactId){
        String assetId = null;
        String accountId = null;
        String caseId = null;
        List<Asset> assetList = [SELECT Id, Azure_Storage_URL__c FROM Asset WHERE ContactId =: contactId AND Name =: Constants.ASSET_NAME_PHOTO AND Status =: STATUS_IN_PROGRESS WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
        if(!assetList.isEmpty()){
            assetId = assetList[0].id;
            CloudStorageController.PayloadWrapper payload = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_NAME_PHOTO, 'Identity', '', caseId, accountId, '', STATUS_IN_PROGRESS, assetId, '', '', '', 'true', assetList[0].Azure_Storage_URL__c);
            return payload;
        }else{
        CloudStorageController.PayloadWrapper payload = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_NAME_PHOTO, 'Identity', 'Replace', caseId, accountId, 'true', STATUS_IN_PROGRESS, assetId);
        return payload;
        }
    }
    @AuraEnabled
    public static CloudStorageController.PayloadWrapper updatePhotoPayload(String contactId, String azureDocUrl){
        List<Asset> assetList = [SELECT Id, Azure_Storage_URL__c FROM Asset WHERE ContactId =: contactId AND Name =: Constants.ASSET_NAME_PHOTO AND Status =: STATUS_IN_PROGRESS WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
        String assetId = null;
        if(!assetList.isEmpty()){
            assetId = assetList[0].id;
            azureDocUrl = assetList[0].Azure_Storage_URL__c;
        }
        String accountId = null;
        String caseId = null;
        CloudStorageController.PayloadWrapper payload = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_NAME_PHOTO, 'Identity', 'Replace', caseId, accountId, 'true', STATUS_IN_PROGRESS, assetId, '', '', '', 'true', azureDocUrl);
        return payload;
    }
   
    // Purpose To create payload for birth certificate upload
    @AuraEnabled
    public static CloudStorageController.PayloadWrapper createBirthCertificatePayload(String contactId){
        String assetId = null;
        String accountId = null;
        String caseId = null;
        List<Asset> assetList = [SELECT Id, Azure_Storage_URL__c FROM Asset WHERE ContactId =: contactId AND Name =: Constants.ASSET_TYPE_BIRTH_CERTIFICATE AND Status =: STATUS_IN_PROGRESS WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
        if(!assetList.isEmpty()){
            assetId = assetList[0].id;
            CloudStorageController.PayloadWrapper payload = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_TYPE_BIRTH_CERTIFICATE, 'Identity', '', caseId, accountId, '', STATUS_IN_PROGRESS, assetId, '', '', '', 'true', assetList[0].Azure_Storage_URL__c);
            return payload;
        }else{
        CloudStorageController.PayloadWrapper payload = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_TYPE_BIRTH_CERTIFICATE, 'Identity', 'Replace', caseId, accountId, 'true', STATUS_IN_PROGRESS, assetId, '', '', '', 'true', '');
        return payload;
        }
    }
    // Purpose To update payload for birth certificate upload
    @AuraEnabled
    public static CloudStorageController.PayloadWrapper updateBirthCertificatePayload(String contactId, String azureDocUrl){
        List<Asset> assetList = [SELECT Id, Azure_Storage_URL__c FROM Asset WHERE ContactId =: contactId AND Name =: Constants.ASSET_TYPE_BIRTH_CERTIFICATE AND Status =: STATUS_IN_PROGRESS WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
        String assetId = null;
        if(!assetList.isEmpty()){
            assetId = assetList[0].id;
            azureDocUrl = assetList[0].Azure_Storage_URL__c;
        }
        String accountId = null;
        String caseId = null;
        CloudStorageController.PayloadWrapper payload = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_TYPE_BIRTH_CERTIFICATE, 'Identity', 'Replace', caseId, accountId, 'true', STATUS_IN_PROGRESS, assetId, '', '', '', 'true', azureDocUrl);
        return payload;
    }
    // Purpose To create payload for marriage certificate upload
    @AuraEnabled
    public static CloudStorageController.PayloadWrapper createMarriageCertificatePayload(String contactId){
        String assetId = null;
        String accountId = null;
        String caseId = null;
        List<Asset> assetList = [SELECT Id, Azure_Storage_URL__c FROM Asset WHERE ContactId =: contactId AND Name =: Constants.ASSET_TYPE_MARRIAGE_CERTIFICATE AND Status =: STATUS_IN_PROGRESS WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
        if(!assetList.isEmpty()){
            assetId = assetList[0].id;
            CloudStorageController.PayloadWrapper payload = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_TYPE_MARRIAGE_CERTIFICATE, 'Identity', '', caseId, accountId, '', STATUS_IN_PROGRESS, assetId, '', '', '', 'true', assetList[0].Azure_Storage_URL__c);
            return payload;
        }else{
        CloudStorageController.PayloadWrapper payload = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_TYPE_MARRIAGE_CERTIFICATE, 'Identity', 'Replace', caseId, accountId, 'true', STATUS_IN_PROGRESS, assetId, '', '', '', 'true', '');
        return payload;
        }
    }
    // Purpose To update payload for marriage certificate upload
    @AuraEnabled
    public static CloudStorageController.PayloadWrapper updateMarriageCertificatePayload(String contactId, String azureDocUrl){
        List<Asset> assetList = [SELECT Id, Azure_Storage_URL__c FROM Asset WHERE ContactId =: contactId AND Name =: Constants.ASSET_TYPE_MARRIAGE_CERTIFICATE AND Status =: STATUS_IN_PROGRESS WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
        String assetId = null;
        if(!assetList.isEmpty()){
            assetId = assetList[0].Id;
        }
        String accountId = null;
        String caseId = null;
        CloudStorageController.PayloadWrapper payload = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_TYPE_MARRIAGE_CERTIFICATE, 'Identity', 'Replace', caseId, accountId, 'true', STATUS_IN_PROGRESS, assetId, '', '', '', 'true', azureDocUrl);
        return payload;
    }
    // Purpose To create payload for Official Court Order upload
    @AuraEnabled
    public static CloudStorageController.PayloadWrapper createOfficialCourtOrderPayload(String contactId){
        String assetId = null;
        String accountId = null;
        String caseId = null;
        List<Asset> assetList = [SELECT Id, Azure_Storage_URL__c FROM Asset WHERE ContactId =: contactId AND Name =: Constants.ASSET_TYPE_OFFICIAL_COURT_ORDER AND Status =: STATUS_IN_PROGRESS WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
        if(!assetList.isEmpty()){
            assetId = assetList[0].id;
            CloudStorageController.PayloadWrapper payload = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_TYPE_OFFICIAL_COURT_ORDER, 'Identity', '', caseId, accountId, '', STATUS_IN_PROGRESS, assetId, '', '', '', 'true', assetList[0].Azure_Storage_URL__c);
            return payload;
        }else{
        CloudStorageController.PayloadWrapper payload = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_TYPE_OFFICIAL_COURT_ORDER, 'Identity', 'Replace', caseId, accountId, 'true', STATUS_IN_PROGRESS, assetId, '', '', '', 'true', '');
        return payload;
        }
    }
    // Purpose To update payload for Official Court Order upload
    @AuraEnabled
    public static CloudStorageController.PayloadWrapper updateOfficialCourtOrderPayload(String contactId, String azureDocUrl){
        List<Asset> assetList = [SELECT Id, Azure_Storage_URL__c FROM Asset WHERE ContactId =: contactId AND Name =: Constants.ASSET_TYPE_OFFICIAL_COURT_ORDER AND Status =: STATUS_IN_PROGRESS WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
        String assetId = null;
        if(!assetList.isEmpty()){
            assetId = assetList[0].Id;
        }
        String accountId = null;
        String caseId = null;
        CloudStorageController.PayloadWrapper payload = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_TYPE_OFFICIAL_COURT_ORDER, 'Identity', 'Replace', caseId, accountId, 'true', STATUS_IN_PROGRESS, assetId, '', '', '', 'true', azureDocUrl);
        return payload;
    }
    // Purpose To create payload for U.S. Resident Alien Card upload
    @AuraEnabled
    public static CloudStorageController.PayloadWrapper createUsResidentAlienCardPayload(String contactId){
        String assetId = null;
        String accountId = null;
        String caseId = null;
        List<Asset> assetList = [SELECT Id, Azure_Storage_URL__c FROM Asset WHERE ContactId =: contactId AND Name =: Constants.ASSET_TYPE_US_RESIDENT_ALIEN_CARD AND Status =: STATUS_IN_PROGRESS WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
        if(!assetList.isEmpty()){
            assetId = assetList[0].id;
            CloudStorageController.PayloadWrapper payload = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_TYPE_US_RESIDENT_ALIEN_CARD, 'Identity', '', caseId, accountId, '', STATUS_IN_PROGRESS, assetId, '', '', '', 'true', assetList[0].Azure_Storage_URL__c);
            return payload;
        }else{
        CloudStorageController.PayloadWrapper payload = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_TYPE_US_RESIDENT_ALIEN_CARD, 'Identity', 'Replace', caseId, accountId, 'true', STATUS_IN_PROGRESS, assetId, '', '', '', 'true', '');
        return payload;
        }
    }
    // Purpose To update payload for  U.S. Resident Alien Card upload
    @AuraEnabled
    public static CloudStorageController.PayloadWrapper updateUsResidentAlienCardPayload(String contactId, String azureDocUrl){
        List<Asset> assetList = [SELECT Id FROM Asset WHERE ContactId =: contactId AND Name =: Constants.ASSET_TYPE_US_RESIDENT_ALIEN_CARD AND Status =: STATUS_IN_PROGRESS WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
        String assetId = null;
        if(!assetList.isEmpty()){
            assetId = assetList[0].Id;
        }
        String accountId = null;
        String caseId = null;
        CloudStorageController.PayloadWrapper payload = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_TYPE_US_RESIDENT_ALIEN_CARD, 'Identity', 'Replace', caseId, accountId, 'true', STATUS_IN_PROGRESS, assetId, '', '', '', 'true', azureDocUrl);
        return payload;
    }
    // Purpose To create payload for U.S. Naturalization Certificate upload
    @AuraEnabled
    public static CloudStorageController.PayloadWrapper createUsNaturalizationCertificatePayload(String contactId){
        String assetId = null;
        String accountId = null;
        String caseId = null;
        List<Asset> assetList = [SELECT Id, Azure_Storage_URL__c FROM Asset WHERE ContactId =: contactId AND Name =: Constants.ASSET_TYPE_US_NATURALIZATION_CERTIFICATE AND Status =: STATUS_IN_PROGRESS WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
        if(!assetList.isEmpty()){
            assetId = assetList[0].id;
            CloudStorageController.PayloadWrapper payload = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_TYPE_US_NATURALIZATION_CERTIFICATE, 'Identity', '', caseId, accountId, '', STATUS_IN_PROGRESS, assetId, '', '', '', 'true', assetList[0].Azure_Storage_URL__c);
            return payload;
        }else{
        CloudStorageController.PayloadWrapper payload = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_TYPE_US_NATURALIZATION_CERTIFICATE, 'Identity', 'Replace', caseId, accountId, 'true', STATUS_IN_PROGRESS, assetId, '', '', '', 'true', '');
        return payload;
        }
    }
    // Purpose To update payload for U.S. Naturalization Certificate upload
    @AuraEnabled
    public static CloudStorageController.PayloadWrapper updateUsNaturalizationCertificatePayload(String contactId, String azureDocUrl){
        List<Asset> assetList = [SELECT Id FROM Asset WHERE ContactId =: contactId AND Name =: Constants.ASSET_TYPE_US_NATURALIZATION_CERTIFICATE AND Status =: STATUS_IN_PROGRESS WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
        String assetId = null;
        if(!assetList.isEmpty()){
            assetId = assetList[0].Id;
        }
        String accountId = null;
        String caseId = null;
        CloudStorageController.PayloadWrapper payload = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_TYPE_US_NATURALIZATION_CERTIFICATE, 'Identity', 'Replace', caseId, accountId, 'true', STATUS_IN_PROGRESS, assetId, '', '', '', 'true', azureDocUrl);
        return payload;
    }
    // Purpose To create payload for U.S. Passport Card upload
    @AuraEnabled
    public static CloudStorageController.PayloadWrapper createUsPassportCardPayload(String contactId){
        String assetId = null;
        String accountId = null;
        String caseId = null;
        List<Asset> assetList = [SELECT Id, Azure_Storage_URL__c FROM Asset WHERE ContactId =: contactId AND Name =: Constants.ASSET_TYPE_US_PASSPORT_CARD AND Status =: STATUS_IN_PROGRESS WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
        if(!assetList.isEmpty()){
            assetId = assetList[0].id;
            CloudStorageController.PayloadWrapper payload = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_TYPE_US_PASSPORT_CARD, 'Identity', '', caseId, accountId, '', STATUS_IN_PROGRESS, assetId, '', '', '', 'true', assetList[0].Azure_Storage_URL__c);
            return payload;
        }else{
        CloudStorageController.PayloadWrapper payload = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_TYPE_US_PASSPORT_CARD, 'Identity', 'Replace', caseId, accountId, 'true', STATUS_IN_PROGRESS, assetId, '', '', '', 'true', '');
        return payload;
        }
    }
    // Purpose To update payload for U.S. Passport Card upload
    @AuraEnabled
    public static CloudStorageController.PayloadWrapper updateUsPassportCardPayload(String contactId, String azureDocUrl){
        List<Asset> assetList = [SELECT Id FROM Asset WHERE ContactId =: contactId AND Name =: Constants.ASSET_TYPE_US_PASSPORT_CARD AND Status =: STATUS_IN_PROGRESS WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
        String assetId = null;
        if(!assetList.isEmpty()){
            assetId = assetList[0].Id;
        }
        String accountId = null;
        String caseId = null;
        CloudStorageController.PayloadWrapper payload = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_TYPE_US_PASSPORT_CARD, 'Identity', 'Replace', caseId, accountId, 'true', STATUS_IN_PROGRESS, assetId, '', '', '', 'true', azureDocUrl);
        return payload;
    }
    @AuraEnabled
    public static String updateContactInformationWithEmail(String contactId, String country, String street, String city, String state, String zip, String email, String phoneNumber, String phoneType){
        String conError = '';
        String userError = '';
        Community_Settings__c settings = Community_Settings__c.getOrgDefaults();
        Boolean restricted = false;
        Contact oldC = getContact();
        String dupeCheck = email + settings.Username_Append__c;
        List<User> dupe = [Select Id FROM User WHERE isActive = true AND (UserName = :email OR UserName = :dupeCheck)];
        if(dupe.size() > 0){
            return 'Duplicate';
        }
        User u = new User(Id = UserInfo.getUserId(),
                Email = email,
                Username_Change_Needed__c = true
        );
        try{
            update u;
        }
        catch(Exception e){
            System.debug('Error: ' + e.getMessage());
            userError = e.getMessage();
        }
        if(userError == ''){
            Contact c = new Contact(Id = oldC.Id,
                    MailingStreet = street,
                    MailingCity = city,
                    MailingStateCode = state,
                    MailingPostalCode = zip,
                    MailingCountryCode = country,
                    Email = email,
                    Phone = phoneNumber,
                    Phone_Type__c = phoneType
            );
            try{
                update c;
                Contact newC = [SELECT MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry FROM Contact WHERE Id = :c.Id];
                if(oldC.MailingCountry != newC.MailingCountry){
                    restricted = checkRestrictedCountry(country);
                }
                if(restricted){
                    Case cse = createNotificationCase();
                    cse.description = '\n Old Address \n Street: ' + (oldC.MailingStreet == null ? '' : oldC.MailingStreet) + '\n City: ' + (oldC.MailingCity == null ? '' : oldC.MailingCity) + '\n State:' + (oldC.MailingState == null ? '' : oldC.MailingState) + '\n Country: ' + (oldC.MailingCountry == null ? '' : oldC.MailingCountry) + '\n Postal Code: ' + (oldC.MailingPostalCode == null ? '' : oldC.MailingPostalCode) + '\n';
                    cse.description = cse.description + '\n New Address \n Street: ' + (newC.MailingStreet == null ? '' : newC.MailingStreet) + '\n City: ' + (newC.MailingCity == null ? '' : newC.MailingCity) + '\n State:' + (newC.MailingState == null ? '' : newC.MailingState) + '\n Country: ' + (newC.MailingCountry == null ? '' : newC.MailingCountry) + '\n Postal Code: ' + (newC.MailingPostalCode == null ? '' : newC.MailingPostalCode) + '\n';
                    insert cse;
                }
            }
            catch(Exception e){
                System.debug('Error: ' + e.getMessage());
                conError = e.getMessage();
            }
        }
        if(ConError == '' && userError == '')
            return 'Success'; else
                return 'Error:' + conError + userError;
    }
    @AuraEnabled
    public static Case updateContactBiographics(Boolean oneNameOnly, String genSuffix, Date dob, Date ppIssued, Date ppExpires, String ppNumber, String inputMapString){
        Map<String, String> inputMap = (Map<String, String>) JSON.deserialize(inputMapString, Map<String, String>.class);
        String pendingSubCaseId = '';
        Contact_Staging__c csRec = new Contact_Staging__c();
        Contact c = getContact();
        String caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Applicant Biographic Change').getRecordTypeId();
        List<Case> pendingSubCase = new List<Case>();
        try{
            pendingSubCase = [SELECT Id FROM Case WHERE ContactId =: c.Id AND Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION AND RecordTypeId =: caseRecordTypeId];
        }catch(Exception e){
            pendingSubCase = new List<Case>();
        }
        if(!pendingSubCase.isEmpty()){
            String caseId = pendingSubCase[0].Id;
            List<Contact_Staging__c> catsList = new List<Contact_Staging__c>();
            catsList = [SELECT Case__c, Contact__c, Date_of_Birth__c, First_Name__c, Gender__c, Generational_Suffix__c, Id,Last_Name__c,
            Legal_Name_Consists_of_One_Name_Only__c, Name, National_Identification__c, National_ID_Country__c, Native_Language__c,
            Other_Languages_Spoken__c, Other_Native_Language__c, Passport_Country__c, Passport_Expiration__c, Passport_Issue_Date__c,
            Passport_Number__c, Previous_License__c, Reason_for_Change__c, RecordTypeId, T_C_Agreement__c, US_Social_Security__c
            FROM Contact_Staging__c WHERE Case__c =: caseId ORDER BY CreatedDate DESC];
            if(!catsList.isEmpty()){
                csRec = catsList[0];
                csRec.Contact__c = c.Id;
                csRec.Date_of_Birth__c = dob;
                csRec.First_Name__c = inputMap.get('fName');
                csRec.Gender__c = inputMap.get('genderVal');
                if(oneNameOnly == true || oneNameOnly == false){
                csRec.Legal_Name_Consists_of_One_Name_Only__c = oneNameOnly;
                }
                csRec.Generational_Suffix__c = genSuffix;
                csRec.Last_Name__c = inputMap.get('lName');
                csRec.Passport_Country__c = inputMap.get('ppCountry');
                csRec.Passport_Expiration__c = ppExpires;
                csRec.Passport_Issue_Date__c = ppIssued;
                csRec.Passport_Number__c = ppNumber;
                csRec.Reason_for_Change__c = inputMap.get('reason');
                csRec.T_C_Agreement__c = inputMap.get('confirm');
                update csRec;
                pendingSubCaseId = processContactStaging(csRec.Id);
            }else{
                Contact_Staging__c cs = new Contact_Staging__c(
                    Contact__c = c.Id,
                    Date_of_Birth__c = dob,
                    First_Name__c = inputMap.get('fName'),
                    Gender__c = inputMap.get('genderVal'),
                    Legal_Name_Consists_of_One_Name_Only__c = oneNameOnly,
                    Generational_Suffix__c = genSuffix,
                    Last_Name__c = inputMap.get('lName'),
                    Passport_Country__c = inputMap.get('ppCountry'),
                    Passport_Expiration__c = ppExpires,
                    Passport_Issue_Date__c = ppIssued,
                    Passport_Number__c = ppNumber,
                    Reason_for_Change__c = inputMap.get('reason'),
                    T_C_Agreement__c = inputMap.get('confirm')
                );
                insert cs;
                csRec = cs;
                pendingSubCaseId = processContactStaging(cs.Id);
            }
        }
        Case caseResult = [Select Id, CaseNumber, Description FROM Case WHERE Id = :pendingSubCaseId];
        String caseDesc = '';
        if(csRec.Date_of_Birth__c != c.Birthdate){
            caseDesc += 'Date of Birth changed from ' + c.Birthdate.format() + ' to ' + csRec.Date_of_Birth__c.format() + '\n';
        }
        if(csRec.First_Name__c != c.FirstName){
            caseDesc += 'First Name changed from ' + c.FirstName + ' to ' + csRec.First_Name__c + '\n';
        }
        if(csRec.Legal_Name_Consists_of_One_Name_Only__c != c.legal_name_consists_of_one_name_only__c){
            caseDesc += 'Legal Name Consists of One Name Only changed from ' + c.legal_name_consists_of_one_name_only__c + ' to ' + csRec.Legal_Name_Consists_of_One_Name_Only__c + '\n';
        }
        if(csRec.Last_Name__c != c.LastName){
            caseDesc += 'Last Name changed from ' + c.LastName + ' to ' + csRec.Last_Name__c + '\n';
        }
        if(csRec.Gender__c != c.Gender__c){
            caseDesc += 'Gender changed from ' + c.Gender__c + ' to ' + csRec.Gender__c + '\n';
        }
        if(csRec.Generational_Suffix__c != c.Generational_Suffix__c){
            // prepare new value if blank
            String generationalSuffixNewValue = csRec.Generational_Suffix__c == '' || csRec.Generational_Suffix__c == null ? 'Not Selected' : csRec.Generational_Suffix__c;
            caseDesc += 'Generational Suffix changed from ' + c.Generational_Suffix__c + ' to ' + generationalSuffixNewValue + '\n';
        }
        //caseDesc = caseDesc.replace(' 00:00:00', '');
        caseResult.Description = 'The following information was captured as the initial applicant input:\n\n' + caseDesc;
        update caseResult;
        return caseResult;
    }
    /*Returns a map of select options ready to use with listboxes.
        Use these keys to get the options you want:
         - passport
         - birth
         - currentCitizenship
         - citizenshipAtBirth
         - citizenshipUponEnteringSchool */
    @AuraEnabled
    public static Map<String, List<SelectOption>> getCountriesMap(){
        // holds our return result
        Map<String, List<SelectOption>> result = new Map<String, List<SelectOption>>();
        // hold the current options
        List<SelectOption> options = new List<SelectOption>();
        // get passport countries
        Schema.DescribeFieldResult fieldResult = Contact.Passport_Country__c.getDescribe();
        Schema.sObjectField field = fieldResult.getSObjectField();
        List<PicklistEntry> entries = field.getDescribe().getPicklistValues();
        for(PicklistEntry pe : entries){
            if(pe.getLabel() != 'Select...'){
                options.add(new SelectOption(pe.getValue(), pe.getLabel()));
            }
        }
        // add to result map
        result.put('passport', options);
        // get birth countries
        fieldResult = Contact.Birth_Country__c.getDescribe();
        field = fieldResult.getSObjectField();
        entries = field.getDescribe().getPicklistValues();
        // create a new options instance
        options = new List<SelectOption>();
        for(PicklistEntry pe : entries){
            if(pe.getLabel() != 'Select...'){
                options.add(new SelectOption(pe.getValue(), pe.getLabel()));
            }
        }
        // add to result map
        result.put('birth', options);
        // get current citizenship countries
        fieldResult = Contact.Current_Citizenship__c.getDescribe();
        field = fieldResult.getSObjectField();
        entries = field.getDescribe().getPicklistValues();
        // create a new options instance
        options = new List<SelectOption>();
        for(PicklistEntry pe : entries){
            if(pe.getLabel() != 'Select...'){
                options.add(new SelectOption(pe.getValue(), pe.getLabel()));
            }
        }
        // add to result map
        result.put('currentCitizenship', options);
        // get citizenship at birth countries
        fieldResult = Contact.Citizenship_at_Birth__c.getDescribe();
        field = fieldResult.getSObjectField();
        entries = field.getDescribe().getPicklistValues();
        // create a new options instance
        options = new List<SelectOption>();
        for(PicklistEntry pe : entries){
            if(pe.getLabel() != 'Select...'){
                options.add(new SelectOption(pe.getValue(), pe.getLabel()));
            }
        }
        // add to result map
        result.put('citizenshipAtBirth', options);
        // get citizenship upon entering medical school countries
        fieldResult = Contact.Citizenship_Upon_Entering_Medical_School__c.getDescribe();
        field = fieldResult.getSObjectField();
        entries = field.getDescribe().getPicklistValues();
        // create a new options instance
        options = new List<SelectOption>();
        for(PicklistEntry pe : entries){
            if(pe.getLabel() != 'Select...'){
                options.add(new SelectOption(pe.getValue(), pe.getLabel()));
            }
        }
        // add to result map
        result.put('citizenshipUponEnteringSchool', options);
        // return result
        return result;
    }
    @AuraEnabled
    public static List<Case> getContactDetailsUpdateCases(Boolean isClosed){
        List<Case> cL = [SELECT Id, CaseNumber, Internal_Status__c FROM Case WHERE isClosed = :isClosed AND RecordType.Name = 'Applicant Biographic Change' AND ContactId = :getRunningContactId()];
        return cL;
    }
    /* This method takes the contactStagingId and creates a case and all of its related records, such as:
         - Assets
         - Affirmations
         - ContentDocumentLink
        Returns the ID of the newly created case.*/
    @AuraEnabled
    public static String processContactStaging(String contactStagingId){
        String caseId = null;
        if(contactStagingId == null || contactStagingId == ''){
            throw new CommunityException('Contact Staging Id cannot be null or empty');
        }
        List<Contact_Staging__c> css = [select Id, Contact__c, Case__c, Reason_for_Change__c from Contact_Staging__c where Id = :contactStagingId];
        if(css.size() == 0){
            throw new CommunityException('Cannot find Contact Staging record with Id ' + contactStagingId);
        }
        Contact_Staging__c cs = css[0];
        String caseRecordTypeId = null;
        if(Schema.SObjectType.Case.getRecordTypeInfosByName().get('Applicant Biographic Change') == null){
            throw new CommunityException('Could not find Case Record Type named Applicant Biographic Change.');
        }else{
            caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Applicant Biographic Change').getRecordTypeId();
        }
        String caseQueueGroupId = null;
        List<Group> groups = [select Id from Group where Type = 'Queue' and Name = 'Biographic Change Queue'];
        if(groups.size() == 0){
            throw new CommunityException('Could not find Biographic Change Queue for Case.');
        }
        caseQueueGroupId = groups[0].Id;
        Case c = new Case();
        c = [SELECT Id FROM Case WHERE ContactId =: cs.Contact__c AND Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION AND RecordTypeId =: caseRecordTypeId WITH SECURITY_ENFORCED LIMIT 1];
        c.ContactId = cs.Contact__c;
        c.RecordTypeId = caseRecordTypeId;
        c.OwnerId = caseQueueGroupId;
        c.Contact_Staging__c = contactStagingId;
        c.Reason_for_Change__c = cs.Reason_for_Change__c;
        // insert the case and get the id.
        update c;
        caseId = c.Id;
        // update the contact staging with the case id
        cs.Case__c = caseId;
        update cs;
        // get product code map <ProductCode, Id>
        List<Product2> products = [select Id, ProductCode from Product2];
        Map<String, String> productCodeIdMap = new Map<String, String>();
        for(Product2 product : products) productCodeIdMap.put(product.ProductCode, product.Id);
        List<String> assetNames = new List<String>();
        assetNames.add('Birth Certificate');
        assetNames.add('Marriage Certificate');
        assetNames.add('Official Court Order');
        assetNames.add('U.S. Resident Alien Card');
        assetNames.add('U.S. Naturalization Certificate');
        assetNames.add('U.S. Passport Card');
        assetNames.add('Passport Translation Page');
        assetNames.add('Passport Expiration Page');
        assetNames.add('Passport');
        assetNames.add('Photo');
        Id passportAssetId;
        Id photoAssetId;
        // update assets
        List<Asset> assets = [SELECT id,Type__c,Name FROM Asset where ContactId = :c.ContactId AND status = :Constants.ASSET_STATUS_IN_PROGRESS AND Name IN:assetNames];
        for(Asset ast : assets){
            ast.Product2Id = productCodeIdMap.get(ast.type__c);
            ast.Case__c = c.Id;
            if(ast.name == 'Passport'){
                passportAssetId = ast.Id;
            }
            if(ast.name == 'Photo'){
                photoAssetId = ast.Id;
            }
        }
        update assets;
        // get affirmation passport record type id
        String affirmationRecordTypeId = null;
        if(Schema.SObjectType.Affirmation__c.getRecordTypeInfosByName().get('Passport') == null){
            throw new CommunityException('Could not find Affirmation Record Type named Passport.');
        }else{
            affirmationRecordTypeId = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByName().get('Passport').getRecordTypeId();
        }
        // create the passport affirmation
        insert new Affirmation__c(
                RecordTypeId = affirmationRecordTypeId,
                Status__c = Constants.ASSET_STATUS_IN_PROGRESS,
                Asset__c = passportAssetId
        );
        if(Schema.SObjectType.Affirmation__c.getRecordTypeInfosByName().get('Photo') == null){
            throw new CommunityException('Could not find Affirmation Record Type named Photo.');
        }else{
            affirmationRecordTypeId = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByName().get('Photo').getRecordTypeId();
        }
        // create the photo affirmation
        insert new Affirmation__c(
                RecordTypeId = affirmationRecordTypeId,
                Status__c = Constants.ASSET_STATUS_IN_PROGRESS,
                Asset__c = photoAssetId
        );
        return caseId;
    }
    public static Boolean checkRestrictedCountry(String country){
        List<Country_Configuration__mdt> cLa = [SELECT Name__c, Restricted__c FROM Country_Configuration__mdt WHERE Restricted__c = true AND Name__c = :country];
        List<Country_Configuration__mdt> cLb = [SELECT Name__c, Restricted__c FROM Country_Configuration__mdt WHERE Restricted__c = true AND ISO_2_Character__c = :country];
        if((cLa.size() + cLb.size()) > 0)
            return true; else
                return false;
    }
    public static Case createNotificationCase(){
        String caseRecordTypeId = null;
        if(Schema.SObjectType.Case.getRecordTypeInfosByName().get('Applicant Biographic Change') == null){
            throw new CommunityException('Could not find Case Record Type named Applicant Biographic Change.');
        }else{
            caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Notification').getRecordTypeId();
        }
        String caseQueueGroupId = null;
        List<Group> groups = [select Id from Group where Type = 'Queue' and Name = 'Notifications Queue'];
        if(groups.size() == 0){
             throw new CommunityException('Could not find Biographic Change Queue for Case.');
        }
        caseQueueGroupId = groups[0].Id;
        Contact c = [Select Id, FirstName, LastName, MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode FROM Contact WHERE Id = :getRunningContactId()];
        String description = 'Old Address \n Street: ' + c.MailingStreet + '\n City: ' + c.MailingCity + '\n State:' + c.MailingState + '\n Country: ' + c.MailingCountry + '\n Postal Code: ' + c.MailingPostalCode + '\n';
        Case cse = new Case();
        cse.ContactId = c.Id;
        cse.RecordTypeId = caseRecordTypeId;
        cse.Internal_Status__c = 'New';
        cse.Type = 'Applicant Address Change';
        cse.OwnerId = caseQueueGroupId;
        cse.Subject = ('Applicant Address Change - ' + c.FirstName + ' ' + c.LastName).replace('null', '').trim();
        cse.Description = description;
        return cse;
    }
    @AuraEnabled
    public static String getRunningContactId(){
        String userId = (String) UserInfo.getUserId();
        User usr = [select ContactId from User where Id = :userId limit 1];
        String contactId = usr.ContactId;
        if(contactId == null || contactId == ''){
            Community_Settings__c settings = Community_Settings__c.getOrgDefaults();
            contactId = settings.Builder_Test_Contact__c;
            if(contactId != null){
                // ensure the setting provided is a valid contact id and/or is valid for this org.
                List<Contact> contacts = [select Id from Contact where Id = :contactId];
                if(contacts.size() == 0) contactId = null;
            }
            if(contactId == null){
                throw new CommunityException('Unable to find Community User/Contact. If using a test contact, make sure it is valid for this org.');
            }
        }
        return contactId;
    }
    @AuraEnabled
    public static List <String> getCountries(){
        return CommunityIdentityVerificationController.getCountries();
    }
    @AuraEnabled
    public static Terms_and_Conditions__c getTerms(String name){
        List<Terms_and_Conditions__c> cL = [SELECT Id, Copy__c, Status__c FROM Terms_and_Conditions__c WHERE Name = :name];
        if(cL.size() > 0)
            return cL[0]; else
                return null;
    }
    @AuraEnabled
    public static List<Asset> getAssets(){
        List<Asset> aL = [SELECT Id, Name, RecordType.Name, Type__c, Status, Case__c FROM Asset WHERE ContactId = :getRunningContactId() AND Status = 'Verified' AND Name != 'ID Form Template'];
        return aL;
    }
    @AuraEnabled
    public static List<Asset> getAllAssets(){
        List<Asset> aL = [SELECT Id, Name, RecordType.Name, Type__c, Status, Case__c, Product2.Family FROM Asset WHERE ContactId = :getRunningContactId() AND status != :constants.ASSET_STATUS_MARKED_FOR_DELETION];
        return aL;
    }
    @AuraEnabled
    public static List<ContentDocumentLink> getAssetFiles(List<String> assetIds){
        Set<Id> parentIds = new Set<Id>();
        for(String s : assetIds){
            parentIds.add(s);
        }
        return [SELECT ContentDocument.Title,ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :parentIds ORDER BY LinkedEntityId ASC];
    }
    @AuraEnabled
    public static Case getCaseDetails(String caseId){
        Case c = [
                SELECT CaseNumber, ContactId, isClosed, ParentId, Parent.CaseNumber, Case_Status__c, Internal_Status__c, Owner.FirstName, Owner.LastName, RecordType.Name, CreatedDate, Action_Required_Icon__c, External_Status__c,
                        LastModifiedDate, Subject, Description, Reason_for_Change__c, Close_Reason__c, External_Close_Comments__c,Deficiency_Reason_RTF__c, RecordType.DeveloperName,
                        Related_Transcript_Case__c, Related_Transcript_Case__r.CaseNumber,Type,Reason_for_Duplicate_Certificate__c,Secondary_Parent_Case__c,
                        Account.Name,Account.Website,Account.BillingCountry,Account.BillingStreet,Account.BillingCity,Account.BillingState,Account.BillingPostalCode,Entity__c,Entity__r.External_Instructions__c,Tracking_Number__c,
                        Token_Request_date__c,Token__c,Date_Token_Issued__c
                FROM Case
                WHERE ID = :caseId  WITH SECURITY_ENFORCED
        ];
        return c;
    }
    @AuraEnabled
    public static List<Case> getSubCases(String appForCertCaseID){
        List<Case> subcvCases = [Select Id, CaseNumber, Document_Type__c, External_Status__c  From Case where ParentId =: appForCertCaseID WITH SECURITY_ENFORCED];
        return subcvCases;
    }
    // MP: byWho will either be Agent or Analyst
    @AuraEnabled
    public static String cancelCase(String caseId, String reason, String reasonNotes, String byWho){
        try{
            String caseStatus = 'Cancelled by Applicant';
            if(byWho == 'Agent') caseStatus = 'Cancelled by ECFMG';
            Case c = [SELECT Internal_Status__c, isClosed, Close_Reason__c, External_Close_Comments__c FROM Case WHERE ID = :caseId];
            if(c.isClosed){
                return 'Error: Closed';
            }else{
                c.Internal_Status__c = caseStatus;
                c.Close_Reason__c = reason;
                c.External_Close_Comments__c = reasonNotes;
                List<Group> groups = [select Id from Group where Type = 'Queue' and Name = 'Cancelled Queue'];
                if(groups.size() == 0){
                    throw new CommunityException('Could not find Cancelled Queue for Case.');
                }
                c.OwnerId = groups[0].Id;
                update c;
                // update all In Progress Assets for this Case with Identity Record Type to "Canceled" Status
                List<RecordType> rts = [select Id from RecordType where Name = 'Identity' and SobjectType = 'Asset'];
                if(rts.size() == 0){
                    throw new CommunityException('Could not find record type named Identity for Asset.');
                }
                RecordType rt = rts[0];
                String rtId = rt.Id;
                List<Asset> assets = [select Id, Status, Type__c from Asset where Case__c = :caseId and RecordType.Id = :rtId and Status = 'In Progress'];
                if(assets.size() == 0){
                    throw new CommunityException('Should not have zero assets for this case + ' + caseId);
                }
                String passportAssetId = null;
                String photoId = null;
                for(Asset ass : assets){
                    ass.Status = 'Cancelled';
                    if(ass.Type__c == 'Passport'){
                        passportAssetId = ass.Id;
                    }else if(ass.Type__c == 'Photo'){
                        photoId = ass.Id;
                    }
                }
                update assets;
                List<Affirmation__c> affirmations = [select Id, Status__c from Affirmation__c where Asset__c = :passportAssetId OR Asset__c = :photoId];
                if(affirmations.size() == 0){
                    throw new CommunityException('Should always have a passport affirmation record.');
                }
                for(Affirmation__c aff : affirmations){
                    aff.Status__c = 'Cancelled';
                }
                update affirmations;
                return 'Success';
            }
        }catch(Exception e){
            return 'Error' + e.getMessage();
        }
    }
    @AuraEnabled
    public static Map<String, String> getAffirmationResults(String serviceName, String caseId){
        return CommunityIdentityVerificationController.getAffirmationResults(serviceName, caseId);
    }
    //This method will return a list of case statuses enabling the ability for an applicant to cancel their own case on the Applicant Portal.
    @AuraEnabled(cacheable=true)
    public static List<String> getCancelableCaseStatuses(){
        // get statuses from community settings
        Community_Settings__c settings = Community_Settings__c.getOrgDefaults();
        String statuses = settings.Applicant_Bio_Change_Cancel_Statuses__c;
        // verify the setting exists
        if(statuses == null || statuses == ''){
            throw new CommunityException('Applicant Biographic Change Cancel Status(es) not found in Community Settings.');
        }
        // info: https://salesforced.wordpress.com/2012/05/16/using-the-string-split-method-with-a-pipe-delimiter/
        return statuses.split('\\|');
    }
    @AuraEnabled
    public static String disableUser(String contactId, String details){
        List<Profile> pL = [Select Id, Name FROM Profile WHERE Name = '5-Inactive-Unknown-Community'];
        if(pL.size() == 0){
            throw new CommunityException('5-Inactive-Unknown-Community Profile');
        }
        List<User> uL = [Select Id, UserName, ContactId, IsActive, IsPortalEnabled, Disable_Date__c FROM User WHERE ContactId = :contactId];
        if(uL.size() == 0){
            return 'Error: Not a valid community user';
        }else{
            User u = uL[0];
            addNote(contactId, 'User Disabled By: ' + UserInfo.getUserName(), 'Disabled User Activity has taken place.  The ' + u.UserName + ' was deactivated on ' + System.Now() + ' by ' + UserInfo.getUserName() + '. The User disabled comments are: ' + details);
            if(u.IsActive && u.IsPortalEnabled){
                u.IsActive = false;
                u.IsPortalEnabled = false;
                u.Disable_Comments__c = 'Disabled By ' + UserInfo.getUserName() + '. ' + details;
                u.Disable_Date__c = System.Today();
                u.profileId = pL[0].Id;
                try{
                    update u;
                    return 'Success';
                }catch(Exception e){
                    return 'Error: ' + e.getMessage();
                }
            }else{
                return 'Error: Not a valid community user';
            }
        }
    }
    @AuraEnabled
    public static UserData getUserInfo(String contactId){
        UserData userData = new UserData();
        userData.currentUser = [SELECT Id, Name, UserRoleId FROM User WHERE Id = :UserInfo.getUserId()];
        List<User> uL = [SELECT Id, ContactId, IsActive, IsPortalEnabled, Disable_Date__c, UserRoleId FROM User WHERE ContactId = :contactId WITH SECURITY_ENFORCED];
        if(uL.size() == 0){
            userData.hasRelatedUser = false;
        }else{
            userData.hasRelatedUser = true;
            userData.relatedUserId = uL[0].Id;
        }
        return userData;
    }
    public class UserData{
        @AuraEnabled public User currentUser;
        @AuraEnabled public Boolean hasRelatedUser;
        @AuraEnabled public String relatedUserId;
    }
    @Future
    public static void addNote(String parentId, String title, String body){
        ContentNote cn = new ContentNote(Title = title, Content = Blob.valueOf(body.escapeHTML4()));
        insert cn;
        insert new ContentDocumentLink(ContentDocumentId = cn.Id, LinkedEntityId = parentId, ShareType = 'I', Visibility = 'AllUsers');
    }
    @AuraEnabled
    public static Contact getContactById(String contactId){
        Contact currentContact = [
                Select Id, name, FirstName, LastName, Birthdate, Birth_Country__c, Email, Generational_Suffix__c, AccountId,
                        legal_name_consists_of_one_name_only__c, Phone, Department, Title, Gender__c, Active_Entity_Portal_User__c,
                        Entity_Contact_Initial_Fields_Complete__C, Account.Owner.Id, Account.Owner.Name,
                        Account.RecordType.DeveloperName, Account.Owner.UserRole.Name, Account.Owner.UserRoleId
                From Contact
                Where Id = :contactId
                WITH SECURITY_ENFORCED
        ];
        return currentContact;
    }
    // User the below method activateUserNew
    @AuraEnabled
    public static String activateUser(String contactId){
        Community_Settings__c settings = Community_Settings__c.getOrgDefaults();
        List<Profile> pL = [Select Id, Name FROM Profile WHERE Name = '4-Customer Community Entity 360'];
        if(pL.size() == 0){
            throw new CommunityException('4-Customer Community Entity 360');
        }
        Contact c = getContactById(contactId);
        String nickname = '';
        if(nickname.length() > 0){
            nickname = c.FirstName.substring(0, 1);
        }
        nickname = nickname + c.LastName;
        if(nickname.length() > 20){
            nickname.substring(0, 20);
        }
        String alias = '';
        if(nickname.length() > 8)
            alias = nickname.substring(0, 7); else
                alias = nickname;
        nickname = nickname + System.now();
        User u = new User(
                FirstName = c.FirstName,
                LastName = c.LastName,
                Email = c.Email,
                UserName = c.Email + settings.Username_Append__c,
                ProfileId = pL[0].Id,
                CommunityNickname = nickname,
                Alias = alias,
                TimeZoneSidKey = 'GMT',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                ContactId = contactId
        );
        try{
            insert u;
            addNote(contactId, 'User Enabled By: ' + UserInfo.getUserName(), UserInfo.getUserName() + ' has created a User Community User for this contact on ' + System.Now());
        }catch(Exception e){
            return 'ERROR: ' + e.getMessage();
        }
        return u.Id;
    }
    // Called from modal component on Contact Quick action :- Enable ECFMG Portal User - Activate Entity user button
    @AuraEnabled
    public static void activateUserNew(String contactId){
        if(Schema.SObjectType.Profile.isAccessible()){
            List<Profile> pL = [SELECT Id, Name FROM Profile WHERE Name = '4-Customer Community Entity 360' WITH SECURITY_ENFORCED];
            if(pL.isEmpty()){
                throw new CommunityException('4-Customer Community Entity 360');
            }
        }
        Contact c = getContactById(contactId); // get existing contact
        if(String.isBlank(c.AccountId) || c.Account.RecordType.DeveloperName != 'HH_Account'){
            // Create new account for the existing contact
            Id houseHoldAccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HH_Account').getRecordTypeId();
            Account newAccount = new Account(Name = c.LastName + ' Household', RecordTypeId = houseHoldAccountRecTypeId, OwnerId = UserInfo.getUserId());
            if(Schema.sObjectType.Account.isCreateable()){
                insert newAccount;
            }
            c.AccountId = newAccount.Id;
            if(Schema.sObjectType.Contact.isUpdateable()){
                update c;
            }
        }
        // Future method to create user
        createUserFromContact(new Set<Id>{
                c.Id
        });
    }
    // Creating User from contactId
    @future
    public static void createUserFromContact(Set<Id> contactIds){
        Community_Settings__c settings = Community_Settings__c.getOrgDefaults();
        List<Id> idList = new List<Id>(contactIds);
        Id contactId = idList[0];
        Contact c = getContactById(contactId); // get existing contact
        List<Profile> pL;
        if(Schema.sObjectType.Profile.isAccessible()){
            pL = [SELECT Id, Name FROM Profile WHERE Name = '4-Customer Community Entity 360' WITH SECURITY_ENFORCED];
        }
        List<User> userList = new List<User>();
        // Nickname default
        String nickname = '';
        if(nickname.length() > 0){
            nickname = c.FirstName.substring(0, 1);
        }
        nickname = nickname + c.LastName;
        if(nickname.length() > 20){
            nickname.substring(0, 20);
        }
        String alias = '';
        if(nickname.length() > 8){
            alias = nickname.substring(0, 7);
        }else{
            alias = nickname;
        }
        nickname = nickname + System.now();
        // Create portal user
        User uObj = new User(
                FirstName = c.FirstName,
                LastName = c.LastName,
                Email = c.Email,
                Username = c.Email + settings.Username_Append__c,
                ProfileId = pL[0].Id,
                CommunityNickname = nickname,
                Alias = alias,
                TimeZoneSidKey = 'GMT',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                ContactId = contactId
        );
        userList.add(uObj);
        try{
            if(Schema.sObjectType.User.isCreateable()){
                insert userList;
                //Added for checking the active entity checkbox on contact
                if(Schema.sObjectType.Contact.isUpdateable()){
                    c.Active_Entity_Portal_User__c = true;
                    update c;
                }
            }
        }catch(Exception e){
            throw e;
        }
    }
    // Purpose : Method to convert date into user time zone. Return Type : List<DateTime>
    @AuraEnabled
    public static List<DateTime> getDateInUserZone(List<DateTime> dateToConvertList){
        List<DateTime> convertedUserDateList = new List<DateTime>();
        for(Datetime dt : dateToConvertList){
            Integer offset = UserInfo.getTimezone().getOffset(dt);
            Datetime convertedUserDate = dt.addSeconds(offset / 1000);
            convertedUserDateList.add(convertedUserDate);
        }
        return convertedUserDateList;
    }
    //Purpose : Method to get current Case Transcript Request. Return Type : List<Transcript_Request__c>
    @AuraEnabled
    public static List<Transcript_Request__c> getTrascriptRecs(String caseId){
        List<Transcript_Request__c> transcriptDetailsToReturn = new List<Transcript_Request__c>([
                SELECT Case__c, City__c, Contact__c, Country__c,
                        Courier__c, Name_of_Recipient__c, Number_of_Copies__c, Organization__c,
                        Parent_Transcript_Request__c, Send_to_Same_Address__c, Send_to_Self__c,
                        State__c, Street__c, Telephone_Number__c,
                        Zip_Postal_Code__c,
                        Tracking_Number__c
                FROM Transcript_Request__c
                WHERE Case__c = :caseId
        ]);
        return transcriptDetailsToReturn;
    }
    //Purpose : Method to get if Entity is enrolled in Entity Portal.Return Type : Boolean
    @AuraEnabled
    public static boolean checkPEForm(){
        Boolean returnVal = true;
        Id contactId = AppforCertHelper.retrieveCurrentContactId();
        List<Contact_Association_Type__c> catRecord = new List<Contact_Association_Type__c>([Select Account__c from Contact_Association_Type__c where Contact__c = :contactId AND RecordType.DeveloperName = 'Degree_Medical_School']);
        if(!catRecord.isEmpty()){
            List<Account2Service__c> acnt2services = [
                    SELECT Id, Service__c, Service__r.Id
                    FROM Account2Service__c
                    WHERE Account__c = :catRecord[0].Account__c AND Active__c = true
            ];
            if(!acnt2services.isEmpty()){
                returnVal = false;
            }else{
                returnVal = true;
            }
        }else{
            returnVal = true;
        }
        return returnVal;
    }
    //Purpose: To fetch the Azure URL for Paper Enrollment verification form
    @AuraEnabled
    public static string getPEFormURLEV(String caseId){
        String returnVal = '';
        List<Case> caseList = new List<Case>([Select Id, Enrollment_Verification_Parent__c from Case where Id = :caseId]);
        String parentCase = caseList[0].Enrollment_Verification_Parent__c;
        if(parentCase != null || parentCase != ''){
            List<Asset> getAssetLink = new List<Asset>([Select Id, Azure_Storage_URL__c from Asset where Case__c = :parentCase AND Type__c = 'Enrollment Verification Form' AND Status = 'In Progress']);
            if(getAssetLink.size() > 0){
                String assetLink = getAssetLink[0].Azure_Storage_URL__c;
                returnVal = assetLink.substringAfterLast('/');
            }
        }
        return returnVal;
    }
    //Check EPex Request and then check Exam Reg EVCase
    @AuraEnabled
    public static string getPEFormURL(String caseId){
        String returnVal = ExamRegistrationController.getPEAssetLink(caseId);
        return returnVal;
    }
    @AuraEnabled(cacheable = true)
    public static String getFileUrlWithSAS(String fileName){
        try{
            String fullFileURLWithSasToken = CloudStorageUtils.getRequestUrl(DocumentEnums.DocumentAccessLevel.READ, fileName);
            return fullFileURLWithSasToken;
        }catch(Exception e){
            throw e;
        }
    }
    //Purpose : Method to check Internal status of the Enrollement Verification Parent. Return Type : Boolean
    @AuraEnabled
    public static boolean getInternalStatus(String caseId){
        Boolean returnFlag = false;
        Boolean flag1 = false;
        Boolean flag2 = false;
        List<Case> caseRec = new List<Case>([Select Id, Enrollment_Verification_Parent__c from Case where Id = :caseId]);
        String parentCase = caseRec[0].Enrollment_Verification_Parent__c;
        if(parentCase == null || parentCase == ''){
            flag1 = false;
        }else{
            List<Case> caseRecord = new List<Case>([Select Id, Internal_Status__c from Case where Id = :parentCase]);
            List<String> caseStatus = new List<String>{
                    Constants.CASE_STATUS_RECEIVED_IN_REVIEW, Constants.CASE_STATUS_PENDING_ENROLLMENT, Constants.CASE_STATUS_PENDING_REVIEW, Constants.CASE_STATUS_ENROLLMENT_VERIFICATION_INCOMPLETE, Constants.CASE_STATUS_IN_REVIEW
            };
            flag1 = caseStatus.contains(caseRecord[0].Internal_Status__c);
        }
        flag2 = ExamRegistrationController.getParentCaseInternalStatus(caseId);
        returnFlag = flag1 || flag2;
        return returnFlag;
    }
    // Purpose : Method to check if Scheduling Permit link is to be Visible on the Exam registration Case detail. Return Type : Boolean
    @AuraEnabled
    public static boolean checkPermitForm(String caseId){
        Boolean returnVal = false;
        List<Exam_Registration__c> examRecList = new List<Exam_Registration__c>([Select Id, Exam_Status__c, Case__r.External_Status__c from Exam_Registration__c where Case__c = :caseId]);
        List<Asset> assetList = new List<Asset>([Select Id from Asset where Case__c = :caseId AND Type__c = 'Scheduling Permit' AND Status = 'In Progress']);
        if(examRecList.size() > 0){
            if(examRecList[0].Case__r.External_Status__c == 'Registered' && (examRecList[0].Exam_Status__c == '' || examRecList[0].Exam_Status__c == null) && assetList.size() > 0){
                returnVal = true;
            }else{
                returnVal = false;
            }
        }else{
            returnVal = false;
        }
        return returnVal;
    }
    //Purpose : Method to check if Visa Letter link is to be Visible on the Exam registration Case detail. Return Type : Boolean
    @AuraEnabled
    public static boolean checkVisaLetter(String caseId){
        Boolean returnVal = false;
        List<Exam_Registration__c> examRecList = new List<Exam_Registration__c>([Select Id, Exam_Status__c, Exam_Types__c, Case__r.External_Status__c, Visa_Letter_Needed__c from Exam_Registration__c where Case__c = :caseId]);
        List<Asset> assetList = new List<Asset>([Select Id from Asset where Case__c = :caseId AND Type__c = 'Visa Letter' AND Status = 'In Progress']);
        if(examRecList.size() > 0){
            if(examRecList[0].Case__r.External_Status__c == 'Registered' && (examRecList[0].Exam_Status__c == '' || examRecList[0].Exam_Status__c == null) && assetList.size() > 0 && examRecList[0].Exam_Types__c == 'USMLE Step 2 CS' && examRecList[0].Visa_Letter_Needed__c == TRUE){
                returnVal = true;
            }else{
                returnVal = false;
            }
        }else{
            returnVal = false;
        }
        return returnVal;
    }
    //Purpose: To get the License Val of the logged in User. Return Type: String
    @AuraEnabled(cacheable = false)
    public static string contactStagingLicenseVal(){
        Id contactId = AppforCertHelper.retrieveCurrentContactId();
        List<Contact_Staging__c > csRecords = new List<Contact_Staging__c >();
        List<Contact> conRec = new List<Contact>();
        csRecords = [Select Id, Contact__c, Previous_License__c, RecordType.DeveloperName from Contact_Staging__c where Contact__c = :contactId AND RecordType.DeveloperName = :Constants.CONTACT_STAGING_RECORDTYPE_EXAMREGISTRATION LIMIT 1];
        if(csRecords.size() > 0){
            return csRecords[0].Previous_License__c;
        }else{
            conRec = [Select Id, Previous_License__c, RecordType.DeveloperName from Contact where Id = :contactId];
            if(conRec.size() > 0){
                return conRec[0].Previous_License__c;
            }else{
                return 'NoValue';
            }
        }
    }
    //Purpose: To get the Exam registered with the case.Return Type: List<ExamRegRecordWrapper>
    @AuraEnabled(cacheable = false)
    public static List< ExamRegRecordWrapper > getExamRegistrations(String caseId){
        Id examRegRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        List<ExamRegRecordWrapper> examRegWrapperList = new List<ExamRegRecordWrapper>();
        for(Exam_Registration__c examReg : [SELECT Id, Exam_Types__c, EP_start_Date__c, EP_end_Date__c, Product_Detail__c, Product_Detail__r.Exam_Region__r.Name, Test_Accommodations_needed__c FROM Exam_Registration__c WHERE Case__r.RecordTypeId = :examRegRecordTypeId AND Case__c = :caseId ORDER BY Exam_Types__c]){
            Integer epSTYear = examReg.EP_start_Date__c.year();
            Integer epSTMonth = examReg.EP_start_Date__c.month();
            Integer epSTDay = examReg.EP_start_Date__c.day();
            DateTime epSTDt = DateTime.newInstance(epSTYear, epSTMonth, epSTDay);
            Integer epENYear = examReg.EP_end_Date__c.year();
            Integer epENMonth = examReg.EP_end_Date__c.month();
            Integer epENDay = examReg.EP_end_Date__c.day();
            DateTime epENDt = DateTime.newInstance(epENYear, epENMonth, epENDay);
            examRegWrapperList.add(new ExamRegRecordWrapper(
                    examReg.Id,
                    examReg.Exam_Types__c,
                    epSTDt.format('MMM d,  yyyy') + ' - ' + epENDt.format('MMM d,  yyyy'),
                    examReg.Product_Detail__r.Exam_Region__r.Name,
                    examReg.Test_Accommodations_needed__c
            ));
        }
        return examRegWrapperList;
    }
    //Wrapper class to store exam registration record data in examregLandingPage
    public class ExamRegRecordWrapper{
        @auraenabled public string recordIdVal{
            get;
            set;
        }
        @auraenabled public string examType{
            get;
            set;
        }
        @auraenabled public string eligibilityPeriod{
            get;
            set;
        }
        @auraenabled public string testingRegion{
            get;
            set;
        }
        @auraenabled public string testAccomodations{
            get;
            set;
        }
        public ExamRegRecordWrapper(String examRegId, String examRegType, String examRegEP, String examRegRegion, String examRegTestAcc){
            recordIdVal = examRegId;
            examType = examRegType;
            eligibilityPeriod = examRegEP;
            testingRegion = examRegRegion;
            testAccomodations = examRegTestAcc;
        }
    }
    // Return Type: StagingRecordWrapper, Purpose :  To get the ethnicity details and Native language details
    @AuraEnabled
    public static StagingRecordWrapper getStagingRecord(){
        Id contactId = AppForCertHelper.retrieveCurrentContactId();
        String tempEnthnicity = '';
        String tempNationalIdCountry = '';
        String tempNationalIdentification = '';
        String tempNativeLanguage = '';
        String tempSocialSecurity = '';
        String tempOfficiallyEnrolled = '';
        String tempBasicSciencesRequirement = '';
        String tempOtherNativeLanguage = '';
        String tempOtherLanguagesSpoken = '';
        String tempAddLanguagesSpoken = '';
        StagingRecordWrapper returnValues;
        List<Contact_Staging__c> csRecords = [SELECT Id, Native_Language__c, Ethnicity__c, National_ID_Country__c, US_Social_Security__c, National_Identification__c, Other_Native_Language__c, Other_Languages_Spoken__c, Additional_Languages_Spoken__c FROM Contact_Staging__c where Contact__c = :contactId AND RecordType.DeveloperName = :Constants.CONTACT_STAGING_RECORDTYPE_EXAMREGISTRATION];
        if(csRecords.size() > 0){
            if(csRecords[0].Native_Language__c == null){
                Contact contact = [SELECT Id, Native_Language__c, Ethnicity__c, National_ID_Country__c, US_Social_Security__c, National_Identification__c, Other_Native_Language__c, Other_Languages_Spoken__c, Additional_Languages_Spoken__c FROM Contact where Id = :contactId][0];
                tempEnthnicity = checkNullValue(contact.Ethnicity__c);
                tempNationalIdCountry = checkNullValue(contact.National_ID_Country__c);
                tempNationalIdentification = checkNullValue(contact.National_Identification__c);
                tempNativeLanguage = checkNullValue(contact.Native_Language__c);
                tempSocialSecurity = checkNullValue(contact.US_Social_Security__c);
                tempOtherNativeLanguage = checkNullValue(contact.Other_Native_Language__c);
                tempOtherLanguagesSpoken = checkNullValue(contact.Other_Languages_Spoken__c);
                tempAddLanguagesSpoken = checkNullValue(contact.Additional_Languages_Spoken__c);
            }else{
                Contact_Staging__c contactStaging = csRecords[0];
                tempEnthnicity = checkNullValue(contactStaging.Ethnicity__c);
                tempNationalIdCountry = checkNullValue(contactStaging.National_ID_Country__c);
                tempNationalIdentification = checkNullValue(contactStaging.National_Identification__c);
                tempNativeLanguage = checkNullValue(contactStaging.Native_Language__c);
                tempSocialSecurity = checkNullValue(contactStaging.US_Social_Security__c);
                tempOtherNativeLanguage = checkNullValue(contactStaging.Other_Native_Language__c);
                tempOtherLanguagesSpoken = checkNullValue(contactStaging.Other_Languages_Spoken__c);
                tempAddLanguagesSpoken = checkNullValue(contactStaging.Additional_Languages_Spoken__c);
            }
            List<Exam_Registration__c > examRegs = [SELECT Basic_Sciences_Requirement__c, Officially_Enrolled__c FROM Exam_Registration__c WHERE Applicant__c = :contactId];
            if(!examRegs.isEmpty()){
                if(examRegs[0].Basic_Sciences_Requirement__c != null){
                    tempBasicSciencesRequirement = examRegs[0].Basic_Sciences_Requirement__c;
                }
                if(examRegs[0].Officially_Enrolled__c != null){
                    tempOfficiallyEnrolled = examRegs[0].Officially_Enrolled__c;
                }
            }
            returnValues = new StagingRecordWrapper(tempEnthnicity, tempNationalIdCountry, tempNationalIdentification, tempNativeLanguage, tempSocialSecurity, tempOfficiallyEnrolled, tempBasicSciencesRequirement, tempOtherNativeLanguage, tempOtherLanguagesSpoken, tempAddLanguagesSpoken);
        }else{
            returnValues = sonarFixGetStaging(contactId);
        }
        return returnValues;
    }
    public static StagingRecordWrapper sonarFixGetStaging(Id contactId){
        String tempEnthnicity = '';
        String tempNationalIdCountry = '';
        String tempNationalIdentification = '';
        String tempNativeLanguage = '';
        String tempSocialSecurity = '';
        String tempOfficiallyEnrolled = '';
        String tempBasicSciencesRequirement = '';
        String tempOtherNativeLanguage = '';
        String tempOtherLanguagesSpoken = '';
        String tempAddLanguagesSpoken = '';
        StagingRecordWrapper val;
        List<Contact> conRec = [SELECT Id, Native_Language__c, Ethnicity__c, National_ID_Country__c, US_Social_Security__c, National_Identification__c, Other_Native_Language__c, Other_Languages_Spoken__c, Additional_Languages_Spoken__c FROM Contact where Id = :contactId];
        tempEnthnicity = checkNullValue(conRec[0].Ethnicity__c);
        tempNationalIdCountry = checkNullValue(conRec[0].National_ID_Country__c);
        tempNationalIdentification = checkNullValue(conRec[0].National_Identification__c);
        tempNativeLanguage = checkNullValue(conRec[0].Native_Language__c);
        tempSocialSecurity = checkNullValue(conRec[0].US_Social_Security__c);
        tempOtherNativeLanguage = checkNullValue(conRec[0].Other_Native_Language__c);
        tempOtherLanguagesSpoken = checkNullValue(conRec[0].Other_Languages_Spoken__c);
        tempAddLanguagesSpoken = checkNullValue(conRec[0].Additional_Languages_Spoken__c);
        List<Exam_Registration__c > examRegs = [SELECT Basic_Sciences_Requirement__c, Officially_Enrolled__c FROM Exam_Registration__c WHERE Applicant__c = :contactId];
        if(!examRegs.isEmpty()){
            if(examRegs[0].Basic_Sciences_Requirement__c != null){
                tempBasicSciencesRequirement = examRegs[0].Basic_Sciences_Requirement__c;
            }
            if(examRegs[0].Officially_Enrolled__c != null){
                tempOfficiallyEnrolled = examRegs[0].Officially_Enrolled__c;
            }
        }
        val = new StagingRecordWrapper(tempEnthnicity, tempNationalIdCountry, tempNationalIdentification, tempNativeLanguage, tempSocialSecurity, tempOfficiallyEnrolled, tempBasicSciencesRequirement, tempOtherNativeLanguage, tempOtherLanguagesSpoken, tempAddLanguagesSpoken);
        return val;
    }
    //Wrapper class to store staging record data in screen 6
    public class StagingRecordWrapper{
        @auraenabled public string ethnicity{
            get;
            set;
        }
        @auraenabled public string nationalIDCountry{
            get;
            set;
        }
        @auraenabled public string nationalIdentification{
            get;
            set;
        }
        @auraenabled public string nativeLanguage{
            get;
            set;
        }
        @auraenabled public string socialSecurityNumber{
            get;
            set;
        }
        @auraenabled public string officiallyEnrolled{
            get;
            set;
        }
        @auraenabled public string basicSciencesRequirement{
            get;
            set;
        }
        @auraenabled public string otherNativeLanguage{
            get;
            set;
        }
        @auraenabled public string otherLanguagesSpoken{
            get;
            set;
        }
        @auraenabled public string addLanguagesSpoken{
            get;
            set;
        }
        public StagingRecordWrapper(String sRethnicity, String sRnationalIDCountry, String sRnationalIdentification, String sRnativeLanguage, String sRsocialSecurityNumber, String sRofficiallyEnrolled, String sRbasicSciencesRequirement, String sRotherNativeLanguage, String sRotherLanguagesSpoken, String sRaddLanguagesSpoken){
            ethnicity = sRethnicity;
            nationalIDCountry = sRnationalIDCountry;
            nationalIdentification = sRnationalIdentification;
            nativeLanguage = sRnativeLanguage;
            socialSecurityNumber = sRsocialSecurityNumber;
            officiallyEnrolled = sRofficiallyEnrolled;
            basicSciencesRequirement = sRbasicSciencesRequirement;
            otherNativeLanguage = sRotherNativeLanguage;
            otherLanguagesSpoken = sRotherLanguagesSpoken;
            addLanguagesSpoken = sRaddLanguagesSpoken;
        }
    }
    public static String checkNullValue(String stringVal){
        String returnVal = '';
        if(stringVal != null){
            returnVal = stringVal;
        }
        return returnVal;
    }
    @AuraEnabled(Cacheable = false)
    public static Boolean isApplicantStudentOrGraduate(){
        Boolean isGraduate = false;
        Id contactId = AppforCertHelper.retrieveCurrentContactId();
        String contactStatus = [
                SELECT School_Enrollment_Status__c
                FROM Contact
                WHERE id = :contactId
        ].School_Enrollment_Status__c;
        if(contactStatus == Constants.CONASCTYPESTG_STATUS_GRADUATE){
            isGraduate = true;
        }
        return isGraduate;
    }
    //Purpose : Method to fetch Exam Registration for summary. Return Type : List of Exam_Registration__c records
    @AuraEnabled
    public static List <RegionRecordWrapper> getExamRegistrationforSummary(String caseId){
        List<String> allExams = new List<String>();
        List<RegionRecordWrapper> retList = new List<RegionRecordWrapper>();
        List<String> regionName = new List<String>();
        List<Decimal> regionCharge = new List<Decimal>();
        for(Case exam : [
                Select Id, Exam_Registration__c, Product_Detail__r.Surcharge__c, Product_Detail__r.Exam_Region__r.Region_Name__c
                from Case
                Where Id = :caseId
        ]){
            allExams.add(exam.Exam_Registration__c);
            regionName.add(exam.Product_Detail__r.Exam_Region__r.Region_Name__c);
            Decimal sumVal = exam.Product_Detail__r.Surcharge__c;
regionCharge.add(sumVal);
        }
        if(allExams.size() > 0){
            Integer val = 0;
            for(Exam_Registration__c exam : [
                    Select Id, Name, Exam_Types__c, Surcharge__c,
                            New_Region_Name__c, Current_Region_Name__c,
                            Case__r.Product_Detail__r.Exam_Region__r.Region_Name__c,
                            Case__r.Surcharge__c
                    From Exam_Registration__c
                    Where Id IN:allExams
                    Order By Exam_Types__c
            ]){
                String newRegion = regionName[val] + '($' + regionCharge[val] + ')';
                String idVal = '' + exam.Id;
                RegionRecordWrapper recToAdd = new RegionRecordWrapper(idVal, exam.Exam_Types__c, exam.Current_Region_Name__c, newRegion);
                retList.add(recToAdd);
                val++;
            }
        }
        return retList;
    }
    //Wrapper class
    public class RegionRecordWrapper{
        @auraenabled public string recId{
            get;
            set;
        }
        @auraenabled public string examTypeVal{
            get;
            set;
        }
        @auraenabled public string currentRegionName{
            get;
            set;
        }
        @auraenabled public string newRegionName{
            get;
            set;
        }
        public RegionRecordWrapper(String id, String examType, String currentRegion, String newRegion){
            recId = id;
            examTypeVal = examType;
            currentRegionName = currentRegion;
            newRegionName = newRegion;
        }
    }
    // Purpose : Method to fetch Exam Registration for EPeX summary. Return Type : List of Exam Registration
    @AuraEnabled(Cacheable = false)
    public static List <Case> getUpdatedEPEx(String caseId){
        List<Case> returnList = new List<Case>([Select Id, EP_Start_Date__c, EP_End_Date__c, Parent.Eligibility_Period__r.EP_Start_Date__c, Parent.Eligibility_Period__r.EP_End_Date__c, Parent.Eligibility_Period__r.Exam_Type__c, Parent.Previous_EP_Start_Date__c, Parent.Previous_EP_End_Date__c from Case where Id =:caseId]);
        return returnList;
    }
    //Return Type: Boolean. Purpose: get if the User has asset of Recheck Letter
    @AuraEnabled(Cacheable = false)
    public static boolean getAssetRec(String caseId){
        Boolean retVal = false;
        List<Asset> assetRec = new List<Asset>();
        assetRec = [Select Id from Asset where Type__c = 'Score Recheck Letter' AND RecordType.DeveloperName = 'Exam_Registration' AND Case__c = :caseId AND status != :constants.ASSET_STATUS_MARKED_FOR_DELETION];
        if(assetRec.size() > 0){
            retVal = true;
        }else{
            retVal = false;
        }
        return retVal;
    }
    //Return Type: String. Purpose: get the User Asset Id
    @AuraEnabled(Cacheable = false)
    public static List<String> getAssetRecords(String caseId){
        List<Asset> assetRec = new List<Asset>();
        List<Id> assetId = new List<Id>();
        List<String> idToReturn = new List<String>();
        assetRec = [Select Id from Asset where Type__c = 'Score Recheck Letter' AND RecordType.DeveloperName = 'Exam_Registration' AND Case__c = :caseId AND status != :constants.ASSET_STATUS_MARKED_FOR_DELETION];
        if(assetRec.size() > 0){
            for(Integer i = 0; i < assetRec.size(); i++){
                assetId.add(assetRec[i].Id);
            }
            List<ContentDocumentLink> docList = new List<ContentDocumentLink>();
            docList = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN:assetId AND LinkedEntity.Type = 'Asset'];
            if(docList.size() > 0){
                for(integer i = 0; i < docList.size(); i++){
                    idToReturn.add(docList[i].ContentDocumentId);
                }
            }
        }
        return idToReturn;
    }
    //Purpose : Method to fetch Score Report Information.Return Type : List of Exam Registration
    @AuraEnabled(Cacheable = false)
    public static List< ScoreReportHelper.ExamScoreWrapper > getScoreReportInfo(string caseId){
        List<ScoreReportHelper.ExamScoreWrapper> returnValue = new List<ScoreReportHelper.ExamScoreWrapper>();
        String examRecId;
        Case examRec = [Select Id, Exam_Registration__c from Case where Id = :caseId];
        examRecId = examRec.Exam_Registration__c;
        for(Exam_Registration__c examReg : [
                SELECT Id, Name, Exam_Types__c, Exam_taken_date__c, Posted_Date__c,Pd_Optout_flag__c,Withheld_Reason__c,Withheld_Score__c
                FROM Exam_Registration__c
                WHERE Id = :examRecId
        ]){
            String tempAvailableDate;
            String tempExamDate;
            Boolean tempIsAvailable = true;
            String optOutFlag = Constants.STATUS_NO;
            string withHeldReason = '';
            Date availableDate = examReg.Posted_Date__c.addDays(365);
            tempAvailableDate = String.valueOf(DateTime.newInstance(availableDate.year(), availableDate.month(), availableDate.day()).format(Constants.DATE_FORMAT));
            if(System.today() > availableDate){
                tempIsAvailable = false;
            }
            if(examReg.Exam_taken_date__c != null){
                tempExamDate = String.valueOf(DateTime.newInstance(examReg.Exam_taken_date__c.year(), examReg.Exam_taken_date__c.month(), examReg.Exam_taken_date__c.day()).format(Constants.DATE_FORMAT));
            }else{
                tempExamDate = '';
            }
            if(examReg.Pd_Optout_flag__c == True){
                optOutFlag = Constants.STATUS_YES;
            }
            withHeldReason = getWithHeldReason(examReg);
            String scoreReport = '';
            ScoreReportHelper.ExamScoreWrapper examScoreObj = new ScoreReportHelper.ExamScoreWrapper (examReg.Id, examReg.Exam_Types__c, tempExamDate, tempAvailableDate, scoreReport, tempIsAvailable, optOutFlag, withHeldReason, examReg.Withheld_Score__c);
            returnValue.add(examScoreObj);
        }
        return returnValue;
    }
    // Purpose : Method to get WithHeldReason.Return Type : String
    @AuraEnabled(Cacheable = false)
    public static String getWithHeldReason(Exam_Registration__c examReg){
        string withHeldReason = '';
        if(string.isnotblank(examReg.Withheld_Reason__c)){
            if(examReg.Withheld_Reason__c.contains(Constants.SCORE_WITHHELD_REASON_ENROLLMENT_REVERIFICATION) && examReg.Withheld_Reason__c.contains(Constants.SCORE_WITHHELD_REASON_ID_VERIFICATION)){
                withHeldReason = Constants.SCORE_WITHHELD_REASON_ID_VERIFICATION_SCORE_RECHECK + ' ' + Constants.SCORE_WITHHELD_REASON_ENROLLMENT_REVERIFICATION_SCORE_RECHECK;
            }else if(examReg.Withheld_Reason__c.contains(Constants.SCORE_WITHHELD_REASON_ENROLLMENT_REVERIFICATION)){
                withHeldReason = Constants.SCORE_WITHHELD_REASON_ENROLLMENT_REVERIFICATION_SCORE_RECHECK;
            }else if(examReg.Withheld_Reason__c.contains(Constants.SCORE_WITHHELD_REASON_ID_VERIFICATION)){
                withHeldReason = Constants.SCORE_WITHHELD_REASON_ID_VERIFICATION_SCORE_RECHECK;
            }
        }
        return withHeldReason;
    }
    // Description : To create payload for already uploaded Accepted assets . Exposed as Public
    @AuraEnabled
    public static CloudStorageController.PayloadWrapper createAcceptedPhotoPayload(String contactId, string assetName){
        List<Asset> assetList = [SELECT id FROM Asset where contactId = :contactId AND Name = :assetName AND 
        status = :Constants.ASSET_STATUS_VERIFIED AND status != :Constants.ASSET_STATUS_MARKED_FOR_DELETION 
        AND Case__r.RecordType.DeveloperName !=: Constants.CASE_RECORD_TYPE_ERAS 
        WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC ];
        String assetId = null;
        String accountId = null;
        String caseId = null;
        List<Case> caseList = [SELECT id,AccountId FROM Case where contactId = :contactId and RecordType.DeveloperName = :Constants.CASE_RECORD_TYPE_IDENTITY_VERIFICATION];
        if(!caseList.isEmpty()){
            accountId = caseList[0].AccountId;
            caseId = caseList[0].Id;
        }
        if(!assetList.isEmpty()){
            assetId = assetList[0].Id;
        }
        CloudStorageController.PayloadWrapper payload = new CloudStorageController.PayloadWrapper(contactId, assetName, 'Identity', '', caseId, accountId, 'true', 'Verified', assetId);
        return payload;
    }
    //Description : To create payload for already uploaded Accepted assets . Exposed as Public  
    @AuraEnabled
    public static Boolean checkForAcceptedDoc(){
        List<String> assetName = new List<String>();
        assetName.add(Constants.ASSET_NAME_PASSPORT);
        assetName.add(Constants.ASSET_NAME_PHOTO);
        assetName.add(Constants.ASSET_NAME_PASSPORT_TRANSLATION);
        assetName.add(Constants.ASSET_NAME_PASSPORT_EXPIRATION);
        assetName.add(Constants.ASSET_NAME_ID_FORM_NOTARIZED);
        List<Asset> assetList = [SELECT id FROM Asset where contactId = :getRunningContactId() AND Name in :assetName AND status = :Constants.ASSET_STATUS_VERIFIED AND status != :Constants.ASSET_STATUS_MARKED_FOR_DELETION ORDER BY CreatedDate DESC];
        Boolean assetId = false;
        if(assetList.isEmpty()){
            assetId = true;
        }
        return assetId;
    }
    // Purpose To create payload for passport translation upload  Exposed as Public
    @AuraEnabled
    public static CloudStorageController.PayloadWrapper createPassportTranslationPayload(String contactId){
        String assetId = null;
        String accountId = null;
        String caseId = null;
        List<Asset> assetList = [SELECT Id, Azure_Storage_URL__c FROM Asset WHERE ContactId =: contactId AND Name =: Constants.ASSET_NAME_PASSPORT_TRANSLATION AND Status =: STATUS_IN_PROGRESS WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
        if(!assetList.isEmpty()){
            assetId = assetList[0].id;
            CloudStorageController.PayloadWrapper payload = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_NAME_PASSPORT_TRANSLATION, 'Identity', '', caseId, accountId, '', STATUS_IN_PROGRESS, assetId, '', '', '', 'true', assetList[0].Azure_Storage_URL__c);
            return payload;
        }else{
            CloudStorageController.PayloadWrapper payload = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_NAME_PASSPORT_TRANSLATION, 'Identity', 'Replace', caseId, accountId, 'true', STATUS_IN_PROGRESS, assetId);
            return payload;
        }
    }

    @AuraEnabled
    public static CloudStorageController.PayloadWrapper createPassportExpirationPayload(String contactId){
        String assetId = null;
        String accountId = null;
        String caseId = null;
        List<Asset> assetList = [SELECT Id, Azure_Storage_URL__c FROM Asset WHERE ContactId =: contactId AND Name =: Constants.ASSET_NAME_PASSPORT_EXPIRATION AND Status =: STATUS_IN_PROGRESS WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
        if(!assetList.isEmpty()){
            assetId = assetList[0].id;
            CloudStorageController.PayloadWrapper payload = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_NAME_PASSPORT_EXPIRATION, 'Identity', '', caseId, accountId, '', STATUS_IN_PROGRESS, assetId, '', '', '', 'true', assetList[0].Azure_Storage_URL__c);
            return payload;
        }else{
            CloudStorageController.PayloadWrapper payload = new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_NAME_PASSPORT_EXPIRATION, 'Identity', 'Replace', caseId, accountId, 'true', STATUS_IN_PROGRESS, assetId);
            return payload;
        }
    }
    // To mark existing translation assets for deletion . Exposed as Public
    @AuraEnabled
    public static void deleteExistingAsset(String contactId){
        List<Asset> assetList = [SELECT id FROM Asset where contactId = :contactId AND Name = :Constants.ASSET_NAME_PASSPORT_TRANSLATION AND status = :Constants.ASSET_STATUS_IN_PROGRESS ORDER BY CreatedDate DESC];
        List<RecordType> rts = new List<RecordType>();
        if(RecordType.SObjectType.getDescribe().isAccessible()){
            rts = [SELECT Id, Name from RecordType where DeveloperName = :Constants.ASSET_RECORD_TYPE_MARKED_FOR_DELETION AND SObjectType = 'Asset'];
        }
        if(rts.size() == 0){
            throw new CommunityException(RECORD_TYPE_EXCEPTION);
        }
        RecordType assetMarkedForDeletionRT = rts[0];
        for(Asset asst : assetList){
            asst.case__c = null;
            asst.status = constants.ASSET_STATUS_MARKED_FOR_DELETION;
            asst.RecordTypeId = assetMarkedForDeletionRT.Id;
        }
        if(!assetList.isEmpty()){
            update assetList;
        }
    }
    // To mark existing passport and photo assets for deletion.  Exposed as Public
    @AuraEnabled
    public static void deleteExistingPassportAssets(String contactId){
        List<Asset> assetList = [SELECT id FROM Asset where contactId = :contactId AND (type__c = :Constants.ASSET_NAME_PASSPORT OR type__c = :Constants.ASSET_NAME_PHOTO OR type__c = :Constants.ASSET_TYPE_BIRTH_CERTIFICATE OR type__c = :Constants.ASSET_TYPE_MARRIAGE_CERTIFICATE OR type__c = :Constants.ASSET_TYPE_OFFICIAL_COURT_ORDER OR type__c = :Constants.ASSET_TYPE_US_RESIDENT_ALIEN_CARD OR type__c = :Constants.ASSET_TYPE_US_NATURALIZATION_CERTIFICATE OR type__c = :Constants.ASSET_TYPE_US_PASSPORT_CARD) AND status = :Constants.ASSET_STATUS_IN_PROGRESS ORDER BY CreatedDate DESC];
        List<RecordType> rts = new List<RecordType>();
        if(RecordType.SObjectType.getDescribe().isAccessible()){
            rts = [SELECT Id, Name from RecordType where DeveloperName = :Constants.ASSET_RECORD_TYPE_MARKED_FOR_DELETION AND SObjectType = 'Asset'];
        }
        if(rts.size() == 0){
            throw new CommunityException(RECORD_TYPE_EXCEPTION);
        }
        RecordType assetMarkedForDeletionRT = rts[0];
        for(Asset asst : assetList){
            asst.case__c = null;
            asst.status = constants.ASSET_STATUS_MARKED_FOR_DELETION;
            asst.RecordTypeId = assetMarkedForDeletionRT.Id;
        }
        if(!assetList.isEmpty()){
            update assetList;
        }

        Contact c = getContact();
        String caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Applicant Biographic Change').getRecordTypeId();
        List<Case>caseList = new List<Case>();
        try{
        caseList = [SELECT Id, Description, Reason_for_Change__c FROM Case WHERE ContactId =: c.Id AND Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION AND RecordTypeId =: caseRecordTypeId];
        }catch(Exception e){
        caseList = new List<Case>();
        }
        List<Contact_Staging__c>cs = [SELECT Id FROM Contact_Staging__c WHERE Case__c =: caseList[0].Id];
        if(!cs.isEmpty()){
        try{
            delete cs;
        }catch(Exception e){
            cs = new List<Contact_Staging__c>();
        }
        }
        if(!caseList.isEmpty()){
            caseList[0].Description = '';
            caseList[0].Reason_for_Change__c = '';
            try{
                update caseList[0];
            }catch(Exception e){
                caseList = new List<Case>();
            }
        }
    }
    // To mark existing expiration assets for deletion. Exposed as Public
    @AuraEnabled
    public static void deleteExistingExpirationAsset(String contactId){
        List<Asset> assetList = [SELECT id FROM Asset where contactId = :contactId AND Name = :Constants.ASSET_NAME_PASSPORT_EXPIRATION AND status = :Constants.ASSET_STATUS_IN_PROGRESS ORDER BY CreatedDate DESC];
        List<RecordType> rts = new List<RecordType>();
        if(RecordType.SObjectType.getDescribe().isAccessible()){
            rts = [SELECT Id, Name from RecordType where DeveloperName = :Constants.ASSET_RECORD_TYPE_MARKED_FOR_DELETION AND SObjectType = 'Asset'];
        }
        if(rts.size() == 0){
            throw new CommunityException(RECORD_TYPE_EXCEPTION);
        }
        RecordType assetMarkedForDeletionRT = rts[0];
        for(Asset asst : assetList){
            asst.case__c = null;
            asst.status = constants.ASSET_STATUS_MARKED_FOR_DELETION;
            asst.RecordTypeId = assetMarkedForDeletionRT.Id;
        }
        if(!assetList.isEmpty()){
            update assetList;
        }
    }
    @AuraEnabled
    public static string downloadEpermit(){
       return NBMEEPermit.getBase64Pdf();
    }
    @AuraEnabled
    public static Boolean checkRestrictOnAppBio(){
        try{
            String contactId = CommunityIdentityVerificationController.getRunningContactId();
            ConWrapper conWrap = new ConWrapper();
            conWrap.contactId = contactId;
            conWrap.service = 'Biographic Change - Internal and External';
            String jsonInput = JSON.serialize(conWrap);
            String errorMsg = RestrictedMessage.getMessage(jsonInput);
            if(errorMsg != null && errorMsg != ''){
                return true;
            }
            return false;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    public class ConWrapper{
       @auraenabled public string contactId;
       @auraenabled public string service;
    }
    @AuraEnabled
    public static String getCaseRestrictionDtl(String caseId){
        String returnVal= '';        
        Case restCheck = [Select Id,Case_Service__c,ContactId,Action_Required_Icon__c From Case Where Id =: caseId WITH SECURITY_ENFORCED];
        ApplicantCaseRecord.GetMessageWrapper rstMsg = new ApplicantCaseRecord.GetMessageWrapper();                
        rstMsg.caseId = null;
        rstMsg.accountId = null;
        rstMsg.contactId = restCheck.ContactId;
        rstMsg.service = restCheck.Case_Service__c+ ' - Internal and External';
        String inputJSONdtl = JSON.serialize(rstMsg);                
        String rstDtl = RestrictedMessage.getMessage(inputJSONdtl);                
        if(string.isNotBlank(rstDtl)){
            String actionVal;
            if(restCheck.Action_Required_Icon__c != NULL){
                actionVal = restCheck.Action_Required_Icon__c;
            }            
            String resubmitId = 'Resubmit ID Documents';
            String onlineNotary = 'Online Notary Confirmation';
            String notarizeId = 'Notarize ID Form';
            String resubmitNotarize = 'Resubmit Notarized ID Form';
            String onlineNotarySession = 'Online Notary Session Links';            
            if(actionVal.contains('Yes')){
                returnVal = 'Yes';
            }
            else if(actionVal.contains(resubmitId)){
                returnVal = resubmitId;
            }
            else if(actionVal.contains(onlineNotary)){
                returnVal = onlineNotary;
            }
            else if(actionVal.contains(notarizeId)){
                returnVal = notarizeId;
            }
            else if(actionVal.contains(resubmitNotarize)){
                returnVal = resubmitNotarize;
            }
            else if(actionVal.contains(onlineNotarySession)){
                returnVal = onlineNotarySession;
            }
        }  
        return returnVal;
    }

    //get azure url for asset summary record type - Account Establishment Applicant Summary
    @AuraEnabled
    public static string getIdentityVerifSummaryAsset(Id caseId){
        try{
            String strAzureURL ='';
            List<Asset> applicantSummaryLst = [SELECT Id, Name, Azure_Storage_URL__c FROM Asset WHERE Case__c =: caseId AND Type__c = 'Application Summary' AND Status = 'Accepted' WITH SECURITY_ENFORCED LIMIT 1];
            if(applicantSummaryLst.size() > 0){
                strAzureURL = applicantSummaryLst[0].Azure_Storage_URL__c;
            }
            return strAzureURL;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static void createAppBioPendingSubCase(){
    Contact con = getContact();
    String caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Applicant Biographic Change').getRecordTypeId();
    String caseQueueGroupId = null;
    List<Group> groups = new List<Group>();
    groups = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Notifications Queue'];
    if(groups.isEmpty()){
        throw new CommunityException('Could not find Biographic Change Queue for Case.');
    }else{
        caseQueueGroupId = groups[0].Id;
    }
    List<Case> appPendingSubCase = new List<Case>();
    try{
        appPendingSubCase = [SELECT Id FROM Case WHERE ContactId =: con.Id AND Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION AND RecordTypeId =: caseRecordTypeId WITH SECURITY_ENFORCED];
    }catch(Exception e){
        appPendingSubCase = new List<Case>();
    }
    if(appPendingSubCase.isEmpty()){
        Case c = new Case();
        c.ContactId = con.Id;
        c.RecordTypeId = caseRecordTypeId;
        c.Internal_Status__c = Constants.CASE_STATUS_PENDING_SUBMISSION;
        c.OwnerId = caseQueueGroupId;
        insert c;
    }
    }

    @AuraEnabled
    public static Contact_Staging__c checkAndGetCSAssosiated(){
        Contact con = getContact();
        String caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Applicant Biographic Change').getRecordTypeId();
        List<Case> pendingSubCase = new List<Case>();
        try{
            pendingSubCase = [SELECT Id FROM Case WHERE ContactId =: con.Id AND Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION AND RecordTypeId =: caseRecordTypeId WITH SECURITY_ENFORCED];
        }catch(Exception e){
            pendingSubCase = new List<Case>();
        }
        if(!pendingSubCase.isEmpty()){
            String caseId = pendingSubCase[0].Id;
            List<Contact_Staging__c> catsList = new List<Contact_Staging__c>();
            catsList = [SELECT Case__c, Contact__c, Date_of_Birth__c, First_Name__c, Gender__c, Generational_Suffix__c, Id,Last_Name__c,
            Legal_Name_Consists_of_One_Name_Only__c, Name, National_Identification__c, National_ID_Country__c, Native_Language__c,
            Other_Languages_Spoken__c, Other_Native_Language__c, Passport_Country__c, Passport_Expiration__c, Passport_Issue_Date__c,
            Passport_Number__c, Previous_License__c, Reason_for_Change__c, RecordTypeId, T_C_Agreement__c, US_Social_Security__c
            FROM Contact_Staging__c WHERE Case__c =: caseId ORDER BY CreatedDate DESC];
            if(!catsList.isEmpty()){
                return catsList[0];
            }else{
                return null;
            }
        }else{
            return null;
        }
    }
    // Method to update Applicant Biographic Change status as Pending Review
    @AuraEnabled
    public static Boolean updateAppBioCaseStatus(){
        try{
            Id appBioChangeReqRecordTypeId = Constants.APP_BIO_CHANGE_RDTYPEID;
            List<Case> caseList = [SELECT Id, Internal_Status__c, CaseNumber FROM Case WHERE ContactId =: getRunningContactId() AND Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION
                                   AND RecordTypeId =: appBioChangeReqRecordTypeId WITH SECURITY_ENFORCED];
            for(Case cse : caseList){
                cse.Internal_Status__c = Constants.CASE_STATUS_PENDING_REVIEW;
            }
            if(Schema.sObjectType.Case.isUpdateable()){
                UPDATE caseList;
            }
            return true;
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }       
    }
}