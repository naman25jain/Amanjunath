({
    doInit : function(component, event, helper) {
    	var flow = component.find("Community_Steps");
        var recId = component.get("v.recordId");
    	var inputVariables = [{ name : "recordId", type : "String", value: recId }];
    	flow.startFlow("Community_Steps", inputVariables);
    },

    change : function(component, event, helper) {
        component.set("v.cStatus", component.get("v.caseRecord.Internal_Status__c"));
    },
    
    statusChange : function(component, event, helper) {
        if(component.get("v.runOnce"))
			$A.get('e.force:refreshView').fire();
        else
            component.set("v.runOnce", true);
    },
    
    handleCaseRecordDataUpdated : function(component, event, helper) {
        component.set("v.cStatus", component.get(v.caseRecord.Internal_Status__c));
    }
})