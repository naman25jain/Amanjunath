({
	doInit  : function(component, event, helper) {
    	helper.initialize(component, helper)
	},
	
	redirectInfoChange  : function(component, event, helper){
		var restrictionExists = component.get("v.restrictionOnContact");
		if(restrictionExists){
    	var toastEvent = $A.get("e.force:showToast");
    	toastEvent.setParams({
       		type : 'error',
        	title : 'Restriction Applied',
   			message: 'You are currently restricted from accessing this service.  If you have any questions please contact ECFMG.'
    	});
    	toastEvent.fire();
		}
		else{
		var action = component.get("c.createAppBioPendingSubCase");
        $A.enqueueAction(action);
		window.open('/s/my-profile-identity-information-change','_top');
		}
	},
})