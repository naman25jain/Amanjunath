public class PlatformEvent_JSONClass {
	public String AckToken;
	public String CorrelationID;
	public String RawJSONUri;
	public String EnrichedJSONUri;
	public Requester Requester;
	public Applicant Applicant;
	public CandidateCreation CandidateCreation;
	public Documents Documents;
	public Credentials Credentials;

    public class Requester {
		public String Sender;
		public String CreatedDatetime;
	}

	public class Address {
		public String Street;
		public String City;
		public String State;
		public String Country;
		public String PostalCode;
	}

	public class Documents {
		public Release Release;
		public List<Release> Photos;
	}

	public class PostgraduateMedicalEducationCredential {
		public String ExternalDocumentId;
		public String FileName;
		public String FileUri;
		public String NameOnDocument;
		public String DocumentIssueDate;
		public String MedicalSchoolCode;
		public String MedicalSchoolName;
		public Institution Institution;
	}

	public class FinalMedicalDiploma {
		public String ExternalDocumentId;
		public String FileName;
		public String FileUri;
		public String NameOnDocument;
		public String DocumentIssueDate;
		public String MedicalSchoolCode;
		public String MedicalSchoolName;
	}

	public class MedicalLicensure {
		public String ExternalDocumentId;
		public String FileName;
		public String FileUri;
		public String NameOnDocument;
		public String DocumentIssueDate;
		public Institution Institution;
	}

	public class Institution {
		public String ClientInstitutionId;
		public String ECFMGInstitutionId;
		public String InstitutionName;
		public String Comments;
		public Address Address;
	}

	public class Applicant {
		public String LastName;
		public String RestOfName;
		public String GenerationalSuffix;
		public String DateOfBirth;
		public String Gender;
		public String CitizenshipAtBirth;
		public String ResidenceCountry;
		public String Email;
		public Boolean IsUSMLE;
		public String USMLEId;
		public Boolean IsEICS;
		public String EICSId;
		public String ECFMGId;
		public Long CandidateCode;
		public String DegreeMedicalSchoolCode;
		public String GraduationDate;
		public String PreviousLastName;
		public String PreviousRestOfName;
		public String Comments;
	}
    // wrapper object for candidate creation
	public class CandidateCreation{
		public String usmleId;
		public String sourceDocumentId;
		public String lastName;
		public String firstName;
		public String middleName;
		public String restOfName;
		public String generationSuffix;
		public String gender;
		public String dateOfBirth;
		public String ssn;
		public String schoolId;
		public String graduationYear;
		public String graduationMonth;
		public String schoolStartYear;
		public String schoolStartMonth;
		public String schoolCountryId;
		public String nid;
		public String nidCountryId;
		public String deceasedDate;
		public String deceasedFlag;
		public String emailAddress;
	}

	public class Release {
		public String ExternalDocumentId;
		public String FileName;
		public String FileUri;
	}

	public class Credentials {
		public List<FinalMedicalDiploma> FinalMedicalDiploma;
		public List<FinalMedicalDiploma> FinalMedSchoolTranscript;
		public List<FinalMedicalDiploma> StudentMedicalSchoolTranscript;
		public List<FinalMedicalDiploma> AlternateGraduationDocument;
		public List<MedicalLicensure> MedicalLicensure;
		public List<PostgraduateMedicalEducationCredential> PostgraduateMedicalEducationCredential;
		public List<PostgraduateMedicalEducationCredential> InternCertPreDiploma;
		public List<PostgraduateMedicalEducationCredential> InternCertPostDiploma;
	}
	
	public static PlatformEvent_JSONClass parse(String json) {
		return (PlatformEvent_JSONClass) System.JSON.deserialize(json, PlatformEvent_JSONClass.class);
	}
}