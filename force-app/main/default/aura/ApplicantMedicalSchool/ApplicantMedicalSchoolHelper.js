/**
 * Created by Matthew on 10/31/18.
 */
({
    initialize: function(component, event, helper) {
        helper.getRunningContactId(component, event, helper);
    },

    getContactMedicalSchools : function(component, event, helper) {
        var action = component.get("c.getContactMedicalSchools");
        var contactId = component.get("v.contactId");
        action.setParams( {
            "contactId": contactId,
            "recordTypeName":  component.get("v.associationRecordType")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var schools = response.getReturnValue();
                component.set("v.schools", schools);
            } else {
                helper.handleError(response);
            }
        });
        $A.enqueueAction(action);
    },

    getRunningContactId : function(component, event, helper) {
        var action = component.get("c.getRunningContactId");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.contactId", response.getReturnValue());
                helper.getContactMedicalSchools(component, event, helper);
            } else {
                helper.handleError(response);
            }
        });
        $A.enqueueAction(action);
    },

    /*
        This generic error handler accepts a string, a server response (as returned by an Apex call) or a result, as returned
        by a force:recordData call. Shows first error message in collection if any, or default error message.
    */
    handleError : function(errorStringOrObject) {
        var errorMessage = "Sorry, an unknown error has occurred. Please contact Customer Service.";
        if(typeof errorStringOrObject == "string") {
            errorMessage = errorStringOrObject;
        } else if(errorStringOrObject.getError) {
            // this is an error from an apex call
            var errors = errorStringOrObject.getError();
            if (errors[0] && errors[0].message) {
                errorMessage = errors[0].message;
            }
        } else if(errorStringOrObject.error) {
            // this is an error from a force:recordData call
            errorMessage = errorStringOrObject.error
        }
        $A.get("e.c:NotificationEvent").setParams({"errorMessage" : errorMessage }).fire();
    },

})