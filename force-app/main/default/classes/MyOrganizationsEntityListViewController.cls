public with sharing class MyOrganizationsEntityListViewController{
	@AuraEnabled(Cacheable = false)
	public static Id getContact(String userId){
		User uId = [SELECT Id, ContactId FROM User WHERE Id = : userId WITH SECURITY_ENFORCED];
		Id getContactId = uId.contactId;
		return getContactId;
	}
    //My Organizations
    @AuraEnabled(cacheable = false)
    public static List<MyOrganizationsEntityListViewHelper.MyOrgWrapper> getMyOrganizations(String currentEntityContactId){
        List<Contact> currentUser = new List<Contact>();
        Id cID =  AppForCertHelper.retrieveCurrentContactId();
        currentUser = [SELECT Id, FirstName, LastName, AccountId FROM Contact WHERE Id =: CID WITH SECURITY_ENFORCED];  
        List<MyOrganizationsEntityListViewHelper.MyOrgWrapper> myOrganizations = new List<MyOrganizationsEntityListViewHelper.MyOrgWrapper>();
        List<Contact> entityContactList = new List<Contact>();        
        entityContactList = [SELECT Id, Name, AccountId, Account.Name, Account.Country__c, Account.BillingAddress, 
                            Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingCountry, 
                            Account.BillingPostalCode,Account.LastModifiedDate 
                            FROM Contact WHERE Id = : currentEntityContactId AND Account.Type != 'Household' AND 
                            Community_My_Contact__c = true WITH SECURITY_ENFORCED];  
        if(!entityContactList.isEmpty()){
                        
            myOrganizations = getMyOrganizationsList(entityContactList,currentUser[0]);            
        }
        return myOrganizations;        
    }
    public static List<MyOrganizationsEntityListViewHelper.MyOrgWrapper> getMyOrganizationsList(List<Contact> entityContacts, Contact currentUser){       
        List<MyOrganizationsEntityListViewHelper.MyOrgWrapper> returnValue = new List<MyOrganizationsEntityListViewHelper.MyOrgWrapper>();        
        if(!entityContacts.isEmpty()){
            for(Contact entityContact : entityContacts){     
                String orgName = entityContact.Account.Name;
                String conId = entityContact.Id;                     
                String orgCountry = entityContact.Account.Country__c;
                String orgLastModifiedDate = String.valueOf(entityContact.Account.LastModifiedDate);
                String entityId = entityContact.AccountId;
                String entityAddress = '';
                if(entityContact.Account.BillingAddress != NULL){
                    if(entityContact.Account.BillingStreet != NULL){
                        entityAddress += String.valueOf( entityContact.Account.BillingStreet) ;
                    }
                    if(entityContact.Account.BillingCity != NULL){
                        entityAddress += ', ' + String.valueOf( entityContact.Account.BillingCity);
                    }
                    if(entityContact.Account.BillingState != NULL){
                        entityAddress += ', ' + String.valueOf( entityContact.Account.BillingState);
                    }
                    if(entityContact.Account.BillingCountry != NULL){
                        entityAddress += ', ' + String.valueOf( entityContact.Account.BillingCountry);
                    }
                    entityAddress = entityAddress.removeStart(',');
                }
                String orgAddress = entityAddress;
                Map<String,String> eData = new Map<String,String>();
                eData.put('entityIdVal',entityId);
                eData.put('entityConIdVal',conId);
                eData.put('orgNameVal',orgName);
                eData.put('orgCountryVal',orgCountry);
                eData.put('orgAddressVal',orgAddress);
                eData.put('orgLastModifiedDateVal',orgLastModifiedDate);
                MyOrganizationsEntityListViewHelper.MyOrgWrapper evWrap = new MyOrganizationsEntityListViewHelper.MyOrgWrapper(eData, entityId, orgName, orgCountry, orgAddress, orgLastModifiedDate, conId);
                returnValue.add(evWrap);                            
            }
        }        
        return returnValue;
    }
    //My Cases
    @AuraEnabled(cacheable = false)
    public static List<MyOrganizationsEntityListViewHelper.myCasesWrapper> getMyCases(String currentEntityContactId){
        List<Contact> currentUser = new List<Contact>();
        Id cID =  AppForCertHelper.retrieveCurrentContactId();
        currentUser = [SELECT Id,FirstName,LastName,AccountId FROM Contact WHERE Id =: CID WITH SECURITY_ENFORCED];  
        List<MyOrganizationsEntityListViewHelper.myCasesWrapper> myCases = new List<MyOrganizationsEntityListViewHelper.myCasesWrapper>();
        List<Case> myCasesList = new List<Case>();        
        myCasesList = [SELECT Id, CaseNumber, Type, AccountId, ContactId, Account.Name, Case_Status__c, CreatedDate, LastModifiedDate 
                            FROM Case WHERE ContactId = : currentEntityContactId AND RecordType.Name =: Constants.CASE_RECORD_TYPE_ENTITY_SERVICE_REQUEST AND 
                            Type =: Constants.CASE_TYPE_ENTITY_DETAILS_CHANGE WITH SECURITY_ENFORCED];                              
        if(!myCasesList.isEmpty()){                        
            myCases = getMyCasesList(myCasesList,currentUser[0]);
        }
        return myCases;
    }
    public static List<MyOrganizationsEntityListViewHelper.MyCasesWrapper> getMyCasesList(List<Case> caseList, Contact currentUser){       
        List<MyOrganizationsEntityListViewHelper.MyCasesWrapper> returnValue = new List<MyOrganizationsEntityListViewHelper.MyCasesWrapper>();        
        if(!caseList.isEmpty()){
            for(Case caseRecord : caseList){                                                    
                String caseId = caseRecord.Id;
                String entityId = caseRecord.AccountId;
                String caseNumber = caseRecord.CaseNumber;
                String caseType = caseRecord.Type;                     
                String caseEntityName = caseRecord.Account.Name;
                String caseStatus = caseRecord.Case_Status__c;
                String caseDateOpened = String.ValueOf(caseRecord.CreatedDate);
                String caseLastModifiedDate = String.ValueOf(caseRecord.LastModifiedDate);
                String caseConId = caseRecord.ContactId;                                
                Map<String,String> caseData = new Map<String,String>();
                caseData.put('caseIdVal',caseId);
                caseData.put('entityIdVal',entityId);
                caseData.put('caseConIdVal',caseConId);
                caseData.put('caseNumberVal',caseNumber);
                caseData.put('caseTypeVal',caseType);
                caseData.put('caseEntityNameVal',caseEntityName);
                caseData.put('caseStatusVal',caseStatus);
                caseData.put('caseDateOpenedVal',caseDateOpened);
                caseData.put('caseLastModifiedDateVal',caseLastModifiedDate);
                MyOrganizationsEntityListViewHelper.MyCasesWrapper evWrap = new MyOrganizationsEntityListViewHelper.MyCasesWrapper(caseData, caseId, entityId, caseNumber, caseType, caseEntityName, caseStatus, caseDateOpened, caseLastModifiedDate, caseConId);
                returnValue.add(evWrap);                            
            }
        }        
        return returnValue;
    }
}