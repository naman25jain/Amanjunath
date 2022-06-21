({

	handleClose : function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
	},

    handleActivate  : function(component, event, helper) {
		var contactId = component.get("v.recordId");
        component.set('v.disabledEntityUserBtn', true);
    	helper.apex(component, helper, "activateUserNew", {"contactId":contactId})
	    .then(
	        (result) => {
		        if(result == null) {
                    var toast = $A.get("e.force:showToast");
                    toast.setParams({
                        "title"   : "Success!",
                        "type"    : "success",
                        "message" : "The user has been activated!"
                     });
                    toast.fire();
                    window.location.reload();
                } else if (result.includes('ERROR')) {
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
			    // Verify it its already a portal user
				if(result.hasRelatedUser) {
					component.set('v.alreadyPortalUser', true);
					component.set("v.pageReady", true);
				} else {
				    // Logic for not a portal user
				   component.set("v.contactUserId", result.relatedUserId);
				   helper.apex(component, helper, "getContactById", {"contactId":contactId})
				   .then(
					  (res) => {
						 if((res && res.Account && res.Account.Owner && !res.Account.Owner.UserRoleId) || (res && !res.AccountId && result.currentUser.UserRoleId)){
						    component.set('v.accountOwnerWithNoRole', true);
						 } 
						 //checking missing info  
						 if(res.LastName == null || res.Email == null || ((res.legal_name_consists_of_one_name_only__c == false || res.legal_name_consists_of_one_name_only__c == null) && res.FirstName == null)){
							component.set("v.missingInfo", true);
						 }
						 component.set("v.contact", res);
					     component.set("v.pageReady", true);
				   });
				}
		});
	},
})