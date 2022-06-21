public inherited sharing class RestrictionBulkProcessController {

    @AuraEnabled
    public static accountContactWrapper SearchRecords(String keyWord, String strObjName) {
        accountContactWrapper accConData = new accountContactWrapper();
        try {
            if(String.isNotBlank(strObjName)) {
                String strQuery = 'SELECT ';
                keyWord = '%' + keyWord + '%';
                if(strObjName == 'Account') {
                    strQuery += 'Id, Name, Recordtype.Name, BillingStreet, BillingCity, BillingCountry, Entity_ID__c, Medschool_Code__c, Institution_ID__c FROM ' + strObjName + ' WHERE Name LIKE :keyWord AND RecordType.Name = \'Entity\'';
                    accConData.accountRecords = Database.query(strQuery);
                    accConData.contactRecords = null;
                }
                else if(strObjName == 'Contact') {
                    strQuery += 'Id, Name, RecordType.Name, ECFMG_ID__c, Birthdate, Gender__c, MailingStreet, MailingCity, MailingCountry FROM ' + strObjName + ' WHERE Name LIKE :keyWord';
                    accConData.contactRecords = Database.query(strQuery);
                    accConData.accountRecords = null;
                }
    
            }
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    
        return accConData;
    }

    @AuraEnabled
    public static accountContactWrapper getDataFromReport(String strReportId, String restrictionLevel) {
        accountContactWrapper accConData = new accountContactWrapper();
        try {
            accConData.accountRecords = new List<Account>();
            accConData.contactRecords = new List<Contact>();
            if(String.isNotBlank(strReportId)) {
                Reports.reportResults results = Reports.ReportManager.runReport(strReportId, true);
                if(results != null) {
                    Reports.ReportFactWithDetails factDetails = (Reports.ReportFactWithDetails)results.getFactMap().get('T!T');
                    List<Reports.ReportDetailRow> detailRows = factDetails.getRows();
                    for(Reports.ReportDetailRow detail : detailRows){
                        for(Reports.ReportDataCell dataCell : detail.getDataCells()) {
                            if(restrictionLevel != null && restrictionLevel == 'Account' && accConData != null && dataCell.getValue() != null && String.valueOf(dataCell.getValue()).startsWith('001')) {
                                accConData.accountRecords.add(new Account(Id = String.valueOf(dataCell.getValue())));
                            }
                            else if(restrictionLevel != null && restrictionLevel == 'Contact' && accConData != null && dataCell.getValue() != null && String.valueOf(dataCell.getValue()).startsWith('003')) {
                                accConData.contactRecords.add(new Contact(Id = String.valueOf(dataCell.getValue())));
                            }
                        }
                    }
                }
            }
        }
        catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
        return accConData;
    }

    @AuraEnabled
    public static accountContactWrapper getExstingRowsData(String strRecordId) {
        accountContactWrapper accConData = new accountContactWrapper();
        try {
            if(String.isNotBlank(strRecordId)) {
                Restriction_Request__c objRes = [SELECT Id, Entity_ID_List__c, Applicant_ID_List__c FROM Restriction_Request__c WHERE Id =:strRecordId];

                if(objRes != null) {
                    if(objRes.Entity_ID_List__c != null) {
                        list<String> lstEnIds = new list<String>();
                        list<String> lstEntities = objRes.Entity_ID_List__c.removeStart('[').removeEnd(']').split(',');
                        if(lstEntities != null && !lstEntities.isEmpty()) {
                            for(String str : lstEntities) {
                                lstEnIds.add(str.replace('"',''));
                            }
                       
                            if(lstEnIds != null && !lstEnIds.isEmpty()) {
                                list<Account> lstAccs = [SELECT Id, Name, BillingStreet, BillingCity, BillingCountry, Entity_ID__c, Medschool_Code__c, Institution_ID__c FROM Account WHERE Id IN:lstEnIds];
                                accConData.accountRecords = (Account[])lstAccs;
                          
                            }
                        }
                    }
                    
                    if(objRes.Applicant_ID_List__c != null) {
                        list<String> lstApIds = new list<String>();
                        list<String> lstApplicants = objRes.Applicant_ID_List__c.removeStart('[').removeEnd(']').split(',');
                        if(lstApplicants != null && !lstApplicants.isEmpty()) {
                            for(String str : lstApplicants) {
                                lstApIds.add(str.replace('"',''));
                            }

                            if(lstApIds != null && !lstApIds.isEmpty()) {
                                list<Contact> lstCons = [SELECT Id, Name, RecordType.Name, ECFMG_ID__c, Birthdate, Gender__c, MailingStreet, MailingCity, MailingCountry FROM Contact WHERE Id IN:lstApIds];
                                accConData.contactRecords = (Contact[])lstCons;
                            }
                        }
                    }
                }
   
            }
        }catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return accConData;
    }

    @AuraEnabled(cacheable=true)
    public static boolean compareDates (string startDate, string endDate){
        String todayDate = String.valueOf(System.today());
        if(String.isNotEmpty(startDate) && startDate == todayDate){
            return true;
        }
        if(String.isNotEmpty(endDate) && endDate == todayDate){
            return true;
        }
        return false;
    }

    @AuraEnabled
    public static void updateRestrictionRequest(String rrID, String requestType){
        try {
            Restriction_Request__c rrRec = new Restriction_Request__c();
            rrRec.Id = rrID;
            if(requestType == 'New'){
                rrRec.Restriction_Start_Date__c = System.today();
                rrRec.RecordTypeId = Schema.SObjectType.Restriction_Request__c.getRecordTypeInfosByName().get('New - RO').getRecordTypeId();
            }
            else if(requestType == 'Completed') {
               rrRec.Restriction_End_Date__c = System.today(); 
               rrRec.RecordTypeId = Schema.SObjectType.Restriction_Request__c.getRecordTypeInfosByName().get('Rollback - RO').getRecordTypeId();
            }
            rrRec.RestrictionStatus__c = 'Ready to Process';
            update rrRec;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    // @AuraEnabled(Cacheable = true)
    // public static list<Restriction_Req_Bulk_Process__mdt> getCmdtRecords() {
    //     return [SELECT Id, MasterLabel, DeveloperName, Header_Field_Names__c, Query_Fileds__c, isActive__c FROM Restriction_Req_Bulk_Process__mdt WHERE isActive__c = true];
    // }

    // @AuraEnabled
    // public static accountContactWrapper SearchRecords(String keyWord) {
    //     accountContactWrapper accConData = new accountContactWrapper();
    //     List<List<sObject>> searchList = [FIND :keyWord IN ALL FIELDS RETURNING Account(Name,AccountNumber),Contact(FirstName,LastName,Department)];
    //     accConData.accountRecords = (Account[])searchList[0];
    //     accConData.contactRecords = (Contact[])searchList[1];
    //     return accConData;
    // }

    public class accountContactWrapper{

        @AuraEnabled
        public List<Account> accountRecords {get;set;}

        @AuraEnabled
        public List<Contact> contactRecords {get;set;}
    }
}