({
	doInit  : function(component, event, helper) {
		var parsedUrl = new URL(window.location.href);
		var serviceName = parsedUrl.searchParams.get("service");
		var recordType;
		if (serviceName != null && (serviceName != "FCVS"||serviceName!="EICS")) {
			component.set("v.service", serviceName);
			recordType = "Identity Verification";
		}
		
		//Find the case record type =- Identity Verification or Applicant Bio Change
		var caseIdParam = parsedUrl.searchParams.get("id");
		if (caseIdParam != null) {
			component.set("v.caseId", caseIdParam);
			recordType = "Applicant Biographic Change";
		}
		var params = { "service": serviceName, "recordType": recordType };
		//New code - To get CaseId & CaseNumber
		helper.apex(component, helper, "getCaseNumberIDByServiceAndRecordType", params)
			.then( (result) => {
				component.set("v.caseId", result[0]);
				component.set("v.caseNumber", result[1]);
            });
		
		var getConId = component.get("c.getContactId");
		getConId.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var conId = response.getReturnValue();
				component.set("v.contactId", conId);

				// Get Previously Uploaded Photo (InComplete Asset)		
				var getIncompleteAssetPhotoPayload = component.get("c.createResumbitExistPhotoPayload");
				getIncompleteAssetPhotoPayload.setParams({
					"contactId": conId,
					"serviceName": serviceName
				});
				getIncompleteAssetPhotoPayload.setCallback(this, function (incompletePhotoPayloadResponse) {
					var  incompletePhotoPayloadState = incompletePhotoPayloadResponse.getState();
					if (incompletePhotoPayloadState === "SUCCESS") {
						var incompletePhotoPayload = incompletePhotoPayloadResponse.getReturnValue();
						if (incompletePhotoPayload.assetId !== null && incompletePhotoPayload.assetId !== undefined) {
							component.set("v.photoUploadedPrevious", "Yes");
						}
						component.set("v.payloadPhotoPrevious", JSON.stringify(incompletePhotoPayload));
						if(component.get("v.photoUploadedPrevious") == "Yes") {
							component.find('prephoto').auraThumbnailLoader();
						}
					} else if (incompletePhotoPayloadState === "ERROR") {
						var incompletePhotoPayloadErrors = incompletePhotoPayloadResponse.getError();
						if (incompletePhotoPayloadErrors && incompletePhotoPayloadErrors[0] && incompletePhotoPayloadErrors[0].message) {
							console.log("Error message: " + incompletePhotoPayloadErrors[0].message);
						}
					} else {
						console.log("Unknown error");
					}
				});
				$A.enqueueAction(getIncompleteAssetPhotoPayload);

				// Newly Created Photo
				var createPhotoPayload = component.get("c.createResumbitPhotoPayload");
				createPhotoPayload.setParams({
					"contactId": conId,
					"currentCaseId": component.get("v.caseId"),
					"serviceName": serviceName
				});
				createPhotoPayload.setCallback(this, function (photoPayloadResponse) {
					var photoPayloadState = photoPayloadResponse.getState();
					if (photoPayloadState === "SUCCESS") {
						var photoPayload = photoPayloadResponse.getReturnValue();
						if (photoPayload.assetId !== null && photoPayload.assetId !== undefined) {
							component.set("v.photoUploadedNew", "Yes");
						}
						component.set("v.payloadPhotoNew", JSON.stringify(photoPayload));
						if(component.get("v.photoUploadedNew") == "Yes") {
							component.find('photo').auraThumbnailLoader();
						}
					} else if (photoPayloadState === "ERROR") {
						var photoPayloadErrors = photoPayloadResponse.getError();
						if (photoPayloadErrors && photoPayloadErrors[0] && photoPayloadErrors[0].message) {
							console.log("Error message: " + photoPayloadErrors[0].message);
						}
					} else {
						console.log("Unknown error");
					}
				});
				$A.enqueueAction(createPhotoPayload);				

				// Previously Uploaded Passport - Asset Status InComplete or Verified - Identity Verification
				// Previously Uploaded Passport - Asset Status Invalidated - Biographic Chnage

				var createExistPassportPayload = component.get("c.createExistPassportPayload");
				createExistPassportPayload.setParams({
					"contactId": conId,
					"currentCaseId": component.get("v.caseId"),
					"serviceName": serviceName
				});
				createExistPassportPayload.setCallback(this, function (prepassportPayloadResponse) {
					var prepassportPayloadState = prepassportPayloadResponse.getState();
					if (prepassportPayloadState === "SUCCESS") {
						var prepassportPayload = prepassportPayloadResponse.getReturnValue();
						if (prepassportPayload.assetId) {
							component.set("v.passportUploaded", "Yes");
						}
						component.set("v.payloadPassportExisting", JSON.stringify(prepassportPayload));
						if(component.get("v.passportUploaded") == "Yes") {
							component.find('prepassport').auraThumbnailLoader();
						}
					}
					else if(prepassportPayloadState === "ERROR"){
						var payLoadErrorsPrePassport = payLoadErrorsPrePassport.getError();
						if (payLoadErrorsPrePassport && payLoadErrorsPrePassport[0] && payLoadErrorsPrePassport[0].message) {
							console.log("Error message: " + payLoadErrorsPrePassport[0].message);
						}
					}else{
						console.log("createExistPayload - Unknown error");
					}
				});
				$A.enqueueAction(createExistPassportPayload);
				// Previously Uploaded Passport Translation
				
				var createPassportTranslationPayloadExisting = component.get("c.passportTranslPayloadExist");
				createPassportTranslationPayloadExisting.setParams({
					"contactId": conId,
					"currentCaseId" : component.get("v.caseId"),
					"serviceName": serviceName
				});
				createPassportTranslationPayloadExisting.setCallback(this, function (payLoadResponsePreTranslate) {
					var payLoadStatePreTranslate = payLoadResponsePreTranslate.getState();
					if (payLoadStatePreTranslate === "SUCCESS") {
						var payloadExisting = payLoadResponsePreTranslate.getReturnValue();
						if (payloadExisting.assetId !== null && payloadExisting.assetId !== undefined) {
							component.set("v.passportTranslationDone", "Yes");
						}
						component.set("v.payloadPassportTranslationExisting", JSON.stringify(payloadExisting));

						if(component.get("v.passportTranslationDone") == "Yes"){
							component.find('prepassportTranslation').auraThumbnailLoader();
						}
					} else if (payLoadStatePreTranslate === "ERROR") {
						var payLoadErrorsPreTranslate = payLoadResponsePreTranslate.getError();
						if (payLoadErrorsPreTranslate && payLoadErrorsPreTranslate[0] && payLoadErrorsPreTranslate[0].message) {
							console.log("Error message: " + payLoadErrorsPreTranslate[0].message);
						}
					} else {
						console.log("Unknown error");
					}
				});
				$A.enqueueAction(createPassportTranslationPayloadExisting);

				// Previously Uploaded Passport Expiration
				var createPassportExpirationPayloadExisting = component.get("c.passportExpirePayloadExist");
				createPassportExpirationPayloadExisting.setParams({
					"contactId": conId,
					"currentCaseId": component.get("v.caseId"),
					"serviceName": serviceName
				});
				createPassportExpirationPayloadExisting.setCallback(this, function (payLoadResponsePreExpire) {
					var payLoadStatePreExpire = payLoadResponsePreExpire.getState();
					if (payLoadStatePreExpire === "SUCCESS") {
						var payloadPreExpire = payLoadResponsePreExpire.getReturnValue();
						if (payloadPreExpire.assetId !== null && payloadPreExpire.assetId !== undefined) {
							component.set("v.passportExpirationDone", "Yes");
						}
						component.set("v.payloadPassportExpirationExisting", JSON.stringify(payloadPreExpire));
						if(component.get("v.passportExpirationDone") == "Yes"){
							component.find('prepassportExpiration').auraThumbnailLoader();
						}
					} else if (payLoadStatePreExpire === "ERROR") {
						var payLoadErrorsPreExpire = payLoadResponsePreExpire.getError();
						if (payLoadErrorsPreExpire && payLoadErrorsPreExpire[0] && payLoadErrorsPreExpire[0].message) {
							console.log("Error message: " + payLoadErrorsPreExpire[0].message);
						}
					} else {
						console.log("Unknown error");
					}
				});
				$A.enqueueAction(createPassportExpirationPayloadExisting);
			}
			else if (state === "INCOMPLETE") {
			}
			else if (state === "ERROR") {
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
		getContactInfo.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var contactRec = response.getReturnValue();
				component.set("v.contact", contactRec);
				component.set("v.legal_name_consists_of_one_name_only", contactRec.legal_name_consists_of_one_name_only__c);
			}
			else if (state === "INCOMPLETE") {
			}
			else if (state === "ERROR") {
				var errors = response.getError();
				if (errors && errors[0] && errors[0].message) {
			        console.log("Error message: " + errors[0].message);
			    }
			} else {
				console.log("Unknown error");
		    }
		});
		$A.enqueueAction(getContactInfo);					
		
		var affirmationResults = component.get("c.getAffirmationResults");
		affirmationResults.setParams({'serviceName' : serviceName, 'caseId': component.get("v.caseId")});
		affirmationResults.setCallback(this, function(response) {
			var errorList = response.getReturnValue();
			var conId = component.get("v.contactId");
			var photoErrors = [];
			var photoExpiredError;
			var passportErrors = [];
			for (var x in errorList) {
				var rec = x.split(' ');
				if (rec.length == 2) {
					if (rec[0] == 'Photo') {
						photoErrors.push(errorList[x]);
					} else if (rec[0] == 'Passport') {
						passportErrors.push(errorList[x]);
					}
					////// MM code to show Photo is expired /////
					if (rec[1] == "ID_Form_Expired_Picklist__c" && rec[0] == 'Photo'){
					    photoExpiredError = 'The ECFMG Identification Form (EIF) that was previously created for you is no longer valid because your notarized EIF was not received within 6 months of the date it was created. As a result, your previously accepted photograph has been invalidated as well. Please upload a new photograph. Once your new photograph has been accepted, you will be able to access your new EIF.';
					    component.set('v.photoIsExpired', true);
                     }
                     //////// end MM photo expiration
				}
			}

			if (photoErrors.length > 0) {
				component.set("v.showPhotoError", true);
		     	////// MM code to show Photo is expired /////
                if(component.get("v.photoIsExpired")){
                    component.set("v.photoErrors", photoExpiredError);
                } else{  /////// end MM Photo Expiration //////////
				    component.set("v.photoErrors", photoErrors);
				}
			}
			if (passportErrors.length > 0) {
				component.set("v.showPassportError", true);
				component.set("v.passportErrors", passportErrors);
				
				// Newly Uploaded Passport
				//New code - Shailaja - createResubmitPassportPayload
				var createPassportPayload = component.get("c.createResubmitPassportPayload");
				createPassportPayload.setParams({
					"contactId": conId,
					"currentCaseId": component.get("v.caseId"),
					"serviceName": serviceName
				});
				createPassportPayload.setCallback(this, function (passportPayloadResponse) {
					var passportPayloadState = passportPayloadResponse.getState();
					if (passportPayloadState === "SUCCESS") {
						var passportPayload = passportPayloadResponse.getReturnValue();
						if (passportPayload.assetId !== null && passportPayload.assetId !== undefined) {
							//component.set("v.passportUploadedNew", "Yes");
						}

						component.set("v.payloadPassport", JSON.stringify(passportPayload));
						if(component.get("v.passportUploadedNew") == "Yes") {
							component.find('passport').auraThumbnailLoader();
						}
					} else if (passportPayloadState === "ERROR") {
						var passportPayloadErrors = passportPayloadResponse.getError();
						if (passportPayloadErrors && passportPayloadErrors[0] && passportPayloadErrors[0].message) {
							console.log("Error message: " + passportPayloadErrors[0].message);
						}
					} else {
						console.log("createPassportPayload - else loop Unknown error");
					}
				});
				$A.enqueueAction(createPassportPayload);

				// Newly Uploaded Passport Translation				
				//NEW Code - //createResubmitPassportTranslationPayload - takes caseid
				var createPassportTranslationPayload = component.get("c.createResubmitPassportTranslationPayload");
				createPassportTranslationPayload.setParams({
					"contactId": conId,
					"currentCaseId": component.get("v.caseId"),
					"serviceName": serviceName
				});
				createPassportTranslationPayload.setCallback(this, function (payLoadResponse) {
					var payLoadState = payLoadResponse.getState();
					if (payLoadState === "SUCCESS") {
						var payload = payLoadResponse.getReturnValue();
						if (payload.assetId) {
							component.set("v.passportTranslationDoneNewInitialLoading", "Yes");
						}
						component.set("v.payloadPassportTranslation", JSON.stringify(payload));
				
						if(component.get("v.passportTranslationDoneNewInitialLoading") == "Yes"){
							component.find('passportTranslation').auraThumbnailLoader();
						}
					}
				});
				$A.enqueueAction(createPassportTranslationPayload);	

				// Newly Uploaded Passport Expiration
				//New Code added by Shailaja. US#11859. The method takes caseid as parameter.
				var createPassportExpirationPayload = component.get("c.createResubmitPpExpPayload");
				createPassportExpirationPayload.setParams({
					"contactId": conId,
					"currentCaseId": component.get("v.caseId"),
					"serviceName": serviceName
				});
				createPassportExpirationPayload.setCallback(this, function (payLoadResponseExpiration) {
					var payLoadStateExpiration = payLoadResponseExpiration.getState();
					if (payLoadStateExpiration === "SUCCESS") {
						var payloadExpiration = payLoadResponseExpiration.getReturnValue();
						if (payloadExpiration.assetId !== null && payloadExpiration.assetId !== undefined) {
							component.set("v.passportExpirationDoneNewInitialLoading", "Yes");
						}
						component.set("v.payloadPassportExpiration", JSON.stringify(payloadExpiration));
						if(component.get("v.passportExpirationDoneNewInitialLoading") == "Yes"){
							component.find('newPassportExpiration').auraThumbnailLoader();
						}
					}				
				});
				$A.enqueueAction(createPassportExpirationPayload);
			}
		});
		$A.enqueueAction(affirmationResults);
		
		var actionReq = component.get("c.caseRequiresAction");
		actionReq.setParams({'serviceName' : serviceName});
		actionReq.setCallback(this, function(response) {
			var isActionReq = response.getReturnValue();
			component.set("v.actionRequired", isActionReq);
		});
		$A.enqueueAction(actionReq);
		
        var getCountryMetadata = component.get("c.getCountries");
        getCountryMetadata.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var allMetadata = response.getReturnValue();
                var indexOfFirst = allMetadata.indexOf('break1');
                var indexOfSecond = allMetadata.indexOf('break2');
                var indexOfThird = allMetadata.indexOf('break3');
                var citizenBirthCountries = allMetadata.slice(0,indexOfFirst);
                var medSchoolCountries = allMetadata.slice(indexOfFirst + 1, indexOfSecond);
                var currentCountries = allMetadata.slice(indexOfSecond + 1, indexOfThird);
                var birthCountries = allMetadata.slice(indexOfThird + 1);
				var listOfObjects = [];
				var a = currentCountries.sort();
				a.forEach(function(entry) {
				    var singleObj = {};
				    singleObj['label'] = entry;
				    singleObj['value'] = entry;
				    listOfObjects.push(singleObj);
				});
                component.set("v.currentCitizenshipCountry",currentCountries.sort());
                component.set("v.pageReady", true);
            }
        });
		$A.enqueueAction(getCountryMetadata);		
    },
	
	handleUploadFinishedPassport: function (component, event) {
		component.set("v.passportUploadedNew", "Yes");
	},

	handleUploadFinishedPhoto: function (component, event) {
		component.set("v.photoUploadedNew", "Yes");
	},
    
    handlePreviousUploadedPhoto: function (component, event) {
		component.set("v.photoUploadedPrevious", "Yes");
    },
    
    handleUploadFinishedPassportExpiration: function (component, event) {
		component.set("v.passportExpirationDoneNew", "Yes");
	},
	
	handleUploadFinishedPassportTranslation: function (component, event) {
		component.set("v.passportTranslationDoneNew", "Yes");
	},
    
    handleLoad  : function(component, event, helper) {
    },
    
    handleSubmit  : function(component, event, helper) {
    },
    
    handleSuccess  : function(component, event, helper) {
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
	        "title": "Success!",
	        "message": "Your changes have been saved!",
	        "type": "success"
	    });
	    toastEvent.fire();
	    helper.showHide(component);
    },
    
    lastOnlyChange  : function(component, event, helper) {
    	component.set("v.contact.FirstName", "");
    },
    
    countryChange  : function(component, event, helper) {
		var curCountry = component.find("country").get("v.value");
		if (curCountry == 'US' || curCountry == 'USA' || curCountry == 'United States' || curCountry == 'United States of America' || curCountry == 'CA' || curCountry == 'Canada') {
			component.set("v.USorCA", true);
		} else {
			component.set("v.USorCA", false);
		}
    },
    
    handleExpirationChecked : function(component, event, helper) {
		component.set("v.contact.Passport_Photo_Includes_Expiration_Date__c", event.getSource().get('v.value'));
		component.set("v.passport_Photo_Includes_Expiration_Date", event.getSource().get('v.value'));
		component.set("v.passportExpirationDoneNewInitialLoading", 'No');
		
		if (event.getSource().get('v.value') === 'true') {
			var conId = component.get("v.contactId");
			var payloadPassportExpirationDel1 = JSON.parse(component.get("v.payloadPassportExpiration"));
			payloadPassportExpirationDel1.assetId = null;
			component.set("v.payloadPassportExpiration", JSON.stringify(payloadPassportExpirationDel1));
			
			var deleteExistingExpirationAsset = component.get("c.deleteExistingPhotoAsset");
			component.set("v.passportExpirationDoneNew", "No");
			deleteExistingExpirationAsset.setParams({
				'contactId': conId, 
				'passport': 'Expiration'
			});
			deleteExistingExpirationAsset.setCallback(this, function (response) {
				var state2 = response.getState();
				if (state2 === "ERROR") {
					var errors2 = response.getError();
					if (errors2 && errors[0] && errors2[0].message) {
						console.log("Error message: " + errors2[0].message);
					}
				} else {
					console.log("Unknown error");
				}
			});
			$A.enqueueAction(deleteExistingExpirationAsset);
		}
    },
    
	handleEnglishChecked: function (component, event, helper) {
		component.set("v.contact.Passport_Photo_Is_In_English__c", event.getSource().get('v.value'));
		component.set("v.Passport_Photo_Is_In_English", event.getSource().get('v.value'));
		component.set("v.passportTranslationDoneNewInitialLoading", 'No');
		if (event.getSource().get('v.value') === 'true') {
			var conId = component.get("v.contactId");
			var payloadPassportTranslationDel1 = JSON.parse(component.get("v.payloadPassportTranslation"));
			payloadPassportTranslationDel1.assetId = null;
			component.set("v.payloadPassportTranslation", JSON.stringify(payloadPassportTranslationDel1));
			var deleteExistingPhotoAsset2 = component.get("c.deleteExistingPhotoAsset");
			component.set("v.passportTranslationDoneNew", "No");
			deleteExistingPhotoAsset2.setParams({
				'contactId': conId, 'passport': 'translation'
			});
			deleteExistingPhotoAsset2.setCallback(this, function (response) {
				var state2 = response.getState();
				if (state2 === "ERROR") {
					var errors2 = response.getError();
					if (errors2 && errors[0] && errors2[0].message) {
						console.log("Error message: " + errors2[0].message);
					}
				} else {
					console.log("Unknown error");
				}
			});
			$A.enqueueAction(deleteExistingPhotoAsset2);
		}
    },
    
    handleNext :  function(component, event, helper) {
		// If newly photo is upoaded, photo Asset should be set to a status of "Marked for Deletion"
		var conId = component.get("v.contactId");
		if (component.get("v.photoUploadedNew") == 'Yes') {
			var payloadPhotoDel = JSON.parse(component.get("v.payloadPhotoNew"));
			payloadPhotoDel.assetId = null;
			component.set("v.payloadPhotoNew", JSON.stringify(payloadPhotoDel));
		
			var deleteExistingPhotoAsset = component.get("c.deleteExistingPhotoAsset");
			component.set("v.photoUploadedNew", "No");
			deleteExistingPhotoAsset.setParams({
				'contactId': conId,
				"passport" : "No"
			});
			deleteExistingPhotoAsset.setCallback(this, function (response) {
				var state = response.getState();
				if (state === "ERROR") {
					var errors = response.getError();
					if (errors && errors[0] && errors[0].message) {
						console.log("Error message: " + errors[0].message);
					}
				} else {
					console.log("Unknown error");
				}
			});
			$A.enqueueAction(deleteExistingPhotoAsset);
		}

		if (component.get("v.passportUploadedNew") == 'Yes') {
			console.log("Unknown error1");
			var payloadPassportDel = JSON.parse(component.get("v.payloadPassport"));
			payloadPassportDel.assetId = null;
			component.set("v.payloadPassport", JSON.stringify(payloadPassportDel));
			
			var deleteExistingPhotoAsset1 = component.get("c.deleteExistingPhotoAsset");
			console.log("Unknown error2");
			component.set("v.passportUploadedNew", "No");
			deleteExistingPhotoAsset1.setParams({
				'contactId': conId, 
				'passport': 'Yes'
			});
			console.log("Unknown error3");
			deleteExistingPhotoAsset1.setCallback(this, function (response) {
				var state1 = response.getState();
				console.log("Unknown error4");
				if (state1 === "ERROR") {
					var errors1 = response.getError();
					if (errors1 && errors[0] && errors1[0].message) {
						console.log("Error message: " + errors1[0].message);
					}
				} else {
					console.log("Unknown error");
				}
			});
			$A.enqueueAction(deleteExistingPhotoAsset1);
		}

		if (component.get("v.passportTranslationDoneNew") == 'Yes') {
			var payloadPassportTranslationDel = JSON.parse(component.get("v.payloadPassportTranslation"));
			payloadPassportTranslationDel.assetId = null;
			component.set("v.payloadPassportTranslation", JSON.stringify(payloadPassportTranslationDel));
			
			var deleteExistingPhotoAsset2 = component.get("c.deleteExistingPhotoAsset");
			component.set("v.passportTranslationDoneNew", "No");
			deleteExistingPhotoAsset2.setParams({
				'contactId': conId, 
				'passport': 'translation'
			});
			deleteExistingPhotoAsset2.setCallback(this, function (response) {
				var state2 = response.getState();
				if (state2 === "ERROR") {
					var errors2 = response.getError();
					if (errors2 && errors[0] && errors2[0].message) {
						console.log("Error message: " + errors2[0].message);
					}
				} else {
					console.log("Unknown error");
				}
			});
			$A.enqueueAction(deleteExistingPhotoAsset2);
		}

		if (component.get("v.passportExpirationDoneNew") == 'Yes') {
			var payloadPassportExpirationDel = JSON.parse(component.get("v.payloadPassportExpiration"));
			payloadPassportExpirationDel.assetId = null;
			component.set("v.payloadPassportExpiration", JSON.stringify(payloadPassportExpirationDel));
			
			var deleteExistingExpirationAsset = component.get("c.deleteExistingPhotoAsset");
			component.set("v.passportExpirationDoneNew", "No");
			deleteExistingExpirationAsset.setParams({
				'contactId': conId, 
				'passport': 'Expiration'
			});
			deleteExistingExpirationAsset.setCallback(this, function (response) {
				var state2 = response.getState();
				if (state2 === "ERROR") {
					var errors2 = response.getError();
					if (errors2 && errors[0] && errors2[0].message) {
						console.log("Error message: " + errors2[0].message);
					}
				} else {
					console.log("Unknown error");
				}
			});
			$A.enqueueAction(deleteExistingExpirationAsset);
		}
    	window.open('/s/','_top');
	},

	//New code for date validations. #User story 827
	checkPPIssueDateValid: function(component, event, helper) {
		var curDate = new Date();
		curDate.setHours(0,0,0,0);
		var currYear = curDate.getFullYear();
		var pastYear = Number(currYear)-20;		
		var ppiDate = helper.findComponentByName("fieldToValidate", "passportIssueDate", component);
		var ppIssueDate = new Date(component.get("v.contact.Passport_Issue_Date__c") + "T00:00:00");
		var ppIssueMonth = ppIssueDate.getMonth();
		var ppIssueDay = ppIssueDate.getDate();
		var tempPPIssueDatePast = new Date(pastYear, ppIssueMonth, ppIssueDay);		
		//Bug fix#13526
		if (ppIssueDate > curDate) {
			ppiDate.setCustomValidity("Passport Issue Date must be in the past.");
			ppiDate.reportValidity();
		} else if(ppIssueDate < tempPPIssueDatePast){//Issue Date cannot be older than 20 years in the past			
			ppiDate.setCustomValidity("Passport Issue Date cannot be older than 20 years in the past.");
			ppiDate.reportValidity();
		}else {
			ppiDate.setCustomValidity("");
		}
	},

	checkPPExpDateValid: function(component, event, helper) {
		var curDate = new Date();
		curDate.setHours(0,0,0,0);
		var currYear = curDate.getFullYear();
		var futureYear = Number(currYear)+20;
		var ppeDate = helper.findComponentByName("fieldToValidate", "passportExpiration", component);
		var ppExpirationDate = new Date(component.get("v.contact.Passport_Expiration__c") + "T00:00:00");
		var ppExpMonth = ppExpirationDate.getMonth();
		var ppExpDay = ppExpirationDate.getDate();
		var tempPPExpirationDateFuture = new Date(futureYear, ppExpMonth, ppExpDay);		
		//Expiration Date cannot be greater than 20 years in the future
		if (ppExpirationDate <= curDate) {
			ppeDate.setCustomValidity("Passport Expiration Date must be in the future.");
			ppeDate.reportValidity();
		}else if(ppExpirationDate > tempPPExpirationDateFuture){
			ppeDate.setCustomValidity("Passport Expiration Date cannot be greater than 20 years in the future.");
			ppeDate.reportValidity();
		}else {
			ppeDate.setCustomValidity("");
		}
	},

	checkDOBDateValid: function(component, event, helper) {
		var curDate = new Date();
		curDate.setHours(0,0,0,0);
		var currYear = curDate.getFullYear();
		//For calculating the dob between 11 & 100 years old
		var dobPastElevenYears = Number(currYear)-11;
		var dobPastHundYears = Number(currYear)-100;
		var bDate = helper.findComponentByName("fieldToValidate", "dateOfBirth", component);
		var birthDate = new Date(component.get("v.contact.Birthdate") + "T00:00:00");		
		var bMonth = birthDate.getMonth();
		var bDay =birthDate.getDate();
		var tempElevenBirthDate = new Date(dobPastElevenYears,bMonth,bDay);
		var tempHundBirthDate = new Date(dobPastHundYears,bMonth,bDay);
		
		if (birthDate >= curDate) {
			bDate.setCustomValidity("Date of Birth must be in the past.");
			bDate.reportValidity();
		}else if(birthDate > tempElevenBirthDate){//Date of Birth:Should not be more recent than 11 years in the past
			bDate.setCustomValidity("Date of Birth should not be more recent than 11 years in the past.");
			bDate.reportValidity();
		}else if(birthDate < tempHundBirthDate){//Date of Birth:Should not be greater than 100 years in the past
			bDate.setCustomValidity("Date of Birth should not be greater than 100 years in the past.");
			bDate.reportValidity();
		}else {
			bDate.setCustomValidity("");
		}
	},
    handleSave :  function(component, event, helper) {
		component.set("v.showSaveSpinner", true);
		var expired 			= 	component.get("v.photoIsExpired");
		var hasPassportErrors 	= 	component.get("v.showPassportError");
		var hasPhotoError 		= 	component.get("v.showPhotoError");
		if (hasPassportErrors) {
			var hasErrors = false;
			var allValid = component.find("fieldToValidate");
			for (var x=0; x<allValid.length; x++) {
				if(!allValid[x].get("v.validity").valid) {
					allValid[x].showHelpMessageIfInvalid();
					hasErrors = true;
				}
			}
			
	    	if (component.get("v.showPhotoError")) {
				if(component.get("v.photoUploadedNew") == 'No') {
					hasErrors = true;
				}
	    	} 
	    	if (component.get("v.showPassportError")) {
		    	if(component.get("v.passportUploadedNew") == 'No') {
					hasErrors = true;
		    	}
		    	
		    	if(component.get("v.passport_Photo_Includes_Expiration_Date") == false || component.get("v.passport_Photo_Includes_Expiration_Date") == 'false') {
		    	    if(component.get("v.passportExpirationDoneNew") == null || component.get("v.passportExpirationDoneNew") == 'No' ) {
						hasErrors = true;
		            }
				}
		    	if(component.get("v.Passport_Photo_Is_In_English") == false || component.get("v.Passport_Photo_Is_In_English") == 'false') {
		    	    if(component.get("v.passportTranslationDoneNew") == 'No') {
						hasErrors = true;
		            }
				}
		    }
	    }		
		if(hasPhotoError){
			if(component.get("v.photoUploadedNew") == 'No') {
				hasErrors = true;
			}
		} 
        if(!hasErrors){
			var contact = component.get("v.contact");
			var contactStr = JSON.stringify(contact);
			var updteContact = component.get("c.updateContact");
			updteContact.setParams({"contactId":contact.Id, "contactJSON":contactStr});
			updteContact.setCallback(this, function(response) {
				var state = response.getState();
				if (state === "SUCCESS") {
					var contactRec = response.getReturnValue();
				}
				else if (state === "INCOMPLETE") {			}
				else if (state === "ERROR") {
					var errors = response.getError(); 
					if (errors && errors[0] && errors[0].message) {
						 console.log("Error message: " + errors[0].message);
						 console.error("Error message 1: " + errors[0].message);
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
				"caseId":component.get("v.caseId")
			};
			helper.apex(component, helper, "resubmitIdentificationV3", params)
				.then(() => {
					component.set("v.showSaveSpinner", true);
					var toast = $A.get("e.force:showToast");
					toast.setParams({
						"role": "status",
						"mode": "sticky",
						"title": "Success!",
						"type": "success",
						"message": "You have successfully resubmitted your identification document(s) for review."
					});
					toast.fire();
					// Redirect to home page
					window.open('/s/','_top');
				})
				.then(() => {
					if (serviceName == 'J1') {
						return helper.apex(component, helper, "closeJ1InviteCase");
					}
				});

		}else{
			component.set("v.showSaveSpinner", false);
			var toastElse = $A.get("e.force:showToast");
			toastElse.setParams({
				"role": "status",
				"mode": "sticky",
	            "title"   : "Error!",
	            "type"    : "error",
	            "message" : "You must complete all required fields before proceeding."
	        });
			toastElse.fire();
		}
    },

    handleInputOnBlur :  function(component, event, helper) {
        var field = event.getSource();
        if(field.get("v.value") && typeof field.get("v.value") == "string") field.set("v.value", field.get("v.value").trim());
    },
    
    redirectHome :  function(component, event, helper) {
        window.open('/s/','_top');
    },
})