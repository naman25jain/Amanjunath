public with sharing class CibisSchedulingPermit{
    /*public static Id currentUserContactId(){
        Id currentUser = UserInfo.getUserId();
        List <User> userList = [SELECT contactId FROM User u Where u.Id =: currentUser WITH SECURITY_ENFORCED];
        Id contactId = userList[0].contactId;
        return contactId;
    }    
    public static List<NBME_Parameter__c> getParameter(string parameterTypeEpermit){       
        list<NBME_Parameter__c> nbmeList = [SELECT Base_Url__c, Client_Id__c, Client_Password__c, client_Type__c, Client_Code__c
                                      FROM NBME_Parameter__c WHERE Parameter_Type__c =:parameterTypeEpermit 
                                      WITH SECURITY_ENFORCED LIMIT 1]; 
        return nbmeList; 
    }     
    public static List <Exam_Registration__c> getExamDetail(){
        Id contactId =currentUserContactId();       
        Id epexRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD).getRecordTypeId();    
        List<Exam_Registration__c>  examRegList = [SELECT Id, Applicant__c, Case__c, Exam__c, Score_report_Document_id__c, 
                                                   Application_Id__c, Exam_Request_Id__c FROM Exam_Registration__c
                                                   WHERE Applicant__c =: contactId
                                                   AND Case__r.RecordTypeId =: epexRecordTypeId
                                                   AND Case__r.Internal_Status__c !=: Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD
                                                   AND Case__r.Internal_Status__c !=: Constants.CASE_STATUS_PENDING_SUBMISSION
                                                   AND Case__r.Internal_Status__c !=: Constants.CASE_STATUS_EXPIRED
                                                   AND Case__r.Internal_Status__c !=: Constants.CASE_STATUS_REJECTED
                                                   AND Case__r.Internal_Status__c !=: Constants.CASE_STATUS_ENROLLMENT_NOT_VERIFIED_MEDSCL
                                                   AND Exam_Status__c = null WITH SECURITY_ENFORCED ORDER BY Exam_Types__c];                                           
        return examRegList; 
    }

    @TestVisible
    private static String decryptData(string encryptedData){ 
        string errorMessage; 
        String decryptedData; 
        NBME_EPermit__c cusSetting = NBME_EPermit__c.getOrgDefaults();
        string secretKey = cusSetting.EPermit_Key__c; 
        string  sVector = cusSetting.EPermit_Vector__c; 
        blob key = blob.valueOf(secretKey);    
        Blob data = EncodingUtil.base64Decode(encryptedData);             
        String vectorString = sVector; 
        Blob bVector = EncodingUtil.convertFromHex(vectorString);
        try{ 
            Blob dataToDecrypt = Crypto.decrypt('AES256', key, bVector, data);
            decryptedData = dataToDecrypt.toString(); 
        } 
        catch(Exception e){ 
            errorMessage = e.getMessage();              
        } 
        return (string.isEmpty(errorMessage) ?  decryptedData :  null);  
    } 

    @TestVisible
    private static string encryptData(string sdata){         
        NBME_EPermit__c cusSetting = NBME_EPermit__c.getOrgDefaults();
        string secretKey = cusSetting.EPermit_Key__c; 
        string  sVector = cusSetting.EPermit_Vector__c; 
        Blob bVector = EncodingUtil.convertFromHex(sVector);
        blob key = blob.valueOf(secretKey);
        Blob data = Blob.valueOf(sdata); 
        Blob encryptedData = Crypto.encrypt('AES256', key, bVector, data);
        string base64EncryptedData = EncodingUtil.base64Encode(encryptedData);            
        return base64EncryptedData; 
    } 

    @AuraEnabled
    public static string buildUrlForEpermit(){
        string errorMessage;
        Datetime dt1 = Datetime.now(); 
        string timeStamp =dt1.format('MM/DD/YYYY HH:mm:ss');        
        Datetime gmtDateTime = System.now();
        string formatedGmtTime = gmtDateTime.format('yyyy-MM-dd HH:mm:ss\'Z\'');          
        List<NBME_Parameter__c> nbmeParam = getParameter(Constants.PARAMETER_TYPE_EPERMIT); 
        List <Exam_Registration__c> listExamReg =  getExamDetail(); 
        string finalUrl; 
        string clientCode = nbmeParam[0].Client_Code__c; 
        string clientType = nbmeParam[0].Client_Type__c; 
        string urlPrefix = nbmeParam[0].Base_Url__c; 
        string clientPassword=	nbmeParam[0].Client_Password__c;
        string examRequestId = String.ValueOf(listExamReg[0].Exam_Request_Id__c); 
        NBME_EPermit__c cusSetting = NBME_EPermit__c.getOrgDefaults();
        string secretKey = cusSetting.EPermit_Key__c; 
        string  sVector = cusSetting.EPermit_Vector__c; 
        try {
            If (!String.isBlank(examRequestId) ){
                string urlRelated = 'client_code=' + clientCode + ';client_type=' + clientType + ';exam_request_id=' + examRequestId + ';output_type=PDF' + ';time_stamp='+ timeStamp+   + ';original_sf_time_stamp=' +   formatedGmtTime  ; 
                urlRelated = urlRelated+';client_password='+clientPassword;                      	
                blob key = blob.valueOf(secretKey);         
                string encode = encryptData(urlRelated);
                finalUrl = urlprefix+ EncodingUtil.urlEncode(encode, 'UTF-8');  
            }else{
                NoDataFoundException dfe = new NoDataFoundException(); 
                dfe.setMessage('Exam Request Id is empty'); 
                throw dfe;  
            }             
        } catch (Exception e){
            errorMessage = e.getMessage(); 
            throw e;             
        }         
        return finalUrl; 
    }

    public static HttpResponse calloutNBMEforEpermit(string epermitUrl){        
        string errorMessage;
        blob resbody;
        string pdf;        
        Datetime dt1 =Datetime.now();         
        string timeStamp =dt1.format('yyyyMMddHHmmss');
        string fileName = 'NMBE_Epermit'+timeStamp+'.pdf'; 
        HttpResponse response; 
        try {
            string strJson; 
            Http http = new Http(); 
            HttpRequest request = new HttpRequest(); 
            request.setEndpoint(epermitUrl);  
            request.setMethod('GET');
            response = http.send(request);
            if (response.getStatusCode()==200){                 
                resbody = response.getBodyAsBlob();
                pdf = EncodingUtil.Base64Encode(resbody); 
            } 
        } catch (Exception e){
            errorMessage = e.getMessage(); 
            throw e;            
        } 
        return response; 
    }
    @AuraEnabled
    public static string getBase64Pdf(){
        string errorMessage;
        string pdfBase64String;
        string surl = buildUrlForEpermit(); 
        HttpResponse res = calloutNBMEforEpermit(surl); 
        try {            
            if (res.getStatusCode()==200){                 
                Blob resbody = res.getBodyAsBlob();
                pdfBase64String = EncodingUtil.Base64Encode(resbody);
            }   
        } catch (Exception e){
            errorMessage = e.getMessage(); 
            throw e;
        }
        return pdfBase64String; 
    }
    */
}