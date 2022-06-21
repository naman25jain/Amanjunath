//Class to do validation during Returned Medical Education Form method evaluation
public class RetMedEduMethodAffirmationValidation implements AffirmationValidationInterface{
    public string process(Affirmation_Validation__mdt mdtValidation, Map<String, Object> mapValues){
        string errorMsg = '';        
        try{
            if(mapValues.containsKey('Responses_are_in_English__c')){
                String verRespone = String.valueOf(mapValues.get('Responses_are_in_English__c'));
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