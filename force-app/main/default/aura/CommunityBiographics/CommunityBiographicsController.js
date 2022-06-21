({
	doInit: function (component, event, helper) {

		helper.handleUrlParams(component, event, helper);

		var getConId = component.get("c.getContactId");
		getConId.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var conId = response.getReturnValue();
				component.set("v.contactId", conId);
				var createPassportTranslationPayload = component.get("c.createPassportTranslationPayload");
				createPassportTranslationPayload.setParams({
					"contactId": conId
				});
				createPassportTranslationPayload.setCallback(this, function (payLoadResponse) {
					var payLoadState = payLoadResponse.getState();
					if (payLoadState === "SUCCESS") {
						var payload = payLoadResponse.getReturnValue();
						if (payload.assetId !== null && payload.assetId !== undefined) {
							component.set("v.passportTranslationDone", "Yes");
						}
						component.set("v.payloadPassportTranslation", JSON.stringify(payload));
						if(component.get("v.contact").Passport_Photo_Is_In_English__c === true){

							var deleteExistingAsset = component.get("c.deleteExistingAsset");
							component.set("v.passportTranslationDone", "No");
							deleteExistingAsset.setParams({
								'contactId': conId
							});
							deleteExistingAsset.setCallback(this, function (deleteResponse) {
								var deleteState = deleteResponse.getState();
								if (deleteState === "ERROR") {
									var deleteErrors = deleteResponse.getError();
									if (deleteErrors && deleteErrors[0] && deleteErrors[0].message) {
										console.log("Error message: " + deleteErrors[0].message);
									}
								} 
							});
							$A.enqueueAction(deleteExistingAsset);
						}
						if(component.get("v.contact").Passport_Photo_Is_In_English__c !== true){
							component.find('passportTranslation').auraThumbnailLoader();
						}

					} else if (payLoadState === "ERROR") {
						var payLoadErrors = payLoadResponse.getError();
						if (payLoadErrors && payLoadErrors[0] && payLoadErrors[0].message) {
							console.log("Error message: " + payLoadErrors[0].message);
						}
					} else {
						console.log("Unknown error");
					}
				});
				$A.enqueueAction(createPassportTranslationPayload);

				var createPassportPayload = component.get("c.createPassportPayload");
				createPassportPayload.setParams({
					"contactId": conId
				});
				createPassportPayload.setCallback(this, function (passportPayloadResponse) {
					var passportPayloadState = passportPayloadResponse.getState();
					if (passportPayloadState === "SUCCESS") {
						var passportPayload = passportPayloadResponse.getReturnValue();
						if (passportPayload.assetId !== null && passportPayload.assetId !== undefined) {
							component.set("v.passportUploaded", "Yes");
						}
						component.set("v.payloadPassport", JSON.stringify(passportPayload));
						component.find('passport').auraThumbnailLoader();
						

					}else if (passportPayloadState === "ERROR") {
						var passportPayloadErrors = passportPayloadResponse.getError();
						if (passportPayloadErrors && passportPayloadErrors[0] && passportPayloadErrors[0].message) {
							console.log("Error message: " + passportPayloadErrors[0].message);
						}
					} else {
						console.log("Unknown error");
					}
				});
				$A.enqueueAction(createPassportPayload);

				var createPhotoPayload = component.get("c.createPhotoPayload");
				createPhotoPayload.setParams({
					"contactId": conId
				});
				createPhotoPayload.setCallback(this, function (photoPayloadResponse) {
					var photoPayloadState = photoPayloadResponse.getState();
					if (photoPayloadState === "SUCCESS") {
						var photoPayload = photoPayloadResponse.getReturnValue();
						if (photoPayload.assetId !== null && photoPayload.assetId !== undefined) {
							component.set("v.photoUploaded", "Yes");
						}
						component.set("v.payloadPhoto", JSON.stringify(photoPayload));
						component.find('photo').auraThumbnailLoader();

					}else if (photoPayloadState === "ERROR") {
						var photoPayloadErrors = photoPayloadResponse.getError();
						if (photoPayloadErrors && photoPayloadErrors[0] && photoPayloadErrors[0].message) {
							console.log("Error message: " + photoPayloadErrors[0].message);
						}
					} else {
						console.log("Unknown error");
					}
				});
				$A.enqueueAction(createPhotoPayload);

				var createPassportExpirationPayload = component.get("c.createPpExpPayload");
				createPassportExpirationPayload.setParams({
					"contactId": conId
				});
				createPassportExpirationPayload.setCallback(this, function (passportExpirationPayLoadResponse) {
					var passportExpirationPayLoadState = passportExpirationPayLoadResponse.getState();
					if (passportExpirationPayLoadState === "SUCCESS") {
						var passportExpirationPayload = passportExpirationPayLoadResponse.getReturnValue();
						if (passportExpirationPayload.assetId !== null && passportExpirationPayload.assetId !== undefined) {
							component.set("v.passportExpirationDone", "Yes");
						}
						component.set("v.payloadPassportExpiration", JSON.stringify(passportExpirationPayload));
						if(component.get("v.contact").Passport_Photo_Includes_Expiration_Date__c === true){
							var deleteExistingPassportExpirationAsset = component.get("c.deleteExistingPassportExpirationAsset");
							component.set("v.passportExpirationDone", "No");
							deleteExistingPassportExpirationAsset.setParams({
								'contactId': conId
							});
							deleteExistingPassportExpirationAsset.setCallback(this, function (dltResponse) {
								var dltState = dltResponse.getState();
								if (dltState === "ERROR") {
									var dltErrors = dltResponse.getError();
									if (dltErrors && dltErrors[0] && dltErrors[0].message) {
										console.log("Error message: " + dltErrors[0].message);
									}
								} 
							});
							$A.enqueueAction(deleteExistingPassportExpirationAsset);
						}
						if(component.get("v.contact").Passport_Photo_Includes_Expiration_Date__c !== true){
							component.find('passportExpiration').auraThumbnailLoader();
						}

					} else if (passportExpirationPayLoadState === "ERROR") {
						var passportExpirationPayLoadErrors = passportExpirationPayLoadResponse.getError();
						if (passportExpirationPayLoadErrors && passportExpirationPayLoadErrors[0] && passportExpirationPayLoadErrors[0].message) {
							console.log("Error message: " + passportExpirationPayLoadErrors[0].message);
						}
					} else {
						console.log("Unknown error");
					}
				});
				$A.enqueueAction(createPassportExpirationPayload);
								

			} else if (state === "ERROR") {
				var errors = response.getError();
				if (errors && errors[0] && errors[0].message) {
					console.log("Error message: " + errors[0].message);
				}
			} else {
				console.log("Unknown error");
			}
		});
		$A.enqueueAction(getConId);
		var getContactInfo = component.get("c.getContact");
		getContactInfo.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var contactRec = response.getReturnValue();
				component.set("v.contact", contactRec);
				//component.set("v.legal_name_consists_of_one_name_only", contactRec.legal_name_consists_of_one_name_only);
				component.set("v.passport_Photo_Includes_Expiration_Date", contactRec.Passport_Photo_Includes_Expiration_Date__c);
				component.set("v.Passport_Photo_Is_In_English", contactRec.Passport_Photo_Is_In_English__c);
				component.set("v.Previous_ECFMG_Cert_or_Examination", contactRec.Previous_ECFMG_Cert_or_Examination__c);
				component.set("v.Previous_EPIC_Services", contactRec.Previous_EPIC_Services__c);

				var countryDualSelect = contactRec.Current_Citizenship__c;
				if (countryDualSelect != undefined && countryDualSelect != null) {
					component.set("v.countryDualSelected", countryDualSelect.split(";"));
				}
				// handle proxied components due to radio button bug
				helper.initializePreviouslyVerified(component, contactRec);
				helper.initializePreviouslyApplied(component, contactRec);
				helper.initializePreviouslyEPIC(component, contactRec);
				// tell page is ready
				component.set("v.pageReady", true);
				////// set dropdown values ////////
				var passportDropDown = component.get("v.contact.Passport_Country__c");
				var birthCountryDropDown = component.get("v.contact.Birth_Country__c");
				if ($A.util.isUndefinedOrNull(birthCountryDropDown) || birthCountryDropDown == 'Select...') {
					component.set("v.birthCountyisNull", true)
				}
				var citizenshipBirthDropDown = component.get("v.contact.Citizenship__c");
				if ($A.util.isUndefinedOrNull(citizenshipBirthDropDown) || citizenshipBirthDropDown == 'Select...') {
					component.set("v.citizenshipAtBirthIsNull", true)
				}
				var citizenshipMedSchoolDropDown = component.get("v.contact.Citizenship_Upon_Entering_Medical_School__c");
				if ($A.util.isUndefinedOrNull(citizenshipMedSchoolDropDown) || citizenshipMedSchoolDropDown == 'Select...' || citizenshipMedSchoolDropDown == 'None') {
					component.set("v.citizenshipAtMedSchoolIsNull", true)
				}
			} else if (state === "ERROR") {
				var errors = response.getError();
				if (errors && errors[0] && errors[0].message) {
					console.log("Error message: " + errors[0].message);
				}
			} else {
				console.log("Unknown error");
			}
		});
		$A.enqueueAction(getContactInfo);

		var getCountryMetadata = component.get("c.getCountries");
		getCountryMetadata.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var allMetadata = response.getReturnValue();
				for (var i = 0; i < allMetadata.length; i++) {
					if (allMetadata[i] === "Select...") {
						allMetadata.splice(i, 1);
					}
				}
				var indexOfFirst = allMetadata.indexOf('break1');
				var indexOfSecond = allMetadata.indexOf('break2');
				var indexOfThird = allMetadata.indexOf('break3');
				var citizenBirthCountries = allMetadata.slice(0, indexOfFirst);
				var medSchoolCountries = allMetadata.slice(indexOfFirst + 1, indexOfSecond);
				var currentCountries = allMetadata.slice(indexOfSecond + 1, indexOfThird);
				var birthCountries = allMetadata.slice(indexOfThird + 1);
				//[{label : 'Afghanistan', value : 'Afghanistan'},

				var listOfObjects = [];
				var a = currentCountries.sort();
				a.forEach(function (entry) {
					var singleObj = {};
					singleObj['label'] = entry;
					singleObj['value'] = entry;
					if (entry != "Select...")
						listOfObjects.push(singleObj);
				});

				component.set("v.currentCitizenshipCountryDual", listOfObjects);
				component.set("v.citizenshipAtBirthCountry", citizenBirthCountries.sort());
				component.set("v.citizenshipUponEnteringMedSchoolCountry", medSchoolCountries.sort());
				component.set("v.currentCitizenshipCountry", currentCountries.sort());
				component.set("v.birthCountry", birthCountries.sort());
			} else if (state === "ERROR") {
				var errors = response.getError();
				if (errors && errors[0] && errors[0].message) {
					console.log("Error message: " + errors[0].message);
				}
			} else {
				console.log("Unknown error");
			}
		});
		$A.enqueueAction(getCountryMetadata);

		var curURL = new URL(window.location.href);
		var serviceName = curURL.searchParams.get("service");
		var getCaseInfo = component.get("c.getLatestCase");
		getCaseInfo.setParams({
			"service": serviceName
		});
		getCaseInfo.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var caseList = response.getReturnValue();
				if (caseList.length > 0) {
					var cse = caseList[0];
					component.set("v.validationError", !cse.ValidationPassed_Biographics__c);
				}
			} else if (state === "ERROR") {
				var errors = response.getError();
				if (errors && errors[0] && errors[0].message) {
					console.log("Error message: " + errors[0].message);
				}
			} else {
				console.log("Unknown error");
			}
		});
		$A.enqueueAction(getCaseInfo);
	},
	//New code added - Change Event for Date of Birth Validations - 
	checkDOBIfValid: function(component, event, helper){
		var bDate = helper.findComponentByName("fieldToValidate", "dateOfBirth", component);
		var birthDate = new Date(component.get("v.contact.Birthdate") + "T00:00:00");
		var curDate = new Date();		
		curDate.setHours(0, 0, 0, 0);
		var currYear = curDate.getFullYear();
		//For calculating the dob between 11 & 100 years old
		var dobPastElevenYears = Number(currYear)-11;
		var dobPastHundYears = Number(currYear)-100;
		var bMonth = birthDate.getMonth();
		var bDay =birthDate.getDate();
		var tempElevenBirthDate = new Date(dobPastElevenYears,bMonth,bDay);
		var tempHundBirthDate = new Date(dobPastHundYears,bMonth,bDay);
		if (birthDate >= curDate) {
			bDate.setCustomValidity("Date of Birth must be in the past.");
			bDate.reportValidity();
		}else if(birthDate > tempElevenBirthDate){
			bDate.setCustomValidity("Date of Birth should not be more recent than 11 years in the past.");
			bDate.reportValidity();
		}else if(birthDate < tempHundBirthDate){
			bDate.setCustomValidity("Date of Birth should not be greater than 100 years in the past.");
			bDate.reportValidity();
		}else{
			bDate.setCustomValidity("");
		}
	},
	//New code added - Change Event for PassportIssue Date Validations - 
	checkIssueDateIfValid: function(component, event, helper){
		var ppiDate = helper.findComponentByName("fieldToValidate", "passportIssueDate", component);
		var ppIssueDate = new Date(component.get("v.contact.Passport_Issue_Date__c") + "T00:00:00");
		var curDate = new Date();		
		curDate.setHours(0, 0, 0, 0);
		var currYear = curDate.getFullYear();
		var pastYear = Number(currYear)-20;
		var futureYear = Number(currYear)+20;
		var ppIssueMonth = ppIssueDate.getMonth();
		var ppIssueDay = ppIssueDate.getDate();
		var tempPPIssueDatePast = new Date(pastYear, ppIssueMonth, ppIssueDay);		
		if (ppIssueDate > curDate) {
			ppiDate.setCustomValidity("Passport Issue Date must be in the past.");
			ppiDate.reportValidity();
		}else if(ppIssueDate < tempPPIssueDatePast){////Issue Date cannot be older than 20 years in the past
			ppiDate.setCustomValidity("Passport Issue Date cannot be older than 20 years in the past.");
			ppiDate.reportValidity();
		}else {
			ppiDate.setCustomValidity("");
		}		
	},
	//New code added - Change Event for Passport Expiration Date Validations - 
	checkExpirationDateIfValid: function(component, event, helper){
		var ppExpirationDate = new Date(component.get("v.contact.Passport_Expiration__c") + "T00:00:00");
		var curDate = new Date();		
		curDate.setHours(0, 0, 0, 0);
		var currYear = curDate.getFullYear();
		var futureYear = Number(currYear)+20;
		var ppExpMonth = ppExpirationDate.getMonth();
		var ppExpDay = ppExpirationDate.getDate();
		var tempPPExpirationDateFuture = new Date(futureYear, ppExpMonth, ppExpDay);		
		var ppeDate = helper.findComponentByName("fieldToValidate", "passportExpiration", component);
		if (ppExpirationDate <= curDate) {
			ppeDate.setCustomValidity("Passport Expiration Date must be in the future.");
			ppeDate.reportValidity();
		}else if(ppExpirationDate > tempPPExpirationDateFuture){//Expiration Date cannot be greater than 20 years in the future		
			ppeDate.setCustomValidity("Passport Expiration Date cannot be greater than 20 years in the future.");
			ppeDate.reportValidity();
		}
		else {
			ppeDate.setCustomValidity("");
		}		
	},
	handleUploadFinishedPassport: function (component, event) {
		component.set("v.passportUploaded", "Yes");
	},

	handleUploadFinishedPhoto: function (component, event) {
		component.set("v.photoUploaded", "Yes");
	},

	handleUploadFinishedPassportExpiration: function (component, event) {
		component.set("v.passportExpirationDone", "Yes");
	},

	handleUploadFinishedPassportTranslation: function (component, event) {
		component.set("v.passportTranslationDone", "Yes");
	},

	handleLoad: function (component, event, helper) {},

	handleSubmit: function (component, event, helper) {},

	handleSuccess: function (component, event, helper) {
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			"title": "Success!",
			"message": "Your changes have been saved!",
			"type": "success"
		});
		toastEvent.fire();
		helper.showHide(component);
	},

	lastOnlyChange: function (component, event, helper) {
		var curVal = component.find("lastOnly").get("v.value");
		component.set("v.lastOnly", curVal);
	},

	epicChange: function (component, event, helper) {
		var curVal = component.find("epicBox").get("v.value");
		component.set("v.EPIC", curVal);
	},

	usmleChange: function (component, event, helper) {
		var curVal = component.find("usmleBox").get("v.value");
		component.set("v.USMLE", curVal);
	},

	countryChange: function (component, event, helper) {
		var curCountry = component.find("country").get("v.value");
		if (curCountry == 'US' || curCountry == 'USA' || curCountry == 'United States' || curCountry == 'United States of America' || curCountry == 'CA' || curCountry == 'Canada') {
			component.set("v.USorCA", true);
		} else {
			component.set("v.USorCA", false);
		}
	},

	handlePrevious: function (component, event, helper) {
		// disable buttons to prevent multiple clicks
		component.set("v.disableButtons", true);
		var parsedUrl = new URL(window.location.href);
		var serviceName = parsedUrl.searchParams.get("service");
		if (serviceName == "ECFMG_Certification") {
			window.open('/s/ecfmgcertsteps', '_top');
		} else if (serviceName == "GEMx") {
			window.open('/s/gemxsteps', '_top');
		} else if (serviceName == "J1") {
			window.open('/s/', '_top');
		} else {
			window.open('/s/epicsteps', '_top');
		}
	},

	handleCitizenshipChange: function (component, event, helper) {
		var sel = component.get("v.countryDualSelected");
		var txt = "";
		for (var x = 0; x < sel.length; x++) {
			txt += ";" + sel[x];
		}
		var contactRec = component.get("v.contact");
		component.set("v.contact.Current_Citizenship__c", txt.substring(1));
	},

	handleExpirationChecked: function (component, event, helper) {
		component.set("v.contact.Passport_Photo_Includes_Expiration_Date__c", event.getSource().get('v.value'));
		component.set("v.passport_Photo_Includes_Expiration_Date", event.getSource().get('v.value'));

		var payload = JSON.parse(component.get("v.payloadPassportExpiration"));
		payload.assetId = null;
		component.set("v.payloadPassportExpiration", JSON.stringify(payload));
		var conId = component.get("v.contactId");
		if (event.getSource().get('v.value') === "true") {
			var deleteExistingPassportExpirationAsset = component.get("c.deleteExistingPassportExpirationAsset");
			component.set("v.passportExpirationDone", "No");
			deleteExistingPassportExpirationAsset.setParams({
				'contactId': conId
			});
			deleteExistingPassportExpirationAsset.setCallback(this, function (response) {
				var state = response.getState();
				if (state === "ERROR") {
					var errors = response.getError();
					if (errors && errors[0] && errors[0].message) {
						console.log("Error message: " + errors[0].message);
					}
				}
			});
			$A.enqueueAction(deleteExistingPassportExpirationAsset);
		}
	},

	handleEnglishChecked: function (component, event, helper) {
		component.set("v.contact.Passport_Photo_Is_In_English__c", event.getSource().get('v.value'));
		component.set("v.Passport_Photo_Is_In_English", event.getSource().get('v.value'));
		var payload = JSON.parse(component.get("v.payloadPassportTranslation"));
		payload.assetId = null;
		component.set("v.payloadPassportTranslation", JSON.stringify(payload));
		var conId = component.get("v.contactId");
		if (event.getSource().get('v.value') === "true") {
			var deleteExistingAsset = component.get("c.deleteExistingAsset");
			component.set("v.passportTranslationDone", "No");
			deleteExistingAsset.setParams({
				'contactId': conId
			});
			deleteExistingAsset.setCallback(this, function (response) {
				var state = response.getState();
				if (state === "ERROR") {
					var errors = response.getError();
					if (errors && errors[0] && errors[0].message) {
						console.log("Error message: " + errors[0].message);
					}
				}
			});
			$A.enqueueAction(deleteExistingAsset);
		}
	},

	handleInputOnBlur: function (component, event, helper) {
		var field = event.getSource();
		if (field.get("v.value") && typeof field.get("v.value") == "string") field.set("v.value", field.get("v.value").trim());
	},

	handleExistingAccountOkButtonOnClick: function (component, event, helper) {
		component.set("v.showExistingAccount", false);
	},

	handleSave: function (component, event, helper) {
		helper.saveTest(component, event, helper, false);
	},

	handleNext: function (component, event, helper) {
		var url;
		if (component.get("v.service").toLowerCase() == 'ecfmg_certification') {
			url = '/s/medical-schools-ecfmg-cert?service=' + component.get("v.service");
		} else if (component.get("v.service").toLowerCase() == 'gemx') {
			url = '/s/medical-schools-gemx?service=' + component.get("v.service");
		} else {
			url = '/s/medical-schools?service=' + component.get("v.service");
		}
		helper.saveTest(component, event, helper, url, true);
	},
	handleSaveAndReturn: function (component, event, helper) {
		var url;
		// disable buttons to prevent multiple clicks
		component.set("v.disableButtons", true);
		if (component.get("v.service") && component.get("v.service").toLowerCase() == "epic") {
			url = helper.constants.SERVICE_EPIC_REVIEW_URL + '?service=' + component.get("v.service");
		} else if (component.get("v.service") && component.get("v.service").toLowerCase() == "ecfmg_certification") {
			url = helper.constants.SERVICE_CERT_REVIEW_URL + '?service=' + component.get("v.service");
		} else {
			url = helper.constants.COMMON_REVIEW_URL + '?service=' + component.get("v.service");
		}
		helper.saveTest(component, event, helper, url, true);
	},
	handleCancelAndReturn: function (component, event, helper) {
		// disable buttons to prevent multiple clicks
		component.set("v.disableButtons", true);
		if (component.get("v.service") && component.get("v.service").toLowerCase() == "epic") {
			window.open(helper.constants.SERVICE_EPIC_REVIEW_URL + '?service=' + component.get("v.service"), '_top');
		} else if (component.get("v.service") && component.get("v.service").toLowerCase() == "ecfmg_certification") {
			window.open(helper.constants.SERVICE_CERT_REVIEW_URL + '?service=' + component.get("v.service"), '_top');
		} else {
			window.open(helper.constants.COMMON_REVIEW_URL + '?service=' + component.get("v.service"), '_top');
		}
	},
	
	handlePreviouslyVerifiedOnChange: function (component, event, helper) {
		if (event.getSource().get('v.value') == "true") {
			component.set("v.contact.Previous_EICS_ID__c", true);
		} else {
			component.set("v.contact.Previous_EICS_ID__c", false);
		}
	},

	handlePreviouslyAppliedOnChange: function (component, event, helper) {
		if (event.getSource().get('v.value') == "true") {
			component.set("v.contact.Previous_ECFMG_Cert_or_Examination__c", true);
			component.set("v.Previous_ECFMG_Cert_or_Examination", true);
			// clicking yes should clear the id
			//component.set("v.contact.Applicant_Provided_USMLE_ID__c", "");
		} else {
			component.set("v.contact.Previous_ECFMG_Cert_or_Examination__c", false);
			component.set("v.Previous_ECFMG_Cert_or_Examination", false);
			// clicking No should clear the id - #Bugfix- 15084
			component.set("v.contact.Applicant_Provided_USMLE_ID__c", "");
			// new requirement per b2-14 is not clear the id fields if choosing no
		}
	},
	handleUSMLEChange: function(component, event, helper){
		var previouUsmleID = component.get("v.contact.Applicant_Provided_USMLE_ID__c");
		//reset custom validity
		var pUSMLEID = helper.findComponentByName("fieldToValidate", "usmleId", component);
		pUSMLEID.setCustomValidity("");
		if (event.getSource().get('v.value') != "") {
			//if there is a value validate the id. Pass the value entered by the user
			helper.validatePreviouslyUSMLEID(component, event, helper);
		}
	},
	handlePreviouslyEPICOnChange: function (component, event, helper) {
		if (event.getSource().get('v.value') == "true") {
			component.set("v.contact.Previous_EPIC_Services__c", true);
			component.set("v.Previous_EPIC_Services", true);
			// clicking yes should clear the id
			component.set("v.contact.Applicant_Provided_EPIC_ID__c", "");
		} else {
			component.set("v.contact.Previous_EPIC_Services__c", false);
			component.set("v.Previous_EPIC_Services", false);
			// new requirement per b2-14 is not clear the id fields if choosing no
		}
	},
})