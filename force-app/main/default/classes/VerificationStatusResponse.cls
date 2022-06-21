public class VerificationStatusResponse{
	public cls_applicant applicant;
	public cls_Credentials Credentials;
	public class cls_applicant{
		public String lastName;	//Doe
		public String restOfName;	//John
		public String generationalSuffix;	//Sr.
		public String dateOfBirth;	//2001-11-13T00:00:00+00:00
		public String gender;	//male
		public String citizenshipAtBirth;	//Australia
		public String residenceCountry;	//Australia
		public String email;	//John@Doe.com
		public String isUSMLE;	//true
		public String USMLEId;	//08444135
		public String isEICS;	//true
		public String EICSId;	//08444123
		public String ECFMGId;	//abcd-23984723-asdf09sdf809-0sd0f98sdf
		public String candidateCode;	//234879234873
		public String degreeMedicalSchoolCode;	//023847
		public String graduationDate;	//2007-11-13T00:00:00+00:00
		public String previousLastName;	//Ndo
		public String previousRestOfName;	//Johson
		public String comments;	//Lorem ipsum dolor sit amet consectetur adipiscing elit sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
	}
	public class cls_Credentials{
		public cls_finalMedicalDiploma[] finalMedicalDiploma;
		public cls_finalMedSchoolTranscript[] finalMedSchoolTranscript;
		public cls_studentMedicalSchoolTranscript[] studentMedicalSchoolTranscript;
		public cls_alternateGraduationDocument[] alternateGraduationDocument;
		public cls_medicalLicensure[] medicalLicensure;
		public cls_postgraduateMedicalEducationCredential[] postgraduateMedicalEducationCredential;
		public cls_internCertPreDiploma[] internCertPreDiploma;
		public cls_internCertPostDiploma[] internCertPostDiploma;
	}
	public class cls_finalMedicalDiploma{
		public String externalDocumentId;	//PDF_234240
		public String fileName;	//FinalMedicalDiploma.pdf
		public String nameOnDocument;	//John Doe
		public String actionDate;	//2007-11-13T00:00:00+00:00
		public String actionType;	//RECEIVED
		public String verificationDate;	//2007-11-13T00:00:00+00:00
		public String documentStatus;	//pass
		public String medicalSchoolCode;	//690003
		public String eVerify;	//Yes | No
		public String institutionId;	//4339
		public String originalFile;	//programmatic-account-establishment-raw+FinalMedicalDiploma_e676c439-3cf3-4c24-b7cb-4ce6873117ef_81dbf880-2f53-11eb-b321-06762a4c8d6c.pdf
		public String verificationFile;	//verification-artifacts+FinalMedicalDiploma_e676c439-3cf3-4c24-b7cb-4ce6873117ef_81dbf880-2f53-11eb-b321-06762a4c8d6c.pdf
	}
	public class cls_finalMedSchoolTranscript{
		public String externalDocumentId;	//PDF_234241
		public String fileName;	//FinalMedSchoolTranscript.pdf
		public String nameOnDocument;	//John Doe
		public String actionDate;	//2007-11-13T00:00:00+00:00
		public String actionType;	//RECEIVED
		public String verificationDate;	//2007-11-13T00:00:00+00:00
		public String documentStatus;	//pass
		public String medicalSchoolCode;	//690003
		public String eVerify;	//No
		public String institutionId;	//4339
		public String originalFile;	//programmatic-account-establishment-raw+FinalMedSchoolTranscript_4346c5e3-0cc3-46ee-a255-4d5895728476_81dbf880-2f53-11eb-b321-06762a4c8d6c.pdf
		public String verificationFile;	//verification-artifacts+FinalMedSchoolTranscript_4346c5e3-0cc3-46ee-a255-4d5895728476_81dbf880-2f53-11eb-b321-06762a4c8d6c.pdf
	}
	public class cls_studentMedicalSchoolTranscript{
		public String externalDocumentId;	//PDF_234242
		public String fileName;	//StudentMedicalSchoolTranscript.pdf
		public String nameOnDocument;	//John Doe
		public String actionDate;	//2007-11-13T00:00:00+00:00
		public String actionType;	//RECEIVED
		public String verificationDate;	//2007-11-13T00:00:00+00:00
		public String documentStatus;	//pass
		public String medicalSchoolCode;	//690003
		public String eVerify;	//Yes
		public String institutionId;	//4339
		public String originalFile;	//programmatic-account-establishment-raw+StudentMedicalSchoolTranscript_6eaa7b6c-d9b5-4939-9dbf-912b48911fa6_81dbf880-2f53-11eb-b321-06762a4c8d6c.pdf
		public String verificationFile;	//verification-artifacts+StudentMedicalSchoolTranscript_6eaa7b6c-d9b5-4939-9dbf-912b48911fa6_81dbf880-2f53-11eb-b321-06762a4c8d6c.pdf
	}
	public class cls_alternateGraduationDocument{
		public String externalDocumentId;	//PDF_234243
		public String fileName;	//AlternateGraduationDocument.pdf
		public String nameOnDocument;	//John Doe
		public String actionDate;	//2007-11-13T00:00:00+00:00
		public String actionType;	//RECEIVED
		public String verificationDate;	//2007-11-13T00:00:00+00:00
		public String documentStatus;	//pass
		public String medicalSchoolCode;	//690003
		public String eVerify;	//No
		public String institutionId;	//4339
		public String originalFile;	//programmatic-account-establishment-raw+AlternateGraduationDocument_4a5e5b9b-0764-457c-b669-3e5eb3e9ac5c_81dbf880-2f53-11eb-b321-06762a4c8d6c.pdf
		public String verificationFile;	//verification-artifacts+AlternateGraduationDocument_4a5e5b9b-0764-457c-b669-3e5eb3e9ac5c_81dbf880-2f53-11eb-b321-06762a4c8d6c.pdf
	}
	public class cls_medicalLicensure{
		public String externalDocumentId;	//PDF_234244
		public String fileName;	//JohnMedicalLicense.pdf
		public String nameOnDocument;	//John Doe
		public String actionDate;	//2007-11-13T00:00:00+00:00
		public String actionType;	//RECEIVED
		public String verificationDate;	//2007-11-13T00:00:00+00:00
		public String documentStatus;	//pass
		public String medicalSchoolCode;	//690003
		public String eVerify;	//No
		public String institutionId;	//4339
		public String originalFile;	//programmatic-account-establishment-raw+JohnMedicalLicense_b226536c-f685-4467-83d3-d1aee9a390f3_81dbf880-2f53-11eb-b321-06762a4c8d6c.pdf
		public String verificationFile;	//verification-artifacts+JohnMedicalLicense_b226536c-f685-4467-83d3-d1aee9a390f3_81dbf880-2f53-11eb-b321-06762a4c8d6c.pdf
	}
	public class cls_postgraduateMedicalEducationCredential{
		public String externalDocumentId;	//PDF_234245
		public String fileName;	//PostgraduateMedicalEducationCredential.pdf
		public String nameOnDocument;	//John Doe
		public String actionDate;	//2007-11-13T00:00:00+00:00
		public String actionType;	//RECEIVED
		public String verificationDate;	//2007-11-13T00:00:00+00:00
		public String documentStatus;	//pass
		public String medicalSchoolCode;	//690003
		public String eVerify;	//No
		public String institutionId;	//4339
		public String originalFile;	//programmatic-account-establishment-raw+PostgraduateMedicalEducationCredential_2dadf5ca-e9e4-4fe7-8c92-1599f6cd6743_81dbf880-2f53-11eb-b321-06762a4c8d6c.pdf
		public String verificationFile;	//verification-artifacts+PostgraduateMedicalEducationCredential_2dadf5ca-e9e4-4fe7-8c92-1599f6cd6743_81dbf880-2f53-11eb-b321-06762a4c8d6c.pdf
	}
	public class cls_internCertPreDiploma{
		public String externalDocumentId;	//PDF_234246
		public String fileName;	//InternCertPreDiploma.pdf
		public String nameOnDocument;	//John Doe
		public String actionDate;	//2007-11-13T00:00:00+00:00
		public String actionType;	//RECEIVED
		public String verificationDate;	//2007-11-13T00:00:00+00:00
		public String documentStatus;	//pass
		public String medicalSchoolCode;	//690003
		public String eVerify;	//No
		public String institutionId;	//4339
		public String originalFile;	//programmatic-account-establishment-raw+InternCertPreDiploma_50d1f159-92fa-4871-9d19-b47fe303ae34_81dbf880-2f53-11eb-b321-06762a4c8d6c.pdf
		public String verificationFile;	//verification-artifacts+InternCertPreDiploma_50d1f159-92fa-4871-9d19-b47fe303ae34_81dbf880-2f53-11eb-b321-06762a4c8d6c.pdf
	}
	public class cls_internCertPostDiploma{
		public String externalDocumentId;	//PDF_234247
		public String fileName;	//InternCertPostDiploma.pdf
		public String nameOnDocument;	//John Doe
		public String actionDate;	//2007-11-13T00:00:00+00:00
		public String actionType;	//RECEIVED
		public String verificationDate;	//2007-11-13T00:00:00+00:00
		public String documentStatus;	//pass
		public String medicalSchoolCode;	//690003
		public String eVerify;	//No
		public String institutionId;	//4339
		public String originalFile;	//programmatic-account-establishment-raw+InternCertPostDiploma_c1b89feb-62f2-43ad-ae28-854e64c9321c_81dbf880-2f53-11eb-b321-06762a4c8d6c.pdf
		public String verificationFile;	//verification-artifacts+InternCertPostDiploma_c1b89feb-62f2-43ad-ae28-854e64c9321c_81dbf880-2f53-11eb-b321-06762a4c8d6c.pdf
	}
    public static List<VerificationStatusResponse> parse(String json){
		return (List<VerificationStatusResponse>) System.JSON.deserialize(json, List<VerificationStatusResponse>.class);
	}
}