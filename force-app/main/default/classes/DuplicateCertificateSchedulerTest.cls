@IsTest
public class DuplicateCertificateSchedulerTest{
    @isTest
    public static void testDupicateCertScheduler(){
        Contact con = new Contact();
        con.LastName = 'Test';
        con.MailingCountry = 'United States';
        con.MailingState = 'Pennsylvania';
        con.MailingCity = 'Fort Washington';
        con.MailingStreet = '1300 Virginia Dr';
        con.MailingPostalCode = '19034';
        con.Email = 'test@test.com';
        INSERT con;
        System.assert(con.Id != null, 'Contact creation failed');
        Id dCRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_DUPLICATE_CERTIFICATE).getRecordTypeId();
        System.assert(dCRTId != null, 'Recordtype does not exist');
        Case dcCase = new Case();
        dcCase.RecordTypeId = dCRTId;
        dcCase.ContactId = con.Id;
        dcCase.Internal_Status__c = Constants.CASE_STATUS_SUBMITTED_IN_REVIEW;
        dcCase.Is_Shipping_Label_Created__c = False;
        INSERT dcCase;
        System.assert(dcCase.Id != null, 'Case creation failed');
        zkmulti__MCCustom_Address_Source__c source = new zkmulti__MCCustom_Address_Source__c();
        source.Name = 'Case Shipment';
        INSERT source;
        System.assert(source.Id != null, 'Custom Address Source creation failed');
        String cronExp = '0 0 0 3 9 ? 2023';
        String jobId = System.schedule('Test Shipment Create', cronExp, new DuplicateCertificateScheduler());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
        System.assertEquals(0, ct.TimesTriggered, 'Schedlued job not triggered');
        System.assertEquals('2023-09-03 00:00:00', String.valueOf(ct.NextFireTime), 'Job scheduled for next run');   
        DuplicateCertificateShipmentHandler handler = new DuplicateCertificateShipmentHandler();
        handler.createShipment();
        System.assertEquals([SELECT Is_Shipping_Label_Created__c FROM Case WHERE Id=:dcCase.Id][0].Is_Shipping_Label_Created__c, False, 'Shipment not created');
    }
}