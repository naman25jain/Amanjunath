({
	doInit  : function(component, event, helper) {
		var parsedUrl = new URL(window.location.href);
		var serviceName = parsedUrl.searchParams.get("service");
		if (serviceName != null)
			component.set("v.service", serviceName);

		var caseIdParam = parsedUrl.searchParams.get("id");

		if (caseIdParam != null)
			component.set("v.caseId", caseIdParam);	


		// populate the case number attribute
		var params = { "service": serviceName, "recordType": "Identity Verification" };
		helper.apex(component, helper, "getCaseNumberByServiceAndRecordType", params)
			.then( (result) => {
			    component.set("v.caseNumber", result);
            });


		var getConId = component.get("c.getContactId");
		getConId.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var conId = response.getReturnValue();
				component.set("v.contactId", conId);
				
					// Get Previously Uploaded Notary (InComplete Asset)		
			var getIncompleteAssetNotaryPayload = component.get("c.getIncompleteAssetNotaryPayload");
			getIncompleteAssetNotaryPayload.setParams({
				'contactId': conId,'cs':caseIdParam
			});
			getIncompleteAssetNotaryPayload.setCallback(this, function (incompleteNotaryPayloadResponse) {
				var  incompleteNotaryPayloadState = incompleteNotaryPayloadResponse.getState();
				if (incompleteNotaryPayloadState === "SUCCESS") {
					var incompleteNotaryPayload = incompleteNotaryPayloadResponse.getReturnValue();
					
					if (incompleteNotaryPayload.assetId !== null && incompleteNotaryPayload.assetId !== undefined) {
						component.set("v.notaryUploadedPrevious", "Yes");
						
					}
					
					

					component.set("v.payloadNotaryPrevious", JSON.stringify(incompleteNotaryPayload));
					component.find('preNotary').auraThumbnailLoader();
				} else if (incompleteNotaryPayloadState === "ERROR") {
					var incompleteNotaryPayloadErrors = incompleteNotaryPayloadResponse.getError();
					if (incompleteNotaryPayloadErrors && incompleteNotaryPayloadErrors[0] && incompleteNotaryPayloadErrors[0].message) {
						console.log("Error message: " + incompleteNotaryPayloadErrors[0].message);
					}
				} else {
					console.log("Unknown error");
				}
			});
			$A.enqueueAction(getIncompleteAssetNotaryPayload);

			// Newly Created Notary
			var createNotaryPayload = component.get("c.createNotaryPayload");
			createNotaryPayload.setParams({
				'contactId': conId,'cs':caseIdParam
			});
			createNotaryPayload.setCallback(this, function (NotaryPayloadResponse) {
				var NotaryPayloadState = NotaryPayloadResponse.getState();
				if (NotaryPayloadState === "SUCCESS") {
					var NotaryPayload = NotaryPayloadResponse.getReturnValue();
					if (NotaryPayload.assetId !== null && NotaryPayload.assetId !== undefined) {
						component.set("v.notaryUploadedNew", "Yes");
					}
					component.set("v.payloadNotaryNew", JSON.stringify(NotaryPayload));
					component.find('notary').auraThumbnailLoader();
				} else if (NotaryPayloadState === "ERROR") {
					var NotaryPayloadErrors = NotaryPayloadResponse.getError();
					if (NotaryPayloadErrors && NotaryPayloadErrors[0] && NotaryPayloadErrors[0].message) {
						console.log("Error message: " + NotaryPayloadErrors[0].message);
					}
				} else {
					console.log("Unknown error");
				}
			});
			$A.enqueueAction(createNotaryPayload);
			

			}
		});
		$A.enqueueAction(getConId);	

		var curFiles = component.get("c.getCurrentAssetFiles");
		curFiles.setParams({'serviceName' : serviceName});
		curFiles.setCallback(this, function(response) {
			var fileList = response.getReturnValue();
			console.log(fileList);
			for (var x=0; x<fileList.length; x++) {
				if(fileList[x].ContentDocument.Title == 'Notarized ID Form')
				component.set("v.notarizedFormIdOld", fileList[x].ContentDocumentId);
				break;
			}
		});
		$A.enqueueAction(curFiles);

	
			
		var affirmationResults = component.get("c.getAffirmationResults");
		affirmationResults.setParams({'serviceName' : serviceName, 'caseId': caseIdParam});
		affirmationResults.setCallback(this, function(response) {
			var errorList = response.getReturnValue();
			console.log('ERRORS');
			console.log(errorList);
			var photoErrors = [];
			var passportErrors = [];
			var notaryErrors = [];
			for (var x in errorList) {
				var rec = x.split(' ');
				if (rec.length == 2) {
					if (rec[0] == 'Photo') {
						photoErrors.push(errorList[x]);
					} else if (rec[0] == 'Passport') {
						passportErrors.push(errorList[x]);
					} else {
						console.log("Notary ERROR:" + errorList[x]);
						notaryErrors.push(errorList[x]);
					}
				}
			}
			console.log(photoErrors);
			console.log(passportErrors);
			console.log(notaryErrors);
			if (photoErrors.length > 0) {
				component.set("v.showPhotoError", true);
				component.set("v.photoErrors", photoErrors);
			}
			if (passportErrors.length > 0) {
				component.set("v.showPassportError", true);
				component.set("v.passportErrors", passportErrors);
			}
			if (notaryErrors.length > 0) {
				component.set("v.showNotaryError", true);
				component.set("v.notaryErrors", notaryErrors);
			}
		});
		$A.enqueueAction(affirmationResults);

		
	},
	handleUploadFinishedNotary: function (component, event) {
		component.set("v.notaryUploadedNew", "Yes");
	},

	handleFileViewer: function (component, event) {
        var viewFile = component.get("c.getAzureUrl");
		viewFile.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS" && response.getReturnValue()) {
				window.open(response.getReturnValue());
			}
            else{
                var toast = $A.get("e.force:showToast");
                toast.setParams({
                    "title"   : "Error!",
                    "type"    : "error",
                    "message" : "Error: EIF has not created."
                });
                toast.fire();
            }
		});
		$A.enqueueAction(viewFile);
	},
	
	handleSave : function(component, event, helper) {
		var service = component.get("v.service");
		var notaryId = component.get("v.notarizedFormId");
		var cas = component.get("v.caseId");
		var createAsset = component.get("c.resubmitNotaryAsset");		
		createAsset.setParams({'notaryId' : notaryId,'service' : service, 'caseId': cas});
		createAsset.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				component.set("v.showCompleteModal", true);
				
			}
		});
		$A.enqueueAction(createAsset);
	},
	
	cancelAsset :  function(component, event, helper) {
		var contactId = component.get("v.contactId");
		var delAsset = component.get("c.deleteExistingNotarizedAsset");
		delAsset.setParams({'contactId' : contactId});
		delAsset.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				window.open('/s/','_top');
			}
		});
		$A.enqueueAction(delAsset);
        
	},

    redirectHome :  function(component, event, helper) {
        window.open('/s/','_top');
    },
})