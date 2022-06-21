/** @name: ContactHandler
*  @description: Define methods to pre-process the data and pass on to helper methods for processing business logic
**/
public with sharing class ContactHandler implements TriggerInterface{  
    private Set<Id> sObjectIdList = new Set<Id>(); 
    private List<SObject> sObjectList = new List<SObject>(); 
    private static boolean hasRunBeforeUpdate = false;
    private static boolean hasRunAfterUpdate = false;
    private static boolean hasRunBeforeInsert = false;
    private static boolean hasRunAfterInsert = false;
    private static boolean hasRunBeforeDelete = false;
    private static boolean hasRunAfterDelete = false;
    private static boolean hasRunAfterUndelete = false;
    public  ContactHandler(){}
    private static Boolean TriggerDisabled = false;
    /* Checks to see if the trigger has been disabled either by custom setting or by running code */
    public Boolean IsDisabled(){
        List<TriggerSettings__mdt> conTrgSetting = [SELECT Disabled__c FROM TriggerSettings__mdt WHERE MasterLabel = 'ContactTrigger'];
        if(conTrgSetting <> null && (conTrgSetting.size()!=0) && conTrgSetting[0].Disabled__c){
            return true;
        }
        else{
            return TriggerDisabled;
        }
    }
    /* Perform preprocessing on data before executing the updates to contacts are committed to database */
    public void beforeInsert(List<sObject> sObjList){
        Map<ID, Schema.RecordTypeInfo> rectypeMap = Schema.SObjectType.Contact.getRecordTypeInfosById();
        //Add code for user story#16988
        Disable_Processes_for_Data_Migration__c dProcessSettings = Disable_Processes_for_Data_Migration__c.getInstance(UserInfo.getProfileId());
        //query the custom setting and get the ECFMG id value stored
        CurrentECFMGIDSequence__c curECFMGSetting = CurrentECFMGIDSequence__c.getOrgDefaults();
        //Boolean flagUpdateSettings = false;

        if(Null != dProcessSettings){
            //check disable triggers
            boolean disableTriggers = dProcessSettings.Disable_Triggers__c; 
            String newSequence; 
            if(disableTriggers == false){
                for(Contact itr:(List<Contact>) sObjList){
                    //Display error if someone manually tries to enter ECFMG ID
                    if(itr.ECFMG_ID__c != null){
                        itr.addError('You are not allowed to enter ECFMG ID manually. It is auto generated.');
                    }
                    if(RecordTypeUtility.getRecordTypeNameById('Contact',itr.RecordTypeId) == Constants.CONTACT_RECORD_TYPE_REG_USR 
                       && itr.AccountId == Label.Default_Portal_Account){
                           itr.MailingStreet = null;
                           itr.MailingCountry = null;
                           itr.MailingState = null;
                           itr.MailingPostalCode = null;
                           itr.MailingCity = null;
                       }
                    string recType = rectypeMap.get(itr.RecordTypeId).getName();
                    if((recType == Constants.CONTACT_RECORD_TYPE_REG_USR || recType == Constants.CONTACT_RECORD_TYPE_APPLICANT || recType == Constants.CONTACT_RECORD_TYPE_IFOM_APP || 
                        recType == Constants.CONTACT_RECORD_TYPE_EICS_APPLICANT || recType == Constants.CONTACT_RECORD_TYPE_ENTITY_CONT || recType == Constants.CONTACT_RECORD_TYPE_ENTITY_USER) 
                       && itr.ECFMG_ID__c == null){
                           String ecfmgId = String.valueOf(curECFMGSetting.get('ECFMG_ID__c'));
                           //build the ecfmg id in the format ECFMG-00000001                
                           String tempValue = 'ECFMG-'+ecfmgId;
                           //set the value for ECFMG id
                        itr.ECFMG_ID__c = tempValue;
                           if(ecfmgId!=null){
                               Integer newValue = Integer.valueOf(ecfmgId.trim())+1;
                               newSequence = (String.valueOf(newValue)).leftpad(8,'0');
                               //update the custom setting with increase by 1
                               curECFMGSetting.ECFMG_ID__c = newSequence;                               
                           }
                       }
                    ContactService.setDuplicateCheckFields(itr);
                }
                //Moved the DML out of For loop
                if(!String.isBlank(newSequence) ){
                    update curECFMGSetting;
                }
            }
        } 
    }   
    /* Perform preprocessing on data before executing the business logic to update the data */
    public void afterInsert(List<sObject> sObjList){
        List<Id> contactIds = new List<Id>();
        //Add code for user story#16988
        Disable_Processes_for_Data_Migration__c dProcessSettings = Disable_Processes_for_Data_Migration__c.getInstance(UserInfo.getProfileId());
        if(Null != dProcessSettings){
            //check disable triggers
            boolean disableTriggers = dProcessSettings.Disable_Triggers__c; 
            if(disableTriggers == false){
                if(!hasRunAfterInsert){
                    for(Contact itr:(List<Contact>) sObjList){
                        if(itr.IndividualId == null){
                            sObjectList.add(itr);
                        }
                    }
                    ContactService.createIndividuals(sObjectList);
                    sObjectList = new List<Contact>();
                    for(Contact itr: (List<Contact>) sObjList){
                        if(RecordTypeUtility.getRecordTypeNameById('Contact', itr.RecordTypeId) == Constants.CONTACT_RECORD_TYPE_REG_USR 
                           && itr.AccountId == Label.Default_Portal_Account){
                               sObjectList.add(itr);
                               contactIds.add(itr.Id);
                           }
                    }
                    if(contactIds.size()>0){
                        ContactService.createUpdateHouseholdAccount(contactIds);
                    }
                    hasRunAfterInsert = true;
                }
            }
        }
    }

    public void beforeUpdate(List<sObject> sObjList, Map<Id, SObject> oldmap){
        //Add code for user story#16988
        Disable_Processes_for_Data_Migration__c dProcessSettings = Disable_Processes_for_Data_Migration__c.getInstance(UserInfo.getProfileId());
        if(Null != dProcessSettings){
            //check disable triggers
            boolean disableTriggers = dProcessSettings.Disable_Triggers__c; 
            if(disableTriggers == false){
                if(!hasRunBeforeUpdate){
                    for(Contact itr : (List<Contact>) sObjList){
                        ContactService.setDuplicateCheckFields(itr);
                    }
                }
            }
        }
    }  
    /* Perform preprocessing on data before executing the business logic to update the data */
    public void afterUpdate(List<sObject> sObjList, Map<Id, SObject> oldmap){
        Id contactRecTypeId = RecordTypeUtility.getRecordTypeIdByName('Contact', Constants.CONTACT_RECORD_TYPE_DEACTIVATE);
        Set<Id> contactIds = new Set<Id>();
        List<Id> contactIdList = new List<Id>();
        Set<Id> contactIdsScrReport = new Set<Id>();
        //Add code for user story#16988
        Disable_Processes_for_Data_Migration__c dProcessSettings = Disable_Processes_for_Data_Migration__c.getInstance(UserInfo.getProfileId());
        if(Null != dProcessSettings){
            //check disable triggers
            boolean disableTriggers = dProcessSettings.Disable_Triggers__c; 
            if(disableTriggers == false){
                if(!hasRunAfterUpdate){
                    for(Contact itr:(List<Contact>) sObjList){
                        Contact oldCon = (Contact)oldmap.get(itr.Id);
                        if(itr.IndividualId != null && (itr.FirstName != oldCon.FirstName 
                                                        || itr.LastName != oldcon.LastName 
                                                        || itr.Birthdate != oldcon.Birthdate)){
                            sObjectList.add(itr);
                                                        }
                        if(itr.RecordTypeId == contactRecTypeId && itr.isDuplicate__c && itr.RecordTypeId != oldCon.RecordTypeId
                           && itr.isDuplicate__c != oldCon.isDuplicate__c){
                               contactIds.add(itr.Id);
                           }
                        //Added for US 8037
                        if(itr.ServicesRestricted__c != NULL && itr.ServicesRestricted__c.contains('Score Reporting - Internal and External') && oldCon.ServicesRestricted__c != NULL && !(oldCon.ServicesRestricted__c.contains('Score Reporting - Internal and External'))){
                            contactIdsScrReport.add(itr.Id);
                        }
                        else if(oldCon.ServicesRestricted__c == NULL && itr.ServicesRestricted__c != NULL && itr.ServicesRestricted__c.contains('Score Reporting - Internal and External')){
                        	contactIdsScrReport.add(itr.Id);
                        }
                    }
                    //Added for US 8037
                    if(!contactIdsScrReport.isEmpty()){
                        updateExamRegForScoreReporting(contactIdsScrReport);
                    }
                    if(!contactIds.isEmpty()){
                        contactIdList.addAll(contactIds);
                        ContactService.deactivateUser(contactIdList);
                    }
                    ContactService.updateIndividuals(sObjectList);
                    hasRunAfterUpdate = true;
                }
            }
        }
    }
    public void beforeDelete(List<sObject> sObjList){}
    public void afterDelete(List<sObject> sObjList){}
    public void afterUndelete(List<sObject> sObjList){}
    //Added for US 8037
    public void updateExamRegForScoreReporting(Set<Id> contIds){
        List<Contact> conList = [SELECT Id, ServicesRestricted__c, (SELECT Id, Exam_Status__c, Withheld_Score__c, Withheld_Reason__c  FROM Exam_Registrations__r WHERE Exam_Status__c = NULL) FROM Contact WHERE Id IN: contIds];
        List<Case> scrRptCaseList =  new List<Case>();
        List<Exam_Registration__c> exmRegList = new List<Exam_Registration__c>();
        Id scrReportRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_SCORE_REPORT).getRecordTypeId();
        Group scrReportCaseQueue = [SELECT Id FROM Group WHERE Type =:Constants.GROUP_TYPE_QUEUE AND DeveloperName =:Constants.CASE_QUEUE_SCORE_REPORTS WITH SECURITY_ENFORCED];
        for(Contact con : conList){
            for(Exam_Registration__c exmReg : con.Exam_Registrations__r){
                exmReg.Withheld_Score__c = TRUE;
                exmReg.Withheld_Reason__c = 'Applicant Restricted';
                exmRegList.add(exmReg);
                Case scrRptCase = new Case();
                scrRptCase.RecordTypeId = scrReportRecordTypeId;
                scrRptCase.Internal_Status__c = 'New';
                scrRptCase.ContactId = con.Id;
                scrRptCase.Exam_Registration__c = exmReg.Id;
                scrRptCase.OwnerId = scrReportCaseQueue.Id; 
                scrRptCaseList.add(scrRptCase);
            }
        }
        if(scrRptCaseList.size() > 0){
            insert scrRptCaseList;
        }
        if(exmRegList.size() > 0){
            update exmRegList;
        }
    }
}