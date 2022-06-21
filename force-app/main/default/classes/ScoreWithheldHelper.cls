/**
    * @author: Femi
    * @name: ScoreWithheldHelper
    * @description: Helper class for ScoreWithheldCheckTrigger
    * @createdDate: 27-Apr-2020
**/
public with sharing class ScoreWithheldHelper {
    /* 27 Apr 2020
    * Created by Femi
    * Method Name: updateScoreWithheld
    * Purpose :Check for whether score is withheld 
    * 
   */
   public static void updateScoreWithheld(List<NBME_Score_Update_Event__e> eventList){
       Map<String, NBME_Score_Update_Event__e> eventMap = new Map<String, NBME_Score_Update_Event__e>();
       Map<NBME_Score_Update_Event__e, Exam_Registration__c> eventExamRegMap = new Map<NBME_Score_Update_Event__e, Exam_Registration__c>();
       List<String> uSMLEList = new List<String>();
       List<Exam_Registration__c> examRegList = new List<Exam_Registration__c>();
       List<Exam_Registration__c> examRegListToUpdate = new List<Exam_Registration__c>();
       List<Contact> contactList = new List<Contact>();
       
       for(NBME_Score_Update_Event__e ev : eventList){
           String keyValue = ev.USMLE_ID__c + String.valueOf(Integer.valueOf(ev.Application_id__c)) + ev.Exam__c;
           eventMap.put(keyValue, ev); 
           uSMLEList.add(ev.USMLE_ID__c);
       }
       examRegList = [SELECT id, Posted_Date__c ,USMLE_ID_CIBIS__c, Application_Id__c, Applicant__c, Exam__c, Case__c, case__r.Enrollment_Re_Verification_Parent__c, Withheld_Reason__c,Pd_Optout_flag__c,Test_Accommodations__c,Irregularity_Status__c,Exam_Status__c FROM Exam_Registration__c WHERE USMLE_ID_CIBIS__c IN:uSMLEList];
       for(Exam_Registration__c examReg : examRegList) {
           String keyStr = examReg.USMLE_ID_CIBIS__c + String.valueOf(Integer.valueOf(examReg.Application_id__c)) + examReg.Exam__c;
           if(eventMap.get(keyStr) != null){
               examRegListToUpdate.add(examReg);
               eventExamRegMap.put(eventMap.get(keyStr), examReg);
               Contact con = new Contact();
               con.Id = examReg.Applicant__c;
               contactList.add(con);
           }
       }
       createScoreImportErrorRecords(eventList, eventExamRegMap);
       List<Exam_Registration__c> idList = withHeldCheckForIdVerification(examRegListToUpdate);
       List<Exam_Registration__c> reVerList = withHeldCheckForEnrollmentReVerification(examRegListToUpdate);
       List<Exam_Registration__c> nBMEList = withHeldCheckForNBME(eventExamRegMap);
  List<Exam_Registration__c> appRestrictList = withheldApplicantRestricted(examRegListToUpdate);
       Set<Exam_Registration__c> finalUpdateSet = new Set<Exam_Registration__c>();
       finalUpdateSet.addAll(idList);
       finalUpdateSet.addAll(reVerList);
       finalUpdateSet.addAll(nBMEList);
  finalUpdateSet.addAll(appRestrictList);
       List<Exam_Registration__c> finalUpdateList = new List<Exam_Registration__c>();
       finalUpdateList.addAll(finalUpdateSet);
       for(Exam_Registration__c examReg : finalUpdateList){
           String reason = '';
           if(idList.contains(examReg)){
               reason = reasonStringGenerator(reason, Constants.SCORE_WITHHELD_REASON_ID_VERIFICATION);
           }
           if(reVerList.contains(examReg)){
               reason = reasonStringGenerator(reason, Constants.SCORE_WITHHELD_REASON_ENROLLMENT_REVERIFICATION);
           }
           if(nBMEList.contains(examReg)){
               reason = reasonStringGenerator(reason, Constants.SCORE_WITHHELD_REASON_REQUESTED_BY_NBME);
           }
    if(appRestrictList.contains(examReg)){
       reason = reasonStringGenerator(reason, Constants.SCORE_WITHHELD_REASON_APPLICANT_RESTRICTED);
        }
           examReg.Withheld_Reason__c = reason;
           examReg.Withheld_Score__c = true;
           examReg.Posted_Date__c = null;
       }
       eventExamRegMap = updateExamOutcome(eventExamRegMap);
       eventExamRegMap = updatePostedDate(finalUpdateList,examRegListToUpdate,eventExamRegMap);
       updateRemarks(eventExamRegMap,contactList);
       if(!finalUpdateList.isEmpty()){
           try{
               update finalUpdateList;
           }
           catch(Exception e){
               System.debug('Exception caught.'+e.getMessage());
           } 
       }

   }
   public static List<Exam_Registration__c> withheldApplicantRestricted(List<Exam_Registration__c> examRegList){
    List<String> applicantIdList = new List<String>();
    List<Exam_Registration__c> examRegListToUpdate = new List<Exam_Registration__c>();
    for(Exam_Registration__c examReg : examRegList){
        applicantIdList.add(examReg.Applicant__c);
    }
    List<Contact> conServ = [SELECT Id, ServicesRestricted__c FROM Contact WHERE Id IN: applicantIdList AND ServicesRestricted__c = 'Score Reporting - Internal and External' WITH SECURITY_ENFORCED];
    if(!conServ.isEmpty()){
        for(Exam_Registration__c examReg : examRegList){
            if(applicantIdList.contains(examReg.Applicant__c)){
            examRegListToUpdate.add(examReg);
            }
        }
    }
    return examRegListToUpdate;
    }
   /* 27 Apr 2020
    * Created by Femi
    * Method Name: withHeldCheckForIdVerification
    * Purpose :Check for whether score is withheld due to Pending Id verification
    * 
   */
   public static List<Exam_Registration__c> withHeldCheckForIdVerification(List<Exam_Registration__c> examRegList){
       List<Exam_Registration__c> examRegListToUpdate = new List<Exam_Registration__c>();
       List<String> applicantIdList = new List<String>();
       List<String> appIdListUpdateAsset = new List<String>();
       List<String> appIdListUpdateCase = new List<String>();
       List<Case> bioStatChangecase = new List<Case>();
       List<Asset> assetList = new List<Asset>();
       Map<Id, Asset> assetMap =new Map<Id, Asset>();
       
       for(Exam_Registration__c examReg : examRegList) {
           applicantIdList.add(examReg.Applicant__c);
       }
       assetList = [SELECT id, Status, contactId FROM Asset WHERE contactId in:applicantIdList AND Name = 'ID Form Notarized' AND Type__c =:Constants.ASSET_TYPE_IDENTITY_VERIFICATION  AND status != :constants.ASSET_STATUS_MARKED_FOR_DELETION ORDER BY CreatedDate DESC];
       for(Asset idAsset: assetList){
           if(assetMap.get(idAsset.contactId) == null){
             assetMap.put(idAsset.contactId, idAsset);
               if(idAsset.Status != Constants.ASSET_STATUS_VERIFIED){
                   appIdListUpdateAsset.add(idAsset.contactId);
               }
           }
       }
       
       bioStatChangecase = [Select id, contactId From Case Where contactId in:applicantIdList AND Internal_Status__c !=: Constants.CASE_STATUS_ACCEPTED AND Internal_Status__c !=: Constants.CASE_STATUS_REJECTED AND Internal_Status__c !=: Constants.CASE_STATUS_CANCELLED_BY_APPLICANT AND Internal_Status__c !=: Constants.CASE_STATUS_CANCELLED_BY_ECFMG AND recordType.DeveloperName =:Constants.CASE_RECORD_TYPE_APP_BIO_CHANGE];
       for(Case bsCase : bioStatChangecase){
           appIdListUpdateCase.add(bsCase.contactId);
       }
       for(Exam_Registration__c examReg : examRegList) {
           if(appIdListUpdateAsset.contains(examReg.Applicant__c) || appIdListUpdateCase.contains(examReg.Applicant__c)){
               examRegListToUpdate.add(examReg);
           }
       }
       return examRegListToUpdate;
       
   }
   /* 27 Apr 2020
    * Created by Femi
    * Method Name: withHeldCheckForEnrollmentReVerification
    * Purpose :Check for whether score is withheld due to Pending Enrollment Reverification
    * 
   */
   public static List<Exam_Registration__c> withHeldCheckForEnrollmentReVerification(List<Exam_Registration__c> examRegList){
       List<Exam_Registration__c> examRegListToUpdate = new List<Exam_Registration__c>();
       List<Exam_Registration__c> examRegListToReturn = new List<Exam_Registration__c>();
       List<String> examRegIdList = new List<String>();
       List<String> examRegIdListUpdate = new List<String>();
       
       for(Exam_Registration__c examReg : examRegList) {
           examRegIdList.add(examReg.Id);
       }
       examRegListToUpdate = [SELECT  id, Posted_Date__c ,USMLE_ID_CIBIS__c, Application_Id__c, Applicant__c, Exam__c, Case__c, case__r.Enrollment_Re_Verification_Parent__c, Withheld_Reason__c,Pd_Optout_flag__c,Test_Accommodations__c,Irregularity_Status__c,Exam_Status__c FROM Exam_Registration__c where Id in:examRegIdList AND case__r.Enrollment_Re_Verification_Parent__c != null AND case__r.Enrollment_Re_Verification_Parent__r.Internal_Status__c !=: Constants.CASE_STATUS_ENROLLMENT_VERIFIED];
       
       for(Exam_Registration__c examReg : examRegListToUpdate) {
           examRegIdListUpdate.add(examReg.Id);
       }
       for(Exam_Registration__c examReg : examRegList) {
           if(examRegIdListUpdate.contains(examReg.Id)){
               examRegListToReturn.add(examReg);
           }
       }
       return examRegListToReturn;
   }

   /* 27 Apr 2020
    * Created by Femi
    * Method Name: withHeldCheckForEnrollmentReVerification
    * Purpose :Check for whether score is withheld due to request from NBME
    * 
   */
   public static List<Exam_Registration__c> withHeldCheckForNBME(Map<NBME_Score_Update_Event__e, Exam_Registration__c> eventExamRegMap){
       List<Exam_Registration__c> examRegListToUpdate = new List<Exam_Registration__c>();
       for(NBME_Score_Update_Event__e ev : eventExamRegMap.keySet()){
           if((ev.score_report_document_id__c == null || ev.score_report_document_id__c == '') && ev.score_status__c == 'N' && eventExamRegMap.get(ev) != null){
               examRegListToUpdate.add(eventExamRegMap.get(ev));
           }
       }
       return examRegListToUpdate;
   }
  
   /* 28 Apr 2020
    * Created by Femi
    * Method Name: reasonStringGenerator
    * Purpose :Generate the reason string to be updated
    * 
   */
   public static String reasonStringGenerator(String reason, String newValue){
       if(reason == ''){
           reason = newValue;
       }else{
           if(!reason.contains(newValue)){
               reason = reason + ';' + newValue;
           }
           
       }
       return reason;
   }
   /* 28 Apr 2020
    * Created by Femi
    * Method Name: updatePostedDate
    * Purpose : Update the posted date for records which are not in withheld
    * 
   */
   public static Map<NBME_Score_Update_Event__e, Exam_Registration__c> updatePostedDate(List<Exam_Registration__c> finalUpdateList, List<Exam_Registration__c> examRegList,Map<NBME_Score_Update_Event__e, Exam_Registration__c> eventExamRegMap){
       List<Exam_Registration__c> examRegListToUpdate = new List<Exam_Registration__c>();
       for(NBME_Score_Update_Event__e evEvent: eventExamRegMap.keySet()){
           if(!finalUpdateList.contains(eventExamRegMap.get(evEvent))){
               if(eventExamRegMap.get(evEvent).Exam_Status__c == Constants.EXAM_REGISTRATION_EXAM_STATUS_FAILED || eventExamRegMap.get(evEvent).Exam_Status__c == Constants.EXAM_REGISTRATION_EXAM_STATUS_PASSED){
                    eventExamRegMap.get(evEvent).Posted_Date__c = System.today();
               }else{
                    eventExamRegMap.get(evEvent).Posted_Date__c = null;
               }
               eventExamRegMap.get(evEvent).Withheld_Reason__c = null;
               eventExamRegMap.get(evEvent).Withheld_Score__c = false;
               examRegListToUpdate.add(eventExamRegMap.get(evEvent));
           }
       }
       if(!examRegListToUpdate.isEmpty()){
           try{
               update examRegListToUpdate;
           }
           catch(Exception e){
               System.debug('Exception caught.'+e.getMessage());
           } 
       }
       return eventExamRegMap;
   }   

   /* 22 June 2020
    * Created by Jofrin
    * Method Name: updateRemarks
    * Purpose : Update the remarks field for records
    * 
   */
   public static void updateRemarks(Map<NBME_Score_Update_Event__e, Exam_Registration__c> examRegMapToUpdate,List<Contact> contactList){
      
       Date sysDate = System.Today();

       //Query all medical school records where Enrolled_for_Performance_Data__c is checked
       List<Contact_Association_Type__c> degMedSchool = new List<Contact_Association_Type__c>([Select Id,account__r.Id,account__r.Name,Name, Contact__r.Id, RecordType.Name, RecordType.DeveloperName, Transfer_Credit_to_Degree_School__c from Contact_Association_Type__c where RecordType.DeveloperName=: Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL and contact__c =: contactList]);
       List<Id> accountIdList = new list<Id>();
       Map<Id,List<Id>> contactPerformanceMap = new Map<Id,List<Id>>();
       Map<Id,Boolean> finalPerformanceMap = new Map<Id,Boolean>();

       if(!degMedSchool.isEmpty()){
           for(Contact_Association_Type__c degMed: degMedSchool){
               accountIdList.add(degMed.account__r.Id);
               contactPerformanceMap = getContPerfMap(degMed,contactPerformanceMap);
           }
       }
       List<Account2Service__c> acc2ServiceRecordList = new List<Account2Service__c>([Select id, Name,Active__c ,Account__r.Id, Account__c,Service__c from Account2Service__c where Account__c =: accountIdList AND Service__r.Name = :Constants.SERVICE_NAME_PERFORMANCE_DATA AND Active__c = True ]);

       finalPerformanceMap = getContactBooleanMapValue(acc2ServiceRecordList,contactPerformanceMap);

       List<Exam_Registration__c> eRList = new List<Exam_Registration__c>();

       //Update the remarks field for each exam based on the flag.
       for(NBME_Score_Update_Event__e evEvent: examRegMapToUpdate.keySet()){
           if(examRegMapToUpdate.get(evEvent).Posted_Date__c != null && (examRegMapToUpdate.get(evEvent).Posted_Date__c.daysBetween(sysDate)) < 1825 && finalPerformanceMap.get(examRegMapToUpdate.get(evEvent).Applicant__c) != null && finalPerformanceMap.get(examRegMapToUpdate.get(evEvent).Applicant__c) && (examRegMapToUpdate.get(evEvent).Exam_Status__c == Constants.EXAM_REGISTRATION_EXAM_STATUS_PASSED || examRegMapToUpdate.get(evEvent).Exam_Status__c ==  Constants.EXAM_REGISTRATION_EXAM_STATUS_FAILED || examRegMapToUpdate.get(evEvent).Exam_Status__c == Constants.EXAM_REGISTRATION_EXAM_STATUS_INDETERMINATE)){
               Exam_Registration__c examRegUpdate = exmRegRemarkCheck(evEvent, examRegMapToUpdate);
               eRList.add(examRegUpdate);
           }
       }
       
       if(!eRList.isEmpty()){
           try{
               update eRList;
           }
           catch(Exception e){
               System.debug('Exception Message'+e.getMessage());
           } 
       }
   } 

    /* 22 June 2020
    * Created by Jofrin
    * Method Name: getContPerfMap
    * Purpose : Method to return the mapValue of account and its list of contacts.
    * 
   */
   public static Map<Id,List<Id>> getContPerfMap(Contact_Association_Type__c degMed,Map<Id,List<Id>> contactPerformanceMap){
       
       List<Id> contacList = new List<Id>();
       if(!contactPerformanceMap.isEmpty() && contactPerformanceMap.containsKey(degMed.account__r.Id)){
           contacList = contactPerformanceMap.get(degMed.account__r.Id);
           contacList.add(degMed.Contact__r.Id);
           contactPerformanceMap.put(degMed.account__r.Id,contacList);
       }
       else{
           contacList.add(degMed.Contact__r.Id);
           contactPerformanceMap.put(degMed.account__r.Id,contacList);
       }
       return contactPerformanceMap;
   }

   /* 22 June 2020
    * Created by Jofrin
    * Method Name: getContactBooleanMapValue
    * Purpose : Method to return the mapValue of contact and its boolean value to update the exam reg remarks.
    * 
   */
   public static Map<Id,Boolean> getContactBooleanMapValue(List<Account2Service__c> acc2ServiceRecordList,Map<Id,List<Id>> contactPerformanceMap){

       Map<Id,Boolean> finalPerformanceMapToReturn = new Map<Id,Boolean>();
       Map<Id,Boolean> finalPerformanceMap = new Map<Id,Boolean>();
       if(!acc2ServiceRecordList.isEmpty()){
           for(Account2Service__c acc2ServiceRecord: acc2ServiceRecordList){
               if(!contactPerformanceMap.isEmpty()){
                   for(Id contactValue: contactPerformanceMap.get(acc2ServiceRecord.account__r.Id)){
                       finalPerformanceMap = finalPerfMap(contactValue,contactPerformanceMap,acc2ServiceRecord);
                       finalPerformanceMapToReturn.putAll(finalPerformanceMap);
                   }
               }
           }
       }

       return finalPerformanceMapToReturn;
   }

    /* 22 June 2020
    * Created by Jofrin
    * Method Name: finalPerfMap
    * Purpose : Return finalperformance map to above method.
    * 
   */
   public static Map<Id,Boolean> finalPerfMap(Id contactValue,Map<Id,List<Id>> contactPerformanceMap, Account2Service__c acc2ServiceRecord){
       
       Map<Id,Boolean> finalPerformanceMap = new Map<Id,Boolean>();
       if(contactPerformanceMap.containsKey(acc2ServiceRecord.account__r.Id)){
           finalPerformanceMap.put(contactValue,True);
       }
       else{
           finalPerformanceMap.put(contactValue,False);
       }
       return finalPerformanceMap;
   }
       

   /* 22 June 2020
    * Created by Jofrin
    * Method Name: exmRegRemarkCheck
    * Purpose : Update the remarks field for records method conditions
    * 
   */
   public static Exam_Registration__c exmRegRemarkCheck(NBME_Score_Update_Event__e examRegist, Map<NBME_Score_Update_Event__e, Exam_Registration__c> examRegEventMapToUpdate){
       
       if(examRegEventMapToUpdate.get(examRegist).Pd_Optout_flag__c == false){
           if(examRegist.Test_Accommodations__c == 'Y'){
               examRegEventMapToUpdate.get(examRegist).Remarks__c = Constants.REMARKS_TA;
           }
           if(examRegist.irregularity_status__c == 'R' || examRegist.irregularity_status__c == 'P' ){
               examRegEventMapToUpdate.get(examRegist).Remarks__c = Constants.REMARKS_IB;
           }
           if(examRegEventMapToUpdate.get(examRegist).Exam_Status__c == Constants.EXAM_REGISTRATION_EXAM_STATUS_INDETERMINATE){
               examRegEventMapToUpdate.get(examRegist).Remarks__c = Constants.REMARKS_IN;
           }
       }
       else{
           examRegEventMapToUpdate.get(examRegist).Remarks__c = Constants.REMARKS_WH;
       }
       
       return examRegEventMapToUpdate.get(examRegist);
   }

   /* 06 May 2020
    * @author: Nayana
    * @methodname: updateWithHeldScore
    * @description: Method to update Withheld Score and Posted Date on Exam Registration
    * @Parameters: List of Exam Registration, List of Contact Ids
    * @return type: void
    */
   public static void updateWithHeldScore(List<Exam_Registration__c> examRegList, List<String> appIdListUpdateAsset, List<String> appIdListUpdateCase,  Set<String> contactIdFormNotarized, Set<String> contactApplicantBioChange){
       List<Exam_Registration__c> examRegListToUpdate = new List<Exam_Registration__c>();

       for(Exam_Registration__c examReg : examRegList) {

           if(((appIdListUpdateAsset.contains(examReg.Applicant__c) && appIdListUpdateCase.contains(examReg.Applicant__c)) 
           || (!contactIdFormNotarized.contains(examReg.Applicant__c) && !contactApplicantBioChange.contains(examReg.Applicant__c))
           || (appIdListUpdateAsset.contains(examReg.Applicant__c) && !contactApplicantBioChange.contains(examReg.Applicant__c))
           || (!contactIdFormNotarized.contains(examReg.Applicant__c) && appIdListUpdateCase.contains(examReg.Applicant__c)))
           && examReg.Score_report_Document_id__c != null 
           && (examReg.Case__r.Enrollment_Re_Verification_Parent__c == null 
           || (examReg.Case__r.Enrollment_Re_Verification_Parent__c != null && examReg.Case__r.Enrollment_Re_Verification_Parent__r.Internal_Status__c == Constants.CASE_STATUS_ENROLLMENT_VERIFIED))) {
                examReg.Withheld_Reason__c = '';
                examReg.Withheld_Score__c = false;
                examReg.Posted_Date__c = postedDateCheck(examReg);
               
                examRegListToUpdate.add(examReg);
           }
           else {
               examReg.Withheld_Reason__c = updateWithHeldReason(examReg, appIdListUpdateAsset, appIdListUpdateCase, contactIdFormNotarized, contactApplicantBioChange);
               examRegListToUpdate.add(examReg);
           } 
       }   
       
       if(!examRegListToUpdate.isEmpty()) {
           Database.update(examRegListToUpdate);
       }  
   }
   /* 06 May 2020
    * @author: Nayana
    * @methodname: updateWithHeldReason
    * @description: Method to update Withheld Reason on Exam Registration
    * @Parameters: List of Exam Registration, List of Contact Ids
    * @return type: String
    */
   public static String updateWithHeldReason(Exam_Registration__c examReg, List<String> appIdListUpdateAsset, List<String> appIdListUpdateCase,  Set<String> contactIdFormNotarized, Set<String> contactApplicantBioChange){
       String reason = '';
       if((!appIdListUpdateAsset.contains(examReg.Applicant__c) && contactIdFormNotarized.contains(examReg.Applicant__c))
           || (!appIdListUpdateCase.contains(examReg.Applicant__c) && contactApplicantBioChange.contains(examReg.Applicant__c))) {
           reason = reasonStringGenerator(reason, Constants.SCORE_WITHHELD_REASON_ID_VERIFICATION);
       }
       if(examReg.Case__r.Enrollment_Re_Verification_Parent__c != null 
           && examReg.Case__r.Enrollment_Re_Verification_Parent__r.Internal_Status__c != Constants.CASE_STATUS_ENROLLMENT_VERIFIED) {
           reason = reasonStringGenerator(reason, Constants.SCORE_WITHHELD_REASON_ENROLLMENT_REVERIFICATION);
       }
       if(examReg.Score_report_Document_id__c == null) {
           reason = reasonStringGenerator(reason, Constants.SCORE_WITHHELD_REASON_REQUESTED_BY_NBME);
       }
       return reason;
   }
   /* 08 May 2020
    * Created by Femi
    * Method Name: createScoreImportErrorRecords
    * Purpose :Create  ScoreImportError records for platform events those doesnt have matching exam registration record
    * 
   */
   public static void createScoreImportErrorRecords(List<NBME_Score_Update_Event__e> eventList, Map<NBME_Score_Update_Event__e, Exam_Registration__c> eventExamRegMap){
       List<Score_Report_Import_Error__c> errorRecordList = new List<Score_Report_Import_Error__c>();
       Group evQueue =  [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = :Constants.ERROR_SCORE_REPORTS_QUEUE LIMIT 1];
       for(NBME_Score_Update_Event__e ev:eventList){
           if(!eventExamRegMap.keyset().contains(ev)){
               Score_Report_Import_Error__c sRrecord = new Score_Report_Import_Error__c();
               sRrecord.actual_exam_start_date__c = ev.actual_exam_start_date__c;
               sRrecord.Application_id__c = ev.Application_id__c;
               sRrecord.cis_pass_fail__c = ev.cis_pass_fail__c;
               sRrecord.eligibility_end_date__c = ev.eligibility_end_date__c;
               sRrecord.eligibility_start_date__c = ev.eligibility_start_date__c;
               sRrecord.Exam__c = ev.Exam__c;
               sRrecord.exam_completion_status__c = ev.exam_completion_status__c;
               sRrecord.examination_repeat_flag__c = ev.examination_repeat_flag__c;
               sRrecord.ice_pass_fail__c = ev.ice_pass_fail__c;
               sRrecord.indeterminate_flag__c = ev.indeterminate_flag__c;
               sRrecord.irregularity_status__c = ev.irregularity_status__c;
               sRrecord.last_update_date__c = ev.last_update_date__c;
               sRrecord.pass_fail__c = ev.pass_fail__c;
               sRrecord.Report_name__c = ev.Report_name__c;
               sRrecord.school_id__c = ev.school_id__c;
               sRrecord.score_available_date__c = ev.score_available_date__c;
               sRrecord.score_report_date__c = ev.score_report_date__c;
               sRrecord.score_report_document_id__c = ev.score_report_document_id__c;
               sRrecord.score_status__c = ev.score_status__c;
               sRrecord.scoring_task_id__c = ev.scoring_task_id__c;
               sRrecord.sep_pass_fail__c = ev.sep_pass_fail__c;
               sRrecord.Test_Accommodations__c = ev.Test_Accommodations__c;
               sRrecord.three_digit_passing_score__c = ev.three_digit_passing_score__c;
               sRrecord.three_digit_score__c = ev.three_digit_score__c;
               sRrecord.two_digit_passing_score__c = ev.two_digit_passing_score__c;
               sRrecord.two_digit_score__c = ev.two_digit_score__c;
               sRrecord.USMLE_ID__c = ev.USMLE_ID__c;
               sRrecord.OwnerId = evQueue.Id;
               errorRecordList.add(sRrecord);
           }
       }
       if(!errorRecordList.isEmpty()){
           try{
               insert errorRecordList;
           }
           catch(Exception e){
               System.debug('Exception caught'+e.getMessage());
           } 
       }


   }
   /* 08 May 2020
    * Created by Femi
    * Method Name: releaseScore
    * Purpose : To map the score to matching exam registration record
    * 
   */
   @AuraEnabled
   public static String releaseScore(Id recordId){
       Score_Report_Import_Error__c sRrecord = [SELECT USMLE_ID__c, actual_exam_start_date__c, Application_id__c, cis_pass_fail__c, eligibility_end_date__c, eligibility_start_date__c, Exam__c, exam_completion_status__c, examination_repeat_flag__c, ice_pass_fail__c, indeterminate_flag__c, irregularity_status__c, last_update_date__c, pass_fail__c, Report_name__c, school_id__c, score_available_date__c, score_report_date__c, score_report_document_id__c, score_status__c, scoring_task_id__c, sep_pass_fail__c, Test_Accommodations__c, three_digit_passing_score__c, three_digit_score__c, two_digit_passing_score__c, two_digit_score__c FROM Score_Report_Import_Error__c WHERE id =:recordId][0];
       List<Exam_Registration__c> examRegList = new List<Exam_Registration__c>();
       List<Exam_Registration__c> examRegListToUpdate = new List<Exam_Registration__c>();
       examRegList = [SELECT id, USMLE_ID_CIBIS__c, Application_Id__c, Applicant__c, Exam__c, Case__c, case__r.Enrollment_Re_Verification_Parent__c, Withheld_Reason__c, Pd_Optout_flag__c FROM Exam_Registration__c WHERE USMLE_ID_CIBIS__c =:sRrecord.USMLE_ID__c AND Application_Id__c =: sRrecord.Application_id__c AND Exam__c =: sRrecord.Exam__c];
       if(examRegList.isEmpty()){
           Return 'Score release failed: No matching record found';
       }else{
           Exam_Registration__c examReg = new Exam_Registration__c();
           examReg.Id = examRegList[0].Id;
           examReg.Applicant__c = examRegList[0].Applicant__c;
           examReg.Pd_Optout_flag__c = examRegList[0].Pd_Optout_flag__c;
           examReg.Actual_Exam_Start_Date__c =    sRrecord.actual_exam_start_date__c;
           examReg.Application_Id__c =    sRrecord.Application_id__c;
           examReg.Cis_pass_fail__c =    sRrecord.cis_pass_fail__c;
           examReg.EP_end_Date__c =    sRrecord.eligibility_end_date__c;
           examReg.EP_start_Date__c =    sRrecord.eligibility_start_date__c;
           examReg.Exam_Completion_Status__c =    sRrecord.exam_completion_status__c;
           examReg.Examination_repeat_flag__c =    sRrecord.examination_repeat_flag__c;
           examReg.Ice_pass_fail__c =    sRrecord.ice_pass_fail__c;
           examReg.Indeterminate_Flag__c =    sRrecord.indeterminate_flag__c;
           examReg.Irregularity_Status__c =    sRrecord.irregularity_status__c;
           examReg.Last_Update_Date__c =    sRrecord.last_update_date__c;
           examReg.Pass_fail__c =    sRrecord.pass_fail__c;
           examReg.Report_Name__c =    sRrecord.Report_name__c;
           examReg.School_Id__c =    sRrecord.school_id__c;
           examReg.Score_Available_Date__c =    sRrecord.score_available_date__c;
           examReg.Score_Report_Date__c =    sRrecord.score_report_date__c;
           examReg.Score_report_Document_id__c =    sRrecord.score_report_document_id__c;
           examReg.Score_Status__c =    sRrecord.score_status__c;
           examReg.Scoring_Task_Id__c =    sRrecord.scoring_task_id__c;
           examReg.Sep_pass_fail__c =    sRrecord.sep_pass_fail__c;
           examReg.Test_Accommodations__c =    sRrecord.Test_Accommodations__c;
           examReg.Three_Digit_Passing_Score__c =    sRrecord.three_digit_passing_score__c;
           examReg.Three_Digit_Score__c =    sRrecord.three_digit_score__c;
           examReg.Two_Digit_Passing_Score__c =    sRrecord.two_digit_passing_score__c;
           examReg.Two_Digit_Score__c =    sRrecord.two_digit_score__c;
           examReg.USMLE_ID_CIBIS__c =    sRrecord.USMLE_ID__c;
           examRegListToUpdate.add(examRegList[0]);
           List<Exam_Registration__c> idList = withHeldCheckForIdVerification(examRegListToUpdate);
           List<Exam_Registration__c> reVerList = withHeldCheckForEnrollmentReVerification(examRegListToUpdate);
           String reason = '';
           Boolean withHeld = false;
           if(idList.contains(examRegList[0])){
               reason = reasonStringGenerator(reason, Constants.SCORE_WITHHELD_REASON_ID_VERIFICATION);
               withHeld = true;
           }
           if(reVerList.contains(examRegList[0])){
               reason = reasonStringGenerator(reason, Constants.SCORE_WITHHELD_REASON_ENROLLMENT_REVERIFICATION);
               withHeld = true;
           }
           if((sRrecord.score_report_document_id__c == '' || sRrecord.score_report_document_id__c == null) && sRrecord.Score_Status__c == 'N' ){
               reason = reasonStringGenerator(reason, Constants.SCORE_WITHHELD_REASON_REQUESTED_BY_NBME);
               withHeld = true;
           }
           examReg.Exam_Status__c = examOutcomeGenerator(sRrecord);
           if(withHeld){
               examReg.Withheld_Reason__c = reason;
               examReg.Withheld_Score__c = true;
           }else{
                examReg.Withheld_Reason__c = null;
                examReg.Withheld_Score__c = false;
           }
            examReg.Posted_Date__c = postedDateCheck(examReg);
           updateRemarksOnScoreRelease(examReg,sRrecord);

           try{
               update examReg;
               delete sRrecord;
           }catch(Exception e){
                System.debug('Exception caught'+e.getMessage());
                Return 'Incorrect data exception:'+e.getMessage();     
           }
       }
       Return 'Score Released Successfully';
   }
   /* 02 July 2020
    * Created by Femi
    * Method Name: updateExamOutcome
    * Purpose : To update exam outcome based on nbme score import
    * 
   */
   public static Map<NBME_Score_Update_Event__e, Exam_Registration__c> updateExamOutcome(Map<NBME_Score_Update_Event__e, Exam_Registration__c> eventExamRegMap){
       List<Exam_Registration__c> examRegListToUpdate = new List<Exam_Registration__c>();
       for(NBME_Score_Update_Event__e ev : eventExamRegMap.keySet()){
           Exam_Registration__c examReg = new Exam_Registration__c();
           examReg.Id = eventExamRegMap.get(ev).Id;
           if(ev.indeterminate_flag__c == 'Y'){
               examReg.Exam_Status__c = Constants.EXAM_REGISTRATION_EXAM_STATUS_INDETERMINATE;
               eventExamRegMap.get(ev).Exam_Status__c = Constants.EXAM_REGISTRATION_EXAM_STATUS_INDETERMINATE;
           }else if(ev.score_status__c == 'N'){
               examReg.Exam_Status__c = Constants.EXAM_REGISTRATION_EXAM_STATUS_WITHHELD;
               eventExamRegMap.get(ev).Exam_Status__c = Constants.EXAM_REGISTRATION_EXAM_STATUS_WITHHELD;
           }else if(ev.pass_fail__c == 'P'){
               examReg.Exam_Status__c = Constants.EXAM_REGISTRATION_EXAM_STATUS_PASSED;
               eventExamRegMap.get(ev).Exam_Status__c = Constants.EXAM_REGISTRATION_EXAM_STATUS_PASSED;
           }else if(ev.pass_fail__c == 'F'){
               examReg.Exam_Status__c = Constants.EXAM_REGISTRATION_EXAM_STATUS_FAILED;
               eventExamRegMap.get(ev).Exam_Status__c = Constants.EXAM_REGISTRATION_EXAM_STATUS_FAILED;
           }else if(ev.exam_completion_status__c == 'N'){
               examReg.Exam_Status__c = Constants.EXAM_REGISTRATION_EXAM_STATUS_NOSHOW;
               eventExamRegMap.get(ev).Exam_Status__c = Constants.EXAM_REGISTRATION_EXAM_STATUS_NOSHOW;
           }else if(ev.exam_completion_status__c == 'P'){
               examReg.Exam_Status__c = Constants.EXAM_REGISTRATION_EXAM_STATUS_INCOMPLETE;
               eventExamRegMap.get(ev).Exam_Status__c = Constants.EXAM_REGISTRATION_EXAM_STATUS_INCOMPLETE;
           }else{
               examReg.Exam_Status__c = null;
               eventExamRegMap.get(ev).Exam_Status__c = null;
           }
           examRegListToUpdate.add(examReg);
       }
       if(!examRegListToUpdate.isEmpty()){
           update examRegListToUpdate; 
       }
       return eventExamRegMap;

   }
   /* 27 Aug 2020
    * Created by Femi
    * Method Name: examOutcomeGenerator
    * Purpose : To update exam outcome based on score release from error record
    * 
   */
    public static String examOutcomeGenerator(Score_Report_Import_Error__c ev){
            String outcome = null;
            if(ev.indeterminate_flag__c == 'Y'){
                outcome = Constants.EXAM_REGISTRATION_EXAM_STATUS_INDETERMINATE;
            }else if(ev.score_status__c == 'N'){
                outcome = Constants.EXAM_REGISTRATION_EXAM_STATUS_WITHHELD;
            }else if(ev.pass_fail__c == 'P'){
                outcome = Constants.EXAM_REGISTRATION_EXAM_STATUS_PASSED;
            }else if(ev.pass_fail__c == 'F'){
                outcome = Constants.EXAM_REGISTRATION_EXAM_STATUS_FAILED;
            }else if(ev.exam_completion_status__c == 'N'){
                outcome = Constants.EXAM_REGISTRATION_EXAM_STATUS_NOSHOW;
            }else if(ev.exam_completion_status__c == 'P'){
                outcome = Constants.EXAM_REGISTRATION_EXAM_STATUS_INCOMPLETE;
            }else{
                outcome = null;
            }
        
        return outcome;

    }
    /* 26 Aug 2020
    * Created by Femi
    * Method Name: updateRemarksOnScoreRelease
    * Purpose : Update the remarks field for records
    * 
   */
   public static void updateRemarksOnScoreRelease(Exam_Registration__c examReg, Score_Report_Import_Error__c errorRecord){
      
    Date sysDate = System.Today();

    //Query all medical school records where Enrolled_for_Performance_Data__c is checked
    List<Contact_Association_Type__c> degMedSchool = new List<Contact_Association_Type__c>([Select Id,account__r.Id,account__r.Name,Name, Contact__r.Id, RecordType.Name, RecordType.DeveloperName, Transfer_Credit_to_Degree_School__c from Contact_Association_Type__c where RecordType.DeveloperName=: Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL and contact__r.Id =: examReg.applicant__c]);
    List<Id> accountIdList = new list<Id>();
    Map<Id,List<Id>> contactPerformanceMap = new Map<Id,List<Id>>();
    Map<Id,Boolean> finalPerformanceMap = new Map<Id,Boolean>();

    if(!degMedSchool.isEmpty()){
        for(Contact_Association_Type__c degMed: degMedSchool){
            accountIdList.add(degMed.account__r.Id);
            contactPerformanceMap = getContPerfMap(degMed,contactPerformanceMap);
        }
    }
    List<Account2Service__c> acc2ServiceRecordList = new List<Account2Service__c>([Select id, Name,Active__c ,Account__r.Id, Account__c,Service__c from Account2Service__c where Account__c =: accountIdList AND Service__r.Name = :Constants.SERVICE_NAME_PERFORMANCE_DATA AND Active__c = True ]);

    finalPerformanceMap = getContactBooleanMapValue(acc2ServiceRecordList,contactPerformanceMap);

    //Update the remarks field for each exam based on the flag.
        if(examReg.Posted_Date__c != null && (examReg.Posted_Date__c.daysBetween(sysDate)) < 1825 && finalPerformanceMap.get(examReg.Applicant__c) != null && finalPerformanceMap.get(examReg.Applicant__c) && (examReg.Exam_Status__c == Constants.EXAM_REGISTRATION_EXAM_STATUS_PASSED || examReg.Exam_Status__c ==  Constants.EXAM_REGISTRATION_EXAM_STATUS_FAILED || examReg.Exam_Status__c == Constants.EXAM_REGISTRATION_EXAM_STATUS_INDETERMINATE)){
            Exam_Registration__c examRegUpdate = exmRegRemarkCheckOnScoreRelease(examReg, errorRecord);
            try{
                update examRegUpdate;
            }
            catch(Exception e){
                System.debug('Exception Message'+e.getMessage());
            } 
        }
        
    }
    /* 26 Aug 2020
    * Created by Femi
    * Method Name: exmRegRemarkCheckOnScoreRelease
    * Purpose : Update the remarks field for records method conditions
    * 
   */
   public static Exam_Registration__c exmRegRemarkCheckOnScoreRelease(Exam_Registration__c examReg, Score_Report_Import_Error__c errorRecord){
       
        if(examReg.Pd_Optout_flag__c == false){
            if(errorRecord.Test_Accommodations__c == 'Y'){
                examReg.Remarks__c = Constants.REMARKS_TA;
            }
            if(errorRecord.irregularity_status__c == 'R' || errorRecord.irregularity_status__c == 'P' ){
                examReg.Remarks__c = Constants.REMARKS_IB;
            }
            if(examReg.Exam_Status__c == Constants.EXAM_REGISTRATION_EXAM_STATUS_INDETERMINATE){
                examReg.Remarks__c = Constants.REMARKS_IN;
            }
        }
        else{
            examReg.Remarks__c = Constants.REMARKS_WH;
        }
        
        return examReg;
    }

    /* 10 Sept 2020
    * Created by Femi
    * Method Name: postedDateCheck
    * Purpose : Check whether to update posted date or not
    * 
   */
   public static Date postedDateCheck(Exam_Registration__c examReg){
       if(!examReg.Withheld_Score__c && (examReg.Exam_Status__c == Constants.EXAM_REGISTRATION_EXAM_STATUS_FAILED || examReg.Exam_Status__c == Constants.EXAM_REGISTRATION_EXAM_STATUS_PASSED)){
           return System.today();
       }
       return null;
   }
}