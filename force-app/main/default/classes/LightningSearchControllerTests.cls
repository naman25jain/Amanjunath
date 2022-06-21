@isTest
private class LightningSearchControllerTests extends ECFMGTestFactory{
    static testMethod void myUnitTest(){
        CurrentEntityIDSequence__c curEntitySetting = CurrentEntityIDSequence__c.getOrgDefaults();
        curEntitySetting.Entity_ID__c = '0000000';
        upsert curEntitySetting;
        String recType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
		Account accRec = new Account(Name='Test', AccountNumber='123', RecordTypeId = recType, School__c = true, Health_Profession_Regulatory_Authority__c = true);
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, accRec);
        run();
        System.assert(accRec.Id!=null, 'Account not inserted');
        Service__c newSer = new Service__c();
        newSer.Name = Constants.EPIC_SERVICENAME;
        Insert newSer;
        System.assert(newSer.Id != null, 'Service creation failed');
        Account2Service__c acctServ = new Account2Service__c();
        acctServ.active__c = true;
        acctServ.Account__c = accRec.Id;
        acctServ.Service__c = newSer.Id;
        Insert acctServ;
        System.assert(acctServ.Id != null, 'Account2Service creation failed');
		LightningSearchController.getSchoolRecords('Medical School','Test');
		LightningSearchController.getSchoolRecords('Regulatory Organization','Test');
		LightningSearchController.getSchoolRecords('Medical Authority','Test');
		LightningSearchController.getSchoolRecords('Test','Test');
    }
}