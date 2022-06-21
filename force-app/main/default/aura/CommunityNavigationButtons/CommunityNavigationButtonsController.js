/**
 * Created by Matthew on 11/8/18.
 */
({
    doInit: function(component, event, helper) {
        helper.handleUrlParams(component, event, helper);

        if(component.get("v.showBackToSummary") == false) {
            if(component.get("v.previousEnabledByDefault") == true) {
                component.find("previousButton").set("v.disabled", false);
            }
            if(component.get("v.nextEnabledByDefault") == true) {
                component.find("nextButton").set("v.disabled", false);
            }
        }
    },

    handlePrevious : function(component, event, helper) {
        // disable button on click
        event.getSource().set("v.disabled", true);
        // TODO: Make generic param handler, without hard-coding specific param(s).
        if(component.get("v.previousUrlForEPIC") && component.get("v.service") && component.get("v.service").toLowerCase() == "epic") {
			window.open(component.get("v.previousUrlForEPIC") + '?service=' + component.get("v.service"),'_top');            
        } else if(component.get("v.previousUrlForECFMGCert") && component.get("v.service") && component.get("v.service").toLowerCase() == "ecfmg_certification") {
			window.open(component.get("v.previousUrlForECFMGCert") + '?service=' + component.get("v.service"),'_top');
        } else if(component.get("v.previousUrlForGEMx") && component.get("v.service") && component.get("v.service").toLowerCase() == "gemx") {
			window.open(component.get("v.previousUrlForGEMx") + '?service=' + component.get("v.service"),'_top');
        } else {
			window.open(component.get("v.previousUrl") + '?service=' + component.get("v.service"),'_top');
        }                
    },

    handleNext : function(component, event, helper) {
        // disable button on click
        event.getSource().set("v.disabled", true);
        // TODO: Make generic param handler, without hard-coding specific param(s).
        if(component.get("v.nextUrlForEPIC") && component.get("v.service") && component.get("v.service").toLowerCase() == "epic") {
			window.open(component.get("v.nextUrlForEPIC") + '?service=' + component.get("v.service"),'_top');            
        } else if(component.get("v.nextUrlForECFMGCert") && component.get("v.service") && component.get("v.service").toLowerCase() == "ecfmg_certification") {
            window.open(component.get("v.nextUrlForECFMGCert") + '?service=' + component.get("v.service"),'_top');
        } else if(component.get("v.nextUrlForGEMx") && component.get("v.service") && component.get("v.service").toLowerCase() == "gemx") {
            window.open(component.get("v.nextUrlForGEMx") + '?service=' + component.get("v.service"),'_top');
        } else {
			window.open(component.get("v.nextUrl") + '?service=' + component.get("v.service"),'_top');
        }
    },
    
    handleBackToSummary : function(component, event, helper) {
		
        // TODO: Make generic param handler, without hard-coding specific param(s).
        if(component.get("v.summaryUrlEPIC") && component.get("v.service") && component.get("v.service").toLowerCase() == "epic") {
			window.open(component.get("v.summaryUrlEPIC") + '?service=' + component.get("v.service"),'_top');            
        } else if(component.get("v.summaryUrlCert") && component.get("v.service") && component.get("v.service").toLowerCase() == "ecfmg_certification") {
			window.open(component.get("v.summaryUrlEPIC") + '?service=' + component.get("v.service"),'_top');            
        } else if(component.get("v.summaryUrlGEMx") && component.get("v.service") && component.get("v.service").toLowerCase() == "gemx") {
			window.open(component.get("v.summaryUrlGEMx") + '?service=' + component.get("v.service"),'_top');            
        } else {
			window.open(component.get("v.summaryUrlOther") + '?service=' + component.get("v.service"),'_top');
        }
    },

    handleGenericValidationError : function(component, event, helper) {

        // get map
        var validationMap = component.get("v.validationMap");
        // update map with event data
        validationMap[event.getParam("source")] = event.getParam("isValid");
        // calculate isValid
        component.set("v.isValid", true);
        for(var key in validationMap) {
            if(validationMap[key] == false) {
                component.set("v.isValid", false);
                break;
            }
        }

        if( component.get("v.showBackToSummary") == false ) {

            // enable/disable button as appropriate
            if(component.get("v.allowPreviousWhenInvalid") == false && component.get("v.isValid") == false) {
                component.find("previousButton").set("v.disabled", true);
            } else {
                component.find("previousButton").set("v.disabled", false);
            }
            // enable/disable button as appropriate
            if(component.get("v.allowNextWhenInvalid") == false && component.get("v.isValid") == false) {
                component.find("nextButton").set("v.disabled", true);
            } else {
                component.find("nextButton").set("v.disabled", false);
            }

        }
        // enable/disable return to summary button as appropriate
        else if(component.get("v.isValid") == false) {
            component.find("backToSummaryButton").set("v.disabled", true);
        } else {
            component.find("backToSummaryButton").set("v.disabled", false);
        }

    },
})