public class InvocablePostBilling {

    @InvocableMethod(label='Post Billing Records')
    public static void postBillingRecords(List<FlowInput> inputs) {
        
        FlowInput input = inputs[0];
        List<String> billingIds = input.billingIds;

        List<AcctSeed__Billing__c> billingsToPost = [SELECT Id FROM AcctSeed__Billing__c WHERE Id IN :billingIds];
        
        AcctSeed.BillingPostService.postBillings(billingsToPost);
    }
    
    public class FlowInput{
		@InvocableVariable(required=true)
		public List<String> billingIds;
	}
}