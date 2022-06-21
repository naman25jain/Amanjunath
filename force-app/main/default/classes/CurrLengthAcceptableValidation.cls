public inherited sharing class CurrLengthAcceptableValidation implements AffirmationValidationInterface{
    public string process(Affirmation_Validation__mdt mdtValidation, Map<String, Object> mapValues){
        string errorMsg = '';        
        try{
            if(mapValues.containsKey('Curriculum_Length_Acceptable__c')){
                string returnMsg = '';
                returnMsg = AffirmationValidationUtility.checkCurrLengthAcceptable(mapValues);
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