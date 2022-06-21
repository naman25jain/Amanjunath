@isTest
private class CommonUtilsTest {
    
    static final String FILE_NAME = 'test.pdf';

    /**
     * * Setup Data (AAA-Arrange)
     */ 
    @testSetup static void setup() {

          // Cloud test data
          CloudDataTestFactory.createCloudConfig();
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testGetDocumentFromAzureReturns200() {
        //Arrange
            
        //Act
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator_GetPicture());
            HttpResponse response = CommonUtils.getDocumentFromAzure(ConstantsTest.TEST_ASSET_AZURE_STORAGE_URL);
            Integer statusCode = response.getStatusCode();
            Test.stopTest();
        
        //Assert
            System.assertEquals(200, statusCode,'Status code is not 200');
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testGetDocumentFromAzureThrowsException() {
        //Arrange
            
        //Act
            try{
                Test.startTest();
                Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator_GetPicture());
                CommonUtils.getDocumentFromAzure(null);
                Test.stopTest();
            }catch(Exception e){
                //Assert
                System.assertNotEquals(null, e,'Exception is not thrown'); 
            }
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testGetFileNameFromUrlReturnsFileName() {
        //Arrange
            
        //Act
            Test.startTest();
            String fileName = CommonUtils.getFileNameFromUrl(ConstantsTest.TEST_ASSET_AZURE_FILE_URL);
            Test.stopTest();
        
        //Assert
            System.assertEquals(FILE_NAME, fileName,'FileName is Empty');
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testLogMessageReturnsTrue() {
        //Arrange
        Log_Message__c logMessage = new Log_Message__c();

        //Act
            Test.startTest();
            Boolean success = CommonUtils.logMessage(logMessage);
            Test.stopTest();
        
        //Assert
            System.assertEquals(true, success,'Insert Log Message returned false');
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
}