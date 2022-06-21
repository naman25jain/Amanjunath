@isTest
public class ApplicantCommunityControllerTest extends ECFMGTestFactory{
    static final string MEDSCHOOL = 'Medical School';
    public static testMethod void runTest(){        
        //create a new contact;
        date birthdate1 = date.valueOf('2001-01-01');
        Contact c1 = new Contact(Firstname='First',Lastname='Last',Birthdate=birthdate1);
        insert c1;        
        //create a medical school
        string artid = ApplicantCommunityControllerTest.getRecordTypeId(Constants.ACCOUNT_RECORD_TYPE_MEDICAL_SCHOOL, 'Account');
        Account a1 = new Account(Name='Test Account Medical School', RecordTypeId=artid);
        insert a1;        
        //associate that medical school to the contact
        string cartid = ApplicantCommunityControllerTest.getRecordTypeId(Constants.ACCOUNT_RECORD_TYPE_MEDICAL_SCHOOL, 'Contact_Association_Type__c');
        Contact_Association_Type__c ca = new Contact_Association_Type__c(Contact__c =c1.Id, Account__c=a1.Id, RecordTypeId=cartid);
        insert ca;
        // Create Case
        Case caseobj = new Case();
        caseobj.ContactId = c1.Id;
        caseobj.AccountId = c1.AccountId;
        caseobj.Internal_Status__c = 'Accepted';        
        insert caseObj;        
        //get the list of medical school associations from the Class
        List<ContactAssociationTypeViewModel> cat = ApplicantCommunityController.getContactAssociationTypes(c1.Id, Constants.ACCOUNT_RECORD_TYPE_MEDICAL_SCHOOL);
        //make sure we got back a row
        system.assertEquals(cat.size()>0, true, 'Cat size is zero');
        //delete the association;
        ApplicantCommunityController.deleteContactAssociationType(ca.Id);        
        // Call ApplicantCommunityController methods
        ApplicantCommunityController.GetAccountRecordTypes();         
        ApplicantCommunityController.getContactAssociationRecordTypes();    
        ApplicantCommunityController.getMonthPicklistEntries();
        ApplicantCommunityController.getContact(c1.Id);        
        ApplicantCommunityController.getCase(caseObj.Id);         
        ApplicantCommunityController.getContactAssociationRecord(c1.Id);        
        ApplicantCommunityController.deleteContactAssociationTypes(c1.Id, 'Applicant');
        //Test some helper functions:
        List<SelectOption> sol = ApplicantCommunityController.getCountryPicklistEntries();
        system.assertEquals(sol.size()>0, true,'sol size is zero');
        SelectOption selOpt = new SelectOption('India','India',false);
        system.assertEquals('India',selOpt.label,'selOpt label is not the same');
        system.assertEquals('India',selOpt.value,'selOpt value is not the same');
        system.assertEquals(false,selOpt.disabled,'selOpt disabled is not false');
        string userId = ApplicantCommunityController.getRunningUserId();
        system.assert(userId.length()>0, true);
        try{
            //as long as this works we're good; it could return null and be correct
            string contactid = ApplicantCommunityController.getRunningContactId();
        } 
        catch(exception e){
            System.assert(e.getMessage().contains('find Community'), 'message=' + e.getMessage());
        }     
    }
    public static string getRecordTypeId(string rtname, string objecttype){
        string id = [select id from Recordtype where sobjecttype=:objecttype AND name = :rtname LIMIT 1].Id;
        return id;
    }
    public static testMethod void testgetCaseImages(){        
        //create a medical school
        string artid = ApplicantCommunityControllerTest.getRecordTypeId(MEDSCHOOL, 'Account');
        Account acc = new Account(Name='Test Medical School', RecordTypeId=artid);
        insert acc;  
        // create case without contact id
        Case caseobj1 = new Case();
        caseobj1.AccountId = acc.Id;
        caseobj1.Internal_Status__c = 'Accepted';        
        insert caseobj1;        
        //create a new contact;
        Date birthDate1 = Date.valueOf('2000-01-01');
        Contact con = new Contact(Firstname='First',Lastname='Last',Birthdate=birthdate1, AccountId=acc.Id);
        insert con;
        // create case
        Id caserecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Identity_Verification').getRecordTypeId();
        Case caseobj = new Case();
        caseobj.recordTypeId = caserecordTypeId;
        caseobj.ContactId = con.Id;
        caseobj.AccountId = con.AccountId;
        caseobj.Internal_Status__c = 'Accepted';        
        insert caseObj;
        // Crate Contact_Association_Type_Staging__c
        Id recordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Other_Institution').getRecordTypeId();
        Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
        cats.recordTypeId = recordTypeId;
        cats.Account__c = con.AccountId;
        cats.Case__c = caseObj.Id;
        cats.Contact__c = con.Id;
        cats.Type__c = 'Degree School';
        insert cats;
        // Create Asset
        Asset asst1 = new Asset(Name = 'Test Asset',
            					Status = 'In Progress',
            					AccountId = con.AccountId,
            					ContactId = con.Id,
            					InstallDate = System.Today(),
            					UsageEndDate = System.Today(),
            					key__c	=	'DIPLOMA DOCUMENT',
            					Type__c	=	'Translation',
            					Contact_Association_Type_Staging__c = cats.Id,
            					Case__c = caseObj.Id);        
        insert asst1;        
        try{
            ContentVersion contentVersion = new ContentVersion(Title = 'TestImage',
              													PathOnClient = 'TestImage.pdf',
              													VersionData = Blob.valueOf('Test Content'),
              													IsMajorVersion = true);
            insert contentVersion;    
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 1];            
            //create ContentDocumentLink  record 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = asst1.id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = 'V';
            insert cdl;            
            test.startTest();
            List<CaseImageModel> caseImageList = ApplicantCommunityController.getCaseImages(caseObj.Id);
            system.assertEquals(caseImageList.size()>0, true, 'caseImageList size is zero');
            List<ApplicantDuplicateMatchModel> appMatches = ApplicantCommunityController.getApplicantMatches(caseObj1.Id);
            system.assertEquals(appMatches.size()>0, true, ' appMatches size is zero');   
            test.stopTest();
        }
        catch(Exception e){
            System.assert(e.getMessage().contains('Identity Verification case must'), 'message=' + e.getMessage());
        }
    }
    public static testMethod void testgetCaseImagesAppForCert(){
        //create a medical school
        string artid = ApplicantCommunityControllerTest.getRecordTypeId(MEDSCHOOL, 'Account');
        Account acc = new Account(Name='Test Medical School', RecordTypeId=artid);
        insert acc;
        //create a new contact;
        Date birthDate1 = Date.valueOf('2000-01-01');
        Contact con = new Contact(Firstname='First',Lastname='Last',Birthdate=birthdate1, AccountId=acc.Id);
        insert con;
        Id caserecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Application_For_Certification').getRecordTypeId();
        Case caseobj = new Case();
        caseobj.recordTypeId = caserecordTypeId;
        caseobj.ContactId = con.Id;
        caseobj.AccountId = con.AccountId;
        caseobj.Internal_Status__c = 'Accepted';        
        insert caseObj;
        Id recordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Other_Institution').getRecordTypeId();
        Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
        cats.recordTypeId = recordTypeId;
        cats.Account__c = con.AccountId;
        cats.Case__c = caseObj.Id;
        cats.Contact__c	= con.Id;
        cats.Type__c = 'Degree School';
        insert cats;        
        Asset asst1 = new Asset(Name = 'Test Asset',
            					Status = 'In Progress',
            					AccountId = con.AccountId,
            				 	ContactId = con.Id,
            					InstallDate = System.Today(),
            					UsageEndDate = System.Today(),
            				 	key__c	= 'DIPLOMA DOCUMENT',
            					Type__c = 'Translation',
            					Contact_Association_Type_Staging__c = cats.Id,
            					Case__c = caseObj.Id);
        insert asst1;
        try{
            ContentVersion contentVersion = new ContentVersion(Title = 'TestImage',
              													  PathOnClient = 'TestImage.jpg',
              													  VersionData = Blob.valueOf('Test Content'),
              													  IsMajorVersion = true);
            insert contentVersion;
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 1];
            //create ContentDocumentLink  record 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = asst1.id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = 'V';
            insert cdl;
            test.startTest();
            List<CaseImageModel> caseImageList = ApplicantCommunityController.getCaseImages(caseObj.Id);
            system.assertEquals(caseImageList.size()>0, true, 'caseImageList size is zro');
            List<ApplicantDuplicateMatchModel> appMatches = ApplicantCommunityController.getApplicantMatches(caseObj.Id);     
            system.assertEquals(appMatches.size()>0, true, 'appMatches size is zro');       	
            test.stopTest();
        }
        catch(Exception e){
        	System.assert(e.getMessage().contains('null object'), 'message = ' +e.getMessage());
        } 
    }
    public static testMethod void testerrorTest(){
        try{
            test.startTest();
            Map<String, List<String>> geoMap = ApplicantCommunityController.getGeoData();
            system.assertEquals(geoMap.size()>0, true, 'geoMap size is zro');       
            List<SelectOption> countryMap =  ApplicantCommunityController.getCountryAndStatePicklistEntries();
            system.assertEquals(countryMap.size()>0, true, 'countryMap size is zro'); 
            Duplicate_Check_Setting__mdt dupSetting = ApplicantCommunityController.getDuplicateCheckSettings();
            System.assert(dupSetting.Id!=null,'No duplicate settings returned');
            ApplicantCommunityController.errorTest();
            test.stopTest();
        }
        catch(Exception e){
            System.assert(e.getMessage().contains('Test exception'), 'message = ' +e.getMessage());
        }
    }
    public static testMethod void testApplicantDuplicateModel(){
        string artid = ApplicantCommunityControllerTest.getRecordTypeId(MEDSCHOOL, 'Account'); 
        Account acc1 = new Account(Name='Test Med School', RecordTypeId = artid);
        insert acc1;
        Date birthDate1 = Date.valueOf('2001-01-01');
        Contact con1 = new Contact( Firstname = 'Second', Lastname = 'last', Birthdate = birthdate1,Birth_Country__c= 'USA', AccountId=acc1.Id,Medschool_Code__c ='X0032', Gender__c= 'Male');
        insert con1;
        ApplicantDuplicateMatchModel model = new ApplicantDuplicateMatchModel();
        integer result=0;
        model.contactId=con1.id;
        model.Id = con1.Id;
        model.LastName = con1.LastName;
        model.RestOfName = con1.FirstName;
        model.BirthDate  = con1.Birthdate;
        model.BirthCountry = con1.Birth_Country__c;
        model.Gender = con1.Gender__c;
        model.MedschoolCode = con1.Medschool_Code__c;
        model.Score =100;
        System.assert(model.ScorePercentage!=null, 'Score Percentage is zero');
        model.compareTo(model);
    }
    
    @isTest
    public static void invokeCibisCandRequestEvent(){
        List<Id> caseIds = new List<Id>();
        string artid = ApplicantCommunityControllerTest.getRecordTypeId(Constants.ACCOUNT_RECORD_TYPE_MEDICAL_SCHOOL, 'Account');
        Account a1 = new Account(Name='Test Account Medical School', RecordTypeId=artid);
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, a1);
        
        date birthdate1 = date.valueOf('2001-01-01');
        Contact c1 = new Contact(Firstname='First',Lastname='Last',Birthdate=birthdate1, Gender__c='Male');
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, c1);
        
        // Create Case
        Case caseobj = new Case();
        caseobj.Contact = c1;
        caseobj.Account = a1;
        caseobj.Internal_Status__c = 'Accepted';        
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, caseobj);

        // Create CAT record
        Contact_Association_Type__c catObj = new Contact_Association_Type__c(Contact__r=c1, Account__r=a1);
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactAssociationTestData.class, catObj);
        
        // Insert all Sobjects
        run();       

        caseIds.add(caseObj.Id);
        Test.startTest();
        ApplicantCommunityController.cibisCandRequestEvent(caseObj.Id);
        String retvalForNull = ApplicantCommunityController.cibisCandRequestEvent(null);
        System.assert(retvalForNull == null,'Return Value is not null or Blank');
        CibisDupCheckRequestEventHandler.buildDupCheck(caseIds);
        Test.stopTest();
    }
    
    @isTest()
    public static void getCibisCandidate(){
        Test.startTest();
        string artid = ApplicantCommunityControllerTest.getRecordTypeId(Constants.ACCOUNT_RECORD_TYPE_MEDICAL_SCHOOL, 'Account');
        Account a1 = new Account(Name='Test Account Medical School', RecordTypeId=artid);
        insert a1;
        
        date birthdate1 = date.valueOf('2001-01-01');
        Contact c1 = new Contact(Firstname='First',Lastname='Last',Birthdate=birthdate1, Gender__c='Male',Email='noemail@nomeal.com');
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, c1);
        
        // Create Case
        Case caseobj = new Case();
        caseobj.Contact= c1;
        caseobj.Account = a1;
        caseobj.Internal_Status__c = 'Accepted';        
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, caseobj);
        
        // Create Product Id Form
        Id prdIdenityRecTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Identity').getRecordTypeId();
        Product2 prodObj = new Product2();
        prodObj.Name = 'ID Form';
        prodObj.RecordTypeID = prdIdenityRecTypeId;
        prodObj.Family = 'Identity';
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultProductTestData.class, prodObj);

        // Create Content_Manager__c obj
        Content_Manager__c cmObj = new Content_Manager__c();
        cmObj.Name = 'CIBIS Contact Email';
        cmObj.Unique_Name__c = 'Why did have to happen';
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactManagerTestData.class, cmObj);
        
        // Insert all Sobjects
        run();

        CIBIS_Duplicate_Check__c duplicateCheckRec = new CIBIS_Duplicate_Check__c(Name = 'Test', CIBIS_USMLE_ID__c = '123', Contact__c = c1.Id, Case__c = caseObj.Id);
        insert duplicateCheckRec;
        
        CIBIS_Duplicate_Check__c retDupCibisCheck = ApplicantCommunityController.getCibisCandidate('123');
        System.assertEquals(retDupCibisCheck.Id, duplicateCheckRec.Id, 'duplicate checks are not Same');
        ApplicantCommunityController.updatecaseContactWithConfirm(duplicateCheckRec);
        Contact con = [SELECT id,USMLE_ID__c FROM Contact Where id=:c1.Id LIMIT 1];
        System.assertEquals(duplicateCheckRec.CIBIS_USMLE_ID__c, con.USMLE_ID__c, 'USMLE id not update to contact');
        Test.stopTest();
    }

    @isTest()
    public static void getContactDetailsandcibisCandResponsetest(){
        date birthdate1 = date.valueOf('2001-01-01');
        Contact c1 = new Contact(Firstname='First',Lastname='Last',Birthdate=birthdate1, Gender__c='Male',Email='noemail@nomeal.com');
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, c1);

        Case caseobj = new Case();
        caseobj.Contact= c1;
        caseobj.Internal_Status__c = 'Accepted';        
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, caseobj);

        run();

        Case returnedCase = ApplicantCommunityController.getContactDetails(caseobj.Id);
        System.assertEquals(returnedCase.ContactId, c1.Id, 'Contact Detail not returned');

        CIBIS_Duplicate_Check__c duplicateCheckRec = new CIBIS_Duplicate_Check__c(Name = 'Test', CIBIS_USMLE_ID__c = '123', Contact__c = c1.Id, Case__c = caseObj.Id);
        insert duplicateCheckRec;
        List<CIBIS_Duplicate_Check__c> cibisList = ApplicantCommunityController.cibisCandResponse(caseobj.Id);
        System.assert(cibisList.size()>0, 'Cibis List not Fetched');
    }
}