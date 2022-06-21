/*
  Response Event Wrapper for EPEX Eligibility Revision Request in CIBIS records : EPEX Eligibility Revision Response
*/
public with sharing class CibisEpexEligRevisionResponseEventWrap{
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
    
    /*public static CibisEpexEligRevisionResponseEventWrap parse(String payload){
        return (CibisEpexEligRevisionResponseEventWrap) System.JSON.deserialize(payload, CibisEpexEligRevisionResponseEventWrap.class);
    }*/
}