//Test class for UpdateCaseAssetsAndAffirmationsInvocable
@isTest
public class UpdateCaseAssetAffirmationInvocableTest extends ECFMGTestFactory{
   	public static testMethod void  testExecute(){
        Account acc = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name = 'Test Acc'));
        run();
        System.assert(acc.Id!=null, 'Account not found');
		Contact con = new Contact();
		con.AccountId = acc.Id;
		con.LastName = 'Test';
		con.Email = 'test@test.com';
        INSERT con;
        System.assert(con.Id!=null, 'Contact not found');
        Case testCase = new Case();
        testCase.AccountId = acc.Id;
        testCase.ContactId = con.Id;
        testCase.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c;
        INSERT testCase;
        System.assert(testCase.Id!=null,'Test case not found');
        List<String> args1 = new List<String>();
       	args1.add(testCase.Id);
        args1.add(Constants.ASSET_STATUS_REJECTED);
        args1.add(Constants.ASSET_STATUS_REJECTED);
        List<List<String>> args = new List<List<String>>();
        args.add(args1);
        List<String> retlist = UpdateCaseAssetsAndAffirmationsInvocable.execute(args); 
        System.assert(retlist.isEmpty(),'Exception is thrown');
    }
    public static testMethod void testExecuteException(){
        List<String> args1 = new List<String>();
        args1.add(null);
        args1.add(Constants.ASSET_STATUS_REJECTED);
        args1.add(Constants.ASSET_STATUS_REJECTED);
        List<List<String>> args = new List<List<String>>();
        args.add(args1);
        try{
            Test.startTest();
            UpdateCaseAssetsAndAffirmationsInvocable.execute(args);
            Test.stopTest();
        }
        catch(Exception e){
            System.assertNotEquals(null, e,'Exception is not thrown'); 
        }
    }
}