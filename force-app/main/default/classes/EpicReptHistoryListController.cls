public with sharing class EpicReptHistoryListController{
    @AuraEnabled
    public static List<EpicReptHistoryListController.ReportWrapper> getReportData(){
        try{
            Id currContId = AppForCertHelper.retrieveCurrentContactId();
            List<EpicReptHistoryListController.ReportWrapper> retList = new List<EpicReptHistoryListController.ReportWrapper>();
            List<Case> epicReportCases = [SELECT Id, EPIC_Report_Entity__c, Entity__c, Entity__r.Name, Payment_History__c, Contact.Name, Report_Type__c,
                                        EPIC_Report_Status__c, Secondary_Parent_Case__r.Document_Type__c, (SELECT CreatedDate, NewValue, OldValue FROM Histories WHERE (Field = 'EPIC_Report_Status__c' OR Field = 'Created') ORDER BY CreatedDate DESC) 
                                        FROM Case WHERE ContactId =: currContId AND RecordType.DeveloperName = 'EPIC_Verification_Report_Request' 
                                        AND (EPIC_Report_Status__c = 'Report Sent' OR EPIC_Report_Status__c = 'Report Expired') AND (Secondary_Parent_Case__r.Internal_Status__c =: Constants.CASE_STATUS_CV_ACCEPTED OR Secondary_Parent_Case__r.Internal_Status__c =: Constants.CASE_STATUS_ACCEPTED) WITH SECURITY_ENFORCED];
            retList = getEpicReportWrap(epicReportCases);
            if(retList.isEmpty()){
                retList = null;
            }
            return retList;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    public static List<ReportWrapper> getEpicReportWrap(List<Case> epicReportCase){
        List<ReportWrapper> retuVal = new List<ReportWrapper>();
        for(Case ca : epicReportCase){
            String caseId = ca.Id;
            String entity = null;
            if(ca.EPIC_Report_Entity__c == null){
                entity = ca.Entity__r.Name;
            }else{
                entity = ca.EPIC_Report_Entity__c;
            }
            String applicant = ca.Contact.Name;
            String status = ca.EPIC_Report_Status__c;
            String paymentHistory = ca.Payment_History__c;
            String doctype = ca.Secondary_Parent_Case__r.Document_Type__c;
            String updDate = null;
            String repType = ca.Report_Type__c;
            for(CaseHistory ch : ca.Histories){
                if((ch.NewValue == 'Report Sent' || ch.NewValue == 'Report Expired') || (ch.OldValue == null && ch.NewValue == null)){
                    Datetime dt = (Datetime)ch.CreatedDate;
                    updDate = dt.format('MMMM d, yyyy');
                }
                break;
            }
            String updatedDate = updDate;
            Map<String, String> epicHisRecMap = new Map<String, String>();
            epicHisRecMap.put('caseIdVal', caseId);
            epicHisRecMap.put('entityName', entity);
            epicHisRecMap.put('applicantName', applicant);
            epicHisRecMap.put('status', status);
            epicHisRecMap.put('payHistory', paymentHistory);
            epicHisRecMap.put('credType', doctype);
            epicHisRecMap.put('statusUpdDate', updatedDate);
            epicHisRecMap.put('reporttype', repType);
            ReportWrapper repWrp = new ReportWrapper(epicHisRecMap);
            retuVal.add(repWrp);
        }
        return retuVal;
    }
    public class ReportWrapper{
        @auraenabled public string caseId {get;set;}
        @auraenabled public string entity {get;set;}
        @auraenabled public string applicant {get;set;}
        @auraenabled public string credential {get;set;}
        @auraenabled public string status {get;set;}
        @auraenabled public string updDate {get;set;}
        @auraenabled public string payHistory {get;set;}
        @auraenabled public string reportType {get;set;}
        public ReportWrapper(Map<String, String> repHisWrap){
            caseId = repHisWrap.get('caseIdVal');
            entity = repHisWrap.get('entityName');
            applicant = repHisWrap.get('applicantName');
            credential = repHisWrap.get('credType');
            status = repHisWrap.get('status');
            updDate = repHisWrap.get('statusUpdDate');
            payHistory = repHisWrap.get('payHistory');
            reportType = repHisWrap.get('reporttype');
        }
    }
    @AuraEnabled
    public static string getVerifiedCredentialURL(Id caseId){
        try{
            Case currCase = [SELECT Id, Secondary_Parent_Case__c FROM Case WHERE Id =: caseId WITH SECURITY_ENFORCED];
            Asset getverCreds = [SELECT Id, Azure_Storage_URL__c, Name FROM Asset WHERE Case__c =: currCase.Secondary_Parent_Case__c AND Name LIKE 'Verified%' AND Status = 'Verified' WITH SECURITY_ENFORCED LIMIT 1];
            return getverCreds.Azure_Storage_URL__c;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static string getEPICReport(Id caseId){
        try{
            Asset epicReport = [SELECT Id, Name, Azure_Storage_URL__c FROM Asset WHERE Case__c =: caseId AND Type__c = 'Verification Report' WITH SECURITY_ENFORCED LIMIT 1];
            return epicReport.Azure_Storage_URL__c;  
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
}