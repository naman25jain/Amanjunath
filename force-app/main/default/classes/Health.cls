// /services/apexrest/health
@RestResource(urlMapping='/health/*')
global with sharing class Health{
    @HttpGet
    global static string getHealth(){
        string retString; 
        retString = '{"serviceHealth": { "serviceType": "sfdc", "status": "UP", "statusCode": 200 } }'; 
        string jString = JSON.serialize(retString);
        return jString; 
    }
}