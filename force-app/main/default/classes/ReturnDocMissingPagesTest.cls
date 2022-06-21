@IsTest
public with sharing class ReturnDocMissingPagesTest{
    @IsTest
    public static void testCredReturnVerificationSuccess(){
        string strScreenName = 'Credential_Returned_with_verification';
        Map<String, Object> mapValues = new Map<String, Object>();
        mapValues.put('Returned_credential_complete_and_legible__c', 'No');
        mapValues.put('Ret_cred_same_sent_for_verif__c', 'Yes');
        mapValues.put('Returned_document_is_cut_off__c', 'true');
        mapValues.put('Returned_document_is_missing_pages__c', 'false');
        Affirmation_Validation__mdt mdtValidation = Affirmation_Validation__mdt.getInstance(strScreenName);
        Test.startTest();
        ReturnDocMissingPages returnDocMissingPages = new ReturnDocMissingPages();
        String errorMsg = returnDocMissingPages.process(mdtValidation, mapValues);
        System.assert(String.isBlank(errorMsg), '');
        Test.stopTest();
    }
    @IsTest
    public static void testCredReturnVerificationFailure(){
        string strScreenName = 'Credential_Returned_with_verification';
        Map<String, Object> mapValues = new Map<String, Object>();
        mapValues.put('Returned_credential_complete_and_legible__c', 'No');
        mapValues.put('Ret_cred_same_sent_for_verif__c', 'Yes');
        mapValues.put('Returned_document_is_cut_off__c', 'false');
        mapValues.put('Returned_document_is_missing_pages__c', 'false');
        Affirmation_Validation__mdt mdtValidation = Affirmation_Validation__mdt.getInstance(strScreenName);
        Test.startTest();
        ReturnDocMissingPages returnDocMissingPages = new ReturnDocMissingPages();
        String errorMsg = returnDocMissingPages.process(mdtValidation, mapValues);
        System.assert(!String.isBlank(errorMsg), 'Please select one or more checkboxes.@');
        Test.stopTest();
    }
}