/**
@Name: Shaik Nagajani
@Description: 
- This class contains the palnet press printing related custom logic methods.

@History
VERSION     AUTHOR             DATE            DETAIL
1.0         Shaik Nagajani     24/Nov/2021     Created the Apex class.
**/

public inherited sharing class DocumentPrintUtilities implements DocumentPrintInterface  {
    
    public static map<Id, List<Asset>> processDocumetPrints(Map<String, list<SObject>> mapUniquekeyAndObjects, Map<String, list<ECFMG_Print_Config__mdt>> mapuniquekeyAndMdts) {
        map<Id, List<Asset>> mapCaseIdAssets = new map<Id, List<Asset>>();
        Map<Id, sObject> mapCases;
        Map<Id, ECFMG_Print_Config__mdt> mapMdts;
        map<Id, Case> mapConIdCons = new map<Id, Case>();
        map<Id, Case> mapConIdCases = new map<Id, Case>();
        set<String> setAssetNames = new set<String>();
        try{
            if(mapUniquekeyAndObjects != null && !mapUniquekeyAndObjects.isEmpty() && mapuniquekeyAndMdts != null && !mapuniquekeyAndMdts.isEmpty()) {
                for(String str : mapUniquekeyAndObjects.keySet()) {
                    if(str.trim() == PlanetPressConstants.Verification_Packet) {
                        mapCases = new Map<Id, SObject>();
                        mapCases.putAll(mapUniquekeyAndObjects.get(str));
                        mapMdts = new Map<Id, ECFMG_Print_Config__mdt>();
                        mapMdts.putAll(mapuniquekeyAndMdts.get(str));
                    }
                    else if(str.trim() == PlanetPressConstants.Secretary_Document_Name) {
                        list<sObject> lstCases = new Map<Id, sObject>(mapUniquekeyAndObjects.get(str)).values();
                        if(lstCases != null && !lstCases.isEmpty()) {
                            for(sObject sObj : lstCases) {
                                Case objCase = (Case)sObj;
                                if(objCase.ContactId != null) mapConIdCons.put(objCase.ContactId , objCase);
                            }
                        }
                    }
                    else if(str.trim() == PlanetPressConstants.Redacted_NonRedacted_Form) {
                        
                        if(mapUniquekeyAndObjects.containsKey(str) && mapUniquekeyAndObjects.get(str) != null && !mapUniquekeyAndObjects.get(str).isEmpty()) {
                            for(sObject sObj : mapUniquekeyAndObjects.get(str)) {
                                Case objCase = (Case)sObj;
                                if(objCase.ContactId != null) mapConIdCases.put(objCase.ContactId , objCase);
                            }
                        }
                        
                        if(mapuniquekeyAndMdts.containsKey(str) && mapuniquekeyAndMdts?.get(str) != null && !mapuniquekeyAndMdts?.get(str).isEmpty()) {
                            for(ECFMG_Print_Config__mdt mdt : mapuniquekeyAndMdts?.get(str)) {
                                if(mdt.Asset_Names_for_Forms__c != null && mdt.Asset_Names_for_Forms__c.contains(PlanetPressConstants.STRING_SEPARATOR)) setAssetNames.addAll(mdt.Asset_Names_for_Forms__c.trim().split(PlanetPressConstants.STRING_SEPARATOR));
                                else setAssetNames.add(mdt?.Asset_Names_for_Forms__c?.trim());
                            }
                        }
                    }
                }
            }
            
            if(mapCases != null && mapMdts != null)  DocumentPrintCustomLogicUtilities.processAsset2Verifications(mapCaseIdAssets, mapCases, mapMdts);
            if(mapConIdCons != null && !mapConIdCons.isEmpty()) DocumentPrintCustomLogicUtilities.getSecretaryDocumentData(mapCaseIdAssets, mapConIdCons);
            if(mapConIdCases != null && !mapConIdCases.isEmpty() && setAssetNames != null && !setAssetNames.isEmpty()) DocumentPrintCustomLogicUtilities.getRedactedFormsData(mapCaseIdAssets, setAssetNames, mapConIdCases);
            
        }
        catch(Exception ex) {
            CibisUtility.insertSobjects(new list<npsp__Error__c>{new npsp__Error__c(npsp__Full_Message__c=ex.getMessage()+'--'+ex.getTypeName(),npsp__Stack_Trace__c=ex.getStackTraceString()+'--'+ex.getLineNumber(),npsp__Error_Type__c='DocumentPrintUtilities')});
        }
        
        if(mapCaseIdAssets != null && !mapCaseIdAssets.isEmpty()) return mapCaseIdAssets;
        else return null;
    }
    
        
    /**
    * @Name: Shaik Nagajani
    * This method filter the asset records based on conditions.
    */
    public static void filterAssetsBasedOnCaseInfo(map<Id, sObject> mapCaseSObjects, list<Asset> lstAssets, list<Asset> lstAssetsFiltered) {
        if(lstAssets != null && !lstAssets.isEmpty()) {
            for(Asset a : lstAssets) {   
                Case objCs = (Case)mapCaseSObjects.get(a.Case__c);
                
                if(a.Type__c == PlanetPressConstants.Cover_Letter) {
                    if(PlanetPressConstants.setRecDevNames.contains(objCs.RecordType.DeveloperName) && objCs.Internal_Status__c == PlanetPressConstants.Pending_Print_Verification_Incomplete) {
                        if(a.Name == PlanetPressConstants.Incomplete_Cover_Letter) {
                             lstAssetsFiltered.add(a);
                        }                        
                    }
                    else if(a.Name != PlanetPressConstants.Incomplete_Cover_Letter) {
                        lstAssetsFiltered.add(a);
                    }
                }
                else {
                    lstAssetsFiltered.add(a);
                }
            }
        }
    }
}