public with sharing class WDOMSMDTProgramDegreeResponse {
    public class Payload{
        public String entity;   //MDTProgramDegree
        public String subEntity;
        public String operation;
        public Cls_payload payload;
    }
    public class Cls_payload {
        public string sfmdtProgramId;
        public string sfmdtProgramDegreeId;
        public string sfmdtProgramDegreeTypeId;
        public string issuedBy;
    }
}