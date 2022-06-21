/**
 * Sampath Karnati 
 * * Online Notary Transaction Response Event Schema Object
 * ? Exposed as Public
 */
public class NotaryTransactionResponseEvent {

    // Data with session links and transaction details
        public class Data {
            public String status { get;set; }
            public List<SigningViews> signingViews { get;set; }
            public List<Documents> documents { get;set; }
             public String  transactionId {get; set;}            
             public Boolean archived { get;set; } {archived = false;  }
             public String department { get; set; }
             public List<Participant>  participants { get; set; }
        }

        public class Documents {
            public String devNotaryLink { get;set; }
        }

        public class SigningViews {
            public String deepLink { get;set; }
            public String txnId { get;set; }
        }
 
        public class Participant{
            public String role{ get;set; }
            public String redirectUrl { get;set; }
            public String roomUrl { get;set; }
            public Person user { get; set; }
        }

        public class  Person{
            public String firstName { get; set; }
            public String lastName { get; set; }
            public String email { get; set; }
            public Address address{ get; set; }
        }
        
        public class  Address{
            public String country { get; set; }
            public String street { get; set; }
            public String city { get; set; }
            public String state{ get; set; }
            public String postalCode{ get; set; }
        }
    
     public String message { get;set; }
     public Data data { get;set; }   
     public String caseId { get;set; }
     public String responseStatus { get;set; }
     public String errorDescription { get;set; }
     public String apiVersion { get;set; }


}