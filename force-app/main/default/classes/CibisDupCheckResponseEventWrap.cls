/*
  Response Event Wrapper for Cibis Duplicate Applicant records : Search Response
*/
public with sharing class CibisDupCheckResponseEventWrap{
   

	public String responseStatus{get;set;}
	public String errorDescription{get;set;}
	public String transactionId{get;set;}
	public List<dupCheckPayload> payload{get;set;}

	public class dupCheckPayload{
		public String USMLEId{get;set;}
		public String sourceGenerationSuffix{get;set;}
		public String birthMonth{get;set;}
		public String gender{get;set;}
		public String lastName{get;set;}
		public Integer overallMatch{get;set;}
		public String SSN{get;set;}
		public String birthYear{get;set;}
		public String medicalSchoolCode{get;set;}
		public String birthDay{get;set;}
		public String sourceLastName{get;set;}
		public Integer requestId{get;set;}
		public String firstName{get;set;}
		public String sourceRestOfName{get;set;}
	}

    /*public static CibisDupCheckResponseEventWrap parse(String payload){
		return (CibisDupCheckResponseEventWrap) System.JSON.deserialize(payload, CibisDupCheckResponseEventWrap.class);
	}*/
}