/**
 * Class for ApplicantVerification
 *
 * @author        Shailaja Yerneni
 * @version       1.0
 * @createdDate   25-APR-2021
 */
/*	
 * Inputs: ECFMG ID
 * Output: FirstName, RestOfName (nullable), LastName
 * Endpoint - {Salesforce Base URL}/services/apexrest/ApplicantVerification/
	API endpoint accepts JSON Request similar to:
		{
			"ecfmgid": "ECFMG-00000001"
		}
		- queries for the Contact with the ECFMG ID provided in the JSON request
		- returns Response JSON similar to:
			{
				"status": "success", 
				"firstName": "Jane",
				"restOfName": "Jane",
				"lastName": "Smith",
				"message": ""
			}
*/
@RestResource(urlMapping='/ApplicantVerification/*')
global with sharing class ApplicantVerificationAPI {    
	//primary logic for the class
	@HttpPost //HttpPost annotation exposes the method as a REST resource and called when an HTTP POST request is sent
    global static ResponseWrapper applicantDetails() {
        RestRequest req = RestContext.request; //the RestRequest for the Apex REST method
        ResponseWrapper responseJSON = new ResponseWrapper(); //ResponseWrapper object for API response
        String strECFMGID = ''; //placeholder for an ECFMGID
        try{
			String jsonBody = req.requestBody.toString(); //the body of the request
			Map<String, Object> body = new Map<String, Object>(); //placeholder for the JSON Body of the request
            if (!String.isBlank(jsonBody)) { //if the request body is NOT white space
				body = (Map<String, Object>)JSON.deserializeUntyped(jsonBody); //deserializes the JSON string into collections of primitive data types
				if(body.containsKey('ecfmgid')){
					strECFMGID = (String)body.get('ecfmgid');
					if(strECFMGID != ''){
						List<Contact> queriedContacts = [SELECT FirstName, LastName FROM Contact WHERE ECFMG_ID__c = :strECFMGID ORDER BY CreatedDate DESC LIMIT 1]; //query for a Contact that has the email address
						if (!queriedContacts.isEmpty()) { //If the list is not empty
							responseJSON.firstName = queriedContacts[0].FirstName; //Populate the FirstName of the Contact record to our response object
							responseJSON.lastName = queriedContacts[0].LastName; //Populate the LastName of the Contact record to our response object
							responseJSON.restOfName = queriedContacts[0].FirstName; //Populate the RestOfName of the Contact record to our response object
							responseJSON.status = 'success';
							responseJSON.message = '';
							
						}else { //Otherwise, no records for given ECFMG ID
							//Respond with failure
							responseJSON.status = 'failure';
							responseJSON.message = 'There are no Contacts with the ECFMGID of '+strECFMGID+'.';
						}
					}else{
						//Respond with failure
						responseJSON.status = 'failure';
						responseJSON.message = 'Empty ECFMG ID';
					}
				}
            }else { //otherwise, the JSON body was white space, empty ('') or null
                //respond with failure
                responseJSON.status = 'failure';
                responseJSON.message = 'Empty or blank json';
			}
        }catch(Exception ex){
            System.debug('Exception e is' + ex.getMessage());
          	responseJSON.message = ex.getMessage();
        }
        return responseJSON;
    }
    //wrapper class for the response to an API request
	global class ResponseWrapper {
		global String status {get;set;} //status string
		global String firstName {get;set;} // FirstName string
		global String restOfName {get;set;} // RestOfName string
		global String lastName {get;set;} // LastName string
        global String message {get;set;} //message string
		
		//constructor
		global ResponseWrapper() {
			//default all values
			this.status = 'failure';
			this.firstName = '';
			this.restOfName = '';
			this.lastName = '';
            this.message = 'Empty or blank json';
		}
	}
}