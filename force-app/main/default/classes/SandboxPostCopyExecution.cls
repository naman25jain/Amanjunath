/*
 * @author Prudhvi, ECFMG.org
 * date July 2019
 * description Post Sandbox refresh activities automation
 * @Log:
 *---------------------------------------------------------------------------------
 * Developer               Date                      Description
 *---------------------------------------------------------------------------------
 * Prudhvi                07/07/2019                 Update Required User email address 
 */


global without sharing class SandboxPostCopyExecution implements SandboxPostCopy {
   
   global void runApexClass(SandboxContext context){
       string strSBName = context.sandboxName();
       updateUserEmail();
   }
  // Update required users email address after Sandbox refresh
   global void updateUserEmail(){
   
   list<User> lstuser = [Select Id, Email from User where Department='IT' and IsActive = true];
   for(User objUser: lstUser){
       //objUser.Email =objUser.Email.replace('=ecfmg.org@example.com','@ecfmg.org');
       objUser.Email =objUser.Email.removeEndIgnoreCase( '.invalid' );
   }
   if(lstUser.size()>0){
       Update lstUser;
   }
   }
}