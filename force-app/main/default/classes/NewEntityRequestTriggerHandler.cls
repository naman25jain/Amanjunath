public class NewEntityRequestTriggerHandler implements CaseTriggerHandlerInterface{
    final String STATUS_NEW = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c;
    final String STATUS_ADDED = Constant_Case__mdt.getInstance('STATUS_ADDED').Value__c;
    final String STATUS_REJECTED = Constant_Case__mdt.getInstance('STATUS_REJECTED').Value__c;
    final String STATUS_INST_ADD_COMPLETE = Constant_Case__mdt.getInstance('STATUS_INSTITUTION_ADD_COMPLETE').Value__c;
    final String STATUS_INST_ADD_REJECTED = Constant_Case__mdt.getInstance('STATUS_INSTITUTION_ADD_REJECTED').Value__c;
    final String STATUS_IN_REVIEW = Constant_Case__mdt.getInstance('STATUS_IN_REVIEW').Value__c;
    final Set<String> STATUS_LIST_1 = new Set<String>{STATUS_NEW, STATUS_ADDED, STATUS_REJECTED};
    final Set<String> STATUS_LIST_2 = new Set<String>{STATUS_ADDED, STATUS_REJECTED};
    public void beforeInsert(List<Case> newCases){
        try{
            for(Case newCase: newCases){
                newCase = updateCaseOwner(newCase);
                // Updates standard case status field to closed/not applicable based on internal status
                CaseTriggerUtility.updateCaseRecordStatusFlag(newCase);
                // Updates External Status
                CaseTriggerUtility.updateCaseExtStatus(newCase,null);
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }
    public void beforeUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap){
        try{
            for(Case newCase: newCasesMap.values()){
                newCase = updateCaseOwner(newCase);
                // Updates standard case status field to closed/not applicable based on internal status
                CaseTriggerUtility.updateCaseRecordStatusFlag(newCase);
                // Updates External Status
                CaseTriggerUtility.updateCaseExtStatus(newCase,oldCasesMap.get(newCase.Id));
            }
            // Updates standard case status field to closed/not applicable based on internal status
        }
        catch(Exception ex){
            throw ex;
        }
    }
    public void afterInsert(Map<Id,Case> newCasesMap){
        try{
            Map<String, sObject> parentCaseMap = CaseTriggerDataInitialize.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('CHILD_CASE_RECORDS').Value__c);
            List<Case> parentCasesToUpdate = new List<Case>();
            for(Case newCase : newCasesMap.values()){
                if(String.isNotBlank(newCase.ParentId) && parentCaseMap.containsKey(newCase.ParentId)){
                    Case cse = (Case)parentCaseMap.get(newCase.ParentId);
                    if(newCase.Internal_Status__c == STATUS_ADDED && cse.Internal_Status__c != STATUS_INST_ADD_COMPLETE){   
                        cse.Internal_Status__c = STATUS_INST_ADD_COMPLETE;
                        parentCasesToUpdate.add(new Case(Id = newCase.ParentId,Internal_Status__c = STATUS_INST_ADD_COMPLETE));
                    }else if(newCase.Internal_Status__c == STATUS_REJECTED && cse.Internal_Status__c != STATUS_INST_ADD_REJECTED){
                        cse.Internal_Status__c = STATUS_INST_ADD_REJECTED;
                        parentCasesToUpdate.add(new Case(Id = newCase.ParentId,Internal_Status__c = STATUS_INST_ADD_REJECTED));
                    }
                }
            }
            if(!parentCasesToUpdate.isEmpty() && GenericUtilities.checkIsUpdatable('Case')){
                CaseTriggerUtility.updateDMLMap(parentCasesToUpdate);
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }
    public void afterUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap){
        try{
            Map<String, sObject> parentCaseMap = CaseTriggerDataInitialize.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('CHILD_CASE_RECORDS').Value__c);
            List<Case> parentCasesToUpdate = new List<Case>();
            for(Case newCase : newCasesMap.values()){
                if(String.isNotBlank(newCase.ParentId) && parentCaseMap.containsKey(newCase.ParentId) && newCase.Internal_Status__c != oldCasesMap.get(newCase.Id).Internal_Status__c){
                    Case cse = (Case)parentCaseMap.get(newCase.ParentId);
                    if(newCase.Internal_Status__c == STATUS_ADDED && cse.Internal_Status__c != STATUS_INST_ADD_COMPLETE){   
                        cse.Internal_Status__c = STATUS_INST_ADD_COMPLETE;
                        parentCasesToUpdate.add(new Case(Id = newCase.ParentId,Internal_Status__c = STATUS_INST_ADD_COMPLETE));
                    }else if(newCase.Internal_Status__c == STATUS_REJECTED && cse.Internal_Status__c != STATUS_INST_ADD_REJECTED){
                        cse.Internal_Status__c = STATUS_INST_ADD_REJECTED;
                        parentCasesToUpdate.add(new Case(Id = newCase.ParentId,Internal_Status__c = STATUS_INST_ADD_REJECTED));
                    }
                }
            }
            if(!parentCasesToUpdate.isEmpty() && GenericUtilities.checkIsUpdatable('Case')){
                CaseTriggerUtility.updateDMLMap(parentCasesToUpdate);
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }
    private Case updateCaseOwner(Case newCase){
        try{
            Id userId = UserInfo.getUserId();
            Id entSerReqQueueId = Constants.QUEUE_DEV_ID_MAP.get(Constant_Case__mdt.getInstance('QUEUE_ENTITY_SERVICE_REQUEST').Value__c);
            if(newCase.OwnerId != userId && newCase.Internal_Status__c == STATUS_IN_REVIEW){
                newCase.OwnerId = userId;
            }else if(((String.isNotBlank(newCase.ParentId) && STATUS_LIST_2.contains(newCase.Internal_Status__c)) || STATUS_LIST_1.contains(newCase.Internal_Status__c))
                     && newCase.OwnerId != entSerReqQueueId){
                newCase.OwnerId = entSerReqQueueId;
            }
            return newCase;
        }
        catch(Exception ex){
            throw ex;
        }
    }
}