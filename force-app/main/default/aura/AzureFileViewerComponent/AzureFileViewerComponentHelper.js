({
	initialize : function (component, event, helper) {
        var objectName = component.get("v.sObjectName");
        var action = '';
        if(objectName == 'Case'){
            action = component.get("c.getDocumentUrl");
        }else{
            action = component.get("c.getAzureUrl");
        }        
		action.setParams({recId: component.get("v.recordId")});
        action.setCallback(this, function(a){
            var stateStatus = a.getState();
            if(stateStatus === "SUCCESS"){
                try{
                    var returnURL = a.getReturnValue();
                    if(returnURL != ''){
                        var pageReference = {
                            type: 'standard__webPage',
                            attributes: {
                                "url": returnURL
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
                    }else{
                        var errMessage = 'No Image URL Available';
                        helper.showError(component, errMessage, helper);
                        $A.get("e.force:closeQuickAction").fire();
                    }
                }catch(e){
                    helper.showError(component, e.message, helper);
                    $A.get("e.force:closeQuickAction").fire();
                }
            }else{
                helper.handleErrors(component, a);
            }
        });
        $A.enqueueAction(action); 
	},
    showError : function(component, message, helper){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error',
            message: message,
            duration:' 10000',
            key: 'info_alt',
            type: 'error',
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
    // Handling Errors
    handleErrors: function(component, response){
        var errors = response.getError();
        if(errors){
            if(errors[0] && errors[0].message){
                helper.showError(component, errors[0].message, helper);
            }
        }else{
            helper.showError(component, 'Unknown Error', helper);
        }
        helper.showError(component, e.message, helper);
        $A.get("e.force:closeQuickAction").fire();
    }
})