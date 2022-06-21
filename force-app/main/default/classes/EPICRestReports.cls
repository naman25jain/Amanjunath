/*
    Createdby       : Pradeep Kumar
    CreatedDate     : 12/09/2021
    Story           : EPIC Reports
*/
@RestResource(urlMapping='/EPICReports/*')
global with sharing class EPICRestReports {

    @HttpGet
    global static List<EpicReportWrap> getEPICReports() {
        
        RestRequest request = RestContext.request;
        String rtName = Constants.CASE_RECORD_TYPE_EPIC_VER_REPORT_REQUEST;
        String internalStatus = Constants.CASE_STATUS_PENDING_SUBMISSION;
        String reportStatus = 'Report Sent';
        List<EpicReportWrap> epicReportWrapList = new List<EpicReportWrap>();
        String entityId = request.params.get('orgID');
        if(entityId == NULL){
            EpicReportWrap wrapper = new EpicReportWrap();
            wrapper.errorCode = 'ERR-001';
            wrapper.errorMessage = 'Missing Required parameter: orgID';
            EpicReportWrapList.add(wrapper);
            return EpicReportWrapList;
        }
        String isArchived = Request.params.get('isArchived');
        String isActive = Request.params.get('isActive');
        String reportID = null;
        String fullreport = Request.params.get('fullreport');
        if(!String.isBlank(String.valueOf(Request.params.get('reportID')))){
            reportID = 'C-'+ String.valueOf(Request.params.get('reportID'));
            if(Test.isRunningTest()){
                reportID = String.valueOf(Request.params.get('reportID'));
            }
            return getEPICReportsByReportID(entityId, reportID, fullreport);

        } 

        String queryString = 'SELECT Id,Entity__r.Entity_ID__c,recordType.DeveloperName,CaseNumber,'+
            'Contact.Name,Contact.LastName,Contact.FirstName,Document_Type__c,contactID,Contact.EPIC_ID__c,Contact.ECFMG_ID__c,Internal_Status__c,Reference_Number__c,'+
            'Country_of_Entity__c,EPIC_Report_Status__c,EPIC_Report_Received_Date__c,EPIC_Report_Available_Date__c,Issuing_Entity__c,'+
            'Issuing_Entity__r.Name,EPIC_Report_Archived_Status__c,Secondary_Parent_Case__c,Entity_External_Status__c FROM Case WHERE Entity__r.Entity_ID__c=:entityId and '+
            'Document_Type__c != null AND (recordType.DeveloperName =: rtname AND Internal_Status__c !=: internalStatus) and EPIC_Report_Status__c =: reportStatus ';
        
        String tempId = request.params.get('ID');
        System.debug('Temp ID +++ ' + tempId);
        String intealthId = '';
        String epicId = '';
        if(String.isNotBlank(tempId)){
        	if(tempId.substring(0,5) == 'ECFMG'){
            	intealthId = request.params.get('ID');
            }else{
                epicId = request.params.get('ID');
            }   
        }
        if(epicId != '' || intealthId != ''){//Service__c=:Constants.CASE_SERVICE_EPIC
            
            List<Contact> contactList = new List<Contact>();
            if(intealthId != ''){
            	contactList = [select Id from Contact where ECFMG_ID__c =: intealthId with SECURITY_ENFORCED limit 1 ];  
                queryString += ' and Contact.ECFMG_ID__C =: intealthId';
            }else if(epicId != ''){
                contactList = [select Id from Contact where EPIC_ID__c =: epicId with SECURITY_ENFORCED limit 1 ];
                queryString += ' and Contact.EPIC_ID__c =:epicId';
            }  
            
            if(contactList.size() == 0){
                EpicReportWrap wrapper = new EpicReportWrap();
                wrapper.errorCode = 'ERR-002';
                wrapper.errorMessage = 'Invalid value: ID';
                EpicReportWrapList.add(wrapper);
                return EpicReportWrapList;
            }
        }
        if(isArchived != null){
            Boolean archived = Boolean.valueOf(isArchived);
            queryString += ' and EPIC_Report_Archived_Status__c =: archived';
        }
        String startDate = Request.params.get('startDate');
        if(startDate != null){
            Date reqStartDate = Date.parse(startDate);
            queryString += ' and EPIC_Report_Received_Date__c >=: reqStartDate'; 
        }
        String endDate = Request.params.get('endDate');
        if(endDate != null){
            Date reqEndDate = Date.parse(endDate);
            queryString += ' and EPIC_Report_Received_Date__c <=: reqEndDate';
        }
        queryString += ' with SECURITY_ENFORCED';
        List<Case> caseList = Database.query(String.escapesinglequotes(queryString));
         
        return getEPICReports(caseList);
    }

    global static List<EpicReportWrap> getEPICReports(List<Case> caseList){

        List<EpicReportWrap> epicReportWrapList = new List<EpicReportWrap>();
        Set<String> statusId = new Set<String>{Constants.ASSET_STATUS_OUTDATED,Constants.ASSET_STATUS_MARKED_FOR_DELETION};
        //Set<String> documentNames = new Set<String>{'Attendance Start Date','Attendance End Date','Date Degree Issued',
        //        'Title of Medical Degree','Name on Document','Program Start Date', 'Program End Date', 'Issue Date', 'Program Name'};

        if(!caseList.isEmpty()){
            List<Id> contactIDList = new List<Id>();
            Map<String, Boolean> contactIBAnnotationMap = new Map<String, Boolean>();// Map<EPICID, IBAnnotation>
            Map<Id, Id> reportCVCaseMap = new Map<Id,Id>();

            for(Case caseRec : caseList){
                reportCVCaseMap.put(caseRec.Id, caseRec.Secondary_Parent_Case__c);
                contactIDList.add(caseRec.ContactId);
            }

            /*if(contactIDList.size() > 0){
                contactIBAnnotationMap = getIBAnnotationInfo(contactIDList);
            }*/
            
            //DocumentDetails to be pulled from CATS or CAT record
            System.debug('reportCVCaseMap ++++ ' + reportCVCaseMap);
            Map<Id, List<DocumentDetails>> caseCatMap = getDocumentDetails(reportCVCaseMap);

            for(Case caseRec : caseList){
                EpicReportWrap wrapper = new EpicReportWrap();
                wrapper.reportID = caseRec.CaseNumber.substringAfter('-');
                wrapper.credential = caseRec.Document_Type__c;
                wrapper.candidate = caseRec.Contact.LastName + (caseRec.Contact.FirstName == null ? '' : ', '+caseRec.Contact.FirstName);
                wrapper.epicID = caseRec.Contact.EPIC_ID__c;
                wrapper.referenceNumber = caseRec.Reference_Number__c == null ? '' : caseRec.Reference_Number__c ;
                wrapper.status = caseRec.Entity_External_Status__c; //caseRec.EPIC_Report_Status__c;
                wrapper.received = caseRec.EPIC_Report_Received_Date__c != null ? String.valueOf(caseRec.EPIC_Report_Received_Date__c)+'T00:00:00' : null ;
                wrapper.availableUntil = caseRec.EPIC_Report_Available_Date__c != null ? String.valueOf(caseRec.EPIC_Report_Available_Date__c)+'T00:00:00' : null;
                wrapper.issuingInstitution = caseRec.Issuing_Entity__r.Name;
                wrapper.country = caseRec.Country_of_Entity__c == null ? null : caseRec.Country_of_Entity__c.toUpperCase();
                wrapper.archived = caseRec.EPIC_Report_Archived_Status__c;
                wrapper.iBAnnotation = contactIBAnnotationMap.containsKey(caseRec.Contact.EPIC_ID__c) ? contactIBAnnotationMap.get(caseRec.Contact.EPIC_ID__c) : false;
                wrapper.documentDetails =  caseCatMap.isEmpty()? null : caseCatMap.get(caseRec.ID);
                wrapper.intealthID = caseRec.Contact.ECFMG_ID__c;
                EpicReportWrapList.add(wrapper);
            }
        }else{

            EpicReportWrap wrapper = new EpicReportWrap();
            wrapper.errorCode = '204';
            wrapper.errorMessage = 'No records found for the criteria provided';
            EpicReportWrapList.add(wrapper);
        }
        return EpicReportWrapList;
    }

    @HttpPost
    global static PostResponse updateArchive(String orgID, String reportID, Boolean isArchived){
        PostResponse resp = new PostResponse();
        String caseNum = 'C-'+String.valueOf(reportID);
        if(Test.isRunningTest()){
            caseNum = reportID;
        }
        Case oldCaseRec = [select Id,CaseNumber,contact.EPIC_ID__c,Entity__c,Entity__r.Entity_ID__c,EPIC_Report_Archived_Status__c from Case where Entity__r.Entity_ID__c =:orgId and CaseNumber =: caseNum with SECURITY_ENFORCED LIMIT 1];
        if(oldCaseRec != null){
            if(oldCaseRec.EPIC_Report_Archived_Status__c == isArchived){
                resp.ArchivedStatus = 'false';
            }
            else{
                try {
                    Case updCaseRecord = new Case(Id = oldCaseRec.Id,  EPIC_Report_Archived_Status__c = isArchived);
                    if(Schema.sObjectType.Case.Fields.EPIC_Report_Archived_Status__c.isUpdateable()){
                        update updCaseRecord;
                    } 
                } catch (DMLException e) {
                    System.debug('Error updating the Report +++ ' + e.getMessage() + ' ' + e.getStackTraceString());
                    resp.archivedStatus = 'false';
                    resp.errorCode = String.valueOf(e.getDmlType(0));
                    resp.errorMessage = e.getDmlMessage(0);
                }
                resp.ArchivedStatus = 'true';
            }
            
        }else{
            resp.archivedStatus = 'false';
            resp.errorCode = '204';
            resp.errorMessage = 'No records found for the criteria provided';
        }
        
        return resp;
    }

    global static List<EpicReportWrap> getEPICReportsByReportID(String entityId, String reportID, String fullreport){
        
        Set<String> statusId = new Set<String>{Constants.ASSET_STATUS_OUTDATED,Constants.ASSET_STATUS_MARKED_FOR_DELETION};
        Set<String> documentNames = new Set<String>{'Attendance Start Date','Attendance End Date','Degree Issue Date','Title of Medical Degree','Name on Document'};
        List<EpicReportWrap> responseWrap = new List<EpicReportWrap>();
        //Service__c=:Constants.CASE_SERVICE_EPIC AND
        List<case> caseList  =  [SELECT Id,Entity__r.Entity_ID__c,recordType.DeveloperName,CaseNumber,Contact.Name,Document_Type__c,contactID,Contact.EPIC_ID__c,Contact.ECFMG_ID__c,Internal_Status__c,Reference_Number__c,Country_of_Entity__c,EPIC_Report_Status__c,EPIC_Report_Received_Date__c,EPIC_Report_Available_Date__c,Issuing_Entity__c,Issuing_Entity__r.Name,EPIC_Report_Archived_Status__c,Secondary_Parent_Case__c
            FROM Case WHERE Entity__r.Entity_ID__c=:entityId AND CaseNumber = :reportID AND Document_Type__c != '' AND (recordType.DeveloperName =: Constants.CASE_RECORD_TYPE_EPIC_VER_REPORT_REQUEST AND Internal_Status__c !=: Constants.CASE_STATUS_PENDING_SUBMISSION) WITH SECURITY_ENFORCED];
        if(caseList.size() > 0){
            List<Id> contactIDList = new List<Id>();
            List<Id> caseIDList = new List<Id>();
            Map<String, Boolean> contactIBAnnotationMap = new Map<String, Boolean>();// Map<EPICID, IBAnnotation>

            for(Case caseRec : caseList){
                contactIDList.add(caseRec.ContactId);
                caseIDList.add(caseRec.Id);
                caseIDList.add(caseRec.Secondary_Parent_Case__c);
            }
            /*if(contactIDList.size() > 0){
                contactIBAnnotationMap = getIBAnnotationInfo(contactIDList);
            }*/

            List<Asset> assetList = [SELECT Id,Case__c,Type__c,Case__r.CaseNumber,Case__r.Contact.EPIC_ID__c,Source_Document__c,Status, Case__r.Document_Type__c,Case__r.Id,Azure_Storage_URL__c FROM Asset WHERE Status NOT IN:statusId AND 
                Case__c IN (SELECT Id FROM Case WHERE ID IN :caseIDList AND Document_Type__c != '' )] ; //AND ((recordType.DeveloperName =: Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION AND Internal_Status__c !=: Constants.CASE_STATUS_PENDING_SUBMISSION)
                    //OR (recordType.DeveloperName =: Constants.CASE_RECORD_TYPE_EXTRACTION_SUB_CASE AND Internal_Status__c =: Constants.CASE_STATUS_ACCEPTED)))];
			System.debug('AssetList ++++ ' + assetList.size() );
            if(assetList != null){
                EpicReportWrap wrapper = new EpicReportWrap();
                wrapper.reportID = reportID.substringAfter('-');
                for(Asset assetRec : assetList){
                    System.debug('Asset +++++ ' + assetRec);
                    wrapper.iBAnnotation = contactIBAnnotationMap.containsKey(assetRec.Case__r.Contact.EPIC_ID__c) ? contactIBAnnotationMap.get(assetRec.Case__r.Contact.EPIC_ID__c) : false;
                    wrapper.credential = assetRec.Case__r.Document_Type__c;
                    if(assetRec.Type__c == 'Verification Report' && assetRec.Case__c == caseList[0].Id){
                        wrapper.report = assetRec.Azure_Storage_URL__c;
                    }
                    if(assetRec.Type__c == 'Translation'){
                        wrapper.translation = assetRec.Azure_Storage_URL__c;
                    }else if(assetRec.Type__c == 'Verification Form'){
                        wrapper.verificationForm = assetRec.Azure_Storage_URL__c;
                    }else if(assetRec.Type__c == 'Verified Credential'){
                        wrapper.verifiedCredential = assetRec.Azure_Storage_URL__c;
                    }else if(wrapper.VerifiedCredential == null && assetRec.Source_Document__c == true && (assetRec.Type__c != 'Verified Credential' && assetRec.Type__c != 'Translation' )){
                        wrapper.sourceCredential = assetRec.Azure_Storage_URL__c;
                    }

                    if(wrapper.VerifiedCredential != null ){
                        wrapper.sourceCredential = null;
                    }
                }
                responseWrap.add(wrapper);
            }
            return responseWrap;
        }else{
            EpicReportWrap wrapper = new EpicReportWrap();
            wrapper.errorCode = '204';
            wrapper.errorMessage = 'No records found for the criteria provided';
            responseWrap.add(wrapper);
            return responseWrap;
        } 
    }

    public static Map<Id, List<DocumentDetails>> getDocumentDetails(Map<Id, Id> reportCVCaseMap){

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
                    
                caseCatMap.put(caseKey, documentDetailsList);   
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

    /*global static Map<String,Boolean> getIBAnnotationInfo(List<Id> contactIDList){
        Map<String, Boolean> contactIBAnnotationMap = new Map<String, Boolean>();
        if(contactIDList.size() > 0){
            System.debug(' Inside Investigation Case logic +++++');
            List<Case> investigationCaseList = [select Id,CaseNumber,ContactId,Contact.EPIC_ID__c,Annotation__c,RecordType.DeveloperName,
                Annotation_Text_for_Specialized__c from Case where ContactId IN :contactIDList and RecordType.DeveloperName = 'Investigation_Case'];
            for(Case cRec : investigationCaseList){
                if(cRec.Annotation__c != null ){
                    contactIBAnnotationMap.put(cRec.Contact.EPIC_ID__c, true);
                }else{
                    contactIBAnnotationMap.put(cRec.Contact.EPIC_ID__c, false);
                }
            }
            System.debug('contactIBAnnotationMap +++++ ' + contactIBAnnotationMap);
        }
        return contactIBAnnotationMap;
    }*/


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

    //Wrapper class
    global class EpicReportWrap{
        global String reportID;
        global String credential;
        global String candidate;
        global String intealthID;
        global String epicID;
        global String referenceNumber;
        global String status;
        global String received;
        global String availableUntil;
        global String issuingInstitution;
        global String country;
        global Boolean archived;
        global Boolean iBAnnotation;
        global List<DocumentDetails> documentDetails; //For Document Details
        global String verifiedCredential;
        global String verificationForm;
        global String translation;
        global String sourceCredential;
        global String report;
        global String fullReport;
    
        //For Error messages
        global String errorCode;
        global string errorMessage;
        
        global EpicReportWrap(){
            this.reportID = '';
            this.credential = '';
            this.candidate = '';
            this.intealthID = '';
            this.epicId = '';
            this.referenceNumber = '';
            this.status = '';
            this.received = '';
            this.availableUntil = '';
            this.issuingInstitution = '';
            this.country = '';
            this.archived = false;
            this.iBAnnotation = false;
            this.verifiedCredential = '';
            this.verificationForm = '';
            this.translation = '';
            this.sourceCredential = '';
            this.report = '';
            this.fullReport = '';
            this.errorCode = '';
            this.errorMessage = '';
        }
    }
    global class DocumentDetails {
        global String name;
        global String value;

        global DocumentDetails(){
            this.name = '';
            this.value = '';
        }
    }
    global class PostResponse{
        global string archivedStatus;
        global string errorCode;
        global string errorMessage;
    }
}