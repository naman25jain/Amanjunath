/**
 * Sampath Karnati 
 * * Online Notary Transaction Update Event Schema  Object
 * ? Exposed as Public
 */
public class NotaryTransactionUpdateEvent {

    // Data with status
        public class Data {
            public String status { get;set; }
            public List<Participant>  participants { get; set; }
            public List<Documents> documents { get;set; }
        }

    public Data data { get;set; }
    public String responseStatus { get;set; }
    public String errorDescription { get;set; }
    public String transactionId { get;set; }
    public String azureUrl { get;set; }
    public String roomUrl { get;set; }

    public class Documents {
        public String thumbnailURL { get;set; }
        public String transactionId { get;set; }
        public String name {get;set; }
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
    }
    
}