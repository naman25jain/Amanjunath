/**
    * @author: Reshma Ravi
    * @name: MockHttpResponseGenerator_GetPicture
    * @description: Mock http callout class for Actionable_GetPictureFromAzureBlobTest
    * @createdDate: 22-Oct-2020
**/
@isTest
global class MockHttpResponseGenerator_GetPicture implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {

        System.assertEquals('GET', req.getMethod(), 'Assert succeeded!');

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBodyAsBlob(Blob.valueOf('tempString'));
        res.setStatusCode(200);
        return res;
    }
}