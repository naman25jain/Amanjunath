@Istest
public class InvocablePostBillingTest {
    
    @TestSetup
    static void makeData(){
        
        BillingTestFactory.testCreateBilling();

    }

    @IsTest
    static void testPostBillings(){
        
        Test.startTest();

        List<Id> billingIds = new List<Id>();
        for (AcctSeed__Billing__c billing : [SELECT Id FROM AcctSeed__Billing__c]) {
            billingIds.add(billing.Id);
        }

        InvocablePostBilling.FlowInput flowInput = new InvocablePostBilling.FlowInput();
        flowInput.billingIds = billingIds;
        
        InvocablePostBilling.postBillingRecords(new List<InvocablePostBilling.FlowInput> { flowInput });

        Test.stopTest();
        
    }
    
}