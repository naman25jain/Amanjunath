//CIBIS
public with sharing class CibisRegChangeResponseEventWrap {
    public String responseStatus{get;set;}
    public String errorDescription{get;set;}	
    public String transactionId{get;set;}
    public regionPayload regionPayload {get;set;}
    public class regionPayload{		
        public String CorrelationID{get;set;}
        public String status{get;set;}
    }   
    
    /*public static CibisRegChangeResponseEventWrap parse(String payload){
        return (CibisRegChangeResponseEventWrap) System.JSON.deserialize(payload, CibisRegChangeResponseEventWrap.class);
    }*/
}