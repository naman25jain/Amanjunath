/*
  Response Event Wrapper for EPEX Schedule Limit Respone in CIBIS records : EPEX Schedule Limit Response
*/
public class CibisEpexScheduleLimitResponseEventWrap {
    // payload for the response event
    public class epexResPayload{
        public String correlationId{get;set;}
        public String message{get;set;}
    }
    //getters/setters for response event
    public String responseStatus{get;set;}
    public String errorDescription{get;set;}
    public String transactionId{get;set;}
    public epexResPayload payload{get;set;}
    
    /*public static CibisEpexScheduleLimitResponseEventWrap parse(String payload){
        return (CibisEpexScheduleLimitResponseEventWrap) System.JSON.deserialize(payload, CibisEpexScheduleLimitResponseEventWrap.class);
    }*/
}