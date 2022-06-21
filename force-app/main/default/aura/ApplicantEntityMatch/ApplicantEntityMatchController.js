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

	//Following code is added by Shailaja Yerneni. 1/4/2021. User Story#850
	akaNamesTableRowOnSelect : function (component, event, helper) {
		var selectedRows = event.getParam("selectedRows");
		if(selectedRows && selectedRows.length == 1) {
			component.set("v.selectedAKANamesId", selectedRows[0].Id);			
        }
    },

    applicantLinkButtonOnClick : function (component, event, helper) {
        component.set("v.showLinkSelectedApplicantModal", true);
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
                    component.set("v.showSearchButton",true);
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
    
    searchEntityAction: function(component, event , helper){
        component.set("v.displaySearchEntity", true);
    },
    
    closeSearchEntity: function(component, event, helper){
        var buttonName = event.getSource().get("v.label");
        if(buttonName == 'Link Selected'){
            helper.linkCaseEntityHelper(component, helper);
        }else{
            var entities = [];
            component.set("v.entitylist", entities);
            component.set("v.selectedAccountRecId", '');
            component.set("v.searchKey",'');
        }
        component.set("v.displaySearchEntity", false);
    },
    
    onSelect: function(component, event, helper) {
        var selected;
        var selectedRows = event.getParam("selectedRows");
        if(selectedRows && selectedRows.length == 1){
            selected = selectedRows[0].id;
            component.set("v.selectedAccountRecId", selected);
            var s = JSON.parse(JSON.stringify(component.get("v.selectedAccountRecId")));            
        }
    },
    
    getEntitiesAction: function(component, event, helper){
        var searchKey = component.get("v.searchKey");
        if($A.util.isUndefinedOrNull(searchKey)){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Warning!",
                "message": "You must enter atlease 3 letter."
            });
            toastEvent.fire();
        }else{  
            component.set("v.displayDataTable",true);
            helper.getEntitiesSearchResult(component);   
        }
    },
   onSelEntityRowAction : function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        var jsonstrign = JSON.stringify(row);
        row = JSON.parse(jsonstrign);
        switch (action.name) {
            case 'details':
                if(row.id) {
                    // open record detail in new window/tab
                    window.open(helper.format(helper.constants.VIEW_LIGHTNING_RECORD_URL, row.id), "_blank");
                }
                break;
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
					helper.getContactAssociationRecord(component, helper, row.Id)
				    .then (
				        (record) => {
							component.set("v.contactAssociationType", record);
						});
				    helper.getApplicant(component, helper, row.Id)
				    .then (
				        (result) => {
							var id = 1;
				            var requestData = component.get("v.verificationRequest");
							var matchData = result;
							var cAssctnData = component.get("v.contactAssociationType");
							var schoolName = '';
							if(cAssctnData.Account__c){
								schoolName = cAssctnData.Account__r.Name;
							}
				            component.set("v.showCompareModal", true);
							//Code added by Shailaja Yerneni. User STory#7916
					        component.set('v.compareColumns', [
					            {label: '', fieldName: 'Field', type: 'text'},
					            {label: 'Request Verification', fieldName: 'Request', type: 'text', wrapText: true},
					            {label: 'Potential Match', fieldName: 'Match', type: 'text', wrapText: true},
							]);
							//Added Phone Number - User Story#843 - Shailaja Yerneni - July 27 2020.
					        component.set('v.compareData', [
					            // note: this configuration is only for the side-by-side view
					            {Id: id++, Field: 'Last Name', Request: requestData.Last_Name__c, Match: matchData.LastName},
					            {Id: id++, Field: 'Rest of Name', Request: requestData.Rest_of_Name__c, Match: matchData.FirstName},
					            {Id: id++, Field: 'Birth Date', Request: $A.localizationService.formatDate(requestData.Birth_Date__c), Match: $A.localizationService.formatDate(matchData.Birthdate)},
					            {Id: id++, Field: 'Birth Country', Request: requestData.Birth_Country__c, Match: matchData.Birth_Country__c},
					            {Id: id++, Field: 'Gender', Request: requestData.Gender__c, Match: matchData.Gender__c},
					            {Id: id++, Field: 'Medschool Code', Request: (requestData.Medschool_Code__c || '') + (requestData.University_Code__c || ''), Match: matchData.Medschool_Code__c},
					            {Id: id++, Field: 'Candidate Code', Request: requestData.Candidate_Code__c, Match: matchData.Candidate_Code__c},
					            {Id: id++, Field: 'Graduation Year', Request: requestData.Graduation_Year__c, Match: cAssctnData.Graduation_Year__c},
					            {Id: id++, Field: 'USMLE ID', Request: requestData.USMLE_ID__c, Match: matchData.USMLE_ID__c},
					            {Id: id++, Field: 'EICS ID', Request: requestData.EICS_ID__c, Match: matchData.EICS_ID__c},
					            {Id: id++, Field: 'EPIC ID', Request: requestData.EPIC_ID__c, Match: matchData.EPIC_ID__c},
					            {Id: id++, Field: 'Previous Last Name', Request: requestData.Previous_Last_Name__c, Match: matchData.Previous_Last_Name__c},
					            {Id: id++, Field: 'Previous Rest of Name', Request: requestData.Previous_Rest_of_Name__c, Match: matchData.Previous_Rest_of_Name__c},
					            {Id: id++, Field: 'Residence Country', Request: requestData.Residence_Country__c, Match: matchData.MailingCountry},
								{Id: id++, Field: 'Current Citizenship', Request: requestData.Current_Citizenship__c, Match: matchData.Current_Citizenship__c},
								{Id: id++, Field: 'Email', Request: requestData.Email__c, Match: matchData.Email},
								{Id: id++, Field: 'Degree Granting Medical School', Request: requestData.Degree_Granting_Medical_School__c, Match: schoolName},
								{Id: id++, Field: 'Medschool Name', Request: requestData.Medschool_Name__c, Match: schoolName},
								{Id: id++, Field: 'Phone Number', Request: requestData.Phone__c, Match: matchData.Phone},
					        ]);
							// by default highlight the same rows
							helper.compareHighlightSame(component, helper);
                    });
                }
                break;
        }
    },

	//Following code is added by Shailaja Yerneni. 1/4/2021. User Story#850
	onAKANamesRowAction : function (component, event, helper) {
		//display the AKA Record
		var action = event.getParam('action');
		var row = event.getParam('row');
		switch (action.name) {
			case 'details':
				if(row.Id) {
				    // open record detail in new window/tab
					window.open(helper.format(helper.constants.VIEW_LIGHTNING_RECORD_URL, row.Id), "_blank");
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
							//Retrieving Parent Acoount name - Code added by Shailaja Yerneni
							var parentName = '';
							if(matchData.ParentId){
								parentName = matchData.Parent.Name;
							}
				            component.set("v.showCompareModal", true);
							//Code added by Shailaja Yerneni. User Story#7916. Wrap text
					        component.set('v.compareColumns', [
					            {label: '', fieldName: 'Field', type: 'text'},
					            {label: 'Request Verification', fieldName: 'Request', type: 'text', wrapText: true},
					            {label: 'Potential Match', fieldName: 'Match', type: 'text', wrapText: true},
							]);
							//Acoount Type & Parent Affiliation are added. User story#840. July 27 2020 by Shailaja Yerneni
							component.set('v.compareData', [
					            // note: this configuration is only for the side-by-side view
								{Id: id++, Field: 'Name', Request: (requestData.Medschool_Name__c || '') + (requestData.University_Name__c || '') + (requestData.Institution_Name__c || ''), Match: matchData.Name},
								{Id: id++, Field: 'Account Type', Request: requestData.Account_Type__c, Match: matchData.Account_Type__c},
								{Id: id++, Field: 'Parent Affiliation', Request: requestData.Parent_Affiliation__c, Match: parentName},
								{Id: id++, Field: 'Medschool Code', Request: (requestData.Medschool_Code__c || '') + (requestData.University_Code__c || ''), Match: matchData.Medschool_Code__c},
					            {Id: id++, Field: 'Institution ID', Request: requestData.Institution_ID__c, Match: matchData.Institution_ID__c},
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
    },

    entityServiceRequestOnChange : function (component, event, helper) {
        if(component.get("v.entityServiceRequest")) {
            component.set("v.showEntityServiceRequestAlert", true);
        }
        else {
            component.set("v.showEntityServiceRequestAlert", false);
        }
    },

    linkedApplicantOrEntityOnChange : function (component, event, helper) {
        if(component.get("v.linkedApplicant") && component.get("v.linkedEntity")) {
            component.set("v.showProceedButton", true);
        }
        else {
            component.set("v.showProceedButton", false);
        }
    },

    proceedButtonOnClick : function (component, event, helper) {
        component.set("v.showProceedConfirmationModal", true);
    },

    proceedModalBackOnClick : function (component, event, helper) {
        component.set("v.showProceedConfirmationModal", false);
    },

    proceedModalProceedOnClick : function (component, event, helper) {
        component.set("v.disabled", true);
        helper.proceed(component, helper)
            .then(
				() => {
					component.set("v.disabled", false);
					component.set("v.showProceedConfirmationModal", false);
                    $A.get('e.force:refreshView').fire();
				}
			).finally(
                () => {
                    component.set("v.disabled", false);
                    component.set("v.showProceedConfirmationModal", false);
                     $A.get('e.force:refreshView').fire();
                }
            );
    },
})