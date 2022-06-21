({
    initialize : function(component, event, helper){
        component.set("v.showExistingContact", true);
        component.set("v.showChosenContact", false);
        component.set("v.chosenContact", null);
        var caseId = component.get("v.caseId");
		if(caseId){
            helper.getCase(component, helper)
                .then(
                    (result)=>{                      
                        component.set("v.case", result);
                        if(result && result.ContactId){
                            helper.getContact(component, helper, result.ContactId)
                                .then(
                                    (result)=>{
                                        component.set("v.existingContact", result);
                                        component.set("v.pageReady", true);
                                });
                            component.set("v.contactId", result.ContactId);
                        }
                        else{
                            $A.get("e.c:NotificationEvent").setParams({ errorMessage: "Could not find case or case does not have an associated contact." }).fire();
                            return;
                        }
                });
            helper.getCibisCandidateMatches(component, helper)
                .then(
                    (result)=>{
                        if(result && result.length && result.length > 0){
                            component.set("v.hasDuplicates", true);
                            component.set("v.flowHeaderText", component.get("v.dupesFoundHeaderText"));
                            var appEvent = $A.get("e.c:ApplicantMatchAE");
                            appEvent.setParam("showMatches", false);
                            appEvent.setParam("cibisDupMatch", false);
                            appEvent.fire();
                        }
                        else {
                            component.set("v.hasDuplicates", false);
                            component.set("v.flowHeaderText", component.get("v.dupesNotFoundHeaderText"));
                        }
                    }
                );
        }
        else {
            $A.get("e.c:NotificationEvent").setParams({ errorMessage : "Please provide a caseId." }).fire();
            return;
        }
    },
    getContact : function(component, helper, id){
		var params = {contactId: id};
        return helper.apex(component, helper, "getContact", params)
            .then(
                (result)=>{
                    return result;
            });
    },
    getCase : function(component, helper){
		var params = {caseId: component.get("v.caseId")};
        return helper.apex(component, helper, "getCase", params);
    },
    getCibisCandidateMatches : function(component, helper,caseId){
		var params = {caseId: component.get("v.caseId")};
        return helper.apex(component, helper, "cibisCandRequestEvent", params);
    },
});