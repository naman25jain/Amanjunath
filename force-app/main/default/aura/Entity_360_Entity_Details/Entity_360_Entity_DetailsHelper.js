({
    initialize : function (component, helper) {
        console.log("1");
        console.log(component.get("v.recordId"));
    	helper.apex(component, helper, "getAccount", {"recordId":component.get("v.recordId")})
	    .then(
	        (result) => {
	            console.log("2");
				console.log(result);
				component.set("v.account", result);
				component.set("v.pageReady", true);
	    });
    },
})