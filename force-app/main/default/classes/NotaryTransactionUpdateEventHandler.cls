/**
 * Sampath Karnati
 * * Handle Notary Transaction Update Platform Event
 * ? Exposed as Public
 */
public with sharing class NotaryTransactionUpdateEventHandler{
    static final String SUCCESS = 'Success';
    static final String ERROR = 'Error';
    static final String AFFIRMATION_YES = 'Yes';
    static final String MESSAGE_SOURCE = 'NotaryCam_Update'; 
    static final String EVENT_STATUS_DOCUMENT_PROCESSED_SUCCESS = 'Documents-processed-success';
    static final String EVENT_STATUS_IN_PROGRESS = 'In-progress';
    public static void handleUpdateEventPayload(string payload){
        LogUtil.logMessage(MESSAGE_SOURCE, payload, null); //delete me
        try{
            NotaryTransactionUpdateEvent notaryTransactionUpdateEvent = new NotaryTransactionUpdateEvent();
            notaryTransactionUpdateEvent = (NotaryTransactionUpdateEvent)System.JSON.deserialize(payload, NotaryTransactionUpdateEvent.class);            
            handleUpdate(notaryTransactionUpdateEvent);            
        }
        catch(Exception e){
            throw e; 
        }
    }
    @TestVisible
    private static void handleUpdate(NotaryTransactionUpdateEvent updateEvent){        
        try{
            // Transaction Exists? 
            //      This check is required, since we have only one testing url registered for all DevInt/QA/UAT Sandboxes
            //      This check doesn't matter in production, because it is one-one mapping with Webhook and Prod            
            Online_Notary_Transaction__c onlineNotaryTransaction = OnlineNotaryTransactionController.getOnlineNotaryTransaction(updateEvent.transactionId);
            if(onlineNotaryTransaction != null){                               
                if(updateEvent.responseStatus == Constants.NOTARY_TRANSACTION_UPDATE_EVENT_COMPLETE_SUCCESS ||updateEvent.responseStatus == SUCCESS){
                    handleCompleteSuccess(updateEvent);
                }else if(updateEvent.responseStatus == EVENT_STATUS_IN_PROGRESS || updateEvent.responseStatus == EVENT_STATUS_DOCUMENT_PROCESSED_SUCCESS){
                    // Update the transaction status
                    OnlineNotaryTransactionController.updateOnlineNotaryTransactionStatus(updateEvent.transactionId, updateEvent.responseStatus);	
                }else{
                    // default means Rejected, can't map a generic status for different rejections due to NotaryCam API Limitation
                    handleRejection(updateEvent);
                }
            }
        }
        catch(Exception e){
            throw e; 
        }
    }
    @TestVisible
    private static void handleRejection(NotaryTransactionUpdateEvent updateEvent){
        Savepoint sp = Database.setSavepoint();        
        try{
             Online_Notary_Transaction__c onlineNotaryTransaction = OnlineNotaryTransactionController.getOnlineNotaryTransaction(updateEvent.transactionId);             
             OnlineNotaryTransactionController.updateOnlineNotaryTransactionStatus(updateEvent.transactionId, updateEvent.responseStatus);
             CaseController.updateCaseStatus(onlineNotaryTransaction.Case__c, constants.CASE_STATUS_ONLINE_NOTARY_SESSION_REJECTED);
                 List<CaseComment> caseComments = new List<CaseComment>();
                  caseComments.add(new CaseComment(ParentId = onlineNotaryTransaction.Case__c, 
                                                    CommentBody = updateEvent.responseStatus));
                  CaseController.insertCaseComment(caseComments); 
        }
        catch(NoAccessException e){
            Database.rollback(sp);
            throw e; 
        }
        catch(Exception e){
            Database.rollback(sp);
            throw e; 
        }
    }
    @TestVisible
    private static void handleCompleteSuccess(NotaryTransactionUpdateEvent updateEvent){        
        Savepoint sp = Database.setSavepoint();
        try{            
            Online_Notary_Transaction__c onlineNotaryTransaction = OnlineNotaryTransactionController.getOnlineNotaryTransaction(updateEvent.transactionId);
            OnlineNotaryTransactionController.updateOnlineNotaryTransactionStatus(updateEvent.transactionId, updateEvent.responseStatus);           
            Case caseContact = CaseController.getCaseContact(onlineNotaryTransaction.Case__c);
             Id productId = [SELECT Id 
                              FROM Product2
                             WHERE ProductCode =: Constants.PRODUCT_CODE_ID_FORM
                             WITH SECURITY_ENFORCED
                             LIMIT 1].Id;
             List<Asset> assets = new List<Asset>();
             assets.add(new Asset(Name = Constants.ASSET_NAME_ID_FORM_NOTARIZED,
                                  Azure_Storage_URL__c = updateEvent.azureUrl,
                                  Type__C = Constants.ASSET_TYPE_IDENTITY_VERIFICATION,
                                  Status = Constants.ASSET_STATUS_INPROGRESS,
                                  Case__c = onlineNotaryTransaction.Case__c,
                                  ContactId = caseContact.ContactId,
                                  AccountId = caseContact.AccountId,
                                  Product2Id = productId,
                                  RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_IDENTITY).getRecordTypeId()));
            AssetsController.insertAsset(assets);
             Id assetId = [SELECT Id 
                           FROM Asset
                           WHERE Case__c =: onlineNotaryTransaction.Case__c
                           AND Azure_Storage_URL__c =: updateEvent.azureUrl
                           WITH SECURITY_ENFORCED
                           LIMIT 1].Id;
             List<Affirmation__c> affirmations = new List<Affirmation__c>();
             affirmations.add(new Affirmation__c(Asset__c = assetId, 
                                                Status__c = Constants.AFFIRMATION_STATUS_IN_PROGRESS, 
                                                Document_is_an_ID_Form_Picklist__c = AFFIRMATION_YES, 
                                                ID_Form_Acceptable_Picklist__c = AFFIRMATION_YES, 
                                                RecordTypeId = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get(Constants.AFFIRMATION_RECORD_TYPE_ID_VERIFICATION).getRecordTypeId()));
            AffirmationController.insertAffirmation(affirmations);
             CaseController.updateCaseStatus(onlineNotaryTransaction.Case__c, Constants.CASE_STATUS_PENDING_ID_VERIFICATION_REVIEW);
        }
        catch(NoAccessException e){
            Database.rollback(sp);
            throw e; 
        }
        catch(Exception e){
            Database.rollback(sp);
            throw e; 
        }
    }   
}