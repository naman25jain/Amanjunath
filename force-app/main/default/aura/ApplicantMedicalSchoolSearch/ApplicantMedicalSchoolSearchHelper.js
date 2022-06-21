/**
 * Created by Matthew on 11/2/18.
 */
({
    initialize : function(component, event, helper) {
        // must get the running contact id in order to add a school
        helper.getRunningContactId(component, event, helper);
        //Load the Start Month picklist. Code added by Shailaja - User Story#7211. Date Format story.
        helper.getMonthPicklistEntries(component, helper);
    },

    initializeSchoolRecordCreator : function(component, event, helper) {
        //console.log('initializeSchoolRecordCreator');
        // prepare a new record from template
        component.find("schoolRecordCreator").getNewRecord(
            "Contact_Association_Type__c", // sObject type (objectApiName)
            component.get("v.associationRecordTypeId"),      // recordTypeId
            false,     // skip cache?
            $A.getCallback(function() {
                var rec = component.get("v.newSchoolRecord");
                var error = component.get("v.newSchoolError");
                if(error || (rec === null)) {
                    helper.handleError(error);
                    return;
                }
            })
        );
    },

    initializeAccountRecordCreator : function(component, event, helper) {
        // prepare a new record from template
        component.find("accountRecordCreator").getNewRecord(
            "Account", // sObject type (objectApiName)
            component.get("v.searchRecordTypeId"),      // recordTypeId
            false,     // skip cache?
            $A.getCallback(function() {
                var rec = component.get("v.newAccountRecord");
                var error = component.get("v.newAccountError");
                if(error || (rec === null)) {
                    helper.handleError(error);
                    return;
                }
            })
        );
    },

    getRunningContactId : function(component, event, helper) {
        // disable search control
        component.set("v.disabled", true);
        var action = component.get("c.getRunningContactId");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // TODO: enable the search feature, as it should be disabled until the contactId attribute is set
                component.set("v.contactId", response.getReturnValue());
                helper.initializeCurrentSchoolCount(component, event, helper);
            } else {
                helper.handleError(response);
            }
        });
        $A.enqueueAction(action);
    },
    
    getMonthPicklistEntries : function(component, helper) {
        return helper.apex(component, helper, "getMonthPicklistEntries")
            .then(
                (result) => {                    
                    component.set("v.monthOptions", result);
                }
            );
    },

    initializeCurrentSchoolCount : function(component, event, helper) {
        //console.log('entered initializeCurrentSchoolCount');
        // disable search control
        component.set("v.disabled", true);
        var action = component.get("c.getContactMedicalSchools");
        var contactId = component.get("v.contactId");
        action.setParams( {
            "contactId": contactId,
            "recordTypeName":  component.get("v.associationRecordType")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var schools = response.getReturnValue();
                component.set("v.currentSchoolCount", schools.length);
                var appEvent = $A.get("e.c:GenericValidationErrorAE");
                appEvent.setParam("source", "applicantMedicalSchoolSearch:" + component.get("v.associationRecordType"));
                if(schools.length < component.get("v.maximumSchools") && schools.length > component.get("v.minimumSchools")) {
                    // enable search control
                    component.set("v.disabled", false);
                    // state is valid
                    appEvent.setParam("isValid", true);
                } else if(schools.length == component.get("v.maximumSchools") && schools.length == component.get("v.minimumSchools")) {
                    // disable search control
                    component.set("v.disabled", true);
                    // state is valid
                    appEvent.setParam("isValid", true);
                } else {
                    // disable search control
                    component.set("v.disabled", false);
                    // state is valid
                    appEvent.setParam("isValid", false);
                }
                appEvent.fire();


            } else {
                helper.handleError(response);
            }
        });
        $A.enqueueAction(action);
    },

    addSchool : function(component, event, helper) {
        // disable search control
        component.set("v.disabled", true);
        var newSchoolFields = component.get("v.newSchoolFields");
        newSchoolFields.Account__c = component.get("v.accountId");
        newSchoolFields.Contact__c = component.get("v.contactId");
        component.set("v.newSchoolFields", newSchoolFields);
        component.find("schoolRecordCreator").saveRecord(function(saveResult) {
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                $A.get("e.c:ApplicantMedicalSchoolAddedAE").fire();
                component.set("v.showAddDialog", false);
                component.set("v.showSubmitDialog", false);
                helper.initializeCurrentSchoolCount(component, event, helper);
            } else {
                helper.handleError(saveResult);
            }
        });
    },

    submitSchool : function(component, event, helper) {
        component.find("accountRecordCreator").saveRecord(function(saveResult) {
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                component.set("v.accountId", saveResult.recordId);
                helper.addSchool(component, event, helper);
            } else {
                helper.handleError(saveResult);
            }
        });
    },

    /*
        This generic error handler accepts a string, a server response (as returned by an Apex call) or a result, as returned
        by a force:recordData call. Shows first error message in collection if any, or default error message.
    */
    handleError : function(errorStringOrObject) {
        var errorMessage = "Sorry, an unknown error has occurred. Please contact Customer Service.";
        if(typeof errorStringOrObject == "string") {
            errorMessage = errorStringOrObject;
        } else if(errorStringOrObject.getError) {
            // this is an error from an apex call
            var errors = errorStringOrObject.getError();
            if (errors[0] && errors[0].message) {
                errorMessage = errors[0].message;
            }
        } else if(errorStringOrObject.error) {
            // this is an error from a force:recordData call
            errorMessage = errorStringOrObject.error
        }
        $A.get("e.c:NotificationEvent").setParams({"errorMessage" : errorMessage }).fire();
    },

    /*
        This will search all components having the same id and return the first one maching the name specified.
    */
    findComponentByName : function(id, name, component)  {
        var cmps = component.find(id);
        for(var i = 0; i < cmps.length; i++) {
            if(cmps[i].get("v.name") == name) {
                return cmps[i];
            }
        }
    },

})