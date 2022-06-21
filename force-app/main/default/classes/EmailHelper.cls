/**
 * Sampath Karnati
 * * Helper class to send email from apex
 * ? Exposed as Public
 */
public with sharing class EmailHelper {
    
    public static boolean caseStatusUpdateEmail(Id caseId, string templateName, string senderAddress) {
        try 
        {
            Case emailDetails  = [SELECT Id, Internal_Status__c, Contact.Id, contact.Name, contact.Email, ECFMG_Portal_Case_Url__c
                                   FROM Case 
                                   WHERE Id =: caseId
                                   WITH SECURITY_ENFORCED];
        
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setTargetObjectId(emailDetails.Contact.Id);

            EmailTemplate emailTemplate = [SELECT Id, HtmlValue
                                            FROM EmailTemplate 
                                            WHERE DeveloperName =: templateName
                                            WITH SECURITY_ENFORCED];
            message.setTemplateID(emailTemplate.Id);

            List<OrgWideEmailAddress> orgWideAddress  = [SELECT Id 
                                                        FROM OrgWideEmailAddress 
                                                        WHERE displayname =: senderAddress
                                                        WITH SECURITY_ENFORCED];
            message.setOrgWideEmailAddressId(orgWideAddress[0].Id);   

            String htmlBody = emailTemplate.HtmlValue;
            htmlBody = htmlBody.replace('{!Case.Internal_Status__c}', emailDetails.Internal_Status__c);
            htmlBody = htmlBody.replace('{!Case.Contact}', emailDetails.contact.Name);
            htmlBody = htmlBody.replace('[Link]', '<a href="' + getCasePortalUrl(emailDetails.ECFMG_Portal_Case_Url__c, emailDetails.Contact.Id) + '">here</a>');
            htmlBody = htmlBody.replaceAll('<!\\[CDATA\\[', '');
            htmlBody = htmlBody.replaceAll('\\]\\]>', '');

            message.setHtmlBody(htmlBody);
            message.toAddresses = new String[] {emailDetails.contact.Email};

            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

            if (results[0].success) 
            {
                return true;
            } 
            else 
            {
                System.debug('Unable to send case status update email: ' +  results[0].errors[0].message);
                return false;
            }
        }
        catch(Exception e)
        {
            System.debug(Logginglevel.ERROR, 'Unable to send case status update email' + e.getMessage());
            throw e; 
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public static string getCasePortalUrl(string ecfmgPortalCaseUrl, Id contactId) {
        try 
        {
            string casePortalUrl = ecfmgPortalCaseUrl;
            // Default: For Contact Record Type Applicant, return the full url with case id appended to it (my cases tab exists)

            Contact contactRecord = [SELECT Id, RecordType.Name
                                      FROM Contact 
                                      WHERE Id =: contactId
                                      WITH SECURITY_ENFORCED];

            // For Contact Record Type Registered User, format the url to redirect the user to home page becaause my cases tab doesn't exists
            if(contactRecord.RecordType.Name == Constants.CONTACT_RECORD_TYPE_REG_USR) {
                casePortalUrl = casePortalUrl.substring(0, casePortalUrl.indexOf('/s'));
            }
            
            return casePortalUrl;
        }
        catch(Exception e)
        {
            System.debug(Logginglevel.ERROR, 'Unable to get case portal url' + e.getMessage());
            throw e; 
        }

    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Generates email by replacing the values.
    public static Messaging.SingleEmailMessage sendEmail(EmailWrapperClass emailWrapper){
        try{
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            string emailBody = emailWrapper.emailTemplate.Body;
            for(string key:emailWrapper.replaceMap.keyset()){
                emailBody = emailBody.replace(key,emailWrapper.replaceMap.get(key));
            }
            message.setPlainTextBody(emailBody);
            if(!(emailWrapper.toAddress).isEmpty()){
                message.setToAddresses(emailWrapper.toAddress);
            }
            if(string.isNotBlank(emailWrapper.sender)){
                message.setOrgWideEmailAddressId(emailWrapper.sender);
            }
            message.setSubject(emailWrapper.emailTemplate.Subject);
            return message;
        }
        catch(Exception ex){
            throw ex;
        }
    }
    // Stores email details
    public class EmailWrapperClass{
        // Stores email template
        public EmailTemplate emailTemplate{get;set;}
        // Stores replacement key value
        public map<string,string> replaceMap{get;set;}
        // Stores to address
        public List<string> toAddress{get;set;}
        // Stores sender id
        public Id sender{get;set;}
    }
}