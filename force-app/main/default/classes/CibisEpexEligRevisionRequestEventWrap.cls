/*
  Request Event Wrapper for EPEX Eligibility Revision Request in CIBIS records : EPEX Eligibility Revision Request
*/
public with sharing class CibisEpexEligRevisionRequestEventWrap{
	public String entity{get;set;}
	public String subEntity{get;set;}
	public String transactionId{get;set;}
	public String operation{get;set;}
	public String USMLEId{get;set;}
	public String field{get;set;}
	public epexPayload payload{get;set;}
    
	public class epexPayload {
		public String USMLEId{get;set;}
		public String exam{get;set;}
		public Integer applicationId{get;set;}
		public Integer sourceDocumentId{get;set;}{sourceDocumentId=50;}
		public String addressChangeFlag{get;set;}{addressChangeFlag='';}
		public String address1{get;set;}
		public String address2{get;set;}{address2='';}
		public String address3{get;set;}{address3='';}
		public String address4{get;set;}
		public String city{get;set;}
		public String state{get;set;}
		public String zip{get;set;}
		public String countryId{get;set;}{countryId='';}
		public String reportAddressToCIBIS{get;set;}{reportAddressToCIBIS='Y';}
		public String nameChangeFlag{get;set;}{nameChangeFlag='N';}
		public String lastName{get;set;}
		public String firstName{get;set;}
		public String middleName{get;set;}
		public String restOfName{get;set;}
		public String reportName{get;set;}{reportName='';}
		public String generationSuffix{get;set;}
		public String eligibilityChangedFlag{get;set;}{eligibilityChangedFlag='N';}
		public String eligibilityExtendedFlag{get;set;}{eligibilityExtendedFlag='N';}
		public string providerId{get;set;}{providerId='1';}
		public String regionId{get;set;}{regionId='';}
		public String eligibilityStartDate{get;set;}{eligibilityStartDate='';}
		public String eligibilityEndDate{get;set;}{eligibilityExtendedFlag='';}
	}    
}