({
    doInit : function(component, event, helper) {
    	var recId = component.get("v.recordId");
	    var getIDs = component.get("c.getCaseFileIds");
	    getIDs.setParams({caseId : recId});
	    getIDs.setCallback(this, function(response) {
	        var state = response.getState();
	        if (state === "SUCCESS") {
	        	var fileL = response.getReturnValue();
	        	console.log("CD IDs: " + fileL);
	        	component.set("v.fileList", fileL);
	        }
	    });
	    $A.enqueueAction(getIDs);
    },
    
	openMultipleFiles: function(component, event, helper) {
		var fileL = component.get("v.fileList");
		$A.get('e.lightning:openFiles').fire({
			    recordIds: [fileL[0], fileL[1]], 
			    selectedRecordId: fileL[0]
		});
	}
})