//CIBIS
public class CibisCandIrregularResponseEventWrap {
    public String responseStatus; 
    public String errorDescription;
    public String transactionId;
    public Payload payload;
    Public class Payload{
        public String USMLEId;	//50564780
        public String NBMEPartHistoryFlag;	//N
        public String FSMBBoardActionFlag;	//N
        public String FSMBFlexHistoryFlag;	//N
        public String nonAdminIrregularityStatus;	//N
        public String lastCSAResultCode;	//N
        public String ECFMGPartHistory;	//N
        public list <irregularBehavior > irregularBehavior;
    }
    Public class irregularBehavior{
        public String USMLEId; 
        public Integer IrregularBehavior; 
        public String Description;
        public String Explanation; 
    }
    /*public static CibisCandIrregularResponseEventWrap parse(String json) {
        return (CibisCandIrregularResponseEventWrap) System.JSON.deserialize(json, CibisCandIrregularResponseEventWrap.class);
    }*/
}