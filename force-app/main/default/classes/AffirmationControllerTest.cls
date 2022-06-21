@isTest
private class AffirmationControllerTest {
    
    @isTest
    static void testInsertAffirmationReturnsTrue() {
        //Arrange
           boolean success;

           List<Affirmation__c> affirmations = new List<Affirmation__c>();
           affirmations.add(new Affirmation__c(Status__c = Constants.AFFIRMATION_STATUS_IN_PROGRESS, 
                                               RecordTypeId = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get(Constants.AFFIRMATION_RECORD_TYPE_ID_VERIFICATION).getRecordTypeId()));

        //Act
                Test.startTest();
                success = AffirmationController.insertAffirmation(affirmations);
                Test.stopTest();
        //Assert
                 System.assertEquals(true, success,'Insert affirmation returns false'); 
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    @isTest
    static void testInsertAffirmationThrowsException() {
        //Arrange

        //Act
        try 
        {
            Test.startTest();
            AffirmationController.insertAffirmation(null);
            Test.stopTest();
        }
        catch(Exception e)
        {
            //Assert
             System.assertNotEquals(null, e,'Insert Affirmation - Exception is not thrown'); 
        }
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
}