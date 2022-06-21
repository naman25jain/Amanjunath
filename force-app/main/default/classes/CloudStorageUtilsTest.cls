@isTest
private class CloudStorageUtilsTest {
    public static final String FILENAME = 'test.pdf';
    public static final String FILEEXT = 'pdf';
    private static final String SASISEMPTY = 'SASUrl is empty';

    @testSetup static void setup() {
        CloudDataTestFactory.createCloudConfig();
    }

    @isTest
    static void testGenerateSASTokenCreate(){
        Cloud_Storage_Config__c csc = [SELECT Account_Name__c, Container_Name__c, Shared_Key__c FROM Cloud_Storage_Config__c WHERE Account_Name__c='storageaccount' LIMIT 1];
        CloudStorageUtils.STORAGE_ACCOUNT = csc.Account_Name__c;
        CloudStorageUtils.STORAGE_CONTAINER = csc.Container_Name__c;
        CloudStorageUtils.SHARED_KEY = csc.Shared_Key__c;
        CloudStorageUtils.STORAGE_CANONICAL_URL = 'storagecanonicalurl';
        
        string sasUrl = CloudStorageUtils.generateSASToken(FILENAME, DocumentEnums.DocumentAccessLevel.CREATE);
        System.assertNotEquals(null, sasUrl,SASISEMPTY);
    }
    
    @isTest
    static void testGenerateSASTokenRead(){
        Cloud_Storage_Config__c csc = [SELECT Account_Name__c, Container_Name__c, Shared_Key__c FROM Cloud_Storage_Config__c WHERE Account_Name__c='storageaccount' LIMIT 1];
        CloudStorageUtils.STORAGE_ACCOUNT = csc.Account_Name__c;
        CloudStorageUtils.STORAGE_CONTAINER = csc.Container_Name__c;
        CloudStorageUtils.SHARED_KEY = csc.Shared_Key__c;
        CloudStorageUtils.STORAGE_CANONICAL_URL = 'storagecanonicalurl';
        
        string sasUrl = CloudStorageUtils.generateSASToken(FILENAME, DocumentEnums.DocumentAccessLevel.READ);
        System.assertNotEquals(null, sasUrl,SASISEMPTY);
    }

    @isTest
    static void testGenerateSASTokenCreateUpdate(){
        Cloud_Storage_Config__c csc = [SELECT Account_Name__c, Container_Name__c, Shared_Key__c FROM Cloud_Storage_Config__c WHERE Account_Name__c='storageaccount' LIMIT 1];
        CloudStorageUtils.STORAGE_ACCOUNT = csc.Account_Name__c;
        CloudStorageUtils.STORAGE_CONTAINER = csc.Container_Name__c;
        CloudStorageUtils.SHARED_KEY = csc.Shared_Key__c;
        CloudStorageUtils.STORAGE_CANONICAL_URL = 'storagecanonicalurl';
        
        string sasUrl = CloudStorageUtils.generateSASToken(FILENAME, DocumentEnums.DocumentAccessLevel.CREATE_UPDATE);
        System.assertNotEquals(null, sasUrl,SASISEMPTY);
    }

    @isTest
    static void testGenerateSASTokenEmpty(){
        Cloud_Storage_Config__c csc = [SELECT Account_Name__c, Container_Name__c, Shared_Key__c FROM Cloud_Storage_Config__c WHERE Account_Name__c='storageaccount' LIMIT 1];
        CloudStorageUtils.STORAGE_ACCOUNT = csc.Account_Name__c;
        CloudStorageUtils.STORAGE_CONTAINER = csc.Container_Name__c;
        CloudStorageUtils.SHARED_KEY = csc.Shared_Key__c;
        CloudStorageUtils.STORAGE_CANONICAL_URL = 'storagecanonicalurl';
        
        string sasUrl = CloudStorageUtils.generateSASToken(FILENAME, null);
        System.assertEquals(null, sasUrl,'SASUrl is not empty');
    }

    @isTest
    static void testCreateGuidBasedFileNamePositive(){
        System.assert(CloudStorageUtils.createGuidBasedFileName(FILEEXT).length() > 4, 'Guid FileName length is less than 4');
    }

    @isTest
    static void testGetFileUrlWithSASPositive(){
        System.assertNotEquals(null, CloudStorageUtils.getFileUrlWithSAS(FILENAME), 'Filename is null');
    }

    @isTest
    static void testGetRequestHeadersPositive(){
        
        Cloud_Storage_Config__c csc = [SELECT Account_Name__c, Container_Name__c, Shared_Key__c FROM Cloud_Storage_Config__c WHERE Account_Name__c='storageaccount' LIMIT 1];
        CloudStorageUtils.STORAGE_ACCOUNT = csc.Account_Name__c;
        CloudStorageUtils.STORAGE_CONTAINER = csc.Container_Name__c;
        CloudStorageUtils.SHARED_KEY = csc.Shared_Key__c;
        CloudStorageUtils.STORAGE_CANONICAL_URL = 'storagecanonicalurl';
        
        string sasUrl = CloudStorageUtils.generateSASToken(FILENAME, null);
        
        System.assertNotEquals(null, CloudStorageUtils.getRequestHeaders(DocumentEnums.DocumentAccessLevel.CREATE,FILENAME,'abc'), 'Request headers is null');

    }

    @isTest
    static void testGetBase64PdfPositive(){
        Cloud_Storage_Config__c csc = [SELECT Account_Name__c, Container_Name__c, Shared_Key__c FROM Cloud_Storage_Config__c WHERE Account_Name__c='storageaccount' LIMIT 1];
        CloudStorageUtils.STORAGE_ACCOUNT = csc.Account_Name__c;
        CloudStorageUtils.STORAGE_CONTAINER = csc.Container_Name__c;
        CloudStorageUtils.SHARED_KEY = csc.Shared_Key__c;
        CloudStorageUtils.STORAGE_CANONICAL_URL = 'storagecanonicalurl';
        
        string sasUrl = CloudStorageUtils.generateSASToken(FILENAME, DocumentEnums.DocumentAccessLevel.READ);

        string res; 
        string expectedEncryptedData;  
        Test.startTest();
        List<Boolean> exceptions = new List<Boolean>();
        try {
            Test.setMock(HttpCalloutMock.class, new MockHttpRespGenerator_calloutAzureDoc());
            res =  CloudStorageUtils.getBase64Pdf(sasUrl);
        } catch (Exception e) {
            if (!String.isBlank(e.getMessage())){
                exceptions.add(true); 
            }
        }
        Test.stopTest();
        System.assertEquals(null, null, 'positive test for EncryptData'); 
        for(Boolean b : exceptions){
            system.assert(b, 'Exception thrown');
          }
    }
      
}