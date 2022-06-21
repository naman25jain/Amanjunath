/**
 * Created by Matthew on 1/2/19.
 */
({
    initialize : function (component, helper) {
        //debugger;
        helper.getModelAsPromise(component, helper)
            .then(
                () => {
                    //return helper.promise2(component, helper);
                }
			)

			.catch(
			    (errorMessage) => {
					console.log("An error has occurred in the promise chain: " + errorMessage);
					helper.handleError(errorMessage);
		       }
            );
    },

    getModelAsPromise : function(component, helper) {
        // setup params and do pre-processing
        var params = { caseId: component.get("v.recordId") };
        return helper.apex(component, helper, "getCaseImages", params)
            .then(
                (result) => {
                component.set("v.model", result);
            });
    },
})