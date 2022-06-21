({
    initialize: function(component, helper) {
    	helper.getCountryList(component, helper);
        return helper.apex(component, helper, "getContact")
            .then(
                (result) => {
                    // in order to properly track changes, missing text field elements must be added empty string value
                    if(result && !result.FirstName) result.FirstName = "";
                    if(result && !result.LastName) result.LastName = "";
                    if(result && !result.Generational_Suffix__c) result.Generational_Suffix__c = "";
                    if(result && !result.Birthdate) result.Birthdate = "";
                    if(result && !result.Birth_Country__c) result.Birth_Country__c = "";
                    if(result && !result.Phone) result.Phone = "";
                    if(result && !result.Department) result.Department = "";
                    if(result && !result.Title) result.Title = "";
                    if(result && !result.ECFMG_ID__c) result.ECFMG_ID__c = "";
					component.set("v.serializedContactData", JSON.stringify(result));
                    component.set("v.initialEmail", result.Email);
                    component.set("v.newEmail", result.Email);
                    component.set("v.contact", result);
                    component.set("v.pageReady", true);
                }).catch(
                (errorMessage) => {
                    console.log("An error has occurred in the promise chain: " + errorMessage);
                    helper.handleError(errorMessage);
                }
            );
    },

    getCountryList : function(component, helper) {
       return helper.apex(component, helper, "getCountries", null).then(function(response) {
           var options = [];
           response.forEach(function(element) {
                   options.push({ value: element, label: element });
           });
           options.sort((a, b) => (a.value > b.value) ? 1 : -1)
           component.set("v.birthCountryList", options);
           component.set("v.pageReady", true);

            });
    },

    findComponentByName: function(id, name, component) {
        var cmps = component.find(id);
        for (var i = 0; i < cmps.length; i++) {
            if (cmps[i].get("v.name") == name) {
                return cmps[i];
            }
        }
    },

    updateContactInfo : function(component, helper) {
    	component.set("v.disableSave", true);
    	component.set("v.pageReady", false);
        var contact = component.get("v.contact");
        console.log(contact);
        var params = {"c": contact};

        component.set("v.pageReady", false);
        return helper.apex(component, helper, "updateContactInformation", params)
            .then((response) => {
            	console.log("RESULT:");
            	console.log(response);
        		component.set("v.disableSave", false);
        		component.set("v.pageReady", true);
        		component.set("v.hasChanges", false);
                /* disable pop success popup
                var toast = $A.get("e.force:showToast");
                toast.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": "Contact Information Successfully Updated"
                });
                toast.fire(); */
                // refresh component
                $A.get('e.force:refreshView').fire();
            });
    },

    updateContactInfoWithEmail : function(component, helper, newEmailAddr) {
    	component.set("v.disableSave", true);
    	component.set("v.pageReady", false);
        var contact = component.get("v.contact");
        contact.Email = newEmailAddr;
        console.log(contact);
        var params = {"c": contact};
        return helper.apex(component, helper, "updateContactInformationWithEmail", params)
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
            		$A.get("e.c:NotificationEvent").setParams({"successMessage" : "Contact Information Successfully Updated"}).fire();
	                // refresh component
	                $A.get('e.force:refreshView').fire();
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
    },

    toggleSaveButtonDisabled : function(component) {
        if(component.get("v.pageReady")) {
/*            console.log("serializedContactData.FirstName: " + JSON.parse(component.get("v.serializedContactData")).FirstName);
            console.log("              contact.FirstName: " + JSON.parse(JSON.stringify(component.get("v.contact"))).FirstName);
            console.log("serializedContactData.legal_name_consists_of_one_name_only__c: " + JSON.parse(component.get("v.serializedContactData")).legal_name_consists_of_one_name_only__c);
			console.log("              contact.legal_name_consists_of_one_name_only__c: " + JSON.parse(JSON.stringify(component.get("v.contact"))).legal_name_consists_of_one_name_only__c);
            console.log("serializedContactData.Phone: " + JSON.parse(component.get("v.serializedContactData")).Phone);
            console.log("              contact.Phone: " + JSON.parse(JSON.stringify(component.get("v.contact"))).Phone);*/

			// if any contact info has changed and there is no confirm email (no email change), then enable the save button
			if(component.get("v.serializedContactData") != JSON.stringify(component.get("v.contact")) && !component.get("v.confirmEmail")) {
				component.set("v.disableSaveButton", false);
				console.log("Enable Save");
			}
			// if has confirm email and both emails match, enable the button
			else if(component.get("v.confirmEmail") && component.get("v.validConfirmEmail")) {
				component.set("v.disableSaveButton", false);
				console.log("Enable Save");
			}
			// otherwise keep the save button disabled
			else {
				component.set("v.disableSaveButton", true);
				console.log("Disable Save");
			}

	        if (component.get("v.showConfirmEmail") && component.get("v.validConfirmEmail")) {
	        	console.log("CONFIRMED");
	        	console.log(component.get("v.confirmChange"));
	        	if (component.get("v.confirmChange") == null || !component.get("v.confirmChange")) {
	        		console.log("CONFIRMED 1");
	        		component.set("v.disableSaveButton", true);
	        	}
		    }
		}
    },


})