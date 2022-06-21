@isTest
public class EcfmgCertificateReGenerationTest{
    @isTest static void createRegenAssetTest(){
        date birthDate = date.valueOf('2000-01-05');
        string emailTest = 'testerTest@unknownmail.com';
        string lastName = 'LastTest';
        string firstName = 'FirstTest';
        Contact cont = new Contact(Firstname = firstName, USMLE_ID__c = 'C123', Lastname = lastName, Birthdate = birthDate, email = emailTest, MailingCountry = 'Albania', School_Enrollment_Status__c = Constants.CONASCTYPESTG_STATUS_GRADUATE, Credential_Pre_req_exempted__c = true);
        INSERT cont;
        System.Assert(cont.Id != null,'Contact is not inserted');
        Id ecfmgCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ECFMG_CERTIFICATION).getRecordTypeId();
        Case csEcfmgCert = new Case(ContactId = cont.Id, Service__c = 'EPIC', RecordTypeId = ecfmgCertRecordTypeId, Internal_Status__c = 'Complete');
        insert csEcfmgCert;
        Case csEcfmgCert1 = new Case(ContactId = cont.Id, Service__c = 'EPIC', RecordTypeId = ecfmgCertRecordTypeId, Internal_Status__c = 'Sent');
        insert csEcfmgCert1;
        System.Assert(csEcfmgCert.Id != null,'csEcfmgCert is not inserted');
        System.Assert(csEcfmgCert1.Id != null,'csEcfmgCert1 is not inserted');
        String assetRTid = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_ECFMG_CERTIFICATION).getRecordTypeId();
        Asset asst = new Asset(
            Name = Constants.ASSET_TYPE_ECFMG_CERTIFICATE,
            Status = Constants.ASSET_STATUS_ACCEPTED,
            ContactId = cont.Id,
            type__c = Constants.ASSET_TYPE_ECFMG_CERTIFICATE,
            RecordTypeId = assetRTid,
            Case__c = csEcfmgCert.Id
        );
        insert asst;
        System.Assert(asst.Id != null,'Asset is not inserted'); 
        Test.StartTest();
            EcfmgCertificateReGeneration.createRegenAsset('New Cert is inserted','Lost in Shipment',String.valueof(asst.Id));
            List<Asset> assetList = new List<Asset>();
            assetList = [Select id,Status from Asset where contactId =:cont.Id AND id =:asst.Id];
        	System.assertEquals(assetList[0].Status == Constants.ASSET_STATUS_OUTDATED, True,'Status is not updated to outdated');
        	EcfmgCertificateReGeneration.createRegenAsset('New Cert is inserted','Lost',String.valueof(asst.Id));
        	assetList.clear();
        	assetList = [Select id,Status,Type__c,Case__c from Asset where contactId =:cont.Id order by CreatedDate Desc Limit 1];
        	System.assertEquals(assetList[0].Case__c == csEcfmgCert.Id, True,'Case id has changed.');
        Test.StopTest();
    }
}