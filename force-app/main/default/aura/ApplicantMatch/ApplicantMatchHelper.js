/**
 * Created by Matthew on 2019-05-23.
 */
 ({
    initialize: function(component, helper) {
        // reset view
        component.set("v.applicantSelectedRows", []);
        component.set("v.showChooseApplicantButton", false);

        var actions = [
            { label: 'View Details', name: 'details' },
            { label: 'Side-by-Side', name: 'compare' }
        ];

        component.set('v.applicantColumns', [
            {label: 'Score', fieldName: 'ScorePercentage', type: 'text'},
            {label: 'Last Name', fieldName: 'LastName', type: 'text'},
            {label: 'Rest of Name', fieldName: 'RestOfName', type: 'text'},
            // set the birth date column to text temporarily so placeholder text will display...
            {label: 'Birth Date', fieldName: 'BirthDate', type: 'text'},
            {label: 'Birth Country', fieldName: 'BirthCountry', type: 'text'},
			{label: 'Gender', fieldName: 'Gender', type: 'text'},
			{label: 'Medschool Code', fieldName: 'MedschoolCode', type: 'text'},
			{ type: 'action', typeAttributes: { rowActions: actions } },
        ]);

        component.set('v.applicantData', [
            {Id: '0', ScorePercentage: '…', LastName: '…', RestOfName: '…', BirthDate: '…', BirthCountry: '…', Gender: '…', MedschoolCode: '…'},
        ]);

        component.set("v.applicantSectionLabel", helper.format(component.get("v.applicantSectionLabelTemplate"), component.get("v.applicantMatchCount")));

		// set default text for linked applicant and entity
        component.set("v.linkedApplicantName", component.get("v.linkedPlaceholder"));

        var caseId = component.get("v.recordId");
        //debugger;
		if(caseId) {

            // get and populate potential matches
            helper.getApplicantMatches(component, helper)
                .then(
                    () => {
                        component.set("v.pageReady", true);
                    }

                );

            // get the case and contact for use by side-by-side
            helper.getCase(component, helper, caseId)
                .then(
                    (result) => {
                        // set the case attribute
                        component.set("v.case", result);
                        // get the applicant on the case
                        if(result && result.ContactId) {
                            // get the applicant
                            helper.getContact(component, helper, result.ContactId)
                                .then(
                                    (result) => {
                                        // set the existing contact attribute
                                        component.set("v.existingContact", result);
                                });
                        }
                        else {
                            // make sure we have a case and a case contact
                            $A.get("e.c:NotificationEvent").setParams({ errorMessage: "Could not find case or case does not have an associated contact." }).fire();
                            // get out
                            return;
                        }
                 });
        }
        else {
            // make sure we have a recordId set by container
            $A.get("e.c:NotificationEvent").setParams({ errorMessage: "This component is intended to be used on record pages. Please provide a recordId (case id)." }).fire();
        }

    },

    getApplicantMatches : function(component, helper) {
        // setup params and do pre-processing
		var params = { caseId: component.get("v.recordId") };
        return helper.apex(component, helper, "getApplicantMatches", params)
            .then(
                (result) => {
                    // set the birth date column back to date-local type so date displays correctly
                    component.get("v.applicantColumns")[3].type = "date-local";
                    // set applicant match data and row count
                    component.set("v.applicantData", result);
                    component.set("v.applicantMatchCount", result.length);
                    component.set("v.applicantSectionLabel", helper.format(component.get("v.applicantSectionLabelTemplate"), component.get("v.applicantMatchCount")));
                    // show checkboxes if there's one or more records
                    if(result.length > 0 ) {
                        component.find("applicantTable").set("v.hideCheckboxColumn", false);
                    }
                    // clear previously selected row
                    component.set("v.applicantSelectedRows", []);
                    return result;
            });
    },

	compareHighlightDifferent : function(component, helper) {
   	    // clears selected
   		component.set("v.compareSelectedRows", []);
		var compareData = component.get("v.compareData");
		var compareSelectedRows = component.get("v.compareSelectedRows");
		for(var i = 0; i < compareData.length; i++) {
			if(helper.nullSafe(compareData[i].Existing).toLowerCase() !== helper.nullSafe(compareData[i].Match).toLowerCase()) {
			    compareSelectedRows.push(compareData[i].Id);
            }
        }
		component.set("v.compareSelectedRows", compareSelectedRows);
    },

	compareHighlightSame : function(component, helper) {
	    // clears selected
		component.set("v.compareSelectedRows", []);
		var compareData = component.get("v.compareData");
		var compareSelectedRows = component.get("v.compareSelectedRows");
		for(var i = 0; i < compareData.length; i++) {
			if(helper.nullSafe(compareData[i].Existing).toLowerCase() === helper.nullSafe(compareData[i].Match).toLowerCase()) {
			    compareSelectedRows.push(compareData[i].Id);
            }
        }
		component.set("v.compareSelectedRows", compareSelectedRows);
    },

	compareHighlightNone : function(component, helper) {
	    // clears selected
		component.set("v.compareSelectedRows", []);
    },

	/*
		Returns the contact (applicant) record.
	*/
    getContact : function(component, helper, id) {
        // setup params and do pre-processing
		var params = { contactId: id };
        return helper.apex(component, helper, "getContact", params)
            .then(
                (result) => {
                    return result;
            });
    },

	/*
		This method will return the case as a promise.
	*/
    getCase : function(component, helper, id) {
        // setup params and do pre-processing
		var params = { caseId: id };
        return helper.apex(component, helper, "getCase", params);
    },

    /*
        Created By: Shailaja Yerneni
        User Story#843.
        Date: July 30 2020
		Returns the applicant details (contactAssociationType) record.
	*/
    getContactAssociationRecord : function(component, helper, id) {
        // setup params and do pre-processing
        
        var params = { contactId: id };
        return helper.apex(component, helper, "getContactAssociationRecord", params)
            .then(
                (result) => {                    
                    return result;
            });
    },

});