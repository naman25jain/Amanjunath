/**
 * Created by Matthew on 11/2/18.
 */
({
    initialize: function(component, event, helper){
        component.set("v.recordNameSingularLower", component.get("v.recordNameSingular").toLowerCase());
        component.set("v.recordNamePluralLower", component.get("v.recordNamePlural").toLowerCase());
        //Load the Start Month picklist
        helper.getMonthPicklistEntries(component, helper);
        // start with component being disabled
        component.set("v.disabled", true);
        //bniraula 3/17/2020: Remove hardcoded value - Set proper id for account and contact association type record
        const CONASCTYPE_RECTYPE_DEGREE_MED_SCHOOL = 'Degree Medical School';
        const ACC_RECTYPE_UNAPPROVED_MEDICAL_SCHOOL = 'Unapproved Medical School';
        const ACCOUNT_RECORD_TYPE_UNAPPROVED_ENTITY = 'Unapproved New Entity'
        const CONASCTYPE_RECORD_TYPE_REGULATORY_ORGANIZATION = 'Regulatory Organization';
        var accRecTypeMap = [];
        var contAsscRecTypeMap = [];
        accRecTypeMap = helper.apex(component, helper, "GetAccountRecordTypes");
        contAsscRecTypeMap = helper.apex(component, helper, "getContactAssociationRecordTypes");
        accRecTypeMap.then(function(accRecResult){
            contAsscRecTypeMap.then(function(conAsscRecResult){
                var asscRecType = component.get("v.associationRecordType");
                var searchRecType = component.get("v.searchRecordType");
                var conAsscRecType = component.get("v.associationRecordType");
                if(conAsscRecType.toString() == CONASCTYPE_RECTYPE_DEGREE_MED_SCHOOL){
                    asscRecType = ACC_RECTYPE_UNAPPROVED_MEDICAL_SCHOOL;
                }
                else if(asscRecType == CONASCTYPE_RECORD_TYPE_REGULATORY_ORGANIZATION){
                    asscRecType = ACCOUNT_RECORD_TYPE_UNAPPROVED_ENTITY;
                }
                component.set("v.associationRecordTypeId", conAsscRecResult[conAsscRecType]);
                component.set("v.searchRecordTypeId", accRecResult[searchRecType]);
                component.set("v.submittedAccountRecordTypeId", accRecResult[asscRecType]);
            })
        })   //bniraula - hardcoded values fixes end 
        // first promise is to get contact is
        helper.apex(component, helper, "getRunningContactId", null)
            .then(function(result){
                // set the contact id to running user contact id
                component.set("v.contactId", result);
                // initialize current association type count
                return helper.apex(
                    component,
                    helper,
                    "getContactAssociationTypes",
                    {
                        "contactId": component.get("v.contactId"),
                        "recordTypeName": component.get("v.associationRecordType")
                    }
                );
            })
            .then(function(result){
                // result returns association types
                var associationTypes = result;
                component.set("v.currentAssociationTypeCount", associationTypes.length);
                var appEvent = $A.get("e.c:GenericValidationErrorAE");
                appEvent.setParam("source", "associationTypeSearch:" + component.get("v.associationRecordType"));
                // have to handle situation differently (and first) when min/max is 1
                if((associationTypes.length == component.get("v.minimumAssociationTypes") && associationTypes.length == component.get("v.maximumAssociationTypes"))||(associationTypes.length == component.get("v.maximumAssociationTypes"))){ // count is equal to min and max (handles just 1 is required scenario)
                    // disable search control
                    component.set("v.disabled", true);
                    // state is valid
                    appEvent.setParam("isValid", true);
                }else if(associationTypes.length >= component.get("v.minimumAssociationTypes") && associationTypes.length <= component.get("v.maximumAssociationTypes")) { // count is between min and max
                    // enable search control
                    component.set("v.disabled", false);
                    // state is valid
                    appEvent.setParam("isValid", true);
                }else{
                    // enable search control
                    component.set("v.disabled", false);
                    // state is valid
                    appEvent.setParam("isValid", false);
                }
                appEvent.fire();
            });
    },    
    constants: {
        'CONASCTYPE_START_END_DAY': '01'
    },

    getMonthPicklistEntries : function(component, helper) {
        return helper.apex(component, helper, "getMonthPicklistEntries")
            .then(
                (result) => {                    
                    component.set("v.monthOptions", result);
                }
            );
    },
    initializeCurrentAssociationTypeCount: function (component, event, helper) {
        // disable search control
        component.set("v.disabled", true);
        var action = component.get("c.getContactAssociationTypes");
        var contactId = component.get("v.contactId");
        action.setParams({
            "contactId": contactId,
            "recordTypeName": component.get("v.associationRecordType")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var associationTypes = response.getReturnValue();
                component.set("v.currentAssociationTypeCount", associationTypes.length);
                var appEvent = $A.get("e.c:GenericValidationErrorAE");
                appEvent.setParam("source", "associationTypeSearch:" + component.get("v.associationRecordType"));
                // have to handle situation differently (and first) when min/max is 1
                if (associationTypes.length == component.get("v.minimumAssociationTypes") && associationTypes.length == component.get("v.maximumAssociationTypes")) { // count is equal to min and max (handles just 1 is required scenario)
                    // disable search control
                    component.set("v.disabled", true);
                    // state is valid
                    appEvent.setParam("isValid", true);
                } else if (associationTypes.length == component.get("v.maximumAssociationTypes")) {
                    // disable search control
                    component.set("v.disabled", true);
                    // state is valid
                    appEvent.setParam("isValid", true);
                } else if (associationTypes.length >= component.get("v.minimumAssociationTypes") && associationTypes.length <= component.get("v.maximumAssociationTypes")) { // count is between min and max
                    // enable search control
                    component.set("v.disabled", false);
                    // state is valid
                    appEvent.setParam("isValid", true);
                } else {
                    // enable search control
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

    initializeAssociationTypeRecordCreator: function (component, event, helper) {
        console.log('initializeAssociationTypeRecordCreator');

        // prepare a new record from template
        component.find("associationTypeRecordCreator").getNewRecord(
            "Contact_Association_Type__c", // sObject type (objectApiName)
            component.get("v.associationRecordTypeId"),      // recordTypeId
            false,     // skip cache?
            $A.getCallback(function () {
                var rec = component.get("v.newAssociationTypeRecord");                
                var error = component.get("v.newAssociationTypeError");
                if (error || (rec === null)) {
                    helper.handleError(error);
                    return;
                }
            })
        );
    },

    initializeAccountRecordCreator: function (component, event, helper) {
        console.log('initializeAccountRecordCreator');
        // prepare a new record from template
        component.find("accountRecordCreator").getNewRecord(
            "Account", // sObject type (objectApiName)
            component.get("v.submittedAccountRecordTypeId"),      // recordTypeId
            false,     // skip cache?
            $A.getCallback(function () {
                var rec = component.get("v.newAccountRecord");
                var error = component.get("v.newAccountError");
                if (error || (rec === null)) {
                    helper.handleError(error);
                    return;
                }
            })
        );
    },

    /*
        This method handles adding an existing account to a new association type.
    */
    addExisting: function (component, event, helper) {
        // disable search control
        component.set("v.disabled", true);
        var newAssociationTypeFields = component.get("v.newAssociationTypeFields");
        newAssociationTypeFields.Account__c = component.get("v.accountId");
        newAssociationTypeFields.Contact__c = component.get("v.contactId");
        component.set("v.newAssociationTypeFields", newAssociationTypeFields);
        component.find("associationTypeRecordCreator").saveRecord(function (saveResult) {
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                $A.get("e.c:ContactAssociationTypeAddedAE").fire();
                component.set("v.showAddDialog", false);
                component.set("v.showSubmitDialog", false);
                // enable add and submit buttons
                if (component.find("addButton")) component.find("addButton").set("v.disabled", false);
                if (component.find("submitButton")) component.find("submitButton").set("v.disabled", false);
                helper.initializeCurrentAssociationTypeCount(component, event, helper);
            } else {
                helper.handleError(saveResult);
            }
        });
    },

    /*
        This method handles submitting a new account and creating an association type at the same time.
        Defers the creation of association type to the addExisting method.
    */
    submitNew: function (component, event, helper) {
        component.find("accountRecordCreator").saveRecord(function (saveResult) {
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                component.set("v.accountId", saveResult.recordId);
                helper.addExisting(component, event, helper);
            } else {
                // enable submit button
                component.find("submitButton").set("v.disabled", false);
                helper.handleError(saveResult);
            }
        });
    },

    /*
        This will search all components having the same id and return the first one matching the name specified.
    */
    findComponentByName: function (id, name, component) {
        var cmps = component.find(id);        
        for (var i = 0; i < cmps.length; i++) {
            if (cmps[i].get("v.name") == name) {                
                return cmps[i];
            }
        }
    },

    apex: function (component, helper, apexAction, params) {
        var p = new Promise($A.getCallback(function (resolve, reject) {
            var action = component.get("c." + apexAction + "");            
            if (params) action.setParams(params);
            action.setCallback(this, function (callbackResult) {
                if (callbackResult.getState() == "SUCCESS") {
                    resolve(callbackResult.getReturnValue());
                }
                else {
                    helper.handleError(callbackResult);
                    reject(callbackResult);
                }
            });
            $A.enqueueAction(action);
        }));
        return p;
    },
    
    /*
        This generic error handler accepts a string, a server response (as returned by an Apex call) or a result, as returned
        by a force:recordData call. Shows first error message in collection if any, or default error message.
    */
    handleError: function (errorStringOrObject) {
        var errorMessage = "Sorry, an unknown error has occurred. Please contact Customer Service.";
        if (typeof errorStringOrObject == "string") {
            errorMessage = errorStringOrObject;
        } else if (errorStringOrObject.getError) {
            // this is an error from an apex call
            var errors = errorStringOrObject.getError();
            if (errors[0] && errors[0].message) {
                errorMessage = errors[0].message;
            }
        } else if (errorStringOrObject.error && errorStringOrObject.error[0] && errorStringOrObject.error[0].message) {
            // this is an error from a force:recordData call
            errorMessage = errorStringOrObject.error[0].message;
        }
        $A.get("e.c:NotificationEvent").setParams({ "errorMessage": errorMessage }).fire();
    },
})