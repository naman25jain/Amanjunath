/**
    * @author: Femi
    * @name: ContentDocumentLinkTriggerHelper
    * @description: Helper class for ContentDocumentLinkTrigger
    * @createdDate: 28-May-2020
**/
public with sharing class ContentDocumentLinkTriggerHelper {
    /**
    * 28 May 2020
    * Created by Femi
    * Method Name: createAssetFromFile
    * Purpose : To create Asset from conga created documents in cases
    */
    public static void createAssetFromFile(List<ContentDocumentLink> contentList){
        List<ContentDocumentLink> conList = new List<ContentDocumentLink>();
        for(ContentDocumentLink att : contentList){
            if(att.LinkedEntityId.getSobjectType() == Case.SobjectType){
                conList.add(att);
            }
        }
        for(ContentDocumentLink atts : conList){
            Case cse = [SELECT id, contactId, recordType.DeveloperName FROM CASE Where id =: atts.LinkedEntityId];
            if(cse.recordType.DeveloperName == Constants.CASE_RECORD_TYPE_SCORE_RECHECK || cse.recordType.DeveloperName == Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION || cse.recordType.DeveloperName == Constants.CASE_RECORD_TYPE_ENROLLMENT_REVERIFICATION){
                createScoreRecheckResponseAsset(atts, cse);
            }
            if(cse.recordType.DeveloperName == Constants.CASE_RECORD_TYPE_IFOM_REQUEST || cse.recordType.DeveloperName == Constants.CASE_RECORD_TYPE_ENTITY_USER_REQUEST){
                createScoreRecheckResponseAsset(atts, cse);
            }
        }
    }
    /**
    * 28 May 2020
    * Created by Femi
    * Method Name: createScoreRecheckResponseAsset
    * Purpose : To create score recheck response Asset from conga created documents in cases
    */
    public static void createScoreRecheckResponseAsset(ContentDocumentLink cont, Case c){
        ContentVersion conVer = [Select Title,VersionData From ContentVersion where ContentDocumentId =:cont.ContentDocumentId];
        Asset response = new Asset();
        String attchName = '';
        response.ContactId = c.contactId;
        response.Case__c = cont.LinkedEntityId;
        if(conVer.Title.contains('EV Deficiency Cover')){
            response.Name = 'Enrollment Re-Verification Deficiency Cover Letter';
            response.type__c = 'EV Deficiency Cover Letter';
            response.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION).getRecordTypeId();
        }
        if(conVer.Title.contains('Score Recheck')){
            attchName = 'Score Recheck Letter.docx';
            response.Name = 'Score Recheck Letter';
            response.type__c = 'Score Recheck Letter';
            response.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        }
        else if(conVer.Title.contains('Enrollment Paper Template')){
            response.Name = 'Enrollment Verification';
            response.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION).getRecordTypeId();
        }
        else if(conVer.Title.contains('Scheduling Permit Template')){
            attchName = 'Scheduling Permit.docx';
            response.Name = 'Scheduling Permit';            
            response.type__c = 'Scheduling Permit';
            response.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        }
        else if(conVer.Title.contains('User Signature Form')){
            response.type__c = 'Signature Template';
            response.Status = 'In Progress';
            response.Name = 'Entity Portal User Signature Form';
            response.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_ENTITY_DOC).getRecordTypeId();
        }
        else{
            return;
        }
        insert response;
        
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = response.Id;
        conDocLink.ContentDocumentId = cont.ContentDocumentId;
        conDocLink.shareType = 'V';
        insert conDocLink;
        
        if(conVer.Title.contains('Scheduling Permit Template') || conVer.Title.contains('Score Recheck')){
            case newCase = [Select id, Internal_Status__c, Contact.Id, contact.Name, recordType.DeveloperName, ECFMG_Portal_Case_Url__c, parentId from Case where Id =: cont.LinkedEntityId];
            Contact contactEmail = [Select Id, Email, Name from Contact where Id =: newCase.Contact.Id];
            
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setTargetObjectId(newCase.ContactId);
            EmailTemplate emailTemplate = [Select Id, Subject, Description, HtmlValue, DeveloperName, Body from EmailTemplate where DeveloperName =: Constants.CASE_EMAIL_TEMPLATE_NAME];
            message.setTemplateID(emailTemplate.Id);
            
            List<OrgWideEmailAddress> addr  = [select Id from OrgWideEmailAddress where displayname =: Constants.ORG_WIDE_ADDRESS];
            message.setOrgWideEmailAddressId(addr[0].Id);
            String htmlBody = emailTemplate.HtmlValue;
            htmlBody = htmlBody.replace('{!Case.Internal_Status__c}', newCase.Internal_Status__c);
            htmlBody = htmlBody.replace('{!Case.Contact}', contactEmail.Name);
            htmlBody = htmlBody.replace('[Link]', '<a href="' + newCase.ECFMG_Portal_Case_Url__c + '">Case Status</a>');
            
            htmlBody = htmlBody.replaceAll('<!\\[CDATA\\[', '');
            htmlBody = htmlBody.replaceAll('\\]\\]>', '');
            
            message.setHtmlBody(htmlBody);
            
            Blob tempBlob = conVer.VersionData;
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setBody(tempBlob);
            efa.setFileName(attchName);
            message.setFileAttachments(new Messaging.EmailFileAttachment[] {
                efa
                    });
            message.toAddresses = new String[] {
                 contactEmail.Email
                    };
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage > {
                    message
                    };
            try {
                    Messaging.sendEmail(messages);
            } catch (Exception e) {
                    system.debug(e);
            }
        }
        
        ContentDocumentLink doc = [Select id From ContentDocumentLink where id=:cont.Id];
        delete doc;
    }
}