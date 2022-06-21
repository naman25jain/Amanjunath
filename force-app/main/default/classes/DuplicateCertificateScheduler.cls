//Scheduler class to create Shipping label for Duplicate Certificate case
public with sharing class DuplicateCertificateScheduler implements Schedulable{
	public void execute(SchedulableContext context){
        DuplicateCertificateShipmentHandler handler = new DuplicateCertificateShipmentHandler();
        handler.createShipment();
	}
}