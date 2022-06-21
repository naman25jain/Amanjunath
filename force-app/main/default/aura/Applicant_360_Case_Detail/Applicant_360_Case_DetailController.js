({
	doInit  : function(component, event, helper) {
    	helper.initialize(component, helper);
	},
    
    handleCancelModal  : function(component, event, helper) {
        component.set("v.showCancelModal", true);
    },
	
	handleCancel : function(component, event, helper) {
    	helper.cancelCase(component, helper);
	},
    
	handleBack : function(component, event, helper) {
    	component.set("v.showCancelModal", false);
	},

	handleDownloadClick : function(component, event, helper) {
		helper.downloadFileContent(component,event);
	},
	
	handleEpermitDownloadClick : function(component, event, helper) {
		helper.downloadEPermitFileContent(component,event);
	},
	handleBackCaseList : function(component, event, helper) {
		var address = '/s/my-cases';
		var urlEvent = $A.get("e.force:navigateToURL");
		urlEvent.setParams({
		  "url": address,
		  "isredirect" :false
		});
		urlEvent.fire();
	}
})