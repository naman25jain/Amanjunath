({
    doInit  : function(component, event) {
        var action = component.get("c.checkOnOutcome");
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            var resultsToast = $A.get("e.force:showToast"); 
            if (component.isValid() && state === "SUCCESS" && response.getReturnValue()!== '') {
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();

                resultsToast.setParams({ 

                    "title": "Move eligibility period response: " , 
                    "type":'Error',
                    "message": response.getReturnValue()

                });
                resultsToast.fire();  
            }else{
                component.set("v.showModel",true);
                component.set("v.loading",false);
            }
              
        });
        $A.enqueueAction(action);
    },
    closeMethod : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})