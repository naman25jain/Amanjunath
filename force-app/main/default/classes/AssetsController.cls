/**
    *   Sampath Karnati 
    * * Generic class with methods for Asset standard object
     * ? Exposed as Public
     * Include all te Get/Save methods related to Assets standard object
     */
    public with sharing class AssetsController extends BaseController {

        @AuraEnabled(cacheable=true)
        public static Asset getAssetByCaseContact(Id caseId, string name, string status) 
        {
            try{
                // Get contact Id
                Case caseContact = CaseController.getCaseContact(caseId);

                if(caseContact != null)
                {
                   List<Asset> asset =  [SELECT Id, Name, Status, Azure_Storage_URL__c
                                            FROM Asset
                                            WHERE ContactId =: caseContact.contactId   
                                            AND Name =:  name
                                            AND Status =:  status                         
                                            WITH SECURITY_ENFORCED
                                            ORDER BY CreatedDate desc];
                    if(!asset.isEmpty()) {return asset[0];}
                }
                    
            }
            catch(QueryException e)
            {
                System.debug(Logginglevel.ERROR, 'Unable to get asset' + e.getMessage());
                throw e; 
            }
            catch(Exception e)
            {
                System.debug(Logginglevel.ERROR, 'Unable to get asset' + e.getMessage());
                throw e; 
            }
        
            return null;
        }
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        @AuraEnabled
        public static boolean insertAsset(List<Asset> assets) 
        {
            try
            {
                // Check for accessability
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE, assets);

                Insert securityDecision.getRecords();

                return true;
                
            }
            catch(Exception e) 
            {
                System.debug(Logginglevel.ERROR, 'Unable to insert asset' + e.getMessage());
                throw e; 
            }
        }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    }