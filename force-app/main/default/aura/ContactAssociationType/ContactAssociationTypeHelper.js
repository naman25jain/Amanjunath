/**
 * Created by Matthew on 10/31/18.
 */
({
    initialize: function(component, event, helper) {

        component.set("v.recordNameSingularLower", component.get("v.recordNameSingular").toLowerCase());
        component.set("v.recordNamePluralLower", component.get("v.recordNamePlural").toLowerCase());
        //helper.getRunningContactId(component, event, helper);


        helper.apex(component, helper, "getRunningContactId")
            .then(function(result) {
                component.set("v.contactId", result);
             }, function(result) {
                 helper.handleError(result);
             })
            .then(function() {
                var action = component.get("c.getContactAssociationTypes");
                var contactId = component.get("v.contactId");
                action.setParams( {
                    "contactId": contactId,
                    "recordTypeName":  component.get("v.associationRecordType")
                });
                action.setCallback(this, function(response) {
                    //debugger;
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var associationTypes = response.getReturnValue();
                        component.set("v.associationTypes", associationTypes);
                    } else {
                        helper.handleError(response);
                    }
                });
                $A.enqueueAction(action);
            });
    },


/*    getRunningContactId : function(component, event, helper) {
        var action = component.get("c.getRunningContactId");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.contactId", response.getReturnValue());
                helper.getContactAssociationTypes(component, event, helper);
            } else {
                helper.handleError(response);
            }
        });
        $A.enqueueAction(action);
    },


    getContactAssociationTypes : function(component, event, helper) {
        debugger;
        var action = component.get("c.getContactAssociationTypes");
        var contactId = component.get("v.contactId");
        action.setParams( {
            "contactId": contactId,
            "recordTypeName":  component.get("v.associationRecordType")
        });
        action.setCallback(this, function(response) {
            debugger;
            var state = response.getState();
            if (state === "SUCCESS") {
                var associationTypes = response.getReturnValue();
                component.set("v.associationTypes", associationTypes);
            } else {
                helper.handleError(response);
            }
        });
        $A.enqueueAction(action);
    },*/


    apex : function(component, helper, apexAction, params ) {
	    var p = new Promise( $A.getCallback( function( resolve , reject ) {
	        var action = component.get("c."+apexAction+"");
	        if(params) action.setParams(params);
	        action.setCallback( this , function(callbackResult) {
	            if(callbackResult.getState()=='SUCCESS') {
	                resolve( callbackResult.getReturnValue() );
	            }
	            else {
	                helper.handleError(callbackResult);
	                reject(callbackResult);
	            }
	        });
	        $A.enqueueAction( action );
	    }));
        return p;
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