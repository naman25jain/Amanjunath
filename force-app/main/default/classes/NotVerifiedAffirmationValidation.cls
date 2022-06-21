// Class holds method to check custom validation for Not_Verified_Screen_1
public inherited sharing class NotVerifiedAffirmationValidation implements AffirmationValidationInterface{
    public string process(Affirmation_Validation__mdt mdtValidation, Map<String, Object> mapValues){
        string errorMsg = '';        
        try{
            if(mapValues.containsKey('Not_Verified_Next_Step__c')){
                string returnMsg = '';
                string[] portalNextAction = (Label.Not_Verified_Status_Portal).split(',');
                if(portalNextAction.contains(string.valueof(mapValues.get('Not_Verified_Next_Step__c')))){
                    returnMsg = AffirmationValidationUtility.checkPortal(string.valueof(mapValues.get('Case__c')));
                    if(string.isNotBlank(returnMsg) && returnMsg!='SUCCESS'){
                        errorMsg += returnMsg + '@';
                    }
                }
            }
            return errorMsg;
        }catch(Exception ex){
            throw ex;
        }
    }
}