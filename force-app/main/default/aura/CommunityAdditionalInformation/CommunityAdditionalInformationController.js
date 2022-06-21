({
	doInit  : function(component, event, helper) {
		//Load the Start Month picklist
        helper.getMonthPicklistEntries(component, helper);
		helper.handleUrlParams(component, event, helper);
		var getContactInfo = component.get("c.getContact");
		getContactInfo.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var contactRec = response.getReturnValue();
				component.set("v.contact", contactRec);
				component.set("v.languageDualSelected", contactRec.Other_Languages_Spoken__c ? contactRec.Other_Languages_Spoken__c.split(";") : []);
				component.set("v.showOtherNativeLanguage", contactRec.Native_Language__c == "Other" ? true : false);
                component.set("v.showOtherLanguagesSpoken", component.get("v.languageDualSelected").includes("Other") ? true : false);
                helper.handleEthnicityLoad(component, event, helper, contactRec.Ethnicity__c);
				helper.handleCurrentlyEmployeedLoad(component, event, helper, contactRec.Currently_Employed__c);
                helper.handlePermanentResidentLoad(component, event, helper, contactRec.Permanent_US_Resident__c);
            }
		});
		$A.enqueueAction(getContactInfo);
   
		var getEmployerInfo = component.get("c.getEmployer");
		getEmployerInfo.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var employerRec = response.getReturnValue();
				component.set("v.employer", employerRec);
		        if(employerRec.Type__c == 'Resident/Fellow/House Officer' || employerRec.Type__c == 'Physician') {
		            component.set("v.showDicipline", true);
		        } else  {
		            component.set("v.showDicipline", false);
		        }
			}
		});
		$A.enqueueAction(getEmployerInfo);

		var getClerkshipInfo = component.get("c.getClerkships");
		getClerkshipInfo.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var clerkships = response.getReturnValue();
				component.set("v.clerkships", clerkships);
			}
		});
		$A.enqueueAction(getClerkshipInfo);
		
        var curURL = new URL(window.location.href);
        var serviceName = curURL.searchParams.get("service");
		var getCaseInfo = component.get("c.getLatestCase");
		getCaseInfo.setParams({"service" : serviceName});
		getCaseInfo.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var caseList = response.getReturnValue();
				if(caseList.length > 0) {
					var cse = caseList[0];
					component.set("v.validationError", !cse.ValidationPassed_AdditionalInformation__c);
				}
			}
		});
		$A.enqueueAction(getCaseInfo);
    },

    handlepermResidentChecked : function(component, event, helper) {
        if(event.getSource().get("v.value") == "Yes"){
           component.set("v.permanentResident", true);
            component.find("prIssuedDate").set("v.value","");
           }else{
            component.set("v.permanentResident", false);
            component.set("v.disableButtons", false);
        }
        
    },
    validatePermYearIssued : function(component, event, helper){
         helper.PermYearIssued(component, event, helper);
        
    },

/*
    handleEmployeedChecked : function(component, event, helper) {
    	component.set("v.contact.Currently_Employed__c", event.getSource().get('v.value'));
    	component.set("v.employed", event.getSource().get('v.value'));
    },
*/

	handleCurrentlyEmployeedChanged : function(component, event, helper) {
	    if(event.getSource().get("v.value") == "Yes, I am currently employed") {
			component.set("v.employed", true);
		}
		else {
		    component.set("v.employed", false);
        }
	},

    showModal : function(component, event, helper) {
    	component.set("v.isOpen", true);
    },

    closeModal : function(component, event, helper) {
        helper.resetClerkship(component, event, helper);
    	component.set("v.isOpen", false);
    },

    handleDeleteClerkship : function(component, event, helper) {
    	var id = event.getSource().get("v.name");
    	if (id) {
			var delClerkship = component.get("c.removeClerkship");
			delClerkship.setParams({"recId":id});
			delClerkship.setCallback(this, function(response) {
				var state = response.getState();
				if (state === "SUCCESS") {
					var clerkships = component.get("v.clerkships");
					for(var x=0; x<clerkships.length; x++) {
						if (clerkships[x].Id == id) {
							if(x == 0) {
                                clerkships.splice(0,1);
                            } else {
                                clerkships.splice(x,x);
                            }
							component.set("v.clerkships", clerkships);
						}
					}
				}
				else if (state === "INCOMPLETE") {			}
				else if (state === "ERROR") {var errors = response.getError(); if (errors && errors[0] && errors[0].message) { console.log("Error message: " + errors[0].message);}
				} else {
					console.log("Unknown error");
			    }
			});
			$A.enqueueAction(delClerkship);
    	}
    },

    saveClerkship : function(component, event, helper) {
		// disable button to prevent multiple clicks
		//debugger;
		const CONASCTYPE_START_END_DAY = '01';
		component.find("saveClerkshipButton").set("v.disabled", true);
		var hasErrors = false;
		var allValid = component.find("clerkshipValidate");
		//check validity of start & end year 
		//check end date is greater than start date if not throww an error.
		var startMonth = helper.findComponentByName("clerkshipValidate", "startMonth", component);
		var startYear = helper.findComponentByName("clerkshipValidate", "startYear", component);
		var endMonth = helper.findComponentByName("clerkshipValidate", "endMonth", component);
		var endYear = helper.findComponentByName("clerkshipValidate", "endYear", component);
		
		var strNewStartDate = startMonth.get("v.value") + ' '+ CONASCTYPE_START_END_DAY + ', '  + startYear.get("v.value") + ' ';
		var strNewEndDate = endMonth.get("v.value") + ' '+ CONASCTYPE_START_END_DAY + ', '  + endYear.get("v.value") + ' ';
		
		var newStartDate = new Date(strNewStartDate);
		var newEndDate = new Date(strNewEndDate);
		
		if(Date.parse(newStartDate) > Date.parse(newEndDate)){
			endMonth.setCustomValidity("End Date cannot be before Start Date.");
			endMonth.reportValidity();
		}
		else {
			endMonth.setCustomValidity("");
		}
		for (var x=0; x<allValid.length; x++) {
			if(!allValid[x].get("v.validity").valid) {
				allValid[x].showHelpMessageIfInvalid();
				hasErrors = true;
			}
		}

        // validate address component
        if(!component.find("clerkshipAddress").validate()) hasErrors = true;
		if (!hasErrors) {
	 		var discipline = component.get("v.Dicipline__c");
			var hospitalName = component.get("v.Name");
			var country = component.get("v.Country_Code__c");
			var street = component.get("v.Street__c");
			var state = component.get("v.State_Code__c");
			var zip = component.get("v.Postal_Code__c");
			var city = component.get("v.City__c");
			var supervisor = component.get("v.Supervising_Physician__c");
			//var dateFrom = component.get("v.Date_From__c");
			//var dateTo = component.get("v.Date_To__c");
			//code added for Start Month & Year and End Month & Year
			var startMonth = component.get("v.Start_Month__c");
			var startYear = component.get("v.Start_Year__c");
			var endMonth = component.get("v.End_Month__c");
			var endYear = component.get("v.End_Year__c");

			var saveClerkship = component.get("c.addClerkship");
			//Added new fields to the method call
			//saveClerkship.setParams({"discipline":discipline, "hospitalName":hospitalName, "country":country, "street":street, "state":state, "zip":zip, "city":city, "supervisor":supervisor, "dateFrom":dateFrom, "dateTo":dateTo, "startMonth":startMonth,"startYear":startYear,"endMonth":endMonth,"endYear":endYear});
			saveClerkship.setParams({"discipline":discipline, "hospitalName":hospitalName, "country":country, "street":street, "state":state, "zip":zip, "city":city, "supervisor":supervisor, "startMonth":startMonth,"startYear":startYear,"endMonth":endMonth,"endYear":endYear});
			saveClerkship.setCallback(this, function(response) {
				var state = response.getState();
				if (state === "SUCCESS") {
					var newClerkship = response.getReturnValue();
					var clerkships = component.get("v.clerkships");
					clerkships.push(newClerkship);
					component.set("v.clerkships", clerkships);
					component.set("v.isOpen", false);
					helper.resetClerkship(component, event, helper);
				}
				else if (state === "INCOMPLETE") {			}
				else if (state === "ERROR") {var errors = response.getError(); if (errors && errors[0] && errors[0].message) { console.log("Error message: " + errors[0].message);}
				} else {

					console.log("Unknown error");
			    }
                component.find("saveClerkshipButton").set("v.disabled", false);
			});
			$A.enqueueAction(saveClerkship);
		} else {
		    // enable button so can fix errors.
		    component.find("saveClerkshipButton").set("v.disabled", false);
			var toast = $A.get("e.force:showToast");
			toast.setParams({
	            "title"   : "Error!",
	            "type"    : "error",
	            "message" : "You must complete all required fields before proceeding."
	        });
			toast.fire();
		}
    },

    handleEthnicityNoAnswerOnChange : function(component, event, helper) {
        if(event.getSource().get("v.checked") == true) {
            component.set("v.showEthnicities", false);
            component.set("v.ethnicityDualSelected", ["Do not wish to respond"]);
            //component.find("ethnicitySelect").set("v.value", []);
        } else  {
            component.set("v.showEthnicities", true);
        }
    },
    
    handleNativeLanguageChange : function(component, event, helper) {
        if(event.getParam("value") == "Other") {
            component.set("v.showOtherNativeLanguage", true);
        } else  {
            component.set("v.showOtherNativeLanguage", false);
        }
    },
    
    handleLanguageChange : function(component, event, helper) {
        var selectedLangs = event.getParam("value");
        if(selectedLangs.includes("Other")) {
            component.set("v.showOtherLanguagesSpoken", true);
        } else  {
            component.set("v.showOtherLanguagesSpoken", false);
        }
    },
    
    handlePositionTypeChange : function(component, event, helper) {
    	var posType = event.getSource().get("v.value");
        if(posType == 'Resident/Fellow/House Officer' || posType == 'Physician') {
            component.set("v.showDicipline", true);
        } else  {
            component.set("v.showDicipline", false);
        }
    },

    handleEthnicityChange : function(component, event, helper) {
        //console.log(event.getSource().get("v.value") );
    },

    handlePrevious : function(component, event, helper) {
        // disable button
        component.set("v.disableButtons", true);
        // TODO: Make generic param handler, without hard-coding specific param(s).
        if(component.get("v.service")) {
			window.open(helper.constants.COMMON_AUTHORITIES_URL + '?service=' + component.get("v.service"),'_top');
        }
        else {
			window.open(helper.constants.COMMON_AUTHORITIES_URL,'_top');
        }
    },

    handleNext : function(component, event, helper) {
        var url;
        // disable button
        component.set("v.disableButtons", true);
        if(component.get("v.service") && component.get("v.service").toLowerCase() == "epic") {
			url = helper.constants.SERVICE_EPIC_REVIEW_URL + '?service=' + component.get("v.service");
        } else if(component.get("v.service") && component.get("v.service").toLowerCase() == "ecfmg_certification") {
			url = helper.constants.SERVICE_CERT_REVIEW_URL + '?service=' + component.get("v.service");
        } else if(component.get("v.service") && component.get("v.service").toLowerCase() == "gemx") {
			url = helper.constants.SERVICE_GEMX_REVIEW_URL + '?service=' + component.get("v.service");
        } else if(component.get("v.service")) {
            url = helper.constants.COMMON_REVIEW_URL + '?service=' + component.get("v.service");
        }
        else {
			url = helper.constants.COMMON_REVIEW_URL;
        }
        helper.validateOtherNativeLanguage(component, event, helper, url, true);
	},


    handleSave : function(component, event, helper) {
		helper.validateOtherNativeLanguage(component, event, helper, '', false);
    },

    handleSaveMyProfile : function(component, event, helper) {
		helper.validateOtherNativeLanguage(component, event, helper, '', true);
    },

    handleSaveAndReturn : function(component, event, helper) {
        var url;
        // disable button
        component.set("v.disableButtons", true);
        if(component.get("v.service") && component.get("v.service").toLowerCase() == "epic") {
			url = helper.constants.SERVICE_EPIC_REVIEW_URL + '?service=' + component.get("v.service");
        } else if(component.get("v.service") && component.get("v.service").toLowerCase() == "ecfmg_certification") {
			url = helper.constants.SERVICE_CERT_REVIEW_URL + '?service=' + component.get("v.service");
        }  else if(component.get("v.service")) {
            url = helper.constants.COMMON_REVIEW_URL + '?service=' + component.get("v.service");
        }
        else {
            url = helper.constants.COMMON_REVIEW_URL;
		}
		helper.validateOtherNativeLanguage(component, event, helper, url, true);
	},

    handleCancelAndReturn : function(component, event, helper) {
        // disable button
        component.set("v.disableButtons", true);
        // TODO: Make generic param handler, without hard-coding specific param(s).
        if(component.get("v.service") && component.get("v.service").toLowerCase() == "epic") {
			window.open(helper.constants.SERVICE_EPIC_REVIEW_URL + '?service=' + component.get("v.service"),'_top');
        } else if(component.get("v.service") && component.get("v.service").toLowerCase() == "ecfmg_certification") {
			window.open(helper.constants.SERVICE_CERT_REVIEW_URL + '?service=' + component.get("v.service"),'_top');
        }  else if(component.get("v.service")) {
            window.open(helper.constants.COMMON_REVIEW_URL + '?service=' + component.get("v.service"),'_top');
        }
        else {
            window.open(helper.constants.COMMON_REVIEW_URL,'_top'); 
        }
	},
	
    handleCancel : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
	},

	handleInputOnBlur :  function(component, event, helper) {
		var field = event.getSource();
		if(field.get("v.value") && typeof field.get("v.value") == "string") field.set("v.value", field.get("v.value").trim());
		//get the name of the startYear- To clear the error message which is getting stuck
		if(field.get("v.name") =="startYear"){
			//get the validity & clear the message
			field.setCustomValidity("");
		}
    },

    handleChangeStartMonth: function (component, event) {
        // Get the "value" attribute on the selected option
        var selectedOptionValue = event.getParam("value");
        //var field = event.getSource();
        component.set("v.startMonth", selectedOptionValue);
    },
    handleChangeEndMonth: function (component, event) {
        // Get the "value" attribute on the selected option
        var selectedOptionValue = event.getParam("value");
        //var field = event.getSource();
        component.set("v.endMonth", selectedOptionValue);
    },

})