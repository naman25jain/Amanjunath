({
    initialize : function (component, helper) {
        //debugger;
        helper.getContact(component, helper)
            .then(
                () => {
                    return helper.getContactDetailsUpdateCases(component, helper);
                }
			)
			.catch(
			    (errorMessage) => {
					console.log("An error has occurred in the promise chain: " + errorMessage);
					helper.handleError(errorMessage);
		       }
            );
            helper.apex(component, helper, "checkRestrictOnAppBio",null).then(function(response){
                var restrictCon = response;
                component.set("v.restrictionOnContact",restrictCon );
            });      
    },

    getContact : function(component, helper) {
        // setup params and do pre-processing
        return helper.apex(component, helper, "getContact")
            .then(
                (result) => {
                component.set("v.contact", result);
                // post-processing
            });
    },

    getContactDetailsUpdateCases : function(component, helper) {
        // setup params and do pre-processing
        return helper.apex(component, helper, "getContactDetailsUpdateCases", {"isClosed":false})
            .then(
                (result) => {
					if (result.length == 0) {
						component.set("v.hasExistingChangeCase", false);
					} else{
                        var matchFound = false;
                        for(var i=0; i<result.length; i++){
                          if(result[i].Internal_Status__c == 'Pending Submission'){
                            matchFound = true;
                            break;
                          }  
                        }
                        if(matchFound == true){
                            component.set("v.hasExistingChangeCase", false);
                        }else{
                            component.set("v.hasExistingChangeCase", true);
                        }
					}
					component.set("v.pageReady", true);
				// post-processing
            });
    },
})