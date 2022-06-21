({
  doInit: function(component, event, helper) {
    var caseRT = component.get("v.caseRecordType");
    var caseServiceFilter = component.get("v.caseService");
    console.log(caseServiceFilter);
    var getCases = component.get("c.getCaseList");
    getCases.setParams({
      caseRecordType: caseRT,
      caseService: caseServiceFilter,
    });
    getCases.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var caseL = response.getReturnValue();
        console.log("HERE CASEL");
        console.log(caseL.length);
        component.set("v.cases", caseL);
        if (caseL.length > 0) {
          component.set("v.service", caseL[0].Service__c.replace("_", " "));
          component.set("v.externalStatus", caseL[0].External_Status__c);
          component.set("v.status", caseL[0].Internal_Status__c);
          component.set("v.actionRequired", caseL[0].Action_Required__c);
          component.set("v.caseId", caseL[0].Id);
          console.log("CaseID:" + caseL[0].Id);
          var progressMapping = component.get("c.getProgressIndicatorMappings");
          progressMapping.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
              var stepsAll = response.getReturnValue();
              var stepL = [];
              var curStep;
              for (var x = 0; x < stepsAll.length; x++) {
                //if(stepsAll[x].Case_Record_Type__c == caseRT && caseL[0].Case_Status__c == stepsAll[x].External_Case_Status__c) {
                if (
                  stepsAll[x].Case_Record_Type__c == caseRT &&
                  caseL[0].Internal_Status__c == stepsAll[x].Internal_Case_Status__c
                ) {
                  curStep = stepsAll[x].Step_Number__c;
                  component.set("v.currentStep", curStep);
                  break;
                }
              }
              for (var x = 0; x < stepsAll.length; x++) {
                if (
                  stepsAll[x].Primary_Step__c == true &&
                  stepsAll[x].Case_Record_Type__c == caseRT
                ) {
                  var step = {};
                  if (stepsAll[x].Step_Number__c == curStep) {
                    step.Internal_Display_Label__c = caseL[0].Internal_Status__c;
                    step.External_Display_Label__c =
                      stepsAll[x].External_Display_Label__c;
                  } else {
                    step.Internal_Display_Label__c =
                      stepsAll[x].Internal_Display_Label__c;
                    step.External_Display_Label__c =
                      stepsAll[x].External_Display_Label__c;
                  }
                  step.Step_Number__c = stepsAll[x].Step_Number__c;
                  step.Internal_Case_Status__c =
                    stepsAll[x].Internal_Case_Status__c;
                  step.External_Case_Status__c =
                    stepsAll[x].External_Case_Status__c;
                  stepL.push(step);
                }
                component.set("v.steps", stepL);
                component.set("v.hasCase", true);
              }
              helper
                .apex(component, helper, "getAllCases", null)
                .then(function(response) {
                  var cases = response;
                  var j1Payment = false;
                  var gemxPayment = false;
                  var epicPayment = false;
                  var certPayment = false;
                  for (var x = 0; x < cases.length; x++) {
                    if (cases[x].Service__c == "ECFMG_Certification") {
                      component.set("v.certStatus", cases[x].Internal_Status__c);
                      component.set("v.certPayment", cases[x].Payment_Made__c);
                      certPayment = cases[x].Payment_Made__c;
                    } else if (cases[x].Service__c == "EPIC") {
                      component.set("v.epicStatus", cases[x].Internal_Status__c);
                      component.set("v.epicPayment", cases[x].Payment_Made__c);
                      epicPayment = cases[x].Payment_Made__c;
                    } else if (cases[x].Service__c == "GEMx") {
                      component.set("v.gemxStatus", cases[x].Internal_Status__c);
                      component.set("v.gemxPayment", cases[x].Payment_Made__c);
                      gemxPayment = cases[x].Payment_Made__c;
                      //} else if (cases[x].Service__c == 'J1') {
                    } else if (
                      cases[x].Service__c == "J1" &&
                      cases[x].RecordType.Name == "Identity Verification"
                    ) {
                      component.set("v.j1Status", cases[x].Internal_Status__c);
                      component.set("v.j1Payment", cases[x].Payment_Made__c);
                      j1Payment = cases[x].Payment_Made__c;
                    }
                  }
                  if (
                    caseL[0].Service__c == "ECFMG_Certification" &&
                    (j1Payment || gemxPayment || epicPayment)
                  ) {
                    component.set("v.disableButtons", true);
                    console.log("HERE1");
                  } else if (
                    caseL[0].Service__c == "EPIC" &&
                    (j1Payment || gemxPayment || certPayment)
                  ) {
                    component.set("v.disableButtons", true);
                    console.log("HERE2");
                  } else if (
                    caseL[0].Service__c == "GEMx" &&
                    (j1Payment || certPayment || epicPayment)
                  ) {
                    component.set("v.disableButtons", true);
                    console.log("HERE3");
                  } else if (
                    caseL[0].Service__c == "J1" &&
                    (certPayment || gemxPayment || epicPayment)
                  ) {
                    component.set("v.disableButtons", true);
                    console.log("HERE4");
                  }
                });
            }
          });
          $A.enqueueAction(progressMapping);
        }
      }
    });
    $A.enqueueAction(getCases);

    helper
      .apex(component, helper, "getPrivacyAccepted", {
        privacyAgreement: "Privacy Agreement",
      })
      .then(function(response) {
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
  },

  handleDetails: function(component, event, helper) {
    var caseId = component.get("v.caseId");
    if (caseId != null) window.open("/s/case/" + caseId + "/detail", "_self");
  },

  handleCompleteInfo: function(component, event, helper){
    var restrictAppOnIdVer = component.get("v.restrictionOnContact");
    if(restrictAppOnIdVer){
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type : 'error',
        title : 'Restriction Applied',
        message : 'You are currently restricted from accessing this service.  If you have any questions please contact ECFMG.'
      });
      toastEvent.fire();
    }
    else{
      var service = component.get("v.service");
      if(service != null){
        window.open(
          "/s/community-biographics?service=" + service.replace(" ", "_"),
          "_self"
        );
      }
    }
  },

  handleNotaryInfo: function(component, event, helper){
    var restrictAppOnIdVer = component.get("v.restrictionOnContact");
    if(restrictAppOnIdVer){
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type : 'error',
        title : 'Restriction Applied',
        message : 'You are currently restricted from accessing this service.  If you have any questions please contact ECFMG.'
      });
      toastEvent.fire();
    }
    else{
      var service = component.get("v.service");
      var caseId = component.get("v.caseId");
      if(service != null){
    // Check if case is eligible for online notary
        helper
        .apex(component, helper, "isCaseEligibleForOnlineNotary", {
        caseId: caseId,
        })
        .then(function(response){
          if(response){
            window.open("/s/onlinenotaryconfirmation?id=" + caseId, "_self");
          }else{
            window.open(
            "/s/uploadnotarizedidform?service=" + service.replace(" ", "_"),
            "_self");
          }
        });
     }
    }
  },

  handleNotaryResubmit: function(component, event, helper){
    var restrictAppOnIdVer = component.get("v.restrictionOnContact");
    if(restrictAppOnIdVer){
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type : 'error',
        title : 'Restriction Applied',
        message : 'You are currently restricted from accessing this service.  If you have any questions please contact ECFMG.'
      });
      toastEvent.fire();
    }
    else{
      var service = component.get("v.service");
      var caseId = component.get("v.caseId");
      if(service != null){
        // Check if case is eligible for online notary
        helper
          .apex(component, helper, "isCaseEligibleForOnlineNotary", {
            caseId: caseId,
          })
          .then(function(response){
            if(response){
              window.open("/s/onlinenotaryconfirmation?id=" + caseId, "_self");
            }else{
              window.open(
                "/s/resubmit-notary?service=" + service.replace(" ", "_"),
                "_self"
              );
            }
          });
      }
    }
  },

  handleIDResubmit: function(component, event, helper){
    var restrictAppOnIdVer = component.get("v.restrictionOnContact");
    if(restrictAppOnIdVer){
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type : 'error',
        title : 'Restriction Applied',
        message : 'You are currently restricted from accessing this service.  If you have any questions please contact ECFMG.'
      });
      toastEvent.fire();
    }
    else{
      var service = component.get("v.service");
      if(service != null){
        window.open(
          "/s/resubmit-id?service=" + service.replace(" ", "_"),
          "_self"
        );
      }
    }
  },

  handleNotarySessionLinks: function(component, event, helper){
    var restrictAppOnIdVer = component.get("v.restrictionOnContact");
    if(restrictAppOnIdVer){
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type : 'error',
        title : 'Restriction Applied',
        message : 'You are currently restricted from accessing this service.  If you have any questions please contact ECFMG.'
      });
      toastEvent.fire();
    }
    else{
      var service = component.get("v.service");
      var caseId = component.get("v.caseId");
      if(service != null){
        window.open("/s/onlinenotarysessionlinks?id=" + caseId, "_self");
      }
    }
  },
});