/*
  Request Event Wrapper for Applicant Creation in CIBIS records : Application Creation Request
*/
public with sharing class CibisCandidateRequestEventWrap{
	public String entity{get;set;}
	public String subEntity{get;set;}
	public String transactionId{get;set;}
	public String operation{get;set;}
	public String USMLEId{get;set;}
	public String field{get;set;}
	public candidatePayLoad payload{get;set;}
	
    public class candidatePayLoad{
		public String USMLEId{get;set;}
		public Integer sourceDocumentId{get;set;}{sourceDocumentId=10;}
		public String lastName{get;set;}
		public String firstName{get;set;}
		public String middleName{get;set;}
		public String restOfName{get;set;}
		public String generationSuffix{get;set;}
		public String gender{get;set;}
		public String dateOfBirth{get;set;}
		public String SSN{get;set;}
		public String schoolId{get;set;}
		public String graduationYear{get;set;}
		public String graduationMonth{get;set;}
		public String schoolStartYear{get;set;}
		public String schoolStartMonth{get;set;}
		public String schoolCountryId{get;set;}{schoolCountryId='';}
		public String nid{get;set;}{nid='';}
		public String nidCountryId{get;set;}{nidCountryId='';}
		public String deceasedDate{get;set;}{deceasedDate='';}
		public String emailAddress{get;set;}
	}    
	public static candidatePayLoad parse(String payload){
        return (candidatePayLoad) System.JSON.deserialize(payload, candidatePayLoad.class);
    }
}