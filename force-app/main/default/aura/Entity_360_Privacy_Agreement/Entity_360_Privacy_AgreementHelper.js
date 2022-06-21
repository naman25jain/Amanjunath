({
    submitTCs : function(component, helper){
         component.set("v.pageReady", false);
            	helper.apex(component, helper, "addPrivacy", {"privacyAgreement": component.get("v.privacyAgreementName")}).then(function(response) {
        				if (response == true){
                            var toast = $A.get("e.force:showToast");
                                    /*
                                    toast.setParams({
                                        "title"   : "Success!",
                                        "type"    : "success",
                                        "message" : "Your Updates Have Been Saved!"
                                    }); */
                            toast.fire();
        				    component.set("v.privacyAgreementAccepted", true);
                         }
                });
    }
})