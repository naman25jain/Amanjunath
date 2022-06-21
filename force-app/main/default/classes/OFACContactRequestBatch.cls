public with sharing class OFACContactRequestBatch implements Database.Batchable<sObject>, Database.Stateful{
    public Integer recordsProcessed = 0;
    static final String OFAC_BATCH_ID_MSG = 'OFAC Batch Id ';
    public Integer batchSeq = 0;
    private String query;

    public OFACContactRequestBatch(String soql) {
        query = soql;
    }


    public Database.Querylocator start(Database.BatchableContext bc){
        return Database.getQuerylocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Contact> scope){
        //unique batch id (jobid + sequence)        
        String batchId =  bc.getJobId();
        batchId = 'CON' + batchId + '.' + batchSeq;
        batchSeq += 1;
        String logMessage = '';
        List<OFACSearchRequest.Party> cases = new List<OFACSearchRequest.Party>();
        IOFACSearchHandler searchHandler = new OFACSearchHandler();        
        for(Contact con : scope){
            cases.add(searchHandler.buildCase(con));
            con.OFAC_Scan_BatchId__c = batchId;
            recordsProcessed += 1;
        }
            // payload object
            OFACSearchRequest requestPayload = new OFACSearchRequest(batchId,cases);
            // JSON payload
            String payLoad = JSON.serialize(requestPayload);
            searchHandler.logMessage(OFAC_BATCH_ID_MSG + batchId + ' search request payload: ' + payLoad); //delete me
            searchHandler.logMessage(OFAC_BATCH_ID_MSG + batchId + ' search request payload size: ' + payLoad.length()); //delete me
         try {
            // create an instance of the event with payload
            OFAC_VeriScan_Search_Request_Event__e requestEvent = new OFAC_VeriScan_Search_Request_Event__e(payload__c = payLoad);
            // publish the event
            Database.SaveResult sr = EventBusWrapper.publish(requestEvent);
            if (sr.isSuccess()) 
            {
                searchHandler.updateContacts(scope);
            } 
            else 
            {
                for(Database.Error err : sr.getErrors()) 
                {
                    logMessage += err.getMessage() + '-->';
                }
                searchHandler.logMessage(logMessage);
            }
        } catch(Exception e){
            searchHandler.logMessage(OFAC_BATCH_ID_MSG + batchId + ' search request error: ' + e);
        } 
    }

    public void finish(Database.BatchableContext bc){       
    }
}