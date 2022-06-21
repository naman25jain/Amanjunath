public with sharing class AzureAssetDeleteRequestBatch {
    public String entity;	
	public String subEntity;	
	public String transactionId;	
	public String operation;	
	public Cls_payload payload;
	
	public class Cls_payload {
		public String containerName;	
		public List<String> document; 	
	}
}