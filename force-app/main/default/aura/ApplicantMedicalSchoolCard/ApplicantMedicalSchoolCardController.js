/**
 * Created by Matthew on 11/1/18.
 */
({

    handleDeleteOnClick : function(component, event, helper) {
        console.log(component.get("v.school").Id);
        component.set("v.showConfirmDelete", true);
    },

    handleConfirmYesOnClick : function(component, event, helper) {
        component.set("v.showConfirmDelete", false);
        helper.deleteContactMedicalSchool(component, event, helper);
    },

    handleConfirmCancelOnClick : function(component, event, helper) {
        component.set("v.showConfirmDelete", false);
    },
})