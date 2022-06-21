/**
 * Created by Matthew on 11/5/18.
 */
({
    doInit : function(component, event, helper) {
        if(component.get("v.layout") == "Stacked") {
            component.set("v.formElementCssClass", "slds-form-element slds-form-element_stacked");
        }
        else {
            component.set("v.formElementCssClass", "slds-form-element slds-form-element_horizontal");
        }
        helper.populateCountryListAsPromise(component, helper)
            .then(
                () => {
                    return helper.populateCountryStateMapAsPromise(component, helper);
                }
			)
            .then(
                () => {
                    component.set("v.disabled", false);
                }
			)
			.catch(
			    (errorMessage) => {
					console.log("An error has occurred in the promise chain: " + errorMessage);
					helper.handleError(errorMessage);
		       }
            );
    },

    handleCountryOnChange : function(component, event, helper) {
        //debugger;
        component.set("v.hasAddressChanges", true);
        var country = component.find("country").get("v.value");
        var message = helper.getProhibitedCountryMessage(component, country)
        if(message) {
            component.set("v.blockEntry", true);
            component.find("country").setCustomValidity(message);
            component.find("country").reportValidity();
        }
        else {
            component.set("v.blockEntry", false);
            component.find("country").setCustomValidity("");
            component.find("country").reportValidity();
            helper.toggleStateInput(component, helper, country);
            helper.setRequiredFields(component, event, helper);
            // handle clearing of state attribute when country changes only after initial load.
            if(component.get("v.initialLoad")) {
                component.set("v.initialLoad", false)
            }
            else {
                component.set("v.state", "");
            }
        }
    },

    handleStateOnChange : function(component, event, helper) {
        // nothing to do here right now...
        component.set("v.hasAddressChanges", true);
    },
    
    handleChange : function(component, event, helper) {
        // nothing to do here right now...
        component.set("v.hasAddressChanges", true);
    },

    validate : function(component, event, helper) {

        var country = component.find("country").get("v.value");
        var message = helper.getProhibitedCountryMessage(component, country)
        if(message) {
            return false;
        }
        else {
            var showStateList = component.get("v.showStateList");
            var street = component.find("street");
            var city = component.find("city");
            var state = showStateList ? component.find("stateList") : component.find("stateText");
            var postalCode = component.find("postalCode");
            var country = component.find("country");
            street.reportValidity();
            city.reportValidity();
            state.reportValidity();
            postalCode.reportValidity();
            country.reportValidity();
            var isValid = street.checkValidity();
            if(isValid) isValid = city.checkValidity();
            if(isValid) isValid = state.checkValidity();
            if(isValid) isValid = postalCode.checkValidity();
            if(isValid) isValid = country.checkValidity();
            return isValid;
        }
    },

    reset: function(component, event, helper) {
        component.set("v.street", null);
        component.set("v.city", null);
        component.set("v.state", null);
        component.set("v.postalCode", null);
        component.set("v.country", null);
    },

    handleInputOnBlur :  function(component, event, helper) {
        var field = event.getSource();
        if(field.get("v.value") && typeof field.get("v.value") == "string") field.set("v.value", field.get("v.value").trim());
    },
})