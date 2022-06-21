({
	doInit: function(component, event, helper) {
        helper.handleUrlParams(component, event, helper);
    },
    
	handleEditOnClick : function(component, event, helper) {
		window.open(component.get("v.editUrl") + '?mode=summary&service=' + component.get("v.service"),'_top');
	}
})