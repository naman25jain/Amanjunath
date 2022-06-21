({
    doInit : function(component, event, helper) {    
    	var idVer = component.get("c.checkIdentityVerification");
		idVer.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var completedIdCheck = response.getReturnValue();
				component.set("v.completedIdentityVerification", completedIdCheck);
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
		$A.enqueueAction(idVer);
	}
})