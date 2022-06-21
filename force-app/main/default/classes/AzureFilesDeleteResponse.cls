public with sharing class AzureFilesDeleteResponse {

    public String correlationId;	
	public String transactionStatus;
	public Cls_transactionDetails[] transactionDetails;
    public Cls_errorDetails errorDetails;

	public Class Cls_transactionDetails {
		public String fileName;
		public String fileStatus;
        public String errorCode;	
		public String errorDescription;	
	}

	public Class Cls_errorDetails {
		public String errorCode;	
		public String errorDescription;	
	}
}