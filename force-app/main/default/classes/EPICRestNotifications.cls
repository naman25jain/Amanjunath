/*
    Createdby       : Pradeep Kumar
    CreatedDate     : 12/09/2021
    Story           : EPIC Notifications
*/
@RestResource(urlMapping='/EPICNotifications/*')
global with sharing class EPICRestNotifications {

    @HttpGet
    global static List<EPICNotificationsWrap> getEPICNotifications(){

        RestRequest request = RestContext.request;
        String rtName = Constants.CASE_RECORD_TYPE_EPIC_VER_REPORT_REQUEST;
        String internalStatus = Constants.CASE_STATUS_PENDING_SUBMISSION;
        List<EPICNotificationsWrap> epicNotificationsWrapList = new List<EPICNotificationsWrap>();
        String entityId = request.params.get('orgID');
        if(entityId == NULL){
            EPICNotificationsWrap wrapper = new EPICNotificationsWrap();
            wrapper.errorCode = 'ERR-001';
            wrapper.errorMessage = 'Missing Required parameter: orgID';
            epicNotificationsWrapList.add(wrapper);
            return epicNotificationsWrapList;
        }
        String isArchived = Request.params.get('isArchived');
        String isActive = Request.params.get('isActive');

        String queryString = 'SELECT Id,recordType.DeveloperName,CaseNumber,Contact.Name,Contact.LastName,Contact.FirstName,Document_Type__c,contactID,Contact.EPIC_ID__c,Contact.ECFMG_ID__c,Internal_Status__c,Reference_Number__c,Country_of_Entity__c,EPIC_Report_Status__c,EPIC_Report_Received_Date__c,'+
            'EPIC_Report_Available_Date__c,Issuing_Entity__c,Issuing_Entity__r.Name,EPIC_Report_Archived_Status__c,Secondary_Parent_Case__c,Secondary_Parent_Case__r.Internal_Status__c,Notification_Archived_Status__c,Notification_Available_Date__c,Verification_Request_Send_Date__c '+
            'FROM Case WHERE Entity__r.Entity_ID__c=:entityId and Document_Type__c != null AND recordType.DeveloperName =: rtName AND Internal_Status__c !=: internalStatus';
        
        String tempId = request.params.get('ID');
        String intealthId = '';
        String epicId = '';
        if(!String.isEmpty(tempId)){
        	if(tempId.substring(0,5) == 'ECFMG'){
                intealthId = request.params.get('ID');
            }else{
                epicId = request.params.get('ID');
            }   
        }
        System.debug('Intealth ID +++++ ' + intealthId);
        if(epicId != '' || intealthId != ''){//Service__c=:Constants.CASE_SERVICE_EPIC
            
            List<Contact> contactList = new List<Contact>();
            if(intealthId != ''){
            	contactList = [select Id from Contact where ECFMG_ID__c =: intealthId with SECURITY_ENFORCED limit 1 ];  
                System.debug('Insider  IntealthID +++++ ' + intealthId);
                queryString += ' and Contact.ECFMG_ID__C =: intealthId';
            }else if(epicId != ''){
                contactList = [select Id from Contact where EPIC_ID__c =: epicId with SECURITY_ENFORCED limit 1 ];
                queryString += ' and Contact.EPIC_ID__c =:epicId';
            }    
            
            if(contactList.size() == 0){
                EPICNotificationsWrap wrapper = new EPICNotificationsWrap ();
                wrapper.errorCode = 'ERR-002';
                wrapper.errorMessage = 'Invalid value: ID';
                epicNotificationsWrapList.add(wrapper);
                return epicNotificationsWrapList;
            }
        }
        String notificationID = null;
        if(!String.isBlank(Request.params.get('notificationID'))){
            notificationID = 'C-'+ String.valueOf(Request.params.get('notificationID'));
            //return getEPICReportsByNotificationtID(entityId, notificationID);
            queryString += ' and CaseNumber =: notificationID';
        }

        if(isArchived != null){
            Boolean archived = Boolean.valueOf(isArchived);
            queryString += ' and Notification_Archived_Status__c =: archived';
        }
        String startDate = Request.params.get('startDate');
        if(startDate != null){
            Date reqStartDate = Date.parse(startDate);
            queryString += ' and Verification_Request_Send_Date__c >=: reqStartDate'; 
        }
        String endDate = Request.params.get('endDate');
        if(endDate != null){
            Date reqEndDate = Date.parse(endDate);
            queryString += ' and Verification_Request_Send_Date__c <=: reqEndDate';
        }
        if(isActive != null){
            queryString += ' and Notification_Archived_Status__c =: false';
        }
        queryString += ' with SECURITY_ENFORCED';
        System.debug('queryString ++ ' + queryString);
        List<Case> caseList = Database.query(String.escapesinglequotes(queryString));
		System.debug('CaseList +++ ' + caseList.size() + ' +++++ ' + caseList );
        return getEPICNotifications(caseList, notificationID);
    }

    global static List<EPICNotificationsWrap > getEPICNotifications(List<Case> caseList, String notificationID){

        map<integer, string> monthMapStatic = new map<integer, string>();
        monthMapStatic.put(1, 'January');
        monthMapStatic.put(2, 'February');
        monthMapStatic.put(3, 'March');
        monthMapStatic.put(4, 'April');
        monthMapStatic.put(5, 'May');
        monthMapStatic.put(6, 'June');
        monthMapStatic.put(7, 'July');
        monthMapStatic.put(8, 'August');
        monthMapStatic.put(9, 'September');
        monthMapStatic.put(10, 'October');
        monthMapStatic.put(11, 'November');
        monthMapStatic.put(12, 'December');
        List<EPICNotificationsWrap > epicNotificationsWrapList = new List<EPICNotificationsWrap >();
        Set<String> statusId = new Set<String>{Constants.ASSET_STATUS_OUTDATED,Constants.ASSET_STATUS_MARKED_FOR_DELETION};
        //Set<String> documentNames = new Set<String>{'Attendance Start Date','Attendance End Date','Date Degree Issued',
              //  'Title of Medical Degree','Name on Document','Program Start Date', 'Program End Date', 'Issue Date'};

        if(!caseList.isEmpty()){

            Map<Id, Id> reportCVCaseMap = new Map<Id,Id>();
            Map<Id,CaseHistory> caseIDHistoryMap = new Map<Id, CaseHistory>();

            for(Case caseRec : caseList){
                reportCVCaseMap.put(caseRec.Id, caseRec.Secondary_Parent_Case__c);
            }
            System.debug('reportCVCaseMap ++++ ' + reportCVCaseMap);
            
            //Map<Id, Contact_Association_Type__c> cvCaseCatMap = new Map<Id,Contact_Association_Type__c>();
            //Map<Id, List<DocumentDetails>> caseCatMap = new Map<Id, List<DocumentDetails>>();
            Map<Id, List<Asset>> parentCaseAssetMap = new Map<Id, List<Asset>>();
            if(!reportCVCaseMap.isEmpty()){

                List<CaseHistory> caseHistoryList = [select Id, CaseId, NewValue, OldValue, CreatedDate from CaseHistory where Field = 'Internal_Status__c' and CaseId IN: reportCVCaseMap.values() order by CreatedDate DESC];
                if(caseHistoryList.size() > 0){
                    for(CaseHistory ch : caseHistoryList){
                        if(!caseIDHistoryMap.containsKey(ch.CaseId)){
                            caseIDHistoryMap.put(ch.CaseId, ch);
                        } 
                    }
                }

                Map<Id, List<DocumentDetails>> caseCatMap = getDocumentDetails(reportCVCaseMap);
                System.debug('caseCatMap ++++ ' + caseCatMap);
            
                for(Case caseRec : caseList){
                    EPICNotificationsWrap  wrapper = new EPICNotificationsWrap ();
                    wrapper.notificationID = caseRec.CaseNumber.substringAfter('-');
                    wrapper.applicant = caseRec.Contact.LastName + (caseRec.Contact.FirstName == null ? '' : ', '+caseRec.Contact.FirstName);
                    wrapper.intealthID = caseRec.Contact.ECFMG_ID__c;
                    wrapper.epicID = caseRec.Contact.EPIC_ID__c;
                    wrapper.credential = caseRec.Document_Type__c;
                    wrapper.credentialStatus = caseRec.Secondary_Parent_Case__r.Internal_Status__c; //caseRec.EPIC_Report_Status__c;
                    wrapper.credentialStatusDate = (caseIDHistoryMap.containsKey(caseRec.Secondary_Parent_Case__c)) ? String.valueOf(caseIDHistoryMap.get(caseRec.Secondary_Parent_Case__c).CreatedDate).replace(' ','T') : '';
                    if(parentCaseAssetMap.containsKey(caseRec.Secondary_Parent_Case__c)){
                        for(Asset ast : parentCaseAssetMap.get(caseRec.Secondary_Parent_Case__c)){
                            System.debug(' Inside Asset loop +++++ ' + +ast.Type__c + ' +++ ' + parentCaseAssetMap.get(caseRec.Secondary_Parent_Case__c));
                            if(ast.Type__c == 'Translation'){
                                wrapper.Translation = ast.Azure_Storage_URL__c; 
                            }else if(ast.RecordType.DeveloperName == 'Credential' && notificationID != null){
                                wrapper.Credential = ast.Azure_Storage_URL__c;//getCredentialBlob(ast.Azure_Storage_URL__c);
                                System.debug('Credential +++ ' + wrapper.Credential);
                            }
                        }
                    }
                    wrapper.fullNotification = '';
                    wrapper.issuingInstitution = caseRec.Issuing_Entity__r.Name;
                    wrapper.country = caseRec.Country_of_Entity__c == null ? null : caseRec.Country_of_Entity__c.toUpperCase();
                    wrapper.verificationRequestSent = caseRec.Verification_Request_Send_Date__c != null ? String.valueOf(caseRec.Verification_Request_Send_Date__c)+'T00:00:00' : null ;
                    wrapper.availableUntil = caseRec.Notification_Available_Date__c != null ? String.valueOf(caseRec.Notification_Available_Date__c)+'T00:00:00' : null;
                    wrapper.archived = caseRec.Notification_Archived_Status__c;
                    wrapper.documentDetails =  caseCatMap.isEmpty()? null : caseCatMap.get(caseRec.ID);
                    epicNotificationsWrapList.add(wrapper);
                }
            }
        }else{

            EPICNotificationsWrap  wrapper = new EPICNotificationsWrap ();
            wrapper.errorCode = '204';
            wrapper.errorMessage = 'No records found for the criteria provided';
            epicNotificationsWrapList.add(wrapper);
        }

        return epicNotificationsWrapList;
    }

    @HttpPost
    global static PostResponse updateArchive(String orgID, String notificationID, Boolean isArchived){
        PostResponse resp = new PostResponse();
        String caseNum = 'C-'+String.valueOf(notificationID);
        List<Case> oldCaseRec = [select Id,CaseNumber,contact.EPIC_ID__c,Entity__c,Entity__r.Entity_ID__c,EPIC_Report_Archived_Status__c,Notification_Archived_Status__c from Case where Entity__r.Entity_ID__c =:orgID and CaseNumber =: caseNum LIMIT 1];
        if(oldCaseRec.size() > 0){
            try {
                if(oldCaseRec[0].Notification_Archived_Status__c != isArchived){
                    Case updCaseRecord = new Case(Id = oldCaseRec[0].Id,  Notification_Archived_Status__c = isArchived);
                    if(Schema.sObjectType.Case.Fields.Notification_Archived_Status__c.isUpdateable()){
                        update updCaseRecord; 
                    }
                    resp.archivedStatus = 'true';
                }else{
                    resp.archivedStatus = '';
                    resp.errorCode = 'ERR-003';
                    if(isArchived == true){
                        resp.errorMessage = 'Cannot archive already archived notification!';
                    }else{
                        resp.errorMessage = 'Cannot activate already active notification';
                    }
                    
                }
                
            } catch (DMLException e) {
                System.debug('Error updating the Notification +++ ' + e.getMessage() + ' ' + e.getStackTraceString());
                resp.archivedStatus = 'false';
                resp.errorCode = String.valueOf(e.getDmlType(0));
                resp.errorMessage = e.getDmlMessage(0);
            }
        }else{
            resp.archivedStatus = 'false';
            resp.errorCode = '204';
            resp.errorMessage = 'No records found for the criteria provided';
        }
        
        return resp;
    }

    public static Map<Id, List<DocumentDetails>> getDocumentDetails(Map<Id, Id> reportCVCaseMap){

        System.debug('+++ Inside GetDocumentDetails +++ ');
        map<integer, string> monthMapStatic = new map<integer, string>();
        monthMapStatic.put(1, 'January');
        monthMapStatic.put(2, 'February');
        monthMapStatic.put(3, 'March');
        monthMapStatic.put(4, 'April');
        monthMapStatic.put(5, 'May');
        monthMapStatic.put(6, 'June');
        monthMapStatic.put(7, 'July');
        monthMapStatic.put(8, 'August');
        monthMapStatic.put(9, 'September');
        monthMapStatic.put(10, 'October');
        monthMapStatic.put(11, 'November');
        monthMapStatic.put(12, 'December');

        Map<Id, Contact_Association_Type__c> cvCaseCatMap = new Map<Id,Contact_Association_Type__c>();
        Map<Id, Contact_Association_Type_Staging__c> cvCaseCatsMap = new Map<Id, Contact_Association_Type_Staging__c>();
        Map<Id, object> cvCaseCatObjMap = new Map<Id, object>();
        Map<Id, List<DocumentDetails>> caseCatMap = new Map<Id, List<DocumentDetails>>();
        List<Id> catsCaseIds = new List<Id>();
        List<Contact_Association_Type__c> catList = [select Id,Case__c,Parent_Case__c,Attendance_Start_Date__c,Attendance_End_Date__c,Expiration_Date__c,
        Degree_Issue_Year__c,Degree_Title__c,Name_on_Document__c,Credential_Type__c,Case__r.Contact.EPIC_ID__c,Case__r.Document_Type__c,Issue_Date__c,Title__c,
        Degree_expected_to_be_issued_Month__c,Degree_expected_to_be_issued_Year__c,Program_Start_Date__c,Program_End_Date__c,School_Program__c
        from Contact_Association_Type__c where Case__c IN: reportCVCaseMap.values() ];
        
        System.debug('Cat List +++++ ' + catList.size() + ' ++++ ' + catList);
        if(!catList.isEmpty()){
            for(Contact_Association_Type__c catRec : catList){
                cvCaseCatMap.put(catRec.Case__c, catRec);
            }
        }
        for(ID cvCaseID : reportCVCaseMap.values()){
            if( !cvCaseCatMap.containsKey(cvCaseID)){
                catsCaseIds.add(cvCaseID);
            }
        }
        System.debug('catsCaseIds +++ ' + catsCaseIds);
        if(catsCaseIds.size() > 0){
            System.debug('Inside catsCaseIds +++++'+catsCaseIds);
            List<Contact_Association_Type_Staging__c> catsList = [select Id,Case__c,Parent_Case__c,Attendance_Start_Date__c,Attendance_End_Date__c,Expiration_Date__c,
                Degree_Issue_Year__c,Degree_Title__c,Name_on_Document__c,Credential_Type__c,Case__r.Contact.EPIC_ID__c,Case__r.Document_Type__c,Issue_Date__c,Title__c,
                Degree_expected_to_be_issued_Month__c,Degree_expected_to_be_issued_Year__c,Program_Start_Date__c,Program_End_Date__c,School_Program__c
                from Contact_Association_Type_Staging__c where Case__c IN: catsCaseIds];//reportCVCaseMap.values() ];
            if(!catsList.isEmpty()){
                for(Contact_Association_Type_Staging__c catsRec : catsList){
                    cvCaseCatsMap.put(catsRec.Case__c, catsRec);
                }
            }
            System.debug('cvCaseCatsMap ++++' + cvCaseCatsMap.size() + ' +++++ ' + cvCaseCatsMap );
        }

        System.debug('cvCaseCatMap ++++ ' + cvCaseCatMap);
        if(!cvCaseCatMap.isEmpty()){
            for(ID caseKey : reportCVCaseMap.keySet()){
                List<DocumentDetails> documentDetailsList = new List<DocumentDetails>();
                String credentialName = cvCaseCatMap.get(reportCVCaseMap.get(caseKey)) != null ? cvCaseCatMap.get(reportCVCaseMap.get(caseKey)).Case__r.Document_Type__c : null ;
                List<String> documentNames = fetchDocumentDetailsNames(credentialName);
                for(String dname : documentNames){
                    DocumentDetails ddRecord = new DocumentDetails();
                    if(dname == 'Degree expected to be issued Year'){
                        ddRecord.name = dname;
                        ddRecord.value = cvCaseCatMap.get(reportCVCaseMap.get(caseKey)) == null ? null : cvCaseCatMap.get(reportCVCaseMap.get(caseKey)).Degree_expected_to_be_issued_Year__c;
                    }else if(dname == 'Expiration Date'){
                        ddRecord.name = dname;
                        Date testDate = cvCaseCatMap.get(reportCVCaseMap.get(caseKey)) == null ? null : Date.valueOf(cvCaseCatMap.get(reportCVCaseMap.get(caseKey)).Expiration_Date__c);
                        ddRecord.value = testDate == null ? null : monthMapStatic.get(testDate.month()) + ' ' + testDate.year();
                    }if(dname == 'Program Start Date'){
                        ddRecord.name = dname;
                        Date testDate = cvCaseCatMap.get(reportCVCaseMap.get(caseKey)) == null ? null : Date.valueOf(cvCaseCatMap.get(reportCVCaseMap.get(caseKey)).Program_Start_Date__c);
                        ddRecord.value = testDate == null ? null : monthMapStatic.get(testDate.month()) + ' ' + testDate.year(); 
                    }else if(dname == 'Program End Date'){
                        ddRecord.name = dname;
                        Date testDate = cvCaseCatMap.get(reportCVCaseMap.get(caseKey)) == null ? null : Date.valueOf(cvCaseCatMap.get(reportCVCaseMap.get(caseKey)).Program_End_Date__c);
                        ddRecord.value = testDate == null ? null : monthMapStatic.get(testDate.month()) + ' ' + testDate.year(); 
                    }else if(dname == 'Program Name' || dname == 'Title'){
                        ddRecord.name = dname;
                        ddRecord.value = String.valueOf(cvCaseCatMap.get(reportCVCaseMap.get(caseKey)).Title__c); 
                    }else if(dname == 'Issue Date'){
                        ddRecord.name = dname;
                        Date testDate = cvCaseCatMap.get(reportCVCaseMap.get(caseKey)) == null ? null : Date.valueOf(cvCaseCatMap.get(reportCVCaseMap.get(caseKey)).Issue_Date__c);
                        ddRecord.value = testDate == null ? null : monthMapStatic.get(testDate.month()) + ' ' + testDate.year(); 
                    }else if(dname == 'Attendance Start Date'){
                        ddRecord.name = dname;
                        Date testDate = cvCaseCatMap.get(reportCVCaseMap.get(caseKey)) == null ? null : Date.valueOf(cvCaseCatMap.get(reportCVCaseMap.get(caseKey)).Attendance_Start_Date__c);
                        ddRecord.value = testDate == null ? null : monthMapStatic.get(testDate.month()) + ' ' + testDate.year(); 
                    }else if(dname == 'Attendance End Date'){
                        ddRecord.name = dname;
                        Date testDate = cvCaseCatMap.get(reportCVCaseMap.get(caseKey)) == null ? null : Date.valueOf(cvCaseCatMap.get(reportCVCaseMap.get(caseKey)).Attendance_End_Date__c);
                        ddRecord.value = testDate == null ? null : monthMapStatic.get(testDate.month()) + ' ' + testDate.year(); 
                    }else if(dname == 'Degree Issue Date'){
                        ddRecord.name = dname;
                        if(cvCaseCatMap.get(reportCVCaseMap.get(caseKey)) != null && (cvCaseCatMap.get(reportCVCaseMap.get(caseKey)).Degree_expected_to_be_issued_Month__c != null && cvCaseCatMap.get(reportCVCaseMap.get(caseKey)).Degree_expected_to_be_issued_Year__c != null)){
                            ddRecord.value = cvCaseCatMap.get(reportCVCaseMap.get(caseKey)).Degree_expected_to_be_issued_Month__c + ' ' + cvCaseCatMap.get(reportCVCaseMap.get(caseKey)).Degree_expected_to_be_issued_Year__c;
                        }
                    }else if(dname == 'Title of Medical Degree'){
                        ddRecord.name = dname;
                        ddRecord.value = cvCaseCatMap.get(reportCVCaseMap.get(caseKey)) == null ? null : cvCaseCatMap.get(reportCVCaseMap.get(caseKey)).Degree_Title__c;
                    }else if(dname == 'Name on Document'){
                        ddRecord.name = dname;
                        ddRecord.value = cvCaseCatMap.get(reportCVCaseMap.get(caseKey)) == null ? null : cvCaseCatMap.get(reportCVCaseMap.get(caseKey)).Name_on_Document__c;
                    }
                    documentDetailsList.add(ddRecord);
                }
                if(!caseCatMap.containsKey(caseKey)){
                    caseCatMap.put(caseKey, documentDetailsList);
                }      
            }
            System.debug(' Case CAT Map +++++ ' + caseCatMap);
        }

        if(!cvCaseCatsMap.isEmpty()){
            for(ID caseKey : reportCVCaseMap.keySet()){
                if(catsCaseIds.contains(reportCVCaseMap.get(caseKey))){
                    List<DocumentDetails> documentDetailsList = new List<DocumentDetails>();
                    String credentialName = cvCaseCatsMap.get(reportCVCaseMap.get(caseKey)) != null ? cvCaseCatsMap.get(reportCVCaseMap.get(caseKey)).Case__r.Document_Type__c : null ;
                    List<String> documentNames = fetchDocumentDetailsNames(credentialName);
                    for(String dname : documentNames){
                        DocumentDetails ddRecord = new DocumentDetails();
                        if(dname == 'Degree expected to be issued Year'){
                            ddRecord.name = dname;
                            ddRecord.value = cvCaseCatsMap.get(reportCVCaseMap.get(caseKey)) == null ? null : cvCaseCatsMap.get(reportCVCaseMap.get(caseKey)).Degree_expected_to_be_issued_Year__c;
                        }else if(dname == 'Expiration Date'){
                            ddRecord.name = dname;
                            Date testDate = cvCaseCatsMap.get(reportCVCaseMap.get(caseKey)) == null ? null : Date.valueOf(cvCaseCatsMap.get(reportCVCaseMap.get(caseKey)).Expiration_Date__c);
                            ddRecord.value = testDate == null ? null : monthMapStatic.get(testDate.month()) + ' ' + testDate.year();
                        }if(dname == 'Program Start Date'){
                            ddRecord.name = dname;
                            Date testDate = cvCaseCatsMap.get(reportCVCaseMap.get(caseKey)) == null ? null : Date.valueOf(cvCaseCatsMap.get(reportCVCaseMap.get(caseKey)).Program_Start_Date__c);
                            ddRecord.value = testDate == null ? null : monthMapStatic.get(testDate.month()) + ' ' + testDate.year(); 
                        }else if(dname == 'Program End Date'){
                            ddRecord.name = dname;
                            Date testDate = cvCaseCatsMap.get(reportCVCaseMap.get(caseKey)) == null ? null : Date.valueOf(cvCaseCatsMap.get(reportCVCaseMap.get(caseKey)).Program_End_Date__c);
                            ddRecord.value = testDate == null ? null : monthMapStatic.get(testDate.month()) + ' ' + testDate.year(); 
                        }else if(dname == 'Program Name' || dname == 'Title'){
                            ddRecord.name = dname;
                            ddRecord.value = String.valueOf(cvCaseCatsMap.get(reportCVCaseMap.get(caseKey)).Title__c); 
                        }else if(dname == 'Issue Date'){
                            ddRecord.name = dname;
                            Date testDate = cvCaseCatsMap.get(reportCVCaseMap.get(caseKey)) == null ? null : Date.valueOf(cvCaseCatsMap.get(reportCVCaseMap.get(caseKey)).Issue_Date__c);
                            ddRecord.value = testDate == null ? null : monthMapStatic.get(testDate.month()) + ' ' + testDate.year(); 
                        }else if(dname == 'Attendance Start Date'){
                            ddRecord.name = dname;
                            Date testDate = cvCaseCatsMap.get(reportCVCaseMap.get(caseKey)) == null ? null : Date.valueOf(cvCaseCatsMap.get(reportCVCaseMap.get(caseKey)).Attendance_Start_Date__c);
                            ddRecord.value = testDate == null ? null : monthMapStatic.get(testDate.month()) + ' ' + testDate.year(); 
                        }else if(dname == 'Attendance End Date'){
                            ddRecord.name = dname;
                            Date testDate = cvCaseCatsMap.get(reportCVCaseMap.get(caseKey)) == null ? null : Date.valueOf(cvCaseCatsMap.get(reportCVCaseMap.get(caseKey)).Attendance_End_Date__c);
                            ddRecord.value = testDate == null ? null : monthMapStatic.get(testDate.month()) + ' ' + testDate.year(); 
                        }else if(dname == 'Degree Issue Date'){
                            ddRecord.name = dname;
                            if(cvCaseCatsMap.get(reportCVCaseMap.get(caseKey)) != null && (cvCaseCatsMap.get(reportCVCaseMap.get(caseKey)).Degree_expected_to_be_issued_Month__c != null && cvCaseCatsMap.get(reportCVCaseMap.get(caseKey)).Degree_expected_to_be_issued_Year__c != null) ){
                                ddRecord.value = cvCaseCatsMap.get(reportCVCaseMap.get(caseKey)).Degree_expected_to_be_issued_Month__c + ' ' + cvCaseCatsMap.get(reportCVCaseMap.get(caseKey)).Degree_expected_to_be_issued_Year__c;
                            }
                        }else if(dname == 'Title of Medical Degree'){
                            ddRecord.name = dname;
                            ddRecord.value = cvCaseCatsMap.get(reportCVCaseMap.get(caseKey)) == null ? null : cvCaseCatsMap.get(reportCVCaseMap.get(caseKey)).Degree_Title__c;
                        }else if(dname == 'Name on Document'){
                            ddRecord.name = dname;
                            System.debug('cvCaseCatsMap --> ' + reportCVCaseMap.get(caseKey) + '----->' + cvCaseCatsMap.get(reportCVCaseMap.get(caseKey)));
                            ddRecord.value = cvCaseCatsMap.get(reportCVCaseMap.get(caseKey)) == null ? null : cvCaseCatsMap.get(reportCVCaseMap.get(caseKey)).Name_on_Document__c;
                        }
                        documentDetailsList.add(ddRecord);
                    }
                    
                    caseCatMap.put(caseKey, documentDetailsList);
                }  //end of for   
            }//end of if
            System.debug(' Case CAT Map +++++ ' + caseCatMap);
        }// end of IF

        return caseCatMap;
    }

    public static List<String> fetchDocumentDetailsNames(String credentialName){
        List<String> documentNames; 
        if(credentialName == 'Final Medical Diploma'){
            documentNames = new List<String>{'Name on Document', 'Degree Issue Date', 'Title of Medical Degree','Graduation Year', 'Attendance Start Date', 'Attendance End Date'};
        }else if(credentialName == 'Alternate Graduation Document'){
            documentNames = new List<String>{'Name on Document', 'Degree Issue Date', 'Date Degree expected to be Issued', 'Title of Medical Degree','Graduation Year', 'Attendance Start Date', 'Attendance End Date'};
        }else if(credentialName == 'Final Medical School Transcript'){
            documentNames = new List<String>{'Name on Document', 'Degree Issue Date', 'Title of Medical Degree','Graduation Year', 'Attendance Start Date', 'Attendance End Date'};
        }else if (credentialName == 'Student Medical School Transcript') {
            documentNames = new List<String>{'Name on Document','Attendance Start Date', 'Attendance End Date'};
        }else if(credentialName == 'Postgraduate Training Credential' || credentialName == 'Pregraduate Internship Certificate'){
            documentNames = new List<String>{'Name on Document', 'Program Name', 'Program Start Date', 'Program End Date', 'Issue Date'};
        }else if(credentialName == 'Specialist Qualification'){
            documentNames = new List<String>{'Name on Document', 'Title', 'Issue Date'};
        }else if(credentialName == 'Medical Registration Certificate/License to Practice Medicine' || credentialName == 'Certificate of Good Standing'){
            documentNames = new List<String>{'Name on Document', 'Issue Date', 'Expiration Date'};
        }else{
            documentNames = new List<String>{'Name on Document', 'Degree Issue Date', 'Date Degree expected to be Issued', 'Title of Medical Degree','Graduation Year', 'Attendance Start Date', 'Attendance End Date'};
        }
        return documentNames;
    }

    public static String getCredentialBlob(String azureURL){
        System.PageReference pageRef = new System.PageReference(azureURL);
        Blob ret = pageRef.getContentAsPDF();
        return EncodingUtil.base64Encode(ret);
    }

    global class EPICNotificationsWrap {
        global String notificationID {get;set;}
        global String applicant {get;set;}
        global String intealthID {get;set;}
        global String epicID {get;set;}
        global String credential {get;set;}
        global String credentialStatus {get;set;}
        global String credentialStatusDate {get;set;}
        global String translation {get;set;}
        global String fullNotification {get;set;}
        global String issuingInstitution {get;set;}
        global String country {get;set;}
        global String verificationRequestSent {get;set;}
        global String availableUntil {get;set;}
        global Boolean archived {get;set;}
        global List<DocumentDetails> documentDetails {get;set;} 
        //For Error messages
        global String errorCode {get;set;}
        global string errorMessage {get;set;}

        global EPICNotificationsWrap(){//Global Constructor for nullifying the attributes
            this.notificationID = '';
            this.applicant = '';
            this.intealthID = '';
            this.epicID = '';
            this.credential = '';
            this.credentialStatus = '';
            this.credentialStatusDate = '';
            this.translation = '';
            this.fullNotification = '';
            this.issuingInstitution = '';
            this.country = '';
            this.verificationRequestSent = '';
            this.archived = false;
            this.documentDetails = new List<DocumentDetails>();
            this.errorCode = '';
            this.errorMessage = '';
        }
    }
    global class DocumentDetails {
        global String name {get;set;}
        global String value {get;set;}
        global DocumentDetails(){//Constructor for initializing the attributes
            this.name = '';
            this.value = '';
        }
    }
    global class PostResponse{
        global string archivedStatus {get;set;}
        global string errorCode {get;set;}
        global string errorMessage {get;set;}
        global PostResponse(){//Constructor for initializing the attributes
            this.archivedStatus = '';
            this.errorCode = '';
            this.errorMessage = '';
        }

    }
}