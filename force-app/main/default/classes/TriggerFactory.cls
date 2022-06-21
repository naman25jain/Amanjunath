/** @name: TriggerFactory
 *  @description: Define methods to instantiate handler of specific object and invoke methods based on specific event type
**/
public without sharing class TriggerFactory{
       
    public static void createHandler(Schema.sObjectType sObjType)
    {
        System.debug('inside createHandler');
        TriggerInterface triggerInterface = getHandler(sObjType);
        
        if(TriggerInterface == null)
            throw new TriggerException('Technical error. Please try again or contact your system admin.');
        
        execute(triggerInterface);
    }
       
   
    private static TriggerInterface getHandler(Schema.SObjectType sObjType)
    {
        System.debug('inside getHandler...'+sObjType);

        if(sObjType == Contact.SObjectType){
            return new ContactHandler();
        }
        
        if(sObjType == Contact_Association_Type__c.SObjectType){
            return new ContactAssociationTypeHandler();
        }
            
        return null;    
    }
    
    
    private static void execute(TriggerInterface triggerHandler){
        System.debug('inside execute'+Trigger.new);
        
        System.debug('Is trigger disabled :'+triggerHandler.IsDisabled());

        // Check to see if the trigger has been disabled. If it has, return
        if (triggerHandler.IsDisabled())
            return;
        
        If(Trigger.isBefore){
 			if(Trigger.IsInsert){
            	triggerHandler.beforeInsert(Trigger.new);
            }
            if(Trigger.IsUpdate){
                triggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
            }
        }
        
        If(Trigger.IsAfter){            
            if(Trigger.IsInsert){
                triggerHandler.afterInsert(Trigger.new);
            }
            if(Trigger.IsUpdate)
            	triggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
    
    }
}