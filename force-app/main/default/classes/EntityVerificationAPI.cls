/**
 * Class for EntityVerificationAPI
 *
 * @author        Shailaja Yerneni
 * @version       1.0
 * @createdDate   01-MAY-2021
 */
/*	
 * Inputs: Entity ID
 * Output: AccountName
 * Endpoint - {Salesforce Base URL}/services/apexrest/EntityVerification/
	API endpoint accepts JSON Request similar to:
		{
			"entityid": "ENT-0000001"
		}
		- queries for the Account with the Entity ID provided in the JSON request
		- returns Response JSON similar to:
			{
				"status": "success", 
				"accountName": "Test Entity",
				"message": ""
			}
*/
@RestResource(urlMapping='/EntityVerification/*')
global with sharing class EntityVerificationAPI {    
	//primary logic for the class
	@HttpPost //HttpPost annotation exposes the method as a REST resource and called when an HTTP POST request is sent
    global static EntityResponseWrapper entityDetails() {
        RestRequest req = RestContext.request; //the RestRequest for the Apex REST method
        EntityResponseWrapper responseJSON = new EntityResponseWrapper(); //entityResponseWrapper object for API response
        String strEntityID = ''; //placeholder for an EntityID
        try{
			String jsonBody = req.requestBody.toString(); //the body of the request
			Map<String, Object> body = new Map<String, Object>(); //placeholder for the JSON Body of the request
            if (!String.isBlank(jsonBody)) { //if the request body is NOT white space
				body = (Map<String, Object>)JSON.deserializeUntyped(jsonBody); //deserializes the JSON string into collections of primitive data types
				if(body.containsKey('entityid')){
					strEntityID = (String)body.get('entityid');
					if(strEntityID != ''){
						List<Account> queriedAccounts = [SELECT Name FROM Account WHERE Entity_ID__c = :strEntityID ORDER BY CreatedDate DESC LIMIT 1]; //query for a Account that has the entityID
						if (!queriedAccounts.isEmpty()) { //if the list is not empty
							responseJSON.accountName = queriedAccounts[0].Name; //populate the AccountName of the Account record to our response object
							responseJSON.status = 'success';
							responseJSON.message = '';	
						}else { //otherwise, no records for given Entity ID
							//respond with failure
							responseJSON.status = 'failure';
							responseJSON.message = 'There are no Entities with the Entity ID of '+strEntityID+'.';
						}
					}else{
						//respond with failure
						responseJSON.status = 'failure';
						responseJSON.message = 'Empty Entity ID';
					}
				}
            }else { //otherwise, the JSON body was white space, empty ('') or null
                //respond with failure
                responseJSON.status = 'failure';
                responseJSON.message = 'Empty or blank json';
			}
        }catch(Exception ex){
          	responseJSON.message = ex.getMessage();
        }
        return responseJSON;
    }
    //wrapper class for the response to an API request
	global class EntityResponseWrapper {
		global String status {get;set;} //status string
		global String accountName {get;set;} // Account Name string
        global String message {get;set;} //message string
		
		//constructor
		global EntityResponseWrapper() {
			//default all values
			this.status = 'failure';
			this.accountName = '';
            this.message = 'Empty or blank json';
		}
	}
}