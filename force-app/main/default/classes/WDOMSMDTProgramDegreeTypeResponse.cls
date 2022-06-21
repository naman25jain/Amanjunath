public with sharing class WDOMSMDTProgramDegreeTypeResponse {
   
    public class Payload{
        public String entity; //MDTProgramDegreeType
        public String subEntity;
        public String operation;
        public Cls_payload payload;
    }
	public class Cls_payload {
		public string sfmdtProgramDegreeTypeId;
		public String mdtProgramDegreeTypeDesc;
		public String degreeAbbreviation;
		public String activeFlag;
		public String englishDegreeTitle;
		public String englishDegreeAbbreviation;
	}
}