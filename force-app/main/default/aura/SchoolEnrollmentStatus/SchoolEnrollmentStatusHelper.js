/**
 * Created by Matthew on 11/30/18.
 */
({
    getRunningContactId : function(component, event, helper) {
        var action = component.get("c.getRunningContactId");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.contactId", response.getReturnValue());
                component.find("contactData").reloadRecord(true);
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
        //debugger;
        var errorMessage = "Sorry, an unknown error has occurred. Please contact Customer Service.";
        if(typeof errorStringOrObject == "string") {
            errorMessage = errorStringOrObject;
        } else if(errorStringOrObject.getError) {
            // this is an error from an apex call
            var errors = errorStringOrObject.getError();
            if (errors[0] && errors[0].message) {
                errorMessage = errors[0].message;
            }
        } else if(errorStringOrObject.error && errorStringOrObject.error[0] && errorStringOrObject.error[0].message) {
            // this is an error from a force:recordData call
            errorMessage = errorStringOrObject.error[0].message;
        }
        $A.get("e.c:NotificationEvent").setParams({"errorMessage" : errorMessage }).fire();
    },
})