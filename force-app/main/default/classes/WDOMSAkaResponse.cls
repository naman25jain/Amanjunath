public with sharing class WDOMSAkaResponse {
    public class Payload{
        public String entity;
        public String subEntity;
        public String operation;
        public String trackingId;
        public Cls_payload payload;
    }
	public class Cls_payload {
		public String akaName;		
		public String sfakaId;
		public String officialFormerNameFlag;
		public String akaEffectiveFromYear;
		public String akaEffectiveToYear;
		public String sfschoolId;
		public String language;
	}
}