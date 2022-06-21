/*
  Request Event Wrapper for USMLE Transcript Eligibility Request in CIBIS : USMLE Transcript Eligibility  Request
*/
public class CibisTranscriptEligRequestEventWrap {

	public String entity;
	public String subEntity;
	public String transactionId;
	public String operation;
	public String USMLEId; //USMLE Id
	public String field;
    
/*	public static CibisTranscriptEligRequestEventWrap parse(String json) {
		return (CibisTranscriptEligRequestEventWrap) System.JSON.deserialize(json, CibisTranscriptEligRequestEventWrap.class);
	} */
}