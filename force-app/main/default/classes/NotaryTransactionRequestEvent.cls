/**
 * Sampath Karnati 
 * * Online Notary Transaction Request Event Schema Object
 * ? Exposed as Public
 */
public class NotaryTransactionRequestEvent {
 
    public NotaryTransactionRequestEvent(String caseId, 
                                        String redirectUrl, 
                                        List<Party> parties, 
                                        List<Document> documents,
                                        String apiVersion,
                                        String notaryTransactionId) {
        this.caseId = caseId;
        this.redirectUrl = redirectUrl;
        this.parties = parties;
        this.documents =  documents;
        this.apiVersion = apiVersion; 
        this.notaryTransactionId = notaryTransactionId; 
    }

    // Parties with Biographic Data
        public class Party {
            public String firstName { get;set; }
            public String lastName { get;set; }
            public String email { get;set; }
            public String phone { get;set; }
        }
    // Documents (Name and URL)
        public class Document {
            public String name { get;set; }
            public String url { get;set; }
        }

    // Getters/Setters
        public String caseId { get;set; }

        public String redirectUrl { get;set; }

        public List<Party> parties { get;set; }

        public List<Document> documents { get;set; }

        public String apiVersion { get;set; }

        public String notaryTransactionId { get;set; }

}