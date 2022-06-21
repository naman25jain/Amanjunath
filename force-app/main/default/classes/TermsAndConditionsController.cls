/**
    *   Sampath Karnati 
    * * Generic class with methods for Terms_and_Conditions__c custom object
     * ? Exposed as Public
     * Include all the Get/Save methods related to Terms_and_Conditions__c custom object
     */
public with sharing class TermsAndConditionsController extends BaseController {

    @AuraEnabled(cacheable=true)
    public static Terms_and_Conditions__c getTermsAndConditions(String name, String productName) 
    {
        try{
            // it's always safer to get the list even though we expect one record, this way we can write unit tests for soql empty rows
               // Reference: https://help.salesforce.com/articleView?type=1&mode=1&id=000328824
            List<Terms_and_Conditions__c> termsAndConditions =  [SELECT Id, Copy__c, Name, Short_Copy__c 
                                                           FROM Terms_and_Conditions__c 
                                                           WHERE Name =: name
                                                           AND Product__r.Name =: productName
                                                           AND Status__c =: Constants.TERMS_AND_COND_STATUS_ACTIVE
                                                           WITH SECURITY_ENFORCED
                                                          ];
        if(!termsAndConditions.isEmpty()) 
            {
              return termsAndConditions[0];
            }    
        }
        catch(QueryException e)
        {
            System.debug(Logginglevel.ERROR, 'Unable to get terms and conditions' + e.getMessage());
            throw e; 
        }
        catch(Exception e)
        {
            System.debug(Logginglevel.ERROR, 'Unable to get terms and conditions' + e.getMessage());
            throw e; 
        }
    
        return null;
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    @AuraEnabled
    public static boolean saveTermsAndConditionsAgreement(Terms_and_Conditions__c termsAndConditions) 
    {
        try{
            // Get running contact Id
            Id userId = getUserId();
            Id contactId = getCurrentUserContactId(userId);

            // SecurityDecision needs a list of records
            List<Terms_and_Conditions_Agreement__c> termsAndConditionsAgreements = new List<Terms_and_Conditions_Agreement__c>();

            termsAndConditionsAgreements.add(new Terms_and_Conditions_Agreement__c(
                                                Contact__c = contactId, 
                                                TermsandConditions__c = termsAndConditions.Id, 
                                                Name = termsAndConditions.Name + contactId, 
                                                Status__c = Constants.TERMS_AND_COND_AGR_STATUS_ACTIVE, 
                                                Copy__c = termsAndConditions.Copy__c));
            
            // Check for accessability
            SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE, termsAndConditionsAgreements);

            Insert securityDecision.getRecords();

            return true;
        }
        catch(DmlException e) 
        {
            System.debug(Logginglevel.ERROR, 'Unable to save terms and conditions' + e.getMessage());
            throw e; 
        }
        catch(NoAccessException e) 
        {
            System.debug(Logginglevel.ERROR, 'Unable to save terms and conditions' + e.getMessage());
            throw e; 
        }
        catch(Exception e) 
        {
            System.debug(Logginglevel.ERROR, 'Unable to save terms and conditions' + e.getMessage());
            throw e; 
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    @AuraEnabled
    public static boolean saveTermsAndConditionsAgreement(Terms_and_Conditions__c termsAndConditions, Id assetId) 
    {
        try{
            // Get running contact Id
            Id userId = getUserId();
            Id contactId = getCurrentUserContactId(userId);

            // SecurityDecision needs a list of records
            List<Terms_and_Conditions_Agreement__c> termsAndConditionsAgreements = new List<Terms_and_Conditions_Agreement__c>();

            termsAndConditionsAgreements.add(new Terms_and_Conditions_Agreement__c(
                                                Contact__c = contactId, 
                                                TermsandConditions__c = termsAndConditions.Id, 
                                                Name = termsAndConditions.Name + contactId, 
                                                Status__c = Constants.TERMS_AND_COND_AGR_STATUS_ACTIVE, 
                                                Copy__c = termsAndConditions.Copy__c,
                                                Asset__c = assetId));
            
            // Check for accessability
            SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE, termsAndConditionsAgreements);

            Insert securityDecision.getRecords();

            return true;
        }
        catch(DmlException e) 
        {
            System.debug(Logginglevel.ERROR, 'Unable to save terms and conditions' + e.getMessage());
            throw e; 
        }
        catch(NoAccessException e) 
        {
            System.debug(Logginglevel.ERROR, 'Unable to save terms and conditions' + e.getMessage());
            throw e; 
        }
        catch(Exception e) 
        {
            System.debug(Logginglevel.ERROR, 'Unable to save terms and conditions' + e.getMessage());
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
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}