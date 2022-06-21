/**
 * Created by Matthew on 11/1/18.
 */
({
    doInit: function(component, event, helper) {
        helper.initialize(component, event, helper);        
    },
    
    // handles showing the add new account dialog, where one can add an existing account
    handleAccountSelectedEvent : function(component, event, helper) {
        // get the selected account record and id from the search app event
        var data = event.getParam("Data");
        var record = event.getParam("LightningSearchRecord");
        component.set("v.selectedAssociationRecordType", data);
        component.set("v.account", record);
        component.set("v.accountId", record.Id);

        // only listen to events for the same record type
        if(component.get("v.selectedAssociationRecordType") == component.get("v.associationRecordType")) {
            // update the the current count
            helper.initializeCurrentAssociationTypeCount(component, event, helper);
            // only allows schools to be added if under the maximum count
            if((component.get("v.currentAssociationTypeCount") < component.get("v.maximumAssociationTypes"))) {
                // initialize the add association type record creator
                helper.initializeAssociationTypeRecordCreator(component, event, helper);
                // show the add school dialog
                component.set("v.showAddDialog", true);
            } else {
                $A.get("e.c:NotificationEvent").setParams({"errorMessage" : "You cannot add any more associationTypes." }).fire();
            }
        }
        // clear the search input field
        component.find("accountSearch").clear();
    },

    /*
        Handles showing the submit new dialog, where one can submit a new account and add it to the association type
        all in one go.
    */
    handleAccountNewEvent : function(component, event, helper) {
        console.log('handleAccountNewEvent');

        // data contains the name of the record type being searched/submitted
        var data = event.getParam("Data");
        component.set("v.selectedAssociationRecordType", data);
        // only listen to events for the same record type
        if(component.get("v.selectedAssociationRecordType") == component.get("v.associationRecordType")) {
            console.log('associated rec type - '+component.get("v.associationRecordType"));
            // update the the current count
            helper.initializeCurrentAssociationTypeCount(component, event, helper);
            // only allows association types to be added if under the maximum count
            if((component.get("v.currentAssociationTypeCount") < component.get("v.maximumAssociationTypes"))) {
                // TODO: Make these synchronous calls, and the last successful call should show dialog. Otherwise there's a race.
                // initialize the add association type record creator
                helper.initializeAssociationTypeRecordCreator(component, event, helper);
                // initialize the add account record creator
                helper.initializeAccountRecordCreator(component, event, helper);
                // show dialog
                component.set("v.showSubmitDialog", true);
            } else {
                $A.get("e.c:NotificationEvent").setParams({"errorMessage" : "You cannot add any more associationTypes." }).fire();
            }
        }
        // clear the search input field
        component.find("accountSearch").clear();
    },

    handleAssociationTypeDeletedEvent : function(component, event, helper) {
         // disable search control
        component.set("v.disabled", true);
        // update the the current count
        helper.initializeCurrentAssociationTypeCount(component, event, helper);
    },

    handleAssociationTypeStateEvent : function(component, event, helper) {
        component.set("v.visible", event.getParam("visible"));
        component.set("v.disabled", event.getParam("disabled"));
        if(typeof event.getParam("minimumAssociationTypes") != "undefined") {
            component.set("v.minimumAssociationTypes", event.getParam("minimumAssociationTypes"));
        }
        if(typeof event.getParam("maximumAssociationTypes") != "undefined") {
            component.set("v.maximumAssociationTypes", event.getParam("maximumAssociationTypes"));
        }
        if((typeof event.getParam("minimumAssociationTypes") != "undefined") || (typeof event.getParam("maximumAssociationTypes") != "undefined")) {
            helper.initializeCurrentAssociationTypeCount(component, event, helper);
        }
    },

    handleAddOnClick : function(component, event, helper) {
        component.find("addButton").set("v.disabled", true);
        // use an array to capture all validation outcomes
        var allValid = [true];

        if(component.get("v.associationRecordType") != "Regulatory Organization" && component.get("v.associationRecordType") != "Medical Authority") {
            //Code commented by Shailaja - 9/1/2020. User Story#7211. Date format stories. The following code has been moved to end of the if loop
            // as the validation of component can be done after the validation of fields.
            //Code added - Shailaja - 8/25/2020 - User Story #7211
            //Code added - Shailaja - 8/28/2020 - User Story #7211
            //Code added by Shailaja Aug 31 2020.
            
            var sMonth = helper.findComponentByName("fieldToValidate", "startMonth", component);
            var sYear = helper.findComponentByName("fieldToValidate", "startYear", component);
            var eYear = helper.findComponentByName("fieldToValidate", "endYear", component);
            var eMonth = helper.findComponentByName("fieldToValidate", "endMonth", component);

            //1/26/2021 - Clear the error messages
            if(!sMonth.get("v.validity").valid){
                sMonth.setCustomValidity("");
            }
            if(!sYear.get("v.validity").valid){
                sYear.setCustomValidity("");
            }
            if(!eMonth.get("v.validity").valid){
                eMonth.setCustomValidity("");
            }
            if(!eYear.get("v.validity").valid){
                eYear.setCustomValidity("");
            }
            var currYear = new Date().getFullYear();
            
            //New Code - User story#827 - 1/26/2021
            var pastEightNineYear = Number(currYear) -89;
            var futureTenYear = Number(currYear) +10;
            //New code - end
            //First validation - Start Date cannot be in future.
            //Second validation - Start date cannot be greater than End Date
            //Third validation -  Start Date cannot be 89 years in past

            //Build the date from the given month and year and day being 01
            var sNewStartDate = sMonth.get("v.value") + ' '+ helper.constants.CONASCTYPE_START_END_DAY + ', '  + sYear.get("v.value") + ' ';
            var sNewEndDate = eMonth.get("v.value") + ' '+ helper.constants.CONASCTYPE_START_END_DAY + ', '  + eYear.get("v.value") + ' ';
            var newSDate = new Date(sNewStartDate);
            var newEDate = new Date(sNewEndDate);

            //New code for Start date validations. #user story 827. 1/26/2021
            var sPastStartDate = sMonth.get("v.value") + ' '+ helper.constants.CONASCTYPE_START_END_DAY + ', '  + pastEightNineYear + ' ';
            var newPastSDate = new Date(sPastStartDate);
            var sFutureEndDate = eMonth.get("v.value") + ' '+ helper.constants.CONASCTYPE_START_END_DAY + ', '  + futureTenYear + ' ';
            var newFutureEDate = new Date(sFutureEndDate);
            
           //add validation to see if the new start date is greater than current date
           //First validation - Start Date cannot be in future.
            if(Date.parse(newSDate) > (new Date())) {
                sMonth.setCustomValidity("Start Date cannot be in the future.");
                sMonth.reportValidity();
                allValid.push(false);
            }
            if (Date.parse(newSDate) > Date.parse(newEDate)){ //Second validation - Start date cannot be greater than End Date
                eMonth.setCustomValidity("End Date cannot be before Start Date.");
                eMonth.reportValidity();
                allValid.push(false);
            }
            if(Date.parse(newSDate) < Date.parse(newPastSDate)){//Third validation -  Start Date cannot be 89 years in past
                sMonth.setCustomValidity("Start Date cannot be older than 89 years in the past .");
                sMonth.reportValidity();                    
                allValid.push(false);
            }
            //Fourth Validation - End date within 10 years in future
            if(Date.parse(newEDate) > Date.parse(newFutureEDate)) {
                eMonth.setCustomValidity("End Date cannot be greater than 10 years in future.");
                eMonth.reportValidity();
                eYear.reportValidity(); 
                allValid.push(false);
            }
            //Verify validity and set custom messages to blank if fields are valid.
            if(sMonth.get("v.validity").valid){
                sMonth.setCustomValidity("");
            }
            if(sYear.get("v.validity").valid){
                sYear.setCustomValidity("");
            }
            if(eMonth.get("v.validity").valid){
                eMonth.setCustomValidity("");
            }
            if(eYear.get("v.validity").valid){
                eYear.setCustomValidity("");
            }
            //Code End - ////
            if(component.get("v.associationRecordType") == 'Degree Medical School') {
                //New code. Get the degree issue month
                var degMonth = helper.findComponentByName("fieldToValidate", "degreeMonth", component); 
                var degYear = helper.findComponentByName("fieldToValidate", "degreeYear", component); 
                //Clear out error messages
                if(!degMonth.get("v.validity").valid){
                    degMonth.setCustomValidity("");
                }
                if(!degYear.get("v.validity").valid){
                    degYear.setCustomValidity("");
                }
                //calculate newDegreeIssueDate
                var strDegIssueDate = degMonth.get("v.value") + ' ' + helper.constants.CONASCTYPE_START_END_DAY + ', '  + degYear.get("v.value") + ' ';
                var newDegIssueDate = new Date(strDegIssueDate);
                //New Code
                var strFutureDegIssueDate = degMonth.get("v.value") + ' ' + helper.constants.CONASCTYPE_START_END_DAY + ', '  + futureTenYear + ' ';
                var newFutureDegIssueDate = new Date(strFutureDegIssueDate);
                //new code end
                //First Validation - End Date cannot be greater than Degree Date
                if(Date.parse(newEDate) > Date.parse(newDegIssueDate)){
                    degMonth.setCustomValidity("Degree Date cannot be before End Date.");
                    degMonth.reportValidity();
                    allValid.push(false);
                }
                //Second Validation - Degree Date cannot be greater than 10 years in future
                if(Date.parse(newDegIssueDate) > Date.parse(newFutureDegIssueDate)) {//Greater than 10 years in future throw an error
                    degMonth.setCustomValidity("Degree Issue Date cannot be greater than 10 years in future.");
                    degMonth.reportValidity();
                    allValid.push(false);
                }
                //if degree date is valid, set the fields custom messages to blank
                if(degMonth.get("v.validity").valid){
                    degMonth.setCustomValidity("");
                }
                if(degYear.get("v.validity").valid){
                    degYear.setCustomValidity("");
                }
                //Code End
            }
            //Code commented by Shailaja - 9/1/2020. User Story#7211. Date format stories. 
            //The following code has been moved here from beginning of the if loop
            // as the validation of component can be done after the validation of fields.

            allValid.push(component.find("fieldToValidate").reduce(function (validSoFar, cmp) {
                cmp.reportValidity();
                return validSoFar && cmp.checkValidity();
            }, true));
        }
        var distinctValid = Array.from(new Set(allValid));
        if(distinctValid.length == 1 && distinctValid[0] == true) {
            helper.addExisting(component, event, helper);
        }
        else {
            // enable button
            component.find("addButton").set("v.disabled", false);
        }
    },

    handleSubmitOnClick : function(component, event, helper) {
        // disable button on click
        component.find("submitButton").set("v.disabled", true);

        // use an array to capture all validation outcomes
        var allValid = [true];
        // may only pull back one field, which won't be an array and "reduce" will fail
        if(typeof component.find("fieldToValidate").length == "undefined") {            
            component.find("fieldToValidate").reportValidity();
            allValid.push(component.find("fieldToValidate").checkValidity());
        }

        // validate address
        allValid.push(component.find("submitAddress").validate());

        if(component.get("v.associationRecordType") != "Regulatory Organization" && component.get("v.associationRecordType") != "Medical Authority") {
            //Code commented by Shailaja - 9/1/2020. User Story#7211. Date format stories. The following code has been moved to end of the if loop
            // as the validation of component can be done after the validation of fields.

            //Code added - Shailaja - 8/25/2020 - User Story #7211            
            var startMonth = helper.findComponentByName("fieldToValidate", "startMonth", component);
            var startYear = helper.findComponentByName("fieldToValidate", "startYear", component);
            var endMonth = helper.findComponentByName("fieldToValidate", "endMonth", component);
            var endYear = helper.findComponentByName("fieldToValidate", "endYear", component);
            
            //1/26/2021 - Clear the error messages
            if(!startMonth.get("v.validity").valid){
                startMonth.setCustomValidity("");
            }
            if(!startYear.get("v.validity").valid){
                startYear.setCustomValidity("");
            }
            if(!endMonth.get("v.validity").valid){
                endMonth.setCustomValidity("");
            }
            if(!endYear.get("v.validity").valid){
                endYear.setCustomValidity("");
            }
            var currentYear = new Date().getFullYear();
            var strNewStartDate;
            var strNewEndDate;
            //Build the date from the given month and year and day being 01
            strNewStartDate = startMonth.get("v.value") + ' '+ helper.constants.CONASCTYPE_START_END_DAY + ', '  + startYear.get("v.value") + ' ';
            strNewEndDate = endMonth.get("v.value") + ' '+ helper.constants.CONASCTYPE_START_END_DAY + ', '  + endYear.get("v.value") + ' ';
            var newStartDate = new Date(strNewStartDate);
            var newEndDate = new Date(strNewEndDate);
            //New date validations            
            //New Code - User story#827 - 1/26/2021
            var pastEightNineYear = Number(currentYear) -89;
            var futureTenYear = Number(currentYear) +10;
            //New code for Start date validations. #user story 827. 1/26/2021
            var sPastStartDate = startMonth.get("v.value") + ' '+ helper.constants.CONASCTYPE_START_END_DAY + ', '  + pastEightNineYear + ' ';
            var newPastSDate = new Date(sPastStartDate);
            var sFutureEndDate = endMonth.get("v.value") + ' '+ helper.constants.CONASCTYPE_START_END_DAY + ', '  + futureTenYear + ' ';
            var newFutureEDate = new Date(sFutureEndDate);
            //New code - end
            //First validation - Start date cannot be in future
            if(Date.parse(newStartDate) > (new Date())){
                startMonth.setCustomValidity("Start Year cannot be in the future.");
                startMonth.reportValidity();
                allValid.push(false);
            }
            //Second validation - Start date cannot be greater than End Date
            if(Date.parse(newStartDate) > Date.parse(newEndDate)){
                endMonth.setCustomValidity("End Date cannot be before Start Date.");
                endMonth.reportValidity();
                allValid.push(false);
            }
            //Third validation -  Start Date cannot be 89 years in past
            if(Date.parse(newStartDate) < Date.parse(newPastSDate)){
                startMonth.setCustomValidity("Start Date cannot be older than 89 years in the past .");
                startMonth.reportValidity();                    
                allValid.push(false);
            }
            //Fourth Validation - //End date cannot be 10 years in future
            if(Date.parse(newEndDate) > Date.parse(newFutureEDate)){
                endMonth.setCustomValidity("End Date cannot be greater than 10 years in future.");
                endMonth.reportValidity();
                allValid.push(false);
            }
            //verify validity of fields and if all fields are valid set the custom messages to blank.
            if(startMonth.get("v.validity").valid){
                startMonth.setCustomValidity("");
            }
            if(startYear.get("v.validity").valid){
                startYear.setCustomValidity("");
            }
            if(endMonth.get("v.validity").valid){
                endMonth.setCustomValidity("");
            }
            if(endYear.get("v.validity").valid){
                endYear.setCustomValidity("");
            }
            //Code End - ////
            
            //add code to validate degree date to end date
            if(component.get("v.associationRecordType") == 'Degree Medical School') {
                //New code. Get the degree issue month
                var degreeMonth = helper.findComponentByName("fieldToValidate", "degreeMonth", component); 
                var degreeYear = helper.findComponentByName("fieldToValidate", "degreeYear", component); 
                //Clear out error messages
                if(!degreeMonth.get("v.validity").valid){
                    degreeMonth.setCustomValidity("");
                }
                if(!degreeYear.get("v.validity").valid){
                    degreeYear.setCustomValidity("");
                }
                //calculate newDegreeIssueDate
                var strDegreeIssueDate = degreeMonth.get("v.value") + ' ' + helper.constants.CONASCTYPE_START_END_DAY + ', '  + degreeYear.get("v.value") + ' ';
                var newDegreeIssueDate = new Date(strDegreeIssueDate);
                var strFutureDegIssueDate = degreeMonth.get("v.value") + ' ' + helper.constants.CONASCTYPE_START_END_DAY + ', '  + futureTenYear + ' ';
                var newFutureDegIssueDate = new Date(strFutureDegIssueDate);
                
                if(Date.parse(newEndDate) > Date.parse(newDegreeIssueDate)){
                    degreeMonth.setCustomValidity("Degree Date cannot be before End Date.");
                    degreeMonth.reportValidity();
                    allValid.push(false);
                } 
                if(Date.parse(newDegreeIssueDate) > Date.parse(newFutureDegIssueDate)){//Greater than 10 years in future throw an error
                    degreeMonth.setCustomValidity("Degree Issue Date cannot be greater than 10 years in future.");
                    degreeMonth.reportValidity();
                    allValid.push(false);
                }
                //Clear the messages if the fields are valid
                if(degreeMonth.get("v.validity").valid){
                    degreeMonth.setCustomValidity("");
                }
                if(degreeYear.get("v.validity").valid){
                    degreeYear.setCustomValidity("");
                }
                //New Code End
            }
            //Code commented by Shailaja - 9/1/2020. User Story#7211. Date format stories. 
            //The following code has been moved here from beginning of the if loop,
            // as the validation of component can be done after the validation of fields.
            allValid.push(component.find("fieldToValidate").reduce(function (validSoFar, cmp) {
                cmp.reportValidity();
                return validSoFar && cmp.checkValidity();
            }, true));
        }
        var distinctValid = Array.from(new Set(allValid));
        if(distinctValid.length == 1 && distinctValid[0] == true) {
            console.log('handleSubmitOnClick Before calling helper.submitNew method in controller');
            helper.submitNew(component, event, helper);
        }
        else {
            // enable button
            component.find("submitButton").set("v.disabled", false);
        }
    },

    handleCancelOnClick : function(component, event, helper) {
        component.set("v.showSubmitDialog", false);
        component.set("v.showAddDialog", false);
    },

    handleInputOnBlur :  function(component, event, helper) {
        var field = event.getSource();
        if(field.get("v.value") && typeof field.get("v.value") == "string") field.set("v.value", field.get("v.value").trim());        
    },

    handleChangeStartMonth: function (component, event) {
        // Get the "value" attribute on the selected option
        var selectedOptionValue = event.getParam("value");
        //var field = event.getSource();
        component.set("v.startMonth", selectedOptionValue);
    },
    handleChangeEndMonth: function (component, event) {
        // Get the "value" attribute on the selected option
        var selectedOptionValue = event.getParam("value");
        //var field = event.getSource();
        component.set("v.endMonth", selectedOptionValue);
    },
    handleChangeDegreeMonth: function (component, event) {
        // Get the "value" attribute on the selected option
        var selectedOptionValue = event.getParam("value");
        //var field = event.getSource();
        component.set("v.degreeMonth", selectedOptionValue);
    },
})