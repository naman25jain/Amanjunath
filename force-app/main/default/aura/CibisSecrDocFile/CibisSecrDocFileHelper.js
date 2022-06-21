({
	initialize : function (component, event, helper) {
        var action = component.get("c.getSecrDocAzureUrl");
		action.setParams({contactId: component.get("v.recordId")});
        action.setCallback(this, function(a) {
            var pageReference = {
                type: 'standard__webPage',
                attributes: {
                    "url": a.getReturnValue()
                }
            };
            component.set("v.pageReference", pageReference);
            const navService = component.find('navService');
            const pageRef = component.get('v.pageReference');
            const handleUrl = (url) => {
                window.open(url);
            };
            const handleError = (error) => {
                console.log(error);
            };
            navService.generateUrl(pageRef).then(handleUrl, handleError);
            $A.get("e.force:closeQuickAction").fire();
        });
        $A.enqueueAction(action);
    }
})