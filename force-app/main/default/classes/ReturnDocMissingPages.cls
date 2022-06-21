//Class to do validation during returned verification form affirmations
public inherited sharing class ReturnDocMissingPages implements AffirmationValidationInterface{
    public string process(Affirmation_Validation__mdt mdtValidation, Map<String, Object> mapValues){
        string errorMsg = '';        
        try{
            if(mapValues.containsKey('Returned_document_is_missing_pages__c') || mapValues.containsKey('Returned_document_is_cut_off__c')){
                string returnMsg = '';
                returnMsg = AffirmationValidationUtility.checkReturnDocMissingPages(mapValues);
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