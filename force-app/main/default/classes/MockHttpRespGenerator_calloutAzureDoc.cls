@isTest
global class MockHttpRespGenerator_calloutAzureDoc implements HttpCalloutMock{
    global HttpResponse respond(HTTPRequest req) {
        System.assertEquals('GET', req.getMethod(), 'Assert succeeded!');
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBodyAsBlob(Blob.valueOf('Azure Doc Test'));
        res.setStatusCode(200);
        return res;
    }
}