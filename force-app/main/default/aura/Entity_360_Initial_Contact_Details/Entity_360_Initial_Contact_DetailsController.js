({
    doInit : function(component, event, helper){
        //Code commented as part of user story#916
   },

    handleSaveOnClick : function(component, event, helper){
        helper.save(component, helper);
    },
    
    handleCancelOnClick : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
    },
    
    certifyOnChange : function(component, event, helper) {
        var certifyCheckbox = event.getSource();
        if(certifyCheckbox.get("v.checked") == true) {
            component.find("saveButton").set("v.disabled", false);
        } else {
			component.find("saveButton").set("v.disabled", true);
        }
    },      
    handleBirthCountryOnChange : function(component, event, helper) {
        var bCountry = event.getParam("value");
        console.log('bCountry is '+bCountry);
        component.set("v.contact.Birth_Country__c", bCountry);
    },
    oneNameOnlyOnChange : function(component, event, helper) {
        var oneNameOnlyCheckbox = event.getSource();
        if(oneNameOnlyCheckbox.get("v.checked") == true) {
            //Bug fix #13587. Do not set the First name to null.
            component.set("v.contact.FirstName", "");
        }
    }, 
    
})