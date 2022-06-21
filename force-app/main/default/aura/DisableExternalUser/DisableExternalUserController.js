({
	handleClose : function(component, event, helper) {
      var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
	},

    handleInactivate  : function(component, event, helper) {
        var contactId = component.get("v.recordId");
    	helper.apex(component, helper, "disableUser", {"contactId":contactId, "details":component.get("v.details")})
	    .then(
	        (result) => {
	            if(result == "Success") {
                    var toast = $A.get("e.force:showToast");
                    toast.setParams({
                        "title"   : "Success!",
                        "type"    : "success",
                        "message" : "Your request has been submitted!"
                     });
                    toast.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                    window.location.reload();
                } else {
                    var toast = $A.get("e.force:showToast");
                    toast.setParams({
                        "title"   : "Error!",
                        "type"    : "error",
                        "message" : result
                     });
                    toast.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                }
	    });
    },

	doInit  : function(component, event, helper) {
	    component.set("v.pageReady", false);
	    var contactId = component.get("v.recordId");
    	helper.apex(component, helper, "getUserInfo", {"contactId":contactId})
	    .then(
	        (result) => {
                //Portal user
                if(result.hasRelatedUser) {
                    component.set("v.contactUserId", result.relatedUserId);
                }else{
                    //user is already disbaled
                    component.set("v.isValid", false);
                }
                component.set("v.pageReady", true);
	    });
	},
})