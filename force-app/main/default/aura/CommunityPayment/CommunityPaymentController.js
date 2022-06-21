({
	doInit  : function(component, event, helper) {
		var parsedUrl = new URL(window.location.href);
		var serviceName = parsedUrl.searchParams.get("service");
		if (serviceName != null)
			component.set("v.service", serviceName);

		console.log(serviceName);
		var paymentMade = component.get("c.paymentMade");
    	paymentMade.setParams({	"service" : serviceName });
		paymentMade.setCallback(this, function(response){
		    console.log("Payment Made: " + response.getReturnValue());
		    component.set("v.pageReady", true);
			var state = response.getState();
			if(state === "SUCCESS"){
				var paymentStatus = response.getReturnValue();
				component.set("v.paymentMade", paymentStatus);
			}
			else if(state === "INCOMPLETE"){
			}
			else if(state === "ERROR"){
				var errors = response.getError();
				if (errors && errors[0] && errors[0].message) {
			        console.log("Error message: " + errors[0].message);
			    }
			}else{
				console.log("Unknown error");
		    }
		});
		$A.enqueueAction(paymentMade);

		var getCaseNumber = component.get("c.getCaseNumberForPayment");
		getCaseNumber.setParams({"serviceType" : serviceName });
		getCaseNumber.setCallback(this, function(response) {
			var state = response.getState();
			console.log(state)
			if(state === "SUCCESS"){
			    console.log(response.getReturnValue());
                console.log(response.getReturnValue()[0].CaseNumber);
                component.set("v.currentCaseNumber", response.getReturnValue()[0].CaseNumber);
				component.set("v.caseRecordId", response.getReturnValue()[0].Id);
			}
		});
	    $A.enqueueAction(getCaseNumber);
    },

	validate  : function(component, event, helper) {
        var inp = component.get("v.CVC");
        if(inp != undefined && inp.length > 3)
            component.set('v.inputN', inp.substring(0, 3));
    },
    
	processPayment  : function(component, event, helper) {			
    	var processPayment = component.get("c.makePayment");
		processPayment.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				component.set("v.paymentMade", true);
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
		$A.enqueueAction(processPayment);
    },
    
    handleNext : function(component, event, helper) {
    	window.open('/s/','_top');
    },
    
})