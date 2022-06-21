/*
  Request Event Wrapper for USMLE Transcript Eligibility Response in CIBIS : USMLE Transcript Eligibility  Response
*/
public class CibisTranscriptEligResponseEventWrap{
	public String responseStatus;	//SUCCESS
	public String errorDescription;	//
	public String transactionId;	//CIBIS_EXAM_IRREGULAR_BEHAVIOR_EVENT-5003C000006DIhmQAG-0033C00000QkPg6QA
	public Payload payload;
	Public class Payload {
		public String IsNBMEMostRecentlyRegistered;
		public String STEP3Exist;	
		public String SecretariatDocumentUpdateDTime;	//YYYY-MM-DDT12:00:00hh:mm:ss
	}
	/*public static CibisTranscriptEligResponseEventWrap parse(String json){
		return (CibisTranscriptEligResponseEventWrap) System.JSON.deserialize(json, CibisTranscriptEligResponseEventWrap.class);
	} */
}