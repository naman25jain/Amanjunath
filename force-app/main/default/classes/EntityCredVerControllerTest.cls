@isTest
public with sharing class EntityCredVerControllerTest{
    Static final String DAY = '12/1/1996';
    Static final String CASE_INSERTION_ERROR = 'Case is not inserted';
    Static final String ASSET_INSERTION_ERROR = 'Asset is not inserted';
    Static final String CONTACT_QUERY_ERROR = 'Contact is null';
    Static final String USER_QUERY_ERROR = 'User is null';
    Static final String VERIFICATION_PACKET_INSERTION_ERROR = 'Verification Packect is not inserted';
    Static final String ADVANCED_DEGREE_IN_MEDICAL_SCIENCES = 'Advanced Degree in the Medical Sciences';
    Static final String BILLING_COUNTRY = 'India';
    Static final String ASSETNOTCREATED = 'Asset not created';
    @testSetup static void setup(){
        CloudDataTestFactory.createCloudConfig();
        CurrentECFMGIDSequence__c curECFMGSetting = CurrentECFMGIDSequence__c.getOrgDefaults();
        curECFMGSetting.ECFMG_ID__c = '00000001';
        upsert curECFMGSetting;
        System.assert(curECFMGSetting.Id!=null,'ecfmg sequence id setting not found');
        CurrentEntityIDSequence__c curEntitySetting = CurrentEntityIDSequence__c.getOrgDefaults();
        curEntitySetting.Entity_ID__c = '0000000';
        upsert curEntitySetting;
        System.assert(curEntitySetting.Id!=null,'Entity sequence id setting not found');
        Id applRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_APPLICANT ).getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Unique_Medical_School_ID__c = 'TA123';
        acc.BillingCountry = BILLING_COUNTRY;
        INSERT acc;
        System.assert(acc.Id!=null,'Account not created');
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        con.Email = 'test1@test.com';
        con.Birthdate = Date.parse(DAY);
        con.RecordTypeId = applRecTypeId;
        INSERT con;
        System.assert(con.Id!=null,'Contact not created');
        Id profId = [Select id from profile where name='4-Customer Community Entity 360' LIMIT 1].id;
        User user1 = new User(alias = 'testUser',
                              email = 'test2@test.com',
                              emailencodingkey = 'UTF-8',
                              lastname = 'test user',
                              languagelocalekey = 'en_US',
                              localesidkey = 'en_US',
                              profileid = profId,
                              country = 'United States',
                              IsActive = true,
                              ContactId = con.Id,
                              timezonesidkey = 'America/Los_Angeles',
                              username = 'testuser@test.com');
        INSERT user1;
        System.assert(user1.Id!=null,'User not found');
    }
    // This method is being used to test the getAppBio.
    @isTest
    public static void testgetAppBio(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Id entityRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account mainAcc = new Account();
        mainAcc.Name = 'UserAccount1';
        mainAcc.RecordTypeId = entityRecordType;
        mainAcc.BillingCountry = BILLING_COUNTRY;
        INSERT mainAcc;
        System.assert(mainAcc.Id!=null,'Entity account not found');
        Id credVerRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION ).getRecordTypeId();
        Case newCase = new Case();
        newCase.RecordTypeId = credVerRecTypeId;
        newCase.ContactId = con.Id;
        newCase.AccountId = acc.Id;
        newCase.Service__c = Constants.CASE_SERVICE_EPIC;
        newCase.Entity__c = mainAcc.Id;
        INSERT newCase;
        System.assert(newCase.Id!=null,'Case not created');
        Id catsCredRecTypeId =Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_CREDENTIAL_INTAKE).getRecordTypeId();
        Contact_Association_Type_Staging__c newCats = new Contact_Association_Type_Staging__c();
        newCats.Contact__c = con.Id;
        newCats.Account__c = mainAcc.Id;
        newCats.Case__c = newCase.Id;
        newCats.RecordTypeId = catsCredRecTypeId;
        newCats.Credential_Type__c = 'Advanced Degree in the Medical Sciences';
        newCats.Name_on_Document__c = 'User';
        INSERT newCats;
        System.assert(newCats.Id!=null,'CATS recs not found');
        User user1 = [SELECT Id FROM User LIMIT 1]; 
        System.runAs(user1){
            Test.startTest();
            Contact_Association_Type_Staging__c catsRec = EntityCredVerController.getAppBioDetail(newCase.Id);
            EntityCredVerController.getFMDAsset(newCase.Id);
            EntityCredVerController.getAppBioDetailMEF(newCase.Id);
            EntityCredVerController.getNameOnDocMEF(newCase.Id);
            EntityCredVerController.getFSTAsset(newCase.Id);
            EntityCredVerController.showReviewScreenForTrans(newCase.Id);
            System.assert(catsRec.Id!=null,'Cats record not found');
            Test.stopTest();
        }
    }
    // This method is being used to test the credential review.
    @isTest
    public static void testCredReviewMethod(){
        Contact cont = [SELECT id FROM Contact LIMIT 1];
        System.assert(cont.Id != null, 'Contact is null');
        User usr = [SELECT Id,ContactId FROM User WHERE username = 'testuser@test.com' LIMIT 1];
        System.assert(usr.Id != null, 'User is null'); 
        Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_REGULATORY_ORG).getRecordTypeId();            
        Account newAcct = new Account();
        newAcct.Name = 'Test AccountCred';
        newAcct.RecordTypeId = recTypeId;
        newAcct.BillingCountry = BILLING_COUNTRY;
        Insert newAcct;            
        System.assert(newAcct.Id!= null,'Account not created');           
        Id credVerRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        String assetUrlRet = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/03002000004oj9mAAA_Transfer_Credit_Transcript_2020-11-17_04_10_39.pdf';	
        String returnedName = 'Returned ' + Constants.ASSET_TYPE_TCT;
        String returnName = 'Returned Verification form';
        Id rtsCred = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_CREDENTIAL).getRecordTypeId();
        Case caseRecord = new Case();
        System.runAs(usr){
            caseRecord.Internal_Status__c = Constants.CASE_STATUS_SUBMITTED_IN_REVIEW;
            caseRecord.RecordTypeId = credVerRTId;            
            caseRecord.Reason_for_not_Certifying__c = 'Other';
            caseRecord.Comments_for_not_Certifying__c = 'coments';
            INSERT caseRecord;
            system.assert(caseRecord.Id != null,'Case is not inserted');
            String assetUrl = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/03002000004oj9mAAA_Transfer_Credit_Transcript_2020-11-17_04_10_38.pdf';
            Id appForCertRTId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
            //Create and Insert Asset
            Asset asst1 = new Asset(Name = Constants.ASSET_TYPE_TCT,
                                    Status = Constants.ASSET_STATUS_IN_PROGRESS,
                                    ContactId = usr.contactId,
                                    Case__c = caseRecord.Id,
                                    InstallDate = System.Today(),
                                    key__c = Constants.ASSET_TYPE_TCT,
                                    Type__c	= Constants.ASSET_TYPE_TCT,
                                    Azure_Storage_URL__c = assetUrl,
                                    RecordTypeId = appForCertRTId);
            insert asst1;
            System.assert(asst1.Id != null, 'failed to insert');
            Asset asst2 = new Asset(Name = Constants.ASSET_NAME_TCT_TRANSLATION,
                                    Status = Constants.ASSET_STATUS_IN_PROGRESS,
                                    ContactId = usr.contactId,
                                    Case__c = caseRecord.Id,
                                    InstallDate = System.Today(),
                                    key__c = Constants.ASSET_NAME_TCT_TRANSLATION,
                                    Type__c	= Constants.ASSET_TYPE_TRANSLATION,
                                    Azure_Storage_URL__c = assetUrl+'1234');
            insert asst2;
            System.assert(asst2.Id != null, 'asset failed');
            //Create and Insert Asset
            Asset asst3 = new Asset(Name = returnName,
                                    Status = Constants.ASSET_STATUS_NEW,
                                    ContactId = usr.contactId,
                                    Case__c = caseRecord.Id,
                                    InstallDate = System.Today(),
                                    key__c = Constants.ASSET_TYPE_TCT,
                                    Type__c = Constants.ASSET_TYPE_TCT,
                                    Azure_Storage_URL__c = assetUrlRet,
                                    RecordTypeId = rtsCred);
            insert asst3;
            Asset asst4 = new Asset(Name = returnedName,
                                    Status = Constants.ASSET_STATUS_IN_PROGRESS,
                                    ContactId = usr.contactId,
                                    Case__c = caseRecord.Id,
                                    InstallDate = System.Today(),
                                    key__c = Constants.ASSET_TYPE_TCT,
                                    Type__c = Constants.ASSET_TYPE_TRANSLATION,
                                    Azure_Storage_URL__c = assetUrlRet,
                                    RecordTypeId = rtsCred);
            insert asst4;
            System.assert(asst3.Id != null, 'failed to insert'); 
            Verification_Packet__c verPackNew = new Verification_Packet__c();
            verPackNew.Case__c = caseRecord.Id;
            verPackNew.Translation_included__c = true;
            verPackNew.Is_Active__c = true;
            INSERT verPackNew;                    
            system.assert(verPackNew.Id != null,'verPackNew is not inserted');
            Asset2Verification__c eachAsset2Ver1 = new Asset2Verification__c();
            eachAsset2Ver1.Verification_Packet__c = verPackNew.Id;
            eachAsset2Ver1.Document_Type__c = constants.ASSET2VER_DOCTYPE_SOURCE;
            eachAsset2Ver1.Asset__c = asst1.Id;  
            INSERT eachAsset2Ver1;
            system.assert(eachAsset2Ver1.Id != null,'eachAsset2Ver2 is not inserted');           
            Asset2Verification__c eachAsset2Ver2 = new Asset2Verification__c();
            eachAsset2Ver2.Verification_Packet__c = verPackNew.Id;
            eachAsset2Ver2.Document_Type__c = constants.ASSET2VER_DOCTYPE_SUPPORTING_DOCUMENT;
            eachAsset2Ver2.Asset__c = asst2.Id;
            INSERT eachAsset2Ver2;
            system.assert(eachAsset2Ver2.Id != null,'eachAsset2Ver2 is not inserted');
            Asset2Verification__c eachAsset2Ver3 = new Asset2Verification__c();
            eachAsset2Ver3.Verification_Packet__c = verPackNew.Id;
            eachAsset2Ver3.Document_Type__c = 'Verified';
            eachAsset2Ver3.Azure_Document_URL__c=assetUrlRet;
            eachAsset2Ver3.Asset__c = asst3.Id;
            INSERT eachAsset2Ver3;
            EntityCredVerController.updVPAssetsforNoAcc(caseRecord,verPackNew.Id);
            system.assert(eachAsset2Ver3.Id != null,'eachAsset2Ver3 is not inserted'); 
            Boolean chckAsst = EntityCredVerController.checkAsstExist(assetUrlRet);
            System.assert(chckAsst, 'Asset Exist');           
            Map<String,String> enREVCtr = EntityCredVerController.getCredUploaded(caseRecord.Id);
            System.assert(!enREVCtr.isEmpty(), 'Credential Exist');    
            String json = '{"ass2VerId":"'+eachAsset2Ver1.Id+'","cert":"Cannot certify","reason":"Applicant action is required","com":"fsda","caseId":"'+caseRecord.Id+'"}';
            Boolean res = EntityCredVerController.updateAsset2VerDtl(json);
            System.assert(res, 'Credential not updated');
            Boolean rewScr = EntityCredVerController.showReviewScreen(caseRecord.Id);
            System.assert(rewScr, 'Show Review screen');                    
        }
        Boolean chckRet= EntityCredVerController.checkReturnedAsstExist(caseRecord.Id,returnedName,assetUrlRet);
        System.assert(chckRet, 'Check Ret Asset'); 
        Boolean markRet= EntityCredVerController.markAssetsForDeletion(caseRecord.Id,returnedName,true);
        System.assert(markRet, 'Delete Asset');
    }
    // This method is being used to test the getAsset method in EntityCredVerController for EICS service. 
    @istest
    public static void getAssetEICSTest(){
        Contact cont = [SELECT Id FROM Contact LIMIT 1];
        System.assert(cont.Id != null,CONTACT_QUERY_ERROR);
        User usr = [SELECT Id,ContactId FROM User WHERE username = 'testuser@test.com' LIMIT 1];
        System.assert(usr.Id != null,USER_QUERY_ERROR); 
        Id credVerRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        //Create and insert case
        Case caseRecord = new Case();
        caseRecord.Internal_Status__c = Constants.CASE_STATUS_SUBMITTED_IN_REVIEW;
        caseRecord.RecordTypeId = credVerRTId;
        caseRecord.Service__c = 'EICS';
        caseRecord.ContactId = usr.contactId;
        INSERT caseRecord;
        System.assert(caseRecord.Id != null,CASE_INSERTION_ERROR);        
        //Create and Insert Asset
        String assetUrl = 'test';
        Asset asst1 = new Asset(Name = 'Photo',
                                Status = Constants.ASSET_STATUS_VERIFIED,
                                ContactId = usr.contactId,
                                Case__c = caseRecord.Id,
                                InstallDate = System.Today(),
                                Type__c	= Constants.ASSET_TYPE_IDENTITY_VERIFICATION,
                                Azure_Storage_URL__c = assetUrl);
        INSERT asst1;
        System.assert(asst1.Id != null,ASSET_INSERTION_ERROR);
        String error = '';
        List<CloudStorageController.PayloadWrapper> payloadList;
        try{
            Test.startTest();
            payloadList = EntityCredVerController.getAsset(caseRecord.Id);
            Test.stopTest();
        }
        catch(Exception ex){
            error = ex.getMessage();
        }
        System.assert(String.isBlank(error),'getAsset threw exception '+error);
        System.assert(!payloadList.isEmpty(),'Empty payload list');
    }
    // This method is being used to test the getAsset method in EntityCredVerController for EPIC service. 
    @istest
    public static void getAssetEPICTest(){
        Contact cont = [SELECT Id FROM Contact LIMIT 1];
        System.assert(cont.Id != null,CONTACT_QUERY_ERROR);
        User usr = [SELECT Id,ContactId FROM User WHERE username = 'testuser@test.com' LIMIT 1];
        System.assert(usr.Id != null,USER_QUERY_ERROR); 
        Id credVerRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        //Create and insert case
        Case caseRecord = new Case();
        caseRecord.Internal_Status__c = Constants.CASE_STATUS_SUBMITTED_IN_REVIEW;
        caseRecord.RecordTypeId = credVerRTId;
        caseRecord.Service__c = 'EPIC';
        caseRecord.ContactId = usr.contactId;
        INSERT caseRecord;
        System.assert(caseRecord.Id != null,CASE_INSERTION_ERROR);        
        //Create and Insert Asset
        String assetUrl = 'test';
        Asset asst1 = new Asset(Name = constants.ASSET_NAME_REDACTED_ID_FORM,
                                Status = Constants.ASSET_STATUS_VERIFIED,
                                ContactId = usr.contactId,
                                Case__c = caseRecord.Id,
                                InstallDate = System.Today(),
                                Type__c	= Constants.ASSET_TYPE_IDENTITY_VERIFICATION,
                                Azure_Storage_URL__c = assetUrl);
        INSERT asst1;
        System.assert(asst1.Id != null,ASSET_INSERTION_ERROR);
        String error = '';
        List<CloudStorageController.PayloadWrapper> payloadList = new List<CloudStorageController.PayloadWrapper>();
        try{
            Test.startTest();
            payloadList = EntityCredVerController.getAsset(caseRecord.Id);
            Test.stopTest();
        }
        catch(Exception ex){
            error = ex.getMessage();
        }
        System.assert(String.isBlank(error),'getAsset threw exception '+error);
        System.assert(!payloadList.isEmpty(),'Empty payload list');
    }
    // This method is being used to test the step number method in EntityCredVerController if step number is higher then step number is updated. 
    @istest
    public static void updateStepHigherTest(){
        Contact cont = [SELECT Id FROM Contact LIMIT 1];
        System.assert(cont.Id != null,CONTACT_QUERY_ERROR);
        User usr = [SELECT Id,ContactId FROM User WHERE username = 'testuser@test.com' LIMIT 1];
        System.assert(usr.Id != null,USER_QUERY_ERROR); 
        Id credVerRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        //Create and insert case
        Case caseRecord = new Case();
        caseRecord.Internal_Status__c = Constants.CASE_STATUS_SUBMITTED_IN_REVIEW;
        caseRecord.RecordTypeId = credVerRTId;
        caseRecord.Service__c = 'EPIC';
        INSERT caseRecord;
        System.assert(caseRecord.Id != null,CASE_INSERTION_ERROR);        
        String error = '';
        Integer stepNumber = 2;
        try{
            Test.startTest();
            EntityCredVerController.updateStep(stepNumber,caseRecord.Id);
            Test.stopTest();
        }
        catch(Exception ex){
            error = ex.getMessage();
        }
        System.assert(String.isBlank(error),'update step threw exception '+error);
        System.assertEquals([SELECT Id,Entity_Review_Step__c FROM Case WHERE Id=:caseRecord.Id].Entity_Review_Step__c,stepNumber,'step number is not updated');        
    }
    // This method is being used to test the step number method in EntityCredVerController if step number is lower then step number should not be updated. 
    @istest
    public static void updateStepLowerTest(){
        Contact cont = [SELECT Id FROM Contact LIMIT 1];
        System.assert(cont.Id != null,CONTACT_QUERY_ERROR);
        User usr = [SELECT Id,ContactId FROM User WHERE username = 'testuser@test.com' LIMIT 1];
        System.assert(usr.Id != null,USER_QUERY_ERROR); 
        Id credVerRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        //Create and insert case
        Case caseRecord = new Case();
        caseRecord.Internal_Status__c = Constants.CASE_STATUS_SUBMITTED_IN_REVIEW;
        caseRecord.RecordTypeId = credVerRTId;
        caseRecord.Service__c = 'EPIC';
        caseRecord.Entity_Review_Step__c = 2;
        INSERT caseRecord;
        System.assert(caseRecord.Id != null,CASE_INSERTION_ERROR);        
        string error = '';
        integer stepNumber = 1;        
        try{
            Test.startTest();
            EntityCredVerController.updateStep(stepNumber,caseRecord.Id);
            Test.stopTest();
        }
        catch(Exception ex){
            error = ex.getMessage();
        }
        System.assert(String.isBlank(error),'update step threw exception '+error);
        System.assertnotEquals([SELECT Id,Entity_Review_Step__c FROM Case WHERE Id=:caseRecord.Id].Entity_Review_Step__c,stepNumber,'step number is updated');
    }
    // This method is being used to test the case status update method in EntityCredVerController. 
    @istest
    public static void updateCaseStatusTest(){
        Contact cont = [SELECT Id FROM Contact LIMIT 1];
        System.assert(cont.Id != null,CONTACT_QUERY_ERROR);
        User usr = [SELECT Id,ContactId FROM User WHERE username = 'testuser@test.com' LIMIT 1];
        System.assert(usr.Id != null,USER_QUERY_ERROR); 
        Id credVerRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        //Create and insert case
        Case caseRecord = new Case();
        caseRecord.Internal_Status__c = Constants.CASE_STATUS_SUBMITTED_IN_REVIEW;
        caseRecord.RecordTypeId = credVerRTId;
        caseRecord.Service__c = 'EPIC';
        caseRecord.ownerId = usr.Id;
        INSERT caseRecord; 
        System.assert(caseRecord.Id != null, CASE_INSERTION_ERROR);
        String error = '';
        Constants cons = new Constants();
        try{
            System.runas(usr){
                Test.startTest();
                EntityCredVerController.updateEntityReviewer(caseRecord.Id);
                EntityCredVerController.updateCaseStatus(caseRecord.Id,cons.LWC_CASE_STATUS_IN_REVIEW_AT_ENTITY);
                Test.stopTest();
            }
        }
        catch(Exception ex){
            error = ex.getMessage();
        }
        System.assert(String.isBlank(error),'update case status threw exception '+error);
        System.assertEquals([SELECT Id,Entity_Reviewer__c FROM Case WHERE Id=:caseRecord.Id].Entity_Reviewer__c, cont.Id,'entitity reviewer not updated');
        System.assertEquals([SELECT Id,Internal_Status__c FROM Case WHERE Id=:caseRecord.Id].Internal_Status__c,cons.LWC_CASE_STATUS_IN_REVIEW_AT_ENTITY,'case status is not updated');     
    }
    @istest 
    public static void additionalDocReviewTest(){
        String url1 = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/00302000004oj9mAAA_Transfer_Credit_Transcript_2020-11-17_04_10_38.pdf';
        String url2 = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/00302000004oj9mAAA_Transfer_Credit_Transcript_2020-11-18_04_10_38.pdf';
        String url3 = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/00302000004oj9mAAA_Transfer_Credit_Transcript_2020-11-18_04_10_36.pdf';
        String url4 = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/00302000004oj9mAAA_Transfer_Credit_Transcript_2020-11-18_04_10_35.pdf';
        String url5 = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/00302000004oj9mAAA_Transfer_Credit_Transcript_2020-11-18_04_10_37.pdf';
        String url6 = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/00302000004oj9mAAA_Transfer_Credit_Transcript_2020-11-18_04_10_57.pdf';
        Contact cont = [SELECT Id FROM Contact LIMIT 1];
        System.assert(cont.Id != null,CONTACT_QUERY_ERROR);
        Id credVerRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        //Create and insert case
        Case caseRecord = new Case();
        caseRecord.Internal_Status__c = Constants.CASE_STATUS_SUBMITTED_IN_REVIEW;
        caseRecord.RecordTypeId = credVerRTId;
        caseRecord.Service__c = Constants.CASE_SERVICE_EPIC;
        INSERT caseRecord;
        System.assert(caseRecord.Id != null,CASE_INSERTION_ERROR);
        Verification_Packet__c verPackNew = new Verification_Packet__c();
        verPackNew.Case__c = caseRecord.Id;
        verPackNew.Translation_included__c = true;
        verPackNew.Is_Active__c = true;
        verPackNew.Entity_provide_the_credential__c = true;
        INSERT verPackNew;
        System.assert(verPackNew.Id != null,VERIFICATION_PACKET_INSERTION_ERROR);
        List<Asset> assetList = new List<Asset>();
        //Create and Insert Asset
        Asset asst1 = new Asset(
            Name = Constants.ASSET_TYPE_TCT,
            Status = Constants.ASSET_STATUS_ACCEPTED,
            ContactId = cont.Id,
            InstallDate = System.Today(),
            key__c	=	Constants.ASSET_TYPE_TCT,
            Type__c	=	Constants.ASSET_NAME_PHOTO,
            case__c =   caseRecord.Id,
            Azure_Storage_URL__c = url1
        );
        assetList.add(asst1);
        Asset asst5 = new Asset(
            Name = Constants.ASSET_TYPE_ENTITY_SUPPORTING_DOCUMENTS,
            Status = Constants.ASSET_STATUS_NEW,
            ContactId = cont.Id,
            InstallDate = System.Today(),
            Type__c	=	Constants.ASSET_NAME_PHOTO,
            case__c =   caseRecord.Id,
            Azure_Storage_URL__c = url2
        );
        assetList.add(asst5);
        Asset asst2 = new Asset(
            Name = Constants.ASSET_TYPE_ENTITY_SUPPORTING_DOCUMENTS,
            Status = Constants.ASSET_STATUS_NEW,
            ContactId = cont.Id,
            InstallDate = System.Today(),
            Type__c	=	Constants.ASSET_NAME_PHOTO,
            case__c =   caseRecord.Id,
            Azure_Storage_URL__c = url3
        );
        assetList.add(asst2);
        Asset asst3 = new Asset(
            Name = Constants.ASSET_NAME_CREDENTIAL_REQUEST,
            Status = Constants.ASSET_STATUS_IN_PROGRESS,
            ContactId = cont.Id,
            InstallDate = System.Today(),
            Type__c	=	Constants.ASSET_NAME_PHOTO,
            case__c =   caseRecord.Id,
            Azure_Storage_URL__c = url4
        );
        assetList.add(asst3);
        insert assetList;
        System.assert(asst1.Id != null, 'asset Id is null');
        List<Asset2Verification__c> asset2VerList = new List<Asset2Verification__c>();
        Asset2Verification__c newAsset2Ver = new Asset2Verification__c();
        newAsset2Ver.Verification_Packet__c = verPackNew.Id;
        newAsset2Ver.Azure_Document_URL__c = url1;
        newAsset2Ver.Asset__c = asst1.Id;
        newAsset2Ver.Document_Type__c = constants.ASSET2VER_DOCTYPE_SUPPORTING_DOCUMENT;
        asset2VerList.add(newAsset2Ver);
        Asset2Verification__c newAsset2Ver1 = new Asset2Verification__c();
        newAsset2Ver1.Verification_Packet__c = verPackNew.Id;
        newAsset2Ver1.Azure_Document_URL__c = url2;
        newAsset2Ver1.Asset__c = asst5.Id;
        newAsset2Ver1.Document_Type__c = constants.ASSET2VER_DOCTYPE_SUPPORTING_DOCUMENT;
        asset2VerList.add(newAsset2Ver1);
        Asset2Verification__c newAsset2Ver2 = new Asset2Verification__c();
        newAsset2Ver2.Verification_Packet__c = verPackNew.Id;
        newAsset2Ver2.Azure_Document_URL__c = url4;
        newAsset2Ver2.Asset__c = asst3.Id;
        newAsset2Ver2.Document_Type__c = constants.ASSET2VER_DOCTYPE_VERIFIED;
        asset2VerList.add(newAsset2Ver2);
        Insert asset2VerList;
        System.assert(newAsset2Ver1.Id != null, 'asset 2 verification Id is null');
        String error = '';
        try{
            Test.startTest();
            EntityCredVerController.getAdditionalDocuments(caseRecord.Id);
            EntityCredVerController.checkDisplayCondition(caseRecord.Id);
            EntityCredVerController.getVerificationPacket(caseRecord.Id);
            EntityCredVerController.getSupportAssetUrl(verPackNew.Id);
            EntityCredVerController.getCredentialUrl(verPackNew.Id);
            List<String> supportList = new List<String>();
            supportList.add(url6);
            String supportListString = JSON.serialize(supportList);
            EntityCredVerController.AddDocWrapper addDocWrapper= new EntityCredVerController.AddDocWrapper();
            addDocWrapper.supportDocUrlList = supportListString;
            addDocWrapper.credUrl = url5;
            addDocWrapper.reason = null;
            addDocWrapper.reasonComment = null;
            addDocWrapper.credAvailable = 'No';
            String jsonInput = JSON.serialize(addDocWrapper);
            EntityCredVerController.updateVerificationPacket(caseRecord.Id, jsonInput);
            EntityCredVerController.deleteDocuments(caseRecord.Id);
            Boolean resultValue = EntityCredVerController.deleteSupportDocuments(url2);
            System.assert(resultValue, 'asset deletion failed');
            Test.stopTest();
        }catch(Exception ex){
            error = ex.getMessage();
        }
        System.assert(String.isBlank(error),'update methods threw exception '+error);
    }
    @istest
    public static void createEcfmgVerFormTest(){
        Contact cont = [SELECT Id FROM Contact LIMIT 1];
        System.assert(cont.Id != null,CONTACT_QUERY_ERROR);
        User usr = [SELECT Id,ContactId FROM User WHERE username = 'testuser@test.com' LIMIT 1];
        System.assert(usr.Id != null,USER_QUERY_ERROR); 
        Id credVerRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        Case caseRecord = new Case();
        caseRecord.Internal_Status__c = Constants.CASE_STATUS_SUBMITTED_IN_REVIEW;
        caseRecord.RecordTypeId = credVerRTId;
        caseRecord.Service__c = 'EPIC';
        caseRecord.ContactId = cont.Id;
        INSERT caseRecord; 
        System.assert(caseRecord.Id != null, CASE_INSERTION_ERROR);
        Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_ENTITY).getRecordTypeId();            
        Account newAcct = new Account();
        newAcct.Name = 'Test AccountCred';
        newAcct.RecordTypeId = recTypeId;
        newAcct.BillingCountry = BILLING_COUNTRY;
        Insert newAcct;  
        System.assert(newAcct.Id!= null,'Account not created here'); 
        Id assetRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_VERIFICATION).getRecordTypeId();   
        Asset asst1 = new Asset(Name = Constants.ASSET_TYPE_RETURNED_VERIFICATION_FORM,
                                Status = Constants.ASSET_STATUS_NEW,
                                ContactId = usr.contactId,
                                Case__c = caseRecord.Id,
                                InstallDate = System.Today(),
                                Type__c	= Constants.ASSET_TYPE_VERIFICATION_FORM,
                                RecordTypeId = assetRecTypeId);
        insert asst1;
        System.assert(asst1.Id != null, 'failed to insert here ');
        cadmus_core__Doc_Config__c docConfig = new cadmus_core__Doc_Config__c();
        docConfig.Name = 'Certified ECFMG Verification Form';
        docConfig.RecordTypeId = Schema.SObjectType.cadmus_core__Doc_Config__c.getRecordTypeInfosByDeveloperName().get('MAIN').getRecordTypeId();
        docConfig.cadmus_core__Delivery_option__c = 'BASE64';
        insert docConfig;
        System.assert(docConfig.Id != null, 'Failed to insert Doc Config Record! here');
        Verification_Packet__c verPack = new Verification_Packet__c();
        verPack.Is_Active__c = true;
        verPack.Case__c	= caseRecord.Id;
        verPack.Contact__c = cont.Id;
        INSERT verPack;
        System.assert(verPack.Id!=null,'Verification Packet not found!');
        String error = '';
        try{
            Test.startTest();
            string certifiedVal = constants.CERTIFIED_VERIFICATION_ENTITY;
            EntityCredVerController.createEcfmgVerForm(string.valueOf(caseRecord.Id),string.valueOf(newAcct),certifiedVal);
            string ecfmgVerFormURL = EntityCredVerController.getEcfmgVerFormURL(string.valueOf(caseRecord.Id));
            system.assert(string.isNotBlank(ecfmgVerFormURL),'EcfmgVerFormURL is empty');
            Test.stopTest();
        }
        catch(Exception ex){
            error = ex.getMessage();
        }
        system.assertEquals(error,'','Error occured');
    }
    @istest
    public static void checkExistingReviewerTest(){
        Contact con =[SELECT Id FROM Contact WHERE Email = 'test1@test.com' WITH SECURITY_ENFORCED LIMIT 1];
        User usr = [SELECT Id, contactId FROM User WHERE Email = 'test2@test.com' WITH SECURITY_ENFORCED LIMIT 1];
        Id credVerRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        String error = '';
        Case caseRecord = new Case();
        caseRecord.RecordTypeId = credVerRTId;
        caseRecord.Service__c = 'EPIC';
        caseRecord.Internal_Status__c = Constants.CASE_STATUS_SUBMITTED_IN_REVIEW;
        caseRecord.Entity_Reviewer__c = con.Id;
        caseRecord.OwnerId = usr.Id;
        INSERT caseRecord;
        System.assert(caseRecord.Id!= null,'Case is not created'); 
        try{
            System.runAs(usr){
                Test.startTest();
                Boolean result = EntityCredVerController.checkExistingReviewer(caseRecord.Id);
                System.assertEquals(true, result, 'Reviewer is not same');
                Test.stopTest();
            }
        }
        catch(Exception e){
            error = e.getMessage();
        }
    }
    @istest
    public static void getVerifiedCredUrlTest(){
        List<RecordType> credRecordType = [SELECT Id, Name from RecordType where DeveloperName =: Constants.ASSET_RECORD_TYPE_CREDENTIAL AND SObjectType = 'Asset' WITH SECURITY_ENFORCED];
        Id credVerRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        Contact con =[SELECT Id FROM Contact WHERE Email = 'test1@test.com' WITH SECURITY_ENFORCED LIMIT 1 ];
        String error = '';
        Case caseRecord = new Case();
        caseRecord.RecordTypeId = credVerRTId;
        caseRecord.Service__c = 'EPIC';
        caseRecord.Internal_Status__c = Constants.CASE_STATUS_SUBMITTED_IN_REVIEW;
        caseRecord.Entity_Reviewer__c = con.Id;
        caseRecord.Document_Type__c = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA;
        INSERT caseRecord;
        System.assert(caseRecord.Id!= null,'Case not created'); 
        Asset asst = new Asset();
        asst.Azure_Storage_URL__c = 'testUrl';
        asst.RecordTypeId = credRecordType[0].Id;
        asst.Case__c = caseRecord.Id;
        asst.Status = Constants.ASSET_STATUS_NEW;
        asst.Name = Constants.ENTITYCREDVERCTRL_TESTCLS_RETURNED + Constants.ASSET_TYPE_FINAL_MED_DIPLOMA;
        asst.Type__c = Constants.ASSET_TYPE_RETURNED_CREDENTIAL;
        asst.ContactId = con.Id; 
        INSERT asst;
        System.assert(asst.Id!= null,'Asset not created'); 
        String retName = Constants.ENTITYCREDVERCTRL_TESTCLS_RETURNED + Constants.ASSET_TYPE_FINAL_MED_DIPLOMA;
        try{
            Test.startTest();
            String credUrl = EntityCredVerController.getVerifiedCredUrl(caseRecord.Id, retName);
            System.assertEquals('testUrl', credUrl, 'returned credential URL not correct');
            Test.stopTest();
        }
        catch(Exception e){
            error = e.getMessage();
        }        
    }
    @IsTest
    public static void testCheckVerAcceptOrNot(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        User usr = [SELECT Id,ContactId FROM User WHERE username = 'testuser@test.com' LIMIT 1];
        Id entityRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account mainAcc = new Account();
        mainAcc.Name = 'UserAccount1';
        mainAcc.RecordTypeId = entityRecordType;
        mainAcc.Entity_Restriction__c = null;
        mainAcc.BillingCountry = BILLING_COUNTRY;
        INSERT mainAcc;
        System.assert(mainAcc.Id != null,'Entity Account not found');
        Id credVerRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION ).getRecordTypeId();
        Case newCase = new Case();
        newCase.RecordTypeId = credVerRecTypeId;
        newCase.ContactId = con.Id;
        newCase.AccountId = acc.Id;
        newCase.Service__c = Constants.CASE_SERVICE_EPIC;
        newCase.Entity__c = mainAcc.Id;
        newCase.Document_Type__c = ADVANCED_DEGREE_IN_MEDICAL_SCIENCES;
        newCase.Certify_the_Document__c = 'Certify';
        INSERT newCase;
        System.assert(newCase.Id != null,'Case not found');
        Id veriAssetRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_VERIFICATION).getRecordTypeId();  
        Id credAsstRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_CREDENTIAL).getRecordTypeId();
        Id suppDocAssRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_SUPP_DOCUMENT).getRecordTypeId();
        String url1 = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/00302000004oj9mAAA_Transfer_Credit_Transcript_2020-11-18_04_10_37.pdf';
        Asset asst1 = new Asset(Name = Constants.ASSET_TYPE_RETURNED_VERIFICATION_FORM,
                                Status = Constants.ASSET_STATUS_NEW,
                                ContactId = usr.contactId,
                                Case__c = newCase.Id,
                                InstallDate = System.Today(),
                                Type__c	= Constants.ASSET_TYPE_VERIFICATION_FORM,
                               	RecordTypeId = veriAssetRecTypeId);
        INSERT asst1;
        Asset asst2 = new Asset(Name = 'Credential Request',
                                Status = Constants.ASSET_STATUS_NEW,
                                ContactId = usr.contactId,
                                Case__c = newCase.Id,
                                InstallDate = System.Today(),
                                Type__c	= ADVANCED_DEGREE_IN_MEDICAL_SCIENCES,
                               	RecordTypeId = credAsstRecTypeId);
        INSERT asst2;
        Asset asst3 = new Asset(Name = Constants.ASSET_NAME_SUPPORTING_DOCUMENTS,
                                Status = Constants.ASSET_STATUS_NEW,
                                ContactId = usr.contactId,
                                InstallDate = System.Today(),
                                Type__c	= Constants.ASSET_TYPE_SUPPORTING_DOCUMENTS,
                                Case__c = newCase.Id,
                                Azure_Storage_URL__c = url1,
                                RecordTypeId = suppDocAssRecTypeId
        );
        INSERT asst3;
        system.assert(asst3.Id!=null,ASSETNOTCREATED);
        Verification_Packet__c verPckt = new Verification_Packet__c();
        verPckt.Case__c = newCase.Id;
        verPckt.Request_additional_information__c = null;
        verPckt.Entity_provide_the_credential__c = false;
        verPckt.Is_Active__c = true;
        INSERT verPckt;
        System.assert(verPckt.Id != null, 'verification packet not found');
        Send_Request__c sendReq = new Send_Request__c();
        sendReq.Current_Send_Date__c = system.today();
        sendReq.Send_Method__c = Constants.CASE_SEND_METHOD_ENTITY_PORTAL;
        sendReq.Verification_Packet__c = verPckt.Id;
        INSERT sendReq;
        System.assert(sendReq.Id != null, 'Send Request is not created');
        Asset2Verification__c ass2ver = new Asset2Verification__c();
        ass2ver.Document_Type__c = Constants.ASSET2VER_DOCTYPE_VERIFIED;
        ass2ver.Verification_Packet__c = verPckt.Id;
        ass2ver.Asset__c = asst2.Id;
        INSERT ass2ver;
        System.assert(ass2ver.Id != null, 'Asset2 Verifcation rec not found');
        Asset2Verification__c ass2ver1 = new Asset2Verification__c();
        ass2ver1.Document_Type__c = Constants.ASSET2VER_DOCTYPE_RETURNED_VER_FORM;
        ass2ver1.Verification_Packet__c = verPckt.Id;
        ass2ver1.Asset__c = asst1.Id;
        INSERT ass2ver1;
        System.assert(ass2ver1.Id != null, 'Asset to Verifcation rec not found');
        Asset2Verification__c ass2ver2 = new Asset2Verification__c();
        ass2ver2.Document_Type__c = Constants.ASSET2VER_DOCTYPE_SUPPORTING_DOCUMENT;
        ass2ver2.Verification_Packet__c = verPckt.Id;
        ass2ver2.Asset__c = asst3.Id;
        INSERT ass2ver2;
        System.assert(ass2ver2.Id != null, 'Asset2Verifcation rec not found');
        String error = '';
        try{
            Test.startTest();
            Boolean updatedOrNot = EntityCredVerController.checkVerResAccOrNot(newCase.Id);
            System.assert(updatedOrNot == true,'Case and verification packet assets are not updated');
            Test.stopTest();
        }catch(Exception ex){
            error = ex.getMessage();
        }
    }
    @IsTest
    public static void testUpdCaseVPForNoAccRes(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        User usr = [SELECT Id,ContactId FROM User WHERE username = 'testuser@test.com' LIMIT 1];
        Id entityRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account mainAcc = new Account();
        mainAcc.Name = 'UserAccount1';
        mainAcc.RecordTypeId = entityRecordType;
        mainAcc.Entity_Restriction__c = null;
        mainAcc.BillingCountry = BILLING_COUNTRY;
        INSERT mainAcc;
        System.assert(mainAcc.Id != null,'Entity account not found');
        Id credVerRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION ).getRecordTypeId();
        Case newCase = new Case();
        newCase.RecordTypeId = credVerRecTypeId;
        newCase.ContactId = con.Id;
        newCase.AccountId = acc.Id;
        newCase.Service__c = Constants.CASE_SERVICE_EPIC;
        newCase.Entity__c = mainAcc.Id;
        newCase.Document_Type__c = 'Transcript to Document Transfer Credits';
        newCase.Certify_the_Document__c = 'Certify';
        INSERT newCase;
        System.assert(newCase.Id!=null,'Case not created.');
        Id assetRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_VERIFICATION).getRecordTypeId();  
        Id credAsstRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_CREDENTIAL).getRecordTypeId();
        Id suppDocAssRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_SUPP_DOCUMENT).getRecordTypeId();
        String url1 = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/00302000004oj9mAAA_Transfer_Credit_Transcript_2020-11-18_04_10_37.pdf';
        Asset asst1 = new Asset(Name = Constants.ASSET_TYPE_RETURNED_VERIFICATION_FORM,
                                Status = Constants.ASSET_STATUS_NEW,
                                ContactId = usr.contactId,
                                Case__c = newCase.Id,
                                InstallDate = System.Today(),
                                Type__c	= Constants.ASSET_TYPE_VERIFICATION_FORM,
                               	RecordTypeId = assetRecTypeId);
        INSERT asst1;
        Asset asst2 = new Asset(Name = 'Returned Transcript to Document Transfer Credits',
                                Status = Constants.ASSET_STATUS_NEW,
                                ContactId = usr.contactId,
                                Case__c = newCase.Id,
                                InstallDate = System.Today(),
                                Type__c	= Constants.ASSET_TYPE_TCT,
                               	RecordTypeId = credAsstRecTypeId);
        INSERT asst2;
        Asset asst3 = new Asset(Name = Constants.ASSET_TYPE_ENTITY_SUPPORTING_DOCUMENTS,
                                Status = Constants.ASSET_STATUS_NEW,
                                ContactId = usr.contactId,
                                InstallDate = System.Today(),
                                Type__c	= Constants.ASSET_TYPE_SUPPORTING_DOCUMENTS,
                                Case__c = newCase.Id,
                                Azure_Storage_URL__c = url1,
                                RecordTypeId = suppDocAssRecTypeId
        );
        INSERT asst3;
        Verification_Packet__c verPckt = new Verification_Packet__c();
        verPckt.Case__c = newCase.Id;
        verPckt.Request_additional_information__c = null;
        verPckt.Entity_provide_the_credential__c = true;
        verPckt.Is_Active__c = true;
        INSERT verPckt;
        System.assert(verPckt.Id != null, 'verification packet not found');
        Asset2Verification__c ass2ver = new Asset2Verification__c();
        ass2ver.Document_Type__c = Constants.ASSET2VER_DOCTYPE_SOURCE;
        ass2ver.Verification_Packet__c = verPckt.Id;
        ass2ver.Asset__c = asst2.Id;
        INSERT ass2ver;
        System.assert(ass2ver.Id != null, 'Asset2Verifcation rec not found');
        Asset2Verification__c ass2ver1 = new Asset2Verification__c();
        ass2ver1.Document_Type__c = Constants.ASSET2VER_DOCTYPE_RETURNED_VER_FORM;
        ass2ver1.Verification_Packet__c = verPckt.Id;
        ass2ver1.Asset__c = asst1.Id;
        INSERT ass2ver1;
        System.assert(ass2ver1.Id != null, 'Asset2Verifcation rec not found');
        Asset2Verification__c ass2ver2 = new Asset2Verification__c();
        ass2ver2.Document_Type__c = Constants.ASSET2VER_DOCTYPE_SUPPORTING_DOCUMENT;
        ass2ver2.Verification_Packet__c = verPckt.Id;
        ass2ver2.Asset__c = asst3.Id;
        ass2ver2.Azure_Document_URL__c = url1;
        INSERT ass2ver2;
        System.assert(ass2ver1.Id != null, 'Asset2Ver rec not found');
        String error = '';
        try{
            Test.startTest();
            Boolean updatedOrNot = EntityCredVerController.updCaseVPForNotAccRes(newCase.Id, mainAcc.Id);
            System.assert(updatedOrNot == true,'Case and verification packet assets are not updated');
            Test.stopTest();
        }catch(Exception ex){
            error = ex.getMessage();
        }
    }
    @IsTest
    public static void testUpdCaseVPForAccRes(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        User usr = [SELECT Id,ContactId FROM User WHERE username = 'testuser@test.com' LIMIT 1];
        Id entityRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account mainAcc = new Account();
        mainAcc.BillingCountry = BILLING_COUNTRY;
        mainAcc.Name = 'UserAccount1';
        mainAcc.RecordTypeId = entityRecordType;
        mainAcc.Entity_Restriction__c = 'Internal Only';
        INSERT mainAcc;
        System.assert(mainAcc.Id != null,'Entity account not found');
        Id credVerRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION ).getRecordTypeId();
        Case newCase = new Case();
        newCase.RecordTypeId = credVerRecTypeId;
        newCase.ContactId = con.Id;
        newCase.AccountId = acc.Id;
        newCase.Service__c = Constants.CASE_SERVICE_EPIC;
        newCase.Entity__c = mainAcc.Id;
        newCase.Document_Type__c = 'Transcript to Document Transfer Credits';
        newCase.Certify_the_Document__c = 'Certify';
        INSERT newCase;
        System.assert(newCase.Id!=null,'Case not created.');
        Id assetRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_VERIFICATION).getRecordTypeId();  
        Id credAsstRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_CREDENTIAL).getRecordTypeId();
        Id suppDocAssRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_SUPP_DOCUMENT).getRecordTypeId();
        String url1 = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/00302000004oj9mAAA_Transfer_Credit_Transcript_2020-11-18_04_10_37.pdf';
        Asset asst1 = new Asset(Name = Constants.ASSET_TYPE_RETURNED_VERIFICATION_FORM,
                                Status = Constants.ASSET_STATUS_NEW,
                                ContactId = usr.contactId,
                                Case__c = newCase.Id,
                                InstallDate = System.Today(),
                                Type__c	= Constants.ASSET_TYPE_VERIFICATION_FORM,
                               	RecordTypeId = assetRecTypeId);
        INSERT asst1;
        Asset asst2 = new Asset(Name = 'Returned Transcript to Document Transfer Credits',
                                Status = Constants.ASSET_STATUS_NEW,
                                ContactId = usr.contactId,
                                Case__c = newCase.Id,
                                InstallDate = System.Today(),
                                Type__c	= Constants.ASSET_TYPE_TCT,
                               	RecordTypeId = credAsstRecTypeId);
        INSERT asst2;
        Asset asst3 = new Asset(Name = Constants.ASSET_TYPE_ENTITY_SUPPORTING_DOCUMENTS,
                                Status = Constants.ASSET_STATUS_NEW,
                                ContactId = usr.contactId,
                                InstallDate = System.Today(),
                                Type__c	= Constants.ASSET_TYPE_SUPPORTING_DOCUMENTS,
                                Case__c = newCase.Id,
                                Azure_Storage_URL__c = url1,
                                RecordTypeId = suppDocAssRecTypeId
        );
        INSERT asst3;
        Verification_Packet__c verPckt = new Verification_Packet__c();
        verPckt.Case__c = newCase.Id;
        verPckt.Request_additional_information__c = null;
        verPckt.Entity_provide_the_credential__c = true;
        verPckt.Is_Active__c = true;
        INSERT verPckt;
        System.assert(verPckt.Id != null, 'verification packet not found');
        Asset2Verification__c ass2ver = new Asset2Verification__c();
        ass2ver.Document_Type__c = Constants.ASSET2VER_DOCTYPE_SOURCE;
        ass2ver.Verification_Packet__c = verPckt.Id;
        ass2ver.Asset__c = asst2.Id;
        INSERT ass2ver;
        System.assert(ass2ver.Id != null, 'Asset2Verifcation rec not found');
        Asset2Verification__c ass2ver1 = new Asset2Verification__c();
        ass2ver1.Document_Type__c = Constants.ASSET2VER_DOCTYPE_RETURNED_VER_FORM;
        ass2ver1.Verification_Packet__c = verPckt.Id;
        ass2ver1.Asset__c = asst1.Id;
        INSERT ass2ver1;
        System.assert(ass2ver1.Id != null, 'Asset2Verifcation rec not found');
        Asset2Verification__c ass2ver2 = new Asset2Verification__c();
        ass2ver2.Document_Type__c = Constants.ASSET2VER_DOCTYPE_SUPPORTING_DOCUMENT;
        ass2ver2.Verification_Packet__c = verPckt.Id;
        ass2ver2.Asset__c = asst3.Id;
        ass2ver2.Azure_Document_URL__c = url1;
        INSERT ass2ver2;
        System.assert(ass2ver1.Id != null, 'Asset2Ver rec not found');
        String error = '';
        try{
            Test.startTest();
            Boolean updatedOrNot = EntityCredVerController.updCaseVPForNotAccRes(newCase.Id, mainAcc.Id);
            System.assert(updatedOrNot == true,'Case and verification packet assets are not updated');
            Test.stopTest();
        }catch(Exception ex){
            error = ex.getMessage();
        }
    }
    @IsTest
    public static void testUpdCaseVPForNotCertifiedNotAuth(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        User usr = [SELECT Id,ContactId FROM User WHERE username = 'testuser@test.com' LIMIT 1];
        Id entityRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account mainAcc = new Account();
        mainAcc.Name = 'UserAccount1';
        mainAcc.RecordTypeId = entityRecordType;
        mainAcc.Entity_Restriction__c = null;
        mainAcc.BillingCountry = BILLING_COUNTRY;
        INSERT mainAcc;
        System.assert(mainAcc.Id != null,'Entity account not found');
        Id credVerRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION ).getRecordTypeId();
        Case newCase = new Case();
        newCase.RecordTypeId = credVerRecTypeId;
        newCase.ContactId = con.Id;
        newCase.AccountId = acc.Id;
        newCase.Service__c = Constants.CASE_SERVICE_EPIC;
        newCase.Entity__c = mainAcc.Id;
        newCase.Document_Type__c = 'Transcript to Document Transfer Credits';
        newCase.Certify_the_Document__c = Constants.CANNOT_CERTIFY_ENTITY;
        newCase.Reason_for_not_Certifying__c = 'Credential is not authentic';
        INSERT newCase;
        System.assert(newCase.Id!=null,'Case not created.');
        Id assetRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_VERIFICATION).getRecordTypeId();  
        Id credAsstRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_CREDENTIAL).getRecordTypeId();
        Id suppDocAssRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_SUPP_DOCUMENT).getRecordTypeId();
        String url1 = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/00302000004oj9mAAA_Transfer_Credit_Transcript_2020-11-18_04_10_37.pdf';
        Asset asst1 = new Asset(Name = Constants.ASSET_TYPE_RETURNED_VERIFICATION_FORM,
                                Status = Constants.ASSET_STATUS_NEW,
                                ContactId = usr.contactId,
                                Case__c = newCase.Id,
                                InstallDate = System.Today(),
                                Type__c	= Constants.ASSET_TYPE_VERIFICATION_FORM,
                               	RecordTypeId = assetRecTypeId);
        INSERT asst1;
        system.assert(asst1.Id!=null,ASSETNOTCREATED);
        Asset asst2 = new Asset(Name = 'Returned Transcript to Document Transfer Credits',
                                Status = Constants.ASSET_STATUS_NEW,
                                ContactId = usr.contactId,
                                Case__c = newCase.Id,
                                InstallDate = System.Today(),
                                Type__c	= Constants.ASSET_TYPE_TCT,
                               	RecordTypeId = credAsstRecTypeId);
        INSERT asst2;
        system.assert(asst2.Id!=null,ASSETNOTCREATED);
        Asset asst3 = new Asset(Name = Constants.ASSET_TYPE_ENTITY_SUPPORTING_DOCUMENTS,
                                Status = Constants.ASSET_STATUS_NEW,
                                ContactId = usr.contactId,
                                InstallDate = System.Today(),
                                Type__c	= Constants.ASSET_TYPE_SUPPORTING_DOCUMENTS,
                                Case__c = newCase.Id,
                                Azure_Storage_URL__c = url1,
                                RecordTypeId = suppDocAssRecTypeId
        );
        INSERT asst3;
        system.assert(asst3.Id!=null,ASSETNOTCREATED);
        Asset asst4 = new Asset(Name = Constants.ASSET_NAME_SUPPORTING_DOCUMENTS,
                                Status = Constants.ASSET_STATUS_NEW,
                                ContactId = usr.contactId,
                                InstallDate = System.Today(),
                                Type__c	= Constants.ASSET_TYPE_SUPPORTING_DOCUMENTS,
                                Case__c = newCase.Id,
                                Azure_Storage_URL__c = url1,
                                RecordTypeId = suppDocAssRecTypeId
        );
        INSERT asst4;
        system.assert(asst4.Id!=null,ASSETNOTCREATED);
        Verification_Packet__c verPckt = new Verification_Packet__c();
        verPckt.Case__c = newCase.Id;
        verPckt.Request_additional_information__c = null;
        verPckt.Entity_provide_the_credential__c = true;
        verPckt.Is_Active__c = true;
        INSERT verPckt;
        System.assert(verPckt.Id != null, 'verification packet not found');
        Asset2Verification__c ass2ver = new Asset2Verification__c();
        ass2ver.Document_Type__c = Constants.ASSET2VER_DOCTYPE_SOURCE;
        ass2ver.Verification_Packet__c = verPckt.Id;
        ass2ver.Asset__c = asst2.Id;
        INSERT ass2ver;
        System.assert(ass2ver.Id != null, 'Asset2Verifcation rec not found');
        Asset2Verification__c ass2ver1 = new Asset2Verification__c();
        ass2ver1.Document_Type__c = Constants.ASSET2VER_DOCTYPE_RETURNED_VER_FORM;
        ass2ver1.Verification_Packet__c = verPckt.Id;
        ass2ver1.Asset__c = asst1.Id;
        INSERT ass2ver1;
        System.assert(ass2ver1.Id != null, 'Asset2Verifcation rec not found');
        Asset2Verification__c ass2ver2 = new Asset2Verification__c();
        ass2ver2.Document_Type__c = Constants.ASSET2VER_DOCTYPE_SUPPORTING_DOCUMENT;
        ass2ver2.Verification_Packet__c = verPckt.Id;
        ass2ver2.Asset__c = asst3.Id;
        ass2ver2.Azure_Document_URL__c = url1;
        INSERT ass2ver2;
        System.assert(ass2ver1.Id != null, 'Asset2Ver rec not found');
        Asset2Verification__c ass2ver3 = new Asset2Verification__c();
        ass2ver3.Document_Type__c = Constants.ASSET2VER_DOCTYPE_SUPPORTING_DOCUMENT;
        ass2ver3.Verification_Packet__c = verPckt.Id;
        ass2ver3.Asset__c = asst4.Id;
        ass2ver3.Azure_Document_URL__c = url1;
        INSERT ass2ver3;
        System.assert(ass2ver3.Id != null, 'Asset2Ver rec not found');
        String error = '';
        try{
            Test.startTest();
            Boolean updatedOrNot = EntityCredVerController.updCaseVPForNotAccRes(newCase.Id, mainAcc.Id);
            System.assert(updatedOrNot == true,'Case and verification packet assets are not updated');
            Test.stopTest();
        }catch(Exception ex){
            error = ex.getMessage();
        }
    }
    @IsTest
    public static void testUpdCaseVPForNotCertified(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        User usr = [SELECT Id,ContactId FROM User WHERE username = 'testuser@test.com' LIMIT 1];
        Id entityRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account mainAcc = new Account();
        mainAcc.Name = 'UserAccount1';
        mainAcc.RecordTypeId = entityRecordType;
        mainAcc.Entity_Restriction__c = null;
        mainAcc.BillingCountry = BILLING_COUNTRY;
        INSERT mainAcc;
        System.assert(mainAcc.Id != null,'Entity account not found');
        Id credVerRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION ).getRecordTypeId();
        Case newCase = new Case();
        newCase.RecordTypeId = credVerRecTypeId;
        newCase.ContactId = con.Id;
        newCase.AccountId = acc.Id;
        newCase.Service__c = Constants.CASE_SERVICE_EPIC;
        newCase.Entity__c = mainAcc.Id;
        newCase.Document_Type__c = 'Transcript to Document Transfer Credits';
        newCase.Certify_the_Document__c = Constants.CANNOT_CERTIFY_ENTITY;
        newCase.Reason_for_not_Certifying__c = 'Credential includes an administrative error(s)';
        INSERT newCase;
        System.assert(newCase.Id!=null,'Case not created.');
        Id assetRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_VERIFICATION).getRecordTypeId();  
        Id credAsstRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_CREDENTIAL).getRecordTypeId();
        Id suppDocAssRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_SUPP_DOCUMENT).getRecordTypeId();
        String url1 = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/00302000004oj9mAAA_Transfer_Credit_Transcript_2020-11-18_04_10_37.pdf';
        Asset asst1 = new Asset(Name = Constants.ASSET_TYPE_RETURNED_VERIFICATION_FORM,
                                Status = Constants.ASSET_STATUS_NEW,
                                ContactId = usr.contactId,
                                Case__c = newCase.Id,
                                InstallDate = System.Today(),
                                Type__c	= Constants.ASSET_TYPE_VERIFICATION_FORM,
                               	RecordTypeId = assetRecTypeId);
        INSERT asst1;
        Asset asst2 = new Asset(Name = 'Returned Transcript to Document Transfer Credits',
                                Status = Constants.ASSET_STATUS_NEW,
                                ContactId = usr.contactId,
                                Case__c = newCase.Id,
                                InstallDate = System.Today(),
                                Type__c	= Constants.ASSET_TYPE_TCT,
                               	RecordTypeId = credAsstRecTypeId);
        INSERT asst2;
        Asset asst3 = new Asset(Name = Constants.ASSET_TYPE_ENTITY_SUPPORTING_DOCUMENTS,
                                Status = Constants.ASSET_STATUS_NEW,
                                ContactId = usr.contactId,
                                InstallDate = System.Today(),
                                Type__c	= Constants.ASSET_TYPE_SUPPORTING_DOCUMENTS,
                                Case__c = newCase.Id,
                                Azure_Storage_URL__c = url1,
                                RecordTypeId = suppDocAssRecTypeId
        );
        INSERT asst3;
        Verification_Packet__c verPckt = new Verification_Packet__c();
        verPckt.Case__c = newCase.Id;
        verPckt.Request_additional_information__c = null;
        verPckt.Entity_provide_the_credential__c = true;
        verPckt.Is_Active__c = true;
        INSERT verPckt;
        System.assert(verPckt.Id != null, 'verification packet not found');
        Asset2Verification__c ass2ver = new Asset2Verification__c();
        ass2ver.Document_Type__c = Constants.ASSET2VER_DOCTYPE_SOURCE;
        ass2ver.Verification_Packet__c = verPckt.Id;
        ass2ver.Asset__c = asst2.Id;
        INSERT ass2ver;
        System.assert(ass2ver.Id != null, 'Asset2Verifcation rec not found');
        Asset2Verification__c ass2ver1 = new Asset2Verification__c();
        ass2ver1.Document_Type__c = Constants.ASSET2VER_DOCTYPE_RETURNED_VER_FORM;
        ass2ver1.Verification_Packet__c = verPckt.Id;
        ass2ver1.Asset__c = asst1.Id;
        INSERT ass2ver1;
        System.assert(ass2ver1.Id != null, 'Asset2Verifcation rec not found');
        Asset2Verification__c ass2ver2 = new Asset2Verification__c();
        ass2ver2.Document_Type__c = Constants.ASSET2VER_DOCTYPE_SUPPORTING_DOCUMENT;
        ass2ver2.Verification_Packet__c = verPckt.Id;
        ass2ver2.Asset__c = asst3.Id;
        ass2ver2.Azure_Document_URL__c = url1;
        INSERT ass2ver2;
        System.assert(ass2ver1.Id != null, 'Asset2Ver rec not found');
        String error = '';
        try{
            Test.startTest();
            Boolean updatedOrNot = EntityCredVerController.updCaseVPForNotAccRes(newCase.Id, mainAcc.Id);
            EntityCredVerController.getPriorCaseStatus(newCase.Id);
            System.assert(updatedOrNot == true,'Case and verification packet assets are not updated');
            Test.stopTest();
        }catch(Exception ex){
            error = ex.getMessage();
        }
    }
    @istest
    public static void testStamp(){
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Unique_Medical_School_ID__c = 'TA123';
        acc.BillingCountry = BILLING_COUNTRY;
        INSERT acc;
        System.assert(acc.Id != null, 'test account insert failed');
        Asset asst1 = new Asset(
                Name = Constants.ASSET_TYPE_ENTITY_SEAL,
                Status = Constants.ASSET_STATUS_ACCEPTED,
                AccountId = acc.Id,
                InstallDate = System.Today(),
                key__c = Constants.ASSET_TYPE_TCT,
                Type__c	= Constants.ASSET_TYPE_ENTITY_SEAL,
            	Azure_Storage_URL__c = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/099095_ECFMGUniversity_SchoolSeal.gif'
            );
       	insert asst1;
        System.assert(asst1.Id != null, 'test entity seal insert failed');
        Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator_UploadDocument());
        EntityCredVerController.getEntitySeal(acc.Id);
        test.stopTest();
    }
    @isTest
    public static void testGetVerReview(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Id entityRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account mainAcc = new Account();
        mainAcc.Name = 'UserAccount1';
        mainAcc.RecordTypeId = entityRecordType;
        mainAcc.Entity_Restriction__c = 'Internal Only';
        mainAcc.BillingCountry = 'United States';
        mainAcc.BillingState = 'New Jersey';
        mainAcc.BillingPostalCode = 'x123';
        INSERT mainAcc;
        System.assert(mainAcc.Id != null, 'Entity account not found');
        Id credVerRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION ).getRecordTypeId();
        Case newCase = new Case();
        newCase.RecordTypeId = credVerRecTypeId;
        newCase.ContactId = con.Id;
        newCase.AccountId = acc.Id;
        newCase.Service__c = Constants.CASE_SERVICE_EPIC;
        newCase.Entity__c = mainAcc.Id;
        newCase.Internal_Status__c = Constants.CASE_STATUS_INCOMPLETE_RESENT_FOR_VERIFICATION;
        newCase.Document_Type__c = 'Certificate of Good Standing';
        INSERT newCase;
        System.assert(newCase.Id != null, 'Case not created.');
        Id affirmVerRevId = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get(Constants.AFFIRMATION_RECORD_TYPE_VERIFICATION_REVIEW).getRecordTypeId();
        Affirmation__c affirm = new Affirmation__c();
        affirm.Case__c = newCase.Id;
        affirm.RecordTypeId = affirmVerRevId;
        affirm.Status__c = 'In Progress';
        affirm.Incomplete_Reason_Authorization__c = true;
        affirm.Incomplete_Reason_Grades__c = true;
        affirm.Incomplete_Reason_Completion_Med_Ed_form__c = true;
        affirm.Incomplete_Reason_Completion_Verform__c = true;
        affirm.Incomplete_Reason_Credential__c = true;
        affirm.Incomplete_Reason_Envelope__c = true;
        affirm.Incomplete_Reason_Name_Match__c = true;
        affirm.Incomplete_Reason_Name_Missing__c = true;
        affirm.Incomplete_Reason_OfficeSeal_Stamp_Miss__c = true;
        affirm.Incomplete_Reason_OfficeSeal_StampNotMat__c = true;
        affirm.Incomplete_Reason_Other__c = true;
        affirm.Comments__c = 'Testing Comments';
        affirm.Incomplete_Reason_Response__c = true;
        affirm.Incomplete_Reason_Return__c = true;
        affirm.Incomplete_Reason_Signature_Match__c =true;
        affirm.Incomplete_Reason_Signature_Missing__c = true;
        affirm.Incomplete_Reason_Title_Match__c = true;
        affirm.Incomplete_Reason_Title_Missing__c = true;
        affirm.Incomplete_Reason_Transcript__c = true;
        affirm.Incomplete_Reason_Transcript_Seal__c = true;
        affirm.Incomplete_Reason_Verification__c = true;
        INSERT affirm;
        System.assert(affirm.Id != null, 'Affirmation rec not created');
        List<String> retList = new List<String>();
        Map<String,String> reason= new Map<String,String>();
        reason.put('Incomplete_Reason_Grades','test');
        String error = '';
        EntityCredVerController.getIncReasonText(affirm);
        EntityCredVerController.refactgetIncReasonText1(affirm,reason);
        try{
            Test.startTest();
            retList = EntityCredVerController.getVerRevAffirm(newCase.Id);
            System.assert(!retList.isEmpty(),'No Incomplete Reasons returned');
            Test.stopTest();
        }catch(Exception ex){
            error = ex.getMessage();
        }
    }
}