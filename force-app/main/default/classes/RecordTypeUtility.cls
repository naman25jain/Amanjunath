/** @name: RecordTypeUtility
 *  @description: Define methods to pre-process the data and pass on to helper methods for processing business logic
**/
public without sharing class RecordTypeUtility{
    
    private static Map<String, Map<String, String>> recordTypeNameToIdMap = null;
    private static Map<String, Map<String, String>> recordTypeIdToNameMap = null;
    
    public RecordTypeUtility(){}
    
    /*
		populate the map to return record type Id by name ad record type name by Id
	*/
    private static void getObjectMetadataDetails()
    {
        if(recordTypeNameToIdMap == null || recordTypeIdToNameMap == null){
           	
            //holds object name as key and value as map of record type name as key and id as value
            recordTypeNameToIdMap = new Map<String, Map<String, String>>();
           	
            //holds object name as key and value as map of record type id as key and name as value
            recordTypeIdToNameMap = new Map<String, Map<String, String>>();
            
            //query record types 
           	List<RecordType> recordTypeList = [SELECT Id, Name, SobjectType 
                                                    FROM RecordType 
                                                    WHERE IsActive = TRUE
                                                    Order By SobjectType ASC];  
            // loop through each record type
            for(RecordType itr: recordTypeList){
                //populate map of record type name as key and id as value
                if(recordTypeNameToIdMap.containsKey(itr.SobjectType)){
                    recordTypeNameToIdMap.get(itr.SobjectType).put(itr.Name, itr.Id);
                }
                else{
                    recordTypeNameToIdMap.put(itr.SobjectType, new Map<String, String>{itr.Name=>itr.Id});
                }
                
                //populate map of record type Id as key and name as value
                if(recordTypeIdToNameMap.containsKey(itr.SobjectType)){
                    recordTypeIdToNameMap.get(itr.SobjectType).put(itr.Id, itr.Name);
                }
                else{
                    recordTypeIdToNameMap.put(itr.SobjectType, new Map<String, String>{itr.Id=>itr.Name});
                }
            }    
        }
    }
    
    /*
		Get record type Id by passing the API Name of record type
	*/
    public static Id getRecordTypeIdByName(String objectName, String strRecordTypeName){
        getObjectMetadataDetails();
        return recordTypeNameToIdMap.get(objectName).get(strRecordTypeName);
    }

    /*
		Get API Name of the record type by passing the record type Id
	*/
    public static String getRecordTypeNameById(String objectName, Id strRecordTypeId){
        getObjectMetadataDetails();
        return recordTypeIdToNameMap.get(objectName).get(strRecordTypeId);
    } 

}