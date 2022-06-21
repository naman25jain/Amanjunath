/**
@Name: Shaik Nagajani
@Description: 
- This class contains the palnet press printing related test methods.

@History
VERSION     AUTHOR             DATE            DETAIL
1.0         Shaik Nagajani     15/Dec/2021     Created the Apex class.
**/

@isTest
public class DocumentsPrintControllerTest extends ECFMGTestFactory {
	@testSetup
    public static void buildData(){
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_APPLICANT).getRecordTypeId();
        Id idRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_ECFMG_CERTIFICATION).getRecordTypeId();
        Id transcriptRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_USMLE_TRANSCRIPT).getRecordTypeId();
        Id credentialPacketRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId(); //Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION
        Id assetRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_CREDENTIAL).getRecordTypeId();
        Id usmleTransRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_USMLE_TRANSCRIPT).getRecordTypeId();
        
        Account acc = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name='Account Test'));
        Contact con = (Contact)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, new Contact(FirstName='Test', LastName='Contacts', USMLE_ID__c='Cibis', RecordTypeId=conRecordTypeId, Secr_Doc_Azure_Blob_URL__c='https://ecfmgb2--devint.my.salesforce.com/'));
        
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=idRecordId, Internal_Status__c=Constants.CASE_STATUS_PENDING_CIBIS, Case_Service_Family__c ='ECFMG Certificate'));
        Case caseTranscript = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=transcriptRecordId, Internal_Status__c=Constants.CASE_STATUS_PENDING_CIBIS, Case_Service_Family__c ='ECFMG Certificate'));
        Case caseCredentialPack = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=credentialPacketRecordId, Internal_Status__c=Constants.CASE_STATUS_PENDING_PRINT, Case_Service_Family__c ='ECFMG Certificate'));
        //Case caseUsmleTransPack = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=usmleTransRecordType, Internal_Status__c=Constants.CASE_STATUS_PENDING_PRINT));
        
        
        Asset assetRecord = (Asset)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssestTestData.class, new Asset(Name = ConstantsTest.TEST_ASSET_NAME_RELATED_TO_CASE,
                                               Account = acc, RecordTypeId=assetRecordTypeId,
                                               Contact = con,
                                               Case__r = caseCredentialPack,
                                               Status = ConstantsTest.TEST_ASSET_STATUS_IN_PROGRESS));
        
        Verification_Packet__c vPacket = (Verification_Packet__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultVerificationPacketTestData.class, new Verification_Packet__c(Case__r=caseCredentialPack, Contact__r=con));
        
        Asset2Verification__c assetVerify = (Asset2Verification__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssestVerficationTestData.class, new Asset2Verification__c(Asset__r=assetRecord, Verification_Packet__r=vPacket));
        run();
    }
    
    @isTest
    public static void sendBulkDocsToPrint(){
        List<Id> caseIds = new List<Id>();
        List<String> caseIdString = new List<String>();
        Case[] casRecords = [SELECT Id,RecordTypeId,RecordType.Name,Case_Service_Family__c,RecordType.DeveloperName, ContactId, Internal_Status__c FROM Case];
        Asset[] AssetRecords = [SELECT Id,AccountId,ContactId,Case__c,Filename__c,Type__c,RecordTypeId,RecordType.DeveloperName  FROM Asset];
        ECFMG_Print_Config__mdt[] metaRecords = [SELECT Id,Printer_Name__c,Azure_Container__c ,Asset_Status__c,Filed_API_Name_from_Case__c,Filed_API_Name_from_Asset__c,Custom_Logic_Unique_Key__c,Custom_Logic__c,Asset_Type__c,Asset_Record_Type_Developer_Name__c, Record_Type_Dev_Name__c,Sequence__c,Tray_Name__c,Media_Size__c FROM ECFMG_Print_Config__mdt];
        System.debug('casRecords '+casRecords);
        for(Case eachCase : casRecords){
            caseIds.add(eachCase.Id);
            caseIdString.add(eachCase.Id);
        }
        if(!caseIds.isEmpty() && caseIds.size()>0){ 
            DocumentPrintCustomLogicUtilities.getRedactedFormsData(new map<Id, List<Asset>>{casRecords[0]?.Id => AssetRecords}, new set<String>{ConstantsTest.TEST_ASSET_NAME_RELATED_TO_CASE}, new map<Id, Case>{casRecords[0]?.contactId => casRecords[0]});
            DocumentPrintCustomLogicUtilities.addToAssetMap(new map<Id, List<Asset>>{casRecords[0]?.Id => AssetRecords}, AssetRecords[0], casRecords[0]?.Id);
            DocumentPrintUtilities.filterAssetsBasedOnCaseInfo(new map<Id, sObject>{casRecords[0]?.Id => casRecords[0]}, AssetRecords, new list<Asset>());
            DocumentsPrintController.sendBulkDocsToPrint(caseIds);
            DocumentsPrintController.getCaseStatusinfo(caseIdString);
            DocumentsPrintController.getAssets(caseIdString[0]);
        }
        if(!AssetRecords.isEmpty() && AssetRecords.size()>0){
            DocumentsPrintController.processAssetsUniquies(AssetRecords);
        }
        if(!casRecords.isEmpty() && casRecords.size()>0 && !AssetRecords.isEmpty() && AssetRecords.size()>0 && !metaRecords.isEmpty() && metaRecords.size() > 0){
            DocumentsPrintController.sentDocumentsToPrint(casRecords, metaRecords, AssetRecords);
        }
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(casRecords);
  		stdSetController.setSelected(casRecords);
    }
    
    /*@isTest
    public static void invokePrintJSONResponseWrapper(){
        DocumentPrintJSONResponse.CreatedById = UserInfo.getUserId();
        DocumentPrintJSONResponse.CreatedDate = Date.today();
        DocumentPrintJSONResponse.ErrorDetails = '{"errorDescription":"Error"}';
        DocumentPrintJSONResponse.EventUuid = '123';
        String json = '{"CreatedById":'+UserInfo.getUserId()+'}';
        DocumentPrintJSONResponse.parse(json);
    }*/
}