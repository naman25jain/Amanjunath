/**
 * Created by Matthew on 12/4/18.
 */
({
    constants: {

        // medical registration / Licensure url
        "COMMON_AUTHORITIES_URL" : "/s/medical-authorities",

        // review url for common paths
        "COMMON_REVIEW_URL" : "/s/community-summary",

        // review url for epic path
        "SERVICE_EPIC_REVIEW_URL" : "/s/epic-summary",

        // review url for ecfmg cert path
        "SERVICE_CERT_REVIEW_URL" : "/s/ecfmg-cert-summary",
        
        // review url for ecfmg cert path
        "SERVICE_GEMX_REVIEW_URL" : "/s/gemx-summary",
                
        // common medical schools
        "COMMON_SCHOOL_URL" : "/s/medical-schools",
        
        // cert medical schools
        "SERVICE_CERT_SCHOOL_URL" : "/s/medical-schools-ecfmg-cert",

		// creates view url for liking to lightning records; replace {0} with id of record
		"VIEW_LIGHTNING_RECORD_URL" : "/one/one.app?#/sObject/{0}/view"

    },

    /*
		This method provides a simple way to call a server method and return promise.
    */
	apex : function(component, helper, apexAction, params) {
	    var p = new Promise( $A.getCallback( function( resolve , reject ) {
	        var action = component.get("c." + apexAction);
	        if(params) action.setParams(params);
	        action.setCallback(this, function(callbackResult) {
	            if(callbackResult.getState() == 'SUCCESS') {
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
        This method provides a simple way to call a server method with client-side caching and return promise.
    */
    apexCache : function(component, helper, apexAction, params) {
        var p = new Promise( $A.getCallback( function( resolve , reject ) {
            var action = component.get("c." + apexAction);
            action.setStorable();
            if(params) action.setParams(params);
            action.setCallback(this, function(callbackResult) {
                if(callbackResult.getState() == 'SUCCESS') {
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

    apexCache : function(component, helper, apexAction) {
        var p = new Promise( $A.getCallback( function( resolve , reject ) {
            var action = component.get("c." + apexAction);
            action.setStorable();
            action.setCallback(this, function(callbackResult) {
                if(callbackResult.getState() == 'SUCCESS') {
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
        Finds a component by id/name, useful when many components have the same id.
    */
    findComponentByName: function(id, name, component) {
        var cmps = component.find(id);
        for (var i = 0; i < cmps.length; i++) {
            if (cmps[i].get("v.name") == name) {
                return cmps[i];
            }
        }
    },

	/*
		Simple string tokenizer/formatter from
		See: https://salesforce.stackexchange.com/a/170634/12290
	*/
	format: function(string) {
	    var outerArguments = arguments;
	    return string.replace(/\{(\d+)\}/g, function() {
	        return outerArguments[parseInt(arguments[1]) + 1];
	    });
	},

	/*
		Simple method to return an empty string with input string is null or undefined.
		If input string isn't of string type, throws exception.
		Returns input string if it is a string (even if it is an empty string).
	*/
	nullSafe : function(string) {
	    if(string) {
	        // if not string type, throw exception
	        if(typeof string !== "string") throw "Input string must be of type string.";
	        // else return the original string (is string type)
	        return string;
        }
        // else return empty string
		return "";
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
        } else if(errorStringOrObject.message) {
            // this is a standard error message object
            errorMessage = errorStringOrObject.message;
        } else if(errorStringOrObject.error && errorStringOrObject.error[0] && errorStringOrObject.error[0].message) {
            // this is an error from a force:recordData call
            errorMessage = errorStringOrObject.error[0].message;
        }
        $A.get("e.c:NotificationEvent").setParams({"errorMessage" : errorMessage }).fire();
    },
})