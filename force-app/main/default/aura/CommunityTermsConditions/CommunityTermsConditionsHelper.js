/**
 * Created by Matthew on 12/5/18.
 */
({
    handleUrlParams : function(component, event, helper) {
        //debugger;
        // TODO: Make generic param handler, without hard-coding specific param(s).
        var parsedUrl = new URL(window.location.href);
        var service = parsedUrl.searchParams.get("service");
        component.set("v.service", service);
    },
})