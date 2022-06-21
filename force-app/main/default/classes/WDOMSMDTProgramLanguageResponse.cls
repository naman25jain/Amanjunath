public with sharing class WDOMSMDTProgramLanguageResponse {

    public class Payload{
        public String entity; //MDTProgramLanguage
        public String subEntity;
        public String operation;
        public Cls_payload payload;
    }
	public class Cls_payload {
        public String language;	
		public String sfmdtProgramId;	
	}
}