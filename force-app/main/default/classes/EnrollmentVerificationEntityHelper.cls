public with sharing class EnrollmentVerificationEntityHelper{
    // Wrapper class to send EV Case     
    public class EVCaseWrapper{
        @auraenabled public String caseId { get; set; }
        @auraenabled public String conId { get; set; }        
        @auraenabled public String caseNumber { get; set; }
        @auraenabled public String restOfName { get; set; }
        @auraenabled public String lastName { get; set; }
        @auraenabled public String usmleID { get; set; }
        @auraenabled public String uniqueMedicalSchoolID { get; set; }
        @auraenabled public String dateOfBirth { get; set; }        
        @auraenabled public String examType { get; set; }
        @auraenabled public String eligibilityPeriod { get; set; }
        @auraenabled public String recordAvailableDate { get; set; }        
        @auraenabled public String status { get; set; }
        @auraenabled public String caseService { get; set; }
        @auraenabled public String entityConId { get; set; }
        @auraenabled public String deadline{ get; set; }
        public EVCaseWrapper(Map<String,String> cData,String dateOfBirthVal,String examTypeVal,String eligibilityPeriodVal,String recordAvailableDateVal,String statusVal,String entityConIdVal){
            caseId = cData.get('caseIdVal');
            conId = cData.get('conIdVal');
            caseNumber = cData.get('caseNumberVal');
            caseService = cData.get('caseServiceVal');
            restOfName = cData.get('restOfNameVal');
            lastName = cData.get('lastNameVal');
            usmleID = cData.get('usmleIDVal');
            uniqueMedicalSchoolID = cData.get('uniqueMedicalSchoolIDVal');
            deadline = getDeadlineIcon(cData.get('DeadlineVal'));
            dateOfBirth = dateOfBirthVal;
            examType = examTypeVal;
            eligibilityPeriod = eligibilityPeriodVal;
            recordAvailableDate = recordAvailableDateVal;
            status = statusVal; 
            entityConId = entityConIdVal;          
        }
    }
    public static String getDeadlineIcon(String val){
        String dl = null;
        if(val == 'true'){
            dl = 'utility:reminder';
        }
        return dl;
    }
}