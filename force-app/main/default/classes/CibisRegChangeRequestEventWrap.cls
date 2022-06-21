//CIBIS
public class CibisRegChangeRequestEventWrap{
    public String entity;	
    public String subEntity;
    public String transactionId;	
    public String operation;	
    public String USMLEId;	
    public Integer applicationId;	
    public String examType;	
    public regChangePayload payload;
    Public class regChangePayload {
        public regChangePayloadStatus registrationStatus;
    }
    Public class regChangePayloadStatus {
        public String registrationStatus;
    }
}