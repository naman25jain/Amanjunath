/**
 * Created by Matthew on 12/31/18.
 */
({

    initialize : function (component, helper) {
        //debugger;
        helper.promise1(component, helper)
            .then(
                () => {
                    return helper.promise2(component, helper);
                }
			)
			.then(
			    () => {
					return helper.promise3(component, helper);
				}
			)
			.then(
			    () => {
					return helper.promise4(component, helper);
				}
			)
			.catch(
			    (errorMessage) => {
					console.log("An error has occurred in the promise chain: " + errorMessage);
					helper.handleError(errorMessage);
		       }
            );
    },

    promise1 : function(component, helper) {
        // setup params and do pre-processing
        return helper.apex(component, helper, "getRunningContactId")
            .then(
                (result) => {
                console.log("Promise 1 Result: " + result);
                // post-processing
            });
    },

    promise2 : function(component, helper) {
        // setup params and do pre-processing
        return helper.apex(component, helper, "getRunningContactId")
            .then(
                (result) => {
                console.log("Promise 2 Result: " + result);
				// post-processing
            });
    },

    promise3 : function(component, helper) {
        // setup params and do pre-processing
        return helper.apex(component, helper, "getRunningContactId")
            .then(
                (result) => {
                console.log("Promise 3 Result: " + result);
                // post-processing
            });
    },

    promise4 : function(component, helper) {
        // setup params and do pre-processing
        return helper.apex(component, helper, "errorTest")
            .then(
                (result) => {
                console.log("Promise 4 Result: " + result);
                // post-processing
            });
    },

})