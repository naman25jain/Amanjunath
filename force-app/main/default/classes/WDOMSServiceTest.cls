@isTest
public with sharing class WDOMSServiceTest {
    @testSetup static void setup(){
        WDOMSResponseServiceTestFactory.servicePageSetup(); 
    }
@isTest
static void getObject2DegreeInfoWDOMSTest(){
    Object2Degree__c o = [select Id from Object2Degree__c where WDOMS_ID__c = '6666']; 

    Test.startTest();
            List<Object2Degree__c> o2ds  = WDOMSService.getObject2DegreeInfoWDOMS(o.Id); 
        Test.stopTest();
        System.assertEquals(1, o2ds.size(), 'getObject2DegreeInfoWDOMS service test ');
}

@isTest
static void getDegreeInfoWDOMSTest(){
    Degree__c d = [select Id from Degree__c where WDOMS_ID__c = '6611']; 

    Test.startTest();
            List<Degree__c> ds  = WDOMSService.getDegreeInfoWDOMS(d.Id); 
        Test.stopTest();
        System.assertEquals(1, ds.size(), 'getDegreeInfoWDOMS service test ');
}

@isTest
static void getMedSchoolCodeByAccountIdTest(){
    account a = [select Id from account where Medschool_Code__c = '098123']; 

    Test.startTest();
            string medSchoolCode  = WDOMSService.getMedSchoolCodeByAccountId(a.Id); 
        Test.stopTest();
        System.assertEquals(medSchoolCode, '098123', 'Medical School Code Test ');
}

@isTest 
static void getAccountAffiliationByProgramIdTest(){ 
    string stypeVariable = 'Other'; 
    string expectedValue = 'OTHER'; 
    string returnValue;   
    
    List<Program__c> progs  = [select id from program__c where WDOMS_ID__c = '23456'];          
    string wdmsid; 
    Test.startTest();        
    List<Account_Affiliation__c> accAffs = WDOMSService.getAccountAffiliationByProgramId(progs[0].Id);         
    Test.stopTest();
    System.assertEquals(1, accAffs.size(), 'School Affiliation by ProgramId ');
    
}

}