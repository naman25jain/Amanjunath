public class CaseStatusUpdateEmailInvocable {

    @InvocableMethod(label='Case Status Update Email' 
                     description='Sends case status update email.' 
                     category='Email')
    public static void caseStatusUpdateEmail(List<EmailDetail> emailDetails) {
        try 
        {
            for(EmailDetail detail: emailDetails) 
            {
                EmailHelper.caseStatusUpdateEmail(detail.caseId, detail.templateName, detail.senderAddress);
            }
        }
        catch(Exception e)
        {
            System.debug(Logginglevel.ERROR, 'Unable to send case status update email-Invocable' + e.getMessage());
            throw e; 
        }
    }

    public class EmailDetail {
        @InvocableVariable(required=true)
        public Id caseId;
        
        @InvocableVariable(required=true)
        public string templateName;
        
        @InvocableVariable(required=true)
        public string senderAddress;
    }
}