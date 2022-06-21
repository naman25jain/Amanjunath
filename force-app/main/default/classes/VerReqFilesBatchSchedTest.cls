/**
 * Created by Matthew on 2019-07-19.
 */
@isTest
public with sharing class VerReqFilesBatchSchedTest {
    @isTest
    public static void myTestMethod(){        
        test.starttest();
        VerReqFilesBatchSched myClass = new VerReqFilesBatchSched();   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, myClass);
        test.stopTest();
    }
}