public class CibisSecrDocURLResponseEventWrap{
	public String responseStatus;	
	public String errorDescription;
	public String transactionId;	
	public Payload payload;
	Public class Payload {	
		public list<SecretariatDocumentInfoWithURL> secretariatDocumentInfoWithURL;
	}

	Public class SecretariatDocumentInfoWithURL {
		public String USMLEId;	
		public String updatedBy;	
		public String createdBy;	
		public String createdAt;	
		public String updatedAt;	
		public String secretariatDocumentImageBLOB;	
	}
	/*public static CibisSecrDocURLResponseEventWrap parse(String json){
		return (CibisSecrDocURLResponseEventWrap) System.JSON.deserialize(json, CibisSecrDocURLResponseEventWrap.class);
	}*/
}