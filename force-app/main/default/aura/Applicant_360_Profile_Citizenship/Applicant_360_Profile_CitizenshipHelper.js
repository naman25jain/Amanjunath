/**
 * Created by Matthew on 2019-02-28.
 */
({
    initialize : function (component, helper) {
        // have to get countries first in order for getContact to populate dual listbox
		helper.getCountries(component, helper)
            .then(
                () => {
                    return helper.getContact(component, helper);
                }
			)
			.then(
			    () => {
			        component.set("v.pageReady", true);
			        debugger;
                }
            )
			.catch(
			    (errorMessage) => {
					console.log("An error has occurred in the promise chain: " + errorMessage);
					helper.handleError(errorMessage);
		       }
            );
    },

    getContact : function(component, helper) {
        return helper.apex(component, helper, "getContact")
            .then(
                (result) => {
                component.set("v.contact", result);
                // process selected current citizenship
                if(result.Current_Citizenship__c) {
                    var splitted = result.Current_Citizenship__c.split(";");
                    if(splitted.length > 0) {
	                        component.set("v.currentCitizenshipSelectedCountries", splitted);

                    }
				}
				return result;
            });
    },

	getCountries : function(component, helper) {
        // setup params and do pre-processing
        return helper.apex(component, helper, "getCountriesMap")
            .then(
                (result) => {
					component.set("v.passportCountries", result["passport"]);
					component.set("v.birthCountries", result["birth"]);
					component.set("v.citizenshipAtBirthCountries", result["citizenshipAtBirth"]);
					component.set("v.currentCitizenshipCountries", result["currentCitizenship"]);
					component.set("v.citizenshipUponEnteringMedicalSchoolCountries", result["citizenshipUponEnteringSchool"]);
            });
    },


    saveContact : function(component, helper) {
        var params = { "c" : component.get("v.contact") };
        return helper.apex(component, helper, "updateContact", params)
            .then(
                () => {
					$A.get("e.c:NotificationEvent").setParams({"successMessage" : "Citizenship Information has been saved." }).fire();
            });
    },
})