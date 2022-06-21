/**
 * Created by Matthew on 11/5/18.
 */
({
    getStateOptions: function(component, country) {
        //debugger;
        // clear existing stateOptions
        var stateOptions = [];
        var stateEntries = component.get("v.countryStateMap")[country];
        var parsed;
        for (var i = 0; stateEntries && i < stateEntries.length; i++) {
            parsed = JSON.parse(stateEntries[i]);
            stateOptions.push( { "value" : parsed.value, "label" : parsed.label}  );
        }
        return stateOptions
    },

    resetRequiredFields : function(component, event, helper) {
        //debugger;
        var allFieldsArray = null;
        var allFieldsRaw = component.get("v.allFields");
        if(allFieldsRaw) {
           allFieldsArray = allFieldsRaw.split(",");
        }
        if(allFieldsArray && allFieldsArray.length > 0) {
            for(var i = 0; i < allFieldsArray.length; i++) {
                try {
                    component.find(allFieldsArray[i]).set("v.required", false);
                    // clear out last error
                    component.find(allFieldsArray[i]).setCustomValidity("");
                    component.find(allFieldsArray[i]).reportValidity();
                }
                catch(ex) {
                    // error on stateList vs stateText; faster than checking on loop
                }
            }
        }
    },


	/*
		This method sets the fields required fields using ECFMG business rules based on country chosen.
		This method also handles showing/hiding state list and changing name of state/postal code fields as appropriate.
	*/
    setRequiredFields : function(component, event, helper) {

		//debugger;

        // first reset previously set required fields
        helper.resetRequiredFields(component, event, helper);

        // set country-specific required fields per business rules
        var country = component.find("country").get("v.value");
        var showStateList = component.get("v.showStateList");
        if(country === "US") {
            component.find("street").set("v.label", "Street");
            component.find("city").set("v.label", "City");
            component.find("postalCode").set("v.label", "Zip Code");
            if(showStateList) {
                component.find("stateList").set("v.label", "State");
                component.set("v.requiredFields", "street,city,stateList,postalCode,country");
            } else {
                component.find("stateText").set("v.label", "State");
                component.set("v.requiredFields",  "street,city,stateText,postalCode,country");
            }
        } else if(country === "CA") {
            component.find("street").set("v.label", "Street");
            component.find("city").set("v.label", "City");
            component.find("postalCode").set("v.label", "Postal Code");
            if(showStateList) {
                component.find("stateList").set("v.label", "Province");
                component.set("v.requiredFields", "street,city,stateList,postalCode,country");
            } else {
                component.find("stateText").set("v.label", "Province");
                component.set("v.requiredFields", "street,city,stateText,postalCode,country");
            }
        } else {
            component.find("street").set("v.label", "Street");
            component.find("city").set("v.label", "City");
            component.find("postalCode").set("v.label", "ZIP/Postal Code");
            if(showStateList) {
                component.find("stateList").set("v.label", "State/Province");
                component.set("v.requiredFields", "street,city,country");
            } else {
                component.find("stateText").set("v.label", "State/Province");
                component.set("v.requiredFields", "street,city,country");
            }
        }

		// apply required fields
        var requiredFieldsArray = null;
        var requiredFieldsRaw = component.get("v.requiredFields");
        if(requiredFieldsRaw) {
            requiredFieldsArray = requiredFieldsRaw.split(",");
            //helper.resetRequiredFields(component, event, helper);
        }
        
        if(requiredFieldsArray && requiredFieldsArray.length > 0) {
            for(var i = 0; i < requiredFieldsArray.length; i++) {
                //console.log(requiredFieldsArray[i]);
                if(component.get("v.readOnly") == false) {
                    // cannot set disabled fields as required
                    component.find(requiredFieldsArray[i]).set("v.disabled", false);
                    component.find(requiredFieldsArray[i]).set("v.required", true);
                }
            }
        }
    },

    toggleStateInput : function(component, helper, country) {
        //debugger;
        var stateOptions = helper.getStateOptions(component, country);
        if(stateOptions && stateOptions.length > 0) {
            component.set("v.stateOptions", stateOptions);
            component.set("v.showStateList", true);
        } else {
            component.set("v.showStateList", false);
            //component.set("v.state", "");
        }
    },

    getProhibitedCountryMessage : function(component, country) {
        return component.get("v.prohibitedCountriesMap")[country];
    },

    populateCountryListAsPromise  : function(component, helper) {
        //debugger;
        component.set("v.disabled", true);
        return helper.apexCache(component, helper, "getCountryPicklistEntries")
            .then( (result) => {
                //debugger;
                // set the local attribute
                component.set("v.countryOptions", result);
            });
    },

    populateCountryStateMapAsPromise  : function(component, helper) {
		//debugger;
        component.set("v.disabled", true);
        return helper.apexCache(component, helper, "getGeoData")
            .then( (result) => {
                //debugger;
                component.set("v.countryStateMap", result);
                component.set("v.disabled", false);
                // set default state loading existing value (must be before setRequiredFields or stateList won't get required field set)
                helper.toggleStateInput(component, helper, component.get("v.country"));
                // must set required fields after re-enabling the fields (must be after toggleStateInput or stateList won't get required field set)
                helper.setRequiredFields(component, event, helper);
            });
    },
})