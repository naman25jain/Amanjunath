/*
  Response Event Wrapper for EPEX Evaluation Response in CIBIS records : EPEX Evaluation Response Response
*/
public with sharing class CibisEpexEvaluationResponseEventWrap{
    // payload for the response event
    public class Payload{
        public string candidateExistInCIBIS{get;set;}
        public string otherOpenRegistration{get;set;}
        public string covertValue{get;set;}
        public string outcomeRecievedValue{get;set;}
        public string currentExamHasOpenRegistration{get;set;}
    }
    
    //getters/setters for response event
    public String responseStatus{get;set;}
    public String errorDescription{get;set;}	
    public String transactionId{get;set;}
    public Payload payload {get;set;}
    
    /*public static CibisEpexEvaluationResponseEventWrap parse(String payload){
        return (CibisEpexEvaluationResponseEventWrap) System.JSON.deserialize(payload, CibisEpexEvaluationResponseEventWrap.class);
    }*/
}