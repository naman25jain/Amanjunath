@isTest
public class CollectionCalculateTest {
    private final static String TEST_RECORD_NAME = 'Test Acc';
    
    @isTest
    static void testExecute(){
              
        List<Account> testAccounts = createAccounts(3, true);
        CollectionCalculate.Requests request1 = new CollectionCalculate.Requests();
        request1.inputCollection = testAccounts;
        request1.fieldName = 'AnnualRevenue';
        request1.operation = 'Add';
        request1.policyForNullAndEmptyFields = 'use0';
        List<CollectionCalculate.Requests> requests = new List<CollectionCalculate.Requests>();
        requests.add(request1);
        
        CollectionCalculate.Requests request2 = new CollectionCalculate.Requests();
        request2.inputCollection = testAccounts;
        request2.fieldName = 'AnnualRevenue';
        request2.operation = 'Multiply';
        request2.policyForNullAndEmptyFields = 'use1';
        requests.add(request2);
        
        CollectionCalculate.Requests request3 = new CollectionCalculate.Requests();
        request3.inputCollection = testAccounts;
        request3.fieldName = 'AnnualRevenue';
        request3.operation = 'Average';
        request3.policyForNullAndEmptyFields = 'use0';
        requests.add(request3);
        
        CollectionCalculate.Requests request4 = new CollectionCalculate.Requests();
        request4.inputCollection = testAccounts;
        request4.fieldName = 'AnnualRevenue';
        request4.operation = 'Average';
		request4.policyForNullAndEmptyFields = 'use0';
        requests.add(request4);
       
        List<CollectionCalculate.Results> responses = CollectionCalculate.execute(requests);
        CollectionCalculate.Results response = responses[0];
    }
    
    public static List<Account> createAccounts(Integer numberOfRecords, Boolean doInsert) {

        List<Account> returnList = new List<Account>();
        for (Integer i = 0; i < numberOfRecords; i++) {
            returnList.add(new Account(Name = TEST_RECORD_NAME + i, Website = '' + i, BillingCountry = 'India', BillingState = 'West Bengal'));
        }
        if (doInsert) {
            //insert returnList without triggering duplicate rules
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.AllowSave = true; 
            List<Database.SaveResult> sr = Database.insert(returnList, dml);

        }

        return returnList;
    }

}