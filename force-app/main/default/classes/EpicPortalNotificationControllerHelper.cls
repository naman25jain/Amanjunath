public with sharing class EpicPortalNotificationControllerHelper{
    // Wrapper class to send EPIC Portal Notifications    
    public class EpicPortalNotificationWrapper{
        @auraenabled public String credentialType { get; set; } 
        @auraenabled public String caseId { get; set; }
        @auraenabled public Date attendanceStartDate { get; set; }  
        @auraenabled public Date attendanceEndDate { get; set; }  
        @auraenabled public Date dateDegreeIssued { get; set; } 
        @auraenabled public String medicalDegreeTitle { get; set; } 
        @auraenabled public String nameOnDocument { get; set; } 
        @auraenabled public String applicantName { get; set; } 
        @auraenabled public String ecfmgID { get; set; } 
        @auraenabled public String credentialStatus { get; set; } 
        @auraenabled public String issuingInstitution { get; set; } 
        @auraenabled public String issuingInstitutionCountry { get; set; } 
        @auraenabled public Date firstVerificationRequestSentDate { get; set; } 
        @auraenabled public Date notificationAvailableDate { get; set; }
        @auraenabled public String asstCred { get; set; } 
        @auraenabled public String typeCred { get; set; } 
        @auraenabled public String urlCred { get; set; } 
        @auraenabled public String asstExistCred { get; set; } 
        @auraenabled public String asstTrans { get; set; } 
        @auraenabled public String typeTrans { get; set; } 
        @auraenabled public String urlTrans { get; set; }
        @auraenabled public String asstExistTrans { get; set; } 
         public EpicPortalNotificationWrapper(case epicReportCase, Contact_Association_Type_Staging__c catsRcd, Asset cred, Asset trans){
            caseId = epicReportCase.Id;
            credentialType = epicReportCase.Document_Type__c; 
            attendanceStartDate = catsRcd.Attendance_Start_Date__c;
            attendanceEndDate = catsRcd.Attendance_End_Date__c;
            dateDegreeIssued = catsRcd.Degree_Issue_Date__c;
            medicalDegreeTitle = catsRcd.Degree_Title__c;
            nameOnDocument = catsRcd.Name_on_Document__c;
            applicantName = epicReportCase.Contact.Name;
            ecfmgID = epicReportCase.ECFMG_ID__c;
            credentialStatus = epicReportCase.Parent_Case_Internal_Status__c;
            issuingInstitution = epicReportCase.Entity_Name__c;
            issuingInstitutionCountry = epicReportCase.Country_of_Entity__c;
            firstVerificationRequestSentDate = epicReportCase.First_Verification_Request_Sent_Date__c;
            notificationAvailableDate = epicReportCase.Notification_Available_Date__c;
            if(cred!= null){
            asstCred = cred.Id;
            typeCred = cred.Type__c;
            asstExistCred = 'true';
            urlCred= cred.Azure_Storage_URL__c;
            }
            else{
                asstCred = '';
            typeCred = '';
            asstExistCred = 'false';
            urlCred= ''; 
            }
            if(trans!= null){
            asstTrans = trans.Id;
            typeTrans = trans.Type__c;
            asstExistTrans = 'true';
            urlTrans= trans.Azure_Storage_URL__c;
        }
        else{
            asstTrans = '';
            typeTrans = '';
            asstExistTrans = 'false';
            urlTrans= '';
        }
        }
    }
}