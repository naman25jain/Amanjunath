/**
 * Created by Matthew on 10/31/18.
 */
({
    doInit: function(component, event, helper) {
        helper.initialize(component, event, helper);
    },

    handleAssociationTypeDeletedEvent : function(component, event, helper) {
       $A.get("e.c:NotificationEvent").setParams({"successMessage" : component.get("v.recordNameSingular") + " has been removed." }).fire();
       helper.initialize(component, event, helper);
    },

    handleAssociationTypeAddedEvent : function(component, event, helper) {
       $A.get("e.c:NotificationEvent").setParams({"successMessage" : component.get("v.recordNameSingular") + " has been added." }).fire();
       helper.initialize(component, event, helper);
    },

    handleAssociationTypeStateEvent : function(component, event, helper) {
        if(event.getParam("source") && event.getParam("source").split(":") && event.getParam("source").split(":").length == 2 && event.getParam("source").split(":")[1] == component.get("v.associationRecordType")) {
            component.set("v.visible", event.getParam("visible"));
            // must re-initialize as records could have been changed with changed state (as when regulator orgs show/hide/delete cards via checkbox)
            helper.initialize(component, event, helper);
        }
    },

})