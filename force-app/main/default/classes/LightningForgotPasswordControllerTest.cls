@IsTest
public with sharing class LightningForgotPasswordControllerTest{
    /* Verifies that ForgotPasswordController handles invalid usernames appropriately */
    @IsTest
    static void testLightningForgotPasswordControllerInvalidUserName(){
        System.assertEquals(LightningForgotPasswordController.forgotPassword('fakeUser', 'http://a.com'), Label.Site.invalid_email, 'Redirecting');
        System.assertEquals(LightningForgotPasswordController.forgotPassword(null, 'http://a.com'), Label.Site.invalid_email,'valid username - redirecting');
        System.assertEquals(LightningForgotPasswordController.forgotPassword('a', '/home/home.jsp'), Label.Site.invalid_email,'Redirecting');
    }
    /* Verifies that null checkEmailRef url throws proper exception. */
    @IsTest
    static void testLightningForgotPasswordControllerWithNullCheckEmailRef(){
        System.assertEquals(LightningForgotPasswordController.forgotPassword('a', null), 'Argument 1 cannot be null','Returned null');
        System.assertEquals(LightningForgotPasswordController.forgotPassword('a@salesforce.com', null), 'Argument 1 cannot be null','null value returned');
    }
    /* Verifies that LightningForgotPasswordController object is instantiated correctly. */
    @IsTest
    static void lightningForgotPasswordControllerInstantiation(){
        LightningForgotPasswordController controller = new LightningForgotPasswordController();
        System.assertNotEquals(controller, null,'Controller not instantiated');
    }
    @IsTest
    static void testSetExperienceId(){
        System.assertEquals('This method can be invoked only from within a community.',LightningForgotPasswordController.setExperienceId('xabc123'),'Setting ExperienceId failed');
        System.assertEquals(null,LightningForgotPasswordController.setExperienceId(null),'Setting ExperienceId failed');
    }
}