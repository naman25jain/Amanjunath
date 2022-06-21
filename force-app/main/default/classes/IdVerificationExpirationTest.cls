@isTest
public class IdVerificationExpirationTest{
	@testSetup
    static void setup(){
        CommunitiesTestFactory.setup();
        EIFMonth__c eifMonth = new EIFMonth__c(Name = 'MonthsToExpiration', Months__c = 6);
        insert eifMonth;
        System.assert(eifMonth.Id!=null,'Record not found');  
        Contact con1 = new Contact(FirstName = 'Test1', LastName = 'User1', Birthdate = Date.parse('1/1/1970'), Gender__c = 'Male', Email = 'test@ecfmg.org');
        insert con1;
        System.assert(con1.Id!=null,'Contact not found');
        Id conId = con1.Id;
        Account acct = new Account(Name = 'Test', BillingCountry = 'United States', BillingState = 'California', BillingCity = 'TEst', BillingPostalCode = '123456');
        insert acct;
		System.assert(acct.Id!=null,'Account not found');        
        Product2 pdt8 = new Product2(Name='Photo', ProductCode='Photo', isActive=true);
    	Product2 pdt9 = new Product2(Name='ID Form', ProductCode='ID Form', isActive=true);
    	insert pdt8;
        System.assert(pdt8.Id!=null,'Product not found');
    	insert pdt9;
        System.assert(pdt9.Id!=null,'Product not found');
    	Case case1 = new Case(contactId = conId, Internal_Status__c = 'Pending Applicant Action-Notarize ID Form', Service__c = 'EPIC', AccountId = acct.Id);
		insert case1;
        System.assert(case1.Id!=null,'Case not found!');
        Asset asst3 = new Asset(Name = 'ID Form Template', type__c = 'ID Verification', Case__c = case1.Id, AccountId = acct.id, ContactId = conId, Status = 'In Progress', Product2Id = pdt9.Id, InstallDate = Date.newInstance(2018, 1, 1));
        Asset asst8 = new Asset(Name='Photo', type__c = 'Photo', Case__c = case1.Id, AccountId = acct.id, ContactId = conId, Status = 'Verified', Product2Id = pdt8.Id, InstallDate = Date.newInstance(2018, 1, 1));
        insert asst3;
        System.assert(asst3.Id!=null,'Asset not found');
        insert asst8;
        System.assert(asst8.Id!=null,'Asset not found');
        Affirmation__c apaff1 = new Affirmation__c(Asset__c = asst8.Id, Status__c = 'Rejected', Photo_is_Pixelated_Picklist__c = 'Yes');
        insert apaff1;
        case1.AssetId = asst3.Id;
        update case1;
        System.assertEquals(case1.AssetId, asst3.Id, 'Update failed');
    }
    @isTest
    static void testBatch(){
        String chron = '0 0 22 * * ?';
        String jobId = System.Schedule('TestIdVerificationScheduler', chron, new IdVerificationScheduler());
        System.assert(jobId!=null,'Scheduling failed');
        Test.StartTest();
        IdVerificationExpiration e = new IdVerificationExpiration();
        Database.executeBatch(e);
        Test.StopTest();
    }
}