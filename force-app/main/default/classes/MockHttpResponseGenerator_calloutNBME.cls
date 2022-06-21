@isTest
global class MockHttpResponseGenerator_calloutNBME implements HttpCalloutMock{
    global HttpResponse respond(HTTPRequest req) {
        System.assertEquals('GET', req.getMethod(), 'Assert succeeded!');
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBodyAsBlob(Blob.valueOf('NBME API Test'));
        res.setStatusCode(200);
        return res;
    }
}