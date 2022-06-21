trigger RestrictionRequestTrigger on Restriction_Request__c (after update) {

    if(RecursiveTriggerHandler.isFirstTime){
        RecursiveTriggerHandler.isFirstTime = false;
        Map<Id,Restriction_Request__c> restrictionRequestMap = new Map<Id,Restriction_Request__c>();
        for(Restriction_Request__c rrRec : Trigger.new){
            if(rrRec.RestrictionStatus__c == 'Ready to Process')
                restrictionRequestMap.put(rrRec.Id, rrRec);
        }
        
        if(!restrictionRequestMap.isEmpty())
            System.enqueueJob(new RestrictionRequestQueueClass(restrictionRequestMap)); 
    }
    
}