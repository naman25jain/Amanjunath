@isTest
public with sharing class NewEntityRequestTriggerHandlerTest extends ECFMGTestFactory{
    @TestSetup
    public static void setUp(){
        Id conRecordTypeId = GenericUtilities.getRecordTypeIdByDevName('Contact',Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c);
        // Account acc = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name='Account Test'));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, new Contact(FirstName='Test', LastName='Contacts', USMLE_ID__c='1234', RecordTypeId=conRecordTypeId));
        run();
        // System.assert(acc.id!=null, 'Account failed');
    }
    @isTest
    public static void insertTestRejectedInstitute(){
        Id caseRecTypeIdAttest = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_ATTESTATION').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        // Create Parent Case
        Case parentCase = new Case();
        parentCase.ContactId= con.Id;
        parentCase.Internal_Status__c = 'In Review'; 
        parentCase.RecordTypeId = caseRecTypeIdAttest;
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, parentCase);
        run();
        System.assert(parentCase.Id!=null,'Parent Case not created');
        // Case
        Id caseRecTypeIdNewEntity = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_NEW_ENTITY_REQUEST').Value__c);
        Case cs = new Case();
        cs.Internal_Status__c = 'Rejected'; 
        cs.RecordTypeId= caseRecTypeIdNewEntity;
        cs.ParentId = parentCase.Id;
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, cs);
        run();
        System.assert(cs.Id!=null,'Case Not created');

        Case newEntCase = [SELECT Id,Internal_Status__c,External_Status__c FROM Case WHERE id =: cs.Id];
        Case parentCaseQueried = [SELECT Id,Internal_Status__c FROM Case WHERE id =: parentCase.Id];
        System.assert(newEntCase.External_Status__c == 'Rejected', 'External Status not set');
        System.assert(parentCaseQueried.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_INSTITUTION_ADD_REJECTED').Value__c,'Parent Case Status Not Changed/Correct');
    }
    @isTest
    public static void updateTestRejectedInstitute(){
        Id caseRecTypeIdAttest = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_ATTESTATION').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        // Create Parent Case
        Case parentCase = new Case();
        parentCase.ContactId= con.Id;
        parentCase.Internal_Status__c = 'New'; 
        parentCase.RecordTypeId = caseRecTypeIdAttest;
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, parentCase);
        run();
        System.assert(parentCase.Id!=null,'Parent Case not created');
        parentCase.Internal_Status__c = 'In Review';
        Update parentCase;
        // Case
        Id caseRecTypeIdNewEntity = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_NEW_ENTITY_REQUEST').Value__c);
        Case cs = new Case();
        cs.Internal_Status__c = 'New'; 
        cs.RecordTypeId= caseRecTypeIdNewEntity;
        cs.ParentId = parentCase.Id;
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, cs);
        run();
        System.assert(cs.Id!=null,'Case Not created');

        cs.Internal_Status__c = 'Rejected';
        update cs;
        
        Case newEntCase = [SELECT Id,Internal_Status__c,External_Status__c FROM Case WHERE id =: cs.Id];
        Case parentCaseQueried = [SELECT Id,Internal_Status__c FROM Case WHERE id =: parentCase.Id];
        System.assert(newEntCase.External_Status__c == 'Rejected', 'External Status not set');
        System.assert(parentCaseQueried.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_INSTITUTION_ADD_REJECTED').Value__c,'Parent Case Status Not Changed/Correct');
    }
    @isTest
    public static void insertTestAddedInstitute(){
        Id caseRecTypeIdAttest = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_ATTESTATION').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        // Create Parent Case
        Case parentCase = new Case();
        parentCase.ContactId= con.Id;
        parentCase.Internal_Status__c = 'In Review';
        parentCase.RecordTypeId = caseRecTypeIdAttest;
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, parentCase);
        run();
        System.assert(parentCase.Id!=null,'Parent Case not created');
        // Create entity
        Id entityRecordId = GenericUtilities.getRecordTypeIdByDevName('Account',Constants.ACCOUNT_RECORD_TYPE_ENTITY);
        Account entity = new Account();
        entity.RecordTypeId = entityRecordId;
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, entity);
        run();
        System.assert(entity.Id!=null, 'Entity not created');
        // Case
        Id caseRecTypeIdNewEntity = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_NEW_ENTITY_REQUEST').Value__c);
        Case cs = new Case();
        cs.AccountId = entity.Id;
        cs.Internal_Status__c = 'Added';
        cs.RecordTypeId= caseRecTypeIdNewEntity;
        cs.ParentId = parentCase.Id;
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, cs);
        run();
        System.assert(cs.Id!=null,'Case Not created');
        
        Case newEntCase = [SELECT Id,Internal_Status__c,External_Status__c FROM Case WHERE id =: cs.Id];
        Case parentCaseQueried = [SELECT Id,Internal_Status__c FROM Case WHERE id =: parentCase.Id];
        System.assert(newEntCase.External_Status__c == 'Added', 'External Status not set');
        System.assert(parentCaseQueried.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_INSTITUTION_ADD_COMPLETE').Value__c,'Parent Case Status Not Changed/Correct');
    }
    @isTest
    public static void updateTestAddedInstitute(){
        Id caseRecTypeIdAttest = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_ATTESTATION').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        // Create Parent Case
        Case parentCase = new Case();
        parentCase.ContactId= con.Id;
        parentCase.Internal_Status__c = 'New'; 
        parentCase.RecordTypeId = caseRecTypeIdAttest;
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, parentCase);
        run();
        System.assert(parentCase.Id!=null,'Parent Case not created');
        parentCase.Internal_Status__c = 'In Review';
        Update parentCase;
        // Case
        Id caseRecTypeIdNewEntity = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_NEW_ENTITY_REQUEST').Value__c);
        Case cs = new Case();
        cs.Internal_Status__c = 'New'; 
        cs.RecordTypeId= caseRecTypeIdNewEntity;
        cs.ParentId = parentCase.Id;
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, cs);
        run();
        System.assert(cs.Id!=null,'Case Not created');

        // Create entity
        Id entityRecordId = GenericUtilities.getRecordTypeIdByDevName('Account',Constants.ACCOUNT_RECORD_TYPE_ENTITY);
        Account entity = new Account();
        entity.Name = 'Test entity';
        entity.RecordTypeId = entityRecordId;
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, entity);
        run();
        System.assert(entity.Id!=null, 'Entity not created');

        cs.AccountId = entity.Id;
        cs.Internal_Status__c = 'Added';
        update cs;
        
        Case newEntCase = [SELECT Id,Internal_Status__c,External_Status__c FROM Case WHERE id =: cs.Id];
        Case parentCaseQueried = [SELECT Id,Internal_Status__c FROM Case WHERE id =: parentCase.Id];
        System.assert(newEntCase.External_Status__c == 'Added', 'External Status not set');
        System.assert(parentCaseQueried.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_INSTITUTION_ADD_COMPLETE').Value__c,'Parent Case Status Not Changed/Correct');
    }
    @isTest
    public static void insertTestOwnerTest(){
        // Case
        Id caseRecTypeIdNewEntity = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_NEW_ENTITY_REQUEST').Value__c);
        Case cs = new Case();
        cs.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_IN_REVIEW').Value__c; 
        cs.RecordTypeId= caseRecTypeIdNewEntity;
        cs.OwnerId = (Constants.QUEUE_DEV_ID_MAP).get(Constant_Case__mdt.getInstance('QUEUE_ENROLLMENT_VERIFICATION').Value__c);
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, cs);
        run();
        System.assert(cs.Id!=null,'Case Not created');

        Case newEntCase = [SELECT Id,Internal_Status__c,External_Status__c,OwnerId FROM Case WHERE id =: cs.Id];
        Id userId = UserInfo.getUserId();
        System.assert(newEntCase.OwnerId == userId,'Owner Id not changed to Current User Id');
    }
}