public with sharing class WDOMSAccountAffiliationResponse {
    public class Payload{
    public String entity; 
    public String subEntity;  
    public String operation;  
    public Cls_payload payload;
        }
    public class Cls_payload {
        public String schoolAffiliationTypeCode;  
        public String schoolAffiliationId;            
        public string sfParentSchoolId;  
        public String sfSchoolId; 
        public String startYear; 
        public String endYear; 
        public String updateDtime;
    }

}