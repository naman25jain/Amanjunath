// This test class is for CaseTriggerUtility.
@isTest
public with sharing class CaseTriggerUtilityTest extends ECFMGTestFactory{
    public static final String EXT_STATUS_INCORRECT = 'External Status is incorrect';
    // IFOM Request record type developer name
    public static final String RECTYPEIFOMREQ = Constant_Case__mdt.getInstance('REC_TYPE_IFOM_REQUEST').Value__c;
    // Case Object
    public static final String CASE_OBJ = 'Case';
    private static CurrentEntityIDSequence__c settingsInstance;
    static{
        CurrentEntityIDSequence__c settingsInstance = CurrentEntityIDSequence__c.getOrgDefaults();
        settingsInstance.Entity_ID__c = '0000000';
        upsert settingsInstance;
    }
    private static CurrentECFMGIDSequence__c settingsECFMGInstance;
    static{
        CurrentECFMGIDSequence__c settingsECFMGInstance = CurrentECFMGIDSequence__c.getOrgDefaults();
        settingsECFMGInstance.ECFMG_ID__c = '00000001';
        upsert settingsECFMGInstance;
    }
    // Test data setup.
    @TestSetup
    public static void setUp(){
        Id entityAccRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Account','Entity');
        Id conRecordTypeId = GenericUtilities.getRecordTypeIdByDevName('Contact',Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c);
        Id ifomIdRecordId = GenericUtilities.getRecordTypeIdByDevName(CASE_OBJ,RECTYPEIFOMREQ);
        Id examRegIdRecordId = GenericUtilities.getRecordTypeIdByDevName(CASE_OBJ,Constant_Case__mdt.getInstance('REC_TYPE_DEV_EXAM_REGISTRATION').Value__c);
        Id cvIdRecordId = GenericUtilities.getRecordTypeIdByDevName(CASE_OBJ,Constant_Case__mdt.getInstance('REC_TYPE_CREDENTIAL_VERIFICATION').Value__c);
        Set<Id> recordTypeIds = new Set<Id>{cvIdRecordId,examRegIdRecordId,ifomIdRecordId};
        Account acc = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name='Account Test'));
        Account entityAcc = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name='EntityAcc Test',RecordTypeId=entityAccRecTypeId));
        Account altEntityAcc = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name='AltEntityAcc Test+1',RecordTypeId=entityAccRecTypeId));
        Contact con = (Contact)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, new Contact(FirstName='Test', LastName='Contacts', USMLE_ID__c='1234', RecordTypeId=conRecordTypeId, Account = acc, Email = 'xyz@mail.com'));
       
        run();
        for(Id recordTypeId: recordTypeIds){
            Case casRecord = new Case(Contact=con, RecordTypeId=recordTypeId, Internal_Status__c=Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c);
            if(recordTypeId == cvIdRecordId){
                casRecord.Service__c = Constant_Case__mdt.getInstance('SERVICE_EPIC').Value__c;
                casRecord.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_EMAIL_CREATION').Value__c;
                casRecord.Entity__c = entityAcc.Id;
                casRecord.Alternate_Entity__c = altEntityAcc.Id;
            }
            casRecord = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, casRecord);
        }
        run();
    }
    // Test method to check if Case Service is updated
    @isTest
    static void testUpdateCaseService(){
        Case casRecord = [SELECT Id,RecordType.DeveloperName FROM Case WHERE RecordType.DeveloperName=:RECTYPEIFOMREQ LIMIT 1];        
        Case_Service_Mapping__mdt serviceRec = [SELECT Id,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c FROM Case_Service_Mapping__mdt WHERE Service_RecordType__c =:casRecord.RecordType.DeveloperName LIMIT 1];
        CaseTriggerUtility.updateCaseService(casRecord,casRecord.RecordType.DeveloperName);
        System.assertEquals(serviceRec.Case_Service__c,casRecord.Case_Service__c,'Service is incorrect');
        System.assertEquals(serviceRec.Case_Service_Family__c,casRecord.Case_Service_Family__c,'Service Family is incorrect');
        System.assertEquals(serviceRec.Case_Service_Line__c,casRecord.Case_Service_Line__c,'Service Line is incorrect');
    }
    // Test method to check if Case record date is updated
    @isTest
    static void testUpdateCaseRecordDate(){
        Case casRecord = [SELECT Id,RecordType.DeveloperName,Internal_Status__c,Applicant_Last_Submission_Date__c FROM Case WHERE RecordType.DeveloperName=:RECTYPEIFOMREQ];
        CaseTriggerUtility.updateCaseRecordDate(casRecord);
        System.assertEquals(Date.today(),casRecord.Applicant_Last_Submission_Date__c,'Applicant Last submission date is incorrect');
    }
    // Test method to check if status flag is updated as closed/Not Applicable
    @isTest
    static void testUpdateCaseRecordStatusFlag(){
        Case casRecord = [SELECT Id,RecordType.DeveloperName,Internal_Status__c,Status FROM Case LIMIT 1];
        casRecord.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_EXPIRED').Value__c;
        CaseTriggerUtility.updateCaseRecordStatusFlag(casRecord);
        System.assertEquals(Constant_Case__mdt.getInstance('STATUS_CLOSED').Value__c,casRecord.Status,'Status is incorrect');
        casRecord.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c;
        CaseTriggerUtility.updateCaseRecordStatusFlag(casRecord);
        System.assertEquals(Constant_Case__mdt.getInstance('STATUS_NOT_APPLICABLE').Value__c,casRecord.Status,'Status is incorrect');        
    }
    // Test method to update External status and Entity External status fields.
    @isTest
    static void testUpdateCaseExtStatus(){
        Case casRecord = [SELECT Id,RecordType.DeveloperName,RecordTypeId,Internal_Status__c,Service__c,External_Status__c,Entity_External_Status__c FROM Case WHERE RecordType.DeveloperName=:Constant_Case__mdt.getInstance('REC_TYPE_CREDENTIAL_VERIFICATION').Value__c LIMIT 1];
        Case casRecOld = casRecord.clone();
        casRecOld.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_VERIFICATION_INCOMPLETE').Value__c;
        GetCaseInternalStatus getInternalStatusObj = GetCaseInternalStatus.getInstance();
        Map<String,map<String,Internal_Status_External_Status_Mapping__mdt>> recIdIntExtStatus = getInternalStatusObj.getIntExtStatus();
        Map<String,Internal_Status_External_Status_Mapping__mdt> intExtStatus = recIdIntExtStatus.get(casRecord.recordTypeId);
        CaseTriggerUtility.updateCaseExtStatus(casRecord,null);
        System.assertEquals(intExtStatus.get(casRecord.Internal_Status__c).External_Status__c,casRecord.External_Status__c, EXT_STATUS_INCORRECT);
        CaseTriggerUtility.updateCaseExtStatus(casRecord,casRecOld);
        System.assertEquals(intExtStatus.get(casRecord.Internal_Status__c+Constants.STATUS_SEPARATOR+casRecOld.Internal_Status__c).External_Status__c,casRecord.External_Status__c, EXT_STATUS_INCORRECT);
        casRecord.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_IN_REVIEW_AT_ENTITY').Value__c;
        CaseTriggerUtility.updateCaseExtStatus(casRecord,casRecOld);
        System.assertEquals(intExtStatus.get(casRecord.Internal_Status__c).Entity_External_Status__c,casRecord.Entity_External_Status__c, EXT_STATUS_INCORRECT);
    }
    // Test method to check if the new records are appended to the CaseTriggerDataWrapper class insertDML member variable.
    @isTest
    static void testInsertDML(){
        List<Case> caseRecList = [SELECT Id,RecordType.DeveloperName,RecordTypeId,Internal_Status__c,Service__c,External_Status__c,Entity_External_Status__c FROM Case];
        CaseTriggerUtility.insertDML(caseRecList);
        CaseTriggerDataInitialize ctData = CaseTriggerDataInitialize.getInstance(new List<Case>(),false);
        CaseTriggerDataInitialize.CaseTriggerDataWrapper ctDataWrap = ctData.fetchData();
        System.assert(!(ctDataWrap.insertDML).isEmpty(),'The Insert DML is empty');
    }
    // Test method to check if the new records are appended to the CaseTriggerDataWrapper class updateDML member variable.
    @isTest
    static void testUpdateDMLMap(){
        List<Case> caseRecList = [SELECT Id,RecordType.DeveloperName,RecordTypeId,Internal_Status__c,Service__c,External_Status__c,Entity_External_Status__c FROM Case];
        CaseTriggerUtility.updateDMLMap(caseRecList);
        CaseTriggerDataInitialize ctData = CaseTriggerDataInitialize.getInstance(new List<Case>(),false);
        CaseTriggerDataInitialize.CaseTriggerDataWrapper ctDataWrap = ctData.fetchData();
        System.assert(!(ctDataWrap.updateDML).isEmpty(),'The Update DML is empty');
        CaseTriggerUtility.updateDMLMap(new List<Case>{new Case(Id = caseRecList[0].Id)});
        System.assert(!(ctDataWrap.updateDML).isEmpty(),'The Update DML is empty');
    }
    // Test method to check if the new records are appended to the CaseTriggerDataWrapper class deleteDML member variable.
    @isTest
    static void testDeleteDMLMap(){
        List<Case> caseRecList = [SELECT Id,RecordType.DeveloperName,RecordTypeId,Internal_Status__c,Service__c,External_Status__c,Entity_External_Status__c FROM Case];
        CaseTriggerUtility.DeleteDML(GenericUtilities.getIdsFromList(caseRecList));
        CaseTriggerDataInitialize ctData = CaseTriggerDataInitialize.getInstance(new List<Case>(),false);
        CaseTriggerDataInitialize.CaseTriggerDataWrapper ctDataWrap = ctData.fetchData();
        System.assert(!(ctDataWrap.deleteDML).isEmpty(),'The Delete DML is empty');
    }
    // Test method to check if the new records are appended to the CaseTriggerDataWrapper class deleteDML member variable.
    @isTest
    static void testCollectCaseShareAcc(){
        Map<Id,set<Id>> insAccCaseMap = new Map<Id,set<Id>>();
        Map<Id,set<Id>> delAccCaseMap = new Map<Id,set<Id>>();
        Map<Id,set<Id>> delAltAccCaseMap = new Map<Id,set<Id>>();
        for(Case caseRecord:[SELECT Id,RecordType.DeveloperName,RecordTypeId,Internal_Status__c,Service__c,External_Status__c,Entity_External_Status__c,Entity__c,Alternate_Entity__c FROM Case]){
            if(String.isNotBlank(caseRecord.Entity__c)){
                if(insAccCaseMap.containsKey(caseRecord.Entity__c)){
                    (insAccCaseMap.get(caseRecord.Entity__c)).add(caseRecord.Entity__c);
                }else{
                    insAccCaseMap.put(caseRecord.Entity__c,new Set<Id>{caseRecord.Id});
                }
                if(delAccCaseMap.containsKey(caseRecord.Entity__c)){
                    (delAccCaseMap.get(caseRecord.Entity__c)).add(caseRecord.Entity__c);
                }else{
                    delAccCaseMap.put(caseRecord.Entity__c,new Set<Id>{caseRecord.Id});
                }
                if(delAltAccCaseMap.containsKey(caseRecord.Alternate_Entity__c)){
                    (delAltAccCaseMap.get(caseRecord.Alternate_Entity__c)).add(caseRecord.Alternate_Entity__c);
                }else{
                    delAltAccCaseMap.put(caseRecord.Alternate_Entity__c,new Set<Id>{caseRecord.Id});
                }
            }
        }
        CaseTriggerUtility.collectCaseShareAcc(insAccCaseMap,delAccCaseMap,Constant_other__mdt.getInstance('SERVICE_NAME_CREDENTIAL_VERIFICATION').Value__c);
        CaseTriggerUtility.collectCaseShareAcc(insAccCaseMap,delAltAccCaseMap,Constant_other__mdt.getInstance('SERVICE_NAME_CREDENTIAL_VERIFICATION').Value__c);
        CaseTriggerDataInitialize ctData = CaseTriggerDataInitialize.getInstance(new List<Case>(),false);
        CaseTriggerDataInitialize.CaseTriggerDataWrapper ctDataWrap = ctData.fetchData();
        System.assert(!(ctDataWrap.insServiceAccCaseMap).isEmpty(),'The insert service sharing is empty');
        System.assert(!(ctDataWrap.delServiceAccCaseMap).isEmpty(),'The delete service sharing is empty');
        System.assert(!(ctDataWrap.accountIdSet).isEmpty(),'The account Ids sharing is empty');
    }
    //test method to check if FCVS child cases are updated 
    @isTest 
    static void testupdChildCaseFCVS1(){
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName(CASE_OBJ,Constant_Case__mdt.getInstance('REC_TYPE_CREDENTIAL_VERIFICATION').Value__c);
        Contact con = [SELECT Id, AccountId FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Id fcvsCaseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case', Constant_Case__mdt.getInstance('REC_TYPE_FCVS_REQUEST').Value__c);
        Case fcvsParCase = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact = con, AccountId = con.AccountId, RecordTypeId = fcvsCaseRecTypeId, Service__c = Constant_Case__mdt.getInstance('SERVICE_FCVS').Value__c, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c));
        run();
        Case subcvCase1 = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact = con, AccountId = con.AccountId, RecordTypeId = caseRecTypeId, Service__c = Constant_Case__mdt.getInstance('SERVICE_FCVS').Value__c, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_CV_REJECTED').Value__c, ParentId = fcvsParCase.Id));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact = con, AccountId = con.AccountId, RecordTypeId = caseRecTypeId, Service__c = Constant_Case__mdt.getInstance('SERVICE_FCVS').Value__c, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_SUBMITTED_IN_REVIEW').Value__c, ParentId = fcvsParCase.Id));
        run();
        fcvsParCase = [SELECT Id, Internal_Status__c,(SELECT Id, Internal_Status__c, RecordType.DeveloperName FROM Cases), AccountId FROM Case WHERE Id =: fcvsParCase.Id];
        Map<Id,Case> updateCaseRecMap = new Map<Id,Case>();
        Test.startTest();
        CaseTriggerUtility.updChildCaseFCVS(subcvCase1, fcvsParCase, updateCaseRecMap);
		subcvCase1.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_CANCELLED').Value__c;
        UPDATE subcvCase1;
        CaseTriggerUtility.updChildCaseFCVS(subcvCase1, fcvsParCase, updateCaseRecMap);
        Test.stopTest();
        System.assert(subcvCase1.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_CANCELLED').Value__c, 'Case not updated');
    }
    @isTest
    static void testupdChildCaseFCVS2(){
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName(CASE_OBJ,Constant_Case__mdt.getInstance('REC_TYPE_CREDENTIAL_VERIFICATION').Value__c);
        Contact con = [SELECT Id, AccountId FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Id fcvsCaseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case', Constant_Case__mdt.getInstance('REC_TYPE_FCVS_REQUEST').Value__c);
        Case fcvsParCase = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact = con, AccountId = con.AccountId, RecordTypeId = fcvsCaseRecTypeId, Service__c = Constant_Case__mdt.getInstance('SERVICE_FCVS').Value__c, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c));
        run();
        Case subcvCase1 = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact = con, AccountId = con.AccountId, RecordTypeId = caseRecTypeId, Service__c = Constant_Case__mdt.getInstance('SERVICE_FCVS').Value__c, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_SENT_FOR_VERIFICATION').Value__c, ParentId = fcvsParCase.Id));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact = con, AccountId = con.AccountId, RecordTypeId = caseRecTypeId, Service__c = Constant_Case__mdt.getInstance('SERVICE_FCVS').Value__c, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_SUBMITTED_IN_REVIEW').Value__c, ParentId = fcvsParCase.Id));
        run();
        fcvsParCase = [SELECT Id, Internal_Status__c, AccountId FROM Case WHERE Id =: fcvsParCase.Id];
        Map<Id,Case> updateCaseRecMap = new Map<Id,Case>();
        CaseTriggerUtility.updChildCaseFCVS(subcvCase1, fcvsParCase, updateCaseRecMap);
        subcvCase1.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_RESENT_FOR_VERIFICATION').Value__c;
        UPDATE subcvCase1;
        CaseTriggerUtility.updChildCaseFCVS(subcvCase1, fcvsParCase, updateCaseRecMap); 
        System.assert(subcvCase1.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_RESENT_FOR_VERIFICATION').Value__c, 'Parent case is not updated');
    }
 	@isTest
    static void testupdChildCaseFCVS3(){
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName(CASE_OBJ,Constant_Case__mdt.getInstance('REC_TYPE_CREDENTIAL_VERIFICATION').Value__c);
        Contact con = [SELECT Id, AccountId FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Id fcvsCaseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case', Constant_Case__mdt.getInstance('REC_TYPE_FCVS_REQUEST').Value__c);
        Case fcvsParCase = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact = con, AccountId = con.AccountId, RecordTypeId = fcvsCaseRecTypeId, Service__c = Constant_Case__mdt.getInstance('SERVICE_FCVS').Value__c, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c));
        run();
        Case subcvCase1 = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact = con, AccountId = con.AccountId, RecordTypeId = caseRecTypeId, Service__c = Constant_Case__mdt.getInstance('SERVICE_FCVS').Value__c, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PREV_VERIFIED_ACCEPTED').Value__c, ParentId = fcvsParCase.Id));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact = con, AccountId = con.AccountId, RecordTypeId = caseRecTypeId, Service__c = Constant_Case__mdt.getInstance('SERVICE_FCVS').Value__c, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_CV_ACCEPTED').Value__c, ParentId = fcvsParCase.Id));
        run();
        fcvsParCase = [SELECT Id, Internal_Status__c, AccountId FROM Case WHERE Id =: fcvsParCase.Id];
        Map<Id,Case> updateCaseRecMap = new Map<Id,Case>();
        CaseTriggerUtility.updChildCaseFCVS(subcvCase1, fcvsParCase, updateCaseRecMap); 
        System.assert(fcvsParCase.Id != null, 'Parent case is present');
    }
    @isTest
    static void testupdChildCaseFCVS4(){
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName(CASE_OBJ,Constant_Case__mdt.getInstance('REC_TYPE_CREDENTIAL_VERIFICATION').Value__c);
        Contact con = [SELECT Id, AccountId FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Id fcvsCaseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case', Constant_Case__mdt.getInstance('REC_TYPE_FCVS_REQUEST').Value__c);
        Case fcvsParCase = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact = con, AccountId = con.AccountId, RecordTypeId = fcvsCaseRecTypeId, Service__c = Constant_Case__mdt.getInstance('SERVICE_FCVS').Value__c, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c));
        run();
        Case subcvCase1 = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact = con, AccountId = con.AccountId, RecordTypeId = caseRecTypeId, Service__c = Constant_Case__mdt.getInstance('SERVICE_FCVS').Value__c, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_SENT_FOR_VERIFICATION').Value__c, ParentId = fcvsParCase.Id));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact = con, AccountId = con.AccountId, RecordTypeId = caseRecTypeId, Service__c = Constant_Case__mdt.getInstance('SERVICE_FCVS').Value__c, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_CV_ACCEPTED').Value__c, ParentId = fcvsParCase.Id));
        run();
        Map<Id,Case> updateCaseRecMap = new Map<Id,Case>();
        subcvCase1.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_CV_ACCEPTED').Value__c;
        UPDATE subcvCase1;
        CaseTriggerUtility.updChildCaseFCVS(subcvCase1, fcvsParCase, updateCaseRecMap); 
        fcvsParCase = [SELECT Id, Internal_Status__c, AccountId FROM Case WHERE Id =: fcvsParCase.Id];
        System.assertEquals(Constant_Case__mdt.getInstance('STATUS_ENROLLMENT_COMPLETED').Value__c, fcvsParCase.Internal_Status__c, 'FCVS case is not updated');
    }
    @isTest
    static void testpopulatesAccCaseMap(){
        List<Case> casesList = new List<Case>(); 
        Id enrolVerRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_ENROLLMENT_VERIFICATION').Value__c);
        Contact con = [SELECT Id, AccountId FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Id caseRecTypeExamRegId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_EXAM_REGISTRATION').Value__c);
        Id epexRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_ELIGIBILITY_PERIOD').Value__c);
        Case enVerCase = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Verification_Status__c = Constant_Case__mdt.getInstance('VERIFICATION_STATUS_NOT_REVIEWED').Value__c
                                                                                                    ,Contact = con, RecordTypeId = enrolVerRecTypeId, AccountId = con.AccountId
                                                                                                    ,Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c
                                                                                                    ,Number_of_Years_Attended__c = 0
                                                                                                    ,Passed_basic_sciences_course__c = Constants.STATUS_NO));
        
        run();       
        Case examReg1 = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(ParentId = enVerCase.Id, Enrollment_Verification_Parent__c = enVerCase.Id, Contact = con, RecordTypeId = caseRecTypeExamRegId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_ACCEPTED').Value__c));
       	run();
        Case epexCase1 = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(ParentId = examReg1.Id, Contact = con, RecordTypeId = epexRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_SUBMITTED_IN_REVIEW').Value__c));
        run(); 
        casesList.add(enVerCase);
        casesList.add(examReg1);
        casesList.add(epexCase1);
        Map<Id,Set<Id>> accCaseIdMap = new Map<Id,Set<Id>>();
        CaseTriggerUtility.populatesAccCaseMap(accCaseIdMap, casesList, Constant_Case__mdt.getInstance('REC_TYPE_DEV_ENROLLMENT_VERIFICATION').Value__c);
        CaseTriggerUtility.populatesAccCaseMap(accCaseIdMap, casesList, Constant_Data_Key__mdt.getInstance('EV_CHILD_CASES').Value__c);
        CaseTriggerUtility.populatesAccCaseMap(accCaseIdMap, casesList, Constant_Case__mdt.getInstance('REC_TYPE_ELIGIBILITY_PERIOD').Value__c); 
        Asset asst1 = CaseTriggerUtility.createAsset(examReg1, examReg1.Id, Constant_Asset__mdt.getInstance('TYPE_SCHEDULING_PERMIT').Value__c);
        System.assert(asst1 != null, 'Scheduling permit not created');
    }
    @isTest
    static void testupdParCaseIntStat(){
        Id ecfmgcertRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case', Constant_Case__mdt.getInstance('REC_TYPE_ECFMG_CERTIFICATION').Value__c);
        Id nameReviewRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case', Constant_Case__mdt.getInstance('REC_TYPE_DEV_NAME_REVIEW').Value__c);
        Contact con = [SELECT Id, AccountId FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case ecfmgCertCase = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact = con, AccountId = con.AccountId, RecordTypeId = ecfmgcertRecTypeId, Service__c = Constant_Case__mdt.getInstance('SERVICE_ECFMG_CERTIFICATION').Value__c, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_RECEIVED_IN_REVIEW').Value__c));
        run(); 
        Case nameReviewCase1 = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact = con, AccountId = con.AccountId, RecordTypeId = nameReviewRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_ACCEPTED').Value__c, ParentId = ecfmgCertCase.Id));
        run(); 
        ecfmgCertCase = [SELECT Id, Internal_Status__c,(SELECT Id, Internal_Status__c, RecordType.DeveloperName FROM Cases),RecordType.DeveloperName FROM Case WHERE Id =: ecfmgCertCase.Id];
        nameReviewCase1 = [SELECT Id, Internal_Status__c, RecordType.DeveloperName, ParentId FROM Case WHERE Id =: nameReviewCase1.Id];
        System.assert(ecfmgCertCase.Id!=null, 'Case not created');
        Case retCase = CaseTriggerUtility.updParCaseIntStat(nameReviewCase1, ecfmgCertCase);
        System.assert(retCase != null,'Case not returned');
    }
    @isTest
    static void testupdateAsset(){
        List<Asset> asstList = new List<Asset>();
        Contact con = [SELECT Id, AccountId, Name FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        OrgWideEmailAddress addr = [SELECT Id, Address FROM OrgWideEmailAddress WHERE DisplayName = 'Salesforce Admin'];     
        EmailTemplate emailTempRec = [SELECT Id, Subject, HtmlValue, Description, DeveloperName, Body FROM EmailTemplate WHERE DeveloperName = 'Case_Status_update_Template'];
        Id caseRecTypeExamRegId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_EXAM_REGISTRATION').Value__c);
        Id examAssetRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Asset', Constant_Asset__mdt.getInstance('RECORD_TYPE_EXAM_REG').Value__c);
        Case examReg1 = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact = con, RecordTypeId = caseRecTypeExamRegId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_ACCEPTED').Value__c,Deficiency_Reason_RTF__c = 'Test'));
        Asset schePermit1 = (Asset)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssestTestData.class, new Asset(Name = Constant_Asset__mdt.getInstance('TYPE_SCHEDULING_PERMIT').Value__c, Type__c = Constant_Asset__mdt.getInstance('TYPE_SCHEDULING_PERMIT').Value__c, RecordTypeId = examAssetRecTypeId, Status = Constant_Asset__mdt.getInstance('STATUS_IN_PROGRESS').Value__c, Contact = con, Case__c = examReg1.Id));
        run();
        asstList.add(schePermit1);
        List<Asset> retList = CaseTriggerUtility.updateAsset(asstList);
        System.assert(!retList.isEmpty(),'No asset is updated');
        Case examCase = [SELECT Id, ContactId, CaseNumber, Internal_Status__c, ECFMG_Portal_Case_Url__c, ContactEmail, Deficiency_Reason_RTF__c FROM Case WHERE Id =: examReg1.Id];
        CaseTriggerUtility.SendMailWrapper sendMailWrap = new CaseTriggerUtility.SendMailWrapper();
        sendMailWrap.caseRec = examCase;
        sendMailWrap.addr = addr;
        sendMailWrap.emailTemplate = emailTempRec;
        sendMailWrap.con = con;
        Messaging.SingleEmailMessage message1 = CaseTriggerUtility.sendCaseStatusMail(sendMailWrap);
        CaseTriggerUtility.sendCaseStatusTextMail(sendMailWrap);
		System.assert(message1!=null, 'Returned message is not null');
    }
    @isTest
    static void testCalculateSLADate(){
        System.assert((CaseTriggerUtility.catMap).isEmpty(),'CAT map is empty');
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_EXAM_REGISTRATION').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c, Enrolled_in_Entity_Portal__c=True));
        Case cas1 = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c));
        Exam_Registration__c examReg = (Exam_Registration__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultExamRegistrationTestData.class, new Exam_Registration__c(Applicant__c=con.Id, Case__c = cas.Id));
        run();
        Case examCase = [SELECT Id, CreatedDate, Enrollment_Verification_Parent__r.Enrolled_in_Entity_Portal__c FROM Case WHERE Id=:cas1.Id];
        Exam_Registration__c exmReg = [SELECT Id, EP_end_Date__c, SLA_Date__c FROM Exam_Registration__c WHERE Id=:examReg.Id];
        CaseTriggerUtility.calculateSLADate(examCase, exmReg);
        examCase.Enrollment_Verification_Parent__c=cas.Id;
        UPDATE examCase;
        examCase = [SELECT Id, CreatedDate, Enrollment_Verification_Parent__r.Enrolled_in_Entity_Portal__c FROM Case WHERE Id=:cas1.Id];
        System.assert(CaseTriggerUtility.calculateSLADate(examCase, exmReg)!=null, 'SLA date not updated');
    }
    @isTest
    static void testUpdateEVCaseStatus(){
        Id evRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_ENROLLMENT_VERIFICATION').Value__c);
        Id examRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_EXAM_REGISTRATION').Value__c);
        Contact con = [SELECT Id,AccountId FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case evCase = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, AccountId=con.AccountId, RecordTypeId=evRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c));
        Case examCase = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=examRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c));
        run();
        examCase.Enrollment_Verification_Parent__c=evCase.Id;
        UPDATE examCase;
        System.Assert(examCase.Enrollment_Verification_Parent__c==evCase.Id, 'EV parent not updated');
        evCase = [SELECT Id,AccountId,(SELECT Id FROM Cases__r) FROM Case WHERE Id=:evCase.Id];
        CaseTriggerUtility.updateEVCaseStatus(evCase, 'Test');
    }
    @isTest
    static void testUpTransReqdParCase(){
        Id nonUSMLETypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_NON_USMLE_TRANSCRIPT').Value__c);
        Id catRTId = GenericUtilities.getRecordTypeIdByDevName('Contact_Association_Type__c',Constant_CAT__mdt.getInstance('REC_TYPE_DEGREE_MEDICAL_SCHOOL').Value__c);
        Contact con = [SELECT Id,AccountId FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case parCase = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, AccountId=con.AccountId, RecordTypeId=nonUSMLETypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_REJECTED').Value__c));
        Case chCase = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=nonUSMLETypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_SENT').Value__c));
        Contact_Association_Type__c cat = (Contact_Association_Type__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactAssociationTestData.class, new Contact_Association_Type__c(Contact__c=con.Id,Account__c=con.AccountId, RecordTypeId=catRTId));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultDocConfigData.class, new cadmus_core__Doc_Config__c(Name = 'NON_USMLE_TRANSCRIPT', cadmus_core__CustomerDocumentConfigId__c = Constant_PDF_Butler__mdt.getInstance('NON_USMLE_TRANSCRIPT').Value__c));
        run();
        chCase.ParentId=parCase.Id;
        UPDATE chCase;
        parCase = [SELECT Id,Internal_Status__c,(SELECT Id,Internal_Status__c FROM Cases) FROM Case WHERE Id=:parCase.Id];
        CaseTriggerUtility.upTransReqdParCase(parCase);
        chCase.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_REJECTED').Value__c;
        UPDATE chCase;
        parCase = [SELECT Id,Internal_Status__c,(SELECT Id,Internal_Status__c FROM Cases) FROM Case WHERE Id=:parCase.Id];
        CaseTriggerUtility.upTransReqdParCase(parCase);
        CaseTriggerUtility.getAccount(new List<Contact_Association_Type__c>{cat});
        cat = [SELECT Id,Account__c,RecordType.DeveloperName FROM Contact_Association_Type__c WHERE Id=:cat.Id];
        CaseTriggerUtility.getAccount(new List<Contact_Association_Type__c>{cat});
        Map<String, cadmus_core__Doc_Config__c> docConfigMap = CaseTriggerUtility.populateDocConfig();
        System.assert(docConfigMap!=null, 'Doc config not created');
        CaseTriggerUtility.generateDocHelper(docConfigMap.get(Constant_PDF_Butler__mdt.getInstance('NON_USMLE_TRANSCRIPT').Value__c).Id, chCase);
    }
    @isTest
    static void testSendMail(){
        CloudDataTestFactory.createCloudConfig();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator_UploadDocument());
        System.assert(CaseTriggerUtility.getAttachment('Test')!= null, 'Attachment not created');
        CaseTriggerUtility.attachFiletoEmail(new Messaging.SingleEmailMessage(), Blob.valueOf('tempString'), 'Test');
        Test.stopTest();
    }
}