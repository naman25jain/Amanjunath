@isTest
public class CollectionProcessorsUtilsTest {
    @isTest
    static void testgetFieldTypes(){
        Account acc = new Account();
        acc.Name = 'accName';
        acc.BillingCity = 'test';
        acc.BillingCountry = 'India';
        acc.BillingPostalCode = '1234';
        acc.BillingState = 'West Bengal';
        acc.BillingStreet = 'test';
        insert acc;

        List<String> fieldnames = new List<String>{'Name','BillingCity','BillingCountry','BillingPostalCode','BillingState','BillingStreet'};
        Test.startTest();
        CollectionProcessorsUtils.getFieldTypes(acc, fieldnames);
        CollectionProcessorsUtils.replaceConstants('sourceString');
        CollectionProcessorsUtils.getFormattedValue('test1','BillingCity');
        CollectionProcessorsUtils.getFormattedValue(Datetime.now().format(), 'Date', null);
        CollectionProcessorsUtils.getFormattedValue(Datetime.now().format(), 'Date', 'yyyy-MM-dd HH:mm:ss');
		Test.stopTest();
    }

}