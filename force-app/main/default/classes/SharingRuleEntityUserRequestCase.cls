// Shares the case records with rowcause as manual.
public without sharing class SharingRuleEntityUserRequestCase{
    public static void updateSharingRulesEntityUserRequestCase(Map<string,Map<Id,set<Id>>> insServiceAccCaseMap,Map<string,Map<Id,set<Id>>> delServiceAccCaseMap,set<Id> accountIdSet){
        map<Id,set<Id>> insConCaseId = new map<Id,set<Id>>();
            map<Id,set<Id>> delConCaseId = new map<Id,set<Id>>();
            set<string> serviceNames = new set<string>(insServiceAccCaseMap.keyset());
            serviceNames.addAll(delServiceAccCaseMap.keyset());
            if(!insServiceAccCaseMap.isEmpty() || !delServiceAccCaseMap.isEmpty()){
            List<CONTACT2ACCTSERVICE__c> contact2AccServiceList = [SELECT Id,Service_Contact__c,Account_Service__r.Account__c,Account_Service__r.Service__r.Name FROM CONTACT2ACCTSERVICE__c WHERE Active__c = true AND Account_Service__r.Active__c = true AND Service_Contact__c != null AND Account_Service__r.Service__r.Name in: serviceNames AND Account_Service__r.Account__c in: accountIdSet];
            for(CONTACT2ACCTSERVICE__c con2accserviceObj : contact2AccServiceList){
                if(insServiceAccCaseMap.containsKey(con2accserviceObj.Account_Service__r.Service__r.Name) && insServiceAccCaseMap.get(con2accserviceObj.Account_Service__r.Service__r.Name).containsKey(con2accserviceObj.Account_Service__r.Account__c)){
                    insConCaseId.put(con2accserviceObj.Service_Contact__c,populateConCaseId(insConCaseId,con2accserviceObj,insServiceAccCaseMap));
                }
                if(delServiceAccCaseMap.containsKey(con2accserviceObj.Account_Service__r.Service__r.Name) && delServiceAccCaseMap.get(con2accserviceObj.Account_Service__r.Service__r.Name).containsKey(con2accserviceObj.Account_Service__r.Account__c)){
                    delConCaseId.put(con2accserviceObj.Service_Contact__c,populateConCaseId(delConCaseId,con2accserviceObj,delServiceAccCaseMap));
                }
            }
            if(!delConCaseId.isEmpty()){
                deleteSharingRules(delConCaseId);
            }
            if(!insConCaseId.isEmpty()){
                SharingRuleNewEntityContact.updateSharingRules(insConCaseId);
            }
        }
    }
    public static set<Id> populateConCaseId(map<Id,set<Id>> conCaseId,CONTACT2ACCTSERVICE__c con2accserviceObj,Map<string,Map<Id,set<Id>>> serviceAccCaseMap){
        set<Id> caseIds = new set<Id>();                    
        if(conCaseId.containsKey(con2accserviceObj.Service_Contact__c)){
            caseIds.addAll(conCaseId.get(con2accserviceObj.Service_Contact__c));
            caseIds.addAll(serviceAccCaseMap.get(con2accserviceObj.Account_Service__r.Service__r.Name).get(con2accserviceObj.Account_Service__r.Account__c));
        }
        else{
            caseIds.addAll(serviceAccCaseMap.get(con2accserviceObj.Account_Service__r.Service__r.Name).get(con2accserviceObj.Account_Service__r.Account__c));
        }
        return caseIds;
    }
    // Deletes caseshare records
    public static void deleteSharingRules(map<Id,set<Id>> delConCaseId){
        List<CaseShare> delCaseShareList = new List<CaseShare>();
        set<Id> caseId = new set<Id>();
        for(Id conId:delConCaseId.keyset()){
            caseId.addAll(delConCaseId.get(conId));
        }
        List<CaseShare> caseShareLists = [SELECT Id,UserorGroupId,CaseId, TYPEOF UserorGroup WHEN User THEN ContactId END FROM CaseShare WHERE UserorGroup.Type = 'User' AND UserorGroupId IN (SELECT Id FROM User WHERE ContactId in:delConCaseId.keyset()) AND CaseId IN: caseId AND RowCause=:Schema.CaseShare.RowCause.Manual];
        for(CaseShare csShareRec:caseShareLists){
            User userRec = csShareRec.UserorGroup;
            if(delConCaseId.containsKey(userRec.ContactId) && delConCaseId.get(userRec.ContactId).contains(csShareRec.CaseId)){
                delCaseShareList.add(csShareRec);
            }
        }
        if(!delCaseShareList.isEmpty()){
            delete delCaseShareList;
        }
    }
}