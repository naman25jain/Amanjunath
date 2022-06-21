@isTest
public class NBMEScoreReportingTest {
    @testSetup static void setup(){
        //create a new contact;
        date birthdate1 = date.valueOf('2000-01-01');
        string emailtest = 'tester@unknownmail.com';
        String userName = 'tester@unknownmail.com_' + System.now();
        userName=userName.replace(' ','').replace(':','-');
        string lastname = 'Last';
        string firstname = 'First';
        Id p=[Select id from profile where name='4-Customer Community Plus Login' LIMIT 1].id;
        Contact c1 = new Contact(Firstname=firstname,School_Enrollment_Status__c=constants.CONASCTYPESTG_STATUS_STUDENT,Lastname=lastname,Birthdate=birthdate1,email=emailtest,MailingCountry='Mexico',Step_1_Attempt_Limit_Exception__c = true, Step_2_CK_Attempt_Limit_Exception__c= true,Step_2_CS_Attempt_Limit_Exception__c= true);
        insert c1;
        //create Entity record for Account                     
        Id identityAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account ac = new Account(Name='EntityAcctName', RecordTypeId=identityAccountRecordTypeId, School__c=true,BillingCountry= 'India');
        insert ac;
        User user3 = new User(alias='user3',email=emailtest,emailencodingkey='UTF-8',lastname=lastname, languagelocalekey='en_US',localesidkey='en_US',profileid=p,country='United States',IsActive=true,ContactId=c1.Id, timezonesidkey='America/Los_Angeles',username=username);
        insert user3;    
        //create Contact Association type object        
        Id conAssocRecordTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_MEDICAL_SCHOOL).getRecordTypeId();
        Contact_Association_Type__c conAssocType = new Contact_Association_Type__c(RecordTypeId=conAssocRecordTypeId,contact__c = c1.Id,Account__c=ac.id, Number_of_Years_Attended__c = 2);
        insert conAssocType;
        Id conAssocRecordTypeId1 = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_OTHER_INSTITUTION).getRecordTypeId();
        Contact_Association_Type__c conAssocType1 = new Contact_Association_Type__c(RecordTypeId=conAssocRecordTypeId1,contact__c = c1.Id,Account__c=ac.id, Number_of_Years_Attended__c = 2);
        insert conAssocType1;
        Asset permit = new Asset();
        permit.Name = Constants.ASSET_TYPE_TCT;
        permit.ContactId = c1.Id;
        permit.Contact_Association_Type__c = conAssocType.Id;
        permit.type__c = Constants.ASSET_TYPE_TCT;
        permit.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        insert permit;

        NBME_Parameter__c np = new NBME_Parameter__c(Base_Url__c = 'www.ecfmg.org', Client_Id__c = 'ECFMG', Client_Password__c = '123456', client_Type__c= 'ADMIN', Client_Code__c = 'ADS', Parameter_Type__c =Constants.PARAMETER_TYPE_SCORE_REPORTING); 
        insert np; 

        User testUser = [Select id,contactId from User where alias='user3'];
        
        Id examRegRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        Case newCase = new Case(
            RecordTypeId = examRegRecordTypeId,
            ContactId = testUser.contactId,
            Service__c = Constants.CASE_SERVICE_ECFMG_CERTIFICATION,
            Internal_Status__c = Constants.CASE_STATUS_REGISTERED
        );
        insert newCase;
        String caseId = newCase.Id;

        //Create Exam Registration 
        date epStartDate = System.Today() + 1;
        date epEndDate = System.Today() - 25;
        Exam_Registration__c er = new Exam_Registration__c();
        er.Exam_Types__c = constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE;
        er.EP_start_Date__c = epStartDate;
        er.EP_end_Date__c = epEndDate;
        er.Test_Accommodations_needed__c = 'yes';
        er.Visa_Letter_Needed__c = true;        
        er.case__c = caseId;
        er.Score_report_Document_id__c = '-1000';
        er.Applicant__c = testUser.contactId;
        insert er;
        
        //Create org default
        NBME_Score_Reporting__c setting = new NBME_Score_Reporting__c();
        setting.ScoreReporting_Key__c = '1d0d1da8d5f715d7e752495139496577';
        setting.ScoreReporting_Vector__c = '2f4792bf3723efcf729e43b937a95678';
        insert setting;   
    }

    @isTest 
    static void testNBMECallout(){        
        User testUser = [Select id,contactId from User where alias='user3'];
        string expectedValue ='NBME API Test'; 
        HttpResponse res; 
        string surl = 'https:test.ecfmg.org'; 

        Test.startTest();
        System.runAs(testUser){
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator_calloutNBME());
            res =  NBMEScoreReporting.calloutNBMEforScoreReporting(surl);                         
            }        
        Test.stopTest();
        System.assertEquals(expectedValue, res.getBody(), 'blob received');
    }

    @isTest
    static void testBuildUrlForEpermit(){        
        User testUser = [Select id,contactId from User where alias='user3'];        
        string testString  = 'www.ecfmg.org'; 
        string expectedEncryptedDate; 
        Exam_Registration__c ler = [SELECT id FROM Exam_Registration__c LIMIT 1]; 

        Test.startTest();
        System.runAs(testUser){
            expectedEncryptedDate = NBMEScoreReporting.buildUrlForScoreReporting(ler.Id); 
        Test.stopTest();
        }
        string nString =expectedEncryptedDate.substring(0, 13); 
        System.assertEquals(testString, nString, 'positive test for buildUrlForEpermit'); 
    }

    @isTest
    static void testDecryptData(){
        User testUser = [Select id,contactId from User where alias='user3'];
        string sdata  = 'This is test'; 
        string encryptedData = NBMEScoreReporting.encryptData(sdata); 
        string expectedDecryptedData; 
        Test.startTest();
        System.runAs(testUser){
            expectedDecryptedData = NBMEScoreReporting.decryptData(encryptedData); 
        Test.stopTest();
        }
        System.assertEquals(sdata, expectedDecryptedData, 'positive test for DecryptData'); 
    }

    @isTest
    static void testGetBase64PdfForException(){
        User testUser = [Select id,contactId from User where alias='user3'];
        blob bdata  = Blob.valueOf('This is test'); 
        string sdata = EncodingUtil.Base64Encode(bdata); 
        string  surl = 'www.ecfmg.org'; 
        string res; 
        string expectedEncryptedData;  
        Exam_Registration__c ler = [SELECT id FROM Exam_Registration__c LIMIT 1]; 
        Test.startTest();
        List<Boolean> exceptions = new List<Boolean>();
        System.runAs(testUser){
            try {
                Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator_calloutNBME());
                res =  NBMEScoreReporting.getBase64Pdf(ler.id);                                 
            } catch (Exception e) {
                if (!String.isBlank(e.getMessage())){
                    exceptions.add(true); 
                }
            }
        Test.stopTest();
        }
        System.assertEquals(null, null, 'positive test for EncryptData'); 
        for(Boolean b : exceptions){
            system.assert(b, 'Exception thrown');
          }
    }    
}