public with sharing class OFACSearchRequest {
    public OFACSearchRequest(String batchId,List<Party> cases) {
        this.batchId = batchId;
        this.cases = cases;
    }

    // OFAC search case
    public class Party {
        public String name { get;set; }
        public String dob { get;set; } {dob = '';}
        public String citizenship { get;set; } {citizenship = '';}
        public String phoneNumber { get;set; } {phoneNumber = '';}
        public Cls_passport passport{get;set;} 
        public String gender { get;set; } {gender = '';}
        public Cls_Case_Attributes caseAttributes {get;set;}
        public String localId {get;set;}{localId = '';}
        public Cls_Address address {get;set;} 
        public String nationality { get;set; } {nationality = '';}
        public String ssn { get;set; } {ssn = '';}
    }
    
    // VeriScan properties
    public Boolean alias = true;
    public Integer minScore = 80;        
    public Boolean consolidated = true;
    public string [] sources= new String[]{'SDN'};
    public string [] types = new string[]{'Individual'}; 

    public class Cls_passport{
        public String passportNumber {get;set;} {passportNumber='';}
        public String passportCountry{get;set;} {passportCountry='';}
    }

    public class Cls_Address{
        public String address1 {get;set;} {address1 = '';}
        public String address2 {get;set;} {address2 = '';}
        public String address3 {get;set;} {address3 = '';}
        public String address4 {get;set;} {address4 = '';}
        public String city {get;set;} {city = '';}
        public String stateOrProvince {get;set;} {stateOrProvince = '';}
        public String postalCode {get;set; }{postalCode = '';}
        public String country {get;set; }{country = '';}
    }

    public class Cls_Case_Attributes{
        public String generationalSuffix { get;set; } {generationalSuffix = '';}
        public String nationalId { get;set; } {nationalId = '';}
        public String medicalSchoolCode {get;set; }{medicalSchoolCode = '';}
        public String institutionId { get;set; } {institutionId = '';}        
        public String accountType { get;set; } {accountType = '';} 

    }

    // Getters/Setters
    public String batchId { get;set; }
    public List<Party> cases { get;set; }
}