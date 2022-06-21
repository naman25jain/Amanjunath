({
	getUrlParameter: function (sParam) {
		var sPageURL = decodeURIComponent(window.location.search.substring(1)),
			sURLVariables = sPageURL.split('&'),
			sParameterName,
			i;

		for (i = 0; i < sURLVariables.length; i++) {
			sParameterName = sURLVariables[i].split('=');

			if (sParameterName[0] === sParam) {
				return sParameterName[1] === undefined ? true : sParameterName[1];
			}
		}
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

	handleUrlParams: function (component, event, helper) {

		// TODO: Make generic param handler, without hard-coding specific param(s).
		var parsedUrl = new URL(window.location.href);
		var service = parsedUrl.searchParams.get("service");
		component.set("v.service", service);
		var mode = parsedUrl.searchParams.get("mode");
		component.set("v.mode", mode);
		if (component.get("v.mode") && component.get("v.mode").toLowerCase() == "summary") {
			component.set("v.showBackToSummary", true);
		} else {
			component.set("v.showBackToSummary", false);
		}
	},

	/*
	    This will remove passport expiration photo and english photo if no longer needed (Yes is selected)
	*/
	removeUnnecessaryFiles: function (component, event, helper) {
		// remove expiring photo if passport includes expiring date
		if (component.get("v.passportExpirationId") != null && (component.get("v.Passport_Photo_Includes_Expiration_Date__c") == true || component.get("v.Passport_Photo_Includes_Expiration_Date__c") == "true" || component.get("v.contact.Passport_Photo_Includes_Expiration_Date__c") == true || component.get("v.contact.Passport_Photo_Includes_Expiration_Date__c") == "true")) {
			helper.removeFileFromServer(component, component.get("v.passportExpirationId"));
		}
		// remove translation photo if passport in english
		if (component.get("v.passportTranslationId") != null && (component.get("v.Passport_Photo_Is_In_English") == true || component.get("v.Passport_Photo_Is_In_English") == "true" || component.get("v.contact.Passport_Photo_Is_In_English") == true || component.get("v.contact.Passport_Photo_Is_In_English") == "true")) {
			helper.removeFileFromServer(component, component.get("v.passportTranslationId"));
		}
	},

	removeFileFromServer: function (component, fileId) {
		var removeFile = component.get("c.removeFile");
		removeFile.setParam("fileId", fileId);
		removeFile.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				// nothing to do here right now
			} else {
				// nothing to do here right now
			}
		});
		$A.enqueueAction(removeFile);
	},


	initializePreviouslyVerified: function (component, contact) {
		if (contact.Previous_EICS_ID__c == true) {
			component.set("v.previouslyVerifiedProxy", "true");
		} else {
			component.set("v.previouslyVerifiedProxy", "false");
		}
	},

	initializePreviouslyApplied: function (component, contact) {
		if (contact.Previous_ECFMG_Cert_or_Examination__c == true) {
			component.set("v.previouslyAppliedProxy", "true");
		} else {
			component.set("v.previouslyAppliedProxy", "false");
		}
	},

	initializePreviouslyEPIC: function (component, contact) {
		if (contact.Previous_EPIC_Services__c == true) {
			component.set("v.previouslyEPICProxy", "true");
		} else {
			component.set("v.previouslyEPICProxy", "false");
		}
		// never show yes or id field on summary page
		if (component.get("v.readOnlyMode") || (component.get("v.mode") && component.get("v.mode").toLowerCase() == "summary")) {
			component.set("v.previouslyEPICProxy", "false");
			component.set("v.Previous_EPIC_Services", false);
		}
	},
	//New Code.#User story 890
	validatePreviouslyUSMLEID: function (component, event, helper) {
		var prevUSMLEID = helper.findComponentByName("fieldToValidate", "usmleId", component);
		prevUSMLEID.setCustomValidity("");
		if(prevUSMLEID.reportValidity()){
			prevUSMLEID.setCustomValidity("");
		}
		//validate usmle
		var tempUSMLEID = '';
		if (component.get("v.contact.Previous_ECFMG_Cert_or_Examination__c") == true) {
			tempUSMLEID = component.get("v.contact.Applicant_Provided_USMLE_ID__c");
			//call the apex class
			var validatePrevUSMLEID = component.get("c.validatePrevUSMLEID");
			validatePrevUSMLEID.setParams({
				"prevUSMLEID": tempUSMLEID
			});
			validatePrevUSMLEID.setCallback(this, function (response) {
				var state = response.getState();
				if (state === "SUCCESS") {
					var validUSMLEID = response.getReturnValue();
					if(validUSMLEID){
						prevUSMLEID.setCustomValidity("");
					}else{
						prevUSMLEID.setCustomValidity("Please enter a valid USMLE ID.");
						prevUSMLEID.reportValidity();
					}
				}
				else if (state === "ERROR") {
					var errors = response.getError();
					if (errors && errors[0] && errors[0].message) {
						console.log("Error message: " + errors[0].message);
					}
				}
			});
			$A.enqueueAction(validatePrevUSMLEID);			
		}
	},
	saveTest: function (component, event, helper, url, isNext) {
		// disable buttons to prevent multiple clicks
		component.set("v.disableButtons", true);
		// clear rest of name if having only one name
		if (component.get("v.contact.legal_name_consists_of_one_name_only__c") == true) {
			component.set("v.contact.FirstName", "");
		}
		var hasErrors = false;
		var allValid = component.find("fieldToValidate");
		for (var x = 0; x < allValid.length; x++) {
			if (!allValid[x].get("v.validity").valid) {
				allValid[x].showHelpMessageIfInvalid();
				hasErrors = true;
			}
		}
		if (!component.find("submitAddress").validate()) hasErrors = true;
		/////// Lightning select Validations ///////
		var passportCountryVar = helper.findComponentByName("fieldToValidate", "passportCountry", component);
		if (component.get("v.contact.Passport_Country__c") == 'Select..' || !component.get("v.contact.Passport_Country__c")) {
			$A.util.addClass(passportCountryVar, "slds-has-error");
			hasErrors = true;
		} else {
			$A.util.removeClass(passportCountryVar, "slds-has-error");
		}
		var birthCountryVar = helper.findComponentByName("fieldToValidate", "birthCountry", component);
		if (component.get("v.contact.Birth_Country__c") == 'Select..' || !component.get("v.contact.Birth_Country__c")) {
			$A.util.addClass(birthCountryVar, "slds-has-error");
			hasErrors = true;
		} else {
			$A.util.removeClass(birthCountryVar, "slds-has-error");
		}
		var birthCitizenshipVar = helper.findComponentByName("fieldToValidate", "citizenshipAtBirthCountry", component);
		if (component.get("v.contact.Citizenship_at_Birth__c") == 'Select..' || !component.get("v.contact.Citizenship_at_Birth__c")) {
			$A.util.addClass(birthCitizenshipVar, "slds-has-error");
			hasErrors = true;
		} else {
			$A.util.removeClass(birthCitizenshipVar, "slds-has-error");
		}
		var photoId = component.get("v.photoUploaded");
		var ppId = component.get("v.passportUploaded");
		if (photoId == 'No') {
			hasErrors = true;
			component.set("v.showPhotoError", true);
		} else {
			component.set("v.showPhotoError", false);
		}
		if (ppId == 'No') {
			hasErrors = true;
			component.set("v.showPassportError", true);
		} else {
			component.set("v.showPassportError", false);
		}
		if (component.get("v.passport_Photo_Includes_Expiration_Date") == false || component.get("v.passport_Photo_Includes_Expiration_Date") == 'false') {
			if (component.get("v.passportExpirationDone") == 'No') {
				hasErrors = true;
			}			
		}
		if (component.get("v.Passport_Photo_Is_In_English") == false || component.get("v.Passport_Photo_Is_In_English") == 'false') {
			if (component.get("v.passportTranslationDone") == 'No') {
				hasErrors = true;
			}
		}
		helper.removeUnnecessaryFiles(component, event, helper);
		if ((!hasErrors && isNext) || !isNext) {
			var contact = component.get("v.contact");
			if (contact.Citizenship_Upon_Entering_Medical_School__c == 'None') contact.Citizenship_Upon_Entering_Medical_School__c = '';
			if (contact.Passport_Issue_Date__c == null) contact.Passport_Issue_Date__c = '';
			if (contact.Passport_Expiration__c == null) contact.Passport_Expiration__c = '';
			var contactStr = JSON.stringify(contact);
			var updteContact = component.get("c.updateContact");
			updteContact.setParams({
				"contactId": contact.Id,
				"contactJSON": contactStr
			});
			updteContact.setCallback(this, function (response) {
				var state = response.getState();
				if (state === "SUCCESS") {
					var contactRec = response.getReturnValue();
					
					//User story#897. If it is valid USMLE_ID let user the procced.
					//if (((contact.Previous_EPIC_Services__c == true || contact.Previous_EPIC_Services__c == "true")) || ((contact.Previous_ECFMG_Cert_or_Examination__c == "true" || contact.Previous_ECFMG_Cert_or_Examination__c == true))) {
					if (((contact.Previous_EPIC_Services__c == true || contact.Previous_EPIC_Services__c == "true"))) {
						component.set("v.showExistingAccount", true);
					} else {
						if (url) window.open(url, '_top');
					}
					component.set("v.disableButtons", false);
				} else if (state === "ERROR") {
					var errors = response.getError();
					if (errors && errors[0] && errors[0].message) {
						console.log("Error message: " + errors[0].message);
					}
				} else {
					console.log("Unknown error");
				}
			});
			$A.enqueueAction(updteContact);
			var parsedUrl = new URL(window.location.href);
			var serviceName = parsedUrl.searchParams.get("service");
			var params = {
				"service": serviceName,
				"validationPassed": !hasErrors
			};
			helper.apex(component, helper, "createCaseAndAssetsV2", params)
				.then(() => {
					if (!(((contact.Previous_EPIC_Services__c == true || contact.Previous_EPIC_Services__c == "true")) || ((contact.Previous_ECFMG_Cert_or_Examination__c == "true" || contact.Previous_ECFMG_Cert_or_Examination__c == true)))) {
						var toast = $A.get("e.force:showToast");
						toast.setParams({
							"title": "Success!",
							"type": "success",
							"message": "Your biographic information has been saved."
						});
						toast.fire();
					}
				})
				.then(() => {
					if (serviceName == 'J1') {
						return helper.apex(component, helper, "closeJ1InviteCase");
					}
				});
		
		} else {
			// enable buttons
			component.set("v.disableButtons", false);
			// complain
			var toast = $A.get("e.force:showToast");
			toast.setParams({
				"title": "Error!",
				"type": "error",
				"message": "You must complete all required fields before proceeding."
			});
			toast.fire();
		}
	},

	apex: function (component, helper, apexAction, params) {
		var p = new Promise($A.getCallback(function (resolve, reject) {
			var action = component.get("c." + apexAction + "");
			if (params) action.setParams(params);
			action.setCallback(this, function (callbackResult) {
				if (callbackResult.getState() == "SUCCESS") {
					resolve(callbackResult.getReturnValue());
				} else {
					helper.handleError(callbackResult);
					reject(callbackResult);
				}
			});
			$A.enqueueAction(action);
		}));
		return p;
	},
})