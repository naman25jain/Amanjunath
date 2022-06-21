@IsTest
public with sharing class MERSubcaseAffirmValidationTest{
    @IsTest
    public static void testMerSubcaseValid(){
        string strScreenName = 'MER_Subcase_Screen2';
        Map<String, Object> mapValues = new Map<String, Object>();
        mapValues.put('Unable_to_Verify__c', 'No');
        mapValues.put('	Incorrect_Entity__c', 'No');
        mapValues.put('Not_Authentic__c', 'Yes');
        mapValues.put('OtherOpt__c', 'Yes');
        mapValues.put('Additional_comments_Explanation_of_decis__c', '');
        Affirmation_Validation__mdt mdtValidation = Affirmation_Validation__mdt.getInstance(strScreenName);
        Test.startTest();
        MERSubcaseAffirmValidations merCaseValid = new MERSubcaseAffirmValidations();
        String errorMsg = merCaseValid.process(mdtValidation, mapValues);
        System.assert(!String.isBlank(errorMsg), 'No error message is not returned');
        Test.stopTest();
    }
}