public without sharing class RestrictionRequestQueueClass implements System.Queueable{
    
    public Map<Id,Restriction_Request__C> mapRestrictionRequests;
    public RestrictionRequestQueueClass(Map<Id,Restriction_Request__c> restrictionReqMap) {
        this.mapRestrictionRequests = restrictionReqMap;
    }

    public void execute(QueueableContext qc){
        RestrictionRequestProcess.processRestrictionRequests(mapRestrictionRequests);
    }
}