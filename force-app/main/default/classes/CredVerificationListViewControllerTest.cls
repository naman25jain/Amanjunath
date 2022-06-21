@isTest
public class CredVerificationListViewControllerTest{
    @isTest
    public static void getEntityTest(){
        CloudDataTestFactory.createCloudConfig();
        CurrentECFMGIDSequence__c curECFMGSetting = CurrentECFMGIDSequence__c.getOrgDefaults();
        curECFMGSetting.ECFMG_ID__c = '00000001';
        upsert curECFMGSetting;
        System.assert(curECFMGSetting.Id!=null,'ecfmg sequence id setting not found');
        CurrentEntityIDSequence__c curEntitySetting = CurrentEntityIDSequence__c.getOrgDefaults();
        curEntitySetting.Entity_ID__c = '0000000';
        upsert curEntitySetting;
        System.assert(curEntitySetting.Id!=null,'Entity sequence id setting not found');
        String email1 = 'testUser@gmail.com';
        String country = 'America/Los_Angeles';
        String country2 = 'United States';
        Id idAccountTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_DEV_ENTITY).getRecordTypeId();
        Account acct = new Account(Name = 'Entity Account', RecordTypeId = idAccountTypeId, School__c = true,BillingCountry='India');
        insert acct;
        System.assert(acct.Id!=null,'Account not found!');
		Id idContactTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_ENTITY_CONTACT).getRecordTypeId();
        Contact con = new Contact(FirstName = 'Entity', LastName = 'User', RecordTypeId = idContactTypeId, Email = email1, AccountId = acct.Id);
        insert con;
        System.assert(con.Id!=null,'Cotact not found!');
        Contact con2 = new Contact(FirstName = 'Second', LastName = 'Contact', RecordTypeId = idContactTypeId, Email = 'email@gmail.com', AccountId = acct.Id, Active_Entity_Portal_User__c = TRUE);
        insert con2;
        System.assert(con2.Id!=null,'Cotact not found!');
        Id p=[Select id from profile where name='4-Customer Community Entity 360' LIMIT 1].id;
        User user = new User(alias='eUser',email=email1,emailencodingkey='UTF-8',lastname='User', languagelocalekey='en_US',localesidkey='en_US',profileid=p,country=country2,IsActive=true,ContactId=con.Id, timezonesidkey=country,username=email1);
        insert user;
        System.assert(user.Id!=null,'User not found!');
        Service__c serv = new Service__c(Name = Constants.SERVICE_NAME_CREDENTIAL_VERIFICATION, Signature_Required__c = TRUE, Seal_Required__c = TRUE);
        insert serv;
        System.assert(serv.Id!=null,'Service is not inserted');
        Account2Service__c acc2Service = new Account2Service__c(Account__c = acct.Id, Active__c = TRUE, Service__c = serv.Id);
        insert acc2Service;
        System.assert(acc2Service.Id!=null,'Account2Service is not inserted');
        CONTACT2ACCTSERVICE__c conService = new CONTACT2ACCTSERVICE__c(Account_Service__c = acc2Service.Id, Role__c = 'Coordinator', Service_Contact__c=con.Id, Credential_Type__c = 'Certificate of Good Standing');
        insert conService;
        System.assert(conService.Id!=null,'Contact2Service is not inserted');
        Id credVerfcnRecTypId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        Case caseobj2 = new Case();
        caseobj2.ContactId = con.Id;
        caseobj2.AccountId = con.AccountId;
        caseobj2.Entity__c = acct.Id;
        caseobj2.Internal_Status__c = Constants.CASE_STATUS_SENT_FOR_VERIFICATION;
        caseobj2.Subject = 'test';
        caseObj2.Priority = 'Medium';
        caseObj2.RecordTypeId = credVerfcnRecTypId;
        caseObj2.Service__c = 'EICS';
        insert caseObj2;
        System.assert(caseObj2.Id!=null,'Case not found!');
        Id affCVRecordTypeId = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get(Constants.AFFIRMATION_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        Affirmation__c affirmation = new Affirmation__c();
        affirmation.RecordTypeId = affCVRecordTypeId;
        affirmation.Case__c = caseObj2.Id;
        affirmation.Verify_with_Alternate_Entity__c = false;
        insert affirmation;
        System.assert(affirmation.Id != null, 'Affirmation creation failed');        
        Verification_Packet__c verPack = new Verification_Packet__c();
        verPack.Is_Active__c = true;
        verPack.Case__c	= caseObj2.Id;
        verPack.Contact__c = con2.Id;
        INSERT verPack;
        System.assert(verPack.Id!=null,'Verification Packet not found!');
        Send_Request__c sendReq = new Send_Request__c();
        sendReq.Verification_Packet__c = verPack.Id;
        sendReq.Send_Method__c = 'Entity Portal';
        sendReq.Verification_Packet__c = verPack.Id;
        sendReq.Current_Send_Date__c = Date.today();
        INSERT sendReq;
        System.assert(sendReq.Id!=null,'Send Request not found!');
        system.runAs(user){
        Test.startTest();
        CredVerificationListViewController.getCaseRecords(acct.Id,null,null);
        CredVerificationListViewController.getCaseRecords(acct.Id,con2.Id,caseObj2.Id);
        Test.stopTest();
        }
    }
}