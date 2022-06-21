public class CibisScoreReportResponseEventWrap{
	public String responseStatus;	//SUCCESS
	public cls_errorDescription errorDescription;
	public String transactionId;	//CIBIS_SCORING_DATA-05006w000003FwBEAA0-0036w00000JNwh2
	public Payload payload;
	class cls_errorDescription {
	}
	Public class Payload {
		public CIBISScoringInfo[] cibisScoringInfo;
	}
 Public class CIBISScoringInfo {
		public String SFExamRegExternalId;	//
		public String USMLEId;	//12312312
     	public String resultcode;
     	public String adminOrg;	//NBCT
		public string scoreAvailableDate;	//YYYY-MM-DD
		public String exam;	//
		public String applicationId;	//
		public string scoreReportDate;	//YYYY-MM-DD
		public String passFail;	//
		public String twoDigitScore;	//
		public String threeDigitScore;	//
		public String twoDigitPassingScore;	//
		public String threeDigitPassingScore;	//
		public String examCompletionStatus;	//
		public String actualStartDateExamDate;	//
		public String indeterminateFlag;	//
		public String scoreStatus;	//
		public string lastUpdateDate;	//YYYY-MM-DDTHH:MM:SS
		public String irregularityStatus;	//
		public String scoreAnnotationFlag;	//
		public String scoringTaskId;	//
		public String icePassFail;	//
		public String cisPassFail;	//
		public String sepPassFail;	//
		public String scoreReportDocumentId;	//
		public String examinationRepeatFlag;	//
	}
	/*public static CibisScoreReportResponseEventWrap parse(String json){
		return (CibisScoreReportResponseEventWrap) System.JSON.deserialize(json, CibisScoreReportResponseEventWrap.class);
	}*/
}