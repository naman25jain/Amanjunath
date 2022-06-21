({
    doInit: function(component, event, helper) {
        helper.initialize(component, helper);
    },

    emailChange: function(component, event, helper) {
        var initialEmail = component.get("v.initialEmail");
        var newEmail = component.get("v.newEmail");
        var confirmEmail = component.get("v.confirmEmail");
        var format = /\S+@\S+\.\S+/.test(newEmail);
        
        if (initialEmail != newEmail) {
        	component.set("v.duplicate", false);
            component.set("v.showConfirmEmail", true);
        } else {
            component.set("v.showConfirmEmail", false);
        }
        component.set("v.emailFormatValid", format);
        
        if (confirmEmail != newEmail) { 
            component.set("v.validConfirmEmail", false);
        } else {
            component.set("v.validConfirmEmail", true);
        }
    },

    confirmEmailChange: function(component, event, helper) {
        var initialEmail = component.get("v.initialEmail");
        var newEmail = component.get("v.newEmail");
        var confirmEmail = component.get("v.confirmEmail");

        if (confirmEmail != newEmail) { 
            component.set("v.validConfirmEmail", false);
        } else {
            component.set("v.validConfirmEmail", true);
        }
    },
 
     handleChange : function(component, event, helper) {
        component.set("v.hasChanges", true);
    },
 
    
	handlePaste: function(component, event, helper) {
	    event.preventDefault(); 
	},
	
	handleContext: function(component, event, helper) {
	    event.preventDefault(); 
	},
	
	handleSave: function(component, event, helper) {
		var contactData = component.get("v.contact");
		contactData.Phone = component.get("v.phoneNumber");
		contactData.Phone_Type__c = component.get("v.phoneType");
	    if (component.get("v.showConfirmEmail") && component.get("v.validConfirmEmail")) {
	    	helper.updateContactInfoWithEmail(component, helper, contactData, component.get("v.newEmail"));
	    }  else {
	    	helper.updateContactInfo(component, helper, contactData);
	    }
	},
	
	handleCancel : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
	},
})