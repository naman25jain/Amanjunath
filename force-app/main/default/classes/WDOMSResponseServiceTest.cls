@isTest
public with sharing class WDOMSResponseServiceTest {

    @testSetup static void setup(){
        WDOMSResponseServiceTestFactory.servicePageSetup(); 
    }

    @isTest 
    static void buildbuildAccountResponseTestPositive(){  
        Account a = [select Id from Account where WDOMS_ID__c = '1234']; 
        string wdmsid; 
        Test.startTest();
            WDOMSAccountResponse.Payload p = WDOMSResponseService.buildAccountResponse(a.Id); 
            if (p!=null){
                wdmsid = p.payload.sfSchoolId; 
            }
        Test.stopTest();
        System.assertEquals('1234', wdmsid, 'Account payload return ');
    }

    @isTest 
    static void buildbuildAccountResponseforUpdateTrigger(){  
        Account a = [select Id from Account where WDOMS_ID__c = '1234']; 
        string wdmsid = '00000'; 
        a.WDOMS_ID__c = wdmsid; 
        update a; 
        Test.startTest();
            WDOMSAccountResponse.Payload p = WDOMSResponseService.buildAccountResponse(a.Id); 
            if (p!=null){
                wdmsid = p.payload.sfSchoolId; 
            }
        Test.stopTest();
        System.assertEquals('00000', wdmsid, 'Account payload return ');

    }


    @isTest 
    static void buildAccLanguageResponseTestPositive(){  
        Account_Language__c a = [select id from Account_Language__c]; 
        user revUser =  [SELECT id, ContactId from User where email = :WDOMSResponseServiceTestFactory.reviewerEmailtest LIMIT 1];  
        user adUser =  [SELECT id, ContactId from User where email = :WDOMSResponseServiceTestFactory.adminEmailtest LIMIT 1];
        System.debug('rev user is '+ adUser);  
        string wdmsid; 
        Test.startTest();
            System.runAs(adUser){
            WDOMSAccLangResponse.Payload p = WDOMSResponseService.buildAccLanguageResponse(a.Id); 
        
                if (p!=null){
                    wdmsid = p.payload.SF_schoolLanguageId; 
                }
            Test.stopTest();
            System.assertEquals('9999', wdmsid, 'Account Language payload return ');
        }

    }

    @isTest 
    static void buildAccLanguageUpdateTrigger(){  
        Account_Language__c a = [select id from Account_Language__c]; 
        string lang;
        a.Language__c = 'Chinese';
        update a;
        Test.startTest();
        WDOMSAccLangResponse.Payload p = WDOMSResponseService.buildAccLanguageResponse(a.Id); 
       
            if (p!=null){
                lang = p.payload.language; 
            }
        Test.stopTest();
        System.assertEquals('Chinese', lang, 'Account Language Update Trigger test ');

    }

    @isTest 
    static void buildSchContactContactInfoResponseTestPositive(){  
        Additional_Info__c a = [select id from Additional_Info__c where WDOMS_ID__c = '8888'];   
        WDOMSAccContactContactInfoResponse.Payload p;   
        user revUser =  [SELECT id, ContactId from User where email = :WDOMSResponseServiceTestFactory.reviewerEmailtest LIMIT 1];
        user adUser =  [SELECT id, ContactId from User where email = :WDOMSResponseServiceTestFactory.adminEmailtest LIMIT 1];
        System.debug('rev user is '+ adUser);               
        string wdmsid; 
        Test.startTest();
            System.runAs(adUser){
                p = WDOMSResponseService.buildSchContactContactInfoResponse(a.Id);         
                if (p!=null){               
                    p.payload.size();                
                }
            }
        Test.stopTest();
        System.assertEquals(1, p.payload.size(), 'Account Language payload return ');
    }

    @isTest 
    static void buildSchContactInfoResponseResponseTestPositive(){  
        Additional_Info__c a = [select id from Additional_Info__c where WDOMS_ID__c = '8888'];         
        string wdmsid; 
        Test.startTest();
        WDOMSAccContactInfoResponse.Payload p = WDOMSResponseService.buildSchContactInfoResponse(a.Id);         
        Test.stopTest();
        System.assertEquals('abcd@ecfmg.org', p.payload.contactData, 'Account Language payload return ');
    }

    @isTest 
    static void buildSchoolAffiliationResponseTestPositive(){  
        Account_Affiliation__c a = [select id from Account_Affiliation__c where WDOMS_ID__c = '7777'];         
        string wdmsid; 
        Test.startTest();
        WDOMSAccountAffiliationResponse.Payload p = WDOMSResponseService.buildSchoolAffiliationResponse(a.Id);         
            if (p!=null){
                wdmsid = p.payload.schoolAffiliationId; 
            }
        Test.stopTest();
        System.assertEquals('7777', wdmsid, 'SchoolAffiliation payload return ');
    }
    
    @isTest 
    static void buildSchoolAffiliationUpdateTrigger(){  
        Account_Affiliation__c a = [select id from Account_Affiliation__c where WDOMS_ID__c = '7777'];         
        a.YearTo__c ='2011'; 
        update a; 
        string yearto; 
        Test.startTest();
        WDOMSAccountAffiliationResponse.Payload p = WDOMSResponseService.buildSchoolAffiliationResponse(a.Id);         
            if (p!=null){
                yearto = p.payload.endYear;                                 
            }
        Test.stopTest();
        System.assertEquals('2011', yearto, 'SchoolAffiliation payload return ');
    }

    @isTest 
    static void decodeStringValueTestNegative(){
        string retValue = WDOMSResponseService.decodeStringValue('No');         
        System.assertEquals('N', retValue, 'Decode String value return N ');
    }

    @isTest 
    static void decodeBooleanToStringTestNegative(){
        string retValue = WDOMSResponseService.decodeBooleanToString(false);         
        System.assertEquals('N', retValue, 'Decode String value return N ');

    }

    @isTest 
    static void buildSchUrlResponseTestPositive(){  
        Additional_Info__c a = [select id from Additional_Info__c where WDOMS_ID__c = '9999']; 
        string newUrl = 'www.Myabcd.org'; 
        a.value__c =  newUrl; 
        update a;        
        Test.startTest();        
            WDOMSAccURLResponse.Payload p = WDOMSResponseService.buildSchUrlResponse(a.Id);         
        Test.stopTest();
        System.assertEquals(newUrl, p.payload.url, 'SchoolURL test ');

    }

    @isTest 
    static void buildSchAKAResponseTestPositive(){  
        aka_Names__c aka  = [select id from aka_Names__c where WDOMS_ID__c = '12345'];         
        string wdmsid; 
        Test.startTest();        
            WDOMSAkaResponse.Payload p = WDOMSResponseService.buildSchAKAResponse(aka.Id);         
        Test.stopTest();
        System.assertEquals('BN AKA Test', p.payload.akaName, 'SchoolURL test ');

    }

    
   @isTest 
    static void buildSchoolProgramResponseTestPositive(){  
        Account_Affiliation__c a = [select id from Account_Affiliation__c where WDOMS_ID__c = '2222'];          
        string wdmsid; 
        Test.startTest();        
            WDOMSSchoolProgramResponse.Payload p = WDOMSResponseService.buildSchoolProgramResponse(a.Id);         
        Test.stopTest();
        System.assertEquals('23456', p.payload.sfmdtprogramId, 'School program test  ');
    }


//Trigger related 
    @isTest 
    static void buildSchoolAffiliationUpdateTriggerforSchAff(){  
        Id affRectype = Schema.SObjectType.Account_Affiliation__c.getRecordTypeInfosByName().get('Academic Affiliation').getRecordTypeId();
        Account_Affiliation__c a = [select id from Account_Affiliation__c where WDOMS_ID__c = '7777' and RecordTypeId =: affRectype];         
        a.YearTo__c ='2011'; 
        update a; 
        string yearto; 
        Test.startTest();
            WDOMSAccountAffiliationResponse.Payload p = WDOMSResponseService.buildSchoolAffiliationResponse(a.Id);         
                if (p!=null){
                    yearto = p.payload.endYear;                                 
                }
        Test.stopTest();
        System.assertEquals('2011', yearto, 'School Affiliation payload return ');
    }

    @isTest 
    static void buildSchoolAffiliationUpdateTriggerforProgAff(){  
        Id affRectype = Schema.SObjectType.Account_Affiliation__c.getRecordTypeInfosByName().get('Educational Program').getRecordTypeId();
        Account_Affiliation__c a = [select id from Account_Affiliation__c where WDOMS_ID__c = '2222' and RecordTypeId =: affRectype];         
        a.YearTo__c ='2011'; 
        update a; 
        string yearto; 
        Test.startTest();
            WDOMSAccountAffiliationResponse.Payload p = WDOMSResponseService.buildSchoolAffiliationResponse(a.Id);         
                if (p!=null){
                    yearto = p.payload.endYear;                                 
                }
        Test.stopTest();
        System.assertEquals('2011', yearto, 'Program Affiliation payload return ');
    }

    @isTest 
    static void additionalInfoTrigerUpdateTest(){  
        Additional_Info__c a = [select id from Additional_Info__c where WDOMS_ID__c = '8888'];  
        a.Value__c = 'xzy@ecfmg.org'; 
        update a;        
        string wdmsid; 
        Test.startTest();
            WDOMSAccContactInfoResponse.Payload p = WDOMSResponseService.buildSchContactInfoResponse(a.Id);         
        Test.stopTest();
        System.assertEquals('xzy@ecfmg.org', p.payload.contactData, 'Additonal info update trigger test ');
    }

    @isTest 
    static void schAKATriggerUpdateTest(){  
        aka_Names__c aka  = [select id from aka_Names__c where WDOMS_ID__c = '12345']; 
        aka.Name = 'AKA Test'; 
        update aka;             
        Test.startTest();        
            WDOMSAkaResponse.Payload p = WDOMSResponseService.buildSchAKAResponse(aka.Id);         
        Test.stopTest();
        System.assertEquals('AKA Test', p.payload.akaName, 'AKA update trigger test');
    }

    @isTest 
    static void degreeTrigerUpdateTest(){  
        Degree__c a = [select id from Degree__c where WDOMS_ID__c = '6611'];  
        a.Abbreviation__c = 'DTTNewOne'; 
        update a;                
        Test.startTest();
        WDOMSMDTProgramDegreeTypeResponse.Payload p = WDOMSResponseService.buildMdtProgramDegreeTypeResponse(a.Id);         
        Test.stopTest();
        System.assertEquals('DTTNewOne', p.payload.degreeAbbreviation, 'Degree tu[e test] update trigger test ');
    }

        
    @isTest 
    static void object2degreeTrigerUpdateTest(){  
        Object2Degree__c a = [select id from Object2Degree__c where WDOMS_ID__c = '6666'];  
        a.Graduation_Year__c = '2015'; 
        update a;                
        Test.startTest();
        WDOMSMdtGradYearResponse.Payload p = WDOMSResponseService.buildMdtGradYearResponse(a.Id);         
        Test.stopTest();
        System.assertEquals('2015', p.payload.gradYear, 'Object2Degree__c update trigger test ');
    }

    @isTest 
    static void programTrigerUpdateTest(){  
        Program__c a = [select id from Program__c where WDOMS_ID__c = '23456'];  
        a.Name  = 'New Test Program'; 
        update a;                
        Test.startTest();
        WDOMSMdtProgramResponse.Payload p = WDOMSResponseService.buildMdtProgramResponse(a.Id);         
        Test.stopTest();
        System.assertEquals('New Test Program', p.payload.programName, 'Program__c update trigger test ');
    }

    @isTest 
    static void getSchoolTypeCodeforBoth(){ 
        string stypeVariable = 'Both'; 
        string expectedValue = 'MIXED PUBLIC/PRIVATE'; 
        string returnValue;        
        Test.startTest();
        returnValue = WDOMSResponseService.getSchoolTypeCode(stypeVariable);         
        Test.stopTest();
        System.assertEquals(expectedValue,returnValue, 'getSchoolTypeCode Test for School type code Both');
    }

    @isTest 
    static void getSchoolTypeCodeforOther(){ 
        string stypeVariable = 'Other'; 
        string expectedValue = 'OTHER'; 
        string returnValue;        
        Test.startTest();
        returnValue = WDOMSResponseService.getSchoolTypeCode(stypeVariable);         
        Test.stopTest();
        System.assertEquals(expectedValue,returnValue, 'getSchoolTypeCode Test for School type code Both');
    }

    @isTest 
    static void buildbuildAccountResponseforAdditionalPE(){  
        boolean isSchool = false; 
        Account a = [select Id from Account where WDOMS_ID__c = '1234']; 
       // string wdmsid = '00000'; 
        a.school__c = false; 
        update a; 
        Account b = [select Id from Account where WDOMS_ID__c = '1234' and school__c =false];
        b.school__c = true; 
        update b;
        Account c = [select Id, school__c from Account where WDOMS_ID__c = '1234'];
        isSchool = c.school__c; 
        Test.startTest();
        AccountTriggerHelper.raiseAdditionalWDOMSPlatformEvents(a.Id); 

        Test.stopTest();
        System.assertEquals(isSchool, true, 'void method raiseAdditionalWDOMSPlatformEvents test ');

    }

}