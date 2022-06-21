@isTest
public with sharing class WDOMSResponseHandlerTest {
    @isTest
        static void wdomsResponseHandlerTestPositive() {
        WDOMSResponse resObj = new  WDOMSResponse(); 
        resObj.responseStatus = 'FAILED'; 
        resObj.status = 200; 
        resObj.errorDescription= 'Invalid entity'; 
        resObj.transactionId = 'Transaction Id missing';
        WDOMSResponse.Cls_payload  resObjPLoad = new  WDOMSResponse.Cls_payload(); 
        resObjPLoad.CorrelationID= 'fd14cdc0-b404-11eb-b050-06882d7c678e';
        resObjPLoad.status = 'FAILED'; 
        resObjPLoad.message = 'Invalid entity'; 
        resObj.payload = resObjPLoad;

        Test.startTest();
            WDOMSResponse__e  wr = new WDOMSResponse__e();
            wr.payload__c =JSON.serializePretty(resObj); 
            Database.SaveResult sr = EventBus.publish(wr);
        Test.stopTest();
        system.assertEquals(sr.isSuccess(), true, 'Successfully published ');
    }

    @isTest
    static void wdomsResponseHandlerTestNegative() {
        WDOMSResponse resObj = new  WDOMSResponse(); 
        WDOMSResponse.Cls_payload  resObjPLoad = new  WDOMSResponse.Cls_payload(); 
        resObj.payload = resObjPLoad;
        Test.startTest();
            WDOMSResponse__e  wr = new WDOMSResponse__e();
            wr.payload__c =JSON.serializePretty(resObj); 
            Database.SaveResult sr = EventBus.publish(wr);  
        Test.stopTest();
        system.assertEquals(sr.isSuccess(), true, 'Successfully published - go to the else part of the trigger handler');
    }
}