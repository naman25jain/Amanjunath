({
    doInit: function(component, event, helper) {
        helper.initialize(component, helper);
    },

    handleGovermentIdUpload: function(component, event, helper) {
        component.set("v.governmentIssuedId", 'Test');
        component.set("v.hasPassportDetails", true);
        var azureDocUrl = event.getParam('url');
        var conId = component.get("v.contactId");
        var updatePassportPayload = component.get("c.updatePassportPayload");
        updatePassportPayload.setParams({
            "contactId": conId,
            "azureDocUrl": azureDocUrl
        });
        updatePassportPayload.setCallback(this, function(passportPayloadResponse) {
            var passportPayloadState = passportPayloadResponse.getState();
            if (passportPayloadState === "SUCCESS") {
                var passportPayload = passportPayloadResponse.getReturnValue();
                component.set("v.payloadPassport", JSON.stringify(passportPayload));
                var thumbnailDisplayAction = component.find('passport').auraThumbnailLoader();
                $A.enqueueAction(thumbnailDisplayAction);

            } else if (passportPayloadState === "ERROR") {
                var passportloadErrors = passportPayloadResponse.getError();
                if (passportloadErrors && passportloadErrors[0] && passportloadErrors[0].message) {
                    console.log("Error message: " + passportloadErrors[0].message);
                }
            } else {
                console.log("Unknown error");
            }
        });
        $A.enqueueAction(updatePassportPayload);
    },

    handlePhotoIdUpload: function(component, event, helper) {
        component.set("v.photoId", 'photouploaded');
        component.set("v.hasPhotoDetails", true);
        var azureDocUrl = event.getParam('url');
        var conId = component.get("v.contactId");
        var updatePhotoPayload = component.get("c.updatePhotoPayload");
        updatePhotoPayload.setParams({
            "contactId": conId,
            "azureDocUrl": azureDocUrl
        });
        updatePhotoPayload.setCallback(this, function(photoPayloadResponse) {
            var photoPayloadState = photoPayloadResponse.getState();
            if (photoPayloadState === "SUCCESS") {
                var photoPayload = photoPayloadResponse.getReturnValue();
                component.set("v.payloadPhoto", JSON.stringify(photoPayload));
                var thumbnailDisplayAction = component.find('photo').auraThumbnailLoader();
                $A.enqueueAction(thumbnailDisplayAction);

            } else if (photoPayloadState === "ERROR") {
                var photoloadErrors = photoPayloadResponse.getError();
                if (photoloadErrors && photoloadErrors[0] && photoloadErrors[0].message) {
                    console.log("Error message: " + photoloadErrors[0].message);
                }
            } else {
                console.log("Unknown error");
            }
        });
        $A.enqueueAction(updatePhotoPayload);
    },

    handleEnglishChecked: function(component, event, helper) {
        var conId = component.get("v.contactId");
        component.set("v.passportInEnglish", "No");
        if (event.getSource().get('v.value') === "true") {
            var deleteExistingAsset = component.get("c.deleteExistingAsset");
            component.set("v.passportTranslationDone", "No");
            component.set("v.passportInEnglish", "Yes");
            deleteExistingAsset.setParams({
                'contactId': conId
            });
            deleteExistingAsset.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                }
            });
            $A.enqueueAction(deleteExistingAsset);
            component.set("v.passportTranslationId", "");
            component.set("v.hasTranslation", false);
		    var createPassportTranslationPayload = component.get("c.createPassportTranslationPayload");
		    createPassportTranslationPayload.setParams({
			    "contactId": conId
		    });
		    createPassportTranslationPayload.setCallback(this, function (passportPayloadTrnResponse) {
			var passportPayloadTrnState = passportPayloadTrnResponse.getState();
			if (passportPayloadTrnState === "SUCCESS") {
				var passportTrnPayload = passportPayloadTrnResponse.getReturnValue();
				component.set("v.payloadPassportTranslation", JSON.stringify(passportTrnPayload));
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
        }
    },
    handleExpirationChecked: function(component, event, helper) {
        var conId = component.get("v.contactId");
        component.set("v.passportExpired", "No");
        if (event.getSource().get('v.value') === "true") {
            var deleteExistingAsset = component.get("c.deleteExistingExpirationAsset");
            component.set("v.passportExpirationDone", "No");
            component.set("v.passportExpired", "Yes");
            deleteExistingAsset.setParams({
                'contactId': conId
            });
            deleteExistingAsset.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                }
            });
            $A.enqueueAction(deleteExistingAsset);  	
            component.set("v.passportExpirationId", "");
		    component.set("v.hasExpiration", false);
		    var createPassportExpirationPayload = component.get("c.createPassportExpirationPayload");
		    createPassportExpirationPayload.setParams({
			    "contactId": conId
		    });
		    createPassportExpirationPayload.setCallback(this, function (passportPayloadExnResponse) {
			var passportPayloadExnState = passportPayloadExnResponse.getState();
			if (passportPayloadExnState === "SUCCESS") {
				var passportExnPayload = passportPayloadExnResponse.getReturnValue();
				component.set("v.payloadPassportExpiration", JSON.stringify(passportExnPayload));
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
        }
    },
    handleTranslationUpload: function(component, event, helper) {
        component.set("v.passportTranslationDone", "Yes");
		component.set("v.hasTranslation", true);
    },
    handleExpirationUpload: function(component, event, helper) {
        component.set("v.passportExpirationDone", "Yes");
		component.set("v.hasExpiration", true);		
    },
    handlebirthCertificateUpload: function(component, event, helper) {
        component.set("v.birthCertificate.hideUpload", "true");
        component.set("v.birthCertificateUploadBool", true);
        var birthAzureDocUrl = event.getParam('url');
        var action = component.get('c.resetDropdown');
        $A.enqueueAction(action);
        var conId = component.get("v.contactId");
        var updateBirthCertificatePayload = component.get("c.updateBirthCertificatePayload");
        updateBirthCertificatePayload.setParams({
            "contactId": conId,
            "azureDocUrl": birthAzureDocUrl
        });
        updateBirthCertificatePayload.setCallback(this, function(birthCertificatePayloadResponse) {
            var birthCertificatePayloadState = birthCertificatePayloadResponse.getState();
            if (birthCertificatePayloadState === "SUCCESS") {
                var birthCertificatePayload = birthCertificatePayloadResponse.getReturnValue();
                component.set("v.payloadBirthCertificate", JSON.stringify(birthCertificatePayload));
                component.set("v.birthCertificateId", "birthCertificateId");
                var thumbnailDisplayAction = component.find('birthCertificateDisplay').auraThumbnailLoader();
                $A.enqueueAction(thumbnailDisplayAction);

            } else if (birthCertificatePayloadState === "ERROR") {
                var birthCertificateloadErrors = birthCertificatePayloadResponse.getError();
                if (birthCertificateloadErrors && birthCertificateloadErrors[0] && birthCertificateloadErrors[0].message) {
                    console.log("Error message: " + birthCertificateloadErrors[0].message);
                }
            } else {
                console.log("Unknown error");
            }
        });
        $A.enqueueAction(updateBirthCertificatePayload);
    },
    handleMarriageCertificateUpload: function(component, event, helper) {
        component.set("v.marriageCertificateUploadBool", true);
        var marCertAzureDocUrl = event.getParam('url');
        var action = component.get('c.resetDropdown');
        $A.enqueueAction(action);
        var conId = component.get("v.contactId");
        var updateMarriageCertificatePayload = component.get("c.updateMarriageCertificatePayload");
        updateMarriageCertificatePayload.setParams({
            "contactId": conId,
            "azureDocUrl": marCertAzureDocUrl
        });
        updateMarriageCertificatePayload.setCallback(this, function(marriageCertificatePayloadResponse) {
            var marriageCertificatePayloadState = marriageCertificatePayloadResponse.getState();
            if (marriageCertificatePayloadState === "SUCCESS") {
                var marriageCertificatePayload = marriageCertificatePayloadResponse.getReturnValue();
                component.set("v.payloadMarriageCertificate", JSON.stringify(marriageCertificatePayload));
                component.set("v.marriageCertificateId", "marriageCertificateId");
                var thumbnailDisplayAction = component.find('marriageCertificateDisplay').auraThumbnailLoader();
                $A.enqueueAction(thumbnailDisplayAction);
            } else if (marriageCertificatePayloadState === "ERROR") {
                var marriageCertificateloadErrors = marriageCertificatePayloadResponse.getError();
                if (marriageCertificateloadErrors && marriageCertificateloadErrors[0] && marriageCertificateloadErrors[0].message) {
                    console.log("Error message: " + marriageCertificateloadErrors[0].message);
                }
            } else {
                console.log("Unknown error");
            }
        });
        $A.enqueueAction(updateMarriageCertificatePayload);
    },
    handleOfficalCourtOrderUpload: function(component, event, helper) {
        component.set("v.officalCourtOrderUploadBool", true);
        var offCourtCertAzureDocUrl = event.getParam('url');
        var action = component.get('c.resetDropdown');
        $A.enqueueAction(action);
        var conId = component.get("v.contactId");
        var updateOfficialCourtOrderPayload = component.get("c.updateOfficialCourtOrderPayload");
        updateOfficialCourtOrderPayload.setParams({
            "contactId": conId,
            "azureDocUrl": offCourtCertAzureDocUrl
        });
        updateOfficialCourtOrderPayload.setCallback(this, function(officialCourtOrderPayloadResponse) {
            var officialCourtOrderPayloadState = officialCourtOrderPayloadResponse.getState();
            if (officialCourtOrderPayloadState === "SUCCESS") {
                var officialCourtOrderPayload = officialCourtOrderPayloadResponse.getReturnValue();
                component.set("v.payloadOfficalCourtOrder", JSON.stringify(officialCourtOrderPayload));
                component.set("v.officalCourtOrderId", "officalCourtOrderId");
                var thumbnailDisplayAction = component.find('officalCourtOrderDisplay').auraThumbnailLoader();
                $A.enqueueAction(thumbnailDisplayAction);
            } else if (officialCourtOrderPayloadState === "ERROR") {
                var officialCourtOrderErrors = officialCourtOrderPayloadResponse.getError();
                if (officialCourtOrderErrors && officialCourtOrderErrors[0] && officialCourtOrderErrors[0].message) {
                    console.log("Error message: " + officialCourtOrderErrors[0].message);
                }
            } else {
                console.log("Unknown error");
            }
        });
        $A.enqueueAction(updateOfficialCourtOrderPayload);
    },
    handleUsResidentAlienCardUpload: function(component, event, helper) {
        component.set("v.usResidentAlienCardUploadBool", true);
        var usResCourtCertAzureDocUrl = event.getParam('url');
        var action = component.get('c.resetDropdown');
        $A.enqueueAction(action);
        var conId = component.get("v.contactId");
        var updateUsResidentAlienCardPayload = component.get("c.updateUsResidentAlienCardPayload");
        updateUsResidentAlienCardPayload.setParams({
            "contactId": conId,
            "azureDocUrl": usResCourtCertAzureDocUrl
        });
        updateUsResidentAlienCardPayload.setCallback(this, function(usResidentAlienCardPayloadResponse) {
            var usResidentAlienCardPayloadState = usResidentAlienCardPayloadResponse.getState();
            if (usResidentAlienCardPayloadState === "SUCCESS") {
                var usResidentAlienCardPayload = usResidentAlienCardPayloadResponse.getReturnValue();
                component.set("v.payloadUsResidentAlienCard", JSON.stringify(usResidentAlienCardPayload));
                component.set("v.usResidentAlienCardId", "usResidentAlienCardId");
                var thumbnailDisplayAction = component.find('usResidentAlienCardDisplay').auraThumbnailLoader();
                $A.enqueueAction(thumbnailDisplayAction);
            } else if (usResidentAlienCardPayloadState === "ERROR") {
                var usResidentAlienCardErrors = usResidentAlienCardPayloadResponse.getError();
                if (usResidentAlienCardErrors && usResidentAlienCardErrors[0] && usResidentAlienCardErrors[0].message) {
                    console.log("Error message: " + usResidentAlienCardErrors[0].message);
                }
            } else {
                console.log("Unknown error");
            }
        });
        $A.enqueueAction(updateUsResidentAlienCardPayload);
    },
    handleUsNaturalizationCertificateUpload: function(component, event, helper) {
        component.set("v.usNaturalizationCertificateUploadBool", true);
        var usNaturalCertAzureDocUrl = event.getParam('url');
        var action = component.get('c.resetDropdown');
        $A.enqueueAction(action);
        var conId = component.get("v.contactId");
        var updateUsNaturalizationCertificatePayload = component.get("c.updateUsNaturalizationCertificatePayload");
        updateUsNaturalizationCertificatePayload.setParams({
            "contactId": conId,
            "azureDocUrl": usNaturalCertAzureDocUrl
        });
        updateUsNaturalizationCertificatePayload.setCallback(this, function(usNaturalizationCertificatePayloadResponse) {
            var usNaturalizationCertificatePayloadState = usNaturalizationCertificatePayloadResponse.getState();
            if (usNaturalizationCertificatePayloadState === "SUCCESS") {
                var usNaturalizationCertificatePayload = usNaturalizationCertificatePayloadResponse.getReturnValue();
                component.set("v.payloadUsNaturalizationCertificate", JSON.stringify(usNaturalizationCertificatePayload));
                component.set("v.naturalizationCertificateId", "naturalizationCertificateId");
                var thumbnailDisplayAction = component.find('usNaturalizationCertificateDisplay').auraThumbnailLoader();
                $A.enqueueAction(thumbnailDisplayAction);
            } else if (usNaturalizationCertificatePayloadState === "ERROR") {
                var usNaturalizationCertificateErrors = usNaturalizationCertificatePayloadResponse.getError();
                if (usNaturalizationCertificateErrors && usNaturalizationCertificateErrors[0] && usNaturalizationCertificateErrors[0].message) {
                    console.log("Error message: " + usNaturalizationCertificateErrors[0].message);
                }
            } else {
                console.log("Unknown error");
            }
        });
        $A.enqueueAction(updateUsNaturalizationCertificatePayload);
    },
    handleUsPassportCardUpload: function(component, event, helper) {
        component.set("v.usPassportCardUploadBool", true);
        var usPassCertAzureDocUrl = event.getParam('url');
        var action = component.get('c.resetDropdown');
        $A.enqueueAction(action);
        var conId = component.get("v.contactId");
        var updateUsPassportCardPayload = component.get("c.updateUsPassportCardPayload");
        updateUsPassportCardPayload.setParams({
            "contactId": conId,
            "azureDocUrl": usPassCertAzureDocUrl
        });
        updateUsPassportCardPayload.setCallback(this, function(usPassportCardPayloadResponse) {
            var usPassportCardPayloadState = usPassportCardPayloadResponse.getState();
            if (usPassportCardPayloadState === "SUCCESS") {
                var usPassportCardPayload = usPassportCardPayloadResponse.getReturnValue();
                component.set("v.payloadUsPassportCard", JSON.stringify(usPassportCardPayload));
                component.set("v.usPassportCardId", "usPassportCardId");
                var thumbnailDisplayAction = component.find('usPassportCardDisplay').auraThumbnailLoader();
                $A.enqueueAction(thumbnailDisplayAction);
            } else if (usPassportCardPayloadState === "ERROR") {
                var usPassportCardPayloadErrors = usPassportCardPayloadResponse.getError();
                if (usPassportCardPayloadErrors && usPassportCardPayloadErrors[0] && usPassportCardPayloadErrors[0].message) {
                    console.log("Error message: " + usPassportCardPayloadErrors[0].message);
                }
            } else {
                console.log("Unknown error");
            }
        });
        $A.enqueueAction(updateUsPassportCardPayload);
    },
    resetDropdown: function(component, event, helper) {
        var docType = component.get("v.docTypeSelected");
        var docTypesRemaining = component.get("v.docTypesRemaining");
        for (var x = 0; x < docTypesRemaining.length; x++) {
            if (docTypesRemaining[x] == docType) {
                docTypesRemaining.splice(x, 1);
                break;
            }
        }
        component.set("v.docTypesRemaining", docTypesRemaining);
        component.set("v.docTypeSelected", "--Select One--");

        if (docTypesRemaining.length == 1) {
            component.set("v.disableSelect", true);
        } else {
            component.set("v.disableSelect", false);
        }
    },

    handleRemovegovernmentId: function(component, event, helper) {
        component.set("v.governmentIssuedId", "");
    },

    handleRemovePhotoId: function(component, event, helper) {
        component.set("v.photoId", "");
    },

    handleRemovePassportExpiration: function(component, event, helper) {
        component.set("v.passportExpirationId", "");
		component.set("v.hasExpiration", false);
		var conId = component.get("v.contactId");
		var createPassportExpirationPayload = component.get("c.createPassportExpirationPayload");
		createPassportExpirationPayload.setParams({
			"contactId": conId
		});
		createPassportExpirationPayload.setCallback(this, function (passportPayloadExnResponse) {
			var passportPayloadExnState = passportPayloadExnResponse.getState();
			if (passportPayloadExnState === "SUCCESS") {
				var passportExnPayload = passportPayloadExnResponse.getReturnValue();
				component.set("v.payloadPassportExpiration", JSON.stringify(passportExnPayload));
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
    },

    handleRemovePassportTranslation: function(component, event, helper) {
        component.set("v.passportTranslationId", "");
        component.set("v.hasTranslation", false);
        var conId = component.get("v.contactId");
		var createPassportTranslationPayload = component.get("c.createPassportTranslationPayload");
		createPassportTranslationPayload.setParams({
			"contactId": conId
		});
		createPassportTranslationPayload.setCallback(this, function (passportPayloadTrnResponse) {
			var passportPayloadTrnState = passportPayloadTrnResponse.getState();
			if (passportPayloadTrnState === "SUCCESS") {
				var passportTrnPayload = passportPayloadTrnResponse.getReturnValue();
				component.set("v.payloadPassportTranslation", JSON.stringify(passportTrnPayload));
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
    },

    handleRemoveBirthCertificate: function(component, event, helper) {
        component.set("v.birthCertificateId", "");
        component.set("v.birthCertificateUploadBool", false);
        helper.updateDocTypesRemaining(component, helper);

        var conId = component.get("v.contactId");

        var createBirthCertificatePayload = component.get("c.createBirthCertificatePayload");
        createBirthCertificatePayload.setParams({
            "contactId": conId
        });
        createBirthCertificatePayload.setCallback(this, function(birthCertificatePayloadResponse) {
            var birthCertificatePayloadState = birthCertificatePayloadResponse.getState();
            if (birthCertificatePayloadState === "SUCCESS") {
                var birthCertificatePayload = birthCertificatePayloadResponse.getReturnValue();
                component.set("v.payloadBirthCertificate", JSON.stringify(birthCertificatePayload));


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
    },

    handleRemoveMarriageCertificate: function(component, event, helper) {
        component.set("v.marriageCertificateId", "");
        component.set("v.marriageCertificateUploadBool", false);
        helper.updateDocTypesRemaining(component, helper);

        var conId = component.get("v.contactId");

        var createMarriageCertificatePayload = component.get("c.createMarriageCertificatePayload");
        createMarriageCertificatePayload.setParams({
            "contactId": conId
        });
        createMarriageCertificatePayload.setCallback(this, function(marriageCertificatePayloadResponse) {
            var marriageCertificatePayloadState = marriageCertificatePayloadResponse.getState();
            if (marriageCertificatePayloadState === "SUCCESS") {
                var marriageCertificatePayload = marriageCertificatePayloadResponse.getReturnValue();
                component.set("v.payloadMarriageCertificate", JSON.stringify(marriageCertificatePayload));


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
    },

    handleRemoveCourtOrder: function(component, event, helper) {
        component.set("v.officalCourtOrderId", "");
        component.set("v.officalCourtOrderUploadBool", false);
        helper.updateDocTypesRemaining(component, helper);

        var conId = component.get("v.contactId");

        var createOfficialCourtOrderPayload = component.get("c.createOfficialCourtOrderPayload");
        createOfficialCourtOrderPayload.setParams({
            "contactId": conId
        });
        createOfficialCourtOrderPayload.setCallback(this, function(officialCourtOrderPayloadResponse) {
            var officialCourtOrderPayloadState = officialCourtOrderPayloadResponse.getState();
            if (officialCourtOrderPayloadState === "SUCCESS") {
                var officialCourtOrderPayload = officialCourtOrderPayloadResponse.getReturnValue();
                component.set("v.payloadOfficalCourtOrder", JSON.stringify(officialCourtOrderPayload));


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
    },

    handleRemoveResidentAlien: function(component, event, helper) {
        component.set("v.usResidentAlienCardId", "");
        component.set("v.usResidentAlienCardUploadBool", false);
        helper.updateDocTypesRemaining(component, helper);

        var conId = component.get("v.contactId");

        var createUsResidentAlienCardPayload = component.get("c.createUsResidentAlienCardPayload");
        createUsResidentAlienCardPayload.setParams({
            "contactId": conId
        });
        createUsResidentAlienCardPayload.setCallback(this, function(usResidentAlienCardPayloadResponse) {
            var usResidentAlienCardPayloadState = usResidentAlienCardPayloadResponse.getState();
            if (usResidentAlienCardPayloadState === "SUCCESS") {
                var usResidentAlienCardPayload = usResidentAlienCardPayloadResponse.getReturnValue();
                component.set("v.payloadUsResidentAlienCard", JSON.stringify(usResidentAlienCardPayload));


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
    },
    handleRemoveNaturalizationCertificate: function(component, event, helper) {
        component.set("v.naturalizationCertificateId", "");
        component.set("v.usNaturalizationCertificateUploadBool", false);
        helper.updateDocTypesRemaining(component, helper);

        var conId = component.get("v.contactId");

        var createUsNaturalizationCertificatePayload = component.get("c.createUsNaturalizationCertificatePayload");
        createUsNaturalizationCertificatePayload.setParams({
            "contactId": conId
        });
        createUsNaturalizationCertificatePayload.setCallback(this, function(usNaturalizationCertificatePayloadResponse) {
            var usNaturalizationCertificatePayloadState = usNaturalizationCertificatePayloadResponse.getState();
            if (usNaturalizationCertificatePayloadState === "SUCCESS") {
                var usNaturalizationCertificatePayload = usNaturalizationCertificatePayloadResponse.getReturnValue();
                component.set("v.payloadUsNaturalizationCertificate", JSON.stringify(usNaturalizationCertificatePayload));


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
    },

    handleRemovePassportCard: function(component, event, helper) {
        component.set("v.usPassportCardId", "");
        component.set("v.usPassportCardUploadBool", false);
        helper.updateDocTypesRemaining(component, helper);

        var conId = component.get("v.contactId");

        var createUsPassportCardPayload = component.get("c.createUsPassportCardPayload");
        createUsPassportCardPayload.setParams({
            "contactId": conId
        });
        createUsPassportCardPayload.setCallback(this, function(usPassportCardPayloadResponse) {
            var usPassportCardPayloadState = usPassportCardPayloadResponse.getState();
            if (usPassportCardPayloadState === "SUCCESS") {
                var usPassportCardPayload = usPassportCardPayloadResponse.getReturnValue();
                component.set("v.payloadUsPassportCard", JSON.stringify(usPassportCardPayload));


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
    },

    handleRestOfNameOnclick: function(component, event, helper) {
        if (event.getSource().get("v.checked") == true) {
            component.set("v.firstName", "");
        }
    },
    checkDOBValid: function(component, event, helper) {
        //New code - #user story 827 - 1/27/2021
        // get components for custom validations
        var dateOfBirth = helper.findComponentByName("fieldToValidate", "dateOfBirth", component);
        //New code
        var curDate = new Date();
        curDate.setHours(0, 0, 0, 0);
        var currYear = curDate.getFullYear();
        //For calculating the dob between 11 & 100 years old
        var dobPastElevenYears = Number(currYear) - 11;
        var dobPastHundYears = Number(currYear) - 100;
        var birthDate = new Date(dateOfBirth.get("v.value") + "T00:00:00");
        var bMonth = birthDate.getMonth();
        var bDay = birthDate.getDate();
        var tempElevenBirthDate = new Date(dobPastElevenYears, bMonth, bDay);
        var tempHundBirthDate = new Date(dobPastHundYears, bMonth, bDay);
        // verify date of birth in past
        if (birthDate > (new Date())) {
            dateOfBirth.setCustomValidity("Date of Birth cannot be in the future.");
            dateOfBirth.reportValidity();
        } else if (birthDate > tempElevenBirthDate) {
            dateOfBirth.setCustomValidity("Date of Birth should not be more recent than 11 years in the past.");
            dateOfBirth.reportValidity();
        } else if (birthDate < tempHundBirthDate) {
            dateOfBirth.setCustomValidity("Date of Birth should not be greater than 100 years in the past.");
            dateOfBirth.reportValidity();
        } else {
            dateOfBirth.setCustomValidity("");
        }
    },
    checkPPIssueDateValid: function(component, event, helper) {
        //New code - #user story 827 - 1/27/2021

        var curDate = new Date();
        curDate.setHours(0, 0, 0, 0);

        var currYear = curDate.getFullYear();
        var pastYear = Number(currYear) - 20;
        console.log('pastYear - ' + pastYear);

        var passportIssueDate = helper.findComponentByName("fieldToValidate", "passportIssueDate", component);
        var ppIssueDate = new Date(passportIssueDate.get("v.value") + "T00:00:00");
        var ppIssueMonth = ppIssueDate.getMonth();
        var ppIssueDay = ppIssueDate.getDate();
        var tempPPIssueDatePast = new Date(pastYear, ppIssueMonth, ppIssueDay);
        console.log('tempPPIssueDatePast - ' + tempPPIssueDatePast);
        // verify passport issue date in past
        if (Date.parse(passportIssueDate.get("v.value")) >= (new Date())) {
            passportIssueDate.setCustomValidity("Passport Issue Date cannot be in the future.");
            passportIssueDate.reportValidity();
        } else if (ppIssueDate < tempPPIssueDatePast) { //Issue Date cannot be older than 20 years in the past
            passportIssueDate.setCustomValidity("Passport Issue Date cannot be older than 20 years in the past.");
            passportIssueDate.reportValidity();
        } else {
            passportIssueDate.setCustomValidity("");
        }
    },
    checkPPExpDateValid: function(component, event, helper) {
        //New code - #user story 827 - 1/27/2021
        var curDate = new Date();
        curDate.setHours(0, 0, 0, 0);
        var currYear = curDate.getFullYear();
        var futureYear = Number(currYear) + 20;
        var passportExpirationDate = helper.findComponentByName("fieldToValidate", "passportExpiration", component);
        var ppExpirationDate = new Date(passportExpirationDate.get("v.value") + "T00:00:00");
        var ppExpMonth = ppExpirationDate.getMonth();
        var ppExpDay = ppExpirationDate.getDate();
        var tempPPExpirationDateFuture = new Date(futureYear, ppExpMonth, ppExpDay);
        // verify passport expiration data in future
        if (Date.parse(passportExpirationDate.get("v.value")) < (new Date())) {
            passportExpirationDate.setCustomValidity("Passport Expiration Date cannot be in the past.");
            passportExpirationDate.reportValidity();
        } else if (ppExpirationDate > tempPPExpirationDateFuture) { //Expiration Date cannot be greater than 20 years in the future
            passportExpirationDate.setCustomValidity("Passport Expiration Date cannot be greater than 20 years in the future.");
            passportExpirationDate.reportValidity();
        } else {
            passportExpirationDate.setCustomValidity("");
        }
    },

    handleSave: function(component, event, helper) {
        // use an array to capture all validation outcomes
        var allValid = [true];
        // validate standard validations attributes
        allValid.push(component.find("fieldToValidate").reduce(function(validSoFar, cmp) {
            cmp.reportValidity();
            return validSoFar && cmp.checkValidity();
        }, true));
        var distinctValid = Array.from(new Set(allValid));
        if (distinctValid.length == 1 && distinctValid[0] == true) {
            helper.doSave(component, helper);
        } else {
            component.set("v.disableButtons", false);
            var toast = $A.get("e.force:showToast");
            toast.setParams({
                "title": "Error!",
                "type": "error",
                "message": "You must complete all required fields before proceeding."
            });
            toast.fire();
            component.set("v.disableButtons", false);
            component.set("v.pageReady", true);
        }
    },

    handleCancel: function(component, event, helper) {
        var conId = component.get("v.contactId");
        var deleteExistingAsset = component.get("c.deleteExistingPassportAssets");
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
        window.open('/s/my-profile-identity-information', '_top');
    },

    onCancel: function(component, event, helper) {
        window.open('/s/my-profile-identity-information', '_top');
    },

    onConfirm: function(component, event, helper) {
        window.open('/s/my-profile-identity-information', '_top');
    },

    onPrevHitFromPayment: function(component, event, helper) {
        component.set("v.hasExistingChangeCase", false);
        component.set("v.pageReady", true);
        component.set("v.showShoppingCartLWC", false);
        component.set("v.showCompleteModal", false);
        component.set("v.governmentIssuedId", 'Test');
        component.set("v.photoId", 'photouploaded');
        component.set("v.disableButtons", false);
        helper.getContactDetailsUpdateCases(component, helper);
        helper.getContact(component, helper);
        helper.getCountries(component, helper);
        helper.getConfirmText(component, helper);
        helper.checkAndGetCSAssosiated(component, helper);
    },

    handleRemovePassport: function(component, event, helper) {
        component.set("v.governmentIssuedId", "");
        component.set("v.hasPassportDetails", false);
        var conId = component.get("v.contactId");

        var createPassportPayload = component.get("c.createPassportPayload");
        createPassportPayload.setParams({
            "contactId": conId
        });
        createPassportPayload.setCallback(this, function(passportPayloadResponse) {
            var passportPayloadState = passportPayloadResponse.getState();
            if (passportPayloadState === "SUCCESS") {
                var passportPayload = passportPayloadResponse.getReturnValue();
                component.set("v.payloadPassport", JSON.stringify(passportPayload));
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
    },

    handleRemovePhoto: function(component, event, helper) {
        component.set("v.photoId", "");
        component.set("v.hasPhotoDetails", false);
        var conId = component.get("v.contactId");

        var createPhotoPayload = component.get("c.createPhotoPayload");
        createPhotoPayload.setParams({
            "contactId": conId
        });
        createPhotoPayload.setCallback(this, function(photoPayloadResponse) {
            var photoPayloadState = photoPayloadResponse.getState();
            if (photoPayloadState === "SUCCESS") {
                var phototPayload = photoPayloadResponse.getReturnValue();
                component.set("v.payloadPhoto", JSON.stringify(phototPayload));
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
    },

})