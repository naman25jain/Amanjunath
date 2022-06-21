public inherited sharing class AffirmationConfigController{
    @AuraEnabled(Cacheable=false)
    public static AffrimationConfigs getAffirmnationConfigs(String strScreenName, String parentRecordId, String strAffirmationRecId, string strAffirmationRecordType, Map<String, Object> fieldToUpdate){
        try {
            AffrimationConfigs objWrapper = new AffrimationConfigs();       
            if(String.isNotBlank(strScreenName)){
                list<Affirmation_Config__mdt> lstMdts = [SELECT Id, Affirmation_Static_Values__c, Affirmation_List_of_Field_Values__c, Label, Required__c, Affirmation_Field_Type__c, DeveloperName, 
                                                            Sequence__c, Affirmation_Question__c, Indentation__c, Parent_Question__c, Parent_Key__c, isReadOnly__c, Affirmation_Field_API_Name__c, Visibility_Conditions__c, Display_Text__c
                                                        FROM Affirmation_Config__mdt 
                                                        WHERE Screen_Name__c = :strScreenName AND isActive__c = true ORDER BY Sequence__c ASC];  
                Boolean isAfRecord = false;
                list<String> lstFileds = new list<String>();
                list<String> lstParentFields = new list<String>();
                map<String, String> mapFiledNameAndValues = new Map<String, String>();
                map<String, Affirmation_Config__mdt> mapAPIKeyAndRecord = new Map<String, Affirmation_Config__mdt>();
                map<String, String> caseFieldValues = new Map<String, String>();
                map<String, String> affAllFieldValues = new Map<String, String>();
                list<String> listCaseFields = GenericUtilities.getFieldNameList('Case');
                list<String> listAllAffFields = GenericUtilities.getFieldNameList('Affirmation__c');
                String sObjName;
                Id parentRecId = parentRecordId;
                if(String.isNotBlank(parentRecId)){
                    sObjName = parentRecId.getSObjectType().getDescribe().getName();
                } 
                if(lstMdts != null && !lstMdts.isEmpty()){
                    for(Affirmation_Config__mdt mdtIterator : lstMdts){
                        if(mdtIterator.Affirmation_Field_API_Name__c != null){
                            mapAPIKeyAndRecord.put(mdtIterator.Affirmation_Field_API_Name__c, mdtIterator);
                        }
                    }
                }
                String fieldToUpdateQuery = '';
                if(fieldToUpdate != null && !fieldToUpdate.isEmpty()){
                    for(String field : fieldToUpdate.keySet()){
                        if(listAllAffFields.contains(field)){
                            Object fieldValue = fieldToUpdate.get(field);
                            fieldToUpdateQuery = fieldToUpdateQuery + ' AND ' + field + ' =: fieldValue';
                        }
                    }
                }
                objWrapper.mapAPIKeyAndRecord = mapAPIKeyAndRecord;
                if(String.isNotBlank(parentRecordId) || String.isNotBlank(strAffirmationRecId)){       
                    lstFileds.addAll(mapAPIKeyAndRecord.keySet());
                    String strQuery = '';
                    String strCaseQuery = '';
                    String strAffQuery = '';
                    Id caseId;
                    if(String.isNotBlank(strAffirmationRecId)){
                        strQuery = 'SELECT '+ String.join(lstFileds, ', ') + ' FROM Affirmation__c WHERE Id =:strAffirmationRecId Order by CreatedDate DESC';
                        caseId = [SELECT Case__c FROM Affirmation__c WHERE Id =:strAffirmationRecId].Case__c;
                        strCaseQuery = 'SELECT '+ String.join(listCaseFields, ', ') + ' FROM Case WHERE Id =:caseId Order by CreatedDate DESC';
                        strAffQuery = 'SELECT '+ String.join(listAllAffFields, ', ') + ' FROM Affirmation__c WHERE Id =:strAffirmationRecId Order by CreatedDate DESC';
                    }else if(String.isNotBlank(parentRecordId) && sObjName == 'Case'){
                        caseId = parentRecordId;
                        strQuery = 'SELECT '+ String.join(lstFileds, ', ') + ' FROM Affirmation__c WHERE Case__c =:parentRecordId AND RecordType.DeveloperName =:strAffirmationRecordType '+ fieldToUpdateQuery +' Order by CreatedDate DESC';
                        strCaseQuery = 'SELECT '+ String.join(listCaseFields, ', ') + ' FROM Case WHERE Id =:parentRecordId Order by CreatedDate DESC';
                        strAffQuery = 'SELECT '+ String.join(listAllAffFields, ', ') + ' FROM Affirmation__c WHERE Case__c =:parentRecordId AND RecordType.DeveloperName =:strAffirmationRecordType Order by CreatedDate DESC';
                    }else if(String.isNotBlank(parentRecordId) && sObjName == 'Asset'){
                        strQuery = 'SELECT '+ String.join(lstFileds, ', ') + ' FROM Affirmation__c WHERE Asset__c =:parentRecordId AND RecordType.DeveloperName =:strAffirmationRecordType '+ fieldToUpdateQuery +' Order by CreatedDate DESC';
                        strAffQuery = 'SELECT '+ String.join(listAllAffFields, ', ') + ' FROM Affirmation__c WHERE Asset__c =:parentRecordId AND RecordType.DeveloperName =:strAffirmationRecordType Order by CreatedDate DESC';
                    }
                    if(String.isNotBlank(strQuery)){
                        List<SObject> lstAfs = Database.query(strQuery);
                        if(lstAfs != null && !lstAfs.isEmpty()){
                            isAfRecord = true;
                            sObject obj = lstAfs[0];
                            objWrapper.strAffirmationId = String.valueOf(obj.get('Id'));
                            for(String str : lstFileds){
                                mapFiledNameAndValues.put(str, String.valueOf(obj.get(str)));
                            }
                        }
                    }
                    if(String.isNotBlank(strCaseQuery) && String.isNotBlank(caseId)){
                        List<SObject> lstCase = Database.query(strCaseQuery);
                        if(lstCase != null && !lstCase.isEmpty()){
                            sObject cse = lstCase[0];
                            for(String str : listCaseFields){
                                caseFieldValues.put(str, String.valueOf(cse.get(str)));
                            }
                        }
                    }
                    if(String.isNotBlank(strAffQuery)){
                        List<SObject> lstAllAff = Database.query(strAffQuery);
                        if(lstAllAff != null && !lstAllAff.isEmpty()){
                            sObject allAff = lstAllAff[0];
                            for(String str : listAllAffFields){
                                if(allAff.get(str) != null){
                                    affAllFieldValues.put(str, String.valueOf(allAff.get(str)));
                                }else{
                                    affAllFieldValues.put(str, '');
                                }
                            }
                        }
                    }                  
                }
                if(lstMdts != null && !lstMdts.isEmpty()){
                    list<Affirmation_Config__mdt> lstParentMdts = new list<Affirmation_Config__mdt>();
                    map<String, list<Affirmation_Config__mdt>> mapChildMdts = new map<String, list<Affirmation_Config__mdt>>();
                    map<String, list<String>> mapParentKeyAndChildAPI = new map<String, list<String>>();
                    list<String> lstValues = new list<String>();                   
                    for(Affirmation_Config__mdt mdtIterator : lstMdts){
                        if(!isAfRecord && mdtIterator.Affirmation_Field_Type__c == 'Checkbox'){
                            mapFiledNameAndValues.put(mdtIterator.Affirmation_Field_API_Name__c, 'false');
                        }else if(!isAfRecord){
                            mapFiledNameAndValues.put(mdtIterator.Affirmation_Field_API_Name__c, '');
                        }
                        if(mdtIterator.Parent_Key__c == null){
                            lstParentMdts.add(mdtIterator);
                            lstParentFields.add(mdtIterator.Affirmation_Field_API_Name__c);
                        }
                        else if(mdtIterator.Parent_Key__c != null){
                            if(!mapChildMdts.containsKey(mdtIterator.Parent_Key__c)){
                                mapChildMdts.put(mdtIterator.Parent_Key__c, new list<Affirmation_Config__mdt>{mdtIterator});
                            }
                            else{
                                mapChildMdts.get(mdtIterator.Parent_Key__c).add(mdtIterator);
                            }
                            if(!mapParentKeyAndChildAPI.containsKey(mdtIterator.Parent_Key__c)){
                                mapParentKeyAndChildAPI.put(mdtIterator.Parent_Key__c, new list<String>{mdtIterator.Affirmation_Field_API_Name__c});
                            }
                            else{
                                mapParentKeyAndChildAPI.get(mdtIterator.Parent_Key__c).add(mdtIterator.Affirmation_Field_API_Name__c);
                            }
                        }
                    }
                    objWrapper.lstParentRecords = lstParentMdts;
                    objWrapper.mapChildRecords = mapChildMdts;
                    objWrapper.lstParentFields = lstParentFields;
                    objWrapper.mapChildsWithKey = mapParentKeyAndChildAPI;
                    if(mapFiledNameAndValues != null && !mapFiledNameAndValues.isEmpty()){
                        objWrapper.mapFiledNameAndValues = mapFiledNameAndValues;
                    }
                    if(caseFieldValues != null && !caseFieldValues.isEmpty()){
                        objWrapper.caseFieldValues = caseFieldValues;
                    }
                    if(affAllFieldValues != null && !affAllFieldValues.isEmpty()){
                        objWrapper.affAllFieldValues = affAllFieldValues;
                    }
                }
            }
            return objWrapper;
        }
        catch(exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static AffirmationWrapper createAffirmationRecord(String strScreenName, String strParentRecord, String strObjectName, Map<String, Object> fieldValues, String strAFrecordId, String strRecordTypeDevName){
        try{
            String sObjName;
            Id parentRecId = strParentRecord;
            if(String.isNotBlank(parentRecId)){
                sObjName = parentRecId.getSObjectType().getDescribe().getName();
            }
            if(strObjectName == null || fieldValues == null){
                return null; 
            }
            if(String.isNotBlank(strRecordTypeDevName)){
                fieldValues.put('RecordTypeId', Schema.getGlobalDescribe().get(strObjectName).getDescribe().getRecordTypeInfosByDeveloperName()?.get(strRecordTypeDevName)?.getRecordTypeId());
            }
            if(String.isNotBlank(strParentRecord) && sObjName == 'Case'){
                fieldValues.put('Case__c', strParentRecord);
            }else if(String.isNotBlank(strParentRecord) && sObjName == 'Asset'){
                fieldValues.put('Asset__c', strParentRecord);
            }
            if(String.isNotBlank(strAFrecordId)){
                fieldValues.put('Id', strAFrecordId);
            }
            Affirmation_Validation__mdt objMdt = Affirmation_Validation__mdt.getInstance(strScreenName);
            AffirmationWrapper objWrapper = new AffirmationWrapper();
            sObject sObj = Schema.getGlobalDescribe().get(strObjectName).newSObject();
            String strValidationMessages =  '';
            if(objMdt != null && objMdt.Apex_Class_Name__c != null){
                strValidationMessages = affirmationCustomValidation(objMdt, fieldValues);
            }
            if(String.isBlank(strValidationMessages)){
                Map<String, String> mapFieldType = GenericUtilities.getFieldAsMap(strObjectName);
                for(String field : fieldValues.keySet()){
                    if(String.valueOf(fieldValues.get(field)) == null || String.valueOf(fieldValues.get(field))==''){
                        sObj.put(field, null);
                    }else{
                        if(mapFieldType != null && !mapFieldType.isEmpty() && mapFieldType.containsKey(field.toLowerCase()) && mapFieldType.get(field.toLowerCase()) == 'BOOLEAN' && (fieldValues.get(field) == 'true' || fieldValues.get(field) == 'false')){
                            sObj.put(field, Boolean.valueOf(fieldValues.get(field)));
                        }else if(mapFieldType != null && !mapFieldType.isEmpty() && mapFieldType.containsKey(field.toLowerCase()) && mapFieldType.get(field.toLowerCase()) == 'DATE'){
                            String dateValue = fieldValues.get(field).toString();
                            sObj.put(field, Date.valueOf(dateValue));
                        }else{
                            sObj.put(field, fieldValues.get(field));
                        }  
                    }
                }
                upsert sObj;
                objWrapper.strError = null;
                Id affId = sObj.Id;
                sObject sObj2 = Schema.getGlobalDescribe().get(strObjectName).newSObject();
                list<String> listAllAffFields = GenericUtilities.getFieldNameList(strObjectName);
                String strAffQuery = 'SELECT '+ String.join(listAllAffFields, ', ') + ' FROM ' + strObjectName + ' WHERE Id =:affId LIMIT 1';
                sObj2 = Database.query(strAffQuery);
                objWrapper.objAfRecord = JSON.serialize(sObj2.getPopulatedFieldsAsMap());          
            }
            else{
                objWrapper.strError = strValidationMessages;
                objWrapper.objAfRecord = null;
            }
            return objWrapper;
        }
        catch(Exception e){                      
            throw new AuraHandledException(e.getMessage());
        }   
    }
    public static String  affirmationCustomValidation(Affirmation_Validation__mdt mdtValidation, Map<String, Object> mapValues) {
        
        String strMessage = '';
        try{
          
            Type t = Type.forName(mdtValidation.Apex_Class_Name__c);
          
            AffirmationValidationInterface objValdation = (AffirmationValidationInterface)t.newInstance();
            strMessage = objValdation.process(mdtValidation, mapValues);
        }
        Catch(Exception e) {
            throw new ControllerException(e.getMessage());
        }
        return strMessage;
    }
    public class AffrimationConfigs {
        @AuraEnabled
        public  list<Affirmation_Config__mdt> lstParentRecords;
        @AuraEnabled
        public map<String, list<Affirmation_Config__mdt>> mapChildRecords;
        @AuraEnabled
        public map<String, String> mapFiledNameAndValues;
        @AuraEnabled
        public map<String, Affirmation_Config__mdt> mapAPIKeyAndRecord;
        @AuraEnabled
        public list<String> lstParentFields;
        @AuraEnabled
        public map<String, list<String>> mapChildsWithKey;
        @AuraEnabled
        public string strAffirmationId;
        @AuraEnabled
        public map<String, String> caseFieldValues;
        @AuraEnabled
        public map<String, String> affAllFieldValues;
    }
    public class AffirmationWrapper {
        @AuraEnabled
        public String strError;
        @AuraEnabled
        public String strSuccess;
        @AuraEnabled
        public object objAfRecord;
    }
}