({
	doInit  : function(component, event, helper) {
		var parsedUrl = new URL(window.location.href);
		var serviceName = parsedUrl.searchParams.get("service");
		component.set("v.service", serviceName);
    },
    
    handleNext : function(component, event, helper) {
    	window.open('/s/epictermsconditions?service=' + component.get("v.service"),'_top');
    },
    
    handlePrevious : function(component, event, helper) {
    	window.open('/s/medical-authorities?service=' + component.get("v.service"),'_top');
    },
})