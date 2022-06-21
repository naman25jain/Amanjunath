({
    // Checking the Case Status is as "Sent for verification" or "Recent for verification"
    initialize: function(component, event, helper){        
        component.set("v.timedResendVar",true);
        component.set("v.responseMessage",'Loading...');
        var caseId = component.get("v.recordId");
		var action = component.get("c.checkCaseStatus");
		action.setParams({
			"caseId": caseId
		});
        action.setCallback(this, function(response){
            var state = response.getState();           
            if(state === "SUCCESS"){
                try{
                    var caseStatus = response.getReturnValue();
                    if(caseStatus === true){
                        component.set("v.responseMessage",'Loading...');
                        helper.getSendMethod(component, event, helper);                        
                    }else{ 
                        var staticLabel = $A.get("$Label.c.TimedResends_Check_Case_Status");
                        helper.showError(component, staticLabel, helper);
                        $A.get("e.force:closeQuickAction").fire();
                    }
                }catch(e){
                    helper.showError(component, e.message, helper);
                    $A.get("e.force:closeQuickAction").fire();
                }       
            }else{
                helper.handleErrors(component, response);
            }
        });
        $A.enqueueAction(action);
    },
    // Get Send Method. Send Method should be Paper or Email. Otherwise dont allow to further.
    getSendMethod: function(component, event, helper){
        component.set("v.responseMessage",'Loading...');
        var caseId = component.get("v.recordId");
        var sendReqAction = component.get("c.getSendMethod");
        sendReqAction.setParams({
            "caseId": caseId
        });
        sendReqAction.setCallback(this, function(responseReq){
            var stateSendRequest = responseReq.getState();
            if(stateSendRequest === "SUCCESS"){
                try{
                    component.set("v.responseMessage",'Loading...');
                    const responseArr = responseReq.getReturnValue().split(":");
                    var sendMethod = responseArr[0];
                    var sendReq = responseArr[1];
                    if(sendMethod === 'Paper' || sendMethod === 'Email'){
                        helper.updateCaseStatus(component, sendMethod, sendReq, helper);
                    }else if(sendMethod === 'norecord'){
                        var staticLabelNo = $A.get("$Label.c.TimedResends_No_Records");
                        helper.showError(component, staticLabelNo, helper);
                        $A.get("e.force:closeQuickAction").fire();
                    }else if(sendMethod === 'adhocsendrecord'){
                        component.set("v.responseMessage",'Loading...');
                        component.set("v.timedResendVar",false);
                    }else{
                        var staticLabelReq = $A.get("$Label.c.TimedResends_Get_Send_Method");
                        helper.showError(component, staticLabelReq, helper);
                        $A.get("e.force:closeQuickAction").fire(); 
                    }
                }catch(e){
                    helper.showError(component, e.message, helper);
                    $A.get("e.force:closeQuickAction").fire();
                }
            }else{
                helper.handleErrors(component, responseReq);
            }
        });
        $A.enqueueAction(sendReqAction);
    },
    // If Case Status is "Sent for verification" or "Recent for verification"
    updateCaseStatus: function(component, sendMethod, sendReq, helper){
        component.set("v.responseMessage",'Loading...');
        var caseId = component.get("v.recordId");
        var updatecaseAction = component.get("c.updateCaseStatus");
        updatecaseAction.setParams({
            "caseId": caseId,
            "sendMethod": sendMethod,
            "sendReq" : sendReq
        });
        updatecaseAction.setCallback(this, function(responseCase){
            var stateUpdateCase = responseCase.getState();
            if(stateUpdateCase === "SUCCESS"){
                try{
                    component.set("v.responseMessage",'Loading...');
                    var returnFlag = responseCase.getReturnValue();
                    if(returnFlag === true){
                        var staticLabelCaseStatus = $A.get("$Label.c.TimedResends_Update_Case_Status");
                        helper.showSuccess(component, staticLabelCaseStatus, helper);
                        $A.get("e.force:closeQuickAction").fire();
                        $A.get('e.force:refreshView').fire();                        
                    }else{
                        var staticLabelFail = $A.get("$Label.c.TimedResends_Case_Status_Failed");
                        helper.showError(component, staticLabelFail, helper);
                        $A.get("e.force:closeQuickAction").fire();
                    }
                }catch(e){
                    helper.showError(component, e.message, helper);
                    $A.get("e.force:closeQuickAction").fire();
                }
            }else{
                helper.handleErrors(component, responseCase);
            }
        });
        $A.enqueueAction(updatecaseAction);
    },
    showSuccess : function(component, message, helper){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success',
            message: message,
            duration:' 5000',
            key: 'info_alt',
            type: 'success',
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
    showError : function(component, message, helper){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error',
            message: message,
            duration:' 10000',
            key: 'info_alt',
            type: 'error',
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
    // Handling Errors
    handleErrors: function(component, response){
        var errors = response.getError();
        if(errors){
            if(errors[0] && errors[0].message){
                helper.showError(component, errors[0].message, helper);
            }
        }else{
            helper.showError(component, 'Unknown Error', helper);
        }
        helper.showError(component, e.message, helper);
        $A.get("e.force:closeQuickAction").fire();
    }
})