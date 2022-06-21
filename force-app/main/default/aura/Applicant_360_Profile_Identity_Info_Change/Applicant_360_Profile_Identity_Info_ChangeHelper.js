({
    initialize: function (component, helper) {
        helper.getContactDetailsUpdateCases(component, helper);
        helper.getContact(component, helper);
        helper.getCountries(component, helper);
        helper.getConfirmText(component, helper);
        helper.checkAndGetCSAssosiated(component, helper);
    },

    findComponentByName: function (id, name, component) {
        var cmps = component.find(id);
        for (var i = 0; i < cmps.length; i++) {
            if (cmps[i].get("v.name") == name) {
                return cmps[i];
            }
        }
    },

checkAndGetCSAssosiated: function (component, helper) {
    return helper.apex(component, helper, "checkAndGetCSAssosiated")
        .then(
            (result) => {
                if(result != null){
                    component.set("v.hasCSDetails", true);
                    component.set("v.firstName", result.First_Name__c);
                    component.set("v.oneNameOnly", result.legal_name_consists_of_one_name_only__c);
                    component.set("v.lastName", result.Last_Name__c);
                    component.set("v.genSuffix", result.Generational_Suffix__c);
                    component.set("v.dob", result.Date_of_Birth__c);
                    component.set("v.gender", result.Gender__c);
                    component.set("v.reasonForChange", result.Reason_for_Change__c);
                    component.set("v.passportNumber", result.Passport_Number__c);
                    component.set("v.passportIssued", result.Passport_Issue_Date__c);
                    component.set("v.passportExpires", result.Passport_Expiration__c);
                    component.set("v.passportCountry", result.Passport_Country__c);
                    component.set("v.confirmChange", true);
                   
                }else{
                    component.set("v.hasCSDetails", false);
                }
            }).catch(
                (errorMessage) => {
                    console.error("An error has occurred in the promise chain: " + errorMessage);
                }
            );
        },

    getContact: function (component, helper) {
        return helper.apex(component, helper, "getContact")
            .then(
                (result) => {
                    component.set("v.contact", result);
                    component.set("v.contactId", result.Id);
                    component.set("v.firstNameInitial", result.FirstName);
                    component.set("v.oneNameOnlyInitial", result.legal_name_consists_of_one_name_only__c);
                    component.set("v.lastNameInitial", result.LastName);
                    component.set("v.genSuffixInitial", result.Generational_Suffix__c);
                    component.set("v.dobInitial", result.Birthdate);
                    component.set("v.genderInitial", result.Gender__c);

                    if(component.get("v.hasCSDetails") === false){
                        component.set("v.firstName", result.FirstName);
                        component.set("v.oneNameOnly", result.legal_name_consists_of_one_name_only__c);
                        component.set("v.lastName", result.LastName);
                        component.set("v.genSuffix", result.Generational_Suffix__c);
                        component.set("v.dob", result.Birthdate);
                        component.set("v.gender", result.Gender__c);
                    }
                    component.set("v.pageReady", true);

                    var conId = component.get("v.contactId");

                    var createPassportPayload = component.get("c.createPassportPayload");
                    createPassportPayload.setParams({
                        "contactId": conId
                    });
                    createPassportPayload.setCallback(this, function (passportPayloadResponse) {
                        var passportPayloadState = passportPayloadResponse.getState();
                        if (passportPayloadState === "SUCCESS") {
                            var passportPayload = passportPayloadResponse.getReturnValue();
                            component.set("v.payloadPassport", JSON.stringify(passportPayload));
                            if(passportPayload.assetId != null){
                                component.set("v.hasPassportDetails", true);
                                component.set("v.governmentIssuedId", 'Test');
                                component.find('passport').auraThumbnailLoader();
                            }
                        } else if (passportPayloadState === "ERROR") {
                            var passportPayloadErrors = passportPayloadResponse.getError();
                            if (passportPayloadErrors && passportPayloadErrors[0] && passportPayloadErrors[0].message) {
                                console.log("Error message: " + passportPayloadErrors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    });
                    $A.enqueueAction(createPassportPayload);

                    var createPassportTranslationPayload = component.get("c.createPassportTranslationPayload");
                    createPassportTranslationPayload.setParams({
                        "contactId": conId
                    });
                    createPassportTranslationPayload.setCallback(this, function (passportPayloadTrnResponse) {
                        var passportPayloadTrnState = passportPayloadTrnResponse.getState();
                        if (passportPayloadTrnState === "SUCCESS") {
                            var passportTrnPayload = passportPayloadTrnResponse.getReturnValue();
                            component.set("v.payloadPassportTranslation", JSON.stringify(passportTrnPayload));
                            if(passportTrnPayload.assetId != null){
                                component.set("v.passportInEnglish", 'No');
                                component.set("v.hasTranslation", true);
                                component.set("v.passportTranslationDone", "Yes");                                
                                component.find('passportTranslation').auraThumbnailLoader();
                            }else if(component.get("v.hasCSDetails") === true){
                                component.set("v.passportInEnglish", 'Yes');
                            }
                        } else if (passportPayloadTrnState === "ERROR") {
                            var passportTrnPayloadErrors = passportPayloadTrnResponse.getError();
                            if (passportTrnPayloadErrors && passportTrnPayloadErrors[0] && passportTrnPayloadErrors[0].message) {
                                console.log("Error message: " + passportTrnPayloadErrors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    });
                    $A.enqueueAction(createPassportTranslationPayload);

        var createPassportExpirationPayload = component.get("c.createPassportExpirationPayload");
		createPassportExpirationPayload.setParams({
			"contactId": conId
		});
		createPassportExpirationPayload.setCallback(this, function (passportPayloadExnResponse) {
			var passportPayloadExnState = passportPayloadExnResponse.getState();
			if (passportPayloadExnState === "SUCCESS") {
				var passportExnPayload = passportPayloadExnResponse.getReturnValue();
				component.set("v.payloadPassportExpiration", JSON.stringify(passportExnPayload));
                if(passportExnPayload.assetId != null){
                    component.set("v.passportExpired", 'No');
                    component.set("v.hasExpiration", true);
                    component.set("v.passportExpirationDone", "Yes");
                    component.find('passportExpiration').auraThumbnailLoader();
                }else if(component.get("v.hasCSDetails") === true){
                    component.set("v.passportExpired", 'Yes');
                }                
			} else if (passportPayloadExnState === "ERROR") {
				var passportExnPayloadErrors = passportPayloadExnResponse.getError();
				if (passportExnPayloadErrors && passportExnPayloadErrors[0] && passportExnPayloadErrors[0].message) {
					console.log("Error message: " + passportExnPayloadErrors[0].message);
				}
			} else {
				console.log("Unknown error");
			}
		});
		$A.enqueueAction(createPassportExpirationPayload);	

                    /*
                    var deleteExistingPassportAssets = component.get("c.deleteExistingPassportAssets");
                    deleteExistingPassportAssets.setParams({
                        'contactId': conId
                    });
                    deleteExistingPassportAssets.setCallback(this, function (response) {
                        var state = response.getState();
                        if (state === "ERROR") {
                            var errors = response.getError();
                            if (errors && errors[0] && errors[0].message) {
                                console.log("Error message: " + errors[0].message);
                            }
                        }
                    });
                    $A.enqueueAction(deleteExistingPassportAssets);
                    */

                    var createPhotoPayload = component.get("c.createPhotoPayload");
                    createPhotoPayload.setParams({
                        "contactId": conId
                    });
                    createPhotoPayload.setCallback(this, function (photoPayloadResponse) {
                        var photoPayloadState = photoPayloadResponse.getState();
                        if (photoPayloadState === "SUCCESS") {
                            var phototPayload = photoPayloadResponse.getReturnValue();
                            component.set("v.payloadPhoto", JSON.stringify(phototPayload));
                            if(phototPayload.assetId != null){
                                component.set("v.hasPhotoDetails", true);
                                component.set("v.photoId", 'photouploaded');
                                component.find('photo').auraThumbnailLoader();
                            }
                        } else if (photoPayloadState === "ERROR") {
                            var phototPayloadErrors = photoPayloadResponse.getError();
                            if (phototPayloadErrors && phototPayloadErrors[0] && phototPayloadErrors[0].message) {
                                console.log("Error message: " + phototPayloadErrors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    });
                    $A.enqueueAction(createPhotoPayload);

                    var createBirthCertificatePayload = component.get("c.createBirthCertificatePayload");
                    createBirthCertificatePayload.setParams({
                        "contactId": conId
                    });
                    createBirthCertificatePayload.setCallback(this, function (birthCertificatePayloadResponse) {
                        var birthCertificatePayloadState = birthCertificatePayloadResponse.getState();
                        if (birthCertificatePayloadState === "SUCCESS") {
                            var birthCertificatePayload = birthCertificatePayloadResponse.getReturnValue();
                            component.set("v.payloadBirthCertificate", JSON.stringify(birthCertificatePayload));
                            if(birthCertificatePayload.assetId!=null){
                            component.set("v.birthCertificateUploadBool", true);
                            component.set("v.birthCertificateId", "birthCertificateId");
                            helper.updateDocTypesRemaining(component, helper);
                            }
                        } else if (birthCertificatePayloadState === "ERROR") {
                            var birthCertificateloadErrors = birthCertificatePayloadResponse.getError();
                            if (birthCertificateloadErrors && birthCertificateloadErrors[0] && birthCertificateloadErrors[0].message) {
                                console.log("Error message: " + birthCertificateloadErrors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    });
                    $A.enqueueAction(createBirthCertificatePayload);

                    var createMarriageCertificatePayload = component.get("c.createMarriageCertificatePayload");
                    createMarriageCertificatePayload.setParams({
                        "contactId": conId
                    });
                    createMarriageCertificatePayload.setCallback(this, function (marriageCertificatePayloadResponse) {
                        var marriageCertificatePayloadState = marriageCertificatePayloadResponse.getState();
                        if (marriageCertificatePayloadState === "SUCCESS") {
                            var marriageCertificatePayload = marriageCertificatePayloadResponse.getReturnValue();
                            component.set("v.payloadMarriageCertificate", JSON.stringify(marriageCertificatePayload));
                            if(marriageCertificatePayload.assetId!=null){
                       component.set("v.marriageCertificateUploadBool", true);
                       component.set("v.marriageCertificateId", "marriageCertificateId");
                       helper.updateDocTypesRemaining(component, helper);
                            }
                        } else if (marriageCertificatePayloadState === "ERROR") {
                            var marriageCertificateloadErrors = marriageCertificatePayloadResponse.getError();
                            if (marriageCertificateloadErrors && marriageCertificateloadErrors[0] && marriageCertificateloadErrors[0].message) {
                                console.log("Error message: " + marriageCertificateloadErrors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    });
                    $A.enqueueAction(createMarriageCertificatePayload);

                    var createOfficialCourtOrderPayload = component.get("c.createOfficialCourtOrderPayload");
                    createOfficialCourtOrderPayload.setParams({
                        "contactId": conId
                    });
                    createOfficialCourtOrderPayload.setCallback(this, function (officialCourtOrderPayloadResponse) {
                        var officialCourtOrderPayloadState = officialCourtOrderPayloadResponse.getState();
                        if (officialCourtOrderPayloadState === "SUCCESS") {
                            var officialCourtOrderPayload = officialCourtOrderPayloadResponse.getReturnValue();
                            component.set("v.payloadOfficalCourtOrder", JSON.stringify(officialCourtOrderPayload));
                            if(officialCourtOrderPayload.assetId!=null){
                            component.set("v.officalCourtOrderUploadBool", true);
                            component.set("v.officalCourtOrderId", "officalCourtOrderId");
                            helper.updateDocTypesRemaining(component, helper);
                            }
                        } else if (officialCourtOrderPayloadState === "ERROR") {
                            var officialCourtOrderPayloadErrors = officialCourtOrderPayloadResponse.getError();
                            if (officialCourtOrderPayloadErrors && officialCourtOrderPayloadErrors[0] && officialCourtOrderPayloadErrors[0].message) {
                                console.log("Error message: " + officialCourtOrderPayloadErrors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    });
                    $A.enqueueAction(createOfficialCourtOrderPayload);

                    var createUsResidentAlienCardPayload = component.get("c.createUsResidentAlienCardPayload");
                    createUsResidentAlienCardPayload.setParams({
                        "contactId": conId
                    });
                    createUsResidentAlienCardPayload.setCallback(this, function (usResidentAlienCardPayloadResponse) {
                        var usResidentAlienCardPayloadState = usResidentAlienCardPayloadResponse.getState();
                        if (usResidentAlienCardPayloadState === "SUCCESS") {
                            var usResidentAlienCardPayload = usResidentAlienCardPayloadResponse.getReturnValue();
                            component.set("v.payloadUsResidentAlienCard", JSON.stringify(usResidentAlienCardPayload));
                            if(usResidentAlienCardPayload.assetId!=null){
                            component.set("v.usResidentAlienCardUploadBool", true);
                            component.set("v.usResidentAlienCardId", "usResidentAlienCardId");
                            helper.updateDocTypesRemaining(component, helper);
                            }
                        } else if (usResidentAlienCardPayloadState === "ERROR") {
                            var usResidentAlienCardPayloadErrors = usResidentAlienCardPayloadResponse.getError();
                            if (usResidentAlienCardPayloadErrors && usResidentAlienCardPayloadErrors[0] && usResidentAlienCardPayloadErrors[0].message) {
                                console.log("Error message: " + usResidentAlienCardPayloadErrors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    });
                    $A.enqueueAction(createUsResidentAlienCardPayload);

                    var createUsNaturalizationCertificatePayload = component.get("c.createUsNaturalizationCertificatePayload");
                    createUsNaturalizationCertificatePayload.setParams({
                        "contactId": conId
                    });
                    createUsNaturalizationCertificatePayload.setCallback(this, function (usNaturalizationCertificatePayloadResponse) {
                        var usNaturalizationCertificatePayloadState = usNaturalizationCertificatePayloadResponse.getState();
                        if (usNaturalizationCertificatePayloadState === "SUCCESS") {
                            var usNaturalizationCertificatePayload = usNaturalizationCertificatePayloadResponse.getReturnValue();
                            component.set("v.payloadUsNaturalizationCertificate", JSON.stringify(usNaturalizationCertificatePayload));
                            if(usNaturalizationCertificatePayload.assetId!=null){
                            component.set("v.usNaturalizationCertificateUploadBool", true);
                            component.set("v.naturalizationCertificateId", "naturalizationCertificateId");
                            helper.updateDocTypesRemaining(component, helper);
                            }
                        } else if (usNaturalizationCertificatePayloadState === "ERROR") {
                            var usNaturalizationCertificatePayloadErrors = usNaturalizationCertificatePayloadResponse.getError();
                            if (usNaturalizationCertificatePayloadErrors && usNaturalizationCertificatePayloadErrors[0] && usNaturalizationCertificatePayloadErrors[0].message) {
                                console.log("Error message: " + usNaturalizationCertificatePayloadErrors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    });
                    $A.enqueueAction(createUsNaturalizationCertificatePayload);

                    var createUsPassportCardPayload = component.get("c.createUsPassportCardPayload");
                    createUsPassportCardPayload.setParams({
                        "contactId": conId
                    });
                    createUsPassportCardPayload.setCallback(this, function (usPassportCardPayloadResponse) {
                        var usPassportCardPayloadState = usPassportCardPayloadResponse.getState();
                        if (usPassportCardPayloadState === "SUCCESS") {
                            var usPassportCardPayload = usPassportCardPayloadResponse.getReturnValue();
                            component.set("v.payloadUsPassportCard", JSON.stringify(usPassportCardPayload));
                            if(usPassportCardPayload.assetId!=null){
                            component.set("v.usPassportCardUploadBool", true);
                            component.set("v.usPassportCardId", "usPassportCardId");
                            helper.updateDocTypesRemaining(component, helper);
                            }
                        } else if (usPassportCardPayloadState === "ERROR") {
                            var usPassportCardPayloadErrors = usPassportCardPayloadResponse.getError();
                            if (usPassportCardPayloadErrors && usPassportCardPayloadErrors[0] && usPassportCardPayloadErrors[0].message) {
                                console.log("Error message: " + usPassportCardPayloadErrors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    });
                    $A.enqueueAction(createUsPassportCardPayload);


                });
    },

    getCountries: function (component, helper) {
        return helper.apex(component, helper, "getCountries")
            .then(
                (result) => {
                    var allMetadata = result;
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
                });
    },

    getContactDetailsUpdateCases: function (component, helper) {
        return helper.apex(component, helper, "getContactDetailsUpdateCases", {
                "isClosed": false
            })
            .then(
                (result) => {
                    if (result.length == 0) {
                        component.set("v.hasExistingChangeCase", false);
                    } else {
                        var matchFound = false;
                        for(var i=0; i<result.length; i++){
                          if(result[i].Internal_Status__c == 'Pending Submission'){
                            matchFound = true;
                            break;
                          }  
                        }
                        if(matchFound == true){
                            component.set("v.hasExistingChangeCase", false);
                        }else{
                            component.set("v.hasExistingChangeCase", true);
                        }
                    }
                });
    },


    getConfirmText: function (component, helper) {
        return helper.apex(component, helper, "getTerms", {
                "name": "Applicant My Profile - Biographics"
            })
            .then(
                (result) => {
                    var confirmText = result;
                    if (confirmText != null) {
                        var termstext = confirmText.Copy__c;
                        component.set("v.confirmText", termstext.replace(/(<([^>]+)>)/ig, ''));
                        component.set("v.confirmId", confirmText.Id);
                    }
                });
    },

    updateDocTypesRemaining: function (component, helper) {
        var docTypeOptions = [];
        docTypeOptions.push("--Select One--");
        if (component.get("v.birthCertificateId") == "") {
            docTypeOptions.push("Birth Certificate");
        }
        if (component.get("v.marriageCertificateId") == "") {
            docTypeOptions.push("Marriage Certificate");
        }
        if (component.get("v.officalCourtOrderId") == "") {
            docTypeOptions.push("Official Court Order");
        }
        if (component.get("v.usResidentAlienCardId") == "") {
            docTypeOptions.push("U.S. Resident Alien Card");
        }
        if (component.get("v.naturalizationCertificateId") == "") {
            docTypeOptions.push("U.S. Naturalization Certificate");
        }
        if (component.get("v.usPassportCardId") == "") {
            docTypeOptions.push("U.S. Passport Card");
        }
        component.set("v.docTypesRemaining", docTypeOptions);

        if (docTypeOptions.length == 1) {
            component.set("v.disableSelect", true);
        } else {
            component.set("v.disableSelect", false);
        }
    },

    doSave: function (component, helper) {
        component.set("v.disableButtons", true);
        component.set("v.pageReady", false);
        var fName = component.get("v.firstName");
        var oneName = component.get("v.oneNameOnly");
        console.log('one name ' + oneName);
        var lName = component.get("v.lastName");
        var gSuffix = component.get("v.genSuffix");
        var birthDate = component.get("v.dob");
        var genderVal = component.get("v.gender");
        var ppCountry = component.get("v.passportCountry");
        var ppIssued = component.get("v.passportIssued");
        var ppExpires = component.get("v.passportExpires");
        var ppNumber = component.get("v.passportNumber");
        var reason = component.get("v.reasonForChange");
        var confirm = component.get("v.confirmId");
        var mapToSend = {}
        mapToSend['ppCountry'] = ppCountry;
        mapToSend['fName'] = fName;
        mapToSend['lName'] = lName;
        mapToSend['reason'] = reason;
        mapToSend['confirm'] = confirm;
        mapToSend['genderVal'] = genderVal;
        var mapToSendString = JSON.stringify(mapToSend);
        var hasErrors = false;
        var ppIssueDate = helper.findComponentByName("fieldToValidate", "passportIssueDate", component);
        var ppExpDate = helper.findComponentByName("fieldToValidate", "passportExpiration", component);
        var dobDate = helper.findComponentByName("fieldToValidate", "dateOfBirth", component);

        /*

            ppIssueDate.setCustomValidity("");
            ppExpDate.setCustomValidity("");
            dobDate.setCustomValidity("");

        var allValid = component.find("fieldToValidate");
        for (var x=0; x<allValid.length; x++) {
        if(!allValid[x].get("v.validity").valid) {
        allValid[x].showHelpMessageIfInvalid();
        hasErrors = true;
        console.log("FIELD VALIDATION");
        allValid[x].setCustomValidity("This field is required.");
            allValid[x].reportValidity();
        }
        }

            var today = new Date();
            var curDate = new Date();
            curDate.setHours(0,0,0,0);
           
            var bDate = helper.findComponentByName("fieldToValidate", "dateOfBirth", component);
            if (new Date(birthDate + "T00:00:00") >= curDate) {
            console.log("Step 3a")
            dobDate.setCustomValidity("Date of Birth must be in the past.;");
           dobDate.reportValidity();
           hasErrors = true;
            }

            if (new Date(ppIssued + "T00:00:00") >= curDate) {
            console.log("Step 3b")
            ppIssueDate.setCustomValidity("Passport Issue Date must be in the past.;");
            ppIssueDate.reportValidity();
           hasErrors = true;
            }

            if (new Date(ppExpires + "T00:00:00") <= curDate) {
            debugger;
            console.log("Step 3c")
            ppExpDate.setCustomValidity("Passport Expiration Date must be in the future.;");
            ppExpDate.reportValidity();
           hasErrors = true;
            }*/

        return helper.apex(component, helper, "updateContactBiographics", {
                "oneNameOnly": oneName,
                "genSuffix": gSuffix,
                "dob": birthDate,
                "ppIssued": ppIssued,
                "ppExpires": ppExpires,
                "ppNumber": ppNumber,
                "inputMapString": mapToSendString
            })
            .then(
                (result) => {
                    console.log("CaseId: " + result);
                    component.set("v.disableButtons", false);
                    component.set("v.hasExistingChangeCase", false);
                    component.set("v.pageReady", false);
                    component.set("v.caseNumber", result.CaseNumber);
                    component.set("v.caseRecordId", (result.Id));
                    component.set("v.showShoppingCartLWC", true);
                    component.set("v.showCompleteModal", false);
                }).catch(
                (errorMessage) => {
                    console.log("An error has occurred in the promise chain: " + errorMessage);
                    helper.handleError(errorMessage);
                    component.set("v.disableButtons", false);
                    component.set("v.pageReady", true);
                }
            );

    },
})