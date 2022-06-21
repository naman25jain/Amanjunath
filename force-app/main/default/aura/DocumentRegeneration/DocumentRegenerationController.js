({
    handleCloseQuickAction: function(component, event){
        let closeAction = $A.get("e.force:closeQuickAction");
        closeAction.fire();
    }
})