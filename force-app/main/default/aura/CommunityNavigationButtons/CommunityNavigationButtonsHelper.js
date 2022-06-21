/**
 * Created by Matthew on 11/14/18.
 */
({
    handleUrlParams : function(component, event, helper) {
        //debugger;
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
})