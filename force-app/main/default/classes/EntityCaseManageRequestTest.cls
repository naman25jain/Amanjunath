/**
* Test Class for EntityCaseManageRequest class
*
* @author        Enable Consulting
* @version       1.0
* @createdDate   3-Sep-2020
*/
@isTest
public class EntityCaseManageRequestTest {
    public static testMethod void getEntityRequestDataTest(){
        
        Id idAccountTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account acct = new Account(Name = 'Entity Account', RecordTypeId = idAccountTypeId, School__c = true,
                                   BillingCountry='United States',
                                   BillingStreet='1234 ECFMG Drive',
                                   BillingCity='Philadelphia',
                                   BillingPostalCode='19112',
                                   BillingState='Alaska');
        insert acct;
		Id entityUserRecordTypeId     =   Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENTITY_USER_REQUEST).getRecordTypeId();
        Id idContactTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Entity_Contact').getRecordTypeId();
        String email1 = 'testUser@gmail.com';
        String country = 'America/Los_Angeles';
        String country2 = 'United States';
        Contact con = new Contact(FirstName = 'Entity', LastName = 'User', RecordTypeId = idContactTypeId, Email = email1, AccountId = acct.Id);
        insert con;

        Id p=[Select id from profile where name='4-Customer Community Entity 360' LIMIT 1].id;
        User user = new User(alias='eUser',email=email1,emailencodingkey='UTF-8',lastname='User', languagelocalekey='en_US',localesidkey='en_US',profileid=p,country=country2,IsActive=true,ContactId=con.Id, timezonesidkey=country,username=email1);
        insert user;

         // Case
         Case caseobj = new Case();
         caseobj.ContactId = con.Id;
         caseobj.AccountId = con.AccountId;
         caseobj.Entity__c = con.AccountId;
         caseobj.Internal_Status__c = Constants.CASE_STATUS_INCOMPLETE; 
         caseObj.Subject = 'test';
         caseObj.Priority = 'Medium';
         caseObj.RecordTypeId = entityUserRecordTypeId;
         insert caseObj;

         Case caseobj2 = new Case();
         caseobj2.ContactId = con.Id;
         caseobj2.AccountId = con.AccountId;
         caseobj2.Entity__c = con.AccountId;
         caseobj2.Internal_Status__c = Constants.CASE_STATUS_PENDING_USER_ACCESS; 
         caseobj2.Subject = 'test';
         caseObj2.Priority = 'Medium';
         caseObj2.RecordTypeId = entityUserRecordTypeId;
         insert caseObj2;
         
         system.runAS(user){
            Map<String, Map<String, String>> getEntMap = new Map<String, Map<String, String>> ();
            getEntMap = EntityCaseManageRequest.getEntityRequestData(acct.Id);
            System.assertEquals(true, getEntMap.size() > 0,'Size is not greater than 0');

            Map<String, Map<String, String>> getEntMapComp = new Map<String, Map<String, String>> ();
            getEntMapComp = EntityCaseManageRequest.getEntityCompletedRequestData(acct.Id);
            System.assertEquals(true, getEntMapComp.size() > 0,'Size is not greater than 0 in completed request data');
         }
    }
}