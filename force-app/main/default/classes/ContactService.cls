/*
    Provides service layer functionality related to Contacts.
 */
public without sharing class ContactService {

    /*
        Returns the Contact specified by contactId. If not found, returns null.
     */
    public static Contact getContact(String contactId) {

        // Basic Parameter checks
        if(contactId == null) throw new InvalidParameterException('contactId cannot be null');
        if(String.isEmpty(contactId)) throw new InvalidParameterException('contactId cannot be empty');

        try {
            return [SELECT
                    AccountId,
                    Additional_Languages_Spoken__c,
                    Applicant_Provided_EPIC_ID__c,
                    Applicant_Provided_USMLE_ID__c,
                    AssistantName,
                    AssistantPhone,
                    Birth_City__c,
                    Birth_Country__c,
                    Birth_State_Province__c,
                    Birthdate,
                    Candidate_Code__c,
                    Citizenship_at_Birth__c,
                    Citizenship_Upon_Entering_Medical_School__c,
                    Community_My_Contact__c,
                    CreatedById,
                    CreatedDate,
                    Current_Citizenship__c,
                    Currently_Employed__c,
                    Department,
                    Description,
                    DoNotCall,
                    ECFMG_ID__c,
                    EICS_ID__c,
                    Email,
                    EmailBouncedDate,
                    EmailBouncedReason,
                    Entity_Contact_Initial_Fields_Complete__c,
                    EPIC_ID__c,
                    Ethnicity__c,
                    Fax,
                    FirstName,
                    Gender__c,
                    Generational_Suffix__c,
                    Graduation_Year__c,
                    HasOptedOutOfEmail,
                    HasOptedOutOfFax,
                    HomePhone,
                    Id,
                    IndividualId,
                    IsDeleted,
                    isDuplicate__c,
                    IsEmailBounced,
                    Jigsaw,
                    JigsawContactId,
                    LastActivityDate,
                    LastCURequestDate,
                    LastCUUpdateDate,
                    LastModifiedById,
                    LastModifiedDate,
                    LastName,
                    LastReferencedDate,
                    LastViewedDate,
                    LeadSource,
                    legal_name_consists_of_one_name_only__c,
                    MailingAddress,
                    MailingCity,
                    MailingCountry,
                    MailingCountryCode,
                    MailingGeocodeAccuracy,
                    MailingLatitude,
                    MailingLongitude,
                    MailingPostalCode,
                    MailingState,
                    MailingStateCode,
                    MailingStreet,
                    MasterRecordId,
                    Medschool_Code__c,
                    MobilePhone,
                    Name,
                    Name_Change__c,
                    Name_ChangedDate__c,
                    Name_Duplicate_Check__c,
                    Native_Language__c,
                    Other_Languages_Spoken__c,
                    OtherAddress,
                    OtherCity,
                    OtherCountry,
                    OtherCountryCode,
                    OtherGeocodeAccuracy,
                    OtherLatitude,
                    OtherLongitude,
                    OtherPhone,
                    OtherPostalCode,
                    OtherState,
                    OtherStateCode,
                    OtherStreet,                                       
                    Overall_Match__c,
                    OwnerId,
                    Passport_Country__c,
                    Passport_Expiration__c,
                    Passport_Issue_Date__c,
                    Passport_Number__c,
                    Passport_Photo_Includes_Expiration_Date__c,
                    Passport_Photo_Is_In_English__c,
                    Permanent_US_Resident__c,
                    Phone,
                    Phone_Type__c,
                    PhotoUrl,
                    Previous_ECFMG_Cert_or_Examination__c,
                    Previous_EICS_ID__c,
                    Previous_EPIC_Services__c,
                    Previous_Last_Name__c,
                    Previous_Rest_of_Name__c,
                    RecordTypeId,
                    Regulatory_Org_Do_Not_Know__c,
                    ReportsToId,
                    Salutation,
                    School_Enrollment_Status__c,
                    SystemModstamp,
                    Title,
                    USMLE_ID__c, 
                    US_Social_Security__c,
                    Verification_Request_Case__c
            FROM Contact
            WHERE Id = :contactId];
        }
        catch(Exception ex) {
            return null;
        }

    }

    /**
    * @name createIndividuals
    * @description: Create Individual record for the contact and update the IndividualId on correponding contact record
    * @param List<Contact> contactList
    * @return void
    **/
    public static void createIndividuals(List<Contact> contactList)
    {
        Map<Id, Individual> individualRecordsToCreate = new Map<Id, Individual>();
        try{
            for(Contact con : contactList) {
                individualRecordsToCreate.put(con.Id, new Individual(FirstName = con.FirstName, LastName = con.LastName,
                        BirthDate=con.Birthdate));
            }
            insert individualRecordsToCreate.values();

            List<Contact> conUpdateList = new List<Contact>();
            for(Contact con : contactList) {
                //con.IndividualId = individualRecordsToCreate.get(con.Id).Id;
                conUpdateList.add(new Contact(Id=con.Id, IndividualId=individualRecordsToCreate.get(con.Id).Id));
            }
            update conUpdateList;
        }
        catch(Exception exp){
            throw new ServiceException(Label.SystemError+' '+exp);
        }
    }

    /**
    * @name updateIndividuals
    * @description: Update Individual record for the coresponding contact record
    * @param List<Contact> contactList
    * @return void
    **/
    public static void updateIndividuals(List<Contact> contactList)
    {
        List<Individual> individualRecordsToUpdate = new List<Individual>();
        try{
            for(Contact con : contactList) {
                individualRecordsToUpdate.add(new Individual(Id=con.IndividualId, FirstName = con.FirstName, LastName = con.LastName,
                        BirthDate=con.Birthdate));
            }
            update individualRecordsToUpdate;
        }
        catch(Exception exp){
            throw new TriggerException(Label.SystemError+' '+exp);
        }
    }

    /**
    * @name createUpdateHouseholdAccount
    * @description: create and associate household account with a contact
    * @param List<Contact> contactList
    * @return void
    * @modifiedBy Reshma - fixed applicant portal registration issue after winter 21 update
    **/
    public static void createUpdateHouseholdAccount(List<Id> contactIds){
        List<Account> acctList = new List<Account>();
        Map<String, Contact> contactMap = new Map<String, Contact>();
        Set<Id> conSet = new Set<Id>();
        List<Contact> contactList = [SELECT Id,LastName,Email,OwnerId,AccountId,MailingStreet,MailingCountry,MailingState,MailingPostalCode,MailingCity FROM Contact WHERE Id IN :contactIds];
        try{
            // create household account from contact last name and email address
            for(Contact itr : contactList) {
                Account acct = new Account(Name = itr.LastName + ' Household',
                        RecordTypeId = RecordTypeUtility.getRecordTypeIdByName('Account', Constants.ACCOUNT_RECORD_TYPE_HOUSEHOLD),
                        OwnerId = itr.OwnerId, Contact_Id__c = itr.Email);
                acctList.add(acct);
                contactMap.put(itr.Email, itr);
                conSet.add(itr.Id);
            }
            insert acctList;
            List<Contact> conList = new List<Contact>();
            for(Account itr: acctList){
                conList.add(new Contact(Id=contactMap.get(itr.Contact_Id__c).Id, AccountId=itr.Id, MailingStreet = null,
                        MailingCountry = null,
                        MailingState = null,
                        MailingPostalCode = null,
                        MailingCity = null));
            }
            // update household account id on contact
            update conList;

            //query AccountContactRelation records inserted via NPSP package
            Map<Id, AccountContactRelation> acctConRelMap = new Map<Id, AccountContactRelation>([SELECT Id FROM AccountContactRelation
            WHERE ContactId IN:conSet
            AND AccountId =: Label.Default_Portal_Account]);
            //delete AccountContactRelation records inserted via NPSP package
            delete acctConRelMap.values();
        }
        catch(Exception exp){
            throw new ServiceException(Label.SystemError + ' ' + exp);
        }
    }

    /**
    * @name setDuplicateCheckFields
    * @description: sets the duplicate check fields on the contact
    * @param Contact c
    * @return void
    **/
    public static void setDuplicateCheckFields(Contact c) {

        c.DC_Last_Name_Exact__c = c.LastName;
        c.DC_Last_Name_Partial__c = c.LastName;

        c.DC_Rest_of_Name_Exact__c = c.FirstName;
        c.DC_Rest_of_Name_Partial__c = c.FirstName;

        c.DC_Last_Rest_of_Name_Switch_Partial__c = c.FirstName;
        c.DC_Last_Rest_of_Name_Switch_Exact__c = c.FirstName;

        c.DC_Prev_Rest_of_Name_Exact__c = c.Previous_Rest_of_Name__c;
        c.DC_Prev_Rest_of_Name_Partial__c = c.Previous_Rest_of_Name__c;

        c.DC_Prev_Last_Name_Exact__c = c.Previous_Last_Name__c;
        c.DC_Prev_Last_Name_Partial__c = c.Previous_Last_Name__c;
        c.DC_Prev_Last_Prev_Rest_Switch_Exact__c = c.Previous_Last_Name__c;
        c.DC_Prev_Last_Prev_Rest_Switch_Partial__c = c.Previous_Last_Name__c;

        c.DC_DOB_Day_Exact__c = c.Birthdate == null ? null : String.valueOf(c.Birthdate.day());
        c.DC_DOB_Month_Exact__c = c.Birthdate == null ? null : String.valueOf(c.Birthdate.month());
        c.DC_DOB_Month_Day_Switch_Exact__c = c.Birthdate == null ? null : String.valueOf(c.Birthdate.month());
        c.DC_DOB_Year_Exact__c = c.Birthdate == null ? null : String.valueOf(c.Birthdate.year());
    }
    
     @future
     public static void deactivateUser(List<Id> Contacts) {
         List<User> userlist = new List<User>();
         if(!Contacts.isEmpty()){
             List<User> usersList = [Select Id, isActive, ProfileId from User where ContactId = : Contacts];
             for(User itr:usersList) {
                 userlist.add(new User(Id=itr.Id, IsActive=false));
             }
         }         
         if(!userlist.IsEmpty()){
             update userlist;
         }   
     }
}