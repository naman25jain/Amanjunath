({
    doInit : function(component, event, helper) {    
    	helper.apex(component, helper, "checkIdentityVerification", null).then(function(response) {
				var completedIdCheck = response;
				console.log("ID CHECK: " + completedIdCheck);
				component.set("v.completedIdentityVerification", completedIdCheck);
    	});
    	
    	helper.apex(component, helper, "checkIdentityVerification_v2", null).then(function(response) {
				var accountStatus = response;
				component.set("v.accountStatus", accountStatus);
    	});

        helper.apex(component, helper, "getContactWithRecordType", null).then(function(response) {
                var contact = response;
                component.set("v.contactEcfmgId", contact.ECFMG_ID__c);
                component.set("v.contactRecordType", contact.RecordType.Name);
				if(contact.ECFMG_ID__c && contact.RecordType.Name == 'Applicant') component.set("v.showContactInfo", true);
        });
    
    	/*
    	var idVer = component.get("c.checkIdentityVerification");
		idVer.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var completedIdCheck = response.getReturnValue();
				console.log("ID CHECK: " + completedIdCheck);
				component.set("v.completedIdentityVerification", completedIdCheck);
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
		$A.enqueueAction(idVer);


    	var idVer2 = component.get("c.checkIdentityVerification_v2");
		idVer2.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var accountStatus = response.getReturnValue();
				component.set("v.accountStatus", accountStatus);
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
		$A.enqueueAction(idVer2);
		*/

    	helper.apex(component, helper, "getAllCases", null).then(function(response) {
				var cases = response;
				for(var x=0; x<cases.length; x++) {
					if (cases[x].Service__c == 'ECFMG_Certification') {
						component.set("v.certStatus", cases[x].Internal_Status__c);
						component.set("v.certPayment", cases[x].Payment_Made__c);
					} else if (cases[x].Service__c == 'EPIC') {
						console.log("EPIC");
						component.set("v.epicStatus", cases[x].Internal_Status__c);
						component.set("v.epicPayment", cases[x].Payment_Made__c);
					} else if (cases[x].Service__c == 'GEMx') {
						component.set("v.gemxStatus", cases[x].Internal_Status__c);
						component.set("v.gemxPayment", cases[x].Payment_Made__c);
					} else if (cases[x].Service__c == 'J1' && cases[x].RecordType.Name ==  'Identity Verification') {
						component.set("v.j1Status", cases[x].Internal_Status__c);
						component.set("v.j1Payment", cases[x].Payment_Made__c);
						component.set("v.j1RecordType", cases[x].RecordType.Name);
					} else if (cases[x].Service__c == 'J1' && cases[x].RecordType.Name !=  'Identity Verification') {
						component.set("v.j1InvitationStatus", cases[x].Internal_Status__c);
						component.set("v.j1InvitationRecordType", cases[x].RecordType.Name);
					}
				}


    	});
    	
    	/*
    	var caseL = component.get("c.getAllCases");
		caseL.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var cases = response.getReturnValue();
				for(var x=0; x<cases.length; x++) {
					if (cases[x].Service__c == 'ECFMG_Certification') {
						component.set("v.certStatus", cases[x].Status);
					} else if (cases[x].Service__c == 'EPIC') {
						console.log("EPIC");
						component.set("v.epicStatus", cases[x].Status);
					} else if (cases[x].Service__c == 'GEMx') {
						component.set("v.gemxStatus", cases[x].Status);
					} else if (cases[x].Service__c == 'J1') {
						component.set("v.j1Status", cases[x].Status);
					}
				}
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
		$A.enqueueAction(caseL);
		*/


    	helper.apex(component, helper, "getPrivacyAccepted", {"privacyAgreement": component.get("v.privacyAgreementName")}).then(function(response) {
				console.log("RESPONSE:" + response);
				if (response == null) {
					component.set("v.privacyAgreementAccepted", true);
				} else {
					component.set("v.privacyText", response);
				}
    	});
		helper.apex(component, helper, "checkRestrictOnAppIdent", null).then(function(response){
			var restrictCon = response;
			component.set("v.restrictionOnContact",restrictCon);
		});
    	/*
    	var getPrivacy = component.get("c.getPrivacyAccepted");
    	getPrivacy.setParams({"privacyAgreement": component.get("v.privacyAgreementName")})
		getPrivacy.setCallback(this, function(response) {
			var state = response.getState();
			console.log("STATE:" + response.getState());
			if (state === "SUCCESS") {
				console.log("RESPONSE:" + response.getReturnValue());
				if (response.getReturnValue() == null) {
					component.set("v.privacyAgreementAccepted", true);
				} else {
					component.set("v.privacyText", response.getReturnValue());
				}
			}
		});
		$A.enqueueAction(getPrivacy);
		*/
		
    },
    
    handleClickValidated : function(component, event, helper) {
    
    },
    
    handleClickNotValidated : function(component, event, helper) {
    	var runningUser = component.get("v.runningUser");
    	component.set("v.showModal", true);
    	var flow = component.find("Identity_Verification_Wizard");
    	var inputVariables = [{ name : "User_Id", type : "String", value: runningUser }];
    	flow.startFlow("Identity_Verification_Wizard", inputVariables);
    },
    
    closeModal : function(component, event, helper) {
    	window.open('https://devint-ecfmg.cs66.force.com/s/','_top');
    	//component.set("v.showModal", false);
    },
    /*
    acceptPrivacy : function(component, event, helper) {
    	var setPrivacy = component.get("c.setPrivacyAgreementAccepted");
		setPrivacy.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				component.set("v.privacyAgreementAccepted", true);
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
		$A.enqueueAction(setPrivacy);
    },
    */
    acceptPrivacy : function(component, event, helper) {
    	var setPrivacy = component.get("c.addPrivacy");
    	setPrivacy.setParams({"privacyAgreement": component.get("v.privacyAgreementName")})
		setPrivacy.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				location.reload(true);
				//component.set("v.privacyAgreementAccepted", true);
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
		$A.enqueueAction(setPrivacy);
    },
    
    rejectPrivacy : function(component, event, helper) {
    	//window.open('https://devint-ecfmg.cs66.force.com/s/','_top');
    },
    
    EPICLink : function(component, event, helper) {
		var restrictionExists = component.get("v.restrictionOnContact");
		if(restrictionExists){
				var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
				   type : 'error',
				   title : 'Restriction Applied',
				   message : 'You are currently restricted from accessing this service.  If you have any questions please contact ECFMG.'
				});
				toastEvent.fire();
		}
		else{
			window.open('/s/epicdetail','_top');
		}
	},
   
	CERTLink : function(component, event, helper) {
		var restrictionExists = component.get("v.restrictionOnContact");
		if(restrictionExists){
				var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
				   type : 'error',
				   title : 'Restriction Applied',
				   message : 'You are currently restricted from accessing this service.  If you have any questions please contact ECFMG.'
				});
				toastEvent.fire();
		}
		else{
			window.open('/s/ecfmgcertdetail','_top');
       }
   },
  
   GEMxLink : function(component, event, helper){
       var restrictionExists = component.get("v.restrictionOnContact");
       if(restrictionExists){
               var toastEvent = $A.get("e.force:showToast");
               toastEvent.setParams({
                  type : 'error',
                  title : 'Restriction Applied',
                  message : 'You are currently restricted from accessing this service.  If you have any questions please contact ECFMG.'
               });
               toastEvent.fire();
       }
       else{
           window.open('/s/gemxdetail','_top');
       }
   },
  
   J1Link : function(component, event, helper){
       var restrictionExists = component.get("v.restrictionOnContact");
       if(restrictionExists){
               var toastEvent = $A.get("e.force:showToast");
               toastEvent.setParams({
                  type : 'error',
                  title : 'Restriction Applied',
                  message : 'You are currently restricted from accessing this service.  If you have any questions please contact ECFMG.'
               });
               toastEvent.fire();
       }
       else{
           window.open('/s/j1detail','_top');
       }
   },
})