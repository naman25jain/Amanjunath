// Class for Changing Eligibility period of Exam Registration.
public with sharing class MoveEligibilityPeriodController{
    //Purpose : Method to get the CurrentEligiblityPeriod of Exam
    @AuraEnabled(Cacheable = false)
    public static String getCurrentEligibilityPeriod(String recordId){
        Exam_Registration__c examReg = [SELECT id, EP_start_Date__c, EP_end_Date__c FROM Exam_Registration__c WHERE id=:recordId][0];
        return epGenerator(examReg.EP_start_Date__c, examReg.EP_end_Date__c);
    }
    //Purpose : Method to get the EligiblityPeriods for Exam
    @AuraEnabled(Cacheable = false)
    public static List<Map<String,String>> getEligibilityPeriods(String recordId){
        List<Map<String,String>> wrprList = new List<Map<String,String>>();
        Exam_Registration__c examReg = [SELECT id, Exam_Types__c,Case__c FROM Exam_Registration__c WHERE id=:recordId][0];
        List<Case> epexCases = [SELECT id FROM Case WHERE recordType.DeveloperName =: Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD AND parentId =: examReg.Case__c AND (Internal_Status__c =: Constants.CASE_STATUS_PENDING_CIBIS OR Internal_Status__c =: Constants.CASE_STATUS_ACCEPTED)];
        String extentionFlag = 'N';
        if(!epexCases.isEmpty()){
            extentionFlag = 'Y';
        }
        Date filterDate = System.today()-14;
        List<Eligibility_Period__c> eligibilityPeriods = [SELECT id, EP_End_Date__c, EP_Start_Date__c FROM Eligibility_Period__c WHERE RecordType.DeveloperName =: Constants.ELIGIBILITY_PERIOD_RECORD_TYPE_EXAM_REG AND Exam_Type__c =:examReg.Exam_Types__c AND active__c =: 'Y' AND Extension_Flag__c =:extentionFlag AND EP_End_Date__c >=:filterDate];
        for(Eligibility_Period__c ep: eligibilityPeriods){
            Map<String, String> values = new Map<String, String>{
                'label' => epGenerator(ep.EP_Start_Date__c, ep.EP_End_Date__c),
                'value' => String.valueOf(ep.Id)
            };
            wrprList.add(values);
        }
        return wrprList;
    }
    //Purpose : Method to check whether exam registration have outcome
    @AuraEnabled(Cacheable = false)
    public static String checkOnOutcome(Id recordId){
        List<Exam_Registration__c> examReg = [SELECT id, Exam_Status__c, case__c, case__r.Internal_Status__c FROM Exam_Registration__c WHERE id=:recordId AND Exam_Status__c = null];
        String returnString = '';
        if(examReg.isEmpty()){
            return 'You cannot move the EP of this exam because it already has an outcome.';
        }
        if(examReg[0].case__r.Internal_Status__c != Constants.CASE_STATUS_REGISTERED && examReg[0].case__r.Internal_Status__c != Constants.CASE_STATUS_PENDING_CIBIS){
            return 'You cannot move the EP of this exam because the exam has not yet been registered.';
        }
        return returnString;
    }
    //Purpose : Method to genarate EP String
    public static String epGenerator(Date startDate, Date endDate){
        Integer epSTYear = startDate.year();
        Integer epSTMonth = startDate.month();
        Integer epSTDay = startDate.day();
        DateTime epSTDt = DateTime.newInstance(epSTYear, epSTMonth, epSTDay);
        Integer epENYear = endDate.year();
        Integer epENMonth = endDate.month();
        Integer epENDay = endDate.day();
        DateTime epENDt = DateTime.newInstance(epENYear, epENMonth, epENDay);
        String dateFormat = 'MMM d,  yyyy';
        return epSTDt.format(dateFormat) +' - '+ epENDt.format(dateFormat);
    }
    //Purpose : Method to update EP according selected EP
    @AuraEnabled(Cacheable = false)
    public static Boolean submitMoveEP(Id recordId, String selectedEP, String reason){
        List<Eligibility_Period__c> eligibilityPeriods = [SELECT id, EP_End_Date__c, EP_Start_Date__c FROM Eligibility_Period__c WHERE id =:selectedEP];
        List<Exam_Registration__c> examRegistrations = [SELECT id, case__c FROM Exam_Registration__c WHERE id =:recordId];
        Exam_Registration__c examReg = new Exam_Registration__c();
        examReg.id = recordId;
        examReg.EP_start_Date__c = eligibilityPeriods[0].EP_Start_Date__c;
        examReg.EP_End_Date__c = eligibilityPeriods[0].EP_End_Date__c;
        examReg.Comments__c = reason;
        Case examRegCase = new Case();
        examRegCase.Id = examRegistrations[0].case__c;
        examRegCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_CIBIS;
        examRegCase.eligibility_Period__c = eligibilityPeriods[0].Id;
        try{
            update examReg; 
            update examRegCase;
            return true;
        }catch(DmlException e){
            return false;
        }
    }
}