global class InvocableCloudController {
    static final String LOG_SOURCE = 'InvocableCloudController';
    ////////////////////////////////////////
	@InvocableMethod(label='Get the Payload' 
                     description='Get Payload from Cloud document.' 
                     category='Cloud Document')
    public static List <IncvPayloadWrapper> getInvocableCloudPayload(List<Cloud_Document__c> cloudDocuments) {
        List<IncvPayloadWrapper> results = new List<IncvPayloadWrapper>();
        try{
            if(cloudDocuments.size() > 0){
                // Get Payload
                string payloadString = cloudDocuments[0].payload__c;
                if(payloadString != ''){
                    IncvPayloadWrapper payload = (IncvPayloadWrapper) JSON.deserialize(payloadString, IncvPayloadWrapper.class);
                    results.add(payload);
                }                
            }
        } catch(Exception e){
             // Insert a log message
             CommonUtils.logMessage(new Log_Message__c(Exception__c = e.getMessage(),
             Source__c = LOG_SOURCE,
             Date_Time_Logged__c = DateTime.now()));
            throw e;
        }
        return results;
    }
    global class IncvPayloadWrapper {
        
        @InvocableVariable(label='ecfmgId' description='ECFMG ID' required=true)
        global string ecfmgId;
        
        @InvocableVariable(label='documentType' description='Document Type' required=true)
        global string documentType;

        @InvocableVariable(label='caseNumber' description='Case Number' required=true)
        global string caseNumber;
        
        @InvocableVariable(label='entityId' description='Entity ID' required=true)
        global string entityId;
        
        @InvocableVariable(label='sourceDocument' description='Source Document' required=true)
        global string sourceDocument;
        
        @InvocableVariable(label='nameOnDocument' description='NameOnDocument' required=true)
        global string nameOnDocument;
        
        @InvocableVariable(label='receivedDate' description='Received Date' required=true)
        //Changed the field to String and the date conversion is being handled in Flow.
        //global date receivedDate;
        global string receivedDate;
    }
}