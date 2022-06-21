/*
  Request Event Wrapper for Cibis Exam History with Irregular records : Exam History with Irregular Request
*/

public with sharing class CibisExamHistoryRequestEventWrap{
    public String entity{get;set;}
	public String subEntity{get;set;}
	public String transactionId{get;set;}
	public String operation{get;set;}
	public String USMLEId{get;set;}
    public String applicationId{get;set;}{applicationId='0';}
    public String examType{get;set;}{examType='';}
	public String field{get;set;}
    
    public static CibisExamHistoryRequestEventWrap parse(String payload){
		return (CibisExamHistoryRequestEventWrap) System.JSON.deserialize(payload, CibisExamHistoryRequestEventWrap.class);
	}
}