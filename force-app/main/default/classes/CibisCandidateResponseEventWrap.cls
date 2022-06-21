//CIBIS
public with sharing class CibisCandidateResponseEventWrap{
     // payload for the response event
    public class Payload{
		public String correlationId{get;set;}
		public String message{get;set;}
	}
    
    //getters/setters for response event
    public String responseStatus{get;set;}
	public string errorDescription{get;set;}	
	public String transactionId{get;set;}
	public Payload payload {get;set;}
	
    /*public static CibisCandidateResponseEventWrap parse(String payload){
		return (CibisCandidateResponseEventWrap) System.JSON.deserialize(payload, CibisCandidateResponseEventWrap.class);
	}*/
}