({
    initialize : function (component, helper) {
			
	var getConId = component.get("c.getRunningContactId");
	getConId.setCallback(this, function(response) {
	var state = response.getState();
	if (state === "SUCCESS") {
		var conId = response.getReturnValue();
		component.set("v.contactId", conId);
		component.set("v.pageReady", true);
		
		//To load accepted Photo
		var getAssetPhotoPayload = component.get("c.createAcceptedPhotoPayload");
		getAssetPhotoPayload.setParams({
			"contactId": conId
		});
		var params = {
			"contactId": conId,
			"assetName": "Photo"
		};
		helper.apex(component, helper, "createAcceptedPhotoPayload", params)
			.then((result) => {
				var acceptedPhotoPayloadState = result.assetId;
				if (acceptedPhotoPayloadState !== "" && acceptedPhotoPayloadState !== null && acceptedPhotoPayloadState !== undefined ) {
					component.set("v.photoUploadedAccepted", "Yes");
					component.set("v.payloadPhotoAccepted", JSON.stringify(result));
					component.find('photo').auraThumbnailLoader();

				}
			})
		
		//To load accepted Passport
		var paramsPP = {
			"contactId": conId,
			"assetName": "Passport"
		};
		helper.apex(component, helper, "createAcceptedPhotoPayload", paramsPP)
		.then((resultPP) => {
			var acceptedPassportPayloadState = resultPP.assetId;
			if (acceptedPassportPayloadState !== "" && acceptedPassportPayloadState !== null && acceptedPassportPayloadState !== undefined ) {
				component.set("v.passportUploadedAccepted", "Yes");
				component.set("v.payloadPassportAccepted", JSON.stringify(resultPP));
				component.find('passport').auraThumbnailLoader();

			}
		})
	
	//To load accepted Passport Translation Page
		var paramsPPTrans = {
			"contactId": conId,
			"assetName": "Passport Translation Page"
		};
		helper.apex(component, helper, "createAcceptedPhotoPayload", paramsPPTrans)
		.then((resultPPTrans) => {
			var acceptedPassportPayloadState = resultPPTrans.assetId;
			if (acceptedPassportPayloadState !== "" && acceptedPassportPayloadState !== null && acceptedPassportPayloadState !== undefined ) {
				component.set("v.passportTranslationDone", "Yes");
				component.set("v.payloadPassportTranslationAccepted", JSON.stringify(resultPPTrans));
				component.find('passportTranslation').auraThumbnailLoader();

			}
		})

	//To load accepted Passport Expiration Page
		var paramsPPExpir = {
			"contactId": conId,
			"assetName": "Passport Expiration Page"
		};
		helper.apex(component, helper, "createAcceptedPhotoPayload", paramsPPExpir)
		.then((resultPPExpir) => {
			var acceptedPassportPayloadState = resultPPExpir.assetId;
			if (acceptedPassportPayloadState !== "" && acceptedPassportPayloadState !== null && acceptedPassportPayloadState !== undefined ) {
				component.set("v.passportExpirationDone", "Yes");
				component.set("v.payloadPassportExpirationAccepted", JSON.stringify(resultPPExpir));
				component.find('passportExpiration').auraThumbnailLoader();

			}
		})
		
		//To load accepted ID Form Notarized
		var paramsNotary = {
			"contactId": conId,
			"assetName": "ID Form Notarized"
		};
		helper.apex(component, helper, "createAcceptedPhotoPayload", paramsNotary)
		.then((resultNotary) => {
			var acceptedPassportPayloadState = resultNotary.assetId;
			if (acceptedPassportPayloadState !== "" && acceptedPassportPayloadState !== null && acceptedPassportPayloadState !== undefined ) {
				component.set("v.notarizedForm", "Yes");
				component.set("v.payloadNotarizedId", JSON.stringify(resultNotary));
				component.find('notarized').auraThumbnailLoader();
			}
		})
		

		helper.apex(component, helper, "checkForAcceptedDoc",'')
		.then((result) => {
			if (result == true ) {
				component.set("v.showNoResults", true);
			}
		})
	}
	else {
		console.log("Unknown error");
		}
	});
	$A.enqueueAction(getConId);	
	},
})