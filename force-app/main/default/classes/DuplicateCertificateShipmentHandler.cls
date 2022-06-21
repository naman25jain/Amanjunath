//Handler class to create Shipping label for Duplicate Certificate case
public with sharing class DuplicateCertificateShipmentHandler{
    public void createShipment(){
        Id dupCertRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_DUPLICATE_CERTIFICATE).getRecordTypeId();
        zkmulti.InvocableShipmentCreate.CreateShipmentParameter inv = new zkmulti.InvocableShipmentCreate.CreateShipmentParameter();
		inv.customAddressId = [SELECT Id FROM zkmulti__MCCustom_Address_Source__c WHERE Name = 'Case Shipment' WITH SECURITY_ENFORCED][0].Id;
        for(Case newCase : [SELECT Id FROM Case WHERE RecordTypeId =:dupCertRTId AND Internal_Status__c =:Constants.CASE_STATUS_SUBMITTED_IN_REVIEW AND Is_Shipping_Label_Created__c =FALSE WITH SECURITY_ENFORCED]){
            inv.recordId = newCase.Id;
            if(!Test.isRunningTest()){
                zkmulti.InvocableShipmentCreate.createShipment(new List<zkmulti.InvocableShipmentCreate.CreateShipmentParameter>{inv});
            }
        }
    }
}