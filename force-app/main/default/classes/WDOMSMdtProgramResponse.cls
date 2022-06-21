public with sharing class WDOMSMdtProgramResponse {
    
    public class Payload{
        public String entity;	
        public String subEntity;	
        public String operation;
        public Cls_payload payload;
    }
    public class Cls_payload {
        public String sfmdtProgramId;
        public String programName;
        public String yearEst;	//2021-02-16T16:54:55.894Z Datetime
        public String operational;
        public string durationYears;
        public String internshipReq;
        public String socservreq;
        public String eligLocalLic;
        public String curriculumComment;	
        public String publicComment;	
        public String internalComment;	
        public String mdtProgDisciplineTypeCode;	
        public String mdtProgramGenderTypeCode;	
        public String mdtProgramDistEdTypeCode;	
        public String mdtProgramEntExamTypeCode;	
        public String address1;	
        public String address2;	
        public String address3;	
        public String address4;	
        public String city;	
        public String stateCode;	
        public String countryCode;	
        public String zip;	
        public String ecfmgOkFlag;	
        public String mdtFseTypeCode;	
        public String internshipLength;	
        public String socServLength;	
        public String curriculumRevisedYear;
        public String curriculumRevisedMonth;
        public String mdtEducationTypeCode;	
        public String tuitionPaidPortion;	
        public String yearEnd;
        public String interviewReqTypeCode;	
    }
    
}