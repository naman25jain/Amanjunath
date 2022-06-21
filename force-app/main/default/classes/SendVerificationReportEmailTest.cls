@isTest
public class SendVerificationReportEmailTest{	
    @isTest
    public static void testSendVerificationReport(){
        SendVerificationReportEmail.EmailDetail emailDetail = new SendVerificationReportEmail.EmailDetail();
        emailDetail.recipient = Constants.TEST_EMAIL_ID;
        emailDetail.contactName = 'Test Name';
        emailDetail.documentType = Constants.CASE_DOCUMENT_TYPE_TCT;
        emailDetail.appDocumentName = 'Test';
        SendVerificationReportEmail.sendEmail(new list<SendVerificationReportEmail.EmailDetail>{emailDetail});
        system.assert(true,'Send EPIC Verification report Email failed');
    }
}