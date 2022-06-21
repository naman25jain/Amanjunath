@isTest
private with sharing class OFACAkaRequestBatchTest {
    @testSetup static void setup() {
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Entity').getRecordTypeId();
        account testAccount=new account(Name = 'Test', 
                                        OFAC_Scan_BatchId__c = null,
                                        OFAC_Scan_Required__c = true,
                                        phone ='222-222-3330',
                                        BillingCountry = 'United States',
                                        BillingState = 'Pennsylvania', 
                                        BillingPostalCode = '19341',                                        
                                        School__c = true,                                      
                                        WDOMS_ID__c = '2000001',                            
                                		recordtypeId= accRecordTypeId

                                        );
        insert testAccount;
        List<aka_Names__c> akaNames = new List<aka_Names__c>();
        for(Integer i=0; i<10; i++){
            aka_Names__c aka = new aka_Names__c(Name = 'Aka Test' + i, 
                                      OFAC_Scan_BatchId__c = null,
                                      OFAC_Scan_Required__c = true,
                                      account__c=testAccount.id,
                                      WDOMS_ID__c= '20000' + i);
            akaNames.add(aka);
        }
        insert akaNames;
    }

    @isTest
    static void testBatchExecute(){
        String soql = 'SELECT Id, Name, WDOMS_ID__c, OFAC_Scan_BatchId__c'
        + ' FROM aka_Names__c'
        + ' WHERE Name != null'
        + ' AND OFAC_Scan_Required__c = true'
        + ' AND OFAC_Scan_BatchId__c = null'
        + ' WITH SECURITY_ENFORCED';
        Test.startTest();
        Database.executeBatch(new OFACAkaRequestBatch(soql), 10);
        Test.stopTest();
        List<aka_Names__c> akaNamesWithBatchId = [SELECT OFAC_Scan_BatchId__c FROM aka_Names__c WHERE OFAC_Scan_BatchId__c != null];
        System.AssertEquals(10,akaNamesWithBatchId.size(),'Returned number of records does not match expected value');
    }

    @isTest
    static void testUpdateAccountsError(){
        List<aka_Names__c> akaNames = [SELECT OFAC_Scan_BatchId__c FROM aka_Names__c WHERE OFAC_Scan_Required__c = true];
        for(aka_Names__c aka : akaNames){
            aka.OFAC_Scan_BatchId__c = 'Acc12345678901234567890X'; //batch id too large
        }
        Test.startTest();
        Boolean result = OFACSearchHandler.updateAkaNames(akaNames);
        Test.stopTest();
        System.AssertEquals(false,result,'Returned invalid boolean value');
    }
}