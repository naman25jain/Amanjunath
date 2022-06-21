({
    doInit: function(component, event, helper) {
        helper.initialize(component, helper);
    },

    emailChange: function(component, event, helper) {
        var initialEmail = component.get("v.initialEmail");
        var newEmail = component.get("v.newEmail");
        var confirmEmail = component.get("v.confirmEmail");
        var format = /\S+@\S+\.\S+/.test(newEmail);

        if (initialEmail != newEmail) {
            component.set("v.duplicate", false);
            component.set("v.showConfirmEmail", true);
        } else {
            component.set("v.showConfirmEmail", false);
        }
        component.set("v.emailFormatValid", format);

        if (confirmEmail != newEmail) {
            component.set("v.validConfirmEmail", false);
        } else {
            component.set("v.validConfirmEmail", true);
        }
    },

    confirmEmailChange: function(component, event, helper) {
        var initialEmail = component.get("v.initialEmail");
        var newEmail = component.get("v.newEmail");
        var confirmEmail = component.get("v.confirmEmail");

        if (confirmEmail != newEmail) {
            component.set("v.validConfirmEmail", false);
        } else {
            component.set("v.validConfirmEmail", true);
        }
        helper.toggleSaveButtonDisabled(component);
    },

    handleChange: function(component, event, helper) {
        component.set("v.hasChanges", true);
    },

    handleOneNameChange: function(component, event, helper) {
        console.log("handleOneNameChange");
        // in order to properly track changes, first name must be set to empty string and not null
        component.set("v.contact.FirstName", "");
        component.set("v.hasChanges", true);
    },


    handlePaste: function(component, event, helper) {
        event.preventDefault();
    },

    handleContext: function(component, event, helper) {
        event.preventDefault();
    },

	handleSave: function(component, event, helper) {

	    component.set("v.disableSaveButton", true);

		var contactData = component.get("v.contact");
        var hasErrors = false;
        var birthDate = new Date(component.get("v.contact.Birthdate") + "T00:00:00");
        var curDate = new Date();
        var bDate = helper.findComponentByName("fieldToValidate", "dateOfBirth", component);
        if (birthDate >= curDate) {
            bDate.setCustomValidity("Date of Birth must be in the past.");
            bDate.reportValidity();
            hasErrors = true
        } else {
            bDate.setCustomValidity("");
        }
        console.log(birthDate)
        if (birthDate == 'Invalid Date') {
            bDate.setCustomValidity("This field is required.");
            bDate.reportValidity();
            hasErrors = true
        }
        var birthCountry = helper.findComponentByName("fieldToValidate", "birthCountry", component);
        if (component.get("v.contact.Birth_Country__c") == '') {
            birthCountry.setCustomValidity("This field is required.");
            birthCountry.reportValidity();
            hasErrors = true
        }
        var email = helper.findComponentByName("fieldToValidate", "email", component);
        if (component.get("v.contact.Email") == '') {
            email.setCustomValidity("This field is required.");
            email.reportValidity();
            hasErrors = true
        }
        var lastName = helper.findComponentByName("fieldToValidate", "lastName", component);
        if (component.get("v.contact.LastName") == '') {
            lastName.setCustomValidity("This field is required.");
            lastName.reportValidity();
            hasErrors = true
        }
        if(component.get("v.contact.legal_name_consists_of_one_name_only__c") == false) {
	        var firstName = helper.findComponentByName("fieldToValidate", "firstName", component);
	        if (!firstName.get("v.value")) {
	            firstName.setCustomValidity("This field is required.");
	            firstName.reportValidity();
	            hasErrors = true
	        }
        }
        if (!hasErrors) {
	        if (component.get("v.showConfirmEmail") && component.get("v.validConfirmEmail")) {
	        	console.log("CONFIRMED");
	        	console.log(component.get("v.confirmChange"));
	        	if (component.get("v.confirmChange") == null || !component.get("v.confirmChange")) {
	        		console.log("CONFIRMED 1");
	        		component.set("v.disableSaveButton", true);
	        	}
		    	helper.updateContactInfoWithEmail(component, helper, component.get("v.newEmail"));
		    }  else {
		    	helper.updateContactInfo(component, helper);
		    }
	    }
	},

	confirmChanges: function(component, event, helper) {
        if (component.get("v.showConfirmEmail") && component.get("v.validConfirmEmail")) {
        	console.log("CONFIRMED");
        	console.log(component.get("v.confirmChange"));
        	if (component.get("v.confirmChange") == null || !component.get("v.confirmChange")) {
        		console.log("CONFIRMED 1");
        		component.set("v.disableSaveButton", true);
        	} else{
        		component.set("v.disableSaveButton", false);
        	}
	    }
    },

    handleCancel: function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
        window.open('/entity360/s/','_top');
    },


/*    contactOnChange : function(component, event, helper) {
        //if(component.get("v.pageReady") && component.get("v.serializedContactData") == JSON.stringify(component.get("v.contact"))) {
		if(component.get("v.serializedContactData") == JSON.stringify(component.get("v.contact")) || (component.get("v.confirmEmail") && component.get("v.validConfirmEmail") == false)) {
            component.set("v.disableSaveButton", true);
            console.log("Disable Save");
        }
        else {
            component.set("v.disableSaveButton", false);
            console.log("Enable Save");
        }
    },*/


    contactOnChange : function(component, event, helper) {
		helper.toggleSaveButtonDisabled(component);
    },
})