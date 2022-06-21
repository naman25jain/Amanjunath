public with sharing class CibisDupCheckRequestEvent{
   /* public String entity{get;set;}
    public String subEntity{get;set;}
    public String transactionId{get;set;}
    public String operation{get;set;}
    public CibisDupCheckRequestEvent.dupCheckPayload payload{get;set;}
    
    public class dupCheckPayload{
        public String USMLEId{get;set;}
        public String lastName{get;set;}
        public String restOfName{get;set;}
        public String generationSuffix{get;set;}
        public String gender{get;set;}
        public String SSN{get;set;}
        public String medicalSchoolCode{get;set;}
        public String dateOfBirth{get;set;}
        public Integer matchThresholdPercentage{get;set;}
        public Integer maxResultRows{get;set;}
    } */
    
    public String entity;
    public String subEntity;
    public String transactionId;
    public String operation;
    public CibisDupCheckRequestEvent.dupCheckPayload payload;
    
    public class dupCheckPayload{
        public String USMLEId;
        public String lastName;
        public String restOfName;
        public String generationSuffix;
        public String gender;
        public String SSN;
        public String medicalSchoolCode;
        public String dateOfBirth;
        public Integer matchThresholdPercentage;
        public Integer maxResultRows;
    }
}