public inherited sharing class DocumentPrintJSONResponse {

	public String transactionId;
	public String transactionStatus;
	public String caseId;
	public Integer totalDocumentsReceived;
	public ErrorDetails errorDetails;

	public class ErrorDetails {
		public String errorDescription;
	}

	
	public static DocumentPrintJSONResponse parse(String json) {
		return (DocumentPrintJSONResponse) System.JSON.deserialize(json, DocumentPrintJSONResponse.class);
	}
}