/**
 * Created by Matthew on 2019-05-21.
 */
 ({
    init: function (component, event, helper) {
		helper.initialize(component, helper);
    },

    applicantTableRowOnSelect : function (component, event, helper) {
		var selectedRows = event.getParam("selectedRows");
		if(selectedRows && selectedRows.length == 1) {
			component.set("v.selectedApplicantId", selectedRows[0].Id);
			component.set("v.showChooseApplicantButton", true);
        }
    },

    applicantChooseButtonOnClick : function (component, event, helper) {
        component.set("v.showChooseApplicantModal", true);
	},

	chooseApplicantModalBackOnClick : function (component, event, helper) {
		component.set("v.showChooseApplicantModal", false);
	},

	chooseApplicantModalProceedOnClick : function (component, event, helper) {
	    // disable controls
	    component.set("v.disabled", true);
        helper.getContact(component, helper, component.get("v.selectedApplicantId"))
        .then (
            (result) => {
                var appEvent = $A.get("e.c:ApplicantMatchAE");
                appEvent.setParam("contact", result);
                appEvent.fire();
                component.set("v.showChooseApplicantModal", false);
                component.set("v.disabled", false);
            });
	},

	compareModalCloseOnClick : function (component, event, helper) {
		component.set("v.showCompareModal", false);
	},

	compareModalChooseOnClick : function (component, event, helper) {
		component.set("v.showCompareModal", false);
		component.set("v.showCompareModalChooseButton", false);
		if(component.get("v.currentlyOpenCompareModal") == "applicant") {
		    component.set("v.showChooseApplicantModal", true);
		    component.set("v.selectedApplicantId", component.get("v.compareModalObjectId"));
		    component.set("v.currentlyOpenCompareModal", null);
        }
	},

	onApplicantRowAction : function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'details':
				if(row.Id) {
				    // open record detail in new window/tab
					window.open(helper.format(helper.constants.VIEW_LIGHTNING_RECORD_URL, row.Id), "_blank");
                }
                break;
            case 'compare':
				if(row.Id) {
					// select the current row
					component.set("v.applicantSelectedRows", [ row.Id ]);
					// show the choose button
					component.set("v.showChooseApplicantButton", true);
					component.set("v.currentlyOpenCompareModal", "applicant");
					if(!component.get("v.linkedApplicant")) {
						component.set("v.compareModalObjectId", row.Id);
					    component.set("v.showCompareModalChooseButton", true);
					}
					//Code added below by Shailaja Yerneni, July 30 2020. User Story#843
					var existingContact = component.get("v.existingContact");
					//get med school for existing contact which in new applicant from portal					
					helper.getContactAssociationRecord(component, helper, existingContact.Id)
					.then (
						(record) => {
							component.set("v.existingContactAssociationType", record);		
						});
					
					helper.getContactAssociationRecord(component, helper, row.Id)
				    .then (
				        (record) => {
							component.set("v.contactAssociationType", record);
						});

				    helper.getContact(component, helper, row.Id)
				    .then (
				        (result) => {
							var id = 1;
				            var existingContact = component.get("v.existingContact");
				            var matchData = result;
							//Code added by Shailaja Yerneni - July 30 2020
							var cAssctnData = component.get("v.contactAssociationType");
							var schoolName = '';
							if(cAssctnData.Account__c){
								schoolName = cAssctnData.Account__r.Name;
							}

							var cExistingAssctnData = component.get("v.existingContactAssociationType");
							var existingSchoolName = '';
							if(cExistingAssctnData.Account__c){
								existingSchoolName = cExistingAssctnData.Account__r.Name;
							}

				            component.set("v.showCompareModal", true);
							//Label updated for Existing Contact - Shailaja Yerneni. July 30 2020
							//Wrap text added for the columns. User Story#7916. Aug 31 2020
					        component.set('v.compareColumns', [
					            {label: '', fieldName: 'Field', type: 'text'},
								//{label: 'Existing Contact', fieldName: 'Existing', type: 'text'},
								{label: 'New Case Contact', fieldName: 'Existing', type: 'text', wrapText: true},
					            {label: 'Potential Match', fieldName: 'Match', type: 'text', wrapText: true},

							]);
							//New columns added - Shailaja Yerneni - July 30 2020.
					        component.set('v.compareData', [
					            // note: this configuration is only for the side-by-side view
					            {Id: id++, Field: 'Last Name', Existing: existingContact.LastName, Match: matchData.LastName},
					            {Id: id++, Field: 'Rest of Name', Existing: existingContact.FirstName, Match: matchData.FirstName},
					            {Id: id++, Field: 'Birth Date', Existing: $A.localizationService.formatDate(existingContact.Birthdate), Match: $A.localizationService.formatDate(matchData.Birthdate)},
					            {Id: id++, Field: 'Birth Country', Existing: existingContact.Birth_Country__c, Match: matchData.Birth_Country__c},
					            {Id: id++, Field: 'Gender', Existing: existingContact.Gender__c, Match: matchData.Gender__c},
					            {Id: id++, Field: 'Medschool Code', Existing: (existingContact.Medschool_Code__c || '') + (existingContact.University_Code__c || ''), Match: matchData.Medschool_Code__c},
					           // {Id: id++, Field: 'Candidate Code', Existing: existingContact.Candidate_Code__c, Match: matchData.Candidate_Code__c},
					            {Id: id++, Field: 'Graduation Year', Existing: existingContact.Graduation_Year__c, Match: matchData.Graduation_Year__c},
					            {Id: id++, Field: 'USMLE ID', Existing: existingContact.USMLE_ID__c, Match: matchData.USMLE_ID__c},
					            {Id: id++, Field: 'EICS ID', Existing: existingContact.EICS_ID__c, Match: matchData.EICS_ID__c},
					            {Id: id++, Field: 'EPIC ID', Existing: existingContact.EPIC_ID__c, Match: matchData.EPIC_ID__c},
					            {Id: id++, Field: 'Previous Last Name', Existing: existingContact.Previous_Last_Name__c, Match: matchData.Previous_Last_Name__c},
					            {Id: id++, Field: 'Previous Rest of Name', Existing: existingContact.Previous_Rest_of_Name__c, Match: matchData.Previous_Rest_of_Name__c},
					            {Id: id++, Field: 'Residence Country', Existing: existingContact.Residence_Country__c, Match: matchData.MailingCountry},
								{Id: id++, Field: 'Current Citizenship', Existing: existingContact.Current_Citizenship__c, Match: matchData.Current_Citizenship__c},
								{Id: id++, Field: 'Email Address', Existing: existingContact.Email, Match: matchData.Email},
								{Id: id++, Field: 'Phone Number', Existing: existingContact.Phone, Match: matchData.Phone},
								{Id: id++, Field: 'Medschool Name', Existing: existingSchoolName, Match: schoolName},
					        ]);

							// by default highlight the same rows
							helper.compareHighlightSame(component, helper);
                    });
                }
                break;
        }
    },

    compareOptionsOnClick : function (component, event, helper) {
        var option = event.getSource().get("v.value");
        switch(option) {
			case "different":
				helper.compareHighlightDifferent(component, helper);
				break;
			case "same":
				helper.compareHighlightSame(component, helper);
				break;
			case "none":
				helper.compareHighlightNone(component, helper);
				break;
			break;
			default:
        }
    },
    handleApplicantMatchAE : function(component, event, helper) {
        var showMatches = event.getParam("showMatches");
        if(showMatches) {
            $A.util.removeClass(component.find("main"), "slds-hide");
        }
        else {
            $A.util.addClass(component.find("main"), "slds-hide");
        }
    },

})