/**
@Name: Shaik Nagajani
@Description: 
- This class contains the palnet press printing related cutom logic utility methods.

@History
VERSION     AUTHOR             DATE            DETAIL
1.0         Shaik Nagajani     24/Nov/2021     Created the Apex class.
**/

public inherited sharing class DocumentPrintCustomLogicUtilities {
    
    public static map<Id, List<Asset>> processAsset2Verifications(map<Id, List<Asset>> mapCaseIdAssets, Map<Id, sObject> mapCases, Map<Id, ECFMG_Print_Config__mdt> mapMdts) {
        set<String> setAssetTypes = new set<String>();
        set<String> setAssetDevNames = new set<String>();
        set<String> setAssetStatus = new set<String>();
        
        if(mapCases.keySet() != null && !mapCases.keySet().isEmpty() && mapMdts != null && !mapMdts.isEmpty()) { 
            for(ECFMG_Print_Config__mdt mdt : mapMdts.values()) {
                setAssetTypes.add(mdt.Asset_Type__c);
                setAssetDevNames.add(mdt.Asset_Record_Type_Developer_Name__c);
                if(mdt.Asset_Status__c.contains(PlanetPressConstants.STRING_SEPARATOR)) setAssetStatus.addAll(mdt.Asset_Status__c.split(PlanetPressConstants.STRING_SEPARATOR));
                else setAssetStatus.add(mdt.Asset_Status__c);
            }
        }
        
        list<Asset2Verification__c> lstVerifications = DocumentPrintCustomLogicUtilities.generateVerfiationPacketQuery(mapCases, setAssetTypes, setAssetDevNames, setAssetStatus);
        
        if(lstVerifications != null && !lstVerifications.isEmpty()) {
            for(Asset2Verification__c iterator : lstVerifications) {
                if(iterator.Asset__c != null && iterator.Verification_Packet__r.Case__c != null) {
                    Asset objAsset = new Asset(Id = iterator.Asset__c, Name=iterator.Asset__r.Name, Type__c = iterator.Asset__r.Type__c,
                                               Status = iterator.Asset__r.Status, Azure_Storage_URL__c = iterator.Asset__r.Azure_Storage_URL__c, 
                                               RecordTypeId = iterator.Asset__r.RecordTypeId, Case__c = iterator.Verification_Packet__r.Case__c, Filename__c='CustomLogic');
                    
                    if(!mapCaseIdAssets.containsKey(iterator.Verification_Packet__r.Case__c)) mapCaseIdAssets.put(iterator.Verification_Packet__r.Case__c, new list<Asset>{objAsset});
                    else mapCaseIdAssets.get(iterator.Verification_Packet__r.Case__c).add(objAsset);
                }
            }
        }
        return mapCaseIdAssets;
    }
    
    public static list<Asset2Verification__c> generateVerfiationPacketQuery(map<Id, sObject> mapCases, set<String> setAssetTypes, set<String> setAssetDevNames, set<String> setAssetStatus) {
        
        String strQuery = 'Select Id, Verification_Packet__r.Case__c, Verification_Packet__r.Case__r.RecordType.DeveloperName, Asset__c, Asset__r.Name, Asset__r.Type__c, Asset__r.Status, Asset__r.Azure_Storage_URL__c, Asset__r.RecordTypeId, Asset__r.RecordType.DeveloperName from Asset2Verification__c ';
        String whereClause = '';
        if(mapCases.keySet() != null && !mapCases.keySet().isEmpty()) {
            Set<Id> setIds = mapCases.keySet();
            whereClause += 'Verification_Packet__r.Case__c IN:setIds AND ';
        }
        
        if(setAssetTypes != null && !setAssetTypes.isEmpty()) whereClause += 'Asset__r.Type__c IN :setAssetTypes AND ';
        if(setAssetDevNames != null && !setAssetDevNames.isEmpty()) whereClause += 'Asset__r.RecordType.DeveloperName IN :setAssetDevNames AND ';
        if(setAssetStatus != null && !setAssetStatus.isEmpty()) whereClause += 'Asset__r.Status IN :setAssetStatus AND ';
        
        whereClause = whereClause.removeEnd(' AND ');
        if(String.isNotBlank(whereClause)) {
            strQuery = strQuery + 'WHERE Verification_Packet__r.Is_Active__c = true AND '+ whereClause;
            return Database.query(strQuery);
        }
        else {
            return null;
        }
    }
    
    
    public static map<Id, List<Asset>> getSecretaryDocumentData(map<Id, List<Asset>> mapCaseIdAssets, map<Id, Case> mapConIdCons) {
        if(mapConIdCons != null && !mapConIdCons.isEmpty()) {
            map<Id, Contact> mapCons = new Map<Id, Contact>([SELECT Id, Secr_Doc_Azure_Blob_URL__c FROM Contact WHERE Id IN :mapConIdCons.keySet()]);
            
            if(mapCons != null && !mapCons.isEmpty()) {
                for(Contact objCon : mapCons.values()) {
                    Case objCase = mapConIdCons.get(objCon.Id);
                    if(objCon.Secr_Doc_Azure_Blob_URL__c != null) {
                        Asset objAsset = new Asset(Case__c=objCase.Id, ContactId=objCon.Id, Name=PlanetPressConstants.Secretary_Document_Name, Azure_Storage_URL__c = objCon.Secr_Doc_Azure_Blob_URL__c, Filename__c='CustomLogic');
                        
                        if(!mapCaseIdAssets.containsKey(objCase.Id)) mapCaseIdAssets.put(objCase.Id, new list<Asset>{objAsset});
                        else mapCaseIdAssets.get(objCase.Id).add(objAsset);
                    }
                }
            }
        }
        return mapCaseIdAssets;
    }
    
    
    public static map<Id, List<Asset>> getRedactedFormsData(map<Id, List<Asset>> mapCaseIdAssets, set<String> setAssetNames, map<Id, Case> mapConIdCases) {
        try {
            if(mapConIdCases != null && !mapConIdCases.isEmpty()) {
                Map<Id, Map<String, Asset>> mapAsetIdAndAss = new Map<Id, Map<String, Asset>>();
                set<Id> setIds = mapConIdCases.keySet();
                String strQuery = 'SELECT '+ String.join(GenericUtilities.getAllFields('Asset'), ', ') + ', RecordType.DeveloperName FROM Asset WHERE ContactId IN:setIds AND Name IN:setAssetNames';
                
                list<Asset> lstAssets = Database.query(strQuery);
                if(lstAssets != null && !lstAssets.isEmpty()) {
                    for(Asset ass : lstAssets) {
                        Case objCase = mapConIdCases.get(ass.ContactId);
                        if(!mapAsetIdAndAss.containsKey(objCase.Id)) mapAsetIdAndAss.put(objCase.Id, new map<String, Asset>{ass.Name => ass});
                        else mapAsetIdAndAss.get(objCase.Id).put(ass.Name, ass);
                    }
                    
                    for(Case obj : mapConIdCases.values()) {
                        sObject sObj = obj;
                        if((String)sObj.get(PlanetPressConstants.CASE_SERVICE_FIELD_API_NAME) != null) {
                            if(PlanetPressConstants.setServiceNamesRelForm.contains((String)sObj.get(PlanetPressConstants.CASE_SERVICE_FIELD_API_NAME))) {
                                if(mapAsetIdAndAss.containsKey(obj.Id) && mapAsetIdAndAss.get(obj.Id).keySet().contains(PlanetPressConstants.ID_FORM_NOTARIZED)) {
                                    Asset objAss = mapAsetIdAndAss.get(obj.Id).get(PlanetPressConstants.ID_FORM_NOTARIZED);
                                    addToAssetMap(mapCaseIdAssets, objAss, obj.Id);
                                } 
                                if(mapAsetIdAndAss.containsKey(obj.Id) && mapAsetIdAndAss.get(obj.Id).keySet().contains(PlanetPressConstants.PHOTO)) {
                                    Asset objAss = mapAsetIdAndAss.get(obj.Id).get(PlanetPressConstants.PHOTO);
                                    addToAssetMap(mapCaseIdAssets, objAss, obj.Id);
                                }  
                            }
                            else if(PlanetPressConstants.setServiceNamesRedacted.contains((String)sObj.get(PlanetPressConstants.CASE_SERVICE_FIELD_API_NAME))) {
                                if(mapAsetIdAndAss.containsKey(obj.Id) && mapAsetIdAndAss.get(obj.Id).keySet().contains(PlanetPressConstants.REDACTED_FORM)) {
                                    Asset objAss = mapAsetIdAndAss.get(obj.Id).get(PlanetPressConstants.REDACTED_FORM);
                                    addToAssetMap(mapCaseIdAssets, objAss, obj.Id);
                                } 
                            }
                        } 
                    }
                }
            }
        }
        catch(Exception ex) {
            System.debug('ex => '+ex.getMessage());
        }
        return mapCaseIdAssets;
    }

    public static void addToAssetMap(map<Id, List<Asset>> mapCaseIdAssets, Asset objAst, String strId) {
        if(objAst != null) {
            objAst.Filename__c = 'CustomLogic';
            objAst.Case__c = strId;
            if(!mapCaseIdAssets.containsKey(strId)) mapCaseIdAssets.put(strId, new list<Asset>{objAst});
            else mapCaseIdAssets.get(strId).add(objAst);
        }
    }
}