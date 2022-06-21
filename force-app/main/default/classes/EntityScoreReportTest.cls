/**
* Test Class for EntityScoreReport class
*
* @author        Enable Consulting
* @version       1.0
* @createdDate   17-June-2020
*/
@isTest
public class EntityScoreReportTest {
    @testSetup static void setup() {
        EntityScoreReportTestFactory.servicePageSetup();
    }
    
    public static testmethod void testcheckPerformanceDataEnrolled(){
        
        Map<String, Map<String, String>> returnValuesMap = new Map<String, Map<String, String>> ();
        User testUser = [SELECT Id, ContactId from User where alias = 'second'];
        Contact con = [Select Id,AccountId from Contact where Id =: testuser.ContactId];
        Test.startTest();
        System.runAs(testUser) {
            Boolean returnVal = EntityScoreReport.checkPerformanceDataEnrolled(con.AccountId);
            system.assert(!returnVal);
            returnValuesMap = EntityScoreReport.getPerformanceData(con.AccountId);
        }
        Test.stopTest();
    }
    
    public static testmethod void testgetPerformanceData(){
        
    }
}