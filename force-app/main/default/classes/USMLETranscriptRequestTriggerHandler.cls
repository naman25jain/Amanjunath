// Handler class for USMLE Request
public with sharing class USMLETranscriptRequestTriggerHandler implements CaseTriggerHandlerInterface{
    final String CASE_STATUS_PENDING_PRINT = Constant_Case__mdt.getInstance('STATUS_PENDING_PRINT').Value__c;
    final String CASE_STATUS_SENT = Constant_Case__mdt.getInstance('STATUS_SENT').Value__c;
    final String CASE_STATUS_REJECTED = Constant_Case__mdt.getInstance('STATUS_REJECTED').Value__c;
    final String REC_TYPE_USMLE_TRANSCRIPT = Constant_Case__mdt.getInstance('REC_TYPE_USMLE_TRANSCRIPT').Value__c;
    final String CASE_STATUS_APPROVED = Constant_Case__mdt.getInstance('STATUS_APPROVED').Value__c;
    final String CASE_STATUS_PENDING_CIBIS = Constant_Case__mdt.getInstance('STATUS_PENDING_CIBIS').Value__c;
    final String CASE_STATUS_SUBMITTED_IN_REVIEW = Constant_Case__mdt.getInstance('STATUS_SUBMITTED_IN_REVIEW').Value__c;
    // Before insert
    public void beforeInsert(List<Case> newCases){
        try{
            for(Case newCase: newCases){                
                if(String.isNotBlank(newCase.OwnerId)){                    
                    // Update Deficiency reason
                    if(newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_REJECTED').Value__c){
                        newCase.Deficiency_Reason_RTF__c = 'We were unable to process your request.';
                    }
                    if(String.valueOf(newCase.OwnerId).startsWith('005')){
                        newCase.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_IN_REVIEW').Value__c;
                    }                     
                }
                // Updates the Service
                CaseTriggerUtility.updateCaseService(newCase,REC_TYPE_USMLE_TRANSCRIPT);
                // Updates the Applicant_Last_Submission_Date__c field
                CaseTriggerUtility.updateCaseRecordDate(newCase);
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
    // Before Update
    public void beforeUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap){
        try{
            Set<String> caseStatus = new Set<String>{Constant_Case__mdt.getInstance('STATUS_REJECTED').Value__c
            ,Constant_Case__mdt.getInstance('STATUS_ACCEPTED').Value__c
            ,Constant_Case__mdt.getInstance('STATUS_PENDING_PRINT').Value__c
            ,Constant_Case__mdt.getInstance('STATUS_PENDING_ADDRESS_REVIEW').Value__c};            
			// Getiing the instance of CaseTriggerDataInitialize                   
            Map<String,sObject> keyRelatedRec = CaseTriggerDataInitialize.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('CASE_TRANSCRIPT_ANOTATION').Value__c);            
            String note = '<p><b>';
            Map<String,String> caseNoteMap = new Map<String,String>();
            // Loops through the Transcript Annotation records
            for(sObject transAnnotRec:keyRelatedRec.values()){                    
                Transcript_Anotation__c childRec = (Transcript_Anotation__c)transAnnotRec;            
                if(childRec.USMLE_Transcripts_Notes__c == null && newCasesMap.containsKey(childRec.Transcript_Case__c)){
                    note = note + 'Note: </b>';
                    note = note + childRec.ANNOTATION_TEXT__c + '</p><p><b>';
                    caseNoteMap.put(childRec.Transcript_Case__c,note);
                }
            }
            for(Case newCase: newCasesMap.values()){
                // Gets the old case.                
                Case oldCase = oldCasesMap.get(newCase.Id);
                if(newCase.Internal_Status__c != oldCase.Internal_Status__c){                    
                    // Update Deficiency reason
                    if(newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_REJECTED').Value__c){
                        newCase.Deficiency_Reason_RTF__c = 'We were unable to process your request.';
                    }
                    if(caseStatus.contains(newCase.internal_status__c)){
                       newCase.OwnerId = ((Constants.QUEUE_DEV_ID_MAP).get(Constant_Case__mdt.getInstance('QUEUE_EXAM_TRANSCRIPTS').Value__c));
                    } 
                    if(newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_PENDING_PRINT').Value__c && caseNoteMap.containsKey(newCase.Id)){
                        newCase.Transcript_Notes__c = caseNoteMap.get(newCase.Id);
                    }
                    // Updates the Applicant_Last_Submission_Date__c field
                    CaseTriggerUtility.updateCaseRecordDate(newCase);
                    // Updates standard case status field to closed/not applicable based on internal status
                    CaseTriggerUtility.updateCaseRecordStatusFlag(newCase);
                    // Updates External Status
                    CaseTriggerUtility.updateCaseExtStatus(newCase,oldCase);
                }
                if(newCase.OwnerId != oldCase.OwnerId && String.valueOf(newCase.OwnerId).startsWith('005') && String.Valueof(oldCase.OwnerId).startsWith('00G')){
                    newCase.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_IN_REVIEW').Value__c;
                }
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }
    // After insert
    public void afterInsert(Map<Id,Case> newCasesMap){}
    // After update
    public void afterUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap){
        try{
            Map<String,List<sObject>> keyRelatedExamRec = CaseTriggerDataInitialize.fetchRTDataSObjectList(Constant_Case__mdt.getInstance('REC_TYPE_USMLE_TRANSCRIPT').Value__c,Constant_Data_Key__mdt.getInstance('CASE_EXAM_REGISTRATION').Value__c);
            Map<String,sObject> keyRelatedTranRec = CaseTriggerDataInitialize.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('CASE_TRANSCRIPT_ANOTATION').Value__c);
            Map<String, cadmus_core__Doc_Config__c> docConfigMap = CaseTriggerUtility.populateDocConfig();
            Id docConfigId = docConfigMap.get(Constant_PDF_Butler__mdt.getInstance('USMLE_TRANSCRIPT').Value__c).Id;
            // Stores already processed parentIds
            Set<Id> processedParentIds = new Set<Id>();
            // collects case Ids for creating transcript annotation
            Set<Id> transAnnotCaseIds = new Set<Id>();
            // Stores the list of records to be updated
            Map<Id,Case> updateCaseRecMap = new Map<Id,Case>();
            // Fetches the stored SOQL for child records obtained using parentId field
            Map<String,SObject> parentChildRecMap = CaseTriggerDataInitialize.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('CHILD_CASE_RECORDS').Value__c);
            // Stores the list of Exam registration records to be updated
            List<Exam_Registration__c> exams = new List<Exam_Registration__c>();
            for(Case newCase: newCasesMap.values()){
                // Gets the old case.
                Case oldCase = oldCasesMap.get(newCase.Id);
                // Checks if internal status is changed
                Boolean isInternalStatChanged = newCase.Internal_Status__c != oldCase.Internal_Status__c;
                if(isInternalStatChanged && newCase.Internal_Status__c == CASE_STATUS_PENDING_PRINT){
                    if(String.isNotBlank(docConfigId)){
                        CaseTriggerUtility.generateDocHelper(docConfigId,newCase);
                    }
                }
                // Get Case's ParentId to update ParentCase Usmle
                // Checks if internal status is Accepted and changed to update the parent record
                if(isInternalStatChanged && (newCase.Internal_Status__c == CASE_STATUS_SENT || newCase.Internal_Status__c == CASE_STATUS_REJECTED)
                && String.isNotBlank(newCase.ParentId) && parentChildRecMap.containsKey(newCase.ParentId)){
                    Case parentRec = (Case)parentChildRecMap.get(newCase.ParentId);
                    if(!processedParentIds.contains(newCase.ParentId)){
                        processedParentIds.add(newCase.ParentId);
                        Case parentRecUpdated = CaseTriggerUtility.upTransReqdParCase(parentRec);
                        if(parentRecUpdated!=null){
                            CaseTriggerUtility.updateRec(updateCaseRecMap,parentRecUpdated);
                        }
                    }
                }
                if(isInternalStatChanged && String.isNotBlank(newCase.Related_Transcript_Case__c) && newCase.Internal_Status__c == CASE_STATUS_APPROVED){
                    transAnnotCaseIds.add(newCase.Id);
                }
                if(isInternalStatChanged && newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_PENDING_PRINT').Value__c 
                && keyRelatedExamRec.containsKey(newCase.ContactId)){
                    exams.addAll(updCommentExam(keyRelatedExamRec.get(newCase.ContactId),keyRelatedTranRec,newCase));
                }
            }
            // Creates Transcript Annotation and updates related case's internal status
            if(!transAnnotCaseIds.isEmpty()){
                processRelatedCaseTransAnnot(transAnnotCaseIds,keyRelatedTranRec,updateCaseRecMap);
            }
            if(!exams.isEmpty() && GenericUtilities.checkIsUpdatable('Exam_Registration__c')){
                CaseTriggerUtility.updateDMLMap(exams);
            }
            if(!updateCaseRecMap.isEmpty() && GenericUtilities.checkIsUpdatable('Case')){
                CaseTriggerUtility.updateDMLMap(updateCaseRecMap.values());
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // Creates Transcript Annotation and updates related case's internal status
    void processRelatedCaseTransAnnot(Set<Id> transAnnotCaseIds,Map<String,sObject> keyRelatedTranRec,Map<Id,Case> updateCaseRecMap){
        try{
            // Stores the Exam Transcript Owner Id
            Id queueExamTrans = Constants.QUEUE_DEV_ID_MAP.get(Constant_Case__mdt.getInstance('QUEUE_EXAM_TRANSCRIPTS').Value__c);
            // Stores the org wide shipping setting metadata
            Org_Wide_Shipment_Setting__mdt orgWidShipSetting = Org_Wide_Shipment_Setting__mdt.getInstance('Enable_Shipment');
            // Stores the related transcript case map
            map<Id,Case> relatedCaseMap=new map<Id,Case>();
            // Stores the list of transcript annotation list
            List<Transcript_Anotation__c> transcAnnotList = new List<Transcript_Anotation__c>();
            for(sObject transAnnotRec:keyRelatedTranRec.values()){
                Transcript_Anotation__c childTranRec = (Transcript_Anotation__c)transAnnotRec;
                if(transAnnotCaseIds.contains(childTranRec.Transcript_Case__c)
                && childTranRec.Transcript_Case__r.Related_Transcript_Case__r.Internal_Status__c == CASE_STATUS_PENDING_CIBIS){
                    if(!relatedCaseMap.containsKey(childTranRec.Transcript_Case__r.Related_Transcript_Case__c)){
                        relatedCaseMap.put(childTranRec.Transcript_Case__r.Related_Transcript_Case__c
                        ,new Case(Id=childTranRec.Transcript_Case__r.Related_Transcript_Case__c,Cibis_Transcript_Status__c=childTranRec.Transcript_Case__r.Cibis_Transcript_Status__c
                        ,Internal_Status__c=childTranRec.Transcript_Case__r.Internal_Status__c));
                        // updates Transcript Case
                        if(!orgWidShipSetting.Enable_Shipment__c 
                        && (childTranRec.Transcript_Case__r.Related_Transcript_Case__r.Internal_Status__c != CASE_STATUS_PENDING_PRINT 
                        || childTranRec.Transcript_Case__r.Related_Transcript_Case__r.OwnerId != queueExamTrans 
                        || childTranRec.Transcript_Case__r.Related_Transcript_Case__r.External_Status__c != CASE_STATUS_SUBMITTED_IN_REVIEW)){
                            childTranRec.Transcript_Case__r.Related_Transcript_Case__r.Internal_Status__c = CASE_STATUS_PENDING_PRINT;
                            childTranRec.Transcript_Case__r.Related_Transcript_Case__r.OwnerId = queueExamTrans;
                            childTranRec.Transcript_Case__r.Related_Transcript_Case__r.External_Status__c = CASE_STATUS_SUBMITTED_IN_REVIEW;
                            CaseTriggerUtility.updateRec(updateCaseRecMap,new Case(Id = childTranRec.Transcript_Case__r.Related_Transcript_Case__c, Internal_Status__c = CASE_STATUS_PENDING_PRINT,External_Status__c = CASE_STATUS_SUBMITTED_IN_REVIEW));
                        }else if(orgWidShipSetting.Enable_Shipment__c && 
                        (childTranRec.Transcript_Case__r.Related_Transcript_Case__r.Internal_Status__c != CASE_STATUS_APPROVED 
                        || childTranRec.Transcript_Case__r.Related_Transcript_Case__r.OwnerId != queueExamTrans 
                        || childTranRec.Transcript_Case__r.Related_Transcript_Case__r.External_Status__c != CASE_STATUS_SUBMITTED_IN_REVIEW)){
                            childTranRec.Transcript_Case__r.Related_Transcript_Case__r.Internal_Status__c = CASE_STATUS_APPROVED;
                            childTranRec.Transcript_Case__r.Related_Transcript_Case__r.OwnerId = queueExamTrans;
                            childTranRec.Transcript_Case__r.Related_Transcript_Case__r.External_Status__c = CASE_STATUS_SUBMITTED_IN_REVIEW;
                            CaseTriggerUtility.updateRec(updateCaseRecMap,new Case(Id = childTranRec.Transcript_Case__r.Related_Transcript_Case__c, Internal_Status__c = CASE_STATUS_APPROVED,External_Status__c = CASE_STATUS_SUBMITTED_IN_REVIEW));
                        }
                    }
                    Transcript_Anotation__c objTransAnt = childTranRec.clone(false, false, false, false);
                    objTransAnt.Transcript_Case__c = childTranRec.Transcript_Case__r.Related_Transcript_Case__c;
                    transcAnnotList.add(objTransAnt);
                }
            }
            if(!transcAnnotList.isEmpty()){
                CaseTriggerUtility.insertDML(transcAnnotList);
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // updates Exam Registration record comments based on transcript annotation
    List<Exam_Registration__c> updCommentExam(List<sObject> examRegList,Map<String,sObject> keyRelatedTranRec,Case newCase){
        List<Exam_Registration__c> exams = new List<Exam_Registration__c>();
        for(sObject examRec:examRegList){
            Exam_Registration__c childRec = (Exam_Registration__c)examRec;
            String comment = '<p>';
            for(sObject transAnnotRec:keyRelatedTranRec.values()){
                Transcript_Anotation__c childTranRec = (Transcript_Anotation__c)transAnnotRec;
                if(childTranRec.USMLE_Transcripts_Notes__c == childRec.Id && newCase.Id == childTranRec.Transcript_Case__c){
                    comment = comment.contains('IRREGULAR BEHAVIOR') ? comment : comment + '<b>IRREGULAR BEHAVIOR</b></p>';
                    comment = childTranRec.SHORT_TEXT__c == null ? comment : comment + '<p>'+childTranRec.SHORT_TEXT__c + '</p>';
                }
            }
            comment = childRec.Exam_Status__c == Constant_Exam_Registration__mdt.getInstance('EXAM_STATUS_INCOMPLETE').Value__c ? comment + '<p>'+Constant_Exam_Registration__mdt.getInstance('EXAM_STATUS_INCOMPLETE').Value__c + '</p>' : comment;
            comment = childRec.Exam_Status__c == Constant_Exam_Registration__mdt.getInstance('EXAM_STATUS_WITHHELD').Value__c ? comment + '<p>Score Not Available</p>' : comment;
            comment = childRec.Exam_Status__c == Constant_Exam_Registration__mdt.getInstance('EXAM_STATUS_INDETERMINATE').Value__c ? comment + '<p><b>'+Constant_Exam_Registration__mdt.getInstance('EXAM_STATUS_INDETERMINATE').Value__c+'</b></p>' : comment;
            comment = childRec.Test_Accommodations__c == 'Y' ? comment + '<p>'+Constants.REMARKS_TA + '</p>' : comment;
            childRec.Transcript_Comments__c = comment;
            exams.add(new Exam_Registration__c(Id = childRec.Id, Transcript_Comments__c = comment));
        }
        return exams;
    }
}