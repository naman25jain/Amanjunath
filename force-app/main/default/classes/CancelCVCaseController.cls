public with sharing class CancelCVCaseController{
    //Check the CV case Status
    @AuraEnabled
    public static Case checkCVCaseStatus(String caseId){
        try{
            Case credVerCase = [SELECT Id, Internal_Status__c, Service__c, RecordType.Name FROM Case WHERE Id =: caseId WITH SECURITY_ENFORCED LIMIT 1];
            return credVerCase;
        }catch(Exception e){
            throw new ControllerException(Constants.EXCEPTION_HANDLING_ERROR_MESSAGE + e.getMessage());
        }
    }
    @AuraEnabled
    public static Boolean updateCVCase(Id caseId, String selectedValue, String reason){
        try{
            Case cvCase = [SELECT Id, Internal_Status__c, Service__c, RecordType.DeveloperName, Reason_for_Cancellation__c, OwnerId, ContactEmail, Contact.name, CaseNumber FROM Case WHERE Id =: caseId WITH SECURITY_ENFORCED LIMIT 1];
            String cvStatus = '';
            cvStatus = selectedValue;
            if(cvCase.Service__c == Constants.CASE_SERVICE_EICS || cvCase.Service__c == Constants.CASE_SERVICE_FCVS){
                cvStatus = Constants.CASE_STATUS_CANCELLED;
            }
            cvCase.Internal_Status__c = cvStatus;
            cvCase.Reason_for_Cancellation__c = reason;
            cvCase.OwnerId = UserInfo.getUserId();
            if(Case.SObjectType.getDescribe().isUpdateable() && cvCase.Id != null){
                UPDATE cvCase;
            } 
            Boolean updted = updateCVCaseAssets(cvCase);
            if(cvCase.Service__c != Constants.CASE_SERVICE_EICS && cvCase.Service__c != Constants.CASE_SERVICE_FCVS){
                sendMailOnStatusUpd(cvCase);
            }
            return updted;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static Boolean updateCVCaseAssets(Case cvCase){
        try{
            Boolean updateAssets = false;
            Set<Id> csIds = new Set<Id>();
            List<Case> updateSubcases = new List<Case>();
            csIds.add(cvCase.Id);
            List<Case> cvSubCasesFCVS = [SELECT Id, CaseNumber, RecordType.DeveloperName, Internal_Status__c, OwnerId FROM Case WHERE ParentId =: cvCase.Id AND (RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION OR RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_MED_EDU_FORM) AND Parent.RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_FCVS_REQUEST WITH SECURITY_ENFORCED];
            if(!cvSubCasesFCVS.isEmpty()){
                for(Case cs : cvSubCasesFCVS){
                    cs.Internal_Status__c = Constants.CASE_STATUS_CANCELLED;
                    cs.OwnerId = UserInfo.getUserId();
                    updateSubcases.add(cs);
                    csIds.add(cs.Id);
                }
            }
            if(Case.SObjectType.getDescribe().isUpdateable() && !updateSubcases.isEmpty()){
                UPDATE updateSubcases;
            } 
            updateVerPckt(csIds);
            Id verifAssRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_VERIFICATION).getRecordTypeId();
            Id credAssRecTypeId =  Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_CREDENTIAL).getRecordTypeId();
            Id suppDocAssRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_SUPP_DOCUMENT).getRecordTypeId();
            Id idenAsstRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_IDENTITY).getRecordTypeId();
            Id medformRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_MED_EDU_FORM).getRecordTypeId();
            List<Asset> cvCaseAssets = new List<Asset>();
            List<Asset> cvEICSIdAssets = new List<Asset>();
            cvCaseAssets = [SELECT Id, Status FROM Asset WHERE Case__c IN: csIds AND (RecordTypeId =: verifAssRecTypeId OR RecordTypeId =: credAssRecTypeId OR RecordTypeId =: suppDocAssRecTypeId OR RecordTypeId =: medformRecTypeId) AND Status !=: Constants.ASSET_STATUS_OUTDATED WITH SECURITY_ENFORCED];
            cvEICSIdAssets = [SELECT Id, Status, Type__c FROM Asset WHERE Case__c =: cvCase.Id AND RecordTypeId =: idenAsstRecTypeId AND (Type__c =: Constants.ASSET_TYPE_RELEASE OR Type__c =: Constants.ASSET_TYPE_PHOTO) AND Status !=: Constants.ASSET_STATUS_OUTDATED WITH SECURITY_ENFORCED];
            updateAssets = updateAssets(cvCase, cvCaseAssets, cvEICSIdAssets);
            return updateAssets;
        }catch(Exception e){
            throw new ControllerException(Constants.EXCEPTION_HANDLING_ERROR_MESSAGE + e.getMessage());
        }
    }
    //Refactored updateCVAssets to avoid cyclomatic complexity
    public static void updateVerPckt(Set<Id> csIds){
        List<Verification_Packet__c> updateVpkts = new List<Verification_Packet__c>();
        List<Verification_Packet__c> verPckt = [SELECT Id, Is_Active__c FROM Verification_Packet__c WHERE Case__c IN: csIds AND Is_Active__c = true WITH SECURITY_ENFORCED];
        if(!verPckt.isEmpty()){
            for(Verification_Packet__c vp : verPckt){
                vp.Is_Active__c = false;
                updateVpkts.add(vp);
            }
        }
        if(Verification_Packet__c.SObjectType.getDescribe().isUpdateable() && !updateVpkts.isEmpty()){
            UPDATE updateVpkts;
        }
    }
    // Refactored updateCVCaseAssets method to avoid cyclomatic complexity
    public static Boolean updateAssets(Case cvCase, List<Asset> cvCaseAssets, List<Asset> cvEICSIdAssets){
       List<Asset> updAssts = new List<Asset>();
       for(Asset a : cvCaseAssets){
    		a.Status = Constants.ASSET_STATUS_CANCELLED;
                updAssts.add(a);
       }
       if(cvCase.Service__c == Constants.CASE_SERVICE_EICS && !cvEICSIdAssets.isEmpty()){
            for(Asset asst : cvEICSIdAssets){
                asst.Status = Constants.ASSET_STATUS_CANCELLED;
                updAssts.add(asst);
            }
       }
       if(Asset.SObjectType.getDescribe().isUpdateable() && !updAssts.isEmpty()){
            UPDATE updAssts;
       }
       return true;
    }
    @AuraEnabled
    public static void sendMailOnStatusUpd(Case credCase){
        try{
            EmailTemplate template = [Select Id, Subject, Description, HtmlValue, DeveloperName, Body from EmailTemplate where DeveloperName =: Constants.EMAIL_CASE_STATUS_UPDATE_ON_CV_ACCEPTED]; //Donot add WITH SECURITY_ENFORCED
            List<OrgWideEmailAddress> addr = [Select Id from OrgWideEmailAddress where displayname =: Constants.ORG_WIDE_ADDRESS]; //Donot add WITH SECURITY_ENFORCED
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setTemplateId(template.Id);
            message.setSubject(template.Subject);
            String htmlBody = template.HtmlValue;
            htmlBody = htmlBody.replace('{!Case.Contact}', credCase.Contact.name);
            htmlBody = htmlBody.replace('{!Case.CaseNumber}', credCase.CaseNumber);
            htmlBody = htmlBody.replaceAll('<!\\[CDATA\\[', '');
            htmlBody = htmlBody.replaceAll('\\]\\]>', '');
            message.setHtmlBody(htmlBody);
            message.setOrgWideEmailAddressId(addr[0].Id);
            message.setToAddresses(new String[]{credCase.ContactEmail});
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{message});
        }catch(Exception e){
            throw new ControllerException(Constants.EXCEPTION_HANDLING_ERROR_MESSAGE + e.getMessage());
        }
    }
}