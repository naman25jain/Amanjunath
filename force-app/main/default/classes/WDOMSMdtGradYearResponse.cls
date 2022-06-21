public with sharing class WDOMSMdtGradYearResponse {    
    public class Payload{
        public String entity;	
        public String subEntity;
        public String operation;
        public Cls_payload payload;
    }
    Public class Cls_payload {
        public String medSchoolCode;
        public String gradYear;
        public String yearOkFlag;
        public String medDegreeName; 
        public String medLicName;
    }        
}