public with sharing class AppForCertHelper{        
    //Method to get the contact id of logged in community user
    public static Id retrieveCurrentContactId(){
        Id currentUser = UserInfo.getUserId();
        List < User > userList = [select contactId from User u where u.Id =: currentUser];
        Id contactId = userList[0].contactId;
        return contactId;
    }    
    //Method to get the exam reopened case
    public static Boolean checkExamReopenedCase() {
        String caseId = getCaseId();
       
        Boolean returnVal = False;
        List < Case > caseList = [select Id,Is_Reopened_Exam_Reg__c from Case 
                                    where Id =: caseId];
            if(!caseList.isEmpty()){
                returnVal = caseList[0].Is_Reopened_Exam_Reg__c;
            }        

        return returnVal;
    }

    //Method to get the case id of logged in community user
    public static String getCaseId(){
        Id currentContactId = retrieveCurrentContactId();
        String returnVal = '';
        List<Case> newCases = new List<Case>();
        if(currentContactId != null){
            newCases = [SELECT id FROM Case WHERE recordType.DeveloperName =: Constants.CASE_RECORD_TYPE_APP_FOR_CERT AND ContactId =: currentContactId 
                AND Case_Status__c != :Constants.CASE_STATUS_REJECTED
                AND Case_Status__c != :Constants.CASE_STATUS_EXPIRED
                AND Case_Status__c != :Constants.CASE_STATUS_CANCELLED
            ];
            if(!newCases.isEmpty()){
                returnVal = newCases[0].Id;
            }
        }
        return returnVal;
    }

    //Method to get the case number of logged in community user
    public static String getCaseNumber() {
        Id currentContactId = retrieveCurrentContactId();
        String returnVal = '';
        List <
            case >newCases = new List <
            case >();
        if (currentContactId != null) {

            newCases = [SELECT id, CaseNumber FROM Case WHERE recordType.DeveloperName =: Constants.CASE_RECORD_TYPE_APP_FOR_CERT
                AND ContactId =: currentContactId 
                AND Case_Status__c != :Constants.CASE_STATUS_REJECTED
            ];

            if (!newCases.isEmpty()) {
                returnVal = newCases[0].CaseNumber;
            }

        }

        return returnVal;
    }

    //Method to get the metadata id of confirmation message
    public static String getMetadataId() {
        String returnVal = '';
        List < Confirmation_Message__mdt > confMsgs = new List < Confirmation_Message__mdt > ();
        confMsgs = [SELECT Id FROM Confirmation_Message__mdt where DeveloperName =: Constants.CONFIRMATION_MESSAGE_APP_FOR_CERT];
        if (!confMsgs.isEmpty()) {
            returnVal = confMsgs[0].Id;
        }

        return returnVal;
    }
    //Method to get the ContactAsscociationTypeStaging id of logged in community user
    @AuraEnabled
    public static String getContactAssociationTypeStaging(Boolean showExamRegActionButton, String currentCaseId, String currentContactId){
        String currentContactAssociatonTypeId = '';
        String recordTypeDevNameDegree;
        if(showExamRegActionButton == true){
            recordTypeDevNameDegree = Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL_EXAM_REG;
        }else{
            recordTypeDevNameDegree = Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL;
        }
        List<Contact_Association_Type_Staging__c> existingConAssoStagingObjList = new List <Contact_Association_Type_Staging__c>();
        if(currentCaseId != ''){
            existingConAssoStagingObjList = [SELECT id FROM Contact_Association_Type_Staging__c 
                                                WHERE recordType.DeveloperName =: recordTypeDevNameDegree
                                                AND Parent_Case__c =: currentCaseId WITH SECURITY_ENFORCED];
            if(!existingConAssoStagingObjList.isEmpty()){
                currentContactAssociatonTypeId = existingConAssoStagingObjList[0].Id;
            }else{
                List<Case> rejectedCaseList = [SELECT Id FROM Case WHERE recordType.DeveloperName =: Constants.CASE_RECORD_TYPE_APP_FOR_CERT AND ContactId =: currentContactId AND Internal_Status__c =: Constants.CASE_STATUS_REJECTED WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1];
                if(!rejectedCaseList.isEmpty()){
                    String rejectedAppForCertId = rejectedCaseList[0].Id;
                    List<Contact_Association_Type_Staging__c> conAssStagobjList = [SELECT id FROM Contact_Association_Type_Staging__c 
                                                                                    WHERE recordType.DeveloperName =: recordTypeDevNameDegree
                                                                                    AND Parent_Case__c =: rejectedAppForCertId WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1];
                    if(!conAssStagobjList.isEmpty()){
                        currentContactAssociatonTypeId = conAssStagobjList[0].Id;
                    }
                }     
            }
        }        
        return currentContactAssociatonTypeId;
    }
    //Method to get the ContactAsscociationTypeStaging id of logged in community user
    @AuraEnabled
    public static List<Contact_Association_Type__c> getContactAssociationType(){
        Id contactId = AppForCertHelper.retrieveCurrentContactId();
        String currentContactAssociatonTypeId = '';
        List<Contact_Association_Type__c> existingConAssoStagingObjList = new List<Contact_Association_Type__c>();       
        existingConAssoStagingObjList = [SELECT Id, Credential_Type__c, Case__c, Case__r.Internal_Status__c, Parent_Case__r.Internal_Status__c, Account__r.Is_Final_Transcript_Required__c FROM Contact_Association_Type__c 
                                            WHERE recordType.DeveloperName =: Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL
                                            AND Contact__c =: contactId WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1];     
        return existingConAssoStagingObjList;
    }
    //Method to get the ContactAsscociationTypeStaging Id of for 'Credential Intake'
    @AuraEnabled
    public static String getConAssocTypeStageCredIntake(){
        Id contactId = AppForCertHelper.retrieveCurrentContactId();
        String currentCaseId = getCaseId();
        String conAssocTypeStagCredIntakeId = '';
        String recordTypeDevNameCredIntake = Constants.CONASCTYPESTG_RECORD_TYPE_CREDENTIAL_INTAKE;
        List<Contact_Association_Type_Staging__c> existingConAssoStagingObjList = new List <Contact_Association_Type_Staging__c>();
        if(currentCaseId != ''){
            existingConAssoStagingObjList = [SELECT id FROM Contact_Association_Type_Staging__c 
                                                WHERE recordType.DeveloperName =: recordTypeDevNameCredIntake
                                                AND Contact__c =: contactId AND Parent_Case__c =: currentCaseId WITH SECURITY_ENFORCED];
            if(!existingConAssoStagingObjList.isEmpty()){
                conAssocTypeStagCredIntakeId = existingConAssoStagingObjList[0].Id;
            }
        }        
        return conAssocTypeStagCredIntakeId;
    }
    
    /* Wrapper class to send terms and conditions data to be displayed in legal terms page
     */
    public class TermsObjWrapper {
        @auraenabled public string termsId { get; set; }
        @auraenabled public string termsContent { get; set; }
        @auraenabled public string termsCheckboxContent { get; set; }

        public TermsObjWrapper(String tId, String tCont, String tCbCont) {
            termsId = tId;
            termsContent = tCont;
            termsCheckboxContent = tCbCont;
        }

    }
    // Method to create wrapper for Asset in AppForCert process
    public class AssetObjWrapper{
        @auraenabled public string recordIdVal { get; set; }
        @auraenabled public string docNotInEnglish { get; set; }
        @auraenabled public string nameOnDoc { get; set; }
        @auraenabled public string nameOnDocIsDifferent { get; set; }
        @auraenabled public string type { get; set; }
        @auraenabled public string keyval { get; set; }
        @auraenabled public string parentval { get; set; }
        @auraenabled public string parentAssetId { get; set; }
        @auraenabled public string parentAssetAzureUrl { get; set; }
        @auraenabled public string azureUrl { get; set; }
        public AssetObjWrapper(String id, String notInEnglish, String nameOnTheDoc, String nameOnDocDifferent, String assetType, String keyValue, String parentKeyValue, String parentId) {
            recordIdVal = id;
            docNotInEnglish = notInEnglish;
            nameOnDoc = nameOnTheDoc;
            nameOnDocIsDifferent = nameOnDocDifferent;
            type = assetType;
            keyval = keyValue;
            parentval = parentKeyValue;
            parentAssetId = parentId;
        }
    }

    public class TcObjWrapper {
        @auraenabled public string recordIdVal { get; set; }
        @auraenabled public string fromSchool { get; set; }
        @auraenabled public string transferCreditCourse { get; set; }
        @auraenabled public string transferCreditGrade { get; set; }
        @auraenabled public string courseOutcome { get; set; }
        @auraenabled public string creditsEarnedMonth { get; set; }
        @auraenabled public string creditsEarnedYear { get; set; }

        public TcObjWrapper(String tcId, String fromSchoolId, String tcCourse, String tcGrade, String coursePassFail, String creditsMonth, String creditsYear) {
            recordIdVal = tcId;
            fromSchool = fromSchoolId;
            transferCreditCourse = tcCourse;
            transferCreditGrade = tcGrade;
            courseOutcome = coursePassFail;
            creditsEarnedMonth = creditsMonth;
            creditsEarnedYear = creditsYear;
        }
    }
    public class OtherSchoolObjWrapper{
        @auraenabled public string recordIdVal { get; set; }
        @auraenabled public String numberOfYearsAttended { get; set; }
        @auraenabled public string otherSchool { get; set; }
        @auraenabled public string otherSchoolId { get; set; }
        @auraenabled public string schoolProgram { get; set; }
        @auraenabled public string studentId { get; set; }
        @auraenabled public string specialty { get; set; }
        @auraenabled public string fromDate { get; set; }
        @auraenabled public string endDate { get; set; }
        @auraenabled public string startMonth { get; set; }
        @auraenabled public string startYear { get; set; }
        @auraenabled public string endMonth { get; set; }
        @auraenabled public string endYear { get; set; }
        @auraenabled public string transferCreditsCheckbox { get; set; }
        @auraenabled public string objectType { get; set; }
        @auraenabled public string caseInternalStatus { get; set; }
        @auraenabled public list <AppForCertHelper.TcObjWrapper> tcWrapperList { get; set; }
        @auraenabled public list <AppForCertHelper.AssetObjWrapper> assets { get; set; }
        public OtherSchoolObjWrapper(String id, String accountName, String noOfYearsAttended, String accountId, String program, String stId, String speclty, String startDate, String toDate, String stMonth, String stYear, String edMonth, String edYear, String transferCredits, List<AppForCertHelper.TcObjWrapper> tcList, List<AppForCertHelper.AssetObjWrapper> assetsList, String objType, String caseStatus){
            recordIdVal = id;
            numberOfYearsAttended = noOfYearsAttended;
            otherSchool = accountName;
            otherSchoolId = accountId;
            schoolProgram = program;
            studentId = stId;
            specialty = speclty;
            fromDate = startDate;
            endDate = toDate;
            startMonth = stMonth;
            startYear = stYear;
            endMonth = edMonth;
            endYear = edYear;
            transferCreditsCheckbox = transferCredits;
            objectType = objType;
            if(tcList != null && !tcList.isEmpty()){
                tcWrapperList = new list <TcObjWrapper>();
                tcWrapperList.addAll(tcList);
            }else{
                tcWrapperList = null;
            }
            if(assetsList != null && !assetsList.isEmpty()){
                assets = new list <AssetObjWrapper>();
                assets.addAll(assetsList);
            }else{
                assets = null;
            }
            caseInternalStatus = caseStatus;
        }
    }

    /**
     * Created by Ajoydhas
     * Method Name: OtherMedicalSchoolCombinedWrapper
     * Purpose : Wrapper method to get Other Medical School Records (Contact Association Type AND Contact Association Type Staging)
     * Return Type : List of the OtherMedicalSchoolCombinedWrapper instances which wraps Contact Association Type Staging
     */
    public class OtherMedicalSchoolCombinedWrapper{
        @auraenabled public list <AppForCertHelper.OtherSchoolObjWrapper> otherSchoolWrapperList { get; set; }
        public OtherMedicalSchoolCombinedWrapper(list <AppForCertHelper.OtherSchoolObjWrapper> otherSchoolCombinedList){
            if (otherSchoolCombinedList != null && !otherSchoolCombinedList.isEmpty()){
                otherSchoolWrapperList = new list <OtherSchoolObjWrapper>();
                otherSchoolWrapperList.addAll(otherSchoolCombinedList);
            } else {
                otherSchoolWrapperList = null;
            }
        }
    }

    /**
     * Created By AJOYDHAS.M.A
     * Method Name: convertMonthTextToNumber
     * Purpose : Method to converting from Month text to Month number
     * Parameters : month (in string format)
     * Return Type : Integer (month as Integer)
     */
    public static Integer convertMonthTextToNumber(String month) {
        Map < String, Integer > monthsMap = new Map < String, Integer > ();
        monthsMap.put('January', 1);
        monthsMap.put('February', 2);
        monthsMap.put('March', 3);
        monthsMap.put('April', 4);
        monthsMap.put('May', 5);
        monthsMap.put('June', 6);
        monthsMap.put('July', 7);
        monthsMap.put('August', 8);
        monthsMap.put('September', 9);
        monthsMap.put('October', 10);
        monthsMap.put('November', 11);
        monthsMap.put('December', 12);
        return monthsMap.get(month);
    }


    /**
     * Created By Balashankar
     * Method Name: IncompleteSchoolObjWrapper
     * Purpose : Method to create wrapper for assets and course details
     * Return Type : wrapper
     */
    public class IncompleteSchoolObjWrapper {
        @auraenabled public string recordIdVal { get; set; }

        @auraenabled public list < AppForCertHelper.TcObjWrapper > tcWrapperList { get; set; }
        @auraenabled public list < AppForCertHelper.IncompleteAssetObjWrapper > assets { get; set; }


        public IncompleteSchoolObjWrapper(String id, list < AppForCertHelper.TcObjWrapper > tcList, list < AppForCertHelper.IncompleteAssetObjWrapper > assetsList) {
            recordIdVal = id;

            if (tcList != null && !tcList.isEmpty()) {
                tcWrapperList = new list < TcObjWrapper > ();
                tcWrapperList.addAll(tcList);
            } else {
                tcWrapperList = null;
            }
            if (assetsList != null && !assetsList.isEmpty()) {
                assets = new list < IncompleteAssetObjWrapper > ();
                assets.addAll(assetsList);
            } else {
                assets = null;
            }

        }


    }

    /**
     * Created By Balashankar
     * Method Name: IncompleteAssetObjWrapper
     * Purpose : Method to create wrapper for assets
     * Return Type : wrapper
     */
    public class IncompleteAssetObjWrapper {
        @auraenabled public string recordIdVal { get; set; }
        @auraenabled public string docNotInEnglish { get; set; }
        @auraenabled public string nameOnDoc { get; set; }
        @auraenabled public string nameOnDocIsDifferent { get; set; }
        @auraenabled public string type { get; set; }
        @auraenabled public string keyval { get; set; }
        @auraenabled public string parentval { get; set; }
        @auraenabled public string parentAssetId { get; set; }
        @auraenabled public string deanDate { get; set; }


        public IncompleteAssetObjWrapper(String id, String notInEnglish, String nameOnTheDoc, String nameOnDocDifferent, String assetType, String keyValue, String parentKeyValue, String parentId, string deanLetterDate) {
            recordIdVal = id;
            docNotInEnglish = notInEnglish;
            nameOnDoc = nameOnTheDoc;
            nameOnDocIsDifferent = nameOnDocDifferent;
            type = assetType;
            keyval = keyValue;
            parentval = parentKeyValue;
            parentAssetId = parentId;
            deanDate = deanLetterDate;

        }
    }
    //  Method to create wrapper for Graduate screen in AppForCert process
    public Class UpdateParentAssetWrapper{
		@auraenabled public String contactId { get; set; }
		@auraenabled public Boolean isDeanLetter { get; set; }
		@auraenabled public String nameonDiplomaDocument { get; set; }
		@auraenabled public Boolean isDiplomaNameDifferent { get; set; }
		@auraenabled public Boolean isDiplomaNameinEnglish { get; set; }		
		@auraenabled public String nameonDeanLetterDocument { get; set; }
		@auraenabled public Boolean isDeanLetterDifferent { get; set; }
		@auraenabled public Boolean isDeanLetterNameinEnglish { get; set; }
		@auraenabled public Boolean isFinalTranscriptRequired { get; set; }
		@auraenabled public String nameonFinalTranscriptDocument { get; set; }
		@auraenabled public Boolean isFinalMedicalTranscriptDifferent { get; set; }
		@auraenabled public Boolean isFinalMedicalTranscriptinEnglish { get; set; }		
		@auraenabled public Date dateonDeanLetterDocument { get; set; }
        @auraenabled public Boolean showExamRegActionButton { get; set; }	
        @auraenabled public Boolean reSubmitFromAppForCert { get; set; }
		public updateParentAssetWrapper(String contactIdToUpdate, Boolean isDeanLetterToUpdate, String nameonDiplomaDocumentToUpdate, Boolean isDiplomaNameDifferentToUpdate, Boolean isDiplomaNameinEnglishToUpdate, String nameonDeanLetterDocumentToUpdate, Boolean isDeanLetterDifferentToUpdate, Boolean isDeanLetterNameinEnglishToUpdate, Boolean isFinalTranscriptRequired, String nameonFinalTranscriptDocumentToUpdate, Boolean isFinalMedicalTranscriptDifferentToUpdate, Boolean isFinalMedicalTranscriptinEnglishToUpdate, Date dateonDeanLetterDocumentToUpdate, Boolean showExamRegActionButtonToUpdate ,Boolean reSubmitAppforCert){		
			contactId = contactIdToUpdate;
			isDeanLetter = isDeanLetterToUpdate;
			nameonDiplomaDocument = nameonDiplomaDocumentToUpdate;
			isDiplomaNameDifferent = isDiplomaNameDifferentToUpdate;
			isDiplomaNameinEnglish =isDiplomaNameinEnglishToUpdate;			
			nameonDeanLetterDocument = nameonDeanLetterDocumentToUpdate;
			isDeanLetterDifferent =isDeanLetterDifferentToUpdate;
			isDeanLetterNameinEnglish =isDeanLetterNameinEnglishToUpdate;
            isFinalTranscriptRequired = isFinalTranscriptRequired;
			nameonFinalTranscriptDocument = nameonFinalTranscriptDocumentToUpdate;
			isFinalMedicalTranscriptDifferent = isFinalMedicalTranscriptDifferentToUpdate;
			isFinalMedicalTranscriptinEnglish = isFinalMedicalTranscriptinEnglishToUpdate;
			dateonDeanLetterDocument =dateonDeanLetterDocumentToUpdate;
            showExamRegActionButton = showExamRegActionButtonToUpdate;
            reSubmitFromAppForCert = reSubmitAppforCert;
		}
    }
    public class TcredObjWrapper {
        @auraenabled public List < Transfer_Credit__c > tcsToUpsert { get; set; }
        @auraenabled public Set<String> tcDelStagingId { get; set; }

        public TcredObjWrapper (List < Transfer_Credit__c > tcsToUpserts, Set<String> tcDelStagingIds){
            tcsToUpsert = tcsToUpserts;
            tcDelStagingId = tcDelStagingIds;
        }
    
    }
    public class AssetObjctWrapper {
        @auraenabled public Set < String > stagingIds { get; set; }
        @auraenabled public List < String > allAssetSet { get; set; }
        @auraenabled public Set < String > allAssetId { get; set; }
        @auraenabled public List < Asset > assetsToUpdate { get; set; }

        public AssetObjctWrapper (Set < String > stagingIdsToUpdate, List < String > allAssetSetToUpdate, Set < String > allAssetIdToUpdate, List < Asset > assetsListToUpdate ){
            stagingIds = stagingIdsToUpdate;
            allAssetSet = allAssetSetToUpdate;
            allAssetId = allAssetIdToUpdate;
            assetsToUpdate = assetsListToUpdate;
        }
    }
    /**
     * Created by Femi
     * Method Name: deansLetterOrFinalDiplomaError
     * Purpose : Method to check whether the error message should be shown or not
     * Return Type : Boolean
     */
    @AuraEnabled(cacheable = true)
    public static Boolean deansLetterOrFinalDiplomaError() {
        Id contactId = retrieveCurrentContactId();
        List<Asset> deanLetterList = [SELECT id FROM Asset where contactId =:contactId AND type__c =:Constants.ASSET_TYPE_DEAN_LETTER AND status =:Constants.ASSET_STATUS_EXPIRED];
        if(!deanLetterList.isEmpty()){
            List<Asset> assetList = [SELECT id FROM Asset where contactId =:contactId AND ((type__c =:Constants.ASSET_TYPE_DEAN_LETTER AND status =:Constants.ASSET_STATUS_ACCEPTED) OR (type__c =:Constants.ASSET_TYPE_FINAL_MED_DIPLOMA AND status =:Constants.ASSET_STATUS_ACCEPTED))];
            if(assetList.isEmpty()){
                return true;
            }
        }
        
        return false;
    }

     
    //method to get the status of Exam Reg-Degree medical school during update my application.
    @AuraEnabled(cacheable = false)
    public static string getContactAssTypeStagingStatus() {

        Id contactId = retrieveCurrentContactId();
        String currentCaseId = getCaseId();
        string returnVal = '';
        List<Contact_Association_Type_Staging__c> getDegMed = new List<Contact_Association_Type_Staging__c>();
        getDegMed = [SELECT Id, Name, Account__c, Contact__r.Id, Case__r.Id, Status__c FROM Contact_Association_Type_Staging__c
        WHERE Contact__r.Id =: contactId
        AND Case__r.Id =: currentCaseId
        AND RecordType.DeveloperName =: Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL_EXAM_REG ];
        if(!getDegMed.isEmpty()){
            returnVal = getDegMed[0].Status__c;
        }
        return returnVal;
    }

    //method to delete the In progress assets on click of previous or cancel button in graduate screen.delDeanLetOrDipDocs
    @AuraEnabled(cacheable = false)
	public static void delDeanLetOrDipDocs(String contactId, String parentCaseId){
		List<Asset> assetList = new List<Asset>();
        List<Asset> assetListToDelete = new List<Asset>();
		Map<String, String> keyAssetMap = new Map<String, String>();
        Set<String> keySet = new Set<String>{
            System.Label.App_for_Cert_DIPLOMA_DOCUMENT,
            System.Label.App_for_Cert_DIPLOMA_NAME_DOCUMENT,
            System.Label.App_for_Cert_DIPLOMA_TRANSLATION_DOCUMENT,
            System.Label.App_for_Cert_DEAN_LETTER_DOCUMENT,
            System.Label.App_for_Cert_DEAN_LETTER_NAME_DOCUMENT,
            System.Label.App_for_Cert_DEAN_LETTER_TRANSLATION_DOCUMENT,
            System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_DOCUMENT,
            System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_NAME_DOCUMENT,
            System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_TRANSLATION_DOCUMENT
        };
        assetList = [SELECT Id, ParentId, Name_on_Document__c, Key__c, Contact_Association_Type_Staging__c FROM Asset WHERE ContactId =: contactId AND Parent_Case__c =: parentCaseId 
                        AND key__c IN: keySet AND IsExpired__c = FALSE AND IsOrphan__c = FALSE AND Contact_Association_Type_Staging__c = null
                        AND status =:constants.ASSET_STATUS_INPROGRESS WITH SECURITY_ENFORCED
        ];
		if(!assetList.isEmpty()){
			for(Asset eachAsset: assetList){
				assetListToDelete.add(eachAsset);
			}
        }
        if(!assetListToDelete.isEmpty()){
            AppForCertController.deleteAffirmationAndUpdateAsset(assetListToDelete);
        }
	}

    // US 10217 - Check if there are any outstanding Enrollment Re-verification cases
    public static List<Case> studentUpdateERVCase(SET<Id> ervCaseIdSet) {
        List<Case> newERVCaseList        =   new List<Case>();
        if(!ervCaseIdSet.isEmpty()) {
            Id ervRecordTypeId          =   Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_REVERIFICATION).getRecordTypeId();
            List<Case> ervCaseList      =   [SELECT Id, Internal_Status__c FROM Case 
                                                    WHERE RecordTypeId =: ervRecordTypeId 
                                                    AND Id =: ervCaseIdSet
                                                    AND Internal_Status__c !=: Constants.CASE_STATUS_ENROLLMENT_VERIFIED
                                                    WITH SECURITY_ENFORCED];
            for(Case ervCase : ervCaseList) {
                Case ervCaseRec      =    new Case();
                ervCaseRec.Id        =    ervCase.Id;
                ervCaseRec.Internal_Status__c = Constants.CASE_STATUS_CLOSED_SCHOOL_CHANGED;
                ervCaseRec.Verification_Status__c=null;
                newERVCaseList.add(ervCaseRec);
            }
        }
        return newERVCaseList;
    }

    // US 10217 - Check if there are any outstanding EPEx requests
    public static List<Case> studentUpdateEpexCase(SET<Id> examRegCaseIdSet) {        
        List<Case> newEpexCaseList          =   new List<Case>();
        List<Case> newCombineEpexCaseList 	= 	new List<Case> ();
        if(!examRegCaseIdSet.isEmpty()) {
            SET<Id> evParentIdSet        =   new SET<Id>();
            Id epexRecordTypeId          =   Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD).getRecordTypeId();
            List<Case> epexCaseList      =   [SELECT Id, ContactId, ParentId, Enrollment_Verification_Parent__c, Internal_Status__c FROM Case 
                                                    WHERE RecordTypeId =: epexRecordTypeId 
                                                    AND ParentId =: examRegCaseIdSet
                                                    AND (Internal_Status__c !=: Constants.CASE_STATUS_PENDING_CIBIS
                                                    AND Internal_Status__c !=: Constants.CASE_STATUS_ACCEPTED
                                                    AND Internal_Status__c !=: Constants.CASE_STATUS_REJECTED) 
                                                    WITH SECURITY_ENFORCED];
            for(Case epexCase : epexCaseList) {
                Case epexCaseObj    =    new Case();
                epexCaseObj.Id      =    epexCase.Id;
                epexCaseObj.Internal_Status__c  =    Constants.CASE_STATUS_REJECTED;
                newEpexCaseList.add(epexCaseObj);
                // Enrollment Verification case 
                if(epexCase.Enrollment_Verification_Parent__c != null) {
                    evParentIdSet.add(epexCase.Enrollment_Verification_Parent__c);
                }
            }
            newCombineEpexCaseList.addAll(newEpexCaseList);
            // Enrollment Verification case
            List<Case> newEVCaseList = AppForCertController.studentUpdateEVCase(evParentIdSet);
            newCombineEpexCaseList.addAll(newEVCaseList);
        }
        return newCombineEpexCaseList;
    }
    //to tie child asset to parent asset 
	@AuraEnabled
	public static void updateParentId(String parentAssetId, String childAssetId) {
		if(childAssetId != null){
			Asset asst = new Asset();
			asst.Id = childAssetId;
			asst.parentId = parentAssetId;
			if (Asset.SObjectType.getDescribe().isUpdateable()) {
				UPDATE asst;
			}
		}
    }
    
    //To get parent id based on key value
	public static string getParentAssetId(String contactId, String key) {
        String parentId = '';
		Map<String, String> keyAssetMap = new Map<String, String>();
		Set<String> keySet = new Set<String> {
			System.Label.App_for_Cert_DIPLOMA_DOCUMENT,
			System.Label.App_for_Cert_DIPLOMA_NAME_DOCUMENT,
			System.Label.App_for_Cert_DIPLOMA_TRANSLATION_DOCUMENT,
			System.Label.App_for_Cert_DEAN_LETTER_DOCUMENT,
			System.Label.App_for_Cert_DEAN_LETTER_NAME_DOCUMENT,
			System.Label.App_for_Cert_DEAN_LETTER_TRANSLATION_DOCUMENT,
			System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_DOCUMENT,
			System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_NAME_DOCUMENT,
			System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_TRANSLATION_DOCUMENT
		};
		for(Asset assetRec : [SELECT Id, Key__c FROM Asset WHERE Key__c IN :keySet AND Status =:Constants.ASSET_STATUS_IN_PROGRESS AND ContactId =:contactId WITH SECURITY_ENFORCED]){
			keyAssetMap.put(assetRec.Key__c, assetRec.Id);
        }
        if(keyAssetMap.containsKey(System.Label.App_for_Cert_DIPLOMA_DOCUMENT) && (key == System.Label.App_for_Cert_DIPLOMA_NAME_DOCUMENT || key == System.Label.App_for_Cert_DIPLOMA_TRANSLATION_DOCUMENT)){
            parentId = keyAssetMap.get(System.Label.App_for_Cert_DIPLOMA_DOCUMENT);
        }
        if(keyAssetMap.containsKey(System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_DOCUMENT) && (key == System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_NAME_DOCUMENT || key == System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_TRANSLATION_DOCUMENT)){
            parentId = keyAssetMap.get(System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_DOCUMENT);
        }
        if(keyAssetMap.containsKey(System.Label.App_for_Cert_DEAN_LETTER_DOCUMENT) && (key == System.Label.App_for_Cert_DEAN_LETTER_NAME_DOCUMENT || key == System.Label.App_for_Cert_DEAN_LETTER_TRANSLATION_DOCUMENT)){
            parentId = keyAssetMap.get(System.Label.App_for_Cert_DEAN_LETTER_DOCUMENT);
        }
        return parentId;
    }
    
    @AuraEnabled
	public static String retrievePMLId(String contactId, String caseId) {
		List<Asset> assetList = new List<Asset> ();
		if (Asset.SObjectType.getDescribe().isAccessible()) {
			assetList = [SELECT id FROM Asset where contactId =: contactId AND Case__c =: caseId AND Name =: Constants.ASSET_TYPE_PRE_MED_LETTER AND status =: Constants.ASSET_STATUS_IN_PROGRESS ORDER BY CreatedDate DESC];
		}
		String assetId = null;
		if (!assetList.isEmpty()) {
			assetId = assetList[0].id;
			Asset a = new Asset();
			a.Id = assetId;
			a.key__c = Constants.ASSET_TYPE_PRE_MED_LETTER_DOCUMENT;
			if (Asset.SObjectType.getDescribe().isUpdateable()) {
				update a;
			}
		}
		return assetId;
    }
    
    @AuraEnabled
	public static String markPmlAssetsForDeletion(String contactId, String caseId){
		List<String> assetTypeList = new List<String>();
		assetTypeList.add(Constants.ASSET_TYPE_PRE_MED_LETTER);
		assetTypeList.add(Constants.ASSET_TYPE_TRANSLATION);
		assetTypeList.add(Constants.ASSET_TYPE_NAME_DOC);
        List<Asset> assetList = new List<Asset>();
		if(Asset.SObjectType.getDescribe().isAccessible()){
			assetList = [SELECT id FROM Asset WHERE Parent_Case__c =: caseId AND Contact_Association_Type_Staging__c = null AND contactId =: contactId AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION AND type__c IN: assetTypeList];
		}
		List<RecordType> recordTypeList = new List<RecordType> ();
		if(RecordType.SObjectType.getDescribe().isAccessible()){
			recordTypeList = [SELECT Id, Name FROM RecordType WHERE DeveloperName =: Constants.ASSET_RECORD_TYPE_MARKED_FOR_DELETION AND SObjectType = 'Asset'];
		}
		if(recordTypeList.size() == 0){
			throw new CommunityException('Could not find record type named Marked for Deletion for Asset.');
		}
		RecordType assetMarkedForDeletionRT = recordTypeList[0];
		if(!assetList.isEmpty()){
			for(Asset asst: assetList){
                asst.Parent_Case__c = null;
				asst.case__c = null;
				asst.status = constants.ASSET_STATUS_MARKED_FOR_DELETION;
				asst.RecordTypeId = assetMarkedForDeletionRT.Id;
			}
			update assetList;
		}
		return 'true';
    }
    // Purpose To retrieve latest uploaded PML Translation Asset's id
	@AuraEnabled
	public static String retrievePmlTranslationId(String contactId, String caseId) {
		List<Asset> assetList = [SELECT id, Key__c, Parent_Key__c FROM Asset where contactId =: contactId AND Case__c =: caseId AND Name =: Constants.ASSET_TYPE_PRE_MED_LETTER_TRANS 
			AND status =: Constants.ASSET_STATUS_IN_PROGRESS WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC
		];
		String assetId = null;
		if (!assetList.isEmpty()) {
			assetId = assetList[0].id;
			assetList[0].Key__c = Constants.ASSET_TYPE_PRE_MED_LETTER_TRANSLATION;
			assetList[0].Parent_Key__c = Constants.ASSET_TYPE_PRE_MED_LETTER_DOCUMENT;
			if (Asset.SObjectType.getDescribe().isUpdateable()) {
				UPDATE assetList[0];
			}
		}
		return assetId;
    }
    
    // Purpose To retrieve latest uploaded Name Documentation Asset's id
	@AuraEnabled
	public static String retrievePmlNameDocId(String contactId, String caseId) {
		List<Asset> assetList = [SELECT id, Key__c, Parent_Key__c FROM Asset where contactId =: contactId AND Case__c =: caseId AND Name =: Constants.ASSET_TYPE_NAME_DOC AND status =: Constants.ASSET_STATUS_IN_PROGRESS WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
		String assetId = null;
		if (!assetList.isEmpty()) {
            assetId = assetList[0].id;
            if(String.isBlank(assetList[0].Key__c)){
                assetList[0].Key__c = Constants.ASSET_TYPE_PRE_MED_LETTER_NAME;
                assetList[0].Parent_Key__c = 'Pre-Med Letter Document';
                if (Asset.SObjectType.getDescribe().isUpdateable()) {
                    UPDATE assetList[0];
                }
            }
		}
		return assetId;
    }
    
    //method to list return the rejected TCT doc and other related docs in appforcert
    @AuraEnabled
	public static List<AppForCertHelper.OtherSchoolObjWrapper> getOtherInstitutionConAssocType(){
		Id contactId = retrieveCurrentContactId();
        String caseId = getCaseId();
		List<AppForCertHelper.OtherSchoolObjWrapper> fetchedValuesToReturn = new List<AppForCertHelper.OtherSchoolObjWrapper>();
        List<Contact_Association_Type__c> medicalschoolsList = new List<Contact_Association_Type__c>([SELECT Id, Case__c, Case__r.Internal_Status__c, Account__c, Account_Name__c, School_Program__c, Student_ID__c, Number_of_Years_Attended__c, Specialty__c, Start_Date__c, End_Date__c, Start_Month__c, Start_Year__c, End_Month__c, End_Year__c, Transfer_Credit_to_Degree_School__c, (SELECT Id, To_School__c, From_School__c, Transfer_Credit_Course__c, Transfer_Credit_Grade__c, Course_Outcome__c, Credits_Earned_Month__c, Credits_Earned_Year__c FROM Transfer_Credits__r ORDER BY Name ASC), (SELECT Id, Azure_Storage_URL__c, Document_is_not_in_English__c, Name_on_Document__c, Name_on_Document_is_Different__c, Type__c, Key__c, Parent_Key__c, ParentId FROM Assets__r WHERE Asset.status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION)
            FROM Contact_Association_Type__c
            WHERE Contact__c =: contactId AND recordType.DeveloperName =: Constants.CONASCTYPESTG_RECORD_TYPE_OTHER_INSTITUTION
            WITH SECURITY_ENFORCED ORDER BY createdDate ASC
        ]);
        for(Contact_Association_Type__c tempconAssocStag: medicalschoolsList){
            String tempRecordIdVal = tempconAssocStag.Id;
            String tempOtherSchool = tempconAssocStag.Account_Name__c;
            String tempnumberOfYearsAttended;
            if(tempconAssocStag.Number_of_Years_Attended__c != null){
                tempnumberOfYearsAttended = String.valueOf(tempconAssocStag.Number_of_Years_Attended__c);
            }else{
                tempnumberOfYearsAttended = '';
            }
            String tempOtherSchoolId = tempconAssocStag.Account__c;
            String tempSchoolProgram = tempconAssocStag.School_Program__c;
            String tempStudentId = tempconAssocStag.Student_ID__c;
            String tempSpecialty = tempconAssocStag.Specialty__c;
            String tempFromDate;
            if(tempconAssocStag.Start_Date__c != null){
                tempFromDate = String.valueOf(DateTime.newInstance(tempconAssocStag.Start_Date__c.year(), tempconAssocStag.Start_Date__c.month(), tempconAssocStag.Start_Date__c.day()).format(Constants.DATE_FORMAT));
            }else{
                tempFromDate = '';
            }
            String tempEndDate;
            if(tempconAssocStag.End_Date__c != null){
                tempEndDate = String.valueOf(DateTime.newInstance(tempconAssocStag.End_Date__c.year(), tempconAssocStag.End_Date__c.month(), tempconAssocStag.End_Date__c.day()).format(Constants.DATE_FORMAT));
            }else{
                tempEndDate = '';
            }
            String tempStartMonth = tempconAssocStag.Start_Month__c;
            String tempStartYear = tempconAssocStag.Start_Year__c;
            String tempEndMonth = tempconAssocStag.End_Month__c;
            String tempEndYear = tempconAssocStag.End_Year__c;
            String caseInternalStatus = tempconAssocStag.Case__r.Internal_Status__c;
            String tempTransferCreditsCheckbox = String.valueOf(tempconAssocStag.Transfer_Credit_to_Degree_School__c);            
            List<AppForCertHelper.TcObjWrapper> tcObjList = new List<AppForCertHelper.TcObjWrapper>();
            tcObjList = AppForCertController.getOtherInstitutionConAssocTypeRefactorMethod(tempconAssocStag, tempOtherSchoolId);
            List<AppForCertHelper.AssetObjWrapper> assetObjList = new List<AppForCertHelper.AssetObjWrapper>();
            assetObjList = AppForCertController.getOtherInstitutionConAssocTypeRefactorAssetList(tempconAssocStag);
            AppForCertHelper.OtherSchoolObjWrapper tempJsObj;
            tempJsObj = new AppForCertHelper.OtherSchoolObjWrapper(tempRecordIdVal, tempOtherSchool, tempnumberOfYearsAttended, tempOtherSchoolId, tempSchoolProgram, tempStudentId, tempSpecialty, tempFromDate, tempEndDate, tempStartMonth, tempStartYear, tempEndMonth, tempEndYear, tempTransferCreditsCheckbox, tcObjList, assetObjList, 'Contact_Association_Type__c', caseInternalStatus);
            tempJsObj.numberOfYearsAttended = tempnumberOfYearsAttended;
            fetchedValuesToReturn.add(tempJsObj);
		}
		return fetchedValuesToReturn;
    }
    // Checking Cancelled / Rejected App For Cert is there or not
    @AuraEnabled
    public Static Boolean checkAppForCertStatus(String recordTypeName){
        Boolean rejectedAppForCert = false;
        Id contactId = AppForCertHelper.retrieveCurrentContactId();
        string caseId = AppForCertHelper.getCaseId();
        List<Contact_Association_Type_Staging__c> tempCatsList = new List<Contact_Association_Type_Staging__c>();
        tempCatsList = [SELECT Id, Name, Account__c, Parent_Case__c, Parent_Case__r.Id, Contact__r.Id, Case__r.Id, Status__c, Is_Reopened_Exam_Reg__c, RecordType.Name, RecordType.DeveloperName 
            FROM Contact_Association_Type_Staging__c
            WHERE Contact__r.Id =: contactId
            AND Parent_Case__r.Id =: caseId
            AND RecordType.DeveloperName =: recordTypeName WITH SECURITY_ENFORCED
        ];
        List<Case> cancelledAppForCerList = [SELECT Id, Internal_Status__c FROM Case WHERE recordType.DeveloperName =: Constants.CASE_RECORD_TYPE_APP_FOR_CERT AND ContactId =: contactId AND Id !=: caseId WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
        if(!cancelledAppForCerList.isEmpty() && cancelledAppForCerList[0].Internal_Status__c == Constants.CASE_STATUS_CANCELLED){      
            List<Contact_Association_Type_Staging__c> catsList = new List<Contact_Association_Type_Staging__c>([SELECT Id,Case__c,Parent_Case__c,Case__r.Internal_Status__c, Parent_Case__r.Internal_Status__c, Account__c, Account_Name__c, School_Program__c, Student_ID__c, Number_of_Years_Attended__c, Specialty__c, Start_Date__c, End_Date__c, Start_Month__c, Start_Year__c, End_Month__c, End_Year__c, Transfer_Credit_to_Degree_School__c, (SELECT Id, To_School__c, From_School__c, Transfer_Credit_Course__c, Transfer_Credit_Grade__c, Course_Outcome__c, Credits_Earned_Month__c, Credits_Earned_Year__c FROM Transfer_Credits__r ORDER BY Name ASC), (SELECT Id, Document_is_not_in_English__c, Name_on_Document__c, Name_on_Document_is_Different__c, Type__c, Key__c, Parent_Key__c, ParentId FROM Assets__r WHERE Asset.status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION)
                FROM Contact_Association_Type_Staging__c
                WHERE Contact__c =: contactId AND Parent_Case__c =: cancelledAppForCerList[0].Id AND recordType.DeveloperName =: recordTypeName WITH SECURITY_ENFORCED
                ORDER BY createdDate DESC
            ]);
            if(!catsList.isEmpty() && (catsList[0].Case__r.Internal_Status__c == Constants.CASE_STATUS_CV_REJECTED || catsList[0].Case__r.Internal_Status__c == Constants.CASE_STATUS_CANCELLED)){
                rejectedAppForCert = true;
            }
        }else{            
            List<Contact_Association_Type__c> medicalschoolsList = new List<Contact_Association_Type__c>([SELECT Id,Case__c,Parent_Case__c,Case__r.Internal_Status__c, Parent_Case__r.Internal_Status__c, Account__c, Account_Name__c, School_Program__c, Student_ID__c, Number_of_Years_Attended__c, Specialty__c, Start_Date__c, End_Date__c, Start_Month__c, Start_Year__c, End_Month__c, End_Year__c, Transfer_Credit_to_Degree_School__c, (SELECT Id, To_School__c, From_School__c, Transfer_Credit_Course__c, Transfer_Credit_Grade__c, Course_Outcome__c, Credits_Earned_Month__c, Credits_Earned_Year__c FROM Transfer_Credits__r ORDER BY Name ASC), (SELECT Id, Document_is_not_in_English__c, Name_on_Document__c, Name_on_Document_is_Different__c, Type__c, Key__c, Parent_Key__c, ParentId FROM Assets__r WHERE Asset.status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION)
                FROM Contact_Association_Type__c
                WHERE Contact__c =: contactId AND recordType.DeveloperName =: recordTypeName WITH SECURITY_ENFORCED
                ORDER BY createdDate Desc
            ]);
            if(tempCatsList.isEmpty() && !medicalschoolsList.isEmpty() && medicalschoolsList[0].Parent_Case__r.Internal_Status__c == Constants.CASE_STATUS_REJECTED){
                rejectedAppForCert = true;
            }
        }        
        return rejectedAppForCert;
    }    
   //Method to get all values for Degree school change in Deficiency screen
	@AuraEnabled(Cacheable = true)
	public static Map<string, string> getSelectedValuesPart() {
		Id contactId = retrieveCurrentContactId();
		Boolean showExamRegActionButton = false;
		String contactStatus = [SELECT School_Enrollment_Status__c
			FROM Contact
			WHERE id =: contactId
		].School_Enrollment_Status__c;
		Map<String, String> valuesToReturn = new Map<String, String> ();
		List<case>newCases = [SELECT id FROM Case WHERE recordType.DeveloperName =: Constants.CASE_RECORD_TYPE_APP_FOR_CERT
				AND ContactId =: contactId
				AND Case_Status__c !=: Constants.CASE_STATUS_REJECTED
				AND Case_Status__c !=: Constants.CASE_STATUS_EXPIRED WITH SECURITY_ENFORCED
			];
		//Code added for month and year by Shailaja. Date format stories. 9/11/2020
		if (!newCases.isEmpty() && showExamRegActionButton == false) {
			List<Contact_Association_Type_Staging__c > existingConAssoStagingObjList = [SELECT id, Status__c, Number_of_Years_Attended__c, Account__c, Degree_Title__c, Account_Name__c,
				Start_Date__c, End_Date__c, Graduation_Year__c, Graduation_Month__c, Degree_Issue_Date__c, School_Program__c, Student_ID__c, Specialty__c,
				Start_Month__c, Start_Year__c, End_Year__c, End_Month__c, Degree_Issue_Month__c, Degree_Issue_Year__c
				FROM Contact_Association_Type_Staging__c
				WHERE recordType.DeveloperName =: Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL
				AND Case__c =: newCases[0].id WITH SECURITY_ENFORCED
			];
			if (String.valueOf(existingConAssoStagingObjList[0].Status__c) == '' || String.valueOf(existingConAssoStagingObjList[0].Status__c) == null) {
				valuesToReturn.put('Status__c', contactStatus);
			} else {
				valuesToReturn.put('Status__c', String.valueOf(existingConAssoStagingObjList[0].Status__c));
			}
			valuesToReturn.put('Account__c', String.valueOf(existingConAssoStagingObjList[0].Account__c));
			valuesToReturn.put('Number_of_Years_Attended__c', String.valueOf(existingConAssoStagingObjList[0].Number_of_Years_Attended__c));
			valuesToReturn.put('Degree_Title__c', String.valueOf(existingConAssoStagingObjList[0].Degree_Title__c));
			valuesToReturn.put('Account_Name__c', String.valueOf(existingConAssoStagingObjList[0].Account_Name__c));
			valuesToReturn.put('Start_Date__c', String.valueOf(existingConAssoStagingObjList[0].Start_Date__c));
			valuesToReturn.put('End_Date__c', String.valueOf(existingConAssoStagingObjList[0].End_Date__c));
			valuesToReturn.put('Degree_Issue_Date__c', String.valueOf(existingConAssoStagingObjList[0].Degree_Issue_Date__c));
			valuesToReturn.put('School_Program__c', String.valueOf(existingConAssoStagingObjList[0].School_Program__c));
			valuesToReturn.put('Student_ID__c', String.valueOf(existingConAssoStagingObjList[0].Student_ID__c));
			valuesToReturn.put('Specialty__c', String.valueOf(existingConAssoStagingObjList[0].Specialty__c));
			valuesToReturn.put('Graduation_Year__c', String.valueOf(existingConAssoStagingObjList[0].Graduation_Year__c));
			valuesToReturn.put('Graduation_Month__c', String.valueOf(existingConAssoStagingObjList[0].Graduation_Month__c));
			//Code added by Shailaja for new fields.
			valuesToReturn.put('Start_Month__c', String.valueOf(existingConAssoStagingObjList[0].Start_Month__c));
			valuesToReturn.put('Start_Year__c', String.valueOf(existingConAssoStagingObjList[0].Start_Year__c));
			valuesToReturn.put('End_Month__c', String.valueOf(existingConAssoStagingObjList[0].End_Month__c));
			valuesToReturn.put('End_Year__c', String.valueOf(existingConAssoStagingObjList[0].End_Year__c));
			valuesToReturn.put('Degree_Issue_Month__c', String.valueOf(existingConAssoStagingObjList[0].Degree_Issue_Month__c));
			valuesToReturn.put('Degree_Issue_Year__c', String.valueOf(existingConAssoStagingObjList[0].Degree_Issue_Year__c));
		} else {
			valuesToReturn = AppForCertController.getSelectedValuesRefactorContinue(showExamRegActionButton, newCases, contactStatus);
		}
		return valuesToReturn;
    }
    
    //get degree change list
	@AuraEnabled(Cacheable = false)
	public static List<Contact_Association_Type_Staging__c> getAssetsDegreeChangeList(Boolean isExamReOpened) {
		Id contactId = retrieveCurrentContactId();
		Id caseId = getCaseId();		
		List<Contact_Association_Type_Staging__c > degreeList = new List<Contact_Association_Type_Staging__c > ();
		if (isExamReOpened) {
			degreeList = [SELECT Id, IsDeanLetter__c, Account__r.Is_Final_Transcript_Required__c
				FROM Contact_Association_Type_Staging__c
				WHERE Contact__c =: contactId
				AND recordType.DeveloperName =: Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL
				AND Case__c =: caseId
				AND Is_Reopened_Exam_Reg__c = TRUE WITH SECURITY_ENFORCED
			];
		} else {
			degreeList = [SELECT Id, IsDeanLetter__c, Account__r.Is_Final_Transcript_Required__c
				FROM Contact_Association_Type_Staging__c
				WHERE Contact__c =: contactId
				AND recordType.DeveloperName =: Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL
				AND Case__c =: caseId
				AND Is_Reopened_Exam_Reg__c = FALSE WITH SECURITY_ENFORCED
			];
		}
		return degreeList;
    }
    
    //To get degree change Records for Incomplete Processing
	public static Map<String, String> getDegIncompleteCaseProc() {
		Map<String, String> returnValue = new Map<String, String> ();
		Boolean isExamReOpened = checkExamReopenedCase();
		List<Contact_Association_Type_Staging__c> degMeDSchoolRec = AppForCertController.getIncompleteCaseProcessingRFCATS(isExamReOpened);
		List<Affirmation__c> afmList = new List<Affirmation__c> ();		
		if (!degMeDSchoolRec.isEmpty()) {
			Id degMedSchoolId = degMeDSchoolRec[0].Id;
			afmList = getIncDegreeRFAffirmation(isExamReOpened, degMedSchoolId);			
			if (!afmList.isEmpty()) {
				returnValue = AppForCertController.getSelectedValues(false);
                returnValue.put('degreeSchool','Yes');
                returnValue.put('comment',afmList[0].Comments__c);
			}
		}
		return returnValue;
	}

    //Method to get Degree school change Affirmation
    @AuraEnabled(Cacheable = false)
    public static List<Affirmation__c> getIncDegreeRFAffirmation(Boolean isExamReOpened, Id degMedSchoolId) {
        List<Affirmation__c> afmList = new List<Affirmation__c>();
        String recordtypeCVID = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get(Constants.AFFIRMATION_RECORD_TYPE_DEGREE_SCHOOL).getRecordTypeId();
        if (isExamReOpened) {
            afmList = [SELECT Id, Asset__c, Degree_School_Change_Status__c, RecordTypeId, Contact_Association_Type_Staging__c,Comments__c
                from Affirmation__c where Contact_Association_Type_Staging__c =: degMedSchoolId
                and Degree_School_Change_Status__c =: Constants.CASE_STATUS and recordtypeId =: recordtypeCVID
                and Asset__r.IsOrphan__c = False and Asset__r.Is_Expired_Exam_Reg__c = False WITH SECURITY_ENFORCED
            ];
        } else {
            afmList = [SELECT Id, Asset__c, Degree_School_Change_Status__c, RecordTypeId, Contact_Association_Type_Staging__c,Comments__c
                from Affirmation__c where Contact_Association_Type_Staging__c =: degMedSchoolId
                and Degree_School_Change_Status__c =: Constants.CASE_STATUS and recordtypeId =: recordtypeCVID
                and Asset__r.IsOrphan__c = False and Asset__r.IsExpired__c = False WITH SECURITY_ENFORCED
            ];
        }
        return afmList;
    }
    //Method to update incomplete case status for deficiency screen
    public static void updateIncompleteCaseStatus(String caseId) {
        Group g = [SELECT Id, name, Group.DeveloperName FROM Group
                    WHERE Type = 'Queue'
                    and Group.DeveloperName =: Constants.QUEUE_APP_FOR_CERT
                ];
        Case csToUpdate = new
        case (Id = caseId);
        csToUpdate.Internal_Status__c = Constants.CASE_STATUS_RESUBMITTED;
        csToUpdate.OwnerId = g.Id;
        if(Case.SObjectType.getDescribe().isAccessible() && Schema.sObjectType.Case.isUpdateable()){
            update csToUpdate;
        }
    }
    // Method to create assets for incomplete case
	@AuraEnabled	
    public static Map<String, Map<String, String>> createAssetForInc(String assetId,String key) {	 
        String contactId = AppForCertController.getContactId();
        String newval = assetId.replace('"','');	
        List<Asset> existingAssetList = new List<Asset>();
        Map<String, Map<String, String>> returnValMapFinal = new Map<String, Map<String, String>> ();
        if (!String.isBlank(newval)) {
            existingAssetList = [Select Id, Name, Type__c, Status, Case__c, Key__c, Parent_Key__c, ParentId, ContactId,
            Contact_Association_Type_Staging__c, RecordTypeId, Document_is_not_in_English__c,
            Name_on_Document__c, Name_on_Document_is_Different__c
            from Asset where Id =: newval
            AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION
           ];
        }
        Asset newAsset;    
        if (!existingAssetList.isEmpty()) {
            List<Asset> delexistingOrphanAssetList = new List<Asset>();
            delexistingOrphanAssetList = [Select Id,status from Asset where Name =: existingAssetList[0].Name and Case__c =: existingAssetList[0].Case__c
            and Contact_Association_Type_Staging__c =: existingAssetList[0].Contact_Association_Type_Staging__c
            and RecordTypeId =: existingAssetList[0].RecordTypeId
            and IsOrphan__c = True
            AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION
        ];

        if (!delexistingOrphanAssetList.isEmpty()) {
            List<Asset> updexistingOrphanAssetList = new List<Asset>();
            for(Asset dec:delexistingOrphanAssetList){
                Asset recAc = new Asset(Id = dec.Id);
                recAc.Case__c = null;
                recAc.Contact_Association_Type_Staging__c =null;
                recAc.Contact_Association_Type__c = null;
                recAc.recordtypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_MARKED_FOR_DELETION).getRecordTypeId();
                recAc.status = constants.ASSET_STATUS_MARKED_FOR_DELETION;
                updexistingOrphanAssetList.add(recAc);
            }
            if (!updexistingOrphanAssetList.isEmpty()) {
                update updexistingOrphanAssetList;
            }				
        }
        newAsset = new Asset(Id = existingAssetList[0].Id);
        newAsset.Key__c = key;
        newAsset.IsOrphan__c = True;
        update newAsset;	
        returnValMapFinal = createAssetForIncRF(existingAssetList[0]);    
    }
    return returnValMapFinal;
}

    // Purpose : Continuation of createAssetForIncompleteCaseProcessing Method to create assets for incomplete case	 
    @AuraEnabled	
    public static Map<String, Map<String, String>> createAssetForIncRF(Asset a) {
        String fileName = '';
        String fileType = '';
        String fileURL = '';
        Map<String, String> assetMap = new Map<String, String> ();
        Map<String, Map<String, String>> returnValMap = new Map<String, Map<String, String>> ();
        assetMap.put('assetId', a.Id);
        assetMap.put('fileName', fileName);
        assetMap.put('fileType', fileType);
        assetMap.put('fileUrl', fileURL);
        assetMap.put('assetNameDoc', a.Name_on_Document__c);
        if (a.Document_is_not_in_English__c) {
            assetMap.put('assetNameDocnotinEnglish', 'Yes');
        } else {
            assetMap.put('assetNameDocnotinEnglish', 'No');
        }
        if (a.Name_on_Document_is_Different__c) {
            assetMap.put('assetNameDocDifferent', 'Yes');
        } else {
            assetMap.put('assetNameDocDifferent', 'No');
        }
        returnValMap.put(a.Contact_Association_Type_Staging__c, assetMap);
        return returnValMap;
    }

    public static void checkForRejectedCat(List<AppForCertHelper.OtherSchoolObjWrapper> wrappedObjList){
		List<String> recordIdValList = new List<String>();
		Map<String,AppForCertHelper.OtherSchoolObjWrapper> catIdentifierMap = new Map<String,AppForCertHelper.OtherSchoolObjWrapper>();
		for(AppForCertHelper.OtherSchoolObjWrapper jsObj: wrappedObjList){
			if(!String.isBlank(jsObj.recordIdVal)){
				recordIdValList.add(jsObj.recordIdVal);
				catIdentifierMap.put(jsObj.recordIdVal,jsObj);
			}
		}
		List<Contact_Association_Type_Staging__c> catsRecordsList = new List<Contact_Association_Type_Staging__c>();
		catsRecordsList = [Select id from Contact_Association_Type_Staging__c where id = :recordIdValList WITH SECURITY_ENFORCED];
		if(catsRecordsList.isEmpty()){
			for(Contact_Association_Type__c eachCatRecord: [Select id,CatIdentifier__c from Contact_Association_Type__c where id = :recordIdValList WITH SECURITY_ENFORCED]){
				AppForCertHelper.OtherSchoolObjWrapper newObj = catIdentifierMap.get(eachCatRecord.Id);
				newObj.recordIdVal = '';
				catIdentifierMap.put(eachCatRecord.Id,newObj);
			}
		}        
    }
    // Update & Upsert process for Other Institute Page
    public static void updateCatsAndAssets(List<Contact_Association_Type_Staging__c> recordsToUpdate, List<Transfer_Credit__c> tcsToUpsert, List<Asset> assetsToUpdate){
		if(!recordsToUpdate.isEmpty() && Schema.sObjectType.Contact_Association_Type_Staging__c.isUpdateable()){
			UPDATE recordsToUpdate;
		}
		if(!tcsToUpsert.isEmpty() && Schema.sObjectType.Transfer_Credit__c.isUpdateable() &&  Schema.sObjectType.Transfer_Credit__c.isCreateable()){
			UPSERT tcsToUpsert;
		}
		if(!assetsToUpdate.isEmpty() && Schema.sObjectType.Asset.isUpdateable()){
			UPDATE assetsToUpdate;
		}
    }
    // Method to delete incomplete case Asset	 
    @AuraEnabled
    public static void cancelIncomAsset(String caseId){	
        Boolean isExamReOpened = checkExamReopenedCase();
        Set<String> delStagingIds = new Set<String>();
        for(Contact_Association_Type_Staging__c co:[Select Id,Case__c from Contact_Association_Type_Staging__c where Case__c =: caseId WITH SECURITY_ENFORCED]){
            delStagingIds.add(co.Id);
        }
        AppForCertController.dltOrphanedAssets(delStagingIds, isExamReOpened);                   
    }
    // Get Graduate Rejected and Cancelled Documents FMD & FMST
    @AuraEnabled
    public static List<Asset> getGraduateRejectedDocs(String recordTypeName, String assetName){
        List<Asset> rejAppForCertAssetIds = new List<Asset>();
        Id contactId = retrieveCurrentContactId();
        List<Case> appForCertCancelledCase = new List<Case>();
        Set<String> keySet = new Set<String>();
        appForCertCancelledCase = [SELECT Id FROM Case Where ContactId =: contactId AND recordType.DeveloperName =: constants.CASE_RECORD_TYPE_APP_FOR_CERT AND (Internal_Status__c=:Constants.CASE_STATUS_CANCELLED  OR Internal_Status__c =: Constants.CASE_STATUS_REJECTED) WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
        if(assetName == constants.ASSET_TYPE_FINAL_MED_DIPLOMA){
            keySet = new Set<String>{
                System.Label.App_for_Cert_DIPLOMA_DOCUMENT,
                System.Label.App_for_Cert_DIPLOMA_NAME_DOCUMENT,
                System.Label.App_for_Cert_DIPLOMA_TRANSLATION_DOCUMENT,
                System.Label.App_for_Cert_DEAN_LETTER_DOCUMENT,
                System.Label.App_for_Cert_DEAN_LETTER_NAME_DOCUMENT,
                System.Label.App_for_Cert_DEAN_LETTER_TRANSLATION_DOCUMENT
             };
        }
        if(assetName == constants.ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT){
           keySet = new Set<String>{
                System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_DOCUMENT,
                System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_NAME_DOCUMENT,
                System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_TRANSLATION_DOCUMENT
            };
        } 
        if(!appForCertCancelledCase.isEmpty()){            
            rejAppForCertAssetIds = [SELECT Id, Case__r.Internal_Status__c, Azure_Storage_URL__c, Document_is_not_in_English__c, Name_on_Document__c, Name_on_Document_is_Different__c, Type__c, Key__c, Parent_Key__c, ParentId, status 
            FROM Asset WHERE Parent_Case__c =: appForCertCancelledCase[0].Id
            AND key__c IN: keySet AND (Status =: Constants.CASE_STATUS_REJECTED OR Status =: Constants.CASE_STATUS_CANCELLED)
            AND ContactId =: contactId WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
        }
        return rejAppForCertAssetIds;
    }

    @AuraEnabled
    public static Boolean isStudorGrad(String contactAssociationTypeId){
        List<Contact_Association_Type_Staging__c> medicalSchoolsList = new List<Contact_Association_Type_Staging__c>([SELECT Id,Status__c,Case__c,Case__r.Status
            FROM Contact_Association_Type_Staging__c
            WHERE Id =:contactAssociationTypeId WITH SECURITY_ENFORCED
            ORDER BY createdDate Desc
        ]);
        if(!medicalSchoolsList.isEmpty() && medicalSchoolsList[0].Status__c == Constants.CONASCTYPESTG_STATUS_STUDENT){
            return true;
        }
        return false;
    }
    @AuraEnabled
    public static string deleteCATRecAndAssets(String catsRecordId, String caseId){
        if(catsRecordId != NULL){
            Id conId = retrieveCurrentContactId();
            List<Contact_Association_Type_Staging__c> catRec = new List<Contact_Association_Type_Staging__c>();
            catRec = [SELECT Id FROM Contact_Association_Type_Staging__c WHERE Contact__c =: conId AND Id =: catsRecordId AND Parent_Case__c =: caseId WITH SECURITY_ENFORCED];
            if(!catRec.isEmpty()){
                List<Transfer_Credit__c> transCredit = new List<Transfer_Credit__c>();
                transCredit = [SELECT Id FROM Transfer_Credit__c WHERE Applicant__c =: conId AND Contact_Association_Type_Staging__c =: catsRecordId AND Case__c =: caseId WITH SECURITY_ENFORCED];
                if(!transCredit.isEmpty() && Schema.sObjectType.Transfer_Credit__c.isDeletable()){
                    delete transCredit;
                }
                List<Asset> assetList = new List<Asset>();
                Set<String> nameList = new Set<String>{Constants.ASSET_TYPE_TRANSLATION,Constants.ASSET_TYPE_NAME_DOC,Constants.ASSET_TYPE_TCT};
                assetList = [SELECT Id FROM Asset WHERE Contact_Association_Type_Staging__c =: catsRecordId AND Name IN: nameList WITH SECURITY_ENFORCED];
                if(!assetList.isEmpty()){
                    updateAssetList(assetList);
                }
                if(Schema.sObjectType.Contact_Association_Type_Staging__c.isDeletable()){
                    delete catRec;
                    return 'true';
                }
            }
        }
        return 'true';
    }
    @AuraEnabled
    public static void updateAssetList(List<Asset> assetList){
        List<Asset> assetListToUpdate = new List<Asset>();
        List<Asset> assetTctList = new List<Asset>();
        String recordtypeAssetId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_MARKED_FOR_DELETION).getRecordTypeId();
        assetTctList = [Select Id from Asset where ParentId IN: assetList];
        if(!assetTctList.isEmpty()){
            assetList.addAll(assetTctList);
            Set<Asset> myset = new Set<Asset>();
            myset.addAll(assetList);
            assetList = new List<Asset>();
            assetList.addAll(myset);
        }
        for(Asset eachAsset: assetList){
            eachAsset.Status = constants.ASSET_STATUS_MARKED_FOR_DELETION;
            eachAsset.RecordTypeId = recordtypeAssetId;
            eachAsset.Contact_Association_Type_Staging__c = null;
            eachAsset.Parent_Case__c = null;
            eachAsset.Case__c = null;
            assetListToUpdate.add(eachAsset);
        }
        if(Schema.sObjectType.Asset.isUpdateable()){
            update assetListToUpdate;
        }
    }
    // Delete the Transfer Creditsthe when Checkbox is unchecked
	@AuraEnabled
	public static string deleteUncheckedTCAndAsset(String contactId, String caseId){
		List<Contact_Association_Type_Staging__c> otherMedSchoolList = 
			new List<Contact_Association_Type_Staging__c>([SELECT Id, Transfer_Credit_to_Degree_School__c,
				(SELECT Id FROM Transfer_Credits__r),
				(SELECT Id FROM Assets__r WHERE Asset.status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION)
				FROM Contact_Association_Type_Staging__c
				WHERE Contact__c =: contactId AND
				Case__c =: caseId AND
				recordType.DeveloperName =: Constants.CONASCTYPESTG_RECORD_TYPE_MEDICAL_SCHOOL
				ORDER BY createdDate ASC
			]);
        List<Contact_Association_Type_Staging__c> otherMedSchoolListUpdate = new List<Contact_Association_Type_Staging__c>();
	    List<Transfer_Credit__c> creditsToDel = new List<Transfer_Credit__c>();
		List<Asset> assetsToDel = new List<Asset>();
		List<RecordType> recTypeToDel = [SELECT Id, Name FROM RecordType WHERE DeveloperName =: Constants.ASSET_RECORD_TYPE_MARKED_FOR_DELETION AND SObjectType = 'Asset'];
		RecordType assetMarkedForDeletionRT = recTypeToDel[0];
        if(!otherMedSchoolList.isEmpty()){
            for(Contact_Association_Type_Staging__c tempconAssocStag : otherMedSchoolList){	
                Contact_Association_Type_Staging__c catsRec = new Contact_Association_Type_Staging__c();
                catsRec.Id = tempconAssocStag.Id;
                catsRec.Transfer_Credit_to_Degree_School__c = false;
                otherMedSchoolListUpdate.add(catsRec);
                if(!tempconAssocStag.Transfer_Credits__r.isEmpty()){
                    creditsToDel = AppForCertController.deleteUncheckedTcAndAssetRefactorCont(tempconAssocStag.Transfer_Credits__r);
                }
                if(!tempconAssocStag.Assets__r.isEmpty()){
                    for(Asset a: tempconAssocStag.Assets__r){
                        Asset asst = new Asset();
                        asst.Id = a.Id;
                        asst.case__c = null;
                        asst.status = constants.ASSET_STATUS_MARKED_FOR_DELETION;
                        asst.RecordTypeId = assetMarkedForDeletionRT.Id;
                        assetsToDel.add(asst);
                    }
                }
            }
        }
        updateCATSTransCredDegreeSchool(otherMedSchoolListUpdate);        
		return AppForCertController.deleteUncheckedTcAndAssetRefactor(creditsToDel, assetsToDel);
	}
    @AuraEnabled
	public static void updateCATSTransCredDegreeSchool(List<Contact_Association_Type_Staging__c> otherMedSchoolListUpdate){
		if(!otherMedSchoolListUpdate.isEmpty() && Contact_Association_Type_Staging__c.SObjectType.getDescribe().isUpdateable()){
            UPDATE otherMedSchoolListUpdate;
        }
	}
    // method to update assets Status to mark for deletion
	@AuraEnabled
	public static Boolean markAssetsForDeletionFromUrl(String azureUrl){
		List<Asset> assetsToUpdateList = new List<Asset>();
		List<RecordType> rts = new List<RecordType>();
		if(RecordType.SObjectType.getDescribe().isAccessible()){
			rts = [SELECT Id, Name from RecordType where DeveloperName =: Constants.ASSET_RECORD_TYPE_MARKED_FOR_DELETION AND SObjectType = 'Asset'];
		}
		if(rts.isEmpty()){
			throw new CommunityException('Could not find record type named Marked for Deletion for Asset.');
		}
		RecordType assetMarkedForDeletionRT = rts[0];
		if(Asset.SObjectType.getDescribe().isUpdateable() && azureUrl != null){
			for(Asset a : [SELECT Id, Status FROM Asset WHERE Azure_Storage_URL__c =: azureUrl AND status !=: constants.ASSET_STATUS_REJECTED WITH SECURITY_ENFORCED]){
				a.Status = Constants.ASSET_STATUS_MARKED_FOR_DELETION;
                a.Parent_Case__c = null;
				a.Case__c = null;
				a.Contact_Association_Type_Staging__c = null;
				a.Exam_Registration__c = null;
				a.Exam_Registration_Exam_Type__c = null;
				a.RecordTypeId = assetMarkedForDeletionRT.Id;
				assetsToUpdateList.add(a);
			}
			UPDATE assetsToUpdateList;
		}
		return true;
	}
   // Method to Get Graduate Asset Azure URL
	@AuraEnabled(cacheable = false)
	public static Map<String, String> getGraduateAssetAzureURL(String contactId, String parentCaseId, String contactAssociationStagingId, Boolean isFinalTranscriptRequired){
        Map<String, String> graduateKeyAzureUrlMap = new Map<String, String>();
        String fmdAzureURL = '';
		String fmdNameDocAzureURL = '';
		String fmdTransDocAzureURL = '';
		String fmstAzureURL = '';
		String fmstNameDocAzureURL = '';
		String fmstTransDocAzureURL = '';
		String deanAzureURL = '';
		String deanNameDocAzureURL = '';
		String deanTransDocAzureURL = '';
        Set<String> keySet = new Set<String> {
            System.Label.App_for_Cert_DIPLOMA_DOCUMENT,
            System.Label.App_for_Cert_DIPLOMA_NAME_DOCUMENT,
            System.Label.App_for_Cert_DIPLOMA_TRANSLATION_DOCUMENT,
            System.Label.App_for_Cert_DEAN_LETTER_DOCUMENT,
            System.Label.App_for_Cert_DEAN_LETTER_NAME_DOCUMENT,
            System.Label.App_for_Cert_DEAN_LETTER_TRANSLATION_DOCUMENT,
            System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_DOCUMENT,
            System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_NAME_DOCUMENT,
            System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_TRANSLATION_DOCUMENT
        };
        List<Asset> assetList = new List<Asset>();
        if(String.isNotBlank(contactAssociationStagingId)){
            assetList = [SELECT Id, key__c, Azure_Storage_URL__c FROM Asset WHERE ContactId =: contactId AND Contact_Association_Type_Staging__c =: contactAssociationStagingId AND IsExpired__c = FALSE AND IsOrphan__c = FALSE
				                AND Parent_Case__c =: parentCaseId AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION
                                AND key__c IN: keySet WITH SECURITY_ENFORCED];            
            Contact_Association_Type_Staging__c degMeDSchoolRec = [SELECT Id, Account__r.Is_Final_Transcript_Required__c FROM Contact_Association_Type_Staging__c WHERE Id =: contactAssociationStagingId];
            isFinalTranscriptRequired = degMeDSchoolRec.Account__r.Is_Final_Transcript_Required__c;
        }else{
            assetList = [SELECT Id, key__c, Azure_Storage_URL__c FROM Asset WHERE ContactId =: contactId AND IsExpired__c = FALSE AND IsOrphan__c = FALSE
				                AND Parent_Case__c =: parentCaseId AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION
                                AND key__c IN: keySet WITH SECURITY_ENFORCED];
        }
        if (!assetList.isEmpty()){
            for(Asset assetRow : assetList){
                if(assetRow.key__c == System.Label.App_for_Cert_DIPLOMA_DOCUMENT){
                    fmdAzureURL = assetRow.Azure_Storage_URL__c;
                }
                if(assetRow.key__c == System.Label.App_for_Cert_DIPLOMA_NAME_DOCUMENT){
                    fmdNameDocAzureURL = assetRow.Azure_Storage_URL__c;
                }
                if(assetRow.key__c == System.Label.App_for_Cert_DIPLOMA_TRANSLATION_DOCUMENT){
                    fmdTransDocAzureURL = assetRow.Azure_Storage_URL__c;
                }
                if(assetRow.key__c == System.Label.App_for_Cert_DEAN_LETTER_DOCUMENT){
                    deanAzureURL = assetRow.Azure_Storage_URL__c;
                }
                if(assetRow.key__c == System.Label.App_for_Cert_DEAN_LETTER_NAME_DOCUMENT){
                    deanNameDocAzureURL = assetRow.Azure_Storage_URL__c;
                }
                if(assetRow.key__c == System.Label.App_for_Cert_DEAN_LETTER_TRANSLATION_DOCUMENT){
                    deanTransDocAzureURL = assetRow.Azure_Storage_URL__c;
                }  
            }            
            if(isFinalTranscriptRequired){
                String intakeCATSRecId = getCATSCredIntakeRecId(contactId, parentCaseId);
                if(intakeCATSRecId != ''){
                    List<Asset> intakeAssetList = new List<Asset>();
                    intakeAssetList = [SELECT Id, key__c, Azure_Storage_URL__c FROM Asset WHERE ContactId =: contactId AND Contact_Association_Type_Staging__c =: intakeCATSRecId AND IsExpired__c = FALSE 
                                    AND IsOrphan__c = FALSE
                                    AND Parent_Case__c =: parentCaseId AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION
                                    AND key__c IN: keySet WITH SECURITY_ENFORCED];
                    if (!intakeAssetList.isEmpty()){
                        for(Asset assetRow : intakeAssetList){                            
                            if(assetRow.key__c == System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_DOCUMENT){
                                fmstAzureURL = assetRow.Azure_Storage_URL__c;
                            }
                            if(assetRow.key__c == System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_NAME_DOCUMENT){
                                fmstNameDocAzureURL = assetRow.Azure_Storage_URL__c;
                            }
                            if(assetRow.key__c == System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_TRANSLATION_DOCUMENT){
                                fmstTransDocAzureURL = assetRow.Azure_Storage_URL__c;
                            }                           
                        }
                    }
                }
            }
            graduateKeyAzureUrlMap.put('fmdAzureURL', fmdAzureURL);
            graduateKeyAzureUrlMap.put('fmdNameDocAzureURL', fmdNameDocAzureURL);
            graduateKeyAzureUrlMap.put('fmdTransDocAzureURL', fmdTransDocAzureURL);
            graduateKeyAzureUrlMap.put('fmstAzureURL', fmstAzureURL);
            graduateKeyAzureUrlMap.put('fmstNameDocAzureURL', fmstNameDocAzureURL);
            graduateKeyAzureUrlMap.put('fmstTransDocAzureURL', fmstTransDocAzureURL);
            graduateKeyAzureUrlMap.put('deanAzureURL', deanAzureURL);
            graduateKeyAzureUrlMap.put('deanNameDocAzureURL', deanNameDocAzureURL);
            graduateKeyAzureUrlMap.put('deanTransDocAzureURL', deanTransDocAzureURL);  
        }
        return graduateKeyAzureUrlMap;
    }
    public static Map<Id,Case> cvCaseMapDtl(Map<Id,Case> cvCaseMap,Contact_Association_Type_Staging__c cst,Case cs,Boolean acceptedFMDStatus){
        if((cst.RecordType.DeveloperName == Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL && acceptedFMDStatus == false) 
        || cst.RecordType.DeveloperName == Constants.CONASCTYPE_RECORD_TYPE_OTHER_INSTITUTION 
        || cst.RecordType.DeveloperName == Constants.CONASCTYPESTG_RECORD_TYPE_CREDENTIAL_INTAKE 
        || (cst.RecordType.DeveloperName == Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL_EXAM_REG && acceptedFMDStatus == false)
        || cst.RecordType.DeveloperName == Constants.CONASCTYPESTG_RECORD_TYPE_OTHER_INSTITUTION_EXAM_REG 
        || (cst.RecordType.DeveloperName == Constants.CONASCTYPESTG_RECORD_TYPE_MEDICAL_SCHOOL_EXAM_REG && cst.Transfer_Credit_to_Degree_School__c)
        || (cst.RecordType.DeveloperName == Constants.CONASCTYPE_RECORD_TYPE_MEDICAL_SCHOOL && cst.Transfer_Credit_to_Degree_School__c)){
           cvCaseMap.put(cst.Id,cs);
       }
       return cvCaseMap;
    }
    public static List<Case> cvCasDtl(List<Case> updateCaseList,Contact_Association_Type_Staging__c cst,Case csUPD){
        if(cst.RecordType.DeveloperName == Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL 
        || cst.RecordType.DeveloperName ==Constants.CONASCTYPE_RECORD_TYPE_OTHER_INSTITUTION 
        || cst.RecordType.DeveloperName == Constants.CONASCTYPESTG_RECORD_TYPE_CREDENTIAL_INTAKE 
        || cst.RecordType.DeveloperName ==Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL_EXAM_REG                                      
        || cst.RecordType.DeveloperName ==Constants.CONASCTYPESTG_RECORD_TYPE_OTHER_INSTITUTION_EXAM_REG 
        || (cst.RecordType.DeveloperName ==Constants.CONASCTYPESTG_RECORD_TYPE_MEDICAL_SCHOOL_EXAM_REG && cst.Transfer_Credit_to_Degree_School__c)
        || (cst.RecordType.DeveloperName ==Constants.CONASCTYPE_RECORD_TYPE_MEDICAL_SCHOOL && cst.Transfer_Credit_to_Degree_School__c)){
            updateCaseList.add(csUPD);
        } 
       return updateCaseList;
    }
    // Creating Subcase (CV Case) from Contact Association Type Staging
    public static void creatCVCaseForAppForCert(Boolean showExamRegActionButton, String currentCaseId, String currentContactId){
        Map<Id,Case> cvCaseMap = new Map<Id,Case>();
        List<Contact_Association_Type_Staging__c> cstUpdateList = new List<Contact_Association_Type_Staging__c>();      
        Boolean acceptedFMDStatus = getCATDegMedSchFMDStatus(currentContactId);
        List<Contact_Association_Type_Staging__c> catsList = [SELECT Id, Name, Contact__r.Id, Parent_Case__r.Id, Status__c, RecordType.Name,
                                                                RecordType.DeveloperName, Parent_Case__r.Graduate_affirmation_required__c, 
                                                                Parent_Case__r.Transfer_credit_affirmation_required__c,Transfer_Credit_to_Degree_School__c,
                                                                Case__r.Id,Credential_Type__c,Account__r.Id
                                                                FROM Contact_Association_Type_Staging__c WHERE Contact__r.Id =: currentContactId AND Parent_Case__r.Id =: currentCaseId 
                                                                AND Status__c != 'Student' WITH SECURITY_ENFORCED];
        for(Contact_Association_Type_Staging__c cst : catsList){
            if(cst.Parent_Case__r.Id == cst.Case__r.Id){
                Case cs = new Case();
                cs.RecordTypeId =  Constants.CVRECORDTYPEID;
                cs.Service__c = 'ECFMG_Certification';
                cs.Internal_Status__c = 'New';
                cs.ParentId = cst.Parent_Case__r.Id;
                cs.Entity__c = cst.Account__r.Id;
                cs.Document_Type__c = cst.Credential_Type__c; 
                cs.Document_type_selected_by_applicant__c = cst.Credential_Type__c;                                   
                cvCaseMap = cvCaseMapDtl(cvCaseMap,cst,cs,acceptedFMDStatus);
            }
        }
        if(!cvCaseMap.values().isEmpty() && Case.SObjectType.getDescribe().isCreateable()){
		    insert cvCaseMap.values();
            List<Contact_Association_Type_Staging__c> catsUpdateList = [SELECT Id, Name, Contact__r.Id, Parent_Case__r.Id, Status__c, RecordType.Name,
                                                                            RecordType.DeveloperName, Parent_Case__r.Graduate_affirmation_required__c, 
                                                                            Parent_Case__r.Transfer_credit_affirmation_required__c, Transfer_Credit_to_Degree_School__c,
                                                                            Case__r.Id,Credential_Type__c,Account__r.Id
                                                                            FROM Contact_Association_Type_Staging__c WHERE Id IN:cvCaseMap.keyset() WITH SECURITY_ENFORCED];
            for(Contact_Association_Type_Staging__c cstUpd : catsUpdateList){                               
                Contact_Association_Type_Staging__c cstUpdated = new Contact_Association_Type_Staging__c(Id =cstUpd.Id);							
                cstUpdated.Case__c = cvCaseMap.get(cstUpd.Id).Id;							
                cstUpdateList.add(cstUpdated);
            }
            if(!cstUpdateList.isEmpty() && Contact_Association_Type_Staging__c.SObjectType.getDescribe().isUpdateable()){
                Update cstUpdateList; 
            }  
            updateAssetForCVCase(cvCaseMap,showExamRegActionButton,currentContactId);    
        }
    }
    public static void updateAssetForCVCase(Map<Id,Case> cvCaseMap,Boolean showExamRegActionButton, String currentContactId){
        String currentCaseId = getCaseId();        
        Group cvQueue = [SELECT Id, name, Group.DeveloperName FROM Group WHERE Type = 'Queue' and Group.DeveloperName =: Constants.CASE_QUEUE_CREDENTIAL_REVIEW_QUEUE WITH SECURITY_ENFORCED];
        List<Asset> asstListToUpd = new List<Asset>();
        List<Asset> assetUpdateList = [SELECT Id, RootAssetId, IsExpired__c, Name, Type__c, parentId, Contact_Association_Type_Staging__c,Contact_Association_Type_Staging__r.Case__c FROM Asset WHERE Case__c =: currentCaseId AND
                                        (recordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_CREDENTIAL OR recordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_IDENTITY OR recordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_APP_FOR_CERT)
                                        And Contact_Association_Type_Staging__c IN: cvCaseMap.keyset() AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION WITH SECURITY_ENFORCED];
        for(Asset a: assetUpdateList){
            Asset asstToUpd = new Asset(Id = a.Id);
            asstToUpd.Case__c = a.Contact_Association_Type_Staging__r.Case__c;                
            asstListToUpd.add(asstToUpd);                
        }
        if(!asstListToUpd.isEmpty() && Asset.SObjectType.getDescribe().isUpdateable()){
            Update asstListToUpd; 
        }
        List<Case> updateCaseList = new List<Case>();
        List<Contact_Association_Type_Staging__c> catsUpdatedList = [SELECT Id,RecordType.DeveloperName,Transfer_Credit_to_Degree_School__c, Name, Contact__r.Id, Parent_Case__r.Id, Status__c,Case__r.Id,Credential_Type__c,Account__r.Id,Case__r.Entity__c,Case__r.Document_Type__c,Case__r.Document_type_selected_by_applicant__c
                                                                        FROM Contact_Association_Type_Staging__c WHERE Contact__r.Id =: currentContactId AND Parent_Case__r.Id =: currentCaseId 
                                                                        AND Status__c != 'Student' WITH SECURITY_ENFORCED];
        for(Contact_Association_Type_Staging__c cst : catsUpdatedList){						  
            if(cst.Case__r.Entity__c != cst.Account__r.Id || cst.Case__r.Document_Type__c != cst.Credential_Type__c){
                Case csUPD = new Case(Id =cst.Case__r.Id);
                csUPD.Entity__c = cst.Account__r.Id;
                csUPD.Document_Type__c = cst.Credential_Type__c; 
                csUPD.Document_type_selected_by_applicant__c =cst.Credential_Type__c;
                csUPD.OwnerId = cvQueue.Id;
                csUPD.ECFMG_Portal_Case_Url__c = getECFMGPortalCaseUrl(csUPD.Id);
                updateCaseList = cvCasDtl(updateCaseList,cst,csUPD);                                                                                                           
            }                                                       
        }                         
        if(!updateCaseList.isEmpty()){
            UPDATE updateCaseList;
        }
        createCVCaseForFMSTNotReq(currentContactId,currentCaseId,showExamRegActionButton);
    }
    // Method to create wrapper for Graduate screen in AppForCert process
    public class GraduateOnlyObjWrapper{
        @auraenabled public string contactAssociationTypeStagingId { get; set; }
        @auraenabled public String conAssocTypeStagCredIntakeId { get; set; }
        @auraenabled public string contactId { get; set; }
        @auraenabled public string parentCaseId { get; set; }
        @auraenabled public Boolean isDeanLetter { get; set; }
        @auraenabled public Boolean isFinalTranscriptRequired { get; set; }
        @auraenabled public Date dateonDeanLetterDocument { get; set; }
        @auraenabled public Boolean showExamRegActionButton { get; set; }
        @auraenabled public Boolean reSubmitFromAppForCert { get; set; }
        @auraenabled public list <AppForCertHelper.AssetObjWrapper> assets { get; set; }
        public GraduateOnlyObjWrapper(String catsIdDegMedSCh, String catsIdCredIntake, String contactIdToUpdate, String parentCaseIdUpdate, Boolean isDeanLetterToUpdate, Boolean isFinalTranscriptRequired, Date dateonDeanLetterDocumentToUpdate, Boolean showExamRegActionButtonToUpdate, Boolean reSubmitAppforCert, List<AppForCertHelper.AssetObjWrapper> assetsList){	
			contactAssociationTypeStagingId = catsIdDegMedSCh;
			conAssocTypeStagCredIntakeId = catsIdCredIntake;
			contactId = contactIdToUpdate;
			parentCaseId = parentCaseIdUpdate;
			isDeanLetter =  isDeanLetterToUpdate;			
            isFinalTranscriptRequired = isFinalTranscriptRequired;
			dateonDeanLetterDocument = dateonDeanLetterDocumentToUpdate;
            showExamRegActionButton = showExamRegActionButtonToUpdate;
            reSubmitFromAppForCert = reSubmitAppforCert;
            if (assetsList != null && !assetsList.isEmpty()) {
                assets = new list < AssetObjWrapper > ();
                assets.addAll(assetsList);
            } else {
                assets = null;
            }
		}
    }
    // Purpose : Method to update Parent Asset in child Assets 
	@AuraEnabled
	public static Boolean saveGraduateOnlyRecords(String jsonString, List<String> assetsUrlsList, Boolean couriercheckbox){
        Boolean returnVal = false;
		String contactId;
		String parentCaseId;
        String contactAssociationTypeStagingId;
        String conAssocTypeStagCredIntakeId;
		Boolean isDeanLetter;
		Boolean reSubmitFromAppForCert;
		Date dateonDeanLetterDocument;
		Boolean showExamRegActionButton;
		Boolean isFinalTranscriptRequired;        
        List<AppForCertHelper.GraduateOnlyObjWrapper> objectList = (List<AppForCertHelper.GraduateOnlyObjWrapper>) JSON.deserialize(jsonString, List<AppForCertHelper.GraduateOnlyObjWrapper>.class);
		contactId = objectList[0].contactId;
        parentCaseId = objectList[0].parentCaseId;
        contactAssociationTypeStagingId = objectList[0].contactAssociationTypeStagingId;
        conAssocTypeStagCredIntakeId = objectList[0].conAssocTypeStagCredIntakeId;
		isDeanLetter = objectList[0].isDeanLetter;
		dateonDeanLetterDocument = objectList[0].dateonDeanLetterDocument;
		showExamRegActionButton = objectList[0].showExamRegActionButton;
		reSubmitFromAppForCert = objectList[0].reSubmitFromAppForCert;
		isFinalTranscriptRequired = objectList[0].isFinalTranscriptRequired;
        if(isDeanLetter && dateonDeanLetterDocument == null){
			returnVal = true;
		}else{
            returnVal = false;
            String credentialType = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA;
            if(isDeanLetter){
                credentialType = Constants.ASSET_NAME_DEAN_LETTER;
            }
            List<Asset> assetsCreatedFromPageList = new List<Asset>([SELECT Id, Azure_Storage_URL__c FROM Asset WHERE Azure_Storage_URL__c IN: assetsUrlsList]);
            Map<String, Asset> azureUrlAssetMap = new Map<String, Asset>();
            for(Asset asstIter : assetsCreatedFromPageList){
                azureUrlAssetMap.put(asstIter.Azure_Storage_URL__c, asstIter);
            }
            // Updating isDeanLetter Status in Contact_Association_Type_Staging__c
            Contact_Association_Type_Staging__c conAssType = new Contact_Association_Type_Staging__c();
            if(Schema.sObjectType.Contact_Association_Type_Staging__c.isUpdateable()){
                conAssType.Id = contactAssociationTypeStagingId;
				conAssType.IsDeanLetter__c = isDeanLetter;
				conAssType.Courier_service_for_an_additional_fee__c = couriercheckbox;
                conAssType.Credential_Type__c = credentialType;
				update conAssType;
			}            
            List<Asset> assetsToUpdate = new List<Asset>();            
            assetsToUpdate = addAssetsToUpdate(objectList[0], azureUrlAssetMap);
            try{
                if(!assetsToUpdate.isEmpty() && Schema.sObjectType.Asset.isUpdateable()){
                    update assetsToUpdate;
                }
            }catch(exception e){
				AppForCertController.saveLogMessage(e.getMessage());
			}
        }
        return returnVal;
    }
    // US 16769 - Create Credential Intake CATS Record if not exist
	public static String getCATSCredIntakeRecord(String contactId, String parentCaseId, String contactAssociationTypeStagingId, String conAssocTypeStagCredIntakeId){
        String credIntakeCatsId = '';
        if(conAssocTypeStagCredIntakeId == '' || conAssocTypeStagCredIntakeId == null){
            credIntakeCatsId = createCATSCredIntakeRecord(contactId, parentCaseId, contactAssociationTypeStagingId);
        }
		return credIntakeCatsId;
	}
    // US 16769 - Check Credential Intake CATS ID already there
	public static String getCATSCredIntakeRecId(String contactId, String parentCaseId){
		String intakeCATSRecId = '';
		List<Contact_Association_Type_Staging__c> intakeCATSList = [SELECT Id FROM Contact_Association_Type_Staging__c
                                                                        WHERE Contact__c =: contactId
                                                                        AND Parent_Case__c =: parentCaseId
                                                                        AND recordtype.developerName =: Constants.CONASCTYPESTG_RECORD_TYPE_CREDENTIAL_INTAKE WITH SECURITY_ENFORCED];																
		if(!intakeCATSList.isEmpty()){
			intakeCATSRecId = intakeCATSList[0].Id;
		}
		return intakeCATSRecId;
	}
    // US 16769 - Cloning CATS Degree Medical School record to CATS Credential Intake
	public static String createCATSCredIntakeRecord(String contactId, String parentCaseId, String contactAssociationTypeStagingId){
		Id intakeCATSRecordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_CREDENTIAL_INTAKE).getRecordTypeId();
		Contact_Association_Type_Staging__c degMedSchoolCATSRec = [SELECT Id, Account__c, Graduation_Year__c, Degree_Title__c, Degree_Issue_Date__c, School_Program__c, Start_Date__c, End_Date__c, Start_Month__c, Start_Year__c, End_Month__c, End_Year__c, Specialty__c, Number_of_Years_Attended__c, Student_ID__c, Transfer_Credit_to_Degree_School__c
																	 FROM Contact_Association_Type_Staging__c
                                                                        WHERE Id =: contactAssociationTypeStagingId WITH SECURITY_ENFORCED];
        String catsIntakeId = '';
        if(Schema.sObjectType.Contact_Association_Type_Staging__c.isCreateable()){
            Contact_Association_Type_Staging__c stageRec = new Contact_Association_Type_Staging__c();
            stageRec.Contact__c = contactId;
            stageRec.Account__c = degMedSchoolCATSRec.Account__c;
            stageRec.recordTypeId = intakeCATSRecordTypeId;
            stageRec.Degree_Title__c = degMedSchoolCATSRec.Degree_Title__c;
            stageRec.Degree_Issue_Date__c = degMedSchoolCATSRec.Degree_Issue_Date__c;
            stageRec.Graduation_Year__c = degMedSchoolCATSRec.Graduation_Year__c;
            stageRec.School_Program__c = degMedSchoolCATSRec.School_Program__c;
            stageRec.Start_Date__c =degMedSchoolCATSRec.Start_Date__c;
            stageRec.End_Date__c = degMedSchoolCATSRec.End_Date__c;
            stageRec.Start_Month__c = degMedSchoolCATSRec.Start_Month__c;
            stageRec.Start_Year__c = degMedSchoolCATSRec.Start_Year__c;
            stageRec.End_Month__c = degMedSchoolCATSRec.End_Month__c;
            stageRec.End_Year__c = degMedSchoolCATSRec.End_Year__c;
            stageRec.Specialty__c = degMedSchoolCATSRec.Specialty__c;
            stageRec.Number_of_Years_Attended__c = degMedSchoolCATSRec.Number_of_Years_Attended__c;
            stageRec.Student_ID__c = degMedSchoolCATSRec.Student_ID__c;
            stageRec.Transfer_Credit_to_Degree_School__c = degMedSchoolCATSRec.Transfer_Credit_to_Degree_School__c;
            stageRec.Credential_Type__c = Constants.CASE_DOC_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT;
            stageRec.Parent_Case__c = parentCaseId;
            Insert stageRec;
            catsIntakeId = stageRec.Id;
        }
		return catsIntakeId;
	}
    // US 16769 - Updating Asset details and Parent Id
    public static List<Asset> addAssetsToUpdate(AppForCertHelper.GraduateOnlyObjWrapper jsObj, Map<String, Asset> assetsMap){
        String contactAssociationTypeStagingId = jsObj.contactAssociationTypeStagingId;
        String conAssocTypeStagCredIntakeId = jsObj.conAssocTypeStagCredIntakeId;
        String contactId = jsObj.contactId;
        String parentCaseId = jsObj.parentCaseId;
        Boolean isFinalTranscriptRequired = jsObj.isFinalTranscriptRequired;
        Boolean isDeanLetter = jsObj.isDeanLetter;
        Date dateonDeanLetterDocument = jsObj.dateonDeanLetterDocument;
        if(isFinalTranscriptRequired && isDeanLetter == false){
            conAssocTypeStagCredIntakeId = getCATSCredIntakeRecord(contactId, parentCaseId, contactAssociationTypeStagingId, conAssocTypeStagCredIntakeId);
        }
        String catsId = contactAssociationTypeStagingId;
		List<Asset> assetsToUpdate = new List<Asset>();
		if(jsObj.assets.size() > 0 && jsObj.assets != null){
			for(AppForCertHelper.AssetObjWrapper tempAsset : jsObj.assets){
				if(tempAsset.azureUrl != '' && tempAsset.azureUrl != 'true' && assetsMap.containsKey(tempAsset.azureUrl)){
                    if(tempAsset.type == 'CredentialIntake' && conAssocTypeStagCredIntakeId != ''){
                        catsId = conAssocTypeStagCredIntakeId;
                    }
					Asset childAsset = new Asset(Id = assetsMap.get(tempAsset.azureUrl).Id);
					childAsset.Contact_Association_Type_Staging__c = catsId;
					childAsset.Name_on_Document__c = tempAsset.nameOnDoc;
					childAsset.Name_on_Document_is_Different__c = tempAsset.nameOnDocIsDifferent == 'true';
					childAsset.Document_is_not_in_English__c = tempAsset.docNotInEnglish == 'true';
					if(String.isNotBlank(tempAsset.parentAssetAzureUrl)){
						childAsset.parentId = assetsMap.get(tempAsset.parentAssetAzureUrl).Id;
						childAsset.Parent_Azure_Storage_URL__c = tempAsset.parentAssetAzureUrl;
					}
                    if(isDeanLetter){
                        childAsset.Dean_s_Letter_Date__c = dateonDeanLetterDocument;
                    }
					assetsToUpdate.add(childAsset);
				}
			}
		}
		return assetsToUpdate;
	}
    @AuraEnabled
	public static Boolean getCatCourierFMST(String selectedEntityId){
        Boolean returnVal = false;
        Boolean finalTranscriptReqd = checkFMST(selectedEntityId);     
        String parentCaseId = getCaseId();
        String contactId = retrieveCurrentContactId();
        List<Contact_Association_Type_Staging__c> catsList = new List<Contact_Association_Type_Staging__c>();
        if(finalTranscriptReqd){
            catsList = [SELECT Id,Courier_service_for_an_additional_fee__c FROM Contact_Association_Type_Staging__c WHERE Contact__c =: contactId AND Parent_Case__c =: parentCaseId
                        AND recordtype.developerName =: Constants.CONASCTYPESTG_RECORD_TYPE_CREDENTIAL_INTAKE WITH SECURITY_ENFORCED];        
            if(!catsList.isEmpty()){
                returnVal = catsList[0].Courier_service_for_an_additional_fee__c;
            }
        } 
        return returnVal;
    }    
	public static Boolean checkFMST(String accId){	
		Boolean finalTranscriptReqd = false;
		List<Account> degMeDSchoolRec = new List<Account>();
		if(Account.SObjectType.getDescribe().isAccessible()){
			degMeDSchoolRec = [SELECT Id,Is_Final_Transcript_Required__c FROM Account WHERE Id =: accId WITH SECURITY_ENFORCED];
			if(!degMeDSchoolRec.isEmpty()){
				finalTranscriptReqd = degMeDSchoolRec[0].Is_Final_Transcript_Required__c;
			}	
		}
		return finalTranscriptReqd;
	}
    // Delete Credential Intake CATS
    @AuraEnabled
	public static void deleteCredIntakeCATS(String contactId, String parentCaseId){
        List<Contact_Association_Type_Staging__c> catsList = [SELECT Id FROM Contact_Association_Type_Staging__c WHERE Contact__c =: contactId AND Parent_Case__c =: parentCaseId
                        AND recordtype.developerName =: Constants.CONASCTYPESTG_RECORD_TYPE_CREDENTIAL_INTAKE WITH SECURITY_ENFORCED];        
        List<Contact_Association_Type_Staging__c> catsIntakeList = new List<Contact_Association_Type_Staging__c> ();
        if(!catsList.isEmpty()){
            for(Contact_Association_Type_Staging__c catsRec : catsList){
                catsIntakeList.add(catsRec);
            }
        }
        if(Contact_Association_Type_Staging__c.SObjectType.getDescribe().isDeletable()){
            DELETE catsIntakeList;
        }    
    }    
    //create CV Case for non required FMST
    public static void createCVCaseForFMSTNotReq(String contactId,String parentCaseId,Boolean showExamRegActionButton){
        String recordTypeDevNameDegree = AppForCertController.getRecordTypeDegree(showExamRegActionButton);
        Group cvQueue = [SELECT Id, name, Group.DeveloperName FROM Group WHERE Type = 'Queue' and Group.DeveloperName =: Constants.CASE_QUEUE_CREDENTIAL_REVIEW_QUEUE WITH SECURITY_ENFORCED];
        Boolean isFinalTranscriptRequired = false;
        List <Contact_Association_Type_Staging__c> conAssType = [SELECT Id, IsDeanLetter__c, Account__c, Courier_service_for_an_additional_fee__c,Credential_Type__c, Parent_Case__r.Id,Account__r.Id
                                                                    FROM Contact_Association_Type_Staging__c 
                                                                WHERE Contact__c =: contactId AND Parent_Case__c =: parentCaseId AND recordtype.developerName =: recordTypeDevNameDegree WITH SECURITY_ENFORCED];
        if(!conAssType.isEmpty() && conAssType[0].Credential_Type__c == constants.CASE_DOC_TYPE_FINAL_MED_DIPLOMA){
            isFinalTranscriptRequired = AppForCertHelper.checkFMST(conAssType[0].Account__c);
            if(!isFinalTranscriptRequired){
                String intakeCATSRecId = AppForCertController.getCATSCredIntakeRecord(contactId, parentCaseId);
                String credIntakeCatsId;
                if(intakeCATSRecId == ''){
                    credIntakeCatsId = createCATSCredIntakeRecord(contactId, parentCaseId, conAssType[0].Id);
                    List<Contact_Association_Type_Staging__c> conAssTypeInt = [SELECT Id, IsDeanLetter__c, Account__c, Courier_service_for_an_additional_fee__c,Credential_Type__c, Parent_Case__r.Id,Account__r.Id,Case__c
                                                                                FROM Contact_Association_Type_Staging__c WHERE Id =:credIntakeCatsId];
                    Case cs = new Case(); 
                    cs.RecordTypeId =  Constants.CVRECORDTYPEID;
                    cs.Service__c = 'ECFMG_Certification';
                    cs.Internal_Status__c = 'New';
                    cs.ParentId = conAssTypeInt[0].Parent_Case__r.Id;
                    cs.Entity__c = conAssTypeInt[0].Account__r.Id;
                    cs.Document_Type__c = conAssTypeInt[0].Credential_Type__c; 
                    cs.Document_type_selected_by_applicant__c = conAssTypeInt[0].Credential_Type__c;
                    cs.ECFMG_Portal_Case_Url__c = getECFMGPortalCaseUrl(cs.Id);
                    cs.OwnerId = cvQueue.Id;
                    INSERT cs;

                    conAssTypeInt[0].Case__c = cs.Id;
                    conAssTypeInt[0].Requested_to_be_sent_to_ECFMG__c = true;
                    UPDATE conAssTypeInt;
                }				
            }		
        }
    }
    // Purpose : Method to return the files/Documents uploaded by applicant for Final Medical Diploma / Letter from Dean
	@AuraEnabled(Cacheable = false)
    public static Map<String, String> getCATGraduateOnlyRecords(Boolean showExamRegActionButton, Boolean showCaseDetail, Boolean resubmitAppForCert, String catId) {
		Map<String, String> returnValue = new Map<String, String> ();
		String fmdId = null,
			fmdFile = '',
			fmdName = '',
			fmdNameDiff = '',
			fmdNameDoc = '',
			fmdTransId = null,
			fmdNameDocId = null,
			fmdTrans = '',
			fmdTransFile = '';
		String dlId = null,
			dlFile = '',
			dlName = '',
			dlNameDiff = '',
			dlNameDoc = '',
			dlTransId = null,
			dlNameDocId = null,
			dlTrans = '',
			dlTransFile = '',
			dlDate = '';		
		String isDeanLetter = 'No',
			isFTReqd = 'No';
			//User story#15591 - Courier_service_for_an_additional_fee__c
		String isCourierService = 'No';
		String isCourierServiceFMST = 'No';
        Map<String, Asset> assetKeyListMap = new Map<String, Asset>();
		Map<Id, Asset> assetsMap = new Map<Id, Asset>();
		List<Id> assetIds = new List<Id> ();
		String recordTypeDeveloperName;
		if (showExamRegActionButton == true) {
			if (resubmitAppForCert) {
				recordTypeDeveloperName = Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL;
			} else {
				recordTypeDeveloperName = Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL_EXAM_REG;
			}
		} else {
			recordTypeDeveloperName = Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL;
		}
		Id contactId = AppForCertHelper.retrieveCurrentContactId();
		Id caseId = AppForCertController.getCaseIdAllStatus(showCaseDetail, contactId);
		//User story#15591 - new field Courier_service_for_an_additional_fee__c added to query
        if(catId != ''){
            List<Contact_Association_Type__c> degMeDSchoolCATRec = [SELECT Id, Case__c, case__r.Internal_Status__c, case__r.Case_Service__c, IsDeanLetter__c, Account__r.Is_Final_Transcript_Required__c, Courier_service_for_an_additional_fee__c 
                                                                    FROM Contact_Association_Type__c
			                                                        WHERE Id =: catId WITH SECURITY_ENFORCED 
                                                                    ORDER BY CreatedDate DESC LIMIT 1];

            Id degMedSchoolId = degMeDSchoolCATRec[0].Id;
			Boolean deanLetter = degMeDSchoolCATRec[0].IsDeanLetter__c;
			Boolean finalTranscriptReqd = degMeDSchoolCATRec[0].Account__r.Is_Final_Transcript_Required__c;			
			Boolean courierService = degMeDSchoolCATRec[0].Courier_service_for_an_additional_fee__c;
            String caseIdVal = degMeDSchoolCATRec[0].Case__c;
            if(!(degMeDSchoolCATRec[0].case__r.Internal_Status__c == Constants.CASE_STATUS_EXPIRED && degMeDSchoolCATRec[0].case__r.Case_Service__c == Constants.CASE_RECORD_TYPE_APP_FOR_CERT)){
                if(courierService){
                    isCourierService = 'Yes';
                }
                for(Asset assetRec : [SELECT Id, Status, key__c, Contact_Association_Type__c, Document_is_not_in_English__c, Name_on_Document__c, Name_on_Document_is_Different__c, Type__c, Dean_s_Letter_Date__c, ParentId FROM Asset WHERE
                    Contact_Association_Type__c =: catId AND (Status =: Constants.ASSET_STATUS_ACCEPTED OR Status =: Constants.ASSET_STATUS_EXPIRED) WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC
                ]){
                    if(!assetKeyListMap.containsKey(assetRec.key__c)){
                        assetKeyListMap.put(assetRec.key__c, assetRec);
                    }                
                }
                List<Asset> assetList = assetKeyListMap.values();
                // This method is created for avoiding SonarCloud issue
                Map<String, String> assetIdsMap = new Map<String, String> ();
                assetIdsMap = AppForCertController.getGradAssetIds(deanLetter, finalTranscriptReqd, assetList);
                dlId = assetIdsMap.get('dlId');
                fmdId = assetIdsMap.get('fmdId');
                // This method is created for avoiding SonarCloud issue...Refactoring Methods
                // ASSET_TYPE_DEAN_LETTER
                if (deanLetter) {
                    isDeanLetter = 'Yes';
                    Map<String, String> assetDeanLetterMap = new Map<String, String> ();
                    assetDeanLetterMap = AppForCertController.getGradDeanLetter(assetList, dlId);
                    dlName = assetDeanLetterMap.get('dlName');
                    dlNameDiff = assetDeanLetterMap.get('dlNameDiff');
                    dlTrans = assetDeanLetterMap.get('dlTrans');
                    dlTransId = assetDeanLetterMap.get('dlTransId');
                    dlDate = assetDeanLetterMap.get('dlDate');
                    dlNameDocId = assetDeanLetterMap.get('dlNameDocId');
                } else {
                    // ASSET_TYPE_FINAL_MED_DIPLOMA
                    Map<String, String> asseMedDiplomaMap = new Map<String, String> ();
                    asseMedDiplomaMap = AppForCertController.getGradMedDiploma(assetList, fmdId);
                    fmdName = asseMedDiplomaMap.get('fmdName');
                    fmdNameDiff = asseMedDiplomaMap.get('fmdNameDiff');
                    fmdTrans = asseMedDiplomaMap.get('fmdTrans');
                    fmdTransId = asseMedDiplomaMap.get('fmdTransId');
                    fmdNameDocId = asseMedDiplomaMap.get('fmdNameDocId');
                }
                // Creating Map for Asset Trans Id
                Map<String, String> assetTransIdMap = new Map<String, String> ();
                assetTransIdMap.put('dlTransId', dlTransId);
                assetTransIdMap.put('fmdTransId', fmdTransId);
                for (Asset rec: assetList) {
                    assetIds.add(rec.Id);
                    assetsMap.put(rec.Id, rec);
                }
                if (assetIds.size() > 0) {
                    // This method is created for avoiding SonarCloud issue
                    Map<String, String> assetFilesMap = new Map<String, String> ();
                    assetFilesMap = AppForCertController.getGraduateOnlyRecordsRefactorDocument(assetIdsMap, assetTransIdMap, deanLetter, finalTranscriptReqd, assetIds, assetsMap);
                    // ASSET_TYPE_DEAN_LETTER
                    dlFile = assetFilesMap.get('dlFile');
                    dlNameDoc = assetFilesMap.get('dlNameDoc');
                    dlTransFile = assetFilesMap.get('dlTransFile');
                    // ASSET_TYPE_FINAL_MED_DIPLOMA
                    fmdFile = assetFilesMap.get('fmdFile');
                    fmdNameDoc = assetFilesMap.get('fmdNameDoc');
                    fmdTransFile = assetFilesMap.get('fmdTransFile');
                }
            }
		}
		returnValue.put('fmdId', fmdId);
		returnValue.put('fmdFile', fmdFile);
		returnValue.put('fmdName', fmdName);
		returnValue.put('fmdNameDiff', fmdNameDiff);
		returnValue.put('fmdNameDoc', fmdNameDoc);
		returnValue.put('fmdTransId', fmdTransId);
		returnValue.put('fmdNameDocId', fmdNameDocId);
		returnValue.put('fmdTrans', fmdTrans);
		returnValue.put('fmdTransFile', fmdTransFile);
		returnValue.put('dlId', dlId);
		returnValue.put('dlFile', dlFile);
		returnValue.put('dlName', dlName);
		returnValue.put('dlNameDiff', dlNameDiff);
		returnValue.put('dlNameDoc', dlNameDoc);
		returnValue.put('dlTransId', dlTransId);
		returnValue.put('dlNameDocId', dlNameDocId);
		returnValue.put('dlTrans', dlTrans);
		returnValue.put('dlTransFile', dlTransFile);
		returnValue.put('dlDate', dlDate);		
		returnValue.put('isDeanLetter', isDeanLetter);
		returnValue.put('isCourierService', isCourierService);
		return returnValue;
	}
    // Purpose : Method to return the files/Documents - Credential Intake - FMST
	@AuraEnabled(Cacheable = false)
    public static Map<String, String> getCATGraduateFMSTRecord(Boolean showExamRegActionButton, Boolean showCaseDetail, Boolean resubmitAppForCert) {
		Map<String, String> returnValue = new Map<String, String>();
		String ftId = null,
			ftFile = '',
			ftName = '',
			ftNameDiff = '',
			ftNameDoc = '',
			ftTransId = null,
			ftNameDocId = null,
			ftTrans = '',
			ftTransFile = '';
		String isDeanLetter = 'No',
			isFTReqd = 'No';
		//User story#15591 - Courier_service_for_an_additional_fee__c
		String isCourierServiceFMST = 'No';
		Map<Id, Asset> assetsMap = new Map<Id, Asset>();
		List<Id> assetIds = new List<Id> ();
		Id contactId = AppForCertHelper.retrieveCurrentContactId();
		Id caseId = AppForCertController.getCaseIdAllStatus(showCaseDetail, contactId);
		List<Asset> intakeAssetList = new List<Asset>();
        // Getting FMST from CAT-Credential Intake
        String intakeRecordTypeDevName = Constants.CONASCTYPE_RECORD_TYPE_CREDENTIAL_INTAKE;
        List<Contact_Association_Type__c> credIntakeCATList = [SELECT Id, Case__c, IsDeanLetter__c, Account__r.Is_Final_Transcript_Required__c, Courier_service_for_an_additional_fee__c 
                                                                FROM Contact_Association_Type__c
                                                                WHERE Contact__c =: contactId AND recordType.DeveloperName =: intakeRecordTypeDevName
                                                                WITH SECURITY_ENFORCED 
                                                                ORDER BY CreatedDate DESC LIMIT 1];
        if(!credIntakeCATList.isEmpty()){
            Id credIntakeCATRecId = credIntakeCATList[0].Id;
            Boolean courierServiceFMST = credIntakeCATList[0].Courier_service_for_an_additional_fee__c;
            if(courierServiceFMST){
                isCourierServiceFMST = 'Yes';
            }
            intakeAssetList = [SELECT Id, Contact_Association_Type_Staging__c, Document_is_not_in_English__c, Name_on_Document__c, Name_on_Document_is_Different__c, Type__c, Dean_s_Letter_Date__c, ParentId 
                                FROM Asset 
                                WHERE Contact_Association_Type__c =: credIntakeCATRecId 
                                    AND Status =: constants.ASSET_STATUS_ACCEPTED 
                                WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];                    
        }
        Boolean finalTranscriptReqd = true;
        Boolean deanLetter = true;
        // This method is created for avoiding SonarCloud issue
        Map<String, String> assetIdsMap = new Map<String, String> ();
        assetIdsMap = AppForCertController.getGradAssetIds(deanLetter, finalTranscriptReqd, intakeAssetList);
        ftId = assetIdsMap.get('ftId');			
		// ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT	
        isFTReqd = 'Yes';
        Map<String, String> assetTransscriptMap = new Map<String, String> ();
        assetTransscriptMap = AppForCertController.getGradTranscript(intakeAssetList, ftId);
        ftName = assetTransscriptMap.get('ftName');
        ftNameDiff = assetTransscriptMap.get('ftNameDiff');
        ftTrans = assetTransscriptMap.get('ftTrans');
        ftTransId = assetTransscriptMap.get('ftTransId');
        ftNameDocId = assetTransscriptMap.get('ftNameDocId');			
        // Creating Map for Asset Trans Id
        Map<String, String> assetTransIdMap = new Map<String, String>();
        assetTransIdMap.put('ftTransId', ftTransId);
        for (Asset rec: intakeAssetList) {
            assetIds.add(rec.Id);
            assetsMap.put(rec.Id, rec);
        }
        if (assetIds.size() > 0) {
            // This method is created for avoiding SonarCloud issue
            Map<String, String> assetFilesMap = new Map<String, String> ();
            assetFilesMap = AppForCertController.getGraduateOnlyRecordsRefactorDocument(assetIdsMap, assetTransIdMap, deanLetter, finalTranscriptReqd, assetIds, assetsMap);
            // ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT
            ftFile = assetFilesMap.get('ftFile');
            ftNameDoc = assetFilesMap.get('ftNameDoc');
            ftTransFile = assetFilesMap.get('ftTransFile');
        }	
		returnValue.put('ftId', ftId);
		returnValue.put('ftFile', ftFile);
		returnValue.put('ftName', ftName);
		returnValue.put('ftNameDiff', ftNameDiff);
		returnValue.put('ftNameDoc', ftNameDoc);
		returnValue.put('ftTransId', ftTransId);
		returnValue.put('ftNameDocId', ftNameDocId);
		returnValue.put('ftTrans', ftTrans);
		returnValue.put('ftTransFile', ftTransFile);
		returnValue.put('isDeanLetter', isDeanLetter);
		returnValue.put('isFTReqd', isFTReqd);
		returnValue.put('isCourierServiceFMST', isCourierServiceFMST);
		return returnValue;
	}
    //Method to check the Contact_Association_Type__c Other Medical School of logged in community user
    @AuraEnabled(Cacheable = false)
    public static Boolean updateCATDeletedOnResubmission(String recordTypeDevName){
        Id contactId = retrieveCurrentContactId();
        List<Contact_Association_Type__c> catObjList = new List<Contact_Association_Type__c>();       
        List<Contact_Association_Type__c> existingCATObjList = [SELECT Id, Deleted_On_Resubmission__c FROM Contact_Association_Type__c 
                                            WHERE recordType.DeveloperName =: recordTypeDevName
                                            AND Contact__c =: contactId WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
        if(!existingCATObjList.isEmpty()){
            for(Contact_Association_Type__c catList : existingCATObjList){
                catList.Deleted_On_Resubmission__c = true;
                catObjList.add(catList);
            }
            if(!catObjList.isEmpty() && Contact_Association_Type__c.SObjectType.getDescribe().isUpdateable()){
                UPDATE catObjList;
            }
        }       
        return true;
    }
    public Static String getECFMGPortalCaseUrl(String caseId){
        String caseUrl = '';
        try{
            Network myNetwork = [SELECT Id FROM Network WHERE Name =: Constants.COMMUNITY_NAME];
            String portalUrl = Network.getLoginUrl(myNetwork.Id);
            portalUrl = portalUrl.substringBefore('login');
            caseUrl = portalUrl+'s/case/'+caseId;            
        }
        catch(Exception e){
            System.debug('Exception caught. '+e.getMessage());
        }
        return caseUrl;
    }
    // Method used in Graduate screen to check whether asset status is accepted for FMST.
	@AuraEnabled(cacheable = false)
	public static Boolean getFMSTAssetStatusAndType(String contactId){
		Boolean returnValue = False;
		List<Asset> assetList = [SELECT Id, Status, Name, Type__c 
                                    FROM Asset WHERE ContactId =: contactId 
                                    AND Type__c =: Constants.ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT
				                    AND IsOrphan__c = FALSE ORDER BY CreatedDate DESC LIMIT 1];
		if(!assetList.isEmpty()){
			if(assetList[0].Status == Constants.ASSET_STATUS_ACCEPTED){
				returnValue = True;
			}
		}
		return returnValue;
	}
    // Method used in Graduate screen to check as FMST's CV Case is CV Accepted or not
	@AuraEnabled(cacheable = false)
	public static Boolean checkFMSTCVAccepted(String contactId){
		Boolean returnValue = false;
        String recordTypeDevNameCredIntake = Constants.CONASCTYPESTG_RECORD_TYPE_CREDENTIAL_INTAKE;
        List<Contact_Association_Type__c> fmstCATObjList = [SELECT Id, Case__r.Internal_Status__c FROM Contact_Association_Type__c 
                                            WHERE recordType.DeveloperName =: recordTypeDevNameCredIntake
                                            AND Contact__c =: contactId WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
        if(!fmstCATObjList.isEmpty()){
            if(fmstCATObjList[0].Case__r.Internal_Status__c == Constants.CASE_STATUS_CV_ACCEPTED){
				returnValue = true;
			}
        }
		return returnValue;
	}
    // Method to remove CAT & CATS link from existing Accepted Dean Assets
	public static void unlinkAcceptedDeanAsset(List<Asset> assetList){
		List<Asset> assetListToUpdate = new List<Asset> ();
		if (!assetList.isEmpty()) {
			String recordtypeAssetId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_MARKED_FOR_DELETION).getRecordTypeId();
			for (Asset eachAsset: assetList) {
				eachAsset.Contact_Association_Type_Staging__c = null;
                eachAsset.Contact_Association_Type__c = null;
				assetListToUpdate.add(eachAsset);
			}
			if (Schema.sObjectType.Asset.isUpdateable()) {
				update assetListToUpdate;
			}
		}
	}
    // Method to get CAT - Degree Medical School - FMD - Internal Status
	@AuraEnabled(Cacheable = true)
	public Static Boolean getCATDegMedSchFMDStatus(String currentContactId){
        if(currentContactId == ''){
            currentContactId = AppforCertHelper.retrieveCurrentContactId();
        }		
		Boolean acceptedFMDStatus = false;
		List<Contact_Association_Type__c> catList = [SELECT Id, Case__c, Case__r.Internal_Status__c, Case__r.Document_Type__c
                                                        FROM Contact_Association_Type__c
                                                    WHERE recordType.DeveloperName =: Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL
                                                        AND Contact__c =: currentContactId 
                                                        AND Case__c != null
                                                        AND Case__r.Document_Type__c =: Constants.CASE_DOC_TYPE_FINAL_MED_DIPLOMA 
                                                        AND Case__r.Internal_Status__c =: Constants.CASE_STATUS_CV_ACCEPTED WITH SECURITY_ENFORCED];
        if(!catList.isEmpty()){
            acceptedFMDStatus = true;
        }
		return acceptedFMDStatus;
	}
    // US 19808 - Download AppForCert Summary PDF
    @AuraEnabled
    public static String getAppForCertSummaryPDFUrl(String caseId){
        String appforcertSummaryPdf = '';
        List<Asset> asstList = [SELECT Id,Case__c,Type__c,Status,RecordType.DeveloperName,Azure_Storage_URL__c 
                                    FROM Asset WHERE Status =: Constants.ASSET_STATUS_ACCEPTED 
                                        AND Case__c =: caseId 
                                        AND Type__c =: Constants.ASSET_TYPE_APPLICATION_SUMMARY 
                                        AND Azure_Storage_URL__c != null WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
        if(!asstList.isEmpty()){
            appforcertSummaryPdf = asstList[0].Azure_Storage_URL__c;
        }
        return appforcertSummaryPdf;
    }
}