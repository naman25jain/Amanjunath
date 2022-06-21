public with sharing class EntityServiceRequestControllerHelper {
    public EntityServiceRequestControllerHelper() {

    }
    public Class InsertContactandCaseEntityRqeuestWrapper{
		@auraenabled public String finalSelectedRecordId { get; set; }
		@auraenabled public String entityLastName { get; set; }
		@auraenabled public String restOfName { get; set; }
		@auraenabled public String shareWithCoValue { get; set; }
		@auraenabled public String phoneNumber { get; set; }
		
		@auraenabled public String emailAddress { get; set; }
		@auraenabled public String jobTitle { get; set; }
		@auraenabled public String serviceValue { get; set; }
		
		@auraenabled public String department { get; set; }
		@auraenabled public String countryVal { get; set; }
		@auraenabled public String generationalSuffix { get; set; }
		
		@auraenabled public Date dateOfBirth { get; set; }
		@auraenabled public Boolean onlyOneName { get; set; }
		
			
		public InsertContactandCaseEntityRqeuestWrapper(String selectedRecordId, String lastName, String restName, String phoneNo, String emailAdd, String jobTit, String serviceVal,String depart, String countryValue, String generationSuffix, Date dob, Boolean legalNameOnlyOneName) {
		
			finalSelectedRecordId = selectedRecordId;
			entityLastName = lastName;
			restOfName = restName;
			phoneNumber =phoneNo;			
			emailAddress = emailAdd;
			jobTitle =jobTit;
			serviceValue =serviceVal;
			department = depart;
			countryVal = countryValue;
			generationalSuffix = generationSuffix;
			dateOfBirth =dob;
			onlyOneName = legalNameOnlyOneName;
		}
	}
    /* Wrapper class to send Service Access List for an Entity
     */
    public class ServiceAccessWrapper {
        @AuraEnabled public String serviceName { get; set; }
        @AuraEnabled public String isEnrolled { get; set; }
        @AuraEnabled public String hasAccess { get; set; }
		@AuraEnabled public Boolean hideRequestAccess { get; set; }
		@AuraEnabled public Boolean disableRequestAccess { get; set; }

        public ServiceAccessWrapper(String sName, String isEnroll, String hasAcc, Boolean hideAccess, Boolean disableAccess) {
            serviceName = sName;
            isEnrolled = isEnroll;
            hasAccess = hasAcc;
			hideRequestAccess = hideAccess;
			disableRequestAccess = disableAccess;
        }
	}
	
	/* Wrapper class to get contact record to add more service.
     */
	public class ContactDetailsRecordWrapper {
		@auraenabled public string lastName {get;set;}
		@auraenabled public string generationalSuffix {get;set;}
		@auraenabled public string emailAddress {get;set;}
		@auraenabled public string phoneNumber {get;	set;}
		@auraenabled public string department {get;set;}
		@auraenabled public string jobTitle {	get;set;}
        @auraenabled public string restOfName {get;set;}
        @auraenabled public Boolean legalNameConsists {get;set;}

		public ContactDetailsRecordWrapper(String lstName, String generationSuffix, String mailAdress, String phoneNo, String dept, String jobTit, String restName, Boolean legalNameConsistsOneName) {
			lastName = lstName;
			generationalSuffix = generationSuffix;
			emailAddress = mailAdress;
			phoneNumber = phoneNo;
			department = dept;
			jobTitle = jobTit;
            restOfName = restName;
            legalNameConsists = legalNameConsistsOneName;
		}
	}

	/* Wrapper class to get service and role records to add more service.
     */
	public class ServicesRoleWrapper {
		@auraenabled public string serviceName {get;set;}
		@auraenabled public Boolean signatureReq {get;set;}
		@auraenabled public string serviceId {get;set;}

		public ServicesRoleWrapper(String servName, Boolean signatureRequired, String servId) {
			serviceName = servName;
			signatureReq = signatureRequired;
			serviceId = servId;
		}
	}
}