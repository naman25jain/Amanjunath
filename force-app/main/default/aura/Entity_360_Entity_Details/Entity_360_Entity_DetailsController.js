({
	doInit  : function(component, event, helper) {
    	helper.initialize(component, helper);
	},

    handleChangeModal  : function(component, event, helper) {
        component.set("v.showChangeModal", true);
    },

	handleChange : function(component, event, helper) {
        component.set("v.pageReady", false);
        var recId = component.get("v.recordId");
        console.log(recId);
        helper.apex(component, helper, "createEntityInfoChangeCase", {"entityId":component.get("v.recordId"), "description":component.get("v.details")}).then(function(response) {
            if (response != null){
                var toast = $A.get("e.force:showToast");
                toast.setParams({
                    "title"   : "Success!",
                    "type"    : "success",
                    "message" : "Your request has been submitted!"
                 });
                toast.fire();
                component.set("v.details", "");
                component.set("v.showChangeModal", false);
                component.set("v.pageReady", true);
            }
        });
	},

	handleBack : function(component, event, helper) {
	    component.set("v.details", "");
    	component.set("v.showChangeModal", false);
	},
})