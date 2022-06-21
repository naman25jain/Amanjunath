public with sharing class WDOMSSchoolProgramResponse {
    public class Payload {
        public String entity;	
        public String subEntity;	
        public String operation;
        public String trackingId; 
        public cls_payload payload;	
    }
    public class cls_payload{
        public String sfmdtprogramId;	  
        public String sfschoolId;	        
    }
}