/**
 * * Sampath Karnati 
 * * Test Factory class for Common Set up
 * ? Exposed as Public
 */
@isTest
public class BaseTestFactory {

    // Constatnts
    public static final String REGEX_INVALID_NUMBERS = '[^0-9]';

    /**
    * * Sampath Karnati 
    * * Create a new user with '4-Customer Community Plus Login' Profile 
    */
    public static User getCustomerCommunityPlusUser() {

        // Create Contact
        Contact contact = getContact();

        // Get Profile
        Profile prof = getProfile(ConstantsTest.TEST_PROFILE_COMMUNITY_LOGIN);

        //create a new User
        return getContactUser(contact.Id, prof.id);

    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    /**
    * * Sampath Karnati 
    * * Create a new user with 'Salesforce Viewer' Profile 
    */
    public static User getSalesforceViewerUser() {

        // Get Profile
        Profile prof = getProfile(ConstantsTest.TEST_PROFILE_SALESFORCE_VIEWER);

        //create a new User
        return getUser(prof.id);
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    /**
    * * Sampath Karnati 
    * * Create a new user with 'Read Only' Profile 
    */
    public static User getReadOnlyUser() {

        // Get Profile
        Profile prof = getProfile(ConstantsTest.TEST_PROFILE_READONLY);

        //create a new User
        return getUser(prof.id);
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    /**
    * * Sampath Karnati 
    * * Create a new contact
    */
    public static Contact getContact() {
        
        // Create Contact (testCounter is incremented to bypass duplicate rules if any)
        Contact contact = new Contact(Firstname=getRandomName(ConstantsTest.TEST_NAME),
                                 Lastname=getRandomName(ConstantsTest.TEST_NAME),
                                 Birthdate=ConstantsTest.TEST_DOB,
                                 email=getRandomEmail(ConstantsTest.TEST_EMAIL),
                                 MailingCountry=ConstantsTest.TEST_COUNTRY);
        insert contact;
        
        return contact;
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    /**
    * * Sampath Karnati 
    * * Get Profile with matching profile name
    * @param name Profile Name
    */
    public static Profile getProfile(String name) {

        // Get Profile
        PROFILE prof = [SELECT id FROM PROFILE
                           WHERE name =: name 
                           LIMIT 1];
        
        return prof;
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    /**
    * * Sampath Karnati 
    * * Create a new user associated with Contact
    */
    public static User getContactUser(Id contactId, Id profileId) {

        // unique user name
        string userName =   getRandomUserName(ConstantsTest.TEST_USERNAME);


        //create a new User row
        User user = new User(alias=ConstantsTest.TEST_USER_ALIAS,
                             email=getRandomEmail(ConstantsTest.TEST_EMAIL),
                             emailencodingkey=ConstantsTest.TEST_ENCODING_KEY,
                             lastname=getRandomName(ConstantsTest.TEST_NAME), 
                             languagelocalekey=ConstantsTest.TEST_LANGUAGE_KEY,
                             localesidkey=ConstantsTest.TEST_LANGUAGE_KEY,
                             profileid=profileId,
                             country=ConstantsTest.TEST_COUNTRY,
                             IsActive=true,
                             ContactId=contactId, 
                             timezonesidkey=ConstantsTest.TEST_TIMEZONE,
                             username=userName);

        insert user;

        return user;   
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
     /**
    * * Sampath Karnati 
    * * Create a new user without Contact
    */
    public static User getUser(Id profileId) {

        // unique user name
        string userName =   getRandomUserName(ConstantsTest.TEST_USERNAME);
    
        //create a new User row
        User user = new User(alias=ConstantsTest.TEST_USER_ALIAS,
                             email=getRandomEmail(ConstantsTest.TEST_EMAIL),
                             emailencodingkey=ConstantsTest.TEST_ENCODING_KEY,
                             lastname=getRandomName(ConstantsTest.TEST_NAME), 
                             languagelocalekey=ConstantsTest.TEST_LANGUAGE_KEY,
                             localesidkey=ConstantsTest.TEST_LANGUAGE_KEY,
                             profileid=profileId,
                             country=ConstantsTest.TEST_COUNTRY,
                             IsActive=true, 
                             timezonesidkey=ConstantsTest.TEST_TIMEZONE,
                             username=userName);
        
        insert user;

        return user;   
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    /**
    * * Sampath Karnati 
    * * Create a new random number between 0 and max
    * @param max maximum value limit
    */
    public static Integer getRandomNumber(Integer max) {

       return Integer.valueof((Math.random() * max));
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    /**
    * * Sampath Karnati 
    * * Create a new random user name
    * @param userName Start with this
    */
    public static string getRandomUserName(string userName) {

        // unique user name (userName + System.now(withoutspecialcharacters) + Random Number + email domain)
        return (userName + 
                ((System.Now() + '').replaceAll(REGEX_INVALID_NUMBERS, '')) + 
                String.valueOf(getRandomNumber(1000)) +
                ConstantsTest.TEST_EMAIL_DOMAIN);
     }
     /////////////////////////////////////////////////////////////////////////////////////////////////////////
    /**
    * * Sampath Karnati 
    * * Create a new random email
    * @param userName Start with this
    */
    public static string getRandomEmail(string email) {

        // unique email (email(withoutdomain) + System.now(withoutspecialcharacters) + Random Number + email domain)
        return (email + 
                ((System.Now() + '').replaceAll(REGEX_INVALID_NUMBERS, '')) + 
                String.valueOf(getRandomNumber(1000)) +
                ConstantsTest.TEST_EMAIL_DOMAIN);
     }
     /////////////////////////////////////////////////////////////////////////////////////////////////////////
    /**
    * * Sampath Karnati 
    * * Create a new random name
    * @param userName Start with this
    */
    public static string getRandomName(string name) {

        // unique name (name + System.now(withoutspecialcharacters) + Random Number)
        return (name + 
                ((System.Now() + '').replaceAll(REGEX_INVALID_NUMBERS, '')) + 
                String.valueOf(getRandomNumber(1000)));
     }
     ////////////////////////////////////////////////////////////////////////////////////////////////////////
       /**
    * * Sampath Karnati 
    * * Create a new pdf attachment
    */
    public static Attachment getPDFAttachment(Id parentId) {

        // Create new attachment
        Attachment attachment = new Attachment();
        attachment.Name = ConstantsTest.TEST_NAME;
        attachment.parentId = parentId;
        attachment.Body = Blob.valueOf(ConstantsTest.TEST_BASE64_PDF_ATTACHMENT);
        attachment.ContentType = ConstantsTest.TEST_PDF_CONTENT_TYPE;
                                               
        insert attachment;
 
        return attachment;
     }
    
    /************************
    * @Author: Naresh
    * @Description: Insert CurrentECFMGIDSequence__c custom setting.
    */
    public static void insertEcfmgSequence() {
        CurrentECFMGIDSequence__c ecfmgRec = new CurrentECFMGIDSequence__c(ECFMG_ID__c='1');
        insert ecfmgRec;
    }
}