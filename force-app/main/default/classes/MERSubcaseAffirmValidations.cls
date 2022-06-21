public class MERSubcaseAffirmValidations implements AffirmationValidationInterface{
    public string process(Affirmation_Validation__mdt mdtValidation, Map<String, Object> mapValues){
        String errorMsg = '';
        try{
            if(mapValues.containsKey('OtherOpt__c')){
                errorMsg = AffirmationValidationUtility.markReqdBasedOnPrevAff(mapValues, 'OtherOpt__c', 'Additional_comments_Explanation_of_decis__c');
            }
            return errorMsg;
        }catch(Exception ex){
            throw ex;
        }
    }
}