/**
 * Class for verification of Student Enrollment in Entity portal
 *
 * @author        Enable Consulting : Chinmay Menon
 * @version       1.0
 * @createdDate   20-May-2020
 */
public with sharing class EnrollmentVerificationFormController {

    /**
     * Created by Chinmay Menon
     * Method Name: fetchApplicantDetails
     * Purpose : Method to retrieve details of applicant based on applicant id and ev case id
     * Return Type : List<Exam_Registration__c>
     */
    @AuraEnabled
    public static List<Exam_Registration__c> fetchApplicantDetails(String applicantId, String caseId) {

        List<Exam_Registration__c> valuesToReturn = new List<Exam_Registration__c>([SELECT Applicant__r.LastName, Applicant__r.FirstName, Applicant__r.Birthdate,
                                                                                           Case__r.Enrollment_Verification_Parent__r.USMLE_ID__c, Case__r.Enrollment_Verification_Parent__r.Unique_Medical_School__c , Case__r.Enrollment_Verification_Parent__r.Name_on_Diploma__c,
                                                                                           Exam_Types__c, EP_start_Date__c, EP_end_Date__c, Scheduled_Test_Date__c,
                                                                                           Case__r.Enrollment_Verification_Parent__r.School_Program__c, Case__r.Enrollment_Verification_Parent__r.Attendance_Start_Date__c, Case__r.Enrollment_Verification_Parent__r.Attendance_End_Date__c,
                                                                                           Case__r.Enrollment_Verification_Parent__r.Graduation_Month__c, Case__r.Enrollment_Verification_Parent__r.Graduation_Year__c, Case__r.Enrollment_Verification_Parent__r.Degree_Date__c,
                                                                                           Case__r.Enrollment_Verification_Parent__r.Number_of_Years_Attended__c, Case__r.Enrollment_Verification_Parent__r.Verification_Status__c,
                                                                                           Case__r.Enrollment_Verification_Parent__r.Verification_Status_Date__c, Case__r.Enrollment_Verification_Parent__r.Passed_basic_sciences_course__c,
                                                                                           Case__r.Enrollment_Verification_Parent__r.Enrollment_Verification_Form_Submitted__c, Case__r.Enrollment_Verification_Parent__r.Verification_Status_Month__c,
                                                                                           Case__r.Enrollment_Verification_Parent__r.Verification_Status_Year__c, Case__r.Enrollment_Verification_Parent__r.Degree_Month__c, Case__r.Enrollment_Verification_Parent__r.Degree_Year__c,
                                                                                           Case__r.Enrollment_Verification_Parent__r.Attendance_End_Month__c, Case__r.Enrollment_Verification_Parent__r.Attendance_End_Year__c,
                                                                                           Case__r.Enrollment_Verification_Parent__r.Attendance_Start_Month__c, Case__r.Enrollment_Verification_Parent__r.Attendance_Start_Year__c
                                                                                    FROM Exam_Registration__c
                                                                                    WHERE Case__r.Enrollment_Verification_Parent__c = :caseId AND
                                                                                          Applicant__c = :applicantId AND
                                                                                          Exam_Status__c = null AND
                                                                                          Case__r.Is_Removed_From_EV__c = false]);
        return valuesToReturn;
    }


    /**
     * Created by Chinmay Menon
     * Method Name: fetchApplicantPhotoId
     * Purpose : Method to retrieve applicant's photo's contentversion id to display on portal form
     * Return Type : String
     */
    @AuraEnabled
    public static String fetchApplicantPhotoId (String applicantId) {
        String returnVal = '';

        List<ContentDocumentLink> cdl = new List<ContentDocumentLink>([SELECT contentdocument.id, contentdocument.title, contentdocument.filetype
        FROM contentdocumentlink
        WHERE linkedentityid = :applicantId AND
              ContentDocument.Title = 'Photo']);
        
          
            if(!cdl.isEmpty()){
                List<ContentVersion> cv = new List<ContentVersion> ([SELECT id
                FROM contentversion
                WHERE contentdocumentid = :cdl[0].contentdocument.id]);
               

                returnVal =  cv[0].id;
        }
    
 

        return returnVal;
    }


    /**
     * Created by Chinmay Menon
     * Method Name: saveApplicantDetails
     * Purpose : Method to Save details of applicant
     * Return Type : String
     */
    @AuraEnabled
    public static string saveApplicantDetails(String applicantDetails){
        Map<String,String> applicantDetailsMap = (Map<String,String>) JSON.deserialize(applicantDetails, Map<String,String>.class);

        System.debug ('applicantDetails ' +applicantDetails); 
        System.debug ('applicantDetailsMap ' + applicantDetailsMap); 

        List<Case> evCasesToBeUpdated = new List<Case>([SELECT Id, Attendance_Start_Date__c, Attendance_End_Date__c, Number_of_Years_Attended__c,
                                               Graduation_Month__c, Graduation_Year__c, Degree_Date__c, Internal_Status__c, Verification_Status__c, Verification_Status_Date__c,
                                               Verification_Status_Month__c	, Verification_Status_Year__c,
                                               Passed_basic_sciences_course__c, Enrollment_Verification_Form_Submitted__c,
                                               Attendance_Start_Month__c, Attendance_Start_Year__c, Attendance_End_Month__c, Attendance_End_Year__c,
                                               Degree_Month__c, Degree_Year__c
                                        FROM Case
                                        WHERE id = :applicantDetailsMap.get('caseId')]);

        if(evCasesToBeUpdated.size() > 0){
            evCasesToBeUpdated[0].Number_of_Years_Attended__c = Decimal.valueOf(applicantDetailsMap.get('numOfYearsAttended'));
            evCasesToBeUpdated[0].Graduation_Month__c = applicantDetailsMap.get('gradMonth');
            evCasesToBeUpdated[0].Graduation_Year__c = applicantDetailsMap.get('gradYear');            
            evCasesToBeUpdated[0].Verification_Status__c = applicantDetailsMap.get('verificationStatus');
            evCasesToBeUpdated[0].Attendance_Start_Month__c = applicantDetailsMap.get('attendanceStartMonth');
            evCasesToBeUpdated[0].Attendance_Start_Year__c = applicantDetailsMap.get('attendanceStartYear');
            evCasesToBeUpdated[0].Attendance_End_Month__c = applicantDetailsMap.get('attendanceEndMonth');
            evCasesToBeUpdated[0].Attendance_End_Year__c = applicantDetailsMap.get('attendanceEndYear');
            evCasesToBeUpdated[0].Degree_Month__c = applicantDetailsMap.get('degreeMonth');
            evCasesToBeUpdated[0].Degree_Year__c = applicantDetailsMap.get('degreeYear');

            List<String> verificationStatusDateParams = getVerificationStatusDateParams(applicantDetailsMap.get('verificationStatus'), applicantDetailsMap.get('verificationStatusDate'), applicantDetailsMap.get('verificationStatusDateMonth'), applicantDetailsMap.get('verificationStatusDateYear'));

            evCasesToBeUpdated[0].Verification_Status_Month__c = verificationStatusDateParams[0];
            evCasesToBeUpdated[0].Verification_Status_Year__c = verificationStatusDateParams[1];
            evCasesToBeUpdated[0].Verification_Status_Date__c = verificationStatusDateParams[2] == 'null' ? null : Date.valueOf(verificationStatusDateParams[2]);

            evCasesToBeUpdated[0].Passed_basic_sciences_course__c = applicantDetailsMap.get('passedBasicScience');
            evCasesToBeUpdated[0].Enrollment_Verification_Form_Submitted__c = true;

            evCasesToBeUpdated[0].Internal_Status__c = Constants.CASE_STATUS_RECEIVED_IN_REVIEW;
            evCasesToBeUpdated[0].External_Status__c = applicantDetailsMap.get('verificationStatus');

            try {
                UPDATE evCasesToBeUpdated;
            } catch(Exception e){
                system.debug('Ev Case Update error: ' + e);
            }
        }

        return 'true';
    }


    /**
     * Created by Chinmay Menon
     * Method Name: getVerificationStatusDateParams
     * Purpose : Method to return date params to reduce Cognitive Complexity
     * Return Type : List<String>
     */
    public static List<String> getVerificationStatusDateParams(String verificationStatus, String verificationStatusDate, String verificationStatusMonth, String verificationStatusYear){
        List<String> valuesToReturn = new List<String>();

        if(verificationStatus== 'Graduated' || verificationStatus == 'Deceased' ||
               verificationStatus == 'Dismissed' || verificationStatus == 'Transferred' ||
               verificationStatus == 'Withdrawn'){

                if(verificationStatus == 'Graduated' || verificationStatus == 'Deceased'){
                    valuesToReturn.add(verificationStatusMonth);
                    valuesToReturn.add(verificationStatusYear);
                    valuesToReturn.add('null');
                }

                if(verificationStatus == 'Dismissed' || verificationStatus == 'Transferred' ||
                   verificationStatus == 'Withdrawn'){
                    valuesToReturn.add('');
                    valuesToReturn.add('');
                    valuesToReturn.add(verificationStatusDate);
                }
        } else {
            valuesToReturn.add('');
            valuesToReturn.add('');
            valuesToReturn.add('null');
        }

        return valuesToReturn;
    }
}