@IsTest
public with sharing class LightningSelfRegisterControllerTest extends ECFMGTestFactory{
    /* Verifies that IsValidPassword method with various password combinations. */
    @IsTest
    static void testIsValidPassword(){
        System.assert(LightningSelfRegisterController.isValidPassword('password?@12334', 'password?@12334') == true, 'Not a valid Password');
        System.assert(LightningSelfRegisterController.isValidPassword('password?@12334', 'dummyPassword') == false, 'Not a valid Password');
        System.assert(LightningSelfRegisterController.isValidPassword('password?@12334', null) == false, 'Not a valid Password');
        System.assert(LightningSelfRegisterController.isValidPassword(null, 'fakePwd') == false, 'Not a valid Password');
    }
    @IsTest
    static void testSiteAsContainerEnabled(){
        System.assertNotEquals(null, LightningSelfRegisterController.siteAsContainerEnabled('https://portaleu1-developer-edition.eu11.force.com'), 'Value not null');
    }
    /* Verifies the selfRegistration method flow with various invalid inputs */
    @IsTest
    static void testSelfRegistration(){
        Map<String, String> paramsMap = initializeParams();
        System.assertNotEquals(null, paramsMap, 'Value is not null');
        System.assertEquals(Label.Site.lastname_is_required, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), '', paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true), 'Last name is required');
        System.assertEquals(Label.Site.email_is_required, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), '', paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true), 'Email is required');
        System.assertEquals(Label.Site.email_is_required, LightningSelfRegisterController.selfRegister(null, paramsMap.get('lastName'), '', null, paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true), 'Email is required');
        System.assertEquals(Label.site.passwords_dont_match, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordWrong'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true), 'Password does not match');
        System.assertNotEquals(null, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), '', paramsMap.get('password'), paramsMap.get('confirmPasswordWrong'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), false), 'Value is not null');
    }
    /* Verifies the selfRegistration flow for valid inputs */
    @IsTest
    static void testSelfRegisterWithProperCredentials(){
        Map<String, String> paramsMap = initializeParams();
        System.assertEquals(null, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), true), 'Value is not null');
    }
    /* Verifies SelfRegistration flow with an accounId that is created within the test */
    @IsTest
    static void testSelfRegisterWithCreatedAccount(){
        Account acc = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name='Account Test'));
        run();
        List<Account> accounts = [SELECT Id FROM Account LIMIT 1];
        System.assert(!accounts.isEmpty(), 'There must be at least one account in this environment!');
        String accountId = accounts[0].Id;
        Map<String, String> paramsMap = initializeParams();
        System.assertEquals(null, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), accountId, paramsMap.get('regConfirmUrl'), null, paramsMap.get('startUrl'), false), 'Value is not null');
    }
    @IsTest
    static void testGetNullExtraFields(){
        System.assertEquals(new List < Map < String, Object >> (), LightningSelfRegisterController.getExtraFields(null), 'Value is not null');
    }
    @IsTest
    static void testGetNonEmptyExtraFields(){
        System.assertEquals(new List < Map < String, Object >> (), LightningSelfRegisterController.getExtraFields('field1'), 'Value is not null');
    }
    /* Verifies validation of extraFields within the Self Registration flow */
    @IsTest
    static void testGetExtraFieldsInSelfRegistration(){
        List<Map<String, Object>> fieldlist = new List<Map<String, Object>>();
        Map<String, String> paramsMap = initializeParams();
        Map<String, Object> fieldMap = new Map<String, Object>();
        fieldMap.put('description', 'new field');
        fieldMap.put('fieldPath', 'dummyPath');
        fieldlist.add(fieldMap);
        String extraFields = JSON.serialize(fieldlist);
        System.assertNotEquals(null, LightningSelfRegisterController.selfRegister(paramsMap.get('firstName'), paramsMap.get('lastName'), paramsMap.get('email'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), null, paramsMap.get('regConfirmUrl'), extraFields, paramsMap.get('startUrl'), true), 'Value is not null');
    }
    @IsTest
    static void LightningSelfRegisterControllerInstantiation(){
        LightningSelfRegisterController controller = new LightningSelfRegisterController();
        System.assertNotEquals(controller, null, 'Value is not null');
    }
    /* Helper method to initialize the parameters required for SelfRegistration. */
    private static Map < String, String > initializeParams(){
        Map<String, String> paramsMap = new Map<String, String>();
        String firstName = 'test';
        String lastName = 'User';
        String email = 'testUser@salesforce.com';
        String password = 'testuser123';
        String confirmPasswordCorrect = 'testuser123';
        String confirmPasswordWrong = 'wrongpassword';
        String accountId = 'testuser123';
        String regConfirmUrl = 'http://registration-confirm.com';
        String startUrl = 'http://my.company.salesforce.com';
        paramsMap.put('firstName', firstName);
        paramsMap.put('lastName', lastName);
        paramsMap.put('email', email);
        paramsMap.put('password', password);
        paramsMap.put('confirmPasswordCorrect', confirmPasswordCorrect);
        paramsMap.put('confirmPasswordWrong', confirmPasswordWrong);
        paramsMap.put('accountId', accountId);
        paramsMap.put('regConfirmUrl', regConfirmUrl);
        paramsMap.put('startUrl', startUrl);
        return paramsMap;
    }
    @IsTest
    static void testSetExperienceId(){
        system.assertEquals('This method can be invoked only from within a community.' , LightningSelfRegisterController.setExperienceId('xabc123'),'Setting ExperienceId failed');
    }
}