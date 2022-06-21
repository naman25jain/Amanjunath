/** @name: TriggerInterface
 *  @description: Declare methods to be implemented by handler of specific object type
**/
public Interface TriggerInterface {
    void beforeInsert(List<sObject> sObjList);
    
    void afterInsert(List<sObject> sObjList);
    
    void beforeUpdate(List<sObject> sObjList, Map<Id, SObject> oldsObjList);

    void afterUpdate(List<sObject> sObjList, Map<Id, SObject> oldsObjList);
    
    void beforeDelete(List<sObject> sObjList);
    
    void afterDelete(List<sObject> sObjList);
      
    void afterUndelete(List<sObject> sObjList);
    
    Boolean IsDisabled();

}