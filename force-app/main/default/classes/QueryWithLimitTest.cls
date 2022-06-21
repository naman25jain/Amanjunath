//Test Class for QueryWithLimit class
@isTest
public class QueryWithLimitTest {
    
    //Testing postive scenario, We created a contact and we should get same contact from this test method.
    @isTest
    public static void verifyGetNrecords(){
        Id evRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION).getRecordTypeId();
        Id entityRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_ENTITY).getRecordTypeId();        
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.RecordTypeId = entityRecTypeId;
        acc.BillingCity = 'test';
        acc.BillingCountry = 'India';
        acc.BillingPostalCode = '1234';
        acc.BillingState = 'West Bengal';
        acc.BillingStreet = 'test';
        insert acc;
        
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        con.Email = 'test@test.com';
        INSERT con;
        List<QueryWithLimit.QueryParameters> lstQueryParams = new List<QueryWithLimit.QueryParameters>();
        QueryWithLimit.QueryParameters objInput = new QueryWithLimit.QueryParameters();
        objInput.objectApiName = 'Contact';
        objInput.fieldsToQuery = 'Email, AccountId, LastName';
        objInput.numberOfRecords = 1;
        lstQueryParams.add(objInput);
        List<QueryWithLimit.QueryResults> result = QueryWithLimit.getNrecords(lstQueryParams);
        System.assert(result != null && result[0].records != null && result[0].records.size() == objInput.numberOfRecords && result[0].records[0].Id == con.Id );
    }
    
    //Testing Negative scenario - We passed numberOfRecords as 500000 then method should throw an exception -  "You cannot query more than 50000 records".
    @isTest
    public static void verifyGetNrecordsFail(){
        List<QueryWithLimit.QueryParameters> lstQueryParams = new List<QueryWithLimit.QueryParameters>();
        QueryWithLimit.QueryParameters objInput = new QueryWithLimit.QueryParameters();
        objInput.objectApiName = 'Contact';
        objInput.fieldsToQuery = 'Email, AccountId, LastName';
        objInput.numberOfRecords = 500000;
        lstQueryParams.add(objInput);
        String errorMessage = '';
        try{
            List<QueryWithLimit.QueryResults> result = QueryWithLimit.getNrecords(lstQueryParams);
        }catch(Exception pEx){
            errorMessage = pEx.getMessage();
        }
        System.assert(errorMessage.contains('You cannot query more than 50000 records.'));
    }
    
    //Testing Negative scenario - We added duplicate AccountId field in Query then method should throw an exception - "duplicate field selected: AccountId".
    @isTest
    public static void verifyGetNrecordsWithWrongParams(){
        List<QueryWithLimit.QueryParameters> lstQueryParams = new List<QueryWithLimit.QueryParameters>();
        QueryWithLimit.QueryParameters objInput = new QueryWithLimit.QueryParameters();
        objInput.objectApiName = 'Contact';
        objInput.fieldsToQuery = 'Email, AccountId, AccountId, LastName';
        objInput.numberOfRecords = 1;
        lstQueryParams.add(objInput);
        String errorMessage = '';
        try{
            List<QueryWithLimit.QueryResults> result = QueryWithLimit.getNrecords(lstQueryParams);
        }catch(Exception pEx){
            errorMessage = pEx.getMessage();
        }
        System.assert(errorMessage.contains('duplicate field selected: AccountId'));
    } 
    
}