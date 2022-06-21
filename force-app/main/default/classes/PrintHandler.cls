/**
 * Sampath Karnati
 * * Common Print Utils (Print means sending an email with attachment to printer)
 * ? Exposed as Public
 */
public with sharing class PrintHandler {

    static final String EMAIL_BODY = 'Please see attached';
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public class PrintDocumentCall implements Queueable, Database.AllowsCallouts {
        
        List<AssetPrintDetail> assetPrintDetails;
        Id orgWideEmailAddress;

       public PrintDocumentCall(List<AssetPrintDetail> assetPrintDetails){
           this.assetPrintDetails = assetPrintDetails;
       }
       public void execute(System.QueueableContext ctx) { 
            try 
            {
                Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();

                List<OrgWideEmailAddress> orgWideAddress  = [SELECT Id 
                                                            FROM OrgWideEmailAddress 
                                                            WHERE displayname =: Constants.ORG_WIDE_ADDRESS
                                                            WITH SECURITY_ENFORCED];

                if (orgWideAddress.size() > 0) {
                    this.orgWideEmailAddress = orgWideAddress[0].Id;
                }

                for(AssetPrintDetail assetPrintDetail : assetPrintDetails)
                {
                    // Get document
                    HttpResponse response = CommonUtils.getDocumentFromAzure(assetPrintDetail.documentUrl);

                    if (response.getStatusCode() == 200) {
                        String document = EncodingUtil.base64Encode(response.getBodyAsBlob());

                        // Get the blob from base64
                        Blob documentBlob = EncodingUtil.base64Decode(document);

                        // Build EMail Message
                        Messaging.SingleEmailMessage message = emailMessage(assetPrintDetail.printerName, 
                                                                            assetPrintDetail.caseId, 
                                                                            EMAIL_BODY);
  
                        // Attach document to email
                        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
                        attachments.add(attachment(CommonUtils.getFileNameFromUrl(assetPrintDetail.documentUrl),
                                                   documentBlob,
                                                   Constants.PDF_CONTENT_TYPE));

                        // message attachment                           
                        message.setFileAttachments(attachments);

                        // Message collection
                        messages.add(message);

                    }
                }

                // Send Email
                sendEmail(messages);
             
            } catch (Exception e) {
                throw e;
            }

       }
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        private Messaging.SingleEmailMessage emailMessage(String toAddress, String subject, String body) {
            try 
            {
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setToAddresses(new String[] { toAddress });
                message.setSubject('Case - ' + subject);
                message.setHTMLBody(body);
                message.setOrgWideEmailAddressId(this.orgWideEmailAddress); 

                return message;
            } catch (Exception e) {
                throw e;
            }
        }
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        private Messaging.EmailFileAttachment attachment(String fileName, Blob body, String contentType) {
            try 
            {
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName(fileName);
                attachment.setBody(body);
                attachment.setContentType(contentType);

                return attachment;

            } catch (Exception e) {
                throw e;
            }
        }
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        private boolean sendEmail(Messaging.SingleEmailMessage[] messages) {
            try 
            {  
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
               
                if (results[0].success) 
                {
                    return true;
                } 
                else 
                {
                    System.debug('Unable to send email: ' +  results[0].errors[0].message);
                    return false;
                }
            }
            catch(Exception e)
            {
                throw e; 
            }
        }
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   }
  
    
}