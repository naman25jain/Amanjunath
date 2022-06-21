/**
 * Created by Matthew on 11/12/18.
 */
({

    doInit: function(component, event, helper) {
        //console.log("school status init");
        helper.getRunningContactId(component, event, helper);
    },

    handleStatusOnChange : function(component, event, helper) {
        //console.log("handleStatusOnChange");
        component.find("contactData").saveRecord($A.getCallback(function(saveResult) {
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                console.log("contactData saved");
                var appEvent = $A.get("e.c:GenericValidationErrorAE");
                appEvent.setParam("source", "schoolEnrollmentStatus");
                appEvent.setParam("isValid", true);
                appEvent.fire();

            } else {
                helper.handleError(saveResult);
            }
        }));
    },


    handleRecordUpdated : function(component, event, helper) {
        //console.log("handleRecordUpdated");
        // if status is set, then valid; else invalid
        var status = component.get("v.contactFields.School_Enrollment_Status__c");
        var appEvent = $A.get("e.c:GenericValidationErrorAE");
        appEvent.setParam("source", "schoolEnrollmentStatus");
        if(status) {
            appEvent.setParam("isValid", true);
        } else {
            appEvent.setParam("isValid", false);
        }
        appEvent.fire();
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