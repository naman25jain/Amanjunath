//@description: Helper class for AssetTrigger    
public with sharing class AssetTriggerHelper{
    //Purpose : Once the case has asset of asset type "Signed Service Form"  in status "In Progress,  the internal case status will be automatically change to "Pending Review"
    public static void afterInsertHelper(List<Asset> newAssets){
        SET<ID> caseIdSignedServiceFormSet = new SET<ID>();
        SET<ID> caseIdSignedPIASet = new SET<ID>();
        Map<Id,ContentVersion> assetContVerMap = new Map<Id,ContentVersion>();
        List<Asset> assetCredVer = new List<Asset>();
        List<Asset> erasAssets = new List<Asset>();
        String updateParAssetCaseRecTypes  = Constant_Case__mdt.getInstance('UPDATE_PARENT_ASSET_TRIGG_CASE_REC_TYPE').Value__c;
        List<String> caseRecTypeList = updateParAssetCaseRecTypes.split(',');
        Blob srBody = [SELECT Name, Id, Body FROM StaticResource WHERE Name =: Constant_other__mdt.getInstance('STATIC_RESOURCE_EXAM_PERMIT').Value__c].Body;
        Map<Id, Asset> erasAssetsMap = new Map<Id, Asset>([SELECT Id FROM Asset WHERE Id IN : newAssets AND Case__r.RecordType.DeveloperName IN : caseRecTypeList WITH SECURITY_ENFORCED]);
        for(Asset newAsset : newAssets){
            if(newAsset.Case__c != null && newAsset.Type__c == Constants.ASSET_TYPE_SIGNED_SERVICE_FORM && newAsset.Status == Constants.ASSET_STATUS_IN_PROGRESS){
                caseIdSignedServiceFormSet.add(newAsset.Case__c);
            }
            if(newAsset.Case__c != null && newAsset.Type__c == Constants.ASSET_TYPE_SIGNED_PIA && newAsset.Status == Constants.ASSET_STATUS_IN_PROGRESS){
                caseIdSignedPIASet.add(newAsset.Case__c);
            }
            if(newAsset.Azure_Storage_URL__c != null){
                assetCredVer.add(newAsset);
            }
            if(newAsset.Case__c != null && (newAsset.Type__c == Constant_Asset__mdt.getInstance('TYPE_SCHEDULING_PERMIT').Value__c || newAsset.Type__c == Constant_Asset__mdt.getInstance('TYPE_VISA_LETTER').Value__c)){
                assetContVerMap.put(newAsset.Id,createConVer(srBody,newAsset.Type__c));
            }
            if(newAsset.Azure_Storage_URL__c != null && erasAssetsMap.containsKey(newAsset.Id)){
                erasAssets.add(newAsset);
            }
        }
        // Once the case has two assets of asset types "Signed Service Form" and "Signed PIA" in status "In Progress",the internal case status will be automatically changed to "Pending Review".When asset type "Signed Service Form" and status "In Progress".
        if(!caseIdSignedServiceFormSet.isEmpty()){
            updateCaseSignedServiceFormRefactor(caseIdSignedServiceFormSet);
        }
        // When asset type "Signed PIA" and status "In Progress", 
        if(!caseIdSignedPIASet.isEmpty()){
            updateCaseSignedPIARefactor(caseIdSignedPIASet);
        }
        //to update the Asset2Verification record with Asset id.
        if(!assetCredVer.isEmpty()){
            updateAsset2VerRecords(assetCredVer);
        }
        if(!assetContVerMap.isEmpty()){
            createContVer(assetContVerMap);
        }
        if(!erasAssets.isEmpty()){
            updateParentAsset(erasAssets);
        }
        updateCaseDocumentURL(newAssets);
    }   
    public static void updateParentAsset(List<Asset> assetList){
        Map<String, Asset> urlMapParent = new Map<String, Asset>();
        Map<String,Asset> urlMapChild = new Map<String,Asset>();
        List<Asset> parentAssets = new List<Asset>();
        List<Asset> childAssets = new List<Asset>();
        List<Asset> assetsToUpdate = new List<Asset>();
        Set<Id> caseIds = new Set<Id>();
        for(Asset eachAsset: assetList){
            if(String.isBlank(eachAsset.Parent_Azure_Storage_URL__c)){
                urlMapParent.put(eachAsset.Azure_Storage_URL__c, eachAsset);
                caseIds.add(eachAsset.Case__c);
            }else if(String.isBlank(eachAsset.parentId)){
                urlMapChild.put(eachAsset.Parent_Azure_Storage_URL__c, eachAsset);
                caseIds.add(eachAsset.Case__c);
            }
        }
        if(!urlMapChild.isEmpty()){
            parentAssets = [SELECT Id, Azure_Storage_URL__c FROM Asset WHERE Azure_Storage_URL__c IN : urlMapChild.Keyset() AND Case__c IN : caseIds WITH SECURITY_ENFORCED];
            for(Asset parAsst : parentAssets){
                Asset childAsst = new Asset();
                childAsst.Id = urlMapChild.get(parAsst.Azure_Storage_URL__c).Id;
                childAsst.parentId = parAsst.Id;
                assetsToUpdate.add(childAsst);
            }
        }
        if(!urlMapParent.isEmpty()){
            childAssets = [SELECT Id, Parent_Azure_Storage_URL__c FROM Asset WHERE Parent_Azure_Storage_URL__c IN : urlMapParent.Keyset() AND ParentId = null AND Case__c IN : caseIds WITH SECURITY_ENFORCED];
            for(Asset childAsst : childAssets){
                childAsst.parentId = urlMapParent.get(childAsst.Parent_Azure_Storage_URL__c).Id;
                assetsToUpdate.add(childAsst);
            }
        }
        if (Asset.SObjectType.getDescribe().isUpdateable() && !assetsToUpdate.isEmpty()){
            UPDATE assetsToUpdate;
        }
        List<Asset> assetListNew = [SELECT Id, Case__c, ParentId, ContactId, Name, Type__c FROM Asset WHERE Id IN : assetList WITH SECURITY_ENFORCED];
        CloudStorageController.outdateAssets(assetListNew);
    }
    public static void updateAsset2VerRecords(List<Asset> assetCredVer){
        Map<String,Asset> urlStringMap = new Map<String,Asset>();
        For(Asset eachAsset: assetCredVer){
            urlStringMap.put(eachAsset.Azure_Storage_URL__c,eachAsset);
        }
        List<Asset2Verification__c> updateListAsset2Ver = new List<Asset2Verification__c>();
        List<Asset2Verification__c> newAsset2Ver = new List<Asset2Verification__c>();
        newAsset2Ver = [SELECT Id,Azure_Document_URL__c,Asset__c FROM Asset2Verification__c WHERE (Asset__c = null OR Asset__r.Status = :Constants.ASSET_STATUS_MARKED_FOR_DELETION) AND Azure_Document_URL__c = :urlStringMap.Keyset() WITH SECURITY_ENFORCED];
        if(!newAsset2Ver.isEmpty()){
            For(Asset2Verification__c eachAsset2Ver: newAsset2Ver){
                if(urlStringMap.containsKey(eachAsset2Ver.Azure_Document_URL__c)){
                   eachAsset2Ver.Asset__c = urlStringMap.get(eachAsset2Ver.Azure_Document_URL__c).Id;
                    updateListAsset2Ver.add(eachAsset2Ver);
                }
            }
        }
        if(Asset2Verification__c.SObjectType.getDescribe().isUpdateable() && !updateListAsset2Ver.isEmpty()){
            Update updateListAsset2Ver;
        }
    }
    //To update the related assets based on new asset insert or Parent asset update
    public static void afterUpdateHelper(List<Asset> newAssets, Map<Id, Asset> oldAssetsMap){
        SET<ID> caseIdSignedServiceFormSet = new SET<ID>();
        SET<ID> caseIdSignedPIASet = new SET<ID>();
        Set<Id> assetIds = new Set<Id>();
        for(Asset newAsset : newAssets){
            if(newAsset.Case__c != null && newAsset.Type__c == Constants.ASSET_TYPE_SIGNED_SERVICE_FORM && newAsset.Status == Constants.ASSET_STATUS_IN_PROGRESS && oldAssetsMap.get(newAsset.Id).status != newAsset.status){
                caseIdSignedServiceFormSet.add(newAsset.Case__c);
            }
            if(newAsset.Case__c != null && newAsset.Type__c == Constants.ASSET_TYPE_SIGNED_PIA && newAsset.Status == Constants.ASSET_STATUS_IN_PROGRESS && oldAssetsMap.get(newAsset.Id).status != newAsset.status){
                caseIdSignedPIASet.add(newAsset.Case__c);
            }
            if(newAsset.Status == Constants.ASSET_STATUS_REJECTED && oldAssetsMap.get(newAsset.Id).status != newAsset.status && (newAsset.Key__c == Constants.ASSET_TYPE_TCT_DOCUMENT || newAsset.Key__c == Constants.ASSET_TYPE_PRE_MED_LETTER_DOCUMENT)){
                assetIds.add(newAsset.Id);
            }
        }
        // Once the case has two assets of asset types "Signed Service Form" and "Signed PIA" in status "In Progress",the internal case status will be automatically changed to "Pending Review",When asset type "Signed Service Form" and status "In Progress".
        if(!caseIdSignedServiceFormSet.isEmpty()){
            updateCaseSignedServiceFormRefactor(caseIdSignedServiceFormSet);
        }
        afterUpdateHelperRfctr(newAssets,oldAssetsMap);
        // When asset type "Signed PIA" and status "In Progress", 
        if(!caseIdSignedPIASet.isEmpty()){
            updateCaseSignedPIARefactor(caseIdSignedPIASet);
        }
        if(!assetIds.isEmpty()){
            updateChildAssets(assetIds);
        }
    }
    //to refactor afterupdate method
    public static void afterUpdateHelperRfctr(List<Asset> newAssets, Map<Id, Asset> oldAssetsMap){
        Set<Id> caseIds = new Set<Id>();
        List<Asset> asstList = new List<Asset>();
        Map<String,String> assetStatusMap = new Map<String,String>();
        Map<String,String> caseStatusMap = new Map<String,String>();
        for(Asset newAsset : newAssets) {
            if(newAsset.Case__c != null && oldAssetsMap.get(newAsset.Id).status != newAsset.status){
                caseIds.add(newAsset.Case__c);
                asstList.add(newAsset);
                assetStatusMap.put(newAsset.Id, newAsset.Status);
            }
        }
        if(!caseIds.isEmpty() && Case.SObjectType.getDescribe().isAccessible()){
            List<Case> appForCertCases = [SELECT id, recordType.DeveloperName FROM Case WHERE Id IN:caseIds];
            for(Case cse:appForCertCases){
                caseStatusMap.put(cse.Id, cse.recordType.DeveloperName);
            }
            updateInternalAssets(asstList,caseStatusMap,assetStatusMap);
        }
    }
    //Update child assets status as rejected if parent asset is rejected
    public static void updateChildAssets(Set<Id> assetIds) {
        List<Asset> assetsToUpdate = new List<Asset>();
        for(Asset asst :[SELECT Id, Status, ParentId FROM Asset WHERE ParentId IN :assetIds WITH SECURITY_ENFORCED]){
            asst.Status = Constants.ASSET_STATUS_REJECTED;
            assetsToUpdate.add(asst);
        }
        if (Asset.SObjectType.getDescribe().isUpdateable() && !assetsToUpdate.isEmpty()) {
            UPDATE assetsToUpdate;
        }
    }
    /* 
     * @author: Ajoydhas
     * @method name: updateCaseSignedServiceFormRefactor
     * Purpose : When asset type "Signed Service Form" and status "In Progress", 
     *          checking the asset type "Signed PIA" and status "In Progress"
     * @return type: no
     */
    public static void updateCaseSignedServiceFormRefactor(SET<ID> caseIdSignedServiceFormSet) {        
        MAP<Id, Asset> caseAssetSignedPIAMap = checkExistSignedPIA(caseIdSignedServiceFormSet);
        MAP<Id, Boolean> casePerformanceDataMap = checkExistPerformanceData(caseIdSignedServiceFormSet);
        List<Case> caseINPerformaceDataList = new List<Case>();
        Map<Id,String> statusMap = new Map<Id,String>();
        List<Case> caseList = [SELECT id,Internal_Status__c FROM Case where id IN:caseIdSignedServiceFormSet];
        for(Case cse:caseList){
            statusMap.put(cse.Id,cse.Internal_Status__c);
        }
        for(Id caseId : caseIdSignedServiceFormSet) {
            if(statusMap.get(caseId)==Constants.CASE_STATUS_INCOMPLETE || statusMap.get(caseId)==Constants.CASE_STATUS_SENT){
                // if the "service of interest" is IN "Performance Data"...service of interest means Case2Service__c
                if(casePerformanceDataMap.containsKey(caseId) && caseAssetSignedPIAMap.containsKey(caseId)) {
                        Case caseObj = new Case();
                        caseObj.Id      =   caseId;
                        caseObj.Internal_Status__c = Constants.CASE_STATUS_PENDING_REVIEW;                 
                        caseINPerformaceDataList.add(caseObj);                  
                } 
                if(!casePerformanceDataMap.containsKey(caseId)) {
                    // if the "service of interest" is NOT "Performance Data"...service of interest means Case2Service__c
                    Case caseObj = new Case();
                    caseObj.Id      =   caseId;
                    caseObj.Internal_Status__c = Constants.CASE_STATUS_PENDING_REVIEW;                 
                    caseINPerformaceDataList.add(caseObj);
                }
            }
            
        }
        if(!caseINPerformaceDataList.isEmpty()) {
            try{
                UPDATE caseINPerformaceDataList;
            }
            catch(Exception e){
                System.debug('Exception Caught '+e.getMessage());
            } 
        }        
    }
    /* 
     * @author: Ajoydhas
     * @method name: updateCaseSignedPIARefactor
     * Purpose : When asset type "Signed PIA" and status "In Progress", 
     *          checking the asset type "Signed Service Form" and status "In Progress"
     * @return type: no
     */
    public static void updateCaseSignedPIARefactor(SET<ID> caseIdSignedPIASet) {
        MAP<Id, Asset> caseAssetSignedServiceFormMap = checkExistSignedServiceForm(caseIdSignedPIASet);
        MAP<Id, Boolean> casePerformanceDataMap = checkExistPerformanceData(caseIdSignedPIASet);
        List<Case> caseINPerformaceDataList = new List<Case>();
        Map<Id,String> statusMap = new Map<Id,String>();
        List<Case> caseList = [SELECT id,Internal_Status__c FROM Case where id IN:caseIdSignedPIASet];
        for(Case cse:caseList){
            statusMap.put(cse.Id,cse.Internal_Status__c);
        }
        for(Id caseId : caseIdSignedPIASet) {
            if((statusMap.get(caseId)==Constants.CASE_STATUS_INCOMPLETE || statusMap.get(caseId)==Constants.CASE_STATUS_SENT) && caseAssetSignedServiceFormMap.containsKey(caseId) && casePerformanceDataMap.containsKey(caseId)) {
                Case caseObj = new Case();
                caseObj.Id      =   caseId;
                caseObj.Internal_Status__c = Constants.CASE_STATUS_PENDING_REVIEW;                 
                caseINPerformaceDataList.add(caseObj);
            }
        }

        if(!caseINPerformaceDataList.isEmpty()) {
            try{
                UPDATE caseINPerformaceDataList;
            }
            catch(Exception e){
                System.debug('Exception Caught '+e.getMessage());
            } 
        }
    }
    /* 
     * @author: Ajoydhas
     * @method name: checkExistSignedPIA
     * Purpose : Method to check as asset type "Signed PIA" and status "In Progress"
     * @return type: Map<Id, Asset>
     */
    public static MAP<Id, Asset> checkExistSignedPIA(SET<ID> caseIdSignedServiceFormSet) {
        MAP<Id, Asset> caseAssetSignedPIAMap = new MAP<Id, Asset>();
        for(Asset assetObj : [SELECT ID, Case__c 
                                FROM Asset 
                            WHERE Type__c =: Constants.ASSET_TYPE_SIGNED_PIA 
                                AND Status =: Constants.ASSET_STATUS_IN_PROGRESS
                                AND Case__c IN: caseIdSignedServiceFormSet]) {            
            caseAssetSignedPIAMap.put(assetObj.Case__c, assetObj);                                                       
        }
        return caseAssetSignedPIAMap;
    }
     /* 
     * @author: Ajoydhas
     * @method name: checkSignedServiceForm
     * Purpose : Method to check as asset type "Signed Service Form" and status "In Progress"
     * @return type: Map<Id, Asset>
     */
    public static MAP<Id, Asset> checkExistSignedServiceForm(SET<ID> caseIdSignedPIASet) {
        MAP<Id, Asset> caseAssetSignedServiceFormMap = new MAP<Id, Asset>();
        for(Asset assetObj : [SELECT ID, Case__c 
                                FROM Asset 
                            WHERE Type__c =: Constants.ASSET_TYPE_SIGNED_SERVICE_FORM 
                                AND Status =: Constants.ASSET_STATUS_IN_PROGRESS
                                AND Case__c IN: caseIdSignedPIASet]) {            
            caseAssetSignedServiceFormMap.put(assetObj.Case__c, assetObj);                                                        
        }
        return caseAssetSignedServiceFormMap;
    }
    /* 
     * @author: Ajoydhas
     * @method name: checkPerformanceData
     * Purpose : Method to check Performance Data - US 6111
     * @return type: Boolean true or false
     */
    public static MAP<Id, Boolean> checkExistPerformanceData(SET<ID> caseIdSet) {
        MAP<Id, Boolean> casePerformanceDataMap = new MAP<Id, Boolean>();
        for(Case2Service__c case2ServiceObj : [SELECT ID, Case__c, Service__c, Service__r.name 
                                                    FROM Case2Service__c 
                                                WHERE Service__r.name =: Constants.SERVICE_NAME_PERFORMANCE_DATA 
                                                    AND Case__c IN: caseIdSet]) {            
            casePerformanceDataMap.put(case2ServiceObj.Case__c, true);                                                        
        }

        return casePerformanceDataMap;
    }
    //To update analyst created assets based on source asset update
    public static void updateInternalAssets(List<Asset> asstList, Map<String, String> caseStatusMap, Map<String,String> assetStatusMap) {
        Map<String, Map<String,String>> catsIdAssetMap = new Map<String, Map<String,String>>();
        List<String> catsIdList = new List<String>();
        List<Asset> assetList = new List<Asset>();
        for(Asset asst: asstList){
            String name = asst.Name;
            if(asst.name == Constants.ASSET_TYPE_NAME_DOC){
                name = asst.key__c;
            }
            if(caseStatusMap.get(asst.case__c) == Constants.CASE_RECORD_TYPE_APP_FOR_CERT && String.isNotBlank(asst.Contact_Association_Type_Staging__c)){
                if(catsIdAssetMap.get(asst.Contact_Association_Type_Staging__c) != null){
                    Map<String,String> assetNames = catsIdAssetMap.get(asst.Contact_Association_Type_Staging__c);
                    assetNames.put(name,asst.Id);
                    catsIdAssetMap.put(asst.Contact_Association_Type_Staging__c,assetNames);
                }else{
                    Map<String,String> assetName = new Map<String,String>();
                    assetName.put(name,asst.Id);
                    catsIdAssetMap.put(asst.Contact_Association_Type_Staging__c,assetName);
                }
                catsIdList.add(asst.Contact_Association_Type_Staging__c);
            }
            if(checkAssetValidity(caseStatusMap,asst)){
                assetList.add(asst);
            }
        }
        updateIdVerificationAssets(assetList);
        setAssetStatus(catsIdList, caseStatusMap, assetStatusMap, catsIdAssetMap);
    }
    // to check if asset is valid to be added to the assetList to be updated
    public static Boolean checkAssetValidity(Map<String, String> caseStatusMap, Asset asst) {
        if (caseStatusMap.get(asst.case__c) == Constants.CASE_RECORD_TYPE_IDENTITY_VERIFICATION || 
            caseStatusMap.get(asst.case__c) == Constants.CASE_RECORD_TYPE_APP_BIO_CHANGE || 
            ((asst.Type__c == Constants.ASSET_TYPE_SIGNED_SERVICE_FORM || asst.Type__c == Constants.ASSET_TYPE_SIGNED_PIA) && (asst.Status == Constants.ASSET_STATUS_ACCEPTED || asst.Status == Constants.ASSET_STATUS_INCOMPLETE))
            ){
            return true;
        }
        return false;
    }
    //To update analyst created assets based on source asset update
    public static void setAssetStatus(List<String> catsIdList, Map<String, String> caseStatusMap, Map<String,String> assetStatusMap, Map<String, Map<String,String>> catsIdAssetMap) {
        List<Asset> internalAssets = new List<Asset>();
        Map<String,String> newAssetStatusMap = new Map<String,String>();
        if(Asset.SObjectType.getDescribe().isAccessible()){
            internalAssets = [SELECT id,Name,parentId,parent.Name,Contact_Association_Type_Staging__c FROM Asset WHERE case__c IN:caseStatusMap.keyset() AND Contact_Association_Type_Staging__c IN:catsIdList AND Source_Document__c = false AND status=:Constants.ASSET_STATUS_IN_PROGRESS];
        }
        Map<String,String> nameKeyMap = new Map<String,String>();
        nameKeyMap.put('Transfer Credit Transcript','Transfer Credit Transcript Name Document');
        nameKeyMap.put('Pre-Med Letter','Pre-Med Letter Name Document');
        nameKeyMap.put('Final Medical Diploma','DIPLOMA NAME DOCUMENT');
        nameKeyMap.put('Letter from Dean','DEAN LETTER NAME DOCUMENT');
        nameKeyMap.put('Final Medical School Transcript','FINAL MEDICAL SCHOOL TRANSCRIPT DOCUMENT');
        for(Asset ast:internalAssets){
            if((catsIdAssetMap.get(ast.Contact_Association_Type_Staging__c).keySet().contains(ast.Name) && ast.Name != Constants.ASSET_TYPE_NAME_DOC)){
                newAssetStatusMap.put(ast.Id,assetStatusMap.get(catsIdAssetMap.get(ast.Contact_Association_Type_Staging__c).get(ast.Name)));
            }else if(assetStatusMap.keySet().contains(ast.parentId)){
                newAssetStatusMap.put(ast.Id,assetStatusMap.get(ast.parentId));
            }
            if(ast.Name == Constants.ASSET_TYPE_NAME_DOC && catsIdAssetMap.get(ast.Contact_Association_Type_Staging__c).keySet().contains(nameKeyMap.get(ast.parent.Name))){
                newAssetStatusMap.put(ast.Id,assetStatusMap.get(catsIdAssetMap.get(ast.Contact_Association_Type_Staging__c).get(nameKeyMap.get(ast.parent.Name))));
            }
        }
        updateAssetStatus(newAssetStatusMap);
    }
    //To update analyst created assets based on source asset update
    public static void updateAssetStatus(Map<String,String> newAssetStatusMap){
        List<Asset> asstList = new List<Asset>();
        for(String assetId : newAssetStatusMap.keySet()){
            Asset asst = new Asset();
            asst.Id = assetId;
            asst.Status = newAssetStatusMap.get(assetId);
            asstList.add(asst);
        }
        if(!asstList.isEmpty() && Asset.SObjectType.getDescribe().isUpdateable()){
            update asstList;
        }
    }
    //To update id verification assets
    public static void updateIdVerificationAssets(List<Asset> asstList){
        List<Asset> internalAssetsList = new List<Asset>();
        Map<String,String> assetMap = new Map<String,String>();
        Map<String,String> newAssetStatusMap = new Map<String,String>();
        Set<String> caseSet = new Set<String>();
        for(Asset asst : asstList){
            caseSet.add(asst.case__c);
            assetMap.put(asst.case__c+asst.Name,asst.status);
        }
        if(!asstList.isEmpty() && Asset.SObjectType.getDescribe().isAccessible()){
            internalAssetsList = [SELECT id, Name, type__c, case__c FROM Asset WHERE case__c IN:caseSet AND status=:Constants.ASSET_STATUS_IN_PROGRESS]; 
        }
        for(Asset ast:internalAssetsList){
            String assetName = ast.Name;
            if(assetName == 'Redacted ID Form'){
                assetName = 'ID Form Notarized';
            }
            if(assetMap.get(ast.case__c+assetName) != null){
                newAssetStatusMap.put(ast.Id, assetMap.get(ast.case__c+assetName));
            }
        }
        updateAssetStatus(newAssetStatusMap);
    }
    // US 12205 - update Returned Verification Form Asset at Document_URL__c in Case Object
    public static void updateCaseDocumentURL(List<Asset> newAssets){
        try{
            MAP<ID, String> caseAssetMap = new MAP<ID, String>();
            for(Asset newAsset : newAssets){
                if(newAsset.Case__c != null && newAsset.Azure_Storage_URL__c != null && newAsset.Name == Constants.ASSET_TYPE_RETURNED_VERIFICATION_FORM && newAsset.Type__c == Constants.ASSET_TYPE_VERIFICATION_FORM && newAsset.Status == Constants.ASSET_STATUS_NEW){
                    caseAssetMap.put(newAsset.Case__c, newAsset.Azure_Storage_URL__c);
                }
            }
            if(!caseAssetMap.isEmpty()){
                List<Case> caseList = new List<Case>();
                for(Id caseId : caseAssetMap.keySet()){
                    Case caseObj = new Case();
                    caseObj.Id = caseId;
                    caseObj.Document_URL__c = caseAssetMap.get(caseId);
                    caseList.add(caseObj);
                }
                if(!caseList.isEmpty() && Case.SObjectType.getDescribe().isUpdateable()){
                    update caseList;
                }
            }
        }catch(DmlException e){
            throw new ControllerException(e.getMessage());
        }
    }
    // Creates Content Verison
    public static ContentVersion createConVer(Blob srBody,String type){
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S';
        conVer.PathOnClient = type + '.pdf';
        conVer.Title = type;
        conVer.VersionData = srBody;
        return conVer;
    }
    // Creates Content Document Link
    public static void createContVer(Map<Id,ContentVersion> assetContVerMap){
        List<ContentDocumentLink> contDocLinkList = new List<ContentDocumentLink>();
        Insert assetContVerMap.values();
        Map<Id,ContentVersion> mapContVer = new Map<Id,ContentVersion>([SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id IN:assetContVerMap.values()]);
        for(Id assetId:assetContVerMap.keySet()){
            ContentDocumentLink conDocLink = new ContentDocumentLink();
            conDocLink.LinkedEntityId = assetId;
            conDocLink.ContentDocumentId = mapContVer.get(assetContVerMap.get(assetId).Id).ContentDocumentId;
            conDocLink.shareType = 'V';
            conDocLink.Visibility = 'AllUsers';
            contDocLinkList.add(conDocLink);
        }
        if(!contDocLinkList.isEmpty() && GenericUtilities.checkIsUpdatable('ContentDocumentLink')){
            Insert contDocLinkList;
        }
    }
}