({
    initialize : function (component, helper) {
        helper.getPrivacyAgreement(component, helper)
            .then(
                () => {
                return helper.getContactInfo(component, helper);
             })
            .then(
                () => {
                return helper.getCountryList(component, helper);
            })
            .catch(
                (errorMessage) => {
                console.log(errorMessage);
            });
        helper.getGenderPicklistEntries(component, helper);
        helper.getGenerationalSuffixPicklistEntries(component, helper);
    },

    getPrivacyAgreement : function(component, helper) {
        var privacyName= component.get("v.privacyAgreementName");   ////////  Entity Contact Privacy Agreement
        var params = {"privacyName" : privacyName}
        return helper.apex(component, helper, "getInitContactInfo", params).then(function(response) {
                console.log(response);
				if (response == null) {  ///// privacy agreement accepted
					component.set("v.privacyAgreementAccepted", true);
				} else { ////// privacy not accepted
					component.set("v.privacyText", response);
				}
           	});
    },
    getContactInfo : function(component, helper) {
       return helper.apex(component, helper, "getContact", null).then(function(response) {
                console.log(response)
                component.set("v.contactRecord", response);
                if (response.Entity_Contact_Initial_Fields_Complete__c == true){
                    component.set("v.contactCompleted", true);
                } else {
                    component.set("v.contactCompleted", false);
                }
                });
    },
    getCountryList : function(component, helper) {
       return helper.apex(component, helper, "getCountries", null).then(function(response) {
           var options = [];
           response.forEach(function(element) {
                   options.push({ value: element, label: element });
           });
           options.sort((a, b) => (a.value > b.value) ? 1 : -1)
           component.set("v.countryList", options);
           component.set("v.pageReady", true);

            });
    },

    getGenderPicklistEntries : function(component, helper) {
        return helper.apex(component, helper, "getGenderPicklistEntries")
            .then(
                (result) => {
                    component.set("v.genderOptions", result);
                }
            );
    },

    getGenerationalSuffixPicklistEntries : function(component, helper) {
        return helper.apex(component, helper, "getGenerationalSuffixPicklistEntries")
            .then(
                (result) => {
                    component.set("v.generationalSuffixOptions", result);
                }
            );
    },
})