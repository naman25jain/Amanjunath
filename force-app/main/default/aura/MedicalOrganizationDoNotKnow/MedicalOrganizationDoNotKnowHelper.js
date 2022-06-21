/**
 * Created by Matthew on 11/15/18.
 */
({
    initialize : function(component, event, helper) {
		// disable control
        component.set("v.disabled", true);
        helper.getRunningContactIdAsPromise(component, helper)
            .then(
                () => {
					// cause the record data component to reload with teh current contactid
	                component.find("contactData").reloadRecord(true);
	                // get contact association types
                    return helper.getContactAssociationTypesAsPromise(component, helper);
                }
			)
			.then(
				() => {
	                // enable the control
	                component.set("v.disabled", false);
                }
            )
			.catch(
			    (errorMessage) => {
			        helper.handleError(errorMessage);
		       }
            );
    },

    getRunningContactIdAsPromise : function(component, helper) {
        return helper.apex(component, helper, "getRunningContactId")
            .then( (result) => {
                // set the local attribute
                component.set("v.contactId", result);
            });
    },

    getContactAssociationTypesAsPromise : function(component, helper) {
		var params = {
            "contactId": component.get("v.contactId"),
            "recordTypeName":  component.get("v.associationRecordType")
        };
        return helper.apex(component, helper, "getContactAssociationTypes", params)
            .then( (result) => {
                // set the local attribute
				component.set("v.associationTypes", result);
				console.log("v.associationTypes count: " + component.get("v.associationTypes").length);
            });
    },

    removeOrgsAsPromise : function(component, helper) {
		var params = {
			"contactId": component.get("v.contactId"),
			"recordTypeName":  component.get("v.associationRecordType")
		};
        return helper.apex(component, helper, "deleteContactAssociationTypes", params)
            .then( (result) => {
                debugger;
                // enable the control
                component.set("v.disabled", false);
                // enable buttons
				component.set("v.disableButtons", false);
		        // hide dialog
		        component.set("v.showDeleteDialog", false);
            });
    },

    orgsUpdated : function(component, event, helper) {
        // if status is set, then valid; else invalid
        var visible = !component.get("v.contactFields.Regulatory_Org_Do_Not_Know__c");
        var appEvent = $A.get("e.c:ContactAssociationTypeStateAE");
        appEvent.setParam("visible", visible);
        appEvent.setParam("disabled", component.get("v.disabled"));
        appEvent.setParam("source", "associationTypeSearch:" + component.get("v.associationRecordType"));
        if(visible) {
            // if searcher is to be visible, then need at least 1 association type
            appEvent.setParam("minimumAssociationTypes", 1);
        } else {
            appEvent.setParam("minimumAssociationTypes", 0);
        }
        appEvent.fire();
        // do not show checkbox is not checked an on summary page (read only)
        if(!component.get("v.contactFields.Regulatory_Org_Do_Not_Know__c") && component.get("v.readOnly")) component.set("v.showCheckbox", false);
    },

	saveContactDataAsPromise : function(component, helper) {
		var p = new Promise( ( resolve , reject ) => {
	        component.find("contactData").saveRecord($A.getCallback(function(saveResult) {
	            debugger;
	            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
					resolve();
	            } else {
	                reject(saveResult);
	            }
	        }));
	    });
        return p;
    },

	apex : function(component, helper, apexAction, params ) {
	    var p = new Promise( $A.getCallback( function( resolve , reject ) {
	        var action = component.get("c."+apexAction+"");
	        if(params) action.setParams(params);
	        action.setCallback( this , function(callbackResult) {
	            if(callbackResult.getState()=='SUCCESS') {
	                resolve(callbackResult.getReturnValue());
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