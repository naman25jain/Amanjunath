/**
    * @author: Femi
    * @name: ExamRegistrationTriggerHepler
    * @description: Helper class for ExamRegistrationTrigger
    * @createdDate: 28-Apr-2020
**/
public with sharing class ExamRegistrationTriggerHepler {
    /* 28 Apr 2020
    * Created by Femi
    * Method Name: sendWithheldNotification
    * Purpose :send notification to applicant on score withheld
    * 
   */
   public static void sendWithheldNotification(List<Exam_Registration__c> newList, Map<Id, Exam_Registration__c> oldMap ){
       List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
       Id orgWideId;
       List<OrgWideEmailAddress> addr  = [select Id from OrgWideEmailAddress where displayname =: Constants.ORG_WIDE_ADDRESS];
       EmailTemplate emailTemplate = [Select Id, Subject, Description, HtmlValue, DeveloperName, Body from EmailTemplate where DeveloperName =: Constants.SCORE_WITHHELD_EMAIL_TEMPLATE_NAME];
       if(!addr.isEmpty()){
           orgWideId = addr[0].Id;
       }
       for(Exam_Registration__c examReg : newList){
           if(orgWideId != null && examReg.Withheld_Score__c == true && examReg.Withheld_Reason__c != null && examReg.Withheld_Reason__c != oldMap.get(examReg.Id).Withheld_Reason__c && (examReg.Withheld_Reason__c.contains(Constants.SCORE_WITHHELD_REASON_ENROLLMENT_REVERIFICATION) || examReg.Withheld_Reason__c.contains(Constants.SCORE_WITHHELD_REASON_ID_VERIFICATION))){
               Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
               message.setTemplateID(emailTemplate.Id);
               message.setSubject(emailTemplate.Subject);
               message.setTargetObjectId(examReg.Applicant__c);
               message.setOrgWideEmailAddressId(orgWideId);
               String htmlBody = emailTemplate.HtmlValue;
               htmlBody = htmlBody.replace('[reason]', examReg.Withheld_Reason__c.replace(';WH by NBME',''));
               htmlBody = htmlBody.replaceAll('\\]\\]>', '');
               message.setHtmlBody(htmlBody);
               mails.add(message);
           }
       }
       if(!mails.isEmpty()){
           try{
               Messaging.sendEmail(mails);
           }
           catch(Exception e){
               System.debug('Exception caught.'+e.getMessage());
           } 
       }  
   }
   
   /* 29 Apr 2020
   * Created by Femi
   * Method Name: createScoreReportCase
   * Purpose :Create score report case on score withheld due to request from NBME
   * 
   */
   public static void createScoreReportCase(List<Exam_Registration__c> newList, Map<Id, Exam_Registration__c> oldMap ){
       Group grp = [SELECT Id, name, Group.DeveloperName FROM Group WHERE Type = 'Queue'
           and Group.DeveloperName =: Constants.CASE_QUEUE_SCORE_REPORTS];
       List<Exam_Registration__c> listToUpdate = new List<Exam_Registration__c>();
       Id sRCaseRecordTypeId   =   Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_SCORE_REPORT).getRecordTypeId();
       List<Case> caseListToUpdate = new List<Case>();
       for(Exam_Registration__c examReg : newList){
        if(examReg.Withheld_Score__c == true && examReg.Withheld_Reason__c != oldMap.get(examReg.Id).Withheld_Reason__c && examReg.Withheld_Reason__c !=null && examReg.Withheld_Reason__c.contains(Constants.SCORE_WITHHELD_REASON_REQUESTED_BY_NBME)){
              listToUpdate.add(examReg);
           }
       }  
       if(!listToUpdate.isEmpty()){
           Map<String, Case> caseMap = getexistingScoreReportCases(listToUpdate);
           for(Exam_Registration__c examReg : listToUpdate){
               if(caseMap.get(examReg.Id) == null){
                   Case scoreReportCase = new Case();
                   scoreReportCase.Exam_Registration__c = examReg.Id;
                   scoreReportCase.Internal_Status__c = Constants.CASE_STATUS_NEW;
                   scoreReportCase.RecordTypeId = sRCaseRecordTypeId;
                   scoreReportCase.ContactId = examReg.Applicant__c;
                   scoreReportCase.OwnerId = grp.Id;
                   caseListToUpdate.add(scoreReportCase);
               }
           }

       }
       if(!caseListToUpdate.isEmpty()){
           try {
               Insert caseListToUpdate;
           } catch (Exception e) {
               system.debug(e);
           }

       }
   }
   /* 29 Apr 2020
   * Created by Femi
   * Method Name: getexistingScoreReportCases
   * Purpose :Get already existing score report cases
   * 
   */
   public static Map<String, Case> getexistingScoreReportCases(List<Exam_Registration__c> listToUpdate){
       Map<String, Case> caseMap = new Map<String, Case>();
       Id sRCaseRecordTypeId   =   Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_SCORE_REPORT).getRecordTypeId();
       List<Case> existingCase = [SELECT id,Exam_Registration__c FROM Case where Exam_Registration__c in:listToUpdate AND RecordTypeId =:sRCaseRecordTypeId AND Internal_Status__c =: Constants.CASE_STATUS_NEW];
       if(!existingCase.isEmpty()){
           for(case sRcase: existingCase){
               caseMap.put(sRcase.Exam_Registration__c, sRcase);
           }  
       }
       return caseMap;
   }

   /* 
   * Created by Jofrin
   * Method Name: updateScoreReportCase
   * Purpose :Get already existing score report cases
   * 
   */
   public static void updateScoreReportCase(List<Exam_Registration__c> newList, Map<Id, Exam_Registration__c> oldMap){
       
       List<Case> existingCase = new List<Case>();
       List<Case> toBeUpdatedCasesList = new List<Case>();
       List<Exam_Registration__c> updatedList = new List<Exam_Registration__c>();
      
       for(Exam_Registration__c examReg : newList){
           if(examReg.Withheld_Score__c == true && !(String.isEmpty(examReg.Score_report_Document_id__c)) && examReg.Score_report_Document_id__c != oldMap.get(examReg.Id).Score_report_Document_id__c && examReg.Withheld_Reason__c.contains(Constants.SCORE_WITHHELD_REASON_REQUESTED_BY_NBME)){
               updatedList.add(examReg);
           }
       }
       if(!updatedList.isEmpty()){
           existingCase= [SELECT id,Exam_Registration__c,RecordType.DeveloperName FROM Case where Exam_Registration__c in:updatedList AND RecordType.DeveloperName=:Constants.CASE_RECORD_TYPE_SCORE_REPORT];
       }
       if(!existingCase.isEmpty()){
           for(Case toBeUpdatedCases: existingCase){
               toBeUpdatedCases.Internal_Status__c = Constants.CASE_STATUS_PENDING_REVIEW;
               toBeUpdatedCasesList.add(toBeUpdatedCases);
           }
       }
       if(!toBeUpdatedCasesList.isEmpty()){
           try {
               Update toBeUpdatedCasesList;
           } catch (Exception e) {
               system.debug(e);
           }
       }
   }
       
   /* 
   * Created by Jofrin
   * Method Name: caseCompletion
   * Purpose :Get already existing score report cases
   * 
   */
   public static void caseCompletion(List<Exam_Registration__c> newList, Map<Id, Exam_Registration__c> oldMap){
   
       List<Exam_Registration__c> uncheckedWithheldList = new List<Exam_Registration__c>();
       List<Exam_Registration__c> uncheckedWithheldUpdatedExamList = new List<Exam_Registration__c>();
       List<Id> uncheckedWithheldUpdatedList = new List<Id>();
       List<Case> existingCase = new List<Case>();
       List<Case> toBeUpdatedCasesList = new List<Case>();

       for(Exam_Registration__c examReg : newList){
           if(examReg.Withheld_Score__c == false && examReg.Withheld_Score__c != oldMap.get(examReg.Id).Withheld_Score__c){
               uncheckedWithheldList.add(examReg);
           }
       }
       
       if(!uncheckedWithheldList.isEmpty()){
           existingCase= [SELECT id,Exam_Registration__c,RecordType.DeveloperName,Exam_Registration__r.Withheld_Reason__c FROM Case where Exam_Registration__c in:uncheckedWithheldList AND RecordType.DeveloperName=:Constants.CASE_RECORD_TYPE_SCORE_REPORT];
       }
       if(!existingCase.isEmpty()){
           for(Case toBeUpdatedCases: existingCase){
               toBeUpdatedCases.Internal_Status__c = Constants.CASE_STATUS_ENROLLMENT_COMPLETED;
               toBeUpdatedCasesList.add(toBeUpdatedCases);
               uncheckedWithheldUpdatedList.add(toBeUpdatedCases.Exam_Registration__c);
           }
       }
       if(!uncheckedWithheldUpdatedList.isEmpty()){
           List<Exam_Registration__c> uncheckedWithheldExamRegList = new List<Exam_Registration__c>([Select id,Applicant__c,Applicant__r.Name,Withheld_Reason__c from Exam_Registration__c where id in :uncheckedWithheldUpdatedList]);
           for(Exam_Registration__c toUpdateExam: uncheckedWithheldExamRegList){
               toUpdateExam.Withheld_Reason__c = '';
               uncheckedWithheldUpdatedExamList.add(toUpdateExam);
           }
       }
       if(!toBeUpdatedCasesList.isEmpty()){
           try {
               sendCompletedNotification(uncheckedWithheldUpdatedExamList);
               Update toBeUpdatedCasesList;
               Update uncheckedWithheldUpdatedExamList;
           } catch (Exception e) {
               system.debug(e);
           }
       }
   }

    /* 
     * Created by Jofrin
     * Method Name: sendCompletedNotification
     * Purpose :send notification to applicant on score report case completed status
    */
    public static void sendCompletedNotification(List<Exam_Registration__c> uncheckedWithheldUpdatedExamList){
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Id orgWideId;
        List<OrgWideEmailAddress> addr  = [select Id from OrgWideEmailAddress where displayname =: Constants.ORG_WIDE_ADDRESS];
        EmailTemplate emailTemplate = [Select Id, Subject, Description, HtmlValue, DeveloperName, Body from EmailTemplate where DeveloperName =: Constants.CASE_EMAIL_TEMPLATE_NAME];
        if(!addr.isEmpty()){
            orgWideId = addr[0].Id;
        }
        for(Exam_Registration__c examReg : uncheckedWithheldUpdatedExamList){
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setTemplateID(emailTemplate.Id);
                message.setSubject(emailTemplate.Subject);
                message.setTargetObjectId(examReg.Applicant__c);
                message.setOrgWideEmailAddressId(orgWideId);
                String htmlBody = emailTemplate.HtmlValue;
                htmlBody = htmlBody.replaceAll('\\]\\]>', '');
                htmlBody = htmlBody.replace('{!Case.Internal_Status__c}', Constants.CASE_STATUS_ENROLLMENT_COMPLETED);
                htmlBody = htmlBody.replace('{!Case.Contact}', examReg.Applicant__r.Name);
                message.setHtmlBody(htmlBody);
                mails.add(message);
        }
        if(!mails.isEmpty()){
            try{
                Messaging.sendEmail(mails);
            }
            catch(Exception e){
                System.debug('Exception caught.'+e.getMessage());
            } 
        }  
    }
    public static void updateCaseRecs(List<Exam_Registration__c> newList, Map<Id, Exam_Registration__c> oldMap, Boolean isInsert, Boolean isUpdate){
        Id examregRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        Set<Id> caseIds = new Set<Id>();
	    List<Case> caseToUpdate = new List<Case>();
	    for(Exam_Registration__c examReg : newList){
            if(String.isNotBlank(examReg.Exam_Status__c) && ((isInsert) || (isUpdate && oldMap.get(examReg.Id).Exam_Status__c != examReg.Exam_Status__c))){
                caseIds.add(examReg.Case__c);
            }
        }
        for(Case newCase : [SELECT Id, Is_Removed_From_EV__c, Enrollment_Verification_Parent__r.Enrolled_in_Entity_Portal__c 
                            FROM Case 
                            WHERE RecordTypeId =:examregRecordTypeId AND Id IN :caseIds]){
            if(newCase.Enrollment_Verification_Parent__r.Enrolled_in_Entity_Portal__c == true){
                newCase.Is_Removed_From_EV__c = TRUE;
                caseToUpdate.add(newCase);
            }
        }
        if(!caseToUpdate.isEmpty()){
            UPDATE caseToUpdate;
        }
    }

    /* 
    * Created by Varsha Hariharan
    * Method Name: updateDegreeSchool
    * Purpose :Update the record with Degree Medical School
    * 
    */
    public static void updateDegreeSchool(Map<Id, Exam_Registration__c> oldMap, List<Exam_Registration__c> newList){
        Set<Id> contactSet = new Set<Id>(); 
        List<Id> contactSetToSend = new List<Id>(); 
        Map<Id, Id> mapExamRegToCon = new Map<Id, Id>();
        for(Exam_Registration__c loopRec : newList){
            if(loopRec.Posted_Date__c != NULL && loopRec.Posted_Date__c != oldMap.get(loopRec.Id).Posted_Date__c){
                contactSet.add(loopRec.Applicant__c);
                mapExamRegToCon.put(loopRec.Applicant__c, loopRec.Id);
            }
            if(contactSet.size() > 0){
                contactSetToSend.addAll(contactSet);
                updateRecs(contactSetToSend, mapExamRegToCon);
            }
        }      
    }
        
    public static void updateRecs(List<Id> contRecs, Map<Id, Id> mapRecs){
        List<Contact_Association_Type__c> recordsList = new List<Contact_Association_Type__c>();
        List<Exam_Registration__c> recsToUpdate = new List<Exam_Registration__c>();
        Id degMedSchoolId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
        recordsList = [Select Id, Account__c, Contact__c, Student_ID__c from Contact_Association_Type__c where RecordTypeId =: degMedSchoolId AND Contact__c =: contRecs];
        if(recordsList.size() > 0){
            for(Contact_Association_Type__c rec : recordsList){
                Exam_Registration__c recToAdd = new Exam_Registration__c();
                recToAdd.Id = mapRecs.get(rec.Contact__c);
                recToAdd.Degree_Medical_School__c = rec.Account__c;
                recToAdd.Unique_Medical_School_ID__c = rec.Student_ID__c;
                recsToUpdate.add(recToAdd);
            }
        }
        if(recsToUpdate.size() > 0){
            update recsToUpdate;
        }
    }

}