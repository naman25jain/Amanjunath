({
    save: function(component, helper) {
        var hasErrors = false;
        var birthDate = new Date(component.get("v.contact.Birthdate") + "T00:00:00");
        var curDate = new Date();
        var bDate = helper.findComponentByName("fieldToValidate", "dateOfBirth", component);
        if (birthDate >= curDate) {
            bDate.setCustomValidity("Date of Birth must be in the past.");
            bDate.reportValidity();
            hasErrors = true;
        } else {
            bDate.setCustomValidity("");
        }
        if (birthDate == 'Invalid Date') {
            bDate.setCustomValidity("This field is required.");
            bDate.reportValidity();
            hasErrors = true;
        }
        var birthCountry = helper.findComponentByName("fieldToValidate", "birthCountry", component);
        if (component.get("v.contact.Birth_Country__c") == '' || component.get("v.contact.Birth_Country__c") == undefined) {
            birthCountry.setCustomValidity("This field is required.");
            birthCountry.reportValidity();
            hasErrors = true;
        }
        var email = helper.findComponentByName("fieldToValidate", "email", component);
        if (component.get("v.contact.Email") == '') {
            email.setCustomValidity("This field is required.");
            email.reportValidity();
            hasErrors = true;
        }
        var lastName = helper.findComponentByName("fieldToValidate", "lastName", component);
        if (component.get("v.contact.LastName") == '') {
            lastName.setCustomValidity("This field is required.");
            lastName.reportValidity();
            hasErrors = true;
        }
        if(component.get("v.contact.legal_name_consists_of_one_name_only__c") != true) {
	        var firstName = helper.findComponentByName("fieldToValidate", "firstName", component);
	        if (!firstName.get("v.value")) {
	            firstName.setCustomValidity("This field is required.");
	            firstName.reportValidity();
	            hasErrors = true;
	        }
        }
        var contact = component.get("v.contact");
        var contactStr = JSON.stringify(contact);
        var params = {
            "contactId": contact.Id,
            "contactJSON": contactStr
        };
        if (!hasErrors) {
            component.set("v.pageReady", false);
            return helper.apex(component, helper, "updateContact", params)
                .then((response) => {
                    component.set("v.pageReady", true);
                    /*
                    $A.get("e.c:NotificationEvent").setParams({"successMessage" : "Your Updates have been Saved!" }).fire();
                    window.open('/entity360/s/', '_top'); */
                })
        } else {
            /* $A.get("e.c:NotificationEvent").setParams({"errorMessage" : "Please check your input fields." }).fire(); */
        }
    },
})