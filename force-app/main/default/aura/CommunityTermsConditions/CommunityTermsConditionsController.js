({
	doInit : function(component, event, helper) {
		var parsedUrl = new URL(window.location.href);
		var serviceName = parsedUrl.searchParams.get("service");
		component.set("v.service", serviceName);
		
    	var termsAccepted = component.get("c.getTerms");
    	termsAccepted.setParams({"service": component.get("v.service")});
		termsAccepted.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var isAccepted = response.getReturnValue();
				component.set("v.isAccepted", isAccepted);
				component.set("v.TC_1", isAccepted);
				component.set("v.TC_2", isAccepted);
				component.set("v.TC_3", isAccepted);
				component.set("v.TC_4", isAccepted);
				component.set("v.TC_5", isAccepted);
			}
			else if (state === "INCOMPLETE") {
			}
			else if (state === "ERROR") {
				var errors = response.getError();
				if (errors && errors[0] && errors[0].message) {
			        console.log("Error message: " + errors[0].message);
			    }
			} else {
				console.log("Unknown error");
		    }
		});
		$A.enqueueAction(termsAccepted);
	},
    
    gotoPayment : function(component, event, helper) {
    	var isAccepted = component.get("v.isAccepted");
    	if(!isAccepted) {
	    	var termsAccepted = component.get("c.addAgreement");
	    	termsAccepted.setParams({"service" : component.get("v.service")});
			termsAccepted.setCallback(this, function(response) {
				var state = response.getState();
				if (state === "SUCCESS") {
					var agreementAdded = response.getReturnValue();
					component.set("v.isAccepted", agreementAdded);
					if(agreementAdded == true) {
						window.open('/s/epicpayment' + '?service=' + component.get("v.service"),'_top');
					}
				}
				else if (state === "INCOMPLETE") {
				}
				else if (state === "ERROR") {
					var errors = response.getError();
					if (errors && errors[0] && errors[0].message) {
				        console.log("Error message: " + errors[0].message);
				    }
				} else {
					console.log("Unknown error");
			    }
			});
			$A.enqueueAction(termsAccepted);
    	} else {
    		window.open('/s/epicpayment?service=' + component.get("v.service"),'_top');
    	}
    },
    
    gotoPrev : function(component, event, helper) {
        // TODO: Make generic param handler, without hard-coding specific param(s).
        if(component.get("v.service") && component.get("v.service").toLowerCase() == "epic") {
			window.open(helper.constants.SERVICE_EPIC_REVIEW_URL + '?service=' + component.get("v.service"),'_top');
        } else if(component.get("v.service")) {
            window.open(helper.constants.COMMON_REVIEW_URL + '?service=' + component.get("v.service"),'_top');
        }
        else {
			window.open(helper.constants.COMMON_REVIEW_URL,'_top');
        }

    },
})