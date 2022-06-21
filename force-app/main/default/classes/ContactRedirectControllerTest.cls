/** @name: ContactRedirectControllerTest
 *  @description: test class for the apex class: ContactRedirectController
**/
@isTest
public with sharing class ContactRedirectControllerTest {
    @testSetup
    static void setup() {
        Account acct = new Account(
            Name = 'Test Entity Account',
            BillingCountry ='Bhutan',
            RecordTypeId = RecordTypeUtility.getRecordTypeIdByName('Account', Constants.ACCOUNT_RECORD_TYPE_ENTITY),
            Medschool_Code__c = 'MED001'
        );
       insert acct;
       
       Contact c = new Contact(LastName = 'Contact Last Name', AccountId = acct.id);
       insert c;
       User u = new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = '4-Customer Community Plus Login'].Id,
                LastName = 'last',
                Email = 'puser000@amamama.com',
                Username = 'puser000@amamama.com' + System.currentTimeMillis(),
                CompanyName = 'TEST',
                Title = 'title',
                Alias = 'alias',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
               ContactId =c.id
            );
            insert u;
    }

    @isTest
    public static void ContactRedirectMethod(){
        user u = [select id,contactId from user where Email = 'puser000@amamama.com' limit 1];
        System.runAs(u){  
            ContactRedirectController.redirect();
        }

    }
}