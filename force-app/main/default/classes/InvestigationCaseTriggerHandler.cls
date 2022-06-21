public class InvestigationCaseTriggerHandler implements CaseTriggerHandlerInterface{
    final String STATUS_REVOKED = Constant_Asset__mdt.getInstance('STATUS_REVOKED').Value__c;
    final String REC_TYPE_EPIC_VER_REPORT_REQUEST = Constant_Case__mdt.getInstance('REC_TYPE_EPIC_VER_REPORT_REQUEST').Value__c;
    final String STATUS_SENT = Constant_Case__mdt.getInstance('STATUS_SENT').Value__c;
    public void beforeInsert(List<Case> newCases){
        for(Case newCase: newCases){
            // Updates the Applicant_Last_Submission_Date__c field
            CaseTriggerUtility.updateCaseRecordDate(newCase);
            // Updates standard case status field to closed/not applicable based on internal status
            CaseTriggerUtility.updateCaseRecordStatusFlag(newCase);
        }
    }
    public void beforeUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap){
        for(Case newCase: newCasesMap.values()){
            Case oldCase = oldCasesMap.get(newCase.Id);
            if(newCase.Internal_Status__c != oldCase.Internal_Status__c){
                // Updates the Applicant_Last_Submission_Date__c field
                CaseTriggerUtility.updateCaseRecordDate(newCase);
                // Updates standard case status field to closed/not applicable based on internal status
                CaseTriggerUtility.updateCaseRecordStatusFlag(newCase);
            }
        }
    }
    public void afterInsert(Map<Id,Case> newCasesMap){
        // Fetches the asset records
        Map<String,List<Asset>> assetRecMap = (Map<String,List<Asset>>)CaseTriggerDataInitialize.fetchGenericDataSObjectList(Constant_Data_Key__mdt.getInstance('ASSET_REC_CONTACT').Value__c);
        // Asset list to be updated
        List<Asset> assetListUpd = new List<Asset>();
        // Stores the contact Id if it is already processed
        Set<Id> contactIds = new Set<Id>();
        for(Case newCase: newCasesMap.values()){
            if(String.isNotBlank(newCase.ContactId) && assetRecMap.containsKey(newCase.ContactId) && !contactIds.contains(newCase.ContactId) 
            && newCase.Committee_Action__c == Constant_Case__mdt.getInstance('COMMITTEE_ACTION_REV_ECFMG_CERT').Value__c
            && newCase.Revocation_Date__c != NULL){
                contactIds.add(newCase.ContactId);
                if(newcase.Timeline__c == Constant_Case__mdt.getInstance('TIMELINE_PERMANENT').Value__c){
                    assetListUpd.addAll(updAsset(assetRecMap.get(newCase.ContactId),newCase,FALSE));
                }else{
                    assetListUpd.addAll(updAsset(assetRecMap.get(newCase.ContactId),newCase,TRUE));
                }
            }
        }
        if(!assetListUpd.isEmpty() && GenericUtilities.checkIsUpdatable('Asset')){
            CaseTriggerUtility.updateDMLMap(assetListUpd);
        }
    }
    public void afterUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap){
        try{
            // Fetches the asset records
            Map<String,List<Asset>> assetRecMap = (Map<String,List<Asset>>)CaseTriggerDataInitialize.fetchGenericDataSObjectList(Constant_Data_Key__mdt.getInstance('ASSET_REC_CONTACT').Value__c);
            // Stores the contact Id and the corresponding list of cases.
            Map<String,List<Case>> conCaseMap = (Map<String,List<Case>>)CaseTriggerDataInitialize.fetchGenericDataSObjectList(Constant_Data_Key__mdt.getInstance('CONTACT_CASE').Value__c);
            // Asset list to be updated
            List<Asset> assetListUpd = new List<Asset>();
            // Stores the contact Id if it is already processed
            Set<Id> contactIds = new Set<Id>();
            // Stores the list of records to be inserted.
            List<sObject> recordsToinsert = new List<sObject>();
            // Stores the list of case ids to be processed(create/update child transcript annotation records).
            Set<Id> transAnnotCaseIds = new Set<Id>();
            // Stores the list of case Ids to be used to delete the child transcript annotation records.
            Set<Id> transAnnotDelCaseIds = new Set<Id>();
            // Stores the Ids to be deleted.
            Set<Id> deleteIds = new Set<Id>();
            // Stores the Id and record to be updated.
            Map<Id,sObject> recordsToUpdate = new Map<Id,sObject>();
            // Stores the Id and case record to be updated.
            Map<Id,Case> casesToUpdate = new Map<Id,Case>();
            // Stores the Ids of the processed contacts.
            Set<Id> processedConIds = new Set<Id>();
            Map<String,sObject> keyRelatedRec = CaseTriggerDataInitialize.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('CASE_TRANSCRIPT_ANOTATION').Value__c);
            for(Case newCase: newCasesMap.values()){
                Case oldCase = oldCasesMap.get(newCase.Id);
                if(String.isNotBlank(newCase.Annotation__c) && newCase.Annotation__c != oldCase.Annotation__c){
                    transAnnotCaseIds.add(newCase.Id);
                    if(conCaseMap.containsKey(newCase.ContactId) && !processedConIds.contains(newCase.Id)){
                        updIrrBehav(conCaseMap.get(newCase.ContactId),casesToUpdate);
                    }
                }else if(String.isBlank(newCase.Annotation__c)){
                    transAnnotDelCaseIds.add(newCase.Id);
                }
                if(String.isNotBlank(newCase.ContactId) && assetRecMap.containsKey(newCase.ContactId) && !contactIds.contains(newCase.ContactId) 
                && newCase.Committee_Action__c == Constant_Case__mdt.getInstance('COMMITTEE_ACTION_REV_ECFMG_CERT').Value__c
                && newCase.Revocation_Date__c != NULL){
                    contactIds.add(newCase.ContactId);
                    if(newcase.Timeline__c == Constant_Case__mdt.getInstance('TIMELINE_PERMANENT').Value__c){
                        assetListUpd.addAll(updAsset(assetRecMap.get(newCase.ContactId),newCase,FALSE));
                    }else{
                        assetListUpd.addAll(updAsset(assetRecMap.get(newCase.ContactId),newCase,TRUE));
                    }
                }
            }
            if(RecursiveTriggerHandler.isFirstTimeInvestigation){
                RecursiveTriggerHandler.isFirstTimeInvestigation = false;
                // Stores the list of cases that has been processed.
                Set<Id> caseUpdAttestation = new Set<Id>();
                // Stores the CIBIS Annotation
                Map<String, Cibis_Annoatation__mdt> cibisAnnotationMap = CibisUtility.getCibisAnnoations();
                // Loops through the Transcript Annotation records
                for(sObject transAnnotRec:keyRelatedRec.values()){
                    Transcript_Anotation__c childRec = (Transcript_Anotation__c)transAnnotRec;
                    if(transAnnotCaseIds.contains(childRec.Transcript_Case__c) && newCasesMap.containsKey(childRec.Transcript_Case__c)){
                        Case newCase = newCasesMap.get(childRec.Transcript_Case__c);
                        updateAnnotationRec(childRec,newCase,cibisAnnotationMap);
                        recordsToUpdate.put(transAnnotRec.Id,childRec);
                        caseUpdAttestation.add(childRec.Transcript_Case__c);
                    }
                    else if(transAnnotDelCaseIds.contains(childRec.Transcript_Case__c)){
                        deleteIds.add(transAnnotRec.Id);
                    }
                }
                // Removes the already processed case records
                transAnnotCaseIds.removeAll(caseUpdAttestation);
                // transaction annotation records to be inserted
                if(!transAnnotCaseIds.isEmpty()){
                    for(String caseId:transAnnotCaseIds){
                        Case newCase = newCasesMap.get(caseId);
                        Transcript_Anotation__c transAnnotation = new Transcript_Anotation__c();
                        updateAnnotationRec(transAnnotation,newCase,cibisAnnotationMap);
                        recordsToinsert.add(transAnnotation);
                    }
                }
            }
            if(!recordsToinsert.isEmpty() && Transcript_Anotation__c.SObjectType.getDescribe().isCreateable()){
                CaseTriggerUtility.insertDML(recordsToinsert);
            }
            if(!recordsToUpdate.isEmpty() && Transcript_Anotation__c.SObjectType.getDescribe().isUpdateable()){
                CaseTriggerUtility.updateDMLMap(recordsToUpdate.values());
            }
            if(!deleteIds.isEmpty() && Transcript_Anotation__c.SObjectType.getDescribe().isDeletable()){
                CaseTriggerUtility.deleteDML(deleteIds);
            }
            if(!assetListUpd.isEmpty() && GenericUtilities.checkIsUpdatable('Asset')){
                CaseTriggerUtility.updateDMLMap(assetListUpd);
            }
            if(!casesToUpdate.isEmpty() && GenericUtilities.checkIsUpdatable('Case')){
                CaseTriggerUtility.updateDMLMap(casesToUpdate.values());
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // updates irregular behaviour for epic verification report cases for the contact.
    void updIrrBehav(List<Case> conCases,Map<Id,Case> casesToUpdate){
        for(Case conCase: conCases){
            if(conCase.recordType.DeveloperName == REC_TYPE_EPIC_VER_REPORT_REQUEST && conCase.Internal_Status__c!=STATUS_SENT && !conCase.Irregular_Behavior_Annotated__c){
                conCase.Irregular_Behavior_Annotated__c = True;
                CaseTriggerUtility.updateRec(casesToUpdate,new Case(Id = conCase.Id, Irregular_Behavior_Annotated__c = true));
            }
        }
    }
    // update Asset based on condition
    List<Asset> updAsset(List<Asset> assetList,Case newCase,Boolean isNotPerm){
        // stores the list of assets which are not duplicate
        List<Asset> orgAssList = new List<Asset>();
        // stores the list of assets which are duplicate
        List<Asset> dupAssList = new List<Asset>();
        for(Asset assetRec:assetList){
            if(assetRec.Status == Constant_Asset__mdt.getInstance('STATUS_ACCEPTED').Value__c){
                if(assetRec.Type__c == Constant_Asset__mdt.getInstance('TYPE_ECFMG_CERTIFICATE').Value__c){
                    Asset updAssetRec = new Asset(Id = assetRec.Id,Status = STATUS_REVOKED,Revocation_Date__c = newCase.Revocation_Date__c);
                    assetRec.Status = STATUS_REVOKED;
                    assetRec.Revocation_Date__c = newCase.Revocation_Date__c;
                    if(isNotPerm){
                        assetRec.Reinstatement_Date__c = newCase.Reinstatement_Date__c;
                        updAssetRec.Reinstatement_Date__c = newCase.Reinstatement_Date__c;
                    }
                    orgAssList.add(updAssetRec);
                }else if(assetRec.Type__c == Constant_Asset__mdt.getInstance('TYPE_DUPLICATE_ECFMG_CERTIFICATE').Value__c){
                    Asset updAssetRec = new Asset(Id = assetRec.Id,Status = STATUS_REVOKED,Revocation_Date__c = newCase.Revocation_Date__c);
                    assetRec.Status = STATUS_REVOKED;
                    assetRec.Revocation_Date__c = newCase.Revocation_Date__c;
                    if(isNotPerm){
                        assetRec.Reinstatement_Date__c = newCase.Reinstatement_Date__c;
                        updAssetRec.Reinstatement_Date__c = newCase.Reinstatement_Date__c;
                    }
                    dupAssList.add(updAssetRec);
                }
            }
        }
        if(!dupAssList.isEmpty()){
            return dupAssList;
        }else{
            return orgAssList;
        }
    }
    // US 15983 - Get Annotation Text from Cibis_Annoatation__mdt
    private String getAnnoationsMdt(Case investigationCase,Map<String,Cibis_Annoatation__mdt> cibisAnnotationMap){
        try{
            String annotationText = '';
            String annotation = investigationCase.Annotation__c;
            if(annotation == 'Specialized'){
                annotationText = investigationCase.Annotation_Text_for_Specialized__c;
            }else if(cibisAnnotationMap.containsKey(annotation)){
                annotationText = cibisAnnotationMap.get(annotation).ANNOTATION_TEXT__c;
            }
            return annotationText;
        }catch(Exception ex){
            throw ex;
        }
    }
    // Update Transcript annotation records
    private void updateAnnotationRec(Transcript_Anotation__c transAnnotRec,Case newCase,Map<String,Cibis_Annoatation__mdt> cibisAnnotationMap){
        try{
            transAnnotRec.Name = newCase.Annotation__c;
            transAnnotRec.Cibis_Transcript_Status__c = newCase.Annotation__c;
            transAnnotRec.Contact__c = newCase.ContactId;
            transAnnotRec.Transcript_Case__c = newCase.Id;
            transAnnotRec.ANNOTATION_TEXT__c = getAnnoationsMdt(newCase,cibisAnnotationMap);
            transAnnotRec.ACTIVE__c = 'Y';
        }catch(Exception ex){
            throw ex;
        }
    }
}