({
    doInit : function(component, event, helper) {
    	var flow = component.find("Case_Flow_Dispatcher");
        var recId = component.get("v.recordId");
    	var inputVariables = [{ name : "recordId", type : "String", value: recId }];
    	flow.startFlow("Case_Flow_Dispatcher", inputVariables);
    },
    
    statusChange : function(component, event, helper) {
		$A.get('e.force:refreshView').fire();
    },
    
    handleClickNotValidated : function(component, event, helper) {
    	var runningUser = component.get("v.runningUser");
    	component.set("v.showModal", true);
    	var flow = component.find("Case_Flow_Dispatcher");
        var recId = component.get("v.recordId");
    	var inputVariables = [{ name : "recordId", type : "String", value: recId }];
    	flow.startFlow("Case_Flow_Dispatcher", inputVariables);
    },
})