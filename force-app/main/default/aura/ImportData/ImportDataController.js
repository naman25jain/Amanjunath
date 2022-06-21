({
    confirm : function(component, event) {
        var action = component.get("c.releaseScore");
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            var resultsToast = $A.get("e.force:showToast"); 
            if (component.isValid() && state === "SUCCESS") {
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();

                resultsToast.setParams({ 

                    "title": "Score Release Response: " , 

                    "message": response.getReturnValue()

                });
                
            }else {

                resultsToast.setParams({ 

                    "title": "Score Release Response: " , 

                    "message": "Score Release Failed"

                }); 

            }
            resultsToast.fire();  
        });
        $A.enqueueAction(action);
    }
})