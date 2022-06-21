public inherited sharing class CodeCoverageExportController {

    @AuraEnabled
    public static CoverageWrap exportClassCoverage() {
        String strResourceQuery = null;
        String strResponse = null;
        CoverageWrap cw;

        strResourceQuery = 'tooling/query/?q=Select+id,ApexClassorTriggerId,ApexClassorTrigger.Name,NumLinesCovered,NumLinesUncovered+from+ApexCodeCoverageAggregate';

        if(strResourceQuery != null) {
            strResponse = OrgREST.retriveResult(strResourceQuery, 'GET', null);
        }
        if(strResponse != null) {
            System.debug('Response '+strResponse);
            cw = new CoverageWrap();
            cw  = (CoverageWrap)JSON.deserialize(strResponse, CoverageWrap.class);
        }
        return cw;
    }

    @AuraEnabled
    public static ContentVersion saveCSVtoFiles(String strBlob) {
        if(String.isNotBlank(strBlob)) {
            ContentVersion cnv = new ContentVersion();
            ContentVersion cv = getCntVersion('Code Coverage.csv'); 
            if(cv != null && cv.VersionData != null) {
                delete new ContentDocument(Id = cv.ContentDocumentId);

                insert returnCntVersion(cnv, strBlob);
            }
            else {
                insert returnCntVersion(cnv, strBlob);
            }

            return cnv;

        }else {return null;}
    }

    public static ContentVersion returnCntVersion(ContentVersion cnv, String strBlob) {
        cnv.Title = 'Code Coverage.csv';
        cnv.PathOnClient = '/' + cnv.Title;
        cnv.FirstPublishLocationId = UserInfo.getUserId();
        cnv.VersionData = Blob.valueOf(strBlob);
        cnv.isMajorVersion = true;
        return cnv;
    }

    public static list<CSVData> processTestRecords(CoverageWrap cw) {
        list<CSVData> lstrows = new list<CSVData>();
        if(cw != null && cw.records != null && !cw.records.isEmpty()) {
            
            Integer orgTotalLines = 0;
            Integer totalCoveredLines = 0;
            Integer totalCountLines = 0;

            for(Records rec : cw.records) {
                CSVData obj = new CSVData();
                 // Total apex lines in org
                orgTotalLines = orgTotalLines + totalCountLines;
                  // Total lines of current apex class
                totalCountLines = Integer.valueOf(rec.NumLinesCovered) + Integer.valueOf(rec.NumLinesUncovered);

                String percentage = '';
                if(totalCountLines > 0) {
                    percentage = String.valueOf(Math.round(Integer.valueOf(rec.NumLinesCovered) / Decimal.valueof(totalCountLines) * 100)) + '%';
                }
                else {
                    percentage = '0%';
                }

                obj.ApexClassOrTrigger = rec.ApexClassOrTrigger.Name;

                 // Percentage covered for current apex class
                obj.PercentageCovered =  percentage;
                lstrows.add(obj);
            }
        }
        return lstrows;
    }

    @AuraEnabled
    public static String getTestQueueData(){
        try {
            list<ApexTestQueueItem> lstQueueItem = [SELECT Id from ApexTestQueueItem WHERE Status IN: new Set<String>{'Holding', 'Queued', 'Preparing', 'Processing'} LIMIT 1];
            if(lstQueueItem != null && lstQueueItem.size() > 0) {
                return 'true';
            }else {
                return 'false';
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static void createCSVFileFromBatch(list<CSVData> lstRows, list<String> lstHeaders) {
        String headerRow = String.join(lstHeaders,',') + '\n';
        String concantenatedStr = headerRow;
        Integer i = 0;
        Integer rowListSize = lstRows.size();
        list<String> lstCSVRows = new list<String>();
        //assuming the rowList is in the correct format and each object in the list is a new record
        for(CSVData row :lstRows){
            String rowStr = row.ApexClassOrTrigger + ',' + row.PercentageCovered;
            lstCSVRows.add(rowStr);
        }
        String strCSVFile = concantenatedStr +  String.join(lstCSVRows,'\n');
        // Saving CSV File
        saveCSVtoFiles(strCSVFile);
    }

    @AuraEnabled
    public static list<CSVData> readCsvDataFromFile(){
        list<CSVData> lstData = new List<CSVData>();
        try {
            ContentVersion cv = getCntVersion('Code Coverage.csv');

            if(cv != null) {
                List <String> records = cv.VersionData.toString().split('\n');
                //Removing the Header
                records.remove(0);

                for (String record : records ) {
                    if (record != null) {
                        CSVData data = new CSVData();
                        List <String> row = record.split(',');
                        data.ApexClassOrTrigger = row[0];
                        data.PercentageCovered = row[1];
                        lstData.add(data);
                    }
                }
            }
            return lstData;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static ContentVersion getCntVersion(String strFileName) {
        list<ContentVersion> lstCnts = [SELECT Id, VersionData,ContentDocumentId FROM ContentVersion where Title = :strFileName AND IsLatest = true LIMIT 1];
        if(lstCnts != null && !lstCnts.isEmpty()) {
            return lstCnts[0];
        }
        else {return null;}
    }

    @AuraEnabled
    public static void sentEmails(list<Object> lstRecords, String toAddress, String strType) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        if(String.isNotBlank(toAddress)) {
            list<string> toAdds = new list<string>();
            if(toAddress.contains(',')) {
                toAdds.addAll(toAddress.split(','));
            }
            else {
                toAdds.add(toAddress);
            }
            
            email.setToAddresses(toAdds);
            if(strType == 'CompareBtn') {
                email.setSubject('Action Required: Apex Test Classes Coverage');
            }
            else if(strType == 'TestResBtn') {
                email.setSubject('Action Required: Test Classes are failed');
            }
            else if(strType == 'seealldata') {
                email.setSubject('Action Required: SeeAllData=true Test Classes');
            }
            
            email.setHtmlBody(generateHTMLBody(lstRecords, strType));
            try{
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            }catch(exception e){
                system.debug('ex => '+e.getMessage());
                throw new AuraHandledException(e.getMessage());
            }
        }
    }


    public static string generateHTMLBody(list<Object> lstRecords, String strType) {
        System.debug('lstRecords @@'+lstRecords);
        if(strType == 'CompareBtn') {
            return createTableForCompareEmailSent(lstRecords);
        }
        else if(strType == 'TestResBtn') {
            return createTableForTestResEmailSent(lstRecords);
        }
        else if(strType == 'seealldata') {
            return createTableForSellAllDataEmailSent(lstRecords);
        }
        else {return null;}
    }

    public static String createTableForCompareEmailSent(list<Object> lstRecords) {
        String htmlBody = 'Hi, <br/><br/> Below class doesn\'t have code coverage or decreased coverage.<br/><br/>';
        htmlBody += '<table border="1" style="border-collapse: collapse"><tr><th>ApexClassOrTrigger</th><th>Old Percentage</th><th>New Percentage</th><th>Percentage Changed</th></tr>';
        
        for(Object l : lstRecords){
            ParseCSVInfo obj = (ParseCSVInfo)JSON.deserialize(JSON.serialize(l), ParseCSVInfo.class);
            htmlBody += '<tr><td>' + obj.ApexClassOrTrigger + '</td><td>' + obj.OldPercentage + '</td><td>' + obj.NewPercentage + '</td><td>' + obj.PercentageChange + '</td></tr>';
        }

        htmlBody += '</table>';
        return htmlBody;
    }

    public static String createTableForTestResEmailSent(list<Object> lstRecords) {
        String htmlBody = 'Hi, <br/><br/> Below class are failed when running the test classes.<br/><br/>';
        htmlBody += '<table border="1" style="border-collapse: collapse;table-layout:fixed;width:800px;"><tr><th>ApexClassOrTrigger</th><th>Method Name</th><th>Message</th><th>StackTrace</th></tr>';
        
        for(Object l : lstRecords){
            ParseTestResCSVInfo obj = (ParseTestResCSVInfo)JSON.deserialize(JSON.serialize(l), ParseTestResCSVInfo.class);
            htmlBody += '<tr><td style="word-wrap:break-word;">' + obj.ApexClassOrTrigger + '</td><td style="word-wrap:break-word;">' + obj.MethodName + '</td><td style="word-wrap:break-word;">' + obj.Message + '</td><td style="word-wrap:break-word;">' + obj.StackTrace + '</td></tr>';
        }

        htmlBody += '</table>';  
        return htmlBody;
    }

    public static String createTableForSellAllDataEmailSent(list<Object> lstRecords) {
        String htmlBody = 'Hi, <br/><br/> Below class have SeeAllData=true in Test Classes<br/><br/>';
        htmlBody += '<table border="1" style="border-collapse: collapse;"><tr><th>Name</th><th>Status</th></tr>';
        
        for(Object l : lstRecords){
            ApexClass obj = (ApexClass)JSON.deserialize(JSON.serialize(l), ApexClass.class);
            htmlBody += '<tr><td style="word-wrap:break-word;">' + obj.Name + '</td><td style="word-wrap:break-word;">' + obj.Status + '</td></tr>';
        }

        htmlBody += '</table>';  
        return htmlBody;
    }

    @AuraEnabled(cacheable=true)
    public static list<ApexTestResult> getApexTestResults() {
        // SELECT ApexClass.Name, MethodName, Message, StackTrace, TestTimeStamp FROM ApexTestResult WHERE Outcome = 'Fail' and TestTimeStamp >= LAST_N_WEEKS:2
        list<ApexTestResult> lstRes = [SELECT ApexClass.Name, MethodName, Message, StackTrace, TestTimeStamp FROM ApexTestResult WHERE Outcome = 'Fail' and DAY_ONLY(TestTimeStamp) >= TODAY AND Apexclass.Name != null];
        if(lstRes != null) {
            return lstRes;
        } else {return null;}
    }

    @AuraEnabled(cacheable=true)
    public static list<ApexClass> getSeeAllDataTestClasses() {
        List<List<ApexClass>> testClasses = [FIND '@isTest(SeeAllData=true) or @istest(seealldata=true)' 
                           IN ALL FIELDS 
                           RETURNING ApexClass(Id, Name, Status WHERE NamespacePrefix = '' AND Name != 'CodeCoverageExportController')];
        if(!testClasses.isEmpty() && testClasses.size() > 0) {
            return (list<ApexClass>)testClasses[0];
        }
        else {return null;}
    }

    @AuraEnabled
    public static String runAllTestClasses() {
        String strMsg = null;
        try {
            list<ApexClass> lstApexClasses = new list<ApexClass>();
        
            List<List<ApexClass>> testClasses = [FIND '@istest or testmethod' 
                            IN ALL FIELDS 
                            RETURNING ApexClass(Id, Name WHERE NamespacePrefix = '')];
            if(!testClasses.isEmpty() && testClasses.size() > 0 && testClasses[0] != null) {
                if(!Test.isRunningTest()) {
                    lstApexClasses = (list<ApexClass>)testClasses[0];
                }
                else if(Test.isRunningTest()) {
                    ApexClass obj = new ApexClass();
        			obj.Id = '01p170000087CEjAAM';
        			obj.Name = 'ExamRegistrationControllerTest';
                    lstApexClasses.add(obj);
                }
            }
            if(lstApexClasses != null && !lstApexClasses.isEmpty()) {
                list<ApexTestQueueItem> lstTestItems = new list<ApexTestQueueItem>();
                for(ApexClass cls : lstApexClasses) {
                    lstTestItems.add(new ApexTestQueueItem(ApexClassId = cls.Id));
                }
                
                if(lstTestItems != null && !lstTestItems.isEmpty()) {
                    try {
                        INSERT lstTestItems;
                        strMsg = 'Success';
                    }
                    catch(Exception ex) {
                        System.debug('ex ==> '+ex.getMessage());
                        strMsg = ex.getMessage();
                    }
                }
            }
        }catch(Exception ex) {
            System.debug('ex => '+ex.getMessage());
            strMsg = ex.getMessage();
        }
        return strMsg;
        
    }


    // Wrapper Classes
    public class ParseCSVInfo {
        @AuraEnabled public String ApexClassOrTrigger;
        @AuraEnabled public String NewPercentage;
        @AuraEnabled public String OldPercentage;
        @AuraEnabled public String PercentageChange;
    }

    public class ParseTestResCSVInfo {
        @AuraEnabled public String ApexClassOrTrigger;
        @AuraEnabled public String MethodName;
        @AuraEnabled public String StackTrace;
        @AuraEnabled public String Message;
    }
    public class CSVData {
        @AuraEnabled public String ApexClassOrTrigger;
        @AuraEnabled public String PercentageCovered;
    }

    public class Attributes {
       @AuraEnabled public String type;
       @AuraEnabled public String url;
    }

    public class Records {
       @AuraEnabled public Attributes attributes;
       @AuraEnabled public String Id;
       @AuraEnabled public ApexClassOrTrigger ApexClassOrTrigger;
       @AuraEnabled public Integer NumLinesCovered;
       @AuraEnabled public Integer NumLinesUncovered;
       @AuraEnabled public String ApexClassOrTriggerId;
    }

    public class ApexClassOrTrigger {
       @AuraEnabled public Attributes attributes;
       @AuraEnabled public String Name;
    }
    
    public class CoverageWrap{
      @AuraEnabled public Integer size;
      @AuraEnabled public Integer totalSize;
      @AuraEnabled public Boolean done;
      @AuraEnabled public Object queryLocator;
      @AuraEnabled public String entityTypeName;
      @AuraEnabled  public List<Records> records;
    }
}