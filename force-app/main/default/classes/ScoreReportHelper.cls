/**
 * Helper class for ScoreReportController
 *
 * @author        Enable Consulting
 * @version       1.0
 * @createdDate   24-APR-2020
 */
public with sharing class ScoreReportHelper {

    /* Wrapper class to send Score Report Information
     */
    public class ExamScoreWrapper {
        @AuraEnabled public String examId { get; set; }
        @AuraEnabled public String examType { get; set; }
        @AuraEnabled public String examDate { get; set; }
        @AuraEnabled public String availableUntil { get; set; }
        @AuraEnabled public String scoreReport { get; set; }
        @AuraEnabled public Boolean isAvailable { get; set; }
        @AuraEnabled public String pdOptOutFlag { get; set; }
        @AuraEnabled public String withHeldReason { get; set; }
        @AuraEnabled public Boolean withHeldScore { get; set; }

        public ExamScoreWrapper(String eId, String eType, String eDate, String aUntil, String sReport, Boolean isAvl, String optOutFlag, String withheldReas, Boolean withHeldSco) {
            examId = eId;
            examType = eType;
            examDate = eDate;
            availableUntil = aUntil;
            scoreReport = sReport;
            isAvailable = isAvl;
            pdOptOutFlag = optOutFlag;
            withHeldReason = withheldReas;
            withHeldScore = withHeldSco;
        }

    }   
    
    public class ExamWithholdWrapper {
        @AuraEnabled public String examId { get; set; }
        @AuraEnabled public String examType { get; set; }
        @AuraEnabled public String examDate { get; set; }
        @AuraEnabled public String testAccomodation { get; set; }
        @AuraEnabled public String regionName { get; set; }

        public ExamWithholdWrapper(String exmId, String exmType, String elgbleDate, String region, String testAccom) {
            examId = exmId;
            examType = exmType;
            examDate = elgbleDate;
            regionName = region;
            testAccomodation = testAccom;
        }
    }   
    
}