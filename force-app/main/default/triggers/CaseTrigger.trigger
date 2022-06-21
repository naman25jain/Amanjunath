// Case Trigger calls trigger handler class
trigger CaseTrigger on Case (after insert, after update, before insert, before update){
    if(Label.Disable_Case_Trigger == 'False' && Label.Disable_New_Case_Trigger == 'True'){
        if(trigger.isBefore){
            if(trigger.isInsert){
                CaseTriggerHandler.beforeInsert(trigger.new);
            }
            if(trigger.isUpdate){
                CaseTriggerHandler.beforeUpdate(trigger.newMap, trigger.oldMap);
            }       
            CaseTriggerHandler.revocationChanges(Trigger.New);        
        }
        if(trigger.isAfter){
            if(trigger.isInsert){
               CaseTriggerHandler.afterInsert(trigger.newMap);          
            }
            if(trigger.isUpdate){
                CaseTriggerHandler.afterUpdate(trigger.newMap, trigger.oldMap);
            }
        }
    }else if(Label.Disable_Case_Trigger == 'False'){
        if(trigger.isInsert){
            if(trigger.isBefore){
                CaseTriggerDataInitialize ctData = CaseTriggerDataInitialize.getInstance(Trigger.New,false);            
                Map<String,List<Case>> rtCases = ctData.fetchData().rtCases;
                for(String recType: rtCases.keySet()){
                    CaseTriggerRecordTypeClass__mdt classRec = (CaseTriggerRecordTypeClass__mdt.getInstance(recType));
                    if(classRec != null){
                        Type t = Type.forName(classRec.Class_Name__c);
                        CaseTriggerHandlerInterface caseInt = (CaseTriggerHandlerInterface)t.newInstance();
                        caseInt.beforeInsert(rtCases.get(recType));
                    }
                }
            }
            if(trigger.isAfter){
                CaseTriggerDataInitialize ctData = CaseTriggerDataInitialize.getInstance(Trigger.New,true);
                CaseTriggerDataInitialize.CaseTriggerDataWrapper ctDataWrap = ctData.fetchData();
                Map<String,List<Case>> rtCases = ctData.fetchData().rtCases;
                CaseTriggerCommonMethod.afterInsert(Trigger.newMap);
                for(String recType: rtCases.keySet()){
                    CaseTriggerRecordTypeClass__mdt classRec = (CaseTriggerRecordTypeClass__mdt.getInstance(recType));
                    if(classRec != null){
                        Type t = Type.forName(classRec.Class_Name__c);
                        CaseTriggerHandlerInterface caseInt = (CaseTriggerHandlerInterface)t.newInstance();
                        caseInt.afterInsert(new Map<Id,Case>(rtCases.get(recType)));
                        ctDataWrap = ctData.fetchData();
                    }
                }
                // caseshare
                SharingRuleEntityUserRequestCase.updateSharingRulesEntityUserRequestCase(ctDataWrap.insServiceAccCaseMap,ctDataWrap.delServiceAccCaseMap,ctDataWrap.accountIdSet);
                ctData.upsertDML();
            }
        }
        if(trigger.isUpdate){
            if(trigger.isBefore){
                CaseTriggerDataInitialize ctData = CaseTriggerDataInitialize.getInstance(Trigger.New,false);
                Map<String,List<Case>> rtCases = ctData.fetchData().rtCases;
                for(String recType: rtCases.keySet()){
                    CaseTriggerRecordTypeClass__mdt classRec = (CaseTriggerRecordTypeClass__mdt.getInstance(recType));
                    if(classRec != null){
                        Type t = Type.forName(CaseTriggerRecordTypeClass__mdt.getInstance(recType).Class_Name__c);
                        CaseTriggerHandlerInterface caseInt = (CaseTriggerHandlerInterface)t.newInstance();
                        caseInt.beforeUpdate(new Map<Id,Case>(rtCases.get(recType)),Trigger.oldMap);
                    }
                }
            }
            if(trigger.isAfter){
                CaseTriggerDataInitialize ctData = CaseTriggerDataInitialize.getInstance(Trigger.New,true);
                CaseTriggerDataInitialize.CaseTriggerDataWrapper ctDataWrap = ctData.fetchData();
                Map<String,List<Case>> rtCases = ctData.fetchData().rtCases;
                CaseTriggerCommonMethod.afterUpdate(Trigger.newMap, Trigger.oldMap);
                for(String recType: rtCases.keySet()){
                    CaseTriggerRecordTypeClass__mdt classRec = (CaseTriggerRecordTypeClass__mdt.getInstance(recType));
                    if(classRec != null){
                        Type t = Type.forName(CaseTriggerRecordTypeClass__mdt.getInstance(recType).Class_Name__c);
                        CaseTriggerHandlerInterface caseInt = (CaseTriggerHandlerInterface)t.newInstance();
                        caseInt.afterUpdate(new Map<Id,Case>(rtCases.get(recType)),Trigger.oldMap);
                    }
                }
                SharingRuleEntityUserRequestCase.updateSharingRulesEntityUserRequestCase(ctDataWrap.insServiceAccCaseMap,ctDataWrap.delServiceAccCaseMap,ctDataWrap.accountIdSet);
                ctData.sendEmail();
                ctData.deleteDML();
                ctData.upsertDML();
            }
        }
    }
}