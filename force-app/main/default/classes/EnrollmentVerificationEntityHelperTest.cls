@isTest public class EnrollmentVerificationEntityHelperTest {
    static string val='true';
    @isTest public static void testgetDeadlineIcon(){
        Test.startTest();
        Map<String,String> cData=new Map<String,string>();
            cData.put('a','b');
            cData.put('x','y');
        string caseId ='caseIdVal';
        string conId ='conIdVal';
        string caseNumber ='caseNumberVal';
        string caseService = 'caseServiceVal';
        string restOfName = 'restOfNameVal';
        string lastName = 'lastNameVal';
        string usmleID = 'usmleIDVal';
        string uniqueMedicalSchoolID ='uniqueMedicalSchoolIDVal';
        string deadline = 'DeadlineVal';
        string dateOfBirth = '19-12-1990';
        string examType = 'examTypeVal';
        string eligibilityPeriod = 'eligibilityPeriodVal';
        string recordAvailableDate = 'recordAvailableDateVal';
        string status = 'true'; 
        string entityConId = 'entityConIdVal';
       // EnrollmentVerificationEntityHelper obj=new EnrollmentVerificationEntityHelper();
      EnrollmentVerificationEntityHelper.EVCaseWrapper obj=new EnrollmentVerificationEntityHelper.EVCaseWrapper(cData,dateOfBirth,examType,eligibilityPeriod,recordAvailableDate,status,entityConId); 
               

        EnrollmentVerificationEntityHelper.getDeadlineIcon('true');
        Test.stopTest();
    }
}