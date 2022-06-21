@isTest
private class OFACSearchResponseHandlerTest{
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

    @testSetup static void setup(){
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Entity').getRecordTypeId();
        system.debug('accRecId'+accRecordTypeId); 
        List<Contact> contacts = new List<Contact>();
        for(Integer i=0; i<10; i++){
            Contact con = new Contact(FirstName = 'FirstName' + i, 
                                        LastName = 'LastName' + i, 
                                        Gender__c = 'Male',
                                        OFAC_Scan_BatchId__c = '7073K00000SPeJeQAL.1', 
                                        OFAC_Scan_Required__c = true,
                                        WDOMS_ID__c = '100000'+i);
            contacts.add(con);
        }
        insert contacts;
        List<Contact> contacts1 = new List<Contact>();
        for(Integer i=0; i<2; i++){
            Contact con1 = new Contact(FirstName = 'FirstName' + i, 
                                        LastName = 'LastName' + i, 
                                        Gender__c = 'Male',
                                        OFAC_Scan_BatchId__c = 'CON7073K00000SPeJeQAL.1', 
                                        OFAC_Scan_Required__c = true,
                                        WDOMS_ID__c = '200000'+i);
            contacts1.add(con1);
        }
        insert contacts1;
        List<Account> accLists = new List<Account>();
         for(Integer i=0; i<1; i++){
            Account acc = new Account(Name = 'EntityAcctName' + i, 
                                        School__c = true, 
                                        OFAC_Scan_BatchId__c = 'ACC7073K00000SPeJeQAL.1', 
                                        OFAC_Scan_Required__c = true,
                                        WDOMS_ID__c = '300000'+i,                                       
                                        BillingCountry = 'Nepal',
                                        recordTypeId = accRecordTypeId);
            accLists.add(acc);
        }
        insert accLists;

        List<aka_Names__c> akaLists = new List<aka_Names__c>();
        for(Integer i=0; i<2; i++){
            aka_Names__c aka = new aka_Names__c(Name = 'AkaName' + i, 
                                        Account__c = accLists[0].Id, 
                                        OFAC_Scan_BatchId__c = 'AKA7073K00000SPeJeQAL.1', 
                                        OFAC_Scan_Required__c = true,
                                        WDOMS_ID__c = '400000'+i);
            akaLists.add(aka);
        }
        insert akaLists;
    }
    @isTest
    static void testResponseEventPayloadSuccess(){
        String payload='{ "timestamp": "", "status": 200, "message": "OK", "path": "/api/search", "batchId": "CON7073K00000SPeJeQAL.1" }';
        Test.startTest();
        EventBusWrapper.publish(new OFAC_VeriScan_Search_Response_Event__e(payload__c = payload));
        Test.stopTest();
        System.assertEquals(1, EventBusWrapper.eventList.size(), 'More than 1 event is published');
    }
    @isTest
    static void testResponseEventPayloadError(){
        String payload='{ "timestamp": "", "status": 403, "message": "Access Denied",  "path": "/api/search", "batchId": "CON7073K00000SPeJeQAL.1" }';
        Test.startTest();
        EventBusWrapper.publish(new OFAC_VeriScan_Search_Response_Event__e(payload__c = payload));
        Test.stopTest();
        System.assertEquals(1, EventBusWrapper.eventList.size(), 'More than 1 event is published');
    }
    @isTest
    static void testResponseEventPayloadInvalidType(){
        String payload='{ "timestamp": "", "status": 200, "message": "OK", "path": "/api/search", "batchId": "ACC7073K00000SPeJeQAL.1" }';
        Test.startTest();
        EventBusWrapper.publish(new OFAC_VeriScan_Search_Response_Event__e(payload__c = payload));
        Test.stopTest();
        System.assertEquals(1, EventBusWrapper.eventList.size(), 'More than 1 event is published');
    }
    @isTest
    static void testResponseAkaEventPayloadSuccess(){
        String payload='{ "timestamp": "", "status": 200, "message": "OK", "path": "/api/search", "batchId": "AKA7073K00000SPeJeQAL.1" }';
        Test.startTest();
        EventBusWrapper.publish(new OFAC_VeriScan_Search_Response_Event__e(payload__c = payload));
        Test.stopTest();
        System.assertEquals(1, EventBusWrapper.eventList.size(), 'More than 1 event is published');
    }
     @isTest
    static void testResponseAkaEventPayloadFailure(){
        String payload='{ "timestamp": "", "status": 403, "message": "OK", "path": "/api/search", "batchId": "AKA7073K00000SPeJeQAL.1" }';
        Test.startTest();
        EventBusWrapper.publish(new OFAC_VeriScan_Search_Response_Event__e(payload__c = payload));
        Test.stopTest();
        System.assertEquals(1, EventBusWrapper.eventList.size(), 'More than 1 event is published');
    }
    @isTest
    static void testResponseEventPayloadElse(){
       String payload='{ "timestamp": "", "status": 200, "message": "OK", "path": "/api/search", "batchId": "7073K00000SPeJeQAL.1" }';
        Test.startTest();
        EventBusWrapper.publish(new OFAC_VeriScan_Search_Response_Event__e(payload__c = payload));
        Test.stopTest();
        System.assertEquals(1, EventBusWrapper.eventList.size(), 'More than 1 event is published');
    }
}