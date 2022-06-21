@isTest
public class CibisEligbilityCheckflagDisableBatchTest extends ECFMGTestFactory {
    private static CurrentECFMGIDSequence__c settingsECFMGInstance;
    static{
        CurrentECFMGIDSequence__c settingsECFMGInstance = CurrentECFMGIDSequence__c.getOrgDefaults();
        settingsECFMGInstance.ECFMG_ID__c = '00000001';
        upsert settingsECFMGInstance;
    }
    public static String CRON_EXP = '0 0 0 3 9 ? 2022';
    @testSetup
    static void setup() {
        List<Contact> contacts = new List<Contact>();
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_APPLICANT).getRecordTypeId();
        for(Integer i=0; i<20; i++){
            Contact con = (Contact)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, new Contact(FirstName='Test '+i, LastName='Contacts', USMLE_ID__c='Cibis', RecordTypeId=conRecordTypeId, USMLE_Transcript_Eligibility_Msg__c='', USMLE_Transcript_Eligible__c=true));
        }
        run();
    }
    
    @isTest
    static void invokeBatchClass(){
        Test.startTest();
        Id batchJobId = Database.executeBatch(new CibisEligbilityCheckflagDisableBatch(), 200);
        Test.stopTest();
    }
    

}