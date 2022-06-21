@IsTest(SeeAllData = true)
public with sharing class LightningLoginFormControllerTest {
 @IsTest
 static void testLoginWithInvalidCredentials() {
  System.assertEquals(null, LightningLoginFormController.login('testUser', 'fakepwd', null),'Login failed');
 }
 @IsTest
 static void lightningLoginFormControllerInstantiation() {
  LightningLoginFormController controller = new LightningLoginFormController();
  System.assertNotEquals(controller, null,'Instantiation failed');
 }
 @IsTest
 static void testIsUsernamePasswordEnabled() {
  System.assertEquals(true, LightningLoginFormController.getIsUsernamePasswordEnabled(), 'Username and password disabled');
 }
 @IsTest
 static void testIsSelfRegistrationEnabled() {
  System.assertEquals(false, LightningLoginFormController.getIsSelfRegistrationEnabled(),'Self Registration enabled');
 }
 @IsTest
 static void testGetSelfRegistrationURL() {
  System.assertEquals(null, LightningLoginFormController.getSelfRegistrationUrl(),'Self registration URL found');
 }
 @IsTest
 static void testAuthConfig() {
  Auth.AuthConfiguration authConfig = LightningLoginFormController.getAuthConfig();
  System.assertNotEquals(null, authConfig,'Authentication failed');
 }
 @IsTest
 static void testSetExperienceId(){
        system.assertEquals('This method can be invoked only from within a community.',LightningLoginFormController.setExperienceId('xabc123'),'Setting ExperienceId failed');
    }
 @IsTest
  static void testGetForgotPasswordURL(){
      System.assertEquals(null,LightningLoginFormController.getForgotPasswordUrl(),'Forgot password URL found');
    }
}