/*
  Request Event Wrapper for EPEX Evalaution Request in CIBIS records : EPEX Evalaution Request
*/
public class CibisEpexEvaluationRequestEventWrap{
    public String entity;	//candidate
    public String subEntity;	//eligibilityExtensionEvaluationInfo
    public String transactionId;	//c407e88b-fe1c-403c-bf3b-c18147722a93
    public String operation;	//GET
    public Payload payload;
    Public class Payload {
        public String USMLEId;	//50560903
        public String ApplicationId;	//21
        public String ExamType;	//STEP1
    }
    /*public static CibisEpexEvaluationRequestEventWrap parse(String json){
        return (CibisEpexEvaluationRequestEventWrap) System.JSON.deserialize(json, CibisEpexEvaluationRequestEventWrap.class);
    }*/
}