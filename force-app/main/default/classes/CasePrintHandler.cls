/**
 * Sampath Karnati
 * * Handle new case print
 * ? Exposed as Public
 */
public with sharing class CasePrintHandler {

    static final String LOG_SOURCE = 'PrintHandler';
    static final String CASE_EXCEPTION_COMMENT = 'Print Error:';
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    @InvocableMethod(label='Print Case Asset' 
                     description='Get Case asset from Azure and print it.' 
                     category='Case Print')
    public static void printCaseAsset(List<List<AssetPrintDetail>> assetPrintDetails) {

        AssetPrintDetail assetPrintDetail;
       try 
       {   
          assetPrintDetail = assetPrintDetails[0][0]; 
          System.enqueueJob(new PrintHandler.PrintDocumentCall(assetPrintDetails[0]));
       } catch (Exception e) {
           // Insert a log message
            CommonUtils.logMessage(new Log_Message__c(Exception__c = e.getMessage(),
                                                    Source__c = LOG_SOURCE,
                                                    Date_Time_Logged__c = DateTime.now(),
                                                    Record_Id__c = assetPrintDetail.caseId));

            throw e;
       }
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}