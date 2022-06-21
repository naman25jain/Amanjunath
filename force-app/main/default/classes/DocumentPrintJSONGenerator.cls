public inherited sharing class DocumentPrintJSONGenerator {
    
    public String entity;
	public String subEntity;
	public String transactionId;
	public String operation;
	public Payload payload;

	public class Payload {
		public String printerName;
		public String caseId;
		public List<Document> document;
	}

	public class Document {
		public String trayName;
		public String mediaSize;
		public String documentURL;
		public String azureContainer;
		public Integer sequence;
	}

	
	public static DocumentPrintJSONGenerator parse(String json) {
		return (DocumentPrintJSONGenerator) System.JSON.deserialize(json, DocumentPrintJSONGenerator.class);
	}
}