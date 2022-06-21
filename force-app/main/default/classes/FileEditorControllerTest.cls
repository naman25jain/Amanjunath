/**
 * @name         : FileEditorControllerTest
 * @description  : Test class for FileEditorController
 * @author       : Shailaja
 * @createdDate  : 12-FEB-2021
 */
@isTest
public class FileEditorControllerTest{
	/**
     * * Setup Data (AAA-Arrange)
     */ 
    @testSetup static void setup(){
        //Common Data Setup
        BaseTestFactory.getCustomerCommunityPlusUser();
        
        // Create a new case to be used in all applicable test functions
        Profile profile = BaseTestFactory.getProfile(ConstantsTest.TEST_PROFILE_COMMUNITY_LOGIN);
        User user = [SELECT id, contactId 
                        FROM User 
                        WHERE alias =: ConstantsTest.TEST_USER_ALIAS
                        AND profileId =: profile.id
                        LIMIT 1];
        Contact contact = [SELECT id, AccountId 
                            FROM Contact 
                            WHERE Id =: user.contactId
                            LIMIT 1];
        // new case 
        Case caseWithWorkingStatus = new Case(ContactId = contact.Id,
                                                AccountId = contact.AccountId,
                                                Internal_Status__c = ConstantsTest.TEST_CASE_STATUS_NEW);
        //ConstantsTest.TEST_CASE_STATUS_WORKING
        insert caseWithWorkingStatus;
    }
    @isTest public static void testPositiveGetFileBlob(){
		try 
        {
			Blob tempBlob;
			Test.startTest();
			tempBlob = FileEditorController.getFileBlob();
			Test.stopTest();
        }
        catch(Exception e)
        {
            //Assert
			System.assertNotEquals(null, e,'GetFileBlob Exception is not thrown'); 
         }
    }
	
	@isTest public static void testPositiveGetCaseFileIds(){
		
		Case workingCase =  [SELECT Id, Internal_Status__c, ContactId
                            FROM Case
                            //WHERE Internal_Status__c =: ConstantsTest.TEST_CASE_STATUS_WORKING
                            WHERE Internal_Status__c =: ConstantsTest.TEST_CASE_STATUS_NEW
                            LIMIT 1];
		
		
        ContentVersion cv1 = new ContentVersion(Title = 'Photo', 
												PathOnClient = 'Test.jpg', 
												VersionData = Blob.valueOf('Test Content Data'), 
												IsMajorVersion = true);
        
        insert cv1;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId 
											FROM ContentDocument LIMIT 1];
        
		ContentDocumentLink cdl = new ContentDocumentLink(LinkedEntityId = workingCase.Id, 
															ContentDocumentId = documents[0].Id, 
															ShareType = Constants.CONTENT_DOCUMENT_LINK_SHARE_TYPE_INFERRED);
        
        insert cdl;

		test.startTest();		
		List<String> caseFileIDs = FileEditorController.getCaseFileIds(workingCase.Id);
		test.stopTest();
		//Assert
        System.assertEquals(caseFileIDs.isEmpty(), false,'GetCaseFileIds not retrieved'); 
	}
}