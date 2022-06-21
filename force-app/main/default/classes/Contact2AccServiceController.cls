public with sharing class Contact2AccServiceController{
    public Class Contact2AccServiceWrapper{
        @auraenabled public String contactId{get;set;}
        @auraenabled public String roleName{get;set;}
		@auraenabled public String preferrredModeOfCommunication{get;set;}
		@auraenabled public String physicalAddress{get;set;}
		@auraenabled public String listOfEmails{get;set;}
		@auraenabled public String verificationWebsiteURL{get;set;}
        @auraenabled public String credentialType{get;set;}
		@auraenabled public String streetName{get;set;}
        @auraenabled public String cityName{get;set;}
        @auraenabled public String countryName{get;set;}
        @auraenabled public String stateName{get;set;}
        @auraenabled public String postalCode{get;set;}
	}
    @AuraEnabled(Cacheable = false)
	public static String createCnt2AccServiceRecs(String jsonString, String accServiceRecordId){
        Contact2AccServiceWrapper objectList = (Contact2AccServiceWrapper) JSON.deserialize(jsonString, Contact2AccServiceWrapper.class);        
        List<CONTACT2ACCTSERVICE__c> credentialTypeStrList = [SELECT Credential_Type__c 
                                                                FROM CONTACT2ACCTSERVICE__c 
                                                                WHERE Account_Service__c =: accServiceRecordId
                                                                AND Service_Contact__c =: objectList.contactId WITH SECURITY_ENFORCED];
        List<String> credenTypeStrList = new List<String>();
        for(CONTACT2ACCTSERVICE__c con2AccServ : credentialTypeStrList){
            credenTypeStrList.add(con2AccServ.Credential_Type__c);
        }        
        List<String> credentialTypeList = objectList.credentialType.split(',');
        List<CONTACT2ACCTSERVICE__c> contact2AccServiceList = new List<CONTACT2ACCTSERVICE__c>();
        for(String credentialType : credentialTypeList){
            if(credenTypeStrList.contains(credentialType)){
                return credentialType;
            }
            CONTACT2ACCTSERVICE__c conAccServiceObj = new CONTACT2ACCTSERVICE__c();
            conAccServiceObj.Role__c = objectList.roleName;
            conAccServiceObj.Preferred_mode_of_communication__c = objectList.preferrredModeOfCommunication;
            conAccServiceObj.Physical_Address__c = objectList.physicalAddress;
            conAccServiceObj.List_of_emails__c = objectList.listOfEmails;
            conAccServiceObj.Verification_Website_URL__c = objectList.verificationWebsiteURL;
            conAccServiceObj.Credential_Type__c = credentialType;
            conAccServiceObj.Account_Service__c = accServiceRecordId;
            conAccServiceObj.Service_Contact__c = objectList.contactId;
            conAccServiceObj.Active__c = true;
            conAccServiceObj.Street__c = objectList.streetName;
            conAccServiceObj.City__c = objectList.cityName;
            conAccServiceObj.Country__c = objectList.countryName;
            conAccServiceObj.State__c = objectList.stateName;
            conAccServiceObj.Postal_Code__c = objectList.postalCode;
            contact2AccServiceList.add(conAccServiceObj);
        }        
        if(!contact2AccServiceList.isEmpty() && CONTACT2ACCTSERVICE__c.SObjectType.getDescribe().isCreateable()){
            insert contact2AccServiceList;
        }
        return 'true';
    }
    @AuraEnabled(cacheable = true)
    public static List<Contact> findRecords(String searchKey){
        List<Contact> contactListReturned = new List<Contact>();
        if(String.isnotBlank(searchKey)){
            String keyValue = '%' + searchKey + '%';
            List<Contact> contactList = new List<Contact>([SELECT Id,RecordType.DeveloperName,Name FROM Contact WHERE (Name LIKE :keyValue OR FirstName LIKE :keyValue OR LastName LIKE :keyValue OR MiddleName LIKE :keyValue) LIMIT 100]);
            for(Contact con : contactList){
                contactListReturned.add(con);
            }
        }
        return contactListReturned;
    }
}