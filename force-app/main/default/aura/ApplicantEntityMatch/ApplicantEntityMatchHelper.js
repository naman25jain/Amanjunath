/**
 * Created by Matthew on 2019-05-23.
 */
({
    initialize: function(component, helper) {
        var actions = [
            { label: 'View Details', name: 'details' },
            { label: 'Side-by-Side', name: 'compare' }
        ];
        //Following code is added by Shailaja Yerneni. 1/4/2021. User Story#850
        var akaActions = [
            { label: 'View Details', name: 'details' }
        ];
        component.set('v.applicantColumns', [
            {label: 'Score', fieldName: 'Score', type: 'percentage'},
            {label: 'Last Name', fieldName: 'LastName', type: 'text'},
            {label: 'Rest of Name', fieldName: 'RestOfName', type: 'text'},
            {label: 'Birth Date', fieldName: 'BirthDate', type: 'date-local'},
            {label: 'Birth Country', fieldName: 'BirthCountry', type: 'text'},
			{label: 'Gender', fieldName: 'Gender', type: 'text'},
			{label: 'Medschool Code', fieldName: 'MedschoolCode', type: 'text'},
			{ type: 'action', typeAttributes: { rowActions: actions } },
        ]);
        component.set('v.applicantData', [
            {Id: '0', Score: '…', LastName: '…', FirstName: '…', BirthDate: '…', BirthCountry: '…', Gender: '…', SchoolCode: '…'},
        ]);
        component.set('v.searchAccColumns', [
            {label: 'Name', fieldName: 'name', type: 'text'},
            {label: 'Address', fieldName: 'address', type: 'text'},
            {label: 'Parent Account', fieldName: 'parentAcc', type: 'text'},
            { type: 'action', typeAttributes: { rowActions: [{ label: 'View Details', name: 'details' }] } },
        ]);
        component.set('v.entityColumns', [
            {label: 'Score', fieldName: 'Score', type: 'percentage'},
            {label: 'Name', fieldName: 'SchoolName', type: 'text'},
            {label: 'Medschool Code', fieldName: 'SchoolCode', type: 'text'},
            {label: 'Institution ID', fieldName: 'InstitutionId', type: 'text'},
            {label: 'City', fieldName: 'City', type: 'text'},
            {label: 'Country', fieldName: 'Country', type: 'text'},
            { type: 'action', typeAttributes: { rowActions: actions } },
        ]);
        component.set('v.entityData', [
            {Id: '0', Score: '…', SchoolCode: '…', SchoolName: '…', City: '…', Country: '…', InstitutionId: '…', InstitutionName: '…'},
        ]);
        //Following code is added by Shailaja Yerneni. 1/4/2021. User Story#850
        component.set('v.akaNamesColumns', [
            {label: 'Score', fieldName: 'Score', type: 'percentage'},
            {label: 'Name', fieldName: 'Name', type: 'text'},
            {label: 'Account Name', fieldName: 'AccountName', type: 'text'},
            { type: 'action', typeAttributes: { rowActions: akaActions } },
        ]);
        component.set('v.akaNamesData', [
            {Id: '0', Score: '…', Name: '…', AccountName: '…'},
        ]);
        component.set("v.applicantSectionLabel", helper.format(component.get("v.applicantSectionLabelTemplate"), component.get("v.applicantMatchCount")));
        component.set("v.entitySectionLabel", helper.format(component.get("v.entitySectionLabelTemplate"), component.get("v.entityMatchCount")));
        component.set("v.showCreateApplicantButton", true);
		// set default text for linked applicant and entity
        component.set("v.linkedApplicantName", component.get("v.linkedPlaceholder"));
        component.set("v.linkedEntityName", component.get("v.linkedPlaceholder"));
        var caseId = component.get("v.recordId");
		if(caseId) {
			helper.getAndPopulateLinkedApplicant(component, helper);
			helper.getAndPopulateLinkedEntity(component, helper);
			helper.getVerificationRequest(component, helper, caseId);
            helper.getEntityServiceRequest(component, helper, caseId);
            helper.getConfirmationMessage(component, helper, caseId);
            //Following code is added by Shailaja Yerneni. 1/4/2021. User Story#850
            helper.getAndPopulateAKANames(component, helper, caseId);
        }
        else {
            // make sure we have a recordId set by container
            $A.get("e.c:NotificationEvent").setParams({errorMessage : "This component is intended to be used on record pages. Please provide a recordId (case id)."}).fire();
        }
    },
            
    /*  
        This Method will get the Search Results
     */ 
    getEntitiesSearchResult: function(component){
        var action =component.get("c.fetchEntityData");
        action.setParams({
            "searchKey" : component.get("v.searchKey")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var result = JSON.parse(response.getReturnValue());
                component.set("v.entitylist", result);
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "No records found.",
                    "type": "error"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },

    linkCaseEntityHelper: function(component, helper){
        var action = component.get("c.linkEntity");
        action.setParams({
            "caseId" : component.get("v.recordId"),
            "accountId" : component.get("v.selectedAccountRecId")
        });
        action.setCallback(this, function(resp){
            var state = resp.getState();
            if(state === 'SUCCESS'){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Case entity is linked successfully.",
                    "type": "success"
                });
                toastEvent.fire();
                var entities = [];
            	component.set("v.entitylist", entities);
                component.set("v.selectedAccountRecId", '');
        		component.set("v.searchKey",'');
                this.initialize(component, helper);
                component.set("v.showSearchButton",false);
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "No records found.",
                    "type": "error"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
            
	/*
		This method will get the case and set the linked applicant and entity fields.
	*/
    getCaseAndPopulateLinkedApplicantAndEntity : function(component, helper) {
        // setup params and do pre-processing
		var params = { caseId: component.get("v.recordId") };
        return helper.apex(component, helper, "getCase", params)
            .then(
                (result) => {
                    component.set("v.case", result);
                    // return the case
                    return result;
            });
    },
    
	/*
		This method will return the case as a promise.
	*/
    getCase : function(component, helper) {
        // setup params and do pre-processing
		var params = { caseId: component.get("v.recordId") };
        return helper.apex(component, helper, "getCase", params);
    },

    getApplicantMatches : function(component, helper) {
        // setup params and do pre-processing
		var params = { caseId: component.get("v.recordId") };
        return helper.apex(component, helper, "getApplicantMatches", params)
            .then(
                (result) => {
                    return result;
            });
    },

	/*
		Returns the entity (account) matches.
	*/
    getEntityMatches : function(component, helper) {
        // setup params and do pre-processing
		var params = { caseId: component.get("v.recordId") };
        return helper.apex(component, helper, "getEntityMatches", params)
            .then(
                (result) => {
                    return result;
            });
    },

    //Following code is added by Shailaja Yerneni. 1/4/2021. User Story#850
    /*
		Returns the AKANames matches.
	*/
    getAKANamesMatches : function(component, helper) {
        // setup params and do pre-processing
		var params = { caseId: component.get("v.recordId") };
        return helper.apex(component, helper, "getAKANamesMatches", params)
            .then(
                (result) => {
                    return result;
            });
    },

	linkApplicant : function(component, helper, id) {
        // setup params and do pre-processing
		var params = { caseId: component.get("v.recordId"), contactId : id };
        return helper.apex(component, helper, "linkApplicant", params)
            .then(
                () => {
					// setup the applicant matches sections as appropriate
					helper.getAndPopulateLinkedApplicant(component, helper);
            });
	},

	unlinkApplicant : function(component, helper) {
        // setup params and do pre-processing
		var params = { caseId: component.get("v.recordId") };
        return helper.apex(component, helper, "unlinkApplicant", params)
            .then(
                () => {
					component.set("v.showLinkApplicantButton", false);
					component.set("v.showUnlinkApplicantButton", false);
					component.set("v.showCreateApplicantButton", true);
					// setup the applicant matches sections as appropriate
					helper.getAndPopulateLinkedApplicant(component, helper);
            });
	},

	/*
		Creates a new applicant using data from verification request and links it to the case.
	*/
	createAndLinkApplicant : function(component, helper, id) {
	    //debugger;
        // setup params and do pre-processing
		var params = { caseId: component.get("v.recordId") };
        return helper.apex(component, helper, "createLinkApplicant", params)
            .then(
                (result) => {
					// setup the applicant matches sections as appropriate
					helper.getAndPopulateLinkedApplicant(component, helper);
            });
	},

	linkEntity : function(component, helper, id) {
        // setup params and do pre-processing
        var params = { caseId: component.get("v.recordId"), accountId : id };
           return helper.apex(component, helper, "linkEntity", params)
               .then(
                   () => {
                    // setup the entity matches sections as appropriate
                    helper.getAndPopulateLinkedEntity(component, helper);
               });
    },

	unlinkEntity : function(component, helper) {
         // setup params and do pre-processing
        var params = { caseId: component.get("v.recordId") };
         return helper.apex(component, helper, "unlinkEntity", params)
             .then(
                 () => {
                    component.set("v.showLinkEntityButton", false);
                    component.set("v.showUnlinkEntityButton", false);
                    // show/hide Request New button/alert as appropriate
                    if(component.get("v.entityServiceRequest")) {
                        component.set("v.showNewEntityButton", false);
                    }
                    else {
                        component.set("v.showNewEntityButton", true);
                    }
                    // setup the entity matches sections as appropriate
                    helper.getAndPopulateLinkedEntity(component, helper);
             });
    },

    /*
        Handles the creating of a new entity service request.
        Returns the newly created entity service request.
    */
	newEntity : function(component, helper) {
         // setup params and do pre-processing
        var params = { caseId: component.get("v.recordId") };
        return helper.apex(component, helper, "createEntityRequest", params);
    },

	/*
		Returns the verification request record.
	*/
    getVerificationRequest : function(component, helper, id) {
        // setup params and do pre-processing
		var params = { caseId: id };
        return helper.apex(component, helper, "getVerificationRequest", params)
            .then(
                (result) => {
                    component.set("v.verificationRequest", result);
            });
    },

	/*
		Returns the verification request record and shows/hides Request New button.
	*/
    getEntityServiceRequest : function(component, helper, id) {
        // setup params and do pre-processing
		var params = { caseId: id };
        return helper.apex(component, helper, "getEntityServiceRequest", params)
            .then(
                (result) => {
                    component.set("v.entityServiceRequest", result);
                    // show/hide Request New button
                    if(result) {
                        component.set("v.showNewEntityButton", false);
                    }
                    else {
                        component.set("v.showNewEntityButton", true);
                    }
            });
    },

	/*
		Returns the applicant (contact) record.
	*/
    getApplicant : function(component, helper, id) {
        // setup params and do pre-processing
		var params = { contactId: id };
        return helper.apex(component, helper, "getContact", params)
            .then(
                (result) => {
                    return result;
            });
    },

	/*
		Returns the entity (account) record.
	*/
    getEntity : function(component, helper, id) {
        // setup params and do pre-processing
		var params = { accountId: id };
        return helper.apex(component, helper, "getAccount", params)
            .then(
                (result) => {
                    return result;
            });
    },

    getLinkedEntityId : function(component, helper) {
        // setup params and do pre-processing
		var params = { caseId: component.get("v.recordId") };
        return helper.apex(component, helper, "getLinkedEntityId", params)
            .then(
                (result) => {
                    return result;
            });
    },

    /*
        This method returns the linked applicant (contact) as a promise.
        It also sets the linked applicant label, handles showing/hiding the applicant section buttons, and populates the
        the applicant table.
    */
    getAndPopulateLinkedApplicant : function(component, helper) {
        // get the case
        helper.getCase(component, helper)
            .then(
                (result) => {
                    if(result && result.ContactId) {
                        // if we are here, the linked applicant was found and returned
						component.set("v.applicantSectionLabel", component.get("v.applicantLinkedSectionLabel"));
						helper.getApplicant(component, helper, result.ContactId)
			                .then(
			                    (result) => {
			                        // set the linked applicant object
			                        component.set("v.linkedApplicant", result);
			                        // set the linked applicant name
			                        component.set("v.linkedApplicantName", result.Name);
			                        // setup button visibility
									component.set("v.showLinkApplicantButton", false);
									component.set("v.showUnlinkApplicantButton", true);
									component.set("v.showCreateApplicantButton", false);
									// set linked applicant table data
							        component.set('v.applicantData', [
							            {Id: result.Id, Score: component.get("v.scoreNotAvailablePlaceholder"), LastName: result.LastName, RestOfName: result.FirstName, BirthDate: result.Birthdate, BirthCountry: result.Birth_Country__c, Gender: result.Gender__c, MedschoolCode: result.Medschool_Code__c}
							        ]);
							        // hide the checkbox for linked entity
							        component.find("applicantTable").set("v.hideCheckboxColumn", true);
							        // returns the applicant (contact)
							        return result;
			                 });
                    }
                    else {
                        // clear the linked applicant object and name
                        component.set("v.linkedApplicant", null);
                        component.set("v.linkedApplicantName", component.get("v.linkedPlaceholder"));
                        // populate applicant matches
						helper.getApplicantMatches(component, helper)
							.then((result) => {
							    if(result) {
							        // format score with % sign
							        for(var i = 0; i < result.length; i++) {
							            result[i].Score = result[i].Score + '%';
			                        }
			                        // set applicant table data
							        component.set("v.applicantData", result);
							        component.set("v.applicantMatchCount", result.length);
							        component.set("v.applicantSectionLabel", helper.format(component.get("v.applicantSectionLabelTemplate"), component.get("v.applicantMatchCount")));
							        // show checkboxes
							        if(result.length > 0 ) component.find("applicantTable").set("v.hideCheckboxColumn", false);
							        // clear previously selected row
							        component.set("v.applicantSelectedRows", []);
						        }
						    });
                        // no applicant linked, so return null
                        return null;
                    }
                }
            );
    },

    /*
        This method returns the linked entity (account) as a promise.
        It also sets the linked entity label, handles showing/hiding the entity section buttons, and populates the
        the entity table.
    */
    getAndPopulateLinkedEntity : function(component, helper) {
        // get the linked entity id
		var params = { caseId: component.get("v.recordId") };
        return helper.apex(component, helper, "getLinkedEntityId", params)
            .then(
                (result) => {
                    // if there's a linked entity...
                    if(result) {
                        // if we are here, the linked entity id attribute/value was found and returned
						component.set("v.entitySectionLabel", component.get("v.entityLinkedSectionLabel"));
						return helper.getEntity(component, helper, result)
			                .then(
			                    (result) => {
			                        // it is possible for someone to tamper with the linked entity id in case attributes and the result could be null
			                        if(result) {
				                        // set the linked entity object
				                        component.set("v.linkedEntity", result);
								        // set the linked entity name
								        component.set("v.linkedEntityName", result.Name);
			                            // setup button visibility
										component.set("v.showLinkEntityButton", false);
										component.set("v.showUnlinkEntityButton", true);
										component.set("v.showNewEntityButton", false);
										// set linked entity table data
								        component.set('v.entityData', [
								            {Id: result.Id, Score: component.get("v.scoreNotAvailablePlaceholder"), SchoolCode: result.Medschool_Code__c, SchoolName: result.Name, Country: result.BillingCountry, City: result.BillingCity, InstitutionId: result.Insitution_ID__c , InstitutionName: result.Name},
								        ]);
								        // hide the checkbox for linked entity
								        component.find("entityTable").set("v.hideCheckboxColumn", true);
								        // returns the entity (account)
								        return result;
                                    }
			                 });
                    }
                    else {
                        // clear the linked entity object and name
                        component.set("v.linkedEntity", null);
                        component.set("v.linkedEntityName", component.get("v.linkedPlaceholder"));
                        // populate entity matches
						helper.getEntityMatches(component, helper)
							.then((result) => {
							    if(result) {
							        // format score with % sign
							        for(var i = 0; i < result.length; i++) {
							            result[i].Score = result[i].Score + '%';
			                        }
			                        // set entity table data
							        component.set("v.entityData", result);
							        component.set("v.entityMatchCount", result.length);
							        component.set("v.entitySectionLabel", helper.format(component.get("v.entitySectionLabelTemplate"), component.get("v.entityMatchCount")));
							        // show checkboxes
							        if(result.length > 0 ) component.find("entityTable").set("v.hideCheckboxColumn", false);
							        // clear previously selected row
							        component.set("v.entitySelectedRows", []);
						        }
						    });
						// no entity linked, so return null
						return null;
                    }
            });
    },

    //Following code is added by Shailaja Yerneni. 1/4/2021. User Story#850
    /*
        It  populates the AKANames table.
    */
   getAndPopulateAKANames : function(component, helper, id) {
        // setup params and do pre-processing
        var params = { caseId: id };
        helper.apex(component, helper, "getAKANamesMatches", params)
        .then((result) => {
            if(result) {                
                // format score with % sign
                for(var i = 0; i < result.length; i++) {
                    result[i].Score = result[i].Score + '%';
                }
                component.set("v.akaNamesData", result);
                component.set("v.akaNamesMatchCount", result.length);
                component.set("v.akaNamesSectionLabel", helper.format(component.get("v.akaNamesSectionLabelTemplate"), component.get("v.akaNamesMatchCount")));
                // show checkboxes
                if(result.length > 0 ) component.find("akaNamesTable").set("v.hideCheckboxColumn", false);
                // clear previously selected row
                component.set("v.akaNamesSelectedRows", []);
            }
        });
   },

    proceed : function(component, helper) {
        // setup params and do pre-processing
		var params = { caseId: component.get("v.recordId") };
        return helper.apex(component, helper, "proceed", params)
            .then(
                (result) => {
                    return result;
            });
    },

	compareHighlightDifferent : function(component, helper) {
   	    // clears selected
   		component.set("v.compareSelectedRows", []);
		var compareData = component.get("v.compareData");
		var compareSelectedRows = component.get("v.compareSelectedRows");
		for(var i = 0; i < compareData.length; i++) {
			if(helper.nullSafe(compareData[i].Request).toLowerCase() !== helper.nullSafe(compareData[i].Match).toLowerCase()) {
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
			if(helper.nullSafe(compareData[i].Request).toLowerCase() === helper.nullSafe(compareData[i].Match).toLowerCase()) {
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
		Returns the confirmation message.
	*/
    getConfirmationMessage : function(component, helper, id) {
        // setup params and do pre-processing
        var params = { caseId: id };
        return helper.apex(component, helper, "getConfirmationMsg", params)
            .then(
                (result) => {
                    component.set("v.confirmationMsg", result);
            });
    },
    /*
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