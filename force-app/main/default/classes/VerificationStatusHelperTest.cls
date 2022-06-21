@isTest 
public  class VerificationStatusHelperTest{
    public static final String CORRELATION_ID = '7cc64d24-f2ad-4d43-8893-f12345690000';
    public static final String AZURE_STORAGE_URL = 'www.azure.docurl.com';
    public static final String TEST_SCHOOL = 'Test School';
    @testSetup static void setup(){
        Verification_Request__c vr = new Verification_Request__c(
            CorrelationId__c = CORRELATION_ID,
            Account_Exact_Scenario_Score__c = null,
            Account_Non_Exact_Scenario_Score__c = null,
            Batch_Id__c = '12345',
            Birth_Date__c = Date.parse('1/1/1970'),
            Candidate_Code__c = 'ABC123',
            Client_Batch_Create_Date__c = Date.today(),
            Client_Institution_ID__c = '12345',
            Client_Provided_Entity_ID__c = '12345',
            Client_Provided_Entity_Name__c = TEST_SCHOOL,
            Comments__c = 'This is a comment',
            Contact_Exact_Scenario_Score__c = null,
            Contact_Non_Exact_Scenario_Score__c = null,                
            EICS_ID__c = 'ABC123',
            EPIC_ID__c = 'ABC123',
            Exact_Match_Account__c = null,
            Exact_Match_Contact__c = null,
            Gender__c = 'Male',
            Graduation_Date__c = Date.parse('1/1/2000'),
            Institution_Address__c = '123 Main Street',
            Institution_City__c = 'Dallas',
            Institution_Country_Code__c = 'US',
            Institution_ID__c = 'ABC123',
            Institution_Name__c = TEST_SCHOOL,
            Institution_Postal_Code__c = '75001',
            Institution_State_Code__c = 'TX',
            Is_EICS__c = false,
            Is_EPIC__c = false,
            Is_USMLE__c = false,
            Last_Name__c = 'User1',
            Medschool_Code__c = 'ABC123',
            Medschool_Name__c = TEST_SCHOOL,
            Previous_Last_Name__c = 'Previous Last1',
            Previous_Rest_of_Name__c = 'Previous First1',
            Request_Id__c = 'ABC123',
            Request_Type__c = 'Test Request',
            Residence_Country__c = 'Nepal',
            Rest_of_Name__c = 'Test1',
            Sender__c = 'FSMB',
            Status__c = Constants.VERIFICATION_REQUEST_STATUS_PENDING,
            University_Code__c = 'ABC123',
            University_Name__c = TEST_SCHOOL,
            Urgent__c = false,
            USMLE_ID__c = 'ABC123'
        );
        insert vr;
        System.assert(vr.Id!=null, 'Verification Request is not created'); 
        Contact cnt = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Generational_Suffix__c ='Jr',
            Birthdate = Date.parse('1/1/1970') ,
            Gender__c = 'Male',
            Citizenship_at_Birth__c = 'Nepal',
            Current_Citizenship__c = 'Nepal',
            Email ='abcd@gmail.com',
            USMLE_ID__c = '0000001',
            Medschool_Code__c = '555555', 
            Previous_Last_Name__c = 'Doe1',
            Previous_Rest_of_Name__c = 'Jon'
        );
        insert cnt;
        system.assert(cnt.Id!=null, 'Contact is not created'); 
        case nCase = new Case(
            Verification_Request__c = vr.Id,
            ContactId = cnt.Id,
            RecordTypeId = RecordTypeUtility.getRecordTypeIdByName('Case', Constants.CASE_RECORD_TYPE_CREDENTIAL_REVIEW),
            External_Close_Comments__c = 'This is case comment'
        );
        insert nCase;
        System.assert(nCase.Id!=null, 'Case is not created'); 
		List<Asset> assetList = new List<Asset>();
        string nameOnDoc = 'John Doe';
        string filename = 'test1.pdf';
        string status = 'Sent';
        Asset nAssest = new Asset(
            Case__c = nCase.Id, 
            ContactId = cnt.Id, 
            Name_on_Document__c = 'John Doe1', 
            Azure_Storage_URL__c = AZURE_STORAGE_URL,
            Filename__c = 'test1.pdf',
            Status = 'Sent',
            Type__c = 'Final Medical School Transcript',
            Name = 'Final Medical School Transcript'
        );
        Asset nAssest1 = new Asset(
            Case__c = nCase.Id, 
            ContactId = cnt.Id, 
            Name_on_Document__c = nameOnDoc, 
            Azure_Storage_URL__c = AZURE_STORAGE_URL,
            Filename__c = filename,
            Status = status,
            Type__c = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA,
            Name = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA
        );
        Asset nAssest2 = new Asset(
            Case__c = nCase.Id, 
            ContactId = cnt.Id, 
            Name_on_Document__c = nameOnDoc, 
            Azure_Storage_URL__c = AZURE_STORAGE_URL,
            Filename__c = filename,
            Status = status,
            Type__c = Constants.ASSET_TYPE_DEAN_LETTER,
            Name = Constants.ASSET_TYPE_DEAN_LETTER
        );
		Asset nAssest3 = new Asset(
            Case__c = nCase.Id, 
            ContactId = cnt.Id, 
            Name_on_Document__c = nameOnDoc, 
            Azure_Storage_URL__c = AZURE_STORAGE_URL,
            Filename__c = filename,
            Status = status,
            Type__c = 'Pregraduate Internship Credential',
            Name = 'Pregraduate Internship Credential'
        );
        Asset nAssest4 = new Asset(
            Case__c = nCase.Id, 
            ContactId = cnt.Id, 
            Name_on_Document__c = nameOnDoc, 
            Azure_Storage_URL__c = AZURE_STORAGE_URL,
            Filename__c = filename,
            Status = status,
            Type__c = 'Internship Certificate Post Diploma',
            Name = 'Internship Certificate Post Diploma'
        );
        Asset nAssest5 = new Asset(
            Case__c = nCase.Id, 
            ContactId = cnt.Id, 
            Name_on_Document__c = nameOnDoc, 
            Azure_Storage_URL__c = AZURE_STORAGE_URL,
            Filename__c = filename,
            Status = status,
            Type__c = 'Medical Registration Certificate/License to Practice Medicine',
            Name = 'Medical Registration Certificate/License to Practice Medicine'
        );
        Asset nAssest6 = new Asset(
            Case__c = nCase.Id, 
            ContactId = cnt.Id, 
            Name_on_Document__c = nameOnDoc, 
            Azure_Storage_URL__c = AZURE_STORAGE_URL,
            Filename__c = filename,
            Status = status,
            Type__c = 'Postgraduate Medical Education Credential',
            Name = 'Postgraduate Medical Education Credential'
        );
        Asset nAssest7 = new Asset(
            Case__c = nCase.Id, 
            ContactId = cnt.Id, 
            Name_on_Document__c = nameOnDoc, 
            Azure_Storage_URL__c = AZURE_STORAGE_URL,
            Filename__c = filename,
            Status = status,
            Type__c = 'Student Medical School Transcript',
            Name = 'Student Medical School Transcript'
        );
        assetList.add(nAssest);
        assetList.add(nAssest1);
        assetList.add(nAssest2);
        assetList.add(nAssest3);
        assetList.add(nAssest4);
        assetList.add(nAssest5);
        assetList.add(nAssest6);
        assetList.add(nAssest7);
        insert assetList; 
        System.assert(assetList[0].Id != null, 'Asset is not created');
    }
    @isTest
    static void testGetVerificationRequest(){
        string corId = CORRELATION_ID; 
        try{
            VerificationStatusHelper.getVerificationStatus('FSMB');
            VerificationStatusResponse vsr = VerificationStatusHelper.getVeficationRequest(corId); 
            string preName = vsr.applicant.previousLastName; 
            System.assertEquals('Doe1', preName, 'Verification request object is good'); 
        }
        catch (Exception e){
            throw e; 
        }
    }
    @isTest
    static void testgetVerificationStatus(){
        List<Verification_Request__c> vr = VerificationStatusHelper.getVerificationRequestStatusBySource('FSMB'); 
        System.assertEquals(1, vr.size(), 'Verification request status by source is good');
    }
    @isTest
    static void testUpdateVerificationRequestPositive(){
        string corId = CORRELATION_ID;
        Verification_Request__c vr = VerificationStatusHelper.updateVeficationRequest(corId); 
        System.assertEquals('Downloaded', vr.Status__c, ' Update Verification request status is good');
    }
    @isTest
    static void testgetCaseByVerifRequestIdPositive(){
        string corId = CORRELATION_ID; 
        list<Verification_Request__c> lvr = VerificationStatusHelper.getVeficationRequestByCorrelationId(corId);    
        string reqId = lvr[0].Id;
        List<Case> listCase  = VerificationStatusHelper.getCaseByVerifRequestId(reqId); 
        System.assertEquals(1,listCase.size(), 'getCaseByVerifRequestId is good');
    }
    @isTest
    static void testGetVerificationRequestTestFinalTransacript(){
        string corId = CORRELATION_ID; 
        try{
            VerificationStatusResponse vsr = VerificationStatusHelper.getVeficationRequest(corId); 
            System.assertEquals(AZURE_STORAGE_URL, vsr.Credentials.finalMedSchoolTranscript[0].verificationFile, 'Verification-final transcript  object is good'); 
        }
        catch (Exception e){
            throw e; 
        }
    }
    @isTest
   	static void testParse(){
		String json = '[{'+
		''+
		'"applicant": {'+
		''+
		'"lastName": "Doe",'+
		''+
		'"restOfName": "John",'+
		''+
		'"generationalSuffix": "Sr.",'+
		''+
		'"dateOfBirth": "2001-11-13T00:00:00+00:00",'+
		''+
		'"gender": "male",'+
		''+
		'"citizenshipAtBirth": "Australia",'+
		''+
		'"residenceCountry": "Australia",'+
		''+
		'"email": "John@Doe.com",'+
		''+
		'"isUSMLE": "true",'+
		''+
		'"USMLEId": "08444135",'+
		''+
		'"isEICS": "true",'+
		''+
		'"EICSId": "08444123",'+
		''+
		'"ECFMGId": "abcd-23984723-asdf09sdf809-0sd0f98sdf",'+
		''+
		'"candidateCode": "234879234873",'+
		''+
		'"degreeMedicalSchoolCode": "023847",'+
		''+
		'"graduationDate": "2007-11-13T00:00:00+00:00",'+
		''+
		'"previousLastName": "Ndo",'+
		''+
		'"previousRestOfName": "Johson",'+
		''+
		'"comments": "Lorem ipsum dolor sit amet consectetur adipiscing elit sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."'+
		''+
		'}'+
		'}]';
        List<VerificationStatusResponse> obj = VerificationStatusResponse.parse(json);
	    System.assert(!obj.isEmpty(),'Parsing failed');
	}
}