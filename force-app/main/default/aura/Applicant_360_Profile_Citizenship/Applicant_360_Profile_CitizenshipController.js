/**
 * Created by Matthew on 2019-02-28.
 */
({

	doInit : function(component, event, helper) {
    	helper.initialize(component, helper);
	},

	handleSaveOnClick : function(component, event, helper) {

        // disable button on click
        component.find("saveButton").set("v.disabled", true);

        // use an array to capture all validation outcomes
        var allValid = [true];

        allValid.push(component.find("fieldToValidate").reduce(function (validSoFar, cmp) {
            cmp.reportValidity();
            return validSoFar && cmp.checkValidity();
        }, true));

		// get unique values
        var distinctValid = Array.from(new Set(allValid));
        if(distinctValid.length == 1 && distinctValid[0] == true) {

			// prepare the citizenship countries string for saving
            var joined = component.get("v.currentCitizenshipSelectedCountries").join("; ");
			var contact = component.get("v.contact");
			contact.Current_Citizenship__c = joined;
			component.set("v.contact", contact);

            // save the contact if no validation errors
            component.set("v.showSaveSpinner", true);
            helper.saveContact(component, helper)
                .then(() => {
		            // enable button
		            component.find("saveButton").set("v.disabled", false);
		            // hide spinner
		            component.set("v.showSaveSpinner", false);
                });
        }
        else {
            // enable button
            component.find("saveButton").set("v.disabled", false);
        }
    },

    handleCancelOnClick : function(component, event, helper) {
        $A.get("e.force:refreshView").fire();
    }
})