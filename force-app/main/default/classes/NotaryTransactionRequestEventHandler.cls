/**
 * Sampath Karnati 
 * * Online Notary Transaction Request Event Controller
 * * Expose methods to build/handle payload for Notary Transaction Request Event Platform Event
 * ? Exposed as Public
 */
public with sharing class NotaryTransactionRequestEventHandler implements INotaryTransactionRequestEventHandler {

    // Constants
    static final String REDIRECT_URL = 'https://www.ecfmg.org'; //TODO:Functionality get the url from DB
    static final String MESSAGE_SOURCE = 'NotaryCam_RequestEvent'; 
    static final String REPLACE_NULL = '-';
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public static String buildRequestEventPayload(Id caseId) {
        try 
        {
            String apiVersion; 
            string transid; 
            // Parties
            List<NotaryTransactionRequestEvent.Party> parties = buildParties(caseId); 
            System.debug('the case id is coming as ' + caseId);
            
            // Documents 
            List<NotaryTransactionRequestEvent.Document> documents = buildDocuments(caseId);

            //get API version 
            Org_Wide_Notary_Setting__mdt notarySettingMdt = Org_Wide_Notary_Setting__mdt.getInstance('Enable_Online_Notary');
            if (!string.isBlank(notarySettingMdt.API_Version__c)){
                apiVersion = notarySettingMdt.API_Version__c; 
            }   
            //get transaction id           
            Online_Notary_Transaction__c onlineNotaryTrans = OnlineNotaryTransactionController.getOnlineNotaryTransaction(caseId); 
            if (OnlineNotaryTrans != null){
                transid = OnlineNotaryTrans.Transaction_ID__c; 
            }            
            // Payload Object
            NotaryTransactionRequestEvent requestPayload = new NotaryTransactionRequestEvent(caseId, 
                                                                                            REDIRECT_URL, 
                                                                                            parties, 
                                                                                            documents,
                                                                                            apiVersion,
                                                                                            transid);
                                                                                             

            // JSON Payload
            String payload = JSON.serialize(requestPayload);
        
            return payload;
        }
        catch(Exception e)
        {
            System.debug(Logginglevel.ERROR, 'Unable to build request event payload' + e.getMessage());            
            throw e; 
        }

    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    @TestVisible
    private static List<NotaryTransactionRequestEvent.Party> buildParties(Id caseId) {
        try 
        {
            // Get Contact
            List<Case> cases =  [SELECT Id, Contact.FirstName, Contact.LastName, Contact.Email, Contact.Phone
                                FROM Case 
                                WHERE Id =: caseId
                                WITH SECURITY_ENFORCED];

            if(!cases.isEmpty()) 
            {
                NotaryTransactionRequestEvent.Party party =  new NotaryTransactionRequestEvent.Party();
                if (string.isBlank(cases[0].Contact.FirstName)){
                    party.firstName = REPLACE_NULL;
                }else{
                    party.firstName = cases[0].Contact.FirstName;
                }
                party.lastName = cases[0].Contact.LastName;
                party.email = cases[0].Contact.Email;
                party.phone = cases[0].Contact.Phone;

                List<NotaryTransactionRequestEvent.Party> parties = new List<NotaryTransactionRequestEvent.Party>();
                parties.add(party);
                return parties;
            }    
            
        }
        catch(Exception e)
        {
            System.debug(Logginglevel.ERROR, 'Unable to build parties' + e.getMessage());            
            throw e; 
        }

        return null;

    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    @TestVisible
    private static List<NotaryTransactionRequestEvent.Document> buildDocuments(Id caseId) {
        try 
        {
            // Get ID Form Template
            Asset idForm = AssetsController.getAssetByCaseContact(caseId,
                                                                  Constants.ASSET_NAME_ID_FORM_TEMPLATE, 
                                                                  Constants.ASSET_STATUS_IN_PROGRESS);

            if(idForm !=null) {
                NotaryTransactionRequestEvent.Document document =  new NotaryTransactionRequestEvent.Document();
                document.name = idForm.Name;
                //TODO: Replace ID Form Generaion is done
                document.url = idForm.Azure_Storage_URL__c;
                //document.url = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/3fef4117-2bf3-4bdf-bab3-2fe6f4499b8a.pdf';
    
                List<NotaryTransactionRequestEvent.Document> documents = new List<NotaryTransactionRequestEvent.Document>();
                documents.add(document);
                
                return documents;
            }

            return null;
            
        }
        catch(Exception e)
        {
            System.debug(Logginglevel.ERROR, 'Unable to build documents' + e.getMessage());            
            throw e; 
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public static boolean publishEvent(string payLoad) {
        try 
        {
            // Create an instance of the event with field values
            Notary_Transaction_Request_Event__e requestEvent = new Notary_Transaction_Request_Event__e(Payload__c=payLoad);

            //for debug purpose            
            LogUtil.logMessage(MESSAGE_SOURCE, payLoad, null); //delete me

            // Call method to publish events
            Database.SaveResult sr = EventBusWrapper.publish(requestEvent);
            // Inspect publishing result
            if (sr.isSuccess()) 
            {
                System.debug('Successfully published event: Notary_Transaction_Request_Event__e');
                return true;
            } 
            else 
            {
                for(Database.Error err : sr.getErrors()) 
                {
                    System.debug('Error returned: ' +
                                err.getStatusCode() +
                                ' - ' +
                                err.getMessage());
                }
            }

            return false; //default
        }
        catch(Exception e)
        {
            System.debug(Logginglevel.ERROR, 'Unable to publish event' + e.getMessage());
            throw e; 
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public static boolean publishEvent(Id caseId) {
        try 
        {
            //build payload
            string payload = buildRequestEventPayload(caseId);

            //publish event
            return publishEvent(payload);
        }
        catch(Exception e)
        {
            System.debug(Logginglevel.ERROR, 'Unable to publish event' + e.getMessage());
            throw e; 
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    @InvocableMethod(label='Publish Notary Request Event' 
                     description='Publishes Online Notary request event after a failure(Online Notary Session Reinitiated).' 
                     category='Online Notary')
    public static void publishEvent(List<Id> caseIds) {
        try 
        {
            publishEvent(caseIds[0]);
        }
        catch(Exception e)
        {
            System.debug(Logginglevel.ERROR, 'Unable to publish event-Invocable' + e.getMessage());
            throw e; 
        }
    } 
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}