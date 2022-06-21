({
    initialize : function (component, helper) {
        helper.getContact(component, helper);
    },

    getContact : function(component, helper) {
        return helper.apex(component, helper, "getContact")
        .then(
            (result) => {
            	console.log("Result: " + result);
            	component.set("v.initialEmail", result.Email);
            	component.set("v.newEmail", result.Email);
            	component.set("v.contact", result);
            	component.set("v.pageReady", true);
            	component.set("v.phoneNumber", result.Phone);
            	component.set("v.phoneType", result.Phone_Type__c);
        }).catch(
		    (errorMessage) => {
				console.log("An error has occurred in the promise chain: " + errorMessage);
				helper.handleError(errorMessage);
	       }
        );
    },
    
    updateContactInfo : function(component, helper, contactData) {
    	console.log("HERE1");
    	var hasErrors = false;
    	if(!component.find("submitAddress").validate()) hasErrors = true;
    	console.log("HERE2");
		var allValid = component.find("fieldToValidate");
		for (var x=0; x<allValid.length; x++) {
			if(!allValid[x].get("v.validity").valid) {
				allValid[x].showHelpMessageIfInvalid();
				hasErrors = true;
			}
		}
		console.log("HERE3");
		if(!hasErrors) {
	    	component.set("v.disableSave", true);
	    	component.set("v.pageReady", false);
	    	console.log("updateContactInfo");
	    	console.log(contactData);
	        console.log(contactData.Phone);
	        console.log(contactData.Phone_Type__c);
	        return helper.apex(component, helper, "updateContactInformation", {"contactId":contactData.Id, "country":contactData.MailingCountryCode, "street":contactData.MailingStreet,"city":contactData.MailingCity, "state":contactData.MailingStateCode, "zip":contactData.MailingPostalCode, "phoneNumber":contactData.Phone, "phoneType":contactData.Phone_Type__c})
	        .then(
	            (result) => {
	            	console.log("Result: " + result);
	            	if (result == "Success") {
	            		$A.get("e.c:NotificationEvent").setParams({"successMessage" : "Contact Information Succesfully Updated"}).fire();
	            		component.set("v.disableSave", false);
	            		component.set("v.pageReady", true);
	            		component.set("v.hasChanges", false);
	            		component.set("v.hasAddressChanges", false);
	            	}
	        }).catch(
			    (errorMessage) => {
					console.log("An error has occurred in the promise chain: " + errorMessage);
					helper.handleError(errorMessage);
					component.set("v.disableSave", false);
					component.set("v.pageReady", true);
		       }
	        );
		} else {
			console.log("ERROR FOUND");
			$A.get("e.c:NotificationEvent").setParams({"errorMessage" : "You must complete all required fields before proceeding."}).fire();
		}
    },
    
    updateContactInfoWithEmail : function(component, helper, contactData, newEmailAddr) {
    	var hasErrors = false;
    	if(!component.find("submitAddress").validate()) hasErrors = true;
		var allValid = component.find("fieldToValidate");
		for (var x=0; x<allValid.length; x++) {
			if(!allValid[x].get("v.validity").valid) {
				allValid[x].showHelpMessageIfInvalid();
				hasErrors = true;
			}
		}

		
		if(!hasErrors) {
	    	component.set("v.disableSave", true);
	    	component.set("v.pageReady", false);
	        console.log("updateContactInfoWithEmail");
	        console.log(contactData.Phone);
	        console.log(contactData.Phone_Type__c);
	        return helper.apex(component, helper, "updateContactInformationWithEmail", {"contactId":contactData.Id, "country":contactData.MailingCountryCode, "street":contactData.MailingStreet,"city":contactData.MailingCity, "state":contactData.MailingStateCode, "zip":contactData.MailingPostalCode, "email":newEmailAddr, "phoneNumber":contactData.Phone, "phoneType":contactData.Phone_Type__c})
	        .then(
	            (result) => {
	            	console.log("Result: " + result);
	            	if (result == "Success") {
	            		component.set("v.initialEmail", newEmailAddr);
	            		component.set("v.showConfirmEmail", false);
	            		component.set("v.disableSave", false);
	            		component.set("v.pageReady", true);
	            		component.set("v.confirmEmail", "");
	            		component.set("v.confirmChange", false);
	            		component.set("v.hasChanges", false);
	            		component.set("v.hasAddressChanges", false);
	            		$A.get("e.c:NotificationEvent").setParams({"successMessage" : "Contact Information Succesfully Updated"}).fire();
	            	} else if (result == "Duplicate") {
	            		component.set("v.duplicate", true);
	            		component.set("v.pageReady", true);
	            		component.set("v.showConfirmEmail", false);
	            		component.set("v.confirmEmail", "");
	            		component.set("v.confirmChange", false);
	            		component.set("v.disableSave", false);
	            	}
	        }).catch(
			    (errorMessage) => {
					console.log("An error has occurred in the promise chain: " + errorMessage);
					helper.handleError(errorMessage);
					component.set("v.disableSave", false);
					component.set("v.pageReady", true);
		       }
	        );
		} else {
			console.log("ERROR FOUND");
			$A.get("e.c:NotificationEvent").setParams({"errorMessage" : "You must complete all required fields before proceeding."}).fire();
		}
    },

})