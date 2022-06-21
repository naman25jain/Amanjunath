/**
* Factory Class for AppForCert functionality
*
* @author        Enable Consulting
* @version       1.0
* @createdDate   13-DEC-2019
*/
@isTest
public class AppforCertTestFactory{
    public static final String ASSET_NAME = 'Test Asset';
    public static final String DIPLOMA_DOCUMENT = 'DIPLOMA DOCUMENT';
    public static final String UNITED_STATES  = 'United States';
    public static final String AMERICA_LA = 'America/Los_Angeles';
	public static testMethod void servicePageSetup(){
        CurrentEntityIDSequence__c settings = CurrentEntityIDSequence__c.getOrgDefaults();
        settings.Entity_ID__c = '00000';
        upsert settings CurrentEntityIDSequence__c.Id;
        CurrentECFMGIDSequence__c curECFMGSetting = CurrentECFMGIDSequence__c.getOrgDefaults();
        curECFMGSetting.ECFMG_ID__c = '00000';
        upsert curECFMGSetting CurrentECFMGIDSequence__c.Id;
        //create ofac country
        List<OFAC__c> ofacList = new List<OFAC__c>();
        OFAC__c ofac = new OFAC__c(Country__c='Afghanistan', Type__c=System.Label.OFAC_NOT_ALLOWED);
        OFAC__c ofacNBME = new OFAC__c(Country__c='India', Type__c=System.Label.OFAC_NOT_ALLOWED1);
        OFAC__c ofacWarning = new OFAC__c(Country__c='Albania', Type__c=System.Label.OFAC_Country_Warning);
        ofacList.add(ofac);
        ofacList.add(ofacNBME);
        ofacList.add(ofacWarning);
        INSERT ofacList;
        System.assert(ofacList[0].Id != null, 'ofacList ID is null');
        //Contact Association Type Staging Record Type Ids
        Id conAssocStagingDegMedSch = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
        Id conAssocStagingOtherInst = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Other_Institution').getRecordTypeId();
        List<Account> accountList = new List<Account>();
        Id identityAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account acc3 = new Account(Name='EntityAcctNameforNegative',RecordTypeId=identityAccountRecordTypeId,School__c=false, Is_Final_Transcript_Required__c = true, BillingCountry = 'India',BillingState='Kerala',billingpostalcode = '123456');        
        INSERT acc3;
        System.assert(acc3.Id != null, 'acc3 ID is null');
        Account acc4 = new Account(Name='EntityAcctNameNew',RecordTypeId=identityAccountRecordTypeId,School__c=false, Is_Final_Transcript_Required__c = true, BillingCountry = 'India',BillingState='Karnataka',billingpostalcode = '123257');       
        INSERT acc4;
        System.assert(acc4.Id != null, 'acc4 ID is null');
        Account acc5 = new Account(Name='Test Account',RecordTypeId=identityAccountRecordTypeId,School__c=false, Is_Final_Transcript_Required__c = true, BillingCountry = 'India',BillingState='Goa',billingpostalcode = '123457');               
        INSERT acc5;
        accountList.add(acc3);
        accountList.add(acc4);
        accountList.add(acc5);
        //create a new contact;
        List<Contact> contactList = new List<Contact>();
        Date birthdate1 = date.valueOf('2000-01-01');
        String emailtest = 'tester@unknownmail.com';
        String userName = 'tester@unknownmail.com_' + System.now();
        userName = userName.replace(' ','').replace(':','-');
        String lastname = 'Last';
        String firstname = 'First';
        String usmleId = '123';
        Contact c1 = new Contact(AccountId = acc4.Id, Firstname=firstname,Lastname=lastname,Birthdate=birthdate1,email=emailtest,MailingCountry='Mexico',USMLE_ID__c = usmleId);
        contactList.add(c1);
        Date birthdate2 = date.valueOf('2000-01-01');
        String emailtest1 = 'tester@unknownmail1.com';
        String userName1 = 'tester@unknownmail1.com_' + System.now();
        userName1=userName1.replace(' ','').replace(':','-');
        String lastname1 = 'Last1';
        String firstname1 = 'First1';
        Contact c2 = new Contact(Firstname=firstname1,Lastname=lastname1,Birthdate=birthdate2,email=emailtest1,MailingCountry='Mexico');
        contactList.add(c2);
        String firstname3 = 'First3';
        String lastname3 = 'Last3';
        String emailtest3 = 'tester3@unknownmail1.com';
        String username3 = 'tester3@unknownmail.com_' + System.now();
        username3 =	username3.replace(' ','').replace(':','-');
        Contact con3 = new Contact(AccountId = acc3.Id, Firstname=firstname3, Lastname=lastname3, Birthdate=birthdate2, email=emailtest3, MailingCountry='Mexico');
        contactList.add(con3);
        String firstname4 =	'First4';
        String lastname4 = 'Last4';
        String emailtest4 = 'tester4@unknownmail1.com';
        String username4 = 'tester4@unknownmail.com_' + System.now();
        username4 =	username4.replace(' ','').replace(':','-');
        Contact con4 = new Contact(AccountId = acc4.Id, Firstname=firstname4, Lastname=lastname4, Birthdate=birthdate2, email=emailtest4, MailingCountry='Mexico');
        contactList.add(con4);        
        INSERT contactList;
        System.assert(contactList[0].Id != null, 'contactList ID is null');
        //get the Household Account
        //String accountname = lastname + ' Household';
        Account acct = new Account(Name = lastname +'Household',RecordTypeId=identityAccountRecordTypeId,School__c=false, Is_Final_Transcript_Required__c = true, BillingCountry = 'India',BillingState='Kerala',billingpostalcode = '123457');
        insert acct;
        //Account a = [Select Id from Account where Name LIKE 'Household' LIMIT 1];
        //System.assert(a.Id!=null,'Account ID is null');
        List<Case> caseList = new List<Case>();
        List<User> userList = new List<User>();
        Id p = [Select id from profile where name='4-Customer Community Plus Login' LIMIT 1].id;
        //create a new User row
        User user = new User(alias='flastt',email=emailtest,emailencodingkey='UTF-8',lastname=lastname, languagelocalekey='en_US',localesidkey='en_US',profileid=p,country=UNITED_STATES,IsActive=true,ContactId=c1.Id, timezonesidkey=AMERICA_LA,username=userName);
        userList.add(user);
        //create new case
        Id idVerCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Identity_Verification').getRecordTypeId();
        Case cs = new Case(AccountId=acc4.Id,ContactId=c1.Id,Service__c='EPIC',Internal_Status__c='New',RecordTypeId=idVerCaseRecordTypeId);
        caseList.add(cs);
        Id idVerCaseRecordTypeId2 = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Application_For_Certification').getRecordTypeId();
        Case cs2 = new Case(AccountId=acc4.Id,ContactId=c1.Id,Service__c='EPIC',Internal_Status__c='Accepted',RecordTypeId=idVerCaseRecordTypeId2);
        caseList.add(cs2);
        INSERT caseList;
        System.assert(caseList[0].Id != null, 'caseList ID is null');
        //create a new User row
        User user1 = new User(alias='second',email=emailtest1,emailencodingkey='UTF-8',lastname=lastname1, languagelocalekey='en_US',localesidkey='en_US',profileid=p,country=UNITED_STATES,IsActive=true,ContactId=c2.Id, timezonesidkey=AMERICA_LA,username=userName1);
        userList.add(user1);
        List<Account> accountListNew = new List<Account>();
        //create Entity record for Account
        Account ac = new Account(Name='EntityAcctName', RecordTypeId=identityAccountRecordTypeId, School__c=true, BillingCountry = 'India',BillingState='Kerala',billingpostalcode = '123458');
        Account ac1 = new Account(Name='EntityAcctNameNoCase',RecordTypeId=identityAccountRecordTypeId,School__c=true, BillingCountry = 'India',BillingState='Kerala',billingpostalcode = '123459');        
		Account ac2 = new Account(Name='EntityAcctNameforNegative1',RecordTypeId=identityAccountRecordTypeId,School__c=false, Is_Final_Transcript_Required__c = true, BillingCountry = 'India',BillingState='Kerala',billingpostalcode = '123450');
        accountListNew.add(ac);
        accountListNew.add(ac1);
        accountListNew.add(ac2);
        INSERT accountListNew;
        System.assert(accountListNew[0].Id != null, 'accountListNew ID is null');
        User user3 = new User(alias='user3',email=emailtest3,emailencodingkey='UTF-8',lastname=lastname3, languagelocalekey='en_US',localesidkey='en_US',profileid=p,country=UNITED_STATES,IsActive=true,ContactId=con3.Id, timezonesidkey=AMERICA_LA,username=username3);
        userList.add(user3);
        //create Degree
        Degree__c deg = new Degree__c(Name = 'BBA', WDOMS_ID__c='7105');
        INSERT deg;
        System.assert(deg.Id != null, 'deg ID is null');  
        //create Object2Degree
        List<Object2Degree__c> o2dList = new List<Object2Degree__c>();
        Id schoolObject2DegreeRecordTypeId = Schema.SObjectType.Object2Degree__c.getRecordTypeInfosByDeveloperName().get('School').getRecordTypeId();
        Object2Degree__c objDeg = new Object2Degree__c(Graduation_Year__c='2010',Account__c=ac.id,Degree__c = deg.Id,RecordTypeId = schoolObject2DegreeRecordTypeId);
        o2dList.add(objDeg);
        Object2Degree__c objDeg1 = new Object2Degree__c(Graduation_Year__c='2010',Account__c=ac1.id,Degree__c = deg.Id,RecordTypeId = schoolObject2DegreeRecordTypeId);
        o2dList.add(objDeg1);
		Object2Degree__c objDegNegative = new Object2Degree__c(Graduation_Year__c='2010',Account__c=ac2.id,Degree__c = deg.Id,RecordTypeId = schoolObject2DegreeRecordTypeId);
        o2dList.add(objDegNegative);
        INSERT o2dList;
        System.assert(o2dList[0].Id != null, 'o2dList ID is null');  
        //create Contact Association type object 
        List<Contact_Association_Type__c> catList = new List<Contact_Association_Type__c>();
		Id conAssocRecordTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
        Contact_Association_Type__c conAssocType = new Contact_Association_Type__c(RecordTypeId=conAssocRecordTypeId,contact__c = c1.Id,Account__c=ac.id);
        catList.add(conAssocType);
		Contact_Association_Type__c conAssocType1 = new Contact_Association_Type__c(RecordTypeId=conAssocRecordTypeId,contact__c = c2.Id,Account__c=ac1.id);
        catList.add(conAssocType1);
        INSERT catList;
        System.assert(catList[0].Id != null, 'catList ID is null');
		//create new case with recordtype : 
        Id idAppForCertCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Authorized_Signature_List').getRecordTypeId();
        Case csAppForCert = new Case(AccountId=acc3.Id,ContactId=con3.Id,Service__c='EPIC',Internal_Status__c='New',RecordTypeId=idAppForCertCaseRecordTypeId);
        INSERT csAppForCert;
        System.assert(csAppForCert.Id != null, 'csAppForCert ID is null');       
		//create Contact Association type object (Staging)        
        Contact_Association_Type_Staging__c conAssocTypeStaging = new Contact_Association_Type_Staging__c(RecordTypeId=conAssocStagingDegMedSch,contact__c = con3.Id, Account__c=acc3.id,case__c=csAppForCert.Id, IsDeanLetter__c = true, Status__c = 'Graduate');
        INSERT conAssocTypeStaging;
        System.assert(conAssocTypeStaging.Id != null, 'conAssocTypeStaging ID is null');   
        Id assetRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Application_for_Certification').getRecordTypeId();
        List<Asset> assetList = new List<Asset>();
        //Create and Insert Asset
        Asset asst1 = new Asset(
            Name = ASSET_NAME,
            Status = 'Installed',
            AccountId = acc3.id,
            ContactId = con3.Id,
            InstallDate = System.Today(),
            UsageEndDate = System.Today(),
            key__c	=	DIPLOMA_DOCUMENT,
            Type__c	=	'Translation',
            Contact_Association_Type_Staging__c = conAssocTypeStaging.Id
        );
        INSERT asst1;
        System.assert(asst1.Id != null, 'asst1 ID is null');  
        Asset asst2 = new Asset(
            Name = ASSET_NAME,
            Status = 'Installed',
            AccountId = acc3.id,
            ContactId = con3.Id,
            InstallDate = System.Today(),
            UsageEndDate = System.Today(),
            key__c	=	DIPLOMA_DOCUMENT,
            Type__c	=	'Translation',
            ParentId	=	asst1.Id,
            Contact_Association_Type_Staging__c = conAssocTypeStaging.Id
        );
        assetList.add(asst2);
        User user4 = new User(alias='user4',email=emailtest4,emailencodingkey='UTF-8',lastname=lastname4, languagelocalekey='en_US',localesidkey='en_US',profileid=p,country=UNITED_STATES,IsActive=true,ContactId=con4.Id, timezonesidkey=AMERICA_LA,username=username4);
        userList.add(user4);       
		INSERT userList;
        System.assert(userList[0].Id != null, 'userList ID is null');  
		//create new case with recordtype : Application_For_Certification
        Id appForCertCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Application_For_Certification').getRecordTypeId();
		List<Case> caseListNew = new List<Case>();
        Case csAppForCert2 = new Case(AccountId=acc4.Id,ContactId=con4.Id,Service__c='EPIC',Internal_Status__c='Accepted',RecordTypeId=appForCertCaseRecordTypeId);
        caseListNew.add(csAppForCert2);
        //create new case with recordtype Applicant_Biographic_Change:
        Id idBioGraChangeCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Applicant_Biographic_Change').getRecordTypeId();
        Case caseBiographic = new Case(AccountId=acc4.Id,ContactId=con4.Id,Internal_Status__c=Constants.CASE_STATUS_PENDING_REVIEW,RecordTypeId=idBioGraChangeCaseRecordTypeId);
        caseListNew.add(caseBiographic);
        INSERT caseListNew;
        System.assert(caseListNew[0].Id != null, 'caseListNew ID is null');       
		//create Contact Association type object (Staging)  
		List<Contact_Association_Type_Staging__c> catsList = new List<Contact_Association_Type_Staging__c>();
        Contact_Association_Type_Staging__c conAssocTypeStaging2 = new Contact_Association_Type_Staging__c(RecordTypeId=conAssocStagingOtherInst,contact__c = con4.Id, Account__c=acc4.id,case__c=csAppForCert2.Id, IsDeanLetter__c = true, Status__c = 'Graduate');
        catsList.add(conAssocTypeStaging2);  
        Contact_Association_Type_Staging__c conAssocTypeStaging3 = new Contact_Association_Type_Staging__c(RecordTypeId=conAssocStagingDegMedSch,contact__c = con4.Id, Account__c=acc4.id,case__c=csAppForCert2.Id, IsDeanLetter__c = true, Status__c = 'Graduate');
        catsList.add(conAssocTypeStaging3);
        INSERT catsList;
        System.assert(catsList[0].Id != null, 'catsList ID is null');
        List<Affirmation__c> affirmationList = new List<Affirmation__c>();
        Id affirmationRecordTypeId = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get('Transfer_Credit_Transcript').getRecordTypeId();
        Affirmation__c aff = new Affirmation__c(RecordTypeId=affirmationRecordTypeId,Contact_Association_Type_Staging__c=conAssocTypeStaging2.Id,TCT_Courses_Distinctly_Identified__c='No',Acceptable_TCT_Submitted__c='Yes');
        affirmationList.add(aff);
        Id affirmationRecordTypeId1 = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get('Credential_Verification').getRecordTypeId();
        Affirmation__c aff1 = new Affirmation__c(RecordTypeId=affirmationRecordTypeId1,Contact_Association_Type_Staging__c=conAssocTypeStaging3.Id,Credential_Verification_Status__c='Incomplete');
        affirmationList.add(aff1);
        INSERT affirmationList;
        System.assert(affirmationList[0].Id != null, 'affirmationList ID is null');
        //Create and Insert Asset
        Asset asst4 = new Asset(
            Name = ASSET_NAME,
            recordTypeId = assetRecordTypeId,
            Status = 'Installed',
            AccountId = acc4.id,
            ContactId = con4.Id,
            InstallDate = System.Today(),
            UsageEndDate = System.Today(),
            key__c	=	DIPLOMA_DOCUMENT,
            Type__c	=	'Translation',
            Contact_Association_Type_Staging__c = conAssocTypeStaging2.Id
        );
        INSERT asst4;
        System.assert(asst4.Id != null, 'asst4 ID is null');
        Asset asst5 = new Asset(
            Name = ASSET_NAME,
            recordTypeId = assetRecordTypeId,
            Status = 'Installed',
            AccountId = acc4.id,
            ContactId = con4.Id,
            InstallDate = System.Today(),
            UsageEndDate = System.Today(),
            key__c	=	DIPLOMA_DOCUMENT,
            Type__c	=	'Translation',
            ParentId	=	asst4.Id,
            Contact_Association_Type_Staging__c = conAssocTypeStaging2.Id
        );
        assetList.add(asst5);
        Asset asst6 = new Asset(
            Name = ASSET_NAME,
            recordTypeId = assetRecordTypeId,
            Status = 'Installed',   
            AccountId = acc4.id,
            ContactId = con4.Id,
            InstallDate = System.Today(),
            UsageEndDate = System.Today(),
            key__c	=	DIPLOMA_DOCUMENT,
            Type__c	=	'Pre-Med Letter',
            Name_on_Document_is_Different__c = true,
            Document_is_not_in_English__c = true,
            Contact_Association_Type_Staging__c = conAssocTypeStaging2.Id
        );
        assetList.add(asst6);
        Asset asst7 = new Asset(
            Name = ASSET_NAME,
            recordTypeId = assetRecordTypeId,
            Status = 'Installed',   
            AccountId = acc4.id,
            ContactId = con4.Id,
            InstallDate = System.Today(),
            UsageEndDate = System.Today(),
            key__c	=	DIPLOMA_DOCUMENT,
            Type__c	=	'Transfer Credit Transcript',
            Name_on_Document_is_Different__c = true,
            Document_is_not_in_English__c = true,
            Contact_Association_Type_Staging__c = conAssocTypeStaging2.Id
        );
        assetList.add(asst7);
        Asset asstGraduate = new Asset(
            Name = 'Test Asset',
            recordTypeId = assetRecordTypeId,
            Status = 'Installed',   
            AccountId = acc4.id,
            ContactId = con4.Id,
            InstallDate = System.Today(),
            UsageEndDate = System.Today(),
            key__c	=	'DIPLOMA DOCUMENT',
            Type__c	=	'Final Medical Diploma',
            Name_on_Document_is_Different__c = true,
            Document_is_not_in_English__c = true,
            Contact_Association_Type_Staging__c = conAssocTypeStaging2.Id
        );
        assetList.add(asstGraduate);
        INSERT assetList;
        System.assert(assetList[0].Id != null, 'assetList ID is null');
        ContentVersion contentVersion = new ContentVersion(
            Title = 'TestImage',
            PathOnClient = 'TestImage.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        INSERT contentVersion;
        System.assert(contentVersion.Id != null, 'contentVersion ID is null');
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 1];
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = asst6.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        INSERT cdl;
        System.assert(cdl.Id != null, 'cdl ID is null');
        insertSettingsValue();
        WDOMS_ID_Sequence__c wdomsIdSeq = WDOMS_ID_Sequence__c.getOrgDefaults();
        if(test.isRunningTest()){
            if(Null != wdomsIdSeq){
                if(wdomsIdSeq.MDT_Degree_Type_ID__c == 0000001){
                    wdomsIdSeq.MDT_Degree_Type_ID__c = 0000002;
                }else{
                    wdomsIdSeq.MDT_Degree_Type_ID__c = 0000001;
                }
                Upsert wdomsIdSeq;
            }else{
                WDOMS_ID_Sequence__c wdomsIdSequence = new WDOMS_ID_Sequence__c();
                wdomsIdSequence.MDT_Degree_Type_ID__c=0000001;
                insert wdomsIdSequence;
            }
        }
    }
    public static testMethod void insertSettingsValue(){        
        CurrentEntityIDSequence__c settingsValue = CurrentEntityIDSequence__c.getOrgDefaults();
        if(test.isRunningTest()){
            if(Null != settingsValue){
                if(settingsValue.Entity_ID__c == '0000001'){
                    settingsValue.Entity_ID__c = '0000002';
                }else{
                    settingsValue.Entity_ID__c = '0000001';
                }
                
                Upsert settingsValue;
            }else{
                CurrentEntityIDSequence__c settingsInstance = new CurrentEntityIDSequence__c();
                settingsInstance.Entity_ID__c='0000001';
                insert settingsInstance;
                System.assert(settingsInstance.Id!=null,'settingsInstance ID is null');
            }
        }
    }
    public static testMethod void servicePageSetup2() {
        CurrentEntityIDSequence__c settings = CurrentEntityIDSequence__c.getOrgDefaults();
        settings.Entity_ID__c = '00000';
        upsert settings CurrentEntityIDSequence__c.Id;
        CurrentECFMGIDSequence__c curECFMGSetting = CurrentECFMGIDSequence__c.getOrgDefaults();
        curECFMGSetting.ECFMG_ID__c = '00000';
        upsert curECFMGSetting CurrentECFMGIDSequence__c.Id;
        //create a new User row
        date birthdate2 = date.valueOf('2000-01-02');
        Id identityAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Id p=[Select id from profile where name='4-Customer Community Plus Login' LIMIT 1].id;
        string firstname5	=	'First5';
        string lastname5	=	'Last5';
        string emailtest5 	= 	'tester5@unknownmail1.com';
        String username5	=	'tester5@unknownmail.com_' + System.now();
        username5	=	username5.replace(' ','').replace(':','-');
        Account acc5 = new Account(Name='TestAcctNameNew',RecordTypeId=identityAccountRecordTypeId,School__c=false, Is_Final_Transcript_Required__c = true, BillingCountry = 'India',BillingState='Kerala',billingpostalcode = '123469');
        insert acc5;        
        System.assert(acc5.Id!=null,'Account ID is null');
        
        Contact con5 = new Contact(AccountId = acc5.Id, Firstname=firstname5, Lastname=lastname5, Birthdate=birthdate2, email=emailtest5, MailingCountry='India',School_Enrollment_Status__c='Graduate');
        insert con5;
        
        User user5 = new User(alias='user5',email=emailtest5,emailencodingkey='UTF-8',lastname=lastname5, languagelocalekey='en_US',localesidkey='en_US',profileid=p,country=UNITED_STATES,IsActive=true,ContactId=con5.Id, timezonesidkey=AMERICA_LA,username=username5);
        insert user5; 
        
        //Test data for getAssetStatusAndType method
        date birthdate1 = date.valueOf('2000-01-02');
        Id identityAccountRecordTypeId1 = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(constants.ACCOUNT_RECORD_TYPE_ENTITY).getRecordTypeId();
        Id p1=[Select id from profile where name='4-Customer Community Plus Login' LIMIT 1].id;
        string firstname1	=	'First1';
        string lastname1	=	'Last1';
        string emailtest1 	= 	'tester11@unknownmail1.com';
        String username1	=	'tester11@unknownmail.com_' + System.now();
        username1	=	username1.replace(' ','').replace(':','-');
        //Added address details on the Account
        Account acc1 = new Account(Name='EntityAcctNameNew1',RecordTypeId=identityAccountRecordTypeId1,School__c=false, Is_Final_Transcript_Required__c = true, BillingCountry = 'India',BillingState='Kerala',billingpostalcode = '123469');
        insert acc1; 
        
        Contact con1 = new Contact(AccountId = acc1.Id, Firstname=firstname1, Lastname=lastname1, Birthdate=birthdate1, email=emailtest1, MailingCountry='India',School_Enrollment_Status__c='Graduate');
        insert con1;
        
        User user1 = new User(alias='userApp',email=emailtest1,emailencodingkey='UTF-8',lastname=lastname1, languagelocalekey='en_US',localesidkey='en_US',profileid=p1,country=UNITED_STATES,IsActive=true,ContactId=con1.Id, timezonesidkey=AMERICA_LA,username=username1);
        insert user1; 
        
        Id idAppForCertCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Application_For_Certification').getRecordTypeId();
        Id idAEntityUserRequestCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Entity_User_Request').getRecordTypeId();
        Case csAppForCert = new Case(AccountId=acc1.Id,ContactId=con1.Id,Service__c='EPIC',Internal_Status__c='Accepted',RecordTypeId=idAppForCertCaseRecordTypeId);
        insert csAppForCert;
        Case csIncomplete = new Case(AccountId=acc1.Id,ContactId=con1.Id,Service__c='EPIC',Internal_Status__c='Incomplete',RecordTypeId=idAEntityUserRequestCaseRecordTypeId);
        insert csIncomplete;

        Id conAssocStagingDegMedSch = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
        Contact_Association_Type_Staging__c conAssocTypeStaging = new Contact_Association_Type_Staging__c(RecordTypeId=conAssocStagingDegMedSch,contact__c = con1.Id, Account__c=acc1.id,case__c=csAppForCert.Id, IsDeanLetter__c = true, Status__c = 'Graduate');
        insert conAssocTypeStaging;

        Id conAssocRecordTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
        Contact_Association_Type__c conAssocType = new Contact_Association_Type__c(RecordTypeId=conAssocRecordTypeId,contact__c = con1.Id,case__c=csAppForCert.Id,Account__c=acc1.id);
        insert conAssocType;
        
        Id conAssocExamRecordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Exam_Registration_Degree_Medical_School').getRecordTypeId();
        Contact_Association_Type_Staging__c conAssocType1 = new Contact_Association_Type_Staging__c(RecordTypeId=conAssocExamRecordTypeId,contact__c = con1.Id,case__c=csAppForCert.Id,Account__c=acc1.id, IsDeanLetter__c = true, Status__c = 'Graduate');
        insert conAssocType1;
        

        Asset asst1 = new Asset(
            Name = ASSET_NAME,
            Status = Constants.ASSET_STATUS_ACCEPTED,
            case__c=csAppForCert.Id,
            AccountId = acc1.id,
            ContactId = con1.Id,
            InstallDate = System.Today(),
            UsageEndDate = System.Today(),
            Type__c	=	Constants.ASSET_TYPE_FINAL_MED_DIPLOMA,
            Contact_Association_Type_Staging__c = conAssocTypeStaging.Id,
            IsExpired__c = FALSE,
            IsOrphan__c = FALSE,
            key__c = System.Label.App_for_Cert_DIPLOMA_DOCUMENT
        );
        insert asst1;
        
        WDOMS_ID_Sequence__c wdomsIdSeq = new WDOMS_ID_Sequence__c(); 
        wdomsIdSeq.School_ID__c=0; 
        wdomsIdSeq.MDT_Degree_Type_ID__c=0000001;
        wdomsIdSeq.MDT_Program_Degree_ID__c=0000001;
        insert wdomsIdSeq;        
    }
}