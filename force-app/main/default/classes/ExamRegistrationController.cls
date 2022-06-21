/**
* Class for Exam Registration
*
* @author        Enable Consulting
* @version       1.0
* @createdDate   20-FEB-2020
*/
public with sharing class ExamRegistrationController {
    
    public static final String dateFormatString  = 'MMM d,  yyyy';    
    /**
* Created by Nayana on 20/02/2020
* Method Name: getOtherMedicalSchoolsWithTransferCredits
* Purpose : Method to fetch other medical school records along with transfer credits if any
* Return Type : List of the contact association type staging records
*/
    @AuraEnabled(Cacheable = false)
    public static List<Contact_Association_Type__c > getOtherMedicalSchoolsWithTransferCredits() {
        //Code added by Shailaja. Date Format Stories. Added Month & Year for start & end dates
        Id contactId = AppForCertHelper.retrieveCurrentContactId();
        List<Contact_Association_Type__c > medicalschoolsList = new List<Contact_Association_Type__c >
            ([SELECT Id, Account__c, Account_Name__c, School_Program__c, Start_Date__c, End_Date__c, Start_Month__c, End_Month__c, Start_Year__c, End_Year__c, Student_ID__c, Specialty__c, Number_of_Years_Attended__c, Transfer_Credit_to_Degree_School__c,
              (SELECT Id, To_School__c, From_School__c, From_School_Name__c, Transfer_Credit_Course__c, Transfer_Credit_Grade__c, Course_Outcome__c, Credits_Earned_Month__c, Credits_Earned_Year__c FROM Transfer_Credits__r ORDER BY Name ASC),
              (SELECT Id, Document_is_not_in_English__c, Name_on_Document__c, Name_on_Document_is_Different__c, Type__c FROM Assets__r  WHERE Asset.status != :constants.ASSET_STATUS_MARKED_FOR_DELETION)
              FROM Contact_Association_Type__c
              WHERE Contact__c =: contactId AND recordType.DeveloperName =: Constants.CONASCTYPE_RECORD_TYPE_MEDICAL_SCHOOL
              ORDER BY createdDate ASC
             ]);
        return medicalschoolsList;
    }
    
    /**
* Created by Nayana on 20/02/2020
* Method Name: getOtherInstitutionsWithTransferCredits
* Purpose : Method to fetch other institution records along with transfer credits if any
* Return Type : List of the contact association type staging records
*/
    @AuraEnabled(Cacheable = false)
    public static List<Contact_Association_Type__c > getOtherInstitutionsWithTransferCredits() {
        //Code added by Shailaja. Date Format Stories. Added Month & Year for start & end dates
        Id contactId = AppForCertHelper.retrieveCurrentContactId();
        List<Contact_Association_Type__c > institutionsList = new List<Contact_Association_Type__c > ([SELECT Id, Account__c, Account_Name__c, School_Program__c, Start_Date__c, End_Date__c, Start_Month__c, End_Month__c, Start_Year__c, End_Year__c, Student_ID__c, Specialty__c, Number_of_Years_Attended__c, Transfer_Credit_to_Degree_School__c, (SELECT Id, To_School__c, From_School__c, From_School_Name__c, Transfer_Credit_Course__c, Transfer_Credit_Grade__c, Course_Outcome__c, Credits_Earned_Month__c, Credits_Earned_Year__c FROM Transfer_Credits__r ORDER BY Name ASC), (SELECT Id, Document_is_not_in_English__c, Name_on_Document__c, Name_on_Document_is_Different__c, Type__c FROM Assets__r WHERE  Asset.status != :constants.ASSET_STATUS_MARKED_FOR_DELETION)
                                                                                                       FROM Contact_Association_Type__c
                                                                                                       WHERE Contact__c =: contactId AND recordType.DeveloperName =: Constants.CONASCTYPE_RECORD_TYPE_OTHER_INSTITUTION
                                                                                                       ORDER BY createdDate ASC
                                                                                                      ]);
        return institutionsList;
    }
    
    // Purpose : Method to return the files/Documents uploaded by applicant for the app For Cert
    @AuraEnabled(Cacheable = false)
    public static Map<String, String > getAssetsAndDocuments(String recId){
        Map<String, String> returnValue = new Map<String, String> ();
        String tctId = null;
        String tctFile = '';
        String tctName = '';
        String tctNameDiff = '';
        String tctNameDoc = '';
        String tctTransId = null;
        String tctTrans = '';
        String tctTransFile = '';
        String tctTransName = '';
        String tctNameDocId = '';
        String tctTransNameDiff = '';
        Map<Id, Asset> assetsMap = new Map<Id, Asset> ();
        List<Id> assetIds = new List<Id>();
        List<Asset> assetList = [SELECT Id, Contact_Association_Type__c, Document_is_not_in_English__c, Name_on_Document__c, Name_on_Document_is_Different__c, Type__c, ParentId, Azure_Storage_URL__c FROM Asset WHERE
                                 Contact_Association_Type__c =: recId AND status != :constants.ASSET_STATUS_MARKED_FOR_DELETION WITH SECURITY_ENFORCED Order By CreatedDate ASC 
                                ];
        for (Asset assId: assetList) {
            if (assId.Type__c == Constants.ASSET_TYPE_TCT) {
                tctId = assId.Id;
            }
        }
        for (Asset rec: assetList) {
            assetIds.add(rec.Id);
            assetsMap.put(rec.Id, rec);
            if (rec.Type__c == Constants.ASSET_TYPE_TCT) {
                tctId = rec.Id;
                tctName = rec.Name_on_Document__c;
                tctNameDiff = checkBoolValue(rec.Name_on_Document_is_Different__c);
                tctTrans = checkBoolValue(rec.Document_is_not_in_English__c);
                tctFile = rec.Azure_Storage_URL__c;
            } else if (rec.Type__c == Constants.ASSET_TYPE_TRANSLATION && rec.ParentId == tctId) {
                tctTransId = rec.Id;
                tctTransName = rec.Name_on_Document__c;
                tctTransNameDiff = checkBoolValue(rec.Name_on_Document_is_Different__c);
                tctTransFile = rec.Azure_Storage_URL__c;
            } else if (rec.Type__c == Constants.ASSET_TYPE_NAME_DOC && rec.ParentId == tctId) {
                tctNameDocId = rec.Id;
                tctNameDoc = rec.Azure_Storage_URL__c;
            }
        }
        returnValue.put('tctId', tctId);
        returnValue.put('tctFile', tctFile);
        returnValue.put('tctName', tctName);
        returnValue.put('tctNameDiff', tctNameDiff);
        returnValue.put('tctNameDoc', tctNameDoc);
        returnValue.put('tctTransId', tctTransId);
        returnValue.put('tctTrans', tctTrans);
        returnValue.put('tctTransFile', tctTransFile);
        returnValue.put('tctTransName', tctTransName);
        returnValue.put('tctNameDocId', tctNameDocId);
        returnValue.put('tctTransNameDiff', tctTransNameDiff);
        returnValue.put('recid', recId);
        return returnValue;
    }
    
    /**
* Created by Praveen
* Method Name: checkBoolValue
* Purpose : Check if the passed value is true and return string value.
* Return Type : String
*/
    public static String checkBoolValue(Boolean boolVal) {
        String returnVal = 'No';
        if (boolVal) {
            returnVal = 'Yes';
        }
        
        return returnVal;
    }
    
    /**
* Created by Praveen
* Method Name: getFileUrls
* Purpose : Get the list of URL's of uploaded files and return as a map.
* Return Type : Map<String, String>
*/
    public static Map<String, String> getFileUrls(List<Id> assetIds, Map<Id, Asset> assetsMap, String tctId, String tctTransId) {
        Map<String, String> fileUrls = new Map<String, String> ();
        Map<Id, List<ContentDocumentLink>> contentMap = new Map<Id, List<ContentDocumentLink>> ();
        Map<Id, ContentVersion> contentVersionMap = new Map<Id, ContentVersion> ();
        contentMap = getContentMap(assetIds);
        contentVersionMap = getContentVersionMap(assetIds);
        for (Id assetId: assetsMap.keyset()) {
            Id fileId = getFileId(assetId, contentMap, contentVersionMap);
            
            Asset assetRecord = assetsMap.get(assetId);
            if (assetRecord.Type__c == Constants.ASSET_TYPE_TCT) {
                fileUrls.put('tctFile', Constants.FILE_DOWNLOAD_URL + fileId);
            } else if (assetRecord.Type__c == Constants.ASSET_TYPE_NAME_DOC && assetRecord.ParentId == tctId) {
                fileUrls.put('tctNameDoc', Constants.FILE_DOWNLOAD_URL + fileId);
            } else if (assetRecord.Type__c == Constants.ASSET_TYPE_TRANSLATION && assetRecord.ParentId == tctId) {
                fileUrls.put('tctTransFile', Constants.FILE_DOWNLOAD_URL + fileId);
            } else if (assetRecord.Type__c == Constants.ASSET_TYPE_NAME_DOC && assetRecord.ParentId == tctTransId) {
                fileUrls.put('tctTransNameDoc', Constants.FILE_DOWNLOAD_URL + fileId);
            }
        }
        
        return fileUrls;
    }
    
    /**
* Created by Praveen
* Method Name: getContentMap
* Purpose : To get the list of content documents of the assets.
* Return Type : Map<Id, List>
*/
    public static Map<Id, List<ContentDocumentLink>> getContentMap(List<Id> assetIds) {
        Map<Id, List<ContentDocumentLink>> contentMap = new Map<Id, List<ContentDocumentLink>> ();
        for (contentDocumentLink contentDoc: [SELECT Id, ContentDocumentId, LinkedEntityId, ContentDocument.LatestPublishedVersionId, ContentDocument.Title FROM contentDocumentLink WHERE LinkedEntityId IN: assetIds]) {
            if (!contentMap.containsKey(contentDoc.LinkedEntityId)) {
                contentMap.put(contentDoc.LinkedEntityId, new List<ContentDocumentLink> ());
            }
            contentMap.get(contentDoc.LinkedEntityId).add(contentDoc);
        }
        
        return contentMap;
    }
    
    /**
* Created by Praveen
* Method Name: getContentVersionMap
* Purpose : To get the list of content versions of the assets.
* Return Type : Map<Id, ContentVersion>
*/
    public static Map<Id, ContentVersion> getContentVersionMap(List<Id> assetIds) {
        List<Id> contentDocumentIds = new List<Id> ();
        Map<Id, ContentVersion> contentVersionMap = new Map<Id, ContentVersion> ();
        for (contentDocumentLink contentDoc: [SELECT Id, ContentDocumentId FROM contentDocumentLink WHERE LinkedEntityId IN: assetIds]) {
            contentDocumentIds.add(contentDoc.ContentDocumentId);
        }
        
        if (contentDocumentIds.size() > 0) {
            for (ContentVersion contentVer: [SELECT ContentDocumentId, ContentDocument.LatestPublishedVersionId, FileExtension, Title FROM ContentVersion WHERE ContentDocumentId IN: contentDocumentIds]) {
                contentVersionMap.put(contentVer.ContentDocumentId, contentVer);
            }
        }
        
        return contentVersionMap;
    }
    
    /**
* Created by Praveen
* Method Name: getFileId
* Purpose : To get the fileId of the document.
* Return Type : Id
*/
    public static Id getFileId(Id assetId, Map<Id, List<ContentDocumentLink>> contentMap, Map<Id, ContentVersion> contentVersionMap) {
        Id fileId;
        if (contentMap.get(assetId) != null) {
            for (ContentDocumentLink contentlink: contentMap.get(assetId)) {
                if (contentVersionMap.get(contentlink.ContentDocumentId) != null) {
                    fileId = contentVersionMap.get(contentlink.ContentDocumentId).ContentDocumentId;
                }
            }
        }
        
        return fileId;
    }
    
    // Purpose : Method to return the files/Documents uploaded by applicant for the app For Cert
    @AuraEnabled(Cacheable = false)
    public static Map<String, Map<String, String >> getInstAssetsAndDocuments() {
        Id contactId = AppForCertHelper.retrieveCurrentContactId();
        Map<String,
            Map<String, String>> returnValue = new Map<String,
            Map<String, String>> ();
        Map<Id, Asset> assetsMap = new Map<Id, Asset> ();
        List<Id> assetIds = new List<Id> ();
        List<Id> instIds = new List<Id> ();
        List<Contact_Association_Type__c > institutionsList = [SELECT Id, Account__c, Account_Name__c FROM Contact_Association_Type__c
                                                               WHERE Contact__c =: contactId AND recordType.DeveloperName =: Constants.CONASCTYPE_RECORD_TYPE_OTHER_INSTITUTION
                                                               ORDER BY createdDate ASC
                                                              ];
        for (Contact_Association_Type__c institution: institutionsList) {
            instIds.add(institution.Id);
        }
        List<Asset> assetList = [SELECT Id, Contact_Association_Type__c, Document_is_not_in_English__c, Name_on_Document__c, Name_on_Document_is_Different__c, Type__c, ParentId, Azure_Storage_URL__c FROM Asset WHERE
                                 Contact_Association_Type__c IN: instIds AND status != :constants.ASSET_STATUS_MARKED_FOR_DELETION Order By CreatedDate ASC
                                ];
        Map<String, String> tctInstMap = new Map<String, String> ();
        Map<String, String> pmlInstMap = new Map<String, String> ();
        for (Asset assId: assetList) {
            assetIds.add(assId.Id);
            assetsMap.put(assId.Id, assId);
            if (assId.Type__c == Constants.ASSET_TYPE_TCT) {
                tctInstMap.put(assId.Contact_Association_Type__c, assId.Id);
            } else if (assId.Type__c == Constants.ASSET_TYPE_PRE_MED_LETTER) {
                pmlInstMap.put(assId.Contact_Association_Type__c, assId.Id);
            }
        }
        Map<String, String> tctNameInstMap = new Map<String, String> ();
        Map<String, String> tctNameDiffInstMap = new Map<String, String> ();
        Map<String, String> tctTransInstMap = new Map<String, String> ();
        Map<String, String> tctTransIdInstMap = new Map<String, String> ();
        Map<String, String> tctNameDocIdInstMap = new Map<String, String> ();
        Map<String, String> tctTransNameInstMap = new Map<String, String> ();
        Map<String, String> tctTransNameDiffInstMap = new Map<String, String> ();
        Map<String, String> pmlNameInstMap = new Map<String, String> ();
        Map<String, String> pmlNameDiffInstMap = new Map<String, String> ();
        Map<String, String> pmlTransInstMap = new Map<String, String> ();
        Map<String, String> pmlTransIdInstMap = new Map<String, String> ();
        Map<String, String> pmlNameDocIdInstMap = new Map<String, String> ();
        Map<String, String> pmlTransNameInstMap = new Map<String, String> ();
        Map<String, String> pmlTransNameDiffInstMap = new Map<String, String> ();
        Map<String, String> tctFileInstMap = new Map<String, String> ();
        Map<String, String> tctNameDocInstMap = new Map<String, String> ();
        Map<String, String> tctTransFileInstMap = new Map<String, String> ();
        Map<String, String> pmlFileInstMap = new Map<String, String> ();
        Map<String, String> pmlNameDocInstMap = new Map<String, String> ();
        Map<String, String> pmlTransFileInstMap = new Map<String, String> ();
        for (Asset rec: assetList) {
            String assInstId = tctInstMap.get(rec.Contact_Association_Type__c);
            String assPmlInstId = pmlInstMap.get(rec.Contact_Association_Type__c);
            if (rec.Type__c == Constants.ASSET_TYPE_TCT) {
                tctNameInstMap.put(rec.Contact_Association_Type__c, rec.Name_on_Document__c);
                tctNameDiffInstMap.put(rec.Contact_Association_Type__c, checkBoolValue(rec.Name_on_Document_is_Different__c));
                tctTransInstMap.put(rec.Contact_Association_Type__c, checkBoolValue(rec.Document_is_not_in_English__c));
                tctFileInstMap.put(rec.Contact_Association_Type__c, rec.Azure_Storage_URL__c);
            } else if (rec.Type__c == Constants.ASSET_TYPE_PRE_MED_LETTER) {
                pmlNameInstMap.put(rec.Contact_Association_Type__c, rec.Name_on_Document__c);
                pmlNameDiffInstMap.put(rec.Contact_Association_Type__c, checkBoolValue(rec.Name_on_Document_is_Different__c));
                pmlTransInstMap.put(rec.Contact_Association_Type__c, checkBoolValue(rec.Document_is_not_in_English__c));
                pmlFileInstMap.put(rec.Contact_Association_Type__c, rec.Azure_Storage_URL__c);
            } else if (rec.Type__c == Constants.ASSET_TYPE_TRANSLATION && rec.ParentId == assInstId) {
                tctTransIdInstMap.put(rec.Contact_Association_Type__c, rec.Id);
                tctTransNameInstMap.put(rec.Contact_Association_Type__c, rec.Name_on_Document__c);
                tctTransNameDiffInstMap.put(rec.Contact_Association_Type__c, checkBoolValue(rec.Name_on_Document_is_Different__c));
                tctTransFileInstMap.put(rec.Contact_Association_Type__c, rec.Azure_Storage_URL__c);
            } else if (rec.Type__c == Constants.ASSET_TYPE_TRANSLATION && rec.ParentId == assPmlInstId) {
                pmlTransIdInstMap.put(rec.Contact_Association_Type__c, rec.Id);
                pmlTransNameInstMap.put(rec.Contact_Association_Type__c, rec.Name_on_Document__c);
                pmlTransNameDiffInstMap.put(rec.Contact_Association_Type__c, checkBoolValue(rec.Name_on_Document_is_Different__c));
                pmlTransFileInstMap.put(rec.Contact_Association_Type__c, rec.Azure_Storage_URL__c);
            } else if (rec.Type__c == Constants.ASSET_TYPE_NAME_DOC && rec.ParentId == assInstId) {
                tctNameDocIdInstMap.put(rec.Contact_Association_Type__c, rec.Id);
                tctNameDocInstMap.put(rec.Contact_Association_Type__c, rec.Azure_Storage_URL__c);
            } else if (rec.Type__c == Constants.ASSET_TYPE_NAME_DOC && rec.ParentId == assPmlInstId) {
                pmlNameDocIdInstMap.put(rec.Contact_Association_Type__c, rec.Id);
                pmlNameDocInstMap.put(rec.Contact_Association_Type__c, rec.Azure_Storage_URL__c);
            }
        }
        For(Id instId: instIds) {
            Map<String,
                String > instRetVal = new Map<String,
                String > ();
            instRetVal.put('tctId', tctInstMap.get(instId));
            instRetVal.put('tctFile', tctFileInstMap.get(instId));
            instRetVal.put('tctName', tctNameInstMap.get(instId));
            instRetVal.put('tctNameDiff', tctNameDiffInstMap.get(instId));
            instRetVal.put('tctNameDoc', tctNameDocInstMap.get(instId));
            instRetVal.put('tctTransId', tctTransIdInstMap.get(instId));
            instRetVal.put('tctNameDocId', tctNameDocIdInstMap.get(instId));
            instRetVal.put('tctTrans', tctTransInstMap.get(instId));
            instRetVal.put('tctTransFile', tctTransFileInstMap.get(instId));
            instRetVal.put('tctTransName', tctTransNameInstMap.get(instId));
            instRetVal.put('tctTransNameDiff', tctTransNameDiffInstMap.get(instId));
            instRetVal.put('pmlId', pmlInstMap.get(instId));
            instRetVal.put('pmlFile', pmlFileInstMap.get(instId));
            instRetVal.put('pmlName', pmlNameInstMap.get(instId));
            instRetVal.put('pmlNameDiff', pmlNameDiffInstMap.get(instId));
            instRetVal.put('pmlNameDoc', pmlNameDocInstMap.get(instId));
            instRetVal.put('pmlTransId', pmlTransIdInstMap.get(instId));
            instRetVal.put('pmlNameDocId', pmlNameDocIdInstMap.get(instId));
            instRetVal.put('pmlTrans', pmlTransInstMap.get(instId));
            instRetVal.put('pmlTransFile', pmlTransFileInstMap.get(instId));
            instRetVal.put('pmlTransName', pmlTransNameInstMap.get(instId));
            instRetVal.put('pmlTransNameDiff', pmlTransNameDiffInstMap.get(instId));
            returnValue.put(instId, instRetVal);
        }
        return returnValue;
    }
    
    /**
* Created by Praveen
* Method Name: getOtherInstFileUrls
* Purpose : Get the list of URL's of uploaded files in other institution and return as a map.
* Return Type : Map<String, String>
*/
    public static Map<String, String> getOtherInstFileUrls(List<Id> assetIds, Map<Id, Asset> assetsMap, Map<String, String> tctInstMap, Map<String, String> tctTransIdInstMap, Map<String, String> pmlInstMap, Map<String, String> pmlTransIdInstMap, String returnFileType) {
        Map<String, String> fileUrls = new Map<String, String> ();
        Map<Id, List<ContentDocumentLink>> contentMap = new Map<Id, List<ContentDocumentLink>> ();
        Map<Id, ContentVersion> contentVersionMap = new Map<Id, ContentVersion> ();
        contentMap = getContentMap(assetIds);
        contentVersionMap = getContentVersionMap(assetIds);
        
        for (Id assetId: assetsMap.keyset()) {
            Id fileId = getFileId(assetId, contentMap, contentVersionMap);
            
            Asset assetRecord = assetsMap.get(assetId);
            String tctId = tctInstMap.get(assetRecord.Contact_Association_Type__c);
            String tctTransId = tctTransIdInstMap.get(assetRecord.Contact_Association_Type__c);
            String pmlId = pmlInstMap.get(assetRecord.Contact_Association_Type__c);
            String pmlTransId = pmlTransIdInstMap.get(assetRecord.Contact_Association_Type__c);
            
            String fileUrl = getOtherInstFileUrl(assetRecord, returnFileType, tctId, tctTransId, pmlId, pmlTransId, fileId);
            if (fileUrl != '') {
                fileUrls.put(assetRecord.Contact_Association_Type__c, fileUrl);
            }
            
        }
        
        return fileUrls;
    }
    
    /**
* Created by Praveen
* Method Name: getOtherInstFileUrls
* Purpose : Get the list of URL's of uploaded files in other institution and return as a map.
* Return Type : Map<String, String>
*/
    public static String getOtherInstFileUrl(Asset assetRecord, String returnFileType, String tctId, String tctTransId, String pmlId, String pmlTransId, String fileId) {
        String fileUrl = '';
        
        if ((assetRecord.Type__c == Constants.ASSET_TYPE_TCT && returnFileType == 'tctFileInstMap') ||
            (assetRecord.Type__c == Constants.ASSET_TYPE_NAME_DOC && assetRecord.ParentId == tctId && returnFileType == 'tctNameDocInstMap') ||
            (assetRecord.Type__c == Constants.ASSET_TYPE_TRANSLATION && assetRecord.ParentId == tctId && returnFileType == 'tctTransFileInstMap') ||
            (assetRecord.Type__c == Constants.ASSET_TYPE_NAME_DOC && assetRecord.ParentId == tctTransId && returnFileType == 'tctTransNameDocInstMap') ||
            (assetRecord.Type__c == Constants.ASSET_TYPE_PRE_MED_LETTER && returnFileType == 'pmlFileInstMap') ||
            (assetRecord.Type__c == Constants.ASSET_TYPE_NAME_DOC && assetRecord.ParentId == pmlId && returnFileType == 'pmlNameDocInstMap') ||
            (assetRecord.Type__c == Constants.ASSET_TYPE_TRANSLATION && assetRecord.ParentId == pmlId && returnFileType == 'pmlTransFileInstMap') ||
            (assetRecord.Type__c == Constants.ASSET_TYPE_NAME_DOC && assetRecord.ParentId == pmlTransId && returnFileType == 'pmlTransNameDocInstMap')) {
                fileUrl = Constants.FILE_DOWNLOAD_URL + fileId;
            }
        
        return fileUrl;
    }
    
    /**
* Created by Nayana on 20/02/2020
* Method Name: getStartDateAndEndDate
* Purpose : Method to get start date , End date and Degree issue date of medical school
* Return Type : date
*/
    @AuraEnabled(cacheable = false)
    public static Map<String, Date> getStartDateAndEndDate(String objectId, String objectType) {
        Map<String, Date> valuesToReturn = new Map<String, Date> ();
        
        Contact_Association_Type__c data = [SELECT Start_Date__c, End_Date__c, Degree_Issue_Date__c FROM Contact_Association_Type__c where id =: objectId][0];
        valuesToReturn.put('Start_Date__c', data.Start_Date__c);
        valuesToReturn.put('End_Date__c', data.End_Date__c);
        valuesToReturn.put('Degree_Issue_Date__c', data.Degree_Issue_Date__c);
        
        return valuesToReturn;
        
    }
    
    /**
* Created by Shailaja Yerneni
* Method Name: getStartEndAndDegreeMonthYear
* Purpose : Method to get start, End and Degree issue month & year of medical school
* Parameters : 
* Return Type : String
*/
    @AuraEnabled(cacheable = false)
    public static Map < String, String > getStartEndAndDegreeMonthYear(String objectId, String objectType) {
        
        Map < String, String > valuesToReturn = new Map < String, String > ();
        Contact_Association_Type__c data = [SELECT Start_Month__c, Start_Year__c, End_Month__c, End_Year__c, Degree_Issue_Month__c, Degree_Issue_Year__c FROM Contact_Association_Type__c where id =: objectId][0];
        valuesToReturn.put('Start_Month__c', data.Start_Month__c);
        valuesToReturn.put('Start_Year__c', data.Start_Year__c);
        valuesToReturn.put('End_Month__c', data.End_Month__c);
        valuesToReturn.put('End_Year__c', data.End_Year__c);
        valuesToReturn.put('Degree_Issue_Month__c', data.Degree_Issue_Month__c);
        valuesToReturn.put('Degree_Issue_Year__c', data.Degree_Issue_Year__c);
        
        return valuesToReturn;
    }
    
    /**
* Created by Nayana
* Method Name: getContactAssociationType
* Purpose : Method to fetch degree medical school data to auto populate on the applicant screen
* Return Type : String
*/
    @AuraEnabled
    public static String getContactAssociationType() {
        String valuesToReturn = '';
        Id contactId = AppForCertHelper.retrieveCurrentContactId();
        if (contactId != null) {
            List<Contact_Association_Type__c > existingConAssoObjList = [SELECT ID From Contact_Association_Type__c WHERE Contact__c =: contactId and recordType.DeveloperName =: Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL];
            if (!existingConAssoObjList.isEmpty()) {
                valuesToReturn = String.valueOf(existingConAssoObjList[0].id) + ',Contact_Association_Type__c';
            }
        }
        return valuesToReturn;
    }
    
    /**
* Created by Femi
* Method Name: createExamRegCase on 20/02/2020
* Purpose : Method to create new exam registration case
* Return Type : String
*/
    @AuraEnabled
    public static String createExamRegCase() {
        
        Id contactId = AppForCertHelper.retrieveCurrentContactId();
        
        Id examRegRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        List<Case> examRegCase = [Select Id from Case Where ContactId =: contactId AND RecordTypeId =: examRegRecordTypeId AND Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION];
        Id caseId;
        if (!examRegCase.isEmpty()) {
            caseId = examRegCase[0].Id;
        } else {
            caseId = createExamRegistationCase();
        }
        return caseId;
    }
    
    /**
* Created by Reshma
* Method Name: getExamRegistrations on 28/02/2020
* Purpose : Method to get list of case with exam registrations for screen 5
* Return Type : List of case records
*/
    @AuraEnabled(cacheable = false)
    public static List< ExamRegRecordWrapper > getExamRegistrations() {
        Id contactId = AppForCertHelper.retrieveCurrentContactId();
        Id examRegRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        List<ExamRegRecordWrapper> examRegWrapperList = new List<ExamRegRecordWrapper>();
        for(Exam_Registration__c examReg : [SELECT Id, Exam_Types__c, EP_start_Date__c, EP_end_Date__c, Product_Detail__c, Product_Detail__r.Exam_Region__r.Region_Name__c, Test_Accommodations_needed__c, Case__r.Internal_Status__c
                                            FROM Exam_Registration__c
                                            WHERE Applicant__c =: contactId
                                            AND Case__r.RecordTypeId =: examRegRecordTypeId
                                            AND Case__r.Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION
                                            ORDER BY Exam_Types__c]){
                                                Integer epSTYear = examReg.EP_start_Date__c.year();
                                                Integer epSTMonth = examReg.EP_start_Date__c.month();
                                                Integer epSTDay = examReg.EP_start_Date__c.day();
                                                DateTime epSTDt = DateTime.newInstance(epSTYear, epSTMonth, epSTDay);
                                                
                                                Integer epENYear = examReg.EP_end_Date__c.year();
                                                Integer epENMonth = examReg.EP_end_Date__c.month();
                                                Integer epENDay = examReg.EP_end_Date__c.day();
                                                DateTime epENDt = DateTime.newInstance(epENYear, epENMonth, epENDay);
                                                String dateFormat = dateFormatString;
                                                examRegWrapperList.add(new ExamRegRecordWrapper(
                                                    examReg,
                                                    epSTDt.format(dateFormat) +' - '+ epENDt.format(dateFormat) + '~' + examReg.Case__r.Internal_Status__c,
                                                    null, null, null, null, null
                                                ));
                                            }
        
        return examRegWrapperList;
    }
    
    /**
* Created by Reshma
* Method Name: deleteExamRegistration on 03/03/2020
* Purpose : Method to delete exam registration and case from screen 5
* Return Type : String
*/
    @AuraEnabled
    public static string deleteExamRegistration(String examRegId) {
        Id contactId = AppForCertHelper.retrieveCurrentContactId();
        Id examRegRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        List<Case> examRegCases = [SELECT Id FROM Case WHERE RecordTypeId =: examRegRecordTypeId AND Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION AND ContactId =: contactId];
        
        if (String.isNotBlank(examRegId)) {
            // Delete If asset there
            String keyval = Constants.ASSET_KEYVAL_VISA_EXCEPTION_DOC;
            delAssetAndRelDoc(contactId, keyval, examRegId);
            
            Exam_Registration__c examReg = [SELECT Id, Case__c FROM Exam_Registration__c WHERE Id =: examRegId];
            DELETE examReg;
            
            if (examRegCases.size() > 1) {
                Case examRegCase = [SELECT Id FROM Case WHERE Id =: examReg.Case__c];
                if (examRegCase != null) {
                    DELETE examRegCase;
                }
            }
            return 'Success';
        } else {
            return 'Error';
        }
    }
    
    /* Wrapper class to store exam registration record data in examregLandingPage
*/
    public class ExamRegRecordWrapper {
        @auraenabled public string recordIdVal {
            get;
            set;
        }
        @auraenabled public string examType {
            get;
            set;
        }
        @auraenabled public string eligibilityPeriod {
            get;
            set;
        }
        @auraenabled public string testingRegion {
            get;
            set;
        }
        @auraenabled public string testAccomodations {
            get;
            set;
        }
        @auraenabled public string applicationStatus {
            get;
            set;
        }
        @auraenabled public string pEvUrl {
            get;
            set;
        }
        @auraenabled public string permitUrl {
            get;
            set;
        }
        @auraenabled public string visaUrl {
            get;
            set;
        }
        @auraenabled public string paperEnrollment {
            get;
            set;
        }
        @auraenabled public String showVisa {
            get;
            set;
        }
        @auraenabled public String showSchedulingPermit {
            get;
            set;
        }
        
        public ExamRegRecordWrapper(Exam_Registration__c examReg, String examRegEP, String url1, String url2, String url3, String paperEnrollmentURL, String boolVals) {
            recordIdVal = examReg.Id;
            examType = examReg.Exam_Types__c;
            if(examRegEP.substringBefore('~') != NULL)
                eligibilityPeriod = examRegEP.subStringBefore('~');
            testingRegion = examReg.Product_Detail__r.Exam_Region__r.Region_Name__c; 
            testAccomodations = examReg.Test_Accommodations_needed__c;
            if(examRegEP.substringAfter('~') != NULL)
                applicationStatus = examRegEP.substringAfter('~');
            pEvUrl = url1;
            permitUrl = url2;
            visaUrl = url3;
            paperEnrollment = paperEnrollmentURL;
            if(boolVals != NULL){
                if(boolVals.substringBefore('~')!= NULL)
                    showVisa = boolVals.substringBefore('~');
                if(boolVals.substringAfter('~') != NULL)
                    showSchedulingPermit = boolVals.substringAfter('~');
            }
        }
    }
    
    // Purpose : Method to update Assets to marked for deletion
    public static void delAssetAndRelDoc(String contactId, String keyval, String examRegId) {
        List<Asset> assetList = new List<Asset> ();
        assetList = [Select Id, case__c, status, RecordTypeId, Contact_Association_Type_Staging__c from Asset where ContactId =: contactId AND key__c =: keyval AND Exam_Registration__c =: examRegId AND IsExpired__c = FALSE AND IsOrphan__c = FALSE AND status != :constants.ASSET_STATUS_MARKED_FOR_DELETION WITH SECURITY_ENFORCED];
        List<RecordType> markedForDeletionRecordType  = [SELECT Id, Name from RecordType where DeveloperName =: Constants.ASSET_RECORD_TYPE_MARKED_FOR_DELETION AND SObjectType = 'Asset' WITH SECURITY_ENFORCED];
        RecordType assetMarkedForDeletionRT = markedForDeletionRecordType[0];
        if (!assetList.isEmpty()) {
            for(Asset a: assetList){
                a.case__c = null;
                a.status = constants.ASSET_STATUS_MARKED_FOR_DELETION;
                a.RecordTypeId = assetMarkedForDeletionRT.Id;
                a.Contact_Association_Type_Staging__c = null;
            }
            if (Asset.SObjectType.getDescribe().isUpdateable()) {
                UPDATE assetList;
            }
        }
    }
    
    /**
* Created by Nayana on 27/02/2020
* Method Name: getSchoolData
* Purpose : Method to get account id of medical school
* Return Type : String
*/
    @AuraEnabled(cacheable = false)
    public static Map<String, String> getSchoolData(String objectId) {
        Map<String, String> valuesToReturn = new Map<String, String> ();
        
        Contact_Association_Type__c data = [SELECT Account__c FROM Contact_Association_Type__c where id =: objectId][0];
        valuesToReturn.put('Account__c', data.Account__c);
        
        return valuesToReturn;
        
    }
    /**
* Created by Femi
* Method Name: getCheckBoxValue on 28/02/2020
* Purpose : Method to get checkbox value for screen 3
* Return Type : Boolean
*/
    @AuraEnabled
    public static Boolean getCheckBoxValue() {
        Boolean returnValue = false;
        Id contactId = AppForCertHelper.retrieveCurrentContactId();
        
        Id examRegRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        List<Case> examRegCase = [Select Id from Case Where ContactId =: contactId AND RecordTypeId =: examRegRecordTypeId AND Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION];
        if (!examRegCase.isEmpty()) {
            returnValue = true;
        }
        return returnValue;
    }
    /**
* Created by Femi
* Method Name: saveStagingRecord on 03/03/2020
* Purpose : Method to update contact Staging records
* Return Type : String
*/
    @AuraEnabled
    public static String saveStagingRecord(String updateValues) {
        Id contactId = AppForCertHelper.retrieveCurrentContactId();
        StagingRecordWrapper sRecord = (StagingRecordWrapper) JSON.deserialize(updateValues, StagingRecordWrapper.class);
        List<Contact_Staging__c > csRecords = [SELECT Id FROM Contact_Staging__c where Contact__c =: contactId AND RecordType.DeveloperName =: Constants.CONTACT_STAGING_RECORDTYPE_EXAMREGISTRATION];
        if (!csRecords.isEmpty()) {
            updateContactStaging(sRecord, csRecords);
        }
        List<Exam_Registration__c > recordsToUpdate = new List<Exam_Registration__c > ();
        List<Exam_Registration__c > examRegs = [SELECT Id, Basic_Sciences_Requirement__c, Officially_Enrolled__c FROM Exam_Registration__c WHERE case__r.Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION AND Applicant__c =: contactId];
        if (!examRegs.isEmpty()) {
            for (Exam_Registration__c examReg: examRegs) {
                if (sRecord.officiallyEnrolled != '') {
                    examReg.Officially_Enrolled__c = sRecord.officiallyEnrolled;
                }
                if (sRecord.basicSciencesRequirement != '') {
                    examReg.Basic_Sciences_Requirement__c = sRecord.basicSciencesRequirement;
                }
                recordsToUpdate.add(examReg);
            }
            update recordsToUpdate;
        }
        return csRecords[0].Id;
    }
    
    /**
* Created by Praveen
* Method Name: updateContactStaging
* Purpose : Update contact staging record with values from ethnicity screen.
* Return Type : null
*/
    public static void updateContactStaging(StagingRecordWrapper sRecord, List<Contact_Staging__c > csRecords) {
        Contact_Staging__c contactStaging = new Contact_Staging__c();
        contactStaging.Id = csRecords[0].Id;
        contactStaging.Ethnicity__c = deserializeValues(sRecord.ethnicity);
        contactStaging.National_ID_Country__c = checkBlankValues(sRecord.nationalIDCountry);
        contactStaging.National_Identification__c = checkBlankValues(sRecord.nationalIdentification);
        contactStaging.Native_Language__c = checkBlankValues(sRecord.nativeLanguage);
        contactStaging.US_Social_Security__c = checkBlankValues(sRecord.socialSecurityNumber);
        contactStaging.Other_Native_Language__c = checkBlankValues(sRecord.otherNativeLanguage);
        contactStaging.Other_Languages_Spoken__c = deserializeValues(sRecord.otherLanguagesSpoken);
        contactStaging.Additional_Languages_Spoken__c = checkBlankValues(sRecord.addLanguagesSpoken);
        
        update contactStaging;
    }
    
    /**
* Created by Reshma
* Method Name: deserializeValues
* Purpose : Deserialize value from ethinicity screen to update multi-picklist fields
* Return Type : string
*/
    public static string deserializeValues(String value){
        if (value != '') {
            List<String> picklistValues = (List<String> ) JSON.deserialize(value, List<String> .class);
            String picklistString = '';
            for (String val : picklistValues) {
                picklistString = picklistString == '' ? picklistString + val : picklistString + ';' + val;
            }
            return picklistString;
        } else {
            return null;
        }
    }
    
    /**
* Created by Reshma
* Method Name: checkBlankValues
* Purpose : Check value received from ethinicity screen is blank or not
* Return Type : string
*/
    public static string checkBlankValues(String value){
        if (value != '') {
            return value;
        } else {
            return null;
        }
    }
    
    /**
* Created by Femi
* Method Name: getStagingRecord on 03/03/2020
* Purpose : Method to get contact Staging records
* Return Type : StagingRecordWrapper
*/
    @AuraEnabled
    public static StagingRecordWrapper getStagingRecord(String values) {
        Id contactId = AppForCertHelper.retrieveCurrentContactId();
        String tempEnthnicity = '';
        String tempNationalIdCountry = '';
        String tempNationalIdentification = '';
        String tempNativeLanguage = '';
        String tempSocialSecurity = '';
        String tempOfficiallyEnrolled = '';
        String tempBasicSciencesRequirement = '';
        String tempOtherNativeLanguage = '';
        String tempOtherLanguagesSpoken = '';
        String tempAddLanguagesSpoken = '';
        StagingRecordWrapper returnValues;
        List<Contact_Staging__c > csRecords = [SELECT Id, Native_Language__c, Ethnicity__c, National_ID_Country__c, US_Social_Security__c, National_Identification__c, Other_Native_Language__c, Other_Languages_Spoken__c, Additional_Languages_Spoken__c FROM Contact_Staging__c where Contact__c =: contactId AND RecordType.DeveloperName =: Constants.CONTACT_STAGING_RECORDTYPE_EXAMREGISTRATION];
        if (!csRecords.isEmpty()) {
            if (csRecords[0].Native_Language__c == null) {
                Contact contact = [SELECT Id, Native_Language__c, Ethnicity__c, National_ID_Country__c, US_Social_Security__c, National_Identification__c, Other_Native_Language__c, Other_Languages_Spoken__c, Additional_Languages_Spoken__c FROM Contact where Id =: contactId][0];
                tempEnthnicity = checkNullValue(contact.Ethnicity__c);
                tempNationalIdCountry = checkNullValue(contact.National_ID_Country__c);
                tempNationalIdentification = checkNullValue(contact.National_Identification__c);
                tempNativeLanguage = checkNullValue(contact.Native_Language__c);
                tempSocialSecurity = checkNullValue(contact.US_Social_Security__c);
                tempOtherNativeLanguage = checkNullValue(contact.Other_Native_Language__c);
                tempOtherLanguagesSpoken = checkNullValue(contact.Other_Languages_Spoken__c);
                tempAddLanguagesSpoken = checkNullValue(contact.Additional_Languages_Spoken__c);
            } else {
                Contact_Staging__c contactStaging = csRecords[0];
                tempEnthnicity = checkNullValue(contactStaging.Ethnicity__c);
                tempNationalIdCountry = checkNullValue(contactStaging.National_ID_Country__c);
                tempNationalIdentification = checkNullValue(contactStaging.National_Identification__c);
                tempNativeLanguage = checkNullValue(contactStaging.Native_Language__c);
                tempSocialSecurity = checkNullValue(contactStaging.US_Social_Security__c);
                tempOtherNativeLanguage = checkNullValue(contactStaging.Other_Native_Language__c);
                tempOtherLanguagesSpoken = checkNullValue(contactStaging.Other_Languages_Spoken__c);
                tempAddLanguagesSpoken = checkNullValue(contactStaging.Additional_Languages_Spoken__c);
            }
            List<Exam_Registration__c > examRegs = [SELECT Basic_Sciences_Requirement__c, Officially_Enrolled__c FROM Exam_Registration__c WHERE case__r.Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION AND Applicant__c =: contactId];
            if (!examRegs.isEmpty()) {
                if (examRegs[0].Basic_Sciences_Requirement__c != null) {
                    tempBasicSciencesRequirement = examRegs[0].Basic_Sciences_Requirement__c;
                }
                if (examRegs[0].Officially_Enrolled__c != null) {
                    tempOfficiallyEnrolled = examRegs[0].Officially_Enrolled__c;
                }
                
            }
            returnValues = new StagingRecordWrapper(tempEnthnicity, tempNationalIdCountry, tempNationalIdentification, tempNativeLanguage, tempSocialSecurity, tempOfficiallyEnrolled, tempBasicSciencesRequirement, tempOtherNativeLanguage, tempOtherLanguagesSpoken, tempAddLanguagesSpoken);
            
        }
        return returnValues;
    }
    
    /**
* Created by Praveen
* Method Name: checkNullValue
* Purpose : Check if the passed value is null and return string value.
* Return Type : String
*/
    public static String checkNullValue(String stringVal) {
        String returnVal = '';
        if (stringVal != null) {
            returnVal = stringVal;
        }
        
        return returnVal;
    }
    
    /* Wrapper class to store staging record data in screen 6
*/
    public class StagingRecordWrapper {
        @auraenabled public string ethnicity {
            get;
            set;
        }
        @auraenabled public string nationalIDCountry {
            get;
            set;
        }
        @auraenabled public string nationalIdentification {
            get;
            set;
        }
        @auraenabled public string nativeLanguage {
            get;
            set;
        }
        @auraenabled public string socialSecurityNumber {
            get;
            set;
        }
        @auraenabled public string officiallyEnrolled {
            get;
            set;
        }
        @auraenabled public string basicSciencesRequirement {
            get;
            set;
        }
        @auraenabled public string otherNativeLanguage {
            get;
            set;
        }
        @auraenabled public string otherLanguagesSpoken {
            get;
            set;
        }
        @auraenabled public string addLanguagesSpoken {
            get;
            set;
        }
        
        public StagingRecordWrapper(String sRethnicity, String sRnationalIDCountry, String sRnationalIdentification, String sRnativeLanguage, String sRsocialSecurityNumber, String sRofficiallyEnrolled, String sRbasicSciencesRequirement, String sRotherNativeLanguage, String sRotherLanguagesSpoken, String sRaddLanguagesSpoken) {
            ethnicity = sRethnicity;
            nationalIDCountry = sRnationalIDCountry;
            nationalIdentification = sRnationalIdentification;
            nativeLanguage = sRnativeLanguage;
            socialSecurityNumber = sRsocialSecurityNumber;
            officiallyEnrolled = sRofficiallyEnrolled;
            basicSciencesRequirement = sRbasicSciencesRequirement;
            otherNativeLanguage = sRotherNativeLanguage;
            otherLanguagesSpoken = sRotherLanguagesSpoken;
            addLanguagesSpoken = sRaddLanguagesSpoken;
        }
        
    }
    /**
* Created by Chinmay on 06/03/2020
* Method Name: fetchAvailableExamTypes
* Purpose : Method to return available exam types
* Return Type : List of string of available exam types
*/
    @AuraEnabled(Cacheable = false)
    public static List<string> fetchAvailableExamTypes(String examRegId) {
        Id contactId = AppForCertHelper.retrieveCurrentContactId();
        Set<String> selectedExamsTypeNames = new Set<String> ();
        Set<String> availableExamTypes = new Set<String> ();
        List<String> examTypesToReturn = new List<String> ();
        List<Exam_Registration__c > selectedExamsRegList = [SELECT id, Exam_Status__c, Exam_Types__c
                                                            FROM Exam_Registration__c
                                                            WHERE Applicant__c =: contactId AND
                                                            Exam_Status__c = ''
                                                            AND Case__r.Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION
                                                           ];
        
        for (Exam_Registration__c er: selectedExamsRegList) {
            selectedExamsTypeNames.add(er.Exam_Types__c);
        }
        List<Exam_Type__mdt> examTypes = new List<Exam_Type__mdt>();
        examTypes = [SELECT Id, Exam_type__c FROM Exam_Type__mdt];
        // Exam Registration - Edit Mode
        if (examRegId != '') {
            Exam_Registration__c examRegInfo = [SELECT id, Exam_Types__c
                                                FROM Exam_Registration__c
                                                WHERE Id =: examRegId
                                               ][0];
            availableExamTypes.add(examRegInfo.Exam_Types__c);
        }
        for (Exam_Type__mdt exmType: examTypes) {
            if (!selectedExamsTypeNames.contains(exmType.Exam_type__c)) {
                availableExamTypes.add(exmType.Exam_type__c);
            }
        }
        
        for (String eT: availableExamTypes) {
            examTypesToReturn.add(eT);
        }
        examTypesToReturn.sort();
        
        return examTypesToReturn;
    }
    
    /**
* Created by Ajoydhas
* Method Name: fetchDocumentedDisabilities
* Purpose : Method to return the Test Accommodations needed
* Return Type : List of string of Test Accommodations needed
*/
    @AuraEnabled(Cacheable = false)
    public static List<string> fetchDocumentedDisabilities() {
        List<String> availableDocumentedDisabilities = new List<String> ();
        String objectName = Constants.EXAM_REGISTRATION_OBJECT;
        String fieldName = Constants.EXAM_REGISTRATION_FIELD_TESTACCOMMODATIONS;
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult r = s.getDescribe();
        Map<String, Schema.SObjectField > fields = r.fields.getMap();
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal: ple) {
            availableDocumentedDisabilities.add(pickListVal.getLabel());
        }
        return availableDocumentedDisabilities;
    }
    @AuraEnabled(Cacheable = false)
    public static string checkLastAttempt(String selectedExam, String contactId){
        List<Exam_Registration_Setting__mdt> examRegSettings = new List<Exam_Registration_Setting__mdt>();
        examRegSettings = [SELECT Step_1_Attempt_Limit__c, Step_2_CK_Attempt_Limit__c, Step_2_CS_Attempt_Limit__c FROM Exam_Registration_Setting__mdt WHERE DeveloperName =: Constants.EXAM_REGISTRATION_SETTING];
        Integer numberOfAttemptsMade = 0;
        Integer numberOfFailedAttempts = 0;
        Integer numberOfPassedAttempts = 0;
        Boolean step1Exception = false;
        Boolean step2CKException = false;
        for(Exam_Registration__c er : [SELECT Id, Exam_Status__c, Exam_Types__c, Applicant__r.Step_1_Attempt_Limit_Exception__c, Applicant__r.Step_2_CK_Attempt_Limit_Exception__c FROM Exam_Registration__c WHERE Applicant__c =:contactId WITH SECURITY_ENFORCED]){
            if(er.Exam_Types__c == selectedExam && (er.Exam_Status__c == Constants.EXAM_REGISTRATION_EXAM_STATUS_PASSED || er.Exam_Status__c == Constants.EXAM_REGISTRATION_EXAM_STATUS_FAILED)){
                numberOfAttemptsMade++;
                if(er.Exam_Status__c == Constants.EXAM_REGISTRATION_EXAM_STATUS_FAILED){
                    numberOfFailedAttempts++;
                }else if(er.Exam_Status__c == Constants.EXAM_REGISTRATION_EXAM_STATUS_PASSED){
                    numberOfPassedAttempts++;
                }
            }
            step1Exception = er.Applicant__r.Step_1_Attempt_Limit_Exception__c;
            step2CKException = er.Applicant__r.Step_2_CK_Attempt_Limit_Exception__c;
        }
        if((!step1Exception && selectedExam == Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE && numberOfFailedAttempts == Integer.valueOf(examRegSettings[0].Step_1_Attempt_Limit__c) - 1 && numberOfPassedAttempts == 0) ||
            (!step2CKException && selectedExam == Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK && numberOfFailedAttempts == Integer.valueOf(examRegSettings[0].Step_2_CK_Attempt_Limit__c) - 1 && numberOfPassedAttempts == 0)){
            return 'warning';
        }
        return '';
    }        
    //Purpose : Method to validate the various conditions on exam selection
    @AuraEnabled(Cacheable = false)
    public static string checkExamConditions(String selectedExam, String examRegId){
        Id contactId = AppForCertHelper.retrieveCurrentContactId();
        Set<String> registeredExamsTypes = new Set<String> ();
        Set<String> passedExamsTypes = new Set<String> ();
        Set<String> withheldExamsTypes = new Set<String> ();
        List<Exam_Registration__c> examsRegList = [SELECT id, Case__r.Internal_Status__c, Exam_Status__c, Exam_Types__c, Case__r.External_Status__c, Withheld_Score__c
                                                    FROM Exam_Registration__c
                                                    WHERE Applicant__c =: contactId
                                                    WITH SECURITY_ENFORCED];
        Boolean addToRegisteredSetBool = false;
        if(!examsRegList.isEmpty()){
            for(Exam_Registration__c er: examsRegList){
                addToRegisteredSetBool = checkRegisteredExamTypeConditions(er);
                if(addToRegisteredSetBool){
                    registeredExamsTypes.add(er.Exam_Types__c);
                }else if(er.Exam_Status__c == Constants.EXAM_REGISTRATION_EXAM_STATUS_WITHHELD || er.Withheld_Score__c){
                    withheldExamsTypes.add(er.Exam_Types__c);
                }else if(er.Exam_Status__c == Constants.EXAM_REGISTRATION_EXAM_STATUS_PASSED){
                    passedExamsTypes.add(er.Exam_Types__c);
                }
            }
        }
        String levelOneValidationResult = levelOneValidations(contactId, selectedExam, registeredExamsTypes, passedExamsTypes, withheldExamsTypes, examsRegList);
        if(levelOneValidationResult != ''){
            return levelOneValidationResult;
        }
        String levelTwoValidationResult = '';
        Boolean limitAttemptedError = true;
        if(selectedExam == Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE || selectedExam == Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK){
            limitAttemptedError = checkUSMLEStepLimitAttempted(contactId, selectedExam);
        }else if(examRegId == '' || examRegId == null){
            levelTwoValidationResult = levelTwoValidations(contactId, selectedExam, examsRegList);
        }
        if(!limitAttemptedError){
            return 'E';
        }
        if(levelTwoValidationResult != ''){
            return levelTwoValidationResult;
        }
        if(passedExamsTypes.contains(selectedExam)){
            return 'F';
        }
        return 'Success';
    }
    
    /**
* Created by Chinmay on March 26th, 2020
* Method Name: checkRegisteredExamTypeConditions
* Purpose : Method to check if the given exam registration record is to be considered as a registered exam or not
* Return Type : Boolean
*/
    public static Boolean checkRegisteredExamTypeConditions(Exam_Registration__c er) {
        return ((!(er.Case__r.External_Status__c == Constants.CASE_STATUS_REJECTED ||
                   er.Case__r.External_Status__c == Constants.CASE_STATUS_ENROLLMENT_NOT_VERIFIED_MEDSCL ||
                   er.Case__r.Internal_Status__c == Constants.CASE_STATUS_EXPIRED ||
                   (er.Case__r.Internal_Status__c == Constants.CASE_STATUS_CANCELLED &&
                    er.Exam_Status__c == null) ||
                   (er.Case__r.External_Status__c == Constants.CASE_STATUS_REGISTERED &&
                    er.Exam_Status__c != null))) ||
                (er.Case__r.External_Status__c == Constants.CASE_STATUS_SUBMITTED_IN_REVIEW ||
                 er.Case__r.External_Status__c == Constants.CASE_STATUS_PENDING_ENROLLMENT ||
                 er.Case__r.External_Status__c == Constants.CASE_STATUS_ENROLLMENT_VERIFICATION_RECEIVED ||
                 er.Case__r.External_Status__c == Constants.CASE_STATUS_ENROLLMENT_VERIFICATION_COMPLETE_MEDSCL))
            && (er.Withheld_Score__c != true && er.Exam_Status__c != Constants.EXAM_REGISTRATION_EXAM_STATUS_WITHHELD);
    }
    
    /**
* Created by Chinmay on March 10th, 2020
* Method Name: levelOneValidations
* Purpose : Method to validate the various conditions on exam selection
* Return Type : String containing validation error or blank if no errors are hit
*/
    public static string levelOneValidations(Id contactId, String selectedExam, Set<String> registeredExamsTypes, Set<String> passedExamsTypes, Set<String> withheldExamsTypes, List<Exam_Registration__c > examsRegList) {
        
        if (registeredExamsTypes.contains(selectedExam)) {
            return 'C';
        }
        
        if (withheldExamsTypes.contains(selectedExam)) {
            return 'D';
        }
        
        if (selectedExam == Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCS) {
            String validationTwoReturnValue = levelTwoValidations(contactId, selectedExam, examsRegList);
            if (validationTwoReturnValue != '') {
                return validationTwoReturnValue;
            }
            
            String usmleStepTwoCsExclusiveValidationsReturnValue = usmleStepTwoCsExclusiveValidations(contactId, selectedExam, passedExamsTypes);
            if (usmleStepTwoCsExclusiveValidationsReturnValue != '') {
                return usmleStepTwoCsExclusiveValidationsReturnValue;
            }
        }
        
        return '';
    }
    
    /**
* Created by Chinmay on March 10th, 2020
* Method Name: levelTwoValidations
* Purpose : Method to validate the number of attempts condition on exam selection
* Return Type : String containing validation error or blank if no errors are hit
*/
public static string levelTwoValidations(Id contactId, String selectedExam, List<Exam_Registration__c > examsRegList) {
    Contact currentApplicant = [SELECT Step_1_Attempt_Limit_Exception__c, Step_2_CK_Attempt_Limit_Exception__c,
                                Step_2_CS_Attempt_Limit_Exception__c
                                FROM Contact
                                WHERE Id =: contactId
                                ];
    
    List<Exam_Registration_Setting__mdt > examRegSettings = new List<Exam_Registration_Setting__mdt > ();
    
    examRegSettings = [SELECT Step_1_Attempt_Limit__c, Step_2_CK_Attempt_Limit__c, Step_2_CS_Attempt_Limit__c
                        FROM Exam_Registration_Setting__mdt
                        WHERE DeveloperName =: Constants.EXAM_REGISTRATION_SETTING
                        ];
    
    Integer numberOfAttemptsMade = 0;
    
    for (Exam_Registration__c er: examsRegList) {
        
        if (er.Exam_Types__c == selectedExam && (er.Exam_Status__c == Constants.EXAM_REGISTRATION_EXAM_STATUS_PASSED || er.Exam_Status__c == Constants.EXAM_REGISTRATION_EXAM_STATUS_FAILED)) {
            numberOfAttemptsMade++;
        }
    }
    
    Integer numberOfAttemptsAllowed = 0;
    
    if (examRegSettings.size() > 0) {
        if (selectedExam == Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE) {
            numberOfAttemptsAllowed = Integer.valueOf(examRegSettings[0].Step_1_Attempt_Limit__c);
        }
        if (selectedExam == Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK) {
            numberOfAttemptsAllowed = Integer.valueOf(examRegSettings[0].Step_2_CK_Attempt_Limit__c);
        }
        if (selectedExam == Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCS) {
            numberOfAttemptsAllowed = Integer.valueOf(examRegSettings[0].Step_2_CS_Attempt_Limit__c);
        }
    }
    
    String returnVal = numberOfAttemptsValidator(currentApplicant, selectedExam, numberOfAttemptsMade, numberOfAttemptsAllowed);
    
    return returnVal;
}
    
    /**
* Created by Chinmay on March 10th, 2020
* Method Name: numberOfAttemptsValidator
* Purpose : Method to validate the number of attempts condition on exam selection
* Return Type : String containing validation error or blank if no errors are hit
*/
    public static string numberOfAttemptsValidator(Contact currentApplicant, String selectedExam, Integer numberOfAttemptsMade, Integer numberOfAttemptsAllowed) {
        if (selectedExam == Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE && numberOfAttemptsMade >= numberOfAttemptsAllowed && !currentApplicant.Step_1_Attempt_Limit_Exception__c) {
            return 'E';
        }
        if (selectedExam == Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK && numberOfAttemptsMade >= numberOfAttemptsAllowed && !currentApplicant.Step_2_CK_Attempt_Limit_Exception__c) {
            return 'E';
        }
        if (selectedExam == Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCS && numberOfAttemptsMade >= numberOfAttemptsAllowed && !currentApplicant.Step_2_CS_Attempt_Limit_Exception__c) {
            return 'E';
        }
        return '';
    }
    
    /**
* Created by Chinmay on March 25th, 2020
* Method Name: usmleStepTwoCsExclusiveValidations
* Purpose : Method to validate the following conditions:
*		   1. Check if USMLE Step 1 has been passed prior to Selecting USMLE Step 2 CS
*		   2. Check if USMLE Step 2 CS was already passed
*		   3. Check if the Applicant has USA as the current citizenship country
* Return Type : String containing validation error or blank if no errors are hit
*/
    public static string usmleStepTwoCsExclusiveValidations(Id contactId, String selectedExam, Set<String> passedExamsTypes) {
        if (!passedExamsTypes.contains(Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE)) {
            return 'A';
        } else {
            if (Schema.sObjectType.Contact.isAccessible()) {
                Contact currentApplicant = [SELECT id, Current_Citizenship__c
                                            FROM Contact
                                            WHERE id =: contactId
                                           ];
                
                if (passedExamsTypes.contains(selectedExam)) {
                    if (!currentApplicant.Current_Citizenship__c.contains(Constants.CONTACT_CURRENT_CITIZENSHIP)) {
                        return 'G';
                    } else {
                        return 'H';
                    }
                }
                
                if (!currentApplicant.Current_Citizenship__c.contains(Constants.CONTACT_CURRENT_CITIZENSHIP)) {
                    return 'B';
                }
            }
        }
        return '';
    }
    @AuraEnabled
    public static Boolean checkUSMLEStepLimitAttempted(String conId, String selectedExam){
        Contact con = [SELECT Id, Step_1_Attempt_Limit_Exception__c, Step_2_CK_Attempt_Limit_Exception__c, (SELECT Id, Exam_Status__c, Exam_Types__c FROM Exam_Registrations__r) FROM Contact WHERE Id =:conId WITH SECURITY_ENFORCED];
        if(String.isBlank(selectedExam) && (con.Step_1_Attempt_Limit_Exception__c || con.Step_2_CK_Attempt_Limit_Exception__c)){
            return true;
        }else if(selectedExam == Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE && con.Step_1_Attempt_Limit_Exception__c){
            return true;
        }else if(selectedExam == Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE && con.Step_2_CK_Attempt_Limit_Exception__c){
            return true;
        }else{
            return getPassFailExams(con.Exam_Registrations__r, selectedExam);
        }
    }
    public static Boolean getPassFailExams(List<Exam_Registration__c> exams, String selectedExam){
        Map<String,List<Exam_Registration__c>> examFailedMap = new Map<String,List<Exam_Registration__c>>();
        Map<String,List<Exam_Registration__c>> examPassedMap = new Map<String,List<Exam_Registration__c>>();
        for(Exam_Registration__c exam : exams){
            if(exam.Exam_Status__c == Constants.EXAM_REGISTRATION_EXAM_STATUS_FAILED){
                if(examFailedMap.containsKey(exam.Exam_Types__c)){
                    examFailedMap.get(exam.Exam_Types__c).add(exam);
                }else{
                    examFailedMap.put(exam.Exam_Types__c, new List<Exam_Registration__c>{exam});
                }
            }else if(exam.Exam_Status__c == Constants.EXAM_REGISTRATION_EXAM_STATUS_PASSED){
                if(examPassedMap.containsKey(exam.Exam_Types__c)){
                    examPassedMap.get(exam.Exam_Types__c).add(exam);
                }else{
                    examPassedMap.put(exam.Exam_Types__c, new List<Exam_Registration__c>{exam});
                }
            }
        }
        return validateAttemptsLimit(examFailedMap, examPassedMap, selectedExam);
    }
    public static Boolean validateAttemptsLimit(Map<String,List<Exam_Registration__c>> examFailedMap, Map<String,List<Exam_Registration__c>> examPassedMap, String selectedExam){
        Exam_Registration_Setting__mdt examRegSettings = [SELECT Step_1_Attempt_Limit__c, Step_2_CK_Attempt_Limit__c, Step_2_CS_Attempt_Limit__c FROM Exam_Registration_Setting__mdt WHERE DeveloperName =:Constants.EXAM_REGISTRATION_SETTING];
        if(String.isBlank(selectedExam) && (examFailedMap.containsKey(Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE) && 
            examFailedMap.get(Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE).size() >= examRegSettings.Step_1_Attempt_Limit__c && 
            !examPassedMap.containsKey(Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE)) || 
            (examFailedMap.containsKey(Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK) && 
            examFailedMap.get(Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK).size() >= examRegSettings.Step_2_CK_Attempt_Limit__c && 
            !examPassedMap.containsKey(Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK))){
            return false;
        }
        else if(selectedExam == Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE && 
                examFailedMap.containsKey(Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE) && 
                examFailedMap.get(Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE).size() >= examRegSettings.Step_1_Attempt_Limit__c && 
                !examPassedMap.containsKey(Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE)){
                return false;
        }else if(selectedExam == Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK && 
                examFailedMap.containsKey(Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK) && 
                examFailedMap.get(Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK).size() >= examRegSettings.Step_2_CK_Attempt_Limit__c && 
                !examPassedMap.containsKey(Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK)){
                return false;
        }else{
            return true;
        }
    }

    /**
* Method Name: getTermsandConditionsDataExamReg
* Purpose : Method to fetch Terms and conditions for exam Registration legalsignoff
* Return Type : List of wrapper with terms content
* @Params : None
*/
    @AuraEnabled(Cacheable = true)
    public static List<AppForCertHelper.TermsObjWrapper > getTermsandConditionsDataExamReg() {
        List<AppForCertHelper.TermsObjWrapper > fetchedValuesToReturn = new List<AppForCertHelper.TermsObjWrapper > ();
        List<Terms_and_Conditions__c > termsList = new List<Terms_and_Conditions__c > ();
        termsList = [Select Id, Copy__c, Name, Short_Copy__c From Terms_and_Conditions__c Where Product__r.Name =: Constants.PRODUCT_NAME_EXAM_REGISTRATION_LEGAL_TERMS
                     and Status__c =: Constants.TERMS_AND_COND_STATUS_ACTIVE
                     Order By CreatedDate ASC
                    ];
        if (!termsList.isEmpty()) {
            For(Terms_and_Conditions__c terms: termsList) {
                string termsId = terms.Id;
                string termsContent = terms.Copy__c;
                string termsCheckBox = terms.Short_Copy__c;
                
                AppForCertHelper.TermsObjWrapper tempTermsObj = new AppForCertHelper.TermsObjWrapper(termsId, termsContent, termsCheckBox);
                
                fetchedValuesToReturn.add(tempTermsObj);
            }
        }
        
        return fetchedValuesToReturn;
    }
    
    /**
* Created by Jofrin
* Method Name: getExamRegCaseNumber
* Purpose : Method to get Exam Registration caseNumber
* Return Type : List<String>
*/
    @AuraEnabled(Cacheable = true)
    public static List<String> getExamRegCaseNumber() {
        String returnVal = '';
        List<string> returnStr = new List<string> ();
        Contact thisContact = ExamRegistrationUtility.contactRecord;
        List<case >newCases = new List<case >();
        if (thisContact != null) {
            
            newCases = [SELECT id, CaseNumber, Internal_Status__c FROM Case WHERE recordType.DeveloperName =: Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION
                        AND ContactId =: thisContact.Id AND Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION
                       ];
            
            if (!newCases.isEmpty())
                for (integer i = 0; i<newCases.size(); i++) {
                    returnVal = newCases[i].CaseNumber;
                    returnStr.add(string.valueOf(returnVal));
                }
        }
        return returnStr;
    }
    
    @AuraEnabled(Cacheable = true)
    public static Constants getConstantsClass() {
        return new Constants();
    }
    
    /**
* Created by Chinmay on March 16th, 2020
* Method Name: passedExamExceptions
* Purpose : Method to fetch the list of exceptions based on the selected Exam Type
* Return Type : List of Passed_Exam_Exception__c
*/
    @AuraEnabled(Cacheable = false)
    public static List<Passed_Exam_Exception__c > passedExamExceptions(String selectedExam) {
        List<Passed_Exam_Exception__c > exceptionList = new List<Passed_Exam_Exception__c > ([SELECT Id, Applicant_Reason_Required__c, Documents_Required__c, Exam_Type__c, Exception_Content__c, Exception_Name__c
                                                                                              FROM Passed_Exam_Exception__c
                                                                                              WHERE Exam_Type__c =: selectedExam
                                                                                              ORDER BY Exception_Name__c
                                                                                             ]);
        if (exceptionList.size() > 0) {
            return exceptionList;
        }
        return null;
    }
    /**
* Created by Femi
* Method Name: manageSchedulingPermit
* Purpose : Method to send email and create asset with scheduling permit for exam registration cases
*/
    @AuraEnabled
    public static void manageSchedulingPermit(String caseId) {
        
        case newCase = [Select id, Internal_Status__c, Contact.Id, contact.Name, contact.Email, recordType.DeveloperName, ECFMG_Portal_Case_Url__c, parentId from Case where Id =: caseId];
        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setTargetObjectId(newCase.ContactId);
        EmailTemplate emailTemplate = [Select Id, Subject, Description, HtmlValue, DeveloperName, Body from EmailTemplate where DeveloperName =: Constants.CASE_EMAIL_TEMPLATE_NAME];
        message.setTemplateID(emailTemplate.Id);
        List<OrgWideEmailAddress> addr  = [select Id from OrgWideEmailAddress where displayname =: Constants.ORG_WIDE_ADDRESS];
        message.setOrgWideEmailAddressId(addr[0].Id);   
        
        String htmlBody = emailTemplate.HtmlValue;
        htmlBody = htmlBody.replace('{!Case.Internal_Status__c}', newCase.Internal_Status__c);
        htmlBody = htmlBody.replace('{!Case.Contact}', newCase.contact.Name);
        htmlBody = htmlBody.replace('[Link]', '<a href="' + newCase.ECFMG_Portal_Case_Url__c + '">Case Status</a>');
        
        htmlBody = htmlBody.replaceAll('<!\\[CDATA\\[', '');
        htmlBody = htmlBody.replaceAll('\\]\\]>', '');
        
        message.setHtmlBody(htmlBody);
        
        StaticResource sr = [Select Name, Id, Body From StaticResource where Name = 'ExamPermit'];
        Blob tempBlob = sr.Body;
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setBody(tempBlob);
        efa.setFileName(Constants.ASSET_TYPE_SCHEDULING_PERMIT + '.pdf');
        message.setFileAttachments(new Messaging.EmailFileAttachment[] {
            efa
                });
        message.toAddresses = new String[] {
            newCase.contact.email
                };
                    Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage > {
                        message
                            };
                                try {
                                    Messaging.sendEmail(messages);
                                } catch (Exception e) {
                                    system.debug(e);
                                }
        
        Asset permit = new Asset();
        permit.Name = Constants.ASSET_TYPE_SCHEDULING_PERMIT;
        permit.ContactId = newCase.contact.Id;
        permit.Case__c = caseId;
        permit.Status = Constants.ASSET_STATUS_IN_PROGRESS;
        if (newCase.recordType.DeveloperName == Constants.CASE_RECORD_TYPE_REGION_CHANGE || newCase.recordType.DeveloperName == Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD) {
            permit.Case__c = newCase.parentId;
        }
        permit.type__c = Constants.ASSET_TYPE_SCHEDULING_PERMIT;
        permit.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        
        List<Asset> assetsToUpdate = new List<Asset>();
        for(Asset assetRec : [SELECT Id, Status FROM Asset WHERE Case__c = :permit.Case__c AND Type__c = :Constants.ASSET_TYPE_SCHEDULING_PERMIT AND Status != :Constants.ASSET_STATUS_OUTDATED AND status != :constants.ASSET_STATUS_MARKED_FOR_DELETION]){
            assetRec.Status = Constants.ASSET_STATUS_OUTDATED;
            assetsToUpdate.add(assetRec);
        }
        if(!assetsToUpdate.isEmpty()){
            UPDATE assetsToUpdate;
        }
        
        insert permit;
        
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S';
        conVer.PathOnClient = Constants.ASSET_TYPE_SCHEDULING_PERMIT + '.pdf';
        conVer.Title = Constants.ASSET_TYPE_SCHEDULING_PERMIT;
        conVer.VersionData = sr.Body;
        insert conVer;
        
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: conVer.Id].ContentDocumentId;
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = permit.Id;
        conDocLink.ContentDocumentId = conDoc;
        conDocLink.shareType = 'V';
        conDocLink.Visibility = 'AllUsers';
        insert conDocLink;
        
    }
    
    /**
* Created by Femi
* Method Name: manageVisaLetter
* Purpose : Method to create asset with visa letter for exam registration cases
*/
    @AuraEnabled
    public static void manageVisaLetter(String caseId) {
        case newCase = [Select id, Internal_Status__c, Contact.Id, contact.Name, ECFMG_Portal_Case_Url__c from Case where Id =: caseId];
        StaticResource sr = [Select Name, Id, Body From StaticResource where Name = 'ExamPermit'];
        
        Asset permit = new Asset();
        permit.Name = Constants.ASSET_TYPE_VISA_LETTER;
        permit.ContactId = newCase.Contact.Id;
        permit.Case__c = caseId;
        permit.type__c = Constants.ASSET_TYPE_VISA_LETTER;
        permit.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        insert permit;
        
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S';
        conVer.PathOnClient = Constants.ASSET_TYPE_VISA_LETTER + '.pdf';
        conVer.Title = Constants.ASSET_TYPE_VISA_LETTER;
        conVer.VersionData = sr.Body;
        insert conVer;
        
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: conVer.Id].ContentDocumentId;
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = permit.Id;
        conDocLink.ContentDocumentId = conDoc;
        conDocLink.shareType = 'V';
        conDocLink.Visibility = 'AllUsers';
        insert conDocLink;
    }
    
    /**
* Created by Ajoydhas
* Method Name: getExamRegionSurcharges
* Purpose : Method to fetch the list of Exam Regions and Surcharges based on the selected Exam Type
* Return Type : String containing validation error or blank if no errors are hit
*/
    @AuraEnabled(Cacheable = false)
    public static List<Product_Detail__c > getExamRegionSurcharges(String selectedExam) {
        List<Product_Detail__c > erSurchargeLists = new List<Product_Detail__c > ();
        
        if (selectedExam == Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE || selectedExam == Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK) {
            List<Product_Detail__c > examRegionSurchargeLists = [SELECT ID, Exam_Types__c, Surcharge__c, Exam_Region__r.Region_Name__c, Exam_Region__r.Region_Short_Description__c, Exam_Region__c
                                                                 FROM Product_Detail__c WHERE Exam_Types__c =: selectedExam AND Active_formula__c = true AND Exam_Region__c != null ORDER BY Exam_Region__r.Region_Name__c ASC
                                                                ];
            
            for (Product_Detail__c erSurcharge: examRegionSurchargeLists) {
                erSurchargeLists.add(erSurcharge);
            }
        }
        return erSurchargeLists;
    }
    
    /**
* Created by Ajoydhas
* Method Name: createExamRegistationCase
* Purpose : Method to create new exam registration case
* Return Type : String
*/
    @AuraEnabled
    public static String createExamRegistationCase() {
        Id contactId = AppForCertHelper.retrieveCurrentContactId();
        Id examRegRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        Case newCase = new Case(
            RecordTypeId = examRegRecordTypeId,
            ContactId = contactId,
            Service__c = Constants.CASE_SERVICE_ECFMG_CERTIFICATION,
            Internal_Status__c = Constants.CASE_STATUS_PENDING_SUBMISSION
        );
        
        insert newCase;
        String caseId = newCase.Id;
        return caseId;
    }
    
    // Purpose : Method to insert and update the Exam registration records
    @AuraEnabled(Cacheable = false)
    public static Boolean manageExamRegistration(String fieldvals) {
        Map<String, String> fieldvalmap = new Map<String, String> ();
        String tempKey,
            tempValue;
        JSONParser parsedMap = JSON.createParser(fieldvals);
        while (parsedMap.nextToken() != null) {
            if (parsedMap.getCurrentToken() == JSONToken.FIELD_NAME) {
                tempKey = parsedMap.getText();
                JSONToken tok = parsedMap.nextToken();
                fieldvalmap.put(tempKey, '');
                if (tok != JSONToken.VALUE_NULL) {
                    tempValue = parsedMap.getText();
                    fieldvalmap.put(tempKey, tempValue);
                }
            }
        }
        
        String examType = fieldvalmap.get('Exam_Types__c');
        Date epStartDate;
        Date epEndDate;
        String examRegionSurchargeId;
        String examEPId;
        Double surchargeCurrency;
        
        if (examType == Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCS) {
            Boolean checkPC = checkPacingRuleApplied(Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCS);
            if (checkPC) {
                LIST<String> eligibilityPeriodLists = getExamEligibilityDate(Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCS);
                String dateString = eligibilityPeriodLists[0];
                String dateStringValue = dateString.substringAfter('||||');
                String epStartDateString = dateStringValue.substringBefore('----');
                epStartDate = Date.valueOf(epStartDateString);
                epEndDate = Date.valueOf(epStartDateString) + 365;
                
            } else {
                epStartDate = System.Today();
                epEndDate = epStartDate + 365;
            }
            examEPId = null;
            examRegionSurchargeId = null;
            surchargeCurrency = null;
        } else {
            epStartDate = Date.valueOf(fieldvalmap.get('EP_start_Date__c'));
            epEndDate = Date.valueOf(fieldvalmap.get('EP_end_Date__c'));
            examEPId = fieldvalmap.get('Eligibility_Period__c');
            examRegionSurchargeId = fieldvalmap.get('Product_Detail__c');
            // Get Surcharge Amount
            Product_Detail__c surchargeRecord = [SELECT Id, Surcharge__c
                                                 FROM Product_Detail__c
                                                 WHERE Id =: examRegionSurchargeId
                                                ][0];
            surchargeCurrency = surchargeRecord.Surcharge__c;
        }
        fieldvalmap.put('Product_Detail__c',examRegionSurchargeId);
        fieldvalmap.put('Eligibility_Period__c',examEPId);
        fieldvalmap.put('EP_start_Date__c',String.valueOf(epStartDate));
        fieldvalmap.put('EP_end_Date__c',String.valueOf(epEndDate));
        if (fieldvalmap.get('examRegId') != '') {
            updateExamReg(fieldvalmap, surchargeCurrency);
        } else {
            createExamRegistration(fieldvalmap, epStartDate, epEndDate, examRegionSurchargeId, surchargeCurrency, examEPId);
        }
        return true;
    }
    
    // Purpose : Method to update Exam Registration Records. This method is created to reduce cognitive complexity
    public static void updateExamReg(Map<String,String> fieldvalmap, Double surchargeCurrency){
        Exam_Registration__c updateExamRegistration = new Exam_Registration__c();
        updateExamRegistration.Id = fieldvalmap.get('examRegId');
        updateExamRegistration.Exam_Types__c = fieldvalmap.get('Exam_Types__c');
        updateExamRegistration.Product_Detail__c = fieldvalmap.get('Product_Detail__c');
        updateExamRegistration.Surcharge__c = surchargeCurrency;
        updateExamRegistration.EP_start_Date__c = Date.valueOf(fieldvalmap.get('EP_start_Date__c'));
        updateExamRegistration.EP_end_Date__c = Date.valueOf(fieldvalmap.get('EP_end_Date__c'));
        updateExamRegistration.Test_Accommodations_needed__c = fieldvalmap.get('Test_Accommodations_needed__c');
        updateExamRegistration.Visa_Letter_Needed__c = fieldvalmap.get('Visa_Letter_Needed__c') == 'true';
        updateExamRegistration.Exception_Reason__c = fieldvalmap.get('exceptionReason');
        if(String.isNotEmpty(fieldvalmap.get('passedExamExceptionId'))){
            updateExamRegistration.Passed_Exam_Exception__c = fieldvalmap.get('passedExamExceptionId');
        }else{
            updateExamRegistration.Passed_Exam_Exception__c = null;
        }
        if(Schema.sObjectType.Exam_Registration__c.isUpdateable()){
            Update updateExamRegistration;
        }
        Exam_Registration__c updateExamRegistrationCase = new Exam_Registration__c();
        updateExamRegistrationCase = [SELECT Id, Case__c, Case__r.Exam_Type__c FROM Exam_Registration__c WHERE Id =: updateExamRegistration.Id];
        Case caseUpdate = new Case();
        caseUpdate.Id = updateExamRegistrationCase.Case__r.Id;
        caseUpdate.Exam_Type__c = fieldvalmap.get('Exam_Types__c');
        caseUpdate.Eligibility_Period__c = fieldvalmap.get('Eligibility_Period__c');             
        caseUpdate.Exam_Region__c  = fieldvalmap.get('examRegion');
        caseupdate.Product_Detail__c = fieldvalmap.get('Product_Detail__c');       
        if(Schema.sObjectType.Case.isUpdateable()){
            Update caseUpdate;
        }
        // Update Exam_Registration__c and Case__c in Asset Record
        if(String.isNotEmpty(fieldvalmap.get('assetUrl')) && fieldvalmap.get('assetInserted') == 'true'){
            updateAssetExamRegistration(fieldvalmap.get('assetUrl'), caseUpdate.Id, updateExamRegistration.Id, fieldvalmap.get('Exam_Types__c'));
        }else if(String.isNotEmpty(fieldvalmap.get('assetUrl')) && fieldvalmap.get('assetInserted') == 'false'){
            EpicCredVerController.markAssetsForDeletion(fieldvalmap.get('assetUrl'));
        }
        deleteVisaExceptionDocEdit(fieldvalmap.get('assetUrl'),updateExamRegistration.Id);
    }
    
    /**
* Created by Ajoydhas
* Method Name: getPassedExamTypes
* Purpose : Method to get all passed exam types
* Return Type : return the passed exam types in SET
*/
    public static Set<String> getPassedExamTypes() {
        Id contactId = AppforCertHelper.retrieveCurrentContactId();
        Set<String> passedExamsTypes = new Set<String> ();
        List<Exam_Registration__c > examsRegList = [SELECT id, Exam_Status__c, Exam_Types__c
                                                    FROM Exam_Registration__c
                                                    WHERE Applicant__c =: contactId
                                                   ];
        if (!examsRegList.isEmpty()) {
            for (Exam_Registration__c er: examsRegList) {
                if (er.Exam_Status__c == Constants.EXAM_REGISTRATION_EXAM_STATUS_PASSED) {
                    passedExamsTypes.add(er.Exam_Types__c);
                }
            }
        }
        return passedExamsTypes;
    }
    
    // Purpose : Method to insert Exam Registration Records. This method is created to avoid Sonar Issue
    @AuraEnabled(Cacheable = false)
    public static void createExamRegistration(Map<String, String> fieldvalmap, Date epStartDate, Date epEndDate, String examRegionSurchargeId, Double surchargeCurrency, String examEPId) {
        Id contactId = AppforCertHelper.retrieveCurrentContactId();
        Id examRegRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        String caseStatus = Constants.CASE_STATUS_PENDING_SUBMISSION;
        String examType = fieldvalmap.get('Exam_Types__c');
        String assetId = fieldvalmap.get('assetUrl');
        String assetInserted = fieldvalmap.get('assetInserted');
        String passedExamExceptionId = fieldvalmap.get('passedExamExceptionId') != '' ? fieldvalmap.get('passedExamExceptionId') : null;
        String exceptionReason = fieldvalmap.get('exceptionReason');
        String previouslyPassed = Constants.STATUS_NO;
        string examRegion = fieldvalmap.get('examRegion');
        Set<String> passedExamsTypes = getPassedExamTypes();
        String newCaseId;
        if(passedExamsTypes.contains(examType)){
            previouslyPassed = Constants.STATUS_YES;
        }
        // Getting Case Id
        List<Exam_Registration__c> examRegRecords = [SELECT Id, Case__c, Case__r.Exam_Type__c
                                                     FROM Exam_Registration__c
                                                     WHERE Applicant__c =: contactId
                                                     AND Case__r.RecordTypeId =: examRegRecordTypeId
                                                     AND Case__r.Internal_Status__c =: caseStatus WITH SECURITY_ENFORCED
                                                    ];
        if(!examRegRecords.isEmpty()){
            newCaseId = createExamRegistationCase();
        }else{
            newCaseId = createExamRegCase();
        }
        Exam_Registration__c examRegistration = new Exam_Registration__c(
            Applicant__c = contactId,
            Case__c = newCaseId,
            Exam_Types__c = examType,
            Product_Detail__c = examRegionSurchargeId,
            Surcharge__c = surchargeCurrency,
            EP_start_Date__c = epStartDate,
            EP_end_Date__c = epEndDate,
            Passed_Exam_Exception__c = passedExamExceptionId,
            Exception_Reason__c = exceptionReason,
            Previously_Passed__c = previouslyPassed,
            Test_Accommodations_needed__c = fieldvalmap.get('Test_Accommodations_needed__c'),
            Visa_Letter_Needed__c = fieldvalmap.get('Visa_Letter_Needed__c') == 'true'
        );
        Case caseUpdate = new Case();
        caseUpdate.Id = newCaseId;
        caseUpdate.Exam_Type__c = examType;
        caseUpdate.Eligibility_Period__c = examEPId;
        caseupdate.Product_Detail__c = examRegionSurchargeId; 
        caseUpdate.Exam_Region__c  = examRegion;
        if(Case.SObjectType.getDescribe().isUpdateable()){
            Update caseUpdate;
        }
        if(Schema.sObjectType.Exam_Registration__c.isCreateable()){
            Insert examRegistration;
        }
        // Update Exam_Registration__c and Case__c in Asset Record
        if(String.isNotEmpty(assetId) && assetInserted == 'true'){
            updateAssetExamRegistration(assetId, newCaseId, examRegistration.Id, examType);
        }else if(String.isNotEmpty(assetId) && assetInserted == 'false'){
            EpicCredVerController.markAssetsForDeletion(assetId);
        }
    }
    
    //Method to update the Case Id and Exam Reg Id in Asset Record
    @AuraEnabled(Cacheable = false)
    public static void updateAssetExamRegistration(String assetUrl, String newCaseId, String examRegId, String examType){
        List<Asset> assetList = [Select Id FROM Asset where Azure_Storage_URL__c=:assetUrl WITH SECURITY_ENFORCED];
        if(!assetList.isEmpty()){
            Asset updateAssetRecord = new Asset();
            updateAssetRecord.Id = assetList[0].Id;
            updateAssetRecord.Case__c = newCaseId;
            updateAssetRecord.Exam_Registration__c = examRegId;
            updateAssetRecord.Exam_Registration_Exam_Type__c = examType;
            Update updateAssetRecord;
        }
    }
    
    /**
* Created by Ajoydhas
* Method Name: getExamRegistrationDetail
* Purpose : Method to fetch the list of Exam Regions and Surcharges based on the selected Exam Type
* Return Type : String containing validation error or blank if no errors are hit
*/
    @AuraEnabled(Cacheable = false)
    public static Map<String, String> getExamRegistrationDetail(String examRegId) {
        Map<String, String> valuesToReturn = new Map<String, String> ();
        Exam_Registration__c examRegRecord = [SELECT Id, Case__c,Case__r.Eligibility_Period__c, Applicant__c, Exam_Types__c, Exception_Reason__c, EP_start_Date__c, EP_end_Date__c, Product_Detail__c, Passed_Exam_Exception__c, Test_Accommodations_needed__c, Visa_Letter_Needed__c, Product_Detail__r.Exam_Region__c
                                              FROM Exam_Registration__c
                                              WHERE Id =: examRegId
                                             ][0];
        valuesToReturn.put('Case__c', examRegRecord.Case__c);
        valuesToReturn.put('Exam_Types__c', examRegRecord.Exam_Types__c);
        valuesToReturn.put('Exception_Reason__c', examRegRecord.Exception_Reason__c);
        valuesToReturn.put('EP_start_Date__c', String.valueOf(examRegRecord.EP_start_Date__c));
        valuesToReturn.put('EP_end_Date__c', String.valueOf(examRegRecord.EP_end_Date__c));
        valuesToReturn.put('Product_Detail__c', examRegRecord.Product_Detail__c);
        valuesToReturn.put('Test_Accommodations_needed__c', examRegRecord.Test_Accommodations_needed__c);
        valuesToReturn.put('Passed_Exam_Exception__c', examRegRecord.Passed_Exam_Exception__c);
        valuesToReturn.put('Visa_Letter_Needed__c', String.valueOf(examRegRecord.Visa_Letter_Needed__c));
        valuesToReturn.put('ExamRegion', examRegRecord.Product_Detail__r.Exam_Region__c);
        // Formatting EP Start Date & EP End Date
        Date epStartDate = examRegRecord.EP_start_Date__c;
        if (epStartDate != null) {
            string elRangeFormatted = '';
            string elRange = '';
            Datetime epStartDateTime = Datetime.newInstance(epStartDate.year(), epStartDate.month(), epStartDate.day());
            Date epEndDate = examRegRecord.EP_end_Date__c;
            Datetime epEndDateTime = Datetime.newInstance(epEndDate.year(), epEndDate.month(), epEndDate.day());
            String eligibilityDateFormatted = epStartDateTime + '----' + epEndDateTime;
            if(examRegRecord.Case__r.Eligibility_Period__c != null){
                eligibilityDateFormatted = eligibilityDateFormatted +'----'+ examRegRecord.Case__r.Eligibility_Period__c;
            }
            Set<string> eligIDSet = new Set<string>();
            List<string> eligIDList = new List<string>();
            eligIDList = getExamEligibilityDate(examRegRecord.Exam_Types__c);
            eligIDSet.addAll(eligIDList);
            
            elRangeFormatted = epStartDateTime.format(Constants.Eligibility_Date_Format) + ' - ' + epEndDateTime.format(Constants.Eligibility_Date_Format);                
            elRange = elRangeFormatted + '||||' + eligibilityDateFormatted ;
            
            
            if (!eligIDSet.contains(elRange)) { 
                valuesToReturn.put('eligibilityDate', '');
            }else{
                valuesToReturn.put('eligibilityDate', eligibilityDateFormatted);
            }
            
        }
        return valuesToReturn;
    }
    
    /*
* Created by Balashankar
* Method Name: examEligibilityDate
* Purpose : Method to get Exam Eligibility Date
* Return Type : List<String>
*/
    @AuraEnabled(Cacheable = true)
    public static List<string> getExamEligibilityDate(String type) {
        Date curDate = System.Today();
        
        Id contactId = AppForCertHelper.retrieveCurrentContactId();        
        
        List<string> returnVal = new List<string> ();
        Integer day = curDate.day();
        String typeVal = type;
        
        Set<String> status = new Set<String> {
            constants.EXAM_REGISTRATION_EXAM_STATUS_PASSED, constants.EXAM_REGISTRATION_EXAM_STATUS_FAILED
                };
                    
                    List<Exam_Registration__c > allExams = new List<Exam_Registration__c > ();
        allExams = [Select Id, Exam_Types__c, Exam_Status__c, Exam_taken_date__c, Applicant__c from Exam_Registration__c
                    where Exam_Status__c IN: status and Exam_Types__c =: typeVal and
                    Applicant__c =: contactId order by Exam_taken_date__c
                   ];
        
        if (allExams.size() >= 3) {
            
            Integer cr1mon = allExams[0].Exam_taken_date__c.month();
            Integer cr1yr = allExams[0].Exam_taken_date__c.year();
            Date tempCR1Date = null;
            Date cr1Date = null;
            if(typeVal == constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCS){
                tempCR1Date = allExams[0].Exam_taken_date__c.addyears(1);
                cr1Date = tempCR1Date;
            }else{
                tempCR1Date = Date.newInstance(cr1yr + 1, cr1mon, 1);
                cr1Date = tempCR1Date.addMonths(1);
            }           
            
            List<Exam_Registration__c > afterSortER = new List<Exam_Registration__c > ();
            for (Integer i = allExams.size() - 1; i >= 0; i--) {
                afterSortER.add(allExams.get(i));
            }
            
            Date cr2Date = null;
            if(typeVal == constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCS){
                cr2Date = afterSortER[0].Exam_taken_date__c.addMonths(6);
            }else{
                cr2Date = afterSortER[0].Exam_taken_date__c.addMonths(7);
            }
            
            Integer cr2mon = cr2Date.month();
            Integer cr2yr = cr2Date.year();
            Date cr2Datefinal = Date.newInstance(cr2yr, cr2mon, 1);
            if(typeVal == constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCS){
                cr2Datefinal = cr2Date;
            }
            
            Date prDate = getPRDate(cr1Date, cr2Datefinal, typeVal);
            returnVal = getAllEligibleDate(prDate,typeVal);
        } 
        else {
            if(typeVal == constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCS){
                curDate = curDate.addDays(1);
            }
            
            returnVal = getAllEligibleDate(curDate,typeVal);
        }
        return returnVal;
    }
    
    /* Created by Reshma
* Method Name: getPRDate
* Purpose : Method added to refactor getExamEligibilityDate method
* Return Type : Integer
*/
    public static Date getPRDate(Date cr1Date, Date cr2Datefinal, String typeVal) {
        Date prDate = null;
        if (cr1Date > cr2Datefinal) {
            prDate = cr1Date;
        } else {
            prDate = cr2Datefinal;
        }
        
        if(prDate < System.Today()){
            prDate = System.Today();
        }
        
        return prDate;
    }
    
    /*
* Created by Balashankar
* Method Name: checkPacingRuleApplied
* Purpose : Method to check whether Pacing rule applied for Step2cs
* Return Type : Boolean
*/
    @AuraEnabled(Cacheable = true)
    public static Boolean checkPacingRuleApplied(String type){
        Boolean returnVal = False;
        Date curDate = System.Today();
        Id contactId = AppForCertHelper.retrieveCurrentContactId();
        
        Integer day = curDate.day();
        String typeVal = type;
        
        Set<String> status = new Set<String> {
            constants.EXAM_REGISTRATION_EXAM_STATUS_PASSED, constants.EXAM_REGISTRATION_EXAM_STATUS_FAILED
                };
                    List<Exam_Registration__c > allExams = new List<Exam_Registration__c > ();
        allExams = [Select Id, Exam_Types__c, Exam_Status__c, Exam_taken_date__c, Applicant__c from Exam_Registration__c
                    where Exam_Status__c IN: status and Exam_Types__c =: typeVal and
                    Applicant__c =: contactId order by Exam_taken_date__c
                   ];
        if (allExams.size() >= 3) {
            returnVal = True;
        }
        return returnVal;
    }
    
    // To get Exam Eligibility Date
    public static List<String> getAllEligibleDate(Date curDate,String typeVal){        
        List<String> finalResult = new List<String>();
        if(typeVal == constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCS){            
            String elRangeFormatted = '';
            String elRangeActual = '';
            String elRange ='';
            Date curDateVal = curDate.addDays(1);
            Integer day1 = curDateVal.day();
            Integer mon1= curDateVal.month();
            Integer yr1 = curDateVal.year();
            DateTime dt1 = DateTime.newInstance(yr1, mon1, day1);            
            Date relatedMonthDate = curDateVal.addMonths(2);
            Integer day2 = relatedMonthDate.day();
            Integer mon2= relatedMonthDate.month();
            Integer yr2 = relatedMonthDate.year();
            DateTime dt2 = DateTime.newInstance(yr2, mon2, day2);            
            elRangeFormatted = dt1.format(Constants.Eligibility_Date_Format) + ' - ' + dt2.format(Constants.Eligibility_Date_Format);
            elRangeActual = dt1 + '----' + dt2;
            elRange = elRangeFormatted + '||||' + elRangeActual;            
            finalResult.add(elRange);
        }
        else{
            for(Eligibility_Period__c ep : [SELECT Id,Name,Active__c,Deadline_Date__c,EP_Start_Date__c,EP_End_Date__c,Exam_Type__c,Extension_Flag__c
                                            FROM Eligibility_Period__c WHERE RecordType.DeveloperName =:Constants.ELIGIBILITY_PERIOD_RECORD_TYPE_EXAM_REG 
                                            AND Exam_Type__c =: typeVal AND 
                                            Deadline_Date__c >=:curDate AND Active__c =: 'Y' AND Extension_Flag__c =: 'N' ORDER BY Deadline_Date__c]){                                                
                String elRangeFormatted = '';
                String elRangeActual = '';
                String elRange ='';
                Integer day1 = ep.EP_Start_Date__c.day();
                Integer mon1= ep.EP_Start_Date__c.month();
                Integer yr1 = ep.EP_Start_Date__c.year();
                DateTime dt1 = DateTime.newInstance(yr1, mon1, day1);                                                
                Integer day2 = ep.EP_End_Date__c.day();
                Integer mon2= ep.EP_End_Date__c.month();
                Integer yr2 = ep.EP_End_Date__c.year();
                DateTime dt2 = DateTime.newInstance(yr2, mon2, day2);                                                
                elRangeFormatted = dt1.format(Constants.Eligibility_Date_Format) + ' - ' + dt2.format(Constants.Eligibility_Date_Format);
                elRangeActual = dt1 + '----' + dt2 +'----'+ep.Id;
                elRange = elRangeFormatted + '||||' + elRangeActual;                                                
                finalResult.add(elRange);
            }            
        }
        return finalResult;
    }
    
    
    
    /* Created by Jofrin
* Method Name: contactStagingLicenseVal
* Purpose : Return previous license field value in contact staging to page.
* Return Type : string
*/
    @AuraEnabled(cacheable = false)
    public static string contactStagingLicenseVal() {
        
        Contact thisContact = ExamRegistrationUtility.contactRecord;
        List<Contact_Staging__c > csRecords = new List<Contact_Staging__c > ();
        csRecords = [Select Id, Contact__c, Previous_License__c, RecordType.DeveloperName from Contact_Staging__c where Contact__c =: thisContact.Id AND RecordType.DeveloperName =: Constants.CONTACT_STAGING_RECORDTYPE_EXAMREGISTRATION LIMIT 1];
        if (csRecords.size() > 0) {
            return csRecords[0].Previous_License__c;
        } else {
            return '';
        }
    }
    
    /*
* Created by Jofrin
* Method Name: examRegPaymentCompletion
* Purpose : Method to check the validation for updating the case status during complete payment
* Return Type : Boolean
*/
    @AuraEnabled(Cacheable = false)
    public static List<string> examRegPaymentCompletion() {        
        Boolean returnVal;
        Boolean statusCheck = false;
        String reviewReason = '';
        Contact thisContact = ExamRegistrationUtility.contactRecord;
        List<string> casesList = getExamRegCaseNumber();
        string licenseVal = contactStagingLicenseVal();
        List<Case> caseExamList = new List<Case> ([SELECT Id, CaseNumber, Internal_Status__c, ContactId FROM Case WHERE CaseNumber IN: casesList]);
        Map<String, OFAC__c > ofacCountriesMap = ServicesComponentController.getOFACCountryList();        
        List<Contact_Association_Type__c > catList = new List<Contact_Association_Type__c > ();        
        Decimal totalYearsAttend = 0.0;
        if (thisContact.School_Enrollment_Status__c == constants.CONASCTYPESTG_STATUS_STUDENT) {
            string soqlQueryCat = 'Select RecordType.DeveloperName, Id,Number_of_Years_Attended__c,Transfer_Credit_to_Degree_School__c from' + ' ' + 'Contact_Association_Type__c where Contact__c = \'' + thisContact.Id + '\'' + 'and RecordType.DeveloperName in (\'' + Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL + '\',\'' + Constants.CONASCTYPE_RECORD_TYPE_MEDICAL_SCHOOL + '\',\'' + Constants.CONASCTYPE_RECORD_TYPE_OTHER_INSTITUTION + '\')';
            catList = Database.query(soqlQueryCat);            
            for (Contact_Association_Type__c catl: catList) {
                if ((catl.RecordType.DeveloperName == Constants.CONASCTYPE_RECORD_TYPE_MEDICAL_SCHOOL && catl.Transfer_Credit_to_Degree_School__c == True) || catl.RecordType.DeveloperName == Constants.CONASCTYPE_RECORD_TYPE_OTHER_INSTITUTION || catl.RecordType.DeveloperName == Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL) {
                    totalYearsAttend = totalYearsAttend + catl.Number_of_Years_Attended__c;
                }
            }
        }
        if (totalYearsAttend<(Decimal.Valueof(System.Label.Basic_Science_Curriculum_months) / 12) && thisContact.School_Enrollment_Status__c == constants.CONASCTYPESTG_STATUS_STUDENT) {
            reviewReason = reviewReason + Constants.REVIEWREASON_TOTALYEARSATTEND + '<br>';
            statusCheck = true;
        }
        if (licenseVal == 'Yes') {
            reviewReason = reviewReason + Constants.REVIEWREASON_USMEDICALLICENSE + '<br>';
            statusCheck = true;
        }
        if (!ofacCountriesMap.isEmpty() && ofacCountriesMap.containsKey(thisContact.MailingCountry) && ofacCountriesMap.get(thisContact.MailingCountry).type__c == System.Label.OFAC_Country_Warning) {
            reviewReason = reviewReason + Constants.REVIEWREASON_OFACWARNING + '<br>';
            statusCheck = true;
        }
        if (casesList.size() > 0) {
            returnVal = updateExamRegCases(caseExamList, statusCheck, thisContact, reviewReason);
        }
        //Querying Doc Configs and calls PDFButler Callout class accordingly- 15087 - Exam Application Summary
        List<cadmus_core__Doc_Config__c> docConfigList = new List<cadmus_core__Doc_Config__c>();
        if(thisContact.School_Enrollment_Status__c == constants.CONASCTYPESTG_STATUS_GRADUATE){
            docConfigList = [SELECT Id,cadmus_core__View_Customer_DocConfig_Id__c 
                                                          FROM cadmus_core__Doc_Config__c 
                                                          WHERE Name = 'Graduate Exam Application Summary' 
                                                          WITH SECURITY_ENFORCED];
        }else if(thisContact.School_Enrollment_Status__c == constants.CONASCTYPESTG_STATUS_STUDENT){
            docConfigList = [SELECT Id,cadmus_core__View_Customer_DocConfig_Id__c 
                                                          FROM cadmus_core__Doc_Config__c 
                                                          WHERE Name = 'Student Exam Application Summary' 
                                                          WITH SECURITY_ENFORCED];
        }
        Id docConfigId;
        if(!docConfigList.isEmpty()){
            docConfigId = docConfigList[0].Id;
        }        
        if(String.isNotBlank(docConfigId) && !caseExamList.isEmpty()){
            for(Case caseRecord : caseExamList){
                PDFButlerCallout calloutClass = new PDFButlerCallout(docConfigId, caseRecord.Id);
                System.enqueueJob(calloutClass);
            }
        }
        return casesList;
    }
    
    /**
* Created by Jofrin
* Method Name: updateExamRegCases
* Purpose : To Update the status.
* Return Type : Boolean
*/
    @AuraEnabled(Cacheable = false)
    public static Boolean updateExamRegCases(List<Case> caseExamList, Boolean statusCheck, Contact thisContact, String reviewReason){
        Boolean returnVal = false;
        List<Id> idList = new List<Id>();
        List<case >newCases = new List<case>();
        List<case >finalCases = new List<case>();
        List<Case> examRegCasesStud = new List<Case>();
        Set<ID> studContactIds = new Set<ID>();
            Map<Id, Case> mapCaseIdCase = new Map<Id, Case>(caseExamList);
        Map<Case, Exam_Registration__c> mapCaseExam = new Map<Case, Exam_Registration__c>();
        List<Exam_Registration__c> exmRgList = new List<Exam_Registration__c>([Select id, Exam_Types__c, Previously_Passed__c, Case__c from Exam_Registration__c where Case__c IN: mapCaseIdCase.keySet()]);
        for(Exam_Registration__c caseER: exmRgList){
            mapCaseExam.put(mapCaseIdCase.get(caseER.Case__c),caseER);
        }
        Group g = [SELECT Id, name, Group.DeveloperName FROM Group WHERE Type = 'Queue'
                   and Group.DeveloperName =: Constants.QUEUE_EXAM_REG
                  ];
        for(Case eachCase: mapCaseExam.keyset()){
            System.debug('****eachCase1936***'+eachCase);
            if(statusCheck == True || mapCaseExam.get(eachCase).Previously_Passed__c == 'Yes')
            {
                eachCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_REVIEW;
            }else
            {
                if(thisContact.School_Enrollment_Status__c == constants.CONASCTYPESTG_STATUS_STUDENT){
                    eachCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_ENROLLMENT;
                    examRegCasesStud.add(eachCase);
                    studContactIds.add(eachCase.ContactId);
                }else{
                    eachCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_CIBIS;
                }
            }
            eachCase.OwnerId = g.Id;
            idList.add(eachCase.Id);
            newCases.add(eachCase);
        }
        if(!examRegCasesStud.isEmpty()){
            createEVCase(examRegCasesStud, studContactIds);
        }
        finalCases = updateManualReasonValue(newCases,exmRgList,reviewReason);
        finalCases = caseListDeduplicator(finalCases); 
        try{
            update finalCases;
            returnVal = true;
        }catch(exception e){
            system.debug('Cases update' + e);
        }
        try{
            Map<Id, Exam_Registration__c> exmRgListIdMap = new Map<Id, Exam_Registration__c>(exmRgList);
            contactStagingMigration(exmRgListIdMap.keyset());
        }catch(exception e){
            system.debug('Contact staging update' + e);
        }
        try{
            sendMailforStatusUpdate(thisContact.Id,idList);
        }catch(exception e){
            system.debug('send mail method' + e);
        }
        return returnVal;
    }
    /**
* @author: Chinmay Menon
* @methodname: caseListDeduplicator
* @description: Method to remove duplicate records from list which is to be processed by a CRUD operation
* @Parameters: List of cases
* @return type: list<Case>
*/
    public static List<case> caseListDeduplicator(List<case > finalCases){
        Map<Id, Case> finalCasesMap = new Map<Id, Case>();
        for(case c: finalCases){
            if(!finalCasesMap.containsKey(c.Id)){
                finalCasesMap.put(c.Id, c);
            }
        }
        finalCases = finalCasesMap.values();
        
        return finalCases;
    }
    
    
    /**
* Created by Jofrin
* Method Name: updateManualReasonValue
* Purpose : Update Manual Reason field
* Return Type : List<case>
*/
    
    public static List<case> updateManualReasonValue(List<case > allCases, List<Exam_Registration__c > exmRgList, String reviewReason) {
        
        Map<Case, Exam_Registration__c > mapCaseExam = new Map<Case, Exam_Registration__c > ();
        Map<Id, Case> mapCaseIdCase = new Map<Id, Case> (allCases);
        List<case> finalCases = new List<case>();
        
        for (Exam_Registration__c caseER: exmRgList) {
            mapCaseExam.put(mapCaseIdCase.get(caseER.Case__c), caseER);
        }
        
        for (Case eachCase: mapCaseExam.keyset()) {
            if (mapCaseExam.get(eachCase).Previously_Passed__c == 'Yes') {
                eachCase.Manual_Review_Reasons__c = reviewReason + Constants.REVIEWREASON_PREVIOUSPASSED;
            }
            else{
                eachCase.Manual_Review_Reasons__c = reviewReason;
            }
            finalCases.add(eachCase);
        }
        
        return finalCases;
    }
    
    /**
* Created by Jofrin
* Method Name: sendMailforStatusUpdate
* Purpose : Send mail when the status is updated.
* Return Type : null
*/
    
    public static void sendMailforStatusUpdate(Id idContact, List<Id> idCase) {
        
        List<case> newCase = new List<case >([Select id, Internal_Status__c, Case_Status__c, ContactId, contact.Name, Contact.Email, ECFMG_Portal_Case_Url__c from Case where Id =: idCase]);
        EmailTemplate emailTemplate = [Select Id, Subject, Description, HtmlValue, DeveloperName, Body from EmailTemplate where DeveloperName =: Constants.CASE_EMAIL_TEMPLATE_NAME];
        List<OrgWideEmailAddress> addr  = [select Id from OrgWideEmailAddress where displayname =: Constants.ORG_WIDE_ADDRESS];
        
        For(Case cas: newCase) {
            
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setTargetObjectId(cas.ContactId);
            message.setTemplateID(emailTemplate.Id);
            message.setOrgWideEmailAddressId(addr[0].Id);
            
            String htmlBody = emailTemplate.HtmlValue;
            htmlBody = htmlBody.replace('{!Case.Internal_Status__c}', cas.Case_Status__c);
            htmlBody = htmlBody.replace('{!Case.Contact}', cas.Contact.Name);
            htmlBody = htmlBody.replace('[Link]', '<a href="' + cas.ECFMG_Portal_Case_Url__c + '">Case Status</a>');
            
            htmlBody = htmlBody.replaceAll('<!\\[CDATA\\[', '');
            htmlBody = htmlBody.replaceAll('\\]\\]>', '');
            
            message.setHtmlBody(htmlBody);
            message.toAddresses = new String[] {
                cas.Contact.Email
                    };
                        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage > {
                            message
                                };
                                    try {
                                        Messaging.sendEmail(messages);
                                    } catch (Exception e) {
                                        system.debug(e);
                                    }
        }
    }
    
    /**
* Created by Jofrin
* Method Name: contactStagingMigration
* Purpose : Method to copy Contact Staging to Contact.
* Return Type : null
*/
    @future
    public static void contactStagingMigration(Set<ID> exmRgListIdMap){
        List<Exam_Registration__c> exmRgList = new List<Exam_Registration__c>([Select id, Exam_Types__c, Previously_Passed__c, Case__c from Exam_Registration__c where Case__c IN: exmRgListIdMap]);
        Contact thisContact = ExamRegistrationUtility.contactRecord;
        string fieldNames = '';
        List<Contact_Staging__c> recordsList = new List<Contact_Staging__c > ();
        List<Contact> contactsList = new List<Contact>();
        Map<String, Schema.SObjectField> fieldMapContactStaging = Schema.getglobaldescribe().get('Contact_Staging__c').getdescribe().fields.getmap();
        for(Schema.SObjectField field1: fieldMapContactStaging.values()){
            fieldNames = fieldNames + field1.getDescribe().getName() + ',';       
        }
        fieldNames = fieldNames.removeEnd(',');        
        List<String> fieldsToCopy = System.Label.Fields_To_Copy_From_Contact_Staging_Object.split(',');
        string soqlQueryConStaging = 'Select RecordType.DeveloperName,' + ' ' + fieldNames + ' ' + 'from' + ' ' + 'Contact_Staging__c where Contact__c = \'' + thisContact.Id + '\'' + 'and RecordType.DeveloperName in (\'' + Constants.CONTACT_STAGING_RECORDTYPE_EXAMREGISTRATION + '\')';
        recordsList = Database.query(soqlQueryConStaging);
        string soqlQueryContacts = 'Select Id,RecordType.DeveloperName,Step_1_Attempt_Limit_Exception__c,Step_2_CK_Attempt_Limit_Exception__c,Step_2_CS_Attempt_Limit_Exception__c,' + ' ' + System.Label.Fields_To_Copy_From_Contact_Staging_Object + ' ' + 'from' + ' ' + 'Contact where Id = \'' + thisContact.Id + '\'';
        contactsList = Database.query(soqlQueryContacts);
        for(Schema.SObjectField field: fieldMapContactStaging.values()){
            string fieldName = field.getDescribe().getName();
            if(fieldsToCopy.contains(fieldName)){
                contactsList[0].put(fieldName, recordsList[0].get(fieldName));
            }
        }
        for(Exam_Registration__c exam: exmRgList){
            if(exam.Exam_Types__c == constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE && contactsList[0].Step_1_Attempt_Limit_Exception__c == true){
                contactsList[0].Step_1_Attempt_Limit_Exception__c = false;
            }
            if(exam.Exam_Types__c == constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK && contactsList[0].Step_2_CK_Attempt_Limit_Exception__c == true){
                contactsList[0].Step_2_CK_Attempt_Limit_Exception__c = false;
            }
            if(exam.Exam_Types__c == constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCS && contactsList[0].Step_2_CS_Attempt_Limit_Exception__c == true){
                contactsList[0].Step_2_CS_Attempt_Limit_Exception__c = false;
            }
        }
        try{
            update contactsList;
            delete recordsList;
        }catch(Exception e){
            system.debug(e);
        }
    }
    
    /**
* Created by Jofrin
* Method Name: getEligibleRegionChangeCases
* Purpose : Method to show Region change link.
* Return Type : List<case>
*/
    
    @AuraEnabled(Cacheable = true)
    public static List<Id> getEligibleRegionChangeCases() {
        
        Id currentContactId = AppForCertHelper.retrieveCurrentContactId();
        List<Id> casesIdList = new List<Id> ();
        
        List<case >newCaseList = new List<case >();
        
        if (currentContactId != null) {
            
            newCaseList = [SELECT id, CaseNumber, Internal_Status__c FROM Case WHERE recordType.DeveloperName =: Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION
                           AND ContactId =: currentContactId AND Internal_Status__c =: Constants.CASE_STATUS_REGISTERED
                          ];
            List<Exam_Registration__c > erList = new List<Exam_Registration__c > ([Select id, case__c, EP_end_Date__c, Exam_taken_date__c, Exam_Status__c, Exam_Types__c from Exam_Registration__c where case__c =: newCaseList
                                                                                   AND (Exam_Types__c =: Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE or Exam_Types__c =: Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK) AND Exam_Status__c = null
                                                                                  ]);
            
            if (!erList.isEmpty()) {
                for (Exam_Registration__c eachER: erList) {
                    casesIdList.add(eachER.case__c);
                }
            }
        }
        return casesIdList;
    }
    /**
* Created by Jofrin
* Method Name: RegionChangeCasesValidation
* Purpose : Method to validate during click on Region change link.
* Return Type : string
*/
    
    @AuraEnabled
    public static string regionChangeCasesValidation() {
        
        Id currentContactId = AppForCertHelper.retrieveCurrentContactId();
        Map<String, OFAC__c > ofacCountriesMap = ServicesComponentController.getOFACCountryList();
        Contact thisContact = [Select id, MailingCountry, School_Enrollment_Status__c from Contact where id =: currentContactId Limit 1];
        String valFail= '';
        Boolean validationError = false;
        List<String> recTypeList = new List<String>();
        recTypeList.add(Constants.CASE_RECORD_TYPE_APP_BIO_CHANGE);
        
        List<Case> existingCases = new List<Case> ([SELECT Id,Internal_Status__c,ContactId,isClosed,Service__c,RecordType.DeveloperName,Case_Status__c FROM Case WHERE ContactId=:currentContactId 
                                                    AND isClosed = FALSE AND RecordType.DeveloperName IN :recTypeList]);
        
        String methodVal = regionValidationContMethod();
        if (!ofacCountriesMap.isEmpty() && ofacCountriesMap.containsKey(thisContact.MailingCountry) && ofacCountriesMap.get(thisContact.MailingCountry).type__c == System.Label.OFAC_NOT_ALLOWED1) {
            valFail = valFail + System.Label.OFAC_Not_Allowed_Error_Message + '<br>';
            validationError = True;
        }
        if (!existingCases.isEmpty()){ 
            valFail = valFail + System.Label.Biographic_change_error_message +'<br>';
            validationError = True;
        }
        if (String.isnotBlank(methodVal) && methodVal != 'true') {
            valFail = valFail + methodVal;
            validationError = True;
        }
        if (validationError){
            return valFail;
        }
        
        return 'true';
    }
    /**
* Created by Jofrin
* Method Name: regionValidationContMethod
* Purpose : Method to validate during click on Region change link.
* Return Type : string
*/
    
    @AuraEnabled
    public static String regionValidationContMethod() {
        
        List<Id> casesList = new List<Id> ();
        casesList = getEligibleRegionChangeCases();
        Date valCheckDate = system.today() + 20;
        
        List<Exam_Registration__c > erList = new List<Exam_Registration__c > ([SELECT Id, case__c, EP_end_Date__c, Exam_taken_date__c, Exam_Status__c, Exam_Types__c FROM Exam_Registration__c WHERE case__c =: casesList]);
        Integer erListSize = erList.size();
        
        String valLabel = '';
        Integer erCount = 0;
        for (Exam_Registration__c eachExmReg: erList) {
            if (eachExmReg.EP_end_Date__c<valCheckDate) {
                erCount++;
            }
            if (eachExmReg.EP_end_Date__c<valCheckDate && !valLabel.contains(System.label.Region_Change_Validation_Eligibility_Period)) {
                valLabel = valLabel +  System.label.Region_Change_Validation_Eligibility_Period;
            }
        }
        if (erCount == erListSize) {
            return valLabel;
        }
        return 'true';
    }
    
    /**
* Created by Chinmay on March 24th, 2020
* Method Name: deleteAsset
* Purpose : Method to delete an asset once exception is changed
* Return Type : void
*/
    @AuraEnabled(Cacheable = false)
    public static void deleteAsset(String contactId) {
        AppForCertController.deleteAssetAndRelatedDocument(contactId, Constants.ASSET_KEYVAL_VISA_EXCEPTION_DOC, '');
    }
    /**
* Created by Femi
* Method Name: getExamRegistrationsForStatus on 27/07/2020
* Purpose : Method to get list of case with exam registrations for Exam Registration subtab
* Return Type : List of ExamRegRecordWrapper records
*/
    @AuraEnabled(cacheable = false)
    public static List< ExamRegRecordWrapper > getExamRegistrationsForStatus() {
        Id contactId = AppForCertHelper.retrieveCurrentContactId();
        Id examRegRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        List<ExamRegRecordWrapper> examRegWrapperList = new List<ExamRegRecordWrapper>();
        Set<String> caseIds = new Set<String>();
        List<Exam_Registration__c> examRegList = [SELECT Id, Exam_Types__c, EP_start_Date__c, EP_end_Date__c, Product_Detail__c, Product_Detail__r.Exam_Region__r.Region_Name__c, Test_Accommodations_needed__c, Case__r.External_Status__c, Case__c 
                                                  FROM Exam_Registration__c
                                                  WHERE Applicant__c =: contactId
                                                  AND Case__r.RecordTypeId =: examRegRecordTypeId
                                                  AND Case__r.Internal_Status__c !=: Constants.CASE_STATUS_PENDING_SUBMISSION
                                                  AND Case__r.Internal_Status__c !=: Constants.CASE_STATUS_EXPIRED
                                                  AND Case__r.Internal_Status__c !=: Constants.CASE_STATUS_REJECTED
                                                  AND Case__r.Internal_Status__c !=: Constants.CASE_STATUS_ENROLLMENT_NOT_VERIFIED_MEDSCL
                                                  AND Case__r.Internal_Status__c !=: Constants.CASE_STATUS_CANCELLED
                                                  AND Exam_Status__c = null
                                                  ORDER BY Exam_Types__c];
        for(Exam_Registration__c examReg : examRegList){
            caseIds.add(examReg.case__c);
        }
        Map<String,string> schedulingPermitMap = getSchedulingPermit(caseIds);
        Map<String,string> visaLetterMap = getVisaLetter(caseIds);
        String entityPortalEnrolled = 'Yes';
        List<Contact_Association_Type__c> catRecord   =   new List<Contact_Association_Type__c>{CaseTriggerUtility.catMap.get(contactId)};
            if(!catRecord.isEmpty()){
                List<Account2Service__c> acnt2services = [SELECT Id, Service__c, Service__r.Id 
                                                          FROM Account2Service__c 
                                                          WHERE Account__c =: catRecord[0].Account__c AND Active__c = true];
                
                if(!acnt2services.isEmpty()){
                    entityPortalEnrolled = 'No';
                }
            }
        
        for(Exam_Registration__c examReg : examRegList){
            Integer epSTYear = examReg.EP_start_Date__c.year();
            Integer epSTMonth = examReg.EP_start_Date__c.month();
            Integer epSTDay = examReg.EP_start_Date__c.day();
            DateTime epSTDt = DateTime.newInstance(epSTYear, epSTMonth, epSTDay);
            
            Integer epENYear = examReg.EP_end_Date__c.year();
            Integer epENMonth = examReg.EP_end_Date__c.month();
            Integer epENDay = examReg.EP_end_Date__c.day();
            DateTime epENDt = DateTime.newInstance(epENYear, epENMonth, epENDay);
            String dateFormat = dateFormatString;
            String caseId;
            String showPaperForm;
            caseId = examReg.Case__c;
            Boolean caseInternalStatus = ApplicantMyProfileController.getInternalStatus(caseId);
            Boolean parentCaseInternalStatus = false;
            if(caseInternalStatus == false){
                parentCaseInternalStatus = getParentCaseInternalStatus(caseId);
            }
            if((caseInternalStatus == true || parentCaseInternalStatus == true) && entityPortalEnrolled == 'Yes'){
                showPaperForm = 'Yes';
            }
            else{
                showPaperForm = 'No';
            }
            Boolean showVisa = ApplicantMyProfileController.checkVisaLetter(caseId);
            Boolean showPermitForm = ApplicantMyProfileController.checkPermitForm(caseId);
            String assetLinkPE = getPEAssetLink(caseId);
            examRegWrapperList.add(new ExamRegRecordWrapper(
                examReg,
                epSTDt.format(dateFormat) +' - '+ epENDt.format(dateFormat) + '~' + examReg.Case__r.External_Status__c,
                showPaperForm,
                schedulingPermitMap.get(examReg.Case__c),
                visaLetterMap.get(examReg.Case__c), 
                assetLinkPE, 
                showVisa + '~' + showPermitForm
            ));
        }
        return examRegWrapperList;
    }
    /**
* Created by Femi
* Method Name: getSchedulingPermit on 28/07/2020
* Purpose : Method to get list of scheduling permits for Exam Registration subtab
* Return Type : Map< String,String >
*/
    public static Map< String,String > getSchedulingPermit(Set<String> caseIds) {
        Map< String,String > caseAssetMap = new Map< String,String >();
        Map< String,String > caseDocMap = new Map< String,String >();
        Set<Id> assetIds = new Set<Id>();
        
        for(Asset asst:[SELECT id,case__c FROM Asset where type__c =: Constants.ASSET_TYPE_SCHEDULING_PERMIT AND case__c IN:caseIds AND RecordTypeId =: Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId() AND Status =: Constants.ASSET_STATUS_IN_PROGRESS]){
            caseAssetMap.put(asst.id,asst.case__c);
            assetIds.add(asst.id);
        }
        if(!assetIds.isEmpty()){
            List<contentDocumentLink> contLinks=[SELECT Id, ContentDocumentId, LinkedEntityId FROM contentDocumentLink WHERE LinkedEntityId IN:assetIds];
            for(contentDocumentLink contLink:contLinks){
                caseDocMap.put(caseAssetMap.get(contLink.LinkedEntityId),Constants.FILE_DOWNLOAD_URL + contLink.ContentDocumentId);
            }
        }
        
        return caseDocMap;
    }
    /**
* Created by Femi
* Method Name: getVisaLetter on 28/07/2020
* Purpose : Method to get list of visa letters for Exam Registration subtab
* Return Type : Map< String,String >
*/
    public static Map< String,String > getVisaLetter(Set<String> caseIds) {
        Map< String,String > caseAssetMap = new Map< String,String >();
        Map< String,String > caseDocMap = new Map< String,String >();
        Set<Id> assetIds = new Set<Id>();
        
        for(Asset asst:[SELECT id,case__c FROM Asset where type__c =: Constants.ASSET_TYPE_VISA_LETTER AND case__c IN:caseIds AND RecordTypeId =: Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId() AND status != :constants.ASSET_STATUS_MARKED_FOR_DELETION]){
            caseAssetMap.put(asst.id,asst.case__c);
            assetIds.add(asst.id);
        }
        if(!assetIds.isEmpty()){
            List<contentDocumentLink> contLinks=[SELECT Id, ContentDocumentId, LinkedEntityId FROM contentDocumentLink WHERE LinkedEntityId IN:assetIds];
            for(contentDocumentLink contLink:contLinks){
                caseDocMap.put(caseAssetMap.get(contLink.LinkedEntityId),Constants.FILE_DOWNLOAD_URL + contLink.ContentDocumentId);
            }
        }
        
        return caseDocMap;
    }
    
    /* Wrapper class to store prior exam registration record data in examregLandingPage
*/
    public class PriorExamRegRecordWrapper {
        @auraenabled public string recordIdVal {
            get;
            set;
        }
        @auraenabled public string examType {
            get;
            set;
        }
        @auraenabled public string eligibilityPeriod {
            get;
            set;
        }
        @auraenabled public string testingRegion {
            get;
            set;
        }
        @auraenabled public string testAccomodations {
            get;
            set;
        }
        @auraenabled public string applicationStatus {
            get;
            set;
        }
        @auraenabled public string pdOptOut {
            get;
            set;
        }
        
        public PriorExamRegRecordWrapper(String examRegId, String examRegType, String examRegEP, String examRegRegion, String examRegTestAcc, String applStatus, String pdOptOutRec) {
            recordIdVal = examRegId;
            examType = examRegType;
            eligibilityPeriod = examRegEP;
            testingRegion = examRegRegion;
            testAccomodations = examRegTestAcc;
            applicationStatus = applStatus;
            pdOptOut = pdOptOutRec;
        }
    }
    
    /**
* Created by Varsha Hariharan
* Method Name: getExamRegistrationPriorRecords
* Purpose : Method to get list of prior exam registration records for Exam Registration subtab
* Return Type : List of ExamRegRecordWrapper records
*/
    @AuraEnabled(cacheable = false)
    public static List< PriorExamRegRecordWrapper > getExamRegistrationPriorRecords() {
        Id contactId = AppForCertHelper.retrieveCurrentContactId();
        Id examRegRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        List<PriorExamRegRecordWrapper> priorExamRegWrapperList = new List<PriorExamRegRecordWrapper>();
        List<Exam_Registration__c> examRegList = [SELECT Id, Exam_Types__c, CreatedDate, EP_start_Date__c, EP_end_Date__c, Exam_Status__c, Product_Detail__c, Product_Detail__r.Exam_Region__r.Region_Name__c, Test_Accommodations_needed__c, Case__r.External_Status__c, Case__c, Pd_Optout_flag__c 
                                                  FROM Exam_Registration__c
                                                  WHERE Applicant__c =: contactId
                                                  AND Case__r.RecordTypeId =: examRegRecordTypeId
                                                  AND (Case__r.External_Status__c =: Constants.CASE_STATUS_REJECTED
                                                       OR Case__r.External_Status__c =: Constants.CASE_STATUS_ENROLLMENT_NOT_VERIFIED_MEDSCL
                                                       OR Case__r.External_Status__c =: Constants.CASE_STATUS_REGISTERED)
                                                  ORDER BY CreatedDate DESC];
        
        for(Exam_Registration__c examReg : examRegList){
            Integer epSTYear = examReg.EP_start_Date__c.year();
            Integer epSTMonth = examReg.EP_start_Date__c.month();
            Integer epSTDay = examReg.EP_start_Date__c.day();
            DateTime epSTDt = DateTime.newInstance(epSTYear, epSTMonth, epSTDay);
            
            Integer epENYear = examReg.EP_end_Date__c.year();
            Integer epENMonth = examReg.EP_end_Date__c.month();
            Integer epENDay = examReg.EP_end_Date__c.day();
            DateTime epENDt = DateTime.newInstance(epENYear, epENMonth, epENDay);
            String dateFormat = dateFormatString;
            String caseId;
            String optOutFlag = Constants.STATUS_NO;
            caseId = examReg.Case__c;
            if(examReg.Pd_Optout_flag__c == True){
                optOutFlag = Constants.STATUS_YES;
            }
            if(examReg.Case__r.External_Status__c == Constants.CASE_STATUS_REGISTERED){
                if(examReg.Exam_Status__c != NULL){
                    priorExamRegWrapperList.add(new PriorExamRegRecordWrapper(
                        examReg.Id, 
                        examReg.Exam_Types__c, 
                        epSTDt.format(dateFormat) +' - '+ epENDt.format(dateFormat),
                        examReg.Product_Detail__r.Exam_Region__r.Region_Name__c, 
                        examReg.Test_Accommodations_needed__c, 
                        examReg.Case__r.External_Status__c, 
                        optOutFlag
                    )); 
                }
            }
            else{
                priorExamRegWrapperList.add(new PriorExamRegRecordWrapper(
                    examReg.Id, 
                    examReg.Exam_Types__c, 
                    epSTDt.format(dateFormat) +' - '+ epENDt.format(dateFormat),
                    examReg.Product_Detail__r.Exam_Region__r.Region_Name__c, 
                    examReg.Test_Accommodations_needed__c, 
                    examReg.Case__r.External_Status__c, 
                    optOutFlag
                ));
            }
        }
        return priorExamRegWrapperList;
    }
    /**
* Created by Varsha Hariharan
* Method Name: getParentCaseInternalStatus
* Purpose : Method to check if the Eligibility Period Extension case's parent EV case status and return the value
* Return Type : Boolean
*/
    @AuraEnabled(cacheable = false)
    public static boolean getParentCaseInternalStatus(String caseId){
        Boolean returnFlag = false;
        List<Case> caseRec = new List<Case>([Select Id, Enrollment_Verification_Parent__c from Case where ParentId =: caseId AND RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD]);
        if(caseRec.size() > 0){
            String parentCase = caseRec[0].Enrollment_Verification_Parent__c;
            if(parentCase == null || parentCase == ''){
                returnFlag = false;
            }
            else{
                List<Case> caseRecord = new List<Case>([Select Id, Internal_Status__c from Case where Id =: parentCase]);
                List<String> caseStatus = new List<String>{Constants.CASE_STATUS_RECEIVED_IN_REVIEW, Constants.CASE_STATUS_PENDING_ENROLLMENT, Constants.CASE_STATUS_PENDING_REVIEW, Constants.CASE_STATUS_ENROLLMENT_VERIFICATION_INCOMPLETE, Constants.CASE_STATUS_IN_REVIEW};
                    returnFlag = caseStatus.contains(caseRecord[0].Internal_Status__c);
            }
        }
        return returnFlag;       
    }
    
    //Purpose: To get the asset link of the Exam Registration Case, EpEx case is checked first
    public static String getPEAssetLink(String caseId){
        String assetLinkToReturn = '';
        List<Case> checkEPEXCase = new List<Case>();
        if(Case.SObjectType.getDescribe().isAccessible() && Schema.SObjectType.Case.fields.Enrollment_Verification_Parent__c.isAccessible() && Schema.SObjectType.Case.fields.Id.isAccessible()){
            checkEPEXCase = [Select Id, Enrollment_Verification_Parent__c from Case where ParentId =: caseId And RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD];
        }
        if(checkEPEXCase.size() > 0){
            List<Asset> assetLink = new List<Asset>();
            if(Asset.SObjectType.getDescribe().isAccessible() && Schema.SObjectType.Asset.fields.Azure_Storage_URL__c.isAccessible() && Schema.SObjectType.Asset.fields.Id.isAccessible()){
                assetLink = [Select Id, Azure_Storage_URL__c from Asset where Case__c =: checkEPEXCase[0].Enrollment_Verification_Parent__c AND Type__c = 'Enrollment Verification Form' AND Status = 'In Progress'];
            }
            if(assetLink.size() > 0){
                String retVal = assetLink[0].Azure_Storage_URL__c;
                assetLinkToReturn = retVal.substringAfterLast('/');
            }
        }
        else{
            assetLinkToReturn = ApplicantMyProfileController.getPEFormURLEV(caseId);
        }
        return assetLinkToReturn;
    }
    
    // Purpose: To retrieve the Visa Exception Asset's id based on contact Id and exam reg id
    @AuraEnabled
    public static String retExcAssetIdOnPageload(String contactId, String examRegId){
        List<Asset> assetList = new List<Asset>();
        if(Asset.SObjectType.getDescribe().isAccessible()){
            assetList = [SELECT id,Azure_Storage_URL__c FROM Asset where contactId =: contactId AND Exam_Registration__c =: examRegId AND IsExpired__c = FALSE AND IsOrphan__c = FALSE AND status != :constants.ASSET_STATUS_MARKED_FOR_DELETION AND Name =: Constants.ASSET_TYPE_VISA_EXCEPTION_DOCUMENTATION ORDER BY CreatedDate DESC];
        }
        String assetUrl = null;
        if(!assetList.isEmpty()){
            assetUrl = assetList[0].Azure_Storage_URL__c;
        }
        return assetUrl;
    }
    // Purpose: To mark the Visa Exception Asset's for deletion
    @AuraEnabled
    public static Boolean deleteVisaExceptionDoc(String contactId){
        List<Asset> assetList = new List<Asset>();
        List<Asset> assetsToUpdateList = new List<Asset>();
        if(Asset.SObjectType.getDescribe().isAccessible()){
            assetList = [SELECT id,Azure_Storage_URL__c FROM Asset where contactId =: contactId AND case__c = null AND status != :constants.ASSET_STATUS_MARKED_FOR_DELETION AND Name =: Constants.ASSET_TYPE_VISA_EXCEPTION_DOCUMENTATION ORDER BY CreatedDate DESC];
        }
        List<RecordType> rts = new List<RecordType>();
        if(RecordType.SObjectType.getDescribe().isAccessible()){
            rts = [SELECT Id, Name from RecordType where DeveloperName =: Constants.ASSET_RECORD_TYPE_MARKED_FOR_DELETION AND SObjectType = 'Asset'];
        }
        RecordType assetMarkedForDeletionRT = rts[0];
        if(Asset.SObjectType.getDescribe().isUpdateable()){
            for(Asset a: assetList){
                a.Status = Constants.ASSET_STATUS_MARKED_FOR_DELETION;
                a.Case__c = null;
                a.Contact_Association_Type_Staging__c = null;
                a.Exam_Registration__c = null;
                a.Exam_Registration_Exam_Type__c = null;
                a.RecordTypeId = assetMarkedForDeletionRT.Id;
                assetsToUpdateList.add(a);
            }
            if(!assetsToUpdateList.isEmpty()){
                UPDATE assetsToUpdateList;
            }
        }
        return true;
    }
    // Purpose: To mark the Visa Exception Asset's for deletion on edit
    @AuraEnabled
    public static void deleteVisaExceptionDocEdit(String azureUrl, String examRegId){
        List<Asset> assetList = new List<Asset>();
        List<Asset> assetsToUpdateList = new List<Asset>();
        if(Asset.SObjectType.getDescribe().isAccessible()){
            assetList = [SELECT id,Azure_Storage_URL__c FROM Asset where Azure_Storage_URL__c !=:azureUrl AND Exam_Registration__c =:examRegId AND status != :constants.ASSET_STATUS_MARKED_FOR_DELETION AND Name =: Constants.ASSET_TYPE_VISA_EXCEPTION_DOCUMENTATION ORDER BY CreatedDate DESC];
        }
        List<RecordType> rts = new List<RecordType>();
        if(RecordType.SObjectType.getDescribe().isAccessible()){
            rts = [SELECT Id, Name from RecordType where DeveloperName =: Constants.ASSET_RECORD_TYPE_MARKED_FOR_DELETION AND SObjectType = 'Asset'];
        }
        RecordType assetMarkedForDeletionRT = rts[0];
        if(Asset.SObjectType.getDescribe().isUpdateable()){
            for(Asset a: assetList){
                a.Status = Constants.ASSET_STATUS_MARKED_FOR_DELETION;
                a.Case__c = null;
                a.Contact_Association_Type_Staging__c = null;
                a.Exam_Registration__c = null;
                a.Exam_Registration_Exam_Type__c = null;
                a.RecordTypeId = assetMarkedForDeletionRT.Id;
                assetsToUpdateList.add(a);
            }
            if(!assetsToUpdateList.isEmpty()){
                UPDATE assetsToUpdateList;
            }
        }
    }
    //Method to create Enrollment Verification case
    public static void createEVCase(List<Case> newExamRegCases, Set<ID> examRegCaseContactIds){
        try{
            Group evQueue                   =   CaseTriggerUtility.groupMap.get(Constants.CASE_QUEUE_ENROLLMENT_VERIFICATION);        
            List<Case> evCaseList           =   new List<Case>();
            List<Case> updateExamRegCaseList=   new List<Case>();
            SET<string> contactIdSet        =   new SET<string>();
            Set<Id> accountIds              =   new Set<Id>();
            List<Contact_Association_Type__c> catRecord   =   new List<Contact_Association_Type__c>();
            Map<Id, Id> contactCATAccountMap              =   new Map<Id, Id>();        
            for(Case newExamRegCase : newExamRegCases){
                catRecord.add(CaseTriggerUtility.catMap.get(newExamRegCase.ContactId));
                accountIds.add(catRecord[0].Account__c);
                contactCATAccountMap.put(newExamRegCase.ContactId, catRecord[0].Account__c);            
            }
            // MAP of contact Id and Account Id of EV CASE 
            MAP<ID, Id> contactEVCaseAccountMap = getContactEVCaseAccountMapRefactor(examRegCaseContactIds, accountIds);
            // Account2Service__c
            Set<Id> account2ServiceSet = getAccount2ServiceRefactor(accountIds);
            // ContactId with List of ExamRegCaseIds
            MAP<String, List<Id>> examRegCaseMap = getExamRegCaseMapRefactor(newExamRegCases);
            for(Case examRegCase : newExamRegCases){
                Id contactId        =   examRegCase.ContactId;
                Id catAccountId     =   contactCATAccountMap.get(contactId);
                Id evcaseAccountId;
                if(contactEVCaseAccountMap.containsKey(contactId)){
                    evcaseAccountId = contactEVCaseAccountMap.get(contactId);
                }
                if(account2ServiceSet.contains(catAccountId)){
                    // Creating New EV Case if no EV Case                
                    if(catAccountId == evcaseAccountId){ 
                        updateExamRegCaseList.add(examRegCase);
                    }else if(!contactIdSet.contains(contactId)){
                            contactIdSet.add(contactId);
                            // Record Type -> Degree_Medical_School
                            Boolean account2Service = true;
                            Case evCaseObj = createEVCaseObject(contactId, evQueue.Id, account2Service); 
                            evCaseList.add(evCaseObj);
                    }              
                }else{
                    // Paper EV Case
                    // Record Type -> Degree_Medical_School
                    Boolean account2Service = false;
                    Case evCaseObj = createEVCaseObject(contactId, evQueue.Id, account2Service); 
                    evCaseList.add(evCaseObj);
                }            
            }
            // manage Update & Inert the lists - avoiding the sonar code issues
            handlingEVCaseDML(evCaseList, updateExamRegCaseList, examRegCaseMap);
        }
        catch(Exception ex){
            throw ex;
        }          
    }
    //Method to get contact from EV Case Account
    public static MAP<ID, Id> getContactEVCaseAccountMapRefactor(Set<Id> examRegCaseContactIds, Set<Id> accountIds){
        try{
            Id evRecordTypeId       =   Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION).getRecordTypeId();     
            MAP<ID, Id> contactEVCaseAccountMap  =   new MAP<ID, Id>();
            for(Case evCaseRecord : [SELECT Id, Internal_Status__c, ContactId, AccountId FROM Case WHERE RecordTypeId =: evRecordTypeId AND ContactId IN: examRegCaseContactIds AND AccountId IN :accountIds WITH SECURITY_ENFORCED]){
                contactEVCaseAccountMap.put(evCaseRecord.ContactId, evCaseRecord.AccountId);
            }
            return contactEVCaseAccountMap;
        }
        catch(Exception ex){
            throw ex;
        } 
    }
    //Method to get Account2Service__c
    public static SET<Id> getAccount2ServiceRefactor(Set<Id> accountIds){
        try{
            Set<Id> account2ServiceSet = new Set<Id>();
            for(Account2Service__c a2s : [SELECT Id, Account__c FROM Account2Service__c WHERE Account__c IN :accountIds AND Active__c = True WITH SECURITY_ENFORCED]){
                account2ServiceSet.add(a2s.Account__c);
            }
            return account2ServiceSet;
        }
        catch(Exception ex){
            throw ex;
        }     
    }
    //Method to get contactid with list of exam reg. cases
    public static MAP<String, List<Id>> getExamRegCaseMapRefactor(List<Case> newExamRegCases){
        try{
            MAP<String, List<Id>> examRegCaseMap = new MAP<String, List<Id>>();
            for(Case examRegCase : newExamRegCases){
                Id examRegCaseId    =   examRegCase.Id;
                Id contactId        =   examRegCase.ContactId;
                if(examRegCaseMap.containsKey(contactId)){
                    List<Id> examRegCaseIdList = examRegCaseMap.get(contactId);
                    examRegCaseIdList.add(examRegCaseId);
                    examRegCaseMap.put(contactId, examRegCaseIdList);
                }else{
                    examRegCaseMap.put(contactId, new List<Id>{examRegCaseId});
                }
            }
            return examRegCaseMap;
        }
        catch(Exception ex){
            throw ex;
        }       
    }
    //Method to return new ev case instance
    public static Case createEVCaseObject(String contactId, String queueId, Boolean account2Service){
        try{
            Id evRecordTypeId       =   Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION).getRecordTypeId();
            List<Contact_Association_Type__c> catRecord   =   new List<Contact_Association_Type__c>{CaseTriggerUtility.catMap.get(contactId)};         
            Case caseObj = new Case();
            caseObj.ContactId                    =   contactId;                
            caseObj.RecordTypeId                 =   evRecordTypeId;
            caseObj.Internal_Status__c           =   Constants.CASE_STATUS_NEW;
            caseObj.OwnerId                      =   queueId;
            caseObj.AccountId                    =   catRecord[0].Account__c;
            caseObj.Enrolled_in_Entity_Portal__c =   account2Service;
            caseObj.School_Program__c            =   catRecord[0].School_Program__c;
            caseObj.Attendance_Start_Date__c     =   catRecord[0].Start_Date__c;
            caseObj.Attendance_End_Date__c       =   catRecord[0].End_Date__c;
            //code added by Shailaja. Date format stories.
            caseObj.Attendance_Start_Month__c     =   catRecord[0].Start_Month__c;        
            caseObj.Attendance_Start_Year__c     =   catRecord[0].Start_Year__c;
            caseObj.Attendance_End_Month__c       =   catRecord[0].End_Month__c;
            caseObj.Attendance_End_Year__c       =   catRecord[0].End_Year__c;
            caseObj.Graduation_Month__c          =   catRecord[0].Graduation_Month__c;
            caseObj.Graduation_Year__c           =   catRecord[0].Graduation_Year__c;
            caseObj.Degree_Date__c               =   catRecord[0].Degree_Issue_Date__c;
            //code added by Shailaja. Date format stories.
            caseObj.Degree_Month__c               =   catRecord[0].Degree_Issue_Month__c;
            caseObj.Degree_Year__c               =   catRecord[0].Degree_Issue_Year__c;
            caseObj.Number_of_Years_Attended__c  =   catRecord[0].Number_of_Years_Attended__c;
            caseObj.Unique_Medical_School__c     =   catRecord[0].Student_ID__c; 
            return caseObj;
        }
        catch(Exception ex){
            throw ex;
        }
    }
    //Method to avoid the Cognitive Complexity
    public static void handlingEVCaseDML(List<Case> evCaseList, List<Case> updateExamRegCaseList, MAP<String, List<Id>> examRegCaseMap){
        try{
            Map<ID, STRING> assetContactMap = new Map<ID, STRING>();
            for(Asset photoAsset : [SELECT Id, Type__c, ContactId, Enrollment_Verification_Case__c
                                                FROM Asset 
                                            WHERE Type__c = 'Photo'
                                                AND ContactId IN: examRegCaseMap.keySet()
                                                AND status != :constants.ASSET_STATUS_MARKED_FOR_DELETION WITH SECURITY_ENFORCED]){
                assetContactMap.put(photoAsset.ContactId, photoAsset.Id);
            }
            if(!evCaseList.isEmpty()){
                if(Schema.sObjectType.Case.isCreateable() && !evCaseList.isEmpty()){
                    INSERT evCaseList;
                }
                reupdateEVCaseStatuses(evCaseList);
                List<Asset> evCaseAssetUpdate = new List<Asset>();
                // Update EV Case Id as Exam Reg.Case's Enrollment Verification Case Id
                handlingEVCaseDMLRefactor(evCaseList, examRegCaseMap);
                // Update Photo Asset
                for(Case evCaseRecord : evCaseList){
                    // Get photo asset & Update the Enrollment_Verification_Case__c in Asset Object                 
                    if(assetContactMap.containsKey(evCaseRecord.ContactId)){
                        Asset evAssetObj = new Asset();
                        evAssetObj.Id  =   assetContactMap.get(evCaseRecord.ContactId);
                        evAssetObj.Enrollment_Verification_Case__c = evCaseRecord.Id;
                        evCaseAssetUpdate.add(evAssetObj);
                    }
                }
                // Update Photo Asset
                if(!evCaseAssetUpdate.isEmpty()){
                    evCaseAssetUpdate = assetListDeduplicator(evCaseAssetUpdate);
                    UPDATE evCaseAssetUpdate;
                }            
            }
            // Update EV Case
            if(!updateExamRegCaseList.isEmpty()){
                updateEVCase(updateExamRegCaseList);
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }
    //Method to get contactid with list of exam reg. cases
    public static void handlingEVCaseDMLRefactor(List<Case> evCaseList, MAP<String, List<Id>> examRegCaseMap){
        try{
            List<Case> examRegCaseToUpdate = new List<Case>();
            Map<Id, Id> tempExamRegCaseMap = new Map<Id, Id>();
            for(Case evCaseRecord : evCaseList){
                Boolean enrolledInEntityPortal  =   evCaseRecord.Enrolled_in_Entity_Portal__c;
                List<Id> examRegCaseIdList      =   examRegCaseMap.get(evCaseRecord.ContactId);
                if(enrolledInEntityPortal == true){
                    for(Id examRegCaseId : examRegCaseIdList){
                        // Update the Exam Registration Case
                        Case examRegCase = new Case();
                        examRegCase.Id  =   examRegCaseId;
                        examRegCase.Enrollment_Verification_Parent__c = evCaseRecord.Id;
                        examRegCaseToUpdate.add(examRegCase);
                    }                    
                }else{
                    // Paper EV Case
                    Id examRegCaseId = examRegCaseIdList.get(0);
                    if(tempExamRegCaseMap.containsKey(examRegCaseId)){
                        examRegCaseId = examRegCaseIdList.get(1);              
                    }else{                    
                        tempExamRegCaseMap.put(examRegCaseId, evCaseRecord.Id);
                    }
                    // Update the Exam Registration Case
                    Case examRegCase = new Case();
                    examRegCase.Id  =   examRegCaseId;
                    examRegCase.Enrollment_Verification_Parent__c = evCaseRecord.Id;
                    examRegCaseToUpdate.add(examRegCase);
                }
            }
            if(!examRegCaseToUpdate.isEmpty()){
                examRegCaseToUpdate = caseListDeduplicator(examRegCaseToUpdate);
                UPDATE examRegCaseToUpdate;
            }
        }
        catch(Exception ex){
            throw ex;
        } 
    }
    //Method to update ev case status, external status and verification status based on Enrolled in Entity Portal field value
    public static void reupdateEVCaseStatuses(List<Case> evCaseList){
        try{
            Set<Case> evCasesToBeReupdated = new Set<Case>();
            for(Case evCaseIter : evCaseList){
                    Case evCaseToReupdate = evCaseIter;
                    if(evCaseIter.Enrolled_in_Entity_Portal__c){
                        evCaseToReupdate.External_Status__c = Constants.CASE_EXTERNAL_STATUS_NOT_REVIEWED;
                        evCaseToReupdate.Status_Not_Reviewed_Date__c = System.today();
                        evCaseToReupdate.Verification_Status__c = Constants.CASE_VERIFICATION_STATUS_NOT_REVIEWED;
                        evCaseToReupdate.Internal_Status__c = Constants.CASE_STATUS_POSTED_TO_ENTITY_PORTAL;
                    }else{
                        evCaseToReupdate.Internal_Status__c = Constants.CASE_STATUS_PENDING_ENROLLMENT;
                    }
                evCasesToBeReupdated.add(evCaseToReupdate);
            }
            if(!evCasesToBeReupdated.isEmpty()){
                List<Case> listOfEvCasesToBeUpdated = new List<Case>();
                listOfEvCasesToBeUpdated.addAll(evCasesToBeReupdated);
                UPDATE listOfEvCasesToBeUpdated;
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }
    //Method to remove duplicate records from asset list which is to be processed by a CRUD operation
    public static List<Asset> assetListDeduplicator(List<Asset> allAssets){
        try{
            Map<Id, Asset> finalAssetsMap = new Map<Id, Asset>();
            for(Asset a: allAssets){
                if(!finalAssetsMap.containsKey(a.Id)){
                    finalAssetsMap.put(a.Id, a);
                }
            }
            allAssets = finalAssetsMap.values();
            return allAssets;
        }
        catch(Exception ex){
            throw ex;
        }
    }
    //Method to update enrollment verification case and child exam reg cases
    public static void updateEVCase(List<Case> newExamRegCases){
        try{
            Id evRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION).getRecordTypeId();
            Group evQueue = CaseTriggerUtility.groupMap.get(Constants.CASE_QUEUE_ENROLLMENT_VERIFICATION);
            Map<Id, Case> caseMap = new Map<Id, Case>();
            List<Contact_Association_Type__c> catRecord   =   new List<Contact_Association_Type__c>();
            Set<Id> contactIds = new Set<Id>();
            Set<Id> accountIds = new Set<Id>();
            Set<Id> account2ServiceSet = new Set<Id>();
             for(Case newCase : newExamRegCases){
                catRecord.add(CaseTriggerUtility.catMap.get(newCase.ContactId));
                contactIds.add(newCase.ContactId);
                accountIds.add(catRecord[0].Account__c);
             }
             for(Account2Service__c a2s : [SELECT Id, Account__c FROM Account2Service__c WHERE Account__c IN :accountIds AND Active__c = True WITH SECURITY_ENFORCED]){
                account2ServiceSet.add(a2s.Account__c);
             }
             List<Case> evCases = [SELECT Id, Internal_Status__c, OwnerId, ContactId, AccountId, Enrolled_in_Entity_Portal__c, Account.IsCustomerPortal
                                FROM Case
                                WHERE RecordTypeId =: evRTId AND ContactId IN :contactIds AND AccountId IN :accountIds WITH SECURITY_ENFORCED];
             List<Case> examRegCases = [SELECT Id, ContactId, Enrollment_Verification_Parent__c, Account.IsCustomerPortal FROM Case WHERE Id IN : newExamRegCases WITH SECURITY_ENFORCED];
             for(Case newCase : examRegCases){
                for(Case evCase : evCases){
                    for(Contact_Association_Type__c cat : catRecord){
                        if(newCase.ContactId == evCase.ContactId && cat.Account__c == evCase.AccountId && account2ServiceSet.contains(evCase.AccountId)){
                            newCase.Enrollment_Verification_Parent__c = evCase.Id;
                            caseMap.put(newCase.Id, newCase);
                            Case evCaseToUpdate = new Case();
                            evCaseToUpdate.Id = evCase.Id;
                            evCaseToUpdate.Internal_Status__c = Constants.CASE_STATUS_NEW;
                            evCaseToUpdate.OwnerId = evQueue.Id;
                            evCaseToUpdate.Enrolled_in_Entity_Portal__c = account2ServiceSet.contains(evCase.AccountId);
                            evCaseToUpdate.School_Program__c            = cat.School_Program__c;
                            evCaseToUpdate.Attendance_Start_Date__c     = cat.Start_Date__c;
                            evCaseToUpdate.Attendance_End_Date__c       = cat.End_Date__c;
                            //code added by Shailaja. Date format stories.
                            evCaseToUpdate.Attendance_Start_Month__c     = cat.Start_Month__c;
                            evCaseToUpdate.Attendance_Start_Year__c     = cat.Start_Year__c;
                            evCaseToUpdate.Attendance_End_Month__c       = cat.End_Month__c;
                            evCaseToUpdate.Attendance_End_Year__c       = cat.End_Year__c;
                            evCaseToUpdate.Graduation_Month__c          = cat.Graduation_Month__c;
                            evCaseToUpdate.Graduation_Year__c           = cat.Graduation_Year__c;
                            evCaseToUpdate.Degree_Date__c               = cat.Degree_Issue_Date__c;
                            //Code added by Shailaja. Dateformat stories.
                            evCaseToUpdate.Degree_Month__c               = cat.Degree_Issue_Month__c;
                            evCaseToUpdate.Degree_Year__c               = cat.Degree_Issue_Year__c;
                            evCaseToUpdate.Number_of_Years_Attended__c  = cat.Number_of_Years_Attended__c;
                            evCaseToUpdate.Unique_Medical_School__c     = cat.Student_ID__c;
                            caseMap.put(evCaseToUpdate.Id, evCaseToUpdate);
                        }
                    }
                }
            }
            updateRefactor(caseMap);
        }
        catch(Exception ex){
            throw ex;   
        }
   }
   public static void updateRefactor(Map<Id, Case> caseMap){
    try{
        Map<Id, Case> evCasesToBeReupdated = new Map<Id, Case>();
        if(!caseMap.isEmpty()){
            UPDATE caseMap.values();
        }
        evCasesToBeReupdated = reupdateCaseStatusMethod(caseMap, evCasesToBeReupdated);
        if(!evCasesToBeReupdated.isEmpty()){
            UPDATE evCasesToBeReupdated.values();
        }
    }
    catch(Exception ex){
        throw ex;
    }
   }
   //Method to create a map of enrollment verification cases whose status needs to be reupdated
    public static Map<Id, Case> reupdateCaseStatusMethod(Map<Id, Case> caseMap, Map<Id, Case> evCasesToBeReupdatedParam){
        try{
            for(Case loopIteratorCase : [SELECT Id, Enrolled_in_Entity_Portal__c, Internal_Status__c FROM Case WHERE Id IN :caseMap.keySet() WITH SECURITY_ENFORCED]){
                if(loopIteratorCase.Enrolled_in_Entity_Portal__c && loopIteratorCase.Internal_Status__c != Constants.CASE_STATUS_POSTED_TO_ENTITY_PORTAL){
                    Case evCaseToReupdate = loopIteratorCase;
                    evCaseToReupdate.Internal_Status__c = Constants.CASE_STATUS_POSTED_TO_ENTITY_PORTAL;
                    evCaseToReupdate.External_Status__c = Constants.CASE_EXTERNAL_STATUS_NOT_REVIEWED;
                    evCaseToReupdate.Status_Not_Reviewed_Date__c = System.today();
                    evCaseToReupdate.Verification_Status__c = Constants.CASE_VERIFICATION_STATUS_NOT_REVIEWED;
                    evCasesToBeReupdatedParam.put(loopIteratorCase.Id, evCaseToReupdate);
                    return evCasesToBeReupdatedParam;
                }
            }
            return evCasesToBeReupdatedParam;
        }
        catch(Exception ex){
            throw ex;
        }
    }
    //Method to create Enrollment Verification case
    @InvocableMethod
    public static void createEVCaseforExamReg(List<Case> examRegCases){
        try{
            Set<Id> studContactIds = new Set<Id>();
            for(Case cs:examRegCases){
                studContactIds.add(cs.ContactId);
            }
            createEVCase(examRegCases, studContactIds);
        }
        catch(Exception ex){
            throw ex;
        }
    }
    @AuraEnabled(cacheable = false)
    public static String getExamRegistrationCases(){
        Id contactId = AppForCertHelper.retrieveCurrentContactId();
        Id examRegRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        List<String> examRegCaseList = new List<String>();
        String caseRecordIds = '';
        for(Exam_Registration__c examReg : [SELECT Id, Case__c
                                            FROM Exam_Registration__c
                                            WHERE Applicant__c =: contactId
                                            AND Case__r.RecordTypeId =: examRegRecordTypeId
                                            AND Case__r.Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION
                                            ORDER BY Exam_Types__c]){
                                                examRegCaseList.add(examReg.Case__c);
                                            }
        if(!examRegCaseList.isEmpty()){
            caseRecordIds = String.join(examRegCaseList,',');
        }        
        return caseRecordIds;
    }
}