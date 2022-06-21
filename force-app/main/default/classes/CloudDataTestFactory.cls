@isTest
public  class CloudDataTestFactory {
    public static void createCloudConfig() {
        Cloud_Storage_Config__c csc = new Cloud_Storage_Config__c();
        csc.Account_Name__c = 'storageaccount';
        csc.Container_Name__c = 'containername';
        csc.Shared_Key__c = '1234567890';
        csc.Account_URL__c = 'accounturl';
        csc.Mode__c = 'LOCAL';
        insert csc;
    }
}