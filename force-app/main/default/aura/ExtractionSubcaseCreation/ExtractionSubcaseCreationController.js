({
	insertsubCase: function(component, event, helper){
		var action = component.get("c.subcaseInsert");
		action.setParams({
			recordId:component.get("v.recordId")
		});
		action.setCallback(this, function(a){
			var state = a.getState();
			var toastType = null;
			var toastmsg = null;
			$A.get("e.force:closeQuickAction").fire()
			$A.get("e.force:refreshView").fire();
			if(state === "SUCCESS"){
				toastType = "success";
				toastmsg = "The Sub-case has been Created successfully";
			}else{
				toastType = "Error";
				toastmsg = "The Sub-Case Craetion Failed";
			}
			var toastEvent = $A.get("e.force:showToast");
			toastEvent.setParams({
			type : toastType,
			title: toastType,
			message: toastmsg
			})
			toastEvent.fire();
			});
			$A.enqueueAction(action)
	},
})