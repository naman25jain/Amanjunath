/**
    * @author: Reshma Ravi
    * @name: MockHttpResponseGenerator_UploadDocument
    * @description: Mock http callout class for Actionable_UploadDocumentToAzureBlobTest
    * @createdDate: 22-Oct-2020
**/
@isTest
global class MockHttpResponseGenerator_UploadDocument implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {

        if(req.getMethod() == 'PUT'){
            System.assertEquals('PUT', req.getMethod(), 'Assert succeeded!');
        } else {
            System.assertEquals('GET', req.getMethod(), 'req.getMethod failed');
        }
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBodyAsBlob(Blob.valueOf('tempString'));
        res.setStatusCode(200);
        return res;
    }
}