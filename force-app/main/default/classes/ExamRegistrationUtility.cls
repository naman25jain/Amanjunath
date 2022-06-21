/**
    * @author: Reshma Ravi
    * @name: ExamRegistrationUtility 
    * @description: Utility class for Exam Registration process
    * @createdDate: 17-Jun-2020
**/
public with sharing class ExamRegistrationUtility {
    /**
     * @author: Reshma
     * @name: contactRecord
     * @description: Variable to query contact of current user
     */
    public static Contact contactRecord {
        get {
            if (contactRecord == null) {
                contactRecord = [SELECT Id, MailingCountry, School_Enrollment_Status__c 
                                FROM Contact 
                                WHERE Id IN (SELECT contactId FROM User WHERE Id = :UserInfo.getUserId()) 
                                LIMIT 1];
            }
            return contactRecord;
        }
        set;
    }
}