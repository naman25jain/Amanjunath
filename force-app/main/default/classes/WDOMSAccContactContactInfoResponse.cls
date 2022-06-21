public with sharing class WDOMSAccContactContactInfoResponse {

    public class Payload{
        public String entity;	
        public String subEntity;	
        public String operation;	
        public Cls_payload[] payload;
    }
    public class Cls_payload {
        public Integer schoolContactId;	
        public String contactTypeCode;	
        public String contactData;	
        public String description;	
        public String SF_mscContactInfoId;	
    }  
}