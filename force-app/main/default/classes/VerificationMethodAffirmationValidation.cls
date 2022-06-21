//Class to do validation during verification method evaluation
public class VerificationMethodAffirmationValidation implements AffirmationValidationInterface{
    public string process(Affirmation_Validation__mdt mdtValidation, Map<String, Object> mapValues){
        string errorMsg = '';        
        try{
            if(mapValues.containsKey('Verification_response_is_in_English__c')){
                String verRespone = String.valueOf(mapValues.get('Verification_response_is_in_English__c'));
                if(verRespone == 'No; Acceptable translation obtained'){
                    errorMsg = AffirmationValidationUtility.checkTranslationFilled(string.valueof(mapValues.get('Case__c')));
                }
            }
            return errorMsg;
        }catch(Exception ex){
            throw ex;
        }
    }
}