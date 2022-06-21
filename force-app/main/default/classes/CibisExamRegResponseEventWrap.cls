//CIBIS
public with sharing class CibisExamRegResponseEventWrap{
    // payload for the response event
    public class Payload{
		public string requestRecordId{get;set;}
        public string correlationId{get;set;}
		public string applicationId{get;set;}
	}

    //getters/setters for response event
    public String responseStatus{get;set;}
	public String errorDescription{get;set;}	
	public String transactionId{get;set;}
	public Payload payload {get;set;}
	
    /*public static CibisExamRegResponseEventWrap parse(String payload){
		return (CibisExamRegResponseEventWrap) System.JSON.deserialize(payload, CibisExamRegResponseEventWrap.class);
	} */
}