/**
 * Created by Matthew on 2019-05-21.
 */
({
    init: function (component, event, helper) {


		helper.initialize(component, helper);
    },

    applicantTableRowOnSelect : function (component, event, helper) {
        debugger
		var selectedRows = event.getParam("selectedRows");
		if(selectedRows && selectedRows.length == 1) {
			component.set("v.selectedApplicantId", selectedRows[0].Id);
			component.set("v.showLinkApplicantButton", true);
        }
    },

    entityTableRowOnSelect : function (component, event, helper) {
		var selectedRows = event.getParam("selectedRows");
		if(selectedRows && selectedRows.length == 1) {
			component.set("v.selectedEntityId", selectedRows[0].Id);
			component.set("v.showLinkEntityButton", true);
        }
    },

    applicantLinkButtonOnClick : function (component, event, helper) {
        component.set("v.showLinkSelectedApplicantModal", true);
/*        var selectedApplicantId = component.get("v.selectedApplicantId");
		if(selectedApplicantId) {
			helper.linkApplicant(component, helper, selectedApplicantId);
        }*/
	},


	applicantUnlinkButtonOnClick : function (component, event, helper) {
	    component.set("v.disabled", true);
        helper.unlinkApplicant(component, helper)
            .then(
				() => {
					component.set("v.disabled", false);
				}
			);
	},

    entityLinkButtonOnClick : function (component, event, helper) {
		component.set("v.showLinkSelectedEntityModal", true);
    },

	entityUnlinkButtonOnClick : function (component, event, helper) {
	    component.set("v.disabled", true);
        helper.unlinkEntity(component, helper)
            .then(
				() => {
					component.set("v.disabled", false);
				}
			);
	},

    entityNewButtonOnClick : function (component, event, helper) {
		component.set("v.showNewEntityModal", true);
    },





	linkSelectedApplicantModalBackOnClick : function (component, event, helper) {
		component.set("v.showLinkSelectedApplicantModal", false);
	},

	linkSelectedApplicantModalProceedOnClick : function (component, event, helper) {
	    component.set("v.disabled", true);
        var selectedApplicantId = component.get("v.selectedApplicantId");
		if(selectedApplicantId) {
			helper.linkApplicant(component, helper, selectedApplicantId)
				.then(
				    () => {
				        component.set("v.disabled", false);
						component.set("v.showLinkSelectedApplicantModal", false);
					}
            );
        }
	},



    createApplicantButtonOnClick : function (component, event, helper) {
		component.set("v.showCreateApplicantModal", true);
    },

	createApplicantModalBackOnClick : function (component, event, helper) {
		component.set("v.showCreateApplicantModal", false);
	},

	createApplicantModalProceedOnClick : function (component, event, helper) {
	    component.set("v.disabled", true);
		helper.createAndLinkApplicant(component, helper)
			.then(
			    () => {
			        component.set("v.disabled", false);
					component.set("v.showCreateApplicantModal", false);
				}
        );
	},






	linkSelectedEntityModalBackOnClick : function (component, event, helper) {
		component.set("v.showLinkSelectedEntityModal", false);
	},

	linkSelectedEntityModalProceedOnClick : function (component, event, helper) {
        var selectedEntityId = component.get("v.selectedEntityId");
		if(selectedEntityId) {
			helper.linkEntity(component, helper, selectedEntityId)
				.then(
				    () => {
						component.set("v.showLinkSelectedEntityModal", false);
					}
            );
        }
	},






	newEntityModalBackOnClick : function (component, event, helper) {
		component.set("v.showNewEntityModal", false);
	},

	newEntityModalProceedOnClick : function (component, event, helper) {
	    component.set("v.disabled", true);

		helper.newEntity(component, helper)
			.then(
			    // returns the new entity service request
			    (result) => {
			        debugger;
			        // set the entity service request attribute
			        component.set("v.entityServiceRequest", result);
			        // hide the request new button and show alert
			        component.set("v.showNewEntityButton", false);
			        // hide the model window
			        component.set("v.showNewEntityModal", false);
			        // enable the control
			        component.set("v.disabled", false);
			        $A.get('e.force:refreshView').fire();
				}
        );
	},

	compareModalCloseOnClick : function (component, event, helper) {
		component.set("v.showCompareModal", false);
	},

	compareModalLinkOnClick : function (component, event, helper) {
	    debugger;
		component.set("v.showCompareModal", false);
		component.set("v.showCompareModalLinkButton", false);
		if(component.get("v.currentlyOpenCompareModal") == "applicant") {
		    component.set("v.showLinkSelectedApplicantModal", true);
		    component.set("v.selectedApplicantId", component.get("v.compareModalObjectId"));
		    component.set("v.currentlyOpenCompareModal", null);
        }
		if(component.get("v.currentlyOpenCompareModal") == "entity") {
		    component.set("v.showLinkSelectedEntityModal", true);
		    component.set("v.selectedEntityId", component.get("v.compareModalObjectId"));
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
					component.set("v.applicantSelectedRows", [ row.Id ]);
					component.set("v.currentlyOpenCompareModal", "applicant");
					if(!component.get("v.linkedApplicant")) {
						component.set("v.compareModalObjectId", row.Id);
					    component.set("v.showCompareModalLinkButton", true);
                    }
				    helper.getApplicant(component, helper, row.Id)
				    .then (
				        (result) => {
							var id = 1;
				            var requestData = component.get("v.verificationRequest");
				            var matchData = result;

				            component.set("v.showCompareModal", true);

					        component.set('v.compareColumns', [
					            {label: '', fieldName: 'Field', type: 'text'},
					            {label: 'Request Verification', fieldName: 'Request', type: 'text'},
					            {label: 'Potential Match', fieldName: 'Match', type: 'text'},

					        ]);
					        component.set('v.compareData', [
					            // note: this configuration is only for the side-by-side view
					            {Id: id++, Field: 'Last Name', Request: requestData.Last_Name__c, Match: matchData.LastName},
					            {Id: id++, Field: 'Rest of Name', Request: requestData.Rest_of_Name__c, Match: matchData.FirstName},
					            {Id: id++, Field: 'Birth Date', Request: $A.localizationService.formatDate(requestData.Birth_Date__c), Match: $A.localizationService.formatDate(matchData.Birthdate)},
					            {Id: id++, Field: 'Birth Country', Request: requestData.Birth_Country__c, Match: matchData.Birth_Country__c},
					            {Id: id++, Field: 'Gender', Request: requestData.Gender__c, Match: matchData.Gender__c},
					            {Id: id++, Field: 'Medschool Code', Request: requestData.Medschool_Code__c, Match: matchData.Medschool_Code__c},
					            {Id: id++, Field: 'University Code', Request: requestData.University_Code__c, Match: matchData.Medschool_Code__c},
					            {Id: id++, Field: 'Candidate Code', Request: requestData.Candidate_Code__c, Match: matchData.Candidate_Code__c},
					            {Id: id++, Field: 'Graduation Date', Request: 'TODO', Match: 'TODO'},
					            {Id: id++, Field: 'USMLE ID', Request: requestData.USMLE_ID__c, Match: matchData.USMLE_ID__c},
					            {Id: id++, Field: 'EICS ID', Request: requestData.EICS_ID__c, Match: matchData.EICS_ID__c},
					            {Id: id++, Field: 'EPIC ID', Request: requestData.EPIC_ID__c, Match: matchData.EPIC_ID__c},
					            {Id: id++, Field: 'Previous Last Name', Request: requestData.Previous_Last_Name__c, Match: matchData.Previous_Last_Name__c},
					            {Id: id++, Field: 'Previous Rest of Name', Request: requestData.Previous_Rest_of_Name__c, Match: matchData.Previous_Rest_of_Name__c},
					            {Id: id++, Field: 'Residence Country', Request: requestData.Residence_Country__c, Match: matchData.MailingCountry},
					            {Id: id++, Field: 'Current Citizenship', Request: requestData.Current_Citizenship__c, Match: matchData.Current_Citizenship__c},
					        ]);

							// by default highlight the same rows
							helper.compareHighlightSame(component, helper);
                    });
                }
                break;
        }
    },

	onEntityRowAction : function (component, event, helper) {
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
					component.set("v.entitySelectedRows", [ row.Id ]);
					component.set("v.currentlyOpenCompareModal", "entity");
					if(!component.get("v.linkedEntity")) {
						component.set("v.compareModalObjectId", row.Id);
					    component.set("v.showCompareModalLinkButton", true);
                    }
				    helper.getEntity(component, helper, row.Id)
				    .then (
				        (result) => {
							var id = 1;
				            var requestData = component.get("v.verificationRequest");
				            var matchData = result;

				            component.set("v.showCompareModal", true);

					        component.set('v.compareColumns', [
					            {label: '', fieldName: 'Field', type: 'text'},
					            {label: 'Request Verification', fieldName: 'Request', type: 'text'},
					            {label: 'Potential Match', fieldName: 'Match', type: 'text'},

					        ]);
					        component.set('v.compareData', [
					            {Id: id++, Field: 'Medschool Code', Request: requestData.Medschool_Code__c, Match: matchData.Medschool_Code__c},
					            {Id: id++, Field: 'University Code', Request: requestData.University_Code__c, Match: matchData.Medschool_Code__c},
					            {Id: id++, Field: 'Medschool Name', Request: requestData.Medschool_Name__c, Match: matchData.Name},
					            {Id: id++, Field: 'University Name', Request: requestData.University_Name__c, Match: matchData.Name},
					            {Id: id++, Field: 'Institution ID', Request: requestData.Institution_ID__c, Match: 'TBD'},
					            {Id: id++, Field: 'Institution Name', Request: requestData.Institution_Name__c, Match: matchData.Name},
					            {Id: id++, Field: 'Institution Country', Request: requestData.Institution_Country_Code__c, Match: matchData.BillingCountryCode},
					            {Id: id++, Field: 'Institution Address', Request: requestData.Institution_Address__c, Match: matchData.BillingStreet},
					            {Id: id++, Field: 'Institution City', Request: requestData.Institution_City__c, Match: matchData.BillingCity},
					            {Id: id++, Field: 'Institution State', Request: requestData.Institution_State_Code__c, Match: matchData.BillingStateCode},
					            {Id: id++, Field: 'Institution Postal Code', Request: requestData.Institution_Postal_Code__c, Match: matchData.BillingPostalCode},
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
    }

})