public with sharing class WDOMSAccContactInfoResponse {

    public class Payload{
        public String entity;	
        public String subEntity;	
        public String operation;	
        public Cls_payload payload;
    }
    public class Cls_payload {
            public String sfSchoolContactInfoId;	
            public String contactTypeCode;	
            public String contactData;	
            public String description;	
            public string sfschoolId;	            
    }
}