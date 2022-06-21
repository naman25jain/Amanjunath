public without sharing class AfterPaymentLogic{
	@InvocableMethod(label='After Payment Logic')
	public static void execute(List<FlowInputs> flowInputs){
		FlowInputs input = flowInputs[0];
		String caseService = input.caseService;
        switch on caseService {
            when 'Identity Verification' {
                CommunityIdentityVerificationController.makePayment();
            }
            when 'Biographic Change' {
                ApplicantMyProfileController.updateAppBioCaseStatus();
            }
            when 'Application for Certification' {
				AppForCertPayment.afterPaymentCompletion();
            }
            when 'USMLE Exam Registration' {
                ExamRegistrationController.examRegPaymentCompletion();
            }
            when 'Eligibility Period Extension' {
                EPExController.getEPExCaseNumber();
            }
            when 'Region Change' {
                RegionChangeController.regionChangePaymentCompletion();
            }
            when 'Score Rechecks' {
                ScoreReportController.paymentCompletion();
            }
            when 'USMLE Transcripts' {
                TranscriptRequestController.updateCaseStatus();
            }
            when 'Duplicate ECFMG certificate' {
                DupEcfmgCertificateController.paymentCompletion();
            }            
            when 'EPIC Credentials Verification' {
                EpicCredVerController.statusChangeEpicExtract();
                EpicCredVerController.payCompletion();
            }                     
            when 'ERAS Support Services' {
                ERASController.checkERASInternalRestriction();
            }
        }        
	}
	public class FlowInputs{
		@InvocableVariable(required=true)
		public String caseService;
	}
}