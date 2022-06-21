@IsTest
public class VerificationMethodAffirmationValidTest{
	@IsTest
    public static void testVerificationMeth(){
        Case c = new Case();
        c.Internal_Status__c = Constants.CASE_STATUS_PENDING_VER_REVIEW;
        c.RecordTypeId = Constants.CVRECORDTYPEID;
        INSERT c;
        System.assert(c.Id != null, 'Case insert failed');
        Map<String, Object> mapValues = new Map<String, Object>();
        mapValues.put('Verification_response_is_in_English__c', 'No; Acceptable translation obtained');
        mapValues.put('Case__c', String.valueOf(c.Id));
        Affirmation_Validation__mdt mdtValidation = Affirmation_Validation__mdt.getInstance('Verification_Evaluation_Screen_2');
        Test.startTest();
        VerificationMethodAffirmationValidation vfMethVal = new VerificationMethodAffirmationValidation();
        String errorMsg = vfMethVal.process(mdtValidation, mapValues);
        System.assert(!String.isBlank(errorMsg), 'No error message is not returned');
        Test.stopTest();
    }
}