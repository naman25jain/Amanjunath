/** @name: ContactTrigger
 *  @description: Trigger to process contact and related data based on event type
**/
trigger ContactTrigger on Contact ( before insert, before update, after insert, after update){

    TriggerFactory.createHandler(Contact.SObjectType);

}