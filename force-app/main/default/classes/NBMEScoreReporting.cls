public inherited sharing class NBMEScoreReporting {

    public static string encryptData(string sdata){         
        NBME_Score_Reporting__c cusSetting = NBME_Score_Reporting__c.getOrgDefaults();
        string secretKey = cusSetting.ScoreReporting_Key__c; 
        string sVector = cusSetting.ScoreReporting_Vector__c; 
        Blob bVector = EncodingUtil.convertFromHex(sVector);
        blob key = blob.valueOf(secretKey);
        Blob data = Blob.valueOf(sdata);
        Blob encryptedData = Crypto.encrypt('AES256', key, bVector, data);  
        string base64EncryptedData = EncodingUtil.base64Encode(encryptedData);          
        return base64EncryptedData; 
    } 

    public static String decryptData(string encryptedData){         
        string errorMessage; 
        String decryptedData; 
        NBME_Score_Reporting__c cusSetting = NBME_Score_Reporting__c.getOrgDefaults();
        string secretKey = cusSetting.ScoreReporting_Key__c; 
        string sVector = cusSetting.ScoreReporting_Vector__c; 

        Blob data = EncodingUtil.base64Decode(encryptedData);    
        Blob key = Blob.valueOf(secretKey);      
        
        String vectorString = sVector; 
        Blob bVector = EncodingUtil.convertFromHex(vectorString);
        try{ 
            Blob dataToDecrypt = Crypto.decrypt('AES256', key, bVector, data);
            system.debug('decrypted '+dataToDecrypt.toString());
            decryptedData = dataToDecrypt.toString(); 
        } 
        catch(Exception e){ 
            errorMessage = e.getMessage();  
            system.debug('Error message at decryptDat '+errorMessage); 
        } 
        return (string.isEmpty(errorMessage) ?  decryptedData :  null);  
    } 

    @AuraEnabled
    public static string buildUrlForScoreReporting(string examId){                 
        Id contactId =NBMEEPermit.currentUserContactId(); 
        string finalUrl;   
        Datetime dt1 =Datetime.now(); 
        string timeStamp =(dt1.addHours(5)).format('yyyyMMddHHmmss');	
        string isAttached = 'Y';         
        List<NBME_Parameter__c> nbmeParam = NBMEEpermit.getParameter(Constants.PARAMETER_TYPE_SCORE_REPORTING);                              
        List<Exam_Registration__c>  er = [SELECT Score_report_Document_id__c, Application_Id__c from Exam_Registration__c
                                           WHERE  Applicant__c =: contactId 
                                           AND Id =: examId
                                           WITH SECURITY_ENFORCED LIMIT 1]; 
        
        string clientId = nbmeParam[0].Client_Id__c;         
        string urlPrefix = nbmeParam[0].Base_Url__c;                 
        string docId = er[0].Score_report_Document_id__c; 
        try {
            if (!String.isBlank(docId) ){
                NBME_Score_Reporting__c cusSetting = NBME_Score_Reporting__c.getOrgDefaults();
                string secretKey = cusSetting.ScoreReporting_Key__c; 
                string  sVector = cusSetting.ScoreReporting_Vector__c;         
                blob key = blob.valueOf(secretKey);         
                string dataToEncrypt = clientId + docId + timeStamp;         
                string encCode=   encryptData(dataToEncrypt); 
                blob bvalue = blob.valueOf(encCode); 
                string hexstring = EncodingUtil.convertToHex(bvalue);         
                string surl = urlprefix+isAttached+'&clientId=' + clientId + '&ddsDocId=' + docId + '&encCode=';          
                finalUrl = surl+EncodingUtil.urlEncode(hexstring, 'UTF-8'); 
            }else{
                NoDataFoundException dfe = new NoDataFoundException(); 
                dfe.setMessage('Document Id is empty' ); 
                throw dfe;  
            }            
        } catch (Exception e) {
            system.debug(e); 
            throw e;             
        }        
        return finalurl;        
    }

    public static HttpResponse calloutNBMEforScoreReporting(string surl){
        Datetime dt1 =Datetime.now();         
        string timeStamp =dt1.format('yyyyMMddHHmmss');        
        string fileName = 'ScoreReporting'+timeStamp+'.pdf'; 
        HttpResponse response; 
        
        try {            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(surl); 
            request.setMethod('GET');
            response = http.send(request);

            if (response.getStatusCode() == 200) {               
                blob resbody = response.getBodyAsBlob();
            }                               
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw e;            
        }
        return  response; 
    }    


    @AuraEnabled
    public static string getBase64Pdf(string examId){
        string pdfBase64String;
        string surl = buildUrlForScoreReporting(examId); 
        HttpResponse res = calloutNBMEforScoreReporting(surl); 
        try {            
            if (res.getStatusCode() == 200) {                 
                Blob resbody = res.getBodyAsBlob();
                pdfBase64String = EncodingUtil.Base64Encode(resbody);
            }   
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw e;
        }
        return pdfBase64String; 
    }

}