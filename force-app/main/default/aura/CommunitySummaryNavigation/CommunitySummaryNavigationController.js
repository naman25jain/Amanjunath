({
	doInit : function(component, event, helper) {
        var curURL = new URL(window.location.href);
        var serviceName = curURL.searchParams.get("service");
		var getCaseInfo = component.get("c.getLatestCase");
		getCaseInfo.setParams({"service" : serviceName});
		getCaseInfo.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var caseList = response.getReturnValue();
				console.log(caseList);
				if(caseList.length > 0) {
					var cse = caseList[0];
					if(!cse.ValidationPassed_Biographics__c || !cse.ValidationPassed_AdditionalInformation__c)
						component.set("v.validationError", true);
				}
			}
		});
		$A.enqueueAction(getCaseInfo);
	}
})