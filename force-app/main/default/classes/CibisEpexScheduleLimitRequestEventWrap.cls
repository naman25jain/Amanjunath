/*
  Request Event Wrapper for EPEX Schedule Limit Request in CIBIS records : EPEX Schedule Limit Request
*/
public class CibisEpexScheduleLimitRequestEventWrap{
	public String entity;	//exams
	public String subEntity;	//
	public String transactionId;	//c407e88b-fe1c-403c-bf3b-c18147722a93
	public String operation;	//PATCH
	public String USMLEId;	//06361646
	public Integer applicationId;	//21
	public String examType;	//STEP1
	public Payload payload;
	Public class Payload {
		public SchedulingLimit schedulingLimit;
        Public Payload(SchedulingLimit scLimit ){
           schedulingLimit= scLimit;
        }
	}
	Public class SchedulingLimit {
		public String eligibilityStartDate;	//1997-08-01
		public String eligibilityEndDate;	//1998-08-01
		public Integer eligibilityInd;{eligibilityInd=1;}	//1
		public String providerId;	//
		public Integer providerIdInd;{providerIdInd=0;}	//0
		public String regionId;	//
		public Integer regionIdInd;{regionIdInd=0;}	//0
	}
	/*public static CibisEpexScheduleLimitRequestEventWrap parse(String json){
		return (CibisEpexScheduleLimitRequestEventWrap) System.JSON.deserialize(json, CibisEpexScheduleLimitRequestEventWrap.class);
	}*/


}