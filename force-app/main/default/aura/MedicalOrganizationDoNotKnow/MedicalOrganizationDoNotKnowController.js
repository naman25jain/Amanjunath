/**
 * Created by Matthew on 11/12/18.
 */
({
    doInit: function(component, event, helper) {
        $A.util.toggleClass(component.find("doNotKnow"), "toggle");
        helper.initialize(component, event, helper);
    },

    handleAssociationTypeAdded : function(component, event, helper) {
        helper.getContactAssociationTypesAsPromise(component, helper);

    },

    handleDoNotKnowOnChange : function(component, event, helper) {
        if(component.find("doNotKnow").get("v.checked") && component.get("v.associationTypes").length > 0) {
            component.set("v.showDeleteDialog", true);
        }
        else {
			helper.saveContactDataAsPromise(component, helper);
        }
    },

    handleRecordUpdated : function(component, event, helper) {
		helper.orgsUpdated(component, event, helper);
    },

    handleOkOnClick : function(component, event, helper) {
        component.set("v.disableButtons", true);
		helper.removeOrgsAsPromise(component, helper)
            .then( () => {
                    return helper.saveContactDataAsPromise(component, helper);
                }
			)
			.then( () => {
					return helper.getContactAssociationTypesAsPromise(component, helper);
                }
            )
			.catch(
			    (errorMessage) => {
			        console.log("Error: " + errorMessage);
			        helper.handleError(errorMessage);
		       }
            );
    },

    handleCancelOnClick : function(component, event, helper) {
        // hide dialog
        component.set("v.showDeleteDialog", false);
        // uncheck
        component.find("doNotKnow").set("v.checked", false);
    },

})