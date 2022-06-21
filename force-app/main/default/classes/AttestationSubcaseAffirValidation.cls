public inherited sharing class AttestationSubcaseAffirValidation implements AffirmationValidationInterface{
    public string process(Affirmation_Validation__mdt mdtValidation, Map<String, Object> mapValues){
        string errorMsg = '';        
        try{
            if(mapValues.containsKey('Acknowledgment_complete_and_include_sign__c')){
                string returnMsg2 = '';
                returnMsg2 = AffirmationValidationUtility.acknReasonSelected(mapValues);
                if(string.isNotBlank(returnMsg2) && returnMsg2!='SUCCESS'){
                    errorMsg += returnMsg2 + '@';
                }
            }
            return errorMsg;
        }catch(Exception ex){
            throw ex;
        }
    }
}