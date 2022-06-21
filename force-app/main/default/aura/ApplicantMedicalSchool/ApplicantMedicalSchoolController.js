/**
 * Created by Matthew on 10/31/18.
 */
({
    doInit: function(component, event, helper) {
        helper.initialize(component, event, helper);
    },

    handleSchoolDeletedEvent : function(component, event, helper) {
       $A.get("e.c:NotificationEvent").setParams({"successMessage" : "School has been removed." }).fire();
       helper.initialize(component, event, helper);
    },

    handleSchoolAddedEvent : function(component, event, helper) {
       $A.get("e.c:NotificationEvent").setParams({"successMessage" : "School has been added." }).fire();
       helper.initialize(component, event, helper);
    },
})