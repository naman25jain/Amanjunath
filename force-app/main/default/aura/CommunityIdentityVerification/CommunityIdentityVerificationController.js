({
    doInit : function(component, event, helper) {
        var displayLabel = component.get("c.getDisplayLabel");
		displayLabel.setParams({ recId : component.get("v.recordId")});
		displayLabel.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				component.set("v.displayLabel", response.getReturnValue());
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
		$A.enqueueAction(displayLabel);
    
    	var idVer = component.get("c.checkIdentityVerification");
		//idVer.setParams({ caseId : caseRecord});
		idVer.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var completedIdCheck = response.getReturnValue();
				console.log("ID CHECK: " + completedIdCheck);
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
		
    	var getUser = component.get("c.getRunningUserId");
		getUser.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				component.set("v.runningUser", response.getReturnValue());
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
		$A.enqueueAction(getUser);
    },
    
    handleClickValidated : function(component, event, helper) {
    
    },
    
    handleClickNotValidated : function(component, event, helper) {
    	var runningUser = component.get("v.runningUser");
    	component.set("v.showModal", true);
    	var flow = component.find("Identity_Verification_Wizard");
    	var inputVariables = [{ name : "User_Id", type : "String", value: runningUser }];
    	flow.startFlow("Identity_Verification_Wizard", inputVariables);
    },
    
    closeModal : function(component, event, helper) {
    	window.open('https://devint-ecfmg.cs66.force.com/s/','_top')
    	//component.set("v.showModal", false);
    },
})