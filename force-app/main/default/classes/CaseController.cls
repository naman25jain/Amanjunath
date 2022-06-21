/**
    *   Sampath Karnati 
    * * Generic class with methods for case standard object
     * ? Exposed as Public
     * Include all the Get/Save methods related to case standard object
     */
    public with sharing class CaseController extends BaseController{
        static final String UNABLE_TO_INSERT_CASE_COMMENT = 'Unable to insert case comment';
        static final String UNABLE_TO_UPDATE_CASE_STATUS = 'Unable to update case status';
        @AuraEnabled
        public static boolean updateCaseStatus(Id id, string status){
            try{
                List<Case> caseToUpdate =  [SELECT Internal_Status__c
                                            FROM Case
                                            WHERE Id =: id
                                            WITH SECURITY_ENFORCED
                                           ];
                if(!caseToUpdate.isEmpty()){
                    caseToUpdate[0].Internal_Status__c = status;
                    SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPDATABLE, caseToUpdate);
                    Update securityDecision.getRecords();
                    return true;
                }     
            return false;       
            }
            catch(NoAccessException e){
                throw e; 
            }
            catch(Exception e){
                throw e; 
            }
        }
        @AuraEnabled
        public static boolean insertCaseComment(List<CaseComment> caseComments){
            try{
                SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE, caseComments);
                Insert securityDecision.getRecords();
                return true;        
            }
            catch(Exception e){
                throw e; 
            }
        }
        @AuraEnabled(cacheable=true)
        public static Case getCaseContact(Id caseId){
            try{
                List<Case> caseContacts = [SELECT ContactId, AccountId
                                            FROM case
                                            WHERE Id =: caseId
                                            WITH SECURITY_ENFORCED];
                if(!caseContacts.isEmpty()){
                    return caseContacts[0];
                }    
            }
            catch(Exception e){
                throw e; 
            }
            return null;
        }
        @AuraEnabled(cacheable=true)
        public static Case getCaseDetail(Id caseId){
            try{
                List<Case> caseDetails = [SELECT Id, Case_Type__c, Parent.ContactId, RecordType.DeveloperName, ContactId, AccountId, RecordType.Name, Exam_Registration__c, Exam_Type__c, Exam_Region_Surcharge__c, Send_Method__c, Internal_Status__c, Case_Outcome__c
                                            FROM case
                                            WHERE Id =: caseId
                                            WITH SECURITY_ENFORCED];
                if(!caseDetails.isEmpty()){
                    return caseDetails[0];
                }    
            }
            catch(Exception e){
                throw e; 
            }
            return null;
        }
    }