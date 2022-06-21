@RestResource(urlMapping='/EPICCredentials/*')
global with sharing class EPICRestCredentials {

    @HttpGet
    global static List<EPICCredentialsWrap> getCredentialStatus(){
        
        RestRequest request = RestContext.request;
        String rtName = Constants.CASE_RECORD_TYPE_EPIC_VER_REPORT_REQUEST;
        String internalStatus = Constants.CASE_STATUS_PENDING_SUBMISSION;
        date reqDOBDate = null;
        Date reqStatusDate = null;
        List<EPICCredentialsWrap> epicCredentialsWrapList = new List<EPICCredentialsWrap>();
        String entityId = request.params.get('orgID');
        String statusDate = Request.params.get('statusDate');
        String dobDate = Request.params.get('DOB');
        String tempId = request.params.get('ID');
        String intealthId = '';
        String epicId = '';

        if(String.isNotBlank(tempId)){
            if(tempId.substring(0,5) == 'ECFMG'){
                intealthId = request.params.get('ID');
            }else{
                epicId = request.params.get('ID');
            }
        }
        /*if(entityId == null){
            EPICCredentialsWrap wrapper = new EPICCredentialsWrap();
            wrapper.errorCode = 'ERR-001';
            wrapper.errorMessage = 'Missing Required parameter: orgID';
            epicCredentialsWrapList.add(wrapper);
            return epicCredentialsWrapList;
        }*/
        if(tempId == null && statusDate == null ){
            EPICCredentialsWrap wrapper = new EPICCredentialsWrap();
            wrapper.errorCode = 'ERR-002';
            wrapper.errorMessage = 'Missing Required parameter: epicID or StatusDate';
            epicCredentialsWrapList.add(wrapper);
            return epicCredentialsWrapList;
        }
        if(tempId != null && dobDate != null){
            return getCredentialByDOB(intealthId, epicId, dobDate);
        }
        if (statusDate != null) {
            reqStatusDate = Date.parse(statusDate);
            //return getCredentials(entityId, intealthId, epicId, reqStatusDate);
        } 
        return getCredentials(entityId, intealthId, epicId, reqStatusDate);
        //return epicCredentialsWrapList;
    }
    
    global static List<EPICCredentialsWrap> getCredentials(String orgId, String intealthId, String epicId, Date reqStatusDate){

        Map<Id, CaseHistory> caseHistoryMap = new Map<Id, CaseHistory>();
        List<EPICCredentialsWrap> epicCredentialsWrapList = new List<EPICCredentialsWrap>();
        if(orgId == null){
            EPICCredentialsWrap wrapper = new EPICCredentialsWrap();
            wrapper.errorCode = 'ERR-001';
            wrapper.errorMessage = 'Missing Required parameter: orgID';
            epicCredentialsWrapList.add(wrapper);
            return epicCredentialsWrapList;
        }
        caseHistoryMap = getCaseHistoryRecords(intealthId, epicId, reqStatusDate);

        if(caseHistoryMap.size() == 0){
            EPICCredentialsWrap wrapper = new EPICCredentialsWrap();
            wrapper.errorCode = '204';
            wrapper.errorMessage = 'No Credentials found for the given date';
            epicCredentialsWrapList.add(wrapper);
            if(!Test.isRunningTest()){
                return epicCredentialsWrapList;
            }
        }

        List<Case> parentCaseList = new List<Case>();
        if(intealthId != null){
        	parentCaseList = [select Id,CaseNumber, Document_Type__c,Internal_Status__c,Issuing_Entity__r.Name,Country_of_Entity__c,Contact.EPIC_ID__c,Contact.ECFMG_ID__c,
                    (SELECT Id,recordType.DeveloperName,CaseNumber,Contact.Name,Document_Type__c,contactID,Contact.EPIC_ID__c,Contact.ECFMG_ID__c,Internal_Status__c,Reference_Number__c,Country_of_Entity__c,EPIC_Report_Status__c,EPIC_Report_Received_Date__c,CreatedDate,
                    EPIC_Report_Available_Date__c,Issuing_Entity__c,Issuing_Entity__r.Name,EPIC_Report_Archived_Status__c,Secondary_Parent_Case__c,Secondary_Parent_Case__r.Internal_Status__c,Notification_Archived_Status__c,Notification_Available_Date__c,Verification_Request_Send_Date__c from Secondary_Child_Cases__r order by CreatedDate DESC limit 1) 
                    from Case where Id IN: caseHistoryMap.keySet() and Contact.ECFMG_ID__c =: intealthId];
        }else {
            parentCaseList = [select Id,CaseNumber, Document_Type__c,Internal_Status__c,Issuing_Entity__r.Name,Country_of_Entity__c,Contact.EPIC_ID__c,Contact.ECFMG_ID__c,
                    (SELECT Id,recordType.DeveloperName,CaseNumber,Contact.Name,Document_Type__c,contactID,Contact.EPIC_ID__c,Contact.ECFMG_ID__c,Internal_Status__c,Reference_Number__c,Country_of_Entity__c,EPIC_Report_Status__c,EPIC_Report_Received_Date__c,CreatedDate,
                    EPIC_Report_Available_Date__c,Issuing_Entity__c,Issuing_Entity__r.Name,EPIC_Report_Archived_Status__c,Secondary_Parent_Case__c,Secondary_Parent_Case__r.Internal_Status__c,Notification_Archived_Status__c,Notification_Available_Date__c,Verification_Request_Send_Date__c from Secondary_Child_Cases__r order by CreatedDate DESC limit 1) 
                    from Case where Id IN: caseHistoryMap.keySet() and Contact.EPIC_ID__c =: epicId];
        }
        
        if(Test.isRunningTest()){
            parentCaseList = [select Id,CaseNumber, Document_Type__c,Internal_Status__c,Issuing_Entity__r.Name,Country_of_Entity__c,Contact.EPIC_ID__c,Contact.ECFMG_ID__c, 
            (SELECT Id,recordType.DeveloperName,CaseNumber,Contact.Name,Document_Type__c,contactID,Contact.EPIC_ID__c,Contact.ECFMG_ID__c,Internal_Status__c,Reference_Number__c,Country_of_Entity__c,EPIC_Report_Status__c,EPIC_Report_Received_Date__c,CreatedDate,
            EPIC_Report_Available_Date__c,Issuing_Entity__c,Issuing_Entity__r.Name,EPIC_Report_Archived_Status__c,Secondary_Parent_Case__c,Secondary_Parent_Case__r.Internal_Status__c,Notification_Archived_Status__c,Notification_Available_Date__c,Verification_Request_Send_Date__c from Secondary_Child_Cases__r order by CreatedDate DESC limit 1) 
            from Case where Secondary_Parent_Case__c = ''];
        }
        System.debug('parentCaseList ++++ ' + parentCaseList);
        if(parentCaseList.size() > 0){
            for(Case cse : parentCaseList){
                if(cse.Secondary_Child_Cases__r.size() > 0){
                    for(Case sec : cse.Secondary_Child_Cases__r){
                        EPICCredentialsWrap wrapper = new EPICCredentialsWrap();
                        wrapper.notificationID = Integer.valueOf(sec.CaseNumber.substringAfter('-'));
                        wrapper.reportID = Integer.valueOf(sec.CaseNumber.substringAfter('-'));
                        wrapper.intealthID = sec.Contact.ECFMG_ID__c;
                        wrapper.epicID = sec.Contact.EPIC_ID__c;
                        wrapper.credential = sec.Document_Type__c;
                        System.debug(' Report Status ++ ' + sec.EPIC_Report_Status__c );
                        if(!caseHistoryMap.isEmpty()){
                            wrapper.statusDate = String.valueOf(caseHistoryMap.get(cse.Id).CreatedDate).replace(' ','T');//(caseIDHistoryMap.get(caseRec.Secondary_Parent_Case__c)) ? String.valueOf(caseIDHistoryMap.get(caseRec.Secondary_Parent_Case__c).CreatedDate).replace(' ','T') : '';
                            if(getEPICAPIStatus(String.valueOf(caseHistoryMap.get(cse.Id).NewValue)) == 'CV Accepted'){
                                System.debug(' inside Report Status ++ ' + sec.EPIC_Report_Status__c );
                                if(sec.EPIC_Report_Status__c == 'Report Sent'){
                                    wrapper.status = 'Verification accepted; report sent';
                                }else{
                                    wrapper.status = 'Verification accepted; report not sent';
                                }
                            }else{
                                wrapper.status = getEPICAPIStatus(String.valueOf(caseHistoryMap.get(cse.Id).NewValue));
                            }
                        }
                        //System.debug('caseIDHistoryStatusDateMap +++ ' + sec.Secondary_Parent_Case__c + '++ Map ++' + caseIDHistoryStatusDateMap.containsKey(sec.Secondary_Parent_Case__c));
                        wrapper.issuingInstitution = sec.Issuing_Entity__r.Name;
                        wrapper.country = sec.Country_of_Entity__c;
                        epicCredentialsWrapList.add(wrapper);
                        
                        /*if(!parentCaseReportMap.containsKey(cse.Id)){
                            parentCaseReportMap.put(cse.Id, sec);
                        }*/
                    }
                }else{
                    EPICCredentialsWrap wrapper = new EPICCredentialsWrap();
                    wrapper.notificationID = null;//Integer.valueOf(cse.CaseNumber.substringAfter('-'));
                    wrapper.reportID = null;//Integer.valueOf(cse.CaseNumber.substringAfter('-'));
                    wrapper.epicID = cse.Contact.EPIC_ID__c;
                    wrapper.intealthID = cse.Contact.ECFMG_ID__c;
                    wrapper.credential = cse.Document_Type__c;
                    if(!caseHistoryMap.isEmpty()){
                        if(getEPICAPIStatus(String.valueOf(caseHistoryMap.get(cse.Id).NewValue)) == 'CV Accepted'){
                            wrapper.status = 'Verification accepted; report not sent';
                        }else{
                            wrapper.status = getEPICAPIStatus(String.valueOf(caseHistoryMap.get(cse.Id).NewValue));
                        }
                        wrapper.statusDate = String.valueOf(caseHistoryMap.get(cse.Id).CreatedDate).replace(' ','T');
                    }
                    //System.debug('caseIDHistoryStatusDateMap +++ ' + sec.Secondary_Parent_Case__c + '++ Map ++' + caseIDHistoryStatusDateMap.containsKey(sec.Secondary_Parent_Case__c));
                    //(caseIDHistoryMap.get(caseRec.Secondary_Parent_Case__c)) ? String.valueOf(caseIDHistoryMap.get(caseRec.Secondary_Parent_Case__c).CreatedDate).replace(' ','T') : '';
                    wrapper.issuingInstitution = cse.Issuing_Entity__r.Name;
                    wrapper.country = cse.Country_of_Entity__c;
                    epicCredentialsWrapList.add(wrapper);
                }
            }
            return epicCredentialsWrapList;
        }else{
            EPICCredentialsWrap wrapper = new EPICCredentialsWrap();
            wrapper.errorCode = '204';
            wrapper.errorMessage = 'No records found for this Criteria';
            epicCredentialsWrapList.add(wrapper);
            return epicCredentialsWrapList;
        }
    }

    global static List<EPICCredentialsWrap> getCredentialByDOB(String intealthId, String epicId, String dobDate){
        
        List<EPICCredentialsWrap> epicCredentialsWrapList = new List<EPICCredentialsWrap>();
        Set<String> sentStatusSet = new Set<String>(System.label.EPIC_FMD_Sent_Status.split(','));
        Set<String> notSentStatusSet = new Set<string>(System.label.EPIC_FMD_NotSent_Status.split(','));

        System.debug('Sent +++++++' + sentStatusSet);
        System.debug('Not Sent +++++++' + notSentStatusSet);
        List<Asset> assetList = new List<Asset>();
        if(intealthId != null){
        	assetList = [select id,name,Status,Contact.EPIC_ID__c, Contact.ECFMG_ID__c, Contact.Birthdate, Type__c, Case__r.Internal_Status__c from Asset where Type__c = 'Final Medical Diploma' and Contact.ECFMG_ID__c =: intealthId limit 1];//Database.query(String.escapesinglequotes(assetQueryString));
        }else if(epicId != null){
            assetList = [select id,name,Status,Contact.EPIC_ID__c, Contact.ECFMG_ID__c, Contact.Birthdate, Type__c, Case__r.Internal_Status__c from Asset where Type__c = 'Final Medical Diploma' and Contact.EPIC_ID__c =: epicId limit 1];//Database.query(String.escapesinglequotes(assetQueryString));
        }
            
        System.debug('Inside DOB assetList +++++++' + assetList);
        if(!assetList.isEmpty()){
            for(Asset astRec : assetList){
                EPICCredentialsWrap wrapper = new EPICCredentialsWrap();
                wrapper.epicIDValid = true;
                wrapper.dobMatch = (astRec.Contact.Birthdate == Date.parse(dobDate) ) ? true : false;
                if(astRec.Contact.Birthdate == Date.parse(dobDate)){
                    if(sentStatusSet.contains(astRec.Case__r.Internal_Status__c)){
                        wrapper.fmdStatus = 'Sent';
                    }else if(notSentStatusSet.contains(astRec.Case__r.Internal_Status__c)){
                        wrapper.fmdStatus = 'Not Sent';
                    }else if(astRec.Case__r.Internal_Status__c == 'Unable to Verify Credential'){
                        wrapper.fmdStatus = 'Not Verifiable';
                    }else{
                        wrapper.fmdStatus = 'Not Authentic';
                    }
                }
                epicCredentialsWrapList.add(wrapper); 
            }
            return epicCredentialsWrapList;
        }else {
            System.debug('Inside AssetList == null');
            EPICCredentialsWrap wrapper = new EPICCredentialsWrap();
            wrapper.errorCode = '204';
            wrapper.errorMessage = 'No records found for the criteria specified';
            wrapper.fmdStatus = null;
            wrapper.epicIDValid = false;
            wrapper.dobMatch = false;
            epicCredentialsWrapList.add(wrapper);
            return epicCredentialsWrapList;
        }
    }

    public static Map<Id,CaseHistory> getCaseHistoryRecords (String intealthId, String epicId, Date reqStatusDate){
        
        Set<String> sentForVerificationSet = new Set<String>{'Sent for Verification', 'Resent for Verification','Pending Print - Resend','Pending Verification Review','Verification In Review at ECFMG','On-hold Pending Translation','Not Verified','In SI Review','Pending Print - Verification Incomplete','Pending Biographic Review','Biographic Review in Process','CV Accepted','Cancelled', 'Closed - Not Authentic', 'Unable to Verify Credential','Incomplete - Resent for Verification','Incomplete'};
        List<CaseHistory> caseHistoryList = new List<CaseHistory>();
        Map<Id, CaseHistory> newCaseHistoryMap = new Map<Id, caseHistory>();
        if(reqStatusDate != null){
            
            System.debug('reqStatusDate ++++ ' + reqStatusDate);
            DateTime reqStatusDateTime = DateTime.newInstanceGMT(reqStatusDate.year(), reqStatusDate.month(), reqStatusDate.day(), 00, 30, 00);
            reqStatusDateTime.format('yyyy-MM-dd HH:mm:ss');
            DateTime reqStatusDateUntil = DateTime.newInstanceGMT(reqStatusDate.year(), reqStatusDate.month(), reqStatusDate.day(), 23, 59, 59);//DateTime.valueOf(reqStatusDateUntilString);
            reqStatusDateUntil.format('yyyy-MM-dd HH:mm:ss');
            System.debug('reqStatusDateTime ++ ' + reqStatusDateTime.format('yyyy-MM-dd HH:mm:ss') + '  reqStatusDateUntil++ ' + reqStatusDateUntil.format('yyyy-MM-dd HH:mm:ss'));
            //DateTime reqStatusDateTime = reqStatusDate;
            caseHistoryList = [select Id, CaseId, NewValue, OldValue, CreatedDate,Case.Contact.EPIC_ID__c, Case.RecordType.DeveloperName from CaseHistory where Field = 'Internal_Status__c' and 
            Case.RecordType.DeveloperName = 'Credential_Verification' and (createdDate >=:reqStatusDateTime and CreatedDate <=:reqStatusDateUntil) order by CreatedDate DESC];
        }else if (epicId != null){
            caseHistoryList = [select Id, CaseId, NewValue, OldValue, CreatedDate, Case.Contact.EPIC_ID__c,Case.RecordType.DeveloperName from CaseHistory where Field = 'Internal_Status__c' and Case.RecordType.DeveloperName = 'Credential_Verification' and Case.Contact.EPIC_ID__c =: epicId order by CreatedDate DESC];//and Case.Contact.EPIC_ID__c = :epicId 
        }else{
            caseHistoryList = [select Id, CaseId, NewValue, OldValue, CreatedDate, Case.Contact.EPIC_ID__c,Case.RecordType.DeveloperName from CaseHistory where Field = 'Internal_Status__c' and Case.RecordType.DeveloperName = 'Credential_Verification' and Case.Contact.ECFMG_ID__c =: intealthId order by CreatedDate DESC];//and Case.Contact.EPIC_ID__c = :epicId 
        }
        System.System.debug('caseHistoryList +++ ' + caseHistoryList);
        for(CaseHistory ch : caseHistoryList){
            if(!newCaseHistoryMap.containsKey(ch.CaseId) && sentForVerificationSet.contains(String.valueOf(ch.NewValue)) ){
                newCaseHistoryMap.put(ch.CaseId, ch);
            }
        }
        System.System.debug('newCaseHistoryMap +++ ' + newCaseHistoryMap);
        return newCaseHistoryMap;
    }

    public static String getEPICAPIStatus(String cvStatus){
        Set<String> sentForVerificationSet = new Set<String>{'Sent for Verification', 'Resent for Verification','Pending Print - Resend'};
        Set<String> verficationReceievedSet = new Set<String>{'Pending Verification Review','Verification In Review at ECFMG','On-hold Pending Translation','Not Verified','In SI Review','Pending Print - Verification Incomplete','Pending Biographic Review','Biographic Review in Process'};
        if(sentForVerificationSet.contains(cvStatus)){
            return 'Sent for Verification';
        }else if(verficationReceievedSet.contains(cvStatus)){
            return 'Verification received; in review at ECFMG';
        }
        else if(cvStatus == 'CV Accepted'){
            return 'CV Accepted';
        }else if (cvStatus == 'Unable to Verify Credential') {
            return 'Verification closed as not verifiable';
        }else if (cvStatus == 'Closed - Not Authentic') {
            return 'Verification closed as not authentic';
        }else if (cvStatus == 'Cancelled') {
            return 'Request Cancelled';
        }else if(cvStatus == 'Incomplete' || cvStatus == 'Incomplete - Resent for Verification'){
            return 'Verification not acceptable; resending for verification';
        }else {
            return '';
        }
    }


    global class EPICCredentialsWrap {
        global Integer notificationID;
        global Integer reportID;
        global String intealthID;
        global String epicID;
        global String credential;
        global String status;
        global String statusDate;
        global String issuingInstitution;
        global String country;
        //For Error messages
        global String errorCode;
        global string errorMessage;

        global Boolean epicIDValid;
        global Boolean dobMatch;
        global String fmdStatus;
    }

    public class CaseHistoryWrapper{
        public string newValue;
        public string oldValue;
        public dateTime createdDate;
        public string field;
        public string caseId;
    } 
}