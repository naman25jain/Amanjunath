// Send Verification Report
public with sharing class SendVerificationReportEmail{    
    @InvocableMethod(label='Send EPIC Verification Report' 
                     description='Triggers EPIC verification Report' 
                     category='Email')
    // This method is called from flow to trigger WPIC Verification Report
    public static void sendEmail(List<EmailDetail> emailDetails){
        try{
            EmailTemplate emailTemplate = [SELECT Id,Body,Subject FROM EmailTemplate WHERE DeveloperName =: Constants.EMAIL_TEMPLATE_ONE_TIME_EPIC_VR];
            OrgWideEmailAddress addr  = [SELECT Id FROM OrgWideEmailAddress WHERE displayname =: Constants.ORG_WIDE_ADDRESS];
            Map<string,string> replaceMap = new Map<string,string>();
            List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
            for(EmailDetail emailDetail:emailDetails){
                replaceMap.put('[!NAME]',emailDetail.contactName);
                replaceMap.put('[!DOCUMENT_TYPE]',emailDetail.documentType);
                replaceMap.put('[!APPLICANT_DOCUMENT_TYPE]',emailDetail.appDocumentName);
                EmailHelper.EmailWrapperClass emailWrap = new EmailHelper.EmailWrapperClass();
                emailWrap.emailTemplate = emailTemplate;
                emailWrap.replaceMap = replaceMap;
                emailWrap.sender = addr.Id;
                emailWrap.toAddress = (emailDetail.recipient).split(',');
                messages.add(EmailHelper.sendEmail(emailWrap));
            }
            if(!messages.isEmpty()){
                Messaging.sendEmail(messages);
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }
    // Input wrapper class to store email details
    public class EmailDetail{
        @InvocableVariable(required=true)
        public string recipient;
        @InvocableVariable(required=true)
        public string contactName;
        @InvocableVariable(required=true)
        public string documentType;
        @InvocableVariable(required=true)
        public string appDocumentName;
    }
}