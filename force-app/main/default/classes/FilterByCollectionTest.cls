@isTest(seeAllData=false)
public class FilterByCollectionTest{
    private static CurrentEntityIDSequence__c settingsInstance;
    static{
        CurrentEntityIDSequence__c settingsInstance = CurrentEntityIDSequence__c.getOrgDefaults();
        settingsInstance.Entity_ID__c = '0000000';
        upsert settingsInstance;
    }
    private static CurrentECFMGIDSequence__c settingsECFMGInstance;
    static{
        CurrentECFMGIDSequence__c settingsECFMGInstance = CurrentECFMGIDSequence__c.getOrgDefaults();
        settingsECFMGInstance.ECFMG_ID__c = '00000001';
        upsert settingsECFMGInstance;
    }
    @isTest public static void filterByCollection(){
        Account acct = new Account (Name = 'Account1',BillingCountry='United States',BillingStreet='1234 Esf',
                                   BillingCity='Philadelphia',
                                   BillingPostalCode='19110',
                                   BillingState='Alaska');
        insert acct;
        Contact con = new Contact(
            FirstName = 'ab',
            LastName = 'cd',
            AccountId = acct.Id
        );
        insert con; 
        List<Campaign> campaignlst = new List<Campaign>();
        Campaign camp = new Campaign(
            Name = 'Test',
            IsActive = TRUE
        ); 
        campaignlst.add(camp);
        insert camp;
        List<CampaignMember> members = new List<CampaignMember>();
        CampaignMember member = new CampaignMember(
            ContactId = con.Id,
            Status = 'sent',
            CampaignId = camp.Id
        ); 
        members.add(member); 
        FilterByCollection.Requests req;
        req = new FilterByCollection.Requests();
        req.objectName = 'CampaignMember';
        req.returnFields = 'Name,Id,CampaignId';
        req.bindField = 'CampaignId';
        req.containingCollection = campaignlst;
        Test.startTest();
        FilterByCollection.filter(new List<FilterByCollection.Requests>{req});
        System.assertEquals(1, members.size());
       	Test.stopTest();
    }
}