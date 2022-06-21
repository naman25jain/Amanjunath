//CIBIS
public with sharing class CibisExamRegRequestEventWrap{
    
    public String entity{get;set;}
	public String subEntity{get;set;}
	public String transactionId{get;set;}
	public String operation{get;set;}
	public String USMLEId{get;set;}
	public String field{get;set;}
	public examRegPayload payload{get;set;}

	public class examRegPayload{
		public String USMLEId{get;set;}
		public String exam{get;set;}
		public String examRequestType{get;set;}{examRequestType= 'C';}
		public String examAdmin{get;set;}{examAdmin='';}
		public String lastName{get;set;}
		public String restOfName{get;set;}
		public String firstName{get;set;}
		public String middleName{get;set;}
		public String generationSuffix{get;set;}
		public String reportName{get;set;}{reportName='';}
		public String gender{get;set;}
		public String dateOfBirth{get;set;}
		public String address1{get;set;}
		public String address2{get;set;}{address2='';}
		public String address3{get;set;}{address3='';}
		public String address4{get;set;}
		public String city{get;set;}
		public String state{get;set;}
		public String zip{get;set;}
		public String countryId{get;set;}{countryId='099';}
		public String ethnics{get;set;}{ethnics='';}
		public String citizenshipCountryId{get;set;}{citizenshipCountryId='';}
		public String schoolId{get;set;}{schoolId='';}
		public String schoolStartDate{get;set;}{schoolStartDate='1998-01-01';}
		public String schoolEndDate{get;set;}{schoolEndDate='1998-01-01';}
		public String eligibilityStartDate{get;set;}
		public String eligibilityEndDate{get;set;}
		public Integer medicalSpecialtyId{get;set;}{medicalSpecialtyId=10;}
		public String hospitalId{get;set;}{hospitalId='';}
		public String residencyType{get;set;}{residencyType='';}
		public String residencyStartDate{get;set;}{residencyStartDate='1900-01-01';}
		public String residencyEndDate{get;set;}{residencyEndDate='1900-01-01';}
		public String englishNativeFlag{get;set;}
		public String dominateHand{get;set;}{dominateHand='L';}
		public String registrationStatus{get;set;}{registrationStatus='C';}
		public String proctorAttentionFlag{get;set;}{proctorAttentionFlag='Y';}
		public String sponsorAuthorityId{get;set;}{sponsorAuthorityId='';}
		public String assignedCenterId{get;set;}{assignedCenterId='';}
		public String assignedFacilityId{get;set;}{assignedFacilityId='';}
		public String providerId{get;set;}{providerId='';}
		public String regionId{get;set;}{regionId='';}
		public String accommodationRequestFlag{get;set;}
		public String SSN{get;set;}{SSN='';}
		public String daytimePhone{get;set;}{daytimePhone='';}
		public String emailAddress{get;set;}
		public String requestRecordId{get;set;}{requestRecordId='c';}
		public String requestedLocationId{get;set;}{requestedLocationId='';}
		public String requestedExamMonth{get;set;}{requestedExamMonth='';}
		public String registrationId{get;set;}{registrationId='';}
	}
}