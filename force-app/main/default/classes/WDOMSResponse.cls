public with sharing class WDOMSResponse { 
    public String responseStatus {get; set;}  
    public String errorDescription { get;set; } {errorDescription = '';}  
    public String transactionId {get; set;}
    public Cls_payload payload; 
    Public Integer status; 
    
    public class Cls_payload {
        public string status { get;set; }
        public String message { get;set; } {message = '';}
        public String correlationID {get;set;}
	}
}