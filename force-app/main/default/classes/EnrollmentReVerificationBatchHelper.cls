public with sharing class EnrollmentReVerificationBatchHelper {
     
    // @description: Method to get Contact Associtation Type Record (Degree Medical School)
    public static Map<Id, Contact_Association_Type__c> getContactAssociationType(Set<Id> contactIdSet) {
    // Record Type -> Degree_Medical_School
    Id degMedSchRecordTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL).getRecordTypeId();        
    Map<Id, Contact_Association_Type__c> contactCatsMap = new Map<Id, Contact_Association_Type__c>();

    for (Contact_Association_Type__c catRecord : [SELECT School_Program__c, Graduation_Month__c, Graduation_Year__c, Start_Date__c, 
        End_Date__c, Graduation_Date__c, Degree_Issue_Date__c, Status__c, Contact__c, Account__c, Number_of_Years_Attended__c,Start_Month__c,Start_Year__c,
        End_Month__c,End_Year__c,Degree_Issue_Month__c, Degree_Issue_Year__c
        FROM Contact_Association_Type__c 
        WHERE Contact__c IN: contactIdSet
        AND RecordTypeId =: degMedSchRecordTypeId]) {
            if(!contactCatsMap.containsKey(catRecord.Contact__c)) {
                contactCatsMap.put(catRecord.Contact__c,catRecord);
            }
        }
        return contactCatsMap;
    }  
    
    //description: Method to create Enrollment Re-Verification
    public static List<Case> createEVCaseObject(String queueId, Map<Id, Contact_Association_Type__c> contactCatsMap) {
        Id enrollVerRecordTypeId       =   Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_REVERIFICATION).getRecordTypeId();
        List<Case> ervCasesToInsert = new List<Case>();

        for(Id contactId : contactCatsMap.keySet()) {
            Case caseObj = new Case();
            caseObj.ContactId                   =   contactId;                
            caseObj.RecordTypeId                =   enrollVerRecordTypeId;
            caseObj.Internal_Status__c          =   Constants.CASE_STATUS_NEW;
            caseObj.OwnerId                     =   queueId;
            caseObj.AccountId                   =   contactCatsMap.get(contactId).Account__c;
            caseObj.School_Program__c           =   contactCatsMap.get(contactId).School_Program__c;
            caseObj.Attendance_Start_Date__c    =   contactCatsMap.get(contactId).Start_Date__c;
            caseObj.Attendance_End_Date__c      =   contactCatsMap.get(contactId).End_Date__c;
            //Code added by Shailaja. Date Format stories.
            caseObj.Attendance_Start_Month__c    =   contactCatsMap.get(contactId).Start_Month__c;
            caseObj.Attendance_Start_Year__c    =   contactCatsMap.get(contactId).Start_Year__c;
            caseObj.Attendance_End_Month__c      =   contactCatsMap.get(contactId).End_Month__c;
            caseObj.Attendance_End_Year__c      =   contactCatsMap.get(contactId).End_Year__c;

            caseObj.Graduation_Month__c         =   contactCatsMap.get(contactId).Graduation_Month__c;
            caseObj.Graduation_Year__c          =   contactCatsMap.get(contactId).Graduation_Year__c;
            caseObj.Degree_Date__c              =   contactCatsMap.get(contactId).Degree_Issue_Date__c;
            //Code added by Shailaja. Date Format stories.
            caseObj.Degree_Month__c              =   contactCatsMap.get(contactId).Degree_Issue_Month__c;
            caseObj.Degree_Year__c              =   contactCatsMap.get(contactId).Degree_Issue_Year__c;

            caseObj.Number_of_Years_Attended__c =   contactCatsMap.get(contactId).Number_of_Years_Attended__c;
            ervCasesToInsert.add(caseObj);
        }
        return ervCasesToInsert;
    } 
   
    //description: Method to update Asset with Enrollment Re-Verification Case
    public static void updateERVAsset(Map<Id,Case> contReVerifCaseNewMap) {
        List<Asset> assetsToUpdate = new List<Asset>();
        for(Asset ervAssetObj : [SELECT Id, Type__c, Enrollment_Reverification_Case__c, ContactId
                                FROM Asset 
                                WHERE Type__c = 'Photo'
                                AND ContactId IN: contReVerifCaseNewMap.keySet()
                                AND status != :constants.ASSET_STATUS_MARKED_FOR_DELETION]) {
            ervAssetObj.Enrollment_Reverification_Case__c = contReVerifCaseNewMap.get(ervAssetObj.ContactId).Id;
            assetsToUpdate.add(ervAssetObj);
        }
        
        if(!assetsToUpdate.isEmpty()) {
            Database.update(assetsToUpdate);
        }
    } 

    //@description: Method to filter the cases with exam registration signature date and start date validations.
    public static Set<Id> checkSignDateEPStartDate(List<Case> caseList, Map<Id, Exam_Registration__c> contactExamRegMap) {
        Set<Id> contactIdSet = new Set<Id>();
        Date todaysDate = System.Today();

        for(Case c : caseList) {
            if(contactExamRegMap.get(c.Id) != null && c.Enrollment_Verification_Parent__r.Signature_Date__c.addMonths(4) < contactExamRegMap.get(c.Id).EP_start_Date__c 
                && contactExamRegMap.get(c.Id).EP_start_Date__c == todaysDate) {
                contactIdSet.add(c.ContactId);
            }
        }
        return contactIdSet;
    } 
    

}