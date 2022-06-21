({
	doInit  : function(component, event, helper) {
	    component.set("v.pageReady", false);
    	helper.initialize(component, helper);
	},

	handlePost  : function(component, event, helper) {

        //debugger;
	    var button = event.getSource();
	    button.set("v.disabled", true);

        var recId = component.get("v.recordId");
    	console.log(component.get("v.messageValue"));
    	var msg = component.get("v.messageValue");
    	//msg = msg.replace(/<img[^>]*>/g,"");
    	if (recId != null) {
            helper.apex(component, helper, "postChatter", {"parentId":recId, "msg":msg})
            .then(
                (result) => {
                    component.set("v.messageValue", "");
                    console.log(result);
                    //component.set("v.postButtonDisabled", false);
                    if(result == 'Success') helper.initialize(component,helper);
            });
         }
	},

	messageValueOnChange : function(component, event, helper) {
        // if field has value and not just white space, enable post button
	    if(component.get("v.messageValue") && component.get("v.messageValue").replace("<p>", "").replace("</p>", "").trim()) {
	        component.set("v.postButtonDisabled", false);
        }
        else {
            component.set("v.postButtonDisabled", true);
        }
    },

})