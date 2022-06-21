/**
    * @author: Reshma Ravi
    * @name: EnrollmentVerificationCaseHandler
    * @description: User Story : 3270,3271,3212 Update existing Enrollment Verification Case with new exam details(from exam registration)
    * @createdDate: 24-Mar-2020systemCheckEVCase
**/
public with sharing class EnrollmentVerificationCaseHandler {
//     /**
//      * @author: Ajoydhas
//      * @name: systemManageNewCases
//      * @description: Method to handling New Cases /// To avoid Cognitive Complexity
//      * @Parameters: 
//      * @return type: void
//      */
//     public static void systemManageNewCases(List<Case> newCases, Map<Id, Case> oldCaseMap){
//         Id examRegRTId          =   Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
//         Id epexRecordTypeId     =   Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD).getRecordTypeId();
//         Id evCaseRecordTypeId   =   Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION).getRecordTypeId();
//         Id ervRecordTypeId      =   Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_REVERIFICATION).getRecordTypeId();
//         List<Case> examRegCases =   new List<Case>();
//         MAP<ID, Case> examRegOldCasesMap = new MAP<ID, Case>();
//         List<Case> epexNewCases =   new List<Case>();
//         MAP<ID, Case> epexOldCasesMap = new MAP<ID, Case>();
//         List<Case> evNewCases   =   new List<Case>();
//         List<Case> ervNewCases   =   new List<Case>();
//         MAP<ID, Case> evOldCasesMap = new MAP<ID, Case>();
        
//         for(Case newCase : newCases) {
//             // Handling Exam Reg Cases
//             if(newCase.RecordTypeId == examRegRTId) {
//                 examRegCases.add(newCase);
//                 examRegOldCasesMap.put(newCase.Id, oldCaseMap.get(newCase.Id));
//             }
//             // Handling EPEx Cases
//             if(newCase.RecordTypeId == epexRecordTypeId){
//                 epexNewCases.add(newCase);
//                 epexOldCasesMap.put(newCase.Id, oldCaseMap.get(newCase.Id));
//             }
//             // Handling EV Cases
//             if(newCase.RecordTypeId == evCaseRecordTypeId){
//                 evNewCases.add(newCase);
//                 evOldCasesMap.put(newCase.Id, oldCaseMap.get(newCase.Id));
//             }
            
//             // Handling Enrollment Reverification Cases
//             if(newCase.RecordTypeId == ervRecordTypeId && newCase.Internal_Status__c != oldCaseMap.get(newCase.Id).Internal_Status__c && newCase.Internal_Status__c == Constants.CASE_STATUS_RECEIVED_IN_REVIEW){
//                 ervNewCases.add(newCase);
//             }
//         }

//         // Handling Exam Reg Cases
//         if(!examRegCases.isEmpty()){
//             systemManageExamRegCases(examRegCases, examRegOldCasesMap);            
//         }
//         // Handling EPEx Cases
//         if(!epexNewCases.isEmpty()){
//             systemManageEPExCases(epexNewCases, epexOldCasesMap);
//         }
//         // Handling EV Cases
//         if(!evNewCases.isEmpty()){
//             systemCheckEVCase(evNewCases, evOldCasesMap);
//         }
        
//         // Handling ERV Cases
//         if(!ervNewCases.isEmpty()){
//             systemManageERVCases(ervNewCases);
//         }
        
//     }
//     /**
//      * @author: Ajoydhas
//      * @name: systemManageExamRegCases
//      * @description: Method to handling Exam Registration Cases /// To avoid Cognitive Complexity
//      * @Parameters: 
//      * @return type: void
//      */
//     public static void systemManageExamRegCases(List<Case> newExamRegCases, MAP<ID, Case> examRegOldCasesMap){
//         List<Case> pendingEnrollmentExamRegList  =   new List<Case>();
//         Set<ID> evCaseIdSet     =   new Set<ID>(); // US 4028
//         Set<ID> examRegCaseIds  =   new Set<ID>();
//         Set<ID> examRegCaseContactIds  =   new Set<ID>();
//         for(Case newExamRegCase : newExamRegCases) {
//             if(newExamRegCase.Internal_Status__c == Constants.CASE_STATUS_PENDING_ENROLLMENT && newExamRegCase.Internal_Status__c != examRegOldCasesMap.get(newExamRegCase.Id).Internal_Status__c && examRegOldCasesMap.get(newExamRegCase.Id).Enrollment_Verification_Parent__c == null) {
//                 pendingEnrollmentExamRegList.add(newExamRegCase);
//                 examRegCaseIds.add(newExamRegCase.Id);  
//                 examRegCaseContactIds.add(newExamRegCase.ContactId);              
//             }
//             if((newExamRegCase.Internal_Status__c == Constants.CASE_STATUS_PENDING_CIBIS || newExamRegCase.Internal_Status__c == Constants.CASE_STATUS_ENROLLMENT_NOT_VERIFIED_MEDSCL) && newExamRegCase.Internal_Status__c != examRegOldCasesMap.get(newExamRegCase.Id).Internal_Status__c && newExamRegCase.Enrollment_Verification_Parent__c != null) {
//                 evCaseIdSet.add(newExamRegCase.Enrollment_Verification_Parent__c);
//             }
//         }
//         // Exam Reg Case ||| Pending Enrollment Status 
//         if(!pendingEnrollmentExamRegList.isEmpty()) {
//             createEVCase(pendingEnrollmentExamRegList, examRegCaseContactIds);
//             updateSLADate(examRegCaseIds);
//         }
        
//         // Updating EV Case Status as Enrollment Verification Complete
//         if(!evCaseIdSet.isEmpty()) {
//             updateEVCaseStatus(evCaseIdSet,new Map<Id,String>());
//         }
//     } 
//     /**
//      * @author: Ajoydhas
//      * @Modified by : Ajoydhas (Due to US 5954)
//      * @name: createEVCase
//      * @description: Method to create Enrollment Verification case
//      * @Parameters: 
//      * @return type: void
//      */
//     public static void createEVCase(List<Case> newExamRegCases, Set<ID> examRegCaseContactIds) {        
//         Group evQueue                   =   CaseTriggerUtility.groupMap.get(Constants.CASE_QUEUE_ENROLLMENT_VERIFICATION);        
//         List<Case> evCaseList           =   new List<Case>();
//         List<Case> updateExamRegCaseList=   new List<Case>();
//         SET<string> contactIdSet        =   new SET<string>();
//         Set<Id> accountIds              =   new Set<Id>();
//         List<Contact_Association_Type__c> catRecord   =   new List<Contact_Association_Type__c>();
//         Map<Id, Id> contactCATAccountMap              =   new Map<Id, Id>();        

//         for(Case newExamRegCase : newExamRegCases){
//             catRecord.add(CaseTriggerUtility.catMap.get(newExamRegCase.ContactId));
//             accountIds.add(catRecord[0].Account__c);
//             contactCATAccountMap.put(newExamRegCase.ContactId, catRecord[0].Account__c);            
//         }

//         // EV CASE MAP
//         MAP<ID, Id> contactEVCaseAccountMap = getContactEVCaseAccountMapRefactor(examRegCaseContactIds, accountIds);

//         // Account2Service__c
//         Set<Id> account2ServiceSet  =   getAccount2ServiceRefactor(accountIds);

//         // ContactId with List of ExamRegCaseIds
//         MAP<String, List<Id>> examRegCaseMap  =   getExamRegCaseMapRefactor(newExamRegCases);

//         for(Case examRegCase : newExamRegCases) {
//             Id contactId        =   examRegCase.ContactId;
//             Id catAccountId     =   contactCATAccountMap.get(contactId);
//             Id evcaseAccountId  =   contactEVCaseAccountMap.get(contactId);
            
//             if(account2ServiceSet.contains(catAccountId)) {
//                 // Creating New EV Case if no EV Case                
//                 if(catAccountId == evcaseAccountId) { 
//                     updateExamRegCaseList.add(examRegCase);
//                 } else {
//                     if(!contactIdSet.contains(contactId)) {
//                         contactIdSet.add(contactId);
//                         // Record Type -> Degree_Medical_School
//                         Boolean account2Service = true;
//                         Case evCaseObj = createEVCaseObject(contactId, evQueue.Id, account2Service); 
//                         evCaseList.add(evCaseObj);
//                     }
//                 }               
//             } else {
//                 // Paper EV Case
//                 // Record Type -> Degree_Medical_School
//                 Boolean account2Service = false;
//                 Case evCaseObj = createEVCaseObject(contactId, evQueue.Id, account2Service); 
//                 evCaseList.add(evCaseObj);
//             }            
//         }

//         // manage Update & Inert the lists - avoiding the sonar code issues
//         handlingEVCaseDML(evCaseList, updateExamRegCaseList, examRegCaseMap);
        
//     }

//     /**
//      * @author: Ajoydhas
//      * @methodname: getContactEVCaseAccountMap
//      * @description: Method to get contact from EV Case Account
//      * @Parameters: examRegCaseContactIds, accountIds
//      * @return type: SET<Id>, SET<Id>
//      */
//     public static MAP<ID, Id> getContactEVCaseAccountMapRefactor(Set<Id> examRegCaseContactIds, Set<Id> accountIds) {   
//         Id evRecordTypeId       =   Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION).getRecordTypeId();     
//         MAP<ID, Id> contactEVCaseAccountMap  =   new MAP<ID, Id>();
//         for(Case evCaseRecord : [SELECT Id, Internal_Status__c, ContactId, AccountId FROM Case WHERE RecordTypeId =: evRecordTypeId AND ContactId IN: examRegCaseContactIds AND AccountId IN :accountIds]) {
//             contactEVCaseAccountMap.put(evCaseRecord.ContactId, evCaseRecord.AccountId);
//         }
//         return contactEVCaseAccountMap;
//     }
//     /**
//      * @author: Ajoydhas
//      * @methodname: getAccount2Service
//      * @description: Method to get Account2Service__c
//      * @Parameters: accountIds
//      * @return type: SET<Id>
//      */
//     public static SET<Id> getAccount2ServiceRefactor(Set<Id> accountIds) {        
//         Set<Id> account2ServiceSet = new Set<Id>();
//         for(Account2Service__c a2s : [SELECT Id, Account__c FROM Account2Service__c WHERE Account__c IN :accountIds AND Active__c = True]) {
//             account2ServiceSet.add(a2s.Account__c);
//         }
//         return account2ServiceSet;
//     }
//     /**
//      * @author: Ajoydhas
//      * @methodname: getExamRegCaseMapRefactor
//      * @description: Method to get contactid with list of exam reg. cases
//      * @Parameters: List of exam reg. cases
//      * @return type: MAP<String, List<Id>>
//      */
//     public static MAP<String, List<Id>> getExamRegCaseMapRefactor(List<Case> newExamRegCases) {        
//         MAP<String, List<Id>> examRegCaseMap = new MAP<String, List<Id>>();
//         for(Case examRegCase : newExamRegCases) {
//             Id examRegCaseId    =   examRegCase.Id;
//             Id contactId        =   examRegCase.ContactId;
//             if(examRegCaseMap.containsKey(contactId)) {
//                 List<Id> examRegCaseIdList = examRegCaseMap.get(contactId);
//                 examRegCaseIdList.add(examRegCaseId);
//                 examRegCaseMap.put(contactId, examRegCaseIdList);
//             } else {
//                 examRegCaseMap.put(contactId, new List<Id>{examRegCaseId});
//             }
//         }
//         return examRegCaseMap;
//     }
//     /**
//      * @author: Ajoydhas
//      * @methodname: handlingEVCaseDML
//      * @description: Method to avoid the Cognitive Complexity
//      * @Parameters: prevEVCaseList, evCaseList and updateExamRegCaseList
//      * @return type: no
//      */
//     public static void handlingEVCaseDML(List<Case> evCaseList, List<Case> updateExamRegCaseList, MAP<String, List<Id>> examRegCaseMap) {        

//         Map<ID, STRING> assetContactMap = new Map<ID, STRING>();
//         for(Asset photoAsset : [SELECT Id, Type__c, ContactId, Enrollment_Verification_Case__c
//                                             FROM Asset 
//                                         WHERE Type__c = 'Photo'
//                                             AND ContactId IN: examRegCaseMap.keySet()
//                                             AND status != :constants.ASSET_STATUS_MARKED_FOR_DELETION]) {
//             assetContactMap.put(photoAsset.ContactId, photoAsset.Id);
//         }

//         if(!evCaseList.isEmpty()) {
//             insert evCaseList;

//             reupdateEVCaseStatuses(evCaseList);
            
//             List<Asset> evCaseAssetUpdate = new List<Asset>();

//             // Update EV Case Id as Exam Reg.Case's Enrollment Verification Case Id
//             handlingEVCaseDMLRefactor(evCaseList, examRegCaseMap);

//             // Update Photo Asset
//             for(Case evCaseRecord : evCaseList){
//                 // Get photo asset & Update the Enrollment_Verification_Case__c in Asset Object                 
//                 if(assetContactMap.containsKey(evCaseRecord.ContactId)) {
//                     Asset evAssetObj = new Asset();
//                     evAssetObj.Id  =   assetContactMap.get(evCaseRecord.ContactId);
//                     evAssetObj.Enrollment_Verification_Case__c = evCaseRecord.Id;
//                     evCaseAssetUpdate.add(evAssetObj);
//                 }
//             }

//             // Update Photo Asset
//             if(!evCaseAssetUpdate.isEmpty()){
//                 evCaseAssetUpdate = assetListDeduplicator(evCaseAssetUpdate);
//                 UPDATE evCaseAssetUpdate;
//             }            
//         }
//         // Update EV Case
//         if(!updateExamRegCaseList.isEmpty()) {
//             updateEVCase(updateExamRegCaseList);
//         }
//     }
//     /**
//      * @author: Ajoydhas
//      * @methodname: handlingEVCaseDMLRefactor
//      * @description: Method to get contactid with list of exam reg. cases
//      * @Parameters: List of exam reg. cases
//      * @return type: MAP<String, List<Id>>
//      */
//     public static void handlingEVCaseDMLRefactor(List<Case> evCaseList, MAP<String, List<Id>> examRegCaseMap) {    
//         List<Case> examRegCaseToUpdate = new List<Case>();
//         Map<Id, Id> tempExamRegCaseMap = new Map<Id, Id>();

//         for(Case evCaseRecord : evCaseList){
//             Boolean enrolledInEntityPortal  =   evCaseRecord.Enrolled_in_Entity_Portal__c;
//             List<Id> examRegCaseIdList      =   examRegCaseMap.get(evCaseRecord.ContactId);

//             if(enrolledInEntityPortal == true) {
//                 for(Id examRegCaseId : examRegCaseIdList) {
//                     // Update the Exam Registration Case
//                     Case examRegCase = new Case();
//                     examRegCase.Id  =   examRegCaseId;
//                     examRegCase.Enrollment_Verification_Parent__c = evCaseRecord.Id;
//                     examRegCaseToUpdate.add(examRegCase);
//                 }                    
//             } else {
//                 // Paper EV Case
//                 Id examRegCaseId = examRegCaseIdList.get(0);

//                 if(tempExamRegCaseMap.containsKey(examRegCaseId)) {
//                     examRegCaseId = examRegCaseIdList.get(1);              
//                 } else {                    
//                     tempExamRegCaseMap.put(examRegCaseId, evCaseRecord.Id);
//                 }
//                 // Update the Exam Registration Case
//                 Case examRegCase = new Case();
//                 examRegCase.Id  =   examRegCaseId;
//                 examRegCase.Enrollment_Verification_Parent__c = evCaseRecord.Id;
//                 examRegCaseToUpdate.add(examRegCase);
//             }
//         }

//         if(!examRegCaseToUpdate.isEmpty()){
//             examRegCaseToUpdate = ExamRegistrationController.caseListDeduplicator(examRegCaseToUpdate);
//             UPDATE examRegCaseToUpdate;
//         }
//     }

//     /**
//      * @author: Chinmay Menon
//      * @methodname: assetListDeduplicator
//      * @description: Method to remove duplicate records from asset list which is to be processed by a CRUD operation
//      * @Parameters: List of assets
//      * @return type: list<Asset>
//      */
//     public static List<Asset> assetListDeduplicator(List<Asset> allAssets){
//         Map<Id, Asset> finalAssetsMap = new Map<Id, Asset>();
//         for(Asset a: allAssets){
//             if(!finalAssetsMap.containsKey(a.Id)){
//                 finalAssetsMap.put(a.Id, a);
//             }
//         }
//         allAssets = finalAssetsMap.values();

//         return allAssets;
//     }

//     /**
//      * @author: Chinmay Menon
//      * @methodname: reupdateEVCaseStatuses
//      * @description: Method to update ev case status, external status and verification status based on Enrolled in Entity Portal field value
//      * @Parameters: List of EV Cases
//      */
//     public static void reupdateEVCaseStatuses(List<Case> evCaseList) {

//         Set<Case> evCasesToBeReupdated = new Set<Case>();
//         for(Case evCaseIter : evCaseList){
//                 Case evCaseToReupdate = evCaseIter;
//                 if(evCaseIter.Enrolled_in_Entity_Portal__c){
//                     evCaseToReupdate.External_Status__c = Constants.CASE_EXTERNAL_STATUS_NOT_REVIEWED;
//                     evCaseToReupdate.Status_Not_Reviewed_Date__c = System.today();
//                     evCaseToReupdate.Verification_Status__c = Constants.CASE_VERIFICATION_STATUS_NOT_REVIEWED;
//                     evCaseToReupdate.Internal_Status__c = Constants.CASE_STATUS_POSTED_TO_ENTITY_PORTAL;
//                 } else {
//                     evCaseToReupdate.Internal_Status__c = Constants.CASE_STATUS_PENDING_ENROLLMENT;
//                 }
//             evCasesToBeReupdated.add(evCaseToReupdate);
//         }

//         if(!evCasesToBeReupdated.isEmpty()){
//             List<Case> listOfEvCasesToBeUpdated = new List<Case>();
//             listOfEvCasesToBeUpdated.addAll(evCasesToBeReupdated);
//             UPDATE listOfEvCasesToBeUpdated;
//         }

//     }

//     /**
//      * @author: Ajoydhas
//      * @methodname: createEVCase
//      * @description: Method to return new ev case instance
//      * @Parameters: Contact Id, Queue id, List of Contact_Association_Type__c
//      * @return type: Case
//      */
//     public static Case createEVCaseObject(String contactId, String queueId, Boolean account2Service) {
//         Id evRecordTypeId       =   Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION).getRecordTypeId();
//         List<Contact_Association_Type__c> catRecord   =   new List<Contact_Association_Type__c>{CaseTriggerUtility.catMap.get(contactId)};         
//         Case caseObj = new Case();
//         caseObj.ContactId                    =   contactId;                
//         caseObj.RecordTypeId                 =   evRecordTypeId;
//         caseObj.Internal_Status__c           =   Constants.CASE_STATUS_NEW;
//         caseObj.OwnerId                      =   queueId;
//         caseObj.AccountId                    =   catRecord[0].Account__c;
//         caseObj.Enrolled_in_Entity_Portal__c =   account2Service;
//         caseObj.School_Program__c            =   catRecord[0].School_Program__c;
//         caseObj.Attendance_Start_Date__c     =   catRecord[0].Start_Date__c;
//         caseObj.Attendance_End_Date__c       =   catRecord[0].End_Date__c;
//         //code added by Shailaja. Date format stories.
//         caseObj.Attendance_Start_Month__c     =   catRecord[0].Start_Month__c;        
//         caseObj.Attendance_Start_Year__c     =   catRecord[0].Start_Year__c;
//         caseObj.Attendance_End_Month__c       =   catRecord[0].End_Month__c;
//         caseObj.Attendance_End_Year__c       =   catRecord[0].End_Year__c;

//         caseObj.Graduation_Month__c          =   catRecord[0].Graduation_Month__c;
//         caseObj.Graduation_Year__c           =   catRecord[0].Graduation_Year__c;
//         caseObj.Degree_Date__c               =   catRecord[0].Degree_Issue_Date__c;
//         //code added by Shailaja. Date format stories.
//         caseObj.Degree_Month__c               =   catRecord[0].Degree_Issue_Month__c;
//         caseObj.Degree_Year__c               =   catRecord[0].Degree_Issue_Year__c;
        
//         caseObj.Number_of_Years_Attended__c  =   catRecord[0].Number_of_Years_Attended__c;
//         caseObj.Unique_Medical_School__c     =   catRecord[0].Student_ID__c;
        
//         return caseObj;
//     }

//     /**
//      * @author: Reshma Ravi
//      * @Modfied by: Chinmay Menon on June 5th 2020 for Bug 5803
//      * @name: updateEVCase
//      * @description: Method to update enrollment verification case and child exam reg cases
//      * @return type: void
//      */
//     public static void updateEVCase(List<Case> newExamRegCases){
//         Id evRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION).getRecordTypeId();
//         Group evQueue = CaseTriggerUtility.groupMap.get(Constants.CASE_QUEUE_ENROLLMENT_VERIFICATION);
//         Map<Id, Case> caseMap = new Map<Id, Case>();
//         Map<Id, Case> evCasesToBeReupdated = new Map<Id, Case> ();
//         List<Contact_Association_Type__c> catRecord   =   new List<Contact_Association_Type__c>();
//         Set<Id> contactIds = new Set<Id>();
//         Set<Id> accountIds = new Set<Id>();
//         Set<Id> account2ServiceSet = new Set<Id>();

//         for(Case newCase : newExamRegCases){
//             catRecord.add(CaseTriggerUtility.catMap.get(newCase.ContactId));
//             contactIds.add(newCase.ContactId);
//             accountIds.add(catRecord[0].Account__c);
//         }
		
//         for(Account2Service__c a2s : [SELECT Id, Account__c FROM Account2Service__c WHERE Account__c IN :accountIds AND Active__c = True]) {
//             account2ServiceSet.add(a2s.Account__c);
//         }
        
//         List<Case> evCases = [SELECT Id, Internal_Status__c, OwnerId, ContactId, AccountId, Enrolled_in_Entity_Portal__c, Account.IsCustomerPortal
//                             FROM Case
//                             WHERE RecordTypeId =: evRTId AND ContactId IN :contactIds AND AccountId IN :accountIds];

//         for(Case newCase : newExamRegCases){
//             newCase = [SELECT Id, ContactId, Enrollment_Verification_Parent__c, Account.IsCustomerPortal FROM Case WHERE Id =: newCase.Id];
//             for(Case evCase : evCases){
//                 for(Contact_Association_Type__c cat : catRecord){
//                     if(newCase.ContactId == evCase.ContactId && cat.Account__c == evCase.AccountId && account2ServiceSet.contains(evCase.AccountId)){
//                         newCase.Enrollment_Verification_Parent__c = evCase.Id;
//                         caseMap.put(newCase.Id, newCase);

//                         Case evCaseToUpdate = new Case();
//                         evCaseToUpdate.Id = evCase.Id;
//                         evCaseToUpdate.Internal_Status__c = Constants.CASE_STATUS_NEW;
//                         evCaseToUpdate.OwnerId = evQueue.Id;
//                         evCaseToUpdate.Enrolled_in_Entity_Portal__c = account2ServiceSet.contains(evCase.AccountId);
//                         evCaseToUpdate.School_Program__c            = cat.School_Program__c;
//                         evCaseToUpdate.Attendance_Start_Date__c     = cat.Start_Date__c;
//                         evCaseToUpdate.Attendance_End_Date__c       = cat.End_Date__c;
//                         //code added by Shailaja. Date format stories.
//                         evCaseToUpdate.Attendance_Start_Month__c     = cat.Start_Month__c;
//                         evCaseToUpdate.Attendance_Start_Year__c     = cat.Start_Year__c;
//                         evCaseToUpdate.Attendance_End_Month__c       = cat.End_Month__c;
//                         evCaseToUpdate.Attendance_End_Year__c       = cat.End_Year__c;
//                         evCaseToUpdate.Graduation_Month__c          = cat.Graduation_Month__c;
//                         evCaseToUpdate.Graduation_Year__c           = cat.Graduation_Year__c;
//                         evCaseToUpdate.Degree_Date__c               = cat.Degree_Issue_Date__c;
//                         //Code added by Shailaja. Dateformat stories.
//                         evCaseToUpdate.Degree_Month__c               = cat.Degree_Issue_Month__c;
//                         evCaseToUpdate.Degree_Year__c               = cat.Degree_Issue_Year__c;

//                         evCaseToUpdate.Number_of_Years_Attended__c  = cat.Number_of_Years_Attended__c;
//                         evCaseToUpdate.Unique_Medical_School__c     = cat.Student_ID__c;
//                         caseMap.put(evCaseToUpdate.Id, evCaseToUpdate);
//                     }
//                 }
//             }
//         }
//         if(!caseMap.isEmpty()){
//             UPDATE caseMap.values();
//         }
        
//         evCasesToBeReupdated = reupdateCaseStatusMethod(caseMap, evCasesToBeReupdated);

//         if(!evCasesToBeReupdated.isEmpty()){
//             UPDATE evCasesToBeReupdated.values();
//         }
//     }

//     /**
//      * @author: Chinmay Menon
//      * @name: reupdateCaseStatusMethod
//      * @description: Method to create a map of enrollment verification cases whose status needs to be reupdated
//      * @Parameters: Case, Map<Id, Case>
//      * @return type: Map<Id, Case>
//      */
//     public static Map<Id, Case> reupdateCaseStatusMethod(Map<Id, Case> caseMap, Map<Id, Case> evCasesToBeReupdatedParam){
//         for(Case loopIteratorCase :[SELECT Id, Enrolled_in_Entity_Portal__c, Internal_Status__c FROM Case WHERE Id IN :caseMap.keySet()]){
//             if(loopIteratorCase.Enrolled_in_Entity_Portal__c && loopIteratorCase.Internal_Status__c != Constants.CASE_STATUS_POSTED_TO_ENTITY_PORTAL){
//                 Case evCaseToReupdate = loopIteratorCase;
//                 evCaseToReupdate.Internal_Status__c = Constants.CASE_STATUS_POSTED_TO_ENTITY_PORTAL;
//                 evCaseToReupdate.External_Status__c = Constants.CASE_EXTERNAL_STATUS_NOT_REVIEWED;
//                 evCaseToReupdate.Status_Not_Reviewed_Date__c = System.today();
//                 evCaseToReupdate.Verification_Status__c = Constants.CASE_VERIFICATION_STATUS_NOT_REVIEWED;
//                 evCasesToBeReupdatedParam.put(loopIteratorCase.Id, evCaseToReupdate);
//                 return evCasesToBeReupdatedParam;
//             }
//         }
//         return evCasesToBeReupdatedParam;
//     }


//     /**
//      * @author: Reshma Ravi
//      * @name: updateSLADate
//      * @description: Method to update SLA date on exam registration
//      * @return type: void
//      */
//     public static void updateSLADate(Set<Id> examRegCaseIds){
//         Id epexRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD).getRecordTypeId();
//         List<Exam_Registration__c> examRegList = new List<Exam_Registration__c>();
//         List<Case> caseList = new List<Case>();
//         for(Case examRegCase : [SELECT Id, CreatedDate, Enrollment_Verification_Parent__c, Enrollment_Verification_Parent__r.Enrolled_in_Entity_Portal__c, 
//                                     (SELECT Id FROM Cases WHERE RecordTypeId = :epexRTId), 
//                                     (SELECT Id, SLA_Date__c, EP_end_Date__c FROM Exam_Registrations__r) 
//                                FROM Case 
//                                WHERE Id IN :examRegCaseIds]){
//             if(!examRegCase.Exam_Registrations__r.isEmpty() && examRegCase.Enrollment_Verification_Parent__c != null){
//                 examRegList = calculateSLADate(examRegCase);
//                 Integer day = examRegList[0].SLA_Date__c.day();
//                 Integer month = examRegList[0].SLA_Date__c.month();
//                 Integer year = examRegList[0].SLA_Date__c.year();

//                 examRegCase.SLA_Date__c = DateTime.newInstance(year, month, day, 23, 00, 00);
//                 caseList.add(examRegCase);
//             }
//         }
//         if(!examRegList.isEmpty()){
//             UPDATE examRegList;
//             UPDATE caseList;
//         }
//     }

//     /**
//      * @author: Reshma Ravi
//      * @name: calculateSLADate
//      * @description: Method to calculate SLA date on exam registration
//      * @return type: List of Exam_Registration__c records
//      */
//     public static List<Exam_Registration__c> calculateSLADate(Case examRegCase){
//         List<Exam_Registration__c> examRegList = new List<Exam_Registration__c>();
//         Exam_Registration__c examReg = new Exam_Registration__c();
//         if(examRegCase.Enrollment_Verification_Parent__r.Enrolled_in_Entity_Portal__c == true){
//             if(!examRegCase.Cases.isEmpty()){
//                 examReg = examRegCase.Exam_Registrations__r[0];
//                 examReg.SLA_Date__c = examReg.EP_end_Date__c.addMonths(2).toStartOfMonth();
//             }
//             else{
//                 examReg = examRegCase.Exam_Registrations__r[0];
//                 examReg.SLA_Date__c = examRegCase.CreatedDate.date().addMonths(12);
//             }
//         }
//         else{
//             if(!examRegCase.Cases.isEmpty()){
//                 examReg = examRegCase.Exam_Registrations__r[0];
//                 examReg.SLA_Date__c = examReg.EP_end_Date__c.addMonths(2).toStartOfMonth().addDays(7);
//             }
//             else{
//                 examReg = examRegCase.Exam_Registrations__r[0];
//                 examReg.SLA_Date__c = examRegCase.CreatedDate.date().addMonths(12).addDays(7);
//             }
//         }
//         examRegList.add(examReg);
//         return examRegList;
//     }

//     /**
//      * @author: Reshma Ravi
//      * @name: updateSLADateEPEx
//      * @description: Method to update SLA date on EPEx
//      * @return type: void
//      */
//     public static void updateSLADateEPEx(Set<Id> examRegCaseIds){
//         Id epexRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD).getRecordTypeId();
//         List<Exam_Registration__c> examRegList = new List<Exam_Registration__c>();
//         List<Case> caseList = new List<Case>();
//         for(Case examRegCase :[SELECT Id, CreatedDate, SLA_Date__c, Enrollment_Verification_Parent__c, Enrollment_Verification_Parent__r.Enrolled_in_Entity_Portal__c, 
//                                     (SELECT Id, SLA_Date__c FROM Cases WHERE RecordTypeId = :epexRTId AND Internal_Status__c = :Constants.CASE_STATUS_PENDING_ENROLLMENT), 
//                                     (SELECT Id, SLA_Date__c, EP_end_Date__c FROM Exam_Registrations__r) 
//                                FROM Case 
//                                WHERE Id IN :examRegCaseIds]){
//             if(!examRegCase.Cases.isEmpty() && !examRegCase.Exam_Registrations__r.isEmpty() && examRegCase.Enrollment_Verification_Parent__c != null){
//                 examRegList = calculateSLADate(examRegCase);
//                 Integer day = examRegList[0].SLA_Date__c.day();
//                 Integer month = examRegList[0].SLA_Date__c.month();
//                 Integer year = examRegList[0].SLA_Date__c.year();

//                 Case epexCase = examRegCase.Cases[0];
//                 epexCase.SLA_Date__c = DateTime.newInstance(year, month, day, 23, 00, 00);
//                 caseList.add(epexCase);
//             }
//         }
//         if(!examRegList.isEmpty()){
//             UPDATE examRegList;
//             UPDATE caseList;
//         }
//     }
//     /**
//      * @author: Ajoydhas
//      * @methodname: systemCheckEVCase
//      * @description: US 3272 - System Check to see if impacted exam reg case(s) can be auto-verified -Scenario 1
//      * @Parameters: evNewCasesList, evOldCasesMap
//      * @return type: no
//      */
//     public static void systemCheckEVCase(List<Case> evNewCasesList, MAP<ID, Case> evOldCasesMap){
//         List<Case> evEnrolledCaseList       =   new List<Case>();       
//         MAP<ID, Case> evEnrolledCaseMap     =   new MAP<ID, Case>();

//         for(Case evNewCase :  evNewCasesList) {
//             // Verification_Status__c = Enrolled, Passed_basic_sciences_course__c = Yes, Entity Portal = true
            
//             if(evNewCase.Verification_Status__c != evOldCasesMap.get(evNewCase.Id).Verification_Status__c &&
//                 evNewCase.Verification_Status__c == Constants.CASE_VERIFICATION_STATUS_ENROLLED && evNewCase.Passed_basic_sciences_course__c == Constants.STATUS_YES && evNewCase.Enrolled_in_Entity_Portal__c == true) {
//                 evEnrolledCaseList.add(evNewCase);
//                 evEnrolledCaseMap.put(evNewCase.Id, evOldCasesMap.get(evNewCase.Id));
//             }       
//         }        
     
//         if(!evEnrolledCaseList.isEmpty()) {
//             systemCheckEVEnrolledCase(evEnrolledCaseList, evEnrolledCaseMap);
//         }      
             
//         systemActionsAfterAffirmations(evNewCasesList,evOldCasesMap);
//         systemCheckRejectedEVCase(evNewCasesList, evOldCasesMap);
//     }   
//     /**
//      * @author: Ajoydhas
//      * @methodname: systemCheckEVEnrolledCase
//      * @description: Method to avoid the Cognitive Complexity (Refactor Method)
//      * @Parameters: newCaseList and oldCaseMap
//      * @return type: no
//      */
//     public static void systemCheckEVEnrolledCase(List<Case> evEnrolledCaseList, Map<Id, Case> evOldCasesMap) {   
//         Id examregRecordTypeId  =   Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
//         Id epexRecordTypeId     =   Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD).getRecordTypeId();
//             map <String,Set<Id>> cibisIdMap = new map <String,Set<Id>> {              
//                     Constants.CIBIS_REGISTRATION_EVENT => new set<Id> (),               
//                     Constants.CIBIS_ELIGIBILITY_EVALUATION_EVENT => new set<Id> ()};
//         List<Case> examRegCaseLists = new List<Case>();
//         Set<ID> evCaseIdSet         =   new Set<ID>();      
//         for(case evEnrolledNewCase : evEnrolledCaseList) {
//             evCaseIdSet.add(evEnrolledNewCase.ID);
//             Case evEnrolledOldCase = evOldCasesMap.get(evEnrolledNewCase.ID);
//             // e. Number of Years Attended  was NOT updated OR (Number of Years Attended  was updated AND Number of Years attended is less than 18 months) 
//             Boolean numberOfYearsAttendedFlag = checkNumberOfYearsAttended(evEnrolledNewCase, evEnrolledOldCase);
            
//             if(evEnrolledNewCase.Attendance_Start_Date__c == evEnrolledOldCase.Attendance_Start_Date__c 
//             && evEnrolledNewCase.Attendance_End_Date__c == evEnrolledOldCase.Attendance_End_Date__c 
//             && evEnrolledNewCase.Graduation_Month__c == evEnrolledOldCase.Graduation_Month__c 
//             && evEnrolledNewCase.Graduation_Year__c == evEnrolledOldCase.Graduation_Year__c
//             && evEnrolledNewCase.Degree_Date__c == evEnrolledOldCase.Degree_Date__c
//             && (evEnrolledNewCase.Number_of_Years_Attended__c == evEnrolledOldCase.Number_of_Years_Attended__c
//             || numberOfYearsAttendedFlag == true)) {
//                 // Exam Reg Cases (All First Time Exam Applications)
//                 for(Case examRegCase : [SELECT Id, Internal_Status__c, ContactId, RecordTypeId
//                                             FROM Case
//                                         WHERE RecordTypeId =: examregRecordTypeId
//                                             AND Enrollment_Verification_Parent__c =: evEnrolledNewCase.ID
//                                             AND Internal_Status__c =: Constants.CASE_STATUS_PENDING_ENROLLMENT]) {
//                     // Update Exam Reg Case with Status as Pending CIBIS
//                     Case examRegCaseUpdate   = examRegCase;
//                     examRegCaseUpdate.Verification_Status__c        =   evEnrolledNewCase.Verification_Status__c;
//                     examRegCaseUpdate.Verification_Status_Month__c  =   evEnrolledNewCase.Verification_Status_Month__c;
//                     examRegCaseUpdate.Verification_Status_Year__c   =   evEnrolledNewCase.Verification_Status_Year__c;
//                     examRegCaseUpdate.Verification_Status_Date__c   =   evEnrolledNewCase.Verification_Status_Date__c;
//                     examRegCaseUpdate.Internal_Status__c            =   Constants.CASE_STATUS_PENDING_CIBIS;
//                     cibisIdMap.get(Constants.CIBIS_REGISTRATION_EVENT).add(examRegCaseUpdate.Id);
//                     examRegCaseLists.add(examRegCaseUpdate);
//                 }

//                 // Check all EPEx Cases under All Exam Registration Cases without any condition
//                 Map<Id, Case> examRegCaseMap =   new Map<Id, Case>([SELECT Id, Internal_Status__c, RecordTypeId, Enrollment_Verification_Parent__c
//                                                 FROM Case
//                                             WHERE RecordTypeId =: examregRecordTypeId
//                                                 AND Enrollment_Verification_Parent__c =: evEnrolledNewCase.Id]);
 
//                 // EPEx Cases (EPEx Applications)
//                 for(Case epexCase : [SELECT Id, Internal_Status__c, RecordTypeId, Exam_Registration__c, Is_Removed_From_EV__c
//                                         FROM Case
//                                     WHERE RecordTypeId =: epexRecordTypeId
//                                         AND ParentId IN : examRegCaseMap.keySet()
//                                         AND Internal_Status__c =: Constants.CASE_STATUS_PENDING_ENROLLMENT]) {
//                     // Update Exam Reg Case with Status as Pending CIBIS
//                     Case epexCaseUpdate   = epexCase;
//                     epexCaseUpdate.Internal_Status__c = Constants.CASE_STATUS_PENDING_CIBIS;
//                     epexCaseUpdate.Is_Removed_From_EV__c = True;
//                     examRegCaseLists.add(epexCaseUpdate);
//                     cibisIdMap.get(Constants.CIBIS_ELIGIBILITY_EVALUATION_EVENT).add(epexCaseUpdate.Id);
//                 }
//             }
//         }
//         // Update Exam Reg Case Status as Pending CIBIS
//         if(!examRegCaseLists.isEmpty()) {
         
//             update examRegCaseLists;  
//             if(cibisIdMap.get(Constants.CIBIS_REGISTRATION_EVENT).size()>0 || cibisIdMap.get(Constants.CIBIS_ELIGIBILITY_EVALUATION_EVENT).size()>0){
//                    system.debug('===cibisIdMap===> ' + cibisIdMap);
//                    CibisRequestUtilityHandler.cibisPlatformEventPublish(cibisIdMap);  
//             }
           
//         }

//         // Updating EV Case Status as Enrollment Verification Complete
//         if(!evCaseIdSet.isEmpty()) {
//             updateEVCaseStatus(evCaseIdSet,new Map<Id,String>());
//         }
//     }
//     /**
//      * @author: Ajoydhas
//      * @methodname: checkNumberOfYearsAttended
//      * @description: Number of Years Attended  was NOT updated OR (Number of Years Attended  was updated AND Number of Years attended is less than 18 months) 
//      * @Parameters: newCase and oldCase
//      * @return type: Boolean true / false
//      */
//     public static Boolean checkNumberOfYearsAttended(Case evEnrolledNewCase, Case evEnrolledOldCase) {
//         Boolean numberOfYearsAttendedFlag = true;
//         if(evEnrolledNewCase.Number_of_Years_Attended__c != evEnrolledOldCase.Number_of_Years_Attended__c) {
//             numberOfYearsAttendedFlag = false;
//             // Getting total of Number of Years Attended
//             Decimal totalNumberOfYearsAttended   =   getTotalNumberOfYearsAttended(evEnrolledNewCase.contactId, evEnrolledNewCase.Number_of_Years_Attended__c);
//             if((totalNumberOfYearsAttended * 12) > Decimal.valueof(System.Label.Number_of_Years_Attended)) {
//                 numberOfYearsAttendedFlag = true;
//             }
//         }
//         return numberOfYearsAttendedFlag;
//     }
//     /**
//      * @author: Ajoydhas
//      * @methodname: getTotalNumberOfYearsAttended
//      * @description: Number of Years Attended should be a total of all schools(degree medical school+other med schools+other institutions)
//      * @Parameters: ContactId, EV Case Number of Years Attended
//      * @return type: Decimal totalNumberOfYearsAttended;
//      */
//     public static Decimal getTotalNumberOfYearsAttended(String contactId, Decimal evCaseNumberOfYearsAttended) {        
//         Decimal totalNumberOfYearsAttended = evCaseNumberOfYearsAttended + getOtherMedSclNumberOfYearsAttended(contactId) + getOtherInstiNumberOfYearsAttended(contactId);
//         return totalNumberOfYearsAttended;
//     }
//     /**
//      * @author: Ajoydhas
//      * @methodname: getOtherMedSclNumberOfYearsAttended
//      * @description: Method to getting the Other Medical School - Number of Years Attended
//      * @Parameters: String contactId
//      * @return type: Decimal otherMedSclNumberOfYearsAttended;
//      */
//     public static Decimal getOtherMedSclNumberOfYearsAttended(String contactId) {
//         Id conAssocTypeRecordTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_MEDICAL_SCHOOL).getRecordTypeId();
//         Decimal otherMedSclNumberOfYearsAttended = 0;
//         List <Contact_Association_Type__c> conAssocMedicalSchoolLists = new List <Contact_Association_Type__c>();
//         conAssocMedicalSchoolLists = [SELECT id, Number_of_Years_Attended__c 
//                                         FROM Contact_Association_Type__c
//                                     WHERE RecordTypeId =: conAssocTypeRecordTypeId
//                                         AND Contact__c =: contactId
//                                         AND Transfer_Credit_to_Degree_School__c = true];
//         if (!conAssocMedicalSchoolLists.isEmpty() && conAssocMedicalSchoolLists[0].Number_of_Years_Attended__c != null) {
//             otherMedSclNumberOfYearsAttended = conAssocMedicalSchoolLists[0].Number_of_Years_Attended__c;
//         }
//         return otherMedSclNumberOfYearsAttended;
//     }
//     /**
//      * @author: Ajoydhas
//      * @methodname: getOtherInstiNumberOfYearsAttended
//      * @description: Method to getting the Other Institution - Number of Years Attended
//      * @Parameters: String contactId
//      * @return type: Decimal otherInstiNumberOfYearsAttended;
//      */
//     public static Decimal getOtherInstiNumberOfYearsAttended(String contactId) {
//         Id conAssocTypeRecordTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_OTHER_INSTITUTION).getRecordTypeId();
//         Decimal otherInstiNumberOfYearsAttended = 0;
//         List <Contact_Association_Type__c> conAssocOtherInstitutionLists = new List <Contact_Association_Type__c>();
//         conAssocOtherInstitutionLists = [SELECT id, Number_of_Years_Attended__c 
//                                         FROM Contact_Association_Type__c
//                                     WHERE RecordTypeId =: conAssocTypeRecordTypeId
//                                         AND Contact__c =: contactId];
//         if (!conAssocOtherInstitutionLists.isEmpty()) {
//             for (Contact_Association_Type__c tempInst: conAssocOtherInstitutionLists) {
//                 if (tempInst.Number_of_Years_Attended__c != null) {
//                     otherInstiNumberOfYearsAttended = otherInstiNumberOfYearsAttended + tempInst.Number_of_Years_Attended__c;
//                 }
//             }
//         }
//         return otherInstiNumberOfYearsAttended;
//     }
//     //Method to update the EV Case Status as Enrollment Verification Complete
//     public static void updateEVCaseStatus(Set<ID> evCaseIdSet,Map<Id,String> evManualRejectedReason) {
//         Id examregRecordTypeId  =   Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
//         Id epexRecordTypeId     =   Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD).getRecordTypeId();
//         List<Case> evCaseList =   new List<Case>();
//         MAP<ID, Case> examRegCaseEnrollMap = new MAP<ID, Case>();
//         MAP<ID, Case> examRegCaseMap = new MAP<ID, Case>();
//         MAP<ID, Case> epexCaseMap = new MAP<ID, Case>();
//         List<Case> examCaseList = new List<Case>();
//         for(Case examRegCaseRecord : [SELECT Id, Internal_Status__c, RecordTypeId, Enrollment_Verification_Parent__c,Manual_Review_Reasons__c
//                                             FROM Case
//                                         WHERE RecordTypeId =: examregRecordTypeId
//                                             AND Enrollment_Verification_Parent__c IN: evCaseIdSet]) {
//             // Exam Reg Case based on without any condition                                    
//             examRegCaseMap.put(examRegCaseRecord.Id, examRegCaseRecord);
//             if(evManualRejectedReason.containsKey(examRegCaseRecord.Enrollment_Verification_Parent__c)){
//                 Case exCase = new Case(Id = examRegCaseRecord.Id);
//                 exCase.Manual_Review_Reasons__c = evManualRejectedReason.get(examRegCaseRecord.Enrollment_Verification_Parent__c);
//                 examCaseList.add(exCase);
//             }
//             List<String> statusList = new List<String>();
//             statusList.add(Constants.CASE_STATUS_PENDING_CIBIS);
//             statusList.add(Constants.CASE_STATUS_REGISTERED);
//             statusList.add(Constants.CASE_STATUS_ENROLLMENT_NOT_VERIFIED_MEDSCL);
//             // Exam Reg Case based on  "Pending CIBIS" or "Registered" or "Enrollment Not Verified At Medical School";
//             if(!statusList.contains(examRegCaseRecord.Internal_Status__c)) {
//                 examRegCaseEnrollMap.put(examRegCaseRecord.Enrollment_Verification_Parent__c, examRegCaseRecord);
//             }     
//         }
//          // EPEx Cases (EPEx Applications)
//         for(Case epexCase : [SELECT Id, Internal_Status__c, RecordTypeId, Exam_Registration__c,ParentId, Enrollment_Verification_Parent__c
//                                             FROM Case
//                                         WHERE RecordTypeId =: epexRecordTypeId
//                                             AND ParentId IN :examRegCaseMap.keySet()
//                                             AND (Internal_Status__c !=: Constants.CASE_STATUS_PENDING_CIBIS
//                                             AND Internal_Status__c !=: Constants.CASE_STATUS_REJECTED
//                                             AND Internal_Status__c !=: Constants.CASE_STATUS_ACCEPTED)]) {            
//             epexCaseMap.put(epexCase.Enrollment_Verification_Parent__c, epexCase);            
//         }
//         for(Case evCase : [SELECT id,Manual_Review_Reasons__c, Internal_Status__c FROM Case WHERE ID IN: evCaseIdSet]) {
//             // Exam Reg Case based on  "Pending CIBIS" or "Registered" or "Enrollment Not Verified At Medical School";  
//             Case examRegCase = examRegCaseEnrollMap.get(evCase.Id);
//             // EPEx Cases (EPEx Applications)
//             Case epexCase = epexCaseMap.get(evCase.Id); 
//             if(examRegCase == null && epexCase == null) {
//                 Case evCaseOBj = new Case();
//                 evCaseOBj.Id = evCase.Id;
//                 evCaseOBj.Internal_Status__c = Constants.CASE_STATUS_ENROLLMENT_VERIFICATION_COMPLETE;
//                 evCaseList.add(evCaseOBj);
//             }   
//         }
//         if(!examCaseList.isEmpty() && Case.SObjectType.getDescribe().isUpdateable()) {
//             update examCaseList;
//         }
//         if(!evCaseList.isEmpty() && Case.SObjectType.getDescribe().isUpdateable()) {
//             update evCaseList;
//         }   
//     }
//     /**
//      * @author: Balashankar
//      * @methodname: sytemCheckEVRejectedFirstSenario
//      * @description: Method to Rejected EV Case
//      * @Parameters: 
//      * @return type: no
//      */
//     public static void sytemCheckEVRejectedFirstSenario(List<Id> evRejectedCaseList,Map<Id,String> evManualRejectedReason) {  
//         List<Case> examRegCaseLists = new List<Case>();        
//         Set<Id> examRegCaseSetIds = new Set<Id>();     
//         Set<ID> evCaseIdSet         =   new Set<ID>();
//         List<Case> epEXCaseList = new List<Case>();        

//         Id examregRecordTypeId  =   Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
//         Id epexRecordTypeId     =   Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD).getRecordTypeId();
//         for(Case examRegCase : [SELECT Id, Internal_Status__c, ContactId, RecordTypeId, Enrollment_Verification_Parent__c,
//                                 Enrollment_Verification_Parent__r.Verification_Status__c,
//                                 Enrollment_Verification_Parent__r.Verification_Status_Month__c,
//                                 Enrollment_Verification_Parent__r.Verification_Status_Year__c,
//                                 Enrollment_Verification_Parent__r.Verification_Status_Date__c
//                                 FROM Case
//                                 WHERE RecordTypeId =: examregRecordTypeId
//                                 AND Enrollment_Verification_Parent__c IN: evRejectedCaseList                            
//                                 ]) {
//                         evCaseIdSet.add(examRegCase.Enrollment_Verification_Parent__c);
//                         examRegCaseSetIds.add(examRegCase.Id); 

//             if (examRegCase.Internal_Status__c == Constants.CASE_STATUS_PENDING_ENROLLMENT
//             && examRegCase.Enrollment_Verification_Parent__r.Verification_Status__c != Constants.CASE_VERIFICATION_DECEASED){
//                 Case examRegCaseUpdate   = new Case(Id = examRegCase.Id);
//                 examRegCaseUpdate.Internal_Status__c = Constants.CASE_STATUS_ENROLLMENT_NOT_VERIFIED_MEDSCL;
//                 examRegCaseUpdate.Verification_Status__c        =   examRegCase.Enrollment_Verification_Parent__r.Verification_Status__c;
//                 examRegCaseUpdate.Verification_Status_Month__c  =   examRegCase.Enrollment_Verification_Parent__r.Verification_Status_Month__c;
//                 examRegCaseUpdate.Verification_Status_Year__c   =   examRegCase.Enrollment_Verification_Parent__r.Verification_Status_Year__c;
//                 examRegCaseUpdate.Verification_Status_Date__c   =   examRegCase.Enrollment_Verification_Parent__r.Verification_Status_Date__c;
//                 examRegCaseLists.add(examRegCaseUpdate);
//             }

//         }
        
//         for(Case epexCase : [SELECT Id, Internal_Status__c, RecordTypeId, Exam_Registration__c, Is_Removed_From_EV__c
//                                         FROM Case
//                                         WHERE RecordTypeId =: epexRecordTypeId
//                                         AND ParentId IN: examRegCaseSetIds
//                                         AND Internal_Status__c =: Constants.CASE_STATUS_PENDING_ENROLLMENT]) {
//                         // Update epex Case as Rejected 
//                         Case epexCaseUpdate   = epexCase;
//                         epexCaseUpdate.Internal_Status__c = Constants.CASE_STATUS_REJECTED;
//                         epexCaseUpdate.Is_Removed_From_EV__c = True;
//                         epEXCaseList.add(epexCaseUpdate);
//         }

//         if(!examRegCaseLists.isEmpty()){
//             update examRegCaseLists;
            
//         }
//         if(!epEXCaseList.isEmpty()){
//             update epEXCaseList;
//         }

//         // Updating EV Case Status as Enrollment Verification Complete
//         if(!evCaseIdSet.isEmpty()) {
//             updateEVCaseStatus(evCaseIdSet,evManualRejectedReason);
//         }       
    
//     }
//     /**
//      * @author: Ajoydhas
//      * @methodname: sytemCheckUpdateExamRegVerificationStatus
//      * @description: Updating Verification Status Enrolled, Deceased and Not Reviewed in Exam Reg Case
//      * @Parameters: 
//      * @return type: no
//      */
//     public static void sytemCheckUpdateExamRegVerificationStatus(List<Id> evVerificationCaseIdList) {  
//         List<Case> examRegCaseLists = new List<Case>();

//         Id examregRecordTypeId  =   Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
//         for(Case examRegCase : [SELECT Id, Internal_Status__c, ContactId, RecordTypeId, Enrollment_Verification_Parent__c,
//                                 Enrollment_Verification_Parent__r.Verification_Status__c,
//                                 Enrollment_Verification_Parent__r.Verification_Status_Month__c,
//                                 Enrollment_Verification_Parent__r.Verification_Status_Year__c,
//                                 Enrollment_Verification_Parent__r.Verification_Status_Date__c
//                                 FROM Case
//                                 WHERE RecordTypeId =: examregRecordTypeId
//                                 AND Enrollment_Verification_Parent__c IN: evVerificationCaseIdList                            
//                                 ]) {
                
//             Case examRegCaseUpdate   = new Case(Id = examRegCase.Id);
//             examRegCaseUpdate.Verification_Status__c        =   examRegCase.Enrollment_Verification_Parent__r.Verification_Status__c;
//             examRegCaseUpdate.Verification_Status_Month__c  =   examRegCase.Enrollment_Verification_Parent__r.Verification_Status_Month__c;
//             examRegCaseUpdate.Verification_Status_Year__c   =   examRegCase.Enrollment_Verification_Parent__r.Verification_Status_Year__c;
//             examRegCaseUpdate.Verification_Status_Date__c   =   examRegCase.Enrollment_Verification_Parent__r.Verification_Status_Date__c;
//             examRegCaseLists.add(examRegCaseUpdate);                
//         }

//         if(!examRegCaseLists.isEmpty()){
//             update examRegCaseLists;            
//         }     
    
//     }
//     /**
//      * @author: Balashankar
//      * @methodname: systemActionsAfterAffirmations
//      * @description: US 1610 - System Actions after Affirmation process is completed
//      * @Parameters: evNewCasesList, evOldCasesMap
//      * @return type: no
//      */
//     public static void systemActionsAfterAffirmations(List<Case> evNewCasesList, MAP<ID, Case> evOldCasesMap){
      
//         Set<Id> evSysActionCaseIdList      =   new Set<Id>();          
 
//         Map<Id,Date> evSignatureDate = new Map<Id,Date>();
//         Map<Id,String> evDefReasonMap = new Map<Id,String>();
//         Id examRegRTId   =   Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();     

//         for(Case evNewCase :  evNewCasesList) {
            
//             if(evNewCase.Internal_Status__c != evOldCasesMap.get(evNewCase.Id).Internal_Status__c && evNewCase.Enrolled_in_Entity_Portal__c == false 
//             && evNewCase.Internal_Status__c == Constants.CASE_STATUS_ENROLLMENT_VERIFICATION_INCOMPLETE) {
//                 evSysActionCaseIdList.add(evNewCase.Id);
//                 evDefReasonMap.put(evNewCase.Id,evNewCase.Deficiency_Reason_RTF__c);
//                 evSignatureDate.put(evNewCase.Id,evNewCase.Signature_Date__c);
//             }
                        
//         }       
        
//         if(!evSysActionCaseIdList.isEmpty()){
        
            
//             systemActionsAfterAffirmationsSonarFix(evSysActionCaseIdList,examRegRTId,evDefReasonMap,evSignatureDate);
//         }
       
//     }

//      /**
//      * @author: Balashankar
//      * @methodname: systemActionsAfterAffirmationsSonarFix
//      * @description: US 1610 - System Actions after Affirmation process is completed
//      * @Parameters: evNewCasesList, evOldCasesMap
//      * @return type: no
//      */
//     public static void systemActionsAfterAffirmationsSonarFix(Set<Id> evSysActionCaseIdList,Id examRegRTId,Map<Id,String> evDefReasonMap,Map<Id,Date> evSignatureDate){
//         List<Case> examCaseList = new List<Case>();               
//         List<Case> sigDateUpdateinExamCase = new List<Case>();
//         Set<Id> examAllCaseIds      =   new Set<Id>(); 
//         for(Case examCase:[Select Id,Enrollment_Verification_Parent__c,Deficiency_Reason_RTF__c,Internal_Status__c,Signature_Date__c,Is_First_time_Exam_Case__c from Case where  
//             Enrollment_Verification_Parent__c IN: evSysActionCaseIdList and RecordTypeId =: examRegRTId]){
                
//             if(examCase.Internal_Status__c == Constants.CASE_STATUS_PENDING_ENROLLMENT || examCase.Is_First_time_Exam_Case__c == True){
//             Case exCaseUpdate   = examCase;
//             examCase.Is_First_time_Exam_Case__c = False;
//             if(evDefReasonMap.containsKey(exCaseUpdate.Enrollment_Verification_Parent__c)){
//                 exCaseUpdate.Deficiency_Reason_RTF__c = evDefReasonMap.get(exCaseUpdate.Enrollment_Verification_Parent__c);
//             }
            
//             exCaseUpdate.Internal_Status__c = Constants.CASE_STATUS_ENROLLMENT_VERIFICATION_INCOMPLETE;
//             exCaseUpdate.Is_First_time_Exam_Case__c = False;
//             examCaseList.add(exCaseUpdate);
//             }
//         examAllCaseIds.add(examCase.Id);
//         }

//         for(Exam_Registration__c examReg:[Select Id,Case__c,Exam_Status__c,Case__r.Id,
//             Case__r.Enrollment_Verification_Parent__c
//             from Exam_Registration__c where Exam_Status__c = '' And Case__r.Id IN:examAllCaseIds]){

//                 Case exSignatureDateCaseUpdate   = new Case (Id=examReg.Case__r.Id);
//                 exSignatureDateCaseUpdate.Signature_Date__c = evSignatureDate.get(examReg.Case__r.Enrollment_Verification_Parent__c);
//                 sigDateUpdateinExamCase.add(exSignatureDateCaseUpdate);

//         }

//            systemActionDMLOperation(examCaseList,sigDateUpdateinExamCase);
//     }

//     /**
//      * @author: Balashankar
//      * @methodname: systemActionDMLOperation
//      * @description: US 1610 - created to perform DML operation for SystemActions
//      * @Parameters: List of cases
//      * @return type: no
//      */
//     public static void systemActionDMLOperation(List<Case> examCaseList,List<Case> sigDateUpdateinExamCase){
//         if(!examCaseList.isEmpty()){
//             update examCaseList;            
//         }
//         if(!sigDateUpdateinExamCase.isEmpty()){
//             update sigDateUpdateinExamCase;            
//         }
//     }
//   /**
//      * @author: Balashankar
//      * @methodname: systemCheckRejectedEVCase
//      * @description: US 3273 - System Check to see if impacted exam reg case(s) can be auto-rejected -Scenario 1
//      * @Parameters: evNewCasesList, evOldCasesMap
//      * @return type: no
//      */
//     public static void systemCheckRejectedEVCase(List<Case> evNewCasesList, MAP<ID, Case> evOldCasesMap) {      
//         List<Id> evRejectedCaseIdList      =   new List<Id>();        
//         List<Id> evVerificationCaseIdList  =   new List<Id>();
//         Map<Id,String> evManualRejectedReason = new Map<Id,String>();
//         for(Case evNewCase :  evNewCasesList) {
//             if(evnewCase.Verification_Status__c != evOldCasesMap.get(evnewCase.Id).Verification_Status__c){
//                 if((evNewCase.Verification_Status__c != Constants.CASE_VERIFICATION_STATUS_ENROLLED && evNewCase.Verification_Status__c != Constants.CASE_VERIFICATION_DECEASED && evNewCase.Verification_Status__c != Constants.CASE_VERIFICATION_STATUS_NOT_REVIEWED) && evNewCase.Enrolled_in_Entity_Portal__c == true){                    
//                     evRejectedCaseIdList.add(evNewCase.Id);
//                     evManualRejectedReason = manualEnrolledRejectedReason(evNewCase);                  
//                  }
//                 else if(evNewCase.Verification_Status__c == Constants.CASE_VERIFICATION_STATUS_ENROLLED && evNewCase.Passed_basic_sciences_course__c == Constants.STATUS_NO
//                 && evNewCase.Enrolled_in_Entity_Portal__c == true) {                    
//                     evRejectedCaseIdList.add(evNewCase.Id);
//                     evManualRejectedReason = manualBasicScienceRejectedReason(evNewCase);
//                 } else {
//                     evVerificationCaseIdList.add(evNewCase.Id);
//                 }
//             }       
//         }       
        
//         if(!evRejectedCaseIdList.isEmpty()){            
//             sytemCheckEVRejectedFirstSenario(evRejectedCaseIdList,evManualRejectedReason);
//         }    
//         // Handling Sonar Cloud issue and to resolve bug US 8740.
//         // Handling Else pasrt for Enrolled, Deceased and Not Reviewed
//         if(!evVerificationCaseIdList.isEmpty()) {
//             sytemCheckUpdateExamRegVerificationStatus(evVerificationCaseIdList);
//         }    
//     }

//     //Helper method for systemCheckRejectedEVCase
//     public static Map<Id,String> manualEnrolledRejectedReason(Case evNewCase){
//         Map<Id,String> evManualRejectedReason = new Map<Id,String>();
//         if(evNewCase.Verification_Status__c != Constants.CASE_VERIFICATION_STATUS_ENROLLED){
                            
//             evManualRejectedReason.put(evNewCase.Id,Constants.CASE_MANUAL_REJECTION_REASON_ENROLLED);
//         }
//         return evManualRejectedReason;
//     }
    
//     //Helper method for systemCheckRejectedEVCase
//     public static Map<Id,String> manualBasicScienceRejectedReason(Case evNewCase){
//         Map<Id,String> evManualRejectedReason = new Map<Id,String>();
//         if(evNewCase.Passed_basic_sciences_course__c == Constants.STATUS_NO){
                            
//             evManualRejectedReason.put(evNewCase.Id,Constants.CASE_MANUAL_REJECTION_REASON_BASIC_SCIENCE);
//         }
//         return evManualRejectedReason;
//     }
//     /**
//      * @author: Ajoydhas
//      * @name: systemManageEPExCases
//      * @description: Method to handling EPEx Cases
//      * @Parameters: 
//      * @return type: void
//      */
//     public static void systemManageEPExCases(List<Case> epexNewCases, MAP<ID, Case> epexOldCasesMap){
//         Set<ID> examRegCaseIdSet    =   new Set<ID>();
//         Set<ID> evCaseIdSet         =   new Set<ID>();
//         // loop for EPEx Cases
//         for(Case epexNewCase : epexNewCases) {
//             if((epexNewCase.Internal_Status__c == Constants.CASE_STATUS_PENDING_CIBIS || epexNewCase.Internal_Status__c == Constants.CASE_STATUS_REJECTED) && epexNewCase.Internal_Status__c != epexOldCasesMap.get(epexNewCase.Id).Internal_Status__c && epexNewCase.ParentId != null) {
//                 examRegCaseIdSet.add(epexNewCase.ParentId); // Adding Exam Reg Case Id
//             }
//         }
//         // loop for Exam Registration Cases
//         for(Case examRegCaseItem : [SELECT Id, Internal_Status__c, ParentId, Enrollment_Verification_Parent__c
//                                         FROM Case 
//                                     WHERE Enrollment_Verification_Parent__c != null 
//                                         AND Id IN :examRegCaseIdSet]) {
//             evCaseIdSet.add(examRegCaseItem.Enrollment_Verification_Parent__c); // Adding Enrollment Verification Case Id
//         }

//         // Updating EV Case Status as Enrollment Verification Complete
//         if(!evCaseIdSet.isEmpty()) {
//             updateEVCaseStatus(evCaseIdSet,new Map<Id,String>());
//         }
//     }
//     /**
//      * @author: Nayana
//      * @name: systemManageERVCases
//      * @description: Method to handle Enrollment Reverification Cases
//      * @Parameters: List of cases
//      * @return type: void
//      */
//     public static void systemManageERVCases(List<Case> ervNewCases){
//         List<Case> ervCaseListToUpdate = new List<Case>();
//         Group ervManualQueue  =   CaseTriggerUtility.groupMap.get(Constants.CASE_QUEUE_MANUAL_REVIEW_ENROLLMENT_RE_VERIFICATION);
        
//         for(Case ervCaseToUpdate : ervNewCases) {
//             ervCaseToUpdate.Internal_Status__c = Constants.CASE_STATUS_PENDING_REVIEW;
//             ervCaseToUpdate.OwnerId = ervManualQueue.Id;
//             ervCaseListToUpdate.add(ervCaseToUpdate);
//         }

//         if(!ervCaseListToUpdate.isEmpty()) {
//             update ervCaseListToUpdate;
//         }
//     }    
}