/**
 * Created by Matthew on 2019-08-14.
 */

 ({
    initialize : function(component, event, helper) {

        // reset view
        component.set("v.showExistingContact", true);
        component.set("v.showChosenContact", false);
        component.set("v.chosenContact", null);

        var caseId = component.get("v.caseId");
		if(caseId) {
            // get the case
            helper.getCase(component, helper)
                .then(
                    (result) => {
                        // set the case attribute
                        component.set("v.case", result);
                        // get the applicant on the case
                        if(result && result.ContactId) {
                            // get the applicant
                            helper.getContact(component, helper, result.ContactId)
                                .then(
                                    (result) => {
                                        // set the existing contact attribute
                                        component.set("v.existingContact", result);
                                        // make page ready
                                        component.set("v.pageReady", true);
                                });
                            // set the output contact id
                            component.set("v.contactId", result.ContactId);
                        }
                        else {
                            // make sure we have a case and a case contact
                            $A.get("e.c:NotificationEvent").setParams({ errorMessage: "Could not find case or case does not have an associated contact." }).fire();
                            // get out
                            return;
                        }

                });

            // this can be called asynchronously with other calls above
            helper.getApplicantMatches(component, helper)
                .then(
                    (result) => {
                        if(result && result.length && result.length > 0) {
                            component.set("v.hasDuplicates", true);
                            component.set("v.flowHeaderText", component.get("v.dupesFoundHeaderText"));
                            // make the dupe matches visible
                            var appEvent = $A.get("e.c:ApplicantMatchAE");
                            appEvent.setParam("showMatches", true);
                            appEvent.fire();
                        }
                        else {
                            component.set("v.hasDuplicates", false);
                            component.set("v.flowHeaderText", component.get("v.dupesNotFoundHeaderText"));
                        }
                    }
                );
        }
        else {
            // make sure we have a caseId set by container
            $A.get("e.c:NotificationEvent").setParams({ errorMessage : "Please provide a caseId." }).fire();
            // get out
            return;
        }

    },


	/*
		Returns the contact (applicant) record.
	*/
    getContact : function(component, helper, id) {
        // setup params and do pre-processing
		var params = { contactId: id };
        return helper.apex(component, helper, "getContact", params)
            .then(
                (result) => {
                    return result;
            });
    },

	/*
		This method will return the case as a promise.
	*/
    getCase : function(component, helper) {
        // setup params and do pre-processing
		var params = { caseId: component.get("v.caseId") };
        return helper.apex(component, helper, "getCase", params);
    },


    getApplicantMatches : function(component, helper) {
        // setup params and do pre-processing
		var params = { caseId: component.get("v.caseId") };
        return helper.apex(component, helper, "getApplicantMatches", params);
    },

});