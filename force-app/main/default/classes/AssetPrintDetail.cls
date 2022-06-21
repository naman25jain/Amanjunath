public class AssetPrintDetail {
        @AuraEnabled
        @InvocableVariable(label='Case Id' required=true)
        public Id caseId;

        @AuraEnabled
        @InvocableVariable(label='Document Url' required=true)
        public String documentUrl;

        @AuraEnabled
        @InvocableVariable(label='Printer Name' required=true)
        public String printerName;
}