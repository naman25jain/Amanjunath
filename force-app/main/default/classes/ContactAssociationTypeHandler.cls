/** @name: ContactAssociationTypeHandler
 *  @description: Define methods to pre-process the data and pass on to helper methods for processing business logic
**/
public with sharing class ContactAssociationTypeHandler implements TriggerInterface{
    
    private Set<Id> SObjectIdList = new Set<Id>(); 
    private List<SObject> SObjectList = new List<SObject>(); 
    private static boolean hasRunBeforeUpdate = false;
    private static boolean hasRunAfterUpdate = false;
    private static boolean hasRunBeforeInsert = false;
    private static boolean hasRunAfterInsert = false;
    private static boolean hasRunBeforeDelete = false;
    private static boolean hasRunAfterDelete = false;
    private static boolean hasRunAfterUndelete = false;
    
    public  ContactAssociationTypeHandler(){
        
    }
    
    // Allows unit tests (or other code) to disable this trigger for the transaction
    private static Boolean TriggerDisabled = false;
 
    /*
        Checks to see if the trigger has been disabled either by custom setting or by running code
    */
    public Boolean IsDisabled()
    {
		System.debug('Inside IsDisabled method in ContactAssociationTypeHandler.');
        List<TriggerSettings__mdt> conTrgSetting = [SELECT Disabled__c FROM TriggerSettings__mdt WHERE MasterLabel = 'ContactAssociationTypeTrigger'];
        if (conTrgSetting <> null && (conTrgSetting.size()!=0) && conTrgSetting[0].Disabled__c)
            return true;
        else
            return TriggerDisabled;
    }
     
    /*
        Perform preprocessing on data before executing the updates to contacts are committed to database
    */
    public void beforeInsert(List<sObject> sObjList){
    
    }
    
    /*
        Perform preprocessing on data before executing the business logic to update the data
    */
    public void afterInsert(List<sObject> sObjList){
        if(!hasRunAfterInsert){
            for(Contact_Association_Type__c itr:(List<Contact_Association_Type__c>) sObjList){

                if(itr.Type__c == Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL && 
                  		itr.RecordTypeId == RecordTypeUtility.getRecordTypeIdByName('Contact_Association_Type__c', Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MED_SCHOOL))
                    SObjectList.add(itr);    
            }
            
            //pass the list of contacts to helper to create individual records
            if(SObjectList <> null && SObjectList.size() >0)
                ContactAssociationTypeService.updateApplication(SObjectList);
            hasRunAfterInsert = true;
        }
    }

    public void beforeUpdate(List<sObject> sObjList, Map<Id, SObject> oldmap){
    
    } 
    
    public void afterUpdate(List<sObject> sObjList, Map<Id, SObject> oldmap){
        
    }   
    
    
    public void beforeDelete(List<sObject> sObjList){
    
    }   
    
    public void afterDelete(List<sObject> sObjList){
    
    } 
    
    public void afterUndelete(List<sObject> sObjList){
    
    } 

}