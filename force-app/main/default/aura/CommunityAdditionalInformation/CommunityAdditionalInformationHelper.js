({
    validateClerkship : function(component, event, helper) {
        allValid.push(component.find("clerkshipValidate").reduce(function (validSoFar, cmp) {
            cmp.reportValidity();
            return validSoFar && cmp.checkValidity();
        }, true));
        var distinctValid = Array.from(new Set(allValid));
        if(distinctValid.length == 1 && distinctValid[0] == true) {
            return true;
        } else {
            return false;
        }
    },
    //code added to get month values
    getMonthPicklistEntries : function(component, helper) {
        return helper.apex(component, helper, "getMonthPicklistEntries")
            .then(
                (result) => {                    
                    component.set("v.monthOptions", result);
                }
            );
    },
    resetClerkship : function(component, event, helper) {
        component.set("v.Dicipline__c", null);
        component.set("v.Name", null);
        component.set("v.Country_Code__c", null);
        component.set("v.Street__c", null);
        component.set("v.State_Code__c", null);
        component.set("v.Postal_Code__c", null);
        component.set("v.City__c", null);
        component.set("v.Supervising_Physician__c", null);
        component.set("v.Start_Month__c", null);
        component.set("v.Start_Year__c", null);
        component.set("v.End_Month__c", null);
        component.set("v.End_Year__c", null);
    },
    handleUrlParams : function(component, event, helper) {
        // TODO: Make generic param handler, without hard-coding specific param(s).
        var parsedUrl = new URL(window.location.href);
        var service = parsedUrl.searchParams.get("service");
        component.set("v.service", service);
        var mode = parsedUrl.searchParams.get("mode");
        component.set("v.mode", mode);
        if(component.get("v.mode") && component.get("v.mode").toLowerCase() == "summary") {
            component.set("v.showBackToSummary", true);
        }
        else {
            component.set("v.showBackToSummary", false);
        }
    },
    handleEthnicityLoad : function(component, event, helper, ethnicities) {
        if(ethnicities) {
            if(ethnicities.includes("Do not wish to respond")) {
                component.set("v.showEthnicities", false);
                component.set("v.ethnicityDualSelected", ["Do not wish to respond"]);
                component.set("v.ethNoAnswer", true);
                component.set("v.showEthnicities", false);
            }
            else {
                component.set("v.showEthnicities", true);
                component.set("v.ethnicityDualSelected", ethnicities.split(";"));
            }
        }
        else {
            component.set("v.ethnicityDualSelected", []);
        }
    },
    handleEthnicitySave : function(component, event, helper) {
        if(component.find("ethnicityNoAnswer").get("v.checked") == false) {
            var array = component.get("v.ethnicityDualSelected");
            var term = "Do not wish to respond";
            for (var i=array.length-1; i>=0; i--) {
                if (array[i] === term) {
                    array.splice(i, 1);
                    break;
                }
            }
            component.set("v.ethnicityDualSelected", array);
        }
    },
    handleCurrentlyEmployeedLoad : function(component, event, helper, currentlyEmployeed) {
        if(currentlyEmployeed) {
            if(currentlyEmployeed == "Yes, I am currently employed") {
                component.set("v.employed", true);
            }
            else {
                component.set("v.employed", false);
            }
        }
        else {
            component.set("v.employed", false);
        }
    },
    handlePermanentResidentLoad : function(component, event, helper, PermanentRes) {
        if(PermanentRes) {
            if(PermanentRes == "Yes") {
                component.set("v.permanentResident", true);
           }
            else {
                component.set("v.permanentResident", false);
            } 
        }
        else {
            component.set("v.permanentResident", false);
        }
    },
    PermYearIssued : function(component, event, helper){
        var inputCmp = component.find("prIssuedDate");
        var value = inputCmp.get("v.value");
        var validity = inputCmp.get("v.validity");        
        inputCmp.setCustomValidity("");
        inputCmp.reportValidity();
        if(validity.valid){
            var yearIssued = parseInt(value);
            var currYear = (new Date()).getFullYear();
            if(yearIssued > currYear){
                inputCmp.setCustomValidity("Pr Issued year cannot be future date");
                component.set("v.prIssuedDate","");
                   component.set("v.disableButtons", true);
            }
            else{
            	inputCmp.setCustomValidity("");
                component.set("v.disableButtons", false);
            }
            inputCmp.reportValidity();
        }   
    },
    /*
        This will search all components having the same id and return the first one matching the name specified.
    */
    findComponentByName : function(id, name, component)  {
        var cmps = component.find(id);
        for(var i = 0; i < cmps.length; i++) {
            if(cmps[i].get("v.name") == name) {
                return cmps[i];
            }
        }
    },
    validateOtherNativeLanguage : function(component, event, helper, url, isNext) {
        if(component.get("v.contact.Native_Language__c") == "Other" && (component.get("v.contact.Other_Native_Language__c") == "" || component.get("v.contact.Other_Native_Language__c") == undefined)){
			var toast = $A.get("e.force:showToast");
			toast.setParams({
	            "title"   : "Error!",
	            "type"    : "error",
	            "message" : "Other Native Language should be filled before saving!"
	        });
            toast.fire();
            component.set("v.disableButtons", false);
        }
        else{
        	helper.saveTest(component, event, helper, url, isNext);
        }
    },
    saveTest : function(component, event, helper, url, isNext) {
        helper.handleEthnicitySave(component, event, helper);
        component.set("v.disableButtons", true);
        var hasErrors = false;
        var employed = component.get("v.employed");
        var currYear = new Date().getFullYear();
        var currDate = new Date();
        if (employed == true || employed == 'true') {
            var allValid = component.find("fieldToValidate");
            for (var x=0; x<allValid.length; x++) {
                if(!allValid[x].get("v.validity").valid) {
                    allValid[x].showHelpMessageIfInvalid();
                    hasErrors = true;
                }
            }
            var empStartMonth = helper.findComponentByName("fieldToValidate", "startMonth", component);
            var empStartYear  = helper.findComponentByName("fieldToValidate", "startYear", component);
            var sMonth = empStartMonth.get("v.value");
            var sYear = empStartYear.get("v.value");
            var sNewStartDate = sMonth +' 01, '  + sYear;
            var newSDate = new Date(sNewStartDate);
            //New code for employment start date not in future.#user story 827
            if(Date.parse(newSDate) > Date.parse(currDate)){
                empStartYear.setCustomValidity("Employment Start Date cannot be in the future.");
                empStartYear.reportValidity();
                hasErrors = true;
            }else{
                empStartYear.setCustomValidity("");
            }
            // validate address component
            if(!component.find("employmentAddress").validate()) hasErrors = true;
        }
        if ((!hasErrors && isNext) || !isNext) {
            var ethnicity = component.get("v.ethnicityDualSelected");
            var ethnicityDual = "";
            for (var x=0; x<ethnicity.length; x++) {
                ethnicityDual += ethnicity[x] + ";";
            }
            var otherLangs = component.get("v.languageDualSelected");
            var otherLangsDual = "";
            for (var x=0; x<otherLangs.length; x++) {
                otherLangsDual += otherLangs[x] + ";";
            }
            var permResident = component.get("v.contact.Permanent_US_Resident__c");            
            var nativeLang = component.get("v.contact.Native_Language__c");
            var employed = component.get("v.contact.Currently_Employed__c");
            var prYearIssued = component.get("v.contact.PR_Year_Issued__c");
            var othNativeLang = component.get("v.showOtherNativeLanguage") == true ? component.get("v.contact.Other_Native_Language__c") : '';
            var othLangSpoken = component.get("v.showOtherLanguagesSpoken") == true ? component.get("v.contact.Additional_Languages_Spoken__c") : '';
            var updateInfo = component.get("c.updateAdditionalInfoV2");
            updateInfo.setParams({"ethnicity":ethnicityDual, "permResident":permResident,"prYearIssued":prYearIssued, "employed":employed, "service":component.get("v.service"), "validationPassed":!hasErrors});
            updateInfo.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var updateLangInfo = component.get("c.updateLanguageInfo");
                    updateLangInfo.setParams({"otherLanguages":otherLangsDual, "nativeLanguage":nativeLang, "otherNativeLanguage":othNativeLang, "otherLanguagesSpoken":othLangSpoken});
                    updateLangInfo.setCallback(this, function(res) {
                        var state1 = res.getState();
                    });
                    $A.enqueueAction(updateLangInfo);
                    if(url) {
                        window.open(url,'_top')
                    }
                    else {
                        var toast = $A.get("e.force:showToast");
                        toast.setParams({
                            "title"   : "Success!",
                            "type"    : "success",
                            "message" : "Your Additional Information Updates have been Saved!"
                        });
                        toast.fire();
                    }
                }
                else if (state === "INCOMPLETE") {			}
                    else if (state === "ERROR") {var errors = response.getError(); if (errors && errors[0] && errors[0].message) { console.log("Error message: " + errors[0].message);}
                                                } else {
                                                    console.log("Unknown error");
                                                }
                // enable button
                component.set("v.disableButtons", false);
            });
            $A.enqueueAction(updateInfo);
            console.log('component.get("v.employed") - '+component.get("v.employed"));
            if(component.get("v.employed")) {
                // create/update employer (association) record
                var employer = component.get("v.employer");
                var employerStr = JSON.stringify(employer);
                var updateEmp = component.get("c.updateEmployer");
                updateEmp.setParams({"empJSON":employerStr});
                updateEmp.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var toast = $A.get("e.force:showToast");
                        toast.setParams({
                            "title"   : "Success!",
                            "type"    : "success",
                            "message" : "Your Additional Information Updates have been Saved!"
                        });
                        toast.fire();
                    }
                    else if (state === "INCOMPLETE") {			}
                        else if (state === "ERROR") {var errors = response.getError(); if (errors && errors[0] && errors[0].message) { console.log("Error message: " + errors[0].message);}
                                                    } else {
                                                        console.error("Unknown error");
                                                    }
                    // enable button
                    component.set("v.disableButtons", false);
                });
                $A.enqueueAction(updateEmp);
            }
            else {
                
                // delete existing employer record (if any) and clear employer fields
                var deleteEmployer = component.get("c.deleteEmployer");
                deleteEmployer.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        // clear address
                        component.find("employmentAddress").reset();
                        // just clear these
                        helper.findComponentByName("fieldToValidate", "employmentPositionType", component).set("v.value", "");
                        helper.findComponentByName("fieldToValidate", "employmentTitle", component).set("v.value", "");
                        helper.findComponentByName("fieldToValidate", "employmentStartDate", component).set("v.value", "");
                        // this field may be hidden
                        if(helper.findComponentByName("fieldToValidate", "employmentClinicalDiscipline", component)) helper.findComponentByName("fieldToValidate", "employmentClinicalDiscipline", component).set("value.", "");
                    }
                });
                $A.enqueueAction(deleteEmployer);
            }
        } else {
            // enable button
            component.set("v.disableButtons", false);
            var toast = $A.get("e.force:showToast");
            toast.setParams({
                "title"   : "Error!",
                "type"    : "error",
                "message" : "You must complete all required fields before proceeding."
            });
            toast.fire();
        }
    },
})