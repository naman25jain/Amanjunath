public with sharing class OFACSearchResponseHandler{
    static final Integer SUCCESS = 200;
    public static void handleResponseEventPayload(string payload){
        IOFACSearchHandler searchHandler = new OFACSearchHandler();
        OFACSearchResponse response = new OFACSearchResponse();
        try{
            searchHandler.logMessage('OFAC Batch Id ' + response.batchId + ' search response payload: ' + payload); //delete me
            response = (OFACSearchResponse)System.JSON.deserialize(payload, OFACSearchResponse.class);
            handleEvent(response);
            searchHandler.logMessage('OFAC Batch Id ' + response.batchId + ' successfully updated'); //delete me
        }
        catch(Exception e){
            searchHandler.logMessage('OFAC Batch Id ' + response.batchId + ' failed with error: ' + e);
        }
    }
    @TestVisible
    private static void handleEvent(OFACSearchResponse response){
        try{
            if(response.status == SUCCESS){
                switch on response.batchId.substring(0,3){
                    when 'CON' {
                        handleContactUpdate(response.batchId);
                    }
                    when 'ACC' {
                        handleAccountUpdate(response.batchId);
                    }
                    when 'AKA' {
                        handleAkaUpdate(response.batchId);
                    }
                    when else {
                        throw new ServiceException ('Unable to determine batch type');
                    }
                }
            }else{
                throw new ServiceException (response.error + ' - ' + response.message);
            }
        }        
        catch(Exception e){
            throw e; 
        }
    }
    @TestVisible
    private static void handleContactUpdate(String batchId){
        IOFACSearchHandler searchHandler = new OFACSearchHandler();
        try{
            List<Contact> contacts  = [SELECT Id, OFAC_Scan_BatchId__c, OFAC_Scan_Required__c, OFAC_Scan_Date__c 
                                        FROM Contact
                                        WHERE OFAC_Scan_BatchId__c =: batchId
                                        WITH SECURITY_ENFORCED FOR UPDATE];
            for(Contact con : contacts){               
                con.OFAC_Scan_BatchId__c = null;
                con.OFAC_Scan_Required__c = false;
                con.OFAC_Scan_Date__c =  System.now();
            }
            searchHandler.updateContacts(contacts);
        }        
        catch(Exception e){
            throw e; 
        }
    }
    @TestVisible
    private static void handleAccountUpdate(String batchId){
        IOFACSearchHandler searchHandler = new OFACSearchHandler();
        try{
            List<Account> accounts  = [SELECT Id, OFAC_Scan_BatchId__c, OFAC_Scan_Date__c, OFAC_Scan_Required__c 
                                        FROM Account
                                        WHERE OFAC_Scan_BatchId__c =: batchId
                                        WITH SECURITY_ENFORCED FOR UPDATE];
            for(Account acc : accounts){               
                acc.OFAC_Scan_BatchId__c = null;
                acc.OFAC_Scan_Required__c = false;
                acc.OFAC_Scan_Date__c =  System.now();
            }
            searchHandler.updateAccounts(accounts);
        }        
        catch(Exception e){
            throw e; 
        }
    }
    @TestVisible
    private static void handleAkaUpdate(String batchId){
        IOFACSearchHandler searchHandler = new OFACSearchHandler();
        try{
            List<aka_Names__c> akaList  = [SELECT Id, OFAC_Scan_BatchId__c, OFAC_Scan_Date__c, OFAC_Scan_Required__c 
                                        FROM aka_Names__c
                                        WHERE OFAC_Scan_BatchId__c =: batchId
                                        WITH SECURITY_ENFORCED FOR UPDATE];
            for(aka_Names__c aka : akaList){               
                aka.OFAC_Scan_BatchId__c= null;
                aka.OFAC_Scan_Required__c = false;
                aka.OFAC_Scan_Date__c =  System.now();
            }
            searchHandler.updateAkaNames(akaList);
        }    
        catch(Exception e){
            throw e; 
        }
    }
}