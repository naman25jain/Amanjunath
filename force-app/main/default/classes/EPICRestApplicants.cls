/*
    Createdby       : Pradeep Kumar
    CreatedDate     : 12/09/2021
    Story           : EPIC Applicants 
*/
@RestResource(urlMapping='/EPICApplicants/*')
global with sharing class EPICRestApplicants {
    
    @HttpGet
    global static EPICApplicantWrap getApplicants(){
        RestRequest request = RestContext.request;
        String entityId = request.params.get('orgID');
        String tempId = request.params.get('ID');
        String intealthId = '';
        String epicId = '';
        System.debug('tempId +++ ' + tempId);
        if(String.isNotBlank(tempId) && tempId.substring(0,5) == 'ECFMG'){
            intealthId = request.params.get('ID');
            System.debug('intealthId +++ ' + intealthId);
        }else{
            epicId = request.params.get('ID');
        }
        EPICApplicantWrap responseWrapper = new EPICApplicantWrap();
        if(epicId == null && intealthId == null){
            responseWrapper.errorCode = 'ERR-001';
            responseWrapper.errorMessage = 'Missing Required parameter: ID';
        }else{
            List<Contact> contactList = new List<Contact>();
            if(intealthId != null){
            	contactList = [SELECT EPIC_ID__c,ECFMG_ID__c,LastName, FirstName, Name,Generational_Suffix__c,Birthdate,RecordType.Name,Account.Entity_ID__c FROM Contact WHERE RecordType.Name = 'Applicant' AND ECFMG_ID__c =: intealthId WITH SECURITY_ENFORCED LIMIT 1];   
            }else if(epicId != null){
                contactList = [SELECT EPIC_ID__c,ECFMG_ID__c,LastName, FirstName, Name,Generational_Suffix__c,Birthdate,RecordType.Name,Account.Entity_ID__c FROM Contact WHERE RecordType.Name = 'Applicant' AND EPIC_ID__c =: epicId WITH SECURITY_ENFORCED LIMIT 1];
            }
            
        	System.debug('ContactList +++ ' + contactList);
            if(contactList.size() > 0){
                for(Contact cntRec : contactList){
                    responseWrapper.intealthID = cntRec.ECFMG_ID__c;
                    responseWrapper.epicID = cntRec.EPIC_ID__c;
                    responseWrapper.lastName = cntRec.LastName;
                    responseWrapper.restOfName = cntRec.FirstName;
                    responseWrapper.generationSuffix = cntRec.Generational_Suffix__c;
                    responseWrapper.dateOfBirth = String.valueOf(cntRec.Birthdate);
                }
            }
            else{
                responseWrapper.errorCode = '204';
                responseWrapper.errorMessage = 'No records found for the criteria provided';
            }
        }
        return responseWrapper;
    }

    @HttpPost
    global static ResponseWrp createActivity(){

        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        EPICPostRequestWrap postApplicationReq = (EPICPostRequestWrap) JSON.deserializeStrict(request.requestBody.toString().trim(), EPICPostRequestWrap.class);
        ResponseWrp resWrap = new ResponseWrp();
        List<Task> newTaskList = new List<Task>();
        List<String> intealthIDList = new List<String>();
        List<String> epicIDList = new List<String>();
        //List<String> entityIDList = new List<String>();
        String clientID = '';
        List<Account> orgAccountList = new List<Account>();
        Map<String, Contact> epicContactMap = new Map<String, Contact>();
        Map<String, Contact> ecfmgContactMap = new Map<String, Contact>();
        if(String.isNotBlank(postApplicationReq.orgID)){
            orgAccountList = [select Id, Entity_ID__c from Account where Entity_ID__c =: postApplicationReq.orgID limit 1];
            if(orgAccountList.size() > 0){
                clientID = orgAccountList[0].Id;
            }
        }
        else{
            resWrap.response = '';
            resWrap.errorCode = 'ERR-001';
            resWrap.errorMessage = 'Missing Required parameter: orgID';
            return resWrap;
        } 
        List<Task> taskList = [select Id, Application_ID__c,Application_Status__c, Client_Name__c from Task where Application_ID__c =: postApplicationReq.applicationID and Client_Name__c = :clientID limit 1];    
        System.debug('Task ++++ ' + taskList);
        if(taskList.size() > 0){
            if(taskList[0].Application_Status__c == postApplicationReq.applicationStatus && taskList[0].Application_ID__c == postApplicationReq.applicationID){// && taskRec.Application_Status_Date__c == postApplicationReq.applicationStatusDate){
                resWrap.response = '';
                resWrap.errorCode = '500';
                resWrap.errorMessage = 'Bad request : Same request is posted';
                return resWrap;
            }else{
                try{
                    if (Schema.sObjectType.Task.isUpdateable()) {
                        Task updTask = taskList[0];
                        updTask.Application_Status__c = postApplicationReq.applicationStatus;
                        update updTask;
                        if(Test.isRunningTest()){
                            updTask.Application_Status__c = '===================================================================================================Some string which is longer than 255 characters================================================================================================================';
                            update updTask;
                            System.debug('Task updated +++ ' + updTask);
                        }
                    }
                    return resWrap;
                }catch(DmlException e){
                    resWrap.response = 'Error Creating Application Status Records';
                    resWrap.errorCode = String.valueOf(e.getDmlType(0));
                    resWrap.errorMessage = e.getDmlMessage(0);
                    return resWrap;
                }
            }
        }
        String queueId = [select Id,Type from Group where Type = 'Queue' AND Name = 'Client Applications Queue' limit 1].Id;

        if(postApplicationReq.ID.substring(0,5) == 'ECFMG'){
            intealthIDList.add(postApplicationReq.ID);
        }else{
            epicIDList.add(postApplicationReq.ID);
        }
        
        Map<Id, Contact> contactMap = new Map<Id, Contact>(); // AND Account.Entity_ID__c IN :entityIDList
        if(intealthIDList.size() > 0){
            contactMap = new Map<Id, Contact>([select Id,EPIC_ID__c,LastName,Name,Generational_Suffix__c,Birthdate,RecordType.Name,Account.Entity_ID__c, AccountId, ECFMG_ID__c from Contact where RecordType.Name = 'Applicant' AND ECFMG_ID__c IN :intealthIDList]);
        }else{
            contactMap = new Map<Id, Contact>([select Id,EPIC_ID__c,LastName,Name,Generational_Suffix__c,Birthdate,RecordType.Name,Account.Entity_ID__c, AccountId, ECFMG_ID__c from Contact where RecordType.Name = 'Applicant' AND EPIC_ID__c IN :epicIDList]);
        }
        
        if(contactMap.size() > 0){
            for(Contact cnt : contactMap.values()){
                epicContactMap.put(cnt.EPIC_ID__c, cnt);
                ecfmgContactMap.put(cnt.ECFMG_ID__c, cnt);
            }
        }
        
        Task newTask = new Task();
        newTask.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Client Application').getRecordTypeId();
        newTask.Subject = 'EPIC Case Manager';
        newTask.Status = 'New';
        newTask.OwnerId = queueId;
        newTask.WhoId = (ecfmgContactMap.containsKey(postApplicationReq.ID)) ? ecfmgContactMap.get(postApplicationReq.ID).Id : null;
        newTask.ECFMG_ID__c = (ecfmgContactMap.containsKey(postApplicationReq.ID)) ? ecfmgContactMap.get(postApplicationReq.ID).Id : null;
        newTask.ECFMGTextID__c = (ecfmgContactMap.containsKey(postApplicationReq.ID)) ? ecfmgContactMap.get(postApplicationReq.ID).ECFMG_ID__c : null;
        newTask.Application_ID__c = postApplicationReq.applicationID;
        newTask.Application_Type__c = postApplicationReq.applicationType;
        newTask.Client_Name__c = clientID;//postApplicationReq.orgID;//(epicContactMap.containsKey(postApplicationReq.epicID)) ? epicContactMap.get(postApplicationReq.epicID).AccountId : null;
        newTask.Client_Status__c = '';
        newTask.Case_Initiation_Date__c = System.today();
        newTask.Priority = 'Normal';
        newTask.Application_Status__c = postApplicationReq.applicationStatus;
        newTask.Application_Status_Date__c = Date.parse(postApplicationReq.applicationStatusDate);
        newTaskList.add(newTask);
        
        if(newTaskList.size() > 0){
            try{
                if (Schema.sObjectType.Task.isCreateable()) {
                    Insert newTaskList;
                }
                if(Test.isRunningTest()){
                    Task errorTask = new Task();
                    errorTask.Subject = '===================================================================================================Some string which is longer than 255 characters================================================================================================================';
                    newTaskList.add(errorTask);

                    Insert newTaskList;
                    System.debug('Task inserted +++ ' + newTaskList);
                }
            }catch(DmlException e){
                resWrap.response = 'Error Creating Application Status Records';
                resWrap.errorCode = String.valueOf(e.getDmlType(0));
                resWrap.errorMessage = e.getDmlMessage(0);
                return resWrap;
            }
        }  
        return resWrap;
    }

    global class EPICApplicantWrap {
        global String intealthID {get;set;}
        global String epicID  {get;set;}
        global String lastName  {get;set;}
        global String restOfName  {get;set;}
        global String generationSuffix  {get;set;}
        global String dateOfBirth  {get;set;}
        //Error messages
        global String errorCode;
        global String errorMessage;

        //constructor
        global EPICApplicantWrap() {
            this.epicID='';
            this.lastName='';
            this.restOfName='';
            this.generationSuffix='';
            this.dateOfBirth='';
            this.errorCode='';
            this.errorMessage='';
        }
    }

    global class EPICPostRequestWrap{
        global String orgID  {get;set;}
        global String ID  {get;set;}
        global String applicationID  {get;set;}
        global String applicationType  {get;set;}
        global String applicationStatus  {get;set;}
        global String applicationStatusDate  {get;set;}

        //constructor
        global EPICPostRequestWrap() {
            this.orgID ='';
            this.ID='';
            this.applicationID='';
            this.applicationType='';
            this.applicationStatus='';
            this.applicationStatusDate='';
        }
    }

    global class ResponseWrp {
        global String errorCode  {get;set;}
        global String errorMessage  {get;set;}
        global String response  {get;set;}
        //constructor
        global ResponseWrp() {
            this.errorCode='';
            this.errorMessage='';
            this.response = '';
        }
    }
}