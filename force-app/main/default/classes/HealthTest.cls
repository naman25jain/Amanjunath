@isTest
public class HealthTest{
    static testmethod void testGetHealth(){
        String returnVal = Health.getHealth();
        System.assertNotEquals(returnVal, NULL ,'Value returned is Null.');
    }
}