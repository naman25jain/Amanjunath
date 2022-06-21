/**
 * @name         : ContentDocumentLinkTriggerTest
 * @description  : Test class for ContentDocumentLinkTrigger and its helper classes
 * @author       : Femi
 * @createdDate  : 17-JUN-2020
 */
@isTest
public class ContentDocumentLinkTriggerTest {
    public static testMethod void testscoreRecheck() {
        Account acc = new Account();
		acc.Name = 'Test Account1';
		acc.BillingCountry = 'Nepal'; 
		acc.BillingCity = 'Testville';
		acc.BillingStreet ='5 Market place';  
		INSERT acc;
        
        Contact con = new Contact();
		con.AccountId = acc.Id;
		con.LastName = 'Test';
		con.Email = 'test1@test.com';
		INSERT con;
        
        Id scoreRecheckRecordTypeId =   Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_SCORE_RECHECK).getRecordTypeId();
        Case sRCase = new Case();
		sRCase.RecordTypeId = scoreRecheckRecordTypeId;
		sRCase.ContactId = con.Id;
		INSERT sRCase;
        
		Blob tempBlob = Blob.valueOf('Temporary blob1');
        ContentVersion conVer = new ContentVersion();
		conVer.ContentLocation = 'S';
		conVer.PathOnClient = 'Score Recheck Letter' + '.pdf';
		conVer.Title = 'Score Recheck Letter';
		conVer.VersionData = tempBlob;
		insert conVer;

		Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: conVer.Id].ContentDocumentId;
		ContentDocumentLink conDocLink = New ContentDocumentLink();
		conDocLink.LinkedEntityId = sRcase.Id;
		conDocLink.ContentDocumentId = conDoc;
		conDocLink.shareType = 'V';
		insert conDocLink;
    }
    public static testMethod void testDeficiencyCover() {
        Account acc = new Account();
		acc.Name = 'Test Account2';
		acc.BillingCountry = 'Nepal'; 
		acc.BillingCity = 'Testville';
		acc.BillingStreet ='5 Market place';  		
		INSERT acc;
        
        Contact con = new Contact();
		con.AccountId = acc.Id;
		con.LastName = 'Test';
		con.Email = 'test2@test.com';
		INSERT con;

		cadmus_core__Doc_Config__c docConfig = new cadmus_core__Doc_Config__c();
        docConfig.Name = 'EnrollReverification Case Template';
        docConfig.cadmus_core__CustomerDocumentConfigId__c ='46b34380-9e1a-4401-a102-07ec5d4d66ad';
        insert docConfig;
        
        Id scoreRecheckRecordTypeId =   Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_REVERIFICATION).getRecordTypeId();
        Case sRCase = new Case();
		sRCase.RecordTypeId = scoreRecheckRecordTypeId;
		sRCase.ContactId = con.Id;
		INSERT sRCase;
        
		Blob tempBlob = Blob.valueOf('Temporary blob2');
        ContentVersion conVer = new ContentVersion();
		conVer.ContentLocation = 'S';
		conVer.PathOnClient = 'EV Deficiency Cover' + '.pdf';
		conVer.Title = 'EV Deficiency Cover';
		conVer.VersionData = tempBlob;
		insert conVer;

		Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: conVer.Id].ContentDocumentId;
		ContentDocumentLink conDocLink = New ContentDocumentLink();
		conDocLink.LinkedEntityId = sRcase.Id;
		conDocLink.ContentDocumentId = conDoc;
		conDocLink.shareType = 'V';
		insert conDocLink;
    }
    public static testMethod void testIFOM() {
        Account acc = new Account();
		acc.Name = 'Test Account';
		acc.BillingCountry = 'Nepal'; 
		acc.BillingCity = 'Testville';
		acc.BillingStreet ='5 Market place';  
		INSERT acc;
        
        Contact con = new Contact();
		con.AccountId = acc.Id;
		con.LastName = 'Test';
		con.Email = 'test@test.com';
		INSERT con;
        
        Id scoreRecheckRecordTypeId =   Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_IFOM_REQUEST).getRecordTypeId();
        Case sRCase = new Case();
		sRCase.RecordTypeId = scoreRecheckRecordTypeId;
		sRCase.ContactId = con.Id;
		INSERT sRCase;
        
		Blob tempBlob = Blob.valueOf('Temporary blob');
        ContentVersion conVer = new ContentVersion();
		conVer.ContentLocation = 'S';
		conVer.PathOnClient = 'Enrollment Paper Template' + '.pdf';
		conVer.Title = 'Enrollment Paper Template';
		conVer.VersionData = tempBlob;
		insert conVer;

		Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: conVer.Id].ContentDocumentId;
		ContentDocumentLink conDocLink = New ContentDocumentLink();
		conDocLink.LinkedEntityId = sRcase.Id;
		conDocLink.ContentDocumentId = conDoc;
		conDocLink.shareType = 'V';
		insert conDocLink;
    }
    public static testMethod void testSchedulingPermit() {
        Account acc = new Account();
		acc.Name = 'Test Account';
		acc.BillingCountry = 'Nepal'; 
		acc.BillingCity = 'Testville one';
		acc.BillingStreet ='Market place';  
		INSERT acc;
        
        Contact con = new Contact();
		con.AccountId = acc.Id;
		con.LastName = 'Test';
		con.Email = 'test@test.com';
		INSERT con;
        
        Id scoreRecheckRecordTypeId =   Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        Case sRCase = new Case();
		sRCase.RecordTypeId = scoreRecheckRecordTypeId;
		sRCase.ContactId = con.Id;
		INSERT sRCase;
        
		Blob tempBlob = Blob.valueOf('Temporary blob');
        ContentVersion conVer = new ContentVersion();
		conVer.ContentLocation = 'S';
		conVer.PathOnClient = 'Scheduling Permit Template' + '.pdf';
		conVer.Title = 'Scheduling Permit Template';
		conVer.VersionData = tempBlob;
		insert conVer;

		Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: conVer.Id].ContentDocumentId;
		ContentDocumentLink conDocLink = New ContentDocumentLink();
		conDocLink.LinkedEntityId = sRcase.Id;
		conDocLink.ContentDocumentId = conDoc;
		conDocLink.shareType = 'V';
		insert conDocLink;
    }
}