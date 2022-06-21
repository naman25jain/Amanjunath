/**
 * Sampath Karnati
 * * Handle Notary Transaction Response Event Platform  Event
 * ? Exposed as Public
 */
public with sharing class NotaryTransactionResponseEventHandler implements INotaryTransactionResponseEventHandler {

    static final String SUCCESS = 'Success';
    static final String ERROR = 'Error';

    static final String NOTARY_PATICIPANT_ROLE_NOTARY ='notary';
    static final String NOTARY_PATICIPANT_ROLE_SIGNER ='signer';

    static final String UNABLE_TO_HANDLE_RESSPONSE_EVENT_SUCCESS = 'Unable to handle response event success';
    static final String UNABLE_TO_HANDLE_RESSPONSE_EVENT_ERROR = 'Unable to handle response event error';

    static final String MESSAGE_SOURCE = 'NotaryCam_ResponseEvent'; 
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public static void handleResponseEventPayload(string payload){
         //debug purpose only - delete me
         LogUtil.logMessage(MESSAGE_SOURCE, payload, null); 
        try 
        {
            //parse payload to NotaryTransactionResponseEvent
            NotaryTransactionResponseEvent notaryTransactionResponseEvent = new NotaryTransactionResponseEvent();
            notaryTransactionResponseEvent = (NotaryTransactionResponseEvent)System.JSON.deserialize(payload, NotaryTransactionResponseEvent.class);
            handleResponse(notaryTransactionResponseEvent);           
        }
        catch(Exception e)
        {
            System.debug(Logginglevel.ERROR, 'Unable to handle response event payload' + e.getMessage());
            throw e; 
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    @TestVisible
    private static void handleResponse(NotaryTransactionResponseEvent responseEvent) {        
        try 
        {
            if(responseEvent.responseStatus == SUCCESS) {                
                handleSuccess(responseEvent);
            }
            else {
                handleError(responseEvent);
            }
        }
        
        catch(Exception e)
        {
            System.debug(Logginglevel.ERROR, 'Unable to handle response event' + e.getMessage());
            LogUtil.logMessage(MESSAGE_SOURCE, 'Unable to handle response event' + e.getMessage(), null); //delete me
            throw e; 
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    @TestVisible
    private static void handleSuccess(NotaryTransactionResponseEvent responseEvent) {
        Savepoint sp = Database.setSavepoint();
        String analystNotaryLink; 
        string signingURL; 
        List<NotaryTransactionResponseEvent.SigningViews> signviews  = new List<NotaryTransactionResponseEvent.SigningViews>(); 
        List<NotaryTransactionResponseEvent.Documents> docs = new List<NotaryTransactionResponseEvent.Documents>();  
        signviews = responseEvent.data.signingViews; 
        docs = responseEvent.data.documents; 

        if (signviews != null && !signviews.isEmpty()){
            for (NotaryTransactionResponseEvent.SigningViews sv: signviews){
                signingURL = sv.deepLink; 
            }            
            signingURL = responseEvent.data.signingViews[0].deepLink; 
        }
        if (docs != null && !docs.isEmpty()){
            for(NotaryTransactionResponseEvent.Documents doc: docs){
                analystNotaryLink = doc.devNotaryLink; 
            }
        }
        List<NotaryTransactionResponseEvent.participant> notaryPaticipants  = new List<NotaryTransactionResponseEvent.Participant>();    
        notaryPaticipants = responseEvent.data.participants;            
        if (notaryPaticipants != null && !notaryPaticipants.isEmpty()){    
            for (NotaryTransactionResponseEvent.Participant notaryPaticipant : notaryPaticipants){                
                if (notaryPaticipant.role == NOTARY_PATICIPANT_ROLE_NOTARY){                
                    analystNotaryLink = notaryPaticipant.roomURL; 
                }else if(notaryPaticipant.role == NOTARY_PATICIPANT_ROLE_SIGNER){
                    signingURL =  notaryPaticipant.roomURL; 
                }
            }
        }
        try 
        {
            Id onlineTransactionId; 
            Online_Notary_Transaction__c onlineTransaction  = OnlineNotaryTransactionController.getOnlineNotaryTransaction(responseEvent.data.transactionId);
            if (onlineTransaction !=null){
                onlineTransactionId= onlineTransaction.Id;                
            }
             // SecurityDecision needs a list of records
             List<Online_Notary_Transaction__c> onlineNotaryTransaction = new List<Online_Notary_Transaction__c>();

             onlineNotaryTransaction.add(new Online_Notary_Transaction__c(
                                            Id = onlineTransactionId, 
                                            Case__c = responseEvent.caseId,                                            
                                            Status__c = responseEvent.responseStatus, 
                                            Transaction_ID__c = responseEvent.data.transactionId, 
                                            Signing_Session_Url__c = signingURL,
                                            Dev_Notary_Link__c = analystNotaryLink));     //temp hold                                        
            
            //Insert Case/Transaction Details for Online Notary Transaction and Update case status                                
            if (OnlineNotaryTransactionController.saveOnlineNotaryTransaction(onlineNotaryTransaction) &&
                CaseController.updateCaseStatus(responseEvent.caseId, Constants.CASE_STATUS_ONLINE_NOTARY_SESSION_CREATED)) {
                    // Case Status update Email
                    EmailHelper.caseStatusUpdateEmail(responseEvent.caseId, Constants.CASE_EMAIL_TEMPLATE_NAME, Constants.ORG_WIDE_ADDRESS);
            }
        }
        catch(DmlException e) 
        {
            System.debug(Logginglevel.ERROR, UNABLE_TO_HANDLE_RESSPONSE_EVENT_SUCCESS + e.getMessage());
            Database.rollback(sp);
            LogUtil.logMessage(MESSAGE_SOURCE, UNABLE_TO_HANDLE_RESSPONSE_EVENT_SUCCESS + e.getMessage(), null); //delete me
            throw e; 
        }
        catch(NoAccessException e) 
        {
            System.debug(Logginglevel.ERROR, UNABLE_TO_HANDLE_RESSPONSE_EVENT_SUCCESS + e.getMessage());
            Database.rollback(sp);
            LogUtil.logMessage(MESSAGE_SOURCE, UNABLE_TO_HANDLE_RESSPONSE_EVENT_SUCCESS + e.getMessage(), null); //delete me
            throw e; 
        }
        catch(Exception e)
        {
            System.debug(Logginglevel.ERROR, UNABLE_TO_HANDLE_RESSPONSE_EVENT_SUCCESS + e.getMessage());
            LogUtil.logMessage(MESSAGE_SOURCE, UNABLE_TO_HANDLE_RESSPONSE_EVENT_SUCCESS + e.getMessage(), null); //delete me
            Database.rollback(sp);
            throw e; 
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    @TestVisible
    private static void handleError(NotaryTransactionResponseEvent responseEvent) {
        Savepoint sp = Database.setSavepoint();
        LogUtil.logMessage(MESSAGE_SOURCE,  'Value of responseEvent: from handle error -->'+System.JSON.serialize(responseEvent), null);        
        try 
        {
            // Update Case Status
                CaseController.updateCaseStatus(responseEvent.caseId, constants.CASE_STATUS_ONLINE_NOTARY_SESSION_FAILED);
            // Add Case comment with error message
                List<CaseComment> caseComments = new List<CaseComment>();
                 caseComments.add(new CaseComment(
                                 ParentId = responseEvent.caseId, 
                                 CommentBody = responseEvent.errorDescription));
                 CaseController.insertCaseComment(caseComments);     
        }
        catch(Exception e)
        {
            System.debug(Logginglevel.ERROR, UNABLE_TO_HANDLE_RESSPONSE_EVENT_ERROR + e.getMessage());
            Database.rollback(sp);
            throw e; 
        }

    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}