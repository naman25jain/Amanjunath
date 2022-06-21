/**
    *   Sampath Karnati 
    * * Generic class with methods for Online Notary  Transaction custom object
     * ? Exposed as Public
     * Include all te Get/Save methods related to Online Notary Transaction custom object
     */
public with sharing class OnlineNotaryTransactionController extends BaseController {

    
    @AuraEnabled(cacheable=true)
        public static Online_Notary_Transaction__c getOnlineNotaryTransaction(Id caseId, string caseStatus) 
        {
            try{
                // it's always safer to get the list even though we expect one record, this way we can write unit tests for soql empty rows
                   // Reference: https://help.salesforce.com/articleView?type=1&mode=1&id=000328824
                List<Online_Notary_Transaction__c> onlineNotaryTransaction =  [SELECT Id, Signing_Session_Url__c
                                                                                FROM Online_Notary_Transaction__c
                                                                                WHERE Case__c =: caseId
                                                                                  AND Case__r.Internal_Status__c =: caseStatus                            
                                                                                WITH SECURITY_ENFORCED
                                                                                ORDER BY CreatedDate desc
                                                                                ];
            if(!onlineNotaryTransaction.isEmpty()) 
                {
                  return onlineNotaryTransaction[0];
                }    
            }
            catch(QueryException e)
            {
                System.debug(Logginglevel.ERROR, 'Unable to get online notary transaction' + e.getMessage());
                throw e; 
            }
           
            return null;
        }
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        public static boolean saveOnlineNotaryTransaction(List<Online_Notary_Transaction__c> onlineNotaryTransaction) 
        {
            try{
                
                if (Online_Notary_Transaction__c.SObjectType.getDescribe().isCreateable() ||Online_Notary_Transaction__c.SObjectType.getDescribe().isUpdateable()){  
                    upsert onlineNotaryTransaction; 
                }
                return true;
            }
            catch(DmlException e) 
            {
                System.debug(Logginglevel.ERROR, 'Unable to save online notary transaction' + e.getMessage());
                throw e; 
            }
            catch(Exception e) 
            {
                System.debug(Logginglevel.ERROR, 'Unable to save online notary transaction' + e.getMessage());
                throw e; 
            }
        }
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        @AuraEnabled(cacheable=true)
        public static Online_Notary_Transaction__c getOnlineNotaryTransaction(string transactionId) 
        {
            try{
                List<Online_Notary_Transaction__c> onlineNotaryTransaction =  [SELECT Id, Signing_Session_Url__c, Case__c
                                                                                FROM Online_Notary_Transaction__c
                                                                                WHERE Transaction_ID__c =: transactionId                            
                                                                                WITH SECURITY_ENFORCED
                                                                                ORDER BY CreatedDate desc
                                                                                ];
            if(!onlineNotaryTransaction.isEmpty()) 
                {
                  return onlineNotaryTransaction[0];
                }    
            }
            catch(QueryException e)
            {
                System.debug(Logginglevel.ERROR, 'Unable to get online notary transaction' + e.getMessage());
                throw e; 
            }
           
            return null;
        }
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        @AuraEnabled
        public static boolean updateOnlineNotaryTransactionStatus(string transactionId, string status) 
        {
            try{
                // Security.stripInaccessible only accepts list
                List<Online_Notary_Transaction__c> onlineNotaryTransaction =  [SELECT Status__c
                                                                                FROM Online_Notary_Transaction__c
                                                                                WHERE Transaction_Id__c =: transactionId
                                                                                WITH SECURITY_ENFORCED];
                
                if(!onlineNotaryTransaction.isEmpty() && Online_Notary_Transaction__c.SObjectType.getDescribe().isUpdateable()) 
                {
                    onlineNotaryTransaction[0].Status__c = status;                   
                    update onlineNotaryTransaction; 
                    return true;                   
                }
                
            return false;
                
            }
            catch(Exception e) 
            {
                System.debug(Logginglevel.ERROR, 'Unable to update transaction status' + e.getMessage());
                throw e; 
            }
        }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
    public static Online_Notary_Transaction__c getOnlineNotaryTransaction(Id caseId) 
    {
        try{
            // it's always safer to get the list even though we expect one record, this way we can write unit tests for soql empty rows
               // Reference: https://help.salesforce.com/articleView?type=1&mode=1&id=000328824
            List<Online_Notary_Transaction__c> onlineNotaryTransaction =  [SELECT Id, Transaction_ID__c, Signing_Session_Url__c
                                                                            FROM Online_Notary_Transaction__c
                                                                            WHERE Case__c =: caseId                                                                                                        
                                                                            WITH SECURITY_ENFORCED
                                                                            ORDER BY CreatedDate desc
                                                                            ];
        if(!onlineNotaryTransaction.isEmpty()) 
            {
              return onlineNotaryTransaction[0];
            }    
        }
        catch(QueryException e)
        {
            System.debug(Logginglevel.ERROR, 'Unable to get online notary transaction' + e.getMessage());
            throw e; 
        }
       
        return null;
    }     
}