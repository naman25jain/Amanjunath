@isTest
private class CancelCaseInvocableTest {
    private static testMethod void cancelCaseFromFlowTest(){
        string firstname = 'First';
        string lastname	= 'Last';
        string emailtest = 'tester@unknownmail1.com';
        Contact con = new Contact(Firstname = firstname, Lastname = lastname, Email = emailtest, MailingCountry='Mexico');
        INSERT con;
        Case testCase = new Case(ContactId = con.Id);
        INSERT testCase;
        String rtId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_IDENTITY).getRecordTypeId();
		Asset testAsset = new Asset(Name = 'Identity', ContactId = con.Id, Case__c = testCase.Id, Type__c = 'Passport', Status = Constants.ASSET_STATUS_IN_PROGRESS, recordTypeId = rtId);
        INSERT testAsset;
        Affirmation__c testAffirmation = new Affirmation__c(Asset__c = testAsset.Id);
        INSERT testAffirmation;
        List<String> argsStringList1 = new List<String>();
        argsStringList1.add(String.valueOf(testCase.Id));
        argsStringList1.add('Request Submitted by Mistake');
        argsStringList1.add('XXXX');
        argsStringList1.add('Agent');
        List<List<String>> args = new List<List<String>>();
        args.add(argsStringList1);
        System.assertEquals('Success', CancelCaseInvocable.cancelCaseFromFlow(args)[0], 'Did not cancel Case.');
        List<String> argsStringList2 = new List<String>();
        argsStringList2.add(null);
        argsStringList2.add('Reason');
        argsStringList2.add('XXXX');
        argsStringList2.add('Agent');
        List<List<String>> args2 = new List<List<String>>();
        args2.add(argsStringList2);
        try{
            CancelCaseInvocable.cancelCaseFromFlow(args2);
        }catch(Exception e){
            System.assertEquals('Must provide a case id for the first argument.', e.getMessage(), 'Did not throw CommunityException for missing case id');
        }
        List<String> argsStringList3 = new List<String>();
        argsStringList3.add(String.valueOf(testCase.Id));
        argsStringList3.add(null);
        argsStringList3.add('XXXX');
        argsStringList3.add('Agent');
        List<List<String>> args3 = new List<List<String>>();
        args3.add(argsStringList3);
        try{
            CancelCaseInvocable.cancelCaseFromFlow(args3);
        }catch(Exception e){
            System.assertEquals('Must provide a reason for the second argument.', e.getMessage(), 'Did not throw CommunityException for missing reason');
        }
        List<String> argsStringList4 = new List<String>();
        argsStringList4.add(String.valueOf(testCase.Id));
        argsStringList4.add('Reason');
        argsStringList4.add('XXXX');
        argsStringList4.add(null);
        List<List<String>> args4 = new List<List<String>>();
        args4.add(argsStringList4);
        try{
            CancelCaseInvocable.cancelCaseFromFlow(args4);
        }catch(Exception e){
            System.assertEquals('Must specify either Agent or Analyst.', e.getMessage(), 'Did not throw CommunityException for not specifying Agent or Analyst');
        }
    }
}