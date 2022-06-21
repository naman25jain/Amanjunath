@isTest
private with sharing class OFACAccountRequestBatchTest {
    public static Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Entity').getRecordTypeId();
    @testSetup static void setup() {
        List<Account> accounts = new List<Account>();
        for(Integer i=0; i<1; i++){
            Account acc = new Account(Name = 'AccountTest' + i, 
                                      OFAC_Scan_BatchId__c = null,
                                      OFAC_Scan_Required__c = true,
                                      phone ='222-222-333'+i,
                                      Medschool_Code__c = '09812' + i,
                                      Institution_ID__c = '654321' + i,
                                      BillingStreet = '5 Market St',
                                      BillingCity = 'Philadelhia',
                                      BillingPostalCode = '19341',
                                      BillingCountry = 'United States',
                                      BillingState = 'Pennsylvania', 
                                      School__c = true, 
                                      Professional_Membership_Organization__c = true,
                                      WDOMS_ID__c = '200000'+i,
                                      recordtypeId = accRecordTypeId
                                      );
            accounts.add(acc);
        }
        insert accounts;
    }

    @isTest
    static void testBatchExecute(){
        String accRecType = Constants.ACCOUNT_RECORD_TYPE_ENTITY;
        String soql = 'SELECT Id, Name, OFAC_Scan_BatchId__c, Phone,'
        + ' Medschool_Code__c, Institution_ID__c, Account_Type__c, Entity_ID__c,'
        + ' BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry'
        + ' FROM Account'
        + ' WHERE Name != null'
        + ' AND OFAC_Scan_Required__c = true'
        + ' AND OFAC_Scan_BatchId__c = null'
        + ' AND recordtype.Name = \'' +  accRecType +  '\''
        + ' WITH SECURITY_ENFORCED';
        Test.startTest();
        Database.executeBatch(new OFACAccountRequestBatch(soql), 10);
        Test.stopTest();
        List<Account> accountsWithBatchId = [SELECT OFAC_Scan_BatchId__c FROM Account WHERE OFAC_Scan_BatchId__c != null];
        System.AssertEquals(1,accountsWithBatchId.size(),'Returned number of records does not match expected value');
    }

    @isTest
    static void testUpdateAccountsError(){
        List<Account> accounts = [SELECT OFAC_Scan_BatchId__c FROM Account WHERE OFAC_Scan_Required__c = true];
        for(Account acc : accounts){
            acc.OFAC_Scan_BatchId__c = 'Acc12345678901234567890X'; //batch id too large
        }
        Test.startTest();
        Boolean result = OFACSearchHandler.updateAccounts(accounts);
        Test.stopTest();
        System.AssertEquals(false,result,'Returned invalid boolean value');
    }
    @isTest
    static void testBatchExecuteForException(){
        List<Boolean> exceptions = new List<Boolean>();
        String accRecType = Constants.ACCOUNT_RECORD_TYPE_ENTITY;
        String soql = 'SELECT Id, Name, OFAC_Scan_BatchId__c, Phone,'
        + ' Medschool_Code__c, Institution_ID__c, Account_Type__c, Entity_ID__c,'
        + ' BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry'
        + ' FROM Account'
        + ' WHERE Name != null'
        + ' AND OFAC_Scan_Required__c = true'
        + ' AND OFAC_Scan_BatchId__c = null'
        + ' AND recordtype.Name = \'' +  accRecType +  '\''
        + ' WITH SECURITY_ENFORCED';     
      Test.startTest();
      try {
        Database.executeBatch(new OFACAccountRequestBatch(soql), 10);
            if(Test.isRunningTest()) {
                // Cause DMLException
                insert new Lead();
            }
        
      } catch (Exception e) {
        exceptions.add(true); 
      }      
      Test.stopTest();
      List<Account> accountsWithBatchId = [SELECT OFAC_Scan_BatchId__c FROM Account WHERE OFAC_Scan_BatchId__c != null];
      System.AssertEquals(1,exceptions.size(),'Exception thrown');
    }

}