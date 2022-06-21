/**
 * Created by Matthew on 9/17/18.
 */
({
    handleNotificationEvent : function(component, event, helper) {
        var successMessage = event.getParam("successMessage");
        var errorMessage = event.getParam("errorMessage");
        var toast = $A.get("e.force:showToast");
        var title = "Uh oh";
        var type = "error";
        var message = "Someone forgot to set the notification message...";
        if(successMessage) {
            title = "Success!";
            type = "success";
            message = successMessage;
        }
        else if(errorMessage) {
            title = "Error!";
            type = "error";
            message = errorMessage;
        }
        toast.setParams({
            "title"   : title,
            "type"    : type,
            "message" : message
        });
        toast.fire();
    }
})