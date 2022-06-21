@isTest
public with sharing class CreateVerificationRequestTest{
    @isTest
    public static void pAeRequestEventHandlerTest(){
        String dateString = String.valueOf(date.newInstance(1990, 11, 21));
        PlatformEvent_JSONClass.Requester req = new PlatformEvent_JSONClass.Requester();
        req.Sender = 'Test Sender';
        req.CreatedDatetime = '12-12-2012 12:12:12';
        PlatformEvent_JSONClass.Address address = new PlatformEvent_JSONClass.Address();
        address.City = 'Da Nang';
        address.Country = 'Vietnam';
        address.PostalCode = '680590';
        address.State = 'Arizona';
        address.Street = '2nd';
        PlatformEvent_JSONClass.Release release = new PlatformEvent_JSONClass.Release();
        release.ExternalDocumentId = '0000235678';
        release.FileName = 'photo';
        release.FileUri = '/testphoto/*';
        PlatformEvent_JSONClass.Documents doc = new PlatformEvent_JSONClass.Documents();
        doc.Release = release;
        List<PlatformEvent_JSONClass.Release> photos = new List<PlatformEvent_JSONClass.Release>();
        photos.add(release);
        doc.Photos = photos;
        PlatformEvent_JSONClass.Institution institution = new PlatformEvent_JSONClass.Institution();
        institution.Address = address;
        institution.ClientInstitutionId = 'inst-1234567';
        institution.Comments = 'Comments';
        institution.InstitutionName = 'Hogwards';
        institution.ECFMGInstitutionId = 'ECFMG Name';
        PlatformEvent_JSONClass.PostgraduateMedicalEducationCredential postgrad = new PlatformEvent_JSONClass.PostgraduateMedicalEducationCredential();
        postgrad.DocumentIssueDate = dateString;
        postgrad.ExternalDocumentId = 'S-128934';
        postgrad.FileName = 'Sample Name';
        postgrad.FileUri = '*/testuri/*';
        postgrad.Institution = institution;
        postgrad.DocumentIssueDate = 'Med School - 1112233';
        postgrad.MedicalSchoolName = 'Med School';
        postgrad.NameOnDocument = 'Applicant';
        PlatformEvent_JSONClass.FinalMedicalDiploma finalDiploma =  new PlatformEvent_JSONClass.FinalMedicalDiploma();
        finaldiploma.DocumentIssueDate = dateString;
        finaldiploma.ExternalDocumentId = 'Ex-213456';
        finaldiploma.FileName = 'final diploma';
        finaldiploma.FileUri = '/diploma/*';
        finaldiploma.MedicalSchoolCode = 'Medical-123445';
        finaldiploma.MedicalSchoolName = 'Diploma school';
        finaldiploma.NameOnDocument = 'Harry Potter';
        PlatformEvent_JSONClass.MedicalLicensure license = new PlatformEvent_JSONClass.MedicalLicensure();
        license.DocumentIssueDate = dateString;
        license.ExternalDocumentId = 'Ex-34578';
        license.FileName = 'license';
        license.FileUri = '/license/';
        license.Institution = institution;
        license.NameOnDocument = 'Hermoine';
        List<PlatformEvent_JSONClass.FinalMedicalDiploma> diplomaList = new List<PlatformEvent_JSONClass.FinalMedicalDiploma>();
        diplomaList.add(finaldiploma);
        List<PlatformEvent_JSONClass.MedicalLicensure> licenses = new List<PlatformEvent_JSONClass.MedicalLicensure>();
        licenses.add(license);
        List<PlatformEvent_JSONClass.PostgraduateMedicalEducationCredential> postgrads = new List<PlatformEvent_JSONClass.PostgraduateMedicalEducationCredential>();
        postgrads.add(postgrad);
        PlatformEvent_JSONClass.Credentials cred = new PlatformEvent_JSONClass.Credentials();
        cred.AlternateGraduationDocument = diplomaList;
        cred.FinalMedicalDiploma = diplomaList;
        cred.FinalMedSchoolTranscript = diplomaList;
        cred.StudentMedicalSchoolTranscript = diplomaList;
        cred.InternCertPostDiploma = postgrads;
        cred.InternCertPreDiploma = postgrads;
        cred.MedicalLicensure = licenses;
        cred.PostgraduateMedicalEducationCredential = postgrads;
        PlatformEvent_JSONClass.Applicant appl = new PlatformEvent_JSONClass.Applicant();
        appl.CitizenshipAtBirth = 'India';
        appl.Comments = 'Comments';
        appl.DateOfBirth = dateString;
        appl.DegreeMedicalSchoolCode = 'DegMed-123455';
        appl.ECFMGId = 'Id-12345';
        appl.EICSId = 'EICS- 123456';
        appl.Email = 'test@test.com';
        appl.Gender = 'Female';
        appl.GenerationalSuffix = 'Jr.';
        appl.GraduationDate = dateString;
        appl.IsUSMLE = true;
        appl.LastName = 'LastName';
        appl.PreviousLastName = 'PLastName';
        appl.PreviousRestOfName = 'PrestName';
        appl.ResidenceCountry = 'United States';
        appl.RestOfName = 'Harry';
        appl.USMLEId = 'USMLE-1234';
        appl.IsEICS = true;
        PlatformEvent_JSONClass json = new PlatformEvent_JSONClass();
        json.AckToken = 'token-12345';
        json.CorrelationID = 'corr-234567';
        json.RawJSONUri = '/rawuri/*';
        json.EnrichedJSONUri = '/enricheduri/*';
        json.Requester = req;
        json.Applicant = appl;
        json.Documents = doc;
        json.Credentials = cred;
        String jsonString = System.JSON.serialize(json);
        Test.startTest();
        PAE_request__e request = new PAE_request__e();
        request.Payload__c = jsonString;
        Database.SaveResult sr = EventBus.publish(request);
        System.assertEquals(true, sr.isSuccess(),'Event publish Failed');
        Test.stopTest();
    }
}