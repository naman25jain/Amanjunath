public class EpicReportExpirationBatchClass implements Database.Batchable<sObject>{
	public Database.QueryLocator start(Database.BatchableContext bc){
        Date dt = System.today().addDays(-1);
        Datetime dtTodayDateTime = datetime.newInstance(dt.year(),dt.month(),dt.day());
		String strDate = dtTodayDateTime.format('MM/dd/yyyy');
        Date availDate = Date.parse(strDate);
        String query = 'SELECT Id, EPIC_Report_Status__c, EPIC_Report_Available_Date__c FROM Case WHERE'+ ' '+
            'RecordType.DeveloperName = \''+ 'EPIC_Verification_Report_Request'+ '\''+'AND EPIC_Report_Available_Date__c =: availDate';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Case> epicReportCases){
        for(Case epicRepCase : epicReportCases){        
            epicRepCase.EPIC_Report_Status__c = 'Report Expired';
        }
        try{
            UPDATE epicReportCases;
        }catch(Exception e){
            throw e;
        }   
    } 
   	public void finish(Database.BatchableContext bc){}
}