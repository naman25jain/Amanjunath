/**
 * * Controller class for OnlineNotaryConfirmation LWC
 * ? Exposed as Public
 */
public with sharing class OnlineNotaryConfirmationController extends BaseController
{
    static final String UNABLE_TO_PUBLISH_ERROR = 'Unable to publish notary transaction request event'; 
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////   
    @AuraEnabled(cacheable = true)
    public static Constants getConstants() {
        // call base controller
        return getAllConstants();
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    @AuraEnabled
    public static Boolean publishNotaryTransactionRequestEvent(Id caseId, Terms_and_Conditions__c termsAndCondition, Id assetId) {
        Savepoint sp = Database.setSavepoint();
        try{

            TermsAndConditionsController.saveTermsAndConditionsAgreement(termsAndCondition, assetId);

            // Publish Notary Transaction request event
            if(NotaryTransactionRequestEventHandler.publishEvent(caseId)) 
                {
                    return CaseController.updateCaseStatus(caseId, Constants.CASE_STATUS_ONLINE_NOTARY_SESSION_INITIATED);
                }
            }

        catch(DmlException e) 
        {
            System.debug(Logginglevel.ERROR, UNABLE_TO_PUBLISH_ERROR + e.getMessage());
            Database.rollback(sp);
            throw e; 
        }
        catch(NoAccessException e)
        {
            System.debug(Logginglevel.ERROR, UNABLE_TO_PUBLISH_ERROR + e.getMessage());
            Database.rollback(sp);
            throw e; 
        }
        catch(Exception e)
        {
            System.debug(Logginglevel.ERROR, UNABLE_TO_PUBLISH_ERROR + e.getMessage());
            Database.rollback(sp);
            throw e; 
        }
        return false;
    }

    //Method to get azure url of the Id Form Template asset
    @AuraEnabled
    public static String getAzureUrl(String caseId) {
        String url = '';
        List<Asset> assetList = [SELECT Id, Azure_Storage_Url__c FROM Asset WHERE Case__c =:caseId AND Name =:Constants.ASSET_NAME_ID_FORM_TEMPLATE AND Status =:Constants.ASSET_STATUS_IN_PROGRESS WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
        if(!assetList.isEmpty() && String.isNotBlank(assetList[0].Azure_Storage_Url__c)){
            String fileName = assetList[0].Azure_Storage_Url__c.split('/')[4];
            url = CloudStorageUtils.getFileUrlWithSAS(fileName);
        }
        return url;
    }
}