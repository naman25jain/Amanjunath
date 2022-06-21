@isTest
public class CibisUtilityTest extends ECFMGTestFactory {
	@TestSetup
    public static void setUp() {

        Test.startTest();
        createGroup();
        Id idRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
        Id prodRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Identity').getRecordTypeId();
        
        Account acc = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account());
     	Contact con = (Contact)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, new Contact(FirstName='Test', LastName='Contacts', Account=acc));
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=idRecordId, Internal_Status__c=Constants.CASE_STATUS_PENDING_CIBIS, Exam_Type__c='Cibis'));
        //Case cas1 = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=idRecordId, Internal_Status__c=Constants.CASE_STATUS_CANCELLED));
        Content_Manager__c cmData = (Content_Manager__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactManagerTestData.class, new Content_Manager__c(Page_Name__c = 'Test', Unique_Name__c='123q'));
        Product2 pdData = (Product2)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultProductTestData.class, new Product2(RecordTypeId=prodRecordTypeId));
        Exam_Registration__c exam = (Exam_Registration__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultExamRegistrationTestData.class, new Exam_Registration__c(Case__c=cas.Id, Applicant__c=con.Id));
 		
        Blob tempBlob = Blob.valueOf('Temporary blob1');
        //ContentVersion cv = (ContentVersion)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContentVersionTestData.class, new ContentVersion(VersionData=tempBlob));
 		//ContentDocumentLink cdl = (ContentDocumentLink)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContentDocumentLinkTestData.class, new ContentDocumentLink(LinkedEntityId=cas.Id, ContentDocumentId=cv.ContentDocumentId));
        run();
        Test.stopTest();
    }

    @isTest
    static void testCibisUtility() {
        List<String> selectedValues = new List<String>();
        Map<Id, String> caseTransactionMap = new Map<Id, String>();
        selectedValues.add('CIBIS');
        Exam_Registration__c ems = [SELECT Id, Case__c, Applicant__c FROM Exam_Registration__c LIMIT 1];
        System.debug('ems '+ems);
        list<Case> lstCases = [SELECT Id, ContactId, Contact.FirstName, Contact.LastName, Exam_Type__c,Exam_Region__c,OwnerID, internal_status__c,Product_Detail__c,Surcharge__c,Cibis_Transcript_Status__c,RecordTypeId FROM Case];
        Map<Id,Case> mapIdCases = new Map<Id,Case>();
        Set<Id> setIdCases = new Set<Id>();
        for(Case cs : lstCases) {
            //cs.internal_status__c = 'Cancelled';
            mapIdCases.put(cs.Id,cs);
            setIdCases.add(cs.Id);
            caseTransactionMap.put(cs.Id, 'CIBIS_NOTES_REQUEST_EVENT');
            ems.Case__c = cs.Id;
            ems.Applicant__c = cs.ContactId;
        }
        //update lstCases;
        update ems;
        CibisUtility.createExamRegCases(mapIdCases);
        CibisUtility.getContentManagerInfo('');
        //CibisUtility.sendEmailToContacts(lstCases);
        CibisUtility.returnSOQL('Case'); // Exam_Registration_Case_Clone_Set
        CibisUtility.returnQueryByFieldSet('Case', 'Exam_Registration_Case_Clone_Set');
        CibisUtility.createExamRegistrations(mapIdCases, lstCases);
        CibisUtility.createCaseRelatedData(setIdCases);
        CibisUtility.getCibisAnnoations();
        CibisUtility.isNewValue('Test', selectedValues);
        CibisUtility.isNewValue('CIBIS', selectedValues);
        CibisUtility.isNotEmpty(1);
        CibisUtility.getintegerval('12');
        CibisUtility.getDateTimeformat(String.valueOf(DateTime.now()));
        CibisUtility.updateCaseStatus(setIdCases);
        CibisUtility.publishExamRegClonedCase(lstCases);
        GenericUtilities.getFieldAsMap('Case');
        GenericUtilities.getRecordTypeIdByName('Case',Constants.CASE_RECORD_TYPE_APP_FOR_CERT);
        GenericUtilities.getRecordTypeIdsByDevNames('Case',new Set<String>{Constants.CASE_RECORD_TYPE_APP_FOR_CERT});
        GenericUtilities.getRecordTypeIdsByNames('Case', new Set<String>{Constants.CASE_RECORD_TYPE_APP_FOR_CERT});
        GenericUtilities.getRecordTypeNameById('Case',Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId());
        GenericUtilities.getRecordTypeDevNameById('Case',Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId());
        GenericUtilities.getRecordTypeNamesByIds('Case', new Set<Id>{Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId()});
        GenericUtilities.getRecordTypeIdNameMapByNames('Case', new Set<String>{Constants.CASE_RECORD_TYPE_APP_FOR_CERT});
        GenericUtilities.getRecordTypeIdNameMapByIds('Case', new Set<Id>{Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId()});
        GenericUtilities.getRecordTypeNameIdMapByNames('Case', new Set<String>{Constants.CASE_RECORD_TYPE_APP_FOR_CERT});
        GenericUtilities.getRecordTypeNameIdMapByIds('Case', new Set<Id>{Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId()});
        GenericUtilities.retriveRecordTypeIdWithNames('Case');
        GenericUtilities.getAllFields('Case');
            
    }
    
    /*@isTest
    public static void invokeGenericUtilitiesDocs(){
        list<Case> lstCases = [SELECT Id FROM Case];
        List<ContentDocumentLink> cntLink = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN: lstCases];
        System.debug('cntLink '+cntLink);
    }*/

    @future
    public static void createGroup() {
        Group grp = new Group();
        grp.name = 'ID Verification Queue';
        grp.Type = 'Queue'; 
        Insert grp; 
        GroupMember grpMem1 = new GroupMember();
        grpMem1.UserOrGroupId = UserInfo.getUserId();
        grpMem1.GroupId = grp.Id;
        Insert grpMem1;
    }
}