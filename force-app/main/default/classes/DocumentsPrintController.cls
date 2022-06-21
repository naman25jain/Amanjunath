/**
@Name: Shaik Nagajani
@Description: 
- This class contains the palnet press printing related methods.

@History
VERSION     AUTHOR             DATE            DETAIL
1.0         Shaik Nagajani     15/Nov/2021     Created the Apex class.
**/

public inherited sharing class DocumentsPrintController {
    // This list cases come form vf page
    public list<Case> lstCases {get;set;}
    // Static varibales
    public static list<Asset> lstAssets = new List<Asset>();
    public static set<String> setAssetTypes = new set<String>();
    public static set<String> setAssetDevNames = new set<String>();
    public static set<String> setAssetStatus = new set<String>();
    public static map<Id, sObject> mapCaseSObjects = new map<Id, sObject>();
    public static map<String, set<Id>> mapFieldAndIds = new map<String, set<Id>>();
    public static map<String, list<Asset>> mapKeyAndAssets = new map<String, list<Asset>>();
    public static Map<Id, list<DocumentWrapper>> mapCasIdAndWrappers = new Map<Id, list<DocumentWrapper>>();
    public static map<String, list<ECFMG_Print_Config__mdt>> mapRecDevNameAndMdts = new Map<String, List<ECFMG_Print_Config__mdt>>();
    public static Map<Id, Map<String, ECFMG_Print_Config__mdt>> mapOfMdtsWithKey = new Map<Id, Map<String, ECFMG_Print_Config__mdt>>();
    public static Map<String, list<SObject>> mapUniquekeyAndObjects = new Map<String, List<SObject>>();
    public static Map<String, list<ECFMG_Print_Config__mdt>> mapuniquekeyAndMdts = new Map<String, list<ECFMG_Print_Config__mdt>>();
    public static map<Id, Integer> mapCaseIdAndNoOfCopies = new Map<Id, Integer>();

    public static set<String> setRecDevNames = new set<String>{PlanetPressConstants.USMLE_Transcript, PlanetPressConstants.Non_USMLE_Transcript};
    public static set<String> setAstNames = new set<String>{PlanetPressConstants.SHIPPING_LABEL};
    
    public static String strErrorMsg = '';
    
    // StandardSetController to get the selected cases from list view
    private ApexPages.StandardSetController stdController;
    
    public DocumentsPrintController(ApexPages.StandardSetController stdController) {
        this.stdController = stdController;
    }
    
    public PageReference getSelectedCases() {
        // getting the selected case ids from list view
        lstCases = (List<Case>) stdController.getSelected();  
        return null; 
    }
    
    /**
    * @Name: Shaik Nagajani
    * This method returns custom metadata records
    */
    public static list<ECFMG_Print_Config__mdt> getCstmMdtRecords() {
        String strQuery = 'SELECT '+ String.join(GenericUtilities.getAllFields('ECFMG_Print_Config__mdt'), ', ') + ' FROM ECFMG_Print_Config__mdt WHERE Active__c = true';
        return Database.query(strQuery);
    }
    
    /**
    * @Name: Shaik Nagajani
    * This method returns the case information based on the list of case ids
    */
    public static map<Id, sObject> getCasesInfo(list<Id> lstIds) {
        // mapCaseIdAndNoOfCopies
        map<Id, sObject> mapObjects = new map<Id, sObject>();
        set<Id> setCaseIds = new set<Id>();
        
        if(lstIds != null && !lstIds.isEmpty()) {
            String strQuery = 'SELECT '+ String.join(GenericUtilities.getAllFields('Case'), ', ') + ', RecordType.DeveloperName, (SELECT Id, Number_of_Copies__c from Transcript_Requests__r) FROM Case WHERE Id IN:lstIds Order by CreatedDate DESC';
            list<Case> lstOfCases = Database.query(strQuery);
            
            if(lstOfCases != null && !lstOfCases.isEmpty()) {
                for(Case iterator : lstOfCases) {
                    mapObjects.put(iterator.Id, iterator);

                    if(setRecDevNames.contains(iterator.RecordType.DeveloperName) && iterator.Transcript_Requests__r != null && iterator.Transcript_Requests__r.size() > 0) {
                        Integer icount = 0;
                        for(Transcript_Request__c req : iterator.Transcript_Requests__r) {
                            icount += (Integer)req.Number_of_Copies__c != null ? (Integer)req.Number_of_Copies__c : 1;
                        }
                        mapCaseIdAndNoOfCopies.put(iterator.Id, icount);
                    }
                }
            }
        }        
        return mapObjects;
    }
    
    /**
    * @Name: Shaik Nagajani
    * This method will call from when the button click on the case list view and it procees the cases to planet press
    */
    @AuraEnabled
    public static String sendBulkDocsToPrint(list<Id> lstIds) {
        try {
            List<Asset> lstAss = new list<Asset>();
            list<ECFMG_Print_Config__mdt> lstMdts = getCstmMdtRecords();
            mapCaseSObjects = getCasesInfo(lstIds);
            processMdtsAndCases(lstMdts, mapCaseSObjects);
            List<Asset> lstAssets = constructDynamicSOQLQueryAndgetAssets(mapCaseSObjects, mapFieldAndIds, setAssetTypes, setAssetDevNames, setAssetStatus);
           	
            DocumentPrintUtilities.filterAssetsBasedOnCaseInfo(mapCaseSObjects, lstAssets, lstAss);
            
            if(mapUniquekeyAndObjects != null && !mapUniquekeyAndObjects.isEmpty()) {
                map<Id, list<Asset>> mapCustomAssets = processCustomLogic(mapUniquekeyAndObjects, mapuniquekeyAndMdts);
                if(mapCustomAssets != null && !mapCustomAssets.isEmpty()) {
                    for(String s : mapCustomAssets.keySet()) {
                        lstAss.addAll(mapCustomAssets.get(s));
                    }
                }
            }
            processAssetsUniquies(lstAss);
            processAssetRecords(mapCaseSObjects, mapKeyAndAssets, mapOfMdtsWithKey);
            return constructPayloadAndPublishEvent(mapCasIdAndWrappers);
        }
        catch(Exception ex) {
			CibisUtility.insertSobjects(new list<npsp__Error__c>{new npsp__Error__c(npsp__Full_Message__c=ex.getMessage()+'--'+ex.getTypeName(),npsp__Stack_Trace__c=ex.getStackTraceString()+'--'+ex.getLineNumber(),npsp__Error_Type__c='DocumentsPrintController')});
            strErrorMsg += ex.getMessage() +'@~';
            throw new AuraHandledException(ex.getMessage());
        }  
    }
    
    /**
    * @Name: Shaik Nagajani
    * This method process the assets and it will create the unique map based in the assets
    */
    public static void processAssetsUniquies(list<Asset> assetToprocess) {
        try {
            if(assetToprocess != null && !assetToprocess.isEmpty()) {
                for(Asset ast : assetToprocess) {
                    sobject sObj = ast;
                    for(String str : mapFieldAndIds.keySet()) {      
                        String strValue = (String)sObj.get(str);
                        
                        if(String.isNotBlank(strValue)) {
                            String strRecordDevName = '';
                            if(ast.RecordTypeId != null) strRecordDevName = Schema.SObjectType.Asset.getRecordTypeInfosById().get(ast.RecordTypeId).getDeveloperName();
                            
                            // Construct the unique key to identify the cases and assets based on case
                            String strkey = (ast.Filename__c=='CustomLogic' ? 'CustomLogcKey' : str)+'-'+(ast.Filename__c=='CustomLogic' ? null : strValue )+'-'+(ast.Type__c != null ? ast.Type__c : null)+'-'+(ast.RecordType.DeveloperName != null ? ast.RecordType.DeveloperName : (String.isNotBlank(strRecordDevName) ? strRecordDevName : null));
                            
                            if(!mapKeyAndAssets.containsKey(strKey))  mapKeyAndAssets.put(strKey, new list<Asset>{ast});
                            else mapKeyAndAssets.get(strKey).add(ast);
                        }
                    }
                }
            }
        }
        catch(Exception ex) {
			CibisUtility.insertSobjects(new list<npsp__Error__c>{new npsp__Error__c(npsp__Full_Message__c=ex.getMessage()+'--'+ex.getTypeName(),npsp__Stack_Trace__c=ex.getStackTraceString()+'--'+ex.getLineNumber(),npsp__Error_Type__c='DocumentsPrintController')});
            strErrorMsg += ex.getMessage() +'@~';
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    /**
    * @Name: Shaik Nagajani
    * This method process the Cases and metadata records based on the values it constrct the multiple maps.
    */
    public static void processMdtsAndCases(list<ECFMG_Print_Config__mdt> lstMdts, map<Id, sObject> mapCaseSObjects) {
        try {
            if(lstMdts != null && !lstMdts.isEmpty()) {
                for(ECFMG_Print_Config__mdt mIterator : lstMdts) {
                    if(!mapRecDevNameAndMdts.containsKey(mIterator.Record_Type_Dev_Name__c)) mapRecDevNameAndMdts.put(mIterator.Record_Type_Dev_Name__c, new list<ECFMG_Print_Config__mdt>{mIterator});
                    else mapRecDevNameAndMdts.get(mIterator.Record_Type_Dev_Name__c).add(mIterator);
                }
                
                if(mapRecDevNameAndMdts != null && !mapRecDevNameAndMdts.isEmpty() && mapCaseSObjects != null && !mapCaseSObjects.isEmpty()) {
                    for(Sobject sObj : mapCaseSObjects.values()) {
                        String strDevName = (String)sObj.getSObject('RecordType').get('DeveloperName');
                        if(String.isNotBlank(strDevName) && mapRecDevNameAndMdts.containsKey(strDevName)) {
                            for(ECFMG_Print_Config__mdt mObj : mapRecDevNameAndMdts.get(strDevName)) { 
                                String strFieldValue = '';
                                // geeting value from case based on metadata value
                                if(String.isNotBlank(mObj.Filed_API_Name_from_Case__c)) strFieldValue = (String)sObj.get(mObj.Filed_API_Name_from_Case__c);
     
                                if(String.isNotBlank(strFieldValue)) {
                                    // Construct the unique key to identify the cases and assets based on metadata
                                    String strKey = (!mObj.Custom_Logic__c && String.isNotBlank(mObj.Filed_API_Name_from_Asset__c) ? mObj.Filed_API_Name_from_Asset__c : 'CustomLogcKey')+'-'+(!mObj.Custom_Logic__c ? strFieldValue : null)+'-'+mObj.Asset_Type__c+'-'+mObj.Asset_Record_Type_Developer_Name__c;
                                    if(!mapOfMdtsWithKey.containsKey((Id)sObj.get('Id')))  mapOfMdtsWithKey.put((Id)sObj.get('Id'), new map<String, ECFMG_Print_Config__mdt>{strKey => mObj});
                                    else mapOfMdtsWithKey.get((Id)sObj.get('Id')).put(strKey, mObj);
                                }
                                
                                // The unquie map based on the metadata and case information
                                if(String.isNotBlank(mObj.Filed_API_Name_from_Asset__c) && String.isNotBlank(strFieldValue)) {
                                    if(!mapFieldAndIds.containsKey(mObj.Filed_API_Name_from_Asset__c)) mapFieldAndIds.put(mObj.Filed_API_Name_from_Asset__c, new set<Id>{strFieldValue});
                                    else mapFieldAndIds.get(mObj.Filed_API_Name_from_Asset__c).add(strFieldValue);
                                }
                                
                                // Identify the custom logics metadatas to process the custom logic process
                                if(mObj.Custom_Logic__c && String.isNotBlank(mObj.Custom_Logic_Unique_Key__c)) {
                                    if(!mapUniquekeyAndObjects.containsKey(mObj.Custom_Logic_Unique_Key__c)) mapUniquekeyAndObjects.put(mObj.Custom_Logic_Unique_Key__c, new list<sObject>{sObj});
                                    else mapUniquekeyAndObjects.get(mObj.Custom_Logic_Unique_Key__c).add(sObj);
                                    
                                    if(!mapuniquekeyAndMdts.containsKey(mObj.Custom_Logic_Unique_Key__c)) mapuniquekeyAndMdts.put(mObj.Custom_Logic_Unique_Key__c, new list<ECFMG_Print_Config__mdt>{mObj});
                                    else mapuniquekeyAndMdts.get(mObj.Custom_Logic_Unique_Key__c).add(mObj);
                                }
                                
                                // capturing the asset related infomation from metadata to query the asset information
                                if(!mObj.Custom_Logic__c && String.isBlank(mObj.Custom_Logic_Unique_Key__c)) {
                                    setAssetTypes.add(mObj.Asset_Type__c);
                                    setAssetDevNames.add(mObj.Asset_Record_Type_Developer_Name__c);
                                    if(mObj.Asset_Status__c != NULL && mObj.Asset_Status__c.contains(PlanetPressConstants.STRING_SEPARATOR)) setAssetStatus.addAll(mObj.Asset_Status__c.split(PlanetPressConstants.STRING_SEPARATOR));
                                    else setAssetStatus.add(mObj.Asset_Status__c);
                                }
                                
                                // removing the null value from sets
                                setAssetTypes.remove(null);
                                setAssetDevNames.remove(null);
                                setAssetStatus.remove(null);
                            }
                        }
                    }
                }
            }
        }
        catch (Exception ex) {
            CibisUtility.insertSobjects(new list<npsp__Error__c>{new npsp__Error__c(npsp__Full_Message__c=ex.getMessage()+'--'+ex.getTypeName(),npsp__Stack_Trace__c=ex.getStackTraceString()+'--'+ex.getLineNumber(),npsp__Error_Type__c='DocumentsPrintController')});
            strErrorMsg += ex.getMessage() +'@~';
            throw new AuraHandledException(ex.getMessage());
        }   
    }
    
    /**
    * @Name: Shaik Nagajani
    * This method returns the list of assets based on the input values
    */
    public static list<Asset> constructDynamicSOQLQueryAndgetAssets(map<Id, sObject> mapCaseSObjects, map<String, set<Id>> mapFieldAndIds, set<String> setAssetTypes, set<String> setAssetDevNames, set<String> setAssetStatus) {
        try {
            String strQuery = 'SELECT '+ String.join(GenericUtilities.getAllFields('Asset'), ', ') + ', RecordType.DeveloperName FROM Asset ';
            String whereClause = '';
            
            if(mapFieldAndIds != null && !mapFieldAndIds.isEmpty()) {
                whereClause += '(';
                for(String str : mapFieldAndIds.keySet()) {
                    set<Id> lstIds = mapFieldAndIds.get(str);
                    whereClause += str +' IN:lstIds OR ';
                }
                
                whereClause = whereClause.removeEnd(' OR ');
                whereClause += ') AND ';
            }
            
            if(setAssetTypes != null && !setAssetTypes.isEmpty()) whereClause += 'Type__c IN:setAssetTypes AND ';
            if(setAssetDevNames != null && !setAssetDevNames.isEmpty()) whereClause += 'RecordType.DeveloperName IN:setAssetDevNames AND ';
            if(setAssetStatus != null && !setAssetStatus.isEmpty()) whereClause += 'Status IN:setAssetStatus AND ';
            
            whereClause = whereClause.removeEnd(' AND ');
            
            if(String.isNotBlank(whereClause)) strQuery = strQuery + 'WHERE '+whereClause;
            else strQuery = '';
            
            if(String.isNotBlank(strQuery)) return Database.query(strQuery);
            else return null;
        }
        catch(Exception e) {
            CibisUtility.insertSobjects(new list<npsp__Error__c>{new npsp__Error__c(npsp__Full_Message__c=e.getMessage()+'--'+e.getTypeName(),npsp__Stack_Trace__c=e.getStackTraceString()+'--'+e.getLineNumber(),npsp__Error_Type__c='DocumentsPrintController')});
            strErrorMsg += e.getMessage() +'@~';
            throw new AuraHandledException(e.getMessage()); 
        } 
    }
    
    /**
    * @Name: Shaik Nagajani
    * This method process the assets to palnet press and constrct the wrapper in sequence 
    */ 
    public static void processAssetRecords(map<Id, sObject> mapCaseSObjects, map<String, list<Asset>> mapKeyAndAssets,  Map<Id, Map<String, ECFMG_Print_Config__mdt>> mapOfMdtsWithKey) {
        if(mapOfMdtsWithKey.keySet() != null && !mapOfMdtsWithKey.KeySet().isEmpty()) {
            for(String caseId : mapOfMdtsWithKey.keySet()) {
                if(mapOfMdtsWithKey.containsKey(caseId) && mapOfMdtsWithKey.get(caseId).keySet() != null) {
                    for(String strUnikey : mapOfMdtsWithKey.get(caseId).keySet()) {
                        ECFMG_Print_Config__mdt objMdt = mapOfMdtsWithKey.get(caseId).get(strUnikey);
                        if(mapKeyAndAssets.keySet() != null && !mapKeyAndAssets.keySet().isEmpty() && mapKeyAndAssets.containsKey(strUnikey)) {
                            sObject objCase = mapCaseSObjects.get(caseId);
                            for(Asset asst : mapKeyAndAssets.get(strUnikey)) {
                                Sobject objAsset = asst;
                                
                                DocumentWrapper obj = new DocumentWrapper();
                                obj.objMdt = objMdt;
                                obj.objAsset = asst;
                                obj.sequence = Integer.valueof(objMdt.Sequence__c);

                                // check the the condition based on case and metadata 
                                if(!objMdt.Custom_Logic__c && String.isBlank(objMdt.Custom_Logic_Unique_Key__c) 
                                   && (String)objCase.get(objMdt.Filed_API_Name_from_Case__c) == (String)objAsset.get(objMdt.Filed_API_Name_from_Asset__c) 
                                   && objMdt.Asset_Record_Type_Developer_Name__c == asst.RecordType.DeveloperName 
                                   && objMdt.Asset_Type__c == asst.Type__c 
                                   && String.valueof(objMdt.Asset_Status__c).contains(asst.Status)) {
                                       if((objMdt.Service_Line__c != null && objMdt.Service_Line__c == (String)objCase.get(PlanetPressConstants.CASE_SERVICE_FIELD_API_NAME)) || String.isBlank(objMdt.Service_Line__c)) addToMap(caseId, obj);
                                   }
                                else if(objMdt.Custom_Logic__c && String.isNotBlank(objMdt.Custom_Logic_Unique_Key__c) && caseId == asst.Case__c){
                                    addToMap(caseId, obj);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    public static void addToMap(String caseId, DocumentWrapper obj) {
        try {
            Integer iSize = 0;
            if(mapCaseIdAndNoOfCopies.containsKey(caseId) && !setAstNames.contains(obj.objMdt.Asset_Type__c) && obj.objAsset.Name != PlanetPressConstants.Secretary_Document_Name) iSize = mapCaseIdAndNoOfCopies.get(caseId);
            else iSize = 1;
    
            list<DocumentWrapper> lstObj;
            if(!mapCasIdAndWrappers.containsKey(caseId)) { 
                lstObj = new List<DocumentWrapper>();
                for(integer i = 0; i<iSize; i++) {
                    lstObj.add(returnCloneWrapper(obj));
                }
            }
            else { 
                lstObj = mapCasIdAndWrappers.get(caseId);
                for(integer i = 0; i<iSize; i++) {
                    lstObj.add(returnCloneWrapper(obj));
                }            
            }
    
            mapCasIdAndWrappers.put(caseId, lstObj);
        }
        catch(exception ex) {
            CibisUtility.insertSobjects(new list<npsp__Error__c>{new npsp__Error__c(npsp__Full_Message__c=ex.getMessage()+'--'+ex.getTypeName(),npsp__Stack_Trace__c=ex.getStackTraceString()+'--'+ex.getLineNumber(),npsp__Error_Type__c='DocumentsPrintController')});
            strErrorMsg += ex.getMessage() +'@~';
            throw new AuraHandledException(ex.getMessage());
        }
     
    }

    /**
    * @Name: Shaik Nagajani
    * This method clone the wrapper object
    */ 
    public static DocumentWrapper returnCloneWrapper(DocumentWrapper obj) {
        DocumentWrapper objClone = new DocumentWrapper();
        Asset objAss = obj.objAsset.clone(false, false, false, false);
        ECFMG_Print_Config__mdt objMdt = obj.objMdt.clone(false, false, false, false);
        objClone.objAsset = objAss;
        objClone.objMdt = objMdt;
        objClone.sequence = obj.sequence;
        return objClone;
    }

    /**
    * @Name: Shaik Nagajani
    * This method construct the payload based on the wrapper
    */ 
    public static String constructPayloadAndPublishEvent(Map<Id, list<DocumentWrapper>> mapCasIdAndWrappers) {
        try {
            if(mapCasIdAndWrappers.keySet() != null && !mapCasIdAndWrappers.keySet().isEmpty()) {
                list<String> lstPayloads = new  list<String>();
                Map<String, list<DocumentWrapper>> mapCaseIdAndShLabels = new Map<String, list<DocumentWrapper>>();
                list<Print_Request_Event__e> lstReq = new list<Print_Request_Event__e>();
                Map<Id, Case> mapCasesToUpdate = new Map<Id, Case>();
                map<String, list<DocumentWrapper>> mapPrintnameAndDocs = new map<String, list<DocumentWrapper>>();
                
                for(String str : mapCasIdAndWrappers.keySet()) {
                    // sort the data based on sequence order - ASC
                    if(mapCasIdAndWrappers.containsKey(str)) {
                        mapCasIdAndWrappers.get(str).sort();
                        for(DocumentWrapper dw : mapCasIdAndWrappers.get(str)) {
                            ECFMG_Print_Config__mdt objMdt = dw.objMdt;
                            
                            if(!mapPrintnameAndDocs.containsKey(objMdt.Printer_Name__c)) {
                                mapPrintnameAndDocs.put(objMdt.Printer_Name__c, new list<DocumentWrapper>{dw});
                            }
                            else {
                                mapPrintnameAndDocs.get(objMdt.Printer_Name__c).add(dw);
                            }
                    	}
                    } 
                    
                    mapCasesToUpdate.put(str, new Case(Id=str, Internal_Status__c= PlanetPressConstants.INTERNAL_STATUS_REQ));

                  	if(mapPrintnameAndDocs.values() != null && !mapPrintnameAndDocs.values().isEmpty()) {
                      for(String strPrintName : mapPrintnameAndDocs.keySet()) {
                            list<DocumentWrapper> lstDocs = mapPrintnameAndDocs.get(strPrintName);
                              
                            if(lstDocs != null && !lstDocs.isEmpty()) {
                                Integer check = 0;
                                for(Integer i = 0; i < lstDocs.size(); i++) {
                                    check = i + 1;
                                    if(lstDocs[i].sequence != check) lstDocs[i].sequence = check;
                                }
                            }
                   		lstPayloads.add(constructPayloadToPrint(str, lstDocs));
                      }
                    }
                    
                    mapPrintnameAndDocs.clear();
                }
                
                if(lstPayloads != null && !lstPayloads.isEmpty()) {
                    for(String strPayload : lstPayloads) {
                        Print_Request_Event__e obj = new Print_Request_Event__e(payload__c = strPayload);
                        lstReq.add(obj);
                    }
                }

                if(lstReq != null && !lstReq.isEmpty()) {
                    publishPlanetRequest(lstReq);
                    if(mapCasesToUpdate != null && !mapCasesToUpdate.isEmpty()) GenericUtilities.updateSobjects(mapCasesToUpdate.values());
                }
            }
        }
        catch(Exception ex) {
            CibisUtility.insertSobjects(new list<npsp__Error__c>{new npsp__Error__c(npsp__Full_Message__c=ex.getMessage()+'--'+ex.getTypeName(),npsp__Stack_Trace__c=ex.getStackTraceString()+'--'+ex.getLineNumber(),npsp__Error_Type__c='DocumentsPrintController')});
            strErrorMsg += ex.getMessage() +'@~';
            throw new AuraHandledException(ex.getMessage());
        }
        
        return strErrorMsg;
    }
    
    /**
    * @Name: Shaik Nagajani
    * This method check the case internal status is valid or not
    */ 
    @AuraEnabled
    public static Boolean getCaseStatusinfo(list<String> lstCaseIds) {
        Boolean bValid = true;
        if(lstCaseIds != null && !lstCaseIds.isEmpty()) {
            Set<String> setStatus = new Set<String>{PlanetPressConstants.Pending_Print_Resend, PlanetPressConstants.Pending_Print_Verification_Incomplete, PlanetPressConstants.INTERNAL_STATUS_PENDING_PRINT, PlanetPressConstants.INTERNAL_STATUS_PENDING_ERROR};
                for(Case iterator : [SELECT Id, Internal_Status__c FROM Case WHERE Id IN :lstCaseIds]) {
                    if(!setStatus.contains(iterator.Internal_Status__c )) {
                        bValid = false;
                        break;
                    }
                }
        }
        return bValid;
    }
    
    /**
    * @Name: Shaik Nagajani
    * This method call when the button on the case detail page.
    */ 
    @AuraEnabled
    public static DocWrapper getAssets(String strRecordId) {
        try {
            DocWrapper obj = new DocWrapper();
            list<Id> lstIds = new list<Id>();
             List<Asset> lstAssetsToProcess = new List<Asset>();
            if(String.isNotBlank(strRecordId)) {
                lstIds.add(strRecordId);
                list<ECFMG_Print_Config__mdt> lstMdts = getCstmMdtRecords();
                mapCaseSObjects = getCasesInfo(lstIds);
                processMdtsAndCases(lstMdts, mapCaseSObjects);
                List<Asset> lstAssets = constructDynamicSOQLQueryAndgetAssets(mapCaseSObjects, mapFieldAndIds, setAssetTypes, setAssetDevNames, setAssetStatus);
				
                DocumentPrintUtilities.filterAssetsBasedOnCaseInfo(mapCaseSObjects, lstAssets, lstAssetsToProcess);
                
                if(mapUniquekeyAndObjects != null && !mapUniquekeyAndObjects.isEmpty()) {
                    map<Id, list<Asset>> mapCustomAssets = processCustomLogic(mapUniquekeyAndObjects, mapuniquekeyAndMdts);
                    if(mapCustomAssets != null && !mapCustomAssets.isEmpty()) {
                        for(String s : mapCustomAssets.keySet()) {
                            lstAssetsToProcess.addAll(mapCustomAssets.get(s));
                        }
                    }
                }
                
                obj.lstCaseObjects = mapCaseSObjects.values();
                obj.lstMdts = lstMdts;
                obj.assetsRecs = lstAssetsToProcess;
            }
            return obj;
        }
        catch(Exception e) {
            CibisUtility.insertSobjects(new list<npsp__Error__c>{new npsp__Error__c(npsp__Full_Message__c=e.getMessage()+'--'+e.getTypeName(),npsp__Stack_Trace__c=e.getStackTraceString()+'--'+e.getLineNumber(),npsp__Error_Type__c='DocumentsPrintController')});
            strErrorMsg += e.getMessage() +'@~';
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
    * @Name: Shaik Nagajani
    * This method call when custom logic need to execute.
    */ 
    public static map<Id, list<Asset>> processCustomLogic(Map<String, list<SObject>> mapUniquekeyAndObjects, Map<String, list<ECFMG_Print_Config__mdt>> mapuniquekeyAndMdts) {
        try {
            Type t = Type.forName(PlanetPressConstants.PRINT_CUSTOM_CLASS_NAME);
            DocumentPrintInterface obj = (DocumentPrintInterface)t.newInstance();
            map<Id, list<Asset>> mapAssets = obj.processDocumetPrints(mapUniquekeyAndObjects, mapuniquekeyAndMdts);
            return mapAssets;
        }
        catch(Exception e) {
            CibisUtility.insertSobjects(new list<npsp__Error__c>{new npsp__Error__c(npsp__Full_Message__c=e.getMessage()+'--'+e.getTypeName(),npsp__Stack_Trace__c=e.getStackTraceString()+'--'+e.getLineNumber(),npsp__Error_Type__c='DocumentsPrintController')});
            strErrorMsg += e.getMessage() +'@~';
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
    * @Name: Shaik Nagajani
    * This method call from case detail page and it process the case to planet press
    */ 
    @AuraEnabled
    public static String sentDocumentsToPrint(list<Case> lstCaseObjects, list<ECFMG_Print_Config__mdt> lstMdts, list<Asset> lstAssetsToPrint) { 
        try {
            if(lstCaseObjects != null && !lstCaseObjects.isEmpty()) {
                set<Id> seCaseIds = new set<Id>();
                map<Id, sObject> mapCaseObjs = new map<Id, sObject>(lstCaseObjects);
                mapCaseSObjects = mapCaseObjs;

                for(sObject sobj : mapCaseObjs.values()) { 
                    if(sobj != null && (String)sObj.getSObject('RecordType').get('DeveloperName') != null && setRecDevNames.contains((String)sObj.getSObject('RecordType').get('DeveloperName'))) { 
                        seCaseIds.add((Id)sobj.get('Id'));
                    }
                }

                if(seCaseIds != null && !seCaseIds.isEmpty()) getTranscriptCopiesCount(seCaseIds);
                processMdtsAndCases(lstMdts, mapCaseObjs);
                processAssetsUniquies(lstAssetsToPrint);
                processAssetRecords(mapCaseSObjects, mapKeyAndAssets, mapOfMdtsWithKey);
            }

            System.debug('mapCasIdAndWrappers => '+mapCasIdAndWrappers);
            return constructPayloadAndPublishEvent(mapCasIdAndWrappers);
        }
        catch(Exception ex) {
			CibisUtility.insertSobjects(new list<npsp__Error__c>{new npsp__Error__c(npsp__Full_Message__c=ex.getMessage()+'--'+ex.getTypeName(),npsp__Stack_Trace__c=ex.getStackTraceString()+'--'+ex.getLineNumber(),npsp__Error_Type__c='DocumentsPrintController')});
            strErrorMsg += ex.getMessage() +'@~';
            throw new AuraHandledException(ex.getMessage());
        }
    }


    public static void getTranscriptCopiesCount(Set<Id> seCaseIds) { 
        if(seCaseIds != null && !seCaseIds.isEmpty()) {
            list<AggregateResult>  lstTrans = [SELECT SUM(Number_of_Copies__c) sm, Case__c FROM Transcript_Request__c WHERE Case__c IN : seCaseIds GROUP BY Case__c];
            if(lstTrans != null && !lstTrans.isEmpty()) { 
                for(AggregateResult req : lstTrans) {
                    if(!mapCaseIdAndNoOfCopies.containsKey((String)req.get('Case__c'))) { 
                        mapCaseIdAndNoOfCopies.put((String)req.get('Case__c'), (Integer.valueOf((Decimal)req.get('sm')) != null ? Integer.valueOf((Decimal)req.get('sm')) : 1));
                    }
                }
            }
        }
    }
    
    /**
    * @Name: Shaik Nagajani
    * This method construct the request based on the case and wrapper information
    */ 
    public static String constructPayloadToPrint(String strRecordId, list<DocumentWrapper> lstWrapper) {
        List<String> lstStrings = new List<String>();
        DocumentPrintJSONGenerator jsWrapper = new DocumentPrintJSONGenerator();
        Case objCase = null;
        if(mapCaseSObjects.containsKey(strRecordId)) objCase = (Case)mapCaseSObjects.get(strRecordId);
        jsWrapper.entity = PlanetPressConstants.Print_Entity;
        jsWrapper.subEntity = ''; 
        jsWrapper.transactionId = PlanetPressConstants.PRINT_TRANSACTION_KEY_TYPE +'-'+ strRecordId +'-'+objCase.Internal_Status__c+'-'+ GenericUtilities.getUUID();
        jsWrapper.operation = 'POST';
        DocumentPrintJSONGenerator.Payload jsPayload = new DocumentPrintJSONGenerator.Payload();
        
        jsPayload.caseId = strRecordId;

        list<DocumentPrintJSONGenerator.Document> lstPayDocs = new list<DocumentPrintJSONGenerator.Document>();
        if(lstWrapper != null && !lstWrapper.isEmpty()) {
            for(DocumentWrapper iterator : lstWrapper) {
                ECFMG_Print_Config__mdt objMdt = iterator.objMdt;
                Asset objAsset = iterator.objAsset;
                DocumentPrintJSONGenerator.Document jsPayloadDoc = new DocumentPrintJSONGenerator.Document();
                jsPayloadDoc.trayName = objMdt.Tray_Name__c;
                jsPayloadDoc.mediaSize = objMdt.Media_Size__c;
                jsPayloadDoc.documentURL = objAsset.Azure_Storage_URL__c;
                jsPayloadDoc.azureContainer = objMdt.Azure_Container__c;
                jsPayloadDoc.sequence = Integer.valueOf(iterator.sequence);
                jsPayload.printerName = objMdt.Printer_Name__c;
                lstPayDocs.add(jsPayloadDoc);
            }
        }
        
        jsPayload.document = lstPayDocs;
        jsWrapper.payload = jsPayload;
        return JSON.serialize(jsWrapper);
    }
    
    /**
    * @Name: Shaik Nagajani
    * This method publish the platform event and logs the error log record to the case
    */ 
    public static void publishPlanetRequest(List<Print_Request_Event__e> requestEvents) {
        Database.SaveResult[] srList = EventBus.publish(requestEvents); 
        GenericUtilities.upsertErrorLogForEvents(requestEvents, srList, PlanetPressConstants.REQUEST);
    }
    
    /**
    * @Name: Shaik Nagajani
    * This wrapper used to show the asset and case inforation on the detail page
    */ 
    public class DocWrapper {
        @AuraEnabled public list<Asset> assetsRecs;
        @AuraEnabled public list<SObject> lstCaseObjects;
        @auraEnabled public list<ECFMG_Print_Config__mdt> lstMdts;
    }
    
    /**
    * @Name: Shaik Nagajani
    * This wrapper used to capture the all the required information to construct the request 
    * It sorts the data based on sequence
    */ 
    public class DocumentWrapper implements Comparable {
        public ECFMG_Print_Config__mdt objMdt;
        public Asset objAsset;
        public Integer sequence;
        
        public Integer compareTo(Object objToCompare) {
            DocumentWrapper obj = (DocumentWrapper)objToCompare;
            if (this.sequence == obj.sequence) return 0;
            else if (this.sequence > obj.sequence) return 1;
            else return -1;        
        }
    }
}