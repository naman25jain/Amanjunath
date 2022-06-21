/*
  Response Event Wrapper for Cibis Exam History with Irregular records : Exam History with Irregular Response
*/
public class CibisExamHistoryResponseEventWrap {
    public String responseStatus;	//SUCCESS
    public String errorDescription;	//
    public String transactionId;	//CIBIS_EXAM_IRREGULAR_BEHAVIOR_EVENT-5001700000BvPChAAN-0031700001IZ03VAAT
    public List<Payload> payload;
    
    Public class Payload {
        public String USMLEId;	//53256350
        public String exam;	//STEP1
        public String SFExamRegExternalId;	//STEP2CS
        public String scoreAnnotationFlag;	//N
        public String applicationId;	//                      
        public Integer twoDigitPassingScore;	//75
        public Integer threeDigitPassingScore;	//184
        public Integer twoDigitScore;	//
        public Integer threeDigitScore;	//
        public String actualStartDate;	//Exam taken and actual start date
        public String examStatusCode;	//Pass
        public String scoreAvailableDate;	//
        Public string ScoreReportDate;
        public String lastUpdateDate;	//
        public String TAFlag;	//
        public String adminOrg;	//
        public String adminIrregularityStatus;	//
        public List<IrregularBehavior> irregularBehavior ;
 
    }
    public class IrregularBehavior {
        public String USMLEID;
        public Integer applicationId;
        public Integer irregularBehavior;
        public String description;
        public String explanation;
       
    }
    
    /*public static CibisExamHistoryResponseEventWrap parse(String json) {
        return (CibisExamHistoryResponseEventWrap) System.JSON.deserialize(json, CibisExamHistoryResponseEventWrap.class);
    }*/
}