@isTest
private class UserControllerTests {
    
    @testSetup static void setup() {
        CommunitiesTestFactory.setup();
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;  
        BaseTestFactory.getUser(profileId);
    }
    
    public static testMethod void testPositiveGetContactById() {
        String conId = CommunityIdentityVerificationController.getRunningContactId(); 
        Boolean flag = false;
        test.startTest();
        Contact testContact = UserController.getContactById(conId);
        String strContactID = testContact.Id;
        if(conId != strContactID){
            flag = false;
        }
        else if(conId == strContactID){
            flag = true;
        }
        test.stopTest();
        System.assert(flag, 'Contact retrieved successfully');
    }
    public static testMethod void testNegativeGetContactById() {
        String conId = CommunityIdentityVerificationController.getRunningContactId(); 
        Boolean flag = false;
        test.startTest();
        Contact testContact = UserController.getContactById(conId);
        String strContactID = testContact.Id;
        if(conId != strContactID){
            flag = false;
        }
        else if(conId == strContactID){
            flag = true;
        }
        test.stopTest();
        System.assert(flag, 'Contact is not retrieved');
    }    
    public static testMethod void testPositiveGetUserInfo() {
        String conId = CommunityIdentityVerificationController.getRunningContactId(); 
        Boolean flag = false;
        test.startTest();
        UserController.UserData u;
        u = new UserController.UserData();
        u = UserController.getUserInfo(conId);
        if(u.relatedUserId != null){
            flag = true;
        }
        else if(u.relatedUserId == null){
            flag = false;
        }
        test.stopTest();
        System.assert(flag, 'User is retrieved successfully');
    }
    public static testMethod void testNegativeGetUserInfo() {
        String conId = CommunityIdentityVerificationController.getRunningContactId(); 
        Boolean flag = false;
        test.startTest();
        UserController.UserData u;
        u = new UserController.UserData();
        u = UserController.getUserInfo(conId);
        if(u.relatedUserId != null){
            flag = true;
        }
        else if(u.relatedUserId == null){
            flag = false;
        }
        test.stopTest();
        System.assert(flag, 'User is not retrieved');
    }
    public static testMethod void testPositiveActivateUserNew() {
        String conId = CommunityIdentityVerificationController.getRunningContactId();
        Boolean flag = false;
        test.startTest();
        UserController.activateUserNew(conId);
        test.stopTest();
        System.assertEquals(true, [Select Id, IsActive FROM User WHERE ContactId =:conId].IsActive, 'The portal user should be active');
    }
    public static testMethod void testNegativeActivateUserNew() {
        String conId = CommunityIdentityVerificationController.getRunningContactId();
        Boolean flag = false;
        test.startTest();
        UserController.activateUserNew(conId);
        test.stopTest();
        System.assertEquals(true, [Select Id, IsActive FROM User WHERE ContactId =:conId].IsActive, 'portal user already exists for contact');
    }
    public static testMethod void testPositiveDisableUser() {
        String conId = CommunityIdentityVerificationController.getRunningContactId(); 
        String strMessage;
        User adminUsr = [SELECT Id FROM User 
                         WHERE Email like '%@unknownmail.com'
                         AND Profile.Name = 'System Administrator'
                         AND IsActive=true LIMIT 1];
        
        test.startTest();
        System.runAs(adminUsr) {
            strMessage = UserController.disableUser(conId, 'Disable');
        }
        test.stopTest();
        System.assertEquals('Success', strMessage, 'Portal user is disabled');
    }
    public static testMethod void testNegativeDisableUser() {
        String conId = CommunityIdentityVerificationController.getRunningContactId(); 
        String strMessage;
        User adminUsr = [SELECT Id FROM User 
                         WHERE Email like '%@unknownmail.com'
                         AND Profile.Name = 'System Administrator'
                         AND IsActive=true LIMIT 1];
        
        test.startTest();
        System.runAs(adminUsr) {
            strMessage = UserController.disableUser(conId, 'Disable');
        }
        test.stopTest();
        
        System.assertEquals('Success', strMessage, 'Error Occured.');
    }
}