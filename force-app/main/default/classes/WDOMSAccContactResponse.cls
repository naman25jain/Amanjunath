public with sharing class WDOMSAccContactResponse {

	public class Payload{
        public String entity;	
        public String subEntity;	
        public String operation;	
        public Cls_payload payload;
    }

	public class Cls_payload {
		public String sf_school_id;	
		public String sf_school_role_assc_id;	
		public String school_role_name;	
		public String sf_school_contact_id;	
		public String contactTitle;	
		public String countryCode;	
		public String msContactTypeCode;	
		public String contact_last_name;	 
		public String contact_rest_of_name;	
		public String contact_generation_suffix;	
		public String contact_title;	
		public String address1;	
		public String address2;	        
		public String address3;	
		public String address4;	
		public String city;	
		public String state_code;	
		public String zip;	
		public String country_code;	
		public String imed_visible_flag;	
		public String ms_contact_type_code;	
		public String msc_degree_type_id;	
		public String update_date;	
	}
}