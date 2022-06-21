public with sharing class MyOrganizationsEntityListViewHelper{
    // Wrapper class to send the entity     
    public class MyOrgWrapper{
        @auraenabled public String entityId { get; set; }        
        @auraenabled public String orgName { get; set; }
        @auraenabled public String orgCountry { get; set; }
        @auraenabled public String orgAddress { get; set; }
        @auraenabled public String orgLastModifiedDate { get; set; }        
        @auraenabled public String entityConId { get; set; }
        public myOrgWrapper(Map<String,String> eData,String entityIdVal,String orgNameVal,String orgCountryVal,String orgAddressVal,String orgLastModifiedDateVal,String entityConIdVal){
            entityId = eData.get('entityIdVal');
            orgName = eData.get('orgNameVal');
            orgCountry = eData.get('orgCountryVal');
            orgAddress = eData.get('orgAddressVal');
            orgLastModifiedDate = eData.get('orgLastModifiedDateVal');            
            entityConId = entityConIdVal;
        }
    } 
    // Wrapper class to send the cases     
    public class MyCasesWrapper{
        @auraenabled public String caseId { get; set; }
        @auraenabled public String entityId { get; set; }
        @auraenabled public String caseNumber { get; set; }
        @auraenabled public String caseType { get; set; }
        @auraenabled public String caseEntityName { get; set; }
        @auraenabled public String caseStatus { get; set; }
        @auraenabled public String caseDateOpened { get; set; }
        @auraenabled public String caseLastModifiedDate { get; set; }        
        @auraenabled public String caseConId { get; set; }
        public myCasesWrapper(Map<String,String> caseData, String caseIdVal, String entityIdVal,String caseNumberVal,String caseTypeVal,String caseEntityNameVal,String caseStatusVal, String caseDateOpenedVal, String caseLastModifiedDateVal, String caseConIdVal){
            caseId = caseData.get('caseIdVal');
            entityId = caseData.get('entityIdVal');
            caseNumber = caseData.get('caseNumberVal');
            caseType = caseData.get('caseTypeVal');
            caseEntityName = caseData.get('caseEntityNameVal');
            caseStatus = caseData.get('caseStatusVal');
            caseDateOpened = caseData.get('caseDateOpenedVal');
            caseLastModifiedDate = caseData.get('caseLastModifiedDateVal');            
            caseConId = caseConIdVal;
        }
    }    
}