/**
    * @author: Shailaja Yerneni
    * @name: UserController
    * @description: This class runs in system mode. Activates portal (Applicant & Entity 360) users and deactivates them.
    * Depending on the record type - Entity Contact (Entity 360)
    * Applicant & Registered User - Applicant 360
    * @createdDate: 03-Feb-2021
**/

public without sharing class UserController {
    @AuraEnabled
    public static Contact getContactById(String contactId) {
        Contact currentContact = [
            Select Id, name, FirstName, LastName, Birthdate, Birth_Country__c, Email, Generational_Suffix__c, AccountId,
                    legal_name_consists_of_one_name_only__c, Phone, Department, Title, Gender__c, Active_Entity_Portal_User__c,
                    Entity_Contact_Initial_Fields_Complete__C, Account.Owner.Id, Account.Owner.Name,
                    Account.RecordType.DeveloperName, Account.Owner.UserRole.Name, Account.Owner.UserRoleId, Contact.RecordType.DeveloperName
                From Contact
                Where Id = :contactId
        ];
        return currentContact;
    }

    /**
     * Created by Shailaja on 02/05/2021
     * Method Name: activateUserNew
     * Purpose : Method to activate portal user depending on the contact record type.
     *              Called from modal component on Contact Quick action :- Enable Portal Access
     * Return Type : 
     */
    @AuraEnabled
    public static void activateUserNew(String contactId) {
        Contact c = getContactById(contactId); // get existing contact
        String profileName;
        //recordtype name is Applicant or Registered User - 4-Customer Community Plus Login
        //recordtype name is Entity Contact - 4-Customer Community Entity 360
        if(c.RecordType.DeveloperName == Constants.CONTACT_RECORD_TYPE_APPLICANT || c.RecordType.DeveloperName == Constants.CONTACT_RECORD_TYPE_REGISTERED){
            profileName = Constants.Applicant_360_USER_PROFILE;            
        }else if(c.RecordType.DeveloperName == Constants.CONTACT_RECORD_TYPE_ENTITY_CONTACT){
            profileName = Constants.Entity_360_USER_PROFILE;
        }

        List<Profile> pL = [SELECT Id, Name FROM Profile WHERE Name =: profileName];
        if (pL.isEmpty()) {
            throw new CommunityException('Profile Name is empty. Profile name should be 4-Customer Community Entity 360 or 4-Customer Community Plus Login');
        }
        if (String.isBlank(c.AccountId) || c.Account.RecordType.DeveloperName != 'HH_Account') {
            // Create new account for the existing contact
            Id houseHoldAccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('HH_Account').getRecordTypeId();
            Account newAccount = new Account (Name = c.LastName + ' Household', RecordTypeId = houseHoldAccountRecTypeId, OwnerId = UserInfo.getUserId());
            insert newAccount;
            c.AccountId = newAccount.Id;
            update c;
        }
        // Future method to create user
        createUserFromContact(new Set<Id>{
                c.Id
        },profileName);
    }

    /**
     * Created by Shailaja on 02/05/2021
     * Method Name: createUserFromContact
     * Purpose : Method to create a new user record for the contactId and given profile name
     * Return Type : 
     */
    private static void createUserFromContact(Set<Id> contactIds, String profileName) {
        Community_Settings__c settings = Community_Settings__c.getOrgDefaults();
        List<Id> idList = new List<Id>(contactIds);
        Id contactId = idList[0];
        Contact c = getContactById(contactId); // get existing contact
        List<Profile> pL;
        pL = [SELECT Id, Name FROM Profile WHERE Name =: profileName];
        if (pL.isEmpty()) {
            throw new CommunityException('Profile Name is empty. Profile name should be 4-Customer Community Entity 360 or 4-Customer Community Plus Login');
        }
        
        List<User> userList = new List<User>();
        // Nickname default
        String nickname = '';
        if (nickname.length() > 0) {
            nickname = c.FirstName.substring(0, 1);
        }
        nickname = nickname + c.LastName;
        if (nickname.length() > 20) {
            nickname.substring(0, 20);
        }
        String alias = '';
        if (nickname.length() > 8) {
            alias = nickname.substring(0, 7);
        } else {
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
        try {
            insert userList;
            c.Active_Entity_Portal_User__c = true;
            update c;            
        } catch (Exception e) {
            System.debug('ERROR: ' + e.getMessage());
        }
    }

    /**
     * Created by Shailaja on 02/05/2021
     * Method Name: getUserInfo
     * Purpose : Method to retrieve a user record for given contactId
     * Return Type : User
     */
    @AuraEnabled
    public static UserData getUserInfo(String contactId) {
        UserData userData = new UserData();
        userData.currentUser = [SELECT Id, Name, UserRoleId FROM User WHERE Id = :UserInfo.getUserId()];
        List<User> uL = [SELECT Id, ContactId, IsActive, IsPortalEnabled, Disable_Date__c, UserRoleId FROM User WHERE ContactId = :contactId];
        if (uL.size() == 0) {
            userData.hasRelatedUser = false;
        } else {
            userData.hasRelatedUser = true;
            userData.relatedUserId = uL[0].Id;
        }
        return userData;
    }

    public class UserData {
        @AuraEnabled public User currentUser;
        @AuraEnabled public Boolean hasRelatedUser;
        @AuraEnabled public String relatedUserId;
    }

    /**
     * Created by Shailaja on 02/05/2021
     * Method Name: disableUser
     * Purpose : Method to deactivate portal user depending on the contact.
     *              Called from modal component on Contact Quick action :- Disable Portal Access
     * Return Type : String
     */
    @AuraEnabled
    public static String disableUser(String contactId, String details) {
        List<User> uL = [Select Id, UserName, ContactId, IsActive, IsPortalEnabled, Disable_Date__c FROM User WHERE ContactId = :contactId];
        if (uL.size() == 0) {
            return 'Error: Not a valid community user';
        } else {
            User u = uL[0];
            addNote(contactId, 'User Disabled By: ' + UserInfo.getUserName(), 'Disabled User Activity has taken place.  The ' + u.UserName + ' was deactivated on ' + System.Now() + ' by ' + UserInfo.getUserName() + '. The User disabled comments are: ' + details);
            if (u.IsActive && u.IsPortalEnabled) {
                u.IsActive = false;
                u.IsPortalEnabled = false;
                u.Disable_Comments__c = 'Disabled By ' + UserInfo.getUserName() + '. ' + details;
                u.Disable_Date__c = System.Today();
                try {
                    update u;
                    return 'Success';
                } catch (Exception e) {
                    return 'Error: ' + e.getMessage();
                }
            } else {
                return 'Error: Not a valid community user';
            }
        }
    }
    /**
     * Created by Shailaja on 02/05/2021
     * Method Name: addNote
     * Purpose : Method to create a note.
     * Return Type : 
     */
    @Future
    private static void addNote(String parentId, String title, String body) {
        ContentNote cn = new ContentNote(Title = title, Content = Blob.valueOf(body.escapeHTML4()));
        insert cn;
        insert new ContentDocumentLink(ContentDocumentId = cn.Id, LinkedEntityId = parentId, ShareType = 'I', Visibility = 'AllUsers');
    }
}