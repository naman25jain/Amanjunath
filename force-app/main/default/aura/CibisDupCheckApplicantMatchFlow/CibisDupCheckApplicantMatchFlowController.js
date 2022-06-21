({
    init : function(component, event, helper){
        helper.initialize(component, event, helper);
    },
    handleCandidateChosenEvent : function(component, event, helper){
        component.set("v.pageReady", false);
        window.setTimeout(
            $A.getCallback(function(){
                if(component.isValid()){
                    var contact = event.getParam("contact");                    
                    if(contact){
                        component.set("v.chosenContact", contact);
                        component.set("v.showChosenContact", true);
                        component.set("v.showExistingContact", false);
                        component.set("v.contactId", contact.CIBIS_USMLE_ID__c);
                        component.set("v.pageReady", true);
                    }
                }
                else{
                    $A.get("e.c:NotificationEvent").setParams({errorMessage: "An unexpected error has occurred."}).fire();
                }
            }), 500
        );
    },
    resetOnClick : function(component, event, helper){
        component.set("v.pageReady", false);
        $A.get('e.force:refreshView').fire();
    },
});