public inherited sharing class DocNotAccForClientValidation implements AffirmationValidationInterface{
    public string process(Affirmation_Validation__mdt mdtValidation, Map<String, Object> mapValues){
        string errorMsg = '';        
        try{
            if(mapValues.containsKey('Document_is_not_acceptable_for_the_Clien__c')){
                string returnMsg = '';
                returnMsg = AffirmationValidationUtility.checkDocNotAccForClient(mapValues);
                if(string.isNotBlank(returnMsg) && returnMsg!='SUCCESS'){
                    errorMsg += returnMsg + '@';
                }
            }
            return errorMsg;
        }catch(Exception ex){
            throw ex;
        }
    }
}