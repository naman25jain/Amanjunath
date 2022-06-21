/**
  *   Sampath Karnati 
  * * Generic class with methods for zkmulti__MCShipment__c custom object
    * ? Exposed as Public
    * Include all the Get/Save methods related to zkmulti__MCShipment__c custom object
    */
public with sharing class ShipmentController extends BaseController{
	static final String UNABLE_TO_GET_SHIPMENTS = 'Unable to get shipments';
	@AuraEnabled(cacheable=true)
	public static zkmulti__MCShipment__c getShipment(Id shipmentId){
    	List<zkmulti__MCShipment__c> shipments = [SELECT Id, zkmulti__Tracking_Number__c, Transcript_Request__c, Contact__c, Account__c, Case__c 
                                              	FROM zkmulti__MCShipment__c 
                                              	WHERE Id =:shipmentId
                                              	WITH SECURITY_ENFORCED];
    	if(!shipments.isEmpty()){
      		return shipments[0];
    	}    
    	return null;
  	}
}