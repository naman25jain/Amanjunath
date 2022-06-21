@isTest
public with sharing class AzureFilesDeleteRequestBatchTest {

    @TestSetup
    static void setup(){

        CurrentECFMGIDSequence__c curECFMGSetting = CurrentECFMGIDSequence__c.getOrgDefaults();
        curECFMGSetting.ECFMG_ID__c = '00000001';
        upsert curECFMGSetting;

        Contact contact = BaseTestFactory.getContact();              
        
        List<Asset> assets = new List<Asset>(); 
        for (Integer i=0; i<10; i++){
            Asset a = new Asset(ContactId = contact.Id,
            Name= 'Photo',
            Azure_Delete_Batch_Id__c = null,
            Azure_Storage_URL__c = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/file'+i+'.pdf', 
            status = 'Marked for Deletion' );
            assets.add(a); 
        }
        insert assets;     
    }

    @isTest
    public static void testBatchExecute(){
        System.debug('at testBatchExecute'); 
        string soql = 'SELECT Id, Name, Azure_Storage_URL__c, Case__c, Filename__c, Azure_Delete_Batch_Id__c,'
        + ' Name_on_Document__c, ParentId, Parent_Azure_Storage_URL__c' 
        + ' FROM Asset'
        + ' WHERE Status = \''+ 'Marked for Deletion' + '\''
        + ' AND LastModifiedDate >=LAST_N_DAYS:'+200        
        + ' WITH SECURITY_ENFORCED';
        Test.startTest(); 
            AzureFilesDeleteRequestBatch batch = new AzureFilesDeleteRequestBatch(soql); 
            Database.executeBatch(batch,10);
        Test.stopTest();
        List<Asset> aListwithBatchId = [SELECT Azure_Delete_Batch_Id__c FROM Asset where Azure_Delete_Batch_Id__c !=null]; 
        system.assertEquals(10, aListwithBatchId.size(), 'Return record after creating PE and updating assets'); 
    }

    @isTest
    static void testBatchExecuteForDMLError(){
        List<Asset> assets = [SELECT Azure_Delete_Batch_Id__c FROM Asset];
        for(Asset a : assets){
            a.Azure_Delete_Batch_Id__c = 'Acc12345678901234567890X656464465464676'; //batch id too large
        }
        Test.startTest();
        Boolean result =  AzureFileDeleteRequestHandler.updateAssets(assets);
        Test.stopTest();
        System.AssertEquals(false,result,'Returned invalid boolean value');
    }

    @isTest
    static void testBatchExecuteForException(){
        List<Boolean> exceptions = new List<Boolean>();
        string soql = 'SELECT Id, Name, Azure_Storage_URL__c, Case__c, Filename__c, Azure_Delete_Batch_Id__c,'
        + ' Name_on_Document__c, ParentId, Parent_Azure_Storage_URL__c' 
        + ' FROM Asset'
        + ' WHERE Status = \''+ 'Marked for Deletion' + '\''
        + ' AND LastModifiedDate >=LAST_N_DAYS:'+200        
        + ' WITH SECURITY_ENFORCED';      
        Test.startTest();
        try {
            AzureFilesDeleteRequestBatch batch = new AzureFilesDeleteRequestBatch(soql); 
            Database.executeBatch(batch,10);

                if(Test.isRunningTest()) {
                    // Cause DMLException
                    insert new Lead();
                }
            
        } catch (Exception e) {
            exceptions.add(true); 
        }      
        Test.stopTest();        
        System.AssertEquals(1,exceptions.size(),'Exception thrown');
    }

}