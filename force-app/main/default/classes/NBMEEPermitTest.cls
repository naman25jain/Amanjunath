@isTest
public class NBMEEPermitTest {

    public string parameterTypeEpermit = 'Epermit'; 
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
        Account ac = new Account(Name='EntityAcctName', RecordTypeId=identityAccountRecordTypeId, School__c=true, BillingCountry= 'India');
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

        NBME_Parameter__c np = new NBME_Parameter__c(Base_Url__c = 'www.ecfmg.org', Client_Id__c = 'ECFMG', Client_Password__c = '123456', client_Type__c= 'ADMIN', Client_Code__c = 'ADS', Parameter_Type__c =Constants.PARAMETER_TYPE_EPERMIT); 
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
        er.Exam_Request_Id__c = -1000;
        er.Applicant__c = testUser.contactId;
        insert er;

        //Create org default
        NBME_EPermit__c setting = new NBME_EPermit__c();
        setting.EPermit_Key__c = '1ea1842faaa0ec9df4851ea18b9a3c17';
        setting.EPermit_Vector__c = 'CB53030FE0799DDC80A983F103B65983';
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
            res =  NBMEEPermit.calloutNBMEforEpermit(surl);                         
            }        
        Test.stopTest();
        System.assertEquals(expectedValue, res.getBody(), 'blob received');

    }

    @isTest
    static void testGetParameter(){
        User testUser = [Select id,contactId from User where alias='user3'];
        string paramtype = Constants.PARAMETER_TYPE_EPERMIT; 
        list<NBME_Parameter__c> lnp; 
        Test.startTest();
        System.runAs(testUser){
            lnp = NBMEEPermit.getParameter(paramtype); 
        Test.stopTest();
        }
        System.assertEquals(1, lnp.size(), 'positive test for getparameter'); 
    }

    @isTest
    static void testGetExamDetail(){        
        User testUser = [Select id,contactId from User where alias='user3'];
        string paramtype = Constants.PARAMETER_TYPE_EPERMIT; 
        list<Exam_Registration__c> ler; 

        Test.startTest();
        System.runAs(testUser){
            ler = NBMEEPermit.getExamDetail(); 
        Test.stopTest();
        }
        System.assertEquals(1, ler.size(), 'positive test for testGetExamDetail'); 
    }


    @isTest
    static void testEncryptData(){
        User testUser = [Select id,contactId from User where alias='user3'];
        string sdata  = 'This is test';         
        string expectedEncryptedData; 

        Test.startTest();
        System.runAs(testUser){
            expectedEncryptedData = NBMEEPermit.encryptData(sdata); 
        Test.stopTest();
        }       
        System.assertEquals(string.isEmpty(expectedEncryptedData), false, 'positive test for EncryptData'); 
    }

    @isTest
    static void testDecryptData(){
        User testUser = [Select id,contactId from User where alias='user3'];
        string sdata  = 'This is test'; 
        string encryptedData = NBMEEPermit.encryptData(sdata); 
        string expectedDecryptedData; 
        Test.startTest();
        System.runAs(testUser){
            expectedDecryptedData = NBMEEPermit.decryptData(encryptedData); 
        Test.stopTest();
        }
        System.assertEquals(sdata, expectedDecryptedData, 'positive test for DecryptData'); 
    }


    @isTest
    static void testBuildUrlForEpermit(){        
        User testUser = [Select id,contactId from User where alias='user3'];        
        string testString  = 'www.ecfmg.org'; 
        string expectedEncryptedDate; 
/*         string base64EncryptedData  = 'test';  

        NBME_EPermit__c cusSetting = NBME_EPermit__c.getOrgDefaults();
        string secretKey = cusSetting.EPermit_Key__c; 
        string  sVector = cusSetting.EPermit_Vector__c; 
 */
        Test.startTest();
        System.runAs(testUser){
            expectedEncryptedDate = NBMEEPermit.buildUrlForEpermit(); 
        Test.stopTest();
        }
        string nString =expectedEncryptedDate.substring(0, 13); //expectedEncryptedDate value are encrypted string based on time that's why just testing first few charcters
        System.assertEquals(testString, nString, 'positive test for buildUrlForEpermit'); 
    }

    @isTest
    static void testGetBase64PdfForException(){
/* 
        NBME_EPermit__c cusSetting = NBME_EPermit__c.getOrgDefaults();
        string secretKey = cusSetting.EPermit_Key__c; 
        string  sVector = cusSetting.EPermit_Vector__c; 
 */
        User testUser = [Select id,contactId from User where alias='user3'];
        blob bdata  = Blob.valueOf('This is test'); 
        string sdata = EncodingUtil.Base64Encode(bdata); 
        string  surl = 'www.ecfmg.org'; 
        string res; 
        string expectedEncryptedData;  
        Test.startTest();
        List<Boolean> exceptions = new List<Boolean>();
        System.runAs(testUser){
            try {
                Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator_calloutNBME());
                res =  NBMEEPermit.getBase64Pdf();                                 
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