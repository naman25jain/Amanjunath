public with sharing class CommunityIdentityVerificationController{
    Static final String RECORD_TYPE_EXCEPTION = 'Could not find record type named Marked for Deletion for Asset.';
    @AuraEnabled
    public static List<Case> getCaseList(String caseRecordType, String caseService){
        String contactId = getRunningContactId();
        return [Select Id, Case_Status__c, Internal_Status__c, Service__c, External_Status__c, Action_Required__c FROM Case WHERE RecordType.Name = :caseRecordType AND ContactId = :contactId AND Service__c = :caseService ORDER BY CreatedDate DESC];
    }
    @AuraEnabled
    public static List<Case> getLatestCase(String service){
        String contactId = getRunningContactId();
        return [Select Id, Case_Status__c, Internal_Status__c, Service__c, Action_Required__c, ValidationPassed_Biographics__c, ValidationPassed_AdditionalInformation__c FROM Case WHERE ContactId = :contactId AND Service__c = :service ORDER BY CreatedDate DESC];
    }
    @AuraEnabled
    public static List<Case> getAllCases(){
        String contactId = getRunningContactId();
        return [Select Id, Case_Status__c, Internal_Status__c, Service__c, RecordType.Name, Payment_Made__c FROM Case WHERE ContactId = :contactId ORDER BY CreatedDate DESC];
    }
    @AuraEnabled
    public static Boolean checkIdentityVerification(){ //returns false if Identity Verification has not been completed
        String contactId = getRunningContactId();
        List<Asset> aL = [Select Id FROM Asset WHERE Status = 'Verified' AND Product2.Family = 'Identity' AND ContactId = :contactId];
        if(aL.size()>0){
            return true;
        }
        return false;
    }
    @AuraEnabled
    public static String checkIdentityVerification_v2(){
        String contactId = getRunningContactId();
        String result = 'Not Started';
        List<Case> cL = [Select Id, CaseNumber, Internal_Status__c FROM Case WHERE Asset.Product2.ProductCode = 'Identity' AND ContactId = :contactId];
        for(Case c : cL){
            if(c.Internal_Status__c=='Completed'){
                result = 'Completed';
                break;
            } 
            else if(c.Internal_Status__c=='In Progress'){
                result = 'In Progress';
            } 
            else if(c.Internal_Status__c=='Rejected'&&result=='Not Started'){
                result = 'Rejected';
            } 
            else if(result=='Not Started'){
                result = c.Internal_Status__c;
            }
        }
        return result;
    }
    @AuraEnabled
    public static String getDisplayLabel(String recId){
        Product2 p = [Select Name FROM Product2 WHERE Id = :recId];
        if(p!=null){
            return p.Name;
        }
        else{
            return 'UNKNOWN';
        }
    }
    @AuraEnabled
    public static String getRunningUserId(){
        return (String)UserInfo.getUserId();
    }
    @AuraEnabled
    public static Boolean getPrivacyAgreementAccepted(){
        String userId = (String)UserInfo.getUserId();
        User u = [Select Id, privacyAgreementAcceptedDate__c FROM User WHERE Id = :userId];
        if(u.privacyAgreementAcceptedDate__c != null && u.privacyAgreementAcceptedDate__c < System.now()){
            return true;
        }
        else{
            return false;
        }
    }
    @AuraEnabled
    public static void setPrivacyAgreementAccepted(){
        String userId = (String)UserInfo.getUserId();
        User u = [Select Id, privacyAgreementAcceptedDate__c FROM User WHERE Id = :userId];
        u.privacyAgreementAcceptedDate__c = System.now();
        update u;
    }
    @AuraEnabled
    public static String checkEPIC(){
        String contactId = getRunningContactId();
        String result = 'Not Started';
        List<Case> cL = [Select Id, CaseNumber, Internal_Status__c FROM Case WHERE Asset.Product2.ProductCode = 'EPIC' AND ContactId = :contactId];
        for(Case c : cL){
            if(c.Internal_Status__c == 'Completed'){
                result = 'Completed';
                break;
            }
            else if(c.Internal_Status__c == 'In Progress'){
                result = 'In Progress';
            }
            else if(c.Internal_Status__c == 'Rejected' && result == 'Not Started'){
                result = 'Rejected';
            }
            else if(result == 'Not Started'){
                result = c.Internal_Status__c;
            }
        }
        return result;
    }
    @AuraEnabled
    public static String checkCERT(){
        String contactId = getRunningContactId();
        String result = 'Not Started';
        List<Case> cL = [Select Id, CaseNumber, Internal_Status__c FROM Case WHERE Asset.Product2.ProductCode = 'Credential Review' AND ContactId = :contactId];
        for(Case c : cL){
            if(c.Internal_Status__c == 'Completed'){
                result = 'Completed';
                break;
            } 
            else if(c.Internal_Status__c == 'In Progress'){
                result = 'In Progress';
            }
            else if(c.Internal_Status__c == 'Rejected' && result == 'Not Started'){
                result = 'Rejected';
            }
            else if(result == 'Not Started'){
                result = c.Internal_Status__c;
            }
        }
        return result;
    }
    @AuraEnabled
    public static String checkGEMX(){
        String contactId = getRunningContactId();
        String result = 'Not Started';
        List<Case> cL = [Select Id, CaseNumber, Internal_Status__c FROM Case WHERE Asset.Product2.ProductCode = 'GEMx' AND ContactId = :contactId];
        for(Case c : cL){
            if(c.Internal_Status__c == 'Completed'){
                result = 'Completed';
                break;
            }
            else if(c.Internal_Status__c == 'In Progress'){
                result = 'In Progress';
            } 
            else if(c.Internal_Status__c == 'Rejected' && result == 'Not Started'){
                result = 'Rejected';
            }
            else if(result == 'Not Started'){
                result = c.Internal_Status__c;
            }
        }
        return result;
    } 
    @AuraEnabled
    public static String checkJ1(){
        String contactId = getRunningContactId();
        String result = 'Not Started';
        List<Case> cL = [Select Id, CaseNumber, Internal_Status__c FROM Case WHERE RecordType.Name = 'J1 Invitation' AND ContactId = :contactId];
        for(Case c : cL){
            if(c.Internal_Status__c == 'Completed'){
                result = 'Completed';
                break;
            } 
            else if(c.Internal_Status__c == 'In Progress'){
                result = 'In Progress';
            } 
            else if(c.Internal_Status__c == 'Rejected' && result == 'Not Started'){
                result = 'Rejected';
            } 
            else if(c.Internal_Status__c == 'Submitted'){
                result = c.Internal_Status__c;
            }
        }
        return result;
    }
    @AuraEnabled
    public static void makePayment(){
        String contactId = getRunningContactId();        
        Contact contactRecord = [SELECT Id, Service_in_CommunityPayment__c FROM Contact WHERE Id =: contactId WITH SECURITY_ENFORCED];
        String service = contactRecord.Service_in_CommunityPayment__c;
        Set<Id> caseIds = new Set<Id>();
        List<Case> cL = [SELECT Id, Internal_Status__c, Payment_Made__c FROM Case where Service__c = :service AND ContactId = :contactId ORDER BY CreatedDate DESC];
        if(!cL.isEmpty()){
            for(Case c : cL){
                if(!c.Payment_Made__c){
                    c.Payment_Made__c = true;
                }
                if(c.Internal_Status__c == getIdVerificationCaseUnpaidStatus()){
                    c.Internal_Status__c = getIdVerificationCasePaidStatus();
                }
                caseIds.add(c.Id);
            }
            update cL;
            List<Asset> aL = [Select Id, Type__c, Name, Status FROM Asset WHERE Case__c IN :caseIds AND Status IN ('In Progress','Verified')];
            List<Id> asstIds = new List<Id>();
            for(Asset a : aL){
                asstIds.add(a.Id);
            }
            List<Affirmation__c> afL = new List<Affirmation__c>();
            List<Affirmation__c> affrList = [Select Id, Asset__c  FROM Affirmation__c where Asset__c in:asstIds];
            Map<Id,Id> asset2Affr = new Map<Id,Id>();
            for(Affirmation__c a : affrList){
                asset2Affr.put(a.Asset__c,a.Id);
            }
            for(Asset a : aL){
                if(asset2Affr.get(a.Id) == null){
                    Affirmation__c af = new Affirmation__c(Asset__c = a.Id, Status__c = 'In Progress' );
                    if(a.Name == 'Photo'){
                        af.RecordTypeId = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get('Photo').getRecordTypeId();
                        afL.add(af);
                    } 
                    else if(a.Name == 'Passport'){
                        af.RecordTypeId = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get('Passport').getRecordTypeId();
                        afL.add(af);
                    }
                }   
            }
            insert afL;
            generateAccEstablshmtSummaryPDF(cL[0].Id);
        }
    }
    @AuraEnabled
    public static Boolean paymentMade(String service){
        updateServiceInContact(service);
        // ensure we have a service
        service = getNullSafeService(service);
        String contactId = getRunningContactId();
        List<Case> cL = [SELECT Id, Internal_Status__c, Payment_Made__c FROM Case where Service__c = :service AND ContactId = :contactId ORDER BY CreatedDate DESC];
        for(Case c : cL){
            if(c.Payment_Made__c){
                return true;
            }
        }
        return false;
    }
    // Update Service in Contact object to avoid to passing parameter in makePayment method in CommunityIdentityVerificationController
    @AuraEnabled
    public static void updateServiceInContact(String service){
        String contactId = getRunningContactId();
        Contact contactObj = new Contact();
        contactObj.Id = contactId;
        contactObj.Service_in_CommunityPayment__c = service;
        if(Contact.SObjectType.getDescribe().isUpdateable()){
            update contactObj;
        }
    }
    @AuraEnabled
    public static List<ContentDocumentLink> getFiles(String recId){
        List<ContentDocumentLink> cdL = [SELECT ContentDocument.Title,ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :recId AND (ContentDocument.Title = 'Photo' OR ContentDocument.Title = 'Passport' OR ContentDocument.Title = 'Expiration' OR ContentDocument.Title = 'Translation') ORDER BY SystemModstamp DESC];
        return cdL;
    }
    @AuraEnabled
    public static List<ContentVersion> getFilesByVersion(String recId){
        Set<Id> cdIDs = new Set<Id>();
        List<ContentDocumentLink> cdL = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recId ORDER BY SystemModstamp DESC];
        for(ContentDocumentLink l : cdL){
            cdIDs.add(l.ContentDocumentId);
        }
        List<ContentVersion> cvL = [SELECT ContentDocumentId, Document_Type__c FROM ContentVersion WHERE ContentDocumentId IN :cdIDs];
        return cvL;
    }
    @AuraEnabled
    public static List<ContentDocumentLink> getCurrentAssetFiles(String serviceName){
        String contactId = getRunningContactId();
        List<ContentDocumentLink> cdL = new List<ContentDocumentLink>();
        List<Case> caseL = [Select Id FROM Case WHERE ContactId = :contactId AND Service__c = :serviceName ORDER BY CreatedDate DESC];
        if(caseL.size()>0){
            cdL = [SELECT ContentDocument.Title,ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :caseL[0].Id AND (ContentDocument.Title = 'Photo' OR ContentDocument.Title = 'Passport' OR ContentDocument.Title = 'Expiration' OR ContentDocument.Title = 'Translation' OR ContentDocument.Title = 'Notarized ID Form') ORDER BY SystemModstamp DESC];
        }
        return cdL;
    }
    @AuraEnabled
    public static List<ContentVersion> getCurrentAssetFilesVersion(String serviceName){
        String contactId = getRunningContactId();
        Set<Id> cdIDs = new Set<Id>();
        List<ContentDocumentLink> cdL = new List<ContentDocumentLink>();
        List<ContentVersion> cvL = new List<ContentVersion>();
        List<Case> caseL = [Select Id FROM Case WHERE ContactId = :contactId AND Service__c = :serviceName ORDER BY CreatedDate DESC];
        if(caseL.size()>0){
            cdL = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :caseL[0].Id ORDER BY SystemModstamp DESC];
            for(ContentDocumentLink d : cdL){
                cdIDs.add(d.ContentDocumentId);
            }
            cvL = [SELECT ContentDocumentId, Document_Type__c FROM ContentVersion WHERE ContentDocumentId IN :cdIDs];
        }
        return cvL;
    }
    @AuraEnabled
    public static void removeFile(String fileId){
        ContentDocument cd = [select Id from ContentDocument where Id = :fileId];
        delete cd;
        List<ContentDocumentLink> cdls = [select Id from ContentDocumentLink where ContentDocumentId = :fileId];
        delete cdls;
    }
    @AuraEnabled
    public static Contact getContactWithRecordType(){
        String contactId = getRunningContactId();
        return [
                SELECT
                        Other_Languages_Spoken__c,
                        Ethnicity__c,
                        Permanent_US_Resident__c,
            			PR_Year_Issued__c,
                        Native_Language__c,
                        Currently_Employed__c,
                        Previous_EICS_ID__c,
                        Current_Citizenship__c,
                        Passport_Photo_Is_In_English__c,
                        Passport_Photo_Includes_Expiration_Date__c,
                        Citizenship_at_Birth__c,
                        Birthdate,
                        Applicant_Provided_EPIC_ID__c,
                        FirstName,
                        Gender__c,
                        Generational_Suffix__c,
                        Id,
                        LastName,
                        MailingAddress,
                        MailingCity,
                        MailingCountry,
                        MailingCountryCode,
                        MailingPostalCode,
                        MailingState,
                        MailingStateCode,
                        MailingStreet,
                        Name,
                        Passport_Country__c,
                        Passport_Expiration__c,
                        Passport_Number__c,
                        Phone,
                        Applicant_Provided_USMLE_ID__c,
                        legal_name_consists_of_one_name_only__c,
                        Birth_City__c,
                        Birth_Country__c,
                        Citizenship_Upon_Entering_Medical_School__c,
                        Birth_State_Province__c,
                        Passport_Issue_Date__c,
                        Phone_Type__c,
                        Previous_EPIC_Services__c,
                        Previous_ECFMG_Cert_or_Examination__c,
                        RecordType.Name, // karl assured me there will always be a record type
                        ECFMG_ID__c
                FROM
                        Contact
                WHERE
                        Id = :contactId];
    }
    @AuraEnabled
    public static Contact getContact(){
        String contactId = getRunningContactId();
        return [
                SELECT
                        Other_Languages_Spoken__c,
                        Ethnicity__c,
                        Permanent_US_Resident__c,
            			PR_Year_Issued__c,
                        Native_Language__c,
                        Currently_Employed__c,
                        Previous_EICS_ID__c,
                        Current_Citizenship__c,
                        Passport_Photo_Is_In_English__c,
                        Passport_Photo_Includes_Expiration_Date__c,
                        Citizenship_at_Birth__c,
                        Birthdate,
                        Applicant_Provided_EPIC_ID__c,
                        FirstName,
                        Gender__c,
                        Generational_Suffix__c,
                        Id,
                        LastName,
                        MailingAddress,
                        MailingCity,
                        MailingCountry,
                        MailingCountryCode,
                        MailingPostalCode,
                        MailingState,
                        MailingStateCode,
                        MailingStreet,
                        Name,
                        Passport_Country__c,
                        Passport_Expiration__c,
                        Passport_Number__c,
                        Phone,
                        Applicant_Provided_USMLE_ID__c,
                        legal_name_consists_of_one_name_only__c,
                        Birth_City__c,
                        Birth_Country__c,
                        Citizenship_Upon_Entering_Medical_School__c,
                        Birth_State_Province__c,
                        Passport_Issue_Date__c,
                        Phone_Type__c,
                        Previous_EPIC_Services__c,
                        Previous_ECFMG_Cert_or_Examination__c,
                        ECFMG_ID__c,
                        EPIC_ID__c,
                        EICS_ID__c,
                        USMLE_ID__c,
                        Email,
            			Other_Native_Language__c,
            			Additional_Languages_Spoken__c
                FROM
                        Contact
                WHERE
                        Id = :contactId];        
    }
    @AuraEnabled
    public static List<Case> getContactDetailsUpdateCases(Boolean isClosed){
        List<Case> cL = [SELECT Id, CaseNumber, Internal_Status__c FROM Case WHERE isClosed = :isClosed AND RecordType.Name = 'Applicant Contact Details Update'];
        return cL;
    }
    @AuraEnabled
    public static List <String> getCountries(){
        List <String> allCountryMetadata = new List<String>();
        // Get citizenship at birth countries
        Schema.DescribeFieldResult fieldResult = Contact.Citizenship_at_Birth__c.getDescribe();
        Schema.sObjectField field = fieldResult.getSObjectField();
        List<PicklistEntry> entries = field.getDescribe().getPicklistValues();
        for(PicklistEntry pe : entries){
            allCountryMetadata.add(pe.label);
        }
        // Add delimiter entry
        allCountryMetadata.add('break1');
        // Get citizenship upon entering medical school countries
        fieldResult = Contact.Citizenship_Upon_Entering_Medical_School__c.getDescribe();
        field = fieldResult.getSObjectField();
        entries = field.getDescribe().getPicklistValues();
        for(PicklistEntry pe : entries){
            allCountryMetadata.add(pe.label);
        }
        // add delimiter entry
        allCountryMetadata.add('break2');
        // get current citizenship countries
        fieldResult = Contact.Current_Citizenship__c.getDescribe();
        field = fieldResult.getSObjectField();
        entries = field.getDescribe().getPicklistValues();
        for(PicklistEntry pe : entries){
            allCountryMetadata.add(pe.label);
        }
        // add delimiter entry
        allCountryMetadata.add('break3');
        // get birth countries
        fieldResult = Contact.Birth_Country__c.getDescribe();
        field = fieldResult.getSObjectField();
        entries = field.getDescribe().getPicklistValues();
        for(PicklistEntry pe : entries){
            allCountryMetadata.add(pe.label);
        }
        return allCountryMetadata;
    }
    @AuraEnabled
    public static Association__c getEmployer(){
        String contactId = getRunningContactId();
        List<Association__c> aL = [
                SELECT
                        Id,
                        Street__c,
                        City__c,
                        State_Code__c,
                        Postal_Code__c,
                        Country_Code__c,
                        Applicant__c,
                        Start_Month__c,
                        Start_Year__c,
                        End_Month__c,
                        End_Year__c,
                        Dicipline__c,
                        Name,
                        RecordTypeId,
                        Supervising_Physician__c,
                        Title__c,
                        Type__c
                FROM
                        Association__c
                WHERE
                        Applicant__c = :contactId
                        AND RecordType.Name = 'Employment'];
        if(aL.size() > 0){
            return aL[0];
        }
        String recordTypeId = [select Id from RecordType where SobjectType = 'Association__c' and Name = 'Employment'][0].Id;
        //code commented by Shailaja. 9/25/2020. Date Format story.
        //return new Association__c(Applicant__c=contactId,Street__c='',City__c='',Country_Code__c='',State_Code__c='',Postal_Code__c='',Date_From__c=null,RecordTypeId = recordTypeId,Title__c='',Type__c='');
        return new Association__c(Applicant__c=contactId,Street__c='',City__c='',Country_Code__c='',State_Code__c='',Postal_Code__c='',Start_Month__c='',Start_Year__c='',RecordTypeId = recordTypeId,Title__c='',Type__c='');
    }
    @AuraEnabled
    public static List<Association__c> getClerkships(){
        String contactId = getRunningContactId();
        List<Association__c> aL = new List<Association__c>();
            aL = [SELECT Id,
                    Name,
                    RecordTypeId,
                    Applicant__c,
                    Start_Month__c,
                    Start_Year__c,
                    End_Month__c,
                    End_Year__c,
                    Dicipline__c,
                    Supervising_Physician__c,
                    Title__c,
                    Type__c,
                    Street__c,
                    City__c,
                    State_Code__c,
                    Postal_Code__c,
                    Country_Code__c
            FROM Association__c
            WHERE
                    Applicant__c = :contactId
                    AND RecordType.Name = 'Clerkship'];
        return aL;
    }
    /* TODO: factor out */
    @AuraEnabled
    public static String getContactId(){
        return getRunningContactId();
    }
    @AuraEnabled
    public static List<Case> getCaseNumberForPayment(String serviceType){
        Id currentContact = getRunningContactId();
        String status = getIdVerificationCaseUnpaidStatus();
        List <Case> c =
            [
                    Select
                            id,
                            Internal_Status__c,
                            contactId,
                            Service__c,
                            caseNumber,
                            createdDate
                    From
                            Case
                    WHERE
                        contactId = :currentContact
                        AND Internal_Status__c = :status
                        AND service__c = :serviceType
                    ORDER By createdDate DESC Limit 1];
        return c;
    }
    @AuraEnabled
    public static void updateFile(String cdId, String newName){
        ContentDocument d = [Select Id, Title FROM ContentDocument WHERE Id = :cdId];
        d.Title = newName;
        update d;
        List<ContentVersion> cvL = [Select Id, Document_Type__c FROM ContentVersion WHERE ContentDocumentId = :cdId];
        for(ContentVersion v : cvL){
            //v.File_Type__c = newName;
        }
        update cvL;
    }
    @AuraEnabled
    public static String updateContact(String contactId, String contactJSON){
        JSONParser parser = JSON.createParser(contactJSON);
        Contact c = new Contact();
        if(!contactJSON.contains('Generational_Suffix__c')){
            c.put('Generational_Suffix__c', '');
        }
        while(parser.nextToken()!=null){
            String fieldName = parser.getText();
            if(fieldName.contains('{')||fieldName.contains('}')){
                parser.nextToken();
                fieldName = parser.getText();
            }
            parser.nextToken();
            if(fieldName=='ECFMG_ID__c'){
                // do nothing
            }else if(fieldName=='legal_name_consists_of_one_name_only__c'){
                Boolean fieldValue = parser.getBooleanValue();
                c.put(fieldName, fieldValue);
            }else if(fieldName == 'Previous_EICS_ID__c' || fieldName == 'Passport_Photo_Is_In_English__c' || fieldName == 'Passport_Photo_Includes_Expiration_Date__c' || fieldName == 'Previous_EPIC_Services__c' || fieldName == 'Previous_ECFMG_Cert_or_Examination__c'){
                String fieldValue = parser.getText();
                c.put(fieldName, Boolean.valueOf(fieldValue));
            }else if((fieldName == 'Passport_Issue_Date__c' || fieldName == 'Passport_Expiration__c' || fieldName == 'Birthdate') && parser.getText() != null && parser.getText() != ''){
                if(parser.getText() == null || parser.getText() == 'null'){
                    c.put(fieldName, null);
                }else{
                    Date fieldValue = parser.getDateValue();
                    c.put(fieldName, fieldValue);
                }
            }else if(fieldName == 'Applicant_Provided_USMLE_ID__c'){
                // JIRA #B2-272: Applicant Provided USMLE ID and APPLICANT Provided EPIC ID should not be cleared.
                String fieldValue = parser.getText();
                //#Bugfix- 15084. If the value is blank.
                if(fieldValue != null){
                    c.put(fieldName, fieldValue);
                }
            }else if(fieldName == 'Applicant_Provided_EPIC_ID__c'){
                // JIRA #B2-272: Applicant Provided USMLE ID and APPLICANT Provided EPIC ID should not be cleared.
                String fieldValue = parser.getText();
                if(fieldValue != null && fieldValue != ''){
                    c.put(fieldName, fieldValue);
                }
            }else if((fieldName == 'Passport_Issue_Date__c'  || fieldName == 'Passport_Expiration__c') && (parser.getText() == null || parser.getText() == '')){
                c.put(fieldName, null);
            }else if(fieldName != 'MailingAddress' && fieldName != 'street' && fieldName != 'city' && fieldName != 'stateCode' && fieldName != 'state' && fieldName != 'postalCode'  && fieldName != 'country' && fieldName != 'countryCode' && fieldName != 'Name' && fieldName != null){
                String fieldValue = parser.getText();
                c.put(fieldName, fieldValue);
            }
        }
        update c;
        return contactJSON;
    }
    @AuraEnabled
    public static void createCaseAndAssets(String photoId, String passportId, String passportExpirationId, String passportTranslationId, String service){
        String contactId = getRunningContactId();
        String accountId = [select AccountId from Contact where id = :contactId][0].AccountId;
        Set<Id> caseIds = new Set<Id>();
        Set<Id> assetIds = new Set<Id>();
        Set<Id> cdIds = new Set<Id>();
        cdIds.add(photoId);
        cdIds.add(passportId);
        cdIds.add(passportExpirationId);
        cdIds.add(passportTranslationId);
        List<ContentDocumentLink> removeL = new List<ContentDocumentLink>();
        List<ContentDocumentLink> delL = [SELECT Id,LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN :cdIds];
        for(ContentDocumentLink l : delL){
            String parentId = (String)l.LinkedEntityId;
            if(parentId.startsWith('02i') || parentId.startsWith('500')){
                removeL.add(l);
            }
        }
        delete removeL;
        List<Asset> aL = [Select Id,Status,Case__c,Case__r.Id,Name FROM Asset WHERE (Product2.Name = 'Photo' OR Product2.Name = 'Passport') AND ContactId = :contactId AND Case__r.Service__c = :service AND Status IN ('In Progress','Verified')];
        for(Asset a : aL){
            caseIds.add(a.Case__c);
            assetIds.add(a.Id);
        }
        List<Case> cL = [Select Id, Internal_Status__c, Type FROM Case WHERE ContactId = :contactId AND Id IN :caseIds];
        if(aL.size() == 0){
            Case c = new Case(
                                ContactId = contactId,
                                Internal_Status__c = getIdVerificationCaseUnpaidStatus(),
                                OwnerId = getIdVerificationCaseQueueId(),
                                Origin = 'Web',
                                Service__c = service);
            insert c;
            if(photoId != null && photoId != ''){
                Asset a = new Asset(
                        Name = 'Photo',
                        Type__c = 'Photo',
                        Status = 'In Progress',
                        Product2Id = getPhotoProductId(),
                        Quantity = 1,
                        ContactId = contactId,
                        Case__c = c.Id,
                        RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Identity').getRecordTypeId()
                );
                insert a;
                ContentDocumentLink cdl = new ContentDocumentLink(  ContentDocumentId = photoId,
                                                                    LinkedEntityId = a.Id,
                                                                    ShareType = 'I',
                                                                    Visibility = 'AllUsers');
                insert cdl;
                cdl = new ContentDocumentLink(  ContentDocumentId = photoId,
                                                                    LinkedEntityId = c.Id,
                                                                    ShareType = 'I',
                                                                    Visibility = 'AllUsers');
                insert cdl;
            }
            if(passportId != null && passportId != ''){
                Asset a = new Asset(
                        Name = 'Passport',
                        Type__c = 'Passport',
                        Status = 'In Progress',
                        Product2Id = getPassportProductId(),
                        Quantity = 1,
                        ContactId = contactId,
                        Case__c = c.Id,
                        RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Identity').getRecordTypeId()
                );
                insert a;
                ContentDocumentLink cdlA = new ContentDocumentLink( ContentDocumentId = passportId,
                                                                    LinkedEntityId = a.Id,
                                                                    ShareType = 'I',
                                                                    Visibility = 'AllUsers');
                insert cdlA;
                ContentDocumentLink cdlB = new ContentDocumentLink( ContentDocumentId = passportId,
                                                LinkedEntityId = c.Id,
                                                ShareType = 'I',
                                                Visibility = 'AllUsers');
                insert cdlB;
                if(passportExpirationId != null && passportExpirationId != ''){
                    ContentDocumentLink cdl = new ContentDocumentLink(  ContentDocumentId = passportExpirationId,
                                                                        LinkedEntityId = a.Id,
                                                                        ShareType = 'I',
                                                                        Visibility = 'AllUsers');
                    insert cdl;
                    cdl = new ContentDocumentLink(  ContentDocumentId = passportExpirationId,
                                                    LinkedEntityId = c.Id,
                                                    ShareType = 'I',
                                                    Visibility = 'AllUsers');
                    insert cdl;
                }
                if(passportTranslationId != null && passportTranslationId != ''){
                    ContentDocumentLink cdl = new ContentDocumentLink(  ContentDocumentId = passportTranslationId,
                                                                        LinkedEntityId = a.Id,
                                                                        ShareType = 'I',
                                                                        Visibility = 'AllUsers');
                    insert cdl;
                    cdl = new ContentDocumentLink(  ContentDocumentId = passportTranslationId,
                                                    LinkedEntityId = c.Id,
                                                    ShareType = 'I',
                                                    Visibility = 'AllUsers');
                    insert cdl;
                }
            }
        }
        else if(aL.size() > 0 && caseIds.size() > 0){
            List<ContentDocumentLink> cdlL = [Select Id FROM ContentDocumentLink WHERE LinkedEntityId IN :assetIds];
            List<ContentDocumentLink> docsToInsert = new List<ContentDocumentLink>();
            delete cdlL;
            cdlL = [Select Id FROM ContentDocumentLink WHERE LinkedEntityId IN :caseIds];
            delete cdlL;
            for(Asset a : aL){
                if(photoId != null && photoId != '' && a.Name == 'Photo'){
                    ContentDocumentLink cdl = new ContentDocumentLink(  ContentDocumentId = photoId,
                                                                        LinkedEntityId = a.Id,
                                                                        ShareType = 'I',
                                                                        Visibility = 'AllUsers');
                    docsToInsert.add(cdl);
                }
                if(passportId != null && passportId != '' && a.Name == 'Passport'){
                    ContentDocumentLink cdlA = new ContentDocumentLink( ContentDocumentId = passportId,
                                                                        LinkedEntityId = a.Id,
                                                                        ShareType = 'I',
                                                                        Visibility = 'AllUsers');
                    docsToInsert.add(cdlA);
                }
                if(passportExpirationId != null && passportExpirationId != '' && a.Name == 'Passport'){
                    ContentDocumentLink cdl = new ContentDocumentLink(  ContentDocumentId = passportExpirationId,
                                                                        LinkedEntityId = a.Id,
                                                                        ShareType = 'I',
                                                                        Visibility = 'AllUsers');
                    docsToInsert.add(cdl);
                }
                if(passportTranslationId != null && passportTranslationId != '' && a.Name == 'Passport'){
                    ContentDocumentLink cdl = new ContentDocumentLink(  ContentDocumentId = passportTranslationId,
                                                                        LinkedEntityId = a.Id,
                                                                        ShareType = 'I',
                                                                        Visibility = 'AllUsers');
                    docsToInsert.add(cdl);
                }
            }
            for(Id c : caseIds){
                if(photoId != null && photoId != ''){
                    ContentDocumentLink cdl = new ContentDocumentLink(  ContentDocumentId = photoId,
                                                                        LinkedEntityId = c,
                                                                        ShareType = 'V',
                                                                        Visibility = 'AllUsers');
                    docsToInsert.add(cdl);
                }
                if(passportId != null && passportId != ''){
                    ContentDocumentLink cdlB = new ContentDocumentLink( ContentDocumentId = passportId,
                                                    LinkedEntityId = c,
                                                    ShareType = 'I',
                                                    Visibility = 'AllUsers');
                    docsToInsert.add(cdlB);
                }
                if(passportExpirationId!=null && passportExpirationId!=''){
                    ContentDocumentLink cdl = new ContentDocumentLink(  ContentDocumentId = passportExpirationId,
                                                    LinkedEntityId = c,
                                                    ShareType = 'I',
                                                    Visibility = 'AllUsers');
                    docsToInsert.add(cdl);
                }
                if(passportTranslationId!=null && passportTranslationId!=''){
                    ContentDocumentLink cdl = new ContentDocumentLink(  ContentDocumentId = passportTranslationId,
                                                    LinkedEntityId = c,
                                                    ShareType = 'I',
                                                    Visibility = 'AllUsers');
                    docsToInsert.add(cdl);
                }
            } 
            insert docsToInsert;
        }
    }
    //to create identity verification case and link assets to case
    @AuraEnabled
    public static void createCaseAndAssetsV2(String service, Boolean validationPassed){
        String contactId = getRunningContactId();
        String accountId = [select AccountId from Contact where id = :contactId][0].AccountId;
        Set<Id> caseIds = new Set<Id>();
        List<Case> cL = new List<Case>();
        if(Case.SObjectType.getDescribe().isAccessible()){
            cL = [Select Id, Internal_Status__c, Type FROM Case WHERE ContactId = :contactId AND Service__c = :service ORDER BY CreatedDate DESC];
        }
        for(Case c : cL){
            c.ValidationPassed_Biographics__c = validationPassed;
            caseIds.add(c.Id);
        }
        if(Case.SObjectType.getDescribe().isUpdateable()){
            update cL;
        }
        Case c;
        if(cL.size() == 0){
            c = new Case( ContactId = contactId,
                        Internal_Status__c = getIdVerificationCaseUnpaidStatus(),
                        OwnerId = getIdVerificationCaseQueueId(),
                        Origin = 'Web',
                        Service__c = service,
                        ValidationPassed_Biographics__c = validationPassed);
            if(Case.SObjectType.getDescribe().isCreateable()){
                insert c;
            }
        } 
        else{
            c = cL[0];
        }
        if(Asset.SObjectType.getDescribe().isAccessible()){
            List<Asset> assetList = [Select Id,Status,Case__c,Case__r.Id,Name,Type__c FROM Asset WHERE (type__c = 'Photo' OR type__c = 'Passport') AND ContactId = :contactId AND Status IN ('In Progress','Verified') AND status !=:Constants.ASSET_STATUS_MARKED_FOR_DELETION];
            for(Asset asst: assetList){
                asst.Case__c = c.Id;
            }
            if(Asset.SObjectType.getDescribe().isUpdateable()){
                update assetList;
            }
        }
    }
    @AuraEnabled
    public static void resubmitIdentificationV2(String service, Boolean validationPassed){
        String contactId = getRunningContactId();
        String accountId = [select AccountId from Contact where id = :contactId][0].AccountId;
        List<Case> cL = new List<Case>();
        if(Case.SObjectType.getDescribe().isAccessible()){
            cL = [Select Id, Status, Type FROM Case WHERE ContactId = :contactId AND Service__c = :service ORDER BY CreatedDate DESC];
        }
        if(Asset.SObjectType.getDescribe().isAccessible()){
            List<Affirmation__c> afList = new List<Affirmation__c>();
            List<Asset> assetList = [Select Id,Status,Case__c,Case__r.Id,Name,Type__c FROM Asset 
                                        WHERE (Name = 'Photo' OR Name = 'Passport')
                                            AND ContactId = :contactId
                                            AND Status = :Constants.ASSET_STATUS_IN_PROGRESS];
            for(Asset asst: assetList){
                Affirmation__c afObj = new Affirmation__c();
                afObj.Asset__c      =   asst.Id;
                afObj.Status__c     =   Constants.AFFIRMATION_STATUS_IN_PROGRESS; 
                afObj.RecordTypeId  =   Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get(asst.Name).getRecordTypeId();
                afList.add(afObj);                
            }
            if(afList.size()>0){
                insert afList;
            }
        }
        // find the id review queue to set case owner
        if(Group.SObjectType.getDescribe().isAccessible()){
            List<Group> qs = [select Id from Group where Type = 'Queue' and Name = 'ID Review Queue'];
            if(qs.size()!=1){
                throw new CommunityException('Could not find ID Review Queue.');
            }
            Case c = cL[0];
            c.OwnerId = qs[0].Id;
            c.Internal_Status__c = Constants.CASE_STATUS_RESUBMITTED_PENDING_ID_REVIEW;
            c.Action_Required__c = false;
            update c;
        }       
    }
    //Code added by Shailaja Yerneni. 1/15/2021. The method handles both Identity Verification and Applicant Biographic Changes.User Story 11859
    @AuraEnabled
    public static void resubmitIdentificationV3(String service, String caseId){
        String contactId = getRunningContactId();
        String accountId = [select AccountId from Contact where id = :contactId][0].AccountId;
        List<Case> cL = new List<Case>();
        if(Case.SObjectType.getDescribe().isAccessible()){
            cL = [Select Id, Internal_Status__c, Type FROM Case WHERE ContactId = :contactId AND Id = :caseId AND Service__c = :service ORDER BY CreatedDate DESC];
        }
        if(Asset.SObjectType.getDescribe().isAccessible()){
            List<Affirmation__c> afList = new List<Affirmation__c>();
            List<Asset> assetList = [Select Id,Status,Case__c,Case__r.Id,Name,Type__c FROM Asset 
                                        WHERE (Name = 'Photo' OR Name = 'Passport')
                                            AND ContactId = :contactId
                                            AND Case__r.Id = :caseId
                                            AND Status = :Constants.ASSET_STATUS_IN_PROGRESS];
            for(Asset asst: assetList){
                Affirmation__c afObj = new Affirmation__c();
                afObj.Asset__c      =   asst.Id;
                afObj.Status__c     =   Constants.AFFIRMATION_STATUS_IN_PROGRESS; 
                afObj.RecordTypeId  =   Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get(asst.Name).getRecordTypeId();
                afList.add(afObj);                
            }
            if(afList.size()>0){
                insert afList;
            }
        }
        //Find the record type of the case. Depending on that assign the case queue and status
        Case caseRecord = [SELECT Id, RecordType.DeveloperName FROM Case WHERE Id = :caseId];
        if(caseRecord.RecordType.DeveloperName == Constants.CASE_RECORD_TYPE_IDENTITY_VERIFICATION){
            if(Group.SObjectType.getDescribe().isAccessible()){
                //new code to get the bio cahnge queue
                List<Group> qs = [select Id from Group where Type = 'Queue' and Name = 'ID Review Queue'];
                if(qs.size()!=1){
                    throw new CommunityException('Could not find ID Review Queue.');
                }
                caseRecord.OwnerId = qs[0].Id;
                caseRecord.Internal_Status__c = Constants.CASE_STATUS_RESUBMITTED_PENDING_ID_REVIEW;
                caseRecord.Action_Required__c = false;
                update caseRecord;
            }
        } 
        else if(caseRecord.RecordType.DeveloperName == Constants.CASE_RECORD_TYPE_APP_BIO_CHANGE){
            if(Group.SObjectType.getDescribe().isAccessible()){
                List<Group> qs = [select Id from Group where Type = 'Queue' and Name = 'Biographic Change Queue'];
                if(qs.size() != 1){
                    throw new CommunityException('Could not find Biographic Change Queue.');
                }
                caseRecord.OwnerId = qs[0].Id;
                caseRecord.Internal_Status__c = Constants.CASE_STATUS_PENDING_REVIEW;
                caseRecord.Action_Required__c = false;
                update caseRecord;
            }
        }
    }
    @AuraEnabled
    public static void resubmitIdentification(String photoId, String passportId, String passportExpirationId, String passportTranslationId, String service){
        String contactId = getRunningContactId();
        String accountId = [select AccountId from Contact where id = :contactId][0].AccountId;
        Set<Id> caseIds = new Set<Id>();
        Set<Id> assetIds = new Set<Id>();
        Set<Id> cdIds = new Set<Id>();
        cdIds.add(photoId);
        cdIds.add(passportId);
        cdIds.add(passportExpirationId);
        cdIds.add(passportTranslationId);
        List<ContentDocumentLink> removeL = new List<ContentDocumentLink>();
        List<ContentDocumentLink> delL = [SELECT Id,LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN :cdIds];
        for(ContentDocumentLink l : delL){
            String parentId = (String)l.LinkedEntityId;
            // case and asset
            if(parentId.startsWith('02i') || parentId.startsWith('500')){
                removeL.add(l);
            }
        }
        delete removeL;
        List<Case> caseL = [SELECT Id, Internal_Status__c, Action_Required__c FROM Case WHERE Service__c = :service AND ContactId = :contactId ORDER BY CreatedDate DESC];
        if(caseL.size()>0){
            Case c = caseL[0];
            if(photoId!=null && photoId!=''){
                Asset a = new Asset(
                        Name = 'Photo',
                        Type__c = 'Photo',
                        Status = 'In Progress',
                        Product2Id = getPhotoProductId(),
                        Quantity = 1,
                        ContactId = contactId,
                        Case__c = c.Id);
                insert a;
                Affirmation__c af1 = new Affirmation__c(Asset__c = a.Id, Status__c = 'In Progress', RecordTypeId = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByName().get('Photo').getRecordTypeId());
                insert af1;
                ContentDocumentLink cdl = new ContentDocumentLink(  ContentDocumentId = photoId,
                                                                    LinkedEntityId = a.Id,
                                                                    ShareType = 'I',
                                                                    Visibility = 'AllUsers');
                insert cdl;
                cdl = new ContentDocumentLink(  ContentDocumentId = photoId,
                                                                    LinkedEntityId = c.Id,
                                                                    ShareType = 'I',
                                                                    Visibility = 'AllUsers');
                insert cdl;
            }
            if(passportId!=null && passportId!=''){
                Asset a = new Asset(
                        Name = 'Passport',
                        Type__c = 'Passport',
                        Status = 'In Progress',
                        Product2Id = getPassportProductId(),
                        Quantity = 1,
                        ContactId = contactId,
                        Case__c = c.Id);
                insert a;
                Affirmation__c af2 = new Affirmation__c(Asset__c = a.Id, Status__c = 'In Progress', RecordTypeId = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByName().get('Passport').getRecordTypeId()); 
                insert af2;
                ContentDocumentLink cdlA = new ContentDocumentLink( ContentDocumentId = passportId,
                                                                    LinkedEntityId = a.Id,
                                                                    ShareType = 'I',
                                                                    Visibility = 'AllUsers');
                insert cdlA;
                ContentDocumentLink cdlB = new ContentDocumentLink( ContentDocumentId = passportId,
                                                LinkedEntityId = c.Id,
                                                ShareType = 'I',
                                                Visibility = 'AllUsers');
                insert cdlB;
                if(passportExpirationId != null && passportExpirationId != ''){
                    ContentDocumentLink cdl = new ContentDocumentLink(  ContentDocumentId = passportExpirationId,
                                                                        LinkedEntityId = a.Id,
                                                                        ShareType = 'I',
                                                                        Visibility = 'AllUsers');
                    insert cdl;
                    cdl = new ContentDocumentLink(  ContentDocumentId = passportExpirationId,
                                                    LinkedEntityId = c.Id,
                                                    ShareType = 'I',
                                                    Visibility = 'AllUsers');
                    insert cdl;
                }
                if(passportTranslationId!=null && passportTranslationId!=''){
                    ContentDocumentLink cdl = new ContentDocumentLink(  ContentDocumentId = passportTranslationId,
                                                                        LinkedEntityId = a.Id,
                                                                        ShareType = 'I',
                                                                        Visibility = 'AllUsers');
                    insert cdl;
                    cdl = new ContentDocumentLink(  ContentDocumentId = passportTranslationId,
                                                    LinkedEntityId = c.Id,
                                                    ShareType = 'I',
                                                    Visibility = 'AllUsers');
                    insert cdl;
                }
            }
            // find the id review queue to set case owner
            List<Group> qs = [select Id from Group where Type = 'Queue' and Name = 'ID Review Queue'];
            if(qs.size()!=1){
                 throw new CommunityException('Could not find ID Review Queue.');
            }
            c.OwnerId = qs[0].Id;
            c.Internal_Status__c = 'Resubmitted-Pending ID Review';
            c.Action_Required__c = false;
            update c;
        }
    }
    @AuraEnabled
    public static void resubmitNotary(String notaryId, String service, String caseId){
        String contactId = getRunningContactId();
        String accountId = [select AccountId from Contact where id = :contactId][0].AccountId;
        Set<Id> caseIds = new Set<Id>();
        Set<Id> assetIds = new Set<Id>();
        Set<Id> cdIds = new Set<Id>();
        cdIds.add(notaryId);
        List<ContentDocumentLink> removeL = new List<ContentDocumentLink>();
        List<ContentDocumentLink> delL = [SELECT Id,LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN :cdIds];
        for(ContentDocumentLink l : delL){
            String parentId = (String)l.LinkedEntityId;
            // case and asset
            if(parentId.startsWith('02i') || parentId.startsWith('500')){
                removeL.add(l);
            }
        }
        delete removeL;
        List<Case> caseL = new List<Case>();
        if(caseId!=null){
             caseL = [SELECT Id, Internal_Status__c, Action_Required__c FROM Case WHERE Id = :caseId ORDER BY CreatedDate DESC];
        }
        else{
            caseL = [SELECT Id, Internal_Status__c, Action_Required__c FROM Case WHERE Service__c = :service AND ContactId = :contactId ORDER BY CreatedDate DESC];
        }
        if(caseL.size()>0){
            Case c = caseL[0];
            if(notaryId != null && notaryId != ''){
                Asset a = new Asset(
                        Name = 'ID Form Notarized',
                        Type__c = 'ID Verification',
                        Status = 'In Progress',
                        Product2Id = getIdFormProductId(),
                        Quantity = 1,
                        ContactId = contactId,
                        Case__c = c.Id,
                        RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Identity').getRecordTypeId()
                );
                insert a;
                Affirmation__c af1 = new Affirmation__c(Asset__c = a.Id, Status__c = 'In Progress', RecordTypeId = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByName().get('ID_Verification').getRecordTypeId());
                insert af1;
                ContentDocumentLink cdl = new ContentDocumentLink(  ContentDocumentId = notaryId,
                                                                    LinkedEntityId = a.Id,
                                                                    ShareType = 'I',
                                                                    Visibility = 'AllUsers');
                insert cdl;
                cdl = new ContentDocumentLink(  ContentDocumentId = notaryId,
                                                                    LinkedEntityId = c.Id,
                                                                    ShareType = 'I',
                                                                    Visibility = 'AllUsers');
                insert cdl;
                ContentVersion ver = [select Id, ContentDocumentId, Document_Type__c from ContentVersion where ContentDocumentId = :notaryId];
                ver.Document_Type__c = 'Notarized ID Form';
                update ver;
            }
            c.Internal_Status__c = 'Resubmitted-Pending ID Verification Review';
            c.Action_Required__c = false;
            update c;
        }
    }       
    @AuraEnabled
    public static Boolean getTerms(String service){
        String contactId = getRunningContactId();
        List<Terms_and_Conditions_Agreement__c> aL = [SELECT Id FROM Terms_and_Conditions_Agreement__c WHERE Contact__c = :contactId AND TermsandConditions__r.Product__r.Family = :service AND TermsandConditions__r.Name = 'Certification by Applicant' AND TermsandConditions__r.Status__c = 'Active'];
        if(aL.size() > 0){
            return true;
        }
        return false;
    }
    @AuraEnabled
    public static String getPrivacyAccepted(String privacyAgreement){
        String contactId = getRunningContactId();
        List<Terms_and_Conditions_Agreement__c> aL = [SELECT Id FROM Terms_and_Conditions_Agreement__c WHERE Contact__c = :contactId AND TermsandConditions__r.Name = :privacyAgreement AND TermsandConditions__r.Status__c = 'Active'];
        if(aL.size() > 0){
            return null;
        } 
        else{
            List<Terms_and_Conditions__c> cL = [SELECT Id, Copy__c FROM Terms_and_Conditions__c WHERE Name = :privacyAgreement AND Status__c = 'Active'];
            if(cL.size()>0){
                return cL[0].Copy__c;
            }
        }
        return null;
    }
    @AuraEnabled
    public static Boolean addPrivacy(String privacyAgreement){
        String contactId = getRunningContactId();
        if(contactId!=null){
            Terms_and_Conditions__c c = [SELECT Id FROM Terms_and_Conditions__c WHERE Name = :privacyAgreement AND Status__c = 'Active'][0];
            Terms_and_Conditions_Agreement__c a = new Terms_and_Conditions_Agreement__c(Contact__c = contactId,
            TermsandConditions__c = c.Id, Name = privacyAgreement + contactId);
            insert a;
            return true;
        }
        return false;
    }
    @AuraEnabled
    public static Boolean addAgreement(String service){
        String contactId = getRunningContactId();
        if(contactId!=null){
            List<Terms_and_Conditions__c> cL = [SELECT Id FROM Terms_and_Conditions__c WHERE Name = 'Certification by Applicant' AND Product__r.Family = :service AND Status__c = 'Active'];
            if(cL.size()>0){
                Terms_and_Conditions_Agreement__c a = new Terms_and_Conditions_Agreement__c(Contact__c = contactId,
                    TermsandConditions__c = cL[0].Id, Name = 'Certification by Applicant' + contactId);
                insert a;
            }
            return true;
        }
        // TODO: why are we doing this????
        return false;
    }
    @AuraEnabled
    public static List<Case_Status_Progress_Indicator_Mapping__mdt> getProgressIndicatorMappings(){
        List<Case_Status_Progress_Indicator_Mapping__mdt> pimL = [SELECT Case_Record_Type__c, Step_Number__c, Internal_Case_Status__c, Internal_Display_Label__c, External_Case_Status__c, External_Display_Label__c, Primary_Step__c FROM Case_Status_Progress_Indicator_Mapping__mdt ORDER BY Step_Number__c, Primary_Step__c DESC];
        return pimL;
    }
    @AuraEnabled
    public static void updateAdditionalInfo(String ethnicity, String otherLanguages, String permResident, String prYearIssued, String nativeLanguage, String employed){
        String contactId = getRunningContactId();
        Contact c = [SELECT Ethnicity__c, Permanent_US_Resident__c,PR_Year_Issued__c, Other_Languages_Spoken__c, Native_Language__c, Currently_Employed__c  FROM Contact WHERE Id = :contactId];
        c.Ethnicity__c = ethnicity;
        c.Permanent_US_Resident__c = permResident;
        c.PR_Year_Issued__c = prYearIssued;
        c.Other_Languages_Spoken__c = otherLanguages;
        c.Native_Language__c = nativeLanguage;
        c.Currently_Employed__c = employed;
        update c;
    }
    @AuraEnabled
    public static void updateAdditionalInfoV2(String ethnicity, String permResident, String prYearIssued, String employed, String service, Boolean validationPassed){
        String contactId = getRunningContactId();
        Contact c = [SELECT Ethnicity__c, Permanent_US_Resident__c,PR_Year_Issued__c, Currently_Employed__c FROM Contact WHERE Id = :contactId];
        c.Ethnicity__c = ethnicity;
        c.Permanent_US_Resident__c = permResident;
        c.PR_Year_Issued__c = prYearIssued;
        c.Currently_Employed__c = employed;
        update c;
        List<Case> cL = [Select Id, ValidationPassed_AdditionalInformation__c FROM Case WHERE Service__c = :service AND ContactId = :contactId];
        for(Case cse : cL){
            cse.ValidationPassed_AdditionalInformation__c = validationPassed;
        }
        update cL;
    }
    @AuraEnabled
    public static void updateLanguageInfo(String otherLanguages, String nativeLanguage, String otherNativeLanguage, String otherLanguagesSpoken){
        String contactId = getRunningContactId();
        Contact c = [SELECT Id, Other_Languages_Spoken__c, Native_Language__c, Other_Native_Language__c, Additional_Languages_Spoken__c FROM Contact WHERE Id = :contactId];
        c.Other_Languages_Spoken__c = otherLanguages;
        c.Native_Language__c = nativeLanguage;
        c.Other_Native_Language__c = otherNativeLanguage;
        c.Additional_Languages_Spoken__c = otherLanguagesSpoken;
        update c;
    }
    @AuraEnabled
    public static void updateEmployer(String empJSON){
        String contactId = getRunningContactId();
        String recordTypeId = [select Id from RecordType where SobjectType = 'Association__c' and Name = 'Employment'][0].Id;
        Association__c a;
        List<Association__c> aL = [SELECT Id, Street__c,Applicant__c,City__c,Country_Code__c,Start_Month__c,Start_Year__c,End_Month__c,End_Year__c,Dicipline__c,Name,Postal_Code__c,RecordTypeId,State_Code__c,Supervising_Physician__c,Title__c,Type__c FROM Association__c WHERE Applicant__c = :contactId AND RecordType.Name = 'Employment'];
        if(aL.size()>0){
            a = aL[0];
        }
        else{
            a = new Association__c(RecordTypeId = recordTypeId);
        }
        JSONParser parser = JSON.createParser(empJSON);
        while(parser.nextToken()!=null){
            String fieldName = parser.getText();
            if(fieldName.contains('{') || fieldName.contains('}') || fieldName == null){
                parser.nextToken();
                fieldName = parser.getText();
            }
            parser.nextToken();
            if(fieldName == 'Date_From__c'){
                Date fieldValue = parser.getDateValue();
                a.put(fieldName, fieldValue);
            }
            else{
                String fieldValue = parser.getText();
                if(fieldName != null && fieldValue != null){
                    a.put(fieldName, fieldValue);
                }
            }
        }
        upsert a;
    }
    /* Deletes the employer (association) for the logged in user/contact. */
    @AuraEnabled
    public static void deleteEmployer(){
        String contactId = getRunningContactId();
        // get association
        List<Association__c> associations = [SELECT Id FROM Association__c WHERE Applicant__c = :contactId AND RecordType.Name = 'Employment'];
        // delete it
        delete associations;
    }
    @AuraEnabled
    public static Association__c addClerkship(String discipline, String hospitalName, String country, String street, String state, String zip, String city, String supervisor, String startMonth, String startYear, String endMonth, String endYear){
        String contactId = getRunningContactId();
        Association__c a = new Association__c(
                Applicant__c = contactId,
                Dicipline__c = discipline,
                Name = hospitalName,
                Street__c = street,
                City__c = city,
                State_Code__c = state,
                Postal_Code__c = zip,
                Country_Code__c = country,
                Supervising_Physician__c = supervisor,
                Start_Month__c = startMonth,
                Start_Year__c = startYear,
                End_Month__c = endMonth,
                End_Year__c = endYear
        );
        insert a;
        return a;
    }
    @AuraEnabled
    public static void removeClerkship(String recId){
        Association__c a = new Association__c(Id = recId);
        delete a;
    }
    @AuraEnabled
    public static Boolean caseRequiresAction(String serviceName){
        String contactId = getRunningContactId();
        List<Case> caseL = [Select Id, Action_Required__c FROM Case WHERE ContactId = :contactId AND Service__c = :serviceName ORDER BY CreatedDate DESC];
        if(caseL.size()>0 && caseL[0].Action_Required__c!=null){
            return caseL[0].Action_Required__c;                
        }
        return false;
    }
    @AuraEnabled
    public static Map<String, String> getAffirmationResults(String serviceName, String caseId){
        String contactId = getRunningContactId();
        Map<String, String> resultMap = new Map<String, String>();
        serviceName = getNullSafeService(serviceName);
        List<Case> caseL = new List<Case>();
        if(caseId!=null){
            caseL = [Select Id,RecordType.Id, RecordType.Name, Internal_Status__c,(Select Id, Name, Status FROM Assets__r  WHERE Asset.status != :constants.ASSET_STATUS_MARKED_FOR_DELETION AND Asset.status != :constants.ASSET_STATUS_IN_PROGRESS ORDER BY CreatedDate DESC) FROM Case WHERE Id = :caseId];
        }
        else{
            caseL = [Select Id,RecordType.Id, RecordType.Name, Internal_Status__c,(Select Id, Name, Status FROM Assets__r WHERE Asset.status != :constants.ASSET_STATUS_MARKED_FOR_DELETION AND Asset.status != :constants.ASSET_STATUS_IN_PROGRESS ORDER BY CreatedDate DESC) FROM Case WHERE ContactId = :contactId AND Service__c = :serviceName AND IsClosed = false AND RecordType.Name = 'Identity Verification'];
        }
        // sanity checks
        if(caseL.size() == 0){
             throw new CommunityException('Did not find any cases for affirmation processing. Should have one.');
        }
        if(caseL.size() > 1){
             throw new CommunityException('Found more than 1 case for affirmation processing. Should only have one.');
        }
        Set<Id> assetIds = new Set<Id>();
        String assetCSV = '';
        for(Case c : caseL){
            Set<String> currentTypes = new Set<String>();
            for(Asset a : c.Assets__r){
                if(currentTypes.size() == 0 || !currentTypes.contains(a.Name) && a.Status == 'Verified'){
                    currentTypes.add(a.Name);
                    assetIds.add(a.Id);
                    if(assetCSV == ''){
                        assetCSV = '\'' + a.Id + '\'';
                    }
                    else{
                        assetCSV += ',\'' + a.Id + '\'';
                    }
                }
            }
            for(Asset a : c.Assets__r){
                if(currentTypes.size() == 0 || !currentTypes.contains(a.Name)){
                    currentTypes.add(a.Name);
                    assetIds.add(a.Id);
                    if(assetCSV == ''){
                        assetCSV = '\'' + a.Id + '\'';
                    }
                    else{
                        assetCSV += ',\'' + a.Id + '\'';
                    }
                }
            }
        }
        if(assetIds.size()>0){     
                // sanity check
                if(assetCSV == '' ){
                     throw new CommunityException('Could not build a list of asset ids for affirmation processing. Verify there is at least one rejected asset.');
                }
                List<String> fieldNames = new List<String>();
                List<Affirmation_Mapping__mdt> affMapL= [SELECT DeveloperName, Expected_Answer_Picklist__c, Expected_Answer_Text__c, Label, MasterLabel, Message__c, QualifiedApiName, RecordType__c FROM Affirmation_Mapping__mdt];
                Map<String, Affirmation_Mapping__mdt> affMap = new Map<String, Affirmation_Mapping__mdt>();
                for(Affirmation_Mapping__mdt m : affMapL){
                    affMap.put(m.DeveloperName + '__c', m);
                    fieldNames.add(m.DeveloperName + '__c');
                }
                Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                Map<String, Schema.SObjectField> fieldMap = schemaMap.get('Affirmation__c').getDescribe().fields.getMap();
                String commaSepratedFields = '';
                for(String fieldName : fieldMap.keyset()){
                    if(commaSepratedFields == null || commaSepratedFields == ''){
                        commaSepratedFields = fieldName;
                    }
                    else{
                        commaSepratedFields = commaSepratedFields + ', ' + fieldName;
                    }
                }
                String query = 'select ' + commaSepratedFields + ', RecordType.Name from Affirmation__c WHERE Asset__c IN (' + assetCSV + ') ORDER BY CreatedDate ASC';
                List<Affirmation__c> affL = Database.query(query);
                for(Affirmation__c affirmation : affL){
                    for(String field : fieldNames){
                        Affirmation_Mapping__mdt mapping = affMap.get(field);
                        String val = String.valueOf(affirmation.get(field));
                        // if val is null, there was no answer provided (affirmation skipped and should not be evaluated)
                        if(val!=null){
                            // only match on same record type
                            if(affirmation.RecordType.Name==mapping.RecordType__c){
                                // use the picklist expected answer if not null
                                if(mapping.Expected_Answer_Picklist__c!=null){
                                    if(mapping.Expected_Answer_Picklist__c!=val && field!='Other_Rejection_Picklist__c' && field!='ID_Form_Acceptable_Picklist__c'){
                                        resultMap.put(affirmation.RecordType.Name + ' ' + field, mapping.Message__c);
                                    }
                                }
                                // use the text expected answer if not null
                                else if(mapping.Expected_Answer_Text__c!=null){
                                    // info: https://salesforced.wordpress.com/2012/05/16/using-the-string-split-method-with-a-pipe-delimiter/
                                    String[] splittedAnswer = mapping.Expected_Answer_Text__c.split('\\|');
                                    // single value path
                                    if(splittedAnswer.size()==1){
                                        if(splittedAnswer[0]!=val){
                                            resultMap.put(affirmation.RecordType.Name + ' ' + field, mapping.Message__c);
                                        }
                                    }
                                    // more than one value
                                    else{
                                        Boolean passes = false;
                                        for(String answer : splittedAnswer){
                                            if(answer==val){
                                                passes = true;
                                                break;
                                            }
                                        }
                                        if(passes==false){
                                            if(field=='Is_the_ID_Document_a__c' && val=='Neither' && caseL[0].RecordType.Name=='Applicant Biographic Change'){
                                                // suppress error on portal per https://ecfmgcorp.atlassian.net/browse/B2-1039
                                            }
                                            else{
                                                resultMap.put(affirmation.RecordType.Name + ' ' + field, mapping.Message__c);    
                                            }
                                        }
                                    }
                                }
                                else{
                                    throw new CommunityException('The affirmation mapping for ' + field + ' does not have an expected value.');
                                }
                            }
                            if(affirmation.Other__c!=null && affirmation.Other__c!='' && field=='Other_Rejection_Picklist__c'){
                                resultMap.put(affirmation.RecordType.Name + ' ' + field, affirmation.Other__c);
                            }
                        }
                    }
                }
        }
        return resultMap;
    }
    /* This method returns the case number for a specific case id.If none is found, returns null. */
    @AuraEnabled
    public static String getCaseNumberById(String id){
        List<Case> cases = [select Id, CaseNumber from Case where Id = :id];
        if(cases.size()==1){
            return cases[0].CaseNumber;
        }
        else{
            return null;
        }
    }
    /* This method returns the case number for the logged-in community contact by service and record type.If none is found, returns null.If more than one is found, throw exception. */
    @AuraEnabled
    public static String getCaseNumberByServiceAndRecordType(String service, String recordType){
        String contactId = getRunningContactId();
        List<Case> cases = [select Id, CaseNumber from Case where ContactId = :contactId and Service__c = :service and RecordType.Name = :recordType];
        if(cases.size()==1){
            return cases[0].CaseNumber;
        } 
        else if(cases.size()>1){
            throw new CommunityException('More than one case found for contact ' + contactId + ' and service ' + service + ' and record type ' + recordType + '.');
        }
        else{
            return null;
        }
    }
    //New Method - Gets Case ID & Case Number for the given service & record type. Added by Shailaja on 01/15/2021. User Story#11859
    @AuraEnabled
    public static List <String> getCaseNumberIDByServiceAndRecordType(String service, String recordType){
        String contactId = getRunningContactId();
        List<String> caseIDNumber =new List<String>();
        List<Case> cases = new List<Case>();
        //query is different based on the record type.
        if(recordType=='Identity Verification'){
            cases = [select Id, CaseNumber from Case where ContactId = :contactId and Service__c =: service and RecordType.Name = :recordType ];
        }
        else if(recordType=='Applicant Biographic Change'){
            cases = [select Id, CaseNumber from Case where ContactId = :contactId and Service__c =: service and RecordType.Name = :recordType and Internal_Status__c != :Constants.CASE_STATUS_ACCEPTED and Internal_Status__c != :Constants.CASE_STATUS_REJECTED ];
        }
        if(cases.size()==1){
            caseIDNumber.add(cases[0].Id);
            caseIDNumber.add(cases[0].CaseNumber);
            return caseIDNumber;
        }
        else if(cases.size()>1){
            throw new CommunityException('More than one case found for contact ' + contactId + ' and service ' + service + ' and record type ' + recordType + '.');
        } 
        else{
            return null;
        }
    }
    /* This method returns the case record type for the logged-in community contact.If none is found, returns null.If more than one is found, throw exception. */
    @AuraEnabled
    public static String getCaseRecordTypeById(String caseId){
        String contactId = getRunningContactId();
        List<Case> cases = [select RecordType.DeveloperName from Case where ContactId = :contactId and Id = :caseId];
        if(cases.size()==1){
            return cases[0].RecordType.DeveloperName;
        }
        else if(cases.size()>1){
            throw new CommunityException('More than one case found for contact ' + contactId +  ' and record type ');
        }
        else{
            return null;
        }
    }
     // Description : To upload notary documents
    @AuraEnabled
    public static void createNotaryAsset(String notaryId, String service, String caseId){
        String contactId = getRunningContactId();
        String accountId = [select AccountId from Contact where id = :contactId][0].AccountId;
        List<Case> cL = new List<Case>();
        if(caseId==null){
            cL = [Select Id, Internal_Status__c, Type FROM Case WHERE ContactId = :contactId AND Service__c = :service AND RecordType.Name = 'Identity Verification' ORDER BY CreatedDate DESC];
        } 
        else{
            cL = [Select Id, Internal_Status__c, Type FROM Case WHERE Id = :caseId];
        }
        if(cL.size()>0){
            Case c = cL[0];
            c.Internal_Status__c = 'Pending ID Verification Review';
            update c;
			if(Asset.SObjectType.getDescribe().isAccessible()){
                List<Asset> assetList = [Select Id,Status,Case__c,Case__r.Id,Name,Type__c FROM Asset WHERE Name =:constants.ASSET_NAME_ID_FORM_NOTARIZED And (type__c = 'ID Verification') AND ContactId = :contactId AND Status IN ('In Progress','Verified') AND status !=:Constants.ASSET_STATUS_MARKED_FOR_DELETION];
                for(Asset asst: assetList){
                    asst.Case__c = c.Id;
                }
                if(Asset.SObjectType.getDescribe().isUpdateable()){
                    update assetList;
				    Affirmation__c af1 = new Affirmation__c(Asset__c = assetList[0].Id, Status__c = 'In Progress', RecordTypeId = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get('ID_Verification').getRecordTypeId()); //'0120t0000000Kop');
                    insert af1;
                }
            }  
        }
    }
     //Description : To resubmit notary documents
    @AuraEnabled
    public static void resubmitNotaryAsset(String notaryId,String service, String caseId){
        String contactId = getRunningContactId();
        String accountId = [select AccountId from Contact where id = :contactId][0].AccountId;
        List<Case> cL = new List<Case>();
        if(caseId==null){
            cL = [Select Id, Status, Type FROM Case WHERE ContactId = :contactId AND Service__c = :service AND RecordType.Name = 'Identity Verification' ORDER BY CreatedDate DESC];
        }
        else{
            cL = [Select Id, Status, Type FROM Case WHERE Id = :caseId];
        }
        if(cL.size()>0){
            Case c = cL[0];
			c.Internal_Status__c = 'Resubmitted-Pending ID Verification Review';
            c.Action_Required__c = false;
            update c;
			if(Asset.SObjectType.getDescribe().isAccessible()){
                List<Asset> assetList = [Select Id,Status,Case__c,Case__r.Id,Name,Type__c FROM Asset WHERE Name =:constants.ASSET_NAME_ID_FORM_NOTARIZED And (type__c = 'ID Verification') AND ContactId = :contactId AND Status IN ('In Progress','Verified') AND status !=:Constants.ASSET_STATUS_MARKED_FOR_DELETION];
                for(Asset asst: assetList){
                    asst.Case__c = c.Id;
                }
                if(Asset.SObjectType.getDescribe().isUpdateable()){
                    update assetList;
				    Affirmation__c af1 = new Affirmation__c(Asset__c = assetList[0].Id, Status__c = 'In Progress', RecordTypeId = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get('ID_Verification').getRecordTypeId()); //'0120t0000000Kop');
                    insert af1;
                }
            }  
        }
    }
    /* Returns the contact id of the logged in user, such as a user who is a enabled for community access. If not found, tries to load the "test contact" from Community Settings. */
    @AuraEnabled
    public static String getRunningContactId(){
        String userId = (String)UserInfo.getUserId();
        User usr = [select ContactId from User where Id = :userId limit 1];
        String contactId = usr.ContactId;
        if(contactId==null || contactId==''){
            Community_Settings__c settings = Community_Settings__c.getOrgDefaults();
            contactId = settings.Builder_Test_Contact__c;
            if(contactId!=null){
                // ensure the setting provided is a valid contact id and/or is valid for this org.
                List<Contact> contacts = [select Id from Contact where Id = :contactId];
                if(contacts.size() == 0){ 
                    contactId = null;
                }
            }
            if(!Test.isRunningTest() && contactId == null){
                throw new CommunityException('Unable to find Community User/Contact. If using a test contact, make sure it is valid for this org.');
            }
        }
        if(Test.isRunningTest() && contactId == null){
        	return [SELECT id, ContactId from User where email = :CommunitiesTestFactory.emailtest AND ContactId != null LIMIT 1].ContactId;
        }
        else{ 
        	return contactId;
        }
    }
    @AuraEnabled
    public static String encryptURL(String URLparams){
        Security_Settings__c ssCS = Security_Settings__c.getOrgDefaults();
        if(ssCS!=null && ssCS.Encryption_Key__c!=null && ssCS.Encryption_Key__c!=''){
            if(!ssCS.Disable_URL_Encryption__c){
                Blob cryptoKey = Blob.valueOf(ssCS.Encryption_Key__c);
                Blob encryptedDataBlob = Crypto.encryptWithManagedIV('AES256', cryptoKey, Blob.valueOf(URLparams));
                String  encryptedData = EncodingUtil.base64Encode(encryptedDataBlob);
                return encryptedData;
            }
            return URLparams;
        }
        return null;
    }
    @AuraEnabled
    public static String dencryptURL(String encryptedData){
        Security_Settings__c ssCS = Security_Settings__c.getOrgDefaults();
        if(ssCS!=null && ssCS.Encryption_Key__c!=null && ssCS.Encryption_Key__c!=''){
            if(!ssCS.Disable_URL_Encryption__c){
                Blob cryptoKey = Blob.valueOf(ssCS.Encryption_Key__c);
                Blob decryptedDataBlob = Crypto.decryptWithManagedIV('AES256', cryptoKey, EncodingUtil.base64Decode(encryptedData));
                String  decryptedData = decryptedDataBlob.toString();
                return decryptedData;
            }
            return encryptedData;
        }
        return null;
    }
    @AuraEnabled
    public static void closeJ1InviteCase(){
        String contactId = getRunningContactId();
        List<Case> cases = [ select Id, Internal_Status__c from Case where Service__c = 'J1' and Internal_Status__c = 'New' and RecordType.Name = 'J1 Invitation' and ContactId = :contactId ];
        if(cases.size()==1){
            cases[0].Internal_Status__c = 'Accepted';
            update cases;
        }
        else if(cases.size()==0){
            throw new CommunityException('Could not find a J1 Invitation case to close.');
        }
        else if(cases.size()>1){
            throw new CommunityException('Found more than one J1 Invitation case.');
        }
        else{
            throw new CommunityException('There was an unexpected problem whilst looking up the J1 Invitation case.');
        }
    }
    //User Story#7593 & 7594, Code added on Aug 26 2020, Shailaja
    @AuraEnabled
    public static List<SelectOption> getMonthPicklistEntries(){
        List<SelectOption> options = ComponentUtility.getMonthPicklistEntries();
        return options;
    }
    //Returns a null-safe service name. If the service passed in is not null, returns that. If it is null, returns the "test service" from Community Settings. If none is configured, throws CommunityException.
    public static String getNullSafeService(String service){
        if(service==null){
            Community_Settings__c settings = Community_Settings__c.getOrgDefaults();
            service = settings.Builder_Test_Service__c;
            if(service == null){
                 throw new CommunityException('The specified service cannot be null. If you are expecting a test service, please make sure it is configured in Community Settings.');
            }
        }
        return service;
    }
    /* Returns the ID of the product designated for the photo product. Keys off of Product Code.*/
    private static String getPhotoProductId(){
        Community_Settings__c settings = Community_Settings__c.getOrgDefaults();
        String productCode = settings.Photo_Product_Code__c;
        List<Product2> prodL = [select Id from Product2 where ProductCode = :productCode];
        if(prodL==null || prodL.size()==0){
        	throw new CommunityException('Photo Product Code missing in Community Settings');
        } 
        else if(prodL.size()==1){
        	return prodL[0].Id;
    	}else{
        	return prodL[prodL.size()-1].Id;
        }
    }
    /*  Returns the ID of the product designated for the passport product. Keys off of Product Code. */
    private static String getPassportProductId(){
        Community_Settings__c settings = Community_Settings__c.getOrgDefaults();
        String productCode = settings.Passport_Product_Code__c;
        List<Product2> prodL = [select Id from Product2 where ProductCode = :productCode];
        if(prodL==null || prodL.size()==0){
        	throw new CommunityException('Passport Product Code missing in Community Settings');
        } 
        else if(prodL.size()==1){
        	return prodL[0].Id;
        }
        else{
        	return prodL[prodL.size()-1].Id;
        }
    }
    /*  Returns the ID of the product designated for the ID Form product. Keys off of Product Code.*/
    private static String getIdFormProductId(){
        Community_Settings__c settings = Community_Settings__c.getOrgDefaults();
        String productCode = settings.ID_Form_Product_Code__c;
        List<Product2> prodL = [select Id from Product2 where ProductCode = :productCode];
        if(prodL==null || prodL.size()==0){
        	throw new CommunityException('ID Form Product Code missing in Community Settings');
        }
        else if(prodL.size()==1){
        	return prodL[0].Id;
        }
        else{
        	return prodL[prodL.size()-1].Id;
        }
    }
    /*The name of the queue where ID Verifications will be created, e.g. "ID Review Queue" */
    private static String getIdVerificationCaseQueueId(){
        Community_Settings__c settings = Community_Settings__c.getOrgDefaults();
        String queueName = settings.ID_Verification_Case_Queue_Name__c;
        Group grp = [select Id from Group where Type = 'Queue' and Name = :queueName];
        if(grp == null){
            throw new CommunityException('ID Verification Case Queue Name missing in Community Settings');
        }
        return grp.Id;
    }
    /* The initial case status when being created, e.g. "New" */
    private static String getIdVerificationCaseUnpaidStatus(){
        Community_Settings__c settings = Community_Settings__c.getOrgDefaults();
        String status = settings.ID_Verification_Case_Unpaid_Status__c;
        if(status == null){
            throw new CommunityException('ID Verification Case Unpaid Status missing in Community Settings');
        }
        return status;
    }
    /* The status to set the case to after the payment has been processed, e.g. "Pending ID Review"*/
    public static String getIdVerificationCasePaidStatus(){
        Community_Settings__c settings = Community_Settings__c.getOrgDefaults();
        String status = settings.ID_Verification_Case_Paid_Status__c;
        if(status == null){
            throw new CommunityException('ID Verification Case Queue Name missing in Community Settings');
        }
        return status;
    }
    // Check if case is eligible for online notary
    @AuraEnabled
    public static Boolean isCaseEligibleForOnlineNotary(String caseId){
        Try{
            // Get current contact
            Contact contactRecord = getContactWithRecordType();
            Case caseRecord = [Select Internal_Status__c, RecordType.DeveloperName, Eligible_For_Online_Notary__C
                               FROM Case WHERE Id = :caseId];
            // Business rules to check if this case is eligible for online notary 
            // Check Contact Record Type is Applicant OR Registered User
            // Check Case Record Type is Identity Verification OR Applicant Biographic Change
            // Check if status is Pending Applicant Action-Notarize ID Form OR Pending Applicant Action-Resubmit Notarized ID Form
            // Check if "Eligible for Online Notary Flag" is checked on case
            if((contactRecord!= null && caseRecord!= null) &&
               (contactRecord.RecordType.Name == Constants.CONTACT_RECORD_TYPE_APPLICANT || contactRecord.RecordType.Name == Constants.CONTACT_RECORD_TYPE_REG_USR) &&
               (caseRecord.RecordType.DeveloperName == Constants.CASE_RECORD_TYPE_IDENTITY_VERIFICATION || caseRecord.RecordType.DeveloperName == Constants.CASE_RECORD_TYPE_APP_BIO_CHANGE) && 
               (caseRecord.Internal_Status__c == Constants.CASE_STATUS_INTERNAL_PENDING_APPLICANT_ACTION_NOTARIZE_ID || caseRecord.Internal_Status__c == Constants.CASE_STATUS_INTERNAL_PENDING_APPLICANT_ACTION_RESUBMIT_NOTARIZE_ID) &&
               (caseRecord.Eligible_For_Online_Notary__C == 'Yes')){
                return true;
            }
        }
        Catch(Exception e){
            throw e;
        }
        return false;
    }
    // To create payload for passport upload
    @AuraEnabled
    public static CloudStorageController.PayloadWrapper createPassportPayload(String contactId){
        List<Asset> assetList = [SELECT id FROM Asset where contactId =:contactId AND Name =: Constants.ASSET_NAME_PASSPORT AND status !=:Constants.ASSET_STATUS_INCOMPLETE AND status !=:Constants.ASSET_STATUS_MARKED_FOR_DELETION ORDER BY CreatedDate DESC];
        String assetId = null;
        String accountId = null;
        String caseId = null;
        List<Case> caseList = [SELECT id,AccountId FROM Case where contactId =:contactId and RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_IDENTITY_VERIFICATION];
        if(!caseList.isEmpty()){
            accountId= caseList[0].AccountId;
            caseId= caseList[0].Id;
        }
        if(!assetList.isEmpty()){
            assetId= assetList[0].Id;
        }
        CloudStorageController.PayloadWrapper payload= new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_NAME_PASSPORT, 'Identity', 'Replace', caseId, accountId,  'true', 'In Progress', assetId);
        return payload;
    }
   //Code added by Shailaja. User story#11859 // To create payload for passport upload
    @AuraEnabled
    public static CloudStorageController.PayloadWrapper createResubmitPassportPayload(String contactId, String currentCaseId, String serviceName){
        String assetId = null;
        String accountId = null;
        String caseId = null;
        List<Asset> assetList = new List<Asset>();
        if(currentCaseId!=null){
            caseId = currentCaseId;
            assetList = [SELECT Id FROM Asset WHERE Case__c =:currentCaseId AND Name =: Constants.ASSET_NAME_PASSPORT AND status =:Constants.ASSET_STATUS_IN_PROGRESS ORDER BY CreatedDate DESC];
            if(!assetList.isEmpty()){
                assetId = assetList[0].Id;
            }
        }else{
            List<Case> caseList = [SELECT id,AccountId FROM Case WHERE contactId =:contactId AND RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_IDENTITY_VERIFICATION AND service__c =: serviceName];
            if(!caseList.isEmpty()){
                accountId = caseList[0].AccountId;
                caseId = caseList[0].Id;
                assetList = [SELECT id FROM Asset WHERE contactId =:contactId AND Case__c =:caseId AND Name =: Constants.ASSET_NAME_PASSPORT AND status !=:Constants.ASSET_STATUS_INCOMPLETE AND status !=:Constants.ASSET_STATUS_MARKED_FOR_DELETION ORDER BY CreatedDate DESC];
                if(!assetList.isEmpty()){
                    assetId = assetList[0].Id;
                }
            }
        }
        CloudStorageController.PayloadWrapper payload= new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_NAME_PASSPORT, 'Identity', 'Replace', caseId, accountId,  'true', 'In Progress', assetId);
        return payload;
    }
    // To create payload for passport translation upload
    @AuraEnabled
    public static CloudStorageController.PayloadWrapper createPassportTranslationPayload(String contactId){
        List<Asset> assetList = [SELECT id FROM Asset where contactId =:contactId AND Name =: Constants.ASSET_NAME_PASSPORT_TRANSLATION  AND status !=:Constants.ASSET_STATUS_INCOMPLETE AND status !=:Constants.ASSET_STATUS_MARKED_FOR_DELETION ORDER BY CreatedDate DESC];
        String assetId = null;
        String accountId = null;
        String caseId = null;
        List<Case> caseList = [SELECT id,AccountId FROM Case where contactId =:contactId and RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_IDENTITY_VERIFICATION];
        if(!caseList.isEmpty()){
            accountId = caseList[0].AccountId;
            caseId = caseList[0].Id;
        }
        if(!assetList.isEmpty()){
            assetId = assetList[0].Id;
        }
        CloudStorageController.PayloadWrapper payload= new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_NAME_PASSPORT_TRANSLATION, 'Identity', 'Replace', caseId, accountId,  'true', 'In Progress', assetId);
        return payload;
    }    
    //New Code - Added by Shailaja. 1/15/2021. User Story#11859 // To create payload for passport translation upload
    @AuraEnabled
    public static CloudStorageController.PayloadWrapper createResubmitPassportTranslationPayload(String contactId, String currentCaseId, String serviceName){
        String assetId = null;
        String accountId = null;
        String caseId = null;
        List<Asset> assetList = new List<Asset>();
        if(currentCaseId!=null){
            caseId = currentCaseId;
            assetList = [SELECT Id FROM Asset WHERE Case__c =:currentCaseId AND Name =: Constants.ASSET_NAME_PASSPORT_TRANSLATION AND status =:Constants.ASSET_STATUS_IN_PROGRESS ORDER BY CreatedDate DESC];
            if(!assetList.isEmpty()){
                assetId = assetList[0].Id;
            }
        }else{
            List<Case> caseList = [SELECT Id, AccountId FROM Case WHERE contactId =:contactId AND RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_IDENTITY_VERIFICATION AND service__c =: serviceName];
            if(!caseList.isEmpty()){
                accountId = caseList[0].AccountId;
                caseId = caseList[0].Id;
                assetList = [SELECT Id FROM Asset WHERE contactId =:contactId AND Case__c =:caseId AND Name =: Constants.ASSET_NAME_PASSPORT AND status !=:Constants.ASSET_STATUS_INCOMPLETE AND status !=:Constants.ASSET_STATUS_MARKED_FOR_DELETION ORDER BY CreatedDate DESC];
                if(!assetList.isEmpty()){
                    assetId = assetList[0].Id;
                }
            }
        }
        CloudStorageController.PayloadWrapper payload= new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_NAME_PASSPORT_TRANSLATION, 'Identity', 'Replace', caseId, accountId,  'true', 'In Progress', assetId);
        return payload;
    }
    // To create payload for Passport Expiration upload
    @AuraEnabled
    public static CloudStorageController.PayloadWrapper createPpExpPayload(String contactId){
        List<Asset> assetList = [SELECT id FROM Asset where contactId =:contactId AND Name =: Constants.ASSET_NAME_PASSPORT_EXPIRATION AND status !=:Constants.ASSET_STATUS_INCOMPLETE AND status !=:Constants.ASSET_STATUS_MARKED_FOR_DELETION ORDER BY CreatedDate DESC];
        String assetId = null;
        String accountId = null;
        String caseId = null;
        List<Case> caseList = [SELECT id,AccountId FROM Case where contactId =:contactId and RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_IDENTITY_VERIFICATION];
        if(!caseList.isEmpty()){
            accountId = caseList[0].AccountId;
            caseId = caseList[0].Id;
        }
        if(!assetList.isEmpty()){
            assetId = assetList[0].Id;
        }
        CloudStorageController.PayloadWrapper payload= new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_NAME_PASSPORT_EXPIRATION, 'Identity', 'Replace', caseId, accountId,  'true', 'In Progress', assetId);
        return payload;
    }
    //New Code - Added by Shailaja. 1/15/2021. User Story#11859 // To create payload for Passport Expiration upload
    @AuraEnabled
    public static CloudStorageController.PayloadWrapper createResubmitPpExpPayload(String contactId, String currentCaseId, String serviceName){
        String assetId = null;
        String accountId = null;
        String caseId = null;
        List<Asset> assetList = new List<Asset>();
        if(currentCaseId!=null){
            caseId = currentCaseId;
            assetList = [SELECT Id FROM Asset WHERE Case__c =:currentCaseId AND Name =: Constants.ASSET_NAME_PASSPORT_EXPIRATION AND status =:Constants.ASSET_STATUS_IN_PROGRESS ORDER BY CreatedDate DESC];
            if(!assetList.isEmpty()){
                assetId = assetList[0].Id;
            }
        }else{
            List<Case> caseList = [SELECT id,AccountId FROM Case WHERE contactId =:contactId AND RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_IDENTITY_VERIFICATION AND service__c =: serviceName];
            if(!caseList.isEmpty()){
                accountId = caseList[0].AccountId;
                caseId = caseList[0].Id;
                assetList = [SELECT id FROM Asset WHERE contactId =:contactId AND Case__c =:caseId AND Name =: Constants.ASSET_NAME_PASSPORT_EXPIRATION AND status !=:Constants.ASSET_STATUS_INCOMPLETE AND status !=:Constants.ASSET_STATUS_MARKED_FOR_DELETION ORDER BY CreatedDate DESC];
                if(!assetList.isEmpty()){
                    assetId = assetList[0].Id;
                }
            }
        }
        CloudStorageController.PayloadWrapper payload= new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_NAME_PASSPORT_EXPIRATION, 'Identity', 'Replace', caseId, accountId,  'true', 'In Progress', assetId);
        return payload;
    }
    // To create payload for already uploaded passport. //Code  updated for user story#11859 by Shailaja Yerneni. 1/20/2021
    @AuraEnabled
    public static CloudStorageController.PayloadWrapper createExistPassportPayload(String contactId, String currentCaseId){
        List<Asset> assetList;
        List<Case> caseList;
        String assetId = null;
        String assetStatus ='';
        String accountId = null;
        String caseId = null;
        if(currentCaseID!=null){
            //Record type Biographic Change. ASSET STATUS IS INVALIDATED
            assetList = [SELECT id FROM Asset where contactId =:contactId AND Name =: Constants.ASSET_NAME_PASSPORT AND (status =:Constants.ASSET_STATUS_INVALIDATED) AND Case__c =:currentCaseId ORDER BY CreatedDate DESC];
            caseList = [SELECT id,AccountId FROM Case where contactId =:contactId AND RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_APP_BIO_CHANGE ORDER BY CreatedDate DESC];
            assetStatus = 'Invalidated';
        }else{
            //Record Type is Identity verification.
            assetList = [SELECT id FROM Asset where contactId =:contactId AND Name =: Constants.ASSET_NAME_PASSPORT AND (status =:Constants.ASSET_STATUS_INCOMPLETE OR status =:Constants.ASSET_STATUS_VERIFIED) ORDER BY CreatedDate DESC];
            caseList = [SELECT id,AccountId FROM Case where contactId =:contactId and RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_IDENTITY_VERIFICATION];
            assetStatus = 'Incomplete';
        }
        if(!caseList.isEmpty()){
            accountId = caseList[0].AccountId;
            caseId = caseList[0].Id;
        }
        if(!assetList.isEmpty()){
            assetId = assetList[0].Id;
        }
        CloudStorageController.PayloadWrapper payload= new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_NAME_PASSPORT, 'Identity', '', caseId, accountId,  'true', assetStatus, assetId);
        return payload;
    }             
    // To create payload for existing passport translation upload //Code  updated for user story#11859 by Shailaja Yerneni. 1/20/2021
    @AuraEnabled
    public static CloudStorageController.PayloadWrapper passportTranslPayloadExist(String contactId, String currentCaseId){
        List<Asset> assetList;
        List<Case> caseList;
        String assetId = null;
        String accountId = null;
        String caseId = null;
        String assetStatus ='';
        if(currentCaseID != null){
            //Record type Biographic Change. ASSET STATUS IS INVALIDATED
            assetList = [SELECT id FROM Asset where contactId =:contactId AND Name =: Constants.ASSET_NAME_PASSPORT_TRANSLATION AND status =:Constants.ASSET_STATUS_INVALIDATED AND Case__c =:currentCaseId ORDER BY CreatedDate DESC];
            caseList = [SELECT id,AccountId FROM Case where contactId =:contactId  AND id =:currentCaseId AND RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_APP_BIO_CHANGE ORDER BY CreatedDate DESC];
            assetStatus = 'Invalidated';
        }else{
            //Record Type - Identity Verification
            assetList = [SELECT id FROM Asset where contactId =:contactId AND Name =: Constants.ASSET_NAME_PASSPORT_TRANSLATION AND (status =:Constants.ASSET_STATUS_INCOMPLETE OR status =:Constants.ASSET_STATUS_VERIFIED)  ORDER BY CreatedDate DESC];
            caseList = [SELECT id,AccountId FROM Case where contactId =:contactId AND RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_IDENTITY_VERIFICATION];
            assetStatus = 'Incomplete';
        }
        if(!caseList.isEmpty()){
            accountId = caseList[0].AccountId;
            caseId = caseList[0].Id;
        }
        if(!assetList.isEmpty()){
            assetId = assetList[0].Id;
        }
        CloudStorageController.PayloadWrapper payload= new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_NAME_PASSPORT_TRANSLATION, 'Identity', '', caseId, accountId,  'true', assetStatus, assetId);
        return payload;
    }
    // To create payload for existing Passport Expiration //Code  updated for user story#11859 by Shailaja Yerneni. 1/20/2021
    @AuraEnabled
    public static CloudStorageController.PayloadWrapper passportExpirePayloadExist(String contactId, String currentCaseId){
        List<Asset> assetList;
        List<Case> caseList;
        String assetId = null;
        String accountId = null;
        String caseId = null;
        String assetStatus ='';
        if(currentCaseID!=null){
            //Record type Biographic Change. ASSET STATUS IS INVALIDATED
            assetList = [SELECT id FROM Asset where contactId =:contactId AND Name =: Constants.ASSET_NAME_PASSPORT_EXPIRATION AND (status =:Constants.ASSET_STATUS_INVALIDATED) AND Case__c =:currentCaseId ORDER BY CreatedDate DESC];
            caseList = [SELECT id,AccountId FROM Case where contactId =:contactId AND id =:currentCaseId AND RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_APP_BIO_CHANGE ORDER BY CreatedDate DESC];
            assetStatus = 'Invalidated';
        }else{
            //Record Type - Identity Verification
            assetList = [SELECT id FROM Asset where contactId =:contactId AND Name =: Constants.ASSET_NAME_PASSPORT_EXPIRATION AND (status =:Constants.ASSET_STATUS_INCOMPLETE OR status =:Constants.ASSET_STATUS_VERIFIED) ORDER BY CreatedDate DESC];
            caseList = [SELECT id,AccountId FROM Case where contactId =:contactId and RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_IDENTITY_VERIFICATION];
            assetStatus = 'Incomplete';
        }
        if(!caseList.isEmpty()){
            accountId = caseList[0].AccountId;
            caseId = caseList[0].Id;
        }
        if(!assetList.isEmpty()){
            assetId = assetList[0].Id;
        }
        CloudStorageController.PayloadWrapper payload= new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_NAME_PASSPORT_EXPIRATION, 'Identity', '', caseId, accountId,  'true', assetStatus, assetId);
        return payload;
    }
    // To create payload for passport translation upload
    @AuraEnabled
    public static void deleteExistingAsset(String contactId){
        List<Asset> assetList = [SELECT id FROM Asset where contactId =:contactId AND Name =: Constants.ASSET_NAME_PASSPORT_TRANSLATION AND status !=:Constants.ASSET_STATUS_MARKED_FOR_DELETION ORDER BY CreatedDate DESC];
        List<RecordType> rts = new List<RecordType>();
        if(RecordType.SObjectType.getDescribe().isAccessible()){
            rts = [SELECT Id, Name from RecordType where DeveloperName = :Constants.ASSET_RECORD_TYPE_MARKED_FOR_DELETION AND SObjectType = 'Asset'];
        }
        if(rts.size() == 0){
            throw new CommunityException(RECORD_TYPE_EXCEPTION);
        } 
        RecordType assetMarkedForDeletionRT = rts[0];
        for(Asset asst: assetList){
            asst.case__c = null;
            asst.status = constants.ASSET_STATUS_MARKED_FOR_DELETION;
            asst.RecordTypeId = assetMarkedForDeletionRT.Id;
        }
        if(!assetList.isEmpty()){
            update assetList;
        }
    }
    // Description : To Update existing passport expiration asset
    @AuraEnabled
    public static void deleteExistingPassportExpirationAsset(String contactId){
        List<Asset> assetList = [SELECT id FROM Asset where contactId =:contactId AND Name =: Constants.ASSET_NAME_PASSPORT_EXPIRATION AND status !=:Constants.ASSET_STATUS_MARKED_FOR_DELETION ORDER BY CreatedDate DESC];
        List<RecordType> rts = new List<RecordType>();
        if(RecordType.SObjectType.getDescribe().isAccessible()){
            rts = [SELECT Id, Name from RecordType where DeveloperName = :Constants.ASSET_RECORD_TYPE_MARKED_FOR_DELETION AND SObjectType = 'Asset'];
        }
        if(rts.size()==0){
            throw new CommunityException(RECORD_TYPE_EXCEPTION);
        } 
        RecordType assetMarkedForDeletionRT = rts[0];
        for(Asset asst: assetList){
            asst.case__c = null;
            asst.status = constants.ASSET_STATUS_MARKED_FOR_DELETION;
            asst.RecordTypeId = assetMarkedForDeletionRT.Id;
        }
        if(!assetList.isEmpty()){
            update assetList;
        }
    }
    // Description : To Update newly added Photo asset as ASSET_STATUS_MARKED_FOR_DELETION on ResubmitId.cmp
    @AuraEnabled
    public static void deleteExistingPhotoAsset(String contactId, String passport){
        List<Asset> assetList = new List<Asset>();
        if(passport == 'Yes'){
            assetList = [SELECT id FROM Asset where contactId =:contactId AND Name =: Constants.ASSET_NAME_PASSPORT AND (status !=:Constants.ASSET_STATUS_MARKED_FOR_DELETION AND status !=:Constants.ASSET_STATUS_INCOMPLETE) ORDER BY CreatedDate DESC];
        }
        else if(passport == 'translation'){
            assetList = [SELECT id FROM Asset where contactId =:contactId AND Name =: Constants.ASSET_NAME_PASSPORT_TRANSLATION AND (status !=:Constants.ASSET_STATUS_MARKED_FOR_DELETION AND status !=:Constants.ASSET_STATUS_INCOMPLETE) ORDER BY CreatedDate DESC];
        }
        else if(passport == 'expiration'){
            assetList = [SELECT id FROM Asset where contactId =:contactId AND Name =: Constants.ASSET_NAME_PASSPORT_EXPIRATION AND (status !=:Constants.ASSET_STATUS_MARKED_FOR_DELETION AND status !=:Constants.ASSET_STATUS_INCOMPLETE) ORDER BY CreatedDate DESC];
        }
        else{
            assetList = [SELECT id FROM Asset where contactId =:contactId AND Name =: Constants.ASSET_NAME_PHOTO AND (status !=:Constants.ASSET_STATUS_MARKED_FOR_DELETION AND status !=:Constants.ASSET_STATUS_INCOMPLETE AND status !=:Constants.ASSET_STATUS_EXPIRED) ORDER BY CreatedDate DESC];
        }
        List<RecordType> rts = new List<RecordType>();
        if(RecordType.SObjectType.getDescribe().isAccessible()){
            rts = [SELECT Id, Name from RecordType where DeveloperName = :Constants.ASSET_RECORD_TYPE_MARKED_FOR_DELETION AND SObjectType = 'Asset'];
        }
        if(rts.size()==0){
            throw new CommunityException(RECORD_TYPE_EXCEPTION);
        } 
        RecordType assetMarkedForDeletionRT = rts[0];
        for(Asset asst: assetList){
            asst.case__c = null;
            asst.status = constants.ASSET_STATUS_MARKED_FOR_DELETION;
            asst.RecordTypeId = assetMarkedForDeletionRT.Id;
        }
        if(!assetList.isEmpty()){
            update assetList;
        }
    }
    @AuraEnabled
    public static CloudStorageController.PayloadWrapper createPhotoPayload(String contactId, String currentCaseId){    
        List<Asset> assetList = new List<Asset>();
        String assetId = null;
        String accountId = null;
        String caseId = null;
        if(currentCaseId!=null){
            caseId = currentCaseId;
            assetList = [SELECT id FROM Asset where Case__c =:currentCaseId AND Name =: Constants.ASSET_NAME_PHOTO AND status =:Constants.ASSET_STATUS_IN_PROGRESS ORDER BY CreatedDate DESC];            
        }
        else{
            assetList = [SELECT id FROM Asset where contactId =:contactId AND Name =: Constants.ASSET_NAME_PHOTO AND status =:Constants.ASSET_STATUS_IN_PROGRESS ORDER BY CreatedDate DESC];
            List<Case> caseList = [SELECT id,AccountId FROM Case where contactId =:contactId and RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_IDENTITY_VERIFICATION];
            if(!caseList.isEmpty()){
                accountId= caseList[0].AccountId;
                caseId= caseList[0].Id;
            }
        }
        if(!assetList.isEmpty()){
            assetId= assetList[0].Id;
        }
        CloudStorageController.PayloadWrapper payload= new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_NAME_PHOTO, 'Identity', 'Replace', caseId, accountId,  'true', 'In Progress', assetId);
        return payload;
    }
    // Description : To create payload for Notarized Id upload
    @AuraEnabled
    public static CloudStorageController.PayloadWrapper createNotarizedPayload(String contactId,String cs){
        String assetId = null;
        String accountId = null;
        String caseId = null;
        List<Case> caseList =new List<Case>();
        if(cs!=null){
            caseList = [SELECT id,AccountId FROM Case where Id =:cs];
        }else{
            caseList = [SELECT id,AccountId FROM Case where contactId =:contactId and RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_IDENTITY_VERIFICATION];
        }
        if(!caseList.isEmpty()){
            accountId = caseList[0].AccountId;
            caseId = caseList[0].Id;
        }
        List<Asset> assetList = [SELECT id FROM Asset where Case__c=:caseId And contactId =:contactId AND Name ='ID Form Notarized' AND status !=:Constants.ASSET_STATUS_MARKED_FOR_DELETION ORDER BY CreatedDate DESC];
        if(!assetList.isEmpty()){
            assetId = assetList[0].Id;
        }
        CloudStorageController.PayloadWrapper payload= new CloudStorageController.PayloadWrapper(contactId, 'ID Form Notarized', 'Identity', 'Replace', caseId, accountId,  'true', 'In Progress', assetId);
        return payload;
    }
    // Creating Payload for Pending Applicant Action-Resubmit Notarized ID Form
    @AuraEnabled
    public static CloudStorageController.PayloadWrapper createResumbitPhotoPayload(String contactId, String currentCaseId, String serviceName){    
        List<Asset> assetList = new List<Asset>();
        String assetId = null;
        String accountId = null;
        String caseId = null;
        if(currentCaseId!=null){
            caseId = currentCaseId;
            assetList = [SELECT Id FROM Asset WHERE Case__c =:currentCaseId AND Name =: Constants.ASSET_NAME_PHOTO AND status =:Constants.ASSET_STATUS_IN_PROGRESS ORDER BY CreatedDate DESC];
            if(!assetList.isEmpty()){
                assetId = assetList[0].Id;
            }
        }else{
            List<Case> caseList = [SELECT Id, AccountId FROM Case WHERE contactId =:contactId AND RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_IDENTITY_VERIFICATION AND service__c =: serviceName];
            if(!caseList.isEmpty()){
                accountId = caseList[0].AccountId;
                caseId = caseList[0].Id;
                assetList = [SELECT Id FROM Asset WHERE contactId =:contactId AND Case__c =: caseId AND Name =: Constants.ASSET_NAME_PHOTO AND status =:Constants.ASSET_STATUS_IN_PROGRESS ORDER BY CreatedDate DESC];
                if(!assetList.isEmpty()){
                    assetId = assetList[0].Id;
                }
            }
        }        
        CloudStorageController.PayloadWrapper payload= new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_NAME_PHOTO, 'Identity', 'Replace', caseId, accountId,  'true', 'In Progress', assetId);
        return payload;
    }
    @AuraEnabled
    public static CloudStorageController.PayloadWrapper createResumbitExistPhotoPayload(String contactId, String serviceName){
        String assetId = null;
        String accountId = null;
        String caseId = null;
        List<Case> caseList = [SELECT Id, AccountId FROM Case WHERE contactId =:contactId AND service__c =: serviceName AND RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_IDENTITY_VERIFICATION];
        if(!caseList.isEmpty()){
            accountId = caseList[0].AccountId;
            caseId = caseList[0].Id;
            List<Asset> assetList = [SELECT id FROM Asset WHERE ContactId =: contactId AND Case__c =: caseId AND Name =: Constants.ASSET_NAME_PHOTO AND (status =:Constants.ASSET_STATUS_INCOMPLETE OR status =:Constants.ASSET_STATUS_EXPIRED OR status =:Constants.ASSET_STATUS_VERIFIED) ORDER BY CreatedDate DESC];
            if(!assetList.isEmpty()){
                assetId = assetList[0].Id;
            }
        }   
        CloudStorageController.PayloadWrapper payload= new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_NAME_PHOTO, 'Identity', 'Replace', caseId, accountId,  'false', 'Incomplete', assetId);       
        return payload;
    } 
    //Description : To Update existing Notarized asset
    @AuraEnabled
    public static void deleteExistingNotarizedAsset(String contactId){
        List<Asset> assetList = [SELECT id FROM Asset WHERE contactId =:contactId AND Name = 'ID Form Notarized' AND Status IN ('In Progress','Verified') And status !=:Constants.ASSET_STATUS_MARKED_FOR_DELETION ORDER BY CreatedDate DESC];
        List<RecordType> rts = new List<RecordType>();
        if(RecordType.SObjectType.getDescribe().isAccessible()){
            rts = [SELECT Id, Name from RecordType WHERE DeveloperName = :Constants.ASSET_RECORD_TYPE_MARKED_FOR_DELETION AND SObjectType = 'Asset'];
        }
        if(rts.size()==0){
            throw new CommunityException('Could not find record type named Marked for Deletion for Asset.');
        } 
        RecordType assetMarkedForDeletionRT = rts[0];
        for(Asset asst: assetList){
            asst.case__c = null;
            asst.status = constants.ASSET_STATUS_MARKED_FOR_DELETION;
            asst.RecordTypeId = assetMarkedForDeletionRT.Id;
        }
        if(!assetList.isEmpty()){
            update assetList;
        }
    }   
     // Description : To get InComplete Asset for Notary
    @AuraEnabled
    public static CloudStorageController.PayloadWrapper getIncompleteAssetNotaryPayload(String contactId,String cs){
        String assetId = null;
        String accountId = null;
        String caseId = null;
        List<Case> caseList =new List<Case>();
        if(cs!=null){
            caseList = [SELECT id,AccountId FROM Case where Id =:cs];
        }else{
            caseList = [SELECT id,AccountId FROM Case where contactId =:contactId and RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_IDENTITY_VERIFICATION];
        }
        if(!caseList.isEmpty()){
            accountId = caseList[0].AccountId;
            caseId = caseList[0].Id;
        }
        List<Asset> assetList = [SELECT id FROM Asset where Case__c =:caseId And contactId =:contactId AND Name =: Constants.ASSET_NAME_ID_FORM_NOTARIZED AND status =:Constants.ASSET_STATUS_INCOMPLETE AND status !=:Constants.ASSET_STATUS_MARKED_FOR_DELETION ORDER BY CreatedDate DESC];
        if(!assetList.isEmpty()){
            assetId = assetList[0].Id;
        }
        CloudStorageController.PayloadWrapper payload= new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_NAME_ID_FORM_NOTARIZED, 'Identity', 'Replace', caseId, accountId,  'false', 'Incomplete', assetId);       
        return payload;
    }
	// Description : To create payload for notary upload
    @AuraEnabled
    public static CloudStorageController.PayloadWrapper createNotaryPayload(String contactId,String cs){
        String assetId = null;
        String accountId = null;
        String caseId = null;
        List<Case> caseList =new List<Case>();
        if(cs!=null){
            caseList = [SELECT id,AccountId FROM Case where Id =:cs];
        }else{
            caseList = [SELECT id,AccountId FROM Case where contactId =:contactId and RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_IDENTITY_VERIFICATION];
        }
        if(!caseList.isEmpty()){
            accountId= caseList[0].AccountId;
            caseId= caseList[0].Id;
        }
        List<Asset> assetList = [SELECT id FROM Asset where Case__c =:caseId And contactId =:contactId AND Name =: Constants.ASSET_NAME_ID_FORM_NOTARIZED AND (status !=:Constants.ASSET_STATUS_MARKED_FOR_DELETION AND status !=:Constants.ASSET_STATUS_INCOMPLETE) ORDER BY CreatedDate DESC];
        if(!assetList.isEmpty()){
            assetId= assetList[0].Id;
        }
        CloudStorageController.PayloadWrapper payload= new CloudStorageController.PayloadWrapper(contactId, Constants.ASSET_NAME_ID_FORM_NOTARIZED, 'Identity', 'Replace', caseId, accountId,  'true', 'In Progress', assetId);
        return payload;
    }
    //Method to get azure url of the Id Form Template asset
    @AuraEnabled
    public static String getAzureUrl(){
        String contactId = getRunningContactId();
        String url = '';
        List<Asset> assetList = [SELECT Id, Azure_Storage_Url__c FROM Asset WHERE ContactId =:contactId AND Name =:Constants.ASSET_NAME_ID_FORM_TEMPLATE AND Status =:Constants.ASSET_STATUS_IN_PROGRESS WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
        if(!assetList.isEmpty() && String.isNotBlank(assetList[0].Azure_Storage_Url__c)){
            String fileName = assetList[0].Azure_Storage_Url__c.split('/')[4];
            url = CloudStorageUtils.getFileUrlWithSAS(fileName);
        }
        return url;
    }
    //New Method added for validation of previously entered USMLEID
    @AuraEnabled
    public static Boolean validatePrevUSMLEID(String prevUSMLEID){
        prevUSMLEID = prevUSMLEID.trim();
        String substrUSMLEID = prevUSMLEID.substring(0,7);
        List<String> uSMLE_Digits = new List<String>{'0','0','0','0','0','0','0'};
        Integer length = substrUSMLEID.length();
        for(Integer i=0;i<length;i++){
            uSMLE_Digits[i] = substrUSMLEID.substring(length-i-1,length-i);
        }
        Integer n_evenSum = Integer.valueOf(uSMLE_Digits[1]) + Integer.valueOf(uSMLE_Digits[3]) + Integer.valueOf(uSMLE_Digits[5]);
        Integer n_oddCat = Integer.valueOf(uSMLE_Digits[0] + uSMLE_Digits[2] + uSMLE_Digits[4] + uSMLE_Digits[6])*2;
        Integer n_oddSum = 0;
        while(n_oddCat >= 1){
            n_oddSum = n_oddSum + (Math.Mod(n_oddCat,10));
            n_oddCat = n_oddCat/10;
        }
        Integer valueX = n_oddSum + n_evenSum;
        Integer n_checkDigit = getCheckDigit(valueX);
        String n_checkDigitStr = String.valueOf(n_checkDigit).substring(0,1);
        if(substrUSMLEID.length() < 7){
            for(Integer i=0; i < 7-substrUSMLEID.length();i++){
                substrUSMLEID ='0'+substrUSMLEID;
            }
        }
        String newUsmleId = substrUSMLEID + n_checkDigitStr;
        if(newUsmleId == prevUSMLEID){
            return true;
        }
        else{
            return false;
        }
    }
    /* Mar 01 2021
     * @name: getCheckDigit
     * Purpose : To get check digit for usmle id generation
     * @return type: Integer
     */
    //@AuraEnabled
    private static Integer getCheckDigit(Integer valueX){
        Integer valueQ = 0;
        Integer valueZ = 0;
        Integer valueY = 0;
        if(valueX < 10){
            valueQ = 10;
        }else{
            valueY = valueX/10;
            valueZ = Math.mod(valueX, 10);
            if(valueZ > 0){
                valueQ = 10*(valueY+1);
            }else{
                valueQ = 10*valueY;
            }
        }   
        Integer n_checkDigit = valueQ - valueX;
        return n_checkDigit;
    }
    // @description: Method to check if full stop restriction is applied on the Contact
   @AuraEnabled
   public static Boolean checkRestrictOnAppIdent(){
       try{
           String contactId = getRunningContactId();
            ApplicantMyProfileController.ConWrapper conWrap = new ApplicantMyProfileController.ConWrapper();
            conWrap.contactId = contactId;
            conWrap.service = 'Identity Verification - Internal and External';
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
    @AuraEnabled
    public static void generateAccEstablshmtSummaryPDF(String caseId){
        Id docConfigId;
        Map<String, cadmus_core__Doc_Config__c> docConfigMap = new Map<String, cadmus_core__Doc_Config__c>();
        for(cadmus_core__Doc_Config__c config :[SELECT Id,cadmus_core__View_Customer_DocConfig_Id__c FROM cadmus_core__Doc_Config__c WITH SECURITY_ENFORCED]){
            docConfigMap.put(config.cadmus_core__View_Customer_DocConfig_Id__c, config);
        }
        docConfigId = docConfigMap.get(Constants.DOCCONFIG_ACCOUNT_ESTABLISHMENT_SUMMARY).Id;
        if(String.isNotBlank(docConfigId)){
            PDFButlerCallout calloutClass = new PDFButlerCallout(docConfigId, caseId);
            System.enqueueJob(calloutClass);
        }
    }
}