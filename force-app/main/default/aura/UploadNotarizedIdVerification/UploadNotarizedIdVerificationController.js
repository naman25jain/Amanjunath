({
	doInit  : function(component, event, helper) {
		var parsedUrl = new URL(window.location.href);
		var serviceName = parsedUrl.searchParams.get("service");
		var caseIdParam = parsedUrl.searchParams.get("id");
		if (caseIdParam != null)
			component.set("v.caseId", caseIdParam);

		if (serviceName != null)
			component.set("v.service", serviceName);

		var getConId = component.get("c.getContactId");
		getConId.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var conId = response.getReturnValue();
				component.set("v.contactId", conId);
				
					//logic to create Payload
		var createNotarizedPayload = component.get("c.createNotarizedPayload");
		createNotarizedPayload.setParams({
			'contactId': conId,'cs':caseIdParam
		});
		createNotarizedPayload.setCallback(this, function (notarizedPayloadResponse) {
			var notaryloadState = notarizedPayloadResponse.getState();
			if (notaryloadState === "SUCCESS") {
				
				var notarizedPayload = notarizedPayloadResponse.getReturnValue();
				if (notarizedPayload.assetId !== null && notarizedPayload.assetId !== undefined) {
				component.set("v.notarizedIdDone", "Yes");
				}
				component.set("v.payloadNotarizedId", JSON.stringify(notarizedPayload));
				component.find('notarized').auraThumbnailLoader();

			} else {
				console.log("Unknown error");
			}
		});
		$A.enqueueAction(createNotarizedPayload);

			}
		});
		$A.enqueueAction(getConId);

	
		
		var splitURL = parsedUrl.host.split("-");
		var baseURL = 'https://ecfmgb2--' + splitURL[0] + '--c.documentforce.com/';
		component.set("v.docBaseURL", baseURL);

		// populate the case number attribute (use cache since never changes)
		var params = { "service": serviceName, "recordType": "Identity Verification" };
		helper.apex(component, helper, "getCaseNumberByServiceAndRecordType", params)
		.then( (result) => {
		    component.set("v.caseNumber", result);
        });

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

	handleUploadFinishedNotarizedId: function (component, event) {
		component.set("v.notarizedIdDone", "Yes");
	},
	
	handleSave : function(component, event, helper) {
		var service = component.get("v.service");
		var notaryId = component.get("v.notarizedFormId");
		var cseId = component.get("v.caseId");
		var createAsset = component.get("c.createNotaryAsset");
		createAsset.setParams({'notaryId' : notaryId,'service' : service, 'caseId' : cseId});
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
	}
})