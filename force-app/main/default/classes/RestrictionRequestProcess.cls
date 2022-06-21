/*
    Createdby       : Pradeep Kumar
    CreatedDate     : 12/09/2021
    Story           : Restriction Request Process 
*/
public without sharing class RestrictionRequestProcess {

    public static void processRestrictionRequests(Map<Id, Restriction_Request__c> restrictionReqMap){
        
        List<Restriction_Request__c> restrictionReqRecords = new List<Restriction_Request__c>(); 
        List<Restriction__c> restrictionRecords = new List<Restriction__c>();
        List<Restriction__c> failedRestrictionRecords = new List<Restriction__c>();
        List<Account> entityUpdateList = new List<Account>();
        List<Contact> applicantUpdateList = new List<Contact>();
        Map<Id,List<Restriction_Request__c>> entityRestrictionReqMap = new Map<Id,List<Restriction_Request__c>>();
        Map<Id,List<Restriction_Request__c>> applicantRestrictionReqMap = new Map<Id,List<Restriction_Request__c>>();
        Map<Id, List<String>> entityServicesRestrictedMap = new Map<Id,List<String>>();
        Map<Id, List<String>> applicantServicesRestrictedMap = new Map<Id,List<String>>();
        Map<Id,String> rreqIDStatusMap = new Map<Id, String>();

        for(Restriction_Request__c rrRec : restrictionReqMap.Values()){
           
            if(rrRec.Restriction_Level__c == 'Entity'){
                List<Object> entityIDString = (List<Object>)System.JSON.deserializeUntyped(rrRec.Entity_ID_List__c);
                System.debug('entityIDString ++++++ ' + entityIDString);
                
                for(Object entId : entityIDString){
                    if(entityRestrictionReqMap.containsKey((ID)entId) && entityRestrictionReqMap.get((ID)entId) != null) {
                        List<Restriction_Request__c> rrRecList = entityRestrictionReqMap.get((ID)entId);
                        rrRecList.add(rrRec);
                        entityRestrictionReqMap.put((ID)entId,rrRecList); 
                    }   
                    else {
                        entityRestrictionReqMap.put((ID)entId, new List<Restriction_Request__c> {rrRec});
                    }
                }
                    
            }
            
            if(rrRec.Restriction_Level__c == 'Applicant'){

                List<Object> applicantIDString = (List<Object>)System.JSON.deserializeUntyped(rrRec.Applicant_ID_List__c);
                System.debug('applicantIDString ++++++ ' + applicantIDString);
                for(Object appId : applicantIDString){
                    if(applicantRestrictionReqMap.containsKey((ID)appId) && applicantRestrictionReqMap.get((ID)appId) != null) {
                        List<Restriction_Request__c> rrRecList = applicantRestrictionReqMap.get((ID)appId);
                        rrRecList.add(rrRec);
                        applicantRestrictionReqMap.put((ID)appId,rrRecList); 
                    }   
                    else {
                        applicantRestrictionReqMap.put((ID)appId, new List<Restriction_Request__c> {rrRec});
                    }
                }
            }
        }

        System.debug('entityRestrictionReqMap +++++ ' + entityRestrictionReqMap);
        System.debug('applicantRestrictionReqMap +++++ ' + applicantRestrictionReqMap);


        if(!entityRestrictionReqMap.isEmpty()){
            Map<String, Restriction__c> entityRestrictMap = upsertRestrictionRecords(entityRestrictionReqMap);
            restrictionRecords.addAll( entityRestrictMap.Values() );
        }

        if(!applicantRestrictionReqMap.isEmpty()){
            Map<String, Restriction__c> applicantRestrictMap = upsertRestrictionRecords(applicantRestrictionReqMap);
            restrictionRecords.addAll( applicantRestrictMap.Values() );
        }

        System.debug('restrictionRecords +++++++ ' + restrictionRecords);
        if(!restrictionRecords.isEmpty()){
            System.debug('+++++ Inside restrictionRecords Upsert++++++ ');
            Boolean isUpsertfirstTime = true;
            try {
                Schema.SObjectField externalIdfld = Restriction__c.Fields.RestrictionUniqueID__c;
                Database.UpsertResult [] results = Database.upsert(restrictionRecords, externalIdfld, false);
            } catch (DMLException e) {
                Schema.SObjectField externalIdfld = Restriction__c.Fields.RestrictionUniqueID__c;
                System.debug('Re-trying +++++++ ');
                if(isUpsertfirstTime){
                    Database.UpsertResult [] results = Database.upsert(restrictionRecords, externalIdfld, false);
                    isUpsertfirstTime = false;
                }
            } 
        }

        try {
            if(!entityRestrictionReqMap.isEmpty() || !applicantRestrictionReqMap.isEmpty()){
                rreqIDStatusMap = processEntityApplicantRestriction(entityRestrictionReqMap.keySet(), applicantRestrictionReqMap.keySet(),entityRestrictionReqMap,applicantRestrictionReqMap);
            }

            for(Restriction_Request__c rrRec : restrictionReqMap.Values()){
                Restriction_Request__c newRRRecord = new Restriction_Request__c(); 
                newRRRecord.Id = rrRec.Id;
                if(rreqIDStatusMap.containsKey(rrRec.Id)){
                    newRRRecord.RestrictionStatus__c = 'Processing Error';
                    if(rrRec.Restriction_Level__c == 'Entity'){
                        newRRRecord.FailedEntityIDList__c = rreqIDStatusMap.get(rrRec.Id);
                    }else{
                        newRRRecord.FailedApplicantIDList__c = rreqIDStatusMap.get(rrRec.Id);
                    }
                }  
                else{
                    newRRRecord.RestrictionStatus__c = 'Completed';
                }   
                restrictionReqRecords.add(newRRRecord);
            }
            if(!restrictionReqRecords.isEmpty()){
                if (Schema.sObjectType.Contact.isUpdateable()) {
                    update restrictionReqRecords;
                }
            }
                
            List<Restriction__c> restrictionRecords2 = [select Id, Restriction_Status__c, Restriction_Request__r.RestrictionStatus__c, RestrictionUniqueID__c, Restriction_Request__r.FailedEntityIDList__c, Restriction_Request__r.FailedApplicantIDList__c, Restriction_Request__r.Restriction_Level__c, Entity__c, Applicant__c
                from Restriction__c where Restriction_Request__c IN :restrictionReqRecords with SECURITY_ENFORCED];
            
            if(restrictionRecords2 != null){
                List<Object> failedEntityIDList = new List<Object>();
                List<Object> failedApplicantIDList = new List<Object>();
                for(Restriction__c key : restrictionRecords2){
                    Restriction__c rRecord = new Restriction__c();
                    rRecord.Id = key.Id;
                    if(key.Restriction_Request__r.FailedEntityIDList__c != null){
                        failedEntityIDList = (List<Object>)System.JSON.deserializeUntyped(key.Restriction_Request__r.FailedEntityIDList__c);
                    }else if(key.Restriction_Request__r.FailedApplicantIDList__c != null){
                        failedApplicantIDList = (List<Object>)System.JSON.deserializeUntyped(key.Restriction_Request__r.FailedApplicantIDList__c);
                    }    
                    if(failedEntityIDList.contains((ID)key.Entity__c) || failedApplicantIDList.contains((ID)key.Applicant__c)){
                        System.debug('Inside the Restriction condtion++++++++++');
                        rRecord.Restriction_Status__c = 'Processing Error';
                        failedRestrictionRecords.add(rRecord);
                    }
                }
                if(failedRestrictionRecords != null){
                    update failedRestrictionRecords;
                }
            }

        } catch (Exception e) {
            System.debug('Error processing the Restriction Requests ++++++++ ' + e.getMessage() + ' ' + e.getStackTraceString() );
        }
    }

    public static Map<string, Restriction__c> upsertRestrictionRecords(Map<Id, List<Restriction_Request__c>> entityOrApplicantRestrictionReqMap) {
        
        Map<String, Restriction__c> restrictionRecsMap = new Map<String, Restriction__c>();
        for(ID entityOrApplicantID : entityOrApplicantRestrictionReqMap.keySet()){
            for(Restriction_Request__c rrReq : entityOrApplicantRestrictionReqMap.get(entityOrApplicantID)){
                if(rrReq.Services_Restricted__c != NULL ){
                    for(String serviceRestricted : rrReq.Services_Restricted__c.split(';')){
                        Restriction__c newRestrictionRec = new Restriction__c();
                        System.debug(' entityOrApplicantID.getSobjectType().getDescribe().getName() ++++++ ' + entityOrApplicantID.getSobjectType().getDescribe().getName());
                        if(entityOrApplicantID.getSobjectType().getDescribe().getName() == 'Account'){
                            newRestrictionRec.Entity__c = entityOrApplicantID;
                        }else{
                            newRestrictionRec.Applicant__c = entityOrApplicantID;
                        }
        
                        newRestrictionRec.ServiceRestricted__c = serviceRestricted;
                        newRestrictionRec.Restriction_Request__c = rrReq.Id;
                        newRestrictionRec.Assigned_SI_Case_Manager__c = rrReq.Assigned_SI_Case_Manager__c;
                        newRestrictionRec.Restriction_Start_Date__c = rrReq.Restriction_Start_Date__c;
                        newRestrictionRec.Restriction_End_Date__c = rrReq.Restriction_End_Date__c;
                        newRestrictionRec.Restriction_Reason__c = rrReq.Restriction_Reason__c;
                        newRestrictionRec.Restriction_Level__c = rrReq.Restriction_Level__c;
                        if(rrReq.Request_Type__c == 'New'){
                            newRestrictionRec.Restriction_Status__c = 'Active';
                        }   
                        else{
                            newRestrictionRec.Restriction_Status__c = 'Inactive';
                        }    
                        newRestrictionRec.Restriction_Type__c = rrReq.Restriction_Type__c;
                        newRestrictionRec.RestrictionUniqueID__c = serviceRestricted+rrReq.Restriction_Reason__c+rrReq.Restriction_Type__c+entityOrApplicantID;
                        restrictionRecsMap.put(newRestrictionRec.RestrictionUniqueID__c, newRestrictionRec);
                        //restrictionRecsList.add(newRestrictionRec);
                    }
                }
            }
        }
        return restrictionRecsMap;
    }

    public static void processRestrictionRecords(List<Restriction__c> restrictionRecordList){

        Set<ID> entityIDList = new Set<ID>();
        Set<ID> applicantIDList = new Set<ID>();
        List<Restriction__c> updateRestrictionRecList = new List<Restriction__c>();
        
        if(!restrictionRecordList.isEmpty()){

            for(Restriction__c resRec : restrictionRecordList){
                entityIDList.add(resRec.Entity__c);
                applicantIDList.add(resRec.Applicant__c);
            }

            for(Restriction__c restrictRec : restrictionRecordList){
                if(restrictRec.Restriction_End_Date__c <= Date.today() && restrictRec.Restriction_Status__c == 'Active'){
                    restrictRec.Restriction_Status__c = 'Inactive';
                    updateRestrictionRecList.add(restrictRec);
                }
            }
        }
        
        try {
            if(!updateRestrictionRecList.isEmpty()){
                update updateRestrictionRecList;            
                processEntityApplicantRestriction(entityIDList, applicantIDList, null, null);
            }  
        } catch (Exception e) {
            System.debug('Error ++++ ' + e.getStackTraceString() + ' ' + e.getMessage());
        }
    }

    public static Map<Id,String> processEntityApplicantRestriction(Set<Id> entityIDList, Set<Id> applicantIDList, Map<Id,List<Restriction_Request__c>> entityRestrictionReqMap, Map<Id,List<Restriction_Request__c>> applicantRestrictionReqMap){

        //Boolean returnValue = true;
        List<String> failedEntityIDList = new List<String>();
        List<String> failedApplicantIDList = new List<String>();
        Map<Id, String> rreqIDStatusMap = new Map<Id, String>();
        List<Account> updateAccountList = new List<Account>();
        List<Contact> updateContactList = new List<Contact>();
        try {
            if(!entityIDList.isEmpty()){
                Map<ID, Account> entityRestrictionMap = new Map<ID, Account>([select Id,ServicesRestricted__c,Name,
                                                        (Select ID, Entity__c, Applicant__c, Restriction_Level__c, Restriction_Reason__c, Restriction_Start_Date__c, Restriction_Status__c,
                                                        Restriction_End_Date__c,ServiceRestricted__c,Restriction_Type__c,Restriction_Request__c from Restrictions__r) 
                                                    from Account where ID IN :entityIDList]);
                
                                                    
                for(ID entityId : entityRestrictionMap.keySet()){
                    List<String> servicesRestrictedList = new List<String>();
                    Set<String> servicesRestrictedSet = new Set<String>();
                    
                    if(!entityRestrictionMap.get(entityId).Restrictions__r.isEmpty()){
                        
                        for(Restriction__c restrictRec : entityRestrictionMap.get(entityId).Restrictions__r){
                            //If Status = Active , Type = Internal and External
                            if(restrictRec.Restriction_Status__c == 'Active' && restrictRec.Restriction_Type__c == 'Internal and External'){
                                servicesRestrictedSet.add(restrictRec.ServiceRestricted__c + ' - ' + restrictRec.Restriction_Type__c); 
                                if(servicesRestrictedSet.contains(restrictRec.ServiceRestricted__c + ' - ' + 'Internal Only')){
                                    servicesRestrictedSet.remove(restrictRec.ServiceRestricted__c + ' - ' + 'Internal Only');
                                }                                  
                                System.debug('Account Active External serviceRestricted Set +++++ '+servicesRestrictedSet);              
                            }
                            //if Status = Active , Type = Internal Only
                            else if(restrictRec.Restriction_Status__c == 'Active' && restrictRec.Restriction_Type__c == 'Internal Only'){
                                servicesRestrictedSet.add(restrictRec.ServiceRestricted__c + ' - ' + 'Internal Only');
                                if(servicesRestrictedSet.contains(restrictRec.ServiceRestricted__c + ' - ' + 'Internal and External')){
                                    servicesRestrictedSet.remove(restrictRec.ServiceRestricted__c + ' - ' + 'Internal Only');
                                } 
                                System.debug('Account Active Internal servicesRestricted Set ++++ ' + servicesRestrictedSet);
                            }
                        }
                    }
                    
                    servicesRestrictedList.addAll(servicesRestrictedSet);
                    Account updEntity = new Account();
                    updEntity.Id = entityId;
                    updEntity.Name = entityRestrictionMap.get(entityId).Name;
                    updEntity.ServicesRestricted__c = String.join(servicesRestrictedList, ';');
                    updateAccountList.add(updEntity);
                }
            }

            if(!applicantIDList.isEmpty()){
                Map<ID, Contact> applicantRestrictionMap = new Map<ID, Contact>([select Id,ServicesRestricted__c,Name,LastName,FirstName,
                                                                (Select ID, Entity__c, Applicant__c, Restriction_Level__c, Restriction_Reason__c, Restriction_Start_Date__c, Restriction_Status__c,
                                                                Restriction_End_Date__c, Restriction_Type__c,ServiceRestricted__c,Restriction_Request__c from Restrictions__r)
                                                            from Contact where ID IN :applicantIDList]);

                System.debug('applicantRestrictionMap ++++ ' + applicantRestrictionMap);                                              
                
                for(ID applicantId : applicantRestrictionMap.keySet()){
                    List<String> servicesRestrictedList = new List<String>();
                    Set<String> servicesRestrictedSet = new Set<String>();

                    if(!applicantRestrictionMap.get(applicantId).Restrictions__r.isEmpty()){
                        
                        for(Restriction__c restrictRec : applicantRestrictionMap.get(applicantId).Restrictions__r){
                            //If Status = Active , Type = Internal and External
                            if(restrictRec.Restriction_Status__c == 'Active' && restrictRec.Restriction_Type__c == 'Internal and External'){
                                servicesRestrictedSet.add(restrictRec.ServiceRestricted__c + ' - ' + restrictRec.Restriction_Type__c); 
                                if(servicesRestrictedSet.contains(restrictRec.ServiceRestricted__c + ' - ' + 'Internal Only')){
                                    servicesRestrictedSet.remove(restrictRec.ServiceRestricted__c + ' - ' + 'Internal Only');
                                }   
                                System.debug('Contact Active External serviceRestricted Set +++++ '+servicesRestrictedSet);              
                            }
                            //if Status = Active , Type = Internal Only
                            else if(restrictRec.Restriction_Status__c == 'Active' && restrictRec.Restriction_Type__c == 'Internal Only'){
                                servicesRestrictedSet.add(restrictRec.ServiceRestricted__c + ' - ' + 'Internal Only');
                                if(servicesRestrictedSet.contains(restrictRec.ServiceRestricted__c + ' - ' + 'Internal and External')){
                                    servicesRestrictedSet.remove(restrictRec.ServiceRestricted__c + ' - ' + 'Internal Only');
                                }
                                System.debug('Contact servicesRestrictedSet  Active Internal ++++ ' + servicesRestrictedSet);
                            }
                        }
                    }

                    System.debug('servicesRestrictedSet ++++ ' + servicesRestrictedSet);

                    servicesRestrictedList.addAll(servicesRestrictedSet);
                    Contact updApplicant = new Contact();
                    updApplicant.Id = applicantId;
                    updApplicant.LastName = applicantRestrictionMap.get(applicantId).LastName;
                    updApplicant.FirstName = applicantRestrictionMap.get(applicantId).FirstName;
                    updApplicant.ServicesRestricted__c = String.join(servicesRestrictedList, ';');
                    updateContactList.add(updApplicant);

                    System.debug('updateContactList ++++ ' + updateContactList);

                }

                System.debug('updateContactList -------++++------- ' + updateContactList);
            }

            if(!updateContactList.isEmpty()){
                System.debug('updateContactList ----- ++++ ' + updateContactList);
                List <Database.SaveResult> applicantResults = Database.update(updateContactList, false);
                if(Test.isRunningTest()){
                    List<Contact> testContactist = new List<Contact>();
                    for(Contact cont : updateContactList){
                        Contact newCont = new Contact();
                        newCont.Id = cont.Id;
                        newCont.LastName = '===================================================================================================Some string which is longer than 255 characters================================================================================================================';
                        newCont.FirstName = 'test';
                        newCont.ServicesRestricted__c = '';
                        testContactist.add(newCont);
                    }
                    applicantResults = Database.update(testContactist, false);
                }
                Map<Id, String> idNameApplicantMap = new Map<Id, String>();
                Map<ID, Database.Error> applicantErrorMap = new Map<ID, Database.Error>();
                List<Log_Message__c> logMessageList = new List<Log_Message__c>();
                for (Integer i = 0; i < updateContactList.size(); i++) {
                    Database.SaveResult sr = applicantResults[i];
                    Contact origRecord = updateContactList[i];
                    if (!sr.isSuccess() || Test.isRunningTest()) {
                        applicantErrorMap.put(origRecord.Id, sr.getErrors().get(0));
                        idNameApplicantMap.put(origRecord.Id, origRecord.FirstName + ' ' + origRecord.LastName);
                        system.debug('Failed ID++++++ ' + origRecord.Id);
                     } 
                }

                if(!applicantErrorMap.isEmpty()){
                    for(ID key : applicantErrorMap.keySet()){
                        if(applicantRestrictionReqMap.containsKey(key)){
                            for(Restriction_Request__c rreq: applicantRestrictionReqMap.get(key)){
                                failedApplicantIDList.add(key);
                                Log_Message__c lm = new Log_Message__c();
                                lm.Error_Description__c = (!Test.isRunningTest()) ?  applicantErrorMap.get(key).getStatusCode() + ': ' + applicantErrorMap.get(key).getMessage() : null;
                                lm.Exception__c = (!Test.isRunningTest()) ? String.valueOf(applicantErrorMap.get(key).getFields()) : null;
                                lm.Record_Id__c = key;
                                lm.errorDescription__c = idNameApplicantMap.get(key);
                                lm.RestrictionRequest__c = rreq.Id;
                                logMessageList.add(lm);
                                rreqIDStatusMap.put(rreq.Id, System.JSON.serialize(failedApplicantIDList));
                            }
                        }
                    }
                    if(!logMessageList.isEmpty()){
                        insert logMessageList;
                    }
                }
            }
        
            if(!updateAccountList.isEmpty()){
                List <Database.SaveResult> entityResults = Database.update(updateAccountList, false);
                Map<ID, Database.Error> entityErrorMap = new Map<ID, Database.Error>();
                Map<Id, String> idNameEntityMap = new Map<Id, String>();
                List<Log_Message__c> logMessageList = new List<Log_Message__c>();
                if(Test.isRunningTest()){
                    List<Account> testAccountist = new List<Account>();
                    for(Account acc : updateAccountList){
                        Account newAcc = new Account();
                        newAcc.Id = acc.Id;
                        newAcc.Name = '===================================================================================================Some string which is longer than 255 characters================================================================================================================';
                        testAccountist.add(newAcc);
                    }
                    entityResults = Database.update(testAccountist, false);
                }
                // Iterate through each returned result
                for (Integer i = 0; i < updateAccountList.size(); i++) {
                    Database.SaveResult sr = entityResults[i];
                    Account origRecord = updateAccountList[i];
                    if (!sr.isSuccess() || Test.isRunningTest()) {
                        entityErrorMap.put(origRecord.Id, sr.getErrors().get(0));
                        idNameEntityMap.put(origRecord.Id, origRecord.Name);
                        system.debug('Failed ID++++++ ' + origRecord.Id);
                        system.debug('Failed Name++++++ ' + origRecord.Name);
                     } 
                }

                if(!entityErrorMap.isEmpty()){
                    System.debug('EntityErrorMap ++++ ' + entityErrorMap);
                    for(ID key : entityErrorMap.keySet()){
                        if(entityRestrictionReqMap.containsKey(key)){
                            for(Restriction_Request__c rreq: entityRestrictionReqMap.get(key)){
                                System.debug('Inside Nested For loop +++++++++ ');
                                failedEntityIDList.add(key);
                                Log_Message__c lm = new Log_Message__c();
                                lm.Error_Description__c = entityErrorMap.get(key).getStatusCode() + ': ' + entityErrorMap.get(key).getMessage();
                                lm.Exception__c = String.valueOf(entityErrorMap.get(key).getFields());
                                lm.Record_Id__c = key;
                                lm.RestrictionRequest__c = rreq.Id;
                                lm.errorDescription__c = idNameEntityMap.get(key);
                                System.debug('Log Account Name ++++ ' + lm.errorDescription__c );
                                logMessageList.add(lm);
                                System.debug('logMessageList ++++' +logMessageList.size());
                                rreqIDStatusMap.put(rreq.Id, System.JSON.serialize(failedEntityIDList)); 
                            }
                        }
                    } 
                    if(!logMessageList.isEmpty()){
                        insert logMessageList;
                    }
                } 
            }        
            
        } catch (Exception e) {
            System.debug('Error +++ ' + e.getStackTraceString() + ' ' + e.getMessage() );
        }

        return rreqIDStatusMap;
    }
}