({
    initialize : function (component, helper){
        component.set('v.columns', [
            {label: 'Case Number', fieldName: 'numberUrl', type: 'url', typeAttributes: {label: { fieldName: 'CaseNumber' }, target: '_blank'}},
            {label: 'Document Type', fieldName:'Document_Type__c', type: 'text'},
            {label: 'External Status', fieldName:'External_Status__c', type:'text'}]);
        helper.getSubCases(component,helper);
        helper.getCancelableCaseStatuses(component, helper)
            .then(
                   (result) => {
                       console.log(' getCancelableCaseStatuses :  ' + result );
                       // save statuses in attribute
                       component.set("v.cancelableStatuses", result);
                       helper.getCaseRestrictionDtl(component, helper);
                       // get case details
                       return helper.getCaseDetails(component, helper);
                   }
            )
            .then(
                // result of getCaseDetails
                (result) => {
                    console.log(' getCaseDetails :  ' + result );
                    console.log(' getCaseDetails.Internal_Status__c :  ' + result.Internal_Status__c );
                    console.log(' v.cancelableStatuses :  ' + component.get("v.cancelableStatuses") );
                    console.log(' includes :  ' + result );
                    // save case details in attribute
                    component.set("v.case", result);
                    component.set("v.recType", result.RecordType.DeveloperName);
                    var recVal = component.get("v.recType");
                    if(recVal == 'USMLE_Transcript' || recVal == 'Non_USMLE_Transcript'){
                        helper.getTrascriptRecs(component, helper);
                    }
                    else if(recVal == 'Exam_Registration'){
                        helper.getPEFormStatus(component, helper);
                        helper.getInternalStatus(component, helper);
                        helper.getPermitFormStatus(component, helper);
                        helper.getVisaLetterStatus(component, helper);
                        helper.getPEURL(component, helper);
                        helper.getLicenseInfo(component, helper);
                        helper.getStudOrGrad(component, helper);
                        helper.getExamRec(component, helper);
                        helper.getEthnicityInfo(component, helper);
                    }
                    else if(recVal == 'Region_Change'){
                        helper.getRecordsList(component, helper);
                    }
                    else if(recVal == 'Eligibility_Period_Extension'){
                        helper.getRecList(component, helper);
                    }
                    else if(recVal == 'Score_Recheck'){
                        helper.getFlagVal(component, helper);
                        helper.getAssetId(component, helper);                        
                        helper.getExamRegRecs(component, helper);
                    }
                    // determine if we show the cancel button
                    if(component.get("v.cancelableStatuses").includes(result.Internal_Status__c) && result.RecordType.DeveloperName != 'Application_For_Certification' && result.RecordType.DeveloperName != 'Exam_Registration' && result.RecordType.DeveloperName != 'Region_Change' && result.RecordType.DeveloperName != 'Eligibility_Period_Extension' && result.RecordType.DeveloperName != 'USMLE_Transcript' && result.RecordType.DeveloperName != 'Non_USMLE_Transcript' && result.RecordType.DeveloperName != 'Score_Recheck' && result.RecordType.DeveloperName != 'EPIC_Verification_Report_Request') {
                        component.set("v.showCancel", true);
                    }
                    //Determine whether data needs to fetched from Contact Association Type or Contact Association Type Staging
                    if(result.Internal_Status__c == 'Accepted' && result.RecordType.DeveloperName == 'Application_For_Certification'){
                        component.set("v.showExamRegActionButton", true);
                    }
                    var datesToCovert = [result.LastModifiedDate, result.CreatedDate];
                    helper.apex(component, helper, "getDateInUserZone", {"dateToConvertList":datesToCovert})
                    .then(
                        (rslt) => {
                            component.set("v.lastUpdatedDate", rslt[0]);
                            component.set("v.createdDate", rslt[1]);
                            // tell the page it's ready
                            component.set("v.pageReady", true);
                    });
                }
            );
	    helper.getCaseFiles(component, helper);
        helper.getAffirmationDetails(component, helper);
    },
    getTrascriptRecs : function (component, helper){
        var recId = component.get("v.recordId");
        var action = component.get("c.getTrascriptRecs");
        action.setParams({"caseId":recId});
        action.setCallback(this, function(response){
            var res = response.getReturnValue();
            component.set("v.transcriptList", res);
        });
        $A.enqueueAction(action);
    },
    getPEFormStatus : function (component, helper){
        var action = component.get("c.checkPEForm");
        action.setCallback(this, function(response){
            var res = response.getReturnValue();
            component.set("v.flag1", res);
        });
        $A.enqueueAction(action);
    },
    getInternalStatus : function (component, helper){
        var recId = component.get("v.recordId");
        var action = component.get("c.getInternalStatus");
        action.setParams({"caseId":recId});
        action.setCallback(this, function(response){
            var res = response.getReturnValue();
            component.set("v.flagInternalStatus", res);
        });
        $A.enqueueAction(action);
    },
    getPermitFormStatus : function (component, helper){
        var recId = component.get("v.recordId");
        var action = component.get("c.checkPermitForm");
        action.setParams({"caseId":recId});
        action.setCallback(this, function(response){
            var res = response.getReturnValue();
            component.set("v.flag2", res);
        });
        $A.enqueueAction(action);
    },
    getVisaLetterStatus : function (component, helper){
        var recId = component.get("v.recordId");
        var action = component.get("c.checkVisaLetter");
        action.setParams({"caseId":recId});
        action.setCallback(this, function(response){
            var res = response.getReturnValue();
            component.set("v.flag3", res);
        });
        $A.enqueueAction(action);
    },
    getPEURL : function (component, helper){
        var recId = component.get("v.recordId");
        var action = component.get("c.getPEFormURL");
        action.setParams({"caseId":recId});
        action.setCallback(this, function(response){
            var res = response.getReturnValue();
            component.set("v.PEUrl", res);
        });
        $A.enqueueAction(action);
    },
    downloadFileContent : function (component, helper){
        var fileNameUrl = component.get("v.PEUrl");
        let tempFileName = fileNameUrl;
        var action = component.get("c.getFileUrlWithSAS");
        action.setParams({"fileName":tempFileName});
        action.setCallback(this, function(response){
            var res = response.getReturnValue();
            var a = document.createElement("a");
            a.href = res;
            a.target = "_blank";
            a.setAttribute('download', fileNameUrl);
            a.click();
        });
        $A.enqueueAction(action);
    },
    downloadEPermitFileContent : function (component, helper){        
        let tempFileName = 'EPermit.pdf';
        var action = component.get("c.downloadEpermit");        
        action.setCallback(this, function(response){
            var bbody = response.getReturnValue();
            var byteCharacters = atob(bbody);
            var byteCharacters = atob(bbody.replace(/^data:image\/(png|jpeg|jpg);base64,/, ''));                
            const buf = new Array(byteCharacters.length);
            for (var i = 0; i != byteCharacters.length; ++i) buf[i] = byteCharacters.charCodeAt(i);      
            const view = new Uint8Array(buf);      
            const blob = new Blob([view], {
                type: 'application/octet-stream'
            });
            var a = document.createElement("a");
            a.href = window.URL.createObjectURL(blob);
            a.download=tempFileName;
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
        });
        $A.enqueueAction(action);
    },
    getRecList : function (component, helper){
        var recId = component.get("v.recordId");
        var action = component.get("c.getUpdatedEPEx");
        action.setParams({"caseId":recId});
        action.setCallback(this, function(response){
            var res = response.getReturnValue();
            component.set("v.examRecsList", res);
        });
        $A.enqueueAction(action);
    },
    getFlagVal : function (component, helper){
        var recId = component.get("v.recordId");
        var action = component.get("c.getAssetRec");
        action.setParams({"caseId":recId});
        action.setCallback(this, function(response){
            var res = response.getReturnValue();
            component.set("v.flag4",res);
        });
        $A.enqueueAction(action);
    },
    getLicenseInfo : function (component, helper){
        var action = component.get("c.contactStagingLicenseVal");
        action.setCallback(this, function(response){
            var res = response.getReturnValue();
            component.set("v.licVal", res);
        });
        $A.enqueueAction(action);
    },
    getAssetId : function (component, helper){
        var recIdVar = component.get("v.recordId");
        var actionVar = component.get("c.getAssetRecords");
        actionVar.setParams({"caseId":recIdVar});
        actionVar.setCallback(this, function(response){
            var res = response.getReturnValue();
            component.set("v.assetRecId", res[0]);
        });
        $A.enqueueAction(actionVar);
    },
    getExamRegRecs : function (component, helper){
        var recId = component.get("v.recordId");
        var action = component.get("c.getScoreReportInfo");
        action.setParams({"caseId":recId});
        action.setCallback(this, function(response){
            var res = response.getReturnValue();
            component.set("v.recListSR", res);
            component.set("v.examType", res.examType);
        });
        $A.enqueueAction(action);
    },
    getRecordsList : function (component, helper){
        var recId = component.get("v.recordId");
        var action = component.get("c.getExamRegistrationforSummary");
        action.setParams({"caseId":recId});
        action.setCallback(this, function(response){
            var res = response.getReturnValue();
            component.set("v.examRegistrationsList", res);
        });
        $A.enqueueAction(action);
    },
    getStudOrGrad : function (component, helper){
        var action = component.get("c.isApplicantStudentOrGraduate");
        action.setCallback(this, function(response){
            var res = response.getReturnValue();
            component.set("v.isGraduate", res);
        });
        $A.enqueueAction(action);
    },
    getExamRec : function (component, helper){
        var recId = component.get("v.recordId");
        var action = component.get("c.getExamRegistrations");
        action.setParams({"caseId":recId});
        action.setCallback(this, function(response){
            var res = response.getReturnValue();
            component.set("v.examRecs", res);
        });
        $A.enqueueAction(action);
    },
    getEthnicityInfo : function (component, helper){
        var action = component.get("c.getStagingRecord");
        action.setCallback(this, function(response){
            var res = response.getReturnValue();
            component.set("v.ethnicityInfo", res.ethnicity);
            component.set("v.nativeLanguage", res.nativeLanguage);
            component.set("v.socialSecNumber", res.socialSecurityNumber);
            component.set("v.nationalId", res.nationalIdentification);
            component.set("v.nationalCountry", res.nationalIDCountry);
            component.set("v.officiallyEnrolled", res.officiallyEnrolled);
            component.set("v.basicScience", res.basicSciencesRequirement);
            if(res.nativeLanguage == 'Other'){
                component.set("v.showOtherNativeLanguage", true);
                component.set("v.otherNativeLanguage", res.otherNativeLanguage);
            }
            component.set("v.otherLanguagesSpoken", res.otherLanguagesSpoken);
            if(res.otherLanguagesSpoken.split(";").includes('Other')){
                component.set("v.showOtherLanguagesSpoken", true);
                component.set("v.additionalLanguagesSpoken", res.addLanguagesSpoken);
            }
        });
        $A.enqueueAction(action);
    },
    getCancelableCaseStatuses : function(component, helper){
        return helper.apexCache(component, helper, "getCancelableCaseStatuses")
            .then(
                (result) => {
	                return result;
            });
    },
    getSubCases : function(component, helper){
        return helper.apex(component, helper, "getSubCases", { "appForCertCaseID" : component.get("v.recordId") })
        .then(
            (result) => {
                result.forEach(function(repond){
                repond.numberUrl = '/'+repond.Id;
            });
                component.set('v.data', result);
            });
    },                            
    getCaseDetails : function (component, helper){        
    	return helper.apex(component, helper, "getCaseDetails", { "caseId" : component.get("v.recordId") });
    },
    getCaseRestrictionDtl : function(component, helper){
        console.log('changesdeployed');
        return helper.apex(component, helper, "getCaseRestrictionDtl", { "caseId" : component.get("v.recordId") })
        .then( 
            (res) => {
                component.set('v.hypData', res);
            });
    },
    getAffirmationDetails : function (component, helper){ 
    	helper.apex(component, helper, "getAffirmationResults", {"serviceName":"Ignore", "caseId":component.get("v.recordId")})
	    .then(
	        (result) => {
			var errorList = result;
			console.log('ERRORS');
			console.log(errorList);
			var photoErrors = [];
			var photoExpiredError;
			var passportErrors = [];
			for (var x in errorList) {
				var rec = x.split(' ');
				if (rec.length == 2){
					if (rec[0] == 'Photo'){
						photoErrors.push(errorList[x]);
					} else if (rec[0] == 'Passport') {
						passportErrors.push(errorList[x]);
					}
					if (rec[1] == "ID_Form_Expired_Picklist__c" && rec[0] == 'Photo'){
					    photoExpiredError = 'The ECFMG Identification Form (EIF) that was previously created for you is no longer valid because your notarized EIF was not received within 6 months of the date it was created. As a result, your previously accepted photograph has been invalidated as well. Please upload a new photograph. Once your new photograph has been accepted, you will be able to access your new EIF.';
					    component.set('v.photoIsExpired', true);
                     }
				}
			}
			console.log(photoErrors);
			console.log(passportErrors);
			if (photoErrors.length > 0){
				component.set("v.showPhotoError", true);
                if(component.get("v.photoIsExpired")){
                    component.set("v.photoErrors", photoExpiredError);
                } else{
				    component.set("v.photoErrors", photoErrors);
				}
			}
			if (passportErrors.length > 0){
				component.set("v.showPassportError", true);
				component.set("v.passportErrors", passportErrors);
			}
		});
	},
    getCaseFiles : function (component, helper){
    	var fileIds = [];
    	fileIds.push(component.get("v.recordId"));
    	helper.apex(component, helper, "getFilesByParentIds", {"idList":fileIds})
	    .then(
	        (result) => {
				var fileL = result;
				console.log(fileL);
				component.set("v.files", fileL);
	    });
    },    
    cancelCase : function (component, helper){
    	component.set("v.pageReady", false);
        helper.apex(component, helper, "cancelCase", {"caseId":component.get("v.recordId"), "reason":component.get("v.case.Close_Reason__c"), "reasonNotes":component.get("v.case.External_Close_Comments__c")})
	    .then(
	        (result) => {
                if (result == 'Success'){
                    var toast = $A.get("e.force:showToast");
                    toast.setParams({
                        "title"   : "Success!",
                        "type"    : "success",
                        "message" : "Your request has been cancelled"
                    });
                    toast.fire();
    			} else if (result == 'Error: Closed'){ 
                    var toast = $A.get("e.force:showToast");
                    toast.setParams({
                        "title"   : "Error!",
                        "type"    : "error",
    					"message" : "Error: this request has already been closed"
                    });
                    toast.fire();
				} else {
                    var toast = $A.get("e.force:showToast");
                    toast.setParams({
                        "title"   : "Error!",
                        "type"    : "error",
                        "message" : result
                    });
                    toast.fire();
					//helper.getCaseDetails(component, helper);
    			}
                component.set("v.showCancelModal", false);
                helper.getCaseDetails(component, helper).then(
                   (result) => {
                	   component.set("v.showCancel", false);
                	   component.set("v.pageReady", true);
                   }
                );
	    });
    },
})