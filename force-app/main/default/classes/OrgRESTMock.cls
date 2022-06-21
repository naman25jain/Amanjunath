@isTest
global class OrgRESTMock implements HttpCalloutMock {
    public Integer code;
    
    global OrgRESTMock(Integer code){
		this.code = code;
	}
	
    global HTTPResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBodyAsBlob(Blob.valueOf('{"size":528,"totalSize":528,"done":true,"queryLocator":null,"entityTypeName":"ApexCodeCoverageAggregate","records":[{"attributes":{"type":"ApexCodeCoverageAggregate","url":"/services/data/v46.0/tooling/sobjects/ApexCodeCoverageAggregate/71517000003tkxfAAA"},"Id":"71517000003tkxfAAA","ApexClassOrTriggerId":"01p1700000G52SrAAJ","ApexClassOrTrigger":{"attributes":{"type":"Name","url":"/services/data/v46.0/tooling/sobjects/ApexClass/01p1700000G52SrAAJ"},"Name":"WDOMSSchoolProgramResponse"},"NumLinesCovered":18,"NumLinesUncovered":0}]}'));
        //res.setBodyAsBlob(Blob.valueOf('{"size":528,"totalSize":528,"done":true,"queryLocator":null,"entityTypeName":"ApexCodeCoverageAggregate","records":[{"attributes":{"type":"ApexCodeCoverageAggregate","url":"/services/data/v46.0/tooling/sobjects/ApexCodeCoverageAggregate/71517000003tkxfAAA"},"Id":"71517000003tkxfAAA","ApexClassOrTriggerId":"01p1700000G52SrAAJ","ApexClassOrTrigger":{"attributes":{"type":"Name","url":"/services/data/v46.0/tooling/sobjects/ApexClass/01p1700000G52SrAAJ"},"Name":"WDOMSSchoolProgramResponse"},"NumLinesCovered":0,"NumLinesUncovered":0}]}'));
        res.setStatusCode(this.code);
        return res;
    }
}