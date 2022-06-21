/*
 * @author Prudhvi, ECFMG.org
 * date July 2019
 * description Post Sandbox refresh activities automation Test Class
 * @Log:
 *---------------------------------------------------------------------------------
 * Developer               Date                      Description
 *---------------------------------------------------------------------------------
 * Prudhvi                07/07/2019                 Update Required User email address Test Class
 */

@isTest
class SandboxPostCopyExecutionTEST{
   
   @isTest
   static void testsandboxPostCopyScript(){
       Test.startTest();
       User u = new User(profileId =[SELECT Id from Profile where Name='System Administrator'].Id,
       LastName='last',
       Email='testuser=ecfmg.org@example.com',
       Username='testuser@ecfmg.org'+system.currentTimeMillis(),
       CompanyName='ECFMG',
       Title='title',
       Department='IT',
       Alias = 'alias',
       TimeZoneSidKey = 'America/Los_Angeles',
       LanguageLocaleKey='en_US',
       LocaleSidKey='en_US',
       EmailEncodingKey='ISO-8859-1'

       );
      insert u ;
      System.assert(u.Username != Null, 'Username should not be null');
    Test.testSandboxPostCopyScript(new sandboxPostCopyExecution(), null,null,UserInfo.getOrganizationName());

    Test.stopTest();

   }

}