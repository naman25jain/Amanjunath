/**
    *   Sampath Karnati 
    * * Generic class with methods for Affirmation custom object
     * ? Exposed as Public
     * Include all te Get/Save methods related to Affirmation custom object
     */
    public with sharing class AffirmationController extends BaseController {

        
        @AuraEnabled
        public static boolean insertAffirmation(List<Affirmation__c> affirmations) 
        {
            try
            {
                // Check for accessability
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE, affirmations);

                Insert securityDecision.getRecords();

                return true;
                
            }
            catch(Exception e) 
            {
                System.debug(Logginglevel.ERROR, 'Unable to insert affirmation' + e.getMessage());
                throw e; 
            }
        }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    }