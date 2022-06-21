/**
    * @author: Ajoydhas
    * @name: AssetTriggerHandler
    * @description: Handler class for AssetTrigger events
**/
public with sharing class AssetTriggerHandler {	

	public static void afterInsert(List<Asset> newAssets) {
		AssetTriggerHelper.afterInsertHelper(newAssets);
	}

	public static void afterUpdate(List<Asset> newAssets, Map<Id, Asset> oldAssetsMap) {
		AssetTriggerHelper.afterUpdateHelper(newAssets, oldAssetsMap);
	}
}