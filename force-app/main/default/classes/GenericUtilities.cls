/**
@Name: Shaik Nagajani
@Description: 
- This class contains the generic methods to use for common purpose.

@History
VERSION     AUTHOR             DATE            DETAIL
1.0         Shaik Nagajani     24/Aug/2021     Created the Apex class.
*/

public inherited sharing class GenericUtilities {
    
    /**
* This method return the map, key as fieldAPIName and value as fieldType based on the object name
*/
    public static Map < String, String > getFieldAsMap(String strObjName) {
        Map < String, String > fieldsMap = new Map < String, String > ();
        if (String.isNotBlank(strObjName)) {
            Map < String, Schema.SObjectType > schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType schemaObj = schemaMap.get(strObjName);
            Map < String, Schema.SObjectField > fieldMap = schemaObj.getDescribe().fields.getMap();
            for (String fieldName: fieldMap.keySet()) {
                fieldsMap.put(fieldName, String.valueOf(fieldMap.get(fieldName).getDescribe().getType()));
            }
        }
        
        if (fieldsMap != null && !fieldsMap.isEmpty()) {
            return fieldsMap;
        } else {
            return null;
        }
    }
    
    // Record Types Related Utilities - Describe
    private static map < String, map < Id, RecordTypeInfo >> mapAllRecordTypes;
    private static map < String, map < Id, RecordTypeInfo >> loadRecordTypes(String objectName) {
        if (mapAllRecordTypes == null) {
            mapAllRecordTypes = new map < String, map < Id, RecordTypeInfo >> ();
        }
        if (!mapAllRecordTypes.containsKey(objectName)) {
            list < Schema.DescribeSObjectResult > descSObjectResults = Schema.describeSObjects(new String[] {
                objectName
                    });
            map < Id, Schema.RecordTypeInfo > mapRecordType = new map < id, Schema.RecordTypeInfo > ();
            for (Schema.RecordTypeInfo recordType: descSObjectResults[0].getRecordTypeInfos()) {
                mapRecordType.put(recordType.getRecordTypeId(), recordType);
            }
            mapAllRecordTypes.put(objectName, mapRecordType);
        }
        return mapAllRecordTypes;
    }
    
    /**
* This method returns the recordtypeId based on the record name
*/
    public static Id getRecordTypeIdByName(String objectName, String recordTypeName) {
        Id recordTypeId;
        for (RecordTypeInfo rTypeInfo: (loadRecordTypes(objectName)).get(objectName).values()) {
            if (rTypeInfo.getName() == recordTypeName) {
                recordTypeId = rTypeInfo.getRecordTypeId();
                break;
            }
        }
        return recordTypeId;
    }
    
    /**
* This method returns the recordtypeId based on the record developer name
*/
    @AuraEnabled(cacheable = true)
    public static Id getRecordTypeIdByDevName(String objectName, String recordTypeDevName) {
        Id recordTypeId;
        for (RecordTypeInfo rTypeInfo: (loadRecordTypes(objectName)).get(objectName).values()) {
            if (rTypeInfo.getDeveloperName() == recordTypeDevName) {
                recordTypeId = rTypeInfo.getRecordTypeId();
                break;
            }
        }
        return recordTypeId;
    }
    
    /**
* This methods return set of record type Ids based on the set of record type names and object name.
*/
    public static set < Id > getRecordTypeIdsByNames(String objectName, set < String > setRecordTypeNames) {
        set < Id > setRecordTypeIds = new set < Id > ();
        for (RecordTypeInfo rTypeInfo: (loadRecordTypes(objectName)).get(objectName).values()) {
            if (setRecordTypeNames.contains(rTypeInfo.getName())) {
                setRecordTypeIds.add(rTypeInfo.getRecordTypeId());
            }
        }
        return setRecordTypeIds;
    }
    
    /**
* This methods return set of record type Ids based on the set of record type dev names and object name.
*/
    public static set < Id > getRecordTypeIdsByDevNames(String objectName, set < String > setRecordTypeDevNames) {
        set < Id > setRecordTypeIds = new set < Id > ();
        for (RecordTypeInfo rTypeInfo: (loadRecordTypes(objectName)).get(objectName).values()) {
            if (setRecordTypeDevNames.contains(rTypeInfo.getDeveloperName())) {
                setRecordTypeIds.add(rTypeInfo.getRecordTypeId());
            }
        }
        return setRecordTypeIds;
    }
    
    /**
* This method return Record type name based on record type Id and object name
*/
    public static String getRecordTypeNameById(String objectName, Id recordTypeId) {
        return ((loadRecordTypes(objectName)).get(objectName)).get(recordTypeId).getName();
    }
    
    /**
* This method return Record type Developer name based on record type Id and object name
*/
    public static String getRecordTypeDevNameById(String objectName, Id recordTypeId) {
        return ((loadRecordTypes(objectName)).get(objectName)).get(recordTypeId).getDeveloperName();
    }
    
    /**
* This methods return set of record type Names based on the record type Ids and object name.
*/
    public static set < String > getRecordTypeNamesByIds(String objectName, set < Id > setRecordTypeIds) {
        set < String > setRecordTypeNames = new set < String > ();
        for (RecordTypeInfo rTypeInfo: (loadRecordTypes(objectName)).get(objectName).values()) {
            if (setRecordTypeIds.contains(rTypeInfo.getRecordTypeId())) {
                setRecordTypeNames.add(rTypeInfo.getName());
            }
        }
        return setRecordTypeNames;
    }
    
    /**
* This methods return map, key as recordTypeId and value as record type Name based on the record type Names and object name
*/
    public static map < Id, String > getRecordTypeIdNameMapByNames(String objectName, set < String > setRecordTypeNames) {
        map < Id, String > mapRecordTypes = new map < Id, String > ();
        for (RecordTypeInfo rTypeInfo: (loadRecordTypes(objectName)).get(objectName).values()) {
            if (setRecordTypeNames.contains(rTypeInfo.getName())) {
                mapRecordTypes.put(rTypeInfo.getRecordTypeId(), rTypeInfo.getName());
            }
        }
        return mapRecordTypes;
    }
    
    /**
* This methods return map, key as recordTypeId and value as record type name based on the record type Ids and object name.
*/
    public static map < Id, String > getRecordTypeIdNameMapByIds(String objectName, set < Id > setRecordTypeIds) {
        map < Id, String > mapRecordTypes = new map < Id, String > ();
        for (RecordTypeInfo rTypeInfo: (loadRecordTypes(objectName)).get(objectName).values()) {
            if (setRecordTypeIds.contains(rTypeInfo.getRecordTypeId())) {
                mapRecordTypes.put(rTypeInfo.getRecordTypeId(), rTypeInfo.getName());
            }
        }
        return mapRecordTypes;
    }
    
    /**
* This method return map, key as record type name and value as recordtypeId based on the object name and record type names
*/
    public static map < String, Id > getRecordTypeNameIdMapByNames(String objectName, set < String > setRecordTypeNames) {
        map < String, Id > mapRecordTypes = new map < String, Id > ();
        for (RecordTypeInfo rTypeInfo: (loadRecordTypes(objectName)).get(objectName).values()) {
            if (setRecordTypeNames.contains(rTypeInfo.getName())) {
                mapRecordTypes.put(rTypeInfo.getName(), rTypeInfo.getRecordTypeId());
            }
        }
        return mapRecordTypes;
    }
    
    /**
* This method return map, key as record type name and value as recordtypeId based on the object name and record type Developernames
*/
    public static map < String, Id > getRecordTypeDevNameIdMapByDevNames(String objectName, set < String > setRecordTypeDevNames) {
        map < String, Id > mapRecordTypes = new map < String, Id > ();
        for (RecordTypeInfo rTypeInfo: (loadRecordTypes(objectName)).get(objectName).values()) {
            if (setRecordTypeDevNames.contains(rTypeInfo.getDeveloperName())) {
                mapRecordTypes.put(rTypeInfo.getDeveloperName(), rTypeInfo.getRecordTypeId());
            }
        }
        return mapRecordTypes;
    }
    
    /**
* This method return map, key as record type name and value as recordtypeId based on the object name and record type Ids
*/
    public static map < String, Id > getRecordTypeNameIdMapByIds(String objectName, set < Id > setRecordTypeIds) {
        map < String, Id > mapRecordTypes = new map < String, Id > ();
        for (RecordTypeInfo rTypeInfo: (loadRecordTypes(objectName)).get(objectName).values()) {
            if (setRecordTypeIds.contains(rTypeInfo.getRecordTypeId())) {
                mapRecordTypes.put(rTypeInfo.getName(), rTypeInfo.getRecordTypeId());
            }
        }
        return mapRecordTypes;
    }
    
    /**
* This method return the map, key as record type id and value as record type name based on the object name. this method consider only available record types.
*/
    @AuraEnabled
    public static map < Id, String > retriveRecordTypeIdWithNames(String strObjectName) {
        Map < Id, String > mapRecordTypes = new Map < Id, String > ();
        list < Schema.RecordTypeInfo > lstRecordtypes = Schema.getGlobalDescribe().get(strObjectName).getDescribe().getRecordTypeInfos();
        
        for (RecordTypeInfo rt: lstRecordtypes) {
            if (rt.isAvailable()) { // checkes record type is available for current user
                if (rt.getName() != 'Master' && rt.getName().trim() != '') {
                    mapRecordTypes.put(rt.getRecordTypeId(), rt.getName());
                }
            }
        }
        return mapRecordTypes;
    }
    /**
* This method return the map, key as record type id and value as record type developer name based on the object name. this method consider only available record types.
*/
    public static map < Id, String > retriveRecordTypeIdWithDevNames(String strObjectName) {
        Map < Id, String > mapRecordTypes = new Map < Id, String > ();
        list < Schema.RecordTypeInfo > lstRecordtypes = Schema.getGlobalDescribe().get(strObjectName).getDescribe().getRecordTypeInfos();
        for (RecordTypeInfo rt: lstRecordtypes) {
            if (rt.isAvailable()) { // checkes record type is available for current user
                if (rt.getDeveloperName() != 'Master' && rt.getDeveloperName().trim() != '') {
                    mapRecordTypes.put(rt.getRecordTypeId(), rt.getDeveloperName());
                }
            }
        }
        return mapRecordTypes;
    }
    /**
    * This method return the map, key as record type id and value as record type developer name based on the object name. this method consider all record types.
    */
    public static map < Id, String > retriveRecordTypeIdDevNames(String strObjectName) {
        Map < Id, String > mapRecordTypes = new Map < Id, String > ();
        list < Schema.RecordTypeInfo > lstRecordtypes = Schema.getGlobalDescribe().get(strObjectName).getDescribe().getRecordTypeInfos();
        for (RecordTypeInfo rt: lstRecordtypes) {
            if (rt.getDeveloperName() != 'Master' && rt.getDeveloperName().trim() != '') {
                mapRecordTypes.put(rt.getRecordTypeId(), rt.getDeveloperName());
            }
        }
        return mapRecordTypes;
    }
    /**
* This method returns the list of files related parent record.
* This method return the map, key as parent Id and value as list of contentversions based on the list of parent Ids
*/
    public static map < Id, list < ContentVersion >> getRelatedFiles(list < Id > lstParentIds) {
        map < Id, list < ContentVersion >> mapParentIdAndFiles = new map < Id, list < ContentVersion >> ();
        map < Id, Id > mapCntIdParentId = new map < Id, Id > ();
        
        for (ContentDocumentLink cntLink: [SELECT Id, ContentDocumentId, LinkedEntityId
                                           FROM ContentDocumentLink
                                           WHERE LinkedEntityId IN: lstParentIds
                                          ]) {
                                              mapCntIdParentId.put(cntLink.ContentDocumentId, cntLink.LinkedEntityId);
                                          }
        
        if (!mapCntIdParentId.isEmpty()) {
            for (ContentVersion cv: [SELECT Id, Title, VersionData, ContentDocumentId
                                     FROM ContentVersion
                                     WHERE ContentDocumentId IN: mapCntIdParentId.keySet()
                                     AND IsLatest = True
                                    ]) {
                                        
                                        if (!mapParentIdAndFiles.containsKey(mapCntIdParentId.get(cv.ContentDocumentId))) {
                                            mapParentIdAndFiles.put(mapCntIdParentId.get(cv.ContentDocumentId), new list < ContentVersion > ());
                                        }
                                        
                                        mapParentIdAndFiles.get(mapCntIdParentId.get(cv.ContentDocumentId)).add(cv);
                                    }
        }
        
        return mapParentIdAndFiles;
    }
    
    /**
* This method return the parent record have how many files.
* This method returns the map, key as parent Id and value as cout of files(Integer) based on list of parent record Ids
*/
    public static map < Id, Integer > rollupFiles(list < Id > lstLinkedEntityIds) {
        map < Id, Integer > mapCntLinkWithSize = new map < Id, Integer > ();
        if (!lstLinkedEntityIds.isEmpty()) {
            for (AggregateResult cntLinkRes: [SELECT LinkedEntityId, count(ContentDocumentId) cndDocs FROM ContentDocumentLink Where LinkedEntityId IN: lstLinkedEntityIds Group BY LinkedEntityId]) {
                mapCntLinkWithSize.put((Id) cntLinkRes.get('LinkedEntityId'), (Integer) cntLinkRes.get('cndDocs'));
            }
            
            // To initialize the roll up as 0 for the Cases / any parents which do not have any files associated with it. 
            set < Id > setLinkEntityIds = new set < Id > ();
            setLinkEntityIds.addAll(lstLinkedEntityIds);
            setLinkEntityIds.removeAll(mapCntLinkWithSize.keySet());
            for (Id linkIdIterator: setLinkEntityIds) {
                mapCntLinkWithSize.put(linkIdIterator, 0);
            }
        }
        return mapCntLinkWithSize;
    }
    
    /**
* This method Merge fields populated on primary instance into source instance.
*/
    public static void mergeObjects(map < Id, sObject > mapSource, list < sObject > lstPrimary) {
        for (sObject sObj: lstPrimary) {
            if (mapSource.containsKey(sObj.Id)) {
                // If the record is already available in the source, then copy the fields populated in primary record into source record. 
                sObject objSource = mapSource.get(sObj.Id);
                for (String strFieldName: sObj.getPopulatedFieldsAsMap().keySet()) {
                    objSource.put(strFieldName, sObj.get(strFieldName));
                }
            } else {
                mapSource.put(sObj.Id, sObj);
            }
        }
    }
    
    /**
* This method return the object name based on the record id
*/
    @AuraEnabled
    public static String getObjectNameFromRecordId(Id idRec) {
        if (idRec != null) {
            Schema.sObjectType sObjType = idRec.getSObjectType();
            Schema.DescribeSObjectResult sObjDescribeResult = sObjType.getDescribe();
            return sObjDescribeResult.getName();
        } else {
            return null;
        }
    }
    
    public static list < String > getAllFields(String strObjName) {
        list < String > lstFields;
        if (String.isNotBlank(strObjName)) {
            lstFields = new List < String > (Schema.getGlobalDescribe().get(strObjName).getDescribe().fields.getMap().keySet());
        }
        
        if (lstFields != null && !lstFields.isEmpty()) {
            return lstFields;
        } else {
            return null;
        }
    }
    
    // Queue Related Methods
    private static map < Id, Group > mapQueues;
    public static map < Id, Group > getQueueMap() {
        if (mapQueues == null || mapQueues.isEmpty()) {
            /*if (Test.isRunningTest()) {
                mapQueues = new map < Id, Group > ([select Id, Name, DeveloperName, Email, DoesSendEmailToMembers from Group where Type = 'Queue'
                                                    limit 10
                                                   ]);
            } else {*/
                mapQueues = new map < Id, Group > ([select Id, Name, DeveloperName, Email, DoesSendEmailToMembers from Group where Type = 'Queue'
                                                    limit 10000
                                                   ]);
            //}
        }
        return mapQueues;
    }
    
    public static Group getQueueById(Id queueId) {
        return (getQueueMap()).get(queueId);
    }
    
    public static map < Id, String > getQueueIdNameMap() {
        map < Id, String > mapQueueIdName = new map < Id, String > ();
        for (Group queueIterator: (getQueueMap()).values()) {
            mapQueueIdName.put(queueIterator.Id, queueIterator.Name);
        }
        return mapQueueIdName;
    }
    
    public static String getQueueNameById(Id queueId) {
        return (getQueueIdNameMap()).get(queueId);
    }
    
    public static map < String, Id > getQueueNameIdMap() {
        map < String, Id > mapQueueNameId = new map < String, Id > ();
        for (Group queueIterator: (getQueueMap()).values()) {
            mapQueueNameId.put(queueIterator.Name, queueIterator.Id);
        }
        return mapQueueNameId;
    }
    
    public static map < String, Id > getQueueDevNameIdMap() {
        map < String, Id > mapQueueDevNameId = new map < String, Id > ();
        for (Group queueIterator: (getQueueMap()).values()) {
            mapQueueDevNameId.put(queueIterator.DeveloperName, queueIterator.Id);
        }
        return mapQueueDevNameId;
    }
    
    public static String getQueueIdByName(String queueName) {
        return (getQueueNameIdMap()).get(queueName);
    }
    
    public static String getQueueIdByDevName(String queueDevName) {
        return (getQueueDevNameIdMap()).get(queueDevName);
    }
    
    private static map < String, Id > mapQueueNameId;
    public static map < String, Id > getQueueNameIdMapByNames(String sObjectName, set < String > queueNameList) {
        if (mapQueueNameId == null || !mapQueueNameId.keySet().containsAll(queueNameList)) {
            mapQueueNameId = new map < String, Id > ();
            for (QueueSobject queueObj: [SELECT Id, QueueId, Queue.Name
                                         FROM QueueSobject
                                         WHERE SobjectType =: sObjectName AND Queue.Name IN: queueNameList
                                        ]) {
                                            mapQueueNameId.put(queueObj.Queue.Name, queueObj.QueueId);
                                        }
        }
        return mapQueueNameId;
    }
    
    // Public Group Related Methods
    private static map < Id, Group > mapGroups;
    public static map < Id, Group > getGroupMap() {
        if (mapGroups == null || mapGroups.isEmpty()) {
            if (Test.isRunningTest()) {
                mapGroups = new map < Id, Group > ([select Id, Name from Group where Type = 'Regular'
                                                    limit 10
                                                   ]);
            } else {
                mapGroups = new map < Id, Group > ([select Id, Name from Group where Type = 'Regular'
                                                    limit 10000
                                                   ]);
            }
        }
        return mapGroups;
    }
    
    public static Group getGroupById(Id groupId) {
        return (getGroupMap()).get(groupId);
    }
    
    public static map < Id, String > getGroupIdNameMap() {
        map < Id, String > mapGroupIdName = new map < Id, String > ();
        for (Group groupIterator: (getGroupMap()).values()) {
            mapGroupIdName.put(groupIterator.Id, groupIterator.Name);
        }
        return mapGroupIdName;
    }
    
    public static String getGroupNameById(Id groupId) {
        return (getGroupIdNameMap()).get(groupId);
    }
    
    public static map < String, Id > getGroupNameIdMap() {
        map < String, Id > mapGroupNameId = new map < String, Id > ();
        for (Group groupIterator: (getGroupMap()).values()) {
            mapGroupNameId.put(groupIterator.Name, groupIterator.Id);
        }
        return mapGroupNameId;
    }
    
    public static String getGroupIdByName(String groupName) {
        return (getGroupNameIdMap()).get(groupName);
    }
    // Record Types Related Utilities - Describe
    private static map < String, map < String, RecordTypeInfo >> mapAllRecordTypeDevName;
    private static map < String, map < String, RecordTypeInfo >> loadRecordTypeDevName(String objectName) {
        if (mapAllRecordTypeDevName == null) {
            mapAllRecordTypeDevName = new map < String, map < String, RecordTypeInfo >> ();
        }
        if (!mapAllRecordTypeDevName.containsKey(objectName)) {
            list < Schema.DescribeSObjectResult > descSObjectResults = Schema.describeSObjects(new String[] {
                objectName
                    });
            map < String, Schema.RecordTypeInfo > mapRecordType = new map < String, Schema.RecordTypeInfo > ();
            for (Schema.RecordTypeInfo recordType: descSObjectResults[0].getRecordTypeInfos()) {
                mapRecordType.put(recordType.getDeveloperName(), recordType);
            }
            mapAllRecordTypeDevName.put(objectName, mapRecordType);
        }
        return mapAllRecordTypeDevName;
    }
    public static map < String, RecordTypeInfo > getAllrecordTypeDevName(String objName) {
        return loadRecordTypeDevName(objName).get(objName);
    }
    
    // Fetches Id from sobject List
    public static Set < Id > getIdsFromList(List < sObject > sobjectList) {
        if (!sobjectList.isEmpty()) {
            return new Map < Id, sObject > (sobjectList).keySet();
        }
        return null;
    }
    
    public static void updateSobjects(list < Sobject > lstObjects) {
        System.debug('****lstObjects' + lstObjects);
        database.saveresult[] srlist = database.update(lstObjects, false);
        for (Database.SaveResult sr: srList) {
            if (sr.isSuccess()) {
                System.debug('Sobject updated ' + sr.getId());
            } else {
                for (Database.Error err: sr.getErrors()) {
                    System.debug('Sobject fields that affected this error: ' + err.getFields());
                    System.debug('errorMessage' + err.getMessage());
                }
            }
        }
    }
    
    public static String getTransactionIdFromJSON(String strJSON) {
        String strKey = '';
        if (String.isNotBlank(strJSON)) {
            map < String, Object > mapData = (map < String, Object > ) JSON.deserializeUntyped(strJSON);
            if (mapData != null && !mapData.isEmpty() && (String) mapData.get('transactionid') != null) {
                strKey = String.valueOf((String) mapData.get('transactionid'));
            }
        }
        
        return strKey;
    }
    public static map < String, Object > getResponseMapObject(String strJSON) {
        String strKey = '';
        map < String, Object > mapData;
        if (String.isNotBlank(strJSON)) {
            mapData = (map < String, Object > ) JSON.deserializeUntyped(strJSON);
        }
        
        return mapData;
    }
    public static void upsertErrorLogForEvents(list<sObject> lstObjects, Database.SaveResult[] srList, String requestOrResponse) {
        List<npsp__Error__c> errorRecords = new List< npsp__Error__c > ();
        Map<String, String> lookUpFieldDetails = getLookupFieldDetails('npsp__Error__c'); //Map that stores field Label as key and ApiName as value.
        Map<String, String> transIdPayload = new Map<String, String>(); //Map that stores transaction Id as key and Payload as value
        Set<String> recordIdFormats = new Set<String>{'003','500'};
            
        
        system.debug('lookUpFieldDetails'+lookUpFieldDetails);
        
        
        for (Integer i = 0; i <lstObjects.size(); i++) {
            npsp__Error__c eachErrorRecord = new npsp__Error__c();
            if (srList != null && !srList.isEmpty()) {
                if (!srList.isEmpty() || srList != null) {
                    if (!srList[i].isSuccess()) {
                        for (Database.Error err: srList[i].getErrors()) {
                            eachErrorRecord.npsp__Full_Message__c += err.getMessage();
                        }
                        
                    }
                }
            }
            sObject sobj = lstObjects[i];
            system.debug('(String) sobj.get'+(String) sobj.get('Payload__c'));
            system.debug('(String) payload__c'+(String) sobj.get('payload__c'));
             
            String strpayload = sobj.get('Payload__c') != null ? (String)sobj.get('Payload__c') : (String) sobj.get('payload__c');
            if (sobj != null && String.isNotBlank(strpayload)) {
                if (requestOrResponse != null && requestOrResponse == Constants.REQUEST)  eachErrorRecord.Request__c = strpayload;
   			    else if (requestOrResponse != null && requestOrResponse == Constants.RESPONSE) eachErrorRecord.Response__c = strpayload;
                
                map<String, Object> mapObj;
                if(requestOrResponse == Constants.REQUEST) mapObj = GenericUtilities.getResponseMapObject(strpayload);
                //if(requestOrResponse == Constants.REQUEST) mapObj = GenericUtilities.getResponseMapObject((String)JSON.deserialize(strpayload, String.class));
                else mapObj = GenericUtilities.getResponseMapObject(strpayload);
                
                system.debug('mapObj'+mapObj);
                
                string strTransKey = String.valueOf((String) mapObj.get('transactionId'));
                System.debug('*****strTransKey'+strTransKey);
                eachErrorRecord.Unique_Key__c = strTransKey;
                transIdPayload.put(strTransKey, (String)sobj.get('Payload__c') != null ? (String)sobj.get('Payload__c') : (String)sobj.get('payload__c'));
                if (String.isNotBlank(strTransKey)) {
                    list < String > lstValues = strTransKey.split('-');                       
                    for (String eachString: lstValues) {       
                                                
                        if (eachString.length()>3 && recordIdFormats.contains(eachString.substring(0, 3))) {
                            system.debug('eachString'+eachString);
                            String sObjName = Id.valueOf(eachString).getSObjectType().getDescribe().getName();
                            system.debug('sObjName'+sObjName);
                            if (lookUpFieldDetails.get(sObjName) != null)
                                eachErrorRecord.put(lookUpFieldDetails.get(sObjName), Id.valueOf(eachString));
                            system.debug('eachErrorRecord'+eachErrorRecord);
                        }
                    }
                }
            }
            errorRecords.add(eachErrorRecord);
        }
        if (!errorRecords.isEmpty() && errorRecords.size() > 0)
            createErrorLogs(errorRecords);
    }
    
    Public static void createErrorLogs(list < npsp__Error__c > npspErrorLogs) {
        if (!npspErrorLogs.isEmpty() && npspErrorLogs != null && npsp__Error__c.SObjectType.getDescribe().isCreateable()) {
            try {
                upsert npspErrorLogs Unique_Key__c;
            }
            Catch(Exception e) {
                system.debug('=createErrorLogs=> ' + e.getMessage());
            }
        }
    }
    
    public static Map < String, String > getLookupFieldDetails(String objectApiName) {
        Map < String, String > fieldDetails = new Map < String, String > ();
        Map < String, Schema.SObjectType > schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(objectApiName);
        Map < String, Schema.SObjectField > fieldMap = leadSchema.getDescribe().fields.getMap();
        
        for (String fieldName: fieldMap.keySet()) {
            //get all the fields label for Specific Object
            String fieldLabel = fieldMap.get(fieldName).getDescribe().getLabel();
            //get data types for each fields
            Schema.DisplayType fielddataType = fieldMap.get(fieldName).getDescribe().getType();
            if (fielddataType == Schema.DisplayType.Reference) {
                fieldDetails.put(fieldLabel, fieldMap.get(fieldName).getDescribe().getName());
            }
        }
        return fieldDetails;
    }
    public static String getUUID() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0, 8) + '-' + h.SubString(8, 12) + '-' + h.SubString(12, 16) + '-' + h.SubString(16, 20) + '-' + h.substring(20);
        system.debug(guid);
        return guid;
    }
    
    public class CIBISWrapperInfo {
        public Map < String, npsp__Error__c > mapCaseIdErrors;
        public Map < String, npsp__Error__c > mapConIdErrors;
        public map < Id, sObject > mapUniqueKeySobjs;
        public map < Id, String > mapUniqueKeys;
    }
    //To get field names as case Sensitive
    public static List<String> getFieldNameList(String strObjName){
        List<String> fieldList = new List<String>();
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(strObjName).getDescribe().fields.getMap();
        for (String fieldName : fieldMap.keySet()){
            fieldList.Add(fieldMap.get(fieldName).getDescribe().getName());
        }
        return fieldList;
    }
    // Checks if the specified sObject is updateable
    public static Boolean checkIsUpdatable(String strObjName){
        if(Schema.getGlobalDescribe().get(strObjName).getDescribe().isUpdateable()){
            return true;
        }
        return false;
    }
    // Checks if the specified sObject is creatable
    public static Boolean checkIsCreatable(String strObjName){
        if(Schema.getGlobalDescribe().get(strObjName).getDescribe().isCreateable()){
            return true;
        }
        return false;
    }
    // Checks if the specified sObject is deleteable
    public static Boolean checkIsDeletable(String strObjName){
        if(Schema.getGlobalDescribe().get(strObjName).getDescribe().isDeletable()){
            return true;
        }
        return false;
    }
}