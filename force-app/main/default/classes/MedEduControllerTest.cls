@isTest
public with sharing class MedEduControllerTest extends ECFMGTestFactory{
    Static final String DAY='12/1/1996';
    Static final String CASE_INSERTION_ERROR='Case is not inserted';
    Static final String CONTACT_QUERY_ERROR='Contact is null';
    Static final String USER_QUERY_ERROR='User is null';
    Static final String CAT_REC_INSERTION_ERROR='CAT record is not inserted';
    Static final String ACCOUNT_NOT_INSERTED='Account not created here'; 
    @testSetup static void setup(){
        CloudDataTestFactory.createCloudConfig();
        CurrentECFMGIDSequence__c curECFMGSetting=CurrentECFMGIDSequence__c.getOrgDefaults();
        curECFMGSetting.ECFMG_ID__c='00000001';
        upsert curECFMGSetting;
        System.assert(curECFMGSetting.Id!=null,'ecfmg sequence id setting not found');
        CurrentEntityIDSequence__c curEntitySetting=CurrentEntityIDSequence__c.getOrgDefaults();
        curEntitySetting.Entity_ID__c='0000000';
        upsert curEntitySetting;
        System.assert(curEntitySetting.Id!=null,'Entity sequence id setting not found');
        Id applRecTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_APPLICANT ).getRecordTypeId();
        Id recTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_ENTITY).getRecordTypeId(); 
        Account acc=new Account();
        acc.Name='Test Account';
        acc.Unique_Medical_School_ID__c='TA123';
        acc.RecordTypeId = recTypeId;
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, acc);
        run();
        System.assert(acc.Id!=null,'Account not created');
        Contact con=new Contact();
        con.AccountId =acc.Id;
        con.LastName='Test';
        con.Email='test1@test.com';
        con.Birthdate=Date.parse(DAY);
        con.RecordTypeId=applRecTypeId;
        INSERT con;
        System.assert(con.Id!=null,'Contact not created');
        Id profId=[Select id from profile where name='4-Customer Community Entity 360' LIMIT 1].Id;
        User user1=new User(alias='testUser',
                              email='test2@test.com',
                              emailencodingkey='UTF-8',
                              lastname='test user',
                              languagelocalekey='en_US',
                              localesidkey='en_US',
                              profileid=profId,
                              country='United States',
                              IsActive=true,
                              ContactId=con.Id,
                              timezonesidkey='America/Los_Angeles',
                              username='testuser@test.com');
        INSERT user1;
        System.assert(user1.Id!=null,'User not found');
    }
    @istest
    public static void createMedEduFormTest(){
        Contact cont=[SELECT Id FROM Contact LIMIT 1];
        System.assert(cont.Id!=null,CONTACT_QUERY_ERROR);
        User usr=[SELECT Id,ContactId FROM User WHERE username='testuser@test.com' LIMIT 1];
        System.assert(usr.Id!=null,USER_QUERY_ERROR);
        Account newAcct = [SELECT Id FROM Account LIMIT 1];
        Id medEduRTId=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_MED_EDU_FORM).getRecordTypeId();
        Case caseRecord=new Case();
        caseRecord.Internal_Status__c=Constants.CASE_STATUS_SUBMITTED_IN_REVIEW;
        caseRecord.RecordTypeId=medEduRTId;
        caseRecord.Service__c='EPIC';
        caseRecord.ContactId=cont.Id;
        caseRecord.Entity__c=newAcct.Id;
        caseRecord.Alternate_Entity__c=newAcct.Id;
        INSERT caseRecord; 
        System.assert(caseRecord.Id!=null,CASE_INSERTION_ERROR);
        Id assetRecTypeId=Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_MED_EDU_FORM).getRecordTypeId();   
        Asset asst1=new Asset(Name=Constants.ASSET_TYPE_MED_EDU_FORM,
                                Status=Constants.ASSET_STATUS_NEW,
                                ContactId=usr.contactId,
                                Case__c=caseRecord.Id,
                                InstallDate=System.Today(),
                                Type__c=Constants.ASSET_TYPE_MED_EDU_FORM,
                                RecordTypeId=assetRecTypeId);
        INSERT asst1;
        System.assert(asst1.Id!=null,'failed to insert here ');
        cadmus_core__Doc_Config__c docConfig=new cadmus_core__Doc_Config__c();
        docConfig.Name='Medical Education Form';
        docConfig.RecordTypeId=Schema.SObjectType.cadmus_core__Doc_Config__c.getRecordTypeInfosByDeveloperName().get('MAIN').getRecordTypeId();
        docConfig.cadmus_core__Delivery_option__c='BASE64';
        INSERT docConfig;
        System.assert(docConfig.Id!=null,'Failed to insert Doc Config Record! here');
        Verification_Packet__c verPack=new Verification_Packet__c();
        verPack.Is_Active__c=true;
        verPack.Case__c	= caseRecord.Id;
        verPack.Contact__c=cont.Id;
        INSERT verPack;
        System.assert(verPack.Id!=null,'Verification Packet not found!');
        Id affRecTypeId=Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get(Constants.AFFIRMATION_RECORD_TYPE_MED_EDU_FORM).getRecordTypeId();
        Affirmation__c aff=new Affirmation__c();
        aff.Verify_with_Alternate_Entity__c=false;
        aff.Case__c=caseRecord.Id;
        aff.RecordTypeId=affRecTypeId;
        INSERT aff;
        System.assert(aff.Id!=null,'Affirmation record not inserted');
        Asset2Verification__c a2v=new Asset2Verification__c();
        a2v.Verification_Packet__c=verPack.Id; 
        a2v.Document_Type__c=Constants.ASSET_TYPE_RETURNED_VERIFICATION_FORM;
        a2v.Asset__c=asst1.Id;
        INSERT a2v;
        System.assert(a2v.Id!=null,'a2v record not inserted');
        String error='';
        try{
            Test.startTest();
            MedEduController.createMedEduForm(string.valueOf(caseRecord.Id));
            Asset asstMarkedDelete=[SELECT Id,Status FROM Asset WHERE Id=:asst1.Id];
            System.assertEquals(Constants.ASSET_STATUS_MARKED_FOR_DELETION,asstMarkedDelete.Status,'Asset not marked for deletion');
            aff.Verify_with_Alternate_Entity__c=true;
            UPDATE aff;
            System.assert(aff.Id!=null,'Affirmation record not updated');
            MedEduController.createMedEduForm(string.valueOf(caseRecord.Id));
            List<Asset> asstList=[SELECT Id FROM Asset WHERE Name=:Constants.ASSET_NAME_RETURNED_MED_EDU_FORM AND Case__c=:caseRecord.Id AND
                                    Type__c=:constants.ASSET_TYPE_MED_EDU_FORM AND Status=:constants.ASSET_STATUS_NEW];
            System.assert(!asstList.isEmpty(),'assetList is empty');
            Test.stopTest();
        }
        catch(Exception ex){
            error=ex.getMessage();
        }
        system.assertEquals(error,'','Error occured');
    }
    @istest
    public static void updateCaseStatusTest(){
        Contact cont=[SELECT Id FROM Contact LIMIT 1];
        System.assert(cont.Id!=null,CONTACT_QUERY_ERROR);
        User usr=[SELECT Id,ContactId FROM User WHERE username='testuser@test.com' LIMIT 1];
        System.assert(usr.Id!=null,USER_QUERY_ERROR);
        Id recTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_ENTITY).getRecordTypeId();            
        Account newAcct = [SELECT Id FROM Account LIMIT 1];
        Id medEduRTId=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_MED_EDU_FORM).getRecordTypeId();
        Case caseRecord=new Case();
        caseRecord.Internal_Status__c=Constants.CASE_STATUS_SUBMITTED_IN_REVIEW;
        caseRecord.RecordTypeId=medEduRTId;
        caseRecord.Service__c='EPIC';
        caseRecord.ContactId=cont.Id;
        caseRecord.Entity__c=newAcct.Id;
        caseRecord.Alternate_Entity__c=newAcct.Id;
        INSERT caseRecord; 
        System.assert(caseRecord.Id!=null, CASE_INSERTION_ERROR);
        Id assetRecTypeId=Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_MED_EDU_FORM).getRecordTypeId();   
        Asset asst1=new Asset(Name=Constants.ASSET_NAME_RETURNED_MED_EDU_FORM,
                                Status=Constants.ASSET_STATUS_NEW,
                                ContactId=usr.contactId,
                                Case__c=caseRecord.Id,
                                InstallDate=System.Today(),
                                Type__c	= Constants.ASSET_TYPE_MED_EDU_FORM,
                                RecordTypeId=assetRecTypeId);
        INSERT asst1;
        System.assert(asst1.Id!=null,'failed to insert here ');
        Verification_Packet__c verPack=new Verification_Packet__c();
        verPack.Is_Active__c=true;
        verPack.Case__c	= caseRecord.Id;
        verPack.Contact__c=cont.Id;
        INSERT verPack;
        System.assert(verPack.Id!=null,'Verification Packet not inserted');
        Send_Request__c sr= new Send_Request__c();
        sr.Verification_Packet__c=verPack.Id;
        sr.Send_Method__c='Entity Portal';
        INSERT sr;
        System.assert(sr.Id!=null,'Verification Packet not inserted');
        String error='';
        try{
            Test.startTest();
            MedEduController.updateCaseStatus(string.valueOf(caseRecord.Id));
            Case updatedCase=[SELECT Id,Status FROM Case WHERE Id=:caseRecord.Id];
            System.assertEquals(Constants.ASSET_STATUS_MARKED_FOR_DELETION,updatedCase.Internal_Status__c,'Case status not updated');
            Asset updatedAsst=[SELECT Id,Status FROM Asset WHERE Id=:asst1.Id];
            System.assertEquals(Constants.ASSET_STATUS_ACCEPTED,updatedAsst.Status,'Asset status not updated');
            Send_Request__c updatedSr=[SELECT id,Received_Date__c FROM Send_Request__c WHERE Id=:sr.Id];
            System.assert(updatedSr.Received_Date__c!=NULL,'Received date not updated');
            Test.stopTest();
        }
        catch(Exception ex){
            error=ex.getMessage();
        }
    }
    @isTest
    public static void fetchCATrecord(){
        Contact cont=[SELECT Id FROM Contact LIMIT 1];
        System.assert(cont.Id!=null,CONTACT_QUERY_ERROR);
        Id recTypeId=GenericUtilities.getRecordTypeIdByDevName('Account',Constants.ACCOUNT_RECORD_TYPE_ENTITY);
        Account newAcct = [SELECT Id FROM Account LIMIT 1];
        Id medEduRTId=GenericUtilities.getRecordTypeIdByDevName('Case',Constants.CASE_RECORD_TYPE_MED_EDU_FORM);
        Case caseRecord=new Case();
        caseRecord.Internal_Status__c=Constants.CASE_STATUS_SUBMITTED_IN_REVIEW;
        caseRecord.RecordTypeId=medEduRTId;
        caseRecord.Service__c='EPIC';
        caseRecord.ContactId=cont.Id;
        caseRecord.Entity__c=newAcct.Id;
        caseRecord.Alternate_Entity__c=newAcct.Id;
        INSERT caseRecord;
        User us = [SELECT id FROM User WHERE email ='test2@test.com'];
        System.runAs(us){
            System.assert(caseRecord.Id!=null,CASE_INSERTION_ERROR);
            system.assertEquals(null,MedEduController.getMedEduCAT(caseRecord.Id), 'CAT record returned');
            Contact_Association_Type__c contAcctType=new Contact_Association_Type__c();
            contAcctType.Case__c=caseRecord.Id;
            contAcctType.Account__c=newAcct.Id;
            contAcctType.Contact__c=cont.Id; 
            contAcctType.RecordTypeId=GenericUtilities.getRecordTypeIdByDevName('Contact_Association_Type__c',system.label.CAT_Medical_Education_Questionnaire_Record_Type);
            INSERT contAcctType;
            System.assert(contAcctType.Id!=null,CAT_REC_INSERTION_ERROR);
            system.assertNotEquals(null,MedEduController.getMedEduCAT(caseRecord.Id),'CAT record not returned');
        }
    }
}