public with sharing class CredVerAffirmationController{
    @InvocableMethod(label='Get Existing FMD' description='Check FMD Exists for a particular service')
    public static List<Asset> checkFMDExist(List<ID> ids){
        try{
            Case cvCase = [SELECT Id, Service__c, ContactId FROM Case WHERE Id =: ids[0] WITH SECURITY_ENFORCED];  
            List<Asset> epicAsset = [SELECT Id FROM Asset WHERE contactId =: cvCase.contactId AND Case__r.Service__c =: cvCase.Service__c AND Case__c !=: cvCase.Id AND 
                                     Status !=: constants.ASSET_STATUS_REJECTED AND Status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION AND Status !=: constants.ASSET_STATUS_OUTDATED
                                     AND Status !=: constants.ASSET_STATUS_INCOMPLETE AND Type__c =: Constants.ASSET_TYPE_FINAL_MED_DIPLOMA WITH SECURITY_ENFORCED LIMIT 1];
            return epicAsset;
        }
        catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
}