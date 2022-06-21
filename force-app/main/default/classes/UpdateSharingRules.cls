// This class is called from Update send method flow when Affirmation record's verify with alternate entity is changed.
public with sharing class UpdateSharingRules{
    @invocableMethod
    public static void updateSharingRule(List<CaseAccWrapper> caseAccWrapperList){
        try{
            Set<Id> accountIdSet = new Set<Id>();
            Set<Id> caseIds = new Set<Id>();
            Set<Id> parentCaseIds = new Set<Id>();
            Map<string,Map<Id,Set<Id>>> newServAccCaseMap = new Map<string,Map<Id,Set<Id>>>();
            Map<string,Map<Id,Set<Id>>> oldServAccCaseMap = new Map<string,Map<Id,Set<Id>>>();
            Map<Id,Set<Id>> parentCaseEntity = new Map<Id,Set<Id>>();
            for(CaseAccWrapper caseAccWrapperRec:caseAccWrapperList){
                if(caseAccWrapperRec.serviceName == Constants.SERVICE_NAME_CREDENTIAL_VERIFICATION && string.isNotBlank(caseAccWrapperRec.parentCaseId)){
                    caseIds.add(caseAccWrapperRec.caseId);
                    parentCaseIds.add(caseAccWrapperRec.parentCaseId);
                }
            }
            CaseTriggerHelper.PopulateParentCase popParentCase = new CaseTriggerHelper.PopulateParentCase();
            popParentCase.parentCaseEntity = CaseTriggerHelper.getParentCaseChildCaseEntity(caseIds,parentCaseIds);
            for(CaseAccWrapper caseAccWrapperRec:caseAccWrapperList){
                Map<Id,Set<Id>> newAccCaseMap = new Map<Id,Set<Id>>();
                Map<Id,Set<Id>> oldAccCaseMap = new Map<Id,Set<Id>>();
                if(newServAccCaseMap.containsKey(caseAccWrapperRec.serviceName)){                    
                    newAccCaseMap = new Map<Id,Set<Id>>(newServAccCaseMap.get(caseAccWrapperRec.serviceName));                    
                }
                if(oldServAccCaseMap.containsKey(caseAccWrapperRec.serviceName)){
                    oldAccCaseMap = new Map<Id,Set<Id>>(newServAccCaseMap.get(caseAccWrapperRec.serviceName));
                }
                popParentCase.accCaseMap = newAccCaseMap;
                populateAccCaseId(popParentCase,caseAccWrapperRec.accountId,caseAccWrapperRec);
                if(String.isNotBlank(caseAccWrapperRec.oldAccountId)){
                    popParentCase.accCaseMap = oldAccCaseMap;
                    populateAccCaseId(popParentCase,caseAccWrapperRec.oldAccountId,caseAccWrapperRec);
                    oldServAccCaseMap.put(caseAccWrapperRec.serviceName,oldAccCaseMap);
                    accountIdSet.add(caseAccWrapperRec.oldAccountId);
                }
                newServAccCaseMap.put(caseAccWrapperRec.serviceName,newAccCaseMap);
                accountIdSet.add(caseAccWrapperRec.AccountId);
            }
            if(!newServAccCaseMap.isEmpty()){
                SharingRuleEntityUserRequestCase.updateSharingRulesEntityUserRequestCase(newServAccCaseMap,oldServAccCaseMap,accountIdSet);
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }
    private static void populateAccCaseId(CaseTriggerHelper.PopulateParentCase popParentCase,Id accountId,CaseAccWrapper caseAccWrapperRec){
        if(popParentCase.accCaseMap.containsKey(accountId)){
            popParentCase.accCaseMap.get(accountId).add(caseAccWrapperRec.caseId);
        }else{
            popParentCase.accCaseMap.put(accountId,new set<Id>{caseAccWrapperRec.caseId});
        }
        if(string.isNotBlank(caseAccWrapperRec.parentCaseId) && caseAccWrapperRec.serviceName == Constants.SERVICE_NAME_CREDENTIAL_VERIFICATION && !CaseTriggerHelper.checkParentCaseEntityAccess(caseAccWrapperRec.parentCaseId,accountId,popParentCase.parentCaseEntity)){
            popParentCase.accCaseMap.get(accountId).add(caseAccWrapperRec.parentCaseId);
        }
    }
    public class CaseAccWrapper{
        @InvocableVariable
        public string caseId;
        @InvocableVariable
        public string accountId;
        @InvocableVariable
        public string oldAccountId;
        @InvocableVariable
        public string serviceName;
        @InvocableVariable
        public string parentCaseId;
    }
}