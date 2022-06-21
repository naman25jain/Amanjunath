@isTest 
public with sharing class ScheduleJobUtilityTest {

    @isTest 
    public static void getScheduleJobParametersPositive(){
        Schedule_Job_Configuration__mdt  md; 
        Test.startTest(); 
             md = ScheduleJobUtility.getScheduleJobParameters('Azure file Delete'); 
        test.stopTest(); 
        system.assertEquals(30, md.Run_After_No_Of_Days__c , 'Get Schedule Parameter Postive test'); 
    }

    @isTest 
    public static void getScheduleJobParametersNegative(){
        Schedule_Job_Configuration__mdt  md; 
        Test.startTest(); 
             md = ScheduleJobUtility.getScheduleJobParameters('Azure file Delete'); 
        test.stopTest(); 
        system.assertNotEquals(31, md.Run_After_No_Of_Days__c , 'Get Schedule Parameter negative test'); 
    }

    @isTest 
    public static void getScheduleJobParametersNullResult(){
        Schedule_Job_Configuration__mdt  md; 
        List<Boolean> exceptions = new List<Boolean>();
        Test.startTest(); 
        try {
          
            md = ScheduleJobUtility.getScheduleJobParameters('No result'); 
          
        } catch (Exception e) {
            exceptions.add(true); 
        }
        test.stopTest(); 

        System.AssertEquals(1,exceptions.size(),'Exception thrown');
    }
}