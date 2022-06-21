/**
 * Created by Matthew on 2019-08-14.
 */

({
    init : function(component, event, helper) {
        helper.initialize(component, event, helper);
    },

    /*
        This method handles the applicant chosen event from primary component.
        Includes a fake wait event to help the user see (via spinner) that something changed.
    */
    handleApplicantChosenEvent : function(component, event, helper) {
	    // show spinner
        component.set("v.pageReady", false);
        window.setTimeout(
            $A.getCallback(function() {
                if(component.isValid()){
                    var contact = event.getParam("contact");
                    if(contact) {
                        component.set("v.chosenContact", contact);
                        component.set("v.showChosenContact", true);
                        component.set("v.showExistingContact", false);
                        // set the output contact id
                        component.set("v.contactId", contact.Id);
                        // hide spinner
                        component.set("v.pageReady", true);
                    }
                }
                else{
                    $A.get("e.c:NotificationEvent").setParams({ errorMessage: "An unexpected error has occurred." }).fire();
                }
            }), 500
        );
    },

    resetOnClick : function(component, event, helper) {
	    // show spinner
        component.set("v.pageReady", false);
        // fire refresh view event
        $A.get('e.force:refreshView').fire();
    },

});