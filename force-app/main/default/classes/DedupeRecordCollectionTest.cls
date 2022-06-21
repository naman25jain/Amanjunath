@isTest
public class DedupeRecordCollectionTest {
    @isTest
    public static void testContUserSyncBatchSchd(){
        list<DedupeRecordCollection.FlowRequest> listflowreq = new list<DedupeRecordCollection.FlowRequest>();
        List<SObject> listObjects = new List<SObject>();
        Contact contct = new Contact(FirstName = 'Test',LastName = 'LastName', Gender__c = 'Male',MailingStreet = 'Test Street',
                                     Mailingcity = 'Test City', MailingState = 'New Jersey', MailingCountry = 'United States',
                                     MailingPostalCode = '123456', Name_Change__c = true);
        insert contct;
        listObjects.add(contct);
        DedupeRecordCollection.FlowResponse flowresp = new  DedupeRecordCollection.FlowResponse();
        flowresp.outputRecordCollection = listObjects;
        DedupeRecordCollection.FlowRequest flowreq = new DedupeRecordCollection.FlowRequest();
        flowreq.fieldToDedupeOn ='test';
        flowreq.inputRecordCollection =listObjects;
        listflowreq.add(flowreq);
        Test.StartTest();
        DedupeRecordCollection.dedupe(listflowreq);
        Test.StopTest();
    }
    
}