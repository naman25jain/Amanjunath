/**
 * Created by Matthew on 11/1/18.
 */
({

    doInit : function(component, event, helper) {

    },

    handleDeleteOnClick : function(component, event, helper) {
        console.log(component.get("v.associationType").Id);
        component.set("v.showConfirmDelete", true);
    },

    handleConfirmYesOnClick : function(component, event, helper) {
        component.set("v.showConfirmDelete", false);
        helper.deleteContactAssociationType(component, event, helper);
    },

    handleConfirmCancelOnClick : function(component, event, helper) {
        component.set("v.showConfirmDelete", false);
    },

})